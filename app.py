import os
import uuid
from datetime import datetime, timedelta
from functools import wraps
from dotenv import load_dotenv
import traceback

import psycopg2
from psycopg2.extras import RealDictCursor

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from flask import Blueprint  # ← Добавили
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename

from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'секретный-ключ-по-умолчанию')

app.config["JWT_SECRET_KEY"] = os.getenv('JWT_SECRET_KEY', 'super-secret-key-change-in-production')
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=24)

jwt = JWTManager(app)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', 5432),
    'database': os.getenv('DB_NAME', 'TechInstHub'),
    'user': os.getenv('DB_USER', 'iam_user'),
    'password': os.getenv('DB_PASSWORD', ''),
    'client_encoding': 'UTF8'
}

UPLOAD_FOLDER = 'static/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def is_safe_select_query(query: str) -> bool:
    """Проверяет, что запрос является только SELECT (без модификации данных)."""
    query_upper = query.strip().upper()
    # Запрещённые ключевые слова
    dangerous = {'DROP', 'DELETE', 'UPDATE', 'INSERT', 'ALTER', 'TRUNCATE', 'CREATE', 'REPLACE', 'MERGE'}
    if not query_upper.startswith('SeLECT'):
        return False
        # Простейшая проверка на опасные слова внутри запроса
    for word in dangerous:
        # Ищем как отдельное слово (с пробелами/знаками препинания)
        if word in query_upper.split():
            return False
    return True

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# ----- Глобальная защита (доступ только к login, register и статике) -----
@app.before_request
def require_login():
    public_routes = ['login', 'register', 'static']
    if request.endpoint in public_routes:
        return
    if 'user_id' not in session:
        flash('Пожалуйста, войдите в систему.', 'error')
        return redirect(url_for('login'))

# ----- Вспомогательные функции -----
def get_db_connection():
    return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)

def log_action(user_id, action, details=None, ip_address=None):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO logs (user_id, action, details, ip_address, created_at)
        VALUES (%s, %s, %s, %s, NOW())
    """, (user_id, action, details, ip_address))
    conn.commit()
    cur.close()
    conn.close()

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if session.get('role') != 'admin':
            flash('Доступ запрещён.', 'error')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated

def teacher_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if session.get('role') not in ('teacher', 'admin'):
            flash('Только для преподавателей.', 'error')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated

# ----- Проверка и создание колонки max_students в projects (если её нет) -----
def ensure_max_students_column():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='projects' AND column_name='max_students'
        """)
        if not cur.fetchone():
            cur.execute("ALTER TABLE projects ADD COLUMN max_students INTEGER DEFAULT 1")
            conn.commit()
            print("✅ Добавлена колонка max_students в таблицу projects")
    except Exception as e:
        print("⚠️ Не удалось добавить колонку max_students:", e)
    finally:
        cur.close()
        conn.close()

# ----- Функция создания/добавления в групповой чат проекта -----
def ensure_project_chat(project_id, tutor_id, student_id=None):
    """Создаёт групповой чат для проекта, если его нет, и добавляет участников."""
    conn = get_db_connection()
    cur = conn.cursor()
    # Получаем название проекта
    cur.execute("SELECT title FROM projects WHERE id=%s", (project_id,))
    proj = cur.fetchone()
    chat_name = proj['title'] if proj else "Проект"
    # Проверяем, существует ли уже чат для этого проекта
    cur.execute("SELECT id FROM chats WHERE name=%s AND is_group=TRUE", (chat_name,))
    chat = cur.fetchone()
    if chat:
        chat_id = chat['id']
    else:
        chat_id = str(uuid.uuid4())
        cur.execute("""
            INSERT INTO chats (id, name, is_group, created_at, updated_at)
            VALUES (%s, %s, TRUE, NOW(), NOW())
        """, (chat_id, chat_name))
    # Добавляем преподавателя (если ещё не добавлен)
    cur.execute("SELECT 1 FROM chat_members WHERE chat_id=%s AND user_id=%s", (chat_id, tutor_id))
    if not cur.fetchone():
        cur.execute("INSERT INTO chat_members (chat_id, user_id, created_at) VALUES (%s, %s, NOW())", (chat_id, tutor_id))
    # Добавляем студента, если передан
    if student_id:
        cur.execute("SELECT 1 FROM chat_members WHERE chat_id=%s AND user_id=%s", (chat_id, student_id))
        if not cur.fetchone():
            cur.execute("INSERT INTO chat_members (chat_id, user_id, created_at) VALUES (%s, %s, NOW())", (chat_id, student_id))
    conn.commit()
    cur.close()
    conn.close()
    return chat_id

