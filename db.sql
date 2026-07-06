-- ============================================================
-- STUDENT RECORDS MANAGEMENT SYSTEM
-- Core schema: personal details -> classes -> academic portfolio
-- Engine: MySQL 8+
-- ============================================================

CREATE DATABASE IF NOT EXISTS student_records;
USE student_records;

-- ------------------------------------------------------------
-- 1. STUDENTS  (personal details)
-- ------------------------------------------------------------
CREATE TABLE students (
    student_id      INT AUTO_INCREMENT PRIMARY KEY,
    admission_no    VARCHAR(20) NOT NULL UNIQUE,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    date_of_birth   DATE NOT NULL,
    gender          ENUM('M', 'F', 'Other') NOT NULL,
    address         VARCHAR(255),
    admission_date  DATE NOT NULL,
    status          ENUM('active', 'graduated', 'transferred', 'suspended') DEFAULT 'active',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 2. GUARDIANS  (parent/guardian contacts, separate from student)
-- ------------------------------------------------------------
CREATE TABLE guardians (
    guardian_id     INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    relationship    VARCHAR(30) NOT NULL,   -- 'Mother', 'Father', 'Uncle', etc.
    phone_number    VARCHAR(20) NOT NULL,
    email           VARCHAR(100),
    address         VARCHAR(255)
);

-- Junction: a student can have multiple guardians, a guardian can have multiple students (siblings)
CREATE TABLE student_guardians (
    student_id      INT NOT NULL,
    guardian_id     INT NOT NULL,
    is_primary      BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (student_id, guardian_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (guardian_id) REFERENCES guardians(guardian_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 3. ACADEMIC CALENDAR
-- ------------------------------------------------------------
CREATE TABLE academic_years (
    year_id         INT AUTO_INCREMENT PRIMARY KEY,
    year_label      VARCHAR(20) NOT NULL UNIQUE  -- e.g. '2025/2026'
);

CREATE TABLE terms (
    term_id         INT AUTO_INCREMENT PRIMARY KEY,
    year_id         INT NOT NULL,
    term_number     TINYINT NOT NULL,     -- 1, 2, 3
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    FOREIGN KEY (year_id) REFERENCES academic_years(year_id) ON DELETE CASCADE,
    UNIQUE (year_id, term_number)
);

-- ------------------------------------------------------------
-- 4. CLASSES  (e.g. 'Form 2 East')
-- ------------------------------------------------------------
CREATE TABLE classes (
    class_id        INT AUTO_INCREMENT PRIMARY KEY,
    class_name      VARCHAR(50) NOT NULL,   -- 'Form 2', 'Grade 6'
    stream_name     VARCHAR(50),            -- 'East', 'Blue', NULL if no streams
    year_id         INT NOT NULL,           -- which academic year this class instance belongs to
    FOREIGN KEY (year_id) REFERENCES academic_years(year_id) ON DELETE CASCADE
);

-- Which student is in which class, for which academic year
CREATE TABLE enrollments (
    enrollment_id   INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT NOT NULL,
    class_id        INT NOT NULL,
    enrolled_on     DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    UNIQUE (student_id, class_id)
);

-- ------------------------------------------------------------
-- 5. SUBJECTS & TEACHERS
-- ------------------------------------------------------------
CREATE TABLE teachers (
    teacher_id      INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone_number    VARCHAR(20)
);

CREATE TABLE subjects (
    subject_id      INT AUTO_INCREMENT PRIMARY KEY,
    subject_name    VARCHAR(50) NOT NULL UNIQUE,   -- 'Mathematics', 'Biology'
    subject_code    VARCHAR(10) UNIQUE             -- 'MATH101'
);

-- Which teacher teaches which subject to which class
CREATE TABLE class_subject_teacher (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    class_id        INT NOT NULL,
    subject_id      INT NOT NULL,
    teacher_id      INT NOT NULL,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    UNIQUE (class_id, subject_id)
);

-- ------------------------------------------------------------
-- 6. ASSESSMENTS & GRADES  (the academic portfolio)
-- ------------------------------------------------------------
CREATE TABLE assessments (
    assessment_id   INT AUTO_INCREMENT PRIMARY KEY,
    subject_id      INT NOT NULL,
    term_id         INT NOT NULL,
    assessment_name VARCHAR(50) NOT NULL,   -- 'CAT 1', 'Midterm', 'Final Exam'
    max_score       DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    assessment_date DATE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (term_id) REFERENCES terms(term_id) ON DELETE CASCADE
);

CREATE TABLE grades (
    grade_id        INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT NOT NULL,
    assessment_id   INT NOT NULL,
    score           DECIMAL(5,2) NOT NULL,
    recorded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (assessment_id) REFERENCES assessments(assessment_id) ON DELETE CASCADE,
    UNIQUE (student_id, assessment_id)
);

-- ============================================================
-- EXAMPLE QUERIES (things this schema makes easy)
-- ============================================================

-- A student's full academic portfolio for a given term
-- SELECT s.first_name, s.last_name, sub.subject_name, a.assessment_name, g.score, a.max_score
-- FROM grades g
-- JOIN students s ON g.student_id = s.student_id
-- JOIN assessments a ON g.assessment_id = a.assessment_id
-- JOIN subjects sub ON a.subject_id = sub.subject_id
-- WHERE s.student_id = 1 AND a.term_id = 1;

-- Class average for a subject in a term
-- SELECT sub.subject_name, AVG(g.score) AS class_average
-- FROM grades g
-- JOIN assessments a ON g.assessment_id = a.assessment_id
-- JOIN subjects sub ON a.subject_id = sub.subject_id
-- JOIN enrollments e ON g.student_id = e.student_id
-- WHERE e.class_id = 1 AND a.term_id = 1
-- GROUP BY sub.subject_name;