-- ============================================================
-- AIRBNB GLOBAL MALE DASHBOARD - SQL QUERIES
-- Dataset: Listings.csv + Reviews.csv
-- ============================================================


-- ============================================================
-- STEP 1: CREATE TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS listings (
    listing_id BIGINT PRIMARY KEY,
    name TEXT,
    host_id BIGINT,
    host_since DATE,
    host_location TEXT,
    host_response_time TEXT,
    host_response_rate TEXT,
    host_acceptance_rate TEXT,
    host_is_superhost BOOLEAN,
    host_total_listings_count INT,
    host_has_profile_pic BOOLEAN,
    host_identity_verified BOOLEAN,
    neighbourhood TEXT,
    district TEXT,
    city TEXT,
    latitude FLOAT,
    longitude FLOAT,
    property_type TEXT,
    room_type TEXT,
    accommodates INT,
    bedrooms INT,
    amenities TEXT,
    price FLOAT,
    minimum_nights INT,
    maximum_nights INT,
    review_scores_rating FLOAT,
    review_scores_accuracy FLOAT,
    review_scores_cleanliness FLOAT,
    review_scores_checkin FLOAT,
    review_scores_communication FLOAT,
    review_scores_location FLOAT,
    review_scores_value FLOAT,
    instant_bookable BOOLEAN
);

CREATE TABLE IF NOT EXISTS reviews (
    listing_id BIGINT,
    review_id BIGINT PRIMARY KEY,
    date DATE,
    reviewer_id BIGINT
);


-- ============================================================
-- STEP 2: KPI QUERIES (Top Cards on Dashboard)
-- ============================================================

-- Total Listings
SELECT COUNT(*) AS total_listings
FROM listings;

-- Total Cities
SELECT COUNT(DISTINCT city) AS total_cities
FROM listings;

-- Average Price
SELECT ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM listings;

-- Average Review Score Rating
SELECT ROUND(AVG(review_scores_rating)::NUMERIC, 2) AS avg_rating
FROM listings
WHERE review_scores_rating IS NOT NULL;

-- Total Superhosts
SELECT COUNT(*) AS total_superhosts
FROM listings
WHERE host_is_superhost = TRUE;

-- Total Reviews
SELECT COUNT(*) AS total_reviews
FROM reviews;


-- ============================================================
-- STEP 3: PRICE ANALYSIS
-- ============================================================

-- Average Price by City
SELECT city,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
       COUNT(*) AS total_listings
FROM listings
GROUP BY city
ORDER BY avg_price DESC;

-- Average Price by Room Type
SELECT room_type,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
       COUNT(*) AS total_listings
FROM listings
GROUP BY room_type
ORDER BY avg_price DESC;

-- Average Price by Property Type
SELECT property_type,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
       COUNT(*) AS total_listings
FROM listings
GROUP BY property_type
ORDER BY avg_price DESC
LIMIT 10;

-- Price Range Distribution
SELECT 
    CASE 
        WHEN price < 50 THEN 'Under $50'
        WHEN price BETWEEN 50 AND 100 THEN '$50 - $100'
        WHEN price BETWEEN 101 AND 200 THEN '$101 - $200'
        WHEN price BETWEEN 201 AND 500 THEN '$201 - $500'
        ELSE 'Above $500'
    END AS price_range,
    COUNT(*) AS total_listings
FROM listings
GROUP BY price_range
ORDER BY total_listings DESC;


-- ============================================================
-- STEP 4: HOST ANALYSIS
-- ============================================================

-- Superhost vs Non-Superhost Count
SELECT 
    CASE WHEN host_is_superhost = TRUE THEN 'Superhost' ELSE 'Regular Host' END AS host_type,
    COUNT(*) AS total_hosts,
    ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
    ROUND(AVG(review_scores_rating)::NUMERIC, 2) AS avg_rating
FROM listings
GROUP BY host_is_superhost;

-- Top 10 Hosts by Number of Listings
SELECT host_id,
       host_location,
       COUNT(*) AS total_listings,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM listings
GROUP BY host_id, host_location
ORDER BY total_listings DESC
LIMIT 10;

-- Host Growth Over Years (hosts joined per year)
SELECT EXTRACT(YEAR FROM host_since) AS year,
       COUNT(DISTINCT host_id) AS new_hosts
FROM listings
WHERE host_since IS NOT NULL
GROUP BY year
ORDER BY year;

-- Response Time Distribution
SELECT host_response_time,
       COUNT(*) AS total_listings
FROM listings
WHERE host_response_time IS NOT NULL
GROUP BY host_response_time
ORDER BY total_listings DESC;


-- ============================================================
-- STEP 5: REVIEW ANALYSIS
-- ============================================================

-- Total Reviews Per Year
SELECT EXTRACT(YEAR FROM date) AS year,
       COUNT(*) AS total_reviews
FROM reviews
GROUP BY year
ORDER BY year;