# ----- Создание администратора при первом запуске -----
def create_admin_if_not_exists():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        admin_email = os.getenv('ADMIN_EMAIL', 'admin@techinsthub.com')
        admin_password = os.getenv('ADMIN_PASSWORD', 'Admin123!')
        admin_name = os.getenv('ADMIN_NAME', 'Admin')
        admin_surname = os.getenv('ADMIN_SURNAME', 'Admin')
        cur.execute("SELECT 1 FROM users WHERE email = %s", (admin_email,))
        if not cur.fetchone():
            admin_id = str(uuid.uuid4())
            hashed = generate_password_hash(admin_password)
            cur.execute("""
                INSERT INTO users (id, email, password_hash, first_name, last_name, role, is_active, is_verified, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, 'admin', TRUE, TRUE, NOW(), NOW())
            """, (admin_id, admin_email, hashed, admin_name, admin_surname))
            cur.execute("""
                INSERT INTO admins (user_id, admin_level, created_at, updated_at)
                VALUES (%s, 1, NOW(), NOW())
            """, (admin_id,))
            conn.commit()
            print(f"✅ Администратор создан: {admin_email} / {admin_password}")
        else:
            print("👤 Администратор уже существует.")
    except Exception as e:
        print("❌ Ошибка при создании админа:", e)
    finally:
        cur.close()
        conn.close()

# ----- Маршруты -----
@app.route('/')
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.id, p.title, p.description, p.deadline, p.difficulty, p.max_students,
               u.first_name AS name, u.last_name AS surname,
               (SELECT image_url FROM images WHERE entity_type='project' AND entity_id=p.id ORDER BY sort_order LIMIT 1) AS image_url
        FROM projects p
        JOIN users u ON p.id_tutor = u.id
        WHERE p.status = 'открыт'
        ORDER BY p.created_at DESC
        LIMIT 3
    """)
    projects = cur.fetchall()
    cur.execute("""
        SELECT id, title, content, image_url, published_at
        FROM news_feed
        WHERE type = 'news'
        ORDER BY published_at DESC
        LIMIT 3
    """)
    news = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', projects=projects, news=news)

@app.route('/catalog')
def catalog():
    search = request.args.get('search', '')
    topic_id = request.args.get('topic', '')
    conn = get_db_connection()
    cur = conn.cursor()
    query = """
        SELECT p.id, p.title, p.description, p.deadline, p.difficulty, p.max_students,
               u.first_name AS name, u.last_name AS surname, p.topic_id,
               (SELECT image_url FROM images WHERE entity_type='project' AND entity_id=p.id ORDER BY sort_order LIMIT 1) AS image_url
        FROM projects p
        JOIN users u ON p.id_tutor = u.id
        WHERE p.status = 'открыт'
    """
    params = []
    if search:
        query += " AND p.title ILIKE %s"
        params.append(f'%{search}%')
    if topic_id:
        query += " AND p.topic_id = %s"
        params.append(topic_id)
    query += " ORDER BY p.created_at DESC"
    cur.execute(query, params)
    projects = cur.fetchall()
    cur.execute("SELECT id, name FROM topics ORDER BY name")
    topics = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('catalog_projects.html', projects=projects, topics=topics,
                           search_query=search, selected_topic=topic_id)

@app.route('/project/<uuid:project_id>')
def project_detail(project_id):
    project_id_str = str(project_id)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.*, u.first_name AS tutor_name, u.last_name AS tutor_surname,
               t.name AS topic_name,
               (SELECT image_url FROM images WHERE entity_type='project' AND entity_id=p.id ORDER BY sort_order LIMIT 1) AS image_url
        FROM projects p
        JOIN users u ON p.id_tutor = u.id
        LEFT JOIN topics t ON p.topic_id = t.id
        WHERE p.id = %s
    """, (project_id_str,))
    project = cur.fetchone()
    if not project:
        flash('Проект не найден.', 'error')
        return redirect(url_for('catalog'))
    has_accepted = False
    if session.get('role') == 'student' and session.get('user_id'):
        cur.execute("""
            SELECT 1 FROM applications
            WHERE project_id = %s AND student_id = %s AND status = 'accepted'
        """, (project_id_str, session['user_id']))
        has_accepted = cur.fetchone() is not None
    cur.close()
    conn.close()
    return render_template('project_card.html', project=project, has_accepted_application=has_accepted)

@app.route('/apply/<uuid:project_id>', methods=['POST'])
def apply_project(project_id):
    if session.get('role') != 'student':
        flash('Только студенты могут подавать заявки.', 'error')
        return redirect(url_for('project_detail', project_id=project_id))
    project_id_str = str(project_id)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM applications WHERE project_id = %s AND student_id = %s",
                (project_id_str, session['user_id']))
    if cur.fetchone():
        flash('Вы уже подали заявку на этот проект.', 'warning')
    else:
        cur.execute("""
            INSERT INTO applications (id, project_id, student_id, status, applied_at, updated_at)
            VALUES (%s, %s, %s, 'pending', NOW(), NOW())
        """, (str(uuid.uuid4()), project_id_str, session['user_id']))
        conn.commit()
        log_action(session['user_id'], 'apply', f'Заявка на проект {project_id}')
        flash('Заявка отправлена преподавателю.', 'success')
    cur.close()
    conn.close()
    return redirect(url_for('project_detail', project_id=project_id))

