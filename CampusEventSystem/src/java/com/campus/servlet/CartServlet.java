package com.campus.servlet;

import com.campus.dao.CartDAO;
import com.campus.dao.MerchandiseDAO;
import com.campus.model.Cart;
import com.campus.model.Merchandise;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {
    private CartDAO cartDAO;
    private MerchandiseDAO merchandiseDAO;
    
    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();
        merchandiseDAO = new MerchandiseDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            switch (action != null ? action : "") {
                case "getCart":
                    handleGetCart(request, response, userId);
                    break;
                case "getCartCount":
                    handleGetCartCount(request, response, userId);
                    break;
                default:
                    response.getWriter().write("{\"error\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"Server error: " + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            switch (action != null ? action : "") {
                case "addToCart":
                    handleAddToCart(request, response, userId);
                    break;
                case "updateQuantity":
                    handleUpdateQuantity(request, response, userId);
                    break;
                case "removeItem":
                    handleRemoveItem(request, response, userId);
                    break;
                case "clearCart":
                    handleClearCart(request, response, userId);
                    break;
                case "checkout":
                    handleCheckout(request, response, userId);
                    break;
                default:
                    response.getWriter().write("{\"error\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"Server error: " + e.getMessage() + "\"}");
        }
    }
    
    private void handleGetCart(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        List<Cart> cartItems = cartDAO.getCartByUserId(userId);
        BigDecimal cartTotal = cartDAO.getCartTotal(userId);
        int itemCount = cartDAO.getCartItemCount(userId);
        
        StringBuilder json = new StringBuilder();
        json.append("{\"items\":[");
        
        for (int i = 0; i < cartItems.size(); i++) {
            Cart item = cartItems.get(i);
            if (i > 0) json.append(",");
            json.append("{")
                .append("\"cartId\":").append(item.getCartId()).append(",")
                .append("\"merchandiseId\":").append(item.getMerchandiseId()).append(",")
                .append("\"merchandiseName\":\"").append(escapeJson(item.getMerchandiseName())).append("\",")
                .append("\"quantity\":").append(item.getQuantity()).append(",")
                .append("\"unitPrice\":").append(item.getUnitPrice()).append(",")
                .append("\"totalPrice\":").append(item.getTotalPrice()).append(",")
                .append("\"imagePath\":\"").append(escapeJson(item.getImagePath())).append("\"")
                .append("}");
        }
        
        json.append("],")
            .append("\"total\":").append(cartTotal).append(",")
            .append("\"itemCount\":").append(itemCount)
            .append("}");
        
        response.getWriter().write(json.toString());
    }
    
    private void handleGetCartCount(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        int itemCount = cartDAO.getCartItemCount(userId);
        response.getWriter().write("{\"count\":" + itemCount + "}");
    }
    
    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        try {
            String merchandiseIdStr = request.getParameter("merchandiseId");
            String quantityStr = request.getParameter("quantity");
            
            if (merchandiseIdStr == null || quantityStr == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
                return;
            }
            
            int merchandiseId = Integer.parseInt(merchandiseIdStr);
            int quantity = Integer.parseInt(quantityStr);
            
            if (quantity <= 0) {
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid quantity\"}");
                return;
            }
            
            Merchandise merchandise = merchandiseDAO.getMerchandiseById(merchandiseId);
            if (merchandise == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Merchandise not found\"}");
                return;
            }
            
            if (merchandise.getStock() < quantity) {
                response.getWriter().write("{\"success\":false,\"message\":\"Insufficient stock available\"}");
                return;
            }
            
            BigDecimal totalPrice = merchandise.getPrice().multiply(new BigDecimal(quantity));
            Cart cart = new Cart(userId, merchandiseId, quantity, totalPrice);
            
            if (cartDAO.addToCart(cart)) {
                response.getWriter().write("{\"success\":true,\"message\":\"Item added to cart successfully\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to add item to cart\"}");
            }
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid number format\"}");
        }
    }
    
    private void handleUpdateQuantity(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        try {
            String cartIdStr = request.getParameter("cartId");
            String quantityStr = request.getParameter("quantity");
            String merchandiseIdStr = request.getParameter("merchandiseId");
            
            if (cartIdStr == null || quantityStr == null || merchandiseIdStr == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
                return;
            }
            
            int cartId = Integer.parseInt(cartIdStr);
            int quantity = Integer.parseInt(quantityStr);
            int merchandiseId = Integer.parseInt(merchandiseIdStr);
            
            if (quantity <= 0) {
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid quantity\"}");
                return;
            }
            
            Cart existingCart = cartDAO.getCartItem(userId, merchandiseId);
            if (existingCart == null || existingCart.getCartId() != cartId) {
                response.getWriter().write("{\"success\":false,\"message\":\"Cart item not found\"}");
                return;
            }
            
            Merchandise merchandise = merchandiseDAO.getMerchandiseById(merchandiseId);
            if (merchandise == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Merchandise not found\"}");
                return;
            }
            
            if (merchandise.getStock() < quantity) {
                response.getWriter().write("{\"success\":false,\"message\":\"Insufficient stock available\"}");
                return;
            }
            
            BigDecimal totalPrice = merchandise.getPrice().multiply(new BigDecimal(quantity));
            
            if (cartDAO.updateCartItem(cartId, quantity, totalPrice)) {
                response.getWriter().write("{\"success\":true,\"message\":\"Cart updated successfully\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to update cart\"}");
            }
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid number format\"}");
        }
    }
    
    private void handleRemoveItem(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        try {
            String cartIdStr = request.getParameter("cartId");
            
            if (cartIdStr == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Missing cart ID\"}");
                return;
            }
            
            int cartId = Integer.parseInt(cartIdStr);
            
            if (cartDAO.removeFromCart(cartId)) {
                response.getWriter().write("{\"success\":true,\"message\":\"Item removed from cart\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to remove item from cart\"}");
            }
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid cart ID\"}");
        }
    }
    
    private void handleClearCart(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        if (cartDAO.clearCart(userId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"Cart cleared successfully\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Failed to clear cart\"}");
        }
    }
    
    private void handleCheckout(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        List<Cart> cartItems = cartDAO.getCartByUserId(userId);
        
        if (cartItems.isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Cart is empty\"}");
            return;
        }
        
        boolean stockAvailable = true;
        String unavailableItem = "";
        
        for (Cart item : cartItems) {
            Merchandise merchandise = merchandiseDAO.getMerchandiseById(item.getMerchandiseId());
            if (merchandise == null || merchandise.getStock() < item.getQuantity()) {
                stockAvailable = false;
                unavailableItem = item.getMerchandiseName();
                break;
            }
        }
        
        if (!stockAvailable) {
            response.getWriter().write("{\"success\":false,\"message\":\"Insufficient stock for " + unavailableItem + "\"}");
            return;
        }
        
        boolean allUpdated = true;
        for (Cart item : cartItems) {
            Merchandise merchandise = merchandiseDAO.getMerchandiseById(item.getMerchandiseId());
            int newStock = merchandise.getStock() - item.getQuantity();
            
            if (!merchandiseDAO.updateStock(item.getMerchandiseId(), newStock)) {
                allUpdated = false;
                break;
            }
        }
        
        if (allUpdated) {
            cartDAO.clearCart(userId);
            response.getWriter().write("{\"success\":true,\"message\":\"Checkout completed successfully! Thank you for your purchase.\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Checkout failed. Please try again.\"}");
        }
    }
    
    // Helper method to escape JSON strings
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
