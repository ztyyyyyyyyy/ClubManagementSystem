package com.campus.servlet;

import com.campus.dao.*;
import com.campus.model.*;
import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {
    private EventDAO eventDAO;
    private ClubDAO clubDAO;
    private MerchandiseDAO merchandiseDAO;
    private CartDAO cartDAO;
    private RegisterEventDAO registerEventDAO;
    private SaleDAO saleDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            eventDAO = new EventDAO();
            clubDAO = new ClubDAO();
            merchandiseDAO = new MerchandiseDAO();
            cartDAO = new CartDAO();
            registerEventDAO = new RegisterEventDAO();
            saleDAO = new SaleDAO();
            System.out.println("UserServlet initialized successfully");
        } catch (Exception e) {
            System.err.println("Error initializing UserServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Failed to initialize UserServlet", e);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            System.out.println("UserServlet GET - Action: " + action);
            
            switch (action != null ? action : "") {
                case "registerEvent":
                    handleRegisterEvent(request, response, userId);
                    break;
                case "unregisterEvent":
                    handleUnregisterEvent(request, response, userId);
                    break;
                case "removeFromCart":
                    handleRemoveFromCart(request, response, userId);
                    break;
                case "clearCart":
                    handleClearCart(request, response, userId);
                    break;
                default:
                    response.sendRedirect("user.jsp");
            }
        } catch (Exception e) {
            System.err.println("Error in UserServlet GET: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?error=Server error occurred");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            System.out.println("UserServlet POST - Action: " + action);
            
            switch (action != null ? action : "") {
                case "addToCart":
                    handleAddToCart(request, response, userId);
                    break;
                case "updateCartQuantity":
                    handleUpdateCartQuantity(request, response, userId);
                    break;
                case "checkout":
                    handleCheckout(request, response, userId);
                    break;
                default:
                    response.sendRedirect("user.jsp");
            }
        } catch (Exception e) {
            System.err.println("Error in UserServlet POST: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?error=Server error occurred");
        }
    }
    
    private void handleRegisterEvent(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            int eventId = Integer.parseInt(request.getParameter("eventId"));
            
            if (registerEventDAO.isUserRegistered(userId, eventId)) {
                response.sendRedirect("user.jsp?section=events&error=Already registered for this event");
                return;
            }
            
            RegisterEvent registration = new RegisterEvent(userId, eventId);
            
            if (registerEventDAO.registerForEvent(registration)) {
                response.sendRedirect("user.jsp?section=events&success=Successfully registered for event");
            } else {
                response.sendRedirect("user.jsp?section=events&error=Failed to register for event");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("user.jsp?section=events&error=Invalid event ID");
        } catch (Exception e) {
            System.err.println("Error registering for event: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?section=events&error=Server error occurred");
        }
    }
    
    private void handleUnregisterEvent(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            int eventId = Integer.parseInt(request.getParameter("eventId"));
            String returnSection = request.getParameter("returnSection");
            if (returnSection == null) returnSection = "events";
            
            if (registerEventDAO.unregisterFromEvent(userId, eventId)) {
                response.sendRedirect("user.jsp?section=" + returnSection + "&success=Successfully unregistered from event");
            } else {
                response.sendRedirect("user.jsp?section=" + returnSection + "&error=Failed to unregister from event");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("user.jsp?section=events&error=Invalid event ID");
        } catch (Exception e) {
            System.err.println("Error unregistering from event: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?section=events&error=Server error occurred");
        }
    }
    
    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            int merchandiseId = Integer.parseInt(request.getParameter("merchandiseId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            
            System.out.println("Adding to cart - User: " + userId + ", Merchandise: " + merchandiseId + ", Quantity: " + quantity);
            
            Merchandise merchandise = merchandiseDAO.getMerchandiseById(merchandiseId);
            if (merchandise == null) {
                response.sendRedirect("user.jsp?section=merchandise&error=Merchandise not found");
                return;
            }
            
            if (merchandise.getStock() < quantity) {
                response.sendRedirect("user.jsp?section=merchandise&error=Insufficient stock available");
                return;
            }
            
            BigDecimal totalPrice = merchandise.getPrice().multiply(new BigDecimal(quantity));
            Cart cart = new Cart(userId, merchandiseId, quantity, totalPrice);
            
            if (cartDAO.addToCart(cart)) {
                response.sendRedirect("user.jsp?section=merchandise&success=Item added to cart successfully");
            } else {
                response.sendRedirect("user.jsp?section=merchandise&error=Failed to add item to cart");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("user.jsp?section=merchandise&error=Invalid parameters");
        } catch (Exception e) {
            System.err.println("Error adding to cart: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?section=merchandise&error=Server error occurred");
        }
    }
    
    private void handleUpdateCartQuantity(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            int cartId = Integer.parseInt(request.getParameter("cartId"));
            int newQuantity = Integer.parseInt(request.getParameter("quantity"));
            int merchandiseId = Integer.parseInt(request.getParameter("merchandiseId"));
            
            if (newQuantity < 1) {
                response.sendRedirect("user.jsp?section=cart&error=Quantity must be at least 1");
                return;
            }
            
            Cart existingCart = cartDAO.getCartItem(userId, merchandiseId);
            if (existingCart == null || existingCart.getCartId() != cartId) {
                response.sendRedirect("user.jsp?section=cart&error=Cart item not found");
                return;
            }
            
            Merchandise merchandise = merchandiseDAO.getMerchandiseById(merchandiseId);
            if (merchandise == null) {
                response.sendRedirect("user.jsp?section=cart&error=Merchandise not found");
                return;
            }
            
            if (merchandise.getStock() < newQuantity) {
                response.sendRedirect("user.jsp?section=cart&error=Insufficient stock available");
                return;
            }
            
            BigDecimal newTotalPrice = merchandise.getPrice().multiply(new BigDecimal(newQuantity));
            
            if (cartDAO.updateCartItem(cartId, newQuantity, newTotalPrice)) {
                response.sendRedirect("user.jsp?section=cart&success=Cart updated successfully");
            } else {
                response.sendRedirect("user.jsp?section=cart&error=Failed to update cart");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("user.jsp?section=cart&error=Invalid parameters");
        } catch (Exception e) {
            System.err.println("Error updating cart: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?section=cart&error=Server error occurred");
        }
    }
    
    private void handleRemoveFromCart(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            int cartId = Integer.parseInt(request.getParameter("cartId"));
            
            if (cartDAO.removeFromCart(cartId)) {
                response.sendRedirect("user.jsp?section=cart&success=Item removed from cart");
            } else {
                response.sendRedirect("user.jsp?section=cart&error=Failed to remove item from cart");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("user.jsp?section=cart&error=Invalid cart ID");
        } catch (Exception e) {
            System.err.println("Error removing from cart: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?section=cart&error=Server error occurred");
        }
    }
    
    private void handleClearCart(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            if (cartDAO.clearCart(userId)) {
                response.sendRedirect("user.jsp?section=cart&success=Cart cleared successfully");
            } else {
                response.sendRedirect("user.jsp?section=cart&error=Failed to clear cart");
            }
        } catch (Exception e) {
            System.err.println("Error clearing cart: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?section=cart&error=Server error occurred");
        }
    }
    
    private void handleCheckout(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            String paymentMethod = request.getParameter("paymentMethod");
            java.util.List<Cart> cartItems = cartDAO.getCartByUserId(userId);
            
            if (cartItems.isEmpty()) {
                response.sendRedirect("user.jsp?section=cart&error=Cart is empty");
                return;
            }
            
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                response.sendRedirect("user.jsp?section=cart&error=Please select a payment method");
                return;
            }
            
            System.out.println("Processing checkout for user " + userId + " with payment method: " + paymentMethod);
            
            // Check stock availability for all items
            for (Cart cartItem : cartItems) {
                Merchandise merchandise = merchandiseDAO.getMerchandiseById(cartItem.getMerchandiseId());
                if (merchandise == null || merchandise.getStock() < cartItem.getQuantity()) {
                    response.sendRedirect("user.jsp?section=cart&error=Insufficient stock for " + cartItem.getMerchandiseName());
                    return;
                }
            }
            
            // Update stock levels and record sales
            boolean allUpdated = true;
            BigDecimal totalOrderAmount = BigDecimal.ZERO;
            
            for (Cart cartItem : cartItems) {
                Merchandise merchandise = merchandiseDAO.getMerchandiseById(cartItem.getMerchandiseId());
                int newStock = merchandise.getStock() - cartItem.getQuantity();
                
                if (!merchandiseDAO.updateStock(cartItem.getMerchandiseId(), newStock)) {
                    allUpdated = false;
                    break;
                }
                
                // Record individual sale
                Sale sale = new Sale(userId, cartItem.getMerchandiseId(), cartItem.getQuantity(), 
                                   merchandise.getPrice(), cartItem.getTotalPrice(), paymentMethod);
                
                if (!saleDAO.recordSale(sale)) {
                    System.err.println("Failed to record sale for item: " + cartItem.getMerchandiseName());
                }
                
                totalOrderAmount = totalOrderAmount.add(cartItem.getTotalPrice());
            }
            
            if (allUpdated) {
                cartDAO.clearCart(userId);
                
                // Get user info for success message
                HttpSession session = request.getSession();
                User user = (User) session.getAttribute("user");
                String userName = user != null ? user.getUserName() : "Customer";
                
                String successMessage = "Checkout completed successfully! " +
                                      "Order total: RM" + totalOrderAmount + " " +
                                      "Payment method: " + formatPaymentMethod(paymentMethod) + ". " +
                                      "Thank you for your purchase, " + userName + "!";
                
                System.out.println("Checkout successful - User: " + userName + ", Total: RM" + totalOrderAmount + ", Payment: " + paymentMethod);
                
                response.sendRedirect("user.jsp?section=cart&success=" + java.net.URLEncoder.encode(successMessage, "UTF-8"));
            } else {
                response.sendRedirect("user.jsp?section=cart&error=Checkout failed. Please try again.");
            }
        } catch (Exception e) {
            System.err.println("Error during checkout: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("user.jsp?section=cart&error=Server error occurred during checkout");
        }
    }
    
    private String formatPaymentMethod(String paymentMethod) {
        switch (paymentMethod) {
            case "cash": return "Cash Payment";
            case "online_banking": return "Online Banking";
            case "e_wallet": return "E-Wallet";
            case "credit_card": return "Credit/Debit Card";
            default: return paymentMethod;
        }
    }
}
