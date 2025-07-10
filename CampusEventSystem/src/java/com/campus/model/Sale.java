package com.campus.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Sale {
    private int saleId;
    private int userId;
    private int merchandiseId;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private String paymentMethod;
    private Timestamp saleDate;
    
    private String userName;
    private String merchandiseName;
    
    // Default constructor
    public Sale() {}
    
    // Constructor 
    public Sale(int userId, int merchandiseId, int quantity, BigDecimal unitPrice, BigDecimal totalPrice, String paymentMethod) {
        this.userId = userId;
        this.merchandiseId = merchandiseId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = totalPrice;
        this.paymentMethod = paymentMethod;
    }
    
    // Getters and Setters
    public int getSaleId() { 
        return saleId; 
    }
    public void setSaleId(int saleId) { 
        this.saleId = saleId; 
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
    
    public BigDecimal getUnitPrice() { 
        return unitPrice; 
    }
    public void setUnitPrice(BigDecimal unitPrice) { 
        this.unitPrice = unitPrice; 
    }
    
    public BigDecimal getTotalPrice() { 
        return totalPrice; 
    }
    public void setTotalPrice(BigDecimal totalPrice) { 
        this.totalPrice = totalPrice; 
    }
    
    public String getPaymentMethod() { 
        return paymentMethod; 
    }
    public void setPaymentMethod(String paymentMethod) { 
        this.paymentMethod = paymentMethod; 
    }
    
    public Timestamp getSaleDate() { 
        return saleDate; 
    }
    public void setSaleDate(Timestamp saleDate) { 
        this.saleDate = saleDate; 
    }
    
    public String getUserName() { 
        return userName; 
    }
    public void setUserName(String userName) { 
        this.userName = userName; 
    }
    
    public String getMerchandiseName() { 
        return merchandiseName; 
    }
    public void setMerchandiseName(String merchandiseName) { 
        this.merchandiseName = merchandiseName; 
    }
}
