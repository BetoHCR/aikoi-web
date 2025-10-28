package com.aikoi.servlet;

import com.aikoi.util.DBUtil;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegistroServlet")
public class RegistroServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Responder JSON
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (PrintWriter out = response.getWriter()) {
            if (name == null || email == null || password == null ||
                name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false, \"message\":\"Faltan parámetros\"}");
                return;
            }

            Connection conn = null;
            PreparedStatement check = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                conn = DBUtil.getConnection(); // debe ser public static Connection getConnection()
                if (conn == null) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"success\":false, \"message\":\"No se pudo conectar a la base de datos\"}");
                    return;
                }

                // Comprueba si el email ya existe (evitar duplicados)
                String checkSql = "SELECT 1 FROM users WHERE email = ?";
                check = conn.prepareStatement(checkSql);
                check.setString(1, email);
                rs = check.executeQuery();
                if (rs.next()) {
                    out.print("{\"success\":false, \"message\":\"El correo ya está registrado\"}");
                    return;
                }
                // Insert
                String sql = "INSERT INTO users(name, email, password_hash) VALUES (?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, password); // en producción usar hash: password_hash

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    out.print("{\"success\":true}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"success\":false, \"message\":\"No se insertó el usuario\"}");
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                // escapar comillas dobles para no romper JSON
                String msg = ex.getMessage() == null ? "Error en la BD" : ex.getMessage().replace("\"","'");
                out.print("{\"success\":false, \"message\":\"Error en la DB: " + msg + "\"}");
            } catch (Exception ex) {
                ex.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                String msg = ex.getMessage() == null ? "Error interno" : ex.getMessage().replace("\"","'");
                out.print("{\"success\":false, \"message\":\"" + msg + "\"}");
            } finally {
                // Cerrar recursos en orden inverso
                try { if (rs != null) rs.close(); } catch (SQLException ignore) {}
                try { if (check != null) check.close(); } catch (SQLException ignore) {}
                try { if (ps != null) ps.close(); } catch (SQLException ignore) {}
                try { if (conn != null) conn.close(); } catch (SQLException ignore) {}
            }
        }
    }
}
