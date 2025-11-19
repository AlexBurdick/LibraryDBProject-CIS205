-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Library_Management
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `Library_Management` ;

-- -----------------------------------------------------
-- Schema Library_Management
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Library_Management` DEFAULT CHARACTER SET utf8 ;
USE `Library_Management` ;

-- -----------------------------------------------------
-- Table `Employee`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Employee` ;

CREATE TABLE IF NOT EXISTS `Employee` (
  `idEmployee` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `role` VARCHAR(45) NOT NULL,
  `start_date` DATE NOT NULL,
  `phone` VARCHAR(10) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `city` VARCHAR(45) NOT NULL,
  `state` VARCHAR(45) NOT NULL,
  `zip` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`idEmployee`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Reading_Level`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Reading_Level` ;

CREATE TABLE IF NOT EXISTS `Reading_Level` (
  `idReading_Level` INT NOT NULL AUTO_INCREMENT,
  `reading_level` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idReading_Level`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Section`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Section` ;

CREATE TABLE IF NOT EXISTS `Section` (
  `idSection` INT NOT NULL AUTO_INCREMENT,
  `genre` VARCHAR(45) NULL,
  `name` VARCHAR(45) NOT NULL,
  `Reading_Level_id` INT NOT NULL,
  PRIMARY KEY (`idSection`),
  INDEX `fk_Section_Reading_Level1_idx` (`Reading_Level_id` ASC) VISIBLE,
  CONSTRAINT `fk_Section_Reading_Level1`
    FOREIGN KEY (`Reading_Level_id`)
    REFERENCES `Reading_Level` (`idReading_Level`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Book`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Book` ;

CREATE TABLE IF NOT EXISTS `Book` (
  `idBook` INT NOT NULL AUTO_INCREMENT,
  `employeeID` INT NOT NULL,
  `Reading_Level_idReading_Level` INT NOT NULL,
  `Section_idSection` INT NULL,
  `title` VARCHAR(200) NOT NULL,
  `publication_date` DATE NULL,
  `introduce_date` DATE NOT NULL,
  `language` VARCHAR(45) NOT NULL,
  `genre` VARCHAR(45) NULL,
  PRIMARY KEY (`idBook`),
  INDEX `fk_Book_Employee_idx` (`employeeID` ASC) VISIBLE,
  INDEX `fk_Book_Reading_Level1_idx` (`Reading_Level_idReading_Level` ASC) VISIBLE,
  INDEX `fk_Book_Section1_idx` (`Section_idSection` ASC) VISIBLE,
  CONSTRAINT `fk_Book_Employee`
    FOREIGN KEY (`employeeID`)
    REFERENCES `Employee` (`idEmployee`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Book_Reading_Level1`
    FOREIGN KEY (`Reading_Level_idReading_Level`)
    REFERENCES `Reading_Level` (`idReading_Level`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Book_Section1`
    FOREIGN KEY (`Section_idSection`)
    REFERENCES `Section` (`idSection`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Author`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Author` ;

CREATE TABLE IF NOT EXISTS `Author` (
  `idAuthor` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  `birth_date` DATE NULL,
  `death_date` DATE NULL,
  PRIMARY KEY (`idAuthor`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Reader`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Reader` ;

CREATE TABLE IF NOT EXISTS `Reader` (
  `idReader` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `phone` VARCHAR(10) NULL,
  `email` VARCHAR(45) NULL,
  `street_address` VARCHAR(100) NULL,
  `city` VARCHAR(45) NULL,
  `state` VARCHAR(45) NULL,
  `zip` VARCHAR(5) NULL,
  PRIMARY KEY (`idReader`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Checkout`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Checkout` ;

CREATE TABLE IF NOT EXISTS `Checkout` (
  `idCheckout` INT NOT NULL AUTO_INCREMENT,
  `Book_idBook` INT NOT NULL,
  `Reader_idReader` INT NOT NULL,
  `checkout_date` DATE NOT NULL,
  `due_date` DATE NOT NULL,
  `return_date` DATE NULL,
  `condition_returned` VARCHAR(45) NOT NULL,
  INDEX `fk_Book_has_Reader_Reader1_idx` (`Reader_idReader` ASC) VISIBLE,
  INDEX `fk_Book_has_Reader_Book1_idx` (`Book_idBook` ASC) VISIBLE,
  PRIMARY KEY (`idCheckout`),
  CONSTRAINT `fk_Book_has_Reader_Book1`
    FOREIGN KEY (`Book_idBook`)
    REFERENCES `Book` (`idBook`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Book_has_Reader_Reader1`
    FOREIGN KEY (`Reader_idReader`)
    REFERENCES `Reader` (`idReader`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Book_has_Author`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Book_has_Author` ;

CREATE TABLE IF NOT EXISTS `Book_has_Author` (
  `Book_idBook` INT NOT NULL,
  `Author_idAuthor` INT NOT NULL,
  PRIMARY KEY (`Book_idBook`, `Author_idAuthor`),
  INDEX `fk_Book_has_Author_Author1_idx` (`Author_idAuthor` ASC) VISIBLE,
  INDEX `fk_Book_has_Author_Book1_idx` (`Book_idBook` ASC) VISIBLE,
  CONSTRAINT `fk_Book_has_Author_Book1`
    FOREIGN KEY (`Book_idBook`)
    REFERENCES `Book` (`idBook`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Book_has_Author_Author1`
    FOREIGN KEY (`Author_idAuthor`)
    REFERENCES `Author` (`idAuthor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
