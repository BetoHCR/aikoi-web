<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  String ctx = request.getContextPath();
  String serverMsg = request.getParameter("message"); // opcional: ?message=...
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Registro – Fundación Ai-Koi</title>

  <!-- Iconos -->
  <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
        integrity="sha512-SnS0jJz8b4I5iQhKX2mY1DgZx7T2a2+0V9r8C3Y9hB2Z2w1KcTj2t0LQx2e9Gm9q6bq9qVZJf5nY2q3v5+8y7w=="
        crossorigin="anonymous" referrerpolicy="no-referrer" />

  <!-- Hoja de estilos propia de registro -->
  <link rel="stylesheet" href="<%=ctx%>/css/registro.css" />
</head>
<body>
  <div class="meeting-container">
    <!-- Encabezado con tu estilo existente -->
    

    <!-- Tarjeta principal -->
    <main class="card">
      <div class="card-header">
        <img src="<%=ctx%>/img/logo.png.jpg" alt="Logo" class="logo" />
        <h2>Fundación Ai-Koi • Registro</h2>
      </div>

      <div class="card-body">
        <form id="regForm" autocomplete="off" novalidate>
          <div class="form-row">
            <label for="name">Nombre completo</label>
            <input id="name" name="name" type="text" placeholder="Nombre y apellidos" required />
          </div>

          <div class="form-row">
            <label for="email">Correo electrónico</label>
            <input id="email" name="email" type="email" placeholder="correo@ejemplo.com" required />
          </div>

          <div class="form-row">
            <label for="password">Contraseña</label>
            <input id="password" name="password" type="password" placeholder="Mínimo 6 caracteres" required />
          </div>

          <div class="form-row">
            <label for="password2">Confirmar contraseña</label>
            <input id="password2" type="password" placeholder="Repite la contraseña" required />
            <p class="hint">Al registrarse se aceptan políticas de uso y tratamiento de datos.</p>
          </div>

          <div class="actions">
            <button class="btn-primary" id="btnSubmit" type="submit">
              <i class="fas fa-user-check"></i>&nbsp; Crear cuenta
            </button>
            <a class="link" href="<%=ctx%>/sesion.jsp">¿Ya existe una cuenta? Iniciar sesión</a>
          </div>
        </form>
      </div>
    </main>
  </div>

  <!-- Alertas flotantes -->
  <div id="alertLayer" class="custom-alert" style="display:none;"></div>

  <!-- Loader global -->
  <div id="loader" class="loader-overlay" style="display:none;">
    <div class="loader"></div>
  </div>

  <script>
    (function () {
      const ctx = "<%=ctx%>";
      const form = document.getElementById('regForm');
      const btn  = document.getElementById('btnSubmit');
      const alertLayer = document.getElementById('alertLayer');
      const loader = document.getElementById('loader');

      // Mensaje recibido por query param (?message=...)
      <% if (serverMsg != null && !serverMsg.trim().isEmpty()) { %>
        showAlert("<%=serverMsg.replace("\"","\\\"")%>", "success");
      <% } %>

      function showAlert(msg, type) {
        alertLayer.className = 'custom-alert ' + (type || 'success');
        alertLayer.textContent = msg;
        alertLayer.style.display = 'block';
        setTimeout(() => alertLayer.style.display = 'none', 3000);
      }
      function emailOk(s) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);
      }

      form.addEventListener('submit', async function (e) {
        e.preventDefault();
        const name  = document.getElementById('name').value.trim();
        const email = document.getElementById('email').value.trim();
        const pass  = document.getElementById('password').value;
        const pass2 = document.getElementById('password2').value;

        if (!name || !email || !pass || !pass2) {
          return showAlert('Completar todos los campos', 'warning');
        }
        if (!emailOk(email)) {
          return showAlert('Correo inválido', 'warning');
        }
        if (pass.length < 6) {
          return showAlert('La contraseña requiere 6 caracteres como mínimo', 'warning');
        }
        if (pass !== pass2) {
          return showAlert('Las contraseñas no coinciden', 'warning');
        }

        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>&nbsp; Procesando…';
        loader.style.display = 'flex';

        try {
          const body = new URLSearchParams();
          body.set('name', name);
          body.set('email', email);
          body.set('password', pass);

          const resp = await fetch(ctx + '/RegistroServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: body.toString()
          });

          const data = await resp.json().catch(() => ({ success: false, message: 'Respuesta inválida' }));

          if (resp.ok && data.success) {
            showAlert('Cuenta creada correctamente', 'success');
            try { sessionStorage.setItem('userName', name); } catch (_) {}
            setTimeout(() => { window.location.href = ctx + '/sesion.jsp?message=Registro+exitoso'; }, 700);
          } else {
            showAlert(data.message || 'No fue posible completar el registro', 'error');
          }
        } catch (err) {
          showAlert('Error de red: ' + (err && err.message ? err.message : ''), 'error');
        } finally {
          btn.disabled = false;
          btn.innerHTML = '<i class="fas fa-user-check"></i>&nbsp; Crear cuenta';
          loader.style.display = 'none';
        }
      });
    })();
  </script>
</body>
</html>
