package com.campus.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Cart {
    private int cartId;
    private int userId;
    private int merchandiseId;
    private int quantity;
    private BigDecimal totalPrice;
    private Timestamp createdAt;
    
    private String merchandiseName;
    private BigDecimal unitPrice;
    private String imagePath;
    
    // Default constructor
    public Cart() {}
    
    // Constructor 
    public Cart(int userId, int merchandiseId, int quantity, BigDecimal totalPrice) {
        this.userId = userId;
        this.merchandiseId = merchandiseId;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
    }
    
    // Getters and Setters
    public int getCartId() { 
        return cartId; 
    }
    public void setCartId(int cartId) { 
        this.cartId = cartId; 
    }
    
    public int getUserId() { 
        return userId; 
    }
    public void setUserId(int userId) { 
        this.userId = userId; 
    }
    
    public int getMerchandiseId() { 
        return merchandiseId; 
    }
    public void setMerchandiseId(int merchandiseId) { 
        this.merchandiseId = merchandiseId; 
    }
    
    public int getQuantity() { 
        return quantity; 
    }
    public void setQuantity(int quantity) { 
        this.quantity = quantity; 
    }
    
    public BigDecimal getTotalPrice() { 
        return totalPrice; 
    }
    public void setTotalPrice(BigDecimal totalPrice) { 
        this.totalPrice = totalPrice; 
    }
    
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
    
    // Additional getters and setters for joined data
    public String getMerchandiseName() { 
        return merchandiseName; 
    }
    public void setMerchandiseName(String merchandiseName) { 
        this.merchandiseName = merchandiseName; 
    }
    
    public BigDecimal getUnitPrice() { 
        return unitPrice; 
    }
    public void setUnitPrice(BigDecimal unitPrice) { 
        this.unitPrice = unitPrice; 
    }
    
    public String getImagePath() { 
        return imagePath; 
    }
    public void setImagePath(String imagePath) { 
        this.imagePath = imagePath; 
    }
}
