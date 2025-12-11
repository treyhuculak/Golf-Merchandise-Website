<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Reset Password - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow">
                <div class="card-header bg-white">
                    <h1 class="text-center mb-4 font-weight-bold">Reset Your Password</h1>
                </div>
                <div class="card-body">
                    <%
                        String token = request.getParameter("token");
                        
                        if (token == null || token.trim().isEmpty()) {
                            out.println("<div class='alert alert-danger'>Invalid reset link.</div>");
                            out.println("<a href='forgotPassword.jsp' class='btn btn-primary'>Request New Link</a>");
                            return;
                        }
                        
                        // Validate token
                        boolean validToken = false;
                        String userid = null;
                        
                        try {
                            Connection con = getConnection();
                            String sql = "SELECT c.userid, pr.expirationTime, pr.used FROM passwordReset pr " +
                                       "JOIN customer c ON pr.customerId = c.customerId " +
                                       "WHERE pr.resetToken = ?";
                            PreparedStatement ps = con.prepareStatement(sql);
                            ps.setString(1, token);
                            ResultSet rs = ps.executeQuery();
                            
                            if (rs.next()) {
                                long expirationTime = rs.getLong("expirationTime");
                                boolean used = rs.getBoolean("used");
                                userid = rs.getString("userid");
                                
                                if (used) {
                                    out.println("<div class='alert alert-danger'>This reset link has already been used.</div>");
                                    out.println("<a href='forgotPassword.jsp' class='btn btn-primary'>Request New Link</a>");
                                } else if (System.currentTimeMillis() > expirationTime) {
                                    out.println("<div class='alert alert-danger'>This reset link has expired.</div>");
                                    out.println("<a href='forgotPassword.jsp' class='btn btn-primary'>Request New Link</a>");
                                } else {
                                    validToken = true;
                                }
                            } else {
                                out.println("<div class='alert alert-danger'>Invalid reset link.</div>");
                                out.println("<a href='forgotPassword.jsp' class='btn btn-primary'>Request New Link</a>");
                            }
                            
                            rs.close();
                            ps.close();
                            closeConnection();
                            
                        } catch (SQLException e) {
                            out.println("<div class='alert alert-danger'>Database error: " + e.getMessage() + "</div>");
                        }
                        
                        if (validToken) {
                    %>
                    
                    <%
                        // Display error/success messages
                        if (session.getAttribute("resetPasswordMessage") != null) {
                    %>
                        <div class="alert alert-danger">
                            <%= session.getAttribute("resetPasswordMessage") %>
                        </div>
                    <%
                            session.removeAttribute("resetPasswordMessage");
                        }
                    %>
                    
                    <p class="text-muted">Enter your new password for account: <strong><%= userid %></strong></p>
                    
                    <form name="resetPasswordForm" method="post" action="processResetPassword.jsp">
                        <input type="hidden" name="token" value="<%= token %>">
                        
                        <div class="form-group">
                            <label for="newPassword">New Password: <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="newPassword" name="newPassword" required minlength="6" maxlength="30">
                            <small class="form-text text-muted">Minimum 6 characters</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password: <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required maxlength="30">
                        </div>
                        
                        <button type="submit" class="btn btn-success btn-block">Reset Password</button>
                        
                        <div class="text-center mt-3">
                            <a href="login.jsp" class="text-muted">Back to Login</a>
                        </div>
                    </form>
                    
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
