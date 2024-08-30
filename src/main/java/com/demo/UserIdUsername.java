package com.demo;

public class UserIdUsername extends UserId {
    private String username;

    UserIdUsername(String user){
        this.username = user;
    }

    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
}
