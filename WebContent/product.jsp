<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Product Details - The Pro Shop</title>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .product-image {
            width: 100%;
            max-width: 500px;
            height: auto;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }
        .product-price {
            font-size: 2rem;
            font-weight: 600;
            color: #dc3545;
            margin: 20px 0;
        }
        .product-title {
            font-size: 1.75rem;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .quantity-selector {
            display: flex;
            align-items: center;
            margin: 20px 0;
        }
        .quantity-selector input {
            width: 60px;
            text-align: center;
            margin: 0 10px;
        }
        .add-to-cart-btn {
            font-size: 1.1rem;
            padding: 12px 40px;
            border-radius: 25px;
        }
        .product-description {
            margin-top: 30px;
            padding-top: 30px;
            border-top: 1px solid #e9ecef;
        }
        .reviews-section {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid #e9ecef;
        }
        .review-card {
            transition: box-shadow 0.3s ease;
        }
        .review-card:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .modal-content {
            border: 1px solid #e9ecef;
            border-radius: 8px;
        }
        .modal-header {
            border-bottom: 1px solid #e9ecef;
            background-color: #f8f9fa;
        }
        .modal-title {
            color: var(--dark-green);
            font-weight: 600;
        }
        .modal-footer {
            border-top: 1px solid #e9ecef;
            background-color: #f8f9fa;
        }
        #reviewModal .form-control {
            border-radius: 4px;
            border: 1px solid #e9ecef;
        }
        #reviewModal .form-control:focus {
            border-color: var(--dark-green);
            box-shadow: 0 0 0 0.2rem rgba(75, 93, 78, 0.25);
        }
        .form-group label {
            color: var(--dark-green);
        }
        .success-alert {
            position: fixed;
            top: 80px;
            right: 20px;
            z-index: 9999;
            min-width: 300px;
            animation: slideIn 0.3s ease-out;
        }
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        .fade-out {
            animation: fadeOut 0.5s ease-out forwards;
        }
        @keyframes fadeOut {
            to {
                opacity: 0;
                transform: translateX(400px);
            }
        }
        .star-rating:focus {
            outline: none;
        }
        .star-rating:active {
            outline: none;
        }
        * {
            user-select: none;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
        }
        input, textarea, select {
            user-select: text;
            -webkit-user-select: text;
            -moz-user-select: text;
            -ms-user-select: text;
            caret-color: auto;
        }
    </style>
</head>
<body>

<%@ include file="header.jsp" %>

<% 
// Check for success message
String successMsg = (String) session.getAttribute("cartSuccessMessage");
if (successMsg != null) {
    session.removeAttribute("cartSuccessMessage");
%>
    <div class="alert alert-success alert-dismissible success-alert" role="alert" id="successAlert">
        <strong><%= successMsg %></strong>
        <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
    <script>
        setTimeout(function() {
            var alert = document.getElementById('successAlert');
            if (alert) {
                alert.classList.add('fade-out');
                setTimeout(function() { alert.remove(); }, 500);
            }
        }, 3000);
    </script>
<%
}

// Check for error message
String errorMsg = (String) session.getAttribute("errorMessage");
if (errorMsg != null) {
    session.removeAttribute("errorMessage");
%>
    <div class="alert alert-danger alert-dismissible success-alert" role="alert" id="errorAlert">
        <strong>Error:</strong> <%= errorMsg %>
        <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
    <script>
        setTimeout(function() {
            var alert = document.getElementById('errorAlert');
            if (alert) {
                alert.classList.add('fade-out');
                setTimeout(function() { alert.remove(); }, 500);
            }
        }, 4000);
    </script>
<%
}
%>

<div class="container mt-4">
    <a href="listprod.jsp" class="btn btn-outline-secondary mb-3">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"/>
        </svg>
        Back to Products
    </a>

