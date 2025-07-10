<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.model.User" %>
<%@ page import="com.campus.dao.EventDAO" %>
<%@ page import="com.campus.model.Event" %>
<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    String userRole = (String) session.getAttribute("userRole");
    
    if (user == null || !"admin".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get event ID and load event data
    String eventIdStr = request.getParameter("id");
    Event event = null;
    
    if (eventIdStr != null) {
        try {
            int eventId = Integer.parseInt(eventIdStr);
            EventDAO eventDAO = new EventDAO();
            event = eventDAO.getEventById(eventId);
        } catch (NumberFormatException e) {
            response.sendRedirect("admin.jsp?section=events&error=Invalid event ID");
            return;
        }
    }
    
    if (event == null) {
        response.sendRedirect("admin.jsp?section=events&error=Event not found");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Event - Campus Management System</title>
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
        .form-input {
            border: 1px solid #d1d5db; 
            padding: 0.75rem 1rem; 
            font-size: 1rem;
            border-radius: 0.75rem; 
            width: 100%; 
            box-sizing: border-box;
        }
        .form-input:focus {
            outline: none;
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2); 
        }
        
        .btn-primary {
            background-color: #22c55e;
            color: white;
            padding: 0.75rem 1.75rem;
            border-radius: 0.75rem; 
            font-weight: 700; 
            transition: background-color 0.2s ease-in-out, transform 0.1s ease-in-out;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .btn-primary:hover {
            background-color: #16a34a;
            transform: translateY(-2px);
        }
        .btn-secondary {
            background-color: #6b7280;
            color: white;
            padding: 0.75rem 1.75rem; 
            border-radius: 0.75rem; 
            font-weight: 700;
            transition: background-color 0.2s ease-in-out, transform 0.1s ease-in-out;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .btn-secondary:hover {
            background-color: #4b5563;
            transform: translateY(-2px);
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
        <h1 class="text-3xl font-extrabold tracking-wide">Edit Event</h1>
        <a href="admin.jsp?section=events" class="bg-yellow-300 text-purple-800 hover:bg-yellow-400 px-5 py-2 rounded-full text-lg font-semibold transition-all duration-300 ease-in-out shadow-md">
            Back to Events
        </a>
    </header>

    <main class="flex-grow max-w-2xl mx-auto p-6 w-full flex flex-col items-stretch">
        <section class="section-card">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">Edit Event Details</h2>
            
            <!-- Display error messages -->
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <form method="post" action="AdminServlet">
                <input type="hidden" name="action" value="updateEvent">
                <input type="hidden" name="eventId" value="<%= event.getEventId() %>">
                
                <div class="mb-6">
                    <label for="title" class="block text-lg font-semibold text-gray-800 mb-2">Event Title <span class="text-red-500">*</span></label>
                    <input type="text" id="title" name="title" required 
                           class="form-input"
                           value="<%= event.getTitle() %>">
                </div>
                
                <div class="mb-6">
                    <label for="eventDate" class="block text-lg font-semibold text-gray-800 mb-2">Event Date <span class="text-red-500">*</span></label>
                    <input type="date" id="eventDate" name="eventDate" required 
                           class="form-input"
                           value="<%= event.getEventDate() %>">
                </div>
                
                <div class="mb-6">
                    <label for="location" class="block text-lg font-semibold text-gray-800 mb-2">Location <span class="text-red-500">*</span></label>
                    <input type="text" id="location" name="location" required 
                           class="form-input"
                           value="<%= event.getLocation() %>">
                </div>
                
                <div class="mb-8">
                    <label for="description" class="block text-lg font-semibold text-gray-800 mb-2">Description</label>
                    <textarea id="description" name="description" rows="6" 
                              class="form-input resize-y"><%= event.getDescription() != null ? event.getDescription() : "" %></textarea>
                </div>
                
                <div class="flex justify-end space-x-4">
                    <a href="admin.jsp?section=events" class="btn-secondary">Cancel</a>
                    <button type="submit" class="btn-primary">Update Event</button>
                </div>
            </form>
        </section>
    </main>
</body>
</html>
