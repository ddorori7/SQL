
-- 미니 프로젝트

CREATE TABLE PHONE_BOOK (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(10),
    hp VARCHAR2(20),
    tel VARCHAR2(20)
    );
    
DESC PHONE_BOOK;    -- 확인

CREATE SEQUENCE seq_phone_book;

select * from PHONE_BOOK;

insert INTO phone_book (id, name, hp, tel)


select * from author;

drop table PHONE_BOOK;
rollback;
