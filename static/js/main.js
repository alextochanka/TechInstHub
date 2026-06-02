// static/js/main.js
// Единый файл скриптов для всех страниц TechInstHub

// ---------- Вспомогательные функции ----------

/**
 * Валидация пароля по требованиям:
 * - длина 8–14 символов
 * - хотя бы одна заглавная буква (A–Z)
 * - хотя бы одна строчная буква (a–z)
 * - хотя бы один специальный символ (не буква и не цифра)
 */
function validatePasswordStrength(password) {
    const lengthOk = password.length >= 8 && password.length <= 14;
    const upperOk = /[A-Z]/.test(password);
    const lowerOk = /[a-z]/.test(password);
    const specialOk = /[^a-zA-Z0-9]/.test(password);
    return { lengthOk, upperOk, lowerOk, specialOk };
}

/**
 * Обновление подсказок по паролю (если блок существует на странице)
 */
function updatePasswordHints(passwordField) {
    const hintsContainer = document.getElementById('passwordHints');
    if (!hintsContainer) return true;

    const val = passwordField.value;
    const { lengthOk, upperOk, lowerOk, specialOk } = validatePasswordStrength(val);

    const lengthIcon = document.getElementById('length-icon');
    const upperIcon = document.getElementById('upper-icon');
    const lowerIcon = document.getElementById('lower-icon');
    const specialIcon = document.getElementById('special-icon');
    const lengthHint = document.getElementById('hint-length');
    const upperHint = document.getElementById('hint-upper');
    const lowerHint = document.getElementById('hint-lower');
    const specialHint = document.getElementById('hint-special');

    if (lengthIcon) lengthIcon.innerHTML = lengthOk ? '✅' : '❌';
    if (upperIcon) upperIcon.innerHTML = upperOk ? '✅' : '❌';
    if (lowerIcon) lowerIcon.innerHTML = lowerOk ? '✅' : '❌';
    if (specialIcon) specialIcon.innerHTML = specialOk ? '✅' : '❌';
    if (lengthHint) lengthHint.style.color = lengthOk ? '#10B981' : '#6B7280';
    if (upperHint) upperHint.style.color = upperOk ? '#10B981' : '#6B7280';
    if (lowerHint) lowerHint.style.color = lowerOk ? '#10B981' : '#6B7280';
    if (specialHint) specialHint.style.color = specialOk ? '#10B981' : '#6B7280';

    return lengthOk && upperOk && lowerOk && specialOk;
}

function initPasswordValidation(formId, passwordFieldId) {
    const form = document.getElementById(formId);
    const pwdField = document.getElementById(passwordFieldId);
    if (!form || !pwdField) return;

    pwdField.addEventListener('input', () => updatePasswordHints(pwdField));
    form.addEventListener('submit', (e) => {
        if (!updatePasswordHints(pwdField)) {
            e.preventDefault();
            alert('Пароль не соответствует требованиям: длина 8–14 символов, заглавная и строчная буквы, спецсимвол.');
        }
    });
}

function initTogglePassword(toggleBtnId, passwordFieldId, eyeIconId, staticUrl) {
    const toggleBtn = document.getElementById(toggleBtnId);
    const pwdField = document.getElementById(passwordFieldId);
    const eyeIcon = document.getElementById(eyeIconId);
    if (!toggleBtn || !pwdField) return;

    toggleBtn.addEventListener('click', () => {
        const type = pwdField.getAttribute('type') === 'password' ? 'text' : 'password';
        pwdField.setAttribute('type', type);
        if (eyeIcon) {
            eyeIcon.src = staticUrl + (type === 'password' ? 'eye-off.svg' : 'eye-on.svg');
        }
    });
}

// Поиск в каталоге
function initCatalogSearch() {
    const searchForm = document.getElementById('searchForm');
    if (!searchForm) return;
    searchForm.addEventListener('submit', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const topic = urlParams.get('topic');
        const complexity = urlParams.get('complexity');
        if (topic) {
            let hiddenTopic = searchForm.querySelector('input[name="topic"]');
            if (!hiddenTopic) {
                hiddenTopic = document.createElement('input');
                hiddenTopic.type = 'hidden';
                hiddenTopic.name = 'topic';
                searchForm.appendChild(hiddenTopic);
            }
            hiddenTopic.value = topic;
        }
        if (complexity) {
            let hiddenComplexity = searchForm.querySelector('input[name="complexity"]');
            if (!hiddenComplexity) {
                hiddenComplexity = document.createElement('input');
                hiddenComplexity.type = 'hidden';
                hiddenComplexity.name = 'complexity';
                searchForm.appendChild(hiddenComplexity);
            }
            hiddenComplexity.value = complexity;
        }
    });
}

