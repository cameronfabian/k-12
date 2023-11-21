CREATE TABLE Users (
    UserID INT PRIMARY KEY auto_increment,
    Username VARCHAR(50) UNIQUE,
    Password VARCHAR(255),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Access ENUM('student', 'teacher', 'admin') DEFAULT 'student'
);

CREATE TABLE Teachers (
	TeacherID INT PRIMARY KEY auto_increment,
    UserID INT unique,
    Course VARCHAR(100), 
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
    );
    
CREATE TABLE Students (
	StudentID INT PRIMARY KEY auto_increment,
    UserID INT unique,
    LetterGrade varchar(10),
    GradeLevel varchar(10),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
    );
    
CREATE USER 'admin'@'localhost';
CREATE USER 'teacher'@'localhost';
CREATE USER 'student'@'localhost';

GRANT ALL PRIVILEGES ON MyDb.* TO 'admin'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON MyDb.* TO 'teacher'@'localhost';
GRANT SELECT, INSERT, UPDATE ON MyDb.* TO 'student'@'localhost';

DELIMITER //

CREATE PROCEDURE GrantPermissions(IN p_Username VARCHAR(50), IN p_Access ENUM('student', 'teacher', 'admin'))
BEGIN
    DECLARE UserID INT;

    -- Get the UserID for the given username
    SELECT UserID INTO UserID FROM Users WHERE Username = p_Username;

    -- Check if the user exists
    IF UserID IS NOT NULL THEN
        -- Revoke any existing privileges
        REVOKE ALL PRIVILEGES ON MyDb.* FROM p_Username;

        -- Grant permissions based on the user's access level
        CASE p_Access
            WHEN 'admin' THEN
                SET @sql = CONCAT('GRANT ALL PRIVILEGES ON MyDb.* TO ''', p_Username, '''@''localhost''');
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            WHEN 'teacher' THEN
                SET @sql = CONCAT('GRANT SELECT, INSERT, UPDATE, DELETE ON MyDb.* TO ''', p_Username, '''@''localhost''');
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            WHEN 'student' THEN
                SET @sql = CONCAT('GRANT SELECT, INSERT, UPDATE ON MyDb.* TO ''', p_Username, '''@''localhost''');
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid access level';
        END CASE;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
    END IF;
END //

DELIMITER ;

-- Call the procedure to grant permissions, replace the _user part with actual username. We might not need this IDK :)
CALL GrantPermissions('admin_user', 'admin');
CALL GrantPermissions('teacher_user', 'teacher');
CALL GrantPermissions('student_user', 'student');

