# The Pro Shop - E-Commerce Platform

## Project Overview

The Pro Shop is a full-featured e-commerce web application built with Java technologies. This project demonstrates expertise in developing database-driven web applications with modern architecture patterns, including user authentication, product management, shopping cart functionality, and order processing. The application is containerized for easy deployment and scalability.

## Key Features

### 🛒 Shopping Cart System
- **Add/Remove Products**: Users can browse products and manage their shopping cart with real-time updates
- **Cart Management**: View cart contents, modify quantities, and proceed to checkout
- **Product Bundles**: Support for product bundling and outfit combinations for enhanced customer experience

### 👤 User Management & Authentication
- **User Registration**: Secure account creation with email validation
- **Login/Authentication**: Session-based authentication with secure password handling
- **Account Management**: Users can edit their profile information and account details
- **Password Recovery**: Forgot password functionality with secure reset tokens
- **Admin Dashboard**: Administrative interface for managing products, orders, and customers

### 🛍️ Product Catalog
- **Product Browsing**: Organized product listing with filtering by category
- **Product Details**: Comprehensive product information including descriptions, pricing, and images
- **Category Management**: Products organized into logical categories (Meals, Outfits, etc.)
- **Product Reviews**: Customer review system with rating functionality
- **Inventory Management**: Real-time inventory tracking and warehouse integration

### 📦 Order Management
- **Order Processing**: Complete order workflow from cart to checkout
- **Order History**: Customers can view their complete order history and details
- **Order Tracking**: Order status tracking with shipment information
- **Payment Integration**: Checkout process with shipping address management

### 🏭 Advanced Features
- **Multi-Warehouse Support**: Inventory distributed across multiple warehouses with automatic allocation
- **Shipment Tracking**: Integration with shipment management system
- **Database Autonumbering**: Auto-generated order IDs using SQL Server IDENTITY fields
- **Transaction Management**: Proper handling of database transactions for data integrity

## Technologies Used

### Backend
- **Java**: Core application logic and business logic implementation
- **JSP (JavaServer Pages)**: Dynamic web page generation and server-side templating
- **JDBC (Java Database Connectivity)**: Direct database connectivity and query execution

### Frontend
- **HTML5**: Semantic markup and page structure
- **CSS3**: Modern styling with Bootstrap 4.5.2 framework for responsive design
- **Bootstrap 4.5.2**: UI components and responsive layout framework

### Database
- **Microsoft SQL Server**: Enterprise-grade relational database with support for:
  - Transactions and ACID compliance
  - Foreign keys and referential integrity
  - Stored procedures and triggers (if applicable)
  - Autonumber fields (IDENTITY) for primary key generation

### DevOps & Deployment
- **Apache Tomcat 9**: Java servlet container and web server
- **Docker & Docker Compose**: Containerization for reproducible environments
- **JDK 11**: Java Development Kit for compilation and runtime

### Development
- **Git**: Version control and collaboration

## Application Architecture

The application follows a traditional three-tier architecture:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (JSP Pages & HTML Templates)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Business Logic Layer            │
│    (JSP Logic & Java Code)              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Data Access Layer               │
│    (JDBC & SQL Queries)                 │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Microsoft SQL Server Database      │
│    (Orders, Customers, Products)        │
└─────────────────────────────────────────┘
```

## Database Schema Highlights

- **customer**: User account information and authentication
- **product**: Product catalog with pricing and descriptions
- **category**: Product categorization
- **ordersummary**: Order metadata and status tracking
- **orderproduct**: Order line items with product-order associations
- **incart**: Shopping cart items for active sessions
- **outfit**: Product bundles and outfit combinations
- **review**: Customer product reviews and ratings
- **shipment**: Order fulfillment and shipping tracking
- **warehouse**: Inventory management across multiple locations
- **productinventory**: Stock levels and availability

## Installation & Setup

### Prerequisites

- **Docker Desktop**: Required for running containerized services
  - Download from: https://www.docker.com/products/docker-desktop
  - Ensure Docker Desktop is running before starting the application
  
- **Git**: For cloning the repository
  - Download from: https://git-scm.com/

- **Java JDK 11 or higher**: For local development (optional if using Docker)
  - Download from: https://www.oracle.com/java/technologies/javase-jdk11-downloads.html

### System Requirements

- **RAM**: Minimum 4GB (8GB recommended for comfortable development)
- **Disk Space**: Minimum 2GB available
- **Operating System**: Windows, macOS (Intel), or Linux
  - **Note**: SQL Server image is not supported on Apple M1 chips natively (workaround provided below)

### Step-by-Step Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/cosc-304-2025/development-project-lab-7-10-team37.git
cd development-project-lab-7-10-team37/java
```

