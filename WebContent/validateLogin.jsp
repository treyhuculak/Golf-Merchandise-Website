<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
	String authenticatedUser = null;
	session = request.getSession(true);

	try
	{
		authenticatedUser = validateLogin(out,request,session);
	}
	catch(IOException e)
	{	System.err.println(e); }

	// handle optional returnUrl redirection
	String returnUrl = request.getParameter("returnUrl");
	if(authenticatedUser != null) {
		if(returnUrl != null && !returnUrl.equals("")) {
			response.sendRedirect(returnUrl);
		} else {
			response.sendRedirect("index.jsp");
		}
	} else {
		if(returnUrl != null && !returnUrl.equals("")) {
			response.sendRedirect("login.jsp?returnUrl=" + java.net.URLEncoder.encode(returnUrl, "UTF-8"));
		} else {
			response.sendRedirect("login.jsp");
		}
	}

%>
<%!
	String validateLogin(JspWriter out,HttpServletRequest request, HttpSession session) throws IOException
	{
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String retStr = null;

		if(username == null || password == null)
				return null;
		if((username.length() == 0) || (password.length() == 0))
				return null;

		try 
		{
			Connection con = getConnection();
			
			// TODO: Check if userId and password match some customer account. If so, set retStr to be the username.
			String sql = "SELECT userid FROM customer WHERE userid = ? AND password = ?";
			PreparedStatement pstmt = con.prepareStatement(sql);
			pstmt.setString(1, username);
			pstmt.setString(2, password);

			ResultSet rst = pstmt.executeQuery();

			if (rst.next()) {
				retStr = rst.getString("userid");
			}
		} 
		catch (SQLException ex) {
			out.println(ex);
		}
		finally
		{
			closeConnection();
		}	
		
		if(retStr != null)
		{	session.removeAttribute("loginMessage");
			session.setAttribute("authenticatedUser",username);
		}
		else
			session.setAttribute("loginMessage","Could not connect to the system using that username/password.");

		return retStr;
	}
%>

