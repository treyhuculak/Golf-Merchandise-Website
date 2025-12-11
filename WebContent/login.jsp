<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Login - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>
<%
    // If already logged-in and a returnUrl was provided, redirect there
    String returnUrlParam = request.getParameter("returnUrl");
    if (session.getAttribute("authenticatedUser") != null && returnUrlParam != null && returnUrlParam.length() > 0) {
        response.sendRedirect(returnUrlParam);
        return;
    }
%>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow"> <div class="card-header bg-white">
                    <h1 class="text-center mb-4 font-weight-bold">Member Login</h1>
                </div>
                <div class="card-body">
                    <%
                        // Check if user is already logged in
                        if (session.getAttribute("authenticatedUser") != null) {
                    %>
                        <div class="alert alert-success">
                            You are already logged in as: <strong><%= session.getAttribute("authenticatedUser") %></strong>
                        </div>
                        <a href="logout.jsp" class="btn btn-block btn-secondary">Log out</a>
                    <%
                        } else {
                            // Check for success message (password reset)
                            if (session.getAttribute("loginSuccess") != null) {
                    %>
                        <div class="alert alert-success">
                            <%= session.getAttribute("loginSuccess") %>
                        </div>
                    <%
                                session.removeAttribute("loginSuccess");
                            }
                            
                            // Check for error messages from validateLogin.jsp
                            if (session.getAttribute("loginMessage") != null) {
                    %>
                        <div class="alert alert-danger">
                            <%= session.getAttribute("loginMessage") %>
                        </div>
                    <%
                                session.removeAttribute("loginMessage");
                            }
                    %>
                    <form name="MyForm" method="post" action="validateLogin.jsp">
                        <%
                            // Preserve returnUrl across the login POST
                            if (request.getParameter("returnUrl") != null) {
                        %>
                            <input type="hidden" name="returnUrl" value="<%= request.getParameter("returnUrl") %>">
                        <%
                            }
                        %>
                        <div class="form-group">
                            <label for="username">Username:</label>
                            <input type="text" class="form-control" id="username" name="username" required maxlength="20">
                        </div>
                        <div class="form-group">
                            <label for="password">Password:</label>
                            <input type="password" class="form-control" id="password" name="password" required maxlength="30">
                        </div>
                        <button type="submit" class="btn btn-success btn-block">Log In</button>
                        <div class="text-center mt-3">
                            <a href="forgotPassword.jsp" class="text-muted small">Forgot Password?</a>
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