<%
    String productId = request.getParameter("id");
    if (productId == null || productId.trim().isEmpty()) {
        out.println("<div class='alert alert-danger'>Product ID is missing.</div>");
        return;
    }

    try {
        Connection con = getConnection();
        String sql = "SELECT productName, productDesc, productPrice, productImageURL, categoryId FROM product WHERE productId = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, productId);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            String name = rs.getString("productName");
            String description = rs.getString("productDesc");
            double price = rs.getDouble("productPrice");
            String imageUrl = rs.getString("productImageURL");
            Integer categoryId = rs.getObject("categoryId") != null ? rs.getInt("categoryId") : null;
            NumberFormat currFormat = NumberFormat.getCurrencyInstance();
            
            // Get category name if exists
            String categoryName = null;
            if (categoryId != null) {
                String catSql = "SELECT categoryName FROM category WHERE categoryId = ?";
                PreparedStatement catPs = con.prepareStatement(catSql);
                catPs.setInt(1, categoryId);
                ResultSet catRs = catPs.executeQuery();
                if (catRs.next()) {
                    categoryName = catRs.getString("categoryName");
                }
                catRs.close();
                catPs.close();
            }
%>
    <div class="row">
        <div class="col-md-6">
            <img src="<%= imageUrl != null ? imageUrl : "img/placeholder.jpg" %>" class="product-image" alt="<%= name %>">
        </div>
        <div class="col-md-6">
            <h1 class="product-title"><%= name %></h1>
            
            <% if (categoryName != null) { %>
                <p class="text-muted">Category: <strong><%= categoryName %></strong></p>
            <% } %>
            
            <div class="product-price"><%= currFormat.format(price) %></div>
            
            <div style="border-top: 1px solid #e9ecef; padding-top: 20px;">
                <form action="addcart.jsp" method="get">
                    <input type="hidden" name="productId" value="<%= productId %>">
                    
                    <div class="quantity-selector">
                        <label for="quantity" class="mr-3" style="font-weight: 600;">Quantity:</label>
                        <button type="button" class="btn btn-outline-secondary" onclick="decreaseQty()">-</button>
                        <input type="number" id="quantity" name="quantity" value="1" min="1" max="99" class="form-control" readonly>
                        <button type="button" class="btn btn-outline-secondary" onclick="increaseQty()">+</button>
                    </div>
                    
                    <button type="submit" class="btn btn-primary add-to-cart-btn btn-block">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16" style="margin-right: 8px;">
                            <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .491.592l-1.5 8A.5.5 0 0 1 13 12H4a.5.5 0 0 1-.491-.408L2.01 3.607 1.61 2H.5a.5.5 0 0 1-.5-.5zM5 12a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm7 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm-7 1a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
                        </svg>
                        Add to Cart
                    </button>
                </form>
            </div>
            
            <div class="product-description">
                <h4>Product Description</h4>
                <p><%= description != null && !description.isEmpty() ? description : "No description available for this product." %></p>
            </div>
        </div>
    </div>
    
    <div class="reviews-section">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
            <h3>Customer Reviews</h3>
            <% 
                String authUser = (String) session.getAttribute("authenticatedUser");
                if (authUser != null) {
                    // Check if user has purchased this product
                    boolean hasPurchased = false;
                    try {
                        con = getConnection();
                        String customerIdSql = "SELECT customerId FROM customer WHERE userid = ?";
                        PreparedStatement customerPs = con.prepareStatement(customerIdSql);
                        customerPs.setString(1, authUser);
                        ResultSet customerRs = customerPs.executeQuery();
                        
                        if (customerRs.next()) {
                            int customerId = customerRs.getInt("customerId");
                            String purchaseSql = "SELECT COUNT(*) as purchaseCount FROM orderproduct op " +
                                                "INNER JOIN ordersummary os ON op.orderId = os.orderId " +
                                                "WHERE os.customerId = ? AND op.productId = ?";
                            PreparedStatement purchasePs = con.prepareStatement(purchaseSql);
                            purchasePs.setInt(1, customerId);
                            purchasePs.setString(2, productId);
                            ResultSet purchaseRs = purchasePs.executeQuery();
                            
                            if (purchaseRs.next() && purchaseRs.getInt("purchaseCount") > 0) {
                                hasPurchased = true;
                            }
                            purchaseRs.close();
                            purchasePs.close();
                        }
                        customerRs.close();
                        customerPs.close();
                    } catch (SQLException e) {
                        // Handle error silently
                    }
            %>
                <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#reviewModal" <%= !hasPurchased ? "disabled" : "" %> title="<%= !hasPurchased ? "You must purchase this product to review it" : "" %>">
                    Write a Review
                </button>
            <% 
                } else {
            %>
                <a href="login.jsp" class="btn btn-primary">
                    Log in to Review
                </a>
            <% 
                }
            %>
        </div>

        <%
            try {
                // Get authenticated user's customer ID for delete permission check
                int authCustomerId = -1;
                authUser = (String) session.getAttribute("authenticatedUser");
                if (authUser != null) {
                    String authCustomerSql = "SELECT customerId FROM customer WHERE userid = ?";
                    PreparedStatement authCustomerPs = con.prepareStatement(authCustomerSql);
                    authCustomerPs.setString(1, authUser);
                    ResultSet authCustomerRs = authCustomerPs.executeQuery();
                    if (authCustomerRs.next()) {
                        authCustomerId = authCustomerRs.getInt("customerId");
                    }
                    authCustomerRs.close();
                    authCustomerPs.close();
                }
                
                // Get reviews for this product
                String reviewSql = "SELECT r.reviewId, r.rating, r.title, r.description, r.reviewDate, r.customerId, " +
                                  "c.firstName, c.lastName FROM review r " +
                                  "INNER JOIN customer c ON r.customerId = c.customerId " +
                                  "WHERE r.productId = ? ORDER BY r.reviewDate DESC";
                PreparedStatement reviewPs = con.prepareStatement(reviewSql);
                reviewPs.setString(1, productId);
                ResultSet reviewRs = reviewPs.executeQuery();
                
                boolean hasReviews = false;
                while (reviewRs.next()) {
                    hasReviews = true;
                    int reviewId = reviewRs.getInt("reviewId");
                    int customerId = reviewRs.getInt("customerId");
                    int rating = reviewRs.getInt("rating");
                    String reviewTitle = reviewRs.getString("title");
                    String reviewDesc = reviewRs.getString("description");
                    String reviewDate = reviewRs.getString("reviewDate");
                    String firstName = reviewRs.getString("firstName");
                    String lastName = reviewRs.getString("lastName");
                    boolean isOwner = (authCustomerId == customerId);
        %>
                    <div class="review-card" style="margin-bottom: 25px; padding: 20px; background: white; border-radius: 8px; border: 1px solid #e9ecef; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                        <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px;">
                            <div style="flex: 1;">
                                <h5 style="margin: 0 0 8px 0; font-weight: 600;"><%= reviewTitle %></h5>
                                <div style="margin-bottom: 8px;">
                                    <% for (int i = 0; i < rating; i++) { %>
                                        <span style="color: var(--clean-yellow); font-size: 1.1rem;">★</span>
                                    <% } %>
                                    <% for (int i = rating; i < 5; i++) { %>
                                        <span style="color: #ddd; font-size: 1.1rem;">★</span>
                                    <% } %>
                                </div>
                            </div>
                            <div style="display: flex; align-items: start; gap: 10px;">
                                <small style="color: #999; font-size: 0.85rem; white-space: nowrap;"><%= reviewDate %></small>
                                <% if (isOwner) { %>
                                    <button class="btn btn-sm btn-danger" onclick="deleteReview(<%= reviewId %>, '<%= productId %>')" style="padding: 3px 8px; font-size: 0.75rem;">Delete</button>
                                <% } %>
                            </div>
                        </div>
                        <p style="color: #666; margin-bottom: 12px;"><%= reviewDesc %></p>
                        <p style="color: #999; font-size: 0.9rem; margin: 0;"><strong><%= firstName %> <%= lastName %></strong></p>
                    </div>
        <%
                }
                reviewRs.close();
                reviewPs.close();
                
                if (!hasReviews) {
        %>
                    <div class="alert alert-light text-center" style="padding: 40px;">
                        <p class="text-muted mb-0">No reviews yet. Be the first to review this product!</p>
                    </div>
        <%
                }
            } catch (SQLException e) {
                out.println("<div class='alert alert-warning'>Could not load reviews.</div>");
            }
        %>
    </div>

    <!-- Review Modal -->
    <div class="modal fade" id="reviewModal" tabindex="-1" role="dialog" aria-labelledby="reviewModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="reviewModalLabel">Write a Review</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="reviewForm" method="POST" action="submitReview.jsp">
                        <input type="hidden" id="productId" name="productId" value="<%=productId%>">
                        <input type="hidden" id="debugProductId" value="<%=productId%>" style="display:none;">
                        
                        <div class="form-group">
                            <label style="font-weight: 600;">Rating *</label>
                            <div style="margin-top: 10px; display: flex; gap: 5px;">
                                <span class="star-rating" style="cursor: pointer; font-size: 1.8rem; color: #ddd; transition: color 0.2s;" data-value="1">★</span>
                                <span class="star-rating" style="cursor: pointer; font-size: 1.8rem; color: #ddd; transition: color 0.2s;" data-value="2">★</span>
                                <span class="star-rating" style="cursor: pointer; font-size: 1.8rem; color: #ddd; transition: color 0.2s;" data-value="3">★</span>
                                <span class="star-rating" style="cursor: pointer; font-size: 1.8rem; color: #ddd; transition: color 0.2s;" data-value="4">★</span>
                                <span class="star-rating" style="cursor: pointer; font-size: 1.8rem; color: #ddd; transition: color 0.2s;" data-value="5">★</span>
                            </div>
                            <input type="hidden" id="ratingValue" name="ratingValue" value="0">
                        </div>
                        
                        <div class="form-group" style="margin-top: 20px;">
                            <label for="title" style="font-weight: 600;">Review Title *</label>
                            <input type="text" class="form-control" id="title" name="title" placeholder="Sum up your experience" maxlength="100" required>
                            <small class="form-text text-muted">Maximum 100 characters</small>
                        </div>
                        
                        <div class="form-group" style="margin-top: 20px;">
                            <label for="description" style="font-weight: 600;">Review Description *</label>
                            <textarea class="form-control" id="description" name="description" rows="4" placeholder="Share your experience with this product..." maxlength="1000" required></textarea>
                            <small class="form-text text-muted" id="charCount">0 / 1000 characters</small>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="submitReview()">Post Review</button>
                </div>
            </div>
        </div>
    </div>

<%
        } else {
            out.println("<div class='alert alert-warning'>Product not found.</div>");
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        closeConnection();
    }
