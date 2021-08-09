---------
-- DB OBJECTS
---------

-- VIEW
-- System 계정으로 수행
-- create view 권한 필요
GRANT create view TO C##BITUSER;

-- C##BITUSER 전환
-- HR.employees 테이블로부터 department_id=10 사원의 View 생성
CREATE TABLE emp_123 
    AS SELECT * FROM c##HR.employees
        WHERE department_id IN (10, 20, 30);
        
-- Simple View 생성
CREATE OR REPLACE VIEW emp_20
    AS SELECT employee_id, first_name, last_name, salary
        FROM emp_123
        WHERE department_id = 20;
        
DESC emp_20;

-- 마치 일반 테이블처럼 SELECT 할 수 있다.
SELECT employee_id, first_name, salary FROM emp_20;

-- SIMPLE VIEW는 제약 사항에 위배되지 않으면 내용 갱신 가능
UPDATE emp_20 SET salary = salary * 2;
SELECT first_name, salary FROM emp_123 WHERE department_id = 20;

-- 가급적 VIEW는 조회 전용으로 사용하기를 권장
-- WITH READ ONLY 옵션
CREATE OR REPLACE VIEW emp_10
    AS SELECT employee_id, first_name, last_name, salary
    FROM emp_123
    WHERE department_id = 10
    WITH READ ONLY;
    
SELECT * FROM emp_10;
UPDATE emp_10 SET salary = salary * 2;

DESC book;

INSERT INTO book (book_id, title, author_id)
VALUES(1, '토지', 1);

INSERT INTO book (book_id, title, author_id)
VALUES(2, '살인자의 기억법', 2);

COMMIT;

-- Complex View로 조회
SELECT * FROM c#c##bituser.book_detail;

-- Complex View
CREATE OR REPLACE VIEW book_detail
    (book_id, title, author_name, pub_date)
    AS SELECT book_id, title, author_name, pub_date 
        FROM book b, author a
        WHERE b.author_id = a.author_id;
        
SELECT * FROM book_detail;
SELECT * FROM author;

-- Complex View는 갱신이 불가
UPDATE book_detail SET author_name = '소설가'; -- ERROR

-- VIEW의 삭제
-- book_detail은 book, author 테이블을 기반으로 함
DROP VIEW book_detail; -- VIEW 삭제

SELECT * FROM tab;

-- VIEW 확인을 위한 DICTIONARY
SELECT * FROM USER_VIEWS;
SELECT * FROM USER_OBJECTS;

SELECT object_name, object_type, status FROM USER_OBJECTS
WHERE object_type='VIEW';

-- INDEX : 검색 속도 증가
-- INSERT, UPDATE, DELETE -> 인덱스의 갱신 발생
-- HR.employees 테이블 복사 -> s_emp 테이블 생성
CREATE TABLE s_emp
    AS SELECT * FROM c##HR.employees;
    
SELECT * FROM s_emp;

-- s_emp.employee_id에 UNIQUE_INDEX 부여
CREATE UNIQUE INDEX s_emp_id
    ON s_emp (employee_id);
    
-- INDEX 위한 DICTIONARY
SELECT * FROM USER_INDEXES;
SELECT * FROM USER_IND_COLUMNS;

-- 어느 테이블에 어느 컬럼에 S_EMP_ID가 부여되었는가?
SELECT t.index_name, t.table_name, c.column_name, c.column_position
FROM USER_INDEXES t, USER_IND_COLUMNS c
WHERE t.index_name = c.index_name AND
    t.table_name = 'S_EMP';
    
SELECT * FROM s_emp;

-- 인덱스 삭제
DROP INDEX s_emp_id;
SELECT * FROM USER_INDEXES;

-- 인덱스는 테이블과 독립적: 인덱스 삭제해도 테이블 데이터는 남아 있다.