#### 2. Ensure Docker is Running

Before proceeding, verify Docker Desktop is running:
- **Windows**: Look for the Docker icon in the system tray
- **macOS/Linux**: Run `docker --version` in terminal to verify installation

#### 3. Start Docker Containers

Navigate to the directory containing `docker-compose.yml` and start the containers:

```bash
docker-compose up -d
```

This command will:
- Download necessary Docker images (first run only)
- Start Microsoft SQL Server container
- Start Apache Tomcat 9 web server
- Expose the application on `http://localhost:8080/shop/`

**Startup Time**: Initial startup may take 2-3 minutes for containers to fully initialize.

#### 4. Initialize Database

Once containers are running, load the database schema and sample data:

1. Navigate to the database initialization page in your browser:
   ```
   http://localhost:8080/shop/loaddata.jsp
   ```

2. Click the load data button to:
   - Create all database tables
   - Load sample products, customers, and orders
   - Initialize the database schema

#### 5. Access the Application

- **Main Shop Page**: http://localhost:8080/shop/shop.html
- **Login Page**: http://localhost:8080/shop/login.jsp
- **Product Listing**: http://localhost:8080/shop/listprod.jsp
- **Order Management**: http://localhost:8080/shop/listorder.jsp

### Alternative Setup for Apple M1/M2 Macs

If you're using an Apple M1 or M2 chip, SQL Server with ARM support is required:

1. Edit `docker-compose.yml` in the java directory
2. Find the line with: `image: mcr.microsoft.com/mssql/server:2022-latest`
3. Replace it with: `image: mcr.microsoft.com/azure-sql-edge`
4. Save the file and run `docker-compose up -d`

## Running the Application

### Start Services

```bash
docker-compose up -d
```

### Stop Services

```bash
docker-compose down
```

### View Logs

```bash
docker-compose logs -f
```

### Rebuild and Restart

```bash
docker-compose up -d --build
```

## Development Workflow

### Making Code Changes

1. Edit JSP files in the `WebContent/` directory
2. Changes are reflected immediately when you refresh the browser (JSP pages are interpreted at runtime)
3. For any structural changes, restart Tomcat: `docker-compose restart`

### Accessing the Tomcat Console

- **Status Page**: http://localhost:8080/
- **Application Context**: http://localhost:8080/shop/

### Database Connection Details

```
Server: cosc304_sqlserver (Docker hostname)
Port: 1433
Database: orders
JDBC URL: jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True
```

## Project Structure

```
java/
├── WebContent/              # Web application files (JSP, HTML, CSS, images)
│   ├── css/                 # Stylesheets
│   ├── img/                 # Product and UI images
│   ├── ddl/                 # Database schema and SQL scripts
│   ├── WEB-INF/             # Configuration and libraries
│   │   ├── lib/             # JAR dependencies (JDBC drivers)
│   │   └── web.xml          # Servlet configuration
│   ├── *.jsp                # JSP pages (main application files)
│   └── *.html               # Static HTML files
├── Dockerfile               # Docker container configuration for Tomcat
├── docker-compose.yml       # Multi-container orchestration configuration
└── README.md               # This file
```

### Key JSP Pages

