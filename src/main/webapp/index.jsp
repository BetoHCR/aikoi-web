<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    // ====== Protección de sesión ======
    String emailLogeado = (String) session.getAttribute("userEmail");
    String nombreLogeado = (String) session.getAttribute("userName");

    if (emailLogeado == null) {
        // No hay sesión -> manda a login
        response.sendRedirect(request.getContextPath() + "/sesion.jsp?message=Inicia+sesion");
        return;
    }

    // Inicial para el circulito de usuario
    String inicialUsuario = "U";
    if (nombreLogeado != null && !nombreLogeado.isEmpty()) {
        inicialUsuario = nombreLogeado.substring(0,1).toUpperCase();
    } else if (emailLogeado != null && !emailLogeado.isEmpty()) {
        inicialUsuario = emailLogeado.substring(0,1).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Principal - Fundación Ai-Koi</title>

    <!-- usa contextPath para rutas estáticas -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css">
</head>
<body>
    <div class="layout">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="brand">
                <img src="<%= request.getContextPath() %>/img/logo.png.jpg" alt="Logo" class="logo">
                <h2>Fundación Ai-Koi</h2>
            </div>

            <nav class="menu">
                <a href="<%= request.getContextPath() %>/index.jsp" class="menu-item active">
                    <i class="icon">&#128274;</i> Inicio
                </a>
                <a href="<%= request.getContextPath() %>/calendario.jsp" class="menu-item">
                    <i class="icon">&#128197;</i> Calendario
                </a>
                <a href="<%= request.getContextPath() %>/configuracion.jsp" class="menu-item">
                    <i class="icon">&#9881;</i> Configuración
                </a>
            </nav>
        </aside>

        <!-- Contenido principal -->
        <main class="content">
            <header class="topbar">
                <div class="user-block">
                    <div class="user-circle" title="<%= (nombreLogeado != null ? nombreLogeado : emailLogeado) %>">
                        <%= inicialUsuario %>
                    </div>
                    <button id="logoutBtn" class="logout-btn" title="Cerrar sesión">Salir</button>
                </div>
            </header>

            <section class="cards">
                <div class="card">
                    <div class="card-header-row">
                        <h3>Reunión de proyecto</h3>
                        <div class="actions">
                            <button class="btn btn-secondary" id="joinMeetingBtn">Unirse</button>
                            <button class="btn btn-primary" id="createMeetingBtn">Crear reunión</button>
                        </div>
                    </div>
                    <p>Sala de reuniones.</p>
                </div>

                <div class="card">
                    <h3>Próximas reuniones</h3>
                    <ul id="meetingList">
                        <li>No hay reuniones programadas</li>
                    </ul>
                </div>
            </section>
        </main>
    </div>

    <!-- Modal ligero para unirse / crear -->
    <div id="meetingModal" class="modal" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="modalTitle">Reunión</h3>
                <button id="closeModalBtn" class="close-btn">&times;</button>
            </div>

            <div class="modal-body">
                <!-- Para unirse -->
                <div id="joinSection">
                    <label>ID de reunión</label>
                    <input id="joinMeetingCode" type="text" placeholder="Ej: ABC-123">
                    <label>Tu nombre</label>
                    <input id="joinUserName" type="text" value="<%= (nombreLogeado!=null?nombreLogeado:emailLogeado) %>">
                    <button id="confirmJoinBtn" class="btn btn-primary" style="margin-top:1rem;">Entrar a la sala</button>
                </div>

                <!-- Para crear -->
                <div id="createSection" style="display:none;">
                    <label>Nombre de la reunión</label>
                    <input id="newMeetingName" type="text" placeholder="Ej: Reunión semanal">
                    <label>Descripción (opcional)</label>
                    <textarea id="newMeetingDesc" rows="3"></textarea>
                    <button id="confirmCreateBtn" class="btn btn-primary" style="margin-top:1rem;">Crear y entrar</button>
                </div>
            </div>

            <div class="modal-footer">
                <button id="switchToJoinBtn" class="btn btn-secondary">Unirme a una reunión</button>
                <button id="switchToCreateBtn" class="btn btn-secondary">Crear nueva reunión</button>
            </div>
        </div>
    </div>

    <script>
    (function() {
        // contextPath desde el servidor
        var CTX = "<%= request.getContextPath() %>";

        // elementos DOM
        var logoutBtn          = document.getElementById('logoutBtn');
        var joinMeetingBtn     = document.getElementById('joinMeetingBtn');
        var createMeetingBtn   = document.getElementById('createMeetingBtn');
        var meetingModal       = document.getElementById('meetingModal');
        var closeModalBtn      = document.getElementById('closeModalBtn');

        var joinSection        = document.getElementById('joinSection');
        var createSection      = document.getElementById('createSection');
        var switchToJoinBtn    = document.getElementById('switchToJoinBtn');
        var switchToCreateBtn  = document.getElementById('switchToCreateBtn');
        var modalTitle         = document.getElementById('modalTitle');

        var confirmJoinBtn     = document.getElementById('confirmJoinBtn');
        var confirmCreateBtn   = document.getElementById('confirmCreateBtn');

        var joinMeetingCode    = document.getElementById('joinMeetingCode');
        var joinUserName       = document.getElementById('joinUserName');
        var newMeetingName     = document.getElementById('newMeetingName');
        var newMeetingDesc     = document.getElementById('newMeetingDesc');

        // util: generar ID tipo ABC-123
        function generateMeetingId() {
            var letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
            var numbers = '0123456789';
            var id = '';
            for (var i = 0; i < 3; i++) {
                id += letters.charAt(Math.floor(Math.random()*letters.length));
            }
            id += '-';
            for (var j = 0; j < 3; j++) {
                id += numbers.charAt(Math.floor(Math.random()*numbers.length));
            }
            return id;
        }

        // abrir modal en modo "unirse"
        function openJoinModal() {
            modalTitle.textContent = 'Unirse a reunión';
            joinSection.style.display = '';
            createSection.style.display = 'none';
            meetingModal.style.display = 'flex';
        }

        // abrir modal en modo "crear"
        function openCreateModal() {
            modalTitle.textContent = 'Crear reunión';
            joinSection.style.display = 'none';
            createSection.style.display = '';
            meetingModal.style.display = 'flex';
        }

        function closeModal() {
            meetingModal.style.display = 'none';
        }

        // ir a la sala (pantalla.jsp vía servlet)
        function goToRoom(meetingId, meetingName, userName) {
            // PantallaServlet ya hace forward a pantalla.jsp y valida sesión.
            // Le pasamos datos por querystring para que los use JS ahí.
            var url =
                CTX + "/PantallaServlet" +
                "?meetingId=" + encodeURIComponent(meetingId) +
                "&meetingName=" + encodeURIComponent(meetingName) +
                "&userName=" + encodeURIComponent(userName || "");
            window.location.href = url;
        }

        // listeners básicos
        joinMeetingBtn.addEventListener('click', openJoinModal);
        createMeetingBtn.addEventListener('click', openCreateModal);
        closeModalBtn.addEventListener('click', closeModal);

        switchToJoinBtn.addEventListener('click', openJoinModal);
        switchToCreateBtn.addEventListener('click', openCreateModal);

        // confirmación de "unirse"
        confirmJoinBtn.addEventListener('click', function() {
            var code = joinMeetingCode.value.trim();
            var name = joinUserName.value.trim() || 'Invitado';
            if (!code) {
                alert('Ingresa el ID de la reunión');
                return;
            }
            goToRoom(code, "Reunión de proyecto", name);
        });

        // confirmación de "crear"
        confirmCreateBtn.addEventListener('click', function() {
            var name = newMeetingName.value.trim() || "Reunión";
            var desc = newMeetingDesc.value.trim();
            var newId = generateMeetingId();

            // Guardar en localStorage solo como historial visual (opcional)
            var stored = localStorage.getItem('meetings');
            var arr = stored ? JSON.parse(stored) : [];
            arr.push({
                id: newId,
                name: name,
                desc: desc,
                date: new Date().toISOString()
            });
            localStorage.setItem('meetings', JSON.stringify(arr));

            goToRoom(newId, name, joinUserName.value.trim() || 'Host');
        });

        // logout
        logoutBtn.addEventListener('click', function() {
            // invalida sesión en servidor
            window.location.href = CTX + "/LogoutServlet";
        });

        // cerrar modal clickeando fuera
        window.addEventListener('click', function(e) {
            if (e.target === meetingModal) {
                closeModal();
            }
        });

        // pintar próximas reuniones desde localStorage
        // (solo visual por ahora)
        var meetingList = document.getElementById('meetingList');
        if (meetingList) {
            var stored2 = localStorage.getItem('meetings');
            if (stored2) {
                var arr2 = JSON.parse(stored2);
                if (arr2.length > 0) {
                    meetingList.innerHTML = "";
                    arr2.forEach(function(m){
                        var li = document.createElement('li');
                        li.innerHTML = "<strong>" + m.name + "</strong> — " + (m.desc || "") ;
                        meetingList.appendChild(li);
                    });
                }
            }
        }

    })();
    </script>

    <style>
        /* estilos mínimos extra (por si tu index.css no los tiene todavía) */
        .user-block {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .user-circle {
            background: #ff7a18;
            color: #fff;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-family: system-ui, sans-serif;
            font-size: 14px;
        }
        .logout-btn {
            background: transparent;
            border: 1px solid #ccc;
            border-radius: 6px;
            padding: 4px 8px;
            font-size: 12px;
            cursor: pointer;
        }
        .logout-btn:hover {
            background: #f5f5f5;
        }

        .card-header-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
        }

        /* modal básico */
        .modal {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.4);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 2000;
        }
        .modal-content {
            background: #fff;
            border-radius: 10px;
            max-width: 400px;
            width: 90%;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            display: flex;
            flex-direction: column;
            max-height: 90vh;
        }
        .modal-header {
            padding: 1rem 1rem 0.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
        }
        .close-btn {
            background: none;
            border: none;
            font-size: 1.2rem;
            line-height: 1;
            cursor: pointer;
        }
        .modal-body {
            padding: 1rem;
            display: flex;
            flex-direction: column;
            gap: .75rem;
        }
        .modal-body label {
            font-size: .85rem;
            font-weight: 500;
        }
        .modal-body input,
        .modal-body textarea {
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 6px;
            padding: .5rem .6rem;
            font-size: .9rem;
        }
        .modal-footer {
            border-top: 1px solid #eee;
            padding: .75rem 1rem;
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: .5rem;
        }
        .btn-primary {
            background: #ff7a18;
            color: #fff;
            border: none;
            border-radius: 6px;
            padding: .5rem .75rem;
            font-size: .8rem;
            cursor: pointer;
        }
        .btn-secondary {
            background: #fff;
            color: #ff7a18;
            border: 1px solid #ff7a18;
            border-radius: 6px;
            padding: .5rem .75rem;
            font-size: .8rem;
            cursor: pointer;
        }
        .btn-primary:hover {
            filter: brightness(1.05);
        }
        .btn-secondary:hover {
            background: rgba(255,122,24,0.07);
        }
    </style>
</body>
</html>
