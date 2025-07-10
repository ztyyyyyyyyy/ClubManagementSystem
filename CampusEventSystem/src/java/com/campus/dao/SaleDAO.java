package com.campus.dao;

import com.campus.model.Sale;
import com.campus.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class SaleDAO {
    
    public boolean recordSale(Sale sale) {
        String sql = "INSERT INTO Sales (user_id, merchandise_id, quantity, unit_price, total_price, payment_method) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, sale.getUserId());
            pstmt.setInt(2, sale.getMerchandiseId());
            pstmt.setInt(3, sale.getQuantity());
            pstmt.setBigDecimal(4, sale.getUnitPrice());
            pstmt.setBigDecimal(5, sale.getTotalPrice());
            pstmt.setString(6, sale.getPaymentMethod());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Sale> getAllSales() {
        List<Sale> sales = new ArrayList<>();
        String sql = "SELECT s.*, u.user_name, m.merchandise_name " +
                    "FROM Sales s " +
                    "JOIN Users u ON s.user_id = u.user_id " +
                    "JOIN Merchandise m ON s.merchandise_id = m.merchandise_id " +
                    "ORDER BY s.sale_date DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Sale sale = new Sale();
                sale.setSaleId(rs.getInt("sale_id"));
                sale.setUserId(rs.getInt("user_id"));
                sale.setMerchandiseId(rs.getInt("merchandise_id"));
                sale.setQuantity(rs.getInt("quantity"));
                sale.setUnitPrice(rs.getBigDecimal("unit_price"));
                sale.setTotalPrice(rs.getBigDecimal("total_price"));
                sale.setPaymentMethod(rs.getString("payment_method"));
                sale.setSaleDate(rs.getTimestamp("sale_date"));
                
                // Set joined data
                sale.setUserName(rs.getString("user_name"));
                sale.setMerchandiseName(rs.getString("merchandise_name"));
                
                sales.add(sale);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sales;
    }
    
    public BigDecimal getTotalRevenue() {
        String sql = "SELECT SUM(total_price) as total_revenue FROM Sales";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                BigDecimal total = rs.getBigDecimal("total_revenue");
                return total != null ? total : BigDecimal.ZERO;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return BigDecimal.ZERO;
    }
    
    public int getTotalItemsSold() {
        String sql = "SELECT SUM(quantity) as total_items FROM Sales";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt("total_items");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    public int getTotalTransactions() {
        String sql = "SELECT COUNT(*) as total_transactions FROM Sales";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt("total_transactions");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    public List<Sale> getTopSellingItems(int limit) {
        List<Sale> topItems = new ArrayList<>();
        String sql = "SELECT m.merchandise_name, SUM(s.quantity) as total_sold, SUM(s.total_price) as total_revenue " +
                    "FROM Sales s " +
                    "JOIN Merchandise m ON s.merchandise_id = m.merchandise_id " +
                    "GROUP BY s.merchandise_id, m.merchandise_name " +
                    "ORDER BY total_sold DESC " +
                    "FETCH FIRST ? ROWS ONLY";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, limit);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Sale sale = new Sale();
                sale.setMerchandiseName(rs.getString("merchandise_name"));
                sale.setQuantity(rs.getInt("total_sold"));
                sale.setTotalPrice(rs.getBigDecimal("total_revenue"));
                topItems.add(sale);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return topItems;
    }
    
    public List<Sale> getSalesByPaymentMethod() {
        List<Sale> paymentStats = new ArrayList<>();
        String sql = "SELECT payment_method, COUNT(*) as transaction_count, SUM(total_price) as total_amount " +
                    "FROM Sales " +
                    "GROUP BY payment_method " +
                    "ORDER BY total_amount DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Sale sale = new Sale();
                sale.setPaymentMethod(rs.getString("payment_method"));
                sale.setQuantity(rs.getInt("transaction_count")); 
                sale.setTotalPrice(rs.getBigDecimal("total_amount"));
                paymentStats.add(sale);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return paymentStats;
    }
}
