<%-- 
    Document   : edit_user
    Created on : 9 Jun 2025, 1:45:00 pm
    Author     : RUSHANG MAHALE
--%>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="db_conn.jsp" %>
<%@include file="navigation_page.html" %>

<%
    String sessionUser = (String) session.getAttribute("username");
    if (sessionUser == null) {
        session.setAttribute("redirectUrl", request.getRequestURI());
        response.sendRedirect("login.jsp");
        return;
    }

    PreparedStatement ps = null;
    ResultSet rs = null;
    int userId = -1;
    String e_username = "", fullname = "", email = "", phone = "", address = "", city = "", pincode = "";
    String hasPets = "", noOfPets = "", noOfFamilyMembers = "", hasAnyAllergy = "", allergyDetails = "";
    String alertMessage = "";
    String alertType = "";

    // Fetch user data
    try {
        // Get user_id and Users data
        String queryUsers = "SELECT user_id, username, fullname, email, phone, address, city, pincode " +
                           "FROM Users WHERE username = ?";
        ps = conn.prepareStatement(queryUsers);
        ps.setString(1, sessionUser);
        rs = ps.executeQuery();
        if (rs.next()) {
            userId = rs.getInt("user_id");
            e_username = rs.getString("username") != null ? rs.getString("username") : "";
            fullname = rs.getString("fullname") != null ? rs.getString("fullname") : "";
            email = rs.getString("email") != null ? rs.getString("email") : "";
            phone = rs.getString("phone") != null ? rs.getString("phone") : "";
            address = rs.getString("address") != null ? rs.getString("address") : "";
            city = rs.getString("city") != null ? rs.getString("city") : "";
            pincode = rs.getString("pincode") != null ? rs.getString("pincode") : "";
        }
        rs.close();
        ps.close();

        // Get Adopters data
        String queryAdopters = "SELECT has_pets, no_of_pets, no_of_family_members, has_any_allergy, allergy_details " +
                              "FROM Adopters WHERE user_id = ?";
        ps = conn.prepareStatement(queryAdopters);
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            hasPets = rs.getString("has_pets") != null ? rs.getString("has_pets") : "";
            noOfPets = rs.getObject("no_of_pets") != null ? rs.getString("no_of_pets") : "";
            noOfFamilyMembers = rs.getObject("no_of_family_members") != null ? rs.getString("no_of_family_members") : "";
            hasAnyAllergy = rs.getString("has_any_allergy") != null ? rs.getString("has_any_allergy") : "";
            allergyDetails = rs.getString("allergy_details") != null ? rs.getString("allergy_details") : "";
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        alertMessage = "Error fetching profile data: " + e.getMessage();
        alertType = "alert-error";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
    }

    // Handle form submission
    if (request.getMethod().equalsIgnoreCase("POST")) {
        try {
            conn.setAutoCommit(false); // Start transaction

            // Get form data
            String newUsername = request.getParameter("username");
            String newFullname = request.getParameter("fullname");
            String newEmail = request.getParameter("email");
            String newPhone = request.getParameter("phone");
            String newAddress = request.getParameter("address");
            String newCity = request.getParameter("city");
            String newPincode = request.getParameter("pincode");
            String newHasPets = request.getParameter("has_pets");
            String newNoOfPets = request.getParameter("no_of_pets");
            String newNoOfFamilyMembers = request.getParameter("no_of_family_members");
            String newHasAnyAllergy = request.getParameter("has_any_allergy");
            String newAllergyDetails = request.getParameter("allergy_details");

            // Validate required fields
            if (newUsername == null || newUsername.trim().isEmpty() ||
                newFullname == null || newFullname.trim().isEmpty() ||
                newEmail == null || newEmail.trim().isEmpty() ||
                newHasPets == null || newHasPets.trim().isEmpty() ||
                newNoOfFamilyMembers == null || newNoOfFamilyMembers.trim().isEmpty() ||
                newHasAnyAllergy == null || newHasAnyAllergy.trim().isEmpty()) {
                throw new Exception("Required fields cannot be empty.");
            }

            // Validate check constraints
            if (newHasPets.equals("No") && newNoOfPets != null && !newNoOfPets.trim().isEmpty()) {
                throw new Exception("Number of pets must be empty if you have no pets.");
            }
            if (newHasPets.equals("Yes") && (newNoOfPets == null || newNoOfPets.trim().isEmpty())) {
                throw new Exception("Number of pets is required if you have pets.");
            }
            if (newHasAnyAllergy.equals("No") && newAllergyDetails != null && !newAllergyDetails.trim().isEmpty()) {
                throw new Exception("Allergy details must be empty if you have no allergies.");
            }
            if (newHasAnyAllergy.equals("Yes") && (newAllergyDetails == null || newAllergyDetails.trim().isEmpty())) {
                throw new Exception("Allergy details are required if you have allergies.");
            }

            // Update Users table
            String updateUsers = "UPDATE Users SET username = ?, fullname = ?, email = ?, phone = ?, " +
                                "address = ?, city = ?, pincode = ? WHERE user_id = ?";
            ps = conn.prepareStatement(updateUsers);
            ps.setString(1, newUsername);
            ps.setString(2, newFullname);
            ps.setString(3, newEmail);
            ps.setString(4, newPhone != null && !newPhone.trim().isEmpty() ? newPhone : null);
            ps.setString(5, newAddress != null && !newAddress.trim().isEmpty() ? newAddress : null);
            ps.setString(6, newCity != null && !newCity.trim().isEmpty() ? newCity : null);
            ps.setString(7, newPincode != null && !newPincode.trim().isEmpty() ? newPincode : null);
            ps.setInt(8, userId);
            int usersUpdated = ps.executeUpdate();
            ps.close();

            if (usersUpdated == 0) {
                throw new Exception("User not found.");
            }

            // Update or insert into Adopters table
            String checkAdopters = "SELECT COUNT(*) FROM Adopters WHERE user_id = ?";
            ps = conn.prepareStatement(checkAdopters);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            rs.next();
            boolean hasAdopterRecord = rs.getInt(1) > 0;
            rs.close();
            ps.close();

            if (hasAdopterRecord) {
                String updateAdopters = "UPDATE Adopters SET has_pets = ?, no_of_pets = ?, no_of_family_members = ?, " +
                                       "has_any_allergy = ?, allergy_details = ? WHERE user_id = ?";
                ps = conn.prepareStatement(updateAdopters);
                ps.setString(1, newHasPets);
                ps.setObject(2, newHasPets.equals("Yes") && newNoOfPets != null && !newNoOfPets.trim().isEmpty() ? Integer.parseInt(newNoOfPets) : null);
                ps.setObject(3, Integer.parseInt(newNoOfFamilyMembers));
                ps.setString(4, newHasAnyAllergy);
                ps.setObject(5, newHasAnyAllergy.equals("Yes") && newAllergyDetails != null && !newAllergyDetails.trim().isEmpty() ? newAllergyDetails : null);
                ps.setInt(6, userId);
                ps.executeUpdate();
                ps.close();
            } else {
                String insertAdopters = "INSERT INTO Adopters (user_id, has_pets, no_of_pets, no_of_family_members, " +
                                        "has_any_allergy, allergy_details) VALUES (?, ?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(insertAdopters);
                ps.setInt(1, userId);
                ps.setString(2, newHasPets);
                ps.setObject(3, newHasPets.equals("Yes") && newNoOfPets != null && !newNoOfPets.trim().isEmpty() ? Integer.parseInt(newNoOfPets) : null);
                ps.setObject(4, Integer.parseInt(newNoOfFamilyMembers));
                ps.setString(5, newHasAnyAllergy);
                ps.setObject(6, newHasAnyAllergy.equals("Yes") && newAllergyDetails != null && !newAllergyDetails.trim().isEmpty() ? newAllergyDetails : null);
                ps.executeUpdate();
                ps.close();
            }

            conn.commit(); // Commit transaction
            session.setAttribute("username", newUsername); // Update session username
            alertMessage = "Profile updated successfully!";
            alertType = "alert-success";

            // Handle redirect
            String redirectUrl = (String) session.getAttribute("redirectUrl");
            if (redirectUrl != null) {
                session.removeAttribute("redirectUrl");
                response.sendRedirect(redirectUrl);
                return;
            } else {
                response.sendRedirect("settings_user.jsp");
                return;
            }
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ignored) {}
            if (e.getMessage().contains("Duplicate entry")) {
                if (e.getMessage().contains("username")) {
                    alertMessage = "Username already exists. Please choose a different username.";
                } else if (e.getMessage().contains("email")) {
                    alertMessage = "Email already exists. Please use a different email.";
                } else {
                    alertMessage = "Error updating profile: " + e.getMessage();
                }
            } else {
                alertMessage = "Error updating profile: " + e.getMessage();
            }
            alertType = "alert-error";
        } catch (Exception e) {
            try { conn.rollback(); } catch (SQLException ignored) {}
            alertMessage = e.getMessage();
            alertType = "alert-error";
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
            try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Adopter Profile</title>
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
            padding-top: 80px;
        }

        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }

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

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
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
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .full-width {
            grid-column: span 2;
        }

        .required {
            color: #e74c3c;
        }

        .form-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 20px;
        }

        .save-btn, .cancel-btn {
            padding: 12px 25px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
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
        }

        .cancel-btn:hover {
            background-color: #636e72;
            transform: translateY(-2px);
        }

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

        .section-header {
            grid-column: span 2;
            margin-top: 20px;
            margin-bottom: 10px;
            padding-bottom: 10px;
            border-bottom: 2px solid #3498db;
            font-size: 20px;
            font-weight: 600;
            color: #2c3e50;
        }

        .section-header:first-child {
            margin-top: 0;
        }

        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .full-width {
                grid-column: span 1;
            }

            .section-header {
                grid-column: span 1;
            }

            .form-buttons {
                flex-direction: column;
            }
        }
    </style>
    <script>
        window.onload = function() {
            <% if (!alertMessage.isEmpty()) { %>
                var alertDiv = document.getElementById('alert-message');
                var alertText = document.getElementById('alert-text');
                alertDiv.classList.add('<%= alertType %>');
                alertText.textContent = '<%= alertMessage %>';
                alertDiv.style.display = 'block';
                setTimeout(function() {
                    alertDiv.style.display = 'none';
                }, 5000);
            <% } %>

            // Enable/disable fields based on has_pets and has_any_allergy
            var hasPetsSelect = document.getElementById('has_pets');
            var noOfPetsInput = document.getElementById('no_of_pets');
            var hasAllergySelect = document.getElementById('has_any_allergy');
            var allergyDetailsTextarea = document.getElementById('allergy_details');

            function toggleDependentFields() {
                noOfPetsInput.disabled = hasPetsSelect.value !== 'Yes';
                if (noOfPetsInput.disabled) noOfPetsInput.value = '';
                allergyDetailsTextarea.disabled = hasAllergySelect.value !== 'Yes';
                if (allergyDetailsTextarea.disabled) allergyDetailsTextarea.value = '';
            }

            hasPetsSelect.addEventListener('change', toggleDependentFields);
            hasAllergySelect.addEventListener('change', toggleDependentFields);
            toggleDependentFields();
        };
    </script>
