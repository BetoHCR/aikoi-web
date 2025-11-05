package com.aikoi.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DB {
    private static String URL;
    private static String USER;
    private static String PASS;
    private static String DRIVER;

    static {
        try {
            Properties p = new Properties();
            try (InputStream in = DB.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (in == null) throw new RuntimeException("No se encontró db.properties en classpath");
                p.load(in);
            }
            URL = p.getProperty("db.url");
            USER = p.getProperty("db.user");
            PASS = p.getProperty("db.password");
            DRIVER = p.getProperty("db.driver", "com.mysql.cj.jdbc.Driver");
            Class.forName(DRIVER);
        } catch (Exception e) {
            throw new RuntimeException("Error inicializando DB", e);
        }
    }

    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (Exception e) {
            throw new RuntimeException("No se pudo obtener conexión: " + e.getMessage(), e);
        }
    }
}