| Page | Purpose |
|------|---------|
| `shop.html` | Main landing page and product browsing interface |
| `login.jsp` | User authentication and login |
| `register.jsp` | New customer account creation |
| `listprod.jsp` | Product catalog and browsing |
| `showcart.jsp` | Shopping cart display |
| `checkout.jsp` | Order checkout and payment |
| `admin.jsp` | Administrative functions |
| `listorder.jsp` | Order history and tracking |
| `editAccount.jsp` | User profile management |

## Troubleshooting

### Issue: "Connection refused" when accessing the application

**Solution**: Ensure Docker containers are running:
```bash
docker-compose ps
```
If containers are not running, start them with: `docker-compose up -d`

### Issue: Database connection errors

**Solution**: 
1. Verify SQL Server container is fully initialized (wait 30-60 seconds after startup)
2. Check that the loaddata.jsp page has been executed: http://localhost:8080/shop/loaddata.jsp
3. View logs: `docker-compose logs sqlserver`

### Issue: Changes not reflected when editing JSP files

**Solution**: 
1. Clear browser cache (Ctrl+Shift+Delete)
2. Hard refresh the page (Ctrl+Shift+R)
3. If changes still don't appear, restart Tomcat: `docker-compose restart`

### Issue: Port already in use

If port 8080 or 1433 is already in use, modify `docker-compose.yml`:
```yaml
ports:
  - "8081:8080"  # Change first 8080 to an available port
  - "1434:1433"  # Change first 1433 to an available port
```

### Issue: Out of memory or slow performance

**Solution**: Increase Docker memory allocation:
1. Open Docker Desktop preferences
2. Go to Resources
3. Increase available memory to 4GB or more
4. Restart Docker

## Testing the Application

### User Accounts

Default test credentials (after loading sample data):

| Username | Password | Role |
|----------|----------|------|
| testuser | password | Customer |
| admin | admin | Admin |

### Sample Data

The application includes sample products across categories:
- Products with pricing and inventory
- Multiple product categories
- Sample customer accounts
- Historical orders for testing

## Performance & Scalability Considerations

### Features Demonstrating Best Practices

1. **Connection Management**: Proper JDBC connection handling and resource cleanup
2. **Transaction Safety**: Database transactions ensure data consistency during order processing
3. **Session Management**: User session handling for authentication and cart persistence
4. **Scalability**: Containerized architecture allows for horizontal scaling
5. **Security**: Session-based authentication and password validation

### Optimization Areas

- Database queries are optimized with proper indexing on primary keys and foreign keys
- Inventory management prevents overselling through transaction locking
- Shipment tracking provides audit trails for order fulfillment

## Skills Demonstrated

This project showcases practical experience with:

✅ **Backend Development**
- Java server-side programming with JSP
- JDBC database programming and SQL query optimization
- Session management and authentication

✅ **Database Design**
- Relational database schema design
- Normalization and foreign key relationships
- Transaction management and ACID compliance

✅ **Web Development**
- Full-stack web application development
- HTML5 and CSS3 for responsive design
- Bootstrap framework implementation
- User interface design and usability

✅ **DevOps & Deployment**
- Docker containerization
- Docker Compose for multi-service orchestration
- Environment configuration management
- Local development environment setup

✅ **Software Engineering**
- Three-tier architecture implementation
- Separation of concerns
- Code organization and modularity
- Version control with Git

## Future Enhancement Opportunities

- Implement payment gateway integration (Stripe, PayPal)
- Add product search and advanced filtering
- Implement recommendation engine
- Add email notifications for orders
- Implement caching layer for performance optimization
- Create REST API endpoints for mobile app support
- Add automated testing suite (JUnit, Selenium)
- Implement continuous integration/deployment pipeline

## License

This project is part of the COSC 304 course assignment at the University of British Columbia.

## Support & Questions

For issues, questions, or improvements:
1. Check the troubleshooting section above
2. Review the Docker logs: `docker-compose logs`
3. Verify all prerequisites are installed correctly
4. Consult the course materials and documentation

## Authors

Developed as part of COSC 304 - Introduction to Database Systems  
Team 37 - Development Project Lab 7-10

