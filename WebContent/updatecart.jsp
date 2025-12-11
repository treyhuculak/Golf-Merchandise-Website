<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.IOException" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
    // 1. Retrieve the parameters from the submitted form
    String productId = request.getParameter("productId");
    String quantityStr = request.getParameter("quantity");
    int newQuantity = 0;
    
    // Simple validation
    try {
        newQuantity = Integer.parseInt(quantityStr);
        if (newQuantity < 1) {
            newQuantity = 1; // Ensure quantity is at least 1
        }
    } catch (NumberFormatException e) {
        // Handle error: redirect back with a message or default to 1
        newQuantity = 1;
    }

    // 2. Get the product list from the session
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    if (productList != null && productId != null) {
        // 3. Find the product in the map
        ArrayList<Object> product = productList.get(productId);
        
        if (product != null && product.size() > 3) {
            // 4. Update the quantity (stored at index 3 in the ArrayList)
            product.set(3, newQuantity);
        }
    }
    
    // 5. Redirect back to the shopping cart page
    response.sendRedirect("showcart.jsp");
%>