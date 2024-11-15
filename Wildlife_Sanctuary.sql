CREATE DATABASE wildlife_sanctuary;
USE wildlife_sanctuary;

CREATE TABLE habitat (
    habitat_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    officer_id INT,
    FOREIGN KEY (officer_id) REFERENCES wildlife_officers(officer_id) ON DELETE SET NULL,
    habitat_description TEXT
);

CREATE TABLE tour_guide (
    guide_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    age INT NOT NULL CHECK (age > 0),
    gender ENUM('male', 'female') DEFAULT 'male',
    years_of_experience INT NOT NULL CHECK (years_of_experience >= 0),
    phone_number VARCHAR(25),
    package_id INT,
    FOREIGN KEY (package_id) REFERENCES package(package_id) ON DELETE SET NULL
);

CREATE TABLE package (
    package_id INT PRIMARY KEY AUTO_INCREMENT,
    package_name VARCHAR(100) NOT NULL,
    guide_id INT,
    guide_name VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (guide_id) REFERENCES tour_guide(guide_id) ON DELETE SET NULL
);

CREATE TABLE wildlife_officers (
    officer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    age INT NOT NULL CHECK (age > 0),
    gender ENUM('male', 'female') DEFAULT 'male',
    address VARCHAR(100),
    certificate VARCHAR(100),
    phone_number VARCHAR(25),
    habitat_id INT,
    FOREIGN KEY (habitat_id) REFERENCES habitat(habitat_id) ON DELETE SET NULL
);

CREATE TABLE species (
    species_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    species_number INT NOT NULL CHECK (species_number >= 0),
    population INT NOT NULL CHECK (population >= 0),
    food_chain ENUM('herbivore', 'carnivore', 'omnivore'),
    habitat_id INT,
    officer_id INT,
    FOREIGN KEY (habitat_id) REFERENCES habitat(habitat_id) ON DELETE SET NULL,
    FOREIGN KEY (officer_id) REFERENCES wildlife_officers(officer_id) ON DELETE SET NULL
);

CREATE TABLE facilities_and_stalls (
    facility_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    opening_hours VARCHAR(50),
    stall_type ENUM('food', 'souvenir', 'information') DEFAULT NULL,
    habitat_id INT,
    FOREIGN KEY (habitat_id) REFERENCES habitat(habitat_id) ON DELETE SET NULL
);

CREATE TABLE package_habitat (
    package_id INT,
    habitat_id INT,
    FOREIGN KEY (package_id) REFERENCES package(package_id) ON DELETE CASCADE,
    FOREIGN KEY (habitat_id) REFERENCES habitat(habitat_id) ON DELETE CASCADE
);

CREATE TABLE tourist (
    tourist_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    age INT NOT NULL CHECK (age > 0),
    gender ENUM('male', 'female') DEFAULT 'male',
    phone_no VARCHAR(25),
    visit_date DATE,
    package_id INT,
    FOREIGN KEY (package_id) REFERENCES package(package_id) ON DELETE SET NULL
);

SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO tour_guide (name, age, gender, years_of_experience, phone_number, package_id)
VALUES 
('A', 35, 'male', 10, '123-456-7890', 1),  
('B', 28, 'female', 5, '234-567-8901', 2),  
('C', 45, 'male', 20, '345-678-9012', 3),  
('D', 30, 'female', 7, '456-789-0123', 4),   
('E', 38, 'male', 12, '567-890-1234', 5),  
('F', 25, 'female', 3, '678-901-2345', 6);    

INSERT INTO habitat (name, habitat_description , officer_id)
VALUES 
('Savannah', 'A large grassland area with sparse trees, home to species like lions, elephants, and zebras.',  1),
('Rainforest', 'Dense tropical forest with rich biodiversity, including exotic birds, primates, and insects.',  2),
('Desert', 'Arid region with extreme temperatures and unique wildlife, including camels, snakes, and scorpions.',  3),
('Wetlands', 'Water-rich ecosystem supporting diverse aquatic life and migratory birds, such as herons and frogs.',  4),
('Mountain', 'High-altitude terrain with rocky slopes and cold climates, home to mountain goats and eagles.', 5),
('Coral Reef', 'Colorful underwater habitat hosting a variety of marine life, including fish, corals, and sea turtles.', 6);

INSERT INTO package (package_name, guide_id, guide_name, price)
VALUES 
('U', 1, 'A', 150.00),
('V', 2, 'B', 200.00),
('W', 3, 'C', 180.00),
('X', 4, 'D', 175.00),
('Y', 5, 'E', 220.00),
('Z', 6, 'F', 250.00);

