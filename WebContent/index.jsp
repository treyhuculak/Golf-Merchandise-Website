<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>The Pro Shop - Premium Golf Apparel & Equipment</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>

<%@ include file="header.jsp" %>

<!-- Hero Section -->
<div class="hero-section">
    <div class="hero-overlay"></div>
    <div class="hero-content">
        <h1 class="hero-title">
            <span class="green-text">Play Better.</span>
            <span class="yellow-text">Feel Better.</span>
            <span class="white-text">Swing Better.</span>
        </h1>
        <p class="hero-subtitle">Whether you're just starting out or you're a seasoned pro, we have the perfect gear to elevate your game.</p>
        <a href="listprod.jsp" class="btn btn-hero">Up Your Golf Game</a>
    </div>
</div>

<!-- Featured Products Section -->
<div class="products-section">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">Featured Products</h2>
            <p class="section-subtitle">Handpicked excellence for your game</p>
        </div>
    <div class="product-grid">
        <%
            Connection con = null;
            ResultSet rs = null;
            try {
                con = getConnection();
                String sql = "SELECT TOP 8 productId, productName, productPrice, productImageURL, productDesc FROM product";
                PreparedStatement pstmt = con.prepareStatement(sql);
                rs = pstmt.executeQuery();

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
            } catch (SQLException e) {
                out.println("<div class='alert alert-danger'><strong>Error:</strong> " + e.getMessage() + "</div>");
            } finally {
                closeConnection();
            }
        %>
    </div>
</div>

</body>
</html>
