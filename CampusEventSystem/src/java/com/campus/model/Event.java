package com.campus.model;

import java.sql.Timestamp;

public class Event {
    private int eventId;
    private String title;
    private String eventDate;
    private String location;
    private String description;
    private Timestamp createdAt;
    
    // Default constructor
    public Event() {}
    
    // Constructor 
    public Event(String title, String eventDate, String location, String description) {
        this.title = title;
        this.eventDate = eventDate;
        this.location = location;
        this.description = description;
    }
    
    // Getters and Setters
    public int getEventId() { 
        return eventId; 
    }
    public void setEventId(int eventId) { 
        this.eventId = eventId; 
    }
    
    public String getTitle() { 
        return title; 
    }
    public void setTitle(String title) { 
        this.title = title; 
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
    
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
}
