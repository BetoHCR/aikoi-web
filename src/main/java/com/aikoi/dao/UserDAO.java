package com.aikoi.dao;
import com.aikoi.model.User; import com.aikoi.util.DBUtil;
import java.sql.*;
public class UserDAO {
  public void saveUser(User u) throws Exception {
    String sql="INSERT INTO users(name,email,password_hash) VALUES (?,?,?)";
    try(Connection c=DBUtil.getConnection(); PreparedStatement p=c.prepareStatement(sql)){ p.setString(1,u.getName()); p.setString(2,u.getEmail()); p.setString(3,u.getPasswordHash()); p.executeUpdate(); }
  }
  public boolean existsByEmail(String email) throws Exception {
    String sql="SELECT 1 FROM users WHERE email=? LIMIT 1"; try(Connection c=DBUtil.getConnection(); PreparedStatement p=c.prepareStatement(sql)){ p.setString(1,email); try(ResultSet r=p.executeQuery()){return r.next();} }
  }
  public User findByEmail(String email) throws Exception {
    String sql="SELECT id,name,email,password_hash FROM users WHERE email=? LIMIT 1";
    try(Connection c=DBUtil.getConnection(); PreparedStatement p=c.prepareStatement(sql)){ p.setString(1,email); try(ResultSet r=p.executeQuery()){ if(r.next()){ User u=new User(); u.setId(r.getInt("id")); u.setName(r.getString("name")); u.setEmail(r.getString("email")); u.setPasswordHash(r.getString("password_hash")); return u;} } } return null;
  }
}
