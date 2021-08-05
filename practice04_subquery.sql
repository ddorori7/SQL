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
            where hire_date like '07%'
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

select first_name, salary, hire_date from employees where hire_date < '05/01/01'; --24
select first_name, salary, hire_date from employees where salary > 12000; --24








--서브쿼리(SUBQUERY)SQL 문제(연습문제)

--문제1.평균급여보다 적은급여을 받는직원은 몇명인지 구하시요.(56건)
select count(salary) from employees
where salary < (select avg(salary) from employees);

--문제2. 평균급여 이상, 최대급여 이하의 월급을 받는사원의 
--직원번호(employee_id), 이름(first_name), 급여(salary), 평균급여, 최대급여를급여의오름차순으로정렬하여출력하세요(51건)
--문제3.직원중Steven(first_name) king(last_name)이소속된부서(departments)가있는곳의주소를알아보려고한다.도시아이디(location_id), 거리명(street_address), 우편번호(postal_code), 도시명(city), 주(state_province), 나라아이디(country_id) 를출력하세요(1건)
--문제4.job_id 가'ST_MAN' 인직원의급여보다작은직원의사번,이름,급여를급여의내림차순으로출력하세요-ANY연산자사용(74건)
--문제5. 각부서별로최고의급여를받는사원의직원번호(employee_id), 이름(first_name)과급여(salary)부서번호(department_id)를조회하세요단조회결과는급여의내림차순으로정렬되어나타나야합니다. 조건절비교, 테이블조인2가지방법으로작성하세요(11건)
--문제6.각업무( job) 별로연봉(salary)의총합을구하고자합니다. 연봉총합이가장높은업무부터업무명( job_title)과연봉총합을조회하시오(19건)
--문제7.자신의부서평균급여보다연봉(salary)이많은직원의직원번호(employee_id), 이름(first_name)과급여(salary)을조회하세요(38건)
--문제8.직원입사일이11번째에서15번째의직원의사번, 이름, 급여, 입사일을입사일순서로출력하세요



