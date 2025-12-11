<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Pro Shop Looks - The Pro Shop</title>
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
    <h1 class="text-center mb-4 font-weight-bold">Pro Shop Looks</h1>

    <%
        try {
            Connection con = getConnection();
            String outfitSql = "SELECT outfitId, outfitName FROM outfit";
            PreparedStatement outfitPstmt = con.prepareStatement(outfitSql);
            ResultSet outfitRs = outfitPstmt.executeQuery();

            while (outfitRs.next()) {
                int outfitId = outfitRs.getInt("outfitId");
                String outfitName = outfitRs.getString("outfitName");
    %>
    <div class="outfit-card">
        <div class="outfit-card-header">
            <h3 style="color: white"><%= outfitName %></h3>
        </div>
        <div class="outfit-items">
            <%
                String productSql = "SELECT p.productId, p.productName, p.productPrice, p.productImageURL FROM product p " +
                                    "JOIN outfitproduct op ON p.productId = op.productId WHERE op.outfitId = ?";
                PreparedStatement productPstmt = con.prepareStatement(productSql);
                productPstmt.setInt(1, outfitId);
                ResultSet productRs = productPstmt.executeQuery();
                double totalPrice = 0;

                while (productRs.next()) {
                    String productName = productRs.getString("productName");
                    String productImageURL = productRs.getString("productImageURL");
                    double productPrice = productRs.getDouble("productPrice");
                    totalPrice += productPrice;
            %>
            <div class="outfit-item">
                <a href="product.jsp?id=<%= productRs.getInt("productId") %>">
                    <img src="<%= productImageURL %>" alt="<%= productName %>">
                </a>
                <p><strong><a href="product.jsp?id=<%= productRs.getInt("productId") %>" class="product-link"><%= productName %></a></strong></p>
                <p>$<%= String.format("%.2f", productPrice) %></p>
                <a href="addcart.jsp?productId=<%= productRs.getInt("productId") %>" class="btn btn-secondary btn-sm">Add Item</a>
            </div>
            <%
                }
                productRs.close();
                productPstmt.close();
            %>
        </div>
        <div class="outfit-card-footer">
         <p>Total Price: <span style="text-decoration: line-through;">$<%= String.format("%.2f", totalPrice) %></span> <span style="font-weight: bold; color: red;">$<%= String.format("%.2f", totalPrice * 0.9) %></span></p>
            <a href="addBundle.jsp?outfitId=<%= outfitId %>" class="btn btn-primary">Add Look to Cart</a>
        </div>
    </div>
    <%
            }
            outfitRs.close();
            outfitPstmt.close();
            closeConnection();
        } catch (SQLException ex) {
            out.println("<div class='alert alert-danger'><strong>SQLException:</strong> " + ex.getMessage() + "</div>");
        }
    %>
</div>

</body>
</html>