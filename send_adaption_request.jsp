<%-- 
    Document   : send_adaption_request
    Created on : 9 Jun 2025, 1:24:00 pm
    Author     : RUSHANG MAHALE
--%>
<%@ page import="java.sql.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="db_conn.jsp" %>
<%@include file="navigation_page.html" %>

<%
    String sessionUser = (String) session.getAttribute("username");
    if (sessionUser == null) {
        session.setAttribute("redirectUrl", request.getRequestURI() + "?id=" + request.getParameter("id"));
        response.sendRedirect("login.jsp");
        return;
    }

    // Check if user profile is complete
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean isProfileComplete = true;
    int userId = -1;

    try {
        // Get user_id
        String queryUserId = "SELECT user_id FROM Users WHERE username = ?";
        ps = conn.prepareStatement(queryUserId);
        ps.setString(1, sessionUser);
        rs = ps.executeQuery();
        if (rs.next()) {
            userId = rs.getInt("user_id");
        } else {
            isProfileComplete = false;
        }
        rs.close();
        ps.close();

        if (userId != -1) {
            // Check Users table for required fields
            String queryUsers = "SELECT fullname, email, phone, address, city, pincode FROM Users WHERE user_id = ?";
            ps = conn.prepareStatement(queryUsers);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                if (rs.getString("fullname") == null || rs.getString("email") == null || rs.getString("phone") == null ||
                    rs.getString("address") == null || rs.getString("city") == null || rs.getString("pincode") == null) {
                    isProfileComplete = false;
                }
            }
            rs.close();
            ps.close();

            // Check Adopters table for required fields
            String queryAdopters = "SELECT has_pets, no_of_family_members, has_any_allergy FROM Adopters WHERE user_id = ?";
            ps = conn.prepareStatement(queryAdopters);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                if (rs.getString("has_pets") == null || rs.getObject("no_of_family_members") == null || 
                    rs.getString("has_any_allergy") == null) {
                    isProfileComplete = false;
                }
            } else {
                isProfileComplete = false; // No Adopters record
            }
            rs.close();
            ps.close();
        }

        if (!isProfileComplete) {
            session.setAttribute("redirectUrl", request.getRequestURI() + "?id=" + request.getParameter("id"));
            response.sendRedirect("edit_user.jsp");
            return;
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<div class='alert' role='alert'>Error checking profile: " + e.getMessage() + "</div>");
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
    }

    // Fetch pet details
    int petId = Integer.parseInt(request.getParameter("id"));
    String name = "";
    String breed = "";
    try {
        String query = "SELECT name, breed FROM Pets WHERE pet_id = ?";
        ps = conn.prepareStatement(query);
        ps.setInt(1, petId);
        rs = ps.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            breed = rs.getString("breed");
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<div class='alert' role='alert'>Error fetching pet data: " + e.getMessage() + "</div>");
        return;
    }

    // Fetch user details
    String fullname = "";
    String email = "";
    String phone = "";
    try {
        String query2 = "SELECT fullname, email, phone FROM Users WHERE username = ?";
        ps = conn.prepareStatement(query2);
        ps.setString(1, sessionUser);
        rs = ps.executeQuery();
        if (rs.next()) {
            fullname = rs.getString("fullname");
            email = rs.getString("email");
            phone = rs.getString("phone");
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<div class='alert' role='alert'>Error fetching user data: " + e.getMessage() + "</div>");
        return;
    }

    // Handle form submission
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String message = request.getParameter("message");
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        String request_date = now.format(formatter);

        String insertQuery = "INSERT INTO AdoptionRequests (pet_id, user_id, request_date, reason_for_adoption) VALUES (?, ?, ?, ?)";
        try {
            ps = conn.prepareStatement(insertQuery);
            ps.setInt(1, petId);
            ps.setInt(2, userId);
            ps.setString(3, request_date);
            ps.setString(4, message);
            ps.executeUpdate();
            response.sendRedirect("adoption_status.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<div class='alert' role='alert'>Error submitting request: " + e.getMessage() + "</div>");
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send Adoption Request</title>
    <style>
        :root {
            --primary-color: #1a4c96;
            --primary-hover: #2a5ca8;
            --primary-gradient: linear-gradient(135deg, #1a4c96 0%, #2a5ca8 100%);
            --success-color: #4CAF50;
            --warning-color: #ff9800;
            --danger-color: #f44336;
            --vet-color: #ab47bc;
            --light-bg: #f0f5ff;
            --white: #ffffff;
            --text-primary: #333;
            --text-secondary: #666;
            --border-color: #e2e8f0;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 8px rgba(0,0,0,0.12);
            --shadow-lg: 0 8px 16px rgba(0,0,0,0.15);
            --border-radius: 12px;
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-bg);
            color: var(--text-primary);
            line-height: 1.7;
            padding: 2.5rem;
            min-height: 100vh;
            font-size: 16px;
        }

        .container {
            display: flex;
            margin: 2rem auto;
            max-width: 1400px;
            gap: 2rem;
        }

        .main-content {
            flex: 1;
            padding: 1rem;
        }

        .header {
            text-align: center;
            margin-bottom: 3.5rem;
            padding: 2rem;
            background: var(--white);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-sm);
        }

        .header h1 {
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 2.8rem;
            font-weight: 700;
            margin-bottom: 0.75rem;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .form-card {
            background: var(--white);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-md);
            padding: 2rem;
            border-top: 4px solid var(--vet-color);
            transition: var(--transition);
            max-width: 600px;
            margin: 0 auto;
        }

        .form-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        label {
            display: block;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            font-size: 1rem;
        }

        label.required::after {
            content: "*";
            color: var(--danger-color);
            margin-left: 0.25rem;
        }

        input, textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 1rem;
            color: var(--text-primary);
            transition: var(--transition);
        }

        input:focus, textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(26, 76, 150, 0.1);
        }

        input[readonly] {
            background-color: #f8fafc;
            cursor: not-allowed;
        }

        textarea {
            resize: vertical;
            min-height: 120px;
        }

        .submit-btn {
            background: var(--primary-gradient);
            color: var(--white);
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            width: 100%;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        .submit-btn:hover {
            background: var(--primary-hover);
            transform: translateY(-3px);
            box-shadow: var(--shadow-sm);
        }

        .alert {
            padding: 1.25rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            font-size: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            background: rgba(244, 67, 54, 0.1);
            color: var(--danger-color);
            border: 1px solid rgba(244, 67, 54, 0.2);
        }

        .footer-text {
            text-align: center;
            margin-top: 2rem;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        @media (max-width: 768px) {
            body {
                padding: 1.5rem;
            }

            .container {
                flex-direction: column;
                margin: 1rem;
            }

            .header h1 {
                font-size: 2.2rem;
            }

            .form-card {
                padding: 1.5rem;
            }
        }

        @media (max-width: 480px) {
            .header h1 {
                font-size: 1.8rem;
            }

            .form-group label {
                font-size: 0.95rem;
            }

            input, textarea {
                font-size: 0.95rem;
            }

            .submit-btn {
                font-size: 0.95rem;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <div class="main-content">
        <div class="header">
            <h1>Pet Adoption Request</h1>
        </div>
        <div class="form-card" role="form" aria-label="Adoption request form">
            <form action="" method="post">
                <div class="form-group">
                    <label for="fullname">Your Name</label>
                    <input type="text" id="fullname" value="<%= fullname != null ? fullname : "" %>" readonly>
                </div>
                <div class="form-group">
                    <label for="email">Your Email</label>
                    <input type="email" id="email" value="<%= email != null ? email : "" %>" readonly>
                </div>
                <div class="form-group">
                    <label for="phone" class="required">Phone Number</label>
                    <input type="tel" id="phone" name="phone" value="<%= phone != null ? phone : "" %>" required>
                </div>
                <div class="form-group">
                    <label for="name">Pet Name</label>
                    <input type="text" id="name" value="<%= name != null ? name : "" %>" readonly>
                </div>
                <div class="form-group">
                    <label for="breed">Breed</label>
                    <input type="text" id="breed" value="<%= breed != null ? breed : "" %>" readonly>
                </div>
                <div class="form-group">
                    <label for="message" class="required">Why do you want to adopt this pet?</label>
                    <textarea id="message" name="message" placeholder="Tell us about your home, lifestyle, and why you'd be a great pet parent..." required></textarea>
                </div>
                <button type="submit" class="submit-btn" aria-label="Send adoption request">
                    <i class="fas fa-paw"></i> Send Adoption Request
                </button>
            </form>
        </div>
        <div class="footer-text">
            Thank you for considering adoption! We'll review your application and contact you soon.
        </div>
    </div>
</div>
</body>
</html>