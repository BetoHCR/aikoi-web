// sesion.js - validación simple + toggle de contraseña
document.addEventListener('DOMContentLoaded', function () {
  const toggle = document.getElementById('togglePassword');
  const pwd = document.getElementById('password');
  const form = document.getElementById('loginForm');

  if (toggle && pwd) {
    toggle.addEventListener('click', function () {
      if (pwd.type === 'password') {
        pwd.type = 'text';
        toggle.textContent = '🙈';
      } else {
        pwd.type = 'password';
        toggle.textContent = '👁';
      }
    });
  }

  if (form) {
    form.addEventListener('submit', function (e) {
      const email = document.getElementById('email');
      const password = document.getElementById('password');
      const emailHint = document.getElementById('emailHint');
      const passwordHint = document.getElementById('passwordHint');

      // Reset hints
      if (emailHint) emailHint.textContent = '';
      if (passwordHint) passwordHint.textContent = '';

      // Basic validation
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!email.value || !emailRegex.test(email.value)) {
        e.preventDefault();
        if (emailHint) emailHint.textContent = 'Ingresa un correo válido';
        email.focus();
        return false;
      }
      if (!password.value || password.value.length < 6) {
        e.preventDefault();
        if (passwordHint) passwordHint.textContent = 'La contraseña debe tener al menos 6 caracteres';
        password.focus();
        return false;
      }

      // If you want to block submission for testing, uncomment:
      // e.preventDefault(); alert('Validación OK (submit bloqueado para prueba)');
    });
  }
});

