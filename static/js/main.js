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
 * @param {HTMLInputElement} passwordField - поле ввода пароля
 * @returns {boolean} - валиден ли пароль
 */
function updatePasswordHints(passwordField) {
    const hintsContainer = document.getElementById('passwordHints');
    if (!hintsContainer) return true; // нет подсказок – не мешаем

    const val = passwordField.value;
    const { lengthOk, upperOk, lowerOk, specialOk } = validatePasswordStrength(val);

    // Элементы иконок и строк
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

/**
 * Инициализация валидации пароля для конкретной формы
 * @param {string} formId - id формы
 * @param {string} passwordFieldId - id поля пароля
 */
function initPasswordValidation(formId, passwordFieldId) {
    const form = document.getElementById(formId);
    const pwdField = document.getElementById(passwordFieldId);
    if (!form || !pwdField) return;

    // Обновляем подсказки при вводе
    pwdField.addEventListener('input', () => updatePasswordHints(pwdField));

    // Блокируем отправку при невалидном пароле
    form.addEventListener('submit', (e) => {
        if (!updatePasswordHints(pwdField)) {
            e.preventDefault();
            alert('Пароль не соответствует требованиям: длина 8–14 символов, заглавная и строчная буквы, спецсимвол.');
        }
    });
}

/**
 * Переключение видимости пароля (глазик)
 * @param {string} toggleBtnId - id кнопки-глазика
 * @param {string} passwordFieldId - id поля пароля
 * @param {string} eyeIconId - id картинки внутри кнопки
 * @param {string} staticUrl - базовый URL статики (например, '/static/icons/')
 */
function initTogglePassword(toggleBtnId, passwordFieldId, eyeIconId, staticUrl) {
    const toggleBtn = document.getElementById(toggleBtnId);
    const pwdField = document.getElementById(passwordFieldId);
    const eyeIcon = document.getElementById(eyeIconId);
    if (!toggleBtn || !pwdField) return;

    toggleBtn.addEventListener('click', () => {
        const type = pwdField.getAttribute('type') === 'password' ? 'text' : 'password';
        pwdField.setAttribute('type', type);
        if (eyeIcon) {
            eyeIcon.src = staticUrl + (type === 'password' ? 'Eye-off.svg' : 'Eye-on.svg');
        }
    });
}

/**
 * Инициализация поиска в каталоге проектов:
 * при отправке формы поиска добавляет скрытое поле с текущей темой (если есть)
 */
function initCatalogSearch() {
    const searchForm = document.getElementById('searchForm');
    if (!searchForm) return;

    searchForm.addEventListener('submit', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const topic = urlParams.get('topic');
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
    });
}

/**
 * Авто-прокрутка чата вниз (если есть блок сообщений)
 */
function initChatScroll() {
    const messagesDiv = document.getElementById('messages');
    if (messagesDiv) {
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }
}

/**
 * Подтверждение опасных действий (удаление, отклонение заявки и т.п.)
 * Используется для всех ссылок/кнопок с классом .confirm-action
 */
function initConfirmActions() {
    const confirmElements = document.querySelectorAll('.confirm-action');
    confirmElements.forEach(el => {
        el.addEventListener('click', (e) => {
            const message = el.getAttribute('data-confirm') || 'Вы уверены?';
            if (!confirm(message)) {
                e.preventDefault();
            }
        });
    });
}

// ---------- Запуск при загрузке DOM ----------
document.addEventListener('DOMContentLoaded', () => {
    // 1. Валидация пароля для формы регистрации студента
    initPasswordValidation('registerForm', 'password');
    // 2. Валидация пароля для формы добавления пользователя (админ)
    initPasswordValidation('addUserForm', 'passwordAdmin');

    // 3. Переключение видимости пароля (глазик)
    // Базовый URL статики – его нужно определить в каждом шаблоне, но можно вычислить автоматически
    let staticUrl = '/static/icons/'; // значение по умолчанию
    // Если на странице определена переменная STATIC_URL (из шаблона), используем её
    if (typeof window.STATIC_URL !== 'undefined') {
        staticUrl = window.STATIC_URL;
    }
    initTogglePassword('togglePassword', 'password', 'eyeIcon', staticUrl);
    initTogglePassword('togglePasswordAdmin', 'passwordAdmin', 'eyeIconAdmin', staticUrl);

    // 4. Поиск в каталоге
    initCatalogSearch();

    // 5. Прокрутка чата
    initChatScroll();

    // 6. Подтверждение действий
    initConfirmActions();
});