INSERT INTO package_habitat (package_id, habitat_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 2),
    (2, 4),
    (3, 3),
    (3, 1),
    (4, 4),
    (4, 5),
    (5, 5),
    (5, 1),
    (6, 6),
    (6, 3);

INSERT INTO wildlife_officers (name, age, gender, address, certificate, phone_number, habitat_id)
VALUES 
('john', 40, 'male', '123 forest rd', 'wildlife conservation', '555-1234', 1),
('emily', 35, 'female', '456 river ln', 'animal behavior', '555-5678', 2),
('mike', 50, 'male', '789 desert st', 'ecosystem management', '555-9012', 3),
('sarah', 29, 'female', '321 wetlands blvd', 'aquatic life', '555-3456', 4),
('leo', 45, 'male', '654 mountain ave', 'highland wildlife', '555-7890', 5),
('zoe', 33, 'female', '987 ocean dr', 'marine biology', '555-2345', 6);

INSERT INTO species (name, description, species_number, population, food_chain, habitat_id, officer_id)
VALUES 
('lion', 'large carnivorous feline, apex predator', 1, 20, 'carnivore', 1, 1),
('elephant', 'largest land animal, herbivore', 2, 30, 'herbivore', 1, 1),
('toucan', 'brightly colored bird with a large beak', 3, 15, 'omnivore', 2, 2),
('monkey', 'intelligent primate, social animal', 4, 50, 'omnivore', 2, 2),
('camel', 'adapted to desert life, stores fat in humps', 5, 10, 'herbivore', 3, 3),
('scorpion', 'venomous arachnid adapted to dry conditions', 6, 100, 'carnivore', 3, 3),
('heron', 'wading bird, excellent hunter in water', 7, 25, 'carnivore', 4, 4),
('frog', 'amphibian, indicator species for water health', 8, 200, 'carnivore', 4, 4),
('mountain goat', 'sure-footed animal, lives in rugged terrain', 9, 12, 'herbivore', 5, 5),
('eagle', 'large bird of prey, apex predator', 10, 8, 'carnivore', 5, 5),
('clownfish', 'brightly colored fish, forms symbiosis with anemones', 11, 60, 'omnivore', 6, 6),
('sea turtle', 'marine reptile, long lifespan', 12, 5, 'herbivore', 6, 6);

INSERT INTO facilities_and_stalls (name, description, opening_hours, stall_type, habitat_id)
VALUES 
('savannah grill', 'food stall serving local and continental meals', '9:00 am - 5:00 pm', 'food', 1),
('rainforest souvenirs', 'sells unique rainforest-themed memorabilia', '8:00 am - 6:00 pm', 'souvenir', 2),
('desert guide center', 'provides information on desert habitats', '7:00 am - 7:00 pm', 'information', 3),
('wetland eats', 'serves organic meals with fresh ingredients', '10:00 am - 6:00 pm', 'food', 4),
('mountain memories', 'souvenir shop with highland-themed items', '8:00 am - 6:00 pm', 'souvenir', 5),
('reef info center', 'offers information about marine conservation', '8:00 am - 5:00 pm', 'information', 6);

DELIMITER //

CREATE PROCEDURE get_most_popular_packages(IN n INT)
BEGIN
    SELECT p.package_id, p.package_name, COUNT(t.tourist_id) AS tourists_count
    FROM package p
    LEFT JOIN tourist t ON p.package_id = t.package_id
    GROUP BY p.package_id, p.package_name
    ORDER BY tourists_count DESC
    LIMIT n;
END //

DELIMITER ;

DELIMITER $$

CREATE TRIGGER increment_package_popularity
AFTER INSERT ON tourist
FOR EACH ROW
BEGIN
    UPDATE package
    SET popularity = popularity + 1
    WHERE package_id = NEW.package_id;
END$$

DELIMITER ;

-- Create users for wildlife officers and grant permissions
CREATE USER 'o1'@'%' IDENTIFIED BY 'password1';
CREATE USER 'o2'@'%' IDENTIFIED BY 'password2';
CREATE USER 'o3'@'%' IDENTIFIED BY 'password3';
CREATE USER 'o4'@'%' IDENTIFIED BY 'password4';
CREATE USER 'o5'@'%' IDENTIFIED BY 'password5';
CREATE USER 'o6'@'%' IDENTIFIED BY 'password6';