---

**Last Updated**: December 2025  
**Version**: 1.0 

2. In the directory that contains `docker-compose.yml` run the command `docker-compose up -d`. This will start the Docker containers for MySQL, SQL Server, and Tomcat web server. Make sure Docker Desktop is running.

3. There are sample code and practice questions [available](sample/) if you want to see working code and experiment before starting the lab.

4. Create the tables and load the sample data into your SQL Server database.  The file `WebContent/loaddata.jsp` will load the database using the `WebContent/ddl/SQLServer_orderdb.ddl` script. You can run this file by using the URL: `http://localhost/shop/loaddata.jsp`.

5. **SQL Server is not supported on the Apple M1 chip.** However, there is an alternate version that is. In the `docker-compose.yml` file, change:
`image: mcr.microsoft.com/mssql/server:2022-latest` to this: `image: mcr.microsoft.com/azure-sql-edge` .


## Databases and Autonumber Fields

This database storing customers, orders, and products uses autonumber fields to assign a primary key value for orders.  An autonumber field is an integer field which is automatically assigned by the database.  The value of the counter starts at 1.  When a record is added, the value of the autonumber field for the new record is set to the counter and then the counter is incremented.  Thus, the values of the autonumber field for records are 1,2,3,...  Autonumber fields are useful as primary keys as they are guaranteed to be unique.  To create an autonumber field in a SQL Server create table statement use the `IDENTITY` keyword: 

```
CREATE TABLE dummy (
   A int NOT NULL IDENTITY,
   B VARCHAR(50),
   ....
   PRIMARY KEY (A)
);
```

## Question 1 (10 marks)

Modify the `listorder.jsp` so that it lists all orders currently in the database. You must list all orders and the products of those orders.

#### Details:

