<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    // Leer mensaje de la URL, ej: sesion.jsp?message=Inicia+sesion
    String flashMessage = request.getParameter("message");
    if (flashMessage == null) {
        flashMessage = "";
    }

    // Si el usuario YA tiene sesión activa, lo mandamos directo al index.jsp
    String emailLogeado = (String) session.getAttribute("userEmail");
    if (emailLogeado != null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Iniciar sesión - Fundación Ai-Koi</title>
  <link rel="stylesheet" href="<c:url value='/css/sesion.css'/>">
  <style>
    /* mini-estilos para alertas */
    .custom-alert {
      position: fixed;
      top: 16px;
      right: 16px;
      background: #4caf50;
      color: #fff;
      padding: .75rem 1rem;
      border-radius: 8px;
      font-size: .9rem;
      font-family: system-ui, sans-serif;
      box-shadow: 0 10px 25px rgba(0,0,0,.15);
      z-index: 9999;
      min-width: 200px;
      text-align: center;
    }
    .custom-alert.error {
      background: #e53935;
    }
    .custom-alert.warning {
      background: #ff9800;
    }

    .loader {
      display: inline-block;
      width: 14px;
      height: 14px;
      border: 2px solid #fff;
      border-top-color: transparent;
      border-radius: 50%;
      animation: spin .6s linear infinite;
      vertical-align: middle;
      margin-right: .4rem;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    .loading-overlay {
      position: absolute;
      inset: 0;
      display: none;
      background: rgba(0,0,0,0.25);
      align-items: center;
      justify-content: center;
      border-radius: 16px;
      z-index: 1000;
    }
    .loading-overlay.active {
      display: flex;
    }
    .loading-spinner {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      border: 3px solid #fff;
      border-top-color: transparent;
      animation: spin .7s linear infinite;
      box-shadow: 0 10px 25px rgba(0,0,0,.4);
    }
  </style>
</head>
<body>
    <div class="login-container">
        <div class="loading-overlay" id="loadingOverlay">
            <div class="loading-spinner"></div>
        </div>

        <img src="<c:url value='/img/logo.png.jpg'/>" alt="Logo" class="logo">
        <h1>Iniciar sesión</h1>

        <form id="loginForm">
            <div class="input-group">
                <label for="email">Correo electrónico</label>
                <input type="email" id="email" name="email" required placeholder="tu@email.com">
            </div>

            <div class="input-group">
                <label for="password">Contraseña</label>
                <input type="password" id="password" name="password" required placeholder="********">
            </div>

            <button type="submit" class="login-button" id="loginBtn">
                <span id="loginBtnText">Iniciar sesión</span>
            </button>

            <a href="#" class="forgot-password">¿Olvidaste tu contraseña?</a>

            <div class="divider">o</div>

            <button type="button" id="createAccountButton" class="secondary-button">Crear cuenta</button>
        </form>
    </div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const form = document.getElementById('loginForm');
  const loginBtn = document.getElementById('loginBtn');
  const loginBtnText = document.getElementById('loginBtnText');
  const loadingOverlay = document.getElementById('loadingOverlay');

  function showAlert(message, type) {
    type = type || 'success';
    const existing = document.querySelector('.custom-alert');
    if (existing) existing.remove();

    const alert = document.createElement('div');
    alert.className = 'custom-alert ' + (type === 'error' ? 'error' : (type === 'warning' ? 'warning' : 'success'));
    alert.textContent = message;
    document.body.appendChild(alert);

    setTimeout(function() {
      if (alert && alert.parentNode) {
        alert.parentNode.removeChild(alert);
      }
    }, 3000);
  }

  // 💬 Mensaje proveniente de la URL (?message=...)
  <% if (flashMessage != null && !flashMessage.isEmpty()) { %>
    showAlert("<%= flashMessage.replace("\"","\\\"") %>", "warning");
  <% } %>

  form.addEventListener('submit', async function(e) {
    e.preventDefault();

    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;

    if (!email || !password) {
      showAlert('Completa email y contraseña', 'error');
      return;
    }

    // estado de carga
    loginBtn.disabled = true;
    loginBtnText.innerHTML = '<span class="loader"></span> Iniciando sesión...';
    loadingOverlay.classList.add('active');

    try {
      const url = '<c:url value="/LoginServlet"/>'; // POST al servlet real
      const formData = new URLSearchParams();
      formData.append('email', email);
      formData.append('password', password);

      const resp = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body: formData.toString()
      });

      if (!resp.ok) {
        const txt = await resp.text();
        console.error('HTTP', resp.status, txt);
        showAlert('Error del servidor: ' + resp.status, 'error');
        return;
      }

      const json = await resp.json();
      if (json.success) {
        showAlert('¡Inicio de sesión exitoso!', 'success');
        // redirigir al panel principal (index.jsp)
        setTimeout(function() {
          window.location.href = '<c:url value="/index.jsp"/>';
        }, 700);
      } else {
        showAlert(json.message || 'Credenciales inválidas', 'error');
      }
    } catch (err) {
      console.error('Fetch error:', err);
      showAlert('Error de conexión con el servidor', 'error');
    } finally {
      loginBtn.disabled = false;
      loginBtnText.textContent = 'Iniciar sesión';
      loadingOverlay.classList.remove('active');
    }
  });

  document.getElementById('createAccountButton').addEventListener('click', function() {
    window.location.href = '<c:url value="/registro.jsp"/>';
  });
});
</script>
</body>
</html>
