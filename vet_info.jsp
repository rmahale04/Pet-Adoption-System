<%-- 
    Document   : vet_info
    Created on : 8 Jun 2025, 6:08:57 pm
    Author     : RUSHANG MAHALE
--%>

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

    String vetIdParam = request.getParameter("id");
    if (vetIdParam == null || vetIdParam.trim().isEmpty()) {
        out.println("<p>Error: No vet ID provided.</p>");
        return;
    }

    int vetId;
    try {
        vetId = Integer.parseInt(vetIdParam);
    } catch (NumberFormatException e) {
        out.println("<p>Error: Invalid vet ID format.</p>");
        return;
    }

    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        String query = "SELECT vet_id, vet_name, photo, email, contact_no, specialization, clinic_name, " +
                       "address, area, city, pincode, available_days, available_time, extra_info " +
                       "FROM Veterinarians WHERE vet_id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, vetId);
        rs = pstmt.executeQuery();

        if (!rs.next()) {
            out.println("<p>Error: Veterinarian not found.</p>");
            return;
        }

        // Extract vet details
        String vetName = rs.getString("vet_name");
        String photo = rs.getString("photo");
        String email = rs.getString("email");
        String contactNo = rs.getString("contact_no");
        String specialization = rs.getString("specialization");
        String clinicName = rs.getString("clinic_name");
        String address = rs.getString("address");
        String area = rs.getString("area");
        String city = rs.getString("city");
        String pincode = rs.getString("pincode");
        String availableDays = rs.getString("available_days");
        String availableTime = rs.getString("available_time");
        String extraInfo = rs.getString("extra_info");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Vet Details</title>
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

        .vet-image {
            width: 100%;
            max-height: 400px;
            object-fit: cover;
            border-radius: 10px;
        }

        .vet-image-placeholder {
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
    <img src="<%= request.getContextPath() %>/pet_image/<%= photo %>" alt="<%= vetName %>'s Photo" class="vet-image">
<%      } else { %>
    <div class="vet-image-placeholder">No Photo Available</div>
<%      } %>
    <h1><%= vetName %> - Vet</h1>
    <h2>Professional Information</h2>
    <div class="info-grid">
        <p><strong>Vet ID:</strong> <%= vetId %></p>
        <p><strong>Name:</strong> <%= vetName %></p>
        <p><strong>Email:</strong> <%= email %></p>
        <p><strong>Phone:</strong> <%= contactNo != null ? contactNo : "Not provided" %></p>
        <p><strong>Specialization:</strong> <%= specialization != null ? specialization : "Not specified" %></p>
        <p><strong>Clinic Name:</strong> <%= clinicName != null ? clinicName : "Not provided" %></p>
        <p><strong>Address:</strong> <%= address != null ? address : "Not provided" %></p>
        <p><strong>Area:</strong> <%= area != null ? area : "Not provided" %></p>
        <p><strong>City:</strong> <%= city != null ? city : "Not provided" %></p>
        <p><strong>Pincode:</strong> <%= pincode != null ? pincode : "Not provided" %></p>
    </div>
    <br>
    <h2>Availability Information</h2>
    <div class="info-grid">
        <p><strong>Available Days:</strong> <%= availableDays != null ? availableDays : "Not specified" %></p>
        <p><strong>Available Time:</strong> <%= availableTime != null ? availableTime : "Not specified" %></p>
        
    </div>
    <br>
    <h2>Additional Information</h2>
        <% if (extraInfo != null && !extraInfo.trim().isEmpty()) { %>
            <p style="grid-column: 1 / -1;"><strong>Additional Info:</strong> <%= extraInfo %></p>
        <% } %>
    <br>
    <a href="<%= request.getContextPath() %>/manage_vets.jsp" class="btn">← Back</a>
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