package com.aikoi.servlet;

import com.aikoi.util.DBUtil;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            if (email == null || password == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Faltan parámetros\"}");
                return;
            }

            try (Connection conn = DBUtil.getConnection()) {
                if (conn == null) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"success\":false,\"message\":\"No hay conexión con BD\"}");
                    return;
                }

                // Si usas hashing, reemplaza la comprobación por la verificación apropiada.
                String sql = "SELECT id, name, email, password_hash FROM users WHERE email = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, email);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String storedHash = rs.getString("password_hash");
                            boolean ok;
                            // Si guardaste contraseñas en texto (temporal), compara directo:
                            // ok = password.equals(storedHash);
                            // Si usas BCrypt/password_hash en Java, usa la verificación adecuada:
                            ok = password.equals(storedHash);

                            if (ok) {
                                HttpSession session = request.getSession(true);
                                // crea un objeto minimalista de usuario en sesión
                                session.setAttribute("userEmail", rs.getString("email"));
                                session.setAttribute("userName", rs.getString("name"));
                                out.print("{\"success\":true}");
                                return;
                            } else {
                                out.print("{\"success\":false,\"message\":\"Contraseña incorrecta\"}");
                                return;
                            }
                        } else {
                            out.print("{\"success\":false,\"message\":\"Usuario no encontrado\"}");
                            return;
                        }
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Error interno: " + ex.getMessage().replace("\"","'") + "\"}");
            }
        }
    }
}
