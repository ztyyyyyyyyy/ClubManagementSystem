<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.model.User" %>
<%@ page import="com.campus.dao.*" %>
<%@ page import="com.campus.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    String userRole = (String) session.getAttribute("userRole");
    
    if (user == null || !"admin".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Initialize DAOs
    EventDAO eventDAO = new EventDAO();
    ClubDAO clubDAO = new ClubDAO();
    MerchandiseDAO merchandiseDAO = new MerchandiseDAO();
    SaleDAO saleDAO = new SaleDAO();
    
    // Get current section to display
    String section = request.getParameter("section");
    if (section == null) section = "dashboard";
    
    // Get all data
    List<Event> events = eventDAO.getAllEvents();
    List<Club> clubs = clubDAO.getAllClubs();
    List<Merchandise> merchandise = merchandiseDAO.getAllMerchandise();
    List<Sale> sales = saleDAO.getAllSales();
    
    // Get sales statistics
    BigDecimal totalRevenue = saleDAO.getTotalRevenue();
    int totalItemsSold = saleDAO.getTotalItemsSold();
    int totalTransactions = saleDAO.getTotalTransactions();
    List<Sale> topSellingItems = saleDAO.getTopSellingItems(5);
    List<Sale> paymentMethodStats = saleDAO.getSalesByPaymentMethod();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Campus Management System</title>
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
            border-radius: 9999px; 
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
            background-color: #fde68a;
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

        .section-card {
            background-color: #ffffff; 
            border-radius: 1rem;
            padding: 1.5rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); 
            display: none;
            flex-direction: column;
            flex: 1;
        }
        .section-card.active {
            display: flex;
        }

        .dashboard-metric-card {
            background-color: #ffffff; 
            padding: 1.5rem;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            text-align: center;
        }
        .dashboard-metric-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.1);
        }
        .dashboard-breakdown-card {
            background-color: #ffffff;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            padding: 1.5rem;
        }
        .text-blue-main { 
            color: #5a50e0; 
        } 
        .text-green-main { 
            color: #10b981; 
        }
        .text-orange-main { 
            color: #f59e0b; 
        } 
        .text-purple-main { 
            color: #8b5cf6; 
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
 
        .action-btn-edit {
            background-color: #6366f1; 
            color: white;
            padding: 0.375rem 0.75rem; 
            border-radius: 9999px; 
            font-size: 0.875rem;
            font-weight: 500; 
            transition: background-color 0.2s ease, transform 0.1s ease;
        }
        .action-btn-edit:hover {
            background-color: #4f46e5; 
            transform: translateY(-1px);
        }
        .action-btn-delete {
            background-color: #ef4444; 
            color: white;
            padding: 0.375rem 0.75rem; 
            border-radius: 9999px; 
            font-size: 0.875rem;
            font-weight: 500; 
            transition: background-color 0.2s ease, transform 0.1s ease;
        }
        .action-btn-delete:hover {
            background-color: #dc2626; 
            transform: translateY(-1px);
        }

        .add-item-btn {
            background-color: #7f73f7; 
            color: white;
            padding: 0.625rem 1.5rem; 
            border-radius: 9999px; 
            font-weight: 600; 
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        .add-item-btn:hover {
            background-color: #6a5acd; 
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
        }
        .pill-badge-green { 
            background-color: #d1fae5; /* Light green */
            color: #065f46; /*dark green text*/
        } 
        .pill-badge-blue { 
            background-color: #dbeafe; /* Light blue*/
            color: #1e40af; /*dark blue text*/
        } 
        .pill-badge-purple { 
            background-color: #ede9fe; /* Light purple */
            color: #5b21b6; /*dark purple*/
        } 
        .pill-badge-orange { 
            background-color: #ffead5; /* Light orange*/
            color: #9a3412; /*dark orange text*/
        } 
        .pill-badge-gray { 
            background-color: #e5e7eb; /* Light gray*/
            color: #374151; /*dark gray text*/
        } 
    </style>
</head>
<body class="flex flex-col min-h-screen">
    <header class="admin-header-bg text-white px-8 py-4 flex justify-between items-center shadow-lg sticky top-0 z-10">
        <h1 class="text-3xl font-extrabold tracking-wide">Campus Admin Panel</h1>
        <div class="flex items-center space-x-6">
            <span class="text-lg font-medium">Welcome, <span class="text-yellow-300"><%= user.getUserName() %>!</span></span>
            <a href="LogoutServlet" class="bg-yellow-300 text-purple-800 hover:bg-yellow-400 px-5 py-2 rounded-full text-lg font-semibold transition-all duration-300 ease-in-out shadow-md">
                Logout
            </a>
        </div>
    </header>

    <nav class="admin-header-bg px-8 py-3 shadow-md">
        <div class="flex justify-center">
            <a href="admin.jsp?section=dashboard" class="nav-item <%= "dashboard".equals(section) ? "active" : "" %>">
                Dashboard
            </a>
            <a href="admin.jsp?section=events" class="nav-item <%= "events".equals(section) ? "active" : "" %>">
                Events
            </a>
            <a href="admin.jsp?section=clubs" class="nav-item <%= "clubs".equals(section) ? "active" : "" %>">
                Clubs
            </a>
            <a href="admin.jsp?section=merchandise" class="nav-item <%= "merchandise".equals(section) ? "active" : "" %>">
                Merchandise
            </a>
            <a href="admin.jsp?section=sales" class="nav-item <%= "sales".equals(section) ? "active" : "" %>">
                Sales
            </a>
        </div>
    </nav>

    <main class="flex-grow max-w-7xl mx-auto p-6 w-full flex flex-col items-stretch">
        <% if ("dashboard".equals(section)) { %>
        <section class="section-card active">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">Your Campus Overview</h2>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
                <div class="dashboard-metric-card">
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">Total Events</h3>
                    <p class="text-5xl font-extrabold text-blue-main drop-shadow-sm"><%= events.size() %></p>
                </div>
                <div class="dashboard-metric-card">
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">Active Clubs</h3>
                    <p class="text-5xl font-extrabold text-green-main drop-shadow-sm"><%= clubs.size() %></p>
                </div>
                <div class="dashboard-metric-card">
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">Merchandise Items</h3>
                    <p class="text-5xl font-extrabold text-purple-main drop-shadow-sm"><%= merchandise.size() %></p>
                </div>
                <div class="dashboard-metric-card">
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">Total Transactions</h3>
                    <p class="text-5xl font-extrabold text-orange-main drop-shadow-sm"><%= totalTransactions %></p>
                </div>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-10">
                <div class="dashboard-metric-card">
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">Total Revenue</h3>
                    <p class="text-4xl font-extrabold text-green-main drop-shadow-sm">RM<%= totalRevenue.setScale(2, BigDecimal.ROUND_HALF_UP) %></p>
                    <p class="text-sm text-gray-600 mt-2">From all completed purchases</p>
                </div>
                <div class="dashboard-metric-card">
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">Items Sold</h3>
                    <p class="text-4xl font-extrabold text-blue-main drop-shadow-sm"><%= totalItemsSold %></p>
                    <p class="text-sm text-gray-600 mt-2">Total quantity sold across all items</p>
                </div>
                <div class="dashboard-metric-card">
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">Sale Records</h3>
                    <p class="text-4xl font-extrabold text-purple-main drop-shadow-sm"><%= sales.size() %></p>
                    <p class="text-sm text-gray-600 mt-2">Individual item sales recorded</p>
                </div>
            </div>
            
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div class="dashboard-breakdown-card">
                    <h3 class="text-xl font-bold text-gray-800 mb-4">Payment Methods Breakdown</h3>
                    <% if (paymentMethodStats.isEmpty()) { %>
                        <p class="text-gray-500 text-center py-4">No payment data available yet. Start selling!</p>
                    <% } else { %>
                        <div class="space-y-3">
                            <% for (Sale paymentStat : paymentMethodStats) { %>
                            <div class="flex justify-between items-center p-3 bg-gray-50 rounded-lg border border-gray-100">
                                <div class="flex items-center space-x-2">
                                    <span class="text-xl">
                                        <% 
                                        String method = paymentStat.getPaymentMethod();
                                        if ("cash".equals(method)) out.print("💵");
                                        else if ("online_banking".equals(method)) out.print("🏦");
                                        else if ("e_wallet".equals(method)) out.print("📱");
                                        else if ("credit_card".equals(method)) out.print("💳");
                                        else out.print("❓");
                                        %>
                                    </span>
                                    <div>
                                        <span class="font-medium text-gray-800">
                                            <% 
                                            if ("cash".equals(method)) out.print("Cash Payment");
                                            else if ("online_banking".equals(method)) out.print("Online Banking");
                                            else if ("e_wallet".equals(method)) out.print("E-Wallet");
                                            else if ("credit_card".equals(method)) out.print("Credit/Debit Card");
                                            else out.print(method);
                                            %>
                                        </span>
                                        <p class="text-sm text-gray-600"><%= paymentStat.getQuantity() %> transactions</p>
                                    </div>
                                </div>
                                <span class="font-bold text-green-main text-lg">RM<%= paymentStat.getTotalPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></span>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
                
                <div class="dashboard-breakdown-card">
                    <h3 class="text-xl font-bold text-gray-800 mb-4">Our Best Sellers!</h3>
                    <% if (topSellingItems.isEmpty()) { %>
                        <p class="text-gray-500 text-center py-4">No top-selling items yet. Let's get those sales rolling!</p>
                    <% } else { %>
                        <div class="space-y-3">
                            <% for (int i = 0; i < topSellingItems.size(); i++) { 
                                Sale topItem = topSellingItems.get(i);
                            %>
                            <div class="flex justify-between items-center p-3 bg-gray-50 rounded-lg border border-gray-100">
                                <div class="flex items-center space-x-3">
                                    <span class="text-2xl font-bold text-blue-main">#<%= i + 1 %></span>
                                    <div>
                                        <span class="font-medium text-gray-800"><%= topItem.getMerchandiseName() %></span>
                                        <p class="text-sm text-gray-600"><%= topItem.getQuantity() %> units sold</p>
                                    </div>
                                </div>
                                <span class="font-bold text-green-main text-lg">RM<%= topItem.getTotalPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></span>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </section>
        <% } %>

        <% if ("sales".equals(section)) { %>
        <section class="section-card active">
            <div class="flex flex-wrap justify-between items-center mb-6">
                <h2 class="text-3xl font-extrabold text-blue-800 mb-4 md:mb-0">All Sales Records</h2>
                <div class="flex flex-wrap space-x-2 space-y-2 md:space-y-0 text-sm">
                    <span class="px-4 py-2 rounded-full font-semibold shadow-sm pill-badge-green">💰 Total Revenue: RM<%= totalRevenue.setScale(2, BigDecimal.ROUND_HALF_UP) %></span>
                    <span class="px-4 py-2 rounded-full font-semibold shadow-sm pill-badge-blue">📦 Items Sold: <%= totalItemsSold %></span>
                    <span class="px-4 py-2 rounded-full font-semibold shadow-sm pill-badge-purple">🧾 Transactions: <%= totalTransactions %></span>
                </div>
            </div>
            
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <table class="w-full table">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-4 py-3 text-left">Sale ID</th>
                            <th class="px-4 py-3 text-left">Customer</th>
                            <th class="px-4 py-3 text-left">Item</th>
                            <th class="px-4 py-3 text-left">Qty</th>
                            <th class="px-4 py-3 text-left">Unit Price</th>
                            <th class="px-4 py-3 text-left">Total</th>
                            <th class="px-4 py-3 text-left">Payment</th>
                            <th class="px-4 py-3 text-left">Date</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (sales.isEmpty()) { %>
                            <tr>
                                <td colspan="8" class="px-4 py-8 text-center text-gray-500 text-lg">No sales records found. Let's make some sales!</td>
                            </tr>
                        <% } else { %>
                            <% for (Sale sale : sales) { %>
                            <tr class="hover:bg-gray-50 transition-colors duration-200">
                                <td class="px-4 py-3 text-gray-700 font-medium">#<%= sale.getSaleId() %></td>
                                <td class="px-4 py-3 text-gray-700"><%= sale.getUserName() %></td>
                                <td class="px-4 py-3 text-gray-700"><%= sale.getMerchandiseName() %></td>
                                <td class="px-4 py-3 text-gray-700"><%= sale.getQuantity() %></td>
                                <td class="px-4 py-3 text-gray-700">RM<%= sale.getUnitPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                <td class="px-4 py-3 text-gray-700 font-semibold">RM<%= sale.getTotalPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                <td class="px-4 py-3">
                                    <span class="px-3 py-1 text-xs font-semibold rounded-full shadow-sm 
                                        <% 
                                        String method = sale.getPaymentMethod();
                                        if ("cash".equals(method)) out.print("pill-badge-green");
                                        else if ("online_banking".equals(method)) out.print("pill-badge-blue");
                                        else if ("e_wallet".equals(method)) out.print("pill-badge-purple");
                                        else if ("credit_card".equals(method)) out.print("pill-badge-orange");
                                        else out.print("pill-badge-gray");
                                        %>">
                                        <% 
                                        if ("cash".equals(method)) out.print("💵 Cash");
                                        else if ("online_banking".equals(method)) out.print("🏦 Online Banking");
                                        else if ("e_wallet".equals(method)) out.print("📱 E-Wallet");
                                        else if ("credit_card".equals(method)) out.print("💳 Card");
                                        else out.print(method);
                                        %>
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-gray-600 text-sm"><%= sale.getSaleDate() %></td>
                            </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
        <% } %>

        <% if ("events".equals(section)) { %>
        <section class="section-card active">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-3xl font-extrabold text-blue-800">Events Calendar</h2>
                <a href="add-event.jsp" class="add-item-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
                    </svg>
                    Add New Event
                </a>
            </div>
            
            <% if (request.getParameter("success") != null) { %>
                <div class="bg-green-100 border border-green-400 text-green-700 px-6 py-4 rounded-lg mb-4 text-center font-medium shadow-md">
                    <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-6 py-4 rounded-lg mb-4 text-center font-medium shadow-md">
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
                            <th class="px-4 py-3 text-left">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (events.isEmpty()) { %>
                            <tr>
                                <td colspan="4" class="px-4 py-8 text-center text-gray-500 text-lg">No events found. Time to plan some fun!</td>
                            </tr>
                        <% } else { %>
                            <% for (Event event : events) { %>
                            <tr class="hover:bg-gray-50 transition-colors duration-200">
                                <td class="px-4 py-3 text-gray-700 font-medium"><%= event.getTitle() %></td>
                                <td class="px-4 py-3 text-gray-700"><%= event.getEventDate() %></td>
                                <td class="px-4 py-3 text-gray-700"><%= event.getLocation() %></td>
                                <td class="px-4 py-3 flex items-center space-x-2">
                                    <a href="edit-event.jsp?id=<%= event.getEventId() %>" class="action-btn-edit">Edit</a>
                                    <a href="AdminServlet?action=deleteEvent&eventId=<%= event.getEventId() %>" 
                                       onclick="return confirm('Are you sure you want to delete this event? This cannot be undone!')" 
                                       class="action-btn-delete">Delete</a>
                                </td>
                            </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
        <% } %>

        <% if ("clubs".equals(section)) { %>
        <section class="section-card active">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-3xl font-extrabold text-blue-800">Clubs Directory</h2>
                <a href="add-club.jsp" class="add-item-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
                    </svg>
                    Add New Club
                </a>
            </div>
            
            <% if (request.getParameter("success") != null) { %>
                <div class="bg-green-100 border border-green-400 text-green-700 px-6 py-4 rounded-lg mb-4 text-center font-medium shadow-md">
                    <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-6 py-4 rounded-lg mb-4 text-center font-medium shadow-md">
                    <%= request.getParameter("error") %>
                </div>
            <% } %>
            
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <table class="w-full table">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-4 py-3 text-left">Club Name</th>
                            <th class="px-4 py-3 text-left">Description</th>
                            <th class="px-4 py-3 text-left">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (clubs.isEmpty()) { %>
                            <tr>
                                <td colspan="3" class="px-4 py-8 text-center text-gray-500 text-lg">No clubs found. Let's create some communities!</td>
                            </tr>
                        <% } else { %>
                            <% for (Club club : clubs) { %>
                            <tr class="hover:bg-gray-50 transition-colors duration-200">
                                <td class="px-4 py-3 text-gray-700 font-medium"><%= club.getClubName() %></td>
                                <td class="px-4 py-3 text-gray-700 max-w-sm overflow-hidden text-ellipsis whitespace-nowrap">
                                    <%= club.getDescription() != null && !club.getDescription().isEmpty() ? club.getDescription() : "No description provided." %>
                                </td>
                                <td class="px-4 py-3 flex items-center space-x-2">
                                    <a href="edit-club.jsp?id=<%= club.getClubId() %>" class="action-btn-edit">Edit</a>
                                    <a href="AdminServlet?action=deleteClub&clubId=<%= club.getClubId() %>" 
                                       onclick="return confirm('Are you sure you want to delete this club? This cannot be undone!')" 
                                       class="action-btn-delete">Delete</a>
                                </td>
                            </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
        <% } %>

        <% if ("merchandise".equals(section)) { %>
        <section class="section-card active">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-3xl font-extrabold text-blue-800">Merchandise Showcase</h2>
                <a href="add-merchandise.jsp" class="add-item-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
                    </svg>
                    Add New Merchandise
                </a>
            </div>
            
            <% if (request.getParameter("success") != null) { %>
                <div class="bg-green-100 border border-green-400 text-green-700 px-6 py-4 rounded-lg mb-4 text-center font-medium shadow-md">
                    <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-6 py-4 rounded-lg mb-4 text-center font-medium shadow-md">
                    <%= request.getParameter("error") %>
                </div>
            <% } %>
            
            <div class="bg-white rounded-lg shadow-xl overflow-hidden mt-6">
                <table class="w-full table">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-4 py-3 text-left">Name</th>
                            <th class="px-4 py-3 text-left">Price</th>
                            <th class="px-4 py-3 text-left">Stock</th>
                            <th class="px-4 py-3 text-left">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (merchandise.isEmpty()) { %>
                            <tr>
                                <td colspan="4" class="px-4 py-8 text-center text-gray-500 text-lg">No merchandise found. Time to stock up!</td>
                            </tr>
                        <% } else { %>
                            <% for (Merchandise item : merchandise) { %>
                            <tr class="hover:bg-gray-50 transition-colors duration-200">
                                <td class="px-4 py-3 text-gray-700 font-medium"><%= item.getMerchandiseName() %></td>
                                <td class="px-4 py-3 text-gray-700">RM<%= item.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                <td class="px-4 py-3 text-gray-700"><%= item.getStock() %></td>
                                <td class="px-4 py-3 flex items-center space-x-2">
                                    <a href="edit-merchandise.jsp?id=<%= item.getMerchandiseId() %>" class="action-btn-edit">Edit</a>
                                    <a href="AdminServlet?action=deleteMerchandise&merchandiseId=<%= item.getMerchandiseId() %>" 
                                       onclick="return confirm('Are you sure you want to delete this merchandise? This cannot be undone!')" 
                                       class="action-btn-delete">Delete</a>
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
</body>
</html>