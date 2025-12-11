<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<%
    // If user is authenticated, automatically forward to order.jsp with their customerId.
    String authUser = (String) session.getAttribute("authenticatedUser");
    if (authUser != null) {
        try {
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT customerId FROM customer WHERE userid = ?");
            ps.setString(1, authUser);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int custId = rs.getInt("customerId");
                rs.close(); ps.close(); closeConnection();
                response.sendRedirect("order.jsp?customerId=" + custId);
                return;
            }
            rs.close(); ps.close(); closeConnection();
        } catch (Exception e) {
            try { closeConnection(); } catch (Exception ex) {}
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Checkout - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h1 class="text-center mb-4 font-weight-bold">Complete Your Purchase</h1>
                </div>
                <div class="card-body">
                    <p>Please log in with your user id and password to finalize your order.</p>
                    <form method="post" action="validateLogin.jsp">
                        <input type="hidden" name="returnUrl" value="checkout.jsp">
                        <div class="form-group">
                            <label for="username">User ID:</label>
                            <input type="text" class="form-control" id="username" name="username" size="20" required>
                        </div>
                        <div class="form-group">
                            <label for="password">Password:</label>
                            <input type="password" class="form-control" id="password" name="password" size="20" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Log in & Continue</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
