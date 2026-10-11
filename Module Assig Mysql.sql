DROP DATABASE IF EXISTS elearning_db;
CREATE DATABASE learning_db;
USE elearning_db;
DROP DATABASE IF EXISTS elearning_db;
CREATE DATABASE learning_db;
USE learning_db;

CREATE TABLE learners
 (learner_id INT PRIMARY KEY,
full_name  VARCHAR(100) NOT NULL,
country    VARCHAR(50)  NOT NULL);

CREATE TABLE courses
 (course_id   INT PRIMARY KEY,
    course_name VARCHAR(100)  NOT NULL,
    category    VARCHAR(50)   NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL CHECK (unit_price > 1));

CREATE TABLE purchases(
    purchase_id   INT PRIMARY KEY,
    learner_id    INT  NOT NULL,
    course_id     INT  NOT NULL,
    quantity      INT  NOT NULL CHECK (quantity > 0),
    purchase_date DATE NOT NULL,
    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (course_id)  REFERENCES courses(course_id));


INSERT INTO learners (learner_id, full_name, country) VALUES
(1, 'Aarav Sharma',  'India'),
(2, 'Meera Iyer',    'India'),
(3, 'John Carter',   'USA'),
(4, 'Sophie Laurent','France'),
(5, 'Liam O''Connor','Ireland');

INSERT INTO courses (course_id, course_name, category, unit_price) VALUES
(101, 'SQL for Beginners',            'Data Analytics', 49.99),
(102, 'Python Programming',           'Programming',    79.99),
(103, 'Digital Marketing Essentials', 'Marketing',      59.99),
(104, 'Data Visualization (Tableau)', 'Data Analytics', 89.99),
(105, 'UI/UX Design Basics',          'Design',         69.99);

INSERT INTO purchases (purchase_id, learner_id, course_id, quantity, purchase_date) VALUES
(1, 1, 101, 1, '2025-01-10'),
(2, 1, 102, 1, '2025-01-15'),
(3, 2, 101, 2, '2025-02-05'),
(4, 2, 103, 1, '2025-02-18'),
(5, 3, 102, 1, '2025-03-02'),
(6, 3, 104, 1, '2025-03-12'),
(7, 4, 103, 2, '2025-03-20'),
(8, 3, 101, 1, '2025-04-01');

SELECT COUNT(*) FROM learners;  
SELECT COUNT(*) FROM courses;    
SELECT COUNT(*) FROM purchases; 
SELECT * FROM purchases; 




## INNER JOIN – each learner's purchase details

SELECT learners.full_name AS learner_name,
       courses.course_name AS course_name,
       courses.category AS category,
       purchases.quantity AS quantity,
       ROUND(purchases.quantity * courses.unit_price, 2) AS total_amount,
       purchases.purchase_date AS purchase_date FROM purchases
INNER JOIN learners ON purchases.learner_id = learners.learner_id
INNER JOIN courses ON purchases.course_id = courses.course_id
ORDER BY total_amount DESC;

## LEFT JOIN – all learners, even those who bought nothing

SELECT learners.full_name AS learner_name,
       learners.country AS country,
       courses.course_name AS course_name,
       ROUND(purchases.quantity * courses.unit_price, 2) AS total_amount,
       purchases.purchase_date AS purchase_date FROM learners
LEFT JOIN purchases ON learners.learner_id = purchases.learner_id
LEFT JOIN courses ON purchases.course_id = courses.course_id
ORDER BY learners.full_name, purchases.purchase_date;

##RIGHT JOIN – all courses, even those never purchased

SELECT courses.course_name AS course_name,
courses.category AS category,
purchases.purchase_id AS purchase_id,
 purchases.quantity AS quantity FROM purchases
RIGHT JOIN courses ON purchases.course_id = courses.course_id
ORDER BY courses.course_name;

##Q1. Total spending per learner with country

SELECT learners.full_name AS learner_name,
learners.country AS country,ROUND(COALESCE(SUM(purchases.quantity * courses.unit_price), 0), 2)AS total_spent
FROM learners
LEFT JOIN purchases ON learners.learner_id = purchases.learner_id
LEFT JOIN courses ON purchases.course_id = courses.course_id
GROUP BY learners.learner_id, learners.full_name, learners.country
ORDER BY total_spent DESC;

##Top 3 most purchased courses (by quantity sold)

SELECT courses.course_name AS course_name,
SUM(purchases.quantity) AS total_quantity_sold FROM courses
INNER JOIN purchases ON courses.course_id = purchases.course_id
GROUP BY courses.course_id, courses.course_name
ORDER BY total_quantity_sold DESC
LIMIT 3;

##Q3. Category revenue and unique learners

SELECT courses.category AS category,
       ROUND(SUM(purchases.quantity * courses.unit_price), 2) AS total_revenue,
       COUNT(DISTINCT purchases.learner_id) AS unique_learners FROM courses
INNER JOIN purchases ON courses.course_id = purchases.course_id
GROUP BY courses.category
ORDER BY total_revenue DESC;

##Q4. Learners who purchased from more than one category

SELECT learners.full_name AS learner_name,
       COUNT(DISTINCT courses.category) AS categories_purchased FROM learners
INNER JOIN purchases ON learners.learner_id = purchases.learner_id
INNER JOIN courses ON purchases.course_id = courses.course_id
GROUP BY learners.learner_id, learners.full_name
HAVING COUNT(DISTINCT courses.category) > 1
ORDER BY categories_purchased DESC;

##Q5. Courses that have not been purchased

SELECT courses.course_id AS course_id,
       courses.course_name AS course_name,
       courses.category AS category FROM courses
LEFT JOIN purchases ON courses.course_id = purchases.course_id
WHERE purchases.purchase_id IS NULL;

