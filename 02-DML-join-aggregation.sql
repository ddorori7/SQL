----------
-- JOIN
----------

--먼저 employees와 departments 를 확인
DESC employees;
DESC departments;

-- 두 테이블로부터 모든 레코드를 추출: Cartition Product or Cross Join
SELECT first_name, emp.department_id, dept.department_id, department_name
FROM employees emp, departments dept
ORDER BY first_name;

-- 테이블 조인을 위한 조건 부여할 수 있다.
SELECT first_name, emp.department_id, dept.department_id, department_name
FROM employees emp, departments dept
WHERE  emp.department_id = dept.department_id;


-- 총 몇명의 사원이 있는가?
SELECT COUNT(*) FROM employees; -- 107명

SELECT first_name, emp.department_id, department_name
FROM employees emp, departments dept
WHERE emp.department_id = dept.department_id; -- 106명

-- department_id 가 null인 사원?
SELECT * FROM employees
WHERE department_id IS NULL;

-- USING : 조인할 컬럼을 명시
SELECT first_name,department_name
FROM employees JOIN departments USING(department_id); -- 106개

-- on : JOIN의 조건절
SELECT first_name, department_name
FROM employees emp JOIN departments dept
                  ON (emp.department_id = dept.department_id); -- JOIN의 조건 -- 106개
          
                  
-- Natural JOIN
-- 조건 명시 하지않고, 같은 이름을 가진 컬럼으로 JOIN
SELECT first_name, department_name
FROM employees NATURAL JOIN departments; 
-- 32개 why? 관계없는 컬럼인 manager_id 때문 > 조건이 2개가 됌
-- 잘못된 쿼리 : Natural JOIN은 조건을 잘 확인!

------------
-- OUTER JOIN
------------

-- 조건이 만족하는 짝이 없는 튜플도 NULL을 포함하여 출력
-- 모든 레코드를 출력할 테이블의 위치에 따라 LEFT, RIGHT, FULL, OUTER JOIN으로 구분
-- ORACLE의 경우 NULL을 출력할 조건 쪽에 (+)를 명시
SELECT first_name,
    emp.department_id,
    dept.department_id,
    department_name
FROM employees emp, departments dept
WHERE emp.department_id = dept.department_id (+);
      
-- ANSI SQL 
SELECT emp.first_name,
    emp.department_id,
    dept.department_id,
    dept.department_name
FROM employees emp LEFT OUTER JOIN departments dept -- LEFT OUTER JOIN을 명시
                    ON emp.department_id = dept.department_id;
                    
                    
-- RIGHT OUTER JOIN: 짝이 없는 오른쪽 레코드도 NULL을 포함하여 출력
-- ORACLE SQL
SELECT first_name, emp.department_id,
    dept.department_id, department_name
FROM employees emp, departments dept  
-- departments 모두 출력/ emp.department_id가 NULL일 가능성((+)를 붙여줌)
WHERE emp.department_id (+) = dept.department_id;
  
                    
-- ANSI SQL 
SELECT emp.first_name, emp.department_id,
    dept.department_id, dept.department_name
FROM employees emp RIGHT OUTER JOIN departments dept -- RIGHT OUTER JOIN을 명시
                    ON emp.department_id = dept.department_id;                          
    
    
    
-- FULL OUTER JOIN
-- 양쪽 테이블 레코드 전부를 짝이 없어도 출력에 참여

-- ANSI SQL 
SELECT emp.first_name, emp.department_id,
    dept.department_id, dept.department_name
FROM employees emp FULL OUTER JOIN departments dept -- FULL OUTER JOIN을 명시
                    ON emp.department_id = dept.department_id;     

-- ORACLE SQL (+) 방식으로는 불가
--SELECT emp.first_name, emp.department_id,
--    dept.department_id, dept.department_name
--FROM employees emp, departments dept 
--WHERE emp.department_id (+) = dept.department_id (+);         


--------------
-- SELF JOIN
--------------
-- 자기 자신과 JOIN
-- 자기 자신을 두 번 이상 호출 > alias를 사용할 수 밖에 없는 JOIN
SELECT * FROM employees; -- 107명

-- 사원 정보, 매니저 이름을 함께 출력
-- 방법1.
SELECT emp.employee_id, emp.first_name, emp.manager_id,
    man.employee_id, man.first_name
FROM employees emp JOIN employees man
                    ON emp.manager_id = man.employee_id
ORDER BY emp.employee_id;                    

-- 방법2.
SELECT emp.employee_id, emp.first_name, emp.manager_id,
    man.employee_id, man.first_name
FROM employees emp, employees man
WHERE emp.manager_id = man.employee_id (+) -- LEFT OUTER JOIN
ORDER BY emp.employee_id;      


    

--------------
-- 집계 함수
--------------
-- 여러 레코드로부터 데이터를 수집, 하나의 결과 행을 반환

--count: 갯수세기
select count(*) from employees; --특정 컬럼이 아닌 레코드의 갯수 센다

select count(commission_pct) from employees; -- 해당 컬럼의 null이 아닌 갯수
select count(*) from employees
where commission_pct is not null; -- 위와 같은 의미

-- sum: 합계
-- 급여의 합계
select sum(salary) from employees;

-- avg: 평균
-- 급여의 평균
select avg(salary) from employees;
-- avg함수는 null값은 집계에서 제외

-- 사원들의 평균 커미션 비율
select avg(commission_pct) from employees; -- 22%
select avg(nvl(commission_pct,0)) from employees; -- 7%

-- min/max: 최소값, 최대값
select min(salary), max(salary), avg(salary), MEDIAN(salary)
from employees;


-- 일반적 오류
select department_id, avg(salary) 
-- avg(salary)집계함수는 단일행 department_id은 107개의 행 > 오류가남
from employees; -- error

-- 수정: 집계함수
select department_id,avg(salary) 
from employees
GROUP BY department_id
ORDER BY department_id;

-- 집계함수를 사용한 select 문의 컬럼 목록에는
-- Group by 에 참여한 필드, 집계 함수만 올 수 있다.

-- 부서별 평균 급여를 출력,
-- 평균 급여가 7000 이상인 부서만 뽑아봅시다.
SELECT department_id, AVG(salary)
from employees
where AVG(salary) >= 7000 --여기가 문제. where절에서는  AVG(salary)집계 일어나지 않음
GROUP BY department_id;
-- 집계함수(AVG(salary)) 실행 이전에 where 절을 검사하기 때문에
-- 집계함수는 where 절에서 사용할 수 없다.

-- 집계함수 실행 이후에 조건 검사하려면
-- HAVING 절을 이용
SELECT department_id, round(AVG(salary),2)
from employees
GROUP BY department_id
HAVING AVG(salary) >= 7000
ORDER BY department_id;


-------------
-- 분석함수
-------------
-- ROLLUP
-- 그룹핑된 결과에 대한 상세 요약을 제공하는 기능
-- 일종의 ITEM TOTAL
SELECT department_id, job_id, sum(salary)
from employees
group by ROLLUP(department_id, job_id);

-- CUBE 함수
-- Cross Table에 대한 Summary를 함께 추출
-- ROLLUP 함수에서 추출되는 ITEM TOTAL과 함께
-- COLUMN TOTAL 값을 함께 추출
SELECT department_id, job_id, sum(salary)
from employees
group by CUBE(department_id, job_id)
ORDER BY department_id;