@app.route('/complete/<uuid:project_id>', methods=['POST'])
def complete_project(project_id):
    if session.get('role') != 'student':
        flash('Недостаточно прав.', 'error')
        return redirect(url_for('project_detail', project_id=project_id))
    project_id_str = str(project_id)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT 1 FROM applications
        WHERE project_id = %s AND student_id = %s AND status = 'accepted'
    """, (project_id_str, session['user_id']))
    if cur.fetchone():
        cur.execute("UPDATE projects SET status = 'завершён', updated_at = NOW() WHERE id = %s", (project_id_str,))
        conn.commit()
        log_action(session['user_id'], 'complete_project', f'Проект {project_id} завершён')
        flash('Проект успешно завершён!', 'success')
    else:
        flash('Вы не можете завершить этот проект.', 'error')
    cur.close()
    conn.close()
    return redirect(url_for('project_detail', project_id=project_id))

@app.route('/my_projects')
@teacher_required
def my_projects():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT id, title, status, created_at, max_students
        FROM projects
        WHERE id_tutor = %s
        ORDER BY created_at DESC
    """, (session['user_id'],))
    projects = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('my_projects.html', projects=projects)

@app.route('/add_project', methods=['GET', 'POST'])
@teacher_required
def add_project():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, name FROM topics ORDER BY name")
    topics = cur.fetchall()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form.get('description', '')
        requirements = request.form.get('requirements', '')
        details = request.form.get('details', '')
        topic_id = request.form.get('topic_id') or None
        difficulty = request.form.get('difficulty', 'легкий')
        deadline = request.form.get('deadline') or None
        max_students = request.form.get('max_students', 1)
        try:
            max_students = int(max_students)
        except:
            max_students = 1
        image_file = request.files.get('image')
        image_url = None
        if image_file and allowed_file(image_file.filename):
            filename = secure_filename(image_file.filename)
            unique_name = f"{uuid.uuid4().hex}_{filename}"
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_name)
            image_file.save(filepath)
            image_url = f"uploads/{unique_name}"
        project_id = str(uuid.uuid4())
        cur.execute("""
            INSERT INTO projects (id, id_tutor, title, description, requirements, details,
                                  topic_id, difficulty, deadline, status, created_at, updated_at, max_students)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'открыт', NOW(), NOW(), %s)
        """, (project_id, session['user_id'], title, description, requirements,
              details, topic_id, difficulty, deadline, max_students))
        if image_url:
            cur.execute("""
                INSERT INTO images (id, entity_type, entity_id, image_url, image_type, sort_order, is_active, created_at, updated_at)
                VALUES (%s, 'project', %s, %s, 'main', 0, TRUE, NOW(), NOW())
            """, (str(uuid.uuid4()), project_id, image_url))
        conn.commit()
        log_action(session['user_id'], 'add_project', f'Создан проект {title}')
        flash('Проект создан!', 'success')
        return redirect(url_for('my_projects'))
    cur.close()
    conn.close()
    return render_template('add_project.html', topics=topics)

@app.route('/edit_project/<uuid:project_id>', methods=['GET', 'POST'])
@teacher_required
def edit_project(project_id):
    project_id_str = str(project_id)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM projects WHERE id = %s AND id_tutor = %s", (project_id_str, session['user_id']))
    project = cur.fetchone()
    if not project:
        flash('Проект не найден или доступ запрещён.', 'error')
        return redirect(url_for('my_projects'))
    cur.execute("SELECT id, name FROM topics")
    topics = cur.fetchall()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form.get('description', '')
        requirements = request.form.get('requirements', '')
        details = request.form.get('details', '')
        topic_id = request.form.get('topic_id') or None
        difficulty = request.form.get('difficulty')
        deadline = request.form.get('deadline') or None
        status = request.form.get('status', 'открыт')
        max_students = request.form.get('max_students', 1)
        try:
            max_students = int(max_students)
        except:
            max_students = 1
        cur.execute("""
            UPDATE projects SET title=%s, description=%s, requirements=%s, details=%s,
                topic_id=%s, difficulty=%s, deadline=%s, status=%s, max_students=%s, updated_at=NOW()
            WHERE id=%s
        """, (title, description, requirements, details, topic_id, difficulty, deadline, status, max_students, project_id_str))
        image_file = request.files.get('image')
        if image_file and allowed_file(image_file.filename):
            filename = secure_filename(image_file.filename)
            unique_name = f"{uuid.uuid4().hex}_{filename}"
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_name)
            image_file.save(filepath)
            image_url = f"uploads/{unique_name}"
            cur.execute("DELETE FROM images WHERE entity_type='project' AND entity_id=%s", (project_id_str,))
            cur.execute("""
                INSERT INTO images (id, entity_type, entity_id, image_url, image_type, sort_order, is_active, created_at, updated_at)
                VALUES (%s, 'project', %s, %s, 'main', 0, TRUE, NOW(), NOW())
            """, (str(uuid.uuid4()), project_id_str, image_url))
        conn.commit()
        log_action(session['user_id'], 'edit_project', f'Изменён проект {project_id}')
        flash('Изменения сохранены.', 'success')
        return redirect(url_for('my_projects'))
    cur.close()
    conn.close()
    return render_template('edit_project.html', project=project, topics=topics)

@app.route('/project_applications/<uuid:project_id>')
@teacher_required
def project_applications(project_id):
    project_id_str = str(project_id)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM projects WHERE id=%s AND id_tutor=%s", (project_id_str, session['user_id']))
    if not cur.fetchone():
        flash('Нет доступа к заявкам этого проекта.', 'error')
        return redirect(url_for('my_projects'))
    cur.execute("""
        SELECT a.id, a.status, a.applied_at, u.id AS student_id, u.first_name, u.last_name, u.email
        FROM applications a
        JOIN users u ON a.student_id = u.id
        WHERE a.project_id = %s
        ORDER BY a.applied_at
    """, (project_id_str,))
    apps = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('project_applications.html', apps=apps)

