<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%
    // Get the product ID from the request
    String productId = request.getParameter("productId");

    if (productId != null && !productId.isEmpty()) {
        // Get the current list of products from the session
        @SuppressWarnings({"unchecked"})
        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

        if (productList != null) {
            // Remove the product from the list
            productList.remove(productId);
            // Update the session attribute
            session.setAttribute("productList", productList);
        }
    }

    // Redirect back to the shopping cart page
    response.sendRedirect("showcart.jsp");
%>