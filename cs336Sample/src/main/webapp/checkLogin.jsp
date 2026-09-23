<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
	
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB db = new ApplicationDB();
        connection = db.getConnection();

        boolean valid = false;

        // Check CUSTOMER
        ps = connection.prepareStatement("SELECT * FROM CUSTOMER WHERE email = ? AND password = ?");
        ps.setString(1, email);
        ps.setString(2, password);
        rs = ps.executeQuery();
        if (rs.next()) {
        	HttpSession s = request.getSession(true);
        	s.setAttribute("userEmail", email);
            response.sendRedirect("customerHome.jsp");
            valid = true;
        }

        // Check ADMIN
        if (!valid) {
            ps.close(); rs.close();
            ps = connection.prepareStatement("SELECT * FROM ADMIN WHERE email = ? AND password = ?");
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) {
            	HttpSession s = request.getSession(true);
            	s.setAttribute("userEmail", email);
                response.sendRedirect("adminHome.jsp");
                valid = true;
            }
        }

        // Check CUSTOMERREP
        if (!valid) {
            ps.close(); rs.close();
            ps = connection.prepareStatement("SELECT * FROM CUSTOMERREP WHERE email = ? AND password = ?");
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) {
            	HttpSession s = request.getSession(true);
            	s.setAttribute("userEmail", email);
                response.sendRedirect("repHome.jsp");
                valid = true;
            }
        }

        if (!valid) {
            response.sendRedirect("login.jsp?error=1");
        }

    } catch (Exception e) {
        response.sendRedirect("login.jsp?error=2");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (connection != null) try { connection.close(); } catch (SQLException e) {}
    }
%>