-- Grant permissions for wildlife officers
GRANT EXECUTE ON PROCEDURE WILDLIFE_SANCTUARY.get_most_popular_packages TO 'o1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'o1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.habitat TO 'o1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.species TO 'o1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package TO 'o1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package_habitat TO 'o1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'o1'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'o1'@'%';
GRANT SELECT ON wildlife_sanctuary.wildlife_officers TO 'o1'@'%';
GRANT EXECUTE ON PROCEDURE WILDLIFE_SANCTUARY.reset_package_popularity TO 'o1'@'%';

-- Repeat for other officers
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'o2'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.habitat TO 'o2'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.species TO 'o2'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package TO 'o2'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package_habitat TO 'o2'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'o2'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'o2'@'%';
GRANT SELECT ON wildlife_sanctuary.wildlife_officers TO 'o2'@'%';
GRANT EXECUTE ON PROCEDURE WILDLIFE_SANCTUARY.reset_package_popularity TO 'o2'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'o3'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.habitat TO 'o3'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.species TO 'o3'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package TO 'o3'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package_habitat TO 'o3'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'o3'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'o3'@'%';
GRANT SELECT ON wildlife_sanctuary.wildlife_officers TO 'o3'@'%';
GRANT EXECUTE ON PROCEDURE WILDLIFE_SANCTUARY.reset_package_popularity TO 'o3'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'o4'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.habitat TO 'o4'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.species TO 'o4'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package TO 'o4'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package_habitat TO 'o4'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'o4'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'o4'@'%';
GRANT SELECT ON wildlife_sanctuary.wildlife_officers TO 'o4'@'%';
GRANT EXECUTE ON PROCEDURE WILDLIFE_SANCTUARY.reset_package_popularity TO 'o4'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'o5'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.habitat TO 'o5'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.species TO 'o5'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package TO 'o5'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package_habitat TO 'o5'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'o5'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'o5'@'%';
GRANT SELECT ON wildlife_sanctuary.wildlife_officers TO 'o5'@'%';
GRANT EXECUTE ON PROCEDURE WILDLIFE_SANCTUARY.reset_package_popularity TO 'o5'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'o6'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.habitat TO 'o6'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.species TO 'o6'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package TO 'o6'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.package_habitat TO 'o6'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'o6'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'o6'@'%';
GRANT SELECT ON wildlife_sanctuary.wildlife_officers TO 'o6'@'%';
GRANT EXECUTE ON PROCEDURE WILDLIFE_SANCTUARY.reset_package_popularity TO 'o6'@'%';

-- Create users for tour guides and grant permissions
CREATE USER 'tg1'@'%' IDENTIFIED BY 'password1';
CREATE USER 'tg2'@'%' IDENTIFIED BY 'password2';
CREATE USER 'tg3'@'%' IDENTIFIED BY 'password3';
CREATE USER 'tg4'@'%' IDENTIFIED BY 'password4';
CREATE USER 'tg5'@'%' IDENTIFIED BY 'password5';
CREATE USER 'tg6'@'%' IDENTIFIED BY 'password6';

-- Grant permissions for tour guides
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'tg1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'tg1'@'%';
GRANT SELECT ON wildlife_sanctuary.habitat TO 'tg1'@'%';
GRANT SELECT ON wildlife_sanctuary.species TO 'tg1'@'%';
GRANT SELECT ON wildlife_sanctuary.package TO 'tg1'@'%';
GRANT SELECT ON wildlife_sanctuary.package_habitat TO 'tg1'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'tg1'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'tg2'@'%';	
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'tg2'@'%';
GRANT SELECT ON wildlife_sanctuary.habitat TO 'tg2'@'%';
GRANT SELECT ON wildlife_sanctuary.species TO 'tg2'@'%';
GRANT SELECT ON wildlife_sanctuary.package TO 'tg2'@'%';
GRANT SELECT ON wildlife_sanctuary.package_habitat TO 'tg2'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'tg2'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'tg3'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'tg3'@'%';
GRANT SELECT ON wildlife_sanctuary.habitat TO 'tg3'@'%';
GRANT SELECT ON wildlife_sanctuary.species TO 'tg3'@'%';
GRANT SELECT ON wildlife_sanctuary.package TO 'tg3'@'%';
GRANT SELECT ON wildlife_sanctuary.package_habitat TO 'tg3'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'tg3'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'tg4'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'tg4'@'%';
GRANT SELECT ON wildlife_sanctuary.habitat TO 'tg4'@'%';
GRANT SELECT ON wildlife_sanctuary.species TO 'tg4'@'%';
GRANT SELECT ON wildlife_sanctuary.package TO 'tg4'@'%';
GRANT SELECT ON wildlife_sanctuary.package_habitat TO 'tg4'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'tg4'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'tg5'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'tg5'@'%';
GRANT SELECT ON wildlife_sanctuary.habitat TO 'tg5'@'%';
GRANT SELECT ON wildlife_sanctuary.species TO 'tg5'@'%';
GRANT SELECT ON wildlife_sanctuary.package TO 'tg5'@'%';
GRANT SELECT ON wildlife_sanctuary.package_habitat TO 'tg5'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'tg5'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.tourist TO 'tg6'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON wildlife_sanctuary.facilities_and_stalls TO 'tg6'@'%';
GRANT SELECT ON wildlife_sanctuary.habitat TO 'tg6'@'%';
GRANT SELECT ON wildlife_sanctuary.species TO 'tg6'@'%';
GRANT SELECT ON wildlife_sanctuary.package TO 'tg6'@'%';
GRANT SELECT ON wildlife_sanctuary.package_habitat TO 'tg6'@'%';
GRANT SELECT ON wildlife_sanctuary.tour_guide TO 'tg6'@'%';

