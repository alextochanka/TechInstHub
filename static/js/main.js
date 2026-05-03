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
            eyeIcon.src = staticUrl + (type === 'password' ? 'Eye-off.svg' : 'Eye-on.svg');
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
            // сохраняем поисковый запрос и тему
            const search = new URLSearchParams(window.location.search).get('search');
            if (search) url.searchParams.set('search', search);
            const topic = new URLSearchParams(window.location.search).get('topic');
            if (topic) url.searchParams.set('topic', topic);
            window.location.href = url.toString();
        });
    }
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

    // загрузка из localStorage
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

// ---------- Главная инициализация ----------
document.addEventListener('DOMContentLoaded', () => {
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

    // Специфичная для чата переотправка формы при enter (необязательно)
    const chatTextarea = document.querySelector('.chat-form textarea');
    if (chatTextarea) {
        chatTextarea.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                chatTextarea.closest('form')?.submit();
            }
        });
    }
});