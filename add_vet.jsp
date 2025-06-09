<%@ page import="java.sql.*,java.io.*,java.util.*,javax.servlet.http.*,javax.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="db_conn.jsp" %>
<%@include file="admin_side.html" %>

<%
/* ---------- 1. Access Control ---------- */
    String sessionUser = (String) session.getAttribute("username");
    String sessionRole = (String) session.getAttribute("role");

    if (sessionUser == null || sessionRole == null || !sessionRole.equals("Admin")) {
        session.setAttribute("redirectUrl", request.getRequestURI());
        response.sendRedirect("login.jsp");
        return;
    }

/* ---------- 2. Handle Form Submission ---------- */
String message = "";
String messageType = "";
boolean isPost = "POST".equalsIgnoreCase(request.getMethod());

if (isPost) {
    // Basic fields
    String vet_name = request.getParameter("vet_name");
    String photo = request.getParameter("photo");
    String email = request.getParameter("email");
    String contact_no = request.getParameter("contact_no");
    String specialization = request.getParameter("specialization");
    String clinic_name = request.getParameter("clinic_name");
    String address = request.getParameter("address");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String pincode = request.getParameter("pincode");
    String available_days = request.getParameter("available_days");
    String available_time = request.getParameter("available_time");
    String extra_info = request.getParameter("extra_info");

    // Validate required fields
    if (vet_name == null || vet_name.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        address == null || address.trim().isEmpty() ||
        area == null || area.trim().isEmpty()) {
        message = "All required fields must be filled!";
        messageType = "error";
    }

    // Validate email format
    if (message.isEmpty() && (email != null && !email.matches("^[A-Za-z0-9+_.-]+@(.+)$"))) {
        message = "Invalid email format!";
        messageType = "error";
    }

    // Validate pincode (6 digits for India)
    if (message.isEmpty() && (pincode != null && !pincode.trim().isEmpty() && !pincode.matches("\\d{6}"))) {
        message = "Pincode must be a 6-digit number!";
        messageType = "error";
    }

    // Validate contact number (e.g., +91- followed by 10 digits)
    if (message.isEmpty() && (contact_no != null && !contact_no.trim().isEmpty() && !contact_no.matches("\\+91-\\d{10}"))) {
        message = "Contact number must be in format +91-XXXXXXXXXX!";
        messageType = "error";
    }

    // Insert into database
    if (message.isEmpty()) {
        PreparedStatement ps = null;
        try {
            if (conn == null) throw new SQLException("Database connection is null");

            String sql = "INSERT INTO Veterinarians (vet_name, photo, email, contact_no, specialization, clinic_name, " +
                         "address, area, city, pincode, available_days, available_time, extra_info) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, vet_name);
            ps.setString(2, photo != null && !photo.trim().isEmpty() ? photo : null);
            ps.setString(3, email);
            ps.setString(4, contact_no != null && !contact_no.trim().isEmpty() ? contact_no : null);
            ps.setString(5, specialization != null && !specialization.trim().isEmpty() ? specialization : null);
            ps.setString(6, clinic_name != null && !clinic_name.trim().isEmpty() ? clinic_name : null);
            ps.setString(7, address);
            ps.setString(8, area);
            ps.setString(9, city != null && !city.trim().isEmpty() ? city : null);
            ps.setString(10, pincode != null && !pincode.trim().isEmpty() ? pincode : null);
            ps.setString(11, available_days != null && !available_days.trim().isEmpty() ? available_days : null);
            ps.setString(12, available_time != null && !available_time.trim().isEmpty() ? available_time : null);
            ps.setString(13, extra_info != null && !extra_info.trim().isEmpty() ? extra_info : null);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                message = "Veterinarian added successfully!";
                messageType = "success";
            } else {
                message = "Failed to add veterinarian!";
                messageType = "error";
            }
        } catch (SQLException ex) {
            message = "Database error: " + ex.getMessage();
            messageType = "error";
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Add New Veterinarian</title>
    <style>
/*        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f5ff;
            color: #333;
            padding-top: 80px;
        }

         Navbar Styles 
        .navbar {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            background-color: #2c3e50;
            color: white;
            padding: 15px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            z-index: 1000;
        }

        .navbar img {
            height: 50px;
            filter: brightness(0) invert(1);
        }

        .navbar nav {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .navbar a {
            text-decoration: none;
            color: white;
            font-weight: 600;
            padding: 8px 15px;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }

        .navbar a:hover {
            background-color: #1abc9c;
        }

        .logout-btn {
            background-color: #e74c3c;
            color: white;
            padding: 10px 20px;
            border-radius: 4px;
            font-weight: bold;
            transition: all 0.3s ease;
        }

        .logout-btn:hover {
            background-color: #c0392b;
            transform: translateY(-2px);
        }*/

        /* Main Container */
        .container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 0 20px;
        }

        /* Form Container */
        .form-container {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            padding: 30px;
        }

        .page-title {
            text-align: center;
            margin-bottom: 30px;
            color: #2c3e50;
            font-size: 28px;
            position: relative;
        }

        .page-title:after {
            content: "";
            position: absolute;
            width: 80px;
            height: 3px;
            background-color: #3498db;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
        }

        /* Section Headers */
        .section-header {
            font-size: 20px;
            color: #2c3e50;
            margin: 30px 0 20px 0;
            padding-bottom: 10px;
            border-bottom: 2px solid #3498db;
            font-weight: 600;
        }

        .section-header:first-of-type {
            margin-top: 0;
        }

        /* Form Layout */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .form-grid-2 {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
        }

        .required {
            color: #e74c3c;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 16px;
            color: #333;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .full-width {
            grid-column: span 3;
        }

        .half-width {
            grid-column: span 2;
        }

        /* Form Buttons */
        .form-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        .save-btn, .cancel-btn {
            padding: 12px 25px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 16px;
        }

        .save-btn {
            background-color: #27ae60;
            color: white;
        }

        .save-btn:hover {
            background-color: #219653;
            transform: translateY(-2px);
        }

        .cancel-btn {
            background-color: #7f8c8d;
            color: white;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .cancel-btn:hover {
            background-color: #636e72;
            transform: translateY(-2px);
        }

        /* Alert Messages */
        .alert {
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* Responsive Design */
        @media (max-width: 1200px) {
            .form-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .full-width {
                grid-column: span 2;
            }
        }

        @media (max-width: 768px) {
            .form-grid, .form-grid-2 {
                grid-template-columns: 1fr;
            }
            .full-width, .half-width {
                grid-column: span 1;
            }
            .navbar {
                padding: 15px 20px;
            }
            .container {
                padding: 0 15px;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
<!--    <div class="navbar">
        <img src="pet_image/logo.png" alt="Admin Logo">
        <nav>
            <a href="admin_dashboard.jsp">Dashboard</a>
            <a href="admin_view_page.jsp">Pets</a>
            <a href="add_vet.jsp" style="background-color: #1abc9c;">Veterinarians</a>
            <a href="view_adaption_request.jsp">Adoption Requests</a>
            <a href="donation.html">Donations</a>
            <a href="logout.jsp" class="logout-btn">Logout</a>
        </nav>
    </div>-->

    <!-- Main Content -->
    <div class="container">
        <div class="form-container">
            <h1 class="page-title">Add New Veterinarian</h1>

            <!-- Display Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>

            <!-- Form to add veterinarian -->
            <form action="add_vet.jsp" method="post">
                
                <!-- Basic Information Section -->
                <div class="section-header">Basic Information</div>
                <div class="form-grid">
                    <div class="form-group">
                        <label for="vet_name">Veterinarian Name <span class="required">*</span></label>
                        <input type="text" id="vet_name" name="vet_name" required placeholder="e.g., Dr. Anil Patel">
                    </div>

                    <div class="form-group">
                        <label for="photo">Photo Filename</label>
                        <input type="text" id="photo" name="photo" placeholder="e.g., vet_001.jpg">
                    </div>

                    <div class="form-group">
                        <label for="specialization">Specialization</label>
                        <input type="text" id="specialization" name="specialization" placeholder="e.g., Small Animal Medicine">
                    </div>
                </div>

                <!-- Contact Information Section -->
                <div class="section-header">Contact Information</div>
                <div class="form-grid">
                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" id="email" name="email" required placeholder="e.g., vet@example.com">
                    </div>

                    <div class="form-group">
                        <label for="contact_no">Contact Number</label>
                        <input type="tel" id="contact_no" name="contact_no" placeholder="+91-XXXXXXXXXX">
                    </div>
                </div>

                <!-- Clinic Details Section -->
                <div class="section-header">Clinic Details</div>
                <div class="form-grid">
                    <div class="form-group">
                        <label for="clinic_name">Clinic Name</label>
                        <input type="text" id="clinic_name" name="clinic_name" placeholder="e.g., Paws & Claws Clinic">
                    </div>

                    <div class="form-group full-width">
                        <label for="address">Address <span class="required">*</span></label>
                        <textarea id="address" name="address" required placeholder="e.g., Shop No. 12, Surya Complex, Gurukul Road"></textarea>
                    </div>

                    <div class="form-group">
                        <label for="area">Area <span class="required">*</span></label>
                        <input type="text" id="area" name="area" required placeholder="e.g., Memnagar">
                    </div>

                    <div class="form-group">
                        <label for="city">City</label>
                        <input type="text" id="city" name="city" placeholder="e.g., Ahmedabad">
                    </div>

                    <div class="form-group">
                        <label for="pincode">Pincode</label>
                        <input type="text" id="pincode" name="pincode" placeholder="e.g., 380052">
                    </div>
                </div>

                <!-- Availability Section -->
                <div class="section-header">Availability</div>
                <div class="form-grid-2">
                    <div class="form-group">
                        <label for="available_days">Available Days</label>
                        <input type="text" id="available_days" name="available_days" placeholder="e.g., Monday-Saturday">
                    </div>

                    <div class="form-group">
                        <label for="available_time">Available Time</label>
                        <input type="text" id="available_time" name="available_time" placeholder="e.g., 10:00 AM - 6:00 PM">
                    </div>
                </div>

                <!-- Additional Information Section -->
                <div class="section-header">Additional Information</div>
                <div class="form-grid">
                    <div class="form-group full-width">
                        <label for="extra_info">Extra Information</label>
                        <textarea id="extra_info" name="extra_info" placeholder="e.g., Specializes in canine and feline health, offers emergency services"></textarea>
                    </div>
                </div>

                <div class="form-buttons">
                    <a href="admin_view_vets.jsp" class="cancel-btn">Cancel</a>
                    <button type="submit" class="save-btn">Add Veterinarian</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>