// Авто-прокрутка чата
function initChatScroll() {
    const messagesDiv = document.getElementById('messages');
    if (messagesDiv) {
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }
}

// Подтверждение действий (class="confirm-action" или data-confirm)
function initConfirmActions() {
    document.querySelectorAll('.confirm-action, [data-confirm]').forEach(el => {
        el.addEventListener('click', (e) => {
            const message = el.getAttribute('data-confirm') || 'Вы уверены?';
            if (!confirm(message)) {
                e.preventDefault();
            }
        });
    });
}

// Автоматическая отправка формы при изменении select
function initAutoSubmitSelect() {
    document.querySelectorAll('select[data-auto-submit]').forEach(select => {
        select.addEventListener('change', () => {
            select.closest('form')?.submit();
        });
    });
}

// Клик по элементам с data-href (для имитации ссылок)
function initDataHref() {
    document.querySelectorAll('[data-href]').forEach(el => {
        el.addEventListener('click', () => {
            const href = el.getAttribute('data-href');
            if (href) location.href = href;
        });
    });
}

// Применение фильтров сложности в каталоге
function initCatalogFilters() {
    const applyBtn = document.getElementById('applyFiltersBtn');
    if (applyBtn) {
        applyBtn.addEventListener('click', () => {
            const complexityRadios = document.querySelectorAll('input[name="complexity"]');
            let complexity = '';
            for (let radio of complexityRadios) {
                if (radio.checked) complexity = radio.value;
            }
            const url = new URL(window.location.href);
            if (complexity) url.searchParams.set('complexity', complexity);
            else url.searchParams.delete('complexity');
            const search = new URLSearchParams(window.location.search).get('search');
            if (search) url.searchParams.set('search', search);
            const topic = new URLSearchParams(window.location.search).get('topic');
            if (topic) url.searchParams.set('topic', topic);
            window.location.href = url.toString();
        });
    }
}

// Превью изображений при загрузке (несколько файлов)
function initImagePreviews(inputId, containerId) {
    const input = document.getElementById(inputId);
    const container = document.getElementById(containerId);
    if (!input || !container) return;
    
    input.addEventListener('change', function(e) {
        container.innerHTML = '';
        const files = Array.from(e.target.files);
        
        files.forEach((file, index) => {
            if (file.type.startsWith('image/')) {
                const reader = new FileReader();
                reader.onload = function(ev) {
                    const previewDiv = document.createElement('div');
                    previewDiv.className = 'image-preview';
                    previewDiv.innerHTML = `
                        <img src="${ev.target.result}" alt="Превью">
                        <button type="button" class="remove-image" data-index="${index}">×</button>
                    `;
                    container.appendChild(previewDiv);
                    
                    previewDiv.querySelector('.remove-image').addEventListener('click', () => {
                        previewDiv.remove();
                        const dt = new DataTransfer();
                        const remainingFiles = files.filter((_, i) => i !== index);
                        remainingFiles.forEach(f => dt.items.add(f));
                        input.files = dt.files;
                    });
                };
                reader.readAsDataURL(file);
            }
        });
    });
}

// Превью аватара
function initAvatarPreview() {
    const avatarInput = document.getElementById('avatarInput');
    const avatarPreview = document.getElementById('avatarPreview');
    if (!avatarInput || !avatarPreview) return;
    
    avatarInput.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file && file.type.startsWith('image/')) {
            const reader = new FileReader();
            reader.onload = function(ev) {
                avatarPreview.src = ev.target.result;
            };
            reader.readAsDataURL(file);
        }
    });
}

// Загрузка вложений в чат (несколько файлов)
function initChatAttachments() {
    const attachBtn = document.querySelector('[data-attach-alert]');
    const attachmentsInput = document.getElementById('attachmentsInput');
    
    if (!attachBtn || !attachmentsInput) return;
    
    attachBtn.addEventListener('click', () => {
        attachmentsInput.click();
    });
    
    attachmentsInput.addEventListener('change', function(e) {
        const files = Array.from(e.target.files);
        const container = document.getElementById('attachmentsPreview');
        if (!container) return;
        
        container.innerHTML = '';
        files.forEach((file) => {
            const badge = document.createElement('span');
            badge.className = 'chat-attachment';
            badge.innerHTML = `📎 ${file.name} (${(file.size / 1024).toFixed(0)} KB)`;
            container.appendChild(badge);
        });
    });
}

