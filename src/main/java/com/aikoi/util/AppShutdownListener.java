package com.aikoi.util;

import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class AppShutdownListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // opcional: métricas/log
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // 1) Detener el hilo de limpieza del conector MySQL (si existe)
        try {
            // MySQL 8.x
            com.mysql.cj.jdbc.AbandonedConnectionCleanupThread.checkedShutdown();
        } catch (Throwable ignore) {
            // Ignora: método ausente en algunos conectores
        }

        // 2) Dar de baja solo los drivers cargados por el classloader de la app
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver d = drivers.nextElement();
            if (d.getClass().getClassLoader() == cl) {
                try {
                    DriverManager.deregisterDriver(d);
                } catch (SQLException ignore) {
                    // opcional: log
                }
            }
        }
    }
}
