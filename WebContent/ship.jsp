<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>Trey and Frasers Grocery Shipment Processing</title>
</head>
<body>
        
<%@ include file="header.jsp" %>

<%

    Connection conn = getConnection();

	// TODO: Get order id
    String orderIdStr = request.getParameter("orderId");

    if (orderIdStr == null) {
        out.println("<h2>No order ID provided.</h2>");
        return;
    }

    int orderId = Integer.parseInt(orderIdStr);

	// TODO: Check if valid order id in database
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    pstmt = conn.prepareStatement(
        "SELECT orderId FROM ordersummary WHERE orderId = ?");
    pstmt.setInt(1, orderId);
    rs = pstmt.executeQuery();

    if (!rs.next()) {
        out.println("<h2>Order does not exist.</h2>");
        return;
    }

	// TODO: Start a transaction (turn-off auto-commit)
	conn.setAutoCommit(false);

	// TODO: Retrieve all items in order with given id
	pstmt = conn.prepareStatement(
        "SELECT productId, quantity FROM orderproduct WHERE orderId = ?");
    pstmt.setInt(1, orderId);
    rs = pstmt.executeQuery();

	ArrayList<int[]> items = new ArrayList<>();
    while (rs.next()) {
        int pid = rs.getInt("productId");
        int qty = rs.getInt("quantity");
        items.add(new int[]{pid, qty});
    }

	// TODO: Create a new shipment record.
	PreparedStatement shipStmt = conn.prepareStatement(
        "INSERT INTO shipment (shipmentDate, shipmentDesc, warehouseId) VALUES (GETDATE(), ?, 1)");
    shipStmt.setString(1, "Shipment for Order " + orderId);
    shipStmt.executeUpdate();

	// TODO: For each item verify sufficient quantity available in warehouse 1.
	boolean enough = true;
    int failedProduct = -1;

    for (int[] item : items) {
        int pid = item[0];
        int needed = item[1];

        PreparedStatement invCheck = conn.prepareStatement(
            "SELECT quantity FROM productinventory WHERE productId = ? AND warehouseId = 1");
        invCheck.setInt(1, pid);
        ResultSet rs2 = invCheck.executeQuery();

        if (!rs2.next()) {
            enough = false;
            failedProduct = pid;
            break;
        }

        int currentQty = rs2.getInt("quantity");

        if (currentQty < needed) {
            enough = false;
            failedProduct = pid;
            break;
        }
    }

	// TODO: If any item does not have sufficient inventory, cancel transaction and rollback. Otherwise, update inventory for each item.
    if (!enough) {
        conn.rollback();

        // FAILURE GRID (added)
        out.println("<h2>Shipment Not Completed</h2>");
        out.println("<table border='1' cellpadding='6' cellspacing='0'>");
        out.println("<tr><td><b>Order ID</b></td><td>" + orderId + "</td></tr>");
        out.println("<tr><td><b>Problem Product</b></td><td>" + failedProduct + "</td></tr>");
        out.println("<tr><td><b>Reason</b></td><td>Insufficient inventory</td></tr>");
        out.println("</table>");

        conn.setAutoCommit(true);
        return;
    }

    // Update inventory for each item
    out.println("<h2>Shipment Successfully Processed</h2>");

    // SUCCESS GRID (added)
    out.println("<table border='1' cellpadding='6' cellspacing='0'>");
    out.println("<tr>");
    out.println("<th>Product ID</th>");
    out.println("<th>Quantity Shipped</th>");
    out.println("<th>Previous Inventory</th>");
    out.println("<th>New Inventory</th>");
    out.println("</tr>");

	for (int[] item : items) {
        int pid = item[0];
        int needed = item[1];

        // Get current inventory
        PreparedStatement invQ = conn.prepareStatement(
            "SELECT quantity FROM productinventory WHERE productId = ? AND warehouseId = 1");
        invQ.setInt(1, pid);
        ResultSet rs2 = invQ.executeQuery();
        rs2.next();
        int prev = rs2.getInt("quantity");
        int newQty = prev - needed;

        // Update db
        PreparedStatement update = conn.prepareStatement(
            "UPDATE productinventory SET quantity = ? WHERE productId = ? AND warehouseId = 1");
        update.setInt(1, newQty);
        update.setInt(2, pid);
        update.executeUpdate();

        // Table row for this product
        out.println("<tr>");
        out.println("<td>" + pid + "</td>");
        out.println("<td>" + needed + "</td>");
        out.println("<td>" + prev + "</td>");
        out.println("<td>" + newQty + "</td>");
        out.println("</tr>");
    }

    out.println("</table>");

	// TODO: Auto-commit should be turned back on
	conn.commit();
    conn.setAutoCommit(true);

    closeConnection();
%>

<h2><a href="shop.html">Back to Main Page</a></h2>

</body>
</html>
