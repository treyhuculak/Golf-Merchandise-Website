import requests
from bs4 import BeautifulSoup
import time
import re
import concurrent.futures
from threading import Lock

# Categories: (URL, categoryId, max_products)
CATEGORIES = [
    ('https://justgolfstuff.ca/collections/drivers', 3, 15),
    ('https://justgolfstuff.ca/collections/woods', 3, 15),
    ('https://justgolfstuff.ca/collections/irons', 3, 15),
    ('https://justgolfstuff.ca/collections/wedges', 3, 15),
    ('https://justgolfstuff.ca/collections/putters', 3, 15),
    ('https://justgolfstuff.ca/collections/complete-sets', 3, 15),
    ('https://justgolfstuff.ca/collections/new-golf-balls', 3, 15),
    ('https://justgolfstuff.ca/collections/golf-gloves', 1, 15),
    ('https://justgolfstuff.ca/collections/golf-hats', 1, 15),
    ('https://justgolfstuff.ca/collections/mens-shirts', 1, 15),
    ('https://justgolfstuff.ca/collections/mens-shorts', 1, 15),
    ('https://justgolfstuff.ca/collections/golf-pants-for-men', 1, 15),
    ('https://justgolfstuff.ca/collections/mens-spiked-golf-shoes', 2, 15),
    ('https://justgolfstuff.ca/collections/cart-bags', 3, 15)
]

# Lock for thread-safe printing
print_lock = Lock()

def thread_safe_print(message):
    """Thread-safe print function"""
    with print_lock:
        print(message)

def clean_text(text):
    """Clean and escape text for SQL"""
    if not text:
        return ''
    text = ' '.join(text.split())
    text = text.replace("'", "''")
    return text

def extract_price(price_text):
    """Extract numeric price from text"""
    if not price_text:
        return 0.00
    match = re.search(r'[\d,]+\.?\d*', price_text.replace(',', ''))
    if match:
        return float(match.group())
    return 0.00