// Удаление изображений проекта
function initDeleteProjectImage() {
    document.querySelectorAll('.delete-project-image').forEach(btn => {
        btn.addEventListener('click', async function() {
            const imageUrl = this.dataset.imageUrl;
            const projectId = this.dataset.projectId;
            
            if (!confirm('Удалить это изображение?')) return;
            
            try {
                const response = await fetch('/delete_project_image', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ image_url: imageUrl, project_id: projectId })
                });
                const data = await response.json();
                if (data.success) {
                    this.closest('.image-preview').remove();
                }
            } catch (error) {
                console.error('Ошибка удаления:', error);
            }
        });
    });
}

// Инициализация рейтинга звездочками (при выборе оценки)
function initRatingStars() {
    const stars = document.querySelectorAll('.stars .star');
    const ratingInput = document.getElementById('ratingValue');
    
    if (!stars.length || !ratingInput) return;
    
    stars.forEach(star => {
        star.addEventListener('click', function() {
            const value = parseInt(this.dataset.value);
            ratingInput.value = value;
            
            stars.forEach((s, index) => {
                if (index < value) {
                    s.innerHTML = '★';
                    s.classList.add('filled');
                } else {
                    s.innerHTML = '☆';
                    s.classList.remove('filled');
                }
            });
        });
        
        star.addEventListener('mouseenter', function() {
            const value = parseInt(this.dataset.value);
            stars.forEach((s, index) => {
                if (index < value) {
                    s.innerHTML = '★';
                    s.style.color = '#FCD34D';
                } else {
                    s.innerHTML = '☆';
                    s.style.color = '#ccc';
                }
            });
        });
    });
    
    stars.forEach(star => {
        star.addEventListener('mouseleave', function() {
            const currentValue = parseInt(ratingInput.value);
            stars.forEach((s, index) => {
                if (index < currentValue) {
                    s.innerHTML = '★';
                    s.style.color = '#F59E0B';
                } else {
                    s.innerHTML = '☆';
                    s.style.color = '#ccc';
                }
            });
        });
    });
}

// Обработка чекбокса "написать преподавателю" (project_page.html)
function initTeacherMessageToggle() {
    const checkbox = document.getElementById('teacher1Checkbox');
    const messageDiv = document.getElementById('teacher1Message');
    if (checkbox && messageDiv) {
        checkbox.addEventListener('change', () => {
            messageDiv.style.display = checkbox.checked ? 'block' : 'none';
        });
    }
}

// Сохранение проекта в localStorage (project_page.html)
function initProjectPageStorage() {
    const saveBtn = document.getElementById('saveBtn');
    if (!saveBtn) return;
    const projectName = document.getElementById('projectName');
    const shortDescription = document.getElementById('shortDescription');
    const theme = document.getElementById('theme');
    const saveMessage = document.getElementById('saveMessage');
    if (!projectName || !shortDescription || !theme) return;

    if (localStorage.getItem('projectName')) projectName.value = localStorage.getItem('projectName');
    if (localStorage.getItem('shortDescription')) shortDescription.value = localStorage.getItem('shortDescription');
    if (localStorage.getItem('theme')) theme.value = localStorage.getItem('theme');

    saveBtn.addEventListener('click', () => {
        localStorage.setItem('projectName', projectName.value);
        localStorage.setItem('shortDescription', shortDescription.value);
        localStorage.setItem('theme', theme.value);
        if (saveMessage) {
            saveMessage.textContent = '✓ Сохранено';
            setTimeout(() => saveMessage.textContent = '', 3000);
        }
    });
}

