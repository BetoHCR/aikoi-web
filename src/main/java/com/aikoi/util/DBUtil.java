package com.aikoi.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.io.InputStream;

public class DBUtil {

    private static String url;
    private static String user;
    private static String pass;

    static {
        try {
            Properties props = new Properties();
            try (InputStream is = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (is == null) {
                    throw new RuntimeException("No se encontró db.properties en el classpath");
                }
                props.load(is);
            }

            url  = props.getProperty("db.url");
            user = props.getProperty("db.user");
            pass = props.getProperty("db.password");

            if (url == null || user == null || pass == null) {
                throw new RuntimeException("Faltan propiedades db.url / db.user / db.password");
            }

            Class.forName(props.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));

        } catch (Exception e) {
            // Si algo falla aquí, explota temprano y claro, en vez de fallar silenciosamente en runtime
            throw new RuntimeException("Error inicializando DBUtil: " + e.getMessage(), e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, pass);
    }
}
