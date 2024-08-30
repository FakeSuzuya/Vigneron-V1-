CREATE TABLE `user_inventory` (
  `identifier` VARCHAR(64) NOT NULL,
  `item` VARCHAR(50) NOT NULL,
  `count` INT NOT NULL DEFAULT 0,
  `quality` INT DEFAULT 0,
  PRIMARY KEY (`identifier`, `item`)
);


CREATE TABLE `jobs` (
  `name` VARCHAR(50) NOT NULL,
  `label` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`name`)
);

-- Insertion du job "vigneron"
INSERT INTO `jobs` (`name`, `label`) VALUES
('vigneron', 'Vigneron');


CREATE TABLE IF NOT EXISTS `job_grades` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job_name` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NOT NULL,
    `salary` INT NOT NULL,
    `skin_male` TEXT DEFAULT NULL,
    `skin_female` TEXT DEFAULT NULL,
    FOREIGN KEY (`job_name`) REFERENCES `jobs`(`name`) ON DELETE CASCADE
);

ALTER TABLE `job_grades`
MODIFY COLUMN `skin_male` TEXT DEFAULT NULL,
MODIFY COLUMN `skin_female` TEXT DEFAULT NULL;

-- Insertion des grades pour le job "vigneron"
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
(12, 'vigneron', 0, 'trainee', 'Trainee', 500, NULL, NULL),
(13, 'vigneron', 1, 'worker', 'Worker', 800, NULL, NULL),
(14, 'vigneron', 2, 'manager', 'Manager', 1200, NULL, NULL);




CREATE TABLE IF NOT EXISTS `user_vigneron` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(255) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `job_grade` INT NOT NULL,
    `service_time` INT DEFAULT 0,
    `last_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`identifier`) REFERENCES `users`(`identifier`) ON DELETE CASCADE,
    FOREIGN KEY (`job_grade`) REFERENCES `job_grades`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE IF NOT EXISTS `items` (
    `name` VARCHAR(50) NOT NULL PRIMARY KEY,
    `label` VARCHAR(50) NOT NULL,
    `weight` INT NOT NULL
);

-- Insertion des items pour le job "vigneron"
INSERT INTO `items` (`name`, `label`, `weight`) VALUES
('grape', 'Grape', 1),
('wine', 'Wine', 1),
('storage_key', 'Storage Key', 0);

INSERT INTO `items` (`name`, `label`, `weight`) VALUES
('grape_basic', 'Grappe de Raisin Basique', 1),
('grape_good', 'Grappe de Raisin de Bonne Qualité', 1),
('grape_premium', 'Grappe de Raisin Premium', 1),
('secateur', 'Sécateur', 1),
('vigneron_xp', 'Expérience Vigneron', 0);  -- Item virtuel pour stocker l'XP
