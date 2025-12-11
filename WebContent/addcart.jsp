<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<%
// Check if user is logged in
String authenticatedUser = (String) session.getAttribute("authenticatedUser");
if (authenticatedUser == null) {
	// User not logged in - redirect to login required page
	String productId = request.getParameter("productId");
	response.sendRedirect("loginRequired.jsp?productId=" + productId);
	return;
}

// Get the current list of products
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null)
{	// No products currently in list.  Create a list.
	productList = new HashMap<String, ArrayList<Object>>();
}

// Add new product selected
// Get product information
String id = request.getParameter("productId");
String name = "";
double price = 0.0;

try {
	Connection con = getConnection();
	String sql = "SELECT productName, productPrice FROM product WHERE productId = ?";
	PreparedStatement pstmt = con.prepareStatement(sql);
	pstmt.setString(1, id);
	ResultSet rs = pstmt.executeQuery();
	if (rs.next()) {
		name = rs.getString("productName");
		price = rs.getDouble("productPrice");
	} else {
		out.println("<div class='alert alert-danger'><strong>Error:</strong> Product not found.</div>");
		return;
	}
} catch (SQLException e) {
	out.println("<div class='alert alert-danger'><strong>Error:</strong> " + e.getMessage() + "</div>");
	return;
} finally {
	closeConnection();
}

// Get quantity from request parameter (from product detail page) or default to 1
String qtyParam = request.getParameter("quantity");
Integer quantity = new Integer(1);
if (qtyParam != null && !qtyParam.isEmpty()) {
	try {
		quantity = Integer.parseInt(qtyParam);
		if (quantity < 1) quantity = 1;
		if (quantity > 99) quantity = 99;
	} catch (NumberFormatException e) {
		quantity = 1;
	}
}

// Store product information in an ArrayList
ArrayList<Object> product = new ArrayList<Object>();
product.add(id);
product.add(name);
product.add(price);
product.add(quantity);

// Update quantity if add same item to order again
if (productList.containsKey(id))
{	product = (ArrayList<Object>) productList.get(id);
	int curAmount = ((Integer) product.get(3)).intValue();
	product.set(3, new Integer(curAmount + quantity.intValue()));
}
else
	productList.put(id,product);

session.setAttribute("productList", productList);

// Set success message
session.setAttribute("cartSuccessMessage", name + " added to cart!");

// Determine where to redirect - avoid login/auth pages
String referer = request.getHeader("referer");
String redirectTo = "listprod.jsp"; // default

if (referer != null && !referer.isEmpty()) {
	// Don't redirect back to login or auth pages
	if (!referer.contains("login") && !referer.contains("validateLogin") && 
	    !referer.contains("loginRequired") && !referer.contains("register")) {
		redirectTo = referer;
	}
}

response.sendRedirect(redirectTo);
%>