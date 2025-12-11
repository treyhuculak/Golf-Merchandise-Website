<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Your Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .remove-btn {
            color: red;
            text-decoration: none;
            font-weight: bold;
        }
    </style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container mt-5">
<%
    // Get the current list of products
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    if (productList == null || productList.isEmpty()) { 
%>
    <div class="text-center" style="padding: 80px 20px;">
        <div style="width: 100px; height: 100px; margin: 0 auto 30px; background: #dc3545; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
            <svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" fill="white" viewBox="0 0 16 16">
                <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .491.592l-1.5 8A.5.5 0 0 1 13 12H4a.5.5 0 0 1-.491-.408L2.01 3.607 1.61 2H.5a.5.5 0 0 1-.5-.5zM5 12a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm7 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm-7 1a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
            </svg>
        </div>
        <h2 class="mb-3">Your Shopping Cart is Empty</h2>
        <p class="text-muted mb-4">Looks like you haven't added any items to your cart yet.</p>
        <a href="listprod.jsp" class="btn btn-primary btn-lg px-5">Start Shopping</a>
    </div>
<%
    } else {
        NumberFormat currFormat = NumberFormat.getCurrencyInstance();
%>
    <h1 class="text-center mb-4 font-weight-bold">Your Shopping Cart</h1>
    <table class="table table-hover">
        <thead class="thead-dark">
            <tr>
                <th style="width: 100px;">Image</th>
                <th>Product Name</th>
                <th class="text-center">Quantity</th>
                <th class="text-right">Price</th>
                <th class="text-right">Subtotal</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
<%
        double total = 0;
        Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator(); 
        while (iterator.hasNext()) {
            Map.Entry<String, ArrayList<Object>> entry = iterator.next();
            ArrayList<Object> product = (ArrayList<Object>) entry.getValue(); 
            if (product.size() < 4) {
                out.println("<tr><td colspan='6' class='text-danger'>Error: Invalid product data. " + product + "</td></tr>");
                continue; 
            }
            
            String productId = String.valueOf(product.get(0)); 
            double pr = 0;
            int qty = 0;
            
            try {
                pr = Double.parseDouble(product.get(2).toString()); 
            } catch (Exception e) {
                out.println("Invalid price for product: " + productId + " price: " + product.get(2)); 
            } 
            try {
                qty = Integer.parseInt(product.get(3).toString()); 
            } catch (Exception e) {
                out.println("Invalid quantity for product: " + productId + " quantity: " + product.get(3));
            } 
            
            double subtotal = pr * qty; 
            total += subtotal;
            
            // Get product image(s)
            String imageURL = null;
            String bundleDetails = "";
            java.util.ArrayList<String> bundleImages = new java.util.ArrayList<String>();
            
            if (productId.startsWith("bundle_")) {
                // It's a bundle - get outfit details
                int outfitId = Integer.parseInt(productId.replace("bundle_", ""));
                try {
                    Connection con = getConnection();
                    String bundleSql = "SELECT p.productImageURL, p.productName FROM outfitproduct op " +
                                      "JOIN product p ON op.productId = p.productId WHERE op.outfitId = ? ORDER BY op.productId";
                    PreparedStatement bundlePs = con.prepareStatement(bundleSql);
                    bundlePs.setInt(1, outfitId);
                    ResultSet bundleRs = bundlePs.executeQuery();
                    
                    bundleDetails = "<small class='text-muted'>Includes: ";
                    while (bundleRs.next()) {
                        String imgUrl = bundleRs.getString("productImageURL");
                        if (imgUrl != null) {
                            bundleImages.add(imgUrl);
                        }
                        bundleDetails += bundleRs.getString("productName") + ", ";
                    }
                    bundleDetails = bundleDetails.substring(0, bundleDetails.length() - 2) + "</small>";
                    bundleRs.close();
                    bundlePs.close();
                    closeConnection();
                } catch (Exception e) {
                    bundleDetails = "<small class='text-muted'>Bundle</small>";
                }
            } else {
                // Regular product - get image from database
                try {
                    Connection con = getConnection();
                    String imageSql = "SELECT productImageURL FROM product WHERE productId = ?";
                    PreparedStatement imagePs = con.prepareStatement(imageSql);
                    imagePs.setInt(1, Integer.parseInt(productId));
                    ResultSet imageRs = imagePs.executeQuery();
                    if (imageRs.next()) {
                        imageURL = imageRs.getString("productImageURL");
                    }
                    imageRs.close();
                    imagePs.close();
                    closeConnection();
                } catch (Exception e) {
                    // No image available
                }
            }
%>
            <tr>
                <td>
                    <% if (productId.startsWith("bundle_") && bundleImages.size() > 0) { %>
                        <!-- Show all bundle product images horizontally -->
                        <div style="display: flex; gap: 4px; flex-direction: row;">
                            <% for (String img : bundleImages) { %>
                                <img src="<%= img %>" 
                                     alt="Bundle Item" class="img-thumbnail" 
                                     style="width: 50px; height: 50px; object-fit: cover; flex-shrink: 0;">
                            <% } %>
                        </div>
                    <% } else { %>
                        <!-- Single product image -->
                        <img src="<%= imageURL != null ? imageURL : "img/placeholder.jpg" %>" 
                             alt="Product" class="img-thumbnail" style="width: 80px; height: 80px; object-fit: cover;">
                    <% } %>
                </td>
                <td>
                    <% if (productId.startsWith("bundle_")) { %>
                        <!-- Bundle - no link since bundles don't have detail pages -->
                        <strong><%= product.get(1) %></strong>
                        <br><%= bundleDetails %>
                        <br><small class="text-success"><strong>10% bundle discount applied</strong></small>
                    <% } else { %>
                        <!-- Regular product with link -->
                        <a href="product.jsp?id=<%= productId %>" style="text-decoration: none; color: inherit;">
                            <strong><%= product.get(1) %></strong>
                        </a>
                    <% } %>
                </td>
                <td class="text-center">
                    <form action="updatecart.jsp" method="post" id="qtyForm_<%= productId %>">
                        <input type="hidden" name="productId" value="<%= productId %>">
                        <input 
                            type="number" 
                            name="quantity" 
                            value="<%= qty %>" 
                            min="1" 
                            style="width: 60px; text-align: center;"
                            class="form-control form-control-sm mx-auto"
                            onkeypress="return submitOnEnter(event, 'qtyForm_<%= productId %>');"
                            onblur="document.getElementById('qtyForm_<%= productId %>').submit();"
                        >
                    </form>
                </td>
                <td class="text-right"><%= currFormat.format(pr) %></td>
                <td class="text-right"><strong><%= currFormat.format(subtotal) %></strong></td> 
                <td><a href="removecart.jsp?productId=<%= productId %>" class="btn btn-sm btn-danger">Remove</a></td>
            </tr>
<%
        }
%>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="4" class="text-right"><strong>Order Total</strong></td>
                <td class="text-right"><strong><%= currFormat.format(total) %></strong></td> 
                <td></td>
            </tr>
        </tfoot>
    </table>

    <div class="text-center mt-4">
        <a href="checkout.jsp" class="btn btn-primary">Check Out</a>
    </div>
<%
    }
%>
</div>

<script>
    function submitOnEnter(event, formId) {
        // Check if the key pressed is the Enter key (key code 13)
        if (event.keyCode === 13) {
            // Prevent the default action (which might be inserting a newline)
            event.preventDefault(); 
            // Submit the form
            document.getElementById(formId).submit();
            return false; // Stop further processing
        }
        return true; // Allow other keys
    }
</script>

</body>
</html>