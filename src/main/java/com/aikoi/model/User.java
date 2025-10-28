package com.aikoi.model;
public class User {
  private Integer id; private String name,email,passwordHash;
  public User() {}
  public User(String name,String email,String passwordHash){this.name=name;this.email=email;this.passwordHash=passwordHash;}
  public Integer getId(){return id;} public void setId(Integer id){this.id=id;}
  public String getName(){return name;} public void setName(String name){this.name=name;}
  public String getEmail(){return email;} public void setEmail(String email){this.email=email;}
  public String getPasswordHash(){return passwordHash;} public void setPasswordHash(String p){this.passwordHash=p;}
}
