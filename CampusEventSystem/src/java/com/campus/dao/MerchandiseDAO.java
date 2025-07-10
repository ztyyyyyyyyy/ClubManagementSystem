package com.campus.dao;

import com.campus.model.Merchandise;
import com.campus.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MerchandiseDAO {
    
    public boolean createMerchandise(Merchandise merchandise) {
        String sql = "INSERT INTO Merchandise (merchandise_name, price, stock, club_id, image_path) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, merchandise.getMerchandiseName());
            pstmt.setBigDecimal(2, merchandise.getPrice());
            pstmt.setInt(3, merchandise.getStock());
            if (merchandise.getClubId() != null) {
                pstmt.setInt(4, merchandise.getClubId());
            } else {
                pstmt.setNull(4, Types.INTEGER);
            }
            pstmt.setString(5, merchandise.getImagePath());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Merchandise> getAllMerchandise() {
        List<Merchandise> merchandiseList = new ArrayList<>();
        String sql = "SELECT * FROM Merchandise ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Merchandise merchandise = new Merchandise();
                merchandise.setMerchandiseId(rs.getInt("merchandise_id"));
                merchandise.setMerchandiseName(rs.getString("merchandise_name"));
                merchandise.setPrice(rs.getBigDecimal("price"));
                merchandise.setStock(rs.getInt("stock"));
                merchandise.setClubId(rs.getObject("club_id", Integer.class));
                merchandise.setImagePath(rs.getString("image_path"));
                merchandise.setCreatedAt(rs.getTimestamp("created_at"));
                merchandiseList.add(merchandise);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return merchandiseList;
    }
    
    public List<Merchandise> getAvailableMerchandise() {
        List<Merchandise> merchandiseList = new ArrayList<>();
        String sql = "SELECT * FROM Merchandise WHERE stock > 0 ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Merchandise merchandise = new Merchandise();
                merchandise.setMerchandiseId(rs.getInt("merchandise_id"));
                merchandise.setMerchandiseName(rs.getString("merchandise_name"));
                merchandise.setPrice(rs.getBigDecimal("price"));
                merchandise.setStock(rs.getInt("stock"));
                merchandise.setClubId(rs.getObject("club_id", Integer.class));
                merchandise.setImagePath(rs.getString("image_path"));
                merchandise.setCreatedAt(rs.getTimestamp("created_at"));
                merchandiseList.add(merchandise);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return merchandiseList;
    }
    
    public Merchandise getMerchandiseById(int merchandiseId) {
        String sql = "SELECT * FROM Merchandise WHERE merchandise_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, merchandiseId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Merchandise merchandise = new Merchandise();
                merchandise.setMerchandiseId(rs.getInt("merchandise_id"));
                merchandise.setMerchandiseName(rs.getString("merchandise_name"));
                merchandise.setPrice(rs.getBigDecimal("price"));
                merchandise.setStock(rs.getInt("stock"));
                merchandise.setClubId(rs.getObject("club_id", Integer.class));
                merchandise.setImagePath(rs.getString("image_path"));
                merchandise.setCreatedAt(rs.getTimestamp("created_at"));
                return merchandise;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public boolean updateMerchandise(Merchandise merchandise) {
        String sql = "UPDATE Merchandise SET merchandise_name = ?, price = ?, stock = ?, club_id = ?, image_path = ? WHERE merchandise_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, merchandise.getMerchandiseName());
            pstmt.setBigDecimal(2, merchandise.getPrice());
            pstmt.setInt(3, merchandise.getStock());
            if (merchandise.getClubId() != null) {
                pstmt.setInt(4, merchandise.getClubId());
            } else {
                pstmt.setNull(4, Types.INTEGER);
            }
            pstmt.setString(5, merchandise.getImagePath());
            pstmt.setInt(6, merchandise.getMerchandiseId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateStock(int merchandiseId, int newStock) {
        String sql = "UPDATE Merchandise SET stock = ? WHERE merchandise_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, newStock);
            pstmt.setInt(2, merchandiseId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteMerchandise(int merchandiseId) {
        String sql = "DELETE FROM Merchandise WHERE merchandise_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, merchandiseId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
