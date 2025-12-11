<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Order History - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <h1 class="text-center mb-4 font-weight-bold">Your Order History</h1>

    <%
        NumberFormat currFormat = NumberFormat.getCurrencyInstance();
        String userId = (String) session.getAttribute("authenticatedUser");
        int customerId = -1;

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            Connection con = getConnection();
            
            // Get customerId from userid
            String sql = "SELECT customerId FROM customer WHERE userid = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                customerId = rs.getInt("customerId");
            } else {
                out.println("<div class='alert alert-warning'>Could not find customer information.</div>");
                return;
            }

            // Get all orders for the customer
            sql = "SELECT orderId, orderDate, totalAmount FROM ordersummary WHERE customerId = ? ORDER BY orderDate DESC";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, customerId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                int orderId = rs.getInt("orderId");
                Date orderDate = rs.getDate("orderDate");
                double totalAmount = rs.getDouble("totalAmount");
    %>
    <div class="card mb-3">
        <div class="card-header">
            <strong>Order #<%= orderId %></strong> | Placed on <%= orderDate %> | Total: <%= currFormat.format(totalAmount) %>
        </div>
        <div class="card-body">
            <h5 class="card-title">Order Details</h5>
            <table class="table table-sm">
                <thead>
                    <tr>
                        <th style="width: 80px;">Image</th>
                        <th>Product Name</th>
                        <th>Quantity</th>
                        <th>Price</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        // Modified query to handle both products and bundles using LEFT JOIN
                        String sql2 = "SELECT op.productId, p.productName, p.productImageURL, op.quantity, op.price " +
                                     "FROM orderproduct op " +
                                     "LEFT JOIN product p ON op.productId = CAST(p.productId AS VARCHAR(20)) " +
                                     "WHERE op.orderId = ?";
                        PreparedStatement pstmt2 = con.prepareStatement(sql2);
                        pstmt2.setInt(1, orderId);
                        ResultSet rs2 = pstmt2.executeQuery();
                        while (rs2.next()) {
                            String productName = rs2.getString("productName");
                            String productId = rs2.getString("productId");
                            String imageURL = rs2.getString("productImageURL");
                            
                            // If productName is null, it's a bundle
                            if (productName == null && productId.startsWith("bundle_")) {
                                // Extract outfit ID from bundle_1 -> 1
                                int outfitId = Integer.parseInt(productId.replace("bundle_", ""));
                                
                                // Get bundle/outfit details
                                String bundleSql = "SELECT outfitName FROM outfit WHERE outfitId = ?";
                                PreparedStatement bundlePs = con.prepareStatement(bundleSql);
                                bundlePs.setInt(1, outfitId);
                                ResultSet bundleRs = bundlePs.executeQuery();
                                
                                if (bundleRs.next()) {
                                    String outfitName = bundleRs.getString("outfitName");
                                    productName = outfitName + " (Bundle)";
                                }
                                bundleRs.close();
                                bundlePs.close();
                                
                                // Get products in the bundle - collect them in a list first
                                String bundleProductsSql = "SELECT p.productName, p.productImageURL FROM outfitproduct op " +
                                                          "JOIN product p ON op.productId = p.productId WHERE op.outfitId = ?";
                                PreparedStatement bundleProdsPs = con.prepareStatement(bundleProductsSql);
                                bundleProdsPs.setInt(1, outfitId);
                                ResultSet bundleProdsRs = bundleProdsPs.executeQuery();
                                
                                // Collect all products into a list
                                java.util.ArrayList<String> bundleProductNames = new java.util.ArrayList<String>();
                                boolean firstProduct = true;
                                while (bundleProdsRs.next()) {
                                    bundleProductNames.add(bundleProdsRs.getString("productName"));
                                    // Get first product image for bundle thumbnail
                                    if (firstProduct && imageURL == null) {
                                        imageURL = bundleProdsRs.getString("productImageURL");
                                        firstProduct = false;
                                    }
                                }
                                bundleProdsRs.close();
                                bundleProdsPs.close();
                    %>
                    <tr>
                        <td>
                            <img src="<%= imageURL != null ? imageURL : "img/placeholder.jpg" %>" 
                                 alt="Bundle" class="img-thumbnail" style="width: 60px; height: 60px; object-fit: cover;">
                        </td>
                        <td>
                            <strong><%= productName %></strong><br>
                            <small class="text-muted">Includes:</small><br>
                            <%
                                // Display all products from the list
                                for (String prodName : bundleProductNames) {
                                    out.println("<small class='text-muted'>• " + prodName + "</small><br>");
                                }
                            %>
                        </td>
                        <td><%= rs2.getInt("quantity") %></td>
                        <td><%= currFormat.format(rs2.getDouble("price")) %></td>
                    </tr>
                    <%
                            } else {
                                // Regular product
                    %>
                    <tr>
                        <td>
                            <img src="<%= imageURL != null ? imageURL : "img/placeholder.jpg" %>" 
                                 alt="<%= productName %>" class="img-thumbnail" style="width: 60px; height: 60px; object-fit: cover;">
                        </td>
                        <td>
                            <a href="product.jsp?id=<%= productId %>" style="text-decoration: none; color: inherit;">
                                <%= productName %>
                            </a>
                        </td>
                        <td><%= rs2.getInt("quantity") %></td>
                        <td><%= currFormat.format(rs2.getDouble("price")) %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>
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

</body>
</html>
