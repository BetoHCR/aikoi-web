package com.aikoi.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/PantallaServlet")
public class PantallaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession s = request.getSession(false);
        if (s == null || s.getAttribute("userEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/sesion.jsp?message=Inicia+sesion");
            return;
        }

        String userName = (String) s.getAttribute("userName");
        if (userName == null || userName.trim().isEmpty()) userName = "Usuario";

        request.setAttribute("today", LocalDate.now().toString());
        request.setAttribute("userName", userName);

        request.getRequestDispatcher("/pantalla.jsp").forward(request, response);
    }
}
