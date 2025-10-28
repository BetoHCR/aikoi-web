<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuración - Fundación Ai-Koi</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
</head>
<body>
    <div class="layout">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="brand">
                <img src="${pageContext.request.contextPath}/img/logo.png.jpg" alt="Logo" class="logo">
                <h2>Fundación Ai-Koi</h2>
            </div>

            <nav class="menu">
                <a href="index.jsp" class="menu-item">
                    <i class="icon">&#8962;</i> Inicio
                </a>
                <a href="calendario.jsp" class="menu-item">
                    <i class="icon">&#128197;</i> Calendario
                </a>
                <a href="configuracion.jsp" class="menu-item active">
                    <i class="icon">&#9881;</i> Configuración
                </a>
            </nav>
        </aside>

        <!-- Contenido principal -->
        <main class="content">
            <header class="topbar">
                <div class="user-circle">U</div>
            </header>

            <section class="cards">
                <div class="card">
                    <h3>Configuración del usuario</h3>
                    <p>Administración del perfil y preferencias personales del usuario actual.</p>

                    <form class="settings-form">
                        <label>Nombre de usuario</label>
                        <input type="text" value="Usuario Ai-Koi">

                        <label>Correo electrónico</label>
                        <input type="email" value="usuario@aikoi.org">

                        <label>Contraseña</label>
                        <input type="password" placeholder="••••••••">

                        <label>Notificaciones</label>
                        <select>
                            <option>Activadas</option>
                            <option>Desactivadas</option>
                        </select>

                        <div class="actions">
                            <button type="submit" class="btn btn-primary">Guardar cambios</button>
                        </div>
                    </form>
                </div>
            </section>
        </main>
    </div>
</body>
</html>