def scrape_product_page(url):
    """Scrape individual product page for details"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.content, 'html.parser')
        
        product = {}
        
        # Product name
        name_elem = soup.find('h1', class_='product-single__title') or soup.find('h1')
        product['name'] = clean_text(name_elem.text) if name_elem else 'Unknown Product'
        
        # Price
        price_elem = soup.find('span', class_='product-single__price') or soup.find('span', class_='price')
        if not price_elem:
            price_elem = soup.find('meta', property='og:price:amount')
            if price_elem:
                product['price'] = float(price_elem.get('content', 0))
            else:
                product['price'] = 0.00
        else:
            product['price'] = extract_price(price_elem.text)
        
        # Image URL
        img_elem = soup.find('img', class_='product-featured-img') or soup.find('meta', property='og:image')
        if img_elem:
            if img_elem.name == 'meta':
                product['image'] = img_elem.get('content', '')
            else:
                img_url = img_elem.get('src', '') or img_elem.get('data-src', '')
                if img_url.startswith('//'):
                    img_url = 'https:' + img_url
                elif img_url.startswith('/'):
                    img_url = 'https://justgolfstuff.ca' + img_url
                product['image'] = img_url
        else:
            product['image'] = ''
        
        # Description
        desc_elem = soup.find('div', class_='product-single__description') or soup.find('div', class_='product-description')
        if not desc_elem:
            desc_elem = soup.find('meta', property='og:description')
            if desc_elem:
                product['description'] = clean_text(desc_elem.get('content', ''))
            else:
                product['description'] = ''
        else:
            product['description'] = clean_text(desc_elem.get_text())
        
        if len(product['description']) > 3900:
            product['description'] = product['description'][:3900] + '...'
        
        return product
        
    except Exception as e:
        thread_safe_print(f"Error scraping product {url}: {e}")
        return None

def scrape_collection(url, max_products=15):
    """Scrape products from a collection page"""
    products = []
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.content, 'html.parser')
        
        product_links = []
        
        for selector in ['a.product-card__link', 'a.grid-product__link', '.product-item a', 'a[href*="/products/"]']:
            links = soup.select(selector)
            if links:
                product_links = links
                break
        
        if not product_links:
            all_links = soup.find_all('a', href=True)
            product_links = [link for link in all_links if '/products/' in link['href']]
        
        thread_safe_print(f"Found {len(product_links)} product links in collection")
        
        # Build list of unique product URLs
        seen_urls = set()
        product_urls = []
        for link in product_links:
            if len(product_urls) >= max_products:
                break
            
            href = link.get('href', '')
            if not href or '/products/' not in href:
                continue
            
            if href.startswith('http'):
                product_url = href
            elif href.startswith('/'):
                product_url = 'https://justgolfstuff.ca' + href
            else:
                product_url = 'https://justgolfstuff.ca/' + href
            
            if product_url not in seen_urls:
                seen_urls.add(product_url)
                product_urls.append(product_url)
        
        # Scrape products in parallel
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            future_to_url = {executor.submit(scrape_product_page, url): url for url in product_urls}
            
            for i, future in enumerate(concurrent.futures.as_completed(future_to_url), 1):
                product = future.result()
                if product:
                    products.append(product)
                    thread_safe_print(f"Scraped product {i}/{len(product_urls)}")
        
        return products
        
    except Exception as e:
        thread_safe_print(f"Error scraping collection {url}: {e}")
        return []

def generate_sql_inserts(all_products):
    """Generate SQL INSERT statements"""
    sql_statements = []
    
    for category_id, products in all_products.items():
        for product in products:
            sql = f"""INSERT product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES ('{product['name']}', {category_id}, '{product['description']}', {product['price']:.2f}, '{product['image']}');"""
            sql_statements.append(sql)
    
    return sql_statements

def main(max_products_per_category=15, output_file='golf_products_inserts.sql'):
    print("Starting golf product scraper...")
    print(f"Scraping {max_products_per_category} products per category")
    print("=" * 60)
    
    all_products = {}
    
    # Update categories with custom max_products
    categories_to_scrape = [(url, cat_id, max_products_per_category) for url, cat_id, _ in CATEGORIES]
    
    # Scrape collections in parallel
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        future_to_category = {
            executor.submit(scrape_collection, url, max_prods): (url, cat_id)
            for url, cat_id, max_prods in categories_to_scrape
        }
        
        for future in concurrent.futures.as_completed(future_to_category):
            url, category_id = future_to_category[future]
            try:
                products = future.result()
                if category_id not in all_products:
                    all_products[category_id] = []
                all_products[category_id].extend(products)
                print(f"\nCompleted category {category_id}: {url}")
                print(f"Scraped {len(products)} products")
            except Exception as e:
                print(f"Error processing category {url}: {e}")
    
    # Generate SQL
    print("\n" + "=" * 60)
    print("Generating SQL INSERT statements...")
    sql_statements = generate_sql_inserts(all_products)
    
    # Write to file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- Generated Golf Product Inserts\n")
        f.write(f"-- Total products: {len(sql_statements)}\n\n")
        for sql in sql_statements:
            f.write(sql + '\n')
    
    print(f"Successfully generated {len(sql_statements)} SQL INSERT statements")
    print(f"Output saved to: {output_file}")
    
    # Print summary
    print("\nSummary by category:")
    for category_id, products in all_products.items():
        category_names = {1: 'Apparel', 2: 'Footwear', 3: 'Equipment'}
        print(f"  Category {category_id} ({category_names.get(category_id, 'Unknown')}): {len(products)} products")

if __name__ == '__main__':
    # Run test with 3 products first
    print("RUNNING TEST MODE - 3 PRODUCTS PER CATEGORY")
    print("=" * 60)
    main(max_products_per_category=3, output_file='golf_products_test.sql')
    
    print("\n\n" + "=" * 60)
    print("TEST COMPLETE! Check 'golf_products_test.sql'")
    print("If results look good, uncomment the line below to run full scrape")
    print("=" * 60)
    
    # Uncomment this line after testing to run full scrape:
    main(max_products_per_category=15, output_file='golf_products_inserts.sql')