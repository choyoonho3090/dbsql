-- GROUPING (cube, rollup 절의 사용된 컬럼)
-- 해당 컬럼이 소계 계산에 사용된 경우 1
--                     사용되지 않은 경우 0
-- job 컬럼
-- case1. GROUPING(job)= 1 AND GROUPING(dpetno)= 1
-- case else
--         job => job

--실습 GROUP_AD2
SELECT CASE 
            WHEN GROUPING(job) = 1 AND
                 GROUPING(deptno) = 1 THEN '총계'
            ELSE job
       END job, deptno,
       GROUPING(job), GROUPING(deptno), sum(sal) sal
FROM emp
GROUP BY ROLLUP(job, deptno);


--실습 GROUP_AD3
SELECT DEPTNO, job, SUM(SAL)sal
FROM emp
GROUP BY ROLLUP (DEPTNO,JOB);



--CUBE (col, col2...)
--CUBE 절에 나열된 컬럼의 가능한 모든 조합에 대해 서브 그룹으로 생성
--CUBE에 나열된 컬럼에 대해 방향성은 없다(rollup과의 차이)
--GROUP BY CUBE(job,deptno)
--OO : GROUP BY job, deptno
--OX : GROUP BY job
--XO : GROUP BY deptno
--XX : GROUP BY  --모든 데이터에 대해서

SELECT job, deptno, SUM(SAL)
FROM emp
GROUP BY CUBE(job, deptno);


--SUBQUERY를 통한 업데이트
DROP TABLE EMP_TEST;

--emp테이블의 데이터를 포함해서 모든 컬럼을 이용하여 emp_test테이블로 생성
CREATE TABLE emp_test AS
SELECT *
FROM EMP;

--emp_test 테이블의 dept테이블에서 관리되고 있는 dname 컬럼을 추가
ALTER TABLE emp_test ADD (dname VARCHAR2(14));

SELECT *
FROM emp_test;

--emp_test테이블의 dname 컬럼을 dept테이블의 dname 컬럼값으로 업데이트하는 쿼리 작성
UPDATE emp_test SET dname = (SELECT dname
                             FROM dept
                             WHERE dept.deptno = emp_test.deptno);
COMMIT;



--correlated subquery update a1
--dept테이블을 이용하여 dept_test 테이블 생성
CREATE TABLE dept_test AS
SELECT *
FROM dept;
--dept_test 테이블에 empcnt(number) 컬럼 추가
ALTER TABLE dept_test ADD (empcnt NUMBER);
--subquery를 이용하여 dept_test테이블의 empcnt 컬럼에 해당 부서원 수를 update쿼리 작성
UPDATE dept_test SET EMPCNT = (SELECT COUNT(DEPTNO)
                               FROM emp
                               WHERE dept_test.DEPTNO = emp.DEPTNO
                               );
SELECT *
FROM dept_test;


INSERT INTO DEPT_test VALUES (98,'it','daejeon',0);
INSERT INTO DEPT_test VALUES (99,'it','daejeon',0);
--correlated subquery delete a2
--emp테이블의 직원들이 속하지 않은 부서 정보 삭제하는 쿼리를
--서브쿼리를 이용하여 작성하세요.
delete from dept_test where NOT EXISTS (SELECT 'X'
                                    FROM EMP
                                    WHERE emp.DEPTNO = DEPT_test.DEPTNO);
SELECT * 
FROM dept_test;



--correlated subquery delete a3
--EMP테이블을 이용하여 EMP_test테이블 생성
CREATE TABLE emp_test AS
SELECT *
FROM EMP;
--EMP_TEST테이블에 DNAME컬럼 추가
ALTER TABLE emp_test ADD (DNAME VARCHAR2(14));
--SUBQUERY를 이용해 EMP_TEST테이블에서 본인이 속한 부서의(SAL)평균 급여보다 
--급여가 작은 직원의 급여를 현 급여에서 200을 추가해서 업데이트 하는 쿼리를 작성
UPDATE emp_test a SET sal = sal + 200
WHERE SAL < (SELECT AVG(SAL)
             FROM EMP);
             
             
--emp,emp_test empno컬럼으로 같은 값끼리 조회
--1. emp.empno, emp.ename, emp.sal, emp_test.sal
SELECT emp.empno, emp.ename, emp.sal, emp_test.sal, emp.DEPTNO
FROM emp , emp_test 
WHERE emp.empno = emp_test.empno;
--2. emp.empno, emp.ename, emp.sal, emp_test.sal 해당사원(emp테이블 기준)이 속한 부서의 급여평균
SELECT emp.empno, emp.ename, emp.sal, emp_test.sal, emp.DEPTNO, 
        (SELECT AVG(SAL)
         FROM EMP
         GROUP BY DEPTNO)AVG
FROM emp , emp_test 
WHERE emp.empno = emp_test.empno;


