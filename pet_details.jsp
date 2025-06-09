<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="db_conn.jsp" %>
<%@ include file="navigation_page.html" %>

<%
    // Session validation
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
//        session.setAttribute("redirectUrl", request.getRequestURI());
        session.setAttribute("redirectUrl", request.getRequestURI() + "?id=" + request.getParameter("id"));
        response.sendRedirect("login.jsp");
        return;
    }

    int petId = Integer.parseInt(request.getParameter("id"));
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Pet Details</title>
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

        .pet-image {
            width: 100%;
            max-height: 400px;
            object-fit: cover;
            border-radius: 10px;
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
    try {
        ps = conn.prepareStatement("SELECT * FROM pets WHERE pet_id = ?");
        ps.setInt(1, petId);
        rs = ps.executeQuery();

        if (rs.next()) {
%>
    <img src="<%= request.getContextPath() %>/pet_image/<%= rs.getString("image") %>" alt="Pet Image" class="pet-image">
    <h1><%= rs.getString("name") %> - <%= rs.getString("species") %></h1>
    <div class="info-grid">
        <p><strong>Breed:</strong> <%= rs.getString("breed") %></p>
        <p><strong>Age:</strong> <%= rs.getInt("age") %> years</p>
        <p><strong>Gender:</strong> <%= rs.getString("gender") %></p>
        <p><strong>Color:</strong> <%= rs.getString("color") %></p>
        <p><strong>Weight:</strong> <%= rs.getDouble("weight") %> kg</p>
        <p><strong>Height:</strong> <%= rs.getDouble("height") %> cm</p>
        <p><strong>Status:</strong> <%= rs.getString("status") %></p>
        <p><strong>Description:</strong> <%= rs.getString("description") %></p> 
    </div>
    <br>
    <h2>Health & Medical Information</h2>
    <div class="info-grid">
        <p><strong>Vaccinated:</strong> <%= rs.getString("vaccinated") %>
        <p><strong>Neutered/Spayed:</strong> <%= rs.getString("neutered_or_spayed") %>
        <p><strong>Health Status:</strong> <%= rs.getString("health_status") %></p>
        <p><strong>Medications needed (if any):</strong> <%= rs.getString("medication") %></p>
        <p><strong>Special Needs:</strong> <%= rs.getString("special_needs") %></p>
    </div>
    <br>
    <h2>Behavior & Compatibility</h2>
    <div class="info-grid">
        <p><strong>Good with Pets:</strong> <%= rs.getString("good_with_pets") %></p>
        <p><strong>Good with Kids:</strong> <%= rs.getString("good_with_kids") %></p>
        <p><strong>Good with Strangers:</strong> <%= rs.getString("good_with_strangers") %></p>
        <p><strong>Behavioral Traits:</strong> <%= rs.getString("behavioral_traits") %></p>
        <p><strong>Trained For:</strong> <%= rs.getString("trained_for") %></p>
    </div>
    <br>
    <h2>Care & Routine</h2>
    <div class="info-grid">
        <p><strong>Preferable Food:</strong> <%= rs.getString("preferable_food") %></p>
        <p><strong>Dietary Restrictions:</strong> <%= rs.getString("dietary_restrictions") %></p>
        <p><strong>Daily Routine:</strong> <%= rs.getString("daily_routine") %></p>
    </div>
    <br>
    <h2>Reason for Rehoming</h2>
    <p><%= rs.getString("reason_for_rehoming") %></p>
    <br>
    <h2>My Story</h2>
    <p><%= rs.getString("story") %></p>
    <br>
    
    <a href="<%= request.getContextPath() %>/send_adaption_request.jsp?id=<%= petId %>" class="btn">Adopt Me Now</a>
    <a href="<%= request.getContextPath() %>/view_pet.jsp" class="btn">← Back to List</a>
<%
        } else {
            out.println("<p>Pet not found.</p>");
        }
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
</div>
</body>
</html>