%>
</div>

<script>
    function increaseQty() {
        var qtyInput = document.getElementById('quantity');
        var currentQty = parseInt(qtyInput.value);
        if (currentQty < 99) {
            qtyInput.value = currentQty + 1;
        }
    }
    
    function decreaseQty() {
        var qtyInput = document.getElementById('quantity');
        var currentQty = parseInt(qtyInput.value);
        if (currentQty > 1) {
            qtyInput.value = currentQty - 1;
        }
    }

    // Initialize when document is ready
    document.addEventListener('DOMContentLoaded', function() {
        // Set up star rating clicks
        const stars = document.querySelectorAll('.star-rating');
        stars.forEach(star => {
            star.addEventListener('click', function() {
                const rating = this.getAttribute('data-value');
                updateStarDisplay(rating);
            });
            
            // Add hover effect
            star.addEventListener('mouseenter', function() {
                const hoverRating = this.getAttribute('data-value');
                stars.forEach(s => {
                    if (s.getAttribute('data-value') <= hoverRating) {
                        s.style.color = 'var(--clean-yellow)';
                    } else {
                        s.style.color = '#ddd';
                    }
                });
            });
        });
        
        // Reset on mouse leave
        const starContainer = document.querySelector('[style*="display: flex"]');
        if (starContainer) {
            starContainer.addEventListener('mouseleave', function() {
                const currentRating = document.getElementById('ratingValue').value;
                stars.forEach(s => {
                    if (currentRating && s.getAttribute('data-value') <= currentRating) {
                        s.style.color = 'var(--clean-yellow)';
                    } else {
                        s.style.color = '#ddd';
                    }
                });
            });
        }

        // Character counter
        const descArea = document.getElementById('description');
        if (descArea) {
            descArea.addEventListener('keyup', function() {
                const count = this.value.length;
                document.getElementById('charCount').textContent = count + ' / 1000 characters';
            });
        }

        // Title Enter key
        const titleField = document.getElementById('title');
        if (titleField) {
            titleField.addEventListener('keypress', function(e) {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    submitReview();
                }
            });
        }

        // Reset modal
        $('#reviewModal').on('hidden.bs.modal', function() {
            document.getElementById('reviewForm').reset();
            document.getElementById('ratingValue').value = '0';
            stars.forEach(s => {
                s.style.color = '#ddd';
            });
            document.getElementById('charCount').textContent = '0 / 1000 characters';
        });
    });

    // Update star display
    function updateStarDisplay(rating) {
        rating = parseInt(rating);
        document.getElementById('ratingValue').value = rating;
        
        const stars = document.querySelectorAll('.star-rating');
        stars.forEach(star => {
            const starValue = parseInt(star.getAttribute('data-value'));
            if (starValue <= rating) {
                star.style.color = 'var(--clean-yellow)';
            } else {
                star.style.color = '#ddd';
            }
        });
    }

    function submitReview() {
        const rating = document.getElementById('ratingValue').value;
        const title = document.getElementById('title').value;
        const description = document.getElementById('description').value;

        // Validate
        if (!rating || rating === '0') {
            alert('Please select a rating.');
            return;
        }
        if (!title.trim()) {
            alert('Please enter a review title.');
            return;
        }
        if (!description.trim()) {
            alert('Please enter a review description.');
            return;
        }

        // Submit form
        document.getElementById('reviewForm').submit();
    }

    function deleteReview(reviewId, productId) {
        if (confirm('Are you sure you want to delete this review? This cannot be undone.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'deleteReview.jsp';
            
            const reviewIdInput = document.createElement('input');
            reviewIdInput.type = 'hidden';
            reviewIdInput.name = 'reviewId';
            reviewIdInput.value = reviewId;
            
            const productIdInput = document.createElement('input');
            productIdInput.type = 'hidden';
            productIdInput.name = 'productId';
            productIdInput.value = productId;
            
            form.appendChild(reviewIdInput);
            form.appendChild(productIdInput);
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

</body>
</html>