@app.route('/update_application/<uuid:app_id>/<status>', methods=['POST'])
@teacher_required
def update_application(app_id, status):
    if status not in ('accepted', 'rejected'):
        flash('Неверный статус.', 'error')
        return redirect(request.referrer or url_for('my_projects'))
    app_id_str = str(app_id)
    conn = get_db_connection()
    cur = conn.cursor()
    # Получаем данные заявки
    cur.execute("SELECT project_id, student_id FROM applications WHERE id=%s", (app_id_str,))
    app_data = cur.fetchone()
    if not app_data:
        flash('Заявка не найдена.', 'error')
        return redirect(request.referrer or url_for('my_projects'))
    project_id = app_data['project_id']
    student_id = app_data['student_id']
    # Проверяем, что преподаватель владеет проектом
    cur.execute("SELECT id_tutor, max_students FROM projects WHERE id=%s", (project_id,))
    project = cur.fetchone()
    if not project or project['id_tutor'] != session['user_id']:
        flash('Нет прав на изменение этой заявки.', 'error')
        return redirect(request.referrer or url_for('my_projects'))
    if status == 'accepted':
        # Проверяем количество уже принятых студентов
        cur.execute("SELECT COUNT(*) AS cnt FROM applications WHERE project_id=%s AND status='accepted'", (project_id,))
        accepted_count = cur.fetchone()['cnt']
        if accepted_count >= project['max_students']:
            flash(f'Невозможно принять: проект уже набрал {accepted_count} из {project["max_students"]} студентов.', 'error')
            return redirect(request.referrer or url_for('my_projects'))
    # Обновляем статус заявки
    cur.execute("""
        UPDATE applications SET status=%s, updated_at=NOW()
        WHERE id=%s
    """, (status, app_id_str))
    conn.commit()
    if status == 'accepted':
        # Создаём/добавляем в групповой чат проекта
        ensure_project_chat(project_id, project['id_tutor'], student_id)
        log_action(session['user_id'], 'accept_application', f'Принята заявка {app_id}')
        flash(f'Заявка принята. Студент добавлен в групповой чат проекта.', 'success')
    else:
        log_action(session['user_id'], 'reject_application', f'Отклонена заявка {app_id}')
        flash('Заявка отклонена.', 'success')
    cur.close()
    conn.close()
    return redirect(request.referrer or url_for('my_projects'))

@app.route('/profile', methods=['GET', 'POST'])
def profile():
    conn = get_db_connection()
    cur = conn.cursor()
    if request.method == 'POST':
        about = request.form.get('about', '')
        cur.execute("UPDATE users SET about=%s, updated_at=NOW() WHERE id=%s", (about, session['user_id']))
        conn.commit()
        flash('Информация обновлена.', 'success')
        log_action(session['user_id'], 'update_profile', 'Изменено поле about')
    cur.execute("""
        SELECT id, email, first_name AS name, last_name AS surname, about, role, created_at
        FROM users WHERE id = %s
    """, (session['user_id'],))
    user = cur.fetchone()
    student_info = None
    active_projects = 0
    completed_projects = 0
    total_applications = 0
    projects_count = 0
    if session['role'] == 'student':
        cur.execute("SELECT course FROM students WHERE user_id=%s", (session['user_id'],))
        std = cur.fetchone()
        student_info = std['course'] if std else None
        cur.execute("""
            SELECT COUNT(*) AS cnt FROM applications a
            JOIN projects p ON a.project_id = p.id
            WHERE a.student_id=%s AND a.status='accepted' AND p.status='открыт'
        """, (session['user_id'],))
        row = cur.fetchone()
        active_projects = row['cnt'] if row else 0
        cur.execute("""
            SELECT COUNT(*) AS cnt FROM applications a
            JOIN projects p ON a.project_id = p.id
            WHERE a.student_id=%s AND a.status='accepted' AND p.status='завершён'
        """, (session['user_id'],))
        row = cur.fetchone()
        completed_projects = row['cnt'] if row else 0
        cur.execute("SELECT COUNT(*) AS cnt FROM applications WHERE student_id=%s", (session['user_id'],))
        row = cur.fetchone()
        total_applications = row['cnt'] if row else 0
    else:  # teacher or admin
        cur.execute("SELECT COUNT(*) AS cnt FROM projects WHERE id_tutor=%s", (session['user_id'],))
        row = cur.fetchone()
        projects_count = row['cnt'] if row else 0
        cur.execute("""
            SELECT COUNT(*) AS cnt FROM projects p
            JOIN applications a ON p.id = a.project_id
            WHERE p.id_tutor=%s AND a.status='accepted' AND p.status='завершён'
        """, (session['user_id'],))
        row = cur.fetchone()
        completed_projects = row['cnt'] if row else 0
    cur.close()
    conn.close()
    return render_template('profile.html', user=user, student_info=student_info,
                           active_projects=active_projects, completed_projects=completed_projects,
                           total_applications=total_applications, projects_count=projects_count)

