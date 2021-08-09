------------
-- DCL
------------
-- CREATE : 데이터베이스 객체 생성
-- ALTER : 데이터베이스 객체 수정
-- DROP : 데이터베이스 객체 삭제


-- System 계정으로 수행

-- 사용자 생성: CREATE USER
CREATE USER C##bituser IDENTIFIED BY bituser;

-- SQLPLUS에서 사용자로 접속
-- 사용자 삭제: DROP USER
DROP USER C##bituser CASCADE; --CASCADE는 연결된 모든 것을 함께 삭제

-- 다시 생성
create user c##bituser identified by bituser;

-- 사용자 정보 확인
-- USER_ : 현재 사용자 관련
-- ALL_ : 전체의 객체
-- DBA_ : DBA 전용, 객체의 모든 정보
SELECT * FROM USER_USERS;
SELECT * FROM ALL_USERS;
SELECT * FROM DBA_USERS;

-- 새로 만든 사용자 확인
SELECT * FROM DBA_USERS WHERE username = 'C##BITUSER';

-- 권한(Privilege)과 역할(roll)
-- 특정 작업 수행을 위해 적절한 권한을 가져야 한다.
-- CREATE SESSION

-- 시스템 권한의 부여: GRANT 권한 TO 사용자
-- C##BITUSER에게 create session 권한을 부여
GRANT create session TO C##BITUSER;

-- 일반적으로 CONNECT, RESOURCE 롤을 부여하면 일반 사용자의 역할 수행 가능
GRANT CONNECT, RESOURCE to C##BITUSER;

-- Oracle 12 이후로는 임의로 TABLESPACE를 할당 해 줘야 한다.
ALTER USER C##BITUSER -- 사용자 정보 수정
    DEFAULT TABLESPACE USERS -- 기본 테이블 스페이스를 USERS 에 지정
    QUOTA UNLIMITED ON USERS; --  사용 용량 지정

-- 객체 권한 부여
-- C##BITUSER 사용자에게 HR.EMPLOYEES를 SELECT 할 수 있는 권한 부여
GRANT select ON  c##HR.EMPLOYEES TO C##BITUSER;
-- 객체 권한 회수
REVOKE select ON c##HR.EMPLOYEES FROM C##BITUSER;
GRANT select ON c##HR.EMPLOYEES TO C##BITUSER;
-- GRANT all privileges ...

SELECT *FROM c##hr.employees; -- 됌

-----------
-- DDL
-----------
-- 이후 C##BITUSER로 진행 > 비번 bituser

-- 현재 내가 소유한 테이블 목록 확인
select * from tab;
-- 현재 나에게 주어진 role을 조회
select * from user_role_privs;

-- create table : 테이블 생성
create table book(
    book_id number(5),
    title varchar2(50),
    author varchar2(10),
    pub_date date default sysdate
);

select * from tab;
-- 테이블 정의 정보 확인
desc book; 

-- 서브쿼리를 이용한 테이블 생성
-- HR스키마의 employees 테이블의 일부 데이터를 추출, 새 테이블 생성
select * from c##HR.EMPLOYEES;

-- job_id가 IT_관련 직원들만 뽑아내어 새 테이블 생성
create table it_emps as (
    select * from c##hr.EMPLOYEES
    where job_id like 'IT_%'
);

DROP TABLE it_emps; -- 테이블 삭제

desc it_emps;
select * from it_emps;

-- author 테이블 추가
create table author(
    author_id number(10),
    author_name varchar2(50) not null,
    author_desc varchar2(500),
    PRIMARY KEY (author_id) -- 테이블 제약
);

desc author;

-- book 테이블의 author 컬럼 지우기
-- 나중에 author 테이블과 FK 연셜
desc book;
alter table book drop COLUMN author;
desc book;

-- author 테이블 참조를 위한 컬럼 author_id 추가
alter table book add (author_id number(10));
desc book;

-- book 테이블의 book_id 도 number(10)으로 변경
alter table book MODIFY (book_id number(10));
desc book;

desc author;

-- book.book_id 에 PK 제약조건 부여
alter table book
add constraint pk_book_id PRIMARY KEY (book_id);

-- book.author_id 를 author.author_id를 참조하도록 제약
alter table book 
add constraint fk_author_id foreign key (author_id)
                            REFERENCES author(author_id)
                            on DELETE CASCADE;

-- DATA DICTIONARY
-- 전체 데이터 딕셔너리 확인
select * from dictionary;

-- 사용자의 스키마 객체 확인 : user_objects
select * from user_objects;

-- 제약조건의 확인 :  user_constraints
select * from user_constraints;





