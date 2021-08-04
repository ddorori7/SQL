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

-- 조인 연습문제
-- 문제1.직원들의사번(employee_id), 이름(firt_name), 성(last_name)과 부서명(department_name)을 조회하여 
-- 부서이름(department_name) 오름차순, 사번(employee_id) 내림차순으로정렬하세요.(106건)
select EMPLOYEE_ID, FIRST_NAME, LAST_NAME, department_name
from employees emp join departments dept
    on emp.department_id = dept.department_id
order by dept.department_name asc, emp.employee_id desc;


-- 문제2.employees 테이블의 job_id 는 현재의 업무아이디를 가지고 있습니다.
-- 직원들의사번(employee_id), 이름(firt_name), 급여(salary), 부서명(department_name), 
-- 현재업무( job_title)를 사번(employee_id) 오름차순으로 정렬하세요.
-- 부서가없는 Kimberely(사번178)은 표시하지 않습니다.(106건)
select employee_id, FIRST_NAME, salary, department_name, job_title
from employees emp 
    inner join departments dept
        on emp.department_id = dept.department_id
    inner join jobs job
        on emp.job_id = job.job_id   
where emp.department_id is not null
order by emp.employee_id asc;

-- 문제2-1.문제2에서부서가없는Kimberely(사번178)까지표시해보세요(107건)
select employee_id, FIRST_NAME, salary, department_name, job_title
from employees emp 
    FULL OUTER JOIN departments dept
        on emp.department_id = dept.department_id
    inner join jobs job
        on emp.job_id = job.job_id 
order by emp.employee_id asc;


-- 문제3.도시별로 위치한 부서들을 파악하려고 합니다.
-- 도시아이디, 도시명, 부서명, 부서아이디를 도시아이디(오름차순)로 정렬하여 출력하세요 
-- 부서가없는도시는표시하지않습니다.(27건)
select dept.location_id, city, department_name, department_id
from departments dept join locations loc
    on dept.location_id = loc.location_id
where dept.location_id is not null
order by department_id asc;

-- 문제3-1.문제3에서부서가없는도시도표시합니다.(43건)
select dept.location_id, city, department_name, department_id
from departments dept full outer join locations loc
    on dept.location_id = loc.location_id
order by department_id asc;

-- 문제4.지역(regions)에 속한 나라들을 지역이름(region_name), 나라이름(country_name)으로
-- 출력하되지역이름(오름차순), 나라이름(내림차순) 으로정렬하세요.(25건)
select region_name, country_name
from regions reg join countries cou
    on reg.region_id = cou.region_id
ORDER BY reg.region_name asc, cou.country_name desc;


-- 문제5. 자신의 매니저보다 채용일(hire_date)이 빠른사원의
-- 사번(employee_id), 이름(first_name)과 채용일(hire_date), 
-- 매니저이름(first_name), 매니저입사일(hire_date)을 조회하세요.(37건)
select emp.employee_id, emp.first_name, emp.hire_date "자신의 채용일", 
        man.first_name "매니저이름", man.hire_date "매니저 채용일"
FROM employees emp JOIN employees man
    on emp.manager_id = man.employee_id -- 여기 설정하는거 주의
where TO_DATE(emp.hire_date, 'YYYY-MM-DD') < TO_DATE( man.hire_date, 'YYYY-MM-DD') ;

-- 문제6.나라별로 어떠한 부서들이 위치하고 있는지 파악하려고 합니다. 
-- 나라명, 나라아이디, 도시명, 도시아이디, 부서명, 부서아이디를 나라명(오름차순)로 정렬하여 출력하세요.
-- 값이없는 경우 표시하지 않습니다.(27건)
select cou.COUNTRY_NAME, cou.COUNTRY_ID,
        loc. CITY, loc.LOCATION_ID, 
        dept.DEPARTMENT_NAME, dept.DEPARTMENT_ID
from countries cou 
        inner join locations loc
            on cou.country_id = loc.country_id
        inner join departments dept
            on dept.location_id = loc.location_id
order by cou.COUNTRY_NAME asc;      
      

