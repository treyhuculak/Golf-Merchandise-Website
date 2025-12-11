<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Account - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>
<%@ include file="jdbc.jsp" %>

<%
    String userName = (String) session.getAttribute("authenticatedUser");
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get current customer data
    Connection con = getConnection();
    String sql = "SELECT * FROM customer WHERE userid = ?";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, userName);
    ResultSet rs = ps.executeQuery();
    
    if (!rs.next()) {
        out.println("<div class='alert alert-danger'>Error: Customer not found.</div>");
        rs.close();
        ps.close();
        closeConnection();
        return;
    }
%>

<div class="container mt-5 mb-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow">
                <div class="card-header bg-white">
                    <h1 class="text-center mb-4 font-weight-bold">Edit Your Account</h1>
                </div>
                <div class="card-body">
                    <%
                        // Display error/success messages
                        if (session.getAttribute("editMessage") != null) {
                    %>
                        <div class="alert alert-danger">
                            <%= session.getAttribute("editMessage") %>
                        </div>
                    <%
                            session.removeAttribute("editMessage");
                        }
                        
                        if (session.getAttribute("editSuccess") != null) {
                    %>
                        <div class="alert alert-success">
                            <%= session.getAttribute("editSuccess") %>
                        </div>
                    <%
                            session.removeAttribute("editSuccess");
                        }
                    %>
                    
                    <form name="editForm" method="post" action="processEditAccount.jsp">
                        <h5>Personal Information</h5>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="firstName">First Name: <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="firstName" name="firstName" value="<%= rs.getString("firstName") %>" required maxlength="40">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="lastName">Last Name: <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="lastName" name="lastName" value="<%= rs.getString("lastName") %>" required maxlength="40">
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="email">Email: <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" value="<%= rs.getString("email") %>" required maxlength="50">
                        </div>

                        <div class="form-group">
                            <label for="phonenum">Phone Number: <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="phonenum" name="phonenum" value="<%= rs.getString("phonenum") %>" required maxlength="20">
                        </div>

                        <hr>
                        <h5>Shipping Address</h5>

                        <div class="form-group">
                            <label for="address">Street Address: <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="address" name="address" value="<%= rs.getString("address") %>" required maxlength="50">
                        </div>

                        <%
                            String currentCountry = rs.getString("country");
                            String currentStateValue = rs.getString("state");
                        %>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="country">Country: <span class="text-danger">*</span></label>
                                    <select class="form-control" id="country" name="country" required onchange="updateStates()">
                                        <option value="">-- Select Country --</option>
                                        <option value="Canada" <%= currentCountry != null && currentCountry.equals("Canada") ? "selected" : "" %>>Canada</option>
                                        <option value="United States" <%= currentCountry != null && currentCountry.equals("United States") ? "selected" : "" %>>United States</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="state">State/Province: <span class="text-danger">*</span></label>
                                    <select class="form-control" id="state" name="state" required>
                                        <option value="">-- Select Country First --</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="city">City: <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="city" name="city" value="<%= rs.getString("city") %>" required maxlength="40">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="postalCode">Postal Code: <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="postalCode" name="postalCode" value="<%= rs.getString("postalCode") %>" required maxlength="20">
                                </div>
                            </div>
                        </div>

                        <hr>
                        <h5>Change Password (Optional)</h5>
                        <p class="text-muted small">Leave blank if you don't want to change your password</p>

                        <div class="form-group">
                            <label for="currentPassword">Current Password:</label>
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword" maxlength="30">
                            <small class="form-text text-muted">Required only if changing password</small>
                        </div>

                        <div class="form-group">
                            <label for="newPassword">New Password:</label>
                            <input type="password" class="form-control" id="newPassword" name="newPassword" maxlength="30" minlength="6">
                            <small class="form-text text-muted">Minimum 6 characters</small>
                        </div>

                        <div class="form-group">
                            <label for="confirmNewPassword">Confirm New Password:</label>
                            <input type="password" class="form-control" id="confirmNewPassword" name="confirmNewPassword" maxlength="30">
                        </div>

                        <button type="submit" class="btn btn-primary btn-block">Save Changes</button>
                        
                        <div class="text-center mt-3">
                            <a href="customer.jsp" class="text-muted">Cancel and go back</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
var currentState = '<%= currentStateValue %>';

