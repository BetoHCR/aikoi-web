<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendario - Fundación Ai-Koi</title>
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
                <a href="calendario.jsp" class="menu-item active">
                    <i class="icon">&#128197;</i> Calendario
                </a>
                <a href="configuracion.jsp" class="menu-item">
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
                    <h3>Calendario de reuniones</h3>
                    <p>Visualización general de las reuniones programadas y próximas actividades de la Fundación Ai-Koi.</p>
                    <div class="calendar-placeholder">
                        <div class="calendar-header">
                            <button class="btn-secondary">◀</button>
                            <h4>Octubre 2025</h4>
                            <button class="btn-secondary">▶</button>
                        </div>
                        <div class="calendar-grid">
                            <div class="calendar-day header">Lun</div>
                            <div class="calendar-day header">Mar</div>
                            <div class="calendar-day header">Mié</div>
                            <div class="calendar-day header">Jue</div>
                            <div class="calendar-day header">Vie</div>
                            <div class="calendar-day header">Sáb</div>
                            <div class="calendar-day header">Dom</div>

                            <%-- Días simulados --%>
                            <%
                                for (int i = 1; i <= 31; i++) {
                            %>
                                <div class="calendar-day"><%= i %></div>
                            <%
                                }
                            %>
                        </div>
                    </div>
                </div>
            </section>
        </main>
    </div>
</body>
</html>
