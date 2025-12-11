<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Sign Up - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow">
                <div class="card-header bg-white">
                    <h1 class="text-center mb-4 font-weight-bold">Create Your Account</h1>
                </div>
                <div class="card-body">
                    <%
                        // Display error message if registration failed
                        if (session.getAttribute("registerMessage") != null) {
                    %>
                        <div class="alert alert-danger">
                            <%= session.getAttribute("registerMessage") %>
                        </div>
                    <%
                            session.removeAttribute("registerMessage");
                        }
                        
                        // Display success message
                        if (session.getAttribute("registerSuccess") != null) {
                    %>
                        <div class="alert alert-success">
                            <%= session.getAttribute("registerSuccess") %>
                            <a href="login.jsp">Click here to login</a>
                        </div>
                    <%
                            session.removeAttribute("registerSuccess");
                        }
                    %>
                    
                    <form name="registerForm" method="post" action="processRegister.jsp">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="firstName">First Name: <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="firstName" name="firstName" required maxlength="40">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="lastName">Last Name: <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="lastName" name="lastName" required maxlength="40">
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="email">Email: <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" required maxlength="50">
                        </div>

                        <div class="form-group">
                            <label for="phonenum">Phone Number: <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="phonenum" name="phonenum" required maxlength="20">
                        </div>

                        <div class="form-group">
                            <label for="address">Street Address: <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="address" name="address" required maxlength="50">
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="country">Country: <span class="text-danger">*</span></label>
                                    <select class="form-control" id="country" name="country" required onchange="updateStates()">
                                        <option value="">-- Select Country --</option>
                                        <option value="Canada">Canada</option>
                                        <option value="United States">United States</option>
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
                                    <input type="text" class="form-control" id="city" name="city" required maxlength="40">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="postalCode">Postal Code: <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="postalCode" name="postalCode" required maxlength="20">
                                </div>
                            </div>
                        </div>

                        <script>
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
                                    stateSelect.add(option);
                                });
                            }
                        }
                        </script>

                        <hr>
                        <h5>Login Credentials</h5>

                        <div class="form-group">
                            <label for="userid">Username: <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="userid" name="userid" required maxlength="20">
                            <small class="form-text text-muted">Choose a unique username</small>
                        </div>

                        <div class="form-group">
                            <label for="password">Password: <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="password" name="password" required maxlength="30" minlength="6">
                            <small class="form-text text-muted">Minimum 6 characters</small>
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword">Confirm Password: <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required maxlength="30">
                        </div>

                        <button type="submit" class="btn btn-success btn-block">Create Account</button>
                        
                        <div class="text-center mt-3">
                            Already have an account? <a href="login.jsp">Login here</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
