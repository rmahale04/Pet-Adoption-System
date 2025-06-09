<%-- 
    Document   : manage_vets
    Created on : 8 Jun 2025, 3:17:34 PM
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

    // Get filter parameters
    String specialization = request.getParameter("specialization");
    String city = request.getParameter("city");
    String area = request.getParameter("area");

    // Build the query dynamically
    StringBuilder query = new StringBuilder("SELECT vet_id, vet_name, photo, email, contact_no, specialization, clinic_name, address, area, city, pincode, available_days, available_time, extra_info FROM Veterinarians WHERE 1=1");
    
    if (specialization != null && !specialization.isEmpty()) {
        query.append(" AND specialization = '").append(specialization).append("'");
    }
    if (city != null && !city.isEmpty()) {
        query.append(" AND city = '").append(city).append("'");
    }
    if (area != null && !area.isEmpty()) {
        query.append(" AND area = '").append(area).append("'");
    }
    query.append(" ORDER BY vet_id ASC");

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
    <title>Vet Management Dashboard</title>
    <!--<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">-->
    <style>
        :root {
            --primary-color: #1a4c96;
            --primary-hover: #2a5ca8;
            --primary-gradient: linear-gradient(135deg, #1a4c96 0%, #2a5ca8 100%);
            --success-color: #4CAF50;
            --warning-color: #ff9800;
            --danger-color: #f44336;
            --vet-color: #42a5f5;
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

        /* Add Vet Button */
        .add-vet-btn {
            background-color: #27ae60;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .add-vet-btn:hover {
            background-color: #219653;
            transform: translateY(-2px);
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

        .section-header.vet-section {
            border-bottom-color: var(--vet-color);
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

        .vet-count {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--vet-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.9rem;
            font-weight: 600;
        }

        .vet-count i {
            font-size: 1rem;
        }

        .vet-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1.5rem;
        }

        .vet-card {
            background: var(--white);
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            transition: all 0.3s ease;
            position: relative;
        }

        .vet-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }

        .vet-card.vet-card {
            border-top: 4px solid var(--vet-color);
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

        .role-badge.vet {
            background: rgba(66, 165, 245, 0.1);
            color: var(--vet-color);
            border: 1px solid rgba(66, 165, 245, 0.2);
        }

        .vet-info h3 {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            margin-right: 80px;
        }

        .card-body {
            padding: 0 1.5rem 1.5rem;
        }

        .vet-details {
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

            .section-header.vet-section {
                flex-direction: column;
                align-items: flex-start;
            }

            .header-right {
                width: 100%;
                justify-content: space-between;
            }

            .vet-grid {
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
            <form method="post" action="manage_vets.jsp">
                <a href="manage_vets.jsp"><i class="fas fa-filter"></i> <strong>Clear all filters</strong></a>

                <h4>Specialization</h4>
                <select name="specialization">
                    <option value="">All specializations</option>
                    <option value="Small Animals">Small Animals</option>
                    <option value="Large Animals">Large Animals</option>
                    <option value="Exotic Pets">Exotic Pets</option>
                    <option value="Avian">Avian</option>
                </select>

                <h4>City</h4>
                <select name="city">
                    <option value="">Select city...</option>
                    <option value="Mumbai">Mumbai</option>
                    <option value="Delhi">Delhi</option>
                    <option value="Bangalore">Bangalore</option>
                    <option value="Ahmedabad">Ahmedabad</option>
                    <option value="Chennai">Chennai</option>
                </select>

                <h4>Area</h4>
                <select name="area">
                    <option value="">Select area...</option>
                    <option value="Navrangpura">Navrangpura</option>
                    <option value="Satellite">Satellite</option>
                    <option value="Vastrapur">Vastrapur</option>
                    <option value="Maninagar">Maninagar</option>
                    <option value="Thaltej">Thaltej</option>
                    <option value="Paldi">Paldi</option>
                    <option value="Bodakdev">Bodakdev</option>
                    <option value="Chandkheda">Chandkheda</option>
                    <option value="Ghatlodia">Ghatlodia</option>
                    <option value="Bapunagar">Bapunagar</option>
                    <option value="Shahibaug">Shahibaug</option>
                </select>

                <button type="submit">Apply Filter</button>
            </form>
        </div>

        <!-- Main Content -->
        <div class="main-content">

            <%
                // Count statistics
                rs.beforeFirst();
                int totalVets = 0;
                
                while (rs.next()) {
                    totalVets++;
                }
            %>

            <!-- Vets Section -->
            <% if (totalVets > 0) { %>
            <div class="section" id="vet-section">
                <div class="section-header vet-section">
                    <div>
                        <i class="fas fa-stethoscope"></i>
                        <h2>Veterinarians</h2>
                    </div>
                    <div class="header-right">
                        <span class="vet-count">
                            <i class="fas fa-stethoscope"></i>
                            <span><%= totalVets %> Vets</span>
                        </span>
                        <a href="add_vet.jsp" class="add-vet-btn">+ Add New Vet</a>
                    </div>
                </div>
                <div class="vet-grid">
                    <%
                        rs.beforeFirst();
                        while (rs.next()) {
                            int vetId = rs.getInt("vet_id");
                            String vetName = rs.getString("vet_name");
                            String email = rs.getString("email");
                            String contactNo = rs.getString("contact_no");
                            String vetSpecialization = rs.getString("specialization");
                            String clinicName = rs.getString("clinic_name");
                            String vetCity = rs.getString("city");
                    %>
                    <div class="vet-card vet-card">
                        <div class="card-header">
                            <div class="role-badge vet">
                                <i class="fas fa-stethoscope"></i> Vet
                            </div>
                            <div class="vet-info">
                                <h3><%= vetName %></h3>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="vet-details">
                                <div class="detail-item">
                                    <i class="fas fa-id-badge"></i>
                                    <span class="label">ID:</span>
                                    <span class="value">#<%= vetId %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-envelope"></i>
                                    <span class="label">Email:</span>
                                    <span class="value"><%= email %></span>
                                </div>
                                <% if (contactNo != null && !contactNo.trim().isEmpty()) { %>
                                <div class="detail-item">
                                    <i class="fas fa-phone"></i>
                                    <span class="label">Phone:</span>
                                    <span class="value"><%= contactNo %></span>
                                </div>
                                <% } %>
                                <% if (vetSpecialization != null && !vetSpecialization.trim().isEmpty()) { %>
                                <div class="detail-item">
                                    <i class="fas fa-briefcase"></i>
                                    <span class="label">Specialization:</span>
                                    <span class="value"><%= vetSpecialization %></span>
                                </div>
                                <% } %>
                                <% if (clinicName != null && !clinicName.trim().isEmpty()) { %>
                                <div class="detail-item">
                                    <i class="fas fa-clinic-medical"></i>
                                    <span class="label">Clinic:</span>
                                    <span class="value"><%= clinicName %></span>
                                </div>
                                <% } %>
                                <% if (vetCity != null && !vetCity.trim().isEmpty()) { %>
                                <div class="detail-item">
                                    <i class="fas fa-map-marker-alt"></i>
                                    <span class="label">City:</span>
                                    <span class="value"><%= vetCity %></span>
                                </div>
                                <% } %>
                            </div>
                            <div class="card-actions">
                                <a href="vet_info.jsp?id=<%= vetId %>" class="action-btn view-btn">
                                    <i class="fas fa-eye"></i>
                                    View Details
                                </a>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
            <% } %>

            <% if (totalVets == 0) { %>
            <div class="empty-state">
                <i class="fas fa-stethoscope"></i>
                <h3>No Vets Found</h3>
                <p>No veterinarians match the selected filters.</p>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Vet Management Dashboard loaded successfully');
        });
    </script>
</body>
</html>
<%
    } catch (SQLException e) {
        out.println("<div style='text-align: center; padding: 2rem; background: #fff; border-radius: 12px; margin: 2rem; box-shadow: 0 4px 6px rgba(0,0,0,0.1);'>");
        out.println("<i class='fas fa-exclamation-triangle' style='font-size: 3rem; color: #f44336; margin-bottom: 1rem;'></i>");
        out.println("<h3 style='color: #f44336; margin-bottom: 0.5rem;'>Database Error</h3>");
        out.println("<p style='color: #666;'>Error fetching vet data: " + e.getMessage() + "</p>");
        out.println("</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
    }
%>