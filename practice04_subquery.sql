-------------
-- SUBQUERY
-------------
--하나의 질의문 안에 다른 질의문을 포함하는 형태
--전체 사원 중, 급여의 중앙값보다 많이 받는 사원

--1. 급여의 중앙값?
select median(salary) from employees;  --6200
--2. 6200보다 많이 받는 사원 쿼리
select first_name, salary from employees where salary > 6200;
--3. 두 쿼리를 합친다.
select first_name, salary from employees 
where salary > (select median(salary) from employees);


--Den 보다 늦게 입사한 사원들
--1. Den 입사일 쿼리
select hire_date from employees where first_name = 'Den'; --02/12/07
--2. 특정 날짜 이후 입사한 사원 쿼리
select first_name, hire_date from employees where hire_date >= '02/12/07';
--3. 두 쿼리를 합친다.
select first_name, hire_date from employees 
where hire_date >= (select hire_date from employees where first_name = 'Den');



--다중행 서브 쿼리
--서브 쿼리의 결과 레코드가 둘 이상이 나올 때는 단일행 연산자를 사용할 수 없다.
--IN, ANY, ALL, EXISTS 등 집합 연산자를 활용
select salary from employees where department_id = 110; -- 2row

select first_name, salary from employees
where salary = (select salary from employees where department_id = 110); -- error
--why? =은 단일행 연산자

--결과가 다중행이면 집합 연산자를 활용
--in(or)
--salary = 120008 or salary = 8300
select first_name, salary from employees
where salary in (select salary from employees where department_id = 110);

--ALL(and)
--salary > 120008 and salary > 8300
select first_name, salary from employees
where salary > all (select salary from employees where department_id = 110);

--any(or)
--salary > 120008 or salary > 8300
select first_name, salary from employees
where salary > any (select salary from employees where department_id = 110);


--각 부서별로 최고급여를 받는 사원을 출력
--1. 각 부서의 최고급여 확인 쿼리
select department_id, max(salary) from employees
group by department_id;
--2. 서브 쿼리의 결과 (departmnet_id, max(salary))
select department_id, employee_id, first_name, salary
from employees
where (department_id, salary) in (select department_id, max(salary) 
                                    from employees
                                    group by department_id)
order by department_id;

--서브쿼리와 조인
select e.department_id, e.employee_id, e.first_name, e.salary
from employees e, (select department_id, max(salary) salary from employees
                    group by department_id) sal --임시테이블을 sal을 만들어서 조인
where e.department_id = sal.department_id and
        e.salary = sal.salary
order by e.department_id;        
  

-- Correlated Query
--외부 쿼리와 내부 쿼리가 연관관게를 맺는 쿼리
select e.department_id, e.employee_id, e.first_name, e.salary
from employees e
where e.salary = (select max(salary) from employees
                    where department_id = e.department_id)
order by e.department_id;                   


--Top-K Query
--ROWNUM: 레코드의 순서를 가리키는 가상의 컬럼(pseudo)

--2007년 입사자 중에서 급여 순위 5위까지 출력
select * from employees 
            where hire_date like '07%' --like '07%' 07로 시작하는 문자열
            order by salary desc, first_name; -- 맨왼쪽에 출력되는 순서가 rownum

select ROWNUM, first_name
from (select * from employees 
            where hire_date like '07%'
            order by salary desc, first_name)
where rownum <= 5;   


-- 집합 연산: set
-- UNION: 합집합, UNION ALL: 합집합, 중복 요소 체크 안함
-- INTERSECT: 교집합
-- MINUS: 차집합

--05/01/01 이전 입사자 쿼리
select first_name, salary, hire_date from employees where hire_date < '05/01/01'; --24
--급여를 12000 초과 수령 사원
select first_name, salary, hire_date from employees where salary > 12000; --8

select first_name, salary, hire_date from employees where hire_date < '05/01/01'
union -- 합집합
select first_name, salary, hire_date from employees where salary > 12000; --26

select first_name, salary, hire_date from employees where hire_date < '05/01/01'
union all -- 합집합: 중복 허용
select first_name, salary, hire_date from employees where salary > 12000; --32

select first_name, salary, hire_date from employees where hire_date < '05/01/01'
INTERSECT -- 교집합(and)
select first_name, salary, hire_date from employees where salary > 12000; --6

select first_name, salary, hire_date from employees where hire_date < '05/01/01'
MINUS -- 차집합
select first_name, salary, hire_date from employees where salary > 12000; --18


--순위 함수
--RANK(): 중복순위가 있으면 건너뛴다 1,2,2,4
--DENSE_RANK() : 중복순위 상관없이 다음순위 1,2,2,3
--ROW_NUMBER() : 순위 상관없이 차례대로 1,2,3,4
select salary, first_name, 
    rank() over (order by salary desc) rank,
    DENSE_RANK() over (order by salary desc) dense_rank,
    row_number() over (order by salary desc) row_number
from employees;    

