<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Login Required - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container mt-5 mb-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="text-center mb-4">
                <h1 class="text-center mb-4 font-weight-bold">Please Sign In</h1>
                <p class="text-muted">You need to be logged in to add items to your cart</p>
            </div>
            
            <div class="row">
                <!-- Login Card -->
                <div class="col-md-6 mb-4">
                    <div class="card h-100 shadow-sm">
                        <div class="card-body d-flex flex-column">
                            <h4 class="card-title text-center mb-3">Returning Customer</h4>
                            <p class="text-center text-muted mb-4">Sign in with your account</p>
                            <%
                                String productId = request.getParameter("productId");
                                String outfitId = request.getParameter("outfitId");
                                String returnUrl;
                                
                                if (productId != null) {
                                    returnUrl = "addcart.jsp?productId=" + productId;
                                } else if (outfitId != null) {
                                    returnUrl = "addBundle.jsp?outfitId=" + outfitId;
                                } else {
                                    returnUrl = "showcart.jsp";
                                }
                            %>
                            <div class="mt-auto">
                                <a href="login.jsp?returnUrl=<%= java.net.URLEncoder.encode(returnUrl, "UTF-8") %>" class="btn btn-primary btn-block btn-lg">
                                    Log In
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Sign Up Card -->
                <div class="col-md-6 mb-4">
                    <div class="card h-100 shadow-sm">
                        <div class="card-body d-flex flex-column">
                            <h4 class="card-title text-center mb-3">New Customer</h4>
                            <p class="text-center text-muted mb-4">Create a new account to get started</p>
                            <div class="mt-auto">
                                <a href="register.jsp" class="btn btn-success btn-block btn-lg">
                                    Sign Up
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="text-center mt-3">
                <a href="listprod.jsp" class="btn btn-outline-secondary">
                    ← Continue Shopping
                </a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