-- 문제7.job_history 테이블은 과거의 담당업무의 데이터를 가지고있다.
-- 과거의 업무아이디(job_id)가 ‘AC_ACCOUNT’로 근무한 사원의 사번, 이름(풀네임), 업무아이디, 시작일, 종료일을출력하세요.
-- 이름은first_name과 last_name을 합쳐 출력합니다.(2건)
select emp.EMPLOYEE_ID, (emp.FIRST_NAME || ' ' || emp.LAST_NAME) "이름", 
        jh.JOB_ID, jh.START_DATE, jh.END_DATE
from  job_history jh join employees emp
     on emp.employee_id = jh.employee_id
where jh.job_id = 'AC_ACCOUNT';


-- 문제8.각부서(department)에 대해서 부서번호(department_id), 부서이름(department_name), 
-- 매니저(manager)의 이름(first_name), 위치(locations)한 도시(city), 나라(countries)의 이름(countries_name)
-- 그리고 지역구분(regions)의 이름(resion_name)까지 전부 출력해보세요.(11건)
select dept.department_id, dept.department_name, 
        emp.first_name, loc.city, cou.country_name, re.region_name
from DEPARTMENTS dept 
    join employees emp on dept.manager_id = emp.employee_id
    join locations loc on dept.location_id = loc.location_id
    join countries cou on loc.country_id = cou.country_id
    join regions re on cou.region_id = re.region_id;
    

-- 문제9.각사원(employee)에 대해서 
-- 사번(employee_id), 이름(first_name), 부서명(department_name), 매니저(manager)의 이름(first_name)을조회하세요. 
-- 부서가없는직원(Kimberely)도표시합니다.(106명)
select emp.employee_id, emp.first_name, dept.department_name, man.first_name
from employees emp full outer join departments dept
    on emp.department_id = dept.department_id
    join employees man on dept.manager_id = man.employee_id;
    

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


--집계함수 실습문제
--문제1.매니저가 있는 직원은 몇명입니까? 아래의 결과가 나오도록 쿼리문을 작성하세요
--문제2.직원중에 최고임금(salary)과 최저임금을 “최고임금, “최저임금” 프로젝션타이틀로 함께 출력해보세요.
--두임금의차이는얼마인가요? “최고임금–최저임금”이란타이틀로함께출력해보세요.
--문제3.마지막으로신입사원이들어온날은언제입니까? 
--다음형식으로출력해주세요.예) 2014년07월10일
--문제4.부서별로평균임금, 최고임금, 최저임금을부서아이디(department_id)와함께출력합니다.
--정렬순서는부서번호(department_id)내림차순입니다.
--문제5.업무( job_id)별로평균임금, 최고임금, 최저임금을업무아이디( job_id)와함께출력하고정렬순서는최저임금내림차순,평균임금(소수점반올림),오름차순순입니다.(정렬순서는최소임금2500 구간일때확인해볼것)
--문제6.가장오래근속한직원의입사일은언제인가요? 다음형식으로출력해주세요.예) 2001-01-13 토요일
--문제7.평균임금과최저임금의차이가2000 미만인부서(department_id), 평균임금, 최저임금그리고(평균임금–최저임금)를(평균임금–최저임금)의내림차순으로정렬해서출력하세요.
--문제8.업무(JOBS)별로최고임금과최저임금의차이를출력해보세요.차이를확인할수있도록내림차순으로정렬하세요? 
--문제92005년이후입사자중관리자별로평균급여최소급여최대급여를알아보려고한다.출력은관리자별로평균급여가5000이상중에평균급여최소급여최대급여를출력합니다.평균급여의내림차순으로정렬하고평균급여는소수점첫째짜리에서반올림하여출력합니다.문제10아래회사는보너스지급을위해직원을입사일기준으로나눌려고합니다. 입사일이02/12/31일이전이면'창립맴버, 03년은'03년입사’, 04년은‘04년입사’이후입사자는‘상장이후입사’optDate 컬럼의데이터로출력하세요.정렬은입사일로오름차순으로정렬합니다.


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




