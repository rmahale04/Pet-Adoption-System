<%-- 
    Document   : manage_feedback
    Created on : 8 Jun 2025, 9:10:00 PM
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

    // Handle deletion request
    String action = request.getParameter("action");
    String deleteFeedbackId = request.getParameter("delete_id");
    String successMessage = null;
    String errorMessage = null;

    if ("delete".equals(action) && deleteFeedbackId != null && !deleteFeedbackId.trim().isEmpty()) {
        PreparedStatement deleteStmt = null;
        try {
            int feedbackIdToDelete = Integer.parseInt(deleteFeedbackId);
            String deleteQuery = "DELETE FROM Feedback WHERE feedback_id = ?";
            deleteStmt = conn.prepareStatement(deleteQuery);
            deleteStmt.setInt(1, feedbackIdToDelete);
            int rowsAffected = deleteStmt.executeUpdate();

            if (rowsAffected > 0) {
                successMessage = "Feedback with ID #" + feedbackIdToDelete + " has been deleted successfully.";
            } else {
                errorMessage = "Feedback with ID #" + feedbackIdToDelete + " could not be found.";
            }
        } catch (NumberFormatException e) {
            errorMessage = "Invalid feedback ID format.";
        } catch (SQLException e) {
            errorMessage = "Error deleting feedback: " + e.getMessage();
        } finally {
            if (deleteStmt != null) try { deleteStmt.close(); } catch (SQLException ignored) {}
        }
    }

    // Get filter parameter
    String feedbackType = request.getParameter("feedback_type");

    // Build the query dynamically
    StringBuilder query = new StringBuilder(
        "SELECT f.feedback_id, f.user_id, u.username, f.feedback_type, f.feedback_text, f.rating, f.feedback_date " +
        "FROM Feedback f " +
        "JOIN Users u ON f.user_id = u.user_id " +
        "WHERE 1=1"
    );

    if (feedbackType != null && !feedbackType.isEmpty()) {
        query.append(" AND f.feedback_type = '").append(feedbackType).append("'");
    }
    query.append(" ORDER BY f.feedback_date DESC");

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
    <title>Feedback Management Dashboard</title>
    <style>
        :root {
            --primary-color: #1a4c96;
            --primary-hover: #2a5ca8;
            --primary-gradient: linear-gradient(135deg, #1a4c96 0%, #2a5ca8 100%);
            --success-color: #4CAF50;
            --warning-color: #ff9800;
            --danger-color: #f44336;
            --feedback-color: #ab47bc; /* Purple for feedback (used only for card border) */
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

        .section-header.feedback-section {
            border-bottom-color: #3498db; /* Match Delete button color */
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

        .feedback-count {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.9rem;
            font-weight: 600;
        }

        .feedback-grid {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .feedback-card {
            background: var(--white);
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            transition: all 0.3s ease;
            position: relative;
            width: 100%; /* Stretch to full width of parent */
        }

        .feedback-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }

        .feedback-card.feedback-card {
            border-top: 4px solid var(--feedback-color);
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

        .role-badge.feedback {
            background: rgba(171, 71, 188, 0.1);
            color: var(--feedback-color);
            border: 1px solid rgba(171, 71, 188, 0.2);
        }

        .feedback-info h3 {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            margin-right: 80px;
        }

        .card-body {
            padding: 0 1.5rem 1.5rem;
        }

        .feedback-details {
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
            flex: 1; /* Both buttons will take equal space */
            height: 45px; /* Fixed height for consistency */
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            background-color: #3498db;
            color: white;
            font-size: 14px; /* Consistent font size */
        }

        .action-btn:hover {
            background-color: #2980b9;
        }

        .view-user-btn {
            background-color: #3498db;
            color: white;
        }

        .view-user-btn:hover {
            background-color: #2980b9;
        }

        /* Ensure the form doesn't affect button layout */
        .card-actions form {
            flex: 1; /* Form takes equal space like the anchor tag */
            display: flex;
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

        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .alert-success {
            background: rgba(76, 175, 80, 0.1);
            color: var(--success-color);
            border: 1px solid rgba(76, 175, 80, 0.2);
        }

        .alert-error {
            background: rgba(244, 67, 54, 0.1);
            color: var(--danger-color);
            border: 1px solid rgba(244, 67, 54, 0.2);
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

            .section-header.feedback-section {
                flex-direction: column;
                align-items: flex-start;
            }

            .header-right {
                width: 100%;
                justify-content: space-between;
            }

            .feedback-card {
                width: 100%; /* Ensure full width on smaller screens */
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

            .action-btn {
                width: 100%;
            }
            
            .card-actions form {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar Filters -->
        <div class="sidebar">
            <form method="post" action="manage_feedback.jsp">
                <a href="manage_feedback.jsp"><i class="fas fa-filter"></i> <strong>Clear all filters</strong></a>

                <h4>Feedback Type</h4>
                <select name="feedback_type">
                    <option value="">All feedback types</option>
                    <option value="testimonial">Testimonial</option>
                    <option value="general">General</option>
                </select>

                <button type="submit">Apply Filter</button>
            </form>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <br>
            <%
                // Display success or error message
                if (successMessage != null) {
            %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <%= successMessage %>
                </div>
            <%
                } else if (errorMessage != null) {
            %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= errorMessage %>
                </div>
            <%
                }
            %>

            <%
                // Count statistics
                rs.beforeFirst();
                int totalFeedbacks = 0;
                
                while (rs.next()) {
                    totalFeedbacks++;
                }
            %>

            <!-- Feedback Section -->
            <% if (totalFeedbacks > 0) { %>
            <div class="section" id="feedback-section">
                <div class="section-header feedback-section">
                    <div>
                        <i class="fas fa-comment"></i>
                        <h2>Feedback</h2>
                    </div>
                    <div class="header-right">
                        <span class="feedback-count">
                            <i class="fas fa-comment"></i>
                            <span><%= totalFeedbacks %> Feedbacks</span>
                        </span>
                    </div>
                </div>
                <div class="feedback-grid">
                    <%
                        rs.beforeFirst();
                        while (rs.next()) {
                            int feedbackId = rs.getInt("feedback_id");
                            int userId = rs.getInt("user_id");
                            String e_username = rs.getString("username");
                            String feedbackTypeValue = rs.getString("feedback_type");
                            String feedbackText = rs.getString("feedback_text");
                            Integer rating = rs.getInt("rating");
                            if (rs.wasNull()) rating = null;
                            Timestamp feedbackDate = rs.getTimestamp("feedback_date");
                    %>
                    <div class="feedback-card feedback-card">
                        <div class="card-header">
                            <div class="role-badge feedback">
                                <i class="fas fa-comment"></i> <%= feedbackTypeValue %>
                            </div>
                            <div class="feedback-info">
                                <h3><%= e_username %></h3>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="feedback-details">
                                <div class="detail-item">
                                    <i class="fas fa-id-badge"></i>
                                    <span class="label">ID:</span>
                                    <span class="value">#<%= feedbackId %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-comment-alt"></i>
                                    <span class="label">Feedback:</span>
                                    <span class="value"><%= feedbackText %></span>
                                </div>
                                <% if (rating != null) { %>
                                <div class="detail-item">
                                    <i class="fas fa-star"></i>
                                    <span class="label">Rating:</span>
                                    <span class="value"><%= rating %>/5</span>
                                </div>
                                <% } %>
                                <div class="detail-item">
                                    <i class="fas fa-calendar-alt"></i>
                                    <span class="label">Date:</span>
                                    <span class="value"><%= feedbackDate %></span>
                                </div>
                            </div>
                            <div class="card-actions">
                                <a href="user_info.jsp?id=<%= userId %>" class="action-btn view-user-btn">
                                    <i class="fas fa-user"></i>
                                    View User Details
                                </a>
                                <form method="post" action="manage_feedback.jsp">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="delete_id" value="<%= feedbackId %>">
                                    <button type="submit" class="action-btn" onclick="return confirm('Are you sure you want to delete this feedback?')">
                                        <i class="fas fa-trash-alt"></i>
                                        Delete
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
            <% } %>

            <% if (totalFeedbacks == 0) { %>
            <div class="empty-state">
                <i class="fas fa-comment"></i>
                <h3>No Feedback Found</h3>
                <p>No feedback entries match the selected filters.</p>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Feedback Management Dashboard loaded successfully');
        });
    </script>
</body>
</html>
<%
    } catch (SQLException e) {
        out.println("<div style='text-align: center; padding: 2rem; background: #fff; border-radius: 12px; margin: 2rem; box-shadow: 0 4px 6px rgba(0,0,0,0.1);'>");
        out.println("<i class='fas fa-exclamation-triangle' style='font-size: 3rem; color: #f44336; margin-bottom: 1rem;'></i>");
        out.println("<h3 style='color: #f44336; margin-bottom: 0.5rem;'>Database Error</h3>");
        out.println("<p style='color: #666;'>Error fetching feedback data: " + e.getMessage() + "</p>");
        out.println("</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
    }
%>