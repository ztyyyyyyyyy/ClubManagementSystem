<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.model.User" %>
<%@ page import="com.campus.dao.*" %>
<%@ page import="com.campus.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    String userRole = (String) session.getAttribute("userRole");
    
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Initialize DAOs
    EventDAO eventDAO = new EventDAO();
    ClubDAO clubDAO = new ClubDAO();
    MerchandiseDAO merchandiseDAO = new MerchandiseDAO();
    CartDAO cartDAO = new CartDAO();
    RegisterEventDAO registerEventDAO = new RegisterEventDAO();
    
    // Get current section to display
    String section = request.getParameter("section");
    if (section == null) section = "events";
    
    // Get all data
    List<Event> events = eventDAO.getAllEvents();
    List<Club> clubs = clubDAO.getAllClubs();
    List<Merchandise> merchandise = merchandiseDAO.getAvailableMerchandise();
    List<Cart> cartItems = cartDAO.getCartByUserId(user.getUserId());
    List<RegisterEvent> registeredEvents = registerEventDAO.getRegisteredEventsByUserId(user.getUserId());
    List<Integer> registeredEventIds = registerEventDAO.getRegisteredEventIds(user.getUserId());
    
    // Calculate cart totals
    BigDecimal cartTotal = cartDAO.getCartTotal(user.getUserId());
    int cartItemCount = cartDAO.getCartItemCount(user.getUserId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campus Management System - User Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #e0efff;
            min-height: 100vh;
            margin: 0;
            display: flex;
            flex-direction: column;
        }
        .admin-header-bg {
            background: linear-gradient(to right, #7f73f7, #6a5acd);
        }
        
        .nav-item {
            position: relative;
            padding: 0.75rem 1.25rem;
            border-radius: 9999px; /* Pill shape */
            transition: all 0.3s ease;
            color: #ffffff;
            font-weight: 600;
            margin: 0 0.25rem;
            text-decoration: none;
        }
        .nav-item::after {
            content: '';
            position: absolute;
            left: 50%;
            bottom: 0;
            width: 0;
            height: 3px;
            background-color: #fde68a; /* Yellow underline */
            transition: width 0.3s ease, left 0.3s ease;
            transform: translateX(-50%);
        }
        .nav-item:hover {
            background-color: rgba(255, 255, 255, 0.2);
        }
        .nav-item.active {
            background-color: rgba(255, 255, 255, 0.35);
        }
        .nav-item.active::after {
            width: calc(100% - 1rem);
        }

        .cart-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background-color: #ef4444; 
            color: white;
            border-radius: 50%;
            width: 24px; 
            height: 24px;
            font-size: 14px; 
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }

        .modal {
            display: none; 
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.6);
            justify-content: center;
            align-items: center;
            padding: 1rem;
        }
        .modal-content {
            background-color: white;
            padding: 2.5rem; 
            border-radius: 1.5rem;
            width: 90%;
            max-width: 600px;
            position: relative;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15); 
        }
        .close {
            color: #6b7280; 
            position: absolute;
            right: 1.5rem;
            top: 1rem; 
            font-size: 2.5rem;
            font-weight: 300; 
            cursor: pointer;
            transition: color 0.2s ease-in-out;
        }
        .close:hover {
            color: #1f2937; 
        }

        .section-card {
            background-color: #ffffff;
            border-radius: 1rem; 
            padding: 1.5rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); 
            display: flex; 
            flex-direction: column;
            flex: 1;
            margin-bottom: 1.5rem; 
        }

        .table th, .table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #e5e7eb; 
        }
        .table thead th {
            background-color: #f9fafb; 
            font-weight: 600;
            color: #4b5563;
            text-transform: uppercase;
            font-size: 0.875rem; 
        }
        .table tbody tr:hover {
            background-color: #f3f4f6; 
        }

        .action-btn-primary { 
            background-color: #6366f1; 
            color: white;
            padding: 0.625rem 1.5rem; 
            border-radius: 9999px; 
            font-size: 0.875rem; 
            font-weight: 600; 
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center; 
            gap: 0.5rem;
        }
        .action-btn-primary:hover {
            background-color: #4f46e5; 
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
        }
        .action-btn-danger { 
            background-color: #ef4444; /* Red */
            color: white;
            padding: 0.625rem 1.5rem; 
            border-radius: 9999px; 
            font-size: 0.875rem;
            font-weight: 600; 
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center; 
            gap: 0.5rem;
        }
        .action-btn-danger:hover {
            background-color: #dc2626; 
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
        }

        .btn-checkout-confirm {
            background-color: #22c55e; 
            color: white;
            padding: 0.75rem 1.75rem; 
            border-radius: 0.75rem;
            font-weight: 700; /* Bolder text */
            transition: background-color 0.2s ease-in-out, transform 0.1s ease-in-out;
        }
        .btn-checkout-confirm:hover {
            background-color: #16a34a;
            transform: translateY(-2px);
        }
        .btn-checkout-cancel {
            background-color: #6b7280; 
            color: white;
            padding: 0.75rem 1.75rem; 
            border-radius: 0.75rem; 
            font-weight: 700; 
            transition: background-color 0.2s ease-in-out, transform 0.1s ease-in-out;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .btn-checkout-cancel:hover {
            background-color: #4b5563;
            transform: translateY(-2px);
        }

        input[type="number"] {
            border: 1px solid #d1d5db; 
            padding: 0.75rem 1rem; 
            font-size: 1rem;
            border-radius: 0.75rem; 
        }
        
        .success-message {
            background-color: #d1fae5;
            border: 1px solid #a7f3d0;
            color: #059669;
            padding: 1.5rem;
            border-radius: 0.75rem;
            margin-bottom: 1.5rem;
            text-align: center;
            font-weight: 500;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .error-message {
            background-color: #fee2e2;
            border: 1px solid #fca5a5;
            color: #dc2626;
            padding: 1.5rem;
            border-radius: 0.75rem;
            margin-bottom: 1.5rem;
            text-align: center;
            font-weight: 500;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body class="flex flex-col min-h-screen">
    <header class="admin-header-bg text-white px-8 py-4 flex justify-between items-center shadow-lg sticky top-0 z-10">
        <h1 class="text-3xl font-extrabold tracking-wide">Campus Connect Hub</h1>
        <div class="flex items-center space-x-6">
            <span class="text-lg font-medium">Welcome, <span class="text-yellow-300"><%= user.getUserName() %>!</span></span>
            <div class="relative">
                <a href="user.jsp?section=cart" class="bg-yellow-300 text-purple-800 hover:bg-yellow-400 px-5 py-2 rounded-full text-lg font-semibold transition-all duration-300 ease-in-out shadow-md relative">
                    Cart
                    <% if (cartItemCount > 0) { %>
                        <span class="cart-badge"><%= cartItemCount %></span>
                    <% } %>
                </a>
            </div>
            <a href="LogoutServlet" class="bg-yellow-300 text-purple-800 hover:bg-yellow-400 px-5 py-2 rounded-full text-lg font-semibold transition-all duration-300 ease-in-out shadow-md">
                Logout
            </a>
        </div>
    </header>

    <!-- Navigation -->
    <nav class="admin-header-bg px-8 py-3 shadow-md">
        <div class="flex justify-center">
            <a href="user.jsp?section=events" class="nav-item <%= "events".equals(section) ? "active" : "" %>">Events</a>
            <a href="user.jsp?section=clubs" class="nav-item <%= "clubs".equals(section) ? "active" : "" %>">Clubs</a>
            <a href="user.jsp?section=merchandise" class="nav-item <%= "merchandise".equals(section) ? "active" : "" %>">Merchandise</a>
            <a href="user.jsp?section=cart" class="nav-item <%= "cart".equals(section) ? "active" : "" %>">Cart</a>
            <a href="user.jsp?section=my-events" class="nav-item <%= "my-events".equals(section) ? "active" : "" %>">My Events</a>
        </div>
    </nav>

    <!-- Checkout Modal -->
    <div id="checkoutModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeCheckoutModal()">&times;</span>
            <h2 class="text-3xl font-bold text-blue-700 mb-6 text-center">Checkout Confirmation</h2>
            
            <div class="mb-8 p-4 bg-blue-50 rounded-lg">
                <h3 class="text-xl font-semibold mb-3 text-blue-800">Customer Information</h3>
                <p class="text-lg text-gray-700 mb-1"><strong>Name:</strong> <%= user.getUserName() %></p>
                <p class="text-lg text-gray-700"><strong>Email:</strong> <%= user.getEmail() %></p>
            </div>
            
            <div class="mb-8 p-4 bg-green-50 rounded-lg">
                <h3 class="text-xl font-semibold mb-3 text-green-800">Order Summary</h3>
                <div id="checkout-items" class="space-y-3 mb-4 border-b pb-4">
                </div>
                <div class="pt-4 text-right">
                    <p class="text-2xl font-extrabold text-green-700">Total: RM<%= cartTotal.setScale(2, BigDecimal.ROUND_HALF_UP) %></p>
                </div>
            </div>
            
            <form method="post" action="UserServlet" id="checkoutForm">
                <input type="hidden" name="action" value="checkout">
                <input type="hidden" name="paymentMethod" id="selectedPaymentMethod">
                
                <div class="mb-8">
                    <h3 class="text-xl font-semibold mb-4 text-indigo-700">Select Payment Method</h3>
                    <div class="space-y-4">
                        <label class="flex items-center space-x-4 p-4 border border-indigo-200 rounded-xl cursor-pointer hover:bg-indigo-50 transition duration-200 ease-in-out">
                            <input type="radio" name="payment" value="cash" class="form-radio text-indigo-600 h-6 w-6" required>
                            <div class="flex items-center space-x-3">
                                <span class="text-3xl">💵</span>
                                <div>
                                    <div class="font-bold text-lg text-gray-800">Cash Payment</div>
                                    <div class="text-sm text-gray-600">Pay with cash at pickup</div>
                                </div>
                            </div>
                        </label>
                        
                        <label class="flex items-center space-x-4 p-4 border border-indigo-200 rounded-xl cursor-pointer hover:bg-indigo-50 transition duration-200 ease-in-out">
                            <input type="radio" name="payment" value="online_banking" class="form-radio text-indigo-600 h-6 w-6" required>
                            <div class="flex items-center space-x-3">
                                <span class="text-3xl">🏦</span>
                                <div>
                                    <div class="font-bold text-lg text-gray-800">Online Banking</div>
                                    <div class="text-sm text-gray-600">Pay via online banking transfer</div>
                                </div>
                            </div>
                        </label>
                        
                        <label class="flex items-center space-x-4 p-4 border border-indigo-200 rounded-xl cursor-pointer hover:bg-indigo-50 transition duration-200 ease-in-out">
                            <input type="radio" name="payment" value="e_wallet" class="form-radio text-indigo-600 h-6 w-6" required>
                            <div class="flex items-center space-x-3">
                                <span class="text-3xl">📱</span>
                                <div>
                                    <div class="font-bold text-lg text-gray-800">E-Wallet</div>
                                    <div class="text-sm text-gray-600">Pay with GrabPay, Touch 'n Go, etc.</div>
                                </div>
                            </div>
                        </label>
                        
                        <label class="flex items-center space-x-4 p-4 border border-indigo-200 rounded-xl cursor-pointer hover:bg-indigo-50 transition duration-200 ease-in-out">
                            <input type="radio" name="payment" value="credit_card" class="form-radio text-indigo-600 h-6 w-6" required>
                            <div class="flex items-center space-x-3">
                                <span class="text-3xl">💳</span>
                                <div>
                                    <div class="font-bold text-lg text-gray-800">Credit/Debit Card</div>
                                    <div class="text-sm text-gray-600">Pay with Visa, Mastercard, etc.</div>
                                </div>
                            </div>
                        </label>
                    </div>
                </div>
                
                <div class="flex justify-end space-x-4">
                    <button type="button" onclick="closeCheckoutModal()" class="btn-checkout-cancel">
                        Cancel
                    </button>
                    <button type="submit" class="btn-checkout-confirm">
                        Complete Purchase
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Main Content -->
    <main class="flex-grow max-w-7xl mx-auto p-6 w-full flex flex-col items-stretch">
        <!-- Events Section -->
        <% if ("events".equals(section)) { %>
        <section class="section-card">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">Available Events</h2>
            
            <!-- Display success/error messages -->
            <% if (request.getParameter("success") != null) { %>
                <div class="success-message">
                    <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="error-message">
                    <%= request.getParameter("error") %>
                </div>
            <% } %>
            
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <table class="w-full table">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-4 py-3 text-left">Title</th>
                            <th class="px-4 py-3 text-left">Date</th>
                            <th class="px-4 py-3 text-left">Location</th>
                            <th class="px-4 py-3 text-left">Description</th>
                            <th class="px-4 py-3 text-left">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (events.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="px-4 py-8 text-center text-gray-500 text-lg">
                                    No events available at the moment.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Event event : events) { %>
                                <% boolean isRegistered = registeredEventIds.contains(event.getEventId()); %>
                                <tr class="hover:bg-gray-50 transition-colors duration-200">
                                    <td class="px-4 py-3 text-gray-700 font-medium"><%= event.getTitle() %></td>
                                    <td class="px-4 py-3 text-gray-700"><%= event.getEventDate() %></td>
                                    <td class="px-4 py-3 text-gray-700"><%= event.getLocation() %></td>
                                    <td class="px-4 py-3 text-gray-700 max-w-xs overflow-hidden text-ellipsis whitespace-nowrap">
                                        <%= event.getDescription() != null ? event.getDescription() : "No description available." %>
                                    </td>
                                    <td class="px-4 py-3 flex items-center space-x-2">
                                        <% if (isRegistered) { %>
                                            <a href="UserServlet?action=unregisterEvent&eventId=<%= event.getEventId() %>&section=events" 
                                               onclick="return confirm('Are you sure you want to unregister from this event?')"
                                               class="action-btn-danger">Unregister</a>
                                        <% } else { %>
                                            <a href="UserServlet?action=registerEvent&eventId=<%= event.getEventId() %>&section=events" 
                                               onclick="return confirm('Register for this event?')"
                                               class="action-btn-primary">Register</a>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
        <% } %>

        <!-- Clubs Section -->
        <% if ("clubs".equals(section)) { %>
        <section class="section-card">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">Campus Clubs</h2>
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <table class="w-full table">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-4 py-3 text-left">Club Name</th>
                            <th class="px-4 py-3 text-left">Description</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (clubs.isEmpty()) { %>
                            <tr>
                                <td colspan="2" class="px-4 py-8 text-center text-gray-500 text-lg">
                                    No clubs available at the moment.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Club club : clubs) { %>
                                <tr class="hover:bg-gray-50 transition-colors duration-200">
                                    <td class="px-4 py-3 text-gray-700 font-medium"><%= club.getClubName() %></td>
                                    <td class="px-4 py-3 text-gray-700 max-w-lg overflow-hidden text-ellipsis whitespace-nowrap">
                                        <%= club.getDescription() != null ? club.getDescription() : "No description available." %>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
        <% } %>

        <!-- Merchandise Section -->
        <% if ("merchandise".equals(section)) { %>
        <section class="section-card">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">Merchandise Store</h2>
            
            <!-- Display success/error messages -->
            <% if (request.getParameter("success") != null) { %>
                <div class="success-message">
                    <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="error-message">
                    <%= request.getParameter("error") %>
                </div>
            <% } %>
            
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <table class="w-full table">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-4 py-3 text-left">Image</th>
                            <th class="px-4 py-3 text-left">Name</th>
                            <th class="px-4 py-3 text-left">Price</th>
                            <th class="px-4 py-3 text-left">Stock</th>
                            <th class="px-4 py-3 text-left">Quantity</th>
                            <th class="px-4 py-3" style="text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (merchandise.isEmpty()) { %>
                            <tr>
                                <td colspan="6" class="px-4 py-8 text-center text-gray-500 text-lg">
                                    No merchandise available at the moment.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Merchandise item : merchandise) { %>
                                <tr class="hover:bg-gray-50 transition-colors duration-200">
                                    <td class="px-4 py-3">
                                        <div class="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                                            <% if (item.getImagePath() != null && !item.getImagePath().isEmpty()) { %>
                                                <img src="<%= item.getImagePath() %>" alt="<%= item.getMerchandiseName() %>" class="w-full h-full object-cover rounded-full">
                                            <% } else { %>
                                                <span class="text-gray-500 text-xs">No Image</span>
                                            <% } %>
                                        </div>
                                     </td>
                                    <td class="px-4 py-3 text-gray-700 font-medium"><%= item.getMerchandiseName() %></td>
                                    <td class="px-4 py-3 text-gray-700">RM<%= item.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                    <td class="px-4 py-3 text-gray-700"><%= item.getStock() %></td>
                                    <td class="px-4 py-3 text-center"> <%-- Quantity input in its own centered td --%>
                                        <input type="number" name="quantity_<%= item.getMerchandiseId() %>" id="quantity_<%= item.getMerchandiseId() %>" min="1" max="<%= item.getStock() %>" value="1" 
                                               class="w-20 border rounded-lg px-3 py-2 text-center text-base">
                                    </td>
                                    <td class="px-4 py-3 flex items-center justify-center"> <%-- Actions button in its own centered td --%>
                                        <form method="post" action="UserServlet" id="addToCartForm_<%= item.getMerchandiseId() %>">
                                            <input type="hidden" name="action" value="addToCart">
                                            <input type="hidden" name="merchandiseId" value="<%= item.getMerchandiseId() %>">
                                            <input type="hidden" name="quantity" id="hiddenQuantity_<%= item.getMerchandiseId() %>" value="1"> <%-- Hidden quantity input --%>
                                            <button type="submit" class="action-btn-primary" 
                                                    onclick="event.preventDefault(); updateHiddenQuantityAndSubmit(<%= item.getMerchandiseId() %>);">
                                                Add to Cart
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
        <% } %>

        <!-- Cart Section -->
        <% if ("cart".equals(section)) { %>
        <section class="section-card">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">Shopping Cart</h2>
            
            <!-- Display success/error messages -->
            <% if (request.getParameter("success") != null) { %>
                <div class="success-message">
                    <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="error-message">
                    <%= request.getParameter("error") %>
                </div>
            <% } %>
            
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <% if (cartItems.isEmpty()) { %>
                    <p class="text-gray-500 text-center py-8 text-lg">Your cart is empty</p>
                <% } else { %>
                    <table class="w-full table">
                        <thead class="bg-gray-100">
                            <tr>
                                <th class="px-4 py-3 text-left">Image</th>
                                <th class="px-4 py-3 text-left">Item Name</th>
                                <th class="px-4 py-3 text-left">Unit Price</th>
                                <th class="px-4 py-3 text-left">Quantity</th>
                                <th class="px-4 py-3 text-left">Total Price</th>
                                <th class="px-4 py-3 text-left">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <% for (Cart item : cartItems) { %>
                                <tr class="hover:bg-gray-50 transition-colors duration-200">
                                    <td class="px-4 py-3">
                                        <div class="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                                            <% if (item.getImagePath() != null && !item.getImagePath().isEmpty()) { %>
                                                <img src="<%= item.getImagePath() %>" alt="<%= item.getMerchandiseName() %>" class="w-full h-full object-cover rounded-full">
                                            <% } else { %>
                                                <span class="text-gray-500 text-xs">No Image</span>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-gray-700 font-medium"><%= item.getMerchandiseName() %></td>
                                    <td class="px-4 py-3 text-gray-700">RM<%= item.getUnitPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                    <td class="px-4 py-3">
                                        <form method="post" action="UserServlet" class="inline-flex items-center">
                                            <input type="hidden" name="action" value="updateCartQuantity">
                                            <input type="hidden" name="cartId" value="<%= item.getCartId() %>">
                                            <input type="hidden" name="merchandiseId" value="<%= item.getMerchandiseId() %>">
                                            <input type="number" name="quantity" min="1" value="<%= item.getQuantity() %>" 
                                                   class="w-20 border rounded-lg px-3 py-2 text-center text-base"
                                                   onchange="this.form.submit()">
                                        </form>
                                    </td>
                                    <td class="px-4 py-3 text-gray-700 font-semibold">RM<%= item.getTotalPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                    <td class="px-4 py-3">
                                        <a href="UserServlet?action=removeFromCart&cartId=<%= item.getCartId() %>&section=cart" 
                                           onclick="return confirm('Are you sure you want to remove this item from your cart?')"
                                           class="action-btn-danger">Remove</a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Cart Total and Actions -->
                    <div class="border-t pt-4 pb-4 mt-6 flex justify-between items-center px-4">
                        <span class="text-2xl font-extrabold text-blue-800">Grand Total: RM<%= cartTotal.setScale(2, BigDecimal.ROUND_HALF_UP) %></span>
                        <div class="flex space-x-4">
                            <button onclick="openCheckoutModal()" class="btn-checkout-confirm">
                                Proceed to Checkout
                            </button>
                            <a href="UserServlet?action=clearCart&section=cart" 
                               onclick="return confirm('Are you sure you want to clear your entire cart? This action cannot be undone.')"
                               class="btn-checkout-cancel">
                                Clear Cart
                            </a>
                        </div>
                    </div>
                <% } %>
                
            </div>
        </section>
        <% } %>

        <!-- My Events Section -->
        <% if ("my-events".equals(section)) { %>
        <section class="section-card">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">My Registered Events</h2>
            
            <!-- Display success/error messages -->
            <% if (request.getParameter("success") != null) { %>
                <div class="success-message">
                    <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="error-message">
                    <%= request.getParameter("error") %>
                </div>
            <% } %>
            
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <table class="w-full table">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-4 py-3 text-left">Title</th>
                            <th class="px-4 py-3 text-left">Date</th>
                            <th class="px-4 py-3 text-left">Location</th>
                            <th class="px-4 py-3 text-left">Description</th>
                            <th class="px-4 py-3 text-left">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (registeredEvents.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="px-4 py-8 text-center text-gray-500 text-lg">
                                    You have not registered for any events yet.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (RegisterEvent regEvent : registeredEvents) { %>
                                <tr class="hover:bg-gray-50 transition-colors duration-200">
                                    <td class="px-4 py-3 text-gray-700 font-medium"><%= regEvent.getEventTitle() %></td>
                                    <td class="px-4 py-3 text-gray-700"><%= regEvent.getEventDate() %></td>
                                    <td class="px-4 py-3 text-gray-700"><%= regEvent.getLocation() %></td>
                                    <td class="px-4 py-3 text-gray-700 max-w-xs overflow-hidden text-ellipsis whitespace-nowrap">
                                        <%= regEvent.getDescription() != null ? regEvent.getDescription() : "No description available." %>
                                    </td>
                                    <td class="px-4 py-3">
                                        <a href="UserServlet?action=unregisterEvent&eventId=<%= regEvent.getEventId() %>&section=my-events" 
                                           onclick="return confirm('Are you sure you want to unregister from this event?')"
                                           class="action-btn-danger">Unregister</a>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
        <% } %>
    </main>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const successMessage = document.querySelector('.success-message');
            const errorMessage = document.querySelector('.error-message');
        
            if (successMessage) {
                setTimeout(() => {
                    successMessage.style.transition = 'opacity 1s ease-out';
                    successMessage.style.opacity = '0';
                    setTimeout(() => successMessage.remove(), 1000);
                }, 5000); // Message disappears after 5 seconds
            }
            if (errorMessage) {
                setTimeout(() => {
                    errorMessage.style.transition = 'opacity 1s ease-out';
                    errorMessage.style.opacity = '0';
                    setTimeout(() => errorMessage.remove(), 1000);
                }, 7000); // Error message disappears after 7 seconds
            }
        });

        // Cart items data for checkout modal
        const cartItems = [
            <% for (int i = 0; i < cartItems.size(); i++) { 
                Cart item = cartItems.get(i);
                if (i > 0) out.print(",");
            %>
            {
                name: "<%= item.getMerchandiseName() %>",
                quantity: <%= item.getQuantity() %>,
                unitPrice: <%= item.getUnitPrice() %>,
                totalPrice: <%= item.getTotalPrice() %>
            }
            <% } %>
        ];

        function openCheckoutModal() {
            const checkoutItemsDiv = document.getElementById('checkout-items');
            checkoutItemsDiv.innerHTML = '';
            
            cartItems.forEach(item => {
                const itemDiv = document.createElement('div');
                itemDiv.className = 'flex justify-between items-center text-lg text-gray-700'; 
                itemDiv.innerHTML = 
                    '<span class="font-medium">' + item.name + ' (x' + item.quantity + ')</span>' + 
                    '<span class="font-semibold">RM' + item.totalPrice.toFixed(2) + '</span>'; 
                checkoutItemsDiv.appendChild(itemDiv);
            });
            
            document.getElementById('checkoutModal').style.display = 'flex'; 
        }

        function closeCheckoutModal() {
            document.getElementById('checkoutModal').style.display = 'none';
        }

        // Handle form submission
        document.getElementById('checkoutForm').addEventListener('submit', function(e) {
            const selectedPayment = document.querySelector('input[name="payment"]:checked');
            if (selectedPayment) {
                document.getElementById('selectedPaymentMethod').value = selectedPayment.value;
            } else {
                e.preventDefault(); 
                showCustomAlert('Please select a payment method to complete your purchase.');
            }
        });

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('checkoutModal');
            if (event.target == modal) {
                closeCheckoutModal();
            }
        }

        // --- Custom Alert/Message Box (Replaces alert()) ---
        function showCustomAlert(message) {
            const alertModal = document.createElement('div');
            alertModal.id = 'customAlertModal';
            alertModal.className = 'modal'; 
            alertModal.innerHTML = `
                <div class="modal-content max-w-sm text-center">
                    <span class="close" onclick="document.getElementById('customAlertModal').style.display='none'">&times;</span>
                    <p class="text-xl font-semibold text-gray-800 mb-6">${message}</p>
                    <button onclick="document.getElementById('customAlertModal').style.display='none'" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-semibold">
                        OK
                    </button>
                </div>
            `;
            document.body.appendChild(alertModal);
            alertModal.style.display = 'flex';
        }
        
        //Merchandise Quantity submission
        function updateHiddenQuantityAndSubmit(merchandiseId) {
            const quantityInput = document.getElementById('quantity_' + merchandiseId); // Get the visible quantity input
            const hiddenQuantityInput = document.getElementById('hiddenQuantity_' + merchandiseId); // Get the hidden quantity input in the form
            
            if (quantityInput && hiddenQuantityInput) {
                hiddenQuantityInput.value = quantityInput.value; // Update hidden input with visible input's value
            }
            // Submit the form
            document.getElementById('addToCartForm_' + merchandiseId).submit();
        }
    </script>
</body>
</html>