CREATE USER 'tourist'@'%' IDENTIFIED BY 'tour';
GRANT INSERT ON wildlife_sanctuary.tourist TO 'tourist'@'%';
GRANT SELECT ON wildlife_sanctuary.facilities_and_stalls TO 'tourist'@'%';
GRANT SELECT ON wildlife_sanctuary.habitat TO 'tourist'@'%';
GRANT SELECT ON wildlife_sanctuary.species TO 'tourist'@'%';
GRANT SELECT ON wildlife_sanctuary.package TO 'tourist'@'%';
GRANT SELECT ON wildlife_sanctuary.package_habitat TO 'tourist'@'%';

DELIMITER //
CREATE TRIGGER limit_tourists_per_day
BEFORE INSERT ON tourist
FOR EACH ROW
BEGIN
    DECLARE tourist_count INT;
    DECLARE tour_guide_limit INT;

    SELECT COUNT(*) INTO tour_guide_limit
    FROM tour_guide;

    SELECT COUNT(*) INTO tourist_count
    FROM tourist
    WHERE visit_date = NEW.visit_date;

    IF tourist_count >= tour_guide_limit THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tourist limit for the day reached (based on number of tour guides)';
    END IF;
END//

DELIMITER ;

ALTER TABLE tourist
    ADD COLUMN minimum_age INT,
    ADD COLUMN maximum_age INT,
    ADD COLUMN total_people_in_group INT,
    DROP COLUMN age,
    DROP COLUMN gender;

DELIMITER //

CREATE TRIGGER check_age_range_update
BEFORE UPDATE ON tourist
FOR EACH ROW
BEGIN
    IF NEW.minimum_age > NEW.maximum_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: minimum_age cannot be greater than maximum_age';
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER check_min_max_age
BEFORE INSERT ON tourist
FOR EACH ROW
BEGIN
    IF NEW.minimum_age < 5 OR NEW.maximum_age < 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: minimum_age and maximum_age cannot be less than 5';
    END IF;
END//

DELIMITER ;

ALTER TABLE tourist
ADD COLUMN total_cost DECIMAL(10, 2);

DELIMITER //

CREATE TRIGGER limit_group_size
BEFORE INSERT ON tourist
FOR EACH ROW
BEGIN
    -- Check if the total_people_in_group is more than 10
    IF NEW.total_people_in_group > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Group size cannot exceed 10 people.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER check_package_id_exists
BEFORE INSERT ON tourist
FOR EACH ROW
BEGIN
    -- Check if the package_id exists in the package table
    DECLARE package_count INT;
    SELECT COUNT(*) INTO package_count
    FROM package
    WHERE package_id = NEW.package_id;
    
    -- If package_id does not exist, raise an error
    IF package_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid package_id. Package does not exist.';
    END IF;
END //

DELIMITER ;

ALTER TABLE package
ADD COLUMN popularity INT DEFAULT 0;

DELIMITER $$

CREATE PROCEDURE reset_package_popularity(IN package_id_input INT)
BEGIN
    -- Check if the package exists
    IF EXISTS (SELECT 1 FROM package WHERE package_id = package_id_input) THEN
        -- Reset popularity to 0
        UPDATE package
        SET popularity = 0
        WHERE package_id = package_id_input;

        SELECT CONCAT('Popularity for package ID ', package_id_input, ' has been reset to 0.') AS message;
    ELSE
        -- Handle case where package_id does not exist
        SELECT CONCAT('Error: Package ID ', package_id_input, ' does not exist.') AS message;
    END IF;
END$$

DELIMITER ;

