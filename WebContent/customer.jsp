<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>My Account - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<%
    String userName = (String) session.getAttribute("authenticatedUser");
%>

<div class="container mt-5 mb-5">
    <%
    if (userName == null) {
        out.println("<div class='alert alert-warning'><strong>Error:</strong> You must be logged in to view this page.</div>");
        out.println("<a href='login.jsp' class='btn btn-primary'>Go to Login</a>");
    } else {
        // Get connection using jdbc.jsp helper
        Connection con = getConnection();

        String sql = "SELECT * FROM customer WHERE userid = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, userName);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
    %>
    
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="text-center mb-4 font-weight-bold">My Account</h1>
            <p class="text-muted">View and manage your account information</p>
            <%
                // Display success message if account was updated
                if (session.getAttribute("editSuccess") != null) {
            %>
                <div class="alert alert-success">
                    <%= session.getAttribute("editSuccess") %>
                </div>
            <%
                    session.removeAttribute("editSuccess");
                }
            %>
        </div>
    </div>

    <!-- Account Information Card -->
    <div class="row">
        <div class="col-md-8">
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-white">
                    <h5 class="mb-0">Personal Information</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="text-muted small">First Name</label>
                            <p class="font-weight-bold"><%= rs.getString("firstName") %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="text-muted small">Last Name</label>
                            <p class="font-weight-bold"><%= rs.getString("lastName") %></p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="text-muted small">Email</label>
                            <p class="font-weight-bold"><%= rs.getString("email") %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="text-muted small">Phone Number</label>
                            <p class="font-weight-bold"><%= rs.getString("phonenum") %></p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm mb-4">
                <div class="card-header bg-white">
                    <h5 class="mb-0">Shipping Address</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="text-muted small">Street Address</label>
                        <p class="font-weight-bold"><%= rs.getString("address") %></p>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="text-muted small">City</label>
                            <p class="font-weight-bold"><%= rs.getString("city") %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="text-muted small">State/Province</label>
                            <p class="font-weight-bold"><%= rs.getString("state") %></p>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <label class="text-muted small">Postal Code</label>
                            <p class="font-weight-bold"><%= rs.getString("postalCode") %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="text-muted small">Country</label>
                            <p class="font-weight-bold"><%= rs.getString("country") %></p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm mb-4">
                <div class="card-header bg-white">
                    <h5 class="mb-0">Login Information</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <label class="text-muted small">Username</label>
                            <p class="font-weight-bold"><%= userName %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="text-muted small">Password</label>
                            <p class="font-weight-bold">••••••••</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Sidebar Actions -->
        <div class="col-md-4">
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h6 class="card-title">Quick Actions</h6>
                    <div class="d-grid gap-2">
                        <a href="editAccount.jsp" class="btn btn-outline-primary btn-block mb-2">
                            Edit Account Information
                        </a>
                        <a href="listorder.jsp" class="btn btn-outline-secondary btn-block mb-2">
                            View Order History
                        </a>
                        <a href="listprod.jsp" class="btn btn-outline-success btn-block mb-2">
                            Continue Shopping
                        </a>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-light">
                <div class="card-body text-center">
                    <p class="text-muted small mb-2">Need Help?</p>
                    <a href="index.jsp" class="btn btn-link btn-sm">Contact Support</a>
                </div>
            </div>
        </div>
    </div>

    <%
        }
        rs.close();
        ps.close();
        closeConnection();
    }
    %>
</div>

</body>
</html>