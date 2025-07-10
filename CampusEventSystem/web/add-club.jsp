<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.model.User" %>
<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    String userRole = (String) session.getAttribute("userRole");
    
    if (user == null || !"admin".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Club - Campus Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Poppins', sans-serif; 
            background-color: #e0efff; 
            margin: 0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        .page-header-bg {
            background: linear-gradient(to right, #7f73f7, #6a5acd); 
        }
        .form-container-card {
            background-color: #ffffff; 
            padding: 2.5rem; 
            border-radius: 1.5rem; 
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1); 
            transition: all 0.3s ease-in-out; 
        }
        .form-container-card:hover {
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15); 
        }
        input[type="text"],
        textarea {
            border-radius: 0.5rem; 
            border: 1px solid #d1d5db; 
            padding: 0.75rem 1rem; 
            font-size: 1rem;
            outline: none;
            box-shadow: none;
            transition: border-color 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
        }
        input[type="text"]:focus,
        textarea:focus {
            border-color: #6366f1; 
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2); 
        }
        .submit-btn {
            border-radius: 0.75rem; 
            font-weight: 700;
            transition: background-color 0.2s ease-in-out, transform 0.1s ease-in-out;
            background-color: #6366f1; 
            color: white;
            padding: 0.75rem 1.5rem; 
        }
        .submit-btn:hover {
            background-color: #4f46e5; 
            transform: translateY(-2px); 
        }
        .cancel-btn {
            border-radius: 0.75rem;
            font-weight: 600;
            transition: background-color 0.2s ease-in-out, transform 0.1s ease-in-out;
            background-color: #e5e7eb; 
            color: #4b5563;
            padding: 0.75rem 1.5rem;
        }
        .cancel-btn:hover {
            background-color: #d1d5db; 
            transform: translateY(-2px);
        }
        .error-message {
            color: #dc2626;
            background-color: #fee2e2;
            border: 1px solid #fca5a5;
            padding: 0.75rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <header class="page-header-bg text-white px-8 py-4 flex justify-between items-center shadow-lg sticky top-0 z-10">
        <h1 class="text-3xl font-extrabold tracking-wide">Add New Club</h1>
        <a href="admin.jsp?section=clubs" class="text-white hover:text-[#FEFF9F] font-semibold transition-colors duration-300 ease-in-out text-lg">
            Back to Clubs
        </a>
    </header>

    <main class="flex-grow max-w-xl mx-auto p-6 w-full flex flex-col items-stretch">
        <div class="form-container-card">
            <h2 class="text-3xl font-extrabold text-indigo-700 mb-8 text-center">Create a New Campus Club</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <form method="post" action="AdminServlet">
                <input type="hidden" name="action" value="addClub">
                
                <div class="mb-4">
                    <label for="clubName" class="block text-sm font-medium text-gray-700 mb-2">Club Name <span class="text-red-500">*</span></label>
                    <input type="text" id="clubName" name="clubName" required 
                           class="w-full"
                           value="<%= request.getParameter("clubName") != null ? request.getParameter("clubName") : "" %>">
                </div>
                
                <div class="mb-6">
                    <label for="description" class="block text-sm font-medium text-gray-700 mb-2">Description</label>
                    <textarea id="description" name="description" rows="4" 
                              class="w-full"><%= request.getParameter("description") != null ? request.getParameter("description") : "" %></textarea>
                </div>
                
                <div class="flex justify-end space-x-4">
                    <a href="admin.jsp?section=clubs" class="cancel-btn flex items-center justify-center">
                        Cancel
                    </a>
                    <button type="submit" class="submit-btn flex items-center justify-center">
                        Add Club
                    </button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>