@app.route('/my_applications')
def my_applications():
    if session['role'] != 'student':
        flash('Только для студентов.', 'error')
        return redirect(url_for('profile'))
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT a.id, a.status, a.applied_at, p.id AS project_id, p.title
        FROM applications a
        JOIN projects p ON a.project_id = p.id
        WHERE a.student_id = %s
        ORDER BY a.applied_at DESC
    """, (session['user_id'],))
    apps = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('my_applications.html', apps=apps)

@app.route('/reviews', methods=['GET', 'POST'])
def reviews():
    conn = get_db_connection()
    cur = conn.cursor()
    if request.method == 'POST':
        recipient_id = request.form['recipient_id']
        rating = int(request.form['rating'])
        comment = request.form.get('comment', '')
        if recipient_id == session['user_id']:
            flash('Нельзя оставить отзыв самому себе.', 'error')
            return redirect(url_for('reviews'))
        cur.execute("SELECT 1 FROM reviews WHERE author_id=%s AND recipient_id=%s",
                    (session['user_id'], recipient_id))
        if cur.fetchone():
            flash('Вы уже оставляли отзыв этому пользователю.', 'warning')
        else:
            cur.execute("""
                INSERT INTO reviews (id, author_id, recipient_id, rating, comment, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, NOW(), NOW())
            """, (str(uuid.uuid4()), session['user_id'], recipient_id, rating, comment))
            conn.commit()
            log_action(session['user_id'], 'add_review', f'Отзыв для {recipient_id}')
            flash('Отзыв отправлен!', 'success')
        return redirect(url_for('reviews'))
    if session['role'] == 'student':
        cur.execute("SELECT id, first_name AS name, last_name AS surname FROM users WHERE role='teacher'")
    else:
        cur.execute("SELECT id, first_name AS name, last_name AS surname FROM users WHERE role='student'")
    recipients = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('reviews.html', recipients=recipients)

@app.route('/view_reviews/<uuid:user_id>')
def view_reviews(user_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT r.rating, r.comment, r.created_at,
               u.first_name AS name, u.last_name AS surname
        FROM reviews r
        JOIN users u ON r.author_id = u.id
        WHERE r.recipient_id = %s
        ORDER BY r.created_at DESC
    """, (str(user_id),))
    reviews_list = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('view_reviews.html', reviews=reviews_list)

# ----- ЧАТЫ -----
@app.route('/chats')
def chats_list():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT c.id, c.name, c.last_message,
               (SELECT COUNT(*) FROM messages m WHERE m.chat_id = c.id AND m.is_read = FALSE AND m.sender_id != %s) AS unread
        FROM chats c
        JOIN chat_members cm ON c.id = cm.chat_id
        WHERE cm.user_id = %s
        ORDER BY c.updated_at DESC
    """, (session['user_id'], session['user_id']))
    chats = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('chats_list.html', chats=chats)

@app.route('/chat/<uuid:chat_id>')
def chat(chat_id):
    chat_id_str = str(chat_id)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM chat_members WHERE chat_id=%s AND user_id=%s", (chat_id_str, session['user_id']))
    if not cur.fetchone():
        flash('Нет доступа к этому чату.', 'error')
        return redirect(url_for('chats_list'))
    cur.execute("SELECT name FROM chats WHERE id=%s", (chat_id_str,))
    chat_row = cur.fetchone()
    chat_name = chat_row['name'] if chat_row else 'Чат'
    cur.execute("""
        SELECT m.id, m.content, m.sent_at, m.sender_id,
               u.first_name AS name, u.last_name AS surname
        FROM messages m
        JOIN users u ON m.sender_id = u.id
        WHERE m.chat_id = %s
        ORDER BY m.sent_at
    """, (chat_id_str,))
    messages = cur.fetchall()
    cur.execute("""
        UPDATE messages SET is_read = TRUE
        WHERE chat_id = %s AND sender_id != %s
    """, (chat_id_str, session['user_id']))
    conn.commit()
    cur.close()
    conn.close()
    return render_template('chat.html', chat_id=chat_id, chat_name=chat_name, messages=messages)

@app.route('/send_message/<uuid:chat_id>', methods=['POST'])
def send_message(chat_id):
    chat_id_str = str(chat_id)
    content = request.form.get('content', '').strip()
    if not content:
        flash('Сообщение не может быть пустым.', 'error')
        return redirect(url_for('chat', chat_id=chat_id))
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM chat_members WHERE chat_id=%s AND user_id=%s", (chat_id_str, session['user_id']))
    if not cur.fetchone():
        flash('Нет доступа.', 'error')
        return redirect(url_for('chats_list'))
    msg_id = str(uuid.uuid4())
    cur.execute("""
        INSERT INTO messages (id, chat_id, sender_id, content, is_read, sent_at, updated_at)
        VALUES (%s, %s, %s, %s, FALSE, NOW(), NOW())
    """, (msg_id, chat_id_str, session['user_id'], content))
    cur.execute("UPDATE chats SET last_message=%s, updated_at=NOW() WHERE id=%s", (content[:255], chat_id_str))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for('chat', chat_id=chat_id))

# ----- НОВОСТИ (для всех) -----
@app.route('/news')
def news_list():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT id, title, content, image_url, published_at
        FROM news_feed
        WHERE type = 'news'
        ORDER BY published_at DESC
    """)
    news = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('news.html', news=news)

