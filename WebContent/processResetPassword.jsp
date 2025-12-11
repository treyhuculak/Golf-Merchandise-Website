<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
    String token = request.getParameter("token");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");
    
    if (token == null || token.trim().isEmpty()) {
        response.sendRedirect("forgotPassword.jsp");
        return;
    }
    
    // Validation
    boolean isValid = true;
    String errorMessage = "";
    
    if (newPassword == null || newPassword.trim().isEmpty()) {
        isValid = false;
        errorMessage = "Please enter a new password.";
    } else if (newPassword.length() < 6) {
        isValid = false;
        errorMessage = "Password must be at least 6 characters long.";
    } else if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
        isValid = false;
        errorMessage = "Passwords do not match.";
    }
    
    if (!isValid) {
        session.setAttribute("resetPasswordMessage", errorMessage);
        response.sendRedirect("resetPassword.jsp?token=" + token);
        return;
    }
    
    try {
        Connection con = getConnection();
        
        // Verify token is still valid
        String checkSql = "SELECT pr.customerId, pr.expirationTime, pr.used, c.userid FROM passwordReset pr " +
                         "JOIN customer c ON pr.customerId = c.customerId " +
                         "WHERE pr.resetToken = ?";
        PreparedStatement checkStmt = con.prepareStatement(checkSql);
        checkStmt.setString(1, token);
        ResultSet rs = checkStmt.executeQuery();
        
        if (!rs.next()) {
            session.setAttribute("resetPasswordMessage", "Invalid reset token.");
            response.sendRedirect("resetPassword.jsp?token=" + token);
            rs.close();
            checkStmt.close();
            closeConnection();
            return;
        }
        
        int customerId = rs.getInt("customerId");
        long expirationTime = rs.getLong("expirationTime");
        boolean used = rs.getBoolean("used");
        String userid = rs.getString("userid");
        
        rs.close();
        checkStmt.close();
        
        if (used) {
            session.setAttribute("resetPasswordMessage", "This reset link has already been used.");
            response.sendRedirect("resetPassword.jsp?token=" + token);
            closeConnection();
            return;
        }
        
        if (System.currentTimeMillis() > expirationTime) {
            session.setAttribute("resetPasswordMessage", "This reset link has expired.");
            response.sendRedirect("resetPassword.jsp?token=" + token);
            closeConnection();
            return;
        }
        
        // Update password
        String updatePwdSql = "UPDATE customer SET password = ? WHERE customerId = ?";
        PreparedStatement updateStmt = con.prepareStatement(updatePwdSql);
        updateStmt.setString(1, newPassword);
        updateStmt.setInt(2, customerId);
        updateStmt.executeUpdate();
        updateStmt.close();
        
        // Mark token as used
        String markUsedSql = "UPDATE passwordReset SET used = 1 WHERE resetToken = ?";
        PreparedStatement markStmt = con.prepareStatement(markUsedSql);
        markStmt.setString(1, token);
        markStmt.executeUpdate();
        markStmt.close();
        
        closeConnection();
        
        // Success - redirect to login with success message
        session.setAttribute("loginSuccess", "Password reset successfully! Please log in with your new password.");
        response.sendRedirect("login.jsp");
        
    } catch (SQLException e) {
        session.setAttribute("resetPasswordMessage", "Database error: " + e.getMessage());
        response.sendRedirect("resetPassword.jsp?token=" + token);
    }
%>
