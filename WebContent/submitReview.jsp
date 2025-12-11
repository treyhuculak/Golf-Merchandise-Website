<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="jdbc.jsp" %>
<%
    try {
        // Check if user is authenticated
        String authenticatedUser = (String) session.getAttribute("authenticatedUser");
        if (authenticatedUser == null) {
            session.setAttribute("errorMessage", "You must be logged in to post a review.");
            response.sendRedirect("product.jsp?id=" + request.getParameter("productId"));
            return;
        }
        
        // Get parameters
        String productId = request.getParameter("productId");
        String rating = request.getParameter("ratingValue");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        
        // Validate input
        if (productId == null || productId.trim().isEmpty() ||
            rating == null || rating.trim().isEmpty() ||
            title == null || title.trim().isEmpty() ||
            description == null || description.trim().isEmpty()) {
            session.setAttribute("errorMessage", "All fields are required.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        int ratingValue = Integer.parseInt(rating);
        if (ratingValue < 1 || ratingValue > 5) {
            session.setAttribute("errorMessage", "Rating must be between 1 and 5.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        if (title.length() > 100) {
            session.setAttribute("errorMessage", "Title must be 100 characters or less.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        if (description.length() > 1000) {
            session.setAttribute("errorMessage", "Description must be 1000 characters or less.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        Connection con = getConnection();
        
        // Get customer ID from authenticated user
        String customerIdSql = "SELECT customerId FROM customer WHERE userid = ?";
        PreparedStatement customerPs = con.prepareStatement(customerIdSql);
        customerPs.setString(1, authenticatedUser);
        ResultSet customerRs = customerPs.executeQuery();
        
        int customerId = -1;
        if (customerRs.next()) {
            customerId = customerRs.getInt("customerId");
        } else {
            session.setAttribute("errorMessage", "User not found.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        customerRs.close();
        customerPs.close();
        
        // Check if user has purchased this product
        String purchaseSql = "SELECT COUNT(*) as purchaseCount FROM orderproduct op " +
                            "INNER JOIN ordersummary os ON op.orderId = os.orderId " +
                            "WHERE os.customerId = ? AND op.productId = ?";
        PreparedStatement purchasePs = con.prepareStatement(purchaseSql);
        purchasePs.setInt(1, customerId);
        purchasePs.setString(2, productId);
        ResultSet purchaseRs = purchasePs.executeQuery();
        
        int purchaseCount = 0;
        if (purchaseRs.next()) {
            purchaseCount = purchaseRs.getInt("purchaseCount");
        }
        purchaseRs.close();
        purchasePs.close();
        
        if (purchaseCount == 0) {
            session.setAttribute("errorMessage", "You can only review products you have purchased.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        // Check if user already reviewed this product
        String existingReviewSql = "SELECT COUNT(*) as reviewCount FROM review WHERE customerId = ? AND productId = ?";
        PreparedStatement existingPs = con.prepareStatement(existingReviewSql);
        existingPs.setInt(1, customerId);
        existingPs.setString(2, productId);
        ResultSet existingRs = existingPs.executeQuery();
        
        int reviewCount = 0;
        if (existingRs.next()) {
            reviewCount = existingRs.getInt("reviewCount");
        }
        existingRs.close();
        existingPs.close();
        
        if (reviewCount > 0) {
            session.setAttribute("errorMessage", "You have already reviewed this product.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        // Insert review
        String insertSql = "INSERT INTO review (productId, customerId, rating, title, description, reviewDate) VALUES (?, ?, ?, ?, ?, GETDATE())";
        PreparedStatement insertPs = con.prepareStatement(insertSql);
        insertPs.setString(1, productId);
        insertPs.setInt(2, customerId);
        insertPs.setInt(3, ratingValue);
        insertPs.setString(4, title);
        insertPs.setString(5, description);
        
        insertPs.executeUpdate();
        insertPs.close();
        
        session.setAttribute("cartSuccessMessage", "Review posted successfully!");
        response.sendRedirect("product.jsp?id=" + productId);
        
    } catch (NumberFormatException e) {
        session.setAttribute("errorMessage", "Invalid rating value.");
        response.sendRedirect("product.jsp?id=" + request.getParameter("productId"));
    } catch (SQLException e) {
        session.setAttribute("errorMessage", "Database error: " + e.getMessage());
        response.sendRedirect("product.jsp?id=" + request.getParameter("productId"));
    } catch (Exception e) {
        session.setAttribute("errorMessage", "Error: " + e.getMessage());
        response.sendRedirect("product.jsp?id=" + request.getParameter("productId"));
    } finally {
        closeConnection();
    }
%>