<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<body style="font-family: sans-serif; padding: 20px;">

    <h2>Database Connection Diagnostic</h2>
    <hr/>

    <%
        // --- CONFIGURATION ---
        String server   = "cosc304_sqlserver"; 
        String port     = "1433";
        String username = "sa";
        String password = "304#sa#pw";
        
        // JDBC Driver Class
        String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        
        // 1. Load Driver
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            out.println("<h3 style='color:red'>CRITICAL ERROR: Driver Missing</h3>");
            out.println("<p>Could not find class: " + driver + "</p>");
            return; // Stop execution
        }

        // --- ATTEMPT 1: Connect to 'orders' ---
        String targetDB = "orders";
        String urlOrders = "jdbc:sqlserver://" + server + ":" + port + ";databaseName=" + targetDB + ";encrypt=true;trustServerCertificate=true";
        
        Connection con = null;
        
        out.println("<h3>Step 1: Connecting to '" + targetDB + "' database...</h3>");
        
        try {
            con = DriverManager.getConnection(urlOrders, username, password);
            // IF WE GET HERE, IT WORKED
            out.println("<h2 style='color:green'>&#10004; SUCCESS!</h2>");
            out.println("<p>Connected specifically to <b>" + targetDB + "</b>.</p>");
            out.println("<p>The database exists and is ready for your login page.</p>");
            con.close();
        } 
        catch (Exception e) {
            // IF ORDERS FAILED, PRINT ERROR AND TRY MASTER
            out.println("<div style='color:red; border:1px solid red; padding:10px;'>Connection Failed: " + e.getMessage() + "</div>");
            
            out.println("<h3>Step 2: Checking if Server is up (connecting to 'master')...</h3>");
            
            String urlMaster = "jdbc:sqlserver://" + server + ":" + port + ";databaseName=master;encrypt=true;trustServerCertificate=true";
            
            try {
                con = DriverManager.getConnection(urlMaster, username, password);
                // IF WE GET HERE, SERVER IS UP
                out.println("<h2 style='color:orange'>&#9888; PARTIAL SUCCESS</h2>");
                out.println("<p>The Server is running, but the <b>'orders'</b> database is missing.</p>"); 
                out.println("<strong>Fix:</strong> Check your DDL filename in 'WebContent/ddl/'. It must start with 'SQLServer'.");
                con.close();
            } catch (Exception ex2) {
                // IF MASTER FAILS too
                out.println("<h2 style='color:darkred'>&#10006; TOTAL FAILURE</h2>");
                out.println("<p>Could not connect to the server at all. Check if Docker container is running.</p>");
                out.println("Error: " + ex2.getMessage());
            }
        }
    %>

</body>
</html>