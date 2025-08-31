<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Login</title></head>
<body>
  <h2>Please log in</h2>
  <form action="checkLogin.jsp" method="post">
    <table>
      <tr>
        <td>Email:</td>
        <td><input type="email" name="email" required /></td>
      </tr>
      <tr>
        <td>Password:</td>
        <td><input type="password" name="password" required /></td>
      </tr>
    </table>
    <input type="submit" value="Log In" />
  </form>
</body>
</html>
