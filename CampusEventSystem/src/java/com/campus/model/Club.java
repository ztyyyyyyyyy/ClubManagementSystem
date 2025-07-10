package com.campus.model;

import java.sql.Timestamp;

public class Club {
    private int clubId;
    private String clubName;
    private String description;
    private Timestamp createdAt;
    
    // Default constructor
    public Club() {}
    
    // Constructor 
    public Club(String clubName, String description) {
        this.clubName = clubName;
        this.description = description;
    }
    
    // Getters and Setters
    public int getClubId() { 
        return clubId; 
    }
    public void setClubId(int clubId) { 
        this.clubId = clubId; 
    }
    
    public String getClubName() { 
        return clubName; 
    }
    public void setClubName(String clubName) { 
        this.clubName = clubName; 
    }
    
    public String getDescription() { 
        return description; 
    }
    public void setDescription(String description) { 
        this.description = description; 
    }
    
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
}
