<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.model.User" %>
<%@ page import="com.campus.dao.MerchandiseDAO" %>
<%@ page import="com.campus.model.Merchandise" %>
<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    String userRole = (String) session.getAttribute("userRole");
    
    if (user == null || !"admin".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get merchandise ID and load merchandise data
    String merchandiseIdStr = request.getParameter("id");
    Merchandise merchandise = null;
    
    if (merchandiseIdStr != null) {
        try {
            int merchandiseId = Integer.parseInt(merchandiseIdStr);
            MerchandiseDAO merchandiseDAO = new MerchandiseDAO();
            merchandise = merchandiseDAO.getMerchandiseById(merchandiseId);
        } catch (NumberFormatException e) {
            response.sendRedirect("admin.jsp?section=merchandise&error=Invalid merchandise ID");
            return;
        }
    }
    
    if (merchandise == null) {
        response.sendRedirect("admin.jsp?section=merchandise&error=Merchandise not found");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Merchandise - Campus Management System</title>
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

        .file-upload-area {
            border: 2px dashed #9ca3af; 
            background-color: #f9fafb; 
            border-radius: 0.75rem;
            padding: 2rem;
            text-align: center;
            transition: border-color 0.3s ease, background-color 0.3s ease;
            cursor: pointer;
        }
        .file-upload-area:hover {
            border-color: #6366f1; 
            background-color: #eff6ff;
        }
        .file-upload-area.dragover {
            border-color: #6366f1;
            background-color: #eff6ff;
        }
        .image-preview {
            max-width: 200px;
            max-height: 200px;
            object-fit: cover;
            border-radius: 0.75rem; 
            border: 2px solid #e5e7eb;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); 
        }
    </style>
</head>
<body class="flex flex-col min-h-screen">
    <header class="admin-header-bg text-white px-8 py-4 flex justify-between items-center shadow-lg sticky top-0 z-10">
        <h1 class="text-3xl font-extrabold tracking-wide">Edit Merchandise</h1>
        <a href="admin.jsp?section=merchandise" class="bg-yellow-300 text-purple-800 hover:bg-yellow-400 px-5 py-2 rounded-full text-lg font-semibold transition-all duration-300 ease-in-out shadow-md">
            Back to Merchandise
        </a>
    </header>

    <main class="flex-grow max-w-2xl mx-auto p-6 w-full flex flex-col items-stretch">
        <section class="section-card">
            <h2 class="text-3xl font-extrabold text-blue-800 mb-8 text-center">Edit Merchandise Details</h2>
            
            <!-- Display error messages -->
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <form method="post" action="AdminServlet" enctype="multipart/form-data">
                <input type="hidden" name="action" value="updateMerchandise">
                <input type="hidden" name="merchandiseId" value="<%= merchandise.getMerchandiseId() %>">
                <input type="hidden" name="currentImagePath" value="<%= merchandise.getImagePath() != null ? merchandise.getImagePath() : "" %>">
                
                <div class="mb-6">
                    <label for="merchandiseName" class="block text-lg font-semibold text-gray-800 mb-2">Merchandise Name <span class="text-red-500">*</span></label>
                    <input type="text" id="merchandiseName" name="merchandiseName" required 
                           class="form-input"
                           value="<%= merchandise.getMerchandiseName() %>">
                </div>
                
                <div class="mb-6">
                    <label for="price" class="block text-lg font-semibold text-gray-800 mb-2">Price (RM) <span class="text-red-500">*</span></label>
                    <input type="number" step="0.01" min="0" id="price" name="price" required 
                           class="form-input"
                           value="<%= merchandise.getPrice() %>">
                </div>
                
                <div class="mb-6">
                    <label for="stock" class="block text-lg font-semibold text-gray-800 mb-2">Stock Quantity <span class="text-red-500">*</span></label>
                    <input type="number" min="0" id="stock" name="stock" required 
                           class="form-input"
                           value="<%= merchandise.getStock() %>">
                </div>
                
                <div class="mb-6">
                    <label class="block text-lg font-semibold text-gray-800 mb-2">Current Image</label>
                    <div class="mb-4 flex justify-center">
                        <% if (merchandise.getImagePath() != null && !merchandise.getImagePath().isEmpty()) { %>
                            <img src="<%= merchandise.getImagePath() %>" alt="Current image" class="image-preview">
                        <% } else { %>
                            <div class="w-48 h-48 bg-gray-200 rounded-lg flex items-center justify-center border border-gray-300 shadow-sm">
                                <span class="text-gray-500 text-sm">No current image</span>
                            </div>
                        <% } %>
                    </div>
                </div>
                
                <div class="mb-8">
                    <label class="block text-lg font-semibold text-gray-800 mb-2">Update Image</label>
                    
                    <div class="file-upload-area" id="fileUploadArea" onclick="document.getElementById('imageFile').click()">
                        <div id="uploadContent">
                            <svg class="mx-auto h-16 w-16 text-gray-400 mb-4" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                                <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                            </svg>
                            <p class="text-gray-700 mb-2 font-medium">Click to upload image or drag and drop</p>
                            <p class="text-sm text-gray-500">PNG, JPG, GIF up to 5MB</p>
                        </div>
                        <div id="imagePreview" style="display: none;">
                            <img id="previewImg" class="image-preview mx-auto mb-2">
                            <p id="fileName" class="text-sm text-gray-600"></p>
                        </div>
                    </div>
                    
                    <input type="file" id="imageFile" name="imageFile" accept="image/*" style="display: none;">
                    
                    <div class="mt-6">
                        <label for="imagePath" class="block text-lg font-semibold text-gray-800 mb-2">Or enter image path manually</label>
                        <input type="text" id="imagePath" name="imagePath" placeholder="/images/item.jpg"
                               class="form-input"
                               value="<%= merchandise.getImagePath() != null ? merchandise.getImagePath() : "" %>">
                        <p class="text-xs text-gray-500 mt-1">Leave empty to keep current image, or upload a file above</p>
                    </div>
                </div>
                
                <div class="flex justify-end space-x-4">
                    <a href="admin.jsp?section=merchandise" class="btn-secondary">Cancel</a>
                    <button type="submit" class="btn-primary">Update Merchandise</button>
                </div>
            </form>
        </section>
    </main>

    <script>
        const fileUploadArea = document.getElementById('fileUploadArea');
        const imageFile = document.getElementById('imageFile');
        const uploadContent = document.getElementById('uploadContent');
        const imagePreview = document.getElementById('imagePreview');
        const previewImg = document.getElementById('previewImg');
        const fileName = document.getElementById('fileName');
        const imagePath = document.getElementById('imagePath');

        imageFile.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                handleFileSelect(file);
            }
        });

        fileUploadArea.addEventListener('dragover', function(e) {
            e.preventDefault();
            fileUploadArea.classList.add('dragover');
        });

        fileUploadArea.addEventListener('dragleave', function(e) {
            e.preventDefault();
            fileUploadArea.classList.remove('dragover');
        });

        fileUploadArea.addEventListener('drop', function(e) {
            e.preventDefault();
            fileUploadArea.classList.remove('dragover');
            
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                const file = files[0];
                if (file.type.startsWith('image/')) {
                    imageFile.files = files;
                    handleFileSelect(file);
                } else {
                    showCustomAlert('Please drop an image file (PNG, JPG, GIF).');
                }
            }
        });

        function handleFileSelect(file) {
            // Validate file size (5MB limit)
            if (file.size > 5 * 1024 * 1024) {
                showCustomAlert('File size must be less than 5MB.');
                return;
            }

            // Validate file type
            if (!file.type.startsWith('image/')) {
                showCustomAlert('Please select an image file (PNG, JPG, GIF).');
                return;
            }

            const reader = new FileReader();
            reader.onload = function(e) {
                previewImg.src = e.target.result;
                fileName.textContent = file.name;
                uploadContent.style.display = 'none';
                imagePreview.style.display = 'block';
                
                imagePath.value = '';
            };
            reader.readAsDataURL(file);
        }

        // Reset to upload area when manual path is entered
        imagePath.addEventListener('input', function() {
            if (this.value.trim() !== '') {
                uploadContent.style.display = 'block';
                imagePreview.style.display = 'none';
                imageFile.value = ''; 
            }
        });

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
    </script>
</body>
</html>
