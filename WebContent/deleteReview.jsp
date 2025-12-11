<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="jdbc.jsp" %>
<%
    try {
        // Check if user is authenticated
        String authenticatedUser = (String) session.getAttribute("authenticatedUser");
        if (authenticatedUser == null) {
            session.setAttribute("errorMessage", "You must be logged in to delete a review.");
            response.sendRedirect("product.jsp?id=" + request.getParameter("productId"));
            return;
        }
        
        // Get parameters
        String reviewId = request.getParameter("reviewId");
        String productId = request.getParameter("productId");
        
        // Validate input
        if (reviewId == null || reviewId.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Review ID is missing.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        if (productId == null || productId.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Product ID is missing.");
            response.sendRedirect("product.jsp");
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
        
        // Check if the review belongs to this user
        String reviewOwnerSql = "SELECT customerId FROM review WHERE reviewId = ? AND productId = ?";
        PreparedStatement reviewOwnerPs = con.prepareStatement(reviewOwnerSql);
        reviewOwnerPs.setString(1, reviewId);
        reviewOwnerPs.setString(2, productId);
        ResultSet reviewOwnerRs = reviewOwnerPs.executeQuery();
        
        if (!reviewOwnerRs.next()) {
            session.setAttribute("errorMessage", "Review not found.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        int reviewOwnerId = reviewOwnerRs.getInt("customerId");
        reviewOwnerRs.close();
        reviewOwnerPs.close();
        
        if (reviewOwnerId != customerId) {
            session.setAttribute("errorMessage", "You can only delete your own reviews.");
            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }
        
        // Delete the review
        String deleteSql = "DELETE FROM review WHERE reviewId = ?";
        PreparedStatement deletePs = con.prepareStatement(deleteSql);
        deletePs.setString(1, reviewId);
        deletePs.executeUpdate();
        deletePs.close();
        
        session.setAttribute("cartSuccessMessage", "Review deleted successfully!");
        response.sendRedirect("product.jsp?id=" + productId);
        
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
