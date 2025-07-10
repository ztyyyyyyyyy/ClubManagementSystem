package com.campus.dao;

import com.campus.model.RegisterEvent;
import com.campus.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RegisterEventDAO {
    
    public boolean registerForEvent(RegisterEvent registration) {
        String sql = "INSERT INTO RegisterEvent (user_id, event_id) VALUES (?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, registration.getUserId());
            pstmt.setInt(2, registration.getEventId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean unregisterFromEvent(int userId, int eventId) {
        String sql = "DELETE FROM RegisterEvent WHERE user_id = ? AND event_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, eventId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean isUserRegistered(int userId, int eventId) {
        String sql = "SELECT COUNT(*) FROM RegisterEvent WHERE user_id = ? AND event_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, eventId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    public List<RegisterEvent> getRegisteredEventsByUserId(int userId) {
        List<RegisterEvent> registrations = new ArrayList<>();
        String sql = "SELECT r.*, e.title, e.event_date, e.location, e.description " +
                    "FROM RegisterEvent r JOIN Events e ON r.event_id = e.event_id " +
                    "WHERE r.user_id = ? ORDER BY r.registered_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                RegisterEvent registration = new RegisterEvent();
                registration.setRegisterId(rs.getInt("register_id"));
                registration.setUserId(rs.getInt("user_id"));
                registration.setEventId(rs.getInt("event_id"));
                registration.setRegisteredAt(rs.getTimestamp("registered_at"));
                
                // Set joined data
                registration.setEventTitle(rs.getString("title"));
                registration.setEventDate(rs.getString("event_date"));
                registration.setLocation(rs.getString("location"));
                registration.setDescription(rs.getString("description"));
                
                registrations.add(registration);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return registrations;
    }
    
    public List<Integer> getRegisteredEventIds(int userId) {
        List<Integer> eventIds = new ArrayList<>();
        String sql = "SELECT event_id FROM RegisterEvent WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                eventIds.add(rs.getInt("event_id"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return eventIds;
    }
    
    public int getEventRegistrationCount(int eventId) {
        String sql = "SELECT COUNT(*) FROM RegisterEvent WHERE event_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, eventId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
}
