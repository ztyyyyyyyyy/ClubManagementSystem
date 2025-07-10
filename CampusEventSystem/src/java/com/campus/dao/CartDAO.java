package com.campus.dao;

import com.campus.model.Cart;
import com.campus.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class CartDAO {
    
    public boolean addToCart(Cart cart) {
        // First check if item already exists in cart
        Cart existingItem = getCartItem(cart.getUserId(), cart.getMerchandiseId());
        
        if (existingItem != null) {
            // Update quantity and total price
            int newQuantity = existingItem.getQuantity() + cart.getQuantity();
            BigDecimal newTotalPrice = existingItem.getTotalPrice().add(cart.getTotalPrice());
            return updateCartItem(existingItem.getCartId(), newQuantity, newTotalPrice);
        } else {
            // Add new item to cart
            String sql = "INSERT INTO Cart (user_id, merchandise_id, quantity, totalprice) VALUES (?, ?, ?, ?)";
            
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                pstmt.setInt(1, cart.getUserId());
                pstmt.setInt(2, cart.getMerchandiseId());
                pstmt.setInt(3, cart.getQuantity());
                pstmt.setBigDecimal(4, cart.getTotalPrice());
                
                return pstmt.executeUpdate() > 0;
                
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }
    }
    
    public Cart getCartItem(int userId, int merchandiseId) {
        String sql = "SELECT * FROM Cart WHERE user_id = ? AND merchandise_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, merchandiseId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Cart cart = new Cart();
                cart.setCartId(rs.getInt("cart_id"));
                cart.setUserId(rs.getInt("user_id"));
                cart.setMerchandiseId(rs.getInt("merchandise_id"));
                cart.setQuantity(rs.getInt("quantity"));
                cart.setTotalPrice(rs.getBigDecimal("totalprice"));
                cart.setCreatedAt(rs.getTimestamp("created_at"));
                return cart;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public List<Cart> getCartByUserId(int userId) {
        List<Cart> cartItems = new ArrayList<>();
        String sql = "SELECT c.*, m.merchandise_name, m.price as unit_price, m.image_path " +
                    "FROM Cart c JOIN Merchandise m ON c.merchandise_id = m.merchandise_id " +
                    "WHERE c.user_id = ? ORDER BY c.created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Cart cart = new Cart();
                cart.setCartId(rs.getInt("cart_id"));
                cart.setUserId(rs.getInt("user_id"));
                cart.setMerchandiseId(rs.getInt("merchandise_id"));
                cart.setQuantity(rs.getInt("quantity"));
                cart.setTotalPrice(rs.getBigDecimal("totalprice"));
                cart.setCreatedAt(rs.getTimestamp("created_at"));
                
                // Set joined data
                cart.setMerchandiseName(rs.getString("merchandise_name"));
                cart.setUnitPrice(rs.getBigDecimal("unit_price"));
                cart.setImagePath(rs.getString("image_path"));
                
                cartItems.add(cart);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return cartItems;
    }
    
    public boolean updateCartItem(int cartId, int quantity, BigDecimal totalPrice) {
        String sql = "UPDATE Cart SET quantity = ?, totalprice = ? WHERE cart_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, quantity);
            pstmt.setBigDecimal(2, totalPrice);
            pstmt.setInt(3, cartId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean removeFromCart(int cartId) {
        String sql = "DELETE FROM Cart WHERE cart_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, cartId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean clearCart(int userId) {
        String sql = "DELETE FROM Cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public BigDecimal getCartTotal(int userId) {
        String sql = "SELECT SUM(totalprice) as total FROM Cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                BigDecimal total = rs.getBigDecimal("total");
                return total != null ? total : BigDecimal.ZERO;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return BigDecimal.ZERO;
    }
    
    public int getCartItemCount(int userId) {
        String sql = "SELECT SUM(quantity) as count FROM Cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
}
