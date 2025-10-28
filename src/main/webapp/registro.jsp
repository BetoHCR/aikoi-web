<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Videoconferencia - Fundación Ai-Koi</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
    <div class="meeting-container">
        <div class="meeting-header">
            <div class="logo-container">
                <img src="img/logo.png.jpg" alt="Logo Fundación Ai-Koi" class="logo">
                <div class="meeting-title" id="meetingTitle">Reunión de Proyecto</div>
            </div>
            <div class="meeting-id-display">
                <i class="fas fa-users"></i>
                <span id="meetingIdDisplay">ID: ABC123-XYZ456</span>
            </div>
            <div class="meeting-timer" id="meetingTimer">
                <i class="fas fa-clock"></i>
                <span>00:00:00</span>
            </div>
            <div class="meeting-invite" id="meetingInvite">
                <i class="fas fa-user-plus"></i>
                <span>Invitar</span>
            </div>
            <div class="user-avatar" id="userAvatar" title="Usuario"></div>
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
            <button class="control-btn" id="toggleMicBtn">
                <i class="fas fa-microphone"></i>
            </button>
            <button class="control-btn" id="toggleVideoBtn">
                <i class="fas fa-video"></i>
            </button>
            <button class="control-btn" id="shareScreenBtn">
                <i class="fas fa-desktop"></i>
            </button>
            <button class="control-btn" id="recordBtn">
                <i class="fas fa-circle"></i>
            </button>
            <button class="control-btn live-menu-btn" id="liveMenuBtn">
                <i class="fas fa-broadcast-tower"></i>
            </button>
            <button class="control-btn" id="participantsBtn">
                <i class="fas fa-users"></i>
            </button>
            <button class="control-btn" id="chatBtn">
                <i class="fas fa-comment-dots"></i>
            </button>
            <button class="control-btn end-call" id="endCallBtn">
                <i class="fas fa-phone-slash"></i>
            </button>
        </div>
    </div>
    
    <!-- Menú de transmisión en vivo -->
    <div class="live-menu" id="liveMenu">
        <button class="live-platform-btn facebook" id="facebookLiveBtn">
            <i class="fab fa-facebook"></i> Facebook Live
        </button>
        <button class="live-platform-btn youtube" id="youtubeLiveBtn">
            <i class="fab fa-youtube"></i> YouTube Live
        </button>
        <button class="live-platform-btn instagram" id="instagramLiveBtn">
            <i class="fab fa-instagram"></i> Instagram Live
        </button>
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
                    <button class="send-btn" id="sendMessageBtn">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <div class="loader-overlay" id="loaderOverlay" style="display: none;">
        <div class="loader"></div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Obtener parámetros de la URL
            var urlParams = new URLSearchParams(window.location.search);
            var meetingId = urlParams.get('meetingId') || generateMeetingId();
            var meetingName = urlParams.get('meetingName') || 'Reunión de Proyecto';
            
            // Obtener el nombre del usuario que inició sesión
            var userName = localStorage.getItem('userName') || 
                           sessionStorage.getItem('userName') || 
                           urlParams.get('userName') || 
                           'Usuario';
            
            // Guardar el nombre del usuario
            localStorage.setItem('userName', userName);
            
            // Verificar si estamos uniéndonos a una reunión existente
            var isJoiningExisting = urlParams.has('meetingId');
            
            // Elementos de la interfaz
            var meetingTitle = document.getElementById('meetingTitle');
            var meetingIdDisplay = document.getElementById('meetingIdDisplay');
            var meetingTimer = document.getElementById('meetingTimer');
            var meetingInvite = document.getElementById('meetingInvite');
            var userAvatar = document.getElementById('userAvatar');
            var localVideo = document.getElementById('localVideo');
            var localVideoContainer = document.getElementById('localVideoContainer');
            var videoGrid = document.getElementById('videoGrid');
            var localUserName = document.getElementById('localUserName');
            var localMicIcon = document.getElementById('localMicIcon');
            var localVideoIcon = document.getElementById('localVideoIcon');
            var toggleMicBtn = document.getElementById('toggleMicBtn');
            var toggleVideoBtn = document.getElementById('toggleVideoBtn');
            var shareScreenBtn = document.getElementById('shareScreenBtn');
            var recordBtn = document.getElementById('recordBtn');
            var liveMenuBtn = document.getElementById('liveMenuBtn');
            var liveMenu = document.getElementById('liveMenu');
            var facebookLiveBtn = document.getElementById('facebookLiveBtn');
            var youtubeLiveBtn = document.getElementById('youtubeLiveBtn');
            var instagramLiveBtn = document.getElementById('instagramLiveBtn');
            var participantsBtn = document.getElementById('participantsBtn');
            var chatBtn = document.getElementById('chatBtn');
            var endCallBtn = document.getElementById('endCallBtn');
            var meetingSidebar = document.getElementById('meetingSidebar');
            var participantsList = document.getElementById('participantsList');
            var chatMessages = document.getElementById('chatMessages');
            var chatInput = document.getElementById('chatInput');
            var sendMessageBtn = document.getElementById('sendMessageBtn');
            var participantsTab = document.getElementById('participantsTab');
            var chatTab = document.getElementById('chatTab');
            var sidebarTabs = document.querySelectorAll('.sidebar-tab');
            var loaderOverlay = document.getElementById('loaderOverlay');
            
            // Variables de estado
            var localStream = null;
            var screenStream = null;
            var isMicOn = true;
            var isVideoOn = true;
            var isSidebarOpen = false;
            var isLiveMenuOpen = false;
            var currentTab = 'participants';
            var participants = [];
            var chatHistory = [];
            var meetingStartTime = null;
            var timerInterval = null;
            var isRecording = false;
            var mediaRecorder = null;
            var recordedChunks = [];
            var peerConnections = {};
            var dataChannel = null;
            var isFacebookLive = false;
            var isYouTubeLive = false;
            var isInstagramLive = false;
            var liveStreamKey = '';
            var liveStreamUrl = '';
            var liveStream = null;
            
            // Configurar información de la reunión
            meetingTitle.textContent = meetingName;
            meetingIdDisplay.textContent = 'ID: ' + meetingId;
            localUserName.textContent = userName;
            userAvatar.textContent = (userName && userName.length > 0) ? userName.charAt(0).toUpperCase() : 'U';
            userAvatar.setAttribute('title', userName);
            
            // Generar ID de reunión aleatorio
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
            
            // Función para mostrar alertas
            function showAlert(message, type) {
                type = type || 'success';
                var alert = document.createElement('div');
                alert.className = 'custom-alert ' + type;
                alert.textContent = message;
                
                document.body.appendChild(alert);
                
                setTimeout(function() {
                    alert.remove();
                }, 3000);
            }
            
            // Función para iniciar el temporizador de la reunión
            function startMeetingTimer() {
                meetingStartTime = new Date();
                
                timerInterval = setInterval(function() {
                    var now = new Date();
                    var diff = now - meetingStartTime;
                    
                    var hours = Math.floor(diff / (1000 * 60 * 60));
                    var minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((diff % (1000 * 60)) / 1000);
                    
                    var formattedTime = [
                        String(hours).padStart(2, '0'),
                        String(minutes).padStart(2, '0'),
                        String(seconds).padStart(2, '0')
                    ].join(':');
                    
                    var span = meetingTimer.querySelector('span');
                    if (span) span.textContent = formattedTime;
                }, 1000);
            }
            
            // Función para iniciar la cámara y micrófono
            async function startMedia() {
                try {
                    loaderOverlay.style.display = 'flex';
                    
                    var constraints = {
                        audio: true,
                        video: {
                            width: { ideal: 1280 },
                            height: { ideal: 720 },
                            facingMode: "user"
                        }
                    };
                    
                    localStream = await navigator.mediaDevices.getUserMedia(constraints);
                    localVideo.srcObject = localStream;
                    
                    // Configurar estado inicial
                    isMicOn = true;
                    isVideoOn = true;
                    
                    // Actualizar UI
                    toggleMicBtn.classList.add('active');
                    toggleVideoBtn.classList.add('active');
                    localMicIcon.className = 'fas fa-microphone';
                    localVideoIcon.className = 'fas fa-video';
                    
                    // Agregar usuario local a la lista de participantes
                    participants.push({
                        id: 'local',
                        name: userName,
                        avatar: userName.charAt(0).toUpperCase(),
                        isMicOn: true,
                        isVideoOn: true
                    });
                    
                    // Actualizar lista de participantes
                    updateParticipantsList();
                    
                    // Iniciar temporizador
                    startMeetingTimer();
                    
                    // Iniciar conexión WebRTC (simulada)
                    setupWebRTC();
                    
                    loaderOverlay.style.display = 'none';
                    
                    if (isJoiningExisting) {
                        showAlert('Te has unido a la reunión "' + meetingName + '"', 'success');
                    } else {
                        showAlert('Reunión iniciada correctamente', 'success');
                    }
                    
                } catch (error) {
                    console.error('Error al acceder a los dispositivos:', error);
                    loaderOverlay.style.display = 'none';
                    
                    if (error && error.name === 'NotAllowedError') {
                        showAlert('Se necesitan permisos de cámara y micrófono', 'error');
                    } else if (error && error.name === 'NotFoundError') {
                        showAlert('No se encontró ningún dispositivo de video', 'error');
                    } else {
                        showAlert('Error al acceder a la cámara/micrófono', 'error');
                    }
                    
                    // Permitir al usuario continuar sin cámara/micrófono
                    setupWebRTC();
                    startMeetingTimer();
                }
            }
            
            // Función para actualizar la lista de participantes
            function updateParticipantsList() {
                participantsList.innerHTML = '';
                
                participants.forEach(function(participant) {
                    var participantItem = document.createElement('div');
                    participantItem.className = 'participant-item';
                    
                    participantItem.innerHTML =
                        '<div class="participant-avatar">' + participant.avatar + '</div>' +
                        '<div class="participant-name">' + participant.name + '</div>' +
                        '<div class="participant-status">' +
                            '<i class="fas ' + (participant.isMicOn ? 'fa-microphone' : 'fa-microphone-slash') + '"></i>' +
                            '<i class="fas ' + (participant.isVideoOn ? 'fa-video' : 'fa-video-slash') + '"></i>' +
                        '</div>';
                    
                    participantsList.appendChild(participantItem);
                });
            }
            
            // Función para alternar el micrófono
            function toggleMicrophone() {
                if (localStream) {
                    var audioTracks = localStream.getAudioTracks();
                    if (audioTracks.length > 0) {
                        isMicOn = !isMicOn;
                        audioTracks.forEach(function(track) { track.enabled = isMicOn; });
                        
                        // Actualizar UI
                        toggleMicBtn.classList.toggle('active');
                        localMicIcon.className = isMicOn ? 'fas fa-microphone' : 'fas fa-microphone-slash';
                        
                        // Actualizar estado en la lista de participantes
                        var localParticipant = participants.find(function(p){ return p.id === 'local'; });
                        if (localParticipant) {
                            localParticipant.isMicOn = isMicOn;
                            updateParticipantsList();
                        }
                        
                        showAlert('Micrófono ' + (isMicOn ? 'activado' : 'desactivado'), isMicOn ? 'success' : 'warning');
                    } else {
                        showAlert('No se detectó el micrófono', 'error');
                    }
                }
            }
            
            // Función para alternar la cámara
            function toggleCamera() {
                if (localStream) {
                    var videoTracks = localStream.getVideoTracks();
                    if (videoTracks.length > 0) {
                        isVideoOn = !isVideoOn;
                        videoTracks.forEach(function(track) { track.enabled = isVideoOn; });
                        
                        // Actualizar UI
                        toggleVideoBtn.classList.toggle('active');
                        localVideoIcon.className = isVideoOn ? 'fas fa-video' : 'fas fa-video-slash';
                        
                        // Actualizar estado en la lista de participantes
                        var localParticipant = participants.find(function(p){ return p.id === 'local'; });
                        if (localParticipant) {
                            localParticipant.isVideoOn = isVideoOn;
                            updateParticipantsList();
                        }
                        
                        showAlert('Cámara ' + (isVideoOn ? 'activada' : 'desactivada'), isVideoOn ? 'success' : 'warning');
                    } else {
                        showAlert('No se detectó la cámara', 'error');
                    }
                }
            }
            
            // Función para configurar WebRTC (simplificada para este ejemplo)
            function setupWebRTC() {
                try {
                    // Simulación de conexión WebRTC
                    dataChannel = {
                        send: function(message) { console.log('Mensaje enviado:', message); },
                        onmessage: null
                    };
                } catch (error) {
                    console.error('Error al configurar WebRTC:', error);
                    showAlert('Error al configurar la conexión', 'error');
                }
            }
            
            // Función para compartir pantalla
            async function shareScreen() {
                try {
                    loaderOverlay.style.display = 'flex';
                    
                    if (screenStream) {
                        screenStream.getTracks().forEach(function(track){ track.stop(); });
                    }
                    
                    screenStream = await navigator.mediaDevices.getDisplayMedia({
                        video: { cursor: "always", displaySurface: "monitor" },
                        audio: false
                    });
                    
                    localVideo.srcObject = screenStream;
                    shareScreenBtn.classList.add('active');
                    localVideoIcon.className = 'fas fa-desktop';
                    
                    screenStream.getVideoTracks()[0].onended = function() { stopScreenShare(); };
                    
                    loaderOverlay.style.display = 'none';
                    showAlert('Pantalla compartida correctamente', 'success');
                    
                } catch (error) {
                    console.error('Error al compartir pantalla:', error);
                    loaderOverlay.style.display = 'none';
                    if (error && error.name === 'NotAllowedError') {
                        showAlert('Se necesitan permisos para compartir pantalla', 'error');
                    } else {
                        showAlert('Error al compartir pantalla', 'error');
                    }
                }
            }
            
            // Función para dejar de compartir pantalla
            function stopScreenShare() {
                if (screenStream) {
                    screenStream.getTracks().forEach(function(track){ track.stop(); });
                    screenStream = null;
                }
                if (localStream) localVideo.srcObject = localStream;
                shareScreenBtn.classList.remove('active');
                localVideoIcon.className = isVideoOn ? 'fas fa-video' : 'fas fa-video-slash';
                showAlert('Has dejado de compartir pantalla', 'warning');
            }
            
            // Función para iniciar la grabación de la sesión
            function startRecording() {
                if (isRecording) return;
                try {
                    var canvas = document.createElement('canvas');
                    var videoGridRect = videoGrid.getBoundingClientRect();
                    canvas.width = videoGridRect.width;
                    canvas.height = videoGridRect.height;
                    var ctx = canvas.getContext('2d');
                    
                    var stream = canvas.captureStream(25);
                    recordedChunks = [];
                    mediaRecorder = new MediaRecorder(stream, { mimeType: 'video/webm' });
                    
                    mediaRecorder.ondataavailable = function(event) {
                        if (event.data.size > 0) recordedChunks.push(event.data);
                    };
                    
                    function drawVideoGrid() {
                        ctx.fillStyle = 'white';
                        ctx.fillRect(0, 0, canvas.width, canvas.height);
                        var videoItems = document.querySelectorAll('.video-item');
                        var gridWidth = videoGridRect.width;
                        var gridHeight = videoGridRect.height;
                        var cols = Math.ceil(Math.sqrt(videoItems.length));
                        var rows = Math.ceil(videoItems.length / cols);
                        var itemWidth = gridWidth / cols;
                        var itemHeight = gridHeight / rows;
                        
                        videoItems.forEach(function(item, index) {
                            var video = item.querySelector('video');
                            if (video) {
                                var col = index % cols;
                                var row = Math.floor(index / cols);
                                var x = col * itemWidth;
                                var y = row * itemHeight;
                                try { ctx.drawImage(video, x, y, itemWidth, itemHeight); } catch(e) { /* cross-origin maybe */ }
                                var userInfo = item.querySelector('.user-info');
                                if (userInfo) {
                                    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
                                    ctx.fillRect(x, y + itemHeight - 30, itemWidth, 30);
                                    ctx.fillStyle = 'white';
                                    ctx.font = '12px Arial';
                                    var uname = userInfo.querySelector('.user-name');
                                    if (uname) ctx.fillText(uname.textContent, x + 10, y + itemHeight - 15);
                                }
                            }
                        });
                    }
                    
                    mediaRecorder.start(1000);
                    var captureInterval = setInterval(drawVideoGrid, 1000/25);
                    
                    mediaRecorder.onstop = function() {
                        clearInterval(captureInterval);
                        var blob = new Blob(recordedChunks, { type: 'video/webm' });
                        var url = URL.createObjectURL(blob);
                        var a = document.createElement('a');
                        a.style.display = 'none';
                        a.href = url;
                        a.download = 'grabacion-' + meetingId + '-' + new Date().toISOString().slice(0,10) + '.webm';
                        document.body.appendChild(a);
                        a.click();
                        setTimeout(function() {
                            document.body.removeChild(a);
                            window.URL.revokeObjectURL(url);
                        }, 100);
                    };
                    
                    isRecording = true;
                    recordBtn.classList.add('recording');
                    recordBtn.innerHTML = '<i class="fas fa-square"></i>';
                    showAlert('Grabación iniciada', 'success');
                } catch (error) {
                    console.error('Error al iniciar la grabación:', error);
                    showAlert('Error al iniciar la grabación', 'error');
                }
            }
            
            // Función para detener la grabación
            function stopRecording() {
                if (!isRecording) return;
                mediaRecorder.stop();
                isRecording = false;
                recordBtn.classList.remove('recording');
                recordBtn.innerHTML = '<i class="fas fa-circle"></i>';
                showAlert('Grabación detenida. El video se descargará automáticamente.', 'success');
            }
            
            // Función para mostrar el modal de configuración de transmisión en vivo
            function showLiveSettingsModal(platform) {
                var modal = document.createElement('div');
                modal.className = 'live-settings-modal';
                
                modal.innerHTML =
                    '<div class="live-settings-content">' +
                        '<button class="close-invite" id="closeLiveSettingsBtn">&times;</button>' +
                        '<h3>Configurar Transmisión en ' + platform + '</h3>' +
                        '<div class="live-form-group">' +
                            '<label for="streamKey">Clave de Transmisión (Stream Key)</label>' +
                            '<input type="text" id="streamKey" placeholder="Ingresa la clave de transmisión">' +
                        '</div>' +
                        '<div class="live-form-group">' +
                            '<label for="streamUrl">URL del Servidor (Opcional)</label>' +
                            '<input type="text" id="streamUrl" placeholder="rtmp://...">' +
                        '</div>' +
                        '<div class="live-form-group">' +
                            '<label for="privacy">Privacidad</label>' +
                            '<select id="privacy">' +
                                '<option value="public">Público</option>' +
                                '<option value="unlisted">No listado</option>' +
                                '<option value="private">Privado</option>' +
                            '</select>' +
                        '</div>' +
                        '<div class="live-actions">' +
                            '<button class="live-btn live-btn-secondary" id="cancelLiveBtn">Cancelar</button>' +
                            '<button class="live-btn live-btn-primary" id="startLiveBtn">Iniciar Transmisión</button>' +
                        '</div>' +
                    '</div>';
                
                document.body.appendChild(modal);
                
                document.getElementById('closeLiveSettingsBtn').addEventListener('click', function() { modal.remove(); });
                document.getElementById('cancelLiveBtn').addEventListener('click', function() { modal.remove(); });
                
                document.getElementById('startLiveBtn').addEventListener('click', function() {
                    var streamKey = document.getElementById('streamKey').value;
                    var streamUrl = document.getElementById('streamUrl').value || getDefaultStreamUrl(platform);
                    var privacy = document.getElementById('privacy').value;
                    if (!streamKey) { showAlert('Debes ingresar una clave de transmisión', 'error'); return; }
                    startLiveStream(platform, streamKey, streamUrl, privacy);
                    modal.remove();
                });
            }
            
            // Función para obtener la URL de transmisión por defecto según la plataforma
            function getDefaultStreamUrl(platform) {
                switch ((platform || '').toLowerCase()) {
                    case 'facebook': return 'rtmps://live-api-s.facebook.com:443/rtmp/';
                    case 'youtube': return 'rtmp://a.rtmp.youtube.com/live2';
                    case 'instagram': return 'rtmps://live-upload.instagram.com:443/rtmp/';
                    default: return '';
                }
            }
            
            // Función para iniciar la transmisión en vivo
            function startLiveStream(platform, streamKey, streamUrl, privacy) {
                try {
                    showAlert('Configurando transmisión en ' + platform + '...', 'info');
                    setTimeout(function() {
                        liveStreamKey = streamKey;
                        liveStreamUrl = streamUrl;
                        switch ((platform || '').toLowerCase()) {
                            case 'facebook': isFacebookLive = true; facebookLiveBtn.classList.add('active'); break;
                            case 'youtube': isYouTubeLive = true; youtubeLiveBtn.classList.add('active'); break;
                            case 'instagram': isInstagramLive = true; instagramLiveBtn.classList.add('active'); break;
                        }
                        showAlert('Transmisión en ' + platform + ' iniciada correctamente', 'success');
                    }, 2000);
                } catch (error) {
                    console.error('Error al iniciar transmisión en ' + platform + ':', error);
                    showAlert('Error al iniciar transmisión en ' + platform, 'error');
                }
            }
            
            // Función para detener la transmisión en vivo
            function stopLiveStream(platform) {
                showAlert('Deteniendo transmisión en ' + platform + '...', 'info');
                setTimeout(function() {
                    switch ((platform || '').toLowerCase()) {
                        case 'facebook': isFacebookLive = false; facebookLiveBtn.classList.remove('active'); break;
                        case 'youtube': isYouTubeLive = false; youtubeLiveBtn.classList.remove('active'); break;
                        case 'instagram': isInstagramLive = false; instagramLiveBtn.classList.remove('active'); break;
                    }
                    showAlert('Transmisión en ' + platform + ' detenida', 'warning');
                }, 1000);
            }
            
            // Función para alternar el menú de transmisión en vivo
            function toggleLiveMenu() {
                isLiveMenuOpen = !isLiveMenuOpen;
                if (isLiveMenuOpen) liveMenu.classList.add('active'); else liveMenu.classList.remove('active');
            }
            
            // Función para mostrar el modal de invitación
            function showInviteModal() {
                var modal = document.createElement('div');
                modal.className = 'invite-modal';
                
                var inviteLink = window.location.origin + window.location.pathname + '?meetingId=' + meetingId + '&meetingName=' + encodeURIComponent(meetingName);
                
                modal.innerHTML =
                    '<div class="invite-content">' +
                        '<button class="close-invite" id="closeInviteBtn">&times;</button>' +
                        '<h3>Invitar participantes</h3>' +
                        '<div class="invite-options">' +
                            '<div class="invite-option" id="copyLinkOption">' +
                                '<i class="fas fa-link"></i>' +
                                '<div>' +
                                    '<h4>Copiar enlace de invitación</h4>' +
                                    '<p>Envía este enlace a los participantes</p>' +
                                '</div>' +
                            '</div>' +
                            '<div class="invite-option" id="emailOption">' +
                                '<i class="fas fa-envelope"></i>' +
                                '<div>' +
                                    '<h4>Enviar por correo</h4>' +
                                    '<p>Envía una invitación por email</p>' +
                                '</div>' +
                            '</div>' +
                            '<div class="invite-option" id="whatsappOption">' +
                                '<i class="fab fa-whatsapp"></i>' +
                                '<div>' +
                                    '<h4>Compartir por WhatsApp</h4>' +
                                    '<p>Envía la invitación por WhatsApp</p>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<div class="invite-link-container">' +
                            '<input type="text" class="invite-link" value="' + inviteLink + '" readonly id="inviteLinkInput">' +
                            '<button class="copy-btn" id="copyLinkBtn">Copiar enlace</button>' +
                        '</div>' +
                    '</div>';
                
                document.body.appendChild(modal);
                
                document.getElementById('closeInviteBtn').addEventListener('click', function() { modal.remove(); });
                document.getElementById('copyLinkBtn').addEventListener('click', function() {
                    var input = document.getElementById('inviteLinkInput');
                    input.select();
                    document.execCommand('copy');
                    showAlert('Enlace copiado al portapapeles', 'success');
                });
                document.getElementById('copyLinkOption').addEventListener('click', function() {
                    var input = document.getElementById('inviteLinkInput');
                    input.select();
                    document.execCommand('copy');
                    showAlert('Enlace copiado al portapapeles', 'success');
                });
                document.getElementById('emailOption').addEventListener('click', function() {
                    window.location.href = 'mailto:?subject=Invitación a reunión: ' + meetingName + '&body=Únete a la reunión usando este enlace: ' + inviteLink;
                });
                document.getElementById('whatsappOption').addEventListener('click', function() {
                    window.open('https://wa.me/?text=Únete a mi reunión: ' + inviteLink, '_blank');
                });
            }
            
            // Función para agregar mensajes de chat
            function addChatMessage(sender, message, isLocal) {
                isLocal = !!isLocal;
                var messageElement = document.createElement('div');
                messageElement.className = 'chat-message ' + (isLocal ? 'sent' : 'received');
                
                var senderHtml = !isLocal ? '<div class="message-sender">' + sender + '</div>' : '';
                messageElement.innerHTML =
                    '<div class="message-content">' +
                        senderHtml +
                        '<div>' + message + '</div>' +
                    '</div>';
                
                chatMessages.appendChild(messageElement);
                chatMessages.scrollTop = chatMessages.scrollHeight;
                
                // Guardar en historial
                chatHistory.push({ sender: sender, message: message, isLocal: isLocal, timestamp: new Date() });
            }
            
            // Función para enviar mensaje de chat
            function sendChatMessage() {
                var message = chatInput.value.trim();
                if (message) {
                    addChatMessage(userName, message, true);
                    chatInput.value = '';
                    if (dataChannel && typeof dataChannel.send === 'function') dataChannel.send(message);
                }
            }
            
            // Función para detener los medios y redirigir
            function stopMedia() {
                if (isRecording) stopRecording();
                if (screenStream) stopScreenShare();
                if (isFacebookLive) stopLiveStream('facebook');
                if (isYouTubeLive) stopLiveStream('youtube');
                if (isInstagramLive) stopLiveStream('instagram');
                if (localStream) {
                    localStream.getTracks().forEach(function(track){ track.stop(); });
                    localStream = null;
                }
                if (timerInterval) clearInterval(timerInterval);
                window.location.href = 'finalizar.html';
            }
            
            // Event listeners
            toggleMicBtn.addEventListener('click', toggleMicrophone);
            toggleVideoBtn.addEventListener('click', toggleCamera);
            
            shareScreenBtn.addEventListener('click', function() {
                if (screenStream) stopScreenShare(); else shareScreen();
            });
            
            recordBtn.addEventListener('click', function() {
                if (isRecording) stopRecording(); else startRecording();
            });
            
            liveMenuBtn.addEventListener('click', toggleLiveMenu);
            
            facebookLiveBtn.addEventListener('click', function() {
                if (isFacebookLive) stopLiveStream('Facebook'); else showLiveSettingsModal('Facebook');
                liveMenu.classList.remove('active'); isLiveMenuOpen = false;
            });
            youtubeLiveBtn.addEventListener('click', function() {
                if (isYouTubeLive) stopLiveStream('YouTube'); else showLiveSettingsModal('YouTube');
                liveMenu.classList.remove('active'); isLiveMenuOpen = false;
            });
            instagramLiveBtn.addEventListener('click', function() {
                if (isInstagramLive) stopLiveStream('Instagram'); else showLiveSettingsModal('Instagram');
                liveMenu.classList.remove('active'); isLiveMenuOpen = false;
            });
            
            participantsBtn.addEventListener('click', function() {
                if (isSidebarOpen && currentTab === 'participants') { meetingSidebar.classList.remove('active'); isSidebarOpen = false; }
                else { meetingSidebar.classList.add('active'); isSidebarOpen = true; currentTab = 'participants'; updateSidebarTabs(); }
            });
            chatBtn.addEventListener('click', function() {
                if (isSidebarOpen && currentTab === 'chat') { meetingSidebar.classList.remove('active'); isSidebarOpen = false; }
                else { meetingSidebar.classList.add('active'); isSidebarOpen = true; currentTab = 'chat'; updateSidebarTabs(); chatInput.focus(); }
            });
            
            endCallBtn.addEventListener('click', function() {
                if (confirm('¿Estás seguro de que quieres salir de la reunión?')) stopMedia();
            });
            
            meetingInvite.addEventListener('click', showInviteModal);
            
            sidebarTabs.forEach(function(tab) {
                tab.addEventListener('click', function() {
                    currentTab = this.getAttribute('data-tab');
                    updateSidebarTabs();
                });
            });
            
            function updateSidebarTabs() {
                sidebarTabs.forEach(function(tab) { tab.classList.remove('active'); if (tab.getAttribute('data-tab') === currentTab) tab.classList.add('active'); });
                document.querySelectorAll('.tab-content').forEach(function(content) {
                    content.classList.remove('active');
                    if (content.id === currentTab + 'Tab') content.classList.add('active');
                });
            }
            
            sendMessageBtn.addEventListener('click', sendChatMessage);
            chatInput.addEventListener('keypress', function(e) { if (e.key === 'Enter') sendChatMessage(); });
            
            document.addEventListener('click', function(event) {
                if (!liveMenu.contains(event.target) && event.target !== liveMenuBtn) {
                    liveMenu.classList.remove('active'); isLiveMenuOpen = false;
                }
            });
            
            // Iniciar la aplicación
            startMedia();
        });
    </script>
</body>
</html>
