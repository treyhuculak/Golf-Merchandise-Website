<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Forgot Password - The Pro Shop</title>
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
                    <h1 class="text-center mb-4 font-weight-bold">Forgot Password</h1>
                </div>
                <div class="card-body">
                    <p class="text-muted">Enter your username or email address and we'll send you a link to reset your password.</p>
                    
                    <%
                        // Display error/success messages
                        if (session.getAttribute("forgotPasswordMessage") != null) {
                    %>
                        <div class="alert alert-danger">
                            <%= session.getAttribute("forgotPasswordMessage") %>
                        </div>
                    <%
                            session.removeAttribute("forgotPasswordMessage");
                        }
                        
                        if (session.getAttribute("forgotPasswordSuccess") != null) {
                    %>
                        <div class="alert alert-success">
                            <%= session.getAttribute("forgotPasswordSuccess") %>
                        </div>
                    <%
                            session.removeAttribute("forgotPasswordSuccess");
                        }
                    %>
                    
                    <form name="forgotPasswordForm" method="post" action="processForgotPassword.jsp">
                        <div class="form-group">
                            <label for="identifier">Username or Email:</label>
                            <input type="text" class="form-control" id="identifier" name="identifier" required placeholder="Enter your username or email">
                        </div>
                        
                        <button type="submit" class="btn btn-primary btn-block">Send Reset Link</button>
                        
                        <div class="text-center mt-3">
                            <a href="login.jsp" class="text-muted">Back to Login</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
