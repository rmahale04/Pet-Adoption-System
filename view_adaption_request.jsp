<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_conn.jsp" %>
<%@include file="admin_side.html" %>

<%
    String sessionUser = (String) session.getAttribute("username");
    String sessionRole = (String) session.getAttribute("role");

    if (sessionUser == null || sessionRole == null || !sessionRole.equals("Admin")) {
        session.setAttribute("redirectUrl", request.getRequestURI());
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Adoption Requests</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f5ff;
            color: #333;
            padding-top: 80px; /* Space for fixed navbar */
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
        }

        h1 {
            text-align: center;
            color: #2c3e50;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #2c3e50;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .back-btn {
            display: inline-block;
            margin-top: 10px;
            text-decoration: none;
            background: #3498db;
            color: white;
            padding: 10px 16px;
            border-radius: 5px;
        }

        .main-content {
    margin-left: 20px; /* Push content to the right of the sidebar */
    padding: 20px;
}
.action-btn {
    padding: 8px 12px;
    margin: 0 4px;
    border: none;
    border-radius: 4px;
    color: white;
    cursor: pointer;
    text-decoration: none;
}

.approve-btn {
    background-color: #2ecc71; /* Green */
}

.reject-btn {
    background-color: #e74c3c; /* Red */
}

    </style>
</head>
<body>    
    <div class="main-content">
    <div class="header">
        <h1>Adoption Requests</h1>
    </div>
    
    

<%
    Statement stmt = null;
    ResultSet rs = null;

    try {
        stmt = conn.createStatement();
        String sql = "SELECT request_id, user_id, pet_id, request_date, reason_for_adoption, status FROM AdoptionRequests";
        rs = stmt.executeQuery(sql);
%>

<table>
    <tr>
        <th>User ID</th>
        <th>Pet ID</th>
        <th>Request Date</th>
        <th>Reason for Adoption</th>
        <th>Status</th>
        <th>Action</th>
    </tr>

    <%
        while (rs.next()) {
    %>
    <tr>
        <td><%= rs.getInt("user_id") %></td>
        <td><%= rs.getInt("pet_id") %></td>
        <td><%= rs.getString("request_date") %></td>
        <td><%= rs.getString("reason_for_adoption")%></td>
        <td><%= rs.getString("status") == null ? "Pending" : rs.getString("status") %></td>

        <td>
            <a href="accept_adoption.jsp?id=<%= rs.getInt("request_id") %>" class="action-btn approve-btn">Accept</a>
            <br><br>
            <a href="reject_adoption.jsp?id=<%= rs.getInt("request_id") %>" class="action-btn reject-btn">Reject</a>
        </td>
    </tr>
    <%
        }
    %>

</table>

<%
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
    }
%>
<br><br><br>
<a class="back-btn" href="admin_dashboard.jsp">Back to Dashboard</a>
</div>
</body>
</html>
