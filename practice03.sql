-- 조인 연습문제

-- 문제1.직원들의사번(employee_id), 이름(firt_name), 성(last_name)과 부서명(department_name)을 조회하여 
-- 부서이름(department_name) 오름차순, 사번(employee_id) 내림차순으로정렬하세요.(106건)
select EMPLOYEE_ID 사번, FIRST_NAME 이름, LAST_NAME 성, department_name 부서명
from employees emp join departments dept
    on emp.department_id = dept.department_id
order by dept.department_name asc, emp.employee_id desc;

--쌤풀이 1번
select EMPLOYEE_ID 사번, FIRST_NAME 이름, LAST_NAME 성, department_name 부서명
from employees emp , departments dept -- 심플조인
where emp.department_id = dept.department_id
order by dept.department_name asc, emp.employee_id desc;

--------------------------------------------------------------------------------

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

--쌤풀이 -- 일반적 join조건의 수 = 테이블 수 -1개
select EMPLOYEE_ID 사번, FIRST_NAME 이름, SALARY 급여, 
    DEPARTMENT_NAME 부서명, JOB_TITLE 업무명
from employees e, departments d, jobs j
where e.department_id = d.department_id and
    e.job_id = j.job_id
ORDER BY employee_id;


-- 문제2-1.문제2에서부서가없는Kimberely(사번178)까지표시해보세요(107건) -외부조인
select employee_id, FIRST_NAME, salary, department_name, job_title
from employees emp 
    left OUTER JOIN departments dept
        on emp.department_id = dept.department_id
    inner join jobs job
        on emp.job_id = job.job_id 
order by emp.employee_id asc;

--쌤풀이 -- left outer join
select EMPLOYEE_ID 사번, FIRST_NAME 이름, SALARY 급여, 
    DEPARTMENT_NAME 부서명, JOB_TITLE 업무명
from employees e, departments d, jobs j
where e.department_id = d.department_id (+) and
    e.job_id = j.job_id
ORDER BY employee_id;

--쌤풀이 ansi
select EMPLOYEE_ID 사번, FIRST_NAME 이름, SALARY 급여, 
    DEPARTMENT_NAME 부서명, JOB_TITLE 업무명
from employees e left outer join departments d
    on e.department_id = d.department_id,
    jobs j
where e.job_id = j.job_id; 

--------------------------------------------------------------------------------

-- 문제3.도시별로 위치한 부서들을 파악하려고 합니다.
-- 도시아이디, 도시명, 부서명, 부서아이디를 도시아이디(오름차순)로 정렬하여 출력하세요 
-- 부서가없는도시는표시하지않습니다.(27건)
select dept.location_id, city, department_name, department_id
from departments dept join locations loc
    on dept.location_id = loc.location_id
where dept.location_id is not null
order by location_id asc;

--쌤풀이
select loc.location_id, city, department_name, department_id
from departments d join locations loc 
    on d.location_id = loc.location_id
order by loc.location_id;    


-- 문제3-1.문제3에서부서가없는도시도표시합니다.(43건)
select dept.location_id, city, department_name, department_id
from departments dept full outer join locations loc
    on dept.location_id = loc.location_id
order by location_id asc;

--쌤풀이
select loc.location_id, city, department_name, department_id
from locations loc left outer join departments d
    on loc.location_id = d.location_id
order by loc.location_id;        
    

--------------------------------------------------------------------------------

-- 문제4.지역(regions)에 속한 나라들을 지역이름(region_name), 나라이름(country_name)으로
-- 출력하되지역이름(오름차순), 나라이름(내림차순) 으로정렬하세요.(25건)
select region_name, country_name
from regions reg join countries cou
    on reg.region_id = cou.region_id
ORDER BY reg.region_name asc, cou.country_name desc;

--쌤풀이
select region_name 지역이름, country_name 나라이름
from regions r, countries c
where r.region_id = c.region_id
order by r.region_name, country_name desc; -- 오름차순 asc는 기본값


--------------------------------------------------------------------------------

-- 문제5. 자신의 매니저보다 채용일(hire_date)이 빠른사원의
-- 사번(employee_id), 이름(first_name)과 채용일(hire_date), 
-- 매니저이름(first_name), 매니저입사일(hire_date)을 조회하세요.(37건)
select emp.employee_id, emp.first_name, emp.hire_date "자신의 채용일", 
        man.first_name "매니저이름", man.hire_date "매니저 채용일"
FROM employees emp JOIN employees man
    on emp.manager_id = man.employee_id -- 여기 설정하는거 주의
where TO_DATE(emp.hire_date, 'YYYY-MM-DD') < TO_DATE( man.hire_date, 'YYYY-MM-DD') ;

--------------------------------------------------------------------------------

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