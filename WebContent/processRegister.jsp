<%@ page language="java" import="java.io.*,java.sql.*,java.util.*,javax.mail.*,javax.mail.internet.*"%>
<%@ include file="jdbc.jsp" %>
<%
    // Get form parameters
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");
    String address = request.getParameter("address");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String postalCode = request.getParameter("postalCode");
    String country = request.getParameter("country");
    String userid = request.getParameter("userid");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");

    // Validation flags
    boolean isValid = true;
    String errorMessage = "";

    // Check if all fields are filled
    if (firstName == null || firstName.trim().isEmpty() ||
        lastName == null || lastName.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        phonenum == null || phonenum.trim().isEmpty() ||
        address == null || address.trim().isEmpty() ||
        city == null || city.trim().isEmpty() ||
        state == null || state.trim().isEmpty() ||
        postalCode == null || postalCode.trim().isEmpty() ||
        country == null || country.trim().isEmpty() ||
        userid == null || userid.trim().isEmpty() ||
        password == null || password.trim().isEmpty() ||
        confirmPassword == null || confirmPassword.trim().isEmpty()) {
        
        isValid = false;
        errorMessage = "All fields are required. Please fill out every field.";
    }

    // Check email contains @
    if (isValid && !email.contains("@")) {
        isValid = false;
        errorMessage = "Please enter a valid email address (must contain @).";
    }

    // Check password minimum length (6 characters)
    if (isValid && password.length() < 6) {
        isValid = false;
        errorMessage = "Password must be at least 6 characters long.";
    }

    // Check passwords match
    if (isValid && !password.equals(confirmPassword)) {
        isValid = false;
        errorMessage = "Passwords do not match. Please try again.";
    }

    // Check if userid already exists
    if (isValid) {
        try {
            Connection con = getConnection();
            String checkSql = "SELECT userid FROM customer WHERE userid = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, userid);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                isValid = false;
                errorMessage = "Username '" + userid + "' is already taken. Please choose a different username.";
            }
            
            rs.close();
            checkStmt.close();
            closeConnection();
        } catch (SQLException e) {
            isValid = false;
            errorMessage = "Database error: " + e.getMessage();
        }
    }

    // If validation passed, insert new customer
    if (isValid) {
        try {
            Connection con = getConnection();
            String insertSql = "INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement insertStmt = con.prepareStatement(insertSql);
            
            insertStmt.setString(1, firstName);
            insertStmt.setString(2, lastName);
            insertStmt.setString(3, email);
            insertStmt.setString(4, phonenum);
            insertStmt.setString(5, address);
            insertStmt.setString(6, city);
            insertStmt.setString(7, state);
            insertStmt.setString(8, postalCode);
            insertStmt.setString(9, country);
            insertStmt.setString(10, userid);
            insertStmt.setString(11, password);
            
            int rowsInserted = insertStmt.executeUpdate();
            
            insertStmt.close();
            closeConnection();
            
            if (rowsInserted > 0) {
                // Success! Try to send welcome email
                try {
                    // Email configuration - using Gmail SMTP
                    String smtpHost = "smtp.gmail.com";
                    String smtpPort = "587";
                    String senderEmail = "theproshop304@gmail.com";
                    String senderPassword = "rszfwnjahknizsvz";
                    
                    Properties props = new Properties();
                    props.put("mail.smtp.host", smtpHost);
                    props.put("mail.smtp.port", smtpPort);
                    props.put("mail.smtp.auth", "true");
                    props.put("mail.smtp.starttls.enable", "true");
                    
                    Session mailSession = Session.getInstance(props, new Authenticator() {
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(senderEmail, senderPassword);
                        }
                    });
                    
                    Message message = new MimeMessage(mailSession);
                    message.setFrom(new InternetAddress(senderEmail, "The Pro Shop"));
                    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
                    message.setSubject("Welcome to The Pro Shop!");
                    
                    String emailContent = "Hello " + firstName + " " + lastName + ",\n\n" +
                                        "Welcome to The Pro Shop!\n\n" +
                                        "Your account has been successfully created with the following details:\n" +
                                        "Username: " + userid + "\n" +
                                        "Email: " + email + "\n\n" +
                                        "You can now log in and start shopping for premium sports gear.\n\n" +
                                        "Thank you for joining us!\n\n" +
                                        "Best regards,\n" +
                                        "The Pro Shop Team";
                    
                    message.setText(emailContent);
                    
                    Transport.send(message);
                    
                } catch (Exception e) {
                    // Email failed but registration succeeded - just log it
                    System.out.println("Failed to send welcome email: " + e.getMessage());
                }
                
                // Redirect to login page
                session.setAttribute("registerSuccess", "Account created successfully! Please log in with your new credentials.");
                response.sendRedirect("login.jsp");
            } else {
                session.setAttribute("registerMessage", "Failed to create account. Please try again.");
                response.sendRedirect("register.jsp");
            }
            
        } catch (SQLException e) {
            session.setAttribute("registerMessage", "Database error: " + e.getMessage());
            response.sendRedirect("register.jsp");
        }
    } else {
        // Validation failed, redirect back with error
        session.setAttribute("registerMessage", errorMessage);
        response.sendRedirect("register.jsp");
    }
%>
