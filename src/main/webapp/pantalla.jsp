<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // ========= CONTROL DE SESIÓN EN SERVIDOR =========
    String emailLogeado = (String) session.getAttribute("userEmail");
    String nombreLogeado = (String) session.getAttribute("userName");

    if (emailLogeado == null) {
        // No hay sesión -> manda a login JSP
        response.sendRedirect(request.getContextPath() + "/sesion.jsp?message=Inicia+sesion");
        return;
    }

    // Inicial/avatar
    String inicialUsuario = "U";
    if (nombreLogeado != null && !nombreLogeado.isEmpty()) {
        inicialUsuario = nombreLogeado.substring(0,1).toUpperCase();
    } else if (emailLogeado != null && !emailLogeado.isEmpty()) {
        inicialUsuario = emailLogeado.substring(0,1).toUpperCase();
    }

    // ========= ATRIBUTOS PASADOS POR EL SERVLET =========
    String todayFromServlet = (String) request.getAttribute("today");
    if (todayFromServlet == null) {
        todayFromServlet = java.time.LocalDate.now().toString();
    }

    String userNameFromServlet = (String) request.getAttribute("userName");
    if (userNameFromServlet == null || userNameFromServlet.isEmpty()) {
        userNameFromServlet = (nombreLogeado != null && !nombreLogeado.isEmpty())
            ? nombreLogeado
            : "Usuario";
    }

    // Sanitizar por si el nombre trae comillas para el JS
    String safeUserNameForJs = userNameFromServlet.replace("\"","\\\"");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Videoconferencia - Fundación Ai-Koi</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pantalla.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
    <div class="meeting-container">
        <div class="meeting-header">
            <div class="logo-container">
                <img src="<%= request.getContextPath() %>/img/logo.png.jpg" alt="Logo Fundación Ai-Koi" class="logo">
                <div class="meeting-title" id="meetingTitle">Reunión de Proyecto</div>
            </div>

            <div class="meeting-id-display">
                <i class="fas fa-users"></i>
                <span id="meetingIdDisplay">ID: CARGANDO...</span>
            </div>

            <div class="meeting-timer" id="meetingTimer">
                <i class="fas fa-clock"></i>
                <span>00:00:00</span>
            </div>

            <div class="meeting-invite" id="meetingInvite">
                <i class="fas fa-user-plus"></i>
                <span>Invitar</span>
            </div>

            <div class="user-avatar" id="userAvatar" title="<%= userNameFromServlet %>"><%= inicialUsuario %></div>
        </div>

        <div class="meeting-main">
            <div class="video-grid" id="videoGrid">
                <div class="video-item" id="localVideoContainer">
                    <video id="localVideo" autoplay playsinline muted></video>
                    <div class="user-info">
                        <div class="user-name" id="localUserName">Tú</div>
                        <div class="user-status">
                            <i class="fas fa-microphone" id="localMicIcon"></i>
                            <i class="fas fa-video" id="localVideoIcon"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="meeting-controls">
            <button class="control-btn" id="toggleMicBtn"><i class="fas fa-microphone"></i></button>
            <button class="control-btn" id="toggleVideoBtn"><i class="fas fa-video"></i></button>
            <button class="control-btn" id="shareScreenBtn"><i class="fas fa-desktop"></i></button>
            <button class="control-btn" id="recordBtn"><i class="fas fa-circle"></i></button>
            <button class="control-btn live-menu-btn" id="liveMenuBtn"><i class="fas fa-broadcast-tower"></i></button>
            <button class="control-btn" id="participantsBtn"><i class="fas fa-users"></i></button>
            <button class="control-btn" id="chatBtn"><i class="fas fa-comment-dots"></i></button>
            <button class="control-btn end-call" id="endCallBtn"><i class="fas fa-phone-slash"></i></button>
        </div>
    </div>

    <div class="live-menu" id="liveMenu" style="display:none;">
        <button class="live-platform-btn facebook" id="facebookLiveBtn"><i class="fab fa-facebook"></i> Facebook Live</button>
        <button class="live-platform-btn youtube" id="youtubeLiveBtn"><i class="fab fa-youtube"></i> YouTube Live</button>
        <button class="live-platform-btn instagram" id="instagramLiveBtn"><i class="fab fa-instagram"></i> Instagram Live</button>
    </div>

    <div class="meeting-sidebar" id="meetingSidebar">
        <div class="sidebar-tabs">
            <div class="sidebar-tab active" data-tab="participants">Participantes</div>
            <div class="sidebar-tab" data-tab="chat">Chat</div>
        </div>

        <div class="sidebar-content">
            <div class="tab-content active" id="participantsTab">
                <div id="participantsList"></div>
            </div>

            <div class="tab-content" id="chatTab">
                <div id="chatMessages" style="flex: 1; overflow-y: auto;"></div>
                <div class="chat-input-container">
                    <input type="text" class="chat-input" id="chatInput" placeholder="Escribe un mensaje...">
                    <button class="send-btn" id="sendMessageBtn"><i class="fas fa-paper-plane"></i></button>
                </div>
            </div>
        </div>
    </div>

    <div class="loader-overlay" id="loaderOverlay" style="display: none;">
        <div class="loader"></div>
    </div>

    <!-- variables del servidor PARA JS -->
    <script>
      var SERVER_TODAY      = "<%= todayFromServlet %>";
      var SERVER_USER_NAME  = "<%= safeUserNameForJs %>";
      var SERVER_CTX        = "<%= request.getContextPath() %>";
    </script>

    <script>
    document.addEventListener('DOMContentLoaded', function() {

        // ======================
        // utilidades
        // ======================
        function escapeHtml(str) {
            if (str === null || str === undefined) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function generateMeetingId() {
            var letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
            var numbers = '0123456789';
            var id = '';
            for (var i = 0; i < 3; i++) {
                id += letters.charAt(Math.floor(Math.random() * letters.length));
            }
            id += '-';
            for (var j = 0; j < 3; j++) {
                id += numbers.charAt(Math.floor(Math.random() * numbers.length));
            }
            return id;
        }

        function alertFeedback(message, type) {
            var existing = document.querySelector('.custom-alert');
            if (existing) {
                existing.remove();
            }
            var box = document.createElement('div');
            box.className = 'custom-alert ' + (type || 'success');
            box.textContent = message;
            document.body.appendChild(box);
            setTimeout(function() {
                box.remove();
            }, 3000);
        }

        // ======================
        // estado
        // ======================
        var urlParams = new URLSearchParams(window.location.search);
        var meetingId     = urlParams.get('meetingId')   || generateMeetingId();
        var meetingName   = urlParams.get('meetingName') || 'Reunión de Proyecto';
        var isJoiningExisting = urlParams.has('meetingId');

        var userName = SERVER_USER_NAME && SERVER_USER_NAME.length > 0
            ? SERVER_USER_NAME
            : "Usuario";

        var localStream      = null;
        var screenStream     = null;
        var isMicOn          = true;
        var isVideoOn        = true;
        var meetingStartTime = null;
        var timerInterval    = null;
        var isRecording      = false;
        var dataChannel      = null;
        var participants     = [];

        // ======================
        // refs DOM
        // ======================
        var meetingTitle      = document.getElementById('meetingTitle');
        var meetingIdDisplay  = document.getElementById('meetingIdDisplay');
        var meetingTimer      = document.getElementById('meetingTimer');
        var meetingInvite     = document.getElementById('meetingInvite');

        var userAvatar        = document.getElementById('userAvatar');
        var localVideo        = document.getElementById('localVideo');
        var localUserNameEl   = document.getElementById('localUserName');
        var localMicIcon      = document.getElementById('localMicIcon');
        var localVideoIcon    = document.getElementById('localVideoIcon');

        var toggleMicBtn      = document.getElementById('toggleMicBtn');
        var toggleVideoBtn    = document.getElementById('toggleVideoBtn');
        var shareScreenBtn    = document.getElementById('shareScreenBtn');
        var recordBtn         = document.getElementById('recordBtn');
        var liveMenuBtn       = document.getElementById('liveMenuBtn');
        var liveMenu          = document.getElementById('liveMenu');
        var participantsBtn   = document.getElementById('participantsBtn');
        var chatBtn           = document.getElementById('chatBtn');
        var endCallBtn        = document.getElementById('endCallBtn');

        var meetingSidebar    = document.getElementById('meetingSidebar');
        var participantsList  = document.getElementById('participantsList');
        var chatMessages      = document.getElementById('chatMessages');
        var chatInput         = document.getElementById('chatInput');
        var sendMessageBtn    = document.getElementById('sendMessageBtn');
        var loaderOverlay     = document.getElementById('loaderOverlay');

        // ======================
        // init UI
        // ======================
        meetingTitle.textContent     = meetingName;
        meetingIdDisplay.textContent = "ID: " + meetingId;
        localUserNameEl.textContent  = userName;
        userAvatar.textContent       = userName.charAt(0).toUpperCase();
        userAvatar.title             = userName;

        // ======================
        // lógica participantes
        // ======================
        function updateParticipantsList() {
            participantsList.innerHTML = "";

            for (var i=0; i<participants.length; i++) {
                var p = participants[i];
                var item = document.createElement('div');
                item.className = 'participant-item';

                item.innerHTML =
                    '<div class="participant-avatar">' + escapeHtml(p.avatar) + '</div>' +
                    '<div class="participant-name">' + escapeHtml(p.name) + '</div>' +
                    '<div class="participant-status">' +
                        '<i class="fas ' + (p.isMicOn ? 'fa-microphone' : 'fa-microphone-slash') + '"></i> ' +
                        '<i class="fas ' + (p.isVideoOn ? 'fa-video' : 'fa-video-slash') + '"></i>' +
                    '</div>';

                participantsList.appendChild(item);
            }
        }

        // ======================
        // chat
        // ======================
        function addChatMessage(sender, message, isLocal) {
            var messageElement = document.createElement('div');
            messageElement.className = 'chat-message ' + (isLocal ? 'sent' : 'received');

            var senderHtml = "";
            if (!isLocal) {
                senderHtml =
                    '<div class="message-sender">' +
                    escapeHtml(sender) +
                    '</div>';
            }

            var msgHtml =
                '<div>' +
                escapeHtml(message) +
                '</div>';

            messageElement.innerHTML =
                '<div class="message-content">' +
                    senderHtml +
                    msgHtml +
                '</div>';

            chatMessages.appendChild(messageElement);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function sendChatMessage() {
            var text = chatInput.value.trim();
            if (!text) return;

            addChatMessage(userName, text, true);
            chatInput.value = "";

            if (dataChannel && typeof dataChannel.send === "function") {
                dataChannel.send(text);
            }
        }

        // ======================
        // timer
        // ======================
        function startMeetingTimer() {
            meetingStartTime = new Date();
            timerInterval = setInterval(function() {
                var now     = new Date();
                var diff    = now - meetingStartTime;
                var hours   = Math.floor(diff / 3600000);
                var minutes = Math.floor((diff % 3600000) / 60000);
                var seconds = Math.floor((diff % 60000) / 1000);

                var formatted =
                    (hours   <10 ? "0"+hours   : hours)   + ":" +
                    (minutes <10 ? "0"+minutes : minutes) + ":" +
                    (seconds <10 ? "0"+seconds : seconds);

                var span = meetingTimer.querySelector('span');
                if (span) {
                    span.textContent = formatted;
                }
            }, 1000);
        }

        // ======================
        // medios locales
        // ======================
        function setupWebRTC() {
            // Simulado por ahora
            dataChannel = {
                send: function(msg) {
                    console.log("Mock dataChannel send:", msg);
                }
            };
        }

        function toggleMicrophone() {
            if (!localStream) {
                alertFeedback("No hay stream local", "error");
                return;
            }
            var audioTracks = localStream.getAudioTracks();
            if (!audioTracks.length) {
                alertFeedback("No se detectó micrófono", "error");
                return;
            }

            isMicOn = !isMicOn;
            for (var i=0; i<audioTracks.length; i++) {
                audioTracks[i].enabled = isMicOn;
            }

            localMicIcon.className = isMicOn
                ? "fas fa-microphone"
                : "fas fa-microphone-slash";

            for (var j=0; j<participants.length; j++) {
                if (participants[j].id === "local") {
                    participants[j].isMicOn = isMicOn;
                }
            }
            updateParticipantsList();

            alertFeedback(
                "Micrófono " + (isMicOn ? "activado" : "desactivado"),
                isMicOn ? "success" : "warning"
            );
        }

        function toggleCamera() {
            if (!localStream) {
                alertFeedback("No hay stream local", "error");
                return;
            }

            var videoTracks = localStream.getVideoTracks();
            if (!videoTracks.length) {
                alertFeedback("No se detectó cámara", "error");
                return;
            }

            isVideoOn = !isVideoOn;
            for (var i=0; i<videoTracks.length; i++) {
                videoTracks[i].enabled = isVideoOn;
            }

            localVideoIcon.className = isVideoOn
                ? "fas fa-video"
                : "fas fa-video-slash";

            for (var k=0; k<participants.length; k++) {
                if (participants[k].id === "local") {
                    participants[k].isVideoOn = isVideoOn;
                }
            }
            updateParticipantsList();

            alertFeedback(
                "Cámara " + (isVideoOn ? "activada" : "desactivada"),
                isVideoOn ? "success" : "warning"
            );
        }

        async function startMedia() {
            try {
                loaderOverlay.style.display = "flex";

                var constraints = {
                    audio: true,
                    video: {
                        width:  { ideal: 1280 },
                        height: { ideal: 720 },
                        facingMode: "user"
                    }
                };

                localStream = await navigator.mediaDevices.getUserMedia(constraints);
                localVideo.srcObject = localStream;

                isMicOn   = true;
                isVideoOn = true;
                localMicIcon.className   = "fas fa-microphone";
                localVideoIcon.className = "fas fa-video";

                // agrega participante local
                participants.push({
                    id: "local",
                    name: userName,
                    avatar: userName.charAt(0).toUpperCase(),
                    isMicOn: true,
                    isVideoOn: true
                });
                updateParticipantsList();

                startMeetingTimer();
                setupWebRTC();

                loaderOverlay.style.display = "none";

                if (isJoiningExisting) {
                    alertFeedback('Te has unido a la reunión "' + meetingName + '"', "success");
                } else {
                    alertFeedback("Reunión iniciada correctamente", "success");
                }

            } catch (err) {
                console.error("getUserMedia error:", err);
                loaderOverlay.style.display = "none";
                alertFeedback("No se pudo acceder a cámara/micrófono", "error");

                // fallback: aun así arrancamos timer y webrtc simulado
                startMeetingTimer();
                setupWebRTC();
            }
        }

        async function shareScreen() {
            try {
                loaderOverlay.style.display = "flex";

                if (screenStream) {
                    stopScreenShare();
                }

                screenStream = await navigator.mediaDevices.getDisplayMedia({
                    video: true,
                    audio: false
                });

                localVideo.srcObject = screenStream;
                alertFeedback("Compartiendo pantalla", "success");

                // cuando el usuario deje de compartir:
                screenStream.getVideoTracks()[0].onended = function() {
                    stopScreenShare();
                };

                loaderOverlay.style.display = "none";
            } catch (err) {
                loaderOverlay.style.display = "none";
                alertFeedback("No se pudo compartir pantalla", "error");
            }
        }

        function stopScreenShare() {
            if (screenStream) {
                var tracks = screenStream.getTracks();
                for (var i=0; i<tracks.length; i++) {
                    tracks[i].stop();
                }
                screenStream = null;
            }
            if (localStream) {
                localVideo.srcObject = localStream;
            }
            alertFeedback("Dejó de compartir pantalla", "warning");
        }

        function startRecording() {
            var fileName = "grabacion-" + meetingId + "-" + SERVER_TODAY + ".webm";
            isRecording = true;
            recordBtn.classList.add("recording");
            alertFeedback("Grabación iniciada (simulada): " + fileName, "success");
        }

        function stopRecording() {
            if (!isRecording) return;
            isRecording = false;
            recordBtn.classList.remove("recording");
            alertFeedback("Grabación detenida", "success");
        }

        function toggleSidebarTo(tabName) {
            // abre sidebar si no está abierta
            var isOpen = meetingSidebar.classList.contains('active');
            if (!isOpen) {
                meetingSidebar.classList.add('active');
            }

            // pestañas
            var tabButtons = meetingSidebar.querySelectorAll('.sidebar-tab');
            var tabContents = meetingSidebar.querySelectorAll('.tab-content');

            for (var i=0; i<tabButtons.length; i++) {
                var btn = tabButtons[i];
                if (btn.getAttribute('data-tab') === tabName) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            }

            for (var j=0; j<tabContents.length; j++) {
                var tc = tabContents[j];
                if (tc.id === tabName + 'Tab') {
                    tc.classList.add('active');
                } else {
                    tc.classList.remove('active');
                }
            }
        }

        function toggleSidebarOnly() {
            if (meetingSidebar.classList.contains('active')) {
                meetingSidebar.classList.remove('active');
            } else {
                meetingSidebar.classList.add('active');
            }
        }

        function showInviteModal() {
            var modal = document.createElement('div');
            modal.className = "invite-modal";

            var inviteLink =
                window.location.origin +
                window.location.pathname +
                "?meetingId=" + encodeURIComponent(meetingId) +
                "&meetingName=" + encodeURIComponent(meetingName);

            modal.innerHTML =
                '<div class="invite-content">' +
                    '<button class="close-invite" id="closeInviteBtn">&times;</button>' +
                    '<h3>Invitar participantes</h3>' +
                    '<div class="invite-options">' +
                        '<div class="invite-option" id="copyLinkOption">' +
                            '<i class="fas fa-link"></i>' +
                            '<div><h4>Copiar enlace</h4><p>Envía este enlace</p></div>' +
                        '</div>' +
                        '<div class="invite-option" id="emailOption">' +
                            '<i class="fas fa-envelope"></i>' +
                            '<div><h4>Enviar por correo</h4><p>Envía por email</p></div>' +
                        '</div>' +
                        '<div class="invite-option" id="whatsappOption">' +
                            '<i class="fab fa-whatsapp"></i>' +
                            '<div><h4>Compartir por WhatsApp</h4><p>Envía por WhatsApp</p></div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="invite-link-container">' +
                        '<input type="text" class="invite-link" value="' + inviteLink.replace(/"/g,'&quot;') + '" readonly id="inviteLinkInput">' +
                        '<button class="copy-btn" id="copyLinkBtn">Copiar enlace</button>' +
                    '</div>' +
                '</div>';

            document.body.appendChild(modal);

            var closeBtn = document.getElementById('closeInviteBtn');
            closeBtn.addEventListener('click', function() {
                modal.remove();
            });

            function copyLinkToClipboard() {
                var input = document.getElementById('inviteLinkInput');
                input.select();
                document.execCommand('copy');
                alertFeedback("Enlace copiado", "success");
            }

            var copyLinkBtn = document.getElementById('copyLinkBtn');
            var copyLinkOption = document.getElementById('copyLinkOption');
            copyLinkBtn.addEventListener('click', copyLinkToClipboard);
            copyLinkOption.addEventListener('click', copyLinkToClipboard);

            var emailOption = document.getElementById('emailOption');
            emailOption.addEventListener('click', function() {
                window.location.href =
                    "mailto:?subject=Invitación a reunión: " + encodeURIComponent(meetingName) +
                    "&body=Únete: " + encodeURIComponent(inviteLink);
            });

            var whatsappOption = document.getElementById('whatsappOption');
            whatsappOption.addEventListener('click', function() {
                window.open(
                    "https://wa.me/?text=" + encodeURIComponent("Únete a mi reunión: " + inviteLink),
                    "_blank"
                );
            });
        }

        // ======================
        // listeners
        // ======================
        toggleMicBtn.addEventListener("click", toggleMicrophone);
        toggleVideoBtn.addEventListener("click", toggleCamera);

        shareScreenBtn.addEventListener("click", function() {
            if (screenStream) {
                stopScreenShare();
            } else {
                shareScreen();
            }
        });

        recordBtn.addEventListener("click", function() {
            if (isRecording) {
                stopRecording();
            } else {
                startRecording();
            }
        });

        liveMenuBtn.addEventListener("click", function() {
            var isOpen = (liveMenu.style.display === "block");
            liveMenu.style.display = isOpen ? "none" : "block";
        });

        participantsBtn.addEventListener("click", function() {
            // si ya está abierto y ya está en participantes => cerrar
            var isOpen = meetingSidebar.classList.contains('active');
            if (isOpen) {
                var participantsTabActive = document.querySelector('.sidebar-tab.active[data-tab="participants"]');
                if (participantsTabActive) {
                    toggleSidebarOnly();
                    return;
                }
            }
            toggleSidebarTo('participants');
        });

        chatBtn.addEventListener("click", function() {
            var isOpen = meetingSidebar.classList.contains('active');
            if (isOpen) {
                var chatTabActive = document.querySelector('.sidebar-tab.active[data-tab="chat"]');
                if (chatTabActive) {
                    toggleSidebarOnly();
                    return;
                }
            }
            toggleSidebarTo('chat');
        });

        meetingInvite.addEventListener("click", showInviteModal);

        sendMessageBtn.addEventListener("click", sendChatMessage);
        chatInput.addEventListener("keypress", function(e) {
            if (e.key === "Enter") {
                sendChatMessage();
            }
        });

        // botón colgar
        endCallBtn.addEventListener("click", function() {
            if (confirm("¿Salir de la reunión?")) {
                // redirige a la pantalla principal protegida (index.jsp o donde quieras)
                window.location.href = SERVER_CTX + "/index.jsp";
            }
        });

        // ======================
        // arranque
        // ======================
        startMedia();
    });
    </script>
</body>
</html>
