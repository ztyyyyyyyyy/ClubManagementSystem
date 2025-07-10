package com.campus.dao;

import com.campus.model.Event;
import com.campus.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {
    
    public boolean createEvent(Event event) {
        String sql = "INSERT INTO Events (title, event_date, location, description) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, event.getTitle());
            pstmt.setString(2, event.getEventDate());
            pstmt.setString(3, event.getLocation());
            pstmt.setString(4, event.getDescription());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Event> getAllEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM Events ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Event event = new Event();
                event.setEventId(rs.getInt("event_id"));
                event.setTitle(rs.getString("title"));
                event.setEventDate(rs.getString("event_date"));
                event.setLocation(rs.getString("location"));
                event.setDescription(rs.getString("description"));
                event.setCreatedAt(rs.getTimestamp("created_at"));
                events.add(event);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return events;
    }
    
    public Event getEventById(int eventId) {
        String sql = "SELECT * FROM Events WHERE event_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, eventId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Event event = new Event();
                event.setEventId(rs.getInt("event_id"));
                event.setTitle(rs.getString("title"));
                event.setEventDate(rs.getString("event_date"));
                event.setLocation(rs.getString("location"));
                event.setDescription(rs.getString("description"));
                event.setCreatedAt(rs.getTimestamp("created_at"));
                return event;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public boolean updateEvent(Event event) {
        String sql = "UPDATE Events SET title = ?, event_date = ?, location = ?, description = ? WHERE event_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, event.getTitle());
            pstmt.setString(2, event.getEventDate());
            pstmt.setString(3, event.getLocation());
            pstmt.setString(4, event.getDescription());
            pstmt.setInt(5, event.getEventId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteEvent(int eventId) {
        String sql = "DELETE FROM Events WHERE event_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, eventId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
