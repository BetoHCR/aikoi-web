package com.aikoi.servlet;

import com.aikoi.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/MeetingServlet")
public class MeetingServlet extends HttpServlet {

    // ===================== GET =====================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");
        if (action == null) action = "list";

        PrintWriter out = resp.getWriter();

        if ("list".equalsIgnoreCase(action)) {
            handleListMeetings(out);
        } else {
            handleListMeetings(out); // default
        }
    }

    // ===================== POST =====================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        PrintWriter out = resp.getWriter();

        String action = req.getParameter("action");
        if (action == null) action = "";

        if ("create".equalsIgnoreCase(action)) {
            handleCreateMeeting(req, out);
        } else {
            out.print("{\"success\":false,\"message\":\"Acción no soportada\"}");
        }
    }

    // ===================== LIST =====================
    private void handleListMeetings(PrintWriter out) {
        System.out.println("[MeetingServlet] handleListMeetings() INICIO");

        List<MeetingRow> meetings = new ArrayList<>();

        String sql =
            "SELECT meeting_code, meeting_name, description " +
            "FROM meetings " +
            "ORDER BY created_at DESC " +
            "LIMIT 50";

        try (Connection cn = DBUtil.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                MeetingRow m = new MeetingRow();
                m.code = rs.getString("meeting_code");
                m.name = rs.getString("meeting_name");
                m.desc = rs.getString("description");
                meetings.add(m);
            }

            // armamos JSON manual
            StringBuilder sb = new StringBuilder();
            sb.append("{\"success\":true,\"meetings\":[");

            for (int i = 0; i < meetings.size(); i++) {
                MeetingRow m = meetings.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"code\":").append(jsonString(m.code)).append(",");
                sb.append("\"name\":").append(jsonString(m.name)).append(",");
                sb.append("\"desc\":").append(jsonString(m.desc));
                sb.append("}");
            }

            sb.append("]}");

            String jsonOut = sb.toString();
            System.out.println("[MeetingServlet] handleListMeetings() OK -> " + jsonOut);

            out.print(jsonOut);

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error al listar reuniones\"}");
        }
    }

    // ===================== CREATE =====================
    private void handleCreateMeeting(HttpServletRequest req, PrintWriter out) {

        String code = req.getParameter("meetingCode");
        String title = req.getParameter("title");
        String desc  = req.getParameter("description");

        HttpSession session = req.getSession(false);
        String hostEmail = (session != null)
                ? (String) session.getAttribute("userEmail")
                : null;
        if (hostEmail == null || hostEmail.isEmpty()) {
            hostEmail = "desconocido@example.com";
        }

        System.out.println("[MeetingServlet] handleCreateMeeting(): code=" + code +
                ", title=" + title +
                ", desc=" + desc +
                ", host=" + hostEmail);

        if (code == null || code.isEmpty()
         || title == null || title.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Faltan datos\"}");
            return;
        }

        String sql =
            "INSERT INTO meetings (meeting_code, meeting_name, description, host_email) " +
            "VALUES (?, ?, ?, ?)";

        try (Connection cn = DBUtil.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setString(2, title);
            ps.setString(3, desc);
            ps.setString(4, hostEmail);

            ps.executeUpdate();

            StringBuilder sb = new StringBuilder();
            sb.append("{\"success\":true,\"code\":");
            sb.append(jsonString(code));
            sb.append("}");

            String jsonOut = sb.toString();
            System.out.println("[MeetingServlet] Reunión creada OK -> " + jsonOut);

            out.print(jsonOut);

        } catch (SQLException sqle) {
            sqle.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error SQL al crear la reunión\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error al crear la reunión\"}");
        }
    }

    // ===== helper row =====
    private static class MeetingRow {
        String code;
        String name;
        String desc;
    }

    // ===== escapado JSON seguro =====
    private String jsonString(String s) {
        if (s == null) {
            return "\"\"";
        }
        StringBuilder sb = new StringBuilder("\"");
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < 0x20) {
                        String hex = Integer.toHexString(c | 0x100);
                        sb.append("\\u00").append(hex.substring(hex.length() - 2));
                    } else {
                        sb.append(c);
                    }
            }
        }
        sb.append("\"");
        return sb.toString();
    }
}