// Инициализация галереи изображений проекта (улучшенная версия)
function initProjectGallery() {
    const modal = document.getElementById('imageModal');
    const modalImg = document.getElementById('modalImage');
    const closeBtn = document.querySelector('.modal-close');
    
    if (!modal || !modalImg) return;
    
    // Функция открытия модального окна
    function openModal(imageSrc) {
        modal.style.display = 'flex';
        modalImg.src = imageSrc;
        document.body.style.overflow = 'hidden'; // Блокируем скролл страницы
    }
    
    // Функция закрытия модального окна
    function closeModal() {
        modal.style.display = 'none';
        modalImg.src = '';
        document.body.style.overflow = ''; // Возвращаем скролл
    }
    
    // Навешиваем обработчики на все изображения проекта
    document.querySelectorAll('.project-detail-image-thumb, .project-detail-image').forEach(img => {
        // Убираем старый обработчик, если был
        img.removeEventListener('click', img._galleryHandler);
        
        // Создаём новый обработчик
        const handler = function(e) {
            e.stopPropagation();
            openModal(this.src);
        };
        
        img._galleryHandler = handler;
        img.addEventListener('click', handler);
        
        // Добавляем курсор-указатель для интерактивности
        img.style.cursor = 'pointer';
    });
    
    // Закрытие по крестику
    if (closeBtn) {
        closeBtn.removeEventListener('click', closeBtn._closeHandler);
        closeBtn._closeHandler = closeModal;
        closeBtn.addEventListener('click', closeBtn._closeHandler);
    }
    
    // Закрытие по клику на фон
    modal.removeEventListener('click', modal._bgHandler);
    modal._bgHandler = function(event) {
        if (event.target === modal) {
            closeModal();
        }
    };
    modal.addEventListener('click', modal._bgHandler);
    
    // Закрытие по клавише Escape
    function handleEscape(e) {
        if (e.key === 'Escape' && modal.style.display === 'flex') {
            closeModal();
        }
    }
    
    document.removeEventListener('keydown', document._escapeHandler);
    document._escapeHandler = handleEscape;
    document.addEventListener('keydown', document._escapeHandler);
    
    // Плавающие подсказки для изображений
    document.querySelectorAll('.project-detail-image-thumb').forEach(img => {
        img.setAttribute('title', 'Нажмите для увеличения');
    });
}

// ---------- Инициализация карточек на главной странице ----------
function initHomeCards() {
    document.querySelectorAll('.service-card, .rec-card').forEach(card => {
        card.removeEventListener('click', card._clickHandler);
        
        const clickHandler = function(e) {
            if (e.target.classList && e.target.classList.contains('rec-btn')) {
                return;
            }
            const href = this.getAttribute('data-href');
            if (href && href !== '#') {
                window.location.href = href;
            }
        };
        
        card._clickHandler = clickHandler;
        card.addEventListener('click', clickHandler);
    });

    document.querySelectorAll('.rec-btn').forEach(btn => {
        btn.removeEventListener('click', btn._clickHandler);
        
        const clickHandler = function(e) {
            e.stopPropagation();
            const href = this.getAttribute('data-href');
            if (href && href !== '#') {
                window.location.href = href;
            }
        };
        
        btn._clickHandler = clickHandler;
        btn.addEventListener('click', clickHandler);
    });

    document.querySelectorAll('.btn-secondary, .btn-view-all a').forEach(link => {
        link.removeEventListener('click', link._clickHandler);
        
        const clickHandler = function(e) {
            e.preventDefault();
            const href = this.getAttribute('data-href');
            if (href && href !== '#') {
                window.location.href = href;
            }
        };
        
        link._clickHandler = clickHandler;
        link.addEventListener('click', clickHandler);
    });
}

// ---------- Защита от повторной отправки формы ----------
function initFormProtection() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        if (form.id === 'searchForm' || form.classList.contains('no-protection')) {
            return;
        }
        
        form.addEventListener('submit', function(e) {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn && !submitBtn.hasAttribute('data-submitted')) {
                submitBtn.setAttribute('data-submitted', 'true');
                submitBtn.disabled = true;
                setTimeout(() => {
                    submitBtn.disabled = false;
                    submitBtn.removeAttribute('data-submitted');
                }, 5000);
            }
        });
    });
}

// ---------- Анимация появления карточек ----------
function initCardAnimations() {
    const cards = document.querySelectorAll('.news-card, .event-card, .project-card, .rec-card, .service-card');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '0';
                entry.target.style.transform = 'translateY(20px)';
                entry.target.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, 50);
                
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    
    cards.forEach(card => {
        card.style.opacity = '0';
        observer.observe(card);
    });
}

// ---------- Обновление активного фильтра в новостях ----------
function initNewsFilter() {
    const filterLinks = document.querySelectorAll('.filter-tab, .catalog-filters a');
    filterLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            filterLinks.forEach(l => l.classList.remove('active', 'primary'));
            this.classList.add('active', 'primary');
            
            const contentArea = document.querySelector('.ui-vstack.gap-24');
            if (contentArea) {
                contentArea.style.opacity = '0.5';
                setTimeout(() => {
                    contentArea.style.opacity = '1';
                }, 300);
            }
        });
    });
}

