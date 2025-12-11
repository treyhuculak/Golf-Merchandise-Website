<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
    String userName = (String) session.getAttribute("authenticatedUser");
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get form parameters
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");
    String address = request.getParameter("address");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String postalCode = request.getParameter("postalCode");
    String country = request.getParameter("country");
    
    // Password change parameters
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    String confirmNewPassword = request.getParameter("confirmNewPassword");

    // Validation flags
    boolean isValid = true;
    String errorMessage = "";

    // Check if all required fields are filled
    if (firstName == null || firstName.trim().isEmpty() ||
        lastName == null || lastName.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        phonenum == null || phonenum.trim().isEmpty() ||
        address == null || address.trim().isEmpty() ||
        city == null || city.trim().isEmpty() ||
        state == null || state.trim().isEmpty() ||
        postalCode == null || postalCode.trim().isEmpty() ||
        country == null || country.trim().isEmpty()) {
        
        isValid = false;
        errorMessage = "All fields are required. Please fill out every field.";
    }

    // Check email contains @
    if (isValid && !email.contains("@")) {
        isValid = false;
        errorMessage = "Please enter a valid email address (must contain @).";
    }

    // Handle password change if user provided any password field
    boolean changingPassword = false;
    if (currentPassword != null && !currentPassword.trim().isEmpty()) {
        changingPassword = true;
        
        // Verify current password
        try {
            Connection con = getConnection();
            String checkPwdSql = "SELECT password FROM customer WHERE userid = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkPwdSql);
            checkStmt.setString(1, userName);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("password");
                if (!dbPassword.equals(currentPassword)) {
                    isValid = false;
                    errorMessage = "Current password is incorrect.";
                }
            }
            
            rs.close();
            checkStmt.close();
            closeConnection();
        } catch (SQLException e) {
            isValid = false;
            errorMessage = "Database error: " + e.getMessage();
        }
        
        // Validate new password
        if (isValid) {
            if (newPassword == null || newPassword.trim().isEmpty()) {
                isValid = false;
                errorMessage = "Please enter a new password.";
            } else if (newPassword.length() < 6) {
                isValid = false;
                errorMessage = "New password must be at least 6 characters long.";
            } else if (confirmNewPassword == null || !newPassword.equals(confirmNewPassword)) {
                isValid = false;
                errorMessage = "New passwords do not match.";
            }
        }
    } else if ((newPassword != null && !newPassword.trim().isEmpty()) || 
               (confirmNewPassword != null && !confirmNewPassword.trim().isEmpty())) {
        isValid = false;
        errorMessage = "Please enter your current password to change your password.";
    }

    // If validation passed, update customer info
    if (isValid) {
        try {
            Connection con = getConnection();
            String updateSql;
            PreparedStatement updateStmt;
            
            if (changingPassword) {
                // Update with new password
                updateSql = "UPDATE customer SET firstName = ?, lastName = ?, email = ?, phonenum = ?, address = ?, city = ?, state = ?, postalCode = ?, country = ?, password = ? WHERE userid = ?";
                updateStmt = con.prepareStatement(updateSql);
                updateStmt.setString(1, firstName);
                updateStmt.setString(2, lastName);
                updateStmt.setString(3, email);
                updateStmt.setString(4, phonenum);
                updateStmt.setString(5, address);
                updateStmt.setString(6, city);
                updateStmt.setString(7, state);
                updateStmt.setString(8, postalCode);
                updateStmt.setString(9, country);
                updateStmt.setString(10, newPassword);
                updateStmt.setString(11, userName);
            } else {
                // Update without changing password
                updateSql = "UPDATE customer SET firstName = ?, lastName = ?, email = ?, phonenum = ?, address = ?, city = ?, state = ?, postalCode = ?, country = ? WHERE userid = ?";
                updateStmt = con.prepareStatement(updateSql);
                updateStmt.setString(1, firstName);
                updateStmt.setString(2, lastName);
                updateStmt.setString(3, email);
                updateStmt.setString(4, phonenum);
                updateStmt.setString(5, address);
                updateStmt.setString(6, city);
                updateStmt.setString(7, state);
                updateStmt.setString(8, postalCode);
                updateStmt.setString(9, country);
                updateStmt.setString(10, userName);
            }
            
            int rowsUpdated = updateStmt.executeUpdate();
            
            updateStmt.close();
            closeConnection();
            
            if (rowsUpdated > 0) {
                // Success! Redirect to customer page
                session.setAttribute("editSuccess", "Account updated successfully!");
                response.sendRedirect("customer.jsp");
            } else {
                session.setAttribute("editMessage", "Failed to update account. Please try again.");
                response.sendRedirect("editAccount.jsp");
            }
            
        } catch (SQLException e) {
            session.setAttribute("editMessage", "Database error: " + e.getMessage());
            response.sendRedirect("editAccount.jsp");
        }
    } else {
        // Validation failed, redirect back with error
        session.setAttribute("editMessage", errorMessage);
        response.sendRedirect("editAccount.jsp");
    }
%>
