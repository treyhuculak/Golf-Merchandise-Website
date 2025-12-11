<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<%
// Define meals: map key -> array of productIds (we add two new meals: taco_meal and pasta_meal)
Map<String,int[]> meals = new HashMap<String,int[]>();
// Taco Meal: Ground Beef (30), Tortillas (31), Shredded Cheese (32), Salsa (33)
meals.put("taco_meal", new int[]{30,31,32,33});
// Pasta Meal: Spaghetti (34), Tomato Sauce (35), Parmesan (36), Garlic Bread (37)
meals.put("pasta_meal", new int[]{34,35,36,37});

String addMeal = request.getParameter("addMeal");
if (addMeal != null && meals.containsKey(addMeal)) {
    // Server-side add each product in the meal to session productList (same structure as addcart.jsp)
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    if (productList == null) productList = new HashMap<String, ArrayList<Object>>();

    int[] productIds = meals.get(addMeal);
    Connection conn = null;
    try {
        conn = getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT productName, productPrice FROM product WHERE productId = ?");
        for (int pid : productIds) {
            ps.setInt(1, pid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String id = String.valueOf(pid);
                String name = rs.getString("productName");
                String price = String.valueOf(rs.getDouble("productPrice"));

                ArrayList<Object> product = new ArrayList<Object>();
                product.add(id);
                product.add(name);
                product.add(price);
                product.add(new Integer(1));

                if (productList.containsKey(id)) {
                    product = (ArrayList<Object>) productList.get(id);
                    int curAmount = ((Integer) product.get(3)).intValue();
                    product.set(3, new Integer(curAmount+1));
                } else {
                    productList.put(id, product);
                }
            }
            rs.close();
        }
        ps.close();
    } catch (SQLException e) {
        out.println("<p>Error adding meal: " + e.getMessage() + "</p>");
    } finally {
        closeConnection();
    }

    session.setAttribute("productList", productList);
    // Go to cart view after adding
    response.sendRedirect("showcart.jsp");
    return;
}
%>
<%
// Prepare meal display data (name, id, image)
Map<String, List<Map<String,String>>> mealDisplay = new HashMap<String, List<Map<String,String>>>();
Connection dconn = null;
try {
    dconn = getConnection();
    PreparedStatement dps = dconn.prepareStatement("SELECT productName, productImageURL, productPrice FROM product WHERE productId = ?");
    // Image overrides for products that don't have productImageURL set in the DDL
    Map<Integer,String> imgOverrides = new HashMap<Integer,String>();
    // taco meal images (you can replace these files in WebContent/img)
    imgOverrides.put(30, "img/ground_beef.jpg");
    imgOverrides.put(31, "img/tortillas.jpg");
    imgOverrides.put(32, "img/shredded_cheese.jpg");
    imgOverrides.put(33, "img/salsa.jpg");
    // pasta meal images
    imgOverrides.put(34, "img/spaghetti.jpg");
    imgOverrides.put(35, "img/tomato_sauce.jpg");
    imgOverrides.put(36, "img/parmesan.jpg");
    imgOverrides.put(37, "img/garlic_bread.jpg");
    // keep previous fallbacks for older items (optional)
    imgOverrides.put(13, "img/3.jpg");
    imgOverrides.put(14, "img/4.jpg");
    imgOverrides.put(27, "img/2.jpg");
    for (String key : meals.keySet()) {
        List<Map<String,String>> items = new ArrayList<Map<String,String>>();
        for (int pid : meals.get(key)) {
            dps.setInt(1, pid);
            ResultSet drs = dps.executeQuery();
            if (drs.next()) {
                Map<String,String> info = new HashMap<String,String>();
                info.put("id", String.valueOf(pid));
                info.put("name", drs.getString("productName"));
                String img = drs.getString("productImageURL");
                String chosenImg = img;
                if (chosenImg == null || chosenImg.trim().length() == 0) {
                    int keyPid = pid;
                    if (imgOverrides.containsKey(keyPid)) chosenImg = imgOverrides.get(keyPid);
                    else chosenImg = "img/1_a.jpg";
                }
                info.put("img", chosenImg);
                info.put("price", String.valueOf(drs.getDouble("productPrice")));
                items.add(info);
            } else {
                Map<String,String> info = new HashMap<String,String>();
                info.put("id", String.valueOf(pid));
                info.put("name", "Product "+pid);
                info.put("img", "img/1_a.jpg");
                info.put("price", "0.00");
                items.add(info);
            }
            drs.close();
        }
        mealDisplay.put(key, items);
    }
    dps.close();
} catch (SQLException e) {
    out.println("<p>Error loading meal items: " + e.getMessage() + "</p>");
} finally {
    closeConnection();
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Meals</title>
    <style>
        .meal { border: 1px solid #ddd; padding: 12px; margin: 12px; display:inline-block; vertical-align:top; width:300px }
        .meal h3 { margin-top:0 }
        .meal ul { margin:0; padding-left:18px }
        .meal form { margin-top:8px }
    </style>
</head>
<body>
    <h2>Meals</h2>
    <p>Click a meal's "Add meal" button to add all ingredients to your cart at once.</p>

    <div class="meal">
        <h3>Taco Meal</h3>
        <div class="meal-items">
        <%
            List<Map<String,String>> tacoItems = mealDisplay.get("taco_meal");
            double tacoTotal = 0.0;
            for (Map<String,String> it : tacoItems) {
                double p = 0.0;
                try { p = Double.parseDouble(it.get("price")); } catch (Exception e) { }
                tacoTotal += p;
        %>
            <div style="display:flex;align-items:center;margin:6px 0">
                <img src="<%= it.get("img") %>" alt="img" style="width:64px;height:64px;object-fit:cover;margin-right:8px" />
                <span style="flex:1"><%= it.get("name") %></span>
                <span style="margin-left:8px">$<%= String.format("%.2f", p) %></span>
            </div>
        <%
            }
        %>
        </div>
        <div style="margin-top:8px;font-weight:bold">Meal total: $<%= String.format("%.2f", tacoTotal) %></div>
        <form method="post">
            <input type="hidden" name="addMeal" value="taco_meal" />
            <button type="submit">Add meal</button>
        </form>
    </div>

    <div class="meal">
        <h3>Pasta Meal</h3>
        <div class="meal-items">
        <%
            List<Map<String,String>> pastaItems = mealDisplay.get("pasta_meal");
            double pastaTotal = 0.0;
            for (Map<String,String> it : pastaItems) {
                double p2 = 0.0;
                try { p2 = Double.parseDouble(it.get("price")); } catch (Exception e) { }
                pastaTotal += p2;
        %>
            <div style="display:flex;align-items:center;margin:6px 0">
                <img src="<%= it.get("img") %>" alt="img" style="width:64px;height:64px;object-fit:cover;margin-right:8px" />
                <span style="flex:1"><%= it.get("name") %></span>
                <span style="margin-left:8px">$<%= String.format("%.2f", p2) %></span>
            </div>
        <%
            }
        %>
        </div>
        <div style="margin-top:8px;font-weight:bold">Meal total: $<%= String.format("%.2f", pastaTotal) %></div>
        <form method="post">
            <input type="hidden" name="addMeal" value="pasta_meal" />
            <button type="submit">Add meal</button>
        </form>
    </div>

    <p><a href="showcart.jsp">View cart</a></p>
</body>
</html>
