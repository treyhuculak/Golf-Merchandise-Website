<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Order Confirmation - The Golf Shop</title>
<link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
<link href="css/styles.css" rel="stylesheet">
<style>
    .confirmation-container {
        max-width: 900px;
        margin: 50px auto;
        padding: 30px;
    }
    .success-icon {
        width: 80px;
        height: 80px;
        margin: 0 auto 20px;
        background: #28a745;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .success-icon svg {
        width: 40px;
        height: 40px;
        color: white;
    }
    .order-summary-card {
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        padding: 30px;
        margin-top: 30px;
        border: 1px solid #e9ecef;
    }
    .order-header {
        border-bottom: 2px solid #e9ecef;
        padding-bottom: 20px;
        margin-bottom: 25px;
    }
    .order-info {
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        padding: 20px;
        margin-bottom: 25px;
        border-radius: 6px;
    }
    .order-table {
        margin-top: 20px;
    }
    .order-table th {
        background-color: #f8f9fa;
        font-weight: 600;
        border-top: none;
    }
    .total-row {
        background-color: #f8f9fa;
        font-weight: 600;
        font-size: 1.1rem;
    }
    .action-buttons {
        margin-top: 30px;
        display: flex;
        gap: 15px;
        justify-content: center;
    }
    .error-container {
        max-width: 600px;
        margin: 100px auto;
        text-align: center;
        padding: 30px;
    }
    .error-icon {
        width: 80px;
        height: 80px;
        margin: 0 auto 20px;
        background: #dc3545;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .error-icon svg {
        width: 40px;
        height: 40px;
        color: white;
    }
    .shipping-info {
        background: #f8f9fa;
        border-radius: 6px;
        padding: 20px;
        margin-top: 25px;
    }
    .shipping-info h5 {
        font-size: 1rem;
        font-weight: 600;
        margin-bottom: 15px;
        color: #495057;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<% 
// Get customer id
String custId = request.getParameter("customerId");
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

// Determine if valid customer id was entered
// Determine if there are products in the shopping cart
// If either are not true, display an error message

boolean isNumber = true;

if (custId == null || custId.length() == 0) {
    isNumber = false;
} else {
    for (int i = 0; i < custId.length(); i++) {
        char c = custId.charAt(i);
        if (!Character.isDigit(c)) {
            isNumber = false;
            break;
        }
    }
}

if (!isNumber) {
%>
    <div class="error-container">
        <div class="error-icon">
            <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 16 16">
                <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
            </svg>
        </div>
        <h2>Invalid Customer ID</h2>
        <p class="text-muted">Customer ID must be a valid number.</p>
        <a href="showcart.jsp" class="btn btn-primary mt-3">Return to Cart</a>
    </div>
<%
    return;
}

// verify shopping cart has products
if (productList == null || productList.isEmpty()) {
%>
    <div class="error-container">
        <div class="error-icon">
            <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 16 16">
                <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .491.592l-1.5 8A.5.5 0 0 1 13 12H4a.5.5 0 0 1-.491-.408L2.01 3.607 1.61 2H.5a.5.5 0 0 1-.5-.5zM5 12a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm7 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm-7 1a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
            </svg>
        </div>
        <h2>Empty Cart</h2>
        <p class="text-muted">Your shopping cart is empty.</p>
        <a href="listprod.jsp" class="btn btn-primary mt-3">Start Shopping</a>
    </div>
<%
    return;
}


// Make connection
String url = "jdbc:sqlserver://cosc304-sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String username = "sa";
String password = "304#sa#pw";
NumberFormat currFormat = NumberFormat.getCurrencyInstance();


try (Connection con = DriverManager.getConnection(url, username, password)) {


	// verify if customer id exists in the database

	String sqlCust = "SELECT customerId, firstName, lastName FROM customer WHERE customerId = ?";
	PreparedStatement pstmtCust = con.prepareStatement(sqlCust);
	pstmtCust.setInt(1, Integer.parseInt(custId));
		ResultSet rst = pstmtCust.executeQuery();

	    if (!rst.next()) {
%>
        <div class="error-container">
            <div class="error-icon">
                <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
                    <path d="M2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2zm12 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1v-1c0-1-1-4-6-4s-6 3-6 4v1a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12z"/>
                </svg>
            </div>
            <h2>Customer Not Found</h2>
            <p class="text-muted">The customer ID you entered does not exist in our system.</p>
            <a href="showcart.jsp" class="btn btn-primary mt-3">Return to Cart</a>
        </div>
<%
        return;
    }

	String customerName = rst.getString("firstName") + " " + rst.getString("lastName");


    // save order information to database
    String insertSql = "INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), 0)";
    PreparedStatement pstmtOrder = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);

    pstmtOrder.setInt(1, Integer.parseInt(custId));
    pstmtOrder.executeUpdate();

    // Retrieve auto-generated key "orderId"

    ResultSet keys = pstmtOrder.getGeneratedKeys();
    keys.next();
    int orderId = keys.getInt(1);




// Insert each item into OrderProduct table using OrderId from previous INSERT

double totalAmount = 0.0;

Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
while (iterator.hasNext()) {
    Map.Entry<String, ArrayList<Object>> entry = iterator.next();
    ArrayList<Object> product = entry.getValue();

    Object productIdObj = product.get(0);
    String productId = productIdObj == null ? "" : productIdObj.toString();
    Object productNameObj = product.get(1);
    String productName = productNameObj == null ? "" : productNameObj.toString();
    Object priceObj = product.get(2);
    double price;
    if (priceObj instanceof Number) {
        price = ((Number) priceObj).doubleValue();
    } else {
        price = Double.parseDouble(priceObj.toString());
    }
    Object qtyObj = product.get(3);
    int qty;
    if (qtyObj instanceof Number) {
        qty = ((Number) qtyObj).intValue();
    } else {
        qty = Integer.parseInt(qtyObj.toString());
    }

    // Insert into orderproduct (works for both products and bundles now)
    String insertProdSql = "INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
    PreparedStatement pstmtProd = con.prepareStatement(insertProdSql);

    pstmtProd.setInt(1, orderId);
    pstmtProd.setString(2, productId);
    pstmtProd.setInt(3, qty);
    pstmtProd.setDouble(4, price);

    pstmtProd.executeUpdate();

    totalAmount += qty * price;
}


// Update total amount for order record

String updateSql = "UPDATE ordersummary SET totalAmount = ? WHERE orderId = ?";
PreparedStatement pstmtUpdate = con.prepareStatement(updateSql);

pstmtUpdate.setDouble(1, totalAmount);
pstmtUpdate.setInt(2, orderId);

pstmtUpdate.executeUpdate();



// Print out order summary
%>

<div class="confirmation-container">
    <div class="text-center">
        <div class="success-icon">
            <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 16 16">
                <path d="M12.736 3.97a.733.733 0 0 1 1.047 0c.286.289.29.756.01 1.05L7.88 12.01a.733.733 0 0 1-1.065.02L3.217 8.384a.757.757 0 0 1 0-1.06.733.733 0 0 1 1.047 0l3.052 3.093 5.4-6.425a.247.247 0 0 1 .02-.022Z"/>
            </svg>
        </div>
        <h1 class="mb-2">Order Confirmed!</h1>
        <p class="text-muted">Thank you for your purchase. Your order has been successfully placed.</p>
    </div>

    <div class="order-summary-card">
        <div class="order-header">
            <h3 class="mb-3">Order Summary</h3>
            <div class="order-info">
                <div class="row">
                    <div class="col-md-4">
                        <strong>Order Number:</strong><br>
                        <span class="text-primary">#<%= orderId %></span>
                    </div>
                    <div class="col-md-4">
                        <strong>Customer:</strong><br>
                        <%= customerName %>
                    </div>
                    <div class="col-md-4">
                        <strong>Status:</strong><br>
                        <span class="badge badge-success">Processing</span>
                    </div>
                </div>
            </div>
        </div>

        <table class="table table-hover order-table">
            <thead>
                <tr>
                    <th>Product</th>
                    <th class="text-center">Quantity</th>
                    <th class="text-right">Price</th>
                    <th class="text-right">Subtotal</th>
                </tr>
            </thead>
            <tbody>
<%
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator2 = productList.entrySet().iterator();
    while (iterator2.hasNext()) {
        Map.Entry<String, ArrayList<Object>> entry = iterator2.next();
        ArrayList<Object> product = entry.getValue();

        Object productIdObj2 = product.get(0);
        String productId2 = productIdObj2 == null ? "" : productIdObj2.toString();
        Object productNameObj2 = product.get(1);
        String productName2 = productNameObj2 == null ? "" : productNameObj2.toString();
        Object priceObj2 = product.get(2);
        double price2;
        if (priceObj2 instanceof Number) {
            price2 = ((Number) priceObj2).doubleValue();
        } else {
            price2 = Double.parseDouble(priceObj2.toString());
        }
        Object qtyObj2 = product.get(3);
        int qty2;
        if (qtyObj2 instanceof Number) {
            qty2 = ((Number) qtyObj2).intValue();
        } else {
            qty2 = Integer.parseInt(qtyObj2.toString());
        }
%>
                <tr>
                    <td>
                        <strong><%= productName2 %></strong><br>
                        <small class="text-muted">ID: <%= productId2 %></small>
                    </td>
                    <td class="text-center"><%= qty2 %></td>
                    <td class="text-right"><%= currFormat.format(price2) %></td>
                    <td class="text-right"><%= currFormat.format(qty2 * price2) %></td>
                </tr>
<%
    }
%>
            </tbody>
            <tfoot>
                <tr class="total-row">
                    <td colspan="3" class="text-right">Order Total:</td>
                    <td class="text-right"><%= currFormat.format(totalAmount) %></td>
                </tr>
            </tfoot>
        </table>

        <div class="shipping-info">
            <h5>Order Processing & Delivery</h5>
            <p class="mb-2 text-muted">Your order is being prepared for shipment. You can track your order status in the "View All Orders" section.</p>
            <small class="text-muted">Estimated delivery: 3-5 business days</small>
        </div>

        <div class="action-buttons">
            <a href="listprod.jsp" class="btn btn-primary btn-lg px-5">Continue Shopping</a>
            <a href="listorder.jsp" class="btn btn-outline-secondary btn-lg px-5">View All Orders</a>
        </div>
    </div>
</div>

<%

// Clear cart if order placed successfully

session.removeAttribute("productList");




} catch (SQLException e) {
%>
    <div class="error-container">
        <div class="error-icon">
            <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 16 16">
                <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
            </svg>
        </div>
        <h2>Order Processing Error</h2>
        <p class="text-muted">We encountered an error processing your order. Please try again.</p>
        <p><small class="text-danger"><%= e.getMessage() %></small></p>
        <a href="showcart.jsp" class="btn btn-primary mt-3">Return to Cart</a>
    </div>
<%
}
%>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

</BODY>
</HTML>