-- Hierachical Query: 계층적 쿼리
-- Tree 형태의 구조 추출
-- LEVEL 가상컬럼이 생긴다
select level, employee_id, first_name, manager_id
from employees
start with manager_id is null -- 트리 시작 조건
connect by prior employee_id = manager_id -- 앞에있는 employee_id가 manager_id와 일치하는가
order by level;

--------------------------------------------------------------------------------
--서브쿼리(SUBQUERY)SQL 문제(연습문제)
--------------------------------------------------------------------------------
--문제1.평균급여보다 적은급여을 받는직원은 몇명인지 구하시요.(56건)
select count(salary) from employees
where salary < (select avg(salary) from employees);

-- Q1
SELECT COUNT(salary) 
FROM employees
WHERE salary > ( SELECT AVG(salary)
                    FROM employees );
--------------------------------------------------------------------------------
--문제2. 평균급여 이상, 최대급여 이하의 월급을 받는사원의 
select avg(salary) a, max(salary) m from employees; --최대급여 평균급여
--직원번호(employee_id), 이름(first_name), 급여(salary), 평균급여, 최대급여를
--급여의 오름차순으로 정렬하여 출력하세요(51건)
select e.employee_id 직원번호, e.first_name 이름, e.salary 급여, a 평균급여, m 최대급여
from employees e 
        join (select avg(salary) a, max(salary) m from employees) t
--        on e.salary >= a and e.salary <= m    
        on e.salary between t.a and t.m
order by salary asc;

-- Q2
-- 사용할 서브쿼리
SELECT AVG(salary) avgSalary, MAX(salary) maxSalary
FROM employees;
-- 답                    
SELECT e.employee_id, e.first_name, e.salary, t.avgSalary, t.maxSalary
FROM employees e, ( SELECT AVG(salary) avgSalary, MAX(salary) maxSalary
                    FROM employees ) t
WHERE e.salary BETWEEN t.avgSalary AND t.maxSalary
ORDER BY salary;

--------------------------------------------------------------------------------    
--문제3.직원중 Steven(first_name) king(last_name)이 소속된부서(departments)가 있는곳의 주소를 알아보려고 한다.
select e.department_id 
from employees e join departments d
               on d.department_id = e.department_id 
where upper(e.first_name) = 'STEVEN' and upper(e.last_name) = 'KING'; -- 부서찾기   

--도시아이디(location_id), 거리명(street_address), 우편번호(postal_code), 도시명(city), 주(state_province), 나라아이디(country_id) 를 출력하세요(1건)
select l.location_id 도시아이디, l.street_address 거리명, l.postal_code 우편번호,
        l.city 도시명, l.state_province 주, l.country_id 나라아이디
from locations l join departments d
                on d.location_id = l.location_id
where d.department_id = (select e.department_id 
                         from employees e join departments d
                            on d.department_id = e.department_id
                        where upper(e.first_name) = 'STEVEN' and upper(e.last_name) = 'KING');                

-- Q3
-- 쿼리1. Steven King이 소속된 부서
SELECT department_id FROM employees
WHERE first_name='Steven' AND last_name='King';
-- 쿼리2. Steven King이 소속된 부서가 위치한 location 정보
SELECT location_id FROM departments
WHERE department_id = ( SELECT department_id 
                        FROM employees
                        WHERE first_name='Steven' 
                            AND last_name='King' );
-- 최종 쿼리
SELECT location_id, street_address, postal_code, city,state_province, country_id
FROM locations
WHERE location_id = ( SELECT location_id 
                        FROM departments
                        WHERE department_id = 
                            ( SELECT department_id 
                                FROM employees
                                WHERE first_name='Steven' 
                                    AND last_name='King' 
                            )
                        );
--------------------------------------------------------------------------------
--문제4.job_id 가 'ST_MAN' 인 직원의 급여보다 작은 직원의 
select salary from employees where job_id = 'ST_MAN';
--사번, 이름, 급여를 급여의 내림차순으로 출력하세요 -ANY연산자사용(74건)
select employee_id 사번, first_name 이름, salary 급여
from employees
where salary < any(select salary from employees where job_id = 'ST_MAN');
-- Q4.
-- 쿼리 1:
SELECT salary FROM employees WHERE job_id='ST_MAN';
-- 최종 쿼리:
SELECT employee_id, first_name, salary
FROM employees
WHERE salary <ANY (SELECT salary 
                 FROM employees WHERE job_id='ST_MAN');
--------------------------------------------------------------------------------
--문제5.각 부서별로 최고의 급여를 받는 사원의 
--직원번호(employee_id), 이름(first_name)과 급여(salary)부서번호(department_id)를 조회하세요. 
--단 조회 결과는 급여의 내림차순으로 정렬되어 나타나야 합니다. 
--조건절비교, 테이블조인 2가지 방법으로 작성하세요(11건)
select max(salary) from employees
group by department_id; --그룹별 최고급여 
--조건절
select e.employee_id, e.first_name, e.salary, e.department_id
from employees e
where e.salary in (select max(salary) from employees m
                    group by department_id
                    having e.department_id = m.department_id)