# ----- АДМИН-ПАНЕЛЬ -----
@app.route('/admin')
@admin_required
def admin_dashboard():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM users")
    users_cnt = cur.fetchone()['count']
    cur.execute("SELECT COUNT(*) FROM projects")
    projects_cnt = cur.fetchone()['count']
    cur.execute("SELECT COUNT(*) FROM applications")
    apps_cnt = cur.fetchone()['count']
    cur.execute("SELECT COUNT(*) FROM reviews")
    reviews_cnt = cur.fetchone()['count']
    cur.close()
    conn.close()
    return render_template('admin/dashboard.html', users_cnt=users_cnt, projects_cnt=projects_cnt,
                           apps_cnt=apps_cnt, reviews_cnt=reviews_cnt)

@app.route('/admin/users')
@admin_required
def admin_users():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT u.id, u.first_name AS name, u.last_name AS surname, u.email, u.role,
               COALESCE(AVG(r.rating), 0) AS rating
        FROM users u
        LEFT JOIN reviews r ON r.recipient_id = u.id
        GROUP BY u.id, u.first_name, u.last_name, u.email, u.role
        ORDER BY u.created_at
    """)
    users = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('admin/users.html', users=users)

@app.route('/admin/delete_user/<uuid:user_id>')
@admin_required
def admin_delete_user(user_id):
    user_id_str = str(user_id)
    if user_id_str == session['user_id']:
        flash('Нельзя удалить самого себя.', 'error')
        return redirect(url_for('admin_users'))
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM users WHERE id=%s", (user_id_str,))
    conn.commit()
    log_action(session['user_id'], 'delete_user', f'Удалён пользователь {user_id}')
    flash('Пользователь удалён.', 'success')
    cur.close()
    conn.close()
    return redirect(url_for('admin_users'))

@app.route('/admin/add_user', methods=['GET', 'POST'])
@admin_required
def admin_add_user():
    if request.method == 'POST':
        email = request.form['email']
        name = request.form['name']
        surname = request.form['surname']
        role = request.form['role']
        password = request.form['password']
        hashed = generate_password_hash(password)
        user_id = str(uuid.uuid4())
        conn = get_db_connection()
        cur = conn.cursor()
        try:
            cur.execute("""
                INSERT INTO users (id, email, password_hash, first_name, last_name, role, is_active, is_verified, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, TRUE, TRUE, NOW(), NOW())
            """, (user_id, email, hashed, name, surname, role))
            if role == 'teacher':
                department = request.form.get('department', 'Не указан')
                position = request.form.get('position', 'Преподаватель')
                cur.execute("""
                    INSERT INTO teachers (user_id, department, position, created_at, updated_at)
                    VALUES (%s, %s, %s, NOW(), NOW())
                """, (user_id, department, position))
            elif role == 'admin':
                cur.execute("""
                    INSERT INTO admins (user_id, admin_level, created_at, updated_at)
                    VALUES (%s, 1, NOW(), NOW())
                """, (user_id,))
            conn.commit()
            log_action(session['user_id'], 'add_user', f'Создан {role}: {email}')
            flash(f'Пользователь {email} создан.', 'success')
        except Exception as e:
            conn.rollback()
            flash(f'Ошибка: {e}', 'error')
        finally:
            cur.close()
            conn.close()
        return redirect(url_for('admin_users'))
    return render_template('admin/add_user.html')

@app.route('/admin/topics')
@admin_required
def admin_topics():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, name FROM topics ORDER BY name")
    topics = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('admin/topics.html', topics=topics)

@app.route('/admin/add_topic', methods=['POST'])
@admin_required
def admin_add_topic():
    name = request.form['name'].strip()
    if name:
        conn = get_db_connection()
        cur = conn.cursor()
        try:
            cur.execute("INSERT INTO topics (id, name, created_at) VALUES (nextval('topics_id_seq'), %s, NOW())", (name,))
            conn.commit()
            flash('Тема добавлена.', 'success')
        except Exception:
            flash('Такая тема уже существует.', 'error')
        finally:
            cur.close()
            conn.close()
    return redirect(url_for('admin_topics'))

@app.route('/admin/delete_topic/<int:topic_id>')
@admin_required
def admin_delete_topic(topic_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM topics WHERE id=%s", (topic_id,))
    conn.commit()
    flash('Тема удалена.', 'success')
    cur.close()
    conn.close()
    return redirect(url_for('admin_topics'))

@app.route('/admin/news')
@admin_required
def admin_news_list():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, title, content, image_url, published_at FROM news_feed WHERE type='news' ORDER BY published_at DESC")
    news = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('admin/news_list.html', news=news)

@app.route('/admin/add_news', methods=['GET', 'POST'])
@admin_required
def admin_add_news():
    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']
        image_file = request.files.get('image')
        image_url = None
        if image_file and allowed_file(image_file.filename):
            filename = secure_filename(image_file.filename)
            unique_name = f"{uuid.uuid4().hex}_{filename}"
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_name)
            image_file.save(filepath)
            image_url = f"uploads/{unique_name}"
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO news_feed (id, type, title, content, image_url, published_at, created_at, updated_at)
            VALUES (%s, 'news', %s, %s, %s, NOW(), NOW(), NOW())
        """, (str(uuid.uuid4()), title, content, image_url))
        conn.commit()
        log_action(session['user_id'], 'add_news', f'Новость: {title}')
        flash('Новость опубликована.', 'success')
        cur.close()
        conn.close()
        return redirect(url_for('admin_news_list'))
    return render_template('admin/add_news.html')


