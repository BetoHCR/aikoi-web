<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    // ====== Protección de sesión ======
    String emailLogeado = (String) session.getAttribute("userEmail");
    String nombreLogeado = (String) session.getAttribute("userName");

    if (emailLogeado == null) {
        response.sendRedirect(request.getContextPath() + "/sesion.jsp?message=Inicia+sesion");
        return;
    }

    // Inicial para avatar
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

    <!-- Main -->
    <main class="content">
        <header class="topbar">
            <div class="user-block">
                <div class="user-circle"
                     title="<%= (nombreLogeado != null && !nombreLogeado.isEmpty()) ? nombreLogeado : emailLogeado %>">
                    <%= inicialUsuario %>
                </div>
                <button id="logoutBtn" class="logout-btn" title="Cerrar sesión">Salir</button>
            </div>
        </header>

        <section class="cards">
            <!-- tarjeta de reunión -->
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

            <!-- próximas reuniones -->
            <div class="card">
                <h3>Próximas reuniones</h3>
                <ul id="meetingList">
                    <li>Cargando reuniones...</li>
                </ul>
            </div>
        </section>
    </main>
</div>
     <!-- MODAL flotante (inicia oculto) -->
<div id="meetingModal" class="modal" style="display:none;">
    <div class="modal-content">
        <header class="modal-header">
            <h3 id="modalTitle">Reunión</h3>
            <button id="closeModalBtn" class="close-btn" aria-label="Cerrar">&times;</button>
        </header>

        <div class="modal-body">
            <!-- Tabs -->
            <div class="tabs">
                <button class="tab active" data-tab="join">Unirse</button>
                <button class="tab" data-tab="create">Crear</button>
            </div>

            <!-- TAB: UNIRSE -->
            <div id="joinTab" class="tab-content" style="display:block;">
                <label for="joinMeetingCode">ID de la reunión</label>
                <input id="joinMeetingCode" type="text" placeholder="Ej: ABC-123" />

                <label for="joinUserName">Tu nombre</label>
                <input id="joinUserName" type="text" placeholder="Tu nombre" />
            </div>

            <!-- TAB: CREAR -->
            <div id="createTab" class="tab-content" style="display:none;">
                <label for="newMeetingName">Nombre de la reunión</label>
                <input id="newMeetingName" type="text" placeholder="Ej: Reunión semanal" />

                <label for="newMeetingDesc">Descripción (opcional)</label>
                <textarea id="newMeetingDesc" rows="3"
                          placeholder="Notas, agenda, etc."></textarea>
            </div>
        </div>

        <footer class="modal-footer">
            <button id="cancelMeetingBtn" class="btn btn-secondary">Cancelar</button>

            <button id="confirmJoinBtn" class="btn btn-primary" style="display:inline-block;">Unirse</button>
            <button id="confirmCreateBtn" class="btn btn-primary" style="display:none;">Crear y entrar</button>
        </footer>
    </div>
</div>

<!-- contenedor para toasts -->
<div id="toastContainer" style="position:fixed;right:1rem;bottom:1rem;z-index:3000;"></div>


<!-- contenedor para toasts -->
<div id="toastContainer" style="position:fixed;right:1rem;bottom:1rem;z-index:3000;"></div>


