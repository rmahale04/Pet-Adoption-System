import java.io.IOException;
import java.security.MessageDigest;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class login_servlet extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/pet_adoption";
    String usernamee = "root";
    String passwordd = "gj@riya01";
    String query = "SELECT * FROM users WHERE username = ? AND password = ?";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String hashedPassword = hashPassword(password);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, usernamee, passwordd);
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, username);
            ps.setString(2, hashedPassword);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                // Login success
                HttpSession session = request.getSession();
                session.setAttribute("username", username);

                if ("admin_1223".equals(username)) {
                    response.sendRedirect("admin_dashboard.jsp");
                } else {
                    response.sendRedirect("view_pet.jsp");
                }
            } else {
                // Login failed
                request.setAttribute("error", "Incorrect Username or Password");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            response.getWriter().println("Error: " + e.getMessage());
        }
    }

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