// ---------- Обработка кликов по карточкам новостей ----------
function initNewsCardClick() {
    document.querySelectorAll('.news-card, .event-card').forEach(card => {
        const link = card.querySelector('.ui-link');
        if (link) {
            card.addEventListener('click', (e) => {
                if (!e.target.closest('.ui-link') && !e.target.closest('button')) {
                    window.location.href = link.href;
                }
            });
        }
    });
}

// ---------- Фильтрация публикаций в админ-панели ----------
function initAdminNewsFilter() {
    const filterBtns = document.querySelectorAll('.filter-tab');
    const newsItems = document.querySelectorAll('.topic-item[data-type]');
    
    if (!filterBtns.length || !newsItems.length) return;
    
    filterBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            filterBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            const filter = this.dataset.filter;
            
            newsItems.forEach(item => {
                if (filter === 'all' || item.dataset.type === filter) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    });
}

// ---------- Уведомление об успешной отправке ----------
function showNotification(message, type = 'success') {
    const existingNotification = document.querySelector('.floating-notification');
    if (existingNotification) existingNotification.remove();
    
    const notification = document.createElement('div');
    notification.className = `floating-notification ${type}`;
    notification.innerHTML = `
        <span>${type === 'success' ? '✅' : '❌'}</span>
        <span>${message}</span>
    `;
    notification.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: ${type === 'success' ? '#10B981' : '#DC2626'};
        color: white;
        padding: 12px 24px;
        border-radius: 12px;
        font-size: 14px;
        font-weight: 500;
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        animation: slideIn 0.3s ease;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// ---------- Предотвращение возврата на страницы входа и регистрации ----------
function initRegistrationProtection() {
    const isLoginPage = window.location.pathname.includes('/login');
    const isRegisterPage = window.location.pathname.includes('/register');
    
    if (isLoginPage || isRegisterPage) {
        const hasLogoutLink = document.querySelector('.nav-links a[href*="logout"]') !== null;
        const hasUserMenu = document.querySelector('.user-menu') !== null;
        
        if (hasLogoutLink || hasUserMenu) {
            window.location.href = '/';
            return;
        }
        
        if (window.performance && window.performance.navigation.type === 2) {
            window.location.href = '/';
        }
        
        window.addEventListener('pageshow', function(event) {
            if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                window.location.href = '/';
            }
        });
        
        history.pushState(null, null, location.href);
        window.addEventListener('popstate', function() {
            history.pushState(null, null, location.href);
            window.location.href = '/';
        });
    }
}

// ---------- Проверка авторизации на страницах входа ----------
function initAuthCheck() {
    const authPages = ['/login', '/register'];
    const isAuthPage = authPages.some(path => window.location.pathname.includes(path));
    
    if (isAuthPage) {
        fetch('/api/v1/profile', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(response => {
            if (response.status === 200) {
                window.location.href = '/';
            }
        })
        .catch(() => {});
    }
}

// ---------- Очистка истории после успешного входа ----------
function initClearHistoryOnLogin() {
    const successFlash = document.querySelector('.flash-success, .ui-text.success');
    if (successFlash && (successFlash.textContent.includes('Добро пожаловать') || 
        successFlash.textContent.includes('Регистрация успешна'))) {
        history.replaceState(null, null, window.location.href);
        
        window.addEventListener('popstate', function() {
            history.pushState(null, null, window.location.href);
            window.location.href = '/';
        });
    }
}

// ---------- Плавная прокрутка для якорных ссылок ----------
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]:not([href="#"])').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const target = document.querySelector(targetId);
            if (target) {
                e.preventDefault();
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });
}

// ---------- Обработка ошибок форм ----------
function initFormErrorHandling() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function() {
            const requiredFields = this.querySelectorAll('[required]');
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    field.classList.add('error-field');
                    field.addEventListener('input', function() {
                        this.classList.remove('error-field');
                    }, { once: true });
                }
            });
        });
    });
}

// ---------- Обработка добавления новости (тип публикации) ----------
function initNewsTypeSelector() {
    const newsType = document.getElementById('newsType');
    const eventFields = document.getElementById('eventFields');
    const internshipFields = document.getElementById('internshipFields');
    
    if (!newsType) return;
    
    function toggleFields() {
        if (eventFields) eventFields.style.display = 'none';
        if (internshipFields) internshipFields.style.display = 'none';
        
        if (newsType.value === 'event' && eventFields) {
            eventFields.style.display = 'block';
        } else if (newsType.value === 'internship' && internshipFields) {
            internshipFields.style.display = 'block';
        }
    }
    
    newsType.addEventListener('change', toggleFields);
    toggleFields();
}

