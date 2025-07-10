package com.campus.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Merchandise {
    private int merchandiseId;
    private String merchandiseName;
    private BigDecimal price;
    private int stock;
    private Integer clubId;
    private String imagePath;
    private Timestamp createdAt;
    
    // Default constructor
    public Merchandise() {}
    
    // Constructor 
    public Merchandise(String merchandiseName, BigDecimal price, int stock, Integer clubId, String imagePath) {
        this.merchandiseName = merchandiseName;
        this.price = price;
        this.stock = stock;
        this.clubId = clubId;
        this.imagePath = imagePath;
    }
    
    // Getters and Setters
    public int getMerchandiseId() { 
        return merchandiseId; 
    }
    public void setMerchandiseId(int merchandiseId) { 
        this.merchandiseId = merchandiseId; 
    }
    
    public String getMerchandiseName() { 
        return merchandiseName; 
    }
    public void setMerchandiseName(String merchandiseName) { 
        this.merchandiseName = merchandiseName; 
    }
    
    public BigDecimal getPrice() { 
        return price; 
    }
    public void setPrice(BigDecimal price) { 
        this.price = price; 
    }
    
    public int getStock() { 
        return stock; 
    }
    public void setStock(int stock) { 
        this.stock = stock; 
    }
    
    public Integer getClubId() { 
        return clubId; 
    }
    public void setClubId(Integer clubId) { 
        this.clubId = clubId; 
    }
    
    public String getImagePath() { 
        return imagePath; 
    }
    public void setImagePath(String imagePath) { 
        this.imagePath = imagePath; 
    }
    
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
    
}
