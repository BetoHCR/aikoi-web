package com.aikoi.servlet;

import com.aikoi.util.DBUtil;
import com.aikoi.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/RegistroServlet")
public class RegistroServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String name     = request.getParameter("name");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        PrintWriter out = response.getWriter();

        // Validación simple
        if (name == null || email == null || password == null
                || name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Faltan datos\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            if (conn == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"No hay conexión a BD\"}");
                return;
            }

            // ¿Correo ya existe?
            try (PreparedStatement chk = conn.prepareStatement(
                    "SELECT 1 FROM users WHERE email = ?")) {
                chk.setString(1, email);
                try (ResultSet rs = chk.executeQuery()) {
                    if (rs.next()) {
                        out.print("{\"success\":false,\"message\":\"El correo ya está registrado\"}");
                        return;
                    }
                }
            }

            // Hash y registro
            String hash = PasswordUtil.hash(password);

            try (PreparedStatement ins = conn.prepareStatement(
                    "INSERT INTO users(name,email,password_hash) VALUES(?,?,?)")) {
                ins.setString(1, name);
                ins.setString(2, email);
                ins.setString(3, hash);
                ins.executeUpdate();
            }

            out.print("{\"success\":true,\"message\":\"Cuenta creada\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Error en base de datos\"}");
        }
    }
}
