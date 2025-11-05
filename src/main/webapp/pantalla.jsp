<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // ===== Sesión =====
    String emailLogeado  = (String) session.getAttribute("userEmail");
    String nombreLogeado = (String) session.getAttribute("userName");
    if (emailLogeado == null) {
        response.sendRedirect(request.getContextPath() + "/sesion.jsp?message=Inicia+sesion");
        return;
    }
    String inicialUsuario = "U";
    if (nombreLogeado != null && !nombreLogeado.isEmpty()) {
        inicialUsuario = nombreLogeado.substring(0,1).toUpperCase();
    } else if (emailLogeado != null && !emailLogeado.isEmpty()) {
        inicialUsuario = emailLogeado.substring(0,1).toUpperCase();
    }

    // ===== Atributos del servlet =====
    String todayFromServlet = (String) request.getAttribute("today");
    if (todayFromServlet == null) todayFromServlet = java.time.LocalDate.now().toString();

    String userNameFromServlet = (String) request.getAttribute("userName");
    if (userNameFromServlet == null || userNameFromServlet.isEmpty()) {
        userNameFromServlet = (nombreLogeado != null && !nombreLogeado.isEmpty()) ? nombreLogeado : "Usuario";
    }
    String safeUserNameForJs = userNameFromServlet.replace("\"","\\\"");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Videoconferencia - Fundación Ai-Koi</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Estilos -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pantalla.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

  <!-- Barra de selección de cámara (opcional) -->
  <style>
    .device-toolbar{ display:flex; gap:8px; align-items:center; margin:6px 20px 0 auto; }
    .device-toolbar select{ padding:6px 8px; border-radius:6px; border:1px solid #ddd; font-size:12px;}
    .hide{ display:none; }
  </style>
</head>
<body>
  <div class="meeting-container">
    <!-- ===== HEADER ===== -->
    <div class="meeting-header">
      <!-- Badge de grabación (oculto por defecto) -->
      <div id="recBadge" class="control-btn recording hide" title="Grabando"
           style="width:auto;border-radius:16px;padding:6px 10px">
        <i class="fas fa-circle"></i>
        <small style="margin-left:6px">Grabando</small>
      </div>

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

    <!-- Selector de cámara (quítale "hide" si lo quieres visible) -->
    <div class="device-toolbar hide">
      <label for="camSelect" style="font-size:12px;color:#666">Cámara:</label>
      <select id="camSelect"></select>
    </div>

    <!-- ===== MAIN (GRID DE VIDEO) ===== -->
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

    <!-- ===== CONTROLES ===== -->
    <div class="meeting-controls" id="controlsBar">
      <button class="control-btn" id="toggleMicBtn" title="Micrófono activado" aria-pressed="true">
        <i class="fas fa-microphone"></i>
        <small>Micrófono</small>
      </button>

      <button class="control-btn" id="toggleVideoBtn" title="Cámara activada" aria-pressed="true">
        <i class="fas fa-video"></i>
        <small>Cámara</small>
      </button>

      <button class="control-btn" id="shareScreenBtn" title="Compartir pantalla">
        <i class="fas fa-desktop"></i>
        <small>Pantalla</small>
      </button>

      <button class="control-btn" id="recordBtn" title="Iniciar grabación">
        <i class="fas fa-circle"></i>
        <small>Grabar</small>
      </button>

      <button class="control-btn" id="liveMenuBtn" title="Transmisión en vivo">
        <i class="fas fa-broadcast-tower"></i>
        <small>En vivo</small>
      </button>

      <button class="control-btn" id="participantsBtn" title="Ver participantes">
        <i class="fas fa-users"></i>
        <small>Participantes</small>
      </button>

      <button class="control-btn" id="chatBtn" title="Abrir chat">
        <i class="fas fa-comment-dots"></i>
        <small>Chat</small>
      </button>

      <button class="control-btn end-call" id="endCallBtn" title="Salir de la reunión">
        <i class="fas fa-phone-slash"></i>
        <small>Salir</small>
      </button>
    </div>

    <!-- ===== LIVE MENU ===== -->
    <div class="live-menu" id="liveMenu" style="display:none;">
      <button class="live-platform-btn facebook" id="facebookLiveBtn"><i class="fab fa-facebook"></i> Facebook Live</button>
      <button class="live-platform-btn youtube" id="youtubeLiveBtn"><i class="fab fa-youtube"></i> YouTube Live</button>
      <button class="live-platform-btn instagram" id="instagramLiveBtn"><i class="fab fa-instagram"></i> Instagram Live</button>
    </div>

    <!-- ===== SIDEBAR ===== -->
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

    <!-- ===== LOADER ===== -->
    <div class="loader-overlay" id="loaderOverlay" style="display:none;">
      <div class="loader"></div>
    </div>
  </div><!-- /.meeting-container -->

  <!-- ===== Variables del servidor para JS ===== -->
  <script>
    var SERVER_TODAY     = "<%= todayFromServlet %>";
    var SERVER_USER_NAME = "<%= safeUserNameForJs %>";
    var SERVER_CTX       = "<%= request.getContextPath() %>";
  </script>

  <!-- ===== Lógica JS ===== -->
  <script>
  document.addEventListener('DOMContentLoaded', function(){
    // ===== Utilidades =====
    function escapeHtml(str){ if(str==null) return ''; return String(str)
      .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
      .replace(/"/g,'&quot;').replace(/'/g,'&#39;'); }

    function alertFeedback(message, type){
      var old=document.querySelector('.custom-alert'); if(old) old.remove();
      var box=document.createElement('div'); box.className='custom-alert '+(type||'success');
      box.textContent=message; document.body.appendChild(box); setTimeout(()=>box.remove(),3000);
    }

    function setBtnState(btn, {on, titleOn, titleOff, iconOn, iconOff}){
      if (!btn) return;
      btn.setAttribute('aria-pressed', on ? 'true' : 'false');
      btn.title = on ? titleOn : titleOff;
      const i = btn.querySelector('i');
      if (i){ i.className = 'fas ' + (on ? iconOn : iconOff); }
      const small = btn.querySelector('small');
      if (small){ small.textContent = on ? titleOn.split(' ')[0] : titleOff.split(' ')[0]; }
    }

    function startMeetingTimer(){
      meetingStartTime=new Date();
      timerInterval=setInterval(function(){
        var now=new Date(); var diff=now-meetingStartTime;
        var h=Math.floor(diff/3600000);
        var m=Math.floor((diff%3600000)/60000);
        var s=Math.floor((diff%60000)/1000);
        var t=(h<10?'0'+h:h)+':'+(m<10?'0'+m:m)+':'+(s<10?'0'+s:s);
        var span=meetingTimer.querySelector('span'); if(span) span.textContent=t;
      },1000);
    }

    function setupWebRTC(){ dataChannel={ send:function(msg){ console.log('Mock send:',msg); } }; }

    // ===== Estado =====
    var urlParams = new URLSearchParams(window.location.search);
    var meetingId   = urlParams.get('meetingId')   || 'SIN-ID';
    var meetingName = urlParams.get('meetingName') || 'Reunión';
    var isJoiningExisting = urlParams.has('meetingId');
    var userName = SERVER_USER_NAME && SERVER_USER_NAME.length>0 ? SERVER_USER_NAME : 'Usuario';

    var localStream  = null;
    var screenStream = null;
    var isMicOn      = true;
    var isVideoOn    = true;
    var meetingStartTime=null, timerInterval=null;
    var isRecording  = false;
    var dataChannel  = null;
    var participants = [];
    var currentCamId = null;

    var mediaRecorder = null;
    var recordedChunks = [];
    var recBadge = document.getElementById('recBadge');

    // ===== Refs DOM =====
    var meetingTitle     = document.getElementById('meetingTitle');
    var meetingIdDisplay = document.getElementById('meetingIdDisplay');
    var meetingTimer     = document.getElementById('meetingTimer');
    var meetingInvite    = document.getElementById('meetingInvite');

    var userAvatar     = document.getElementById('userAvatar');
    var localVideo     = document.getElementById('localVideo');
    var localUserNameEl= document.getElementById('localUserName');
    var localMicIcon   = document.getElementById('localMicIcon');
    var localVideoIcon = document.getElementById('localVideoIcon');

    var toggleMicBtn   = document.getElementById('toggleMicBtn');
    var toggleVideoBtn = document.getElementById('toggleVideoBtn');
    var shareScreenBtn = document.getElementById('shareScreenBtn');
    var recordBtn      = document.getElementById('recordBtn');
    var liveMenuBtn    = document.getElementById('liveMenuBtn');
    var liveMenu       = document.getElementById('liveMenu');
    var participantsBtn= document.getElementById('participantsBtn');
    var chatBtn        = document.getElementById('chatBtn');
    var endCallBtn     = document.getElementById('endCallBtn');

    var meetingSidebar   = document.getElementById('meetingSidebar');
    var participantsList = document.getElementById('participantsList');
    var chatMessages     = document.getElementById('chatMessages');
    var chatInput        = document.getElementById('chatInput');
    var sendMessageBtn   = document.getElementById('sendMessageBtn');
    var loaderOverlay    = document.getElementById('loaderOverlay');

    var camSelect        = document.getElementById('camSelect');

    // ===== UI inicial =====
    meetingTitle.textContent     = meetingName;
    meetingIdDisplay.textContent = "ID: " + meetingId;
    localUserNameEl.textContent  = userName;
    userAvatar.textContent       = userName.charAt(0).toUpperCase();
    userAvatar.title             = userName;

    // ===== Participantes =====
    function updateParticipantsList(){
      participantsList.innerHTML='';
      participants.forEach(function(p){
        var item=document.createElement('div');
        item.className='participant-item';
        item.innerHTML =
          '<div class="participant-avatar">'+escapeHtml(p.avatar)+'</div>'+
          '<div class="participant-name">'+escapeHtml(p.name)+'</div>'+
          '<div class="participant-status">'+
            '<i class="fas '+(p.isMicOn?'fa-microphone':'fa-microphone-slash')+'"></i> '+
            '<i class="fas '+(p.isVideoOn?'fa-video':'fa-video-slash')+'"></i>'+
          '</div>';
        participantsList.appendChild(item);
      });
    }

    // ===== Chat =====
    function addChatMessage(sender, message, isLocal){
      var wrap=document.createElement('div');
      wrap.className='chat-message '+(isLocal?'sent':'received');
      var senderHtml = isLocal? '' : '<div class="message-sender">'+escapeHtml(sender)+'</div>';
      wrap.innerHTML='<div class="message-content">'+ senderHtml + '<div>'+escapeHtml(message)+'</div></div>';
      chatMessages.appendChild(wrap);
      chatMessages.scrollTop=chatMessages.scrollHeight;
    }
    function sendChatMessage(){
      var text=chatInput.value.trim(); if(!text) return;
      addChatMessage(userName, text, true);
      chatInput.value='';
      if(dataChannel && typeof dataChannel.send==='function'){ dataChannel.send(text); }
    }

    // ===== Dispositivos / Medios =====
    async function listCameras(){
      const devices = await navigator.mediaDevices.enumerateDevices();
      return devices.filter(d=>d.kind==='videoinput');
    }
    async function populateCameraSelect(){
      if(!camSelect) return;
      const cams = await listCameras();
      camSelect.innerHTML='';
      cams.forEach(c=>{
        const opt=document.createElement('option');
        opt.value = c.deviceId;
        opt.textContent = c.label || '(Cámara)';
        camSelect.appendChild(opt);
      });
      camSelect.onchange = function(){ currentCamId = camSelect.value || null; };
      if(cams.length>0){ currentCamId = cams[0].deviceId; camSelect.value=currentCamId; }
    }

    async function ensureStream({audio=true, video=true, deviceId=null}={}){
      const constraints = {
        audio,
        video: video ? (deviceId ? { deviceId:{ exact: deviceId } }
                               : { width:{ideal:1280}, height:{ideal:720}, facingMode:'user' }) : false
      };
      try{
        const s = await navigator.mediaDevices.getUserMedia(constraints);
        return s;
      }catch(e){
        console.warn('ensureStream error:', e);
        // Si falla la CAM, caemos a solo audio
        if(video && (e.name==='NotReadableError' || e.name==='NotFoundError' || e.name==='OverconstrainedError')){
          const s = await navigator.mediaDevices.getUserMedia({audio:true, video:false});
          alertFeedback('No se pudo iniciar la cámara. Continúas con solo audio.','warning');
          return s;
        }
        throw e;
      }
    }

    async function startMedia(){
      try{
        loaderOverlay.style.display='flex';
        localStream = await ensureStream({ audio:true, video:true, deviceId: currentCamId });

        localVideo.srcObject = localStream;

        const at = localStream.getAudioTracks();
        const vt = localStream.getVideoTracks();
        isMicOn   = at.length ? at[0].enabled!==false : false;
        isVideoOn = vt.length>0;

        localMicIcon.className   = isMicOn  ? 'fas fa-microphone' : 'fas fa-microphone-slash';
        localVideoIcon.className = isVideoOn ? 'fas fa-video'      : 'fas fa-video-slash';

        setBtnState(toggleMicBtn,{
          on:isMicOn, titleOn:'Micrófono activado', titleOff:'Micrófono desactivado',
          iconOn:'fa-microphone', iconOff:'fa-microphone-slash'
        });
        setBtnState(toggleVideoBtn,{
          on:isVideoOn, titleOn:'Cámara activada', titleOff:'Cámara desactivada',
          iconOn:'fa-video', iconOff:'fa-video-slash'
        });

        const me = participants.find(p=>p.id==='local');
        if(me){
          me.isMicOn = isMicOn; me.isVideoOn = isVideoOn;
        }else{
          participants.push({ id:'local', name:userName, avatar:userName.charAt(0).toUpperCase(), isMicOn, isVideoOn });
        }
        updateParticipantsList();

        startMeetingTimer();
        setupWebRTC();

        loaderOverlay.style.display='none';
        if(isJoiningExisting) alertFeedback('Te has unido a la reunión "'+meetingName+'"','success');
        else alertFeedback('Reunión iniciada','success');

      }catch(e){
        loaderOverlay.style.display='none';
        if(e.name==='NotAllowedError'){
          alertFeedback('Debes permitir el acceso a cámara/micrófono en el navegador.','error');
        }else{
          alertFeedback('Error de medios: '+e.name,'error');
        }
      }
    }

    function toggleMicrophone(){
      if(!localStream){ alertFeedback('No hay stream local','error'); return; }
      const at = localStream.getAudioTracks(); if(!at.length){ alertFeedback('No se detectó micrófono','error'); return; }
      isMicOn=!isMicOn; at.forEach(t=>t.enabled=isMicOn);

      localMicIcon.className = isMicOn ? 'fas fa-microphone' : 'fas fa-microphone-slash';
      setBtnState(toggleMicBtn,{
        on:isMicOn,
        titleOn:'Micrófono activado',
        titleOff:'Micrófono desactivado',
        iconOn:'fa-microphone',
        iconOff:'fa-microphone-slash'
      });

      const me=participants.find(p=>p.id==='local'); if(me) me.isMicOn=isMicOn; updateParticipantsList();
      alertFeedback('Micrófono '+(isMicOn?'activado':'desactivado'), isMicOn?'success':'warning');
    }

    async function toggleCamera(){
      if(!localStream){ alertFeedback('No hay stream local','error'); return; }
      const vt = localStream.getVideoTracks();

      if(vt.length===0){
        try{
          const cam = await navigator.mediaDevices.getUserMedia({ video: currentCamId ? {deviceId:{exact:currentCamId}} : true });
          const vtrack = cam.getVideoTracks()[0];
          const newStream = new MediaStream([ ...localStream.getAudioTracks(), vtrack ]);
          localStream.getTracks().forEach(t=>t.stop());
          localStream = newStream;
          localVideo.srcObject = localStream;
          isVideoOn=true;
        }catch(e){
          console.warn('No se pudo encender cámara:', e);
          alertFeedback('No se pudo encender la cámara.','error');
          return;
        }
      }else{
        isVideoOn=!isVideoOn;
        vt.forEach(t=>t.enabled=isVideoOn);
      }

      localVideoIcon.className = isVideoOn ? 'fas fa-video' : 'fas fa-video-slash';
      setBtnState(toggleVideoBtn,{
        on:isVideoOn,
        titleOn:'Cámara activada',
        titleOff:'Cámara desactivada',
        iconOn:'fa-video',
        iconOff:'fa-video-slash'
      });

      const me=participants.find(p=>p.id==='local'); if(me) me.isVideoOn=isVideoOn; updateParticipantsList();
      alertFeedback('Cámara '+(isVideoOn?'activada':'desactivada'), isVideoOn?'success':'warning');
    }

    async function shareScreen(){
      try{
        loaderOverlay.style.display='flex';
        if(screenStream){ stopScreenShare(); }
        screenStream = await navigator.mediaDevices.getDisplayMedia({ video:true, audio:false });
        localVideo.srcObject = screenStream;
        alertFeedback('Compartiendo pantalla','success');
        screenStream.getVideoTracks()[0].onended = stopScreenShare;
        loaderOverlay.style.display='none';
      }catch(e){
        loaderOverlay.style.display='none';
        alertFeedback('No se pudo compartir pantalla','error');
      }
    }
    function stopScreenShare(){
      if(screenStream){ screenStream.getTracks().forEach(t=>t.stop()); screenStream=null; }
      if(localStream){ localVideo.srcObject = localStream; }
      alertFeedback('Dejó de compartir pantalla','warning');
    }

    // ===== Grabación real (MediaRecorder) =====
    function getCurrentRecordableStream(){
      if (screenStream) return screenStream;
      return localStream;
    }
    function bestSupportedMime(){
      const candidates = [
        'video/webm;codecs=vp9,opus',
        'video/webm;codecs=vp8,opus',
        'video/webm'
      ];
      for (const type of candidates){
        if (window.MediaRecorder && MediaRecorder.isTypeSupported(type)) return type;
      }
      return '';
    }
    async function startRecording(){
      const streamToRecord = getCurrentRecordableStream();
      if (!streamToRecord){
        alertFeedback('No hay stream disponible para grabar','error');
        return;
      }
      try{
        recordedChunks = [];
        const mimeType = bestSupportedMime();
        mediaRecorder = mimeType ? new MediaRecorder(streamToRecord, { mimeType })
                                 : new MediaRecorder(streamToRecord);

        mediaRecorder.ondataavailable = (e)=>{
          if (e.data && e.data.size > 0) recordedChunks.push(e.data);
        };
        mediaRecorder.onstop = ()=>{
          const blob = new Blob(
            recordedChunks,
            { type: (mediaRecorder && mediaRecorder.mimeType) || 'video/webm' }
          );
          const url  = URL.createObjectURL(blob);
          const filename = 'grabacion-' + meetingId + '-' + SERVER_TODAY + '.webm';
          const a = document.createElement('a');
          a.style.display = 'none';
          a.href = url;
          a.download = filename;
          document.body.appendChild(a);
          a.click();
          setTimeout(()=>{ URL.revokeObjectURL(url); a.remove(); }, 100);
          alertFeedback('Grabación guardada','success');
        };

        mediaRecorder.start(250);
        isRecording = true;
        recordBtn.classList.add('recording');
        recordBtn.title = 'Detener grabación';
        if (recBadge) recBadge.classList.remove('hide');
        alertFeedback('Grabación iniciada','success');

      }catch(err){
        console.error('MediaRecorder error:', err);
        alertFeedback('No se pudo iniciar la grabación','error');
      }
    }
    function stopRecording(){
      if (!isRecording || !mediaRecorder) return;
      try{ mediaRecorder.stop(); }catch(_){}
      isRecording = false;
      recordBtn.classList.remove('recording');
      recordBtn.title = 'Iniciar grabación';
      if (recBadge) recBadge.classList.add('hide');
    }

    // ===== Sidebar / Invitaciones =====
    function toggleSidebarTo(tabName){
      if(!meetingSidebar.classList.contains('active')) meetingSidebar.classList.add('active');
      var tabs=meetingSidebar.querySelectorAll('.sidebar-tab');
      var contents=meetingSidebar.querySelectorAll('.tab-content');
      tabs.forEach(b=> b.classList.toggle('active', b.getAttribute('data-tab')===tabName));
      contents.forEach(c=> c.classList.toggle('active', c.id===tabName+'Tab'));
    }
    function toggleSidebarOnly(){ meetingSidebar.classList.toggle('active'); }

    function showInviteModal(){
      var modal=document.createElement('div'); modal.className='invite-modal';
      var inviteLink = window.location.origin+window.location.pathname+'?meetingId='+encodeURIComponent(meetingId)+'&meetingName='+encodeURIComponent(meetingName);
      modal.innerHTML =
        '<div class="invite-content">'+
          '<button class="close-invite" id="closeInviteBtn">&times;</button>'+
          '<h3>Invitar participantes</h3>'+
          '<div class="invite-options">'+
            '<div class="invite-option" id="copyLinkOption"><i class="fas fa-link"></i><div><h4>Copiar enlace</h4><p>Envía este enlace</p></div></div>'+
            '<div class="invite-option" id="emailOption"><i class="fas fa-envelope"></i><div><h4>Enviar por correo</h4><p>Comparte por correo</p></div></div>'+
            '<div class="invite-option" id="whatsappOption"><i class="fab fa-whatsapp"></i><div><h4>WhatsApp</h4><p>Compartir</p></div></div>'+
          '</div>'+
          '<div class="invite-link-container">'+
            '<input type="text" class="invite-link" value="'+inviteLink.replace(/"/g,'&quot;')+'" readonly id="inviteLinkInput">'+
            '<button class="copy-btn" id="copyLinkBtn">Copiar enlace</button>'+
          '</div>'+
        '</div>';
      document.body.appendChild(modal);
      document.getElementById('closeInviteBtn').onclick = ()=>modal.remove();
      function copyLink(){ var i=document.getElementById('inviteLinkInput'); i.select(); document.execCommand('copy'); alertFeedback('Enlace copiado','success'); }
      document.getElementById('copyLinkBtn').onclick=copyLink;
      document.getElementById('copyLinkOption').onclick=copyLink;
      document.getElementById('emailOption').onclick = ()=> window.location.href="mailto:?subject=Invitación: "+encodeURIComponent(meetingName)+"&body="+encodeURIComponent(inviteLink);
      document.getElementById('whatsappOption').onclick = ()=> window.open("https://wa.me/?text="+encodeURIComponent("Únete a mi reunión: "+inviteLink), "_blank");
    }

    // ===== Listeners =====
    toggleMicBtn.addEventListener('click', toggleMicrophone);
    toggleVideoBtn.addEventListener('click', toggleCamera);
    shareScreenBtn.addEventListener('click', ()=> screenStream ? stopScreenShare() : shareScreen());
    recordBtn.addEventListener('click', ()=> isRecording ? stopRecording() : startRecording());
    liveMenuBtn.addEventListener('click', ()=> liveMenu.style.display = (liveMenu.style.display==='block')?'none':'block');

    participantsBtn.addEventListener('click', function(){
      var open = meetingSidebar.classList.contains('active');
      if(open && document.querySelector('.sidebar-tab.active[data-tab="participants"]')) { toggleSidebarOnly(); return; }
      toggleSidebarTo('participants');
    });
    chatBtn.addEventListener('click', function(){
      var open = meetingSidebar.classList.contains('active');
      if(open && document.querySelector('.sidebar-tab.active[data-tab="chat"]')) { toggleSidebarOnly(); return; }
      toggleSidebarTo('chat');
    });
    meetingInvite.addEventListener('click', showInviteModal);
    sendMessageBtn.addEventListener('click', sendChatMessage);
    chatInput.addEventListener('keypress', function(e){ if(e.key==='Enter') sendChatMessage(); });
    endCallBtn.addEventListener('click', function(){ if(confirm('¿Salir de la reunión?')) window.location.href = SERVER_CTX + '/index.jsp'; });

    // ===== Arranque =====
    (async function init(){
      await populateCameraSelect(); // quita "hide" a .device-toolbar si quieres mostrarlo
      startMedia();
    })();
  });
  </script>
</body>
</html>