// Добавляем CSS анимации для уведомлений
const notificationStyles = document.createElement('style');
notificationStyles.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    .error-field {
        border-color: #DC2626 !important;
        background-color: #fef2f2 !important;
    }
    body.loaded .content {
        animation: fadeInUp 0.4s ease;
    }
    
    /* Анимация для карточек проекта */
    .project-card, .rec-card, .service-card {
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    
    .project-card:hover, .rec-card:hover, .service-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 24px -12px rgba(0,0,0,0.15);
    }
    
    /* Анимация для изображений в галерее */
    .project-detail-image-thumb {
        transition: transform 0.2s ease, border-color 0.2s ease;
    }
    
    .project-detail-image-thumb:hover {
        transform: scale(1.05);
        border-color: #2563eb !important;
    }
    
    /* Анимация для модального окна */
    .modal {
        animation: fadeIn 0.2s ease;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    #modalImage {
        animation: zoomIn 0.2s ease;
    }
    
    @keyframes zoomIn {
        from {
            transform: scale(0.9);
            opacity: 0;
        }
        to {
            transform: scale(1);
            opacity: 1;
        }
    }
`;
document.head.appendChild(notificationStyles);

// ---------- Главная инициализация ----------
document.addEventListener('DOMContentLoaded', () => {
    // Проверка авторизации для страниц входа/регистрации
    initAuthCheck();
    
    // Защита от возврата
    initRegistrationProtection();
    
    // Очистка истории после успешного входа
    initClearHistoryOnLogin();
    
    // Валидация пароля
    initPasswordValidation('registerForm', 'password');
    initPasswordValidation('addUserForm', 'passwordAdmin');

    // Переключение пароля
    let staticUrl = '/static/icons/';
    if (typeof window.STATIC_URL !== 'undefined') staticUrl = window.STATIC_URL;
    initTogglePassword('togglePassword', 'password', 'eyeIcon', staticUrl);
    initTogglePassword('togglePasswordAdmin', 'passwordAdmin', 'eyeIconAdmin', staticUrl);

    // Поиск в каталоге
    initCatalogSearch();

    // Прокрутка чата
    initChatScroll();

    // Подтверждение действий
    initConfirmActions();

    // Дополнительные модули
    initAutoSubmitSelect();
    initDataHref();
    initCatalogFilters();
    initTeacherMessageToggle();
    initProjectPageStorage();
    initAvatarPreview();
    initChatAttachments();
    initRatingStars();
    
    // Новые функции
    initFormProtection();
    initCardAnimations();
    initNewsFilter();
    initNewsCardClick();
    initSmoothScroll();
    initFormErrorHandling();
    initAdminNewsFilter();
    initNewsTypeSelector();
    
    // Превью изображений для проектов и новостей
    initImagePreviews('projectImages', 'imagesPreview');
    initImagePreviews('newsImages', 'newsImagesPreview');
    
    // Удаление изображений проекта
    initDeleteProjectImage();

    // Инициализация галереи проекта (ВАЖНО: добавлена!)
    initProjectGallery();

    // Инициализация карточек на главной странице
    initHomeCards();

    // Специфичная для чата переотправка формы при enter
    const chatTextarea = document.querySelector('.chat-form textarea');
    if (chatTextarea) {
        chatTextarea.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                chatTextarea.closest('form')?.submit();
            }
        });
    }
    
    // Добавляем класс loaded для устранения FOUC
    document.body.classList.add('loaded');
    
    // Убираем индикатор загрузки
    setTimeout(() => {
        document.body.classList.remove('loading');
    }, 100);
    
    // Обработка flash-сообщений как уведомлений (только JS, без отображения черных блоков)
    const flashMessages = document.querySelectorAll('.flash-message');
    flashMessages.forEach(msg => {
        const message = msg.getAttribute('data-flash') || msg.textContent;
        if (message && message.trim()) {
            const isError = msg.classList.contains('flash-error') || msg.classList.contains('error');
            showNotification(message.trim(), isError ? 'error' : 'success');
            msg.remove();
        }
    });
});

// Экспорт функций для использования в других скриптах
window.TechInstHub = {
    showNotification,
    validatePasswordStrength,
    initProjectGallery
};