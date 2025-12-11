<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ include file="jdbc.jsp" %>

<%
    // Check if user is logged in
    String authenticatedUser = (String) session.getAttribute("authenticatedUser");
    if (authenticatedUser == null) {
        // User not logged in - redirect to login required page
        String outfitIdStr = request.getParameter("outfitId");
        response.sendRedirect("loginRequired.jsp?outfitId=" + outfitIdStr);
        return;
    }

    String outfitIdStr = request.getParameter("outfitId");
    if (outfitIdStr == null || outfitIdStr.isEmpty()) {
        response.sendRedirect("outfits.jsp");
        return;
    }

    int outfitId = Integer.parseInt(outfitIdStr);

    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    if (productList == null) {
        productList = new HashMap<String, ArrayList<Object>>();
    }

    try {
        Connection con = getConnection();
        
        // Get outfit name and calculate total price
        String outfitSql = "SELECT outfitName FROM outfit WHERE outfitId = ?";
        PreparedStatement outfitPstmt = con.prepareStatement(outfitSql);
        outfitPstmt.setInt(1, outfitId);
        ResultSet outfitRs = outfitPstmt.executeQuery();
        String outfitName = "";
        if (outfitRs.next()) {
            outfitName = outfitRs.getString("outfitName");
        }

        String productSql = "SELECT SUM(p.productPrice) as totalPrice FROM product p " +
                            "JOIN outfitproduct op ON p.productId = op.productId WHERE op.outfitId = ?";
        PreparedStatement productPstmt = con.prepareStatement(productSql);
        productPstmt.setInt(1, outfitId);
        ResultSet productRs = productPstmt.executeQuery();
        double totalPrice = 0;
        if (productRs.next()) {
            totalPrice = productRs.getDouble("totalPrice");
        }
        
        // Apply 10% discount
        double discountedPrice = totalPrice * 0.9;
        String bundleId = "bundle_" + outfitId;

        if (productList.containsKey(bundleId)) {
            ArrayList<Object> product = productList.get(bundleId);
            int currentQuantity = (Integer) product.get(3);
            product.set(3, currentQuantity + 1);
        } else {
            ArrayList<Object> product = new ArrayList<>();
            product.add(bundleId);
            product.add(outfitName + " (Bundle)");
            product.add(discountedPrice);
            product.add(1); // quantity
            productList.put(bundleId, product);
        }
        
        session.setAttribute("productList", productList);
        
        // Set success message
        session.setAttribute("cartSuccessMessage", outfitName + " Bundle added to cart!");
        
        // Determine where to redirect - avoid login/auth pages
        String referer = request.getHeader("referer");
        String redirectTo = "outfits.jsp"; // default
        
        if (referer != null && !referer.isEmpty()) {
            // Don't redirect back to login or auth pages
            if (!referer.contains("login") && !referer.contains("validateLogin") && 
                !referer.contains("loginRequired") && !referer.contains("register")) {
                redirectTo = referer;
            }
        }
        
        response.sendRedirect(redirectTo);

    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'><strong>Error adding bundle to cart:</strong> " + e.getMessage() + "</div>");
    } finally {
        closeConnection();
    }
%>