</head>
<body>
    <div class="container">
        <div class="form-container">
            <h1 class="page-title">Edit Adopter Profile</h1>

            <!-- Alert Messages -->
            <div id="alert-message" class="alert" style="display: none;">
                <span id="alert-text"></span>
            </div>

            <form id="adopter-form" method="post">
                <div class="form-grid">
                    <!-- Personal Information Section -->
                    <div class="section-header">Personal Information</div>
                    
                    <!-- Username -->
                    <div class="form-group">
                        <label for="username">Username <span class="required">*</span></label>
                        <input type="text" id="username" name="username" value="<%= username %>" required>
                    </div>

                    <!-- Full Name -->
                    <div class="form-group">
                        <label for="fullname">Full Name <span class="required">*</span></label>
                        <input type="text" id="fullname" name="fullname" value="<%= fullname %>" required>
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" id="email" name="email" value="<%= email %>" required>
                    </div>

                    <!-- Phone -->
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" value="<%= phone %>">
                    </div>

                    <!-- City -->
                    <div class="form-group">
                        <label for="city">City</label>
                        <input type="text" id="city" name="city" value="<%= city %>">
                    </div>

                    <!-- Pincode -->
                    <div class="form-group">
                        <label for="pincode">Pincode</label>
                        <input type="text" id="pincode" name="pincode" value="<%= pincode %>" maxlength="6">
                    </div>

                    <!-- Address -->
                    <div class="form-group full-width">
                        <label for="address">Address</label>
                        <textarea id="address" name="address"><%= address %></textarea>
                    </div>

                    <!-- Adoption Information Section -->
                    <div class="section-header">Adoption Information</div>

                    <!-- Has Pets -->
                    <div class="form-group">
                        <label for="has_pets">Do you currently have pets? <span class="required">*</span></label>
                        <select id="has_pets" name="has_pets" required>
                            <option value="" <%= hasPets.isEmpty() ? "selected" : "" %>>Select an option</option>
                            <option value="Yes" <%= "Yes".equals(hasPets) ? "selected" : "" %>>Yes</option>
                            <option value="No" <%= "No".equals(hasPets) ? "selected" : "" %>>No</option>
                        </select>
                    </div>

                    <!-- Number of Pets -->
                    <div class="form-group">
                        <label for="no_of_pets">Number of Pets (if yes)</label>
                        <input type="number" id="no_of_pets" name="no_of_pets" value="<%= noOfPets %>" min="0" max="50">
                    </div>

                    <!-- Family Members -->
                    <div class="form-group">
                        <label for="no_of_family_members">Number of Family Members <span class="required">*</span></label>
                        <input type="number" id="no_of_family_members" name="no_of_family_members" value="<%= noOfFamilyMembers %>" min="1" max="20" required>
                    </div>

                    <!-- Has Allergy -->
                    <div class="form-group">
                        <label for="has_any_allergy">Do you have any allergies? <span class="required">*</span></label>
                        <select id="has_any_allergy" name="has_any_allergy" required>
                            <option value="" <%= hasAnyAllergy.isEmpty() ? "selected" : "" %>>Select an option</option>
                            <option value="Yes" <%= "Yes".equals(hasAnyAllergy) ? "selected" : "" %>>Yes</option>
                            <option value="No" <%= "No".equals(hasAnyAllergy) ? "selected" : "" %>>No</option>
                        </select>
                    </div>

                    <!-- Allergy Details -->
                    <div class="form-group full-width">
                        <label for="allergy_details">Allergy Details (if yes)</label>
                        <textarea id="allergy_details" name="allergy_details" placeholder="Please describe your allergies..."><%= allergyDetails %></textarea>
                    </div>
                </div>

                <!-- Form Buttons -->
                <div class="form-buttons">
                    <button type="button" class="cancel-btn" onclick="window.history.back()">Cancel</button>
                    <button type="submit" class="save-btn">Update Profile</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>