-- Total Reviews Per Month (Trend)
SELECT TO_CHAR(date, 'YYYY-MM') AS month,
       COUNT(*) AS total_reviews
FROM reviews
GROUP BY month
ORDER BY month;

-- Top 10 Most Reviewed Listings
SELECT l.listing_id,
       l.name,
       l.city,
       l.price,
       COUNT(r.review_id) AS total_reviews
FROM listings l
JOIN reviews r ON l.listing_id = r.listing_id
GROUP BY l.listing_id, l.name, l.city, l.price
ORDER BY total_reviews DESC
LIMIT 10;

-- Average Reviews per Listing by City
SELECT l.city,
       COUNT(r.review_id) AS total_reviews,
       COUNT(DISTINCT l.listing_id) AS total_listings,
       ROUND((COUNT(r.review_id)::NUMERIC / COUNT(DISTINCT l.listing_id)), 2) AS avg_reviews_per_listing
FROM listings l
LEFT JOIN reviews r ON l.listing_id = r.listing_id
GROUP BY l.city
ORDER BY avg_reviews_per_listing DESC;


-- ============================================================
-- STEP 6: NEIGHBOURHOOD & LOCATION ANALYSIS
-- ============================================================

-- Top 10 Neighbourhoods by Listings
SELECT neighbourhood,
       city,
       COUNT(*) AS total_listings,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM listings
WHERE neighbourhood IS NOT NULL
GROUP BY neighbourhood, city
ORDER BY total_listings DESC
LIMIT 10;

-- Listings by City
SELECT city,
       COUNT(*) AS total_listings,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
       ROUND(AVG(review_scores_rating)::NUMERIC, 2) AS avg_rating
FROM listings
GROUP BY city
ORDER BY total_listings DESC;


-- ============================================================
-- STEP 7: ROOM TYPE & PROPERTY ANALYSIS
-- ============================================================

-- Listings by Room Type
SELECT room_type,
       COUNT(*) AS total_listings,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
       ROUND(AVG(review_scores_rating)::NUMERIC, 2) AS avg_rating
FROM listings
GROUP BY room_type
ORDER BY total_listings DESC;

-- Listings by Property Type (Top 10)
SELECT property_type,
       COUNT(*) AS total_listings,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM listings
GROUP BY property_type
ORDER BY total_listings DESC
LIMIT 10;

-- Accommodates Distribution
SELECT accommodates,
       COUNT(*) AS total_listings,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM listings
GROUP BY accommodates
ORDER BY accommodates;


-- ============================================================
-- STEP 8: REVIEW SCORES ANALYSIS
-- ============================================================

-- Average Review Scores by City
SELECT city,
       ROUND(AVG(review_scores_rating)::NUMERIC, 2) AS avg_rating,
       ROUND(AVG(review_scores_cleanliness)::NUMERIC, 2) AS avg_cleanliness,
       ROUND(AVG(review_scores_location)::NUMERIC, 2) AS avg_location,
       ROUND(AVG(review_scores_value)::NUMERIC, 2) AS avg_value,
       ROUND(AVG(review_scores_communication)::NUMERIC, 2) AS avg_communication
FROM listings
GROUP BY city
ORDER BY avg_rating DESC;

-- Average Review Scores by Room Type
SELECT room_type,
       ROUND(AVG(review_scores_rating)::NUMERIC, 2) AS avg_rating,
       ROUND(AVG(review_scores_cleanliness)::NUMERIC, 2) AS avg_cleanliness,
       ROUND(AVG(review_scores_value)::NUMERIC, 2) AS avg_value
FROM listings
GROUP BY room_type
ORDER BY avg_rating DESC;


-- ============================================================
-- STEP 9: INSTANT BOOKABLE ANALYSIS
-- ============================================================

SELECT 
    CASE WHEN instant_bookable = TRUE THEN 'Instant Bookable' ELSE 'Not Instant Bookable' END AS booking_type,
    COUNT(*) AS total_listings,
    ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
    ROUND(AVG(review_scores_rating)::NUMERIC, 2) AS avg_rating
FROM listings
GROUP BY instant_bookable;


-- ============================================================
-- STEP 10: COMBINED / DASHBOARD SUMMARY VIEW
-- ============================================================

-- Full Summary by City (used for comparison table in dashboard)
SELECT 
    l.city,
    COUNT(DISTINCT l.listing_id) AS total_listings,
    COUNT(DISTINCT l.host_id) AS total_hosts,
    SUM(CASE WHEN l.host_is_superhost = TRUE THEN 1 ELSE 0 END) AS superhosts,
    ROUND(AVG(l.price)::NUMERIC, 2) AS avg_price,
    ROUND(AVG(l.review_scores_rating)::NUMERIC, 2) AS avg_rating,
    COUNT(r.review_id) AS total_reviews
FROM listings l
LEFT JOIN reviews r ON l.listing_id = r.listing_id
GROUP BY l.city
ORDER BY total_listings DESC;
