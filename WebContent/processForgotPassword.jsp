<%@ page language="java" import="java.io.*,java.sql.*,java.util.*,javax.mail.*,javax.mail.internet.*"%>
<%@ include file="jdbc.jsp" %>
<%
    String identifier = request.getParameter("identifier");
    
    if (identifier == null || identifier.trim().isEmpty()) {
        session.setAttribute("forgotPasswordMessage", "Please enter your username or email.");
        response.sendRedirect("forgotPassword.jsp");
        return;
    }
    
    identifier = identifier.trim();
    
    try {
        Connection con = getConnection();
        
        // Check if identifier is username or email
        String sql = "SELECT customerId, userid, email, firstName FROM customer WHERE userid = ? OR email = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, identifier);
        ps.setString(2, identifier);
        ResultSet rs = ps.executeQuery();
        
        if (!rs.next()) {
            // Don't reveal if user exists or not for security
            session.setAttribute("forgotPasswordSuccess", "If an account exists with that username or email, you will receive a password reset link shortly.");
            response.sendRedirect("forgotPassword.jsp");
            rs.close();
            ps.close();
            closeConnection();
            return;
        }
        
        int customerId = rs.getInt("customerId");
        String userid = rs.getString("userid");
        String email = rs.getString("email");
        String firstName = rs.getString("firstName");
        
        rs.close();
        ps.close();
        
        // Generate reset token (simple random string for now)
        String resetToken = UUID.randomUUID().toString();
        long expirationTime = System.currentTimeMillis() + (24 * 60 * 60 * 1000); // 24 hours
        
        // Store reset token in database (we need to add a table for this)
        // For now, we'll store it in session for demo purposes
        String createTableSql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='passwordReset' AND xtype='U') " +
                               "CREATE TABLE passwordReset (" +
                               "resetId INT IDENTITY PRIMARY KEY, " +
                               "customerId INT NOT NULL, " +
                               "resetToken VARCHAR(100) NOT NULL, " +
                               "expirationTime BIGINT NOT NULL, " +
                               "used BIT DEFAULT 0, " +
                               "FOREIGN KEY (customerId) REFERENCES customer(customerId))";
        
        Statement stmt = con.createStatement();
        stmt.execute(createTableSql);
        stmt.close();
        
        // Insert reset token
        String insertTokenSql = "INSERT INTO passwordReset (customerId, resetToken, expirationTime) VALUES (?, ?, ?)";
        PreparedStatement tokenStmt = con.prepareStatement(insertTokenSql);
        tokenStmt.setInt(1, customerId);
        tokenStmt.setString(2, resetToken);
        tokenStmt.setLong(3, expirationTime);
        tokenStmt.executeUpdate();
        tokenStmt.close();
        
        // Send email
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
            message.setSubject("Password Reset Request - The Pro Shop");
            
            // Create reset link
            String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + 
                             request.getContextPath() + "/resetPassword.jsp?token=" + resetToken;
            
            String emailContent = "Hello " + firstName + ",\n\n" +
                                "We received a request to reset your password for your The Pro Shop account (username: " + userid + ").\n\n" +
                                "Click the link below to reset your password:\n" +
                                resetLink + "\n\n" +
                                "This link will expire in 24 hours.\n\n" +
                                "If you didn't request this password reset, please ignore this email.\n\n" +
                                "Best regards,\n" +
                                "The Pro Shop Team";
            
            message.setText(emailContent);
            
            Transport.send(message);
            
            session.setAttribute("forgotPasswordSuccess", "Password reset link has been sent to your email address. Please check your inbox.");
            
        } catch (Exception e) {
            // Email sending failed - for development, we'll show the reset link directly
            String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + 
                             request.getContextPath() + "/resetPassword.jsp?token=" + resetToken;
            
            session.setAttribute("forgotPasswordSuccess", 
                "Email service not configured. For testing, use this reset link: <a href='" + resetLink + "' class='alert-link'>" + resetLink + "</a><br><small class='text-muted'>In production, this would be sent via email.</small>");
        }
        
        closeConnection();
        response.sendRedirect("forgotPassword.jsp");
        
    } catch (SQLException e) {
        session.setAttribute("forgotPasswordMessage", "Database error: " + e.getMessage());
        response.sendRedirect("forgotPassword.jsp");
    }
%>
