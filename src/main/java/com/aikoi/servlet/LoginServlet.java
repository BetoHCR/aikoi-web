package com.aikoi.servlet;

import com.aikoi.util.DBUtil;
import com.aikoi.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String email = request.getParameter("email");
        String pass  = request.getParameter("password");

        PrintWriter out = response.getWriter();

        if (email == null || pass == null || email.trim().isEmpty() || pass.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Datos incompletos\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            if (conn == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"No hay conexión a BD\"}");
                return;
            }

            String name = null;
            String hash = null;

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT name, password_hash FROM users WHERE email=?")) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        name = rs.getString(1);
                        hash = rs.getString(2);
                    }
                }
            }

            if (hash == null || !PasswordUtil.verify(pass, hash)) {
                out.print("{\"success\":false,\"message\":\"Credenciales inválidas\"}");
                return;
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("userEmail", email);
            session.setAttribute("userName",  name);

            out.print("{\"success\":true,\"message\":\"Acceso concedido\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Error en base de datos\"}");
        }
    }
}
