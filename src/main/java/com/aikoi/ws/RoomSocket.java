package com.aikoi.ws;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Señalización WebRTC por sala.
 * Protocolo JSON (cliente ⇄ servidor):
 *  - hello {type:"hello", cid:"...", name:"..."}
 *  - chat  {type:"chat",  sender:"...", payload:"..."}
 *  - offer/answer {type:"offer"|"answer", from:"cidA", target:"cidB", sdp:{...}}
 *  - candidate    {type:"candidate",      from:"cidA", target:"cidB", candidate:{...}}
 *  - leave        {type:"leave", cid:"..."} (servidor emite al cerrar)
 */
@ServerEndpoint("/ws/room/{meetingId}")
public class RoomSocket {

    // roomId -> sesiones
    private static final ConcurrentHashMap<String, Set<Session>> ROOMS = new ConcurrentHashMap<>();

    // claves de userProperties
    private static final String KEY_ROOM = "meetingId";
    private static final String KEY_CID  = "cid";
    private static final String KEY_NAME = "name";

    @OnOpen
    public void onOpen(Session session, @PathParam("meetingId") String meetingId) {
        session.getUserProperties().put(KEY_ROOM, meetingId);
        ROOMS.computeIfAbsent(meetingId, k -> ConcurrentHashMap.newKeySet()).add(session);
        // hasta hello no se conoce CID/NAME
    }

    @OnMessage
    public void onMessage(Session session, String text) {
        Map<String, Object> msg = Json.parse(text);      // nunca lanza excepción
        String type = Json.asString(msg.get("type"));
        if (type == null) return;

        String roomId = Json.asString(session.getUserProperties().get(KEY_ROOM));
        if (roomId == null) return;

        switch (type) {
            case "hello": {
                String cid  = Json.asString(msg.get("cid"));
                String name = Json.asString(msg.get("name"));
                if (cid == null || cid.isEmpty()) return;

                session.getUserProperties().put(KEY_CID,  cid);
                session.getUserProperties().put(KEY_NAME, name == null ? "Invitado" : name);

                // notificar a terceros que alguien entró
                broadcastExcept(roomId, session, Json.stringify(Map.of(
                        "type","join","id",cid,"name", session.getUserProperties().get(KEY_NAME)
                )));
                break;
            }
            case "chat": {
                String sender  = Json.asString(msg.get("sender"));
                String payload = Json.asString(msg.get("payload"));
                broadcast(roomId, Json.stringify(Map.of(
                        "type","chat","sender", sender == null ? "Invitado" : sender,
                        "payload", payload == null ? "" : payload
                )));
                break;
            }
            case "offer":
            case "answer":
            case "candidate": {
                String targetCid = Json.asString(msg.get("target"));
                if (targetCid == null) return;
                Session target = findByCid(roomId, targetCid);
                if (target != null && target.isOpen()) {
                    try {
                        target.getBasicRemote().sendText(text);
                    } catch (IOException ignored) {}
                }
                break;
            }
            default:
                // ignorar
        }
    }

    @OnClose
    public void onClose(Session session) {
        String roomId = Json.asString(session.getUserProperties().get(KEY_ROOM));
        String cid    = Json.asString(session.getUserProperties().get(KEY_CID));

        if (roomId != null) {
            Set<Session> set = ROOMS.get(roomId);
            if (set != null) {
                set.remove(session);
                if (set.isEmpty()) ROOMS.remove(roomId);
            }
            if (cid != null) {
                broadcast(roomId, Json.stringify(Map.of("type","leave","id",cid)));
            }
        }
    }

    @OnError
    public void onError(Session session, Throwable t) { /* log opcional */ }

    // ===== util =====

    private Session findByCid(String roomId, String cid) {
        Set<Session> set = ROOMS.get(roomId);
        if (set == null) return null;
        for (Session s : set) {
            Object c = s.getUserProperties().get(KEY_CID);
            if (cid != null && cid.equals(c)) return s;
        }
        return null;
    }

    private void broadcast(String roomId, String text) {
        Set<Session> set = ROOMS.get(roomId);
        if (set == null) return;
        for (Session s : set) {
            if (s.isOpen()) {
                try { s.getBasicRemote().sendText(text); } catch (IOException ignored) {}
            }
        }
    }

    private void broadcastExcept(String roomId, Session except, String text) {
        Set<Session> set = ROOMS.get(roomId);
        if (set == null) return;
        for (Session s : set) {
            if (s != except && s.isOpen()) {
                try { s.getBasicRemote().sendText(text); } catch (IOException ignored) {}
            }
        }
    }

    /**
     * Helper JSON basado en Jackson, sin excepciones checked.
     */
    static final class Json {
        private static final com.fasterxml.jackson.databind.ObjectMapper M =
                new com.fasterxml.jackson.databind.ObjectMapper();

        @SuppressWarnings("unchecked")
        static Map<String, Object> parse(String s) {
            if (s == null || s.isEmpty()) return java.util.Collections.emptyMap();
            try {
                return M.readValue(s, Map.class);
            } catch (Exception e) {
                return java.util.Collections.emptyMap();
            }
        }

        static String stringify(Map<String, ?> m) {
            try {
                return M.writeValueAsString(m);
            } catch (Exception e) {
                return "{}";
            }
        }

        static String asString(Object o) {
            return (o == null) ? null : String.valueOf(o);
        }
    }
}
