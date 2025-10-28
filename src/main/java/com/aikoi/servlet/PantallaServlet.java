package com.aikoi.servlet;

import java.io.IOException;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/PantallaServlet")
public class PantallaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public PantallaServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Poner la fecha de hoy en formato ISO (yyyy-MM-dd)
        String today = LocalDate.now().toString();
        request.setAttribute("today", today);

        // Opcional: pasar nombre de usuario desde sesión si lo tienes
        Object userName = request.getSession().getAttribute("userName");
        if (userName != null) {
            request.setAttribute("userName", userName.toString());
        }

        // Forward a la JSP
        request.getRequestDispatcher("/pantalla.jsp").forward(request, response);
    }

    // Si quieres aceptar POST igual que GET
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