<script>
(function () {
    var CTX = "<%= request.getContextPath() %>";

    // ---------- refs ----------
    var logoutBtn        = document.getElementById('logoutBtn');
    var meetingList      = document.getElementById('meetingList');

    var joinMeetingBtn   = document.getElementById('joinMeetingBtn');
    var createMeetingBtn = document.getElementById('createMeetingBtn');

    var meetingModal     = document.getElementById('meetingModal');
    var closeModalBtn    = document.getElementById('closeModalBtn');
    var cancelMeetingBtn = document.getElementById('cancelMeetingBtn');

    var tabs             = document.querySelectorAll('.tab');
    var modalTitle       = document.getElementById('modalTitle');

    var joinTab          = document.getElementById('joinTab');
    var createTab        = document.getElementById('createTab');

    var confirmJoinBtn   = document.getElementById('confirmJoinBtn');
    var confirmCreateBtn = document.getElementById('confirmCreateBtn');

    var joinMeetingCode  = document.getElementById('joinMeetingCode');
    var joinUserName     = document.getElementById('joinUserName');

    // ESTOS TIENEN QUE EXISTIR EN EL HTML:
    var newMeetingName   = document.getElementById('newMeetingName');
    var newMeetingDesc   = document.getElementById('newMeetingDesc');

    var toastContainer   = document.getElementById('toastContainer');
    if (!toastContainer) {
        toastContainer = document.createElement('div');
        toastContainer.id = 'toastContainer';
        toastContainer.style.position = 'fixed';
        toastContainer.style.right = '1rem';
        toastContainer.style.bottom = '1rem';
        toastContainer.style.zIndex = '3000';
        document.body.appendChild(toastContainer);
    }

    // ---------- utils ----------
    function escapeHtml(str) {
        if (str === null || str === undefined) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function mostrarToast(msg, kind) {
        if (!kind) kind = 'success';
        var div = document.createElement('div');
        div.className = 'custom-alert ' + kind;
        div.textContent = msg;
        toastContainer.appendChild(div);
        setTimeout(function () {
            div.remove();
        }, 3000);
    }

    function generateMeetingId() {
        var letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
        var numbers = '0123456789';
        var out = '';
        for (var i = 0; i < 3; i++) {
            out += letters.charAt(Math.floor(Math.random() * letters.length));
        }
        out += '-';
        for (var j = 0; j < 3; j++) {
            out += numbers.charAt(Math.floor(Math.random() * numbers.length));
        }
        return out;
    }

    function goToRoom(meetingId, meetingName, userName) {
        var url = CTX + "/PantallaServlet"
            + "?meetingId="   + encodeURIComponent(meetingId)
            + "&meetingName=" + encodeURIComponent(meetingName || "")
            + "&userName="    + encodeURIComponent(userName || "");
        window.location.href = url;
    }

    // ---------- modal helpers ----------
    function openModal(tabName) {
        if (!tabName) tabName = 'join';
        setTab(tabName);
        meetingModal.style.display = 'flex';
    }

    function closeModal() {
        meetingModal.style.display = 'none';
    }

    function setTab(tabName) {
        tabs.forEach(function (t) { t.classList.remove('active'); });

        joinTab.style.display = 'none';
        createTab.style.display = 'none';
        confirmJoinBtn.style.display = 'none';
        confirmCreateBtn.style.display = 'none';

        if (tabName === 'create') {
            document.querySelector('.tab[data-tab="create"]').classList.add('active');
            createTab.style.display = 'block';
            modalTitle.textContent = 'Crear reunión';
            confirmCreateBtn.style.display = 'inline-block';
        } else {
            document.querySelector('.tab[data-tab="join"]').classList.add('active');
            joinTab.style.display = 'block';
            modalTitle.textContent = 'Unirse a reunión';
            confirmJoinBtn.style.display = 'inline-block';
        }
    }

    // ---------- cargar reuniones ----------
    async function loadMeetings() {
        if (!meetingList) return;

        meetingList.innerHTML = '<li>Cargando reuniones...</li>';

        try {
            const resp = await fetch(CTX + '/MeetingServlet?action=list', {
                method: 'GET',
                headers: { 'Accept': 'application/json' }
            });

            if (!resp.ok) {
                console.error('HTTP error list', resp.status);
                meetingList.innerHTML = '<li>Error al cargar reuniones (HTTP)</li>';
                return;
            }

            const data = await resp.json();
            console.log('Respuesta /MeetingServlet?action=list:', data);

            if (!data.success) {
                meetingList.innerHTML = '<li>Error al cargar reuniones (backend)</li>';
                return;
            }

            const arr = data.meetings || [];
            if (arr.length === 0) {
                meetingList.innerHTML = '<li>No hay reuniones programadas</li>';
                return;
            }

            meetingList.innerHTML = '';

            arr.forEach(function (m) {
                var safeName = escapeHtml(m.name || m.code || '(sin título)');
                var safeCode = escapeHtml(m.code || '');
                var safeDesc = escapeHtml(m.desc || '');

                var li = document.createElement('li');

                var mainLine =
                    '<strong>' + safeName + '</strong>' +
                    ' — <span class="meeting-code">' + safeCode + '</span> ' +
                    '<button class="btn-mini"' +
                    ' data-meeting-id="'   + safeCode + '"' +
                    ' data-meeting-name="' + safeName + '"' +
                    ' data-meeting-desc="' + safeDesc + '">Entrar</button>';

                if (safeDesc) {
                    mainLine +=
                        '<div class="meeting-desc">' +
                        safeDesc +
                        '</div>';
                }

                li.innerHTML = mainLine;
                meetingList.appendChild(li);
            });

            meetingList.querySelectorAll('.btn-mini').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var mid   = this.getAttribute('data-meeting-id');
                    var mname = this.getAttribute('data-meeting-name');
                    var uname = (joinUserName && joinUserName.value.trim()) || 'Invitado';

                    if (!mid) {
                        mostrarToast('Esta reunión no tiene ID válido', 'error');
                        return;
                    }

                    goToRoom(mid, mname, uname);
                });
            });

        } catch (err) {
            console.error('JS error loadMeetings', err);
            meetingList.innerHTML = '<li>Error al cargar reuniones (JS)</li>';
        }
    }

    // ---------- crear reunión ----------
    async function createMeetingAndJoin() {
        // TOMAMOS EXACTAMENTE LO QUE EL USUARIO ESCRIBIÓ
        var name  = (newMeetingName && newMeetingName.value.trim()) || 'Reunión';
        var desc  = (newMeetingDesc && newMeetingDesc.value.trim()) || '';
        var uname = (joinUserName   && joinUserName.value.trim())   || 'Host';

        var code = generateMeetingId();

        try {
            const formData = new URLSearchParams();
            formData.append('action', 'create');
            formData.append('meetingCode', code);
            formData.append('title', name);        // <--- ESTE ES EL NOMBRE
            formData.append('description', desc);  // <--- ESTA ES LA DESCRIPCIÓN

            const resp = await fetch(CTX + '/MeetingServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                },
                body: formData.toString()
            });

            const text = await resp.text();
            console.log('Respuesta /MeetingServlet create:', text);

            let data;
            try {
                data = JSON.parse(text);
            } catch (e) {
                console.error('Respuesta no JSON al crear reunión:', text);
                mostrarToast('Respuesta inesperada del servidor', 'error');
                return;
            }

            if (!resp.ok || !data.success) {
                console.error('Fallo al crear reunión:', data);
                mostrarToast(data.message || 'No se pudo crear la reunión', 'error');
                return;
            }

            closeModal();
            mostrarToast('Reunión creada', 'success');

            await loadMeetings();

            goToRoom(code, name, uname);

        } catch (err) {
            console.error('Error creando reunión:', err);
            mostrarToast('Error de red al crear la reunión', 'error');
        }
    }

    // ---------- unirse ----------
    function joinExistingMeeting() {
        var code  = (joinMeetingCode && joinMeetingCode.value.trim()) || '';
        var uname = (joinUserName   && joinUserName.value.trim())    || 'Invitado';

        if (!code) {
            mostrarToast('Ingresa el ID de la reunión', 'error');
            return;
        }

        var btnExistente = meetingList.querySelector(
            '.btn-mini[data-meeting-id="' + code.replace(/"/g,'&quot;') + '"]'
        );

        if (!btnExistente) {
            mostrarToast('No existe una reunión con ese ID', 'error');
            return;
        }

        var roomName = btnExistente.getAttribute('data-meeting-name') || 'Reunión';

        closeModal();
        goToRoom(code, roomName, uname);
    }

    // ---------- logout ----------
    function doLogout() {
        window.location.href = CTX + "/LogoutServlet";
    }

    // ---------- listeners ----------
    if (joinMeetingBtn) {
        joinMeetingBtn.addEventListener('click', function () {
            openModal('join');
        });
    }

    if (createMeetingBtn) {
        createMeetingBtn.addEventListener('click', function () {
            openModal('create');
        });
    }

    tabs.forEach(function (tabBtn) {
        tabBtn.addEventListener('click', function () {
            var which = this.getAttribute('data-tab');
            setTab(which);
        });
    });

    if (closeModalBtn) {
        closeModalBtn.addEventListener('click', closeModal);
    }
    if (cancelMeetingBtn) {
        cancelMeetingBtn.addEventListener('click', closeModal);
    }

    if (confirmJoinBtn) {
        confirmJoinBtn.addEventListener('click', joinExistingMeeting);
    }
    if (confirmCreateBtn) {
        confirmCreateBtn.addEventListener('click', createMeetingAndJoin);
    }

    if (logoutBtn) {
        logoutBtn.addEventListener('click', doLogout);
    }

    // ---------- init ----------
    loadMeetings();
})();
</script>


</body>
</html>