order by e.salary desc;
--테이블조인
select e.employee_id, e.first_name, e.salary, e.department_id
from employees e join (select max(salary) salary, m.department_id 
                        from employees m
                        group by m.department_id) s
                        on e.department_id = s.department_id and e.salary = s.salary      
order by e.salary desc;         
-- Q5
-- 쿼리 1
SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id;

-- 최종 쿼리: 조건절 비교
SELECT employee_id, first_name, salary, department_id
FROM employees 
WHERE (department_id, salary) IN 
    ( SELECT department_id, MAX(salary)
        FROM employees
        GROUP BY department_id )
ORDER BY salary DESC;

-- 최종쿼리: 테이블 조인
SELECT e.employee_id, e.first_name, e.salary, e.department_id
FROM employees e, 
    ( SELECT department_id, MAX(salary) salary
        FROM employees
        GROUP BY department_id ) t
WHERE e.department_id = t.department_id AND
    e.salary = t.salary 
ORDER BY e.salary DESC;
--------------------------------------------------------------------------------
--문제6.각업무(job) 별로 연봉(salary)의 총합을 구하고자 합니다. 
--연봉 총합이 가장 높은 업무부터 업무명(job_title)과 연봉 총합을 조회하시오(19건)
(select SUM(salary) from employees
GROUP BY job_id); -- 연봉 총합 구하기

select job_title 업무명, s.salary 연봉총합
from jobs j join (select SUM(salary) salary, job_id from employees
                GROUP BY job_id) s
                on s.job_id = j.job_id
order by s.salary desc;                
-- Q6
-- 쿼리1
SELECT job_id, SUM(salary) sumSalary
FROM employees GROUP BY job_id;
-- 최종 쿼리
SELECT j.job_title, t.sumSalary
FROM jobs j, ( SELECT 
                    job_id, 
                    SUM(salary) sumSalary
                FROM employees GROUP BY job_id ) t
WHERE j.job_id = t.job_id
ORDER BY t.sumSalary DESC;

--------------------------------------------------------------------------------
--문제7.자신의 부서평균 급여보다 연봉(salary)이 많은직원의 
--직원번호(employee_id), 이름(first_name)과 급여(salary)을 조회하세요(38건)
select avg(salary) from employees GROUP BY department_id; --부서별 평균 급여 구하기

select employee_id, first_name, salary 
from employees e
where e.salary > (select avg(salary) from employees s
                    GROUP BY department_id
                    having e.department_id = s.department_id);
-- Q7
-- 쿼리1: 부서별 평균 급여
SELECT department_id, AVG(salary) salary 
FROM employees GROUP BY department_id;

-- 최종 쿼리
SELECT e.employee_id,
    e.first_name,
    e.salary
FROM employees e, 
    ( SELECT department_id, AVG(salary) salary 
        FROM employees GROUP BY department_id ) t
WHERE e.department_id = t.department_id AND
    e.salary > t.salary;  

--------------------------------------------------------------------------------
--문제8.직원입사일이 11번째에서 15번째의 직원의 사번, 이름, 급여, 입사일을 입사일순서로 출력하세요
select EMPLOYEE_ID 사번, FIRST_NAME 이름, SALARY 급여, HIRE_DATE 입사일
from (select * from employees order by hire_date)
where rownum <= 15 --rownum은 주로 <, <= 사용하며 >, >= 인 경우 ROWNUM은 동작하지 않는다.
minus
select EMPLOYEE_ID 사번, FIRST_NAME 이름, SALARY 급여, HIRE_DATE 입사일
from (select * from employees order by hire_date)
where rownum < 11;

SELECT EMPLOYEE_ID, FIRST_NAME, SALARY, HIRE_DATE
FROM employees order by hire_date
OFFSET 10 ROWS FETCH FIRST 5 ROWS ONLY;



-- Q8
-- 쿼리 1
SELECT ROWNUM, employee_id,first_name,salary,hire_date
FROM employees
ORDER BY hire_date asc;
-- 쿼리 2
SELECT rownum rn,employee_id, first_name,salary,hire_date
FROM ( SELECT employee_id, first_name, salary, hire_date
        FROM employees
        ORDER BY hire_date asc );
-- 최종 쿼리
SELECT rn, employee_id, first_name, salary, hire_date
FROM (SELECT rownum rn, employee_id, first_name, salary, hire_date
    FROM ( SELECT employee_id, first_name, salary, hire_date
            FROM employees
            ORDER BY hire_date asc )
    )
WHERE rn BETWEEN 11 AND 15;

--11에서 15데이터
--100	Steven	24000	03/06/17
--137	Renske	3600	03/07/14
--200	Jennifer	4400	03/09/17
--141	Trenna	3500	03/10/17
--184	Nandita	4200	04/01/27

select first_name || ' ' || last_name as name, 
email, phone_number, to_char(hire_date, 'yyyy-mm-dd')
FROM employees;