@app.route('/admin/query', methods=['GET', 'POST'])
@admin_required
def admin_query():
    result = None
    error = None

    if request.method == 'POST':
        query = request.form.get('query', '').strip()

        if not query:
            error = "❌ Запрос не может быть пустым."
        else:
            # Запрещённые ключевые слова
            dangerous_keywords = ['DROP', 'DELETE', 'UPDATE', 'INSERT', 'ALTER',
                                  'TRUNCATE', 'CREATE', 'REPLACE', 'MERGE']
            query_upper = query.upper()
            if not query_upper.startswith('SELECT'):
                error = "❌ Разрешены только SELECT-запросы. Изменение данных (INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE) запрещено."
            else:
                # Ищем опасные слова как отдельные токены
                tokens = query_upper.split()
                if any(kw in tokens for kw in dangerous_keywords):
                    error = "❌ Запрос содержит запрещённые ключевые слова (DROP, DELETE и т.п.). Операция отклонена."
                else:
                    try:
                        conn = get_db_connection()
                        cur = conn.cursor()
                        cur.execute(query)
                        result = cur.fetchall()
                        cur.close()
                        conn.close()
                    except Exception as e:
                        error = f"Ошибка выполнения SQL: {str(e)}"
    return render_template('admin/query.html', result=result, error=error)

@app.route('/admin/logs')
@admin_required
def admin_logs():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM logs ORDER BY created_at DESC LIMIT 200")
    logs = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('admin/logs.html', logs=logs)

# ----- АУТЕНТИФИКАЦИЯ -----
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, email, password_hash, first_name, last_name, role FROM users WHERE email=%s", (email,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if user and check_password_hash(user['password_hash'], password):
            session['user_id'] = user['id']
            session['user_name'] = f"{user['first_name']} {user['last_name']}"
            session['role'] = user['role']
            log_action(user['id'], 'login', 'Вход в систему')
            flash('Добро пожаловать!', 'success')
            return redirect(url_for('index'))
        else:
            flash('Неверный email или пароль.', 'error')
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        email = request.form['email']
        faculty = request.form.get('faculty', '')
        group_number = request.form.get('group_number', '')
        course = request.form['course']
        password = request.form['password']
        hashed = generate_password_hash(password)
        user_id = str(uuid.uuid4())
        conn = get_db_connection()
        cur = conn.cursor()
        try:
            cur.execute("""
                INSERT INTO users (id, email, password_hash, first_name, last_name, group_number, course, role, is_active, is_verified, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, 'student', TRUE, FALSE, NOW(), NOW())
            """, (user_id, email, hashed, first_name, last_name, group_number, course))
            student_id_number = f"STU{datetime.now().strftime('%Y%m%d')}{user_id[:4]}"
            cur.execute("""
                INSERT INTO students (user_id, student_id, course, created_at, updated_at)
                VALUES (%s, %s, %s, NOW(), NOW())
            """, (user_id, student_id_number, course))
            conn.commit()
            session['user_id'] = user_id
            session['user_name'] = f"{first_name} {last_name}"
            session['role'] = 'student'
            log_action(user_id, 'register', 'Регистрация студента')
            flash('Регистрация успешна! Добро пожаловать.', 'success')
            return redirect(url_for('index'))
        except Exception as e:
            conn.rollback()
            flash(f'Ошибка: {e}', 'error')
        finally:
            cur.close()
            conn.close()
    return render_template('register.html')

@app.route('/logout')
def logout():
    if 'user_id' in session:
        log_action(session['user_id'], 'logout', 'Выход из системы')
    session.clear()
    flash('Вы вышли из системы.', 'info')
    return redirect(url_for('login'))

app.config["JWT_SECRET_KEY"] = os.getenv('JWT_SECRET_KEY', 'super-secret-key-change-in-production')
jwt = JWTManager(app)

# ====================== API ======================

def get_db_connection_api():
    """Переиспользуем существующее подключение"""
    return get_db_connection()


api = Blueprint('api', __name__, url_prefix='/api/v1')

