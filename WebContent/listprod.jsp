<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<!DOCTYPE html>
<html>
<head>
    <title>All Products - The Pro Shop</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>

<%@ include file="header.jsp" %>

<% 
// Check for success message
String successMsg = (String) session.getAttribute("cartSuccessMessage");
if (successMsg != null) {
    session.removeAttribute("cartSuccessMessage");
%>
    <div class="alert alert-success alert-dismissible" role="alert" id="successAlert" style="position: fixed; top: 80px; right: 20px; z-index: 9999; min-width: 300px;">
        <strong><%= successMsg %></strong>
        <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
    <script>
        setTimeout(function() {
            var alert = document.getElementById('successAlert');
            if (alert) {
                alert.style.transition = 'opacity 0.5s, transform 0.5s';
                alert.style.opacity = '0';
                alert.style.transform = 'translateX(400px)';
                setTimeout(function() { alert.remove(); }, 500);
            }
        }, 3000);
    </script>
<%
}
%>

<div class="container mt-5">
    <h1 class="text-center mb-4 font-weight-bold">Search Products</h1>
    <form method="get" action="listprod.jsp" class="form-inline justify-content-center mb-4">
        <input type="text" name="productName" class="form-control mr-sm-2" placeholder="Search for products..." size="50">
        <button type="submit" class="btn btn-primary">Search</button>
    </form>

    <div class="product-grid">
        <%
            String name = request.getParameter("productName");
            try {
                Connection con = getConnection();
                String sql = "SELECT productId, productName, productPrice, productImageURL, productDesc FROM product WHERE productName LIKE ?";
                PreparedStatement pstmt = con.prepareStatement(sql);

                if (name == null || name.trim().isEmpty()) {
                    pstmt.setString(1, "%");
                } else {
                    pstmt.setString(1, "%" + name + "%");
                }

                ResultSet rs = pstmt.executeQuery();

                while (rs.next()) {
        %>
        <div class="product-card">
            <a href="product.jsp?id=<%= rs.getInt("productId") %>">
                <img src="<%= rs.getString("productImageURL") %>" alt="<%= rs.getString("productName") %>">
            </a>
            <div class="product-card-body">
                <h5 class="product-card-title">
                    <a href="product.jsp?id=<%= rs.getInt("productId") %>" class="product-link"><%= rs.getString("productName") %></a>
                </h5>
                <p class="product-card-text"><%= rs.getString("productDesc") %></p>
                <p class="product-price">$<%= String.format("%.2f", rs.getDouble("productPrice")) %></p>
                <a href="addcart.jsp?productId=<%= rs.getInt("productId") %>" class="btn btn-primary">Add to Cart</a>
            </div>
        </div>
        <%
                }
            } catch (SQLException ex) {
                out.println("<div class='alert alert-danger'><strong>SQLException:</strong> " + ex.getMessage() + "</div>");
            } finally {
                closeConnection();
            }
        %>
    </div>
</div>

</body>
</html>