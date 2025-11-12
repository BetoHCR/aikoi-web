package com.aikoi.util;

import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {

    private PasswordUtil() {}

    /** Genera hash BCrypt con salt interno. */
    public static String hash(String plain) {
        if (plain == null) return null;
        return BCrypt.hashpw(plain, BCrypt.gensalt(10));
    }

    /** Verifica un texto plano contra un hash BCrypt. */
    public static boolean verify(String plain, String hash) {
        if (plain == null || hash == null) return false;
        return BCrypt.checkpw(plain, hash);
    }
}