1. [Sample output](https://cosc304.ok.ubc.ca/rlawrenc/tomcat/Lab7/listorder.jsp)

2. The main shop page is [http://localhost/shop/shop.html](http://localhost/shop/shop.html) and a sample is at [https://cosc304.ok.ubc.ca/rlawrenc/tomcat/Lab7/shop.html](https://cosc304.ok.ubc.ca/rlawrenc/tomcat/Lab7/shop.html).  Feel free to change it to your shop name and style!

3. Your output does not have to look exactly like the sample (feel free to make it look better!).

4. A good way to get started with `listorder.jsp` is to copy some of the [sample SQL Server JDBC code](https://github.com/rlawrenc/cosc_304/blob/main/labs/lab6/code/TestJdbcSqlServer.java) and modify it for this particular query. **Note that the URL is for Microsoft SQL Server not MySQL. The URL is: ``jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True``**</li>


#### Marking Guide:

- **+2 marks** - for SQL Server connection information and making a successful connection
- **+1 mark** - for using try-catch syntax
- **+2 marks** - for displaying order summary information for each order in a table
- **+3 marks** - for displaying items in each order in a table
- **+1 mark** - for formatting currency values correctly (e.g. $91.70)
- **+1 mark** - for closing connection (either explicitly or as part of try-catch with resources syntax)

## Question 2 (30 marks)

Build a simple web site that allows users to search for products by name, put products in their shopping cart, and place an order by checking out the items in their shopping cart. Starter code is provided. Fill in a few of the JSP files to get the application to work.  Here are the steps you should do to get started:

1. Summary of code files:

- **listprod.jsp** - lists all products.  **TODO: fill-in your own code (10 marks)**
- **addcart.jsp** - adds an item to the cart (stored using session variable).  No changes needed.
- **showcart.jsp** - displays the items in the cart.  No changes needed.
- **checkout.jsp** - page to start the checkout.  No changes needed.
- **order.jsp** - store a checked-out order to database. **TODO: fill-in your own code (20 marks)**

2. Take a look at the sample web site available at [https://cosc304.ok.ubc.ca/rlawrenc/tomcat/Lab7/shop.html](https://cosc304.ok.ubc.ca/rlawrenc/tomcat/Lab7/shop.html).

3. Start by editing the JSP file called `listprod.jsp`.  This file is called from `shop.html` when the user begins to shop.  The file allows a customer to search for products by name.  If a customer enters "ab", then the query should be: `productName LIKE '%ab%'`.

4. Start off with just being able to list products by name.  Inside `listprod.jsp` is a form whose GET method calls `listprod.jsp` itself.  When a user submits the form, the URL passed to `listprod.jsp` will contain a parameter `productName`.  Based on this parameter, construct your query. Start with the template code and then add the required code to connect to the database and list the products.

5. The file `listprod.jsp` also allows users to add items to their cart. This is accomplished by having a link beside each item. When the user clicks on the link, another page called `addcart.jsp` is called with information on the product to add.

6. The file `addcart.jsp` expects the following parameters: `addcart.jsp?id=(productId)&name=(productName)&price=(productPrice)`.  You must make sure that you create the appropriate links when listing your products.

7. `addcart.jsp` calls another file that maintains a record of the shopping cart over a user's session.  This file is `showcart.jsp`.

8. When the user wants to check-out, they must enter customer information.  The file `checkout.jsp` prompts the user for a customer id and passes that information onto the JSP file `order.jsp`.

9. The other file you must write is `order.jsp`. This file must save an order and all its products to the database as long as a valid customer id was entered.

10. Make sure to list the order id and all items as shown in the example.


#### Marking Guide (for listprod.jsp): (10 marks total)

- **+1 mark** - for SQL Server connection information and making a successful connection
- **+2 marks** - for using product name parameter to filter products shown (must handle case where nothing is provided in which case all products are shown)
- **+1 mark** - for using PreparedStatements
- **+2 marks** - for displaying table of products
- **+3 marks** - for building web link URL to allow products to be added to the cart
- **+1 mark** - for closing connection (either explicitly or as part of try-catch with resources syntax)

#### Marking Guide (for order.jsp): (20 marks total)

- **+1 mark** - for SQL Server connection information and making a successful connection
- **+3 marks** - for validating that the customer id is a number and the customer id exists in the database. Display an error if customer id is invalid.
- **+1 mark** - for showing error message if shopping cart is empty
- **+3 marks** - for inserting into ordersummary table and retrieving auto-generated id
- **+6 marks** - for traversing list of products and storing each ordered product in the orderproduct table
- **+2 marks** - for updating total amount for the order in OrderSummary table
- **+2 marks** - for displaying the order information including all ordered items
- **+1 mark** - for clearing the shopping cart (sessional variable) after order has been successfully placed
- **+1 mark** - for closing connection (either explicitly or as part of try-catch with resources syntax)


#### Bonus Marks

Up to 10 bonus marks can be received by going beyond the basic assignment requirements:

- **+5 marks** - for allowing a user to remove items from their shopping cart and to change the quantity of items ordered when viewing their cart.
- **+5 marks** - for validating a customer's password when they try to place an order.
- **Up to +5 marks** - for improving the looks of the site such as:
	- **+2 marks** - for a page header with links to product page, list order, and shopping cart
	- **+3 marks** - for formatting product listing page to include better formatting as well as filter by category	
	- **+3 marks** - for improved formatting of cart page		

- Other bonus marks may be possible if discussed with the TA/instructor.

**If you want to be eligible for bonus marks, please note that on your assignment and explain what you did to deserve the extra marks.  An [example web site with improved features is available](https://cosc304.ok.ubc.ca/rlawrenc/tomcat/Lab7/bonus/shop.html).**

#### Deliverables:

1. Option #1: Demonstrate your working site to the TA in a help session. Bonus marks if completed by early deadlines. No submission on Canvas is required.
2. Option #2: Submit in a single zip file all your source code using Canvas. This can be done by exporting your project. Submit all your files, but the files you must change are: `listprod.jsp`, `listorder.jsp` and `order.jsp`.
3. Only one submission for a group. Put both partners' names and student numbers on the submission.
