/*
 *　スキーマ作成
 */
create schema test_plpgsql;

/*
 *　DDL作成
 */
create table test_plpgsql.dept (
    deptno char(5)  primary key,
    deptname varchar(40)    unique not null
);

create table test_plpgsql.pos (
    poscode char(1)  primary key,
    posname varchar(20)    unique not null
);

create table test_plpgsql.emp (
    empno char(5)  primary key,
    empname varchar(40)    not null,
	poscode char(1) not null references test_plpgsql.pos(poscode),
	age	numeric(3,0)	check(age >=0)
);

create table test_plpgsql.member (
    deptno char(5) not null references test_plpgsql.dept(deptno),
    empno  char(5) not null references test_plpgsql.emp(empno), 
    primary key(deptno, empno)
);

create table test_plpgsql.test (
    col1 INTEGER primary key,
    col2 TEXT
);

create sequence test_plpgsql.empno_seq;

/*
 *　DML作成プロシージャ
 */
CREATE OR REPLACE PROCEDURE test_plpgsql.main() AS $$ 
DECLARE	--変数の宣言       
    BEGIN	--手続き内容を以下に書く 
    SET SEARCH_PATH='test_plpgsql';
    perform setval ('empno_seq', 1, false);
    -- マスタデータ登録
    -- 部署
    INSERT INTO test_plpgsql.dept VALUES ('0','営業部');
    INSERT INTO test_plpgsql.dept VALUES ('1','開発部');
    INSERT INTO test_plpgsql.dept VALUES ('2','人事部');
    -- 役職
    INSERT INTO test_plpgsql.pos VALUES ('0', '部長');
    INSERT INTO test_plpgsql.pos VALUES ('1', '課長');
    INSERT INTO test_plpgsql.pos VALUES ('2', '主任');
    INSERT INTO test_plpgsql.pos VALUES ('3', '社員'); 
    --社員
    CALL test_plpgsql.regemployee(1,'0','0','営業部長',45);
    CALL test_plpgsql.regemployee(1,'1','0','開発部長',45);
    CALL test_plpgsql.regemployee(1,'2','0','人事部長',45);
    CALL test_plpgsql.regemployee(3,'0','1','営業課長',40);
    CALL test_plpgsql.regemployee(3,'1','1','開発課長',40);
    CALL test_plpgsql.regemployee(3,'2','1','人事課長',40);
    CALL test_plpgsql.regemployee(30,'0','2','営業主任',35);
    CALL test_plpgsql.regemployee(30,'1','2','開発主任',35);
    CALL test_plpgsql.regemployee(30,'2','2','人事主任',35);
    CALL test_plpgsql.regemployee(300,'0','3','営業社員',30);
    CALL test_plpgsql.regemployee(300,'1','3','開発社員',30);
    CALL test_plpgsql.regemployee(300,'2','3','人事社員',30);
END;	--手続き内容終わり
$$
LANGUAGE plpgsql;	--言語を指定
/*
 *　社員登録プロシージャ
 */
CREATE OR REPLACE PROCEDURE test_plpgsql.regemployee(count IN int, deptno IN char, poscode IN char, emponame IN varchar, age IN int) 
AS $$ 
BEGIN	--手続き内容を以下に書く
    IF count < 1 THEN
        RETURN;
    ELSEIF count = 1 THEN
        INSERT INTO test_plpgsql.emp VALUES ((SELECT nextval('empno_seq')), emponame, poscode ,age);
        INSERT INTO test_plpgsql.member VALUES (deptno, (SELECT currval('empno_seq')));
    ELSE
        FOR i IN 1..count LOOP
            INSERT INTO test_plpgsql.emp VALUES ((SELECT nextval('empno_seq')), emponame || i, poscode ,age);
            INSERT INTO test_plpgsql.member VALUES (deptno, (SELECT currval('empno_seq')));
        END LOOP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION '例外発生SQLSTATE:%, SQLERRM:%', SQLSTATE,SQLERRM;
END;	--手続き内容終わり
$$
LANGUAGE plpgsql;	--言語を指定
/*
 *　DML作成
 */
CALL test_plpgsql.main();