function updateStates() {
    var country = document.getElementById('country').value;
    var stateSelect = document.getElementById('state');
    
    // Clear existing options
    stateSelect.innerHTML = '<option value="">-- Select State/Province --</option>';
    
    if (country === 'Canada') {
        var provinces = [
            {value: 'AB', text: 'Alberta'},
            {value: 'BC', text: 'British Columbia'},
            {value: 'MB', text: 'Manitoba'},
            {value: 'NB', text: 'New Brunswick'},
            {value: 'NL', text: 'Newfoundland and Labrador'},
            {value: 'NT', text: 'Northwest Territories'},
            {value: 'NS', text: 'Nova Scotia'},
            {value: 'NU', text: 'Nunavut'},
            {value: 'ON', text: 'Ontario'},
            {value: 'PE', text: 'Prince Edward Island'},
            {value: 'QC', text: 'Quebec'},
            {value: 'SK', text: 'Saskatchewan'},
            {value: 'YT', text: 'Yukon'}
        ];
        
        provinces.forEach(function(province) {
            var option = document.createElement('option');
            option.value = province.value;
            option.text = province.text;
            if (province.value === currentState) {
                option.selected = true;
            }
            stateSelect.add(option);
        });
    } else if (country === 'United States') {
        var states = [
            {value: 'AL', text: 'Alabama'},
            {value: 'AK', text: 'Alaska'},
            {value: 'AZ', text: 'Arizona'},
            {value: 'AR', text: 'Arkansas'},
            {value: 'CA', text: 'California'},
            {value: 'CO', text: 'Colorado'},
            {value: 'CT', text: 'Connecticut'},
            {value: 'DE', text: 'Delaware'},
            {value: 'FL', text: 'Florida'},
            {value: 'GA', text: 'Georgia'},
            {value: 'HI', text: 'Hawaii'},
            {value: 'ID', text: 'Idaho'},
            {value: 'IL', text: 'Illinois'},
            {value: 'IN', text: 'Indiana'},
            {value: 'IA', text: 'Iowa'},
            {value: 'KS', text: 'Kansas'},
            {value: 'KY', text: 'Kentucky'},
            {value: 'LA', text: 'Louisiana'},
            {value: 'ME', text: 'Maine'},
            {value: 'MD', text: 'Maryland'},
            {value: 'MA', text: 'Massachusetts'},
            {value: 'MI', text: 'Michigan'},
            {value: 'MN', text: 'Minnesota'},
            {value: 'MS', text: 'Mississippi'},
            {value: 'MO', text: 'Missouri'},
            {value: 'MT', text: 'Montana'},
            {value: 'NE', text: 'Nebraska'},
            {value: 'NV', text: 'Nevada'},
            {value: 'NH', text: 'New Hampshire'},
            {value: 'NJ', text: 'New Jersey'},
            {value: 'NM', text: 'New Mexico'},
            {value: 'NY', text: 'New York'},
            {value: 'NC', text: 'North Carolina'},
            {value: 'ND', text: 'North Dakota'},
            {value: 'OH', text: 'Ohio'},
            {value: 'OK', text: 'Oklahoma'},
            {value: 'OR', text: 'Oregon'},
            {value: 'PA', text: 'Pennsylvania'},
            {value: 'RI', text: 'Rhode Island'},
            {value: 'SC', text: 'South Carolina'},
            {value: 'SD', text: 'South Dakota'},
            {value: 'TN', text: 'Tennessee'},
            {value: 'TX', text: 'Texas'},
            {value: 'UT', text: 'Utah'},
            {value: 'VT', text: 'Vermont'},
            {value: 'VA', text: 'Virginia'},
            {value: 'WA', text: 'Washington'},
            {value: 'WV', text: 'West Virginia'},
            {value: 'WI', text: 'Wisconsin'},
            {value: 'WY', text: 'Wyoming'}
        ];
        
        states.forEach(function(state) {
            var option = document.createElement('option');
            option.value = state.value;
            option.text = state.text;
            if (state.value === currentState) {
                option.selected = true;
            }
            stateSelect.add(option);
        });
    }
}

// Initialize the state dropdown on page load
window.onload = function() {
    updateStates();
};
</script>

<%
    rs.close();
    ps.close();
    closeConnection();
%>

</body>
</html>
