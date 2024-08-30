package com.demo;

public class UserIdEmail extends UserId {
    private String email;

    UserIdEmail(String email){
        this.email = email;
    }

    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
}