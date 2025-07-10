package com.campus.servlet;

import com.campus.dao.*;
import com.campus.model.*;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/AdminServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB
    maxRequestSize = 1024 * 1024 * 10    // 10 MB
)
public class AdminServlet extends HttpServlet {
    private EventDAO eventDAO;
    private ClubDAO clubDAO;
    private MerchandiseDAO merchandiseDAO;

    private static final String UPLOAD_DIR = "uploads";

    @Override
    public void init() throws ServletException {
        try {
            eventDAO = new EventDAO();
            clubDAO = new ClubDAO();
            merchandiseDAO = new MerchandiseDAO();
            System.out.println("AdminServlet initialized successfully.");
        } catch (Exception e) {
            System.err.println("Error initializing AdminServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Failed to initialize AdminServlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");

        if (!"admin".equals(userRole)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            System.out.println("AdminServlet GET - Action: " + action);

            switch (action != null ? action : "") {
                case "deleteEvent":
                    handleDeleteEvent(request, response);
                    break;
                case "deleteClub":
                    handleDeleteClub(request, response);
                    break;
                case "deleteMerchandise":
                    handleDeleteMerchandise(request, response);
                    break;
                default:
                    response.sendRedirect("admin.jsp");
            }
        } catch (Exception e) {
            System.err.println("Error in AdminServlet GET: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?error=Server error occurred");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");

        if (!"admin".equals(userRole)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            System.out.println("AdminServlet POST - Action: " + action);

            switch (action != null ? action : "") {
                case "addEvent":
                    handleAddEvent(request, response);
                    break;
                case "updateEvent":
                    handleUpdateEvent(request, response);
                    break;
                case "addClub":
                    handleAddClub(request, response);
                    break;
                case "updateClub":
                    handleUpdateClub(request, response);
                    break;
                case "addMerchandise":
                    handleAddMerchandise(request, response);
                    break;
                case "updateMerchandise":
                    handleUpdateMerchandise(request, response);
                    break;
                default:
                    response.sendRedirect("admin.jsp");
            }
        } catch (Exception e) {
            System.err.println("Error in AdminServlet POST: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?error=Server error occurred");
        }
    }

    private void handleAddEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String title = request.getParameter("title");
            String eventDate = request.getParameter("eventDate");
            String location = request.getParameter("location");
            String description = request.getParameter("description");

            System.out.println("Adding event - Title: " + title + ", Date: " + eventDate + ", Location: " + location);

            if (title == null || title.trim().isEmpty()) {
                request.setAttribute("error", "Title is required");
                request.getRequestDispatcher("add-event.jsp").forward(request, response);
                return;
            }

            if (eventDate == null || eventDate.trim().isEmpty()) {
                request.setAttribute("error", "Event date is required");
                request.getRequestDispatcher("add-event.jsp").forward(request, response);
                return;
            }

            if (location == null || location.trim().isEmpty()) {
                request.setAttribute("error", "Location is required");
                request.getRequestDispatcher("add-event.jsp").forward(request, response);
                return;
            }

            Event event = new Event(title.trim(), eventDate.trim(), location.trim(),
                                    description != null ? description.trim() : "");

            boolean success = eventDAO.createEvent(event);

            if (success) {
                System.out.println("Event added successfully");
                response.sendRedirect("admin.jsp?section=events&success=Event added successfully");
            } else {
                System.err.println("Failed to add event to database");
                request.setAttribute("error", "Failed to add event to database");
                request.getRequestDispatcher("add-event.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.err.println("Error adding event: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
            request.getRequestDispatcher("add-event.jsp").forward(request, response);
        }
    }

    private void handleUpdateEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int eventId = Integer.parseInt(request.getParameter("eventId"));
            String title = request.getParameter("title");
            String eventDate = request.getParameter("eventDate");
            String location = request.getParameter("location");
            String description = request.getParameter("description");

            Event event = new Event(title, eventDate, location, description);
            event.setEventId(eventId);

            if (eventDAO.updateEvent(event)) {
                response.sendRedirect("admin.jsp?section=events&success=Event updated successfully");
            } else {
                request.setAttribute("error", "Failed to update event");
                request.getRequestDispatcher("edit-event.jsp?id=" + eventId).forward(request, response);
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing event ID for update: " + e.getMessage());
            response.sendRedirect("admin.jsp?section=events&error=Invalid event ID");
        } catch (Exception e) {
            System.err.println("Error updating event: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?section=events&error=Server error occurred");
        }
    }

    private void handleDeleteEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int eventId = Integer.parseInt(request.getParameter("eventId"));

            if (eventDAO.deleteEvent(eventId)) {
                response.sendRedirect("admin.jsp?section=events&success=Event deleted successfully");
            } else {
                response.sendRedirect("admin.jsp?section=events&error=Failed to delete event");
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing event ID for delete: " + e.getMessage());
            response.sendRedirect("admin.jsp?section=events&error=Invalid event ID");
        } catch (Exception e) {
            System.err.println("Error deleting event: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?section=events&error=Server error occurred");
        }
    }

    private void handleAddClub(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String clubName = request.getParameter("clubName");
            String description = request.getParameter("description");

            System.out.println("Adding club - Name: " + clubName);

            if (clubName == null || clubName.trim().isEmpty()) {
                request.setAttribute("error", "Club name is required");
                request.getRequestDispatcher("add-club.jsp").forward(request, response);
                return;
            }

            Club club = new Club(clubName.trim(), description != null ? description.trim() : "");

            boolean success = clubDAO.createClub(club);

            if (success) {
                System.out.println("Club added successfully");
                response.sendRedirect("admin.jsp?section=clubs&success=Club added successfully");
            } else {
                System.err.println("Failed to add club to database");
                request.setAttribute("error", "Failed to add club to database");
                request.getRequestDispatcher("add-club.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.err.println("Error adding club: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
            request.getRequestDispatcher("add-club.jsp").forward(request, response);
        }
    }

    private void handleUpdateClub(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int clubId = Integer.parseInt(request.getParameter("clubId"));
            String clubName = request.getParameter("clubName");
            String description = request.getParameter("description");

            Club club = new Club(clubName, description);
            club.setClubId(clubId);

            if (clubDAO.updateClub(club)) {
                response.sendRedirect("admin.jsp?section=clubs&success=Club updated successfully");
            } else {
                request.setAttribute("error", "Failed to update club");
                request.getRequestDispatcher("edit-club.jsp?id=" + clubId).forward(request, response);
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing club ID for update: " + e.getMessage());
            response.sendRedirect("admin.jsp?section=clubs&error=Invalid club ID");
        } catch (Exception e) {
            System.err.println("Error updating club: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?section=clubs&error=Server error occurred");
        }
    }

    private void handleDeleteClub(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int clubId = Integer.parseInt(request.getParameter("clubId"));

            if (clubDAO.deleteClub(clubId)) {
                response.sendRedirect("admin.jsp?section=clubs&success=Club deleted successfully");
            } else {
                response.sendRedirect("admin.jsp?section=clubs&error=Failed to delete club");
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing club ID for delete: " + e.getMessage());
            response.sendRedirect("admin.jsp?section=clubs&error=Invalid club ID");
        } catch (Exception e) {
            System.err.println("Error deleting club: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?section=clubs&error=Server error occurred");
        }
    }

    private void handleAddMerchandise(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String merchandiseName = null;
        String priceStr = null;
        String stockStr = null;
        String imagePath = null;
        Integer clubId = null; 

        try {
            merchandiseName = request.getParameter("merchandiseName");
            priceStr = request.getParameter("price");
            stockStr = request.getParameter("stock");
            String clubIdStr = request.getParameter("clubId"); 
            String imagePathManual = request.getParameter("imagePath");

            System.out.println("Adding merchandise - Name: " + merchandiseName + ", Price: " + priceStr + ", Stock: " + stockStr + ", Club ID: " + clubIdStr);
            System.out.println("Manual image path input: " + imagePathManual);

            // Parse clubId
            if (clubIdStr != null && !clubIdStr.trim().isEmpty()) {
                try {
                    clubId = Integer.parseInt(clubIdStr);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid Club ID format.");
                    setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                    request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                    return;
                }
            }


            String uploadedImagePath = null;
            try {
                uploadedImagePath = handleImageUpload(request);
                System.out.println("Result from handleImageUpload: " + uploadedImagePath);
            } catch (ServletException e) {
                System.err.println("File upload specific error: " + e.getMessage());
                setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                request.setAttribute("error", "Image upload failed: " + e.getMessage());
                request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                return;
            }

            if (uploadedImagePath != null) {
                imagePath = uploadedImagePath;
                System.out.println("Using uploaded image path: " + imagePath);
            } else if (imagePathManual != null && !imagePathManual.trim().isEmpty()) {
                imagePath = imagePathManual.trim();
                System.out.println("Using manual image path: " + imagePath);
            } else {
                imagePath = null;
                System.out.println("No image (uploaded or manual) provided for merchandise.");
            }

            if (merchandiseName == null || merchandiseName.trim().isEmpty()) {
                request.setAttribute("error", "Merchandise name is required");
                setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                return;
            }

            if (priceStr == null || priceStr.trim().isEmpty()) {
                request.setAttribute("error", "Price is required");
                setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                return;
            }

            if (stockStr == null || stockStr.trim().isEmpty()) {
                request.setAttribute("error", "Stock is required");
                setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                return;
            }

            BigDecimal price;
            int stock;

            try {
                price = new BigDecimal(priceStr);
                if (price.compareTo(BigDecimal.ZERO) < 0) {
                    request.setAttribute("error", "Price must be positive");
                    setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                    request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid price format");
                setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                return;
            }

            try {
                stock = Integer.parseInt(stockStr);
                if (stock < 0) {
                    request.setAttribute("error", "Stock must be non-negative");
                    setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                    request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid stock format");
                setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
                return;
            }

            Merchandise merchandise = new Merchandise(merchandiseName.trim(), price, stock, clubId, imagePath);

            boolean success = merchandiseDAO.createMerchandise(merchandise);

            if (success) {
                System.out.println("Merchandise added successfully with image: " + imagePath);
                response.sendRedirect("admin.jsp?section=merchandise&success=Merchandise added successfully");
            } else {
                System.err.println("Failed to add merchandise to database.");
                request.setAttribute("error", "Failed to add merchandise to database.");
                setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubIdStr, imagePathManual);
                request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.err.println("Error adding merchandise: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
            setMerchandiseRequestAttributes(request, merchandiseName, priceStr, stockStr, clubId != null ? clubId.toString() : "", imagePath);
            request.getRequestDispatcher("add-merchandise.jsp").forward(request, response);
        }
    }

    private void handleUpdateMerchandise(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int merchandiseId = 0;
        String merchandiseName = null;
        String priceStr = null;
        String stockStr = null;
        String imagePathManual = null;
        String currentImagePath = null;
        String finalImagePath = null;
        Integer clubId = null; 

        try {
            merchandiseId = Integer.parseInt(request.getParameter("merchandiseId"));
            merchandiseName = request.getParameter("merchandiseName");
            priceStr = request.getParameter("price");
            stockStr = request.getParameter("stock");
            String clubIdStr = request.getParameter("clubId"); 
            imagePathManual = request.getParameter("imagePath");
            currentImagePath = request.getParameter("currentImagePath");

            System.out.println("Updating merchandise ID: " + merchandiseId);
            System.out.println("Current Image Path: " + currentImagePath);
            System.out.println("Manual Image Path Input: " + imagePathManual);
            System.out.println("Club ID String: " + clubIdStr);

            if (clubIdStr != null && !clubIdStr.trim().isEmpty()) {
                try {
                    clubId = Integer.parseInt(clubIdStr);
                } catch (NumberFormatException e) {
                    String errorMsg = "Invalid Club ID format.";
                    response.sendRedirect("edit-merchandise.jsp?id=" + merchandiseId + "&error=" + errorMsg);
                    return;
                }
            }


            String uploadedImagePath = null;
            try {
                uploadedImagePath = handleImageUpload(request);
                System.out.println("Result from handleImageUpload for update: " + uploadedImagePath);
            } catch (ServletException e) {
                 System.err.println("File upload specific error during update: " + e.getMessage());
                 response.sendRedirect("edit-merchandise.jsp?id=" + merchandiseId + "&error=" + e.getMessage());
                 return;
            }

            if (uploadedImagePath != null) {
                finalImagePath = uploadedImagePath;
                System.out.println("Using newly uploaded image: " + finalImagePath);
                if (currentImagePath != null && !currentImagePath.isEmpty() && currentImagePath.startsWith(UPLOAD_DIR + "/")) {
                    deleteImageFile(currentImagePath);
                }
            } else if (imagePathManual != null && !imagePathManual.trim().isEmpty()) {
                finalImagePath = imagePathManual.trim();
                System.out.println("Using manual image path for update: " + finalImagePath);
                if (currentImagePath != null && !currentImagePath.isEmpty() && currentImagePath.startsWith(UPLOAD_DIR + "/")) {
                    deleteImageFile(currentImagePath);
                }
            } else {
                finalImagePath = currentImagePath;
                System.out.println("Keeping existing image path: " + finalImagePath);
            }

            if (merchandiseName == null || merchandiseName.trim().isEmpty() ||
                priceStr == null || priceStr.trim().isEmpty() ||
                stockStr == null || stockStr.trim().isEmpty()) {
                String errorMsg = "All required fields must be filled.";
                response.sendRedirect("edit-merchandise.jsp?id=" + merchandiseId + "&error=" + errorMsg);
                return;
            }

            BigDecimal price = new BigDecimal(priceStr);
            int stock = Integer.parseInt(stockStr);

            if (price.compareTo(BigDecimal.ZERO) < 0 || stock < 0) {
                 String errorMsg = "Price must be positive and Stock must be non-negative.";
                 response.sendRedirect("edit-merchandise.jsp?id=" + merchandiseId + "&error=" + errorMsg);
                 return;
            }

            Merchandise merchandise = new Merchandise(merchandiseName, price, stock, clubId, finalImagePath);
            merchandise.setMerchandiseId(merchandiseId);

            if (merchandiseDAO.updateMerchandise(merchandise)) {
                System.out.println("Merchandise updated successfully with image: " + finalImagePath);
                response.sendRedirect("admin.jsp?section=merchandise&success=Merchandise updated successfully");
            } else {
                String errorMsg = "Failed to update merchandise.";
                System.err.println(errorMsg);
                response.sendRedirect("edit-merchandise.jsp?id=" + merchandiseId + "&error=" + errorMsg);
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing merchandise ID/price/stock/clubId for update: " + e.getMessage());
            response.sendRedirect("admin.jsp?section=merchandise&error=Invalid parameters for update");
        } catch (Exception e) {
            System.err.println("Error updating merchandise: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?section=merchandise&error=Server error occurred during update");
        }
    }

    private void handleDeleteMerchandise(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int merchandiseId = Integer.parseInt(request.getParameter("merchandiseId"));
            
            Merchandise merchandiseToDelete = merchandiseDAO.getMerchandiseById(merchandiseId);
            String imagePathToDelete = null;
            if (merchandiseToDelete != null) {
                imagePathToDelete = merchandiseToDelete.getImagePath(); 
            }

            if (merchandiseDAO.deleteMerchandise(merchandiseId)) {
                if (imagePathToDelete != null && imagePathToDelete.startsWith(UPLOAD_DIR + "/")) {
                    deleteImageFile(imagePathToDelete);
                }
                response.sendRedirect("admin.jsp?section=merchandise&success=Merchandise deleted successfully");
            } else {
                response.sendRedirect("admin.jsp?section=merchandise&error=Failed to delete merchandise");
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing merchandise ID for delete: " + e.getMessage());
            response.sendRedirect("admin.jsp?section=merchandise&error=Invalid merchandise ID");
        } catch (Exception e) {
            System.err.println("Error deleting merchandise: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin.jsp?section=merchandise&error=Server error occurred");
        }
    }

    private String handleImageUpload(HttpServletRequest request) throws IOException, ServletException {
        System.out.println("--- Inside handleImageUpload ---");
        Part filePart = request.getPart("imageFile");

        if (filePart == null || filePart.getSize() == 0) {
            System.out.println("No file part or empty file part found.");
            return null;
        }

        String fileName = filePart.getSubmittedFileName();
        System.out.println("Original submitted filename: " + fileName);

        if (fileName == null || fileName.trim().isEmpty()) {
            System.out.println("Submitted filename is null or empty.");
            return null;
        }

        String contentType = filePart.getContentType();
        System.out.println("Content type of uploaded file: " + contentType);
        if (contentType == null || !contentType.startsWith("image/")) {
            System.err.println("Invalid content type: " + contentType + ". Only images are allowed.");
            throw new ServletException("Only image files (PNG, JPG, GIF) are allowed.");
        }

        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        System.out.println("Absolute upload path: " + uploadPath);

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            boolean created = uploadDir.mkdirs();
            System.out.println("Upload directory created: " + created);
            if (!created) {
                System.err.println("Failed to create upload directory: " + uploadPath);
                throw new ServletException("Failed to create upload directory on server.");
            }
        }

        String fileExtension = "";
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0) {
            fileExtension = fileName.substring(lastDotIndex);
        }
        String sanitizedFileName = fileName.substring(0, lastDotIndex != -1 ? lastDotIndex : fileName.length())
                                         .replaceAll("[^a-zA-Z0-9\\-_.]", "_");
        String uniqueFileName = System.currentTimeMillis() + "_" + sanitizedFileName + fileExtension;
        String filePath = uploadPath + File.separator + uniqueFileName;

        System.out.println("Saving uploaded file to: " + filePath);

        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(filePath));
            System.out.println("File saved successfully.");
        } catch (IOException e) {
            System.err.println("Error saving file to disk: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Could not save uploaded file.", e);
        }

        File savedFile = new File(filePath);
        if (savedFile.exists() && savedFile.length() > 0) {
            System.out.println("Confirmed file exists on disk. Size: " + savedFile.length());
            return UPLOAD_DIR + "/" + uniqueFileName;
        } else {
            System.err.println("File was not saved successfully or is empty after saving.");
            throw new ServletException("Failed to save uploaded file (file not found or empty after write).");
        }
    }

    private void deleteImageFile(String relativeImagePath) {
        if (relativeImagePath == null || relativeImagePath.isEmpty() || !relativeImagePath.startsWith(UPLOAD_DIR + "/")) {
            System.out.println("Skipping file deletion: Invalid or not an uploaded file path: " + relativeImagePath);
            return;
        }
        try {
            String absolutePath = getServletContext().getRealPath("") + File.separator + relativeImagePath.replace("/", File.separator);
            File fileToDelete = new File(absolutePath);
            if (fileToDelete.exists()) {
                if (fileToDelete.delete()) {
                    System.out.println("Successfully deleted old image file: " + absolutePath);
                } else {
                    System.err.println("Failed to delete old image file: " + absolutePath);
                }
            } else {
                System.out.println("Old image file not found, no deletion needed: " + absolutePath);
            }
        } catch (Exception e) {
            System.err.println("Error deleting image file: " + relativeImagePath + " - " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void setMerchandiseRequestAttributes(HttpServletRequest request, String name, String price, String stock, String clubId, String imagePath) {
        request.setAttribute("merchandiseName", name != null ? name : "");
        request.setAttribute("price", price != null ? price : "");
        request.setAttribute("stock", stock != null ? stock : "");
        request.setAttribute("clubId", clubId != null ? clubId : ""); 
        request.setAttribute("imagePath", imagePath != null ? imagePath : "");
    }
}