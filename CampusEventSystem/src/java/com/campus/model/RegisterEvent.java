package com.campus.model;

import java.sql.Timestamp;

public class RegisterEvent {
    private int registerId;
    private int userId;
    private int eventId;
    private Timestamp registeredAt;
    
    private String eventTitle;
    private String eventDate;
    private String location;
    private String description;
    
    // Default constructor
    public RegisterEvent() {}
    
    // Constructor 
    public RegisterEvent(int userId, int eventId) {
        this.userId = userId;
        this.eventId = eventId;
    }
    
    // Getters and Setters
    public int getRegisterId() { 
        return registerId; 
    }
    public void setRegisterId(int registerId) { 
        this.registerId = registerId; 
    }
    
    public int getUserId() { 
        return userId; 
    }
    public void setUserId(int userId) { 
        this.userId = userId; 
    }
    
    public int getEventId() { 
        return eventId; 
    }
    public void setEventId(int eventId) { 
        this.eventId = eventId; 
    }
    
    public Timestamp getRegisteredAt() { 
        return registeredAt; 
    }
    public void setRegisteredAt(Timestamp registeredAt) { 
        this.registeredAt = registeredAt; 
    }
    
    public String getEventTitle() { 
        return eventTitle; 
    }
    public void setEventTitle(String eventTitle) { 
        this.eventTitle = eventTitle; 
    }
    
    public String getEventDate() { 
        return eventDate; 
    }
    public void setEventDate(String eventDate) { 
        this.eventDate = eventDate; 
    }
    
    public String getLocation() { 
        return location; 
    }
    public void setLocation(String location) { 
        this.location = location; 
    }
    
    public String getDescription() { 
        return description; 
    }
    public void setDescription(String description) { 
        this.description = description; 
    }
}
