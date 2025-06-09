<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="db_conn.jsp" %>
<%@include file="admin_side.html" %>

<%
    String sessionUser = (String) session.getAttribute("username");
    String sessionRole = (String) session.getAttribute("role");

    if (sessionUser == null || sessionRole == null || !sessionRole.equals("Admin")) {
        session.setAttribute("redirectUrl", request.getRequestURI() + "?" + request.getQueryString());
        response.sendRedirect("login.jsp");
        return;
    }

    String userIdParam = request.getParameter("id");
    if (userIdParam == null || userIdParam.trim().isEmpty()) {
        out.println("<p>Error: No user ID provided.</p>");
        return;
    }

    int userId;
    try {
        userId = Integer.parseInt(userIdParam);
    } catch (NumberFormatException e) {
        out.println("<p>Error: Invalid user ID format.</p>");
        return;
    }

    String backUrl = request.getParameter("backUrl");
    if (backUrl == null || backUrl.trim().isEmpty()) {
        backUrl = request.getHeader("Referer");
        if (backUrl == null || backUrl.trim().isEmpty()) {
            backUrl = request.getContextPath() + "/manage_users.jsp"; 
        }
    }

    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        String query = "SELECT u.user_id, u.username, u.fullname, u.email, u.phone, u.address, u.city, " +
                       "u.pincode, u.photo, u.role, u.created_at, u.updated_at, " +
                       "a.has_pets, a.no_of_pets, a.no_of_family_members, a.has_any_allergy, a.allergy_details " +
                       "FROM Users u " +
                       "LEFT JOIN Adopters a ON u.user_id = a.user_id " +
                       "WHERE u.user_id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        if (!rs.next()) {
            out.println("<p>Error: User not found.</p>");
            return;
        }

        // Extract user details
        String e_username = rs.getString("username");
        String fullname = rs.getString("fullname");
        String email = rs.getString("email");
        String phone = rs.getString("phone");
        String address = rs.getString("address");
        String city = rs.getString("city");
        String pincode = rs.getString("pincode");
        String photo = rs.getString("photo");
        String role = rs.getString("role");
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");

        // Extract adopter-specific details (null if user is not an Adopter)
        String hasPets = rs.getString("has_pets");
        Integer noOfPets = rs.getInt("no_of_pets");
        if (rs.wasNull()) noOfPets = null;
        Integer noOfFamilyMembers = rs.getInt("no_of_family_members");
        if (rs.wasNull()) noOfFamilyMembers = null;
        String hasAnyAllergy = rs.getString("has_any_allergy");
        String allergyDetails = rs.getString("allergy_details");
%>
<!DOCTYPE html>
<html>
<head>
    <title>User Details</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f5ff;
            margin: 0;
            padding-top: 80px;
            color: #333;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            background-color: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .user-image {
            width: 100%;
            max-height: 400px;
            object-fit: cover;
            border-radius: 10px;
        }

        .user-image-placeholder {
            width: 100%;
            max-height: 400px;
            border-radius: 10px;
            background-color: #e0e7ff;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-size: 16px;
            font-weight: bold;
        }

        h1, h2 {
            color: #1a4c96;
            margin-bottom: 20px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px 30px;
        }

        .info-grid p {
            margin: 5px 0;
            font-size: 16px;
        }

        .btn {
            display: inline-block;
            margin-top: 30px;
            padding: 10px 20px;
            background-color: #4285f4;
            color: white;
            text-decoration: none;
            font-weight: bold;
            border-radius: 6px;
        }

        .btn:hover {
            background-color: #1a4c96;
        }
    </style>
</head>
<body>
<div class="container">
<%
        if (photo != null && !photo.trim().isEmpty()) {
%>
    <img src="<%= request.getContextPath() %>/pet_image/<%= photo %>" alt="<%= e_username %>'s Photo" class="user-image">
<%      } else { %>
    <div class="user-image-placeholder">No Photo Available</div>
<%      } %>
    <h1><%= fullname != null ? fullname : e_username %> - <%= role %></h1>
    <h2>Personal Information</h2>
    <div class="info-grid">
        <p><strong>User ID:</strong> <%= userId %></p>
        <p><strong>Username:</strong> <%= e_username %></p>
        <p><strong>Full Name:</strong> <%= fullname != null ? fullname : "Not provided" %></p>
        <p><strong>Email:</strong> <%= email %></p>
        <p><strong>Phone:</strong> <%= phone != null ? phone : "Not provided" %></p>
        <p><strong>Address:</strong> <%= address != null ? address : "Not provided" %></p>
        <p><strong>City:</strong> <%= city != null ? city : "Not provided" %></p>
        <p><strong>Pincode:</strong> <%= pincode != null ? pincode : "Not provided" %></p>
        <p><strong>Created:</strong> <%= createdAt %></p>
        <!--<p><strong>Updated:</strong> <%= updatedAt %></p>-->
    </div>
    <br>
    <h2>Adopter Information</h2>
    <% if (role.equalsIgnoreCase("Adopter") && (hasPets != null || noOfPets != null || noOfFamilyMembers != null || hasAnyAllergy != null)) { %>
        <div class="info-grid">
            <p><strong>Has Pets:</strong> <%= hasPets != null ? hasPets : "Not specified" %></p>
            <p><strong>Number of Pets:</strong> <%= noOfPets != null ? noOfPets : "Not specified" %></p>
            <p><strong>Family Members:</strong> <%= noOfFamilyMembers != null ? noOfFamilyMembers : "Not specified" %></p>
            <p><strong>Has Allergies:</strong> <%= hasAnyAllergy != null ? hasAnyAllergy : "Not specified" %></p>
            <% if (allergyDetails != null && !allergyDetails.trim().isEmpty()) { %>
                <p style="grid-column: 1 / -1;"><strong>Allergy Details:</strong> <%= allergyDetails %></p>
            <% } %>
        </div>
    <% } else { %>
        <p><%= role.equalsIgnoreCase("Admin") ? "Not applicable for Admin users" : "No adopter information available" %></p>
    <% } %>
    <br>
    <a href="<%= backUrl %>" class="btn">← Back</a>
</div>
</body>
</html>
<%
    } catch (SQLException e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
    }
%>