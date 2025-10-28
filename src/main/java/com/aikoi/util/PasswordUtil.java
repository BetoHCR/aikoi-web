package com.aikoi.util;
import javax.crypto.SecretKeyFactory; import javax.crypto.spec.PBEKeySpec; import java.security.SecureRandom; import java.util.Base64;
public class PasswordUtil {
  public static String hashPassword(String password) throws Exception {
    byte[] salt=new byte[16]; SecureRandom.getInstanceStrong().nextBytes(salt);
    PBEKeySpec spec=new PBEKeySpec(password.toCharArray(),salt,65536,256);
    byte[] hash=SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
    return Base64.getEncoder().encodeToString(salt)+":"+Base64.getEncoder().encodeToString(hash);
  }
  public static boolean verifyPassword(String password,String stored) throws Exception {
    String[] parts=stored.split(":"); byte[] salt=Base64.getDecoder().decode(parts[0]); byte[] hashStored=Base64.getDecoder().decode(parts[1]);
    PBEKeySpec spec=new PBEKeySpec(password.toCharArray(),salt,65536,256);
    byte[] test=SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
    if(test.length!=hashStored.length) return false; int diff=0; for(int i=0;i<test.length;i++) diff|=test[i]^hashStored[i]; return diff==0;
  }
}
