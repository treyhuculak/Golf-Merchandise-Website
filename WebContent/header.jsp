<nav class="navbar navbar-expand-lg navbar-light">
    <div class="container">
        <a class="navbar-brand" href="index.jsp">The Pro Shop</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav mx-auto">
                <li class="nav-item">
                    <a class="nav-link" href="index.jsp">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="listprod.jsp">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="outfits.jsp">Pro Shop Looks</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="listorder.jsp">Order History</a>
                </li>
                 <li class="nav-item">
                    <a class="nav-link" href="admin.jsp">Admin</a>
                </li>
            </ul>
            <ul class="navbar-nav ms-auto align-items-center" style="gap: 0.5rem;">
                <!-- Cart Icon -->
                <li class="nav-item">
                    <a class="nav-link d-flex align-items-center position-relative" href="showcart.jsp" title="Shopping Cart">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-cart3" viewBox="0 0 16 16">
                            <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .49.598l-1 5a.5.5 0 0 1-.465.401l-9.397.472L4.415 11H13a.5.5 0 0 1 0 1H4a.5.5 0 0 1-.491-.408L2.01 3.607 1.61 2H.5a.5.5 0 0 1-.5-.5zM3.102 4l.84 4.479 9.144-.459L13.89 4H3.102zM5 12a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm7 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm-7 1a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
                        </svg>
                        <%
                            // Calculate total cart items
                            @SuppressWarnings({"unchecked"})
                            java.util.HashMap<String, java.util.ArrayList<Object>> cartList = 
                                (java.util.HashMap<String, java.util.ArrayList<Object>>) session.getAttribute("productList");
                            int cartItemCount = 0;
                            if (cartList != null && !cartList.isEmpty()) {
                                for (java.util.ArrayList<Object> item : cartList.values()) {
                                    if (item.size() >= 4) {
                                        try {
                                            cartItemCount += Integer.parseInt(item.get(3).toString());
                                        } catch (Exception e) {}
                                    }
                                }
                            }
                            if (cartItemCount > 0) {
                        %>
                            <span class="badge badge-danger" style="position: absolute; top: -2px; right: -2px; font-size: 10px; padding: 2px 5px; min-width: 18px; border-radius: 9px; font-weight: 600; line-height: 1;">
                                <%= cartItemCount %>
                            </span>
                        <% } %>
                    </a>
                </li>
                
                <!-- Profile Icon with Dropdown -->
                <% if (session.getAttribute("authenticatedUser") != null) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" id="profileDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
                                <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
                                <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
                            </svg>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right" aria-labelledby="profileDropdown">
                            <a class="dropdown-item" href="customer.jsp">My Account</a>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" href="logout.jsp">Logout</a>
                        </div>
                    </li>
                <% } else { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" id="profileDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
                                <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
                                <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
                            </svg>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right" aria-labelledby="profileDropdown">
                            <a class="dropdown-item" href="login.jsp">Log In</a>
                            <a class="dropdown-item" href="register.jsp">Sign Up</a>
                        </div>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

<script>
// Ensure Bootstrap dropdown works
$(document).ready(function() {
    $('.dropdown-toggle').dropdown();
});
</script>