# --------------------- Auth ---------------------
@api.route('/register', methods=['POST'])
def api_register():
    data = request.get_json(silent=True) or {}
    
    first_name = data.get("first_name") or data.get("name")
    last_name = data.get("last_name") or data.get("surname")
    email = data.get("email")
    password = data.get("password")
    course = data.get("course")
    group_number = data.get("group_number") or data.get("group")

    if not all([email, password, first_name, last_name]):
        return jsonify({"error": "Не все обязательные поля заполнены"}), 400

    conn = get_db_connection_api()
    cur = conn.cursor()
    try:
        cur.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cur.fetchone():
            return jsonify({"error": "Пользователь с таким email уже существует"}), 409

        hashed = generate_password_hash(password)
        user_id = str(uuid.uuid4())

        cur.execute("""
            INSERT INTO users (id, email, password_hash, first_name, last_name, group_number, 
                             course, role, is_active, is_verified, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'student', TRUE, FALSE, NOW(), NOW())
            RETURNING id
        """, (user_id, email, hashed, first_name, last_name, group_number, course))

        student_id_number = f"STU{datetime.now().strftime('%Y%m%d')}{user_id[:8]}"
        cur.execute("""
            INSERT INTO students (user_id, student_id, course, created_at, updated_at)
            VALUES (%s, %s, %s, NOW(), NOW())
        """, (user_id, student_id_number, course))

        conn.commit()

        token = create_access_token(identity=user_id)
        return jsonify({
            "message": "Регистрация успешна",
            "token": token,
            "user": {
                "id": user_id,
                "email": email,
                "first_name": first_name,
                "last_name": last_name,
                "role": "student"
            }
        }), 201

    except Exception as e:
        conn.rollback()
        traceback.print_exc()
        return jsonify({"error": "Ошибка сервера", "details": str(e)}), 500
    finally:
        cur.close()
        conn.close()


@api.route('/login', methods=['POST'])
def api_login():
    data = request.get_json(silent=True) or {}
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email и пароль обязательны"}), 400

    conn = get_db_connection_api()
    cur = conn.cursor()
    try:
        cur.execute("SELECT id, password_hash, role FROM users WHERE email = %s", (email,))
        user = cur.fetchone()

        if not user or not check_password_hash(user['password_hash'], password):
            return jsonify({"error": "Неверные данные"}), 401

        token = create_access_token(identity=str(user['id']))
        return jsonify({
            "message": "Вход выполнен",
            "token": token,
            "role": user['role']
        }), 200
    finally:
        cur.close()
        conn.close()


@api.route('/profile', methods=['GET'])
@jwt_required()
def api_profile():
    user_id = get_jwt_identity()
    conn = get_db_connection_api()
    cur = conn.cursor()
    try:
        cur.execute("""
            SELECT id, email, first_name, last_name, about, role, course, 
                   group_number, created_at, is_active
            FROM users WHERE id = %s
        """, (user_id,))
        user = cur.fetchone()
        if not user:
            return jsonify({"error": "Пользователь не найден"}), 404
        return jsonify(dict(user)), 200
    finally:
        cur.close()
        conn.close()


@api.route('/profile', methods=['PATCH'])
@jwt_required()
def api_update_profile():
    user_id = get_jwt_identity()
    data = request.get_json(silent=True) or {}
    about = data.get("about")

    if about is None:
        return jsonify({"error": "Поле 'about' обязательно"}), 400

    conn = get_db_connection_api()
    cur = conn.cursor()
    try:
        cur.execute("""
            UPDATE users SET about = %s, updated_at = NOW()
            WHERE id = %s
            RETURNING id, email, first_name, last_name, about, role
        """, (about, user_id))
        updated = cur.fetchone()
        conn.commit()
        return jsonify(dict(updated)), 200
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()
        conn.close()


# --------------------- Projects ---------------------
@api.route('/projects', methods=['GET'])
def api_get_projects():
    conn = get_db_connection_api()
    cur = conn.cursor()
    try:
        cur.execute("""
            SELECT p.id, p.title, p.description, p.difficulty, p.deadline, p.status, 
                   p.max_students,
                   u.first_name || ' ' || u.last_name AS tutor,
                   (SELECT image_url FROM images 
                    WHERE entity_type='project' AND entity_id=p.id 
                    ORDER BY sort_order LIMIT 1) AS image_url
            FROM projects p
            JOIN users u ON p.id_tutor = u.id
            WHERE p.status = 'открыт'
            ORDER BY p.created_at DESC
        """)
        projects = cur.fetchall()
        return jsonify([dict(p) for p in projects])
    finally:
        cur.close()
        conn.close()


@api.route('/projects', methods=['POST'])
@jwt_required()
def api_create_project():
    user_id = get_jwt_identity()
    data = request.get_json(silent=True) or {}

    title = data.get("title")
    description = data.get("description")
    if not title or not description:
        return jsonify({"error": "title и description обязательны"}), 400

    conn = get_db_connection_api()
    cur = conn.cursor()
    try:
        project_id = str(uuid.uuid4())
        cur.execute("""
            INSERT INTO projects (id, id_tutor, title, description, status, 
                                difficulty, deadline, max_students, created_at, updated_at)
            VALUES (%s, %s, %s, %s, 'открыт', %s, %s, %s, NOW(), NOW())
            RETURNING id, title, description, status
        """, (project_id, user_id, title, description,
              data.get("difficulty", "средний"),
              data.get("deadline"),
              data.get("max_students", 1)))
        
        project = cur.fetchone()
        conn.commit()
        return jsonify({"message": "Проект создан", "project": dict(project)}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()
        conn.close()


# Регистрация Blueprint
app.register_blueprint(api)

# ====================== ЗАПУСК ======================
if __name__ == '__main__':
    ensure_max_students_column()
    create_admin_if_not_exists()
    print("🚀 Сервер запущен: http://127.0.0.1:5000")
    print("📡 API доступно по префиксу /api/v1")
    app.run(debug=True)
