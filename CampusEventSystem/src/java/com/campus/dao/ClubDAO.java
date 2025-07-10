package com.campus.dao;

import com.campus.model.Club;
import com.campus.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClubDAO {
    
    public boolean createClub(Club club) {
        String sql = "INSERT INTO Clubs (club_name, description) VALUES (?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, club.getClubName());
            pstmt.setString(2, club.getDescription());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Club> getAllClubs() {
        List<Club> clubs = new ArrayList<>();
        String sql = "SELECT * FROM Clubs ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Club club = new Club();
                club.setClubId(rs.getInt("club_id"));
                club.setClubName(rs.getString("club_name"));
                club.setDescription(rs.getString("description"));
                club.setCreatedAt(rs.getTimestamp("created_at"));
                clubs.add(club);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return clubs;
    }
    
    public Club getClubById(int clubId) {
        String sql = "SELECT * FROM Clubs WHERE club_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, clubId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Club club = new Club();
                club.setClubId(rs.getInt("club_id"));
                club.setClubName(rs.getString("club_name"));
                club.setDescription(rs.getString("description"));
                club.setCreatedAt(rs.getTimestamp("created_at"));
                return club;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public boolean updateClub(Club club) {
        String sql = "UPDATE Clubs SET club_name = ?, description = ? WHERE club_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, club.getClubName());
            pstmt.setString(2, club.getDescription());
            pstmt.setInt(3, club.getClubId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteClub(int clubId) {
        String sql = "DELETE FROM Clubs WHERE club_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, clubId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
