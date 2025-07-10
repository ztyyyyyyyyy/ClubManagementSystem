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
    <title>Add Merchandise - Campus Management System</title>
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
        input[type="number"],
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
        input[type="number"]:focus,
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

        .file-upload-area {
            border: 2px dashed #a78bfa; 
            border-radius: 0.75rem; 
            padding: 2.5rem; 
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
            background-color: #e0f2fe; 
        }
        .file-upload-area svg {
            color: #818cf8;
        }
        .file-upload-area p {
            color: #4b5563; 
        }
        .file-upload-area p.text-sm {
            color: #6b7280; 
        }
        .image-preview {
            max-width: 200px;
            max-height: 200px;
            object-fit: cover;
            border-radius: 0.75rem; 
            border: 2px solid #c4b5fd; 
        }
    </style>
</head>
<body>
    <header class="page-header-bg text-white px-8 py-4 flex justify-between items-center shadow-lg sticky top-0 z-10">
        <h1 class="text-3xl font-extrabold tracking-wide">Add New Merchandise</h1>
        <a href="admin.jsp?section=merchandise" class="text-white hover:text-[#FEFF9F] font-semibold transition-colors duration-300 ease-in-out text-lg">
            Back to Merchandise
        </a>
    </header>

    <main class="flex-grow max-w-xl mx-auto p-6 w-full flex flex-col items-stretch">
        <div class="form-container-card">
            <h2 class="text-3xl font-extrabold text-indigo-700 mb-8 text-center">Add New Product to Store</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <form method="post" action="AdminServlet" enctype="multipart/form-data">
                <input type="hidden" name="action" value="addMerchandise">
                
                <div class="mb-4">
                    <label for="merchandiseName" class="block text-sm font-medium text-gray-700 mb-2">Merchandise Name <span class="text-red-500">*</span></label>
                    <input type="text" id="merchandiseName" name="merchandiseName" required 
                           class="w-full"
                           value="<%= request.getParameter("merchandiseName") != null ? request.getParameter("merchandiseName") : "" %>">
                </div>
                
                <div class="mb-4">
                    <label for="price" class="block text-sm font-medium text-gray-700 mb-2">Price (RM) <span class="text-red-500">*</span></label>
                    <input type="number" step="0.01" min="0" id="price" name="price" required 
                           class="w-full"
                           value="<%= request.getParameter("price") != null ? request.getParameter("price") : "" %>">
                </div>
                
                <div class="mb-4">
                    <label for="stock" class="block text-sm font-medium text-gray-700 mb-2">Stock Quantity <span class="text-red-500">*</span></label>
                    <input type="number" min="0" id="stock" name="stock" required 
                           class="w-full"
                           value="<%= request.getParameter("stock") != null ? request.getParameter("stock") : "" %>">
                </div>
                
                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-2">Product Image</label>
                    
                    <div class="file-upload-area" id="fileUploadArea" onclick="document.getElementById('imageFile').click()">
                        <div id="uploadContent">
                            <svg class="mx-auto h-12 w-12 mb-4" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                                <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                            </svg>
                            <p class="mb-2">Click to upload image or drag and drop</p>
                            <p class="text-sm">PNG, JPG, GIF up to 5MB</p>
                        </div>
                        <div id="imagePreview" style="display: none;">
                            <img id="previewImg" class="image-preview mx-auto mb-2">
                            <p id="fileName" class="text-sm"></p>
                        </div>
                    </div>
                    
                    <input type="file" id="imageFile" name="imageFile" accept="image/*" style="display: none;">
                    
                    <div class="mt-4">
                        <label for="imagePath" class="block text-sm font-medium text-gray-700 mb-2">Or enter image path manually</label>
                        <input type="text" id="imagePath" name="imagePath" placeholder="/images/item.jpg"
                               class="w-full"
                               value="<%= request.getParameter("imagePath") != null ? request.getParameter("imagePath") : "" %>">
                        <p class="text-xs text-gray-500 mt-1">You can upload a file above OR enter a path manually</p>
                    </div>
                </div>
                
                <div class="flex justify-end space-x-4">
                    <a href="admin.jsp?section=merchandise" class="cancel-btn flex items-center justify-center">
                        Cancel
                    </a>
                    <button type="submit" class="submit-btn flex items-center justify-center">
                        Add Merchandise
                    </button>
                </div>
            </form>
        </div>
    </main>

    <script>
        const fileUploadArea = document.getElementById('fileUploadArea');
        const imageFile = document.getElementById('imageFile');
        const uploadContent = document.getElementById('uploadContent');
        const imagePreview = document.getElementById('imagePreview');
        const previewImg = document.getElementById('previewImg');
        const fileName = document.getElementById('fileName');
        const imagePath = document.getElementById('imagePath');

    // Handle file selection
    imageFile.addEventListener('change', function(e) {
        console.log('File input changed');
        const file = e.target.files[0];
        console.log('Selected file:', file);
        if (file) {
            handleFileSelect(file);
        }
    });

    // Handle drag and drop
    fileUploadArea.addEventListener('dragover', function(e) {
        e.preventDefault();
        console.log('Drag over');
        fileUploadArea.classList.add('dragover');
    });

    fileUploadArea.addEventListener('dragleave', function(e) {
        e.preventDefault();
        console.log('Drag leave');
        fileUploadArea.classList.remove('dragover');
    });

    fileUploadArea.addEventListener('drop', function(e) {
        e.preventDefault();
        console.log('File dropped');
        fileUploadArea.classList.remove('dragover');
        
        const files = e.dataTransfer.files;
        console.log('Dropped files:', files);
        if (files.length > 0) {
            const file = files[0];
            console.log('Dropped file:', file);
            if (file.type.startsWith('image/')) {
                const dt = new DataTransfer();
                dt.items.add(file);
                imageFile.files = dt.files;
                handleFileSelect(file);
            } else {
                alert('Please select an image file');
            }
        }
    });

    function handleFileSelect(file) {
        console.log('Handling file select:', file);
        
        // Validate file size (5MB limit)
        if (file.size > 5 * 1024 * 1024) {
            alert('File size must be less than 5MB');
            return;
        }

        // Validate file type
        if (!file.type.startsWith('image/')) {
            alert('Please select an image file');
            return;
        }

        console.log('File validation passed');

        // Show preview
        const reader = new FileReader();
        reader.onload = function(e) {
            console.log('File read successfully');
            previewImg.src = e.target.result;
            fileName.textContent = file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
            uploadContent.style.display = 'none';
            imagePreview.style.display = 'block';
            
            imagePath.value = '';
            console.log('Preview updated');
        };
        reader.onerror = function(e) {
            console.error('Error reading file:', e);
            alert('Error reading file');
        };
        reader.readAsDataURL(file);
    }

    imagePath.addEventListener('input', function() {
        if (this.value.trim() !== '') {
            console.log('Manual path entered:', this.value);
            uploadContent.style.display = 'block';
            imagePreview.style.display = 'none';
            imageFile.value = ''; 
        }
    });

    document.querySelector('form').addEventListener('submit', function(e) {
        console.log('Form submitting...');
        console.log('File input files:', imageFile.files);
        console.log('Manual path:', imagePath.value);
        
        if (imageFile.files.length > 0) {
            console.log('Submitting with file:', imageFile.files[0]);
        } else if (imagePath.value.trim()) {
            console.log('Submitting with manual path:', imagePath.value);
        } else {
            console.log('Submitting without image');
        }
    });
</script>
</body>
</html>