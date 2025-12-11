<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Administrator Page - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="jdbc.jsp" %>
<%@ include file="auth.jsp" %>
<%@ include file="header.jsp" %>

<div class="container mt-5">
    <h1 class="text-center mb-4 font-weight-bold">Daily Order Summary</h1>

    <%
        NumberFormat currFormat = NumberFormat.getCurrencyInstance();
        try {
            Connection con = getConnection();
            String sql = "SELECT CAST(orderDate AS DATE) AS OrderDay, SUM(totalAmount) AS DailyTotal " +
                         "FROM ordersummary " +
                         "GROUP BY CAST(orderDate AS DATE) " +
                         "ORDER BY OrderDay DESC";
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
    %>
    <table class="table table-striped">
        <thead class="thead-dark">
            <tr>
                <th>Order Date</th>
                <th>Total Amount</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (rs.next()) {
                    Date orderDate = rs.getDate("OrderDay");
                    double totalAmount = rs.getDouble("DailyTotal");
            %>
            <tr>
                <td><%= orderDate %></td>
                <td><%= currFormat.format(totalAmount) %></td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>
    <%
        } catch (SQLException e) {
            out.println("<div class='alert alert-danger'><strong>Error:</strong> " + e.getMessage() + "</div>");
        } finally {
            closeConnection();
        }
    %>
</div>

</body>
</html>