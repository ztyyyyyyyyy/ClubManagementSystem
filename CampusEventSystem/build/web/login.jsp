<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campus Event & Club Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Poppins', sans-serif; 
            background-color: #e0f2fe;
            margin: 0;
            overflow-x: hidden;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        header {
            background-color: #818cf8; 
            color: white;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
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
        .success-message {
            color: #059669;
            background-color: #d1fae5;
            border: 1px solid #a7f3d0;
            padding: 0.75rem;
            border-radius: 0.5rem; 
            margin-bottom: 1rem;
            font-weight: 500;
        }
        .form-container {
            background-color: #ffffff;
            padding: 2.5rem; 
            border-radius: 1.5rem; 
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1); 
            transition: all 0.3s ease-in-out; 
        }
        .form-container:hover {
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15); 
        }
        input[type="email"],
        input[type="password"],
        input[type="text"],
        select {
            border-radius: 0.5rem; 
            border: 1px solid #d1d5db; 
            padding: 0.75rem 1rem; 
            font-size: 1rem;
        }
        button[type="submit"] {
            border-radius: 0.75rem; 
            font-weight: 700; 
            transition: background-color 0.2s ease-in-out, transform 0.1s ease-in-out;
        }
        button[type="submit"]:hover {
            transform: translateY(-2px); 
        }
        #login-form button[type="submit"] {
            background-color: #6366f1; 
            color: white;
        }
        #login-form button[type="submit"]:hover {
            background-color: #4f46e5;
        }
        #register-form button[type="submit"] {
            background-color: #22c55e;
            color: white;
        }
        #register-form button[type="submit"]:hover {
            background-color: #16a34a;
        }
        a {
            color: #4f46e5; 
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s ease-in-out;
        }
        a:hover {
            color: #3730a3;
            text-decoration: underline;
        }
        main {
            flex-grow: 1; 
        }
        footer {
            background-color: #dbeafe; 
            padding: 1rem;
            margin-top: auto; 
            box-shadow: 0 -2px 5px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>
<header class="px-6 py-4 flex justify-between items-center sticky top-0 z-10">
    <h1 class="text-white text-2xl font-bold select-none tracking-wide">Campus Connect Hub</h1>
    <nav aria-label="Primary" role="navigation">
        <a href="#" id="nav-account" class="active" aria-current="page" style="cursor: pointer; padding: 0.75rem 1.5rem; display: inline-block; color: white; font-weight: 700; user-select: none; border-bottom: 4px solid #fde047; background-color: rgba(255 255 255 / 0.25); border-radius: 0.75rem 0.75rem 0 0;">My Account</a>
    </nav>
</header>

<main style="max-width: 900px; margin: 2.5rem auto; padding: 0 1.5rem;">
    <section id="section-account" class="active" role="region" aria-label="Account Management">
        <h2 style="color: #6366f1; font-weight: 800; font-size: 2.25rem; margin-bottom: 1.5rem; text-align: center;">Welcome! Manage Your Campus Life</h2>
        <p class="mb-6 text-center text-gray-600 text-lg">Your hub for events, clubs, and campus connections!</p>
        
        <div class="max-w-md mx-auto">
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="success-message">
                    <%= request.getAttribute("success") %>
                </div>
            <% } %>
            
            <form id="login-form" class="mb-8 form-container" method="post" action="LoginServlet">
                <h3 class="text-2xl font-bold mb-4 text-center text-indigo-700">Login to Your Account</h3>
                <label for="login-email" class="block mb-2 font-medium text-gray-700">Email:</label>
                <input type="email" id="login-email" name="email" required class="w-full mb-4" placeholder="your.email@example.com" />
                <label for="login-password" class="block mb-2 font-medium text-gray-700">Password:</label>
                <input type="password" id="login-password" name="password" required class="w-full mb-6" placeholder="••••••••" />
                <button type="submit" class="w-full py-3">Login</button>
                <div class="mt-6 text-center text-gray-600">
                    <p>Don't have an account? <a href="#register" id="register-link">Register Here</a></p>
                </div>
            </form>
            
            <div class="login-register-form" id="register-form" style="display: none;">
                <form id="register1-form" class="form-container" method="post" action="RegisterServlet">
                    <h3 class="text-2xl font-bold mb-4 text-center text-emerald-700">Join Us! Register Now</h3>
                    <label for="register-username" class="block mb-2 font-medium text-gray-700">Username:</label>
                    <input type="text" id="register-username" name="username" required class="w-full mb-4" placeholder="Choose a username" />
                    <label for="register-password" class="block mb-2 font-medium text-gray-700">Password:</label>
                    <input type="password" id="register-password" name="password" required class="w-full mb-4" placeholder="Create a strong password" />
                    <label for="register-email" class="block mb-2 font-medium text-gray-700">Email:</label>
                    <input type="email" id="register-email" name="email" required class="w-full mb-4" placeholder="your.email@example.com" />
                    <div class="form-group">
                        <label for="register-role" class="block mb-2 font-medium text-gray-700">I am a:</label>
                        <select id="register-role" name="role" class="w-full mb-6">
                            <option value="student">Student </option>
                            <option value="admin">Admin </option>
                            <option value="staff">Staff </option>
                        </select>
                    </div>
                    <button type="submit" class="w-full py-3">Register</button>
                    <div class="mt-6 text-center text-gray-600">
                        <p>Already have an account? <a href="#login" id="login-link">Login Here</a></p>
                    </div>
                </form>
            </div>
        </div>
    </section>
</main>

<footer class="text-center text-gray-600 text-sm py-4">
    &copy; 2025 Campus Connect Hub - All rights reserved. Made with ❤️ for students.
</footer>

<script>
const registerLink = document.getElementById("register-link");
const loginLink = document.getElementById("login-link");
const registrationForm = document.getElementById("register-form");
const loginForm = document.getElementById("login-form");

registerLink.addEventListener('click', (e) => {
    e.preventDefault();
    loginForm.style.display = "none";
    registrationForm.style.display = "block";
});

loginLink.addEventListener('click', (e) => {
    e.preventDefault();
    registrationForm.style.display = "none";
    loginForm.style.display = "block";
});
</script>
</body>
</html>