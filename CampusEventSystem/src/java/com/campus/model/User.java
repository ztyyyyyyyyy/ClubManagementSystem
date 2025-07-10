package com.campus.model;

import java.sql.Timestamp;

public class User {
    private int userId;
    private String userName;
    private String email;
    private String password;
    private String role;
    private Timestamp createdAt;
    
    // Default constructor
    public User() {}
    
    // Constructor
    public User(String userName, String email, String password, String role) {
        this.userName = userName;
        this.email = email;
        this.password = password;
        this.role = role;
    }
    
    // Getters and Setters
    public int getUserId() { 
        return userId; 
    }
    public void setUserId(int userId) { 
        this.userId = userId; 
    }
    
    public String getUserName() { 
        return userName; 
    }
    public void setUserName(String userName) { 
        this.userName = userName; 
    }
    
    public String getEmail() { 
        return email; 
    }
    public void setEmail(String email) { 
        this.email = email; 
    }
    
    public String getPassword() { 
        return password; 
    }
    public void setPassword(String password) { 
        this.password = password; 
    }
    
    public String getRole() { 
        return role; 
    }
    public void setRole(String role) { 
        this.role = role; 
    }
    
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
}
