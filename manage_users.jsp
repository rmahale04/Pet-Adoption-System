<%-- 
    Document   : manage_users
    Created on : 8 Jun 2025, 3:45:43 am
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
        session.setAttribute("redirectUrl", request.getRequestURI());
        response.sendRedirect("login.jsp");
        return;
    }

    // Get filter parameter
    String roleFilter = request.getParameter("role");

    // First query: Get total counts (unfiltered)
    Statement countStmt = null;
    ResultSet countRs = null;
    int totalUsers = 0;
    int adminCount = 0;
    int adopterCount = 0;

    try {
        countStmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        countRs = countStmt.executeQuery("SELECT role FROM users");
        while (countRs.next()) {
            totalUsers++;
            String role = countRs.getString("role");
            if ("Admin".equalsIgnoreCase(role)) {
                adminCount++;
            } else {
                adopterCount++;
            }
        }
    } catch (SQLException e) {
        out.println("Error fetching total counts: " + e.getMessage());
    } finally {
        if (countRs != null) try { countRs.close(); } catch (SQLException ignored) {}
        if (countStmt != null) try { countStmt.close(); } catch (SQLException ignored) {}
    }

    // Second query: Get filtered user list
    StringBuilder query = new StringBuilder("SELECT user_id, username, fullname, email, phone, role, created_at FROM users WHERE 1=1");
    
    if (roleFilter != null && !roleFilter.isEmpty() && !roleFilter.equals("All")) {
        query.append(" AND role = '").append(roleFilter).append("'");
    }
    query.append(" ORDER BY CASE WHEN role = 'Admin' THEN 1 ELSE 2 END, created_at DESC");

    Statement stmt = null;
    ResultSet rs = null;
    try {
        stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        rs = stmt.executeQuery(query.toString());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management Dashboard</title>
    <!--<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">-->
    <style>
        :root {
            --primary-color: #1a4c96;
            --primary-hover: #2a5ca8;
            --primary-gradient: linear-gradient(135deg, #1a4c96 0%, #2a5ca8 100%);
            --success-color: #4CAF50;
            --warning-color: #ff9800;
            --danger-color: #f44336;
            --admin-color: #9c27b0;
            --adopter-color: #2196f3;
            --light-bg: #f0f5ff;
            --white: #ffffff;
            --text-primary: #333;
            --text-secondary: #666;
            --border-color: #e2e8f0;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 8px rgba(0,0,0,0.12);
            --shadow-lg: 0 8px 16px rgba(0,0,0,0.15);
            --border-radius: 12px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f5ff;
            color: #333;
            line-height: 1.6;
            padding: 2rem;
            min-height: 100vh;
        }

        /* Main Container */
        .container {
            display: flex;
            margin: 40px;
            gap: 30px;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 280px;
            background-color: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            position: sticky;
            top: 100px;
            height: fit-content;
        }

        .sidebar h4 {
            margin-top: 20px;
            color: #2c3e50;
            font-size: 18px;
        }

        .sidebar a {
            color: #3498db;
            text-decoration: none;
            display: block;
            margin-bottom: 20px;
            transition: all 0.3s ease;
        }

        .sidebar a:hover {
            color: #2c3e50;
        }

        .sidebar select {
            width: 100%;
            padding: 12px;
            margin-top: 8px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 6px;
            color: #555;
            font-size: 15px;
        }

        .sidebar button {
            background-color: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            width: 100%;
            transition: all 0.3s ease;
        }

        .sidebar button:hover {
            background-color: #2c3e50;
            transform: translateY(-2px);
        }

        /* Main Content */
        .main-content {
            flex: 1;
        }

        .header {
            text-align: center;
            margin-bottom: 3rem;
        }

        .header h1 {
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        /* Stats Container */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--white);
            border-radius: var(--border-radius);
            padding: 1.5rem;
            box-shadow: var(--shadow-md);
            text-align: center;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }

        .stat-card.total {
            border-left: 4px solid var(--primary-color);
        }

        .stat-card.admin {
            border-left: 4px solid var(--admin-color);
        }

        .stat-card.adopter {
            border-left: 4px solid var(--adopter-color);
        }

        .stat-card i {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .stat-card.total i {
            color: var(--primary-color);
        }

        .stat-card.admin i {
            color: var(--admin-color);
        }

        .stat-card.adopter i {
            color: var(--adopter-color);
        }

        .stat-card h3 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }

        .stat-card p {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .section {
            margin-bottom: 3rem;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
            padding: 1rem 0;
            border-bottom: 3px solid var(--border-color);
        }

        .section-header.user-section {
            border-bottom-color: #3498db; /* Match Apply Filter button color */
        }

        .section-header.admin-section {
            border-bottom-color: var(--admin-color);
            justify-content: space-between;
        }

        .section-header.adopter-section {
            border-bottom-color: var(--adopter-color);
            justify-content: space-between;
        }

        .section-header h2 {
            font-size: 1.8rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-count, .admin-count, .adopter-count {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.9rem;
            font-weight: 600;
            color: white;
        }

        .user-count {
            background: var(--primary-color);
        }

        .admin-count {
            background: var(--admin-color);
        }

        .adopter-count {
            background: var(--adopter-color);
        }

        .user-count i, .admin-count i, .adopter-count i {
            font-size: 1rem;
        }

        .user-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1.5rem;
        }

        .user-card {
            background: var(--white);
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            transition: all 0.3s ease;
            position: relative;
        }

        .user-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }

        .user-card.admin-card {
            border-top: 4px solid var(--admin-color);
        }

        .user-card.adopter-card {
            border-top: 4px solid var(--adopter-color);
        }

        .card-header {
            padding: 1.5rem 1.5rem 1rem;
            position: relative;
        }

        .role-badge {
            position: absolute;
            top: 1rem;
            right: 1rem;
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .role-badge.admin {
            background: rgba(156, 39, 176, 0.1);
            color: var(--admin-color);
            border: 1px solid rgba(156, 39, 176, 0.2);
        }

        .role-badge.adopter {
            background: rgba(33, 150, 243, 0.1);
            color: var(--adopter-color);
            border: 1px solid rgba(33, 150, 243, 0.2);
        }

        .user-info h3 {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            margin-right: 80px;
        }

        .card-body {
            padding: 0 1.5rem 1.5rem;
        }

        .user-details {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 0.9rem;
        }

        .detail-item i {
            width: 16px;
            color: var(--primary-color);
            flex-shrink: 0;
        }

        .detail-item .label {
            font-weight: 600;
            color: var(--text-primary);
            min-width: 60px;
        }

        .detail-item .value {
            color: var(--text-secondary);
            flex: 1;
        }

        .card-actions {
            display: flex;
            gap: 0.75rem;
        }

        .action-btn {
            flex: 1;
            padding: 0.75rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        .view-btn {
            background: var(--primary-gradient);
            color: white;
        }

        .view-btn:hover {
            background: linear-gradient(135deg, var(--primary-hover) 0%, #3470dc 100%);
            transform: translateY(-1px);
            box-shadow: var(--shadow-sm);
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: var(--text-secondary);
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            color: var(--border-color);
        }

        .empty-state h3 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            color: var(--text-primary);
        }

        @media (max-width: 768px) {
            body {
                padding: 1rem;
            }

            .container {
                flex-direction: column;
                margin: 20px;
            }

            .sidebar {
                width: 100%;
                position: static;
            }

            .header h1 {
                font-size: 2rem;
            }

            .section-header.admin-section,
            .section-header.adopter-section {
                flex-direction: column;
                align-items: flex-start;
            }

            .header-right {
                width: 100%;
                justify-content: space-between;
            }

            .user-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .header-right {
                flex-direction: column;
                gap: 0.5rem;
            }

            .card-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar Filters -->
        <div class="sidebar">
            <form method="post" action="manage_users.jsp">
                <a href="manage_users.jsp"><i class="fas fa-filter"></i> <strong>Clear all filters</strong></a>

                <h4>Role</h4>
                <select name="role">
                    <option value="">All roles</option>
                    <option value="Admin">Admin</option>
                    <option value="Adopter">Adopter</option>
                </select>

                <button type="submit">Apply Filter</button>
            </form>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <br>
            <div class="section-header user-section">
                <div>
                    <i class="fas fa-users"></i>
                    <h2>System Users</h2>
                </div>
            </div>
            <!-- Stats Cards -->
            <div class="stats-container">
                <div class="stat-card total">
                    <i class="fas fa-users"></i>
                    <h3><%= totalUsers %></h3>
                    <p>Total Users</p>
                </div>
                <div class="stat-card admin">
                    <i class="fas fa-crown"></i>
                    <h3><%= adminCount %></h3>
                    <p>Administrators</p>
                </div>
                <div class="stat-card adopter">
                    <i class="fas fa-heart"></i>
                    <h3><%= adopterCount %></h3>
                    <p>Adopters</p>
                </div>
            </div>

            <!-- Administrators Section -->
            <% if (adminCount > 0) { %>
            <div class="section" id="admin-section">
                <div class="section-header admin-section">
                    <div>
                        <i class="fas fa-crown"></i>
                        <h2>System Administrators</h2>
                    </div>
                    <div class="header-right">
                        <span class="admin-count">
                            <i class="fas fa-crown"></i>
                            <span><%= adminCount %> Admins</span>
                        </span>
                    </div>
                </div>
                <div class="user-grid">
                    <%
                        rs.beforeFirst();
                        while (rs.next()) {
                            String role = rs.getString("role");
                            if ("Admin".equalsIgnoreCase(role)) {
                                int userId = rs.getInt("user_id");
                                String e_username = rs.getString("username");
                                String fullname = rs.getString("fullname");
                                String email = rs.getString("email");
                                String phone = rs.getString("phone");
                                Timestamp createdAt = rs.getTimestamp("created_at");
                    %>
                    <div class="user-card admin-card">
                        <div class="card-header">
                            <div class="role-badge admin">
                                <i class="fas fa-crown"></i> Admin
                            </div>
                            <div class="user-info">
                                <h3><%= fullname != null ? fullname : e_username %></h3>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="user-details">
                                <div class="detail-item">
                                    <i class="fas fa-id-badge"></i>
                                    <span class="label">ID:</span>
                                    <span class="value">#<%= userId %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-envelope"></i>
                                    <span class="label">Email:</span>
                                    <span class="value"><%= email %></span>
                                </div>
                                <% if (phone != null && !phone.trim().isEmpty()) { %>
                                <div class="detail-item">
                                    <i class="fas fa-phone"></i>
                                    <span class="label">Phone:</span>
                                    <span class="value"><%= phone %></span>
                                </div>
                                <% } %>
                                <div class="detail-item">
                                    <i class="fas fa-briefcase"></i>
                                    <span class="label">Role:</span>
                                    <span class="value"><%= role %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-calendar-plus"></i>
                                    <span class="label">Joined:</span>
                                    <span class="value"><%= createdAt != null ? createdAt.toString().substring(0, 10) : "N/A" %></span>
                                </div>
                            </div>
                            <div class="card-actions">
                                <a href="user_info.jsp?id=<%= userId %>" class="action-btn view-btn">
                                    <i class="fas fa-eye"></i>
                                    View Details
                                </a>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        }
                    %>
                </div>
            </div>
            <% } %>

            <!-- Adopters/Users Section -->
            <% if (adopterCount > 0) { %>
            <div class="section" id="adopter-section">
                <div class="section-header adopter-section">
                    <div>
                        <i class="fas fa-heart"></i>
                        <h2>Adopters & Users</h2>
                    </div>
                    <div class="header-right">
                        <span class="adopter-count">
                            <i class="fas fa-heart"></i>
                            <span><%= adopterCount %> Adopters</span>
                        </span>
                    </div>
                </div>
                <div class="user-grid">
                    <%
                        rs.beforeFirst();
                        while (rs.next()) {
                            String role = rs.getString("role");
                            if (!"Admin".equalsIgnoreCase(role)) {
                                int userId = rs.getInt("user_id");
                                String e_username = rs.getString("username");
                                String fullname = rs.getString("fullname");
                                String email = rs.getString("email");
                                String phone = rs.getString("phone");
                                Timestamp createdAt = rs.getTimestamp("created_at");
                    %>
                    <div class="user-card adopter-card">
                        <div class="card-header">
                            <div class="role-badge adopter">
                                <i class="fas fa-heart"></i> <%= role %>
                            </div>
                            <div class="user-info">
                                <h3><%= fullname != null ? fullname : e_username %></h3>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="user-details">
                                <div class="detail-item">
                                    <i class="fas fa-id-badge"></i>
                                    <span class="label">ID:</span>
                                    <span class="value">#<%= userId %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-envelope"></i>
                                    <span class="label">Email:</span>
                                    <span class="value"><%= email %></span>
                                </div>
                                <% if (phone != null && !phone.trim().isEmpty()) { %>
                                <div class="detail-item">
                                    <i class="fas fa-phone"></i>
                                    <span class="label">Phone:</span>
                                    <span class="value"><%= phone %></span>
                                </div>
                                <% } %>
                                <div class="detail-item">
                                    <i class="fas fa-briefcase"></i>
                                    <span class="label">Role:</span>
                                    <span class="value"><%= role %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-calendar-plus"></i>
                                    <span class="label">Joined:</span>
                                    <span class="value"><%= createdAt != null ? createdAt.toString().substring(0, 10) : "N/A" %></span>
                                </div>
                            </div>
                            <div class="card-actions">
                                <a href="user_info.jsp?id=<%= userId %>" class="action-btn view-btn">
                                    <i class="fas fa-eye"></i>
                                    View Details
                                </a>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        }
                    %>
                </div>
            </div>
            <% } %>

            <% if (totalUsers == 0) { %>
            <div class="empty-state">
                <i class="fas fa-users-slash"></i>
                <h3>No Users Found</h3>
                <p>No users match the selected filters.</p>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('User Management Dashboard loaded successfully');
        });
    </script>
</body>
</html>
<%
    } catch (SQLException e) {
        out.println("<div style='text-align: center; padding: 2rem; background: #fff; border-radius: 12px; margin: 2rem; box-shadow: 0 4px 6px rgba(0,0,0,0.1);'>");
        out.println("<i class='fas fa-exclamation-triangle' style='font-size: 3rem; color: #f44336; margin-bottom: 1rem;'></i>");
        out.println("<h3 style='color: #f44336; margin-bottom: 0.5rem;'>Database Error</h3>");
        out.println("<p style='color: #666;'>Error fetching user data: " + e.getMessage() + "</p>");
        out.println("</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
    }
%>