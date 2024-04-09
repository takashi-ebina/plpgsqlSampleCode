/* *******************************************
 * 2.PL/pgSQLの構造
 * *******************************************/
/* *******************************************
 * ファンクションに関するサンプルコード
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample1_01() RETURNS VOID AS $$ 
DECLARE    
BEGIN    
    RAISE INFO 'HELLO WORLD！！'; -- コンソールに「HELLO WORLD！！」が出力
    RETURN;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * プロシージャーに関するサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample1_02() AS $$ 
DECLARE    
BEGIN    
    RAISE INFO 'HELLO WORLD！！'; -- コンソールに「HELLO WORLD！！」が出力
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * AS句以降のドル引用符付けを利用しない場合のサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample1_02() AS '
DECLARE    
BEGIN    
    RAISE INFO ''HELLO WORLD！！'';
END;    
' LANGUAGE plpgsql;
/* *******************************************
 * 副ブロックに関するサンプルコード
 * 参考リンク：
 * https://www.postgresql.jp/document/12/html/test_plpgsql-structure.html
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample2_01(addnum numeric) AS $$ 
<< outerblock >> -- ラベル名
DECLARE    
num1  numeric := 30;
BEGIN    
    RAISE INFO '[ブロックの外側] num1の値：%',num1;
    -- 副ブロックの開始 ------------------------
    DECLARE    
        num1  numeric := 50;           
    BEGIN    
        RAISE INFO '[ブロックの内側] num1の値：%',num1;
        RAISE INFO '[ブロックの外側] num1の値：%',outerblock.num1;
    END;
     -- 副ブロックの終了 ------------------------
     
     num1 := num1 + addnum;
     
     RAISE INFO '[ブロックの外側] num1の値：%',num1;
     RAISE INFO '[ブロックの外側] num1の値：%',outerblock.num1; 
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * 3.宣言
 * *******************************************/
/* *******************************************
 * 変数 / 定数 / デフォルト値 / NOT NULLについてのサンプルコード
 * 参考リンク：
 * https://www.postgresql.jp/document/12/html/test_plpgsql-declarations.html
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample3_01() AS $$
DECLARE    
-- 変数
url VARCHAR := 'https://www.postgresql.jp/document/';
-- 定数
user_id CONSTANT INTEGER := 10;
-- NOT NULL / デフォルト値
tax NUMERIC(3,2) NOT NULL DEFAULT 1.08;
/* 【NG例】
 * NOT NULLの場合に初期値を設定しない場合はエラーとなる
 * tax NUMERIC(3,2) NOT NULL;
 * [出力結果]: ERROR: variable "tax" must have a default value, since it's declared NOT NULL
 */

BEGIN
    RAISE INFO '** 変数の確認 ********************************';
    RAISE INFO '[変更前]urlの値：%',url;
    url = 'https://www.postgresql.jp/document/13/html/';
    RAISE INFO '[変更後]urlの値：%',url;

    /* 【NG例】
     * 定数に代入した場合はエラーとなる
     * user_id := 11;
     * [出力結果]:variable "user_id" is declared CONSTANT
     */
    RAISE INFO '** 定数の確認 ********************************';
    RAISE INFO 'user_idの値：%',user_id;
    
    RAISE INFO '** NOT NULL / デフォルト値の確認 **************';
    RAISE INFO '[変更前]taxの値：%',tax;
    /* 【NG例】
     * NOT NULLの変数にNULLを代入するとエラーになる
     * tax = NULL;
     * [出力結果]:vnull value cannot be assigned to variable "tax" declared NOT NULL
     */
    tax = 1.10;
    RAISE INFO '[変更後]taxの値：%',tax;
END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * %ROWTYPE / %TYPEについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample3_02() AS $$
DECLARE    
-- 型のコピー　%TYPE
-- deptテーブルのdeptnoカラムはcharacter型のため、character型となる
myfield test_plpgsql.dept.deptno%TYPE;
-- 行型　%ROWTYPE
myrow test_plpgsql.member%ROWTYPE; 

BEGIN    
    -- 型のコピー　%TYPE
    RAISE INFO '** %TYPEの確認 *******************************';
    SELECT deptno INTO myfield FROM test_plpgsql.dept ORDER BY deptno LIMIT 1;
    RAISE INFO 'myfieldの値:%, myfieldの型:%', myfield, pg_typeof(myfield);

    -- 行型　%ROWTYPE
    RAISE INFO '** %ROWTYPEの確認 ****************************';
    SELECT * INTO myrow FROM test_plpgsql.member ORDER BY deptno LIMIT 1;
    RAISE INFO 'myrow.deptnoの値:%, myrow.empnoの値:%', myrow.deptno, myrow.empno;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * RECORD型についてのサンプルコード
 * 問い合わせ結果による繰り返しで利用
 * [FOR target IN query LOOP...]
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample3_03() AS $$
DECLARE    
arow RECORD;

BEGIN    
    FOR arow IN SELECT * FROM test_plpgsql.member ORDER BY deptno LOOP
        RAISE INFO 'myrow.deptnoの値:%, myrow.empnoの値:%', myrow.deptno, myrow.empno;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;    


-- 複合型のユーザ定義
create type test_plpgsql.DATA_TYPE1 as (
    param1 numeric(1,0)
    ,param2 text
    ,param3 bytea
);

/* *******************************************
 *　ユーザ定義型についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample3_04_01() AS $$
DECLARE    
    -- ユーザ定義型の宣言
    dataType1 test_plpgsql.DATA_TYPE1;

BEGIN    
    -- 値の設定
    dataType1.param1 := 1;
    dataType1.param2 := 'DATA_TYPE1';
    dataType1.param3 := 'DATA_TYPE1'::bytea;

    -- 値の参照
    RAISE INFO '--ユーザ定義の値確認！！！！--';
    RAISE INFO 'dataType1:%', dataType1;
    RAISE INFO 'dataType1.param1:%', dataType1.param1;
    RAISE INFO 'dataType1.param2:%', dataType1.param2;
    RAISE INFO 'dataType1.param3:%', dataType1.param3;
END;    
$$ LANGUAGE plpgsql;    

-- 複合型のユーザ定義型(入れ子パターン)
create type test_plpgsql.DATA_TYPE2 as (
    param1 numeric(1,0)
    ,param2 test_plpgsql.DATA_TYPE1
);
/* *******************************************
 *　ユーザ定義型(入れ子パターン)についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample3_04_02() AS $$
DECLARE    
    -- ユーザ定義型の宣言
    dataType1 test_plpgsql.DATA_TYPE1;
    dataType2 test_plpgsql.DATA_TYPE2;

BEGIN    
    -- 値の設定
    dataType1.param1 := 1;
    dataType1.param2 := 'DATA_TYPE1';
    dataType1.param3 := 'DATA_TYPE1'::bytea;

    dataType2.param1 := 1;
    dataType2.param2 := dataType1;
    
    /* 【NG例】
     * 入れ子のユーザ定義を設定する際、以下のやり方だとエラーになる
     * dataType2.param2.param1 := 1;
     * [出力結果]:datatype2.param2.param1" is not a known variable
     */
    -- 値の参照
    RAISE INFO '--ユーザ定義の値確認！！！！--';
    RAISE INFO 'dataType2:%', dataType2;
    RAISE INFO 'dataType2.param1:%', dataType2.param1;
    RAISE INFO 'dataType2.param2:%', dataType2.param2;
    
    /* 【NG例】
     * 入れ子のユーザ定義の参照の仕方に注意
     * RAISE INFO 'dataType2.param2:%', dataType2.param2.param1;
     * [出力結果]:missing FROM-clause entry for table "param2"
     */
    -- 入れ子のユーザ定義を参照したい場合は以下のように()を利用する
    RAISE INFO '(dataType2.param2).param1:%', (dataType2.param2).param1;
    RAISE INFO '(dataType2.param2).param2:%', (dataType2.param2).param2;
    RAISE INFO '(dataType2.param2).param2:%', (dataType2.param2).param3;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 *　スカラ型の配列の宣言／初期化／代入についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample3_05_01() AS $$
DECLARE    
    -- 配列の宣言 スカラ型
    arr1 INT[];
    arr2 INT[];
    /* 【NG例】
     * %TYPEを用いて配列を作成することは不可
     * arr2 test_plpgsql.dept.deptno%type[];
     * [出力結果]:NG SQLエラー [42601]: ERROR: syntax error at or near "["
     */
BEGIN    
    -- 配列の値の設定方法
    -- 方法①：配列コンストラクタを利用するやり方
    arr1 := array[123, 456, 789];
    -- 方法②：添字を設定して直接代入するやり方
    arr2[1] := 1;
    arr2[2] := 2;
    arr2[3] := 3;

    RAISE INFO '--配列の値確認！！！！--';
    RAISE INFO 'arr1[1]:%', arr1[1];
    RAISE INFO 'arr1[2]:%', arr1[2];
    RAISE INFO 'arr1[3]:%', arr1[3];
    RAISE INFO 'arr2[1]:%', arr2[1];
    RAISE INFO 'arr2[2]:%', arr2[2];
    RAISE INFO 'arr2[3]:%', arr2[3];
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 *　複合型のユーザ定義の配列の宣言／初期化／代入についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample3_05_02() AS $$
DECLARE    
    -- 配列の宣言 ユーザ定義型
    dataType test_plpgsql.DATA_TYPE1;
    arrDataType test_plpgsql.DATA_TYPE1[];
    
BEGIN    
    -- 値の設定
    dataType.param1 := 1;
    dataType.param2 := 'DATA_TYPE1';
    dataType.param3 := 'DATA_TYPE1'::bytea;
    arrDataType[1] := dataType;

    dataType.param1 := 2;
    dataType.param2 := 'DATA_TYPE2';
    dataType.param3 := 'DATA_TYPE2'::bytea;
    arrDataType[2] := dataType;

    /* 【NG例】
     * 配列[添字].ユーザ定義の項目名　といった記載の仕方はエラーとなる
     * arrDataType[2].param1 := 3;
     * [出力結果]:[42601]: ERROR: syntax error at or near "."
     */
    RAISE INFO 'arrDataType[1]:%', arrDataType[1];
    RAISE INFO 'arrDataType[2]:%', arrDataType[2];

END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 *　関数引数の宣言についてのサンプルコード
 * - 第一引数：型、別名（addnum）を両方宣言
 * - 第二引数：型のみ宣言
 *　　別名は引数ではなく、DECLARE内で宣言(subtractnum)
 *　　[name ALIAS FOR $n;]
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample4_01(addnum NUMERIC, NUMERIC) AS $$
DECLARE    
initnum NUMERIC := 10;
subtractnum ALIAS FOR $2;

BEGIN    
    RAISE INFO '[識別子]第一引数の値：%', $1;
    RAISE INFO '[識別子]第二引数の値：%', $2;
    RAISE INFO '[別名]第一引数の値：%', initnum;
    RAISE INFO '[別名]第二引数の値：%', addnum;
    RAISE INFO '計算結果：%', initnum + addnum -subtractnum;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 *　4.基本的な文
 * *******************************************/
/* *******************************************
 *　代入についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample5_01() AS $$
DECLARE    
    user_name varchar(255);
    user_id integer;
BEGIN    
    user_name := 'ぽすぐれ太郎';
    user_id = 1;
    raise INFO 'user_name:%, user_id:%', user_name, user_id;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * PERFORMについてのサンプルコード（結果を伴わないコマンドの実行）
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample6_01() AS $$
DECLARE    
    myrow record;
    message text;
BEGIN
    /* 【NG例】
     * SELECT文を実行するとエラーとなる
     * select * from test_plpgsql.member;
     * [出力結果]:
     * ERROR:  query has no destination for result data
     * HINT:  If you want to discard the results of a SELECT, use PERFORM instead.
     * CONTEXT:  PL/pgSQL function test_plpgsql.sample5_01() line 4 at SQL statement
     */
    -- SELECT INTO または PERFORM を利用することでエラーを回避することができる
    SELECT * INTO myrow FROM pg_tables ORDER BY schemaname;
    RAISE INFO 'myrowからスキーマ名とテーブル名を出力：%', myrow.schemaname || '.' || myrow.tablename;
    PERFORM * from test_plpgsql.member;
    /* 【NG例】
     * FUNCTIONをSELECT FUNCTION名;で実行するとエラーとなる
     * SELECT test_plpgsql.sample6_01_01();
     * [出力結果]:
     * ERROR:  query has no destination for result data
     * HINT:  If you want to discard the results of a SELECT, use PERFORM instead.
     */
     -- SELECT INTO または PERFORM を利用することでエラーを回避することができる
    SELECT * into message FROM test_plpgsql.sample6_01_01();
    RAISE INFO '%', message;
    PERFORM test_plpgsql.sample5_02_01();

END;    
$$ LANGUAGE plpgsql;    

CREATE OR REPLACE FUNCTION test_plpgsql.sample6_01_01() RETURNS TEXT AS $$
DECLARE    
BEGIN    
    RETURN '[execute]:sample6_01_01';
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * 1行の結果を返す問い合わせの実行についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample7_01() AS $$
DECLARE    
    myrow record;
BEGIN    

    RAISE INFO 'SELECT INTO 実行（STRICTなし）';
    SELECT * INTO myrow FROM test_plpgsql.emp WHERE empno = '1';
    RAISE INFO '従業員名：%', myrow.empname;
    RAISE INFO 'SELECT INTO 実行（STRICTあり）';
    SELECT * INTO STRICT myrow FROM test_plpgsql.emp WHERE empno = '1';
    RAISE INFO '従業員名：%', myrow.empname;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'employee not found';
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'employee not unique';

END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * 0行の結果を返す問い合わせの実行についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample7_02() AS $$
DECLARE    
    myrow record;
BEGIN    

    RAISE INFO 'SELECT INTO 実行（STRICTなし）';
    SELECT * INTO myrow FROM test_plpgsql.emp WHERE empno = '0';
    RAISE INFO '従業員名：%', myrow.empname;
    RAISE INFO 'SELECT INTO 実行（STRICTあり）';
    SELECT * INTO STRICT myrow FROM test_plpgsql.emp WHERE empno = '0';
    RAISE INFO '従業員名：%', myrow.empname;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'employee not found';
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'employee not unique';

END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * 2行以上の結果を返す問い合わせの実行についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample7_03() AS $$
DECLARE    
    myrow record;
BEGIN    

    RAISE INFO 'SELECT INTO 実行（STRICTなし）';
    SELECT * INTO myrow FROM test_plpgsql.emp WHERE poscode = '1';
    RAISE INFO '従業員名：%', myrow.empname;
    RAISE INFO 'SELECT INTO 実行（STRICTあり）';
    SELECT * INTO STRICT myrow FROM test_plpgsql.emp WHERE poscode = '1';
    RAISE INFO '従業員名：%', myrow.empname;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'employee not found';
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'employee not unique';

END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * INSERT / UPDATE / DELETE RETURNING（STRICT無し）についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample8_01() AS $$
DECLARE    
    myrow record;
BEGIN    

    RAISE INFO 'UPDATE RETURNING 実行（STRICTなし／更新件数1件）';
    UPDATE test_plpgsql.emp SET empname = '人事社員30001' WHERE empno = '1002' RETURNING * INTO myrow;
    RAISE INFO '従業員No.：% 従業員名：% 役職コード：% 年齢：%', myrow.empno, myrow.empname, myrow.poscode, myrow.age;
    RAISE INFO 'UPDATE RETURNING 実行（STRICTなし／更新件数2件）';
    UPDATE test_plpgsql.emp SET empname = '人事社員30001' WHERE empno = '1001' OR empno = '1002' RETURNING * INTO myrow;
    RAISE INFO '従業員No.：% 従業員名：% 役職コード：% 年齢：%', myrow.empno, myrow.empname, myrow.poscode, myrow.age;    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'employee not found';
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'employee not unique';

END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * INSERT / UPDATE / DELETE RETURNING（STRICT有り）についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample8_02() AS $$
DECLARE    
    myrow record;
BEGIN    

    RAISE INFO 'UPDATE RETURNING 実行（STRICTあり／更新件数1件）';
    UPDATE test_plpgsql.emp SET empname = '人事社員30001' WHERE empno = '1002' RETURNING * INTO STRICT myrow;
    RAISE INFO '従業員No.：% 従業員名：% 役職コード：% 年齢：%', myrow.empno, myrow.empname, myrow.poscode, myrow.age;
    RAISE INFO 'UPDATE RETURNING 実行（STRICTあり／更新件数0件）';
    UPDATE test_plpgsql.emp SET empname = '人事社員30001' WHERE empno = '1003' RETURNING * INTO STRICT myrow;
    RAISE INFO '従業員No.：% 従業員名：% 役職コード：% 年齢：%', myrow.empno, myrow.empname, myrow.poscode, myrow.age;    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'employee not found';
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'employee not unique';

END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * EXECUTEについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample9_01(numeric, text) AS $$
DECLARE    
    myrow record;
BEGIN    

    EXECUTE 'CREATE TEMPORARY TABLE IF NOT EXISTS sample11 (col1 numeric, col2 text);';
    EXECUTE 'TRUNCATE TABLE sample11';

    -- EXECUTEに指定するコマンドのパラメータを渡したい場合は、「EXECUTE USING」を利用する
    EXECUTE 'INSERT INTO sample11 (col1, col2) VALUES ($1, $2);' USING $1, $2;

    -- EXECUTEに指定するコマンドの実行結果を受け取りたい場合は、「EXECUTE INTO」を利用する
    EXECUTE 'SELECT * FROM sample11 WHERE col1 = $1;' INTO myrow USING $1;

    RAISE INFO 'myrow.col1：% myrow.co2：%', myrow.col1, myrow.col2;
    EXECUTE 'UPDATE sample11 SET col2 = ''UPDATE実施！''  WHERE col1 = ' || $1 || 'RETURNING * ;' INTO myrow ;
    RAISE INFO 'col1：% col2：% ', myrow.col1, myrow.col2;    

END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * 結果ステータスの取得についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample10_01() AS $$
DECLARE    
    integer_var1 INTEGER;
    stack text;
BEGIN
    PERFORM * FROM test_plpgsql.emp;
    -- test_plpgsql.empテーブルのレコード件数を取得する
    GET CURRENT DIAGNOSTICS integer_var1 = ROW_COUNT;
    RAISE INFO '%', integer_var1;

    GET DIAGNOSTICS stack = PG_CONTEXT;
    RAISE INFO '%', stack;

END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * FOUNDについてのサンプルコード（SELECT INTOの場合）
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample11_01() AS $$
DECLARE    
    myrow record;
BEGIN
    RAISE INFO '** 初期値の確認 ********************************';
    RAISE INFO 'FOUNDの値:%', FOUND;
    
    RAISE INFO '** SELECT INTO実行後の確認（レコード有り） ********';
    SELECT * INTO myrow FROM test_plpgsql.emp WHERE poscode = '1';
    RAISE INFO 'FOUNDの値:%', FOUND;
    IF FOUND THEN
        RAISE INFO 'レコードが存在します！';
    END IF;

    RAISE INFO '** SELECT INTO実行後の確認（レコード無し） ********';
    SELECT * INTO myrow FROM test_plpgsql.emp WHERE empno = '0';
    RAISE INFO 'FOUNDの値:%', FOUND;
    IF NOT FOUND THEN
        RAISE INFO 'レコードが存在しません！';
    END IF;
END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * FOUNDについてのサンプルコード（PERFORMの場合）
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample11_02() AS $$
DECLARE    
BEGIN
    RAISE INFO '** 初期値の確認 ********************************';
    RAISE INFO 'FOUNDの値:%', FOUND;

    RAISE INFO '** PERFORM実行後の確認（レコード有り） ************';
    PERFORM * FROM test_plpgsql.emp WHERE poscode = '1';
    RAISE INFO 'FOUNDの値:%', FOUND;
    IF FOUND THEN
        RAISE INFO 'レコードが存在します！';
    END IF;

    RAISE INFO '** PERFORM実行後の確認（レコード無し） ************';
    PERFORM * FROM test_plpgsql.emp WHERE empno = '0';
    RAISE INFO 'FOUNDの値:%', FOUND;
    IF NOT FOUND THEN
        RAISE INFO 'レコードが存在しません！';
    END IF;
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * FOUNDについてのサンプルコード（UPDATEの場合）
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample11_03() AS $$
DECLARE    
BEGIN
    RAISE INFO '** 初期値の確認 ********************************';
    RAISE INFO 'FOUNDの値:%', FOUND;

    RAISE INFO '** UPDATE実行後の確認（レコード有り） ************';
    UPDATE test_plpgsql.emp SET empname = '人事社員30001' WHERE empno = '1002';    
    RAISE INFO 'FOUNDの値:%', FOUND;
    IF FOUND THEN
        RAISE INFO 'レコードが存在します！';
    END IF;

    RAISE INFO '** UPDATE実行後の確認（レコード無し） ************';
    UPDATE test_plpgsql.emp SET empname = '人事社員30001' WHERE empno = '1003';
    RAISE INFO 'FOUNDの値:%', FOUND;
    IF NOT FOUND THEN
        RAISE INFO 'レコードが存在しません！';
    END IF;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * FOUNDについてのサンプルコード（FETCHの場合）
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample11_04(VARCHAR) AS $$
DECLARE    
    empnames CURSOR (pPosCode VARCHAR) FOR 
        SELECT empname FROM test_plpgsql.emp WHERE poscode = pPosCode;
    empname varchar(40);
BEGIN
    RAISE INFO '** 初期値の確認 ********************************';
    RAISE INFO 'FOUNDの値:%', FOUND;

    RAISE INFO '** FETCH実行後の確認 **************';
    OPEN empnames($1);    
    LOOP
    FETCH empnames INTO empname;
    RAISE INFO 'FOUNDの値:%', FOUND;
        IF FOUND THEN
            RAISE INFO 'レコードが存在します！';
        ELSE
            RAISE INFO 'レコードが存在しません！';
            EXIT;
        END IF;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * FOUNDについてのサンプルコード（MOVEの場合）
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample11_05(VARCHAR) AS $$
DECLARE    
    poanames CURSOR (pPosCode VARCHAR) FOR 
        SELECT posname FROM test_plpgsql.pos WHERE poscode = pPosCode;
    poaname varchar(20);
BEGIN
    RAISE INFO '** 初期値の確認 ********************************';
    RAISE INFO 'FOUNDの値:%', FOUND;

    OPEN poanames($1);
    RAISE INFO '** MOVE実行後の確認（MOVE成功） ************';
    MOVE FORWARD 4 IN poanames;    
    RAISE INFO 'FOUNDの値:%', FOUND;

    RAISE INFO '** MOVE実行後の確認（MOVE失敗） ************';
    MOVE FORWARD 4 IN poanames;    
    RAISE INFO 'FOUNDの値:%', FOUND;
    FETCH poanames INTO poaname;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * FOUNDについてのサンプルコード（RETURN QUERYの場合）
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample11_06(VARCHAR) 
RETURNS TABLE ( 
    p_poscode char(1),
    p_posname varchar(20)
) AS $$
DECLARE    
BEGIN
    RAISE INFO '** 初期値の確認 ********************************';
    RAISE INFO 'FOUNDの値:%', FOUND;

    RAISE INFO '** RETURN QUERY実行後の確認 ********************';
    RETURN QUERY SELECT * FROM test_plpgsql.pos WHERE poscode = $1;    
    RAISE INFO 'FOUNDの値:%', FOUND;
    RETURN;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * 5.制御構造
 * *******************************************/
/* *******************************************
 * INパラメータについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample12_01(name IN VARCHAR(40)) AS $$
DECLARE    
    empAge NUMERIC(3,0);
BEGIN
    SELECT age INTO empAge FROM test_plpgsql.emp WHERE empname = name;
    RAISE INFO '%さんの年齢は%歳です', name ,empAge;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * OUTパラメータについてのサンプルコード(OUTパラメータが1つ)
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample12_02(name IN VARCHAR(40), empAge OUT NUMERIC(3,0)) AS $$
DECLARE    
BEGIN
    SELECT age INTO empAge FROM test_plpgsql.emp WHERE empname = name;
    RAISE INFO '%さんの年齢は%歳です', name ,empAge;
    /* 【NG例】
     * RETURNの際にOUTパラメータを指定するとエラーとなる
     * RETURN empAge;
     * [出力結果]: RETURN cannot have a parameter in function with OUT parameters
     */
    RETURN;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * OUTパラメータについてのサンプルコード(OUTパラメータが1つ)
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample12_03(name IN VARCHAR(40), empAge OUT NUMERIC(3,0), result OUT NUMERIC(1,0)) 
RETURNS RECORD AS $$
DECLARE    
BEGIN
    result := 0;
    SELECT age INTO empAge FROM test_plpgsql.emp WHERE empname = name;
    RAISE INFO '%さんの年齢は%歳です', name ,empAge;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        result := -1;
        RETURN;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * INOUTパラメータについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample12_04(empAge IN NUMERIC(3,0)) AS $$
DECLARE    
    empNumber NUMERIC(5,0);
BEGIN
    SELECT count INTO empNumber FROM test_plpgsql.sample12_04_01(empAge, empNumber);
    RAISE INFO '%歳以上の社員は%人です', empAge ,empNumber;
END;    
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_plpgsql.sample12_04_01(empAge IN NUMERIC(3,0), count IN OUT NUMERIC(5,0)) AS $$
DECLARE    
BEGIN
    RAISE INFO 'COUNTの値：%', count;
    SELECT COUNT(*) INTO count FROM test_plpgsql.emp WHERE age >= empAge;
    RAISE INFO 'COUNTの値：%', count;
    RETURN;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * RETURNについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample13_01(name IN VARCHAR(40)) RETURNS NUMERIC(3,0) AS $$
DECLARE    
    empAge NUMERIC(3,0);
BEGIN
    SELECT age INTO empAge FROM test_plpgsql.emp WHERE empname = name;
    RETURN empAge;
END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * RETURNについてのサンプルコード(OUTパラメータが存在する場合)
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample13_02(name IN VARCHAR(40), empAge OUT NUMERIC(3,0)) RETURNS NUMERIC(3,0) AS $$
DECLARE    
BEGIN
    SELECT age INTO empAge FROM test_plpgsql.emp WHERE empname = name;
    RAISE INFO '%さんの年齢は%歳です', name ,empAge;
    /* 【NG例】
     * RETURNの際にOUTパラメータを指定するとエラーとなる
     * RETURN empAge;
     * [出力結果]: RETURN cannot have a parameter in function with OUT parameters
     */
	RETURN;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * RETURNについてのサンプルコード(戻り値宣言／OUTパラメータが存在しない場合)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample13_03(empAge IN NUMERIC(3,0)) AS $$
DECLARE    
    empNumber NUMERIC(5,0);
BEGIN
    IF empAge < 0 THEN
        -- 入力値が０未満の場合はSELECTを実行せずに処理を終了する
        RAISE INFO '年齢が0歳未満です';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO empNumber FROM test_plpgsql.emp WHERE age >= empAge;
    RAISE INFO '%歳以上の社員は%人です', empAge ,empNumber;
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * RETURN NEXTについてのサンプルコード(SETOF sometypeの場合)
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample14_01() RETURNS SETOF test_plpgsql.pos AS $$
DECLARE    
    myrow test_plpgsql.pos%ROWTYPE;
BEGIN
    FOR myrow IN SELECT * FROM test_plpgsql.pos LOOP
        -- ここで処理を実行できます
        RETURN NEXT myrow; -- SELECTの現在の行を返します
    END LOOP;
    RETURN;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * RETURN NEXTについてのサンプルコード(TABLE(columns)の場合)
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample14_02(INTEGER) 
RETURNS TABLE (
    empno char(5),
    empname varchar(40),
    poscode char(1),
    age    numeric(3,0)
) AS $$
DECLARE    
    myrow test_plpgsql.emp%ROWTYPE;
BEGIN
    FOR myrow IN SELECT * FROM test_plpgsql.emp ORDER BY empno LIMIT $1 LOOP
        empno := myrow.empno;
        empname := myrow.empname;
        poscode := myrow.poscode;
        age := myrow.age;
        RETURN NEXT; -- SELECTの現在の行を返します
    END LOOP;
    RETURN;
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * RETURN QUERYについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample15_01(CHAR) RETURNS SETOF test_plpgsql.emp AS $$
DECLARE    
BEGIN
    RETURN QUERY SELECT * FROM test_plpgsql.emp WHERE empno = $1;
    IF NOT FOUND THEN
        RAISE EXCEPTION '社員が存在しません empno:%.', $1;
    END IF;
    RETURN;
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * RETURN QUERY EXECUTEについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample15_02(CHAR) RETURNS SETOF test_plpgsql.emp AS $$
DECLARE    
BEGIN
    RETURN QUERY EXECUTE 'SELECT * FROM test_plpgsql.emp WHERE empno = $1' USING $1;
    IF NOT FOUND THEN
        RAISE EXCEPTION '社員が存在しません empno:%.', $1;
    END IF;
    RETURN;
END;    
$$ LANGUAGE plpgsql;
 

/*
IF文
*/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample17_01(CHAR) AS $$
DECLARE    
    myrow test_plpgsql.emp%ROWTYPE;
BEGIN
    SELECT * INTO STRICT myrow FROM test_plpgsql.emp WHERE empno = $1;
    IF myrow.age >= 45 THEN
        RAISE INFO '%はベテラン社員', myrow.empname;
    ELSIF myrow.age  >= 30 THEN
        RAISE INFO '%は中堅社員', myrow.empname;
    ELSE
        RAISE INFO '%は若手社員', myrow.empname;
    END IF;
END;    
$$ LANGUAGE plpgsql;    

/*
単純CASE文
*/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample18_01() AS $$
DECLARE    
    target NUMERIC;
BEGIN
    SELECT ROUND(( RANDOM() * (1 - 3) )::NUMERIC, 0) + 3 INTO target;
    CASE target
        WHEN 1 THEN
            RAISE INFO 'グー';
        WHEN 2 THEN
            RAISE INFO 'チョキ';
        WHEN 3 THEN
            RAISE INFO 'パー';
    END CASE;
END;    
$$ LANGUAGE plpgsql;    

/*
条件付きCASE文
*/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample18_02(CHAR) AS $$
DECLARE    
    myrow test_plpgsql.emp%ROWTYPE;
BEGIN
    SELECT * INTO STRICT myrow FROM test_plpgsql.emp WHERE empno = $1;
    CASE 
        WHEN myrow.age >= 45 THEN
            RAISE INFO '%はベテラン社員', myrow.empname;
        WHEN myrow.age  > 35 THEN
            RAISE INFO '%は中堅社員', myrow.empname;
        ELSE
            RAISE INFO '%は若手社員', myrow.empname;
    END CASE;
END;    
$$
LANGUAGE plpgsql;    

/*
条件付きCASE文
ELSEなしの場合は例外発生する
*/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample18_03(CHAR) AS $$
DECLARE    
    myrow test_plpgsql.emp%ROWTYPE;
BEGIN
    SELECT * INTO STRICT myrow FROM test_plpgsql.emp WHERE empno = $1;
    CASE 
        WHEN myrow.age >= 45 THEN
            RAISE INFO '%はベテラン社員', myrow.empname;
        WHEN myrow.age  > 35 THEN
            RAISE INFO '%は中堅社員', myrow.empname;
    END CASE;
END;    
$$ LANGUAGE plpgsql;    

/*
LOOP
WHILE
FOR
FOREACH
*/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample19_01() AS $$
DECLARE    
    i INTEGER := 0;
BEGIN
    LOOP
        EXIT WHEN i > 10;
        IF i % 2 = 0 THEN
            RAISE INFO '% ', i;
        END IF;
        i := i + 1;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;    

CREATE OR REPLACE PROCEDURE test_plpgsql.sample19_02() AS $$
DECLARE    
    i INTEGER := 0;
BEGIN
    LOOP
        i := i + 1;
        EXIT WHEN i > 10;
        CONTINUE WHEN i < 5;
        RAISE INFO '% ', i;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;    

CREATE OR REPLACE PROCEDURE test_plpgsql.sample19_03() AS $$
DECLARE    
    i INTEGER := 0;
BEGIN
    WHILE i > 10 LOOP
        RAISE INFO '% ', i;
        i := i + 1;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;    

CREATE OR REPLACE PROCEDURE test_plpgsql.sample19_04() AS $$
DECLARE    
BEGIN
    RAISE INFO 'FOR i IN 1..5 LOOP開始';
    FOR i IN 1..5 LOOP
        RAISE INFO '% ', i;
    END LOOP;

    RAISE INFO 'FOR i IN REVERSE 5..1 LOOP 開始';
    FOR i IN REVERSE 5..1 LOOP
        RAISE INFO '% ', i;
    END LOOP;

    RAISE INFO 'FOR i IN REVERSE 5..1 BY 2 LOOP 開始';
    FOR i IN REVERSE 5..1 BY 2 LOOP
        RAISE INFO '% ', i;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_plpgsql.sample14_02(INTEGER) 
RETURNS TABLE (
    empno char(5),
    empname varchar(40),
    poscode char(1),
    age    numeric(3,0)
) AS $$
DECLARE    
    myrow test_plpgsql.emp%ROWTYPE;
BEGIN
    FOR myrow IN SELECT * FROM test_plpgsql.emp ORDER BY empno LIMIT $1 LOOP
        empno := myrow.empno;
        empname := myrow.empname;
        poscode := myrow.poscode;
        age := myrow.age;
        RETURN NEXT; -- SELECTの現在の行を返します
    END LOOP;
    RETURN;
END;    
$$ LANGUAGE plpgsql;    

CREATE OR REPLACE PROCEDURE test_plpgsql.sample19_05() AS $$
DECLARE
    arr1 INTEGER[];
    target INTEGER;
BEGIN    
    -- 配列の初期化
    arr1 := array[123, 456, 789];
    FOREACH target IN ARRAY arr1 LOOP
        RAISE INFO '%', target;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * 例外処理についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample20_01(NUMERIC) AS $$
DECLARE    
    myrow test_plpgsql.dept%ROWTYPE;
BEGIN    

    INSERT INTO test_plpgsql.dept VALUES ('3','マーケティング部');
    SELECT * INTO myrow FROM test_plpgsql.dept WHERE deptno = '3';
    RAISE INFO '[自動ロールバック前のデータ確認]%', myrow;
    CASE $1
        WHEN 1 THEN
            -- 一意制約違反を発生させる
            INSERT INTO test_plpgsql.dept VALUES ('0','営業部');
        WHEN 2 THEN
            -- RAISEを用いて意図的に例外を発生させる
            RAISE EXCEPTION NO_DATA_FOUND;
    END CASE;
    
EXCEPTION
    WHEN SQLSTATE '23505' THEN -- unique_violationでも可
        SELECT * INTO myrow FROM test_plpgsql.dept WHERE deptno = '3';
        RAISE INFO '[自動ロールバック後のデータ確認]%', myrow;
        RAISE EXCEPTION 'unique_violation';
    WHEN NO_DATA_FOUND THEN
        SELECT * INTO myrow FROM test_plpgsql.dept WHERE deptno = '3';
        RAISE INFO '[自動ロールバック後のデータ確認]%', myrow;
        RAISE EXCEPTION 'employee not found';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'others';

END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * エラーに関する情報の取得についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample20_02() AS $$
DECLARE    
    text_var1 TEXT;
    text_var2 TEXT;
    text_var3 TEXT;
    text_var4 TEXT;
    text_var5 TEXT;
    text_var6 TEXT;
    text_var7 TEXT;
    text_var8 TEXT;
    text_var9 TEXT;
    text_var10 TEXT;
BEGIN    
    -- 一意制約違反を発生させる
    INSERT INTO test_plpgsql.dept VALUES ('3','マーケティング部');
    INSERT INTO test_plpgsql.dept VALUES ('3','マーケティング部');
EXCEPTION
    WHEN OTHERS THEN 
          GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                       text_var2 = COLUMN_NAME,
                       text_var3 = CONSTRAINT_NAME,
                       text_var4 = PG_DATATYPE_NAME,
                       text_var5 = MESSAGE_TEXT,
                       text_var6 = TABLE_NAME,
                       text_var7 = SCHEMA_NAME,
                       text_var8 = PG_EXCEPTION_DETAIL,
                       text_var9 = PG_EXCEPTION_HINT,
                    text_var10 = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'RETURNED_SQLSTATE:%',text_var1;
        RAISE INFO 'COLUMN_NAME:%',text_var2;
        RAISE INFO 'CONSTRAINT_NAME:%',text_var3;
        RAISE INFO 'PG_DATATYPE_NAME:%',text_var4;
        RAISE INFO 'MESSAGE_TEXT:%',text_var5;
        RAISE INFO 'TABLE_NAME:%',text_var6;
        RAISE INFO 'SCHEMA_NAME:%',text_var7;
        RAISE INFO 'PG_EXCEPTION_DETAIL:%',text_var8;
        RAISE INFO 'PG_EXCEPTION_HINT:%',text_var9;
        RAISE INFO 'PG_EXCEPTION_CONTEXT:%',text_var10;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * 6.エラーとメッセージ
 * *******************************************/
/* *******************************************
 * カーソルの基本的な使い方についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_01() AS $$
DECLARE    
    curs1 refcursor;
    record1 RECORD;
BEGIN    
    OPEN curs1 FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;

    LOOP 
        FETCH curs1 INTO record1;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;

    CLOSE curs1;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * カーソル変数の宣言についてのサンプルコード(refcursor)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_02(maxLength INTEGER, startPosition INTEGER) AS $$
DECLARE    
    curs1 refcursor;
    curs2 refcursor;
    record1 RECORD;
    record2 RECORD;
BEGIN    
    -- OPEN 変数名 FOR SQL文の形式でカーソルオープン
    OPEN curs1 FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;

    LOOP 
        -- カーソルから次の行を取得し、RECORD型変数に格納
        FETCH curs1 INTO record1;
        IF NOT FOUND THEN
            -- カーソル内のレコードを全て取得した場合はループを終了
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;
    -- カーソルクローズ
    CLOSE curs1;

    -- OPEN 変数名 FOR EXECUTE SQL文の形式でカーソルオープン
    OPEN curs2 FOR EXECUTE 'SELECT * FROM test_plpgsql.emp ORDER BY empno LIMIT $1 OFFSET $2;' USING maxLength, startPosition;

    LOOP 
        -- カーソルから次の行を取得し、RECORD型変数に格納
        FETCH curs2 INTO record2;
        IF NOT FOUND THEN
            -- カーソル内のレコードを全て取得した場合はループを終了
            EXIT;
        END IF;
        RAISE INFO 'empno:% empname:% poscode:% age:%', record2.empno, record2.empname, record2.poscode, record2.age;
    END LOOP;
    -- カーソルクローズ
    CLOSE curs2;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * カーソル変数の宣言についてのサンプルコード(CURSOR FOR SQL文)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_03(INTEGER, INTEGER, CHAR) AS $$
DECLARE    
    -- カーソル宣言（引数無し）
    curs1 CURSOR FOR 
        SELECT * FROM test_plpgsql.emp ORDER BY empno LIMIT 3 OFFSET 1;

    -- カーソル宣言（引数有り）
    curs2 CURSOR (maxLength INTEGER, startPosition INTEGER) FOR 
        SELECT * FROM test_plpgsql.emp ORDER BY empno LIMIT maxLength OFFSET startPosition;

    -- カーソル宣言（引数有り）
    curs3 CURSOR (target char(5)) FOR 
        SELECT deptname FROM test_plpgsql.dept WHERE deptno = target;

    record1 RECORD;
    record2 RECORD;
    deptName VARCHAR(40);
BEGIN    
    -- カーソルオープン（引数無し）
    OPEN curs1;
    RAISE INFO '--curs1 OPEN!------------------------------';
    LOOP 
        -- カーソルから次の行を取得し、RECORD型変数に格納
        FETCH curs1 INTO record1;
        IF NOT FOUND THEN
            -- カーソル内のレコードを全て取得した場合はループを終了
            EXIT;
        END IF;
        RAISE INFO 'empno:% empname:% poscode:% age:%', record1.empno, record1.empname, record1.poscode, record1.age;
    END LOOP;

    -- カーソルクローズ
    CLOSE curs1;
    RAISE INFO '--curs1 CLOSE!------------------------------';

    RAISE INFO '--curs2 OPEN!------------------------------';
    -- カーソルオープン（引数有り）
    OPEN curs2($1, $2);
    LOOP 
        -- カーソルから次の行を取得し、RECORD型変数に格納
        FETCH curs2 INTO record2;
        IF NOT FOUND THEN
            -- カーソル内のレコードを全て取得した場合はループを終了
            EXIT;
        END IF;
        RAISE INFO 'empno:% empname:% poscode:% age:%', record2.empno, record2.empname, record2.poscode, record2.age;
    END LOOP;

    -- カーソルクローズ
    CLOSE curs2;
    RAISE INFO '--curs2 CLOSE!------------------------------';

    RAISE INFO '--curs3 OPEN!------------------------------';
    -- カーソルオープン（引数有り）
    OPEN curs3(target := $3);
    LOOP 
        -- カーソルから次の行を取得し、RECORD型変数に格納
        FETCH curs3 INTO deptName;
        IF NOT FOUND THEN
            -- カーソル内のレコードを全て取得した場合はループを終了
            EXIT;
        END IF;
        RAISE INFO 'deptName:%', deptName;
    END LOOP;

    -- カーソルクローズ
    CLOSE curs3;
    RAISE INFO '--curs3 CLOSE!------------------------------';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * カーソルの利用についてのサンプルコード(SCROLL／MOVE)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_04() AS $$
DECLARE    
    curs1 refcursor;
    curs2 SCROLL CURSOR FOR 
        SELECT * FROM test_plpgsql.dept ORDER BY deptno;
    record1 RECORD;
    record2 RECORD;

BEGIN

    OPEN curs1 SCROLL FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;
    MOVE FORWARD 2 FROM curs1;
    LOOP 
        FETCH IN curs1 INTO record1;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;
    CLOSE curs1;

    OPEN curs2;
    MOVE FORWARD 2 FROM curs2;
    LOOP 
        FETCH PRIOR IN curs2 INTO record2;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record2.deptno, record2.deptname;
    END LOOP;
    CLOSE curs2;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * カーソルの利用についてのサンプルコード(FETCH)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_04_01() AS $$
DECLARE    
    curs1 refcursor;
    record1 RECORD;
BEGIN    
    OPEN curs1 NO SCROLL FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;
    MOVE FORWARD 2 FROM curs1;
    LOOP 
        -- NO SCROLLの場合に1つ前の行を取り出そうとするとエラーとなる
        -- SQLSTATE:55000 SQLERRM:cursor can only scan forward
        FETCH PRIOR IN curs1 INTO record1;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;
    CLOSE curs1;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * カーソルの利用についてのサンプルコード(UPDATE / DELETE WHERE CURRENT OF)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_04_02(beforAge INTEGER, afterAge INTEGER, maxLength INTEGER, startPosition INTEGER) AS $$
DECLARE 
    curs1 CURSOR (p_age INTEGER, maxLength INTEGER, startPosition INTEGER) FOR 
        SELECT * FROM test_plpgsql.emp WHERE age = p_age ORDER BY empno LIMIT maxLength OFFSET startPosition;
    record1 RECORD;
BEGIN   
    OPEN curs1(beforAge, maxLength, startPosition);
    LOOP 
        -- カーソルの位置を変更
        MOVE curs1;
        IF NOT FOUND THEN
            -- 全て移動した場合はループを終了
            EXIT;
        END IF;
        -- 引数で指定した年齢の社員かつ、引数で指定した件数分のみUPDATEが実行される
        UPDATE test_plpgsql.emp SET age = afterAge WHERE CURRENT OF curs1;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql; 

/* *******************************************
 * カーソルクローズについてのサンプルコード(CLOSE カーソル名で明示的にクローズする場合)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_05() AS $$
DECLARE    
    curs1 refcursor;
    record1 RECORD;
BEGIN    

    RAISE INFO '--curs1 OPEN!------------------------------';
    OPEN curs1 FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;

    LOOP 
        FETCH curs1 INTO record1;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;
    /* 【NG例】
     * CLOSE前にOPENした場合、以下のエラーが発生する
     * OPEN curs1 FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;
     * [出力結果]: SQLSTATE:42P03 SQLERRM:cursor "<unnamed portal 65>" already in use
     */

    CLOSE curs1;
    /* 【NG例】
     * OPENしていない状態でCLOSEした場合、以下のエラーが発生する
     * CLOSE curs1;
     * [出力結果]: SQLSTATE:34000 SQLERRM:cursor "<unnamed portal 66>" does not exist
     */
    RAISE INFO '--curs1 CLOSE!------------------------------';

    RAISE INFO '--curs1 再OPEN!------------------------------';
    OPEN curs1 FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;

    LOOP 
        FETCH curs1 INTO record1;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;

    CLOSE curs1;
    RAISE INFO '--curs1 再CLOSE!------------------------------';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * カーソルクローズについてのサンプルコード(例外が発生し、カーソルが暗黙的にクローズする場合)
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_06() AS $$
DECLARE    
    curs1 refcursor;
    record1 RECORD;
BEGIN    

    OPEN curs1 FOR SELECT * FROM test_plpgsql.dept ORDER BY deptno;

    LOOP 
        FETCH curs1 INTO record1;
        IF NOT FOUND THEN
            EXIT;
        END IF;
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;

    -- EXCEPTIONに飛ばす
    RAISE EXCEPTION NO_DATA_FOUND;

EXCEPTION
    WHEN OTHERS THEN
        -- EXCEPTIONに到達した時点でカーソルが自動クローズされるため、エラーとなる
        CLOSE curs1;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * カーソル結果に対するループについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample21_07(char(5)) AS $$
DECLARE    
    curs1 CURSOR FOR 
        SELECT * FROM test_plpgsql.dept;
    curs2 CURSOR (target char(5)) FOR 
        SELECT * FROM test_plpgsql.dept WHERE deptno = target;
    record1 test_plpgsql.dept%ROWTYPE;
    record2 test_plpgsql.dept%ROWTYPE;
BEGIN    

    RAISE INFO '--curs1 OPEN!------------------------------';
    FOR record1 IN curs1 LOOP
        RAISE INFO 'deptno:% deptname:%', record1.deptno, record1.deptname;
    END LOOP;
    RAISE INFO '--curs1 CLOSE!------------------------------';
    RAISE INFO '--curs2 OPEN!------------------------------';
    FOR record2 IN curs2($1) LOOP
        RAISE INFO 'deptno:% deptname:%', record2.deptno, record2.deptname;
    END LOOP;
    RAISE INFO '--curs2 CLOSE!------------------------------';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;

/* *******************************************
 * 7.エラーとメッセージ
 * *******************************************/
/* *******************************************
 * RAISEについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample22_01() AS $$
DECLARE    
BEGIN    

    RAISE DEBUG 'メッセージレベル：DEBUG';
    RAISE LOG 'メッセージレベル：LOG';
    RAISE INFO 'メッセージレベル：INFO';
    RAISE NOTICE 'メッセージレベル：NOTICE';
    RAISE WARNING 'メッセージレベル：WARNING';
    RAISE EXCEPTION 'メッセージレベル：EXCEPTION';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SQLSTATE:% SQLERRM:%', SQLSTATE, SQLERRM;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * RAISEで設定する文字列についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample22_02() AS $$
DECLARE    
    target NUMERIC;
BEGIN    
    -- 1から10までの値がランダムに生成される
    SELECT ROUND(( RANDOM() * (1 - 10) )::NUMERIC, 0) + 10 INTO target;
    RAISE INFO '出力値：%', target;

END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * RAISEで設定する例外名 / SQLSTATEについてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample22_03() AS $$
DECLARE    
BEGIN    
 
    RAISE INFO NO_DATA_FOUND;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE INFO 'NO_DATA_FOUNDです';
    WHEN OTHERS THEN
        RAISE INFO 'それ以外のエラーです';
END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * RAISEで設定する詳細情報についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample22_04(INTEGER) AS $$
DECLARE    
    myrow record;
BEGIN    
 
    CASE $1
        WHEN 1 THEN
            -- 一意制約違反を発生させる
            INSERT INTO test_plpgsql.dept VALUES ('0','営業部');
        WHEN 2 THEN
            -- NO_DATA_FOUNDを発生させる
            SELECT * INTO STRICT myrow FROM test_plpgsql.emp WHERE empno = '0';
    END CASE;

EXCEPTION
    WHEN UNIQUE_VIOLATION THEN
        RAISE EXCEPTION SQLSTATE '99999' USING MESSAGE='SQLATATE:' || SQLSTATE || ', SQLERRM:' || sqlerrm,
            HINT='[HINT]ヒントメッセージを出力します' , 
            DETAIL='[DETAIL]エラー詳細メッセージを出力します';
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'SQLATATE:%, SQLERRM:%', SQLSTATE, SQLERRM USING HINT='[HINT]ヒントメッセージを出力します' , 
            DETAIL='[DETAIL]エラー詳細メッセージを出力します',
            ERRCODE='99999';
    WHEN OTHERS THEN
        RAISE EXCEPTION SQLSTATE '99999' USING MESSAGE='SQLATATE:' || SQLSTATE || ', SQLERRM:' || SQLERRM;
END;    
$$ LANGUAGE plpgsql;    

/* *******************************************
 * RAISEで設定する詳細情報についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample22_05_01() AS $$
DECLARE    
    myrow record;
BEGIN    
 
    -- 一意制約違反を発生させる
    INSERT INTO test_plpgsql.dept VALUES ('0','営業部');

EXCEPTION
    WHEN UNIQUE_VIOLATION THEN
        RAISE EXCEPTION SQLSTATE '99999' USING MESSAGE='SQLATATE:' || SQLSTATE || ', SQLERRM:' || sqlerrm,
            HINT='[HINT]ヒントメッセージを出力します' , 
            DETAIL='[DETAIL]エラー詳細メッセージを出力します',
            COLUMN='deptno',
            CONSTRAINT='dept_pkey',
            DATATYPE='char(5)',
            TABLE='dept',
            SCHEMA='test_plpgsql';
END;    
$$ LANGUAGE plpgsql;    

CREATE OR REPLACE PROCEDURE test_plpgsql.sample22_05() AS $$
DECLARE    
    text_var1 TEXT;
    text_var2 TEXT;
    text_var3 TEXT;
    text_var4 TEXT;
    text_var5 TEXT;
    text_var6 TEXT;
    text_var7 TEXT;
    text_var8 TEXT;
    text_var9 TEXT;
    text_var10 TEXT;
BEGIN    

    CALL test_plpgsql.sample22_05_01();

EXCEPTION
    WHEN OTHERS THEN 
          GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                       text_var2 = COLUMN_NAME,
                       text_var3 = CONSTRAINT_NAME,
                       text_var4 = PG_DATATYPE_NAME,
                       text_var5 = MESSAGE_TEXT,
                       text_var6 = TABLE_NAME,
                       text_var7 = SCHEMA_NAME,
                       text_var8 = PG_EXCEPTION_DETAIL,
                       text_var9 = PG_EXCEPTION_HINT,
                       text_var10 = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'RETURNED_SQLSTATE:%',text_var1;
        RAISE INFO 'COLUMN_NAME:%',text_var2;
        RAISE INFO 'CONSTRAINT_NAME:%',text_var3;
        RAISE INFO 'PG_DATATYPE_NAME:%',text_var4;
        RAISE INFO 'MESSAGE_TEXT:%',text_var5;
        RAISE INFO 'TABLE_NAME:%',text_var6;
        RAISE INFO 'SCHEMA_NAME:%',text_var7;
        RAISE INFO 'PG_EXCEPTION_DETAIL:%',text_var8;
        RAISE INFO 'PG_EXCEPTION_HINT:%',text_var9;
        RAISE INFO 'PG_EXCEPTION_CONTEXT:%',text_var10;
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * 8.トランザクション制御
 * *******************************************/
/* *******************************************
 * トランザクション制御についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample23_01() AS $$
DECLARE    
BEGIN    
    FOR i IN 0..9 LOOP
        INSERT INTO test_plpgsql.test (col1, col2) VALUES (i, i);
        IF i % 2 = 0 THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    END LOOP;
END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * トランザクション制御についてのサンプルコード
 * *******************************************/
CREATE OR REPLACE PROCEDURE test_plpgsql.sample23_02() AS $$
DECLARE    
BEGIN    
    INSERT INTO test_plpgsql.test (col1, col2) VALUES (1, '1');
    BEGIN
        INSERT INTO test_plpgsql.test (col1, col2) VALUES (2, '2');
        -- 一意制約違反発生
        INSERT INTO test_plpgsql.test (col1, col2) VALUES (2, '2');
    EXCEPTION
        WHEN OTHERS THEN 
            RAISE INFO 'SQLATATE:%, SQLERRM:%', SQLSTATE, SQLERRM;
            RAISE INFO '自動ロールバック発生！！';
    END;
    INSERT INTO test_plpgsql.test (col1, col2) VALUES (3, '3');
    COMMIT;
    INSERT INTO test_plpgsql.test (col1, col2) VALUES (4, '4');
    ROLLBACK;
    INSERT INTO test_plpgsql.test (col1, col2) VALUES (5, '5');
END;    
$$ LANGUAGE plpgsql;
/* *******************************************
 * トランザクション制御についてのサンプルコード(NG例：FUNCTION内でCOMMIT/ROLLBACKが出来ない)
 * *******************************************/
CREATE OR REPLACE FUNCTION test_plpgsql.sample23_03() RETURNS VOID AS $$
DECLARE    
BEGIN    
    FOR i IN 0..9 LOOP
        INSERT INTO test_plpgsql.test (col1, col2) VALUES (i, i);
        IF i % 2 = 0 THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    END LOOP;
    RETURN;
END;    
$$ LANGUAGE plpgsql;    
/* *******************************************
 * 無名ブロックについてのサンプルコード
 * *******************************************/
DO $$
DECLARE
    dataType test_plpgsql.DATA_TYPE1;
BEGIN
    dataType.param1 := 9;
    dataType.param2 := '無名ブロックを経由して、ユーザー定義型を引数に持つプロシージャを呼び出し';
    dataType.param3 := convert_to('無名ブロックを経由して、ユーザー定義型を引数に持つプロシージャを呼び出し', 'UTF-8');
    CALL test_plpgsql.sample24_01(dataType);
END
$$ LANGUAGE plpgsql; 

CREATE OR REPLACE PROCEDURE test_plpgsql.sample24_01(p_dataType test_plpgsql.DATA_TYPE1 ) AS $$
DECLARE
BEGIN
    RAISE INFO 'DATA_TYPE1.param1:%', p_dataType.param1;
    RAISE INFO 'DATA_TYPE1.param2:%', p_dataType.param2;
    RAISE INFO 'DATA_TYPE1.param3:%', p_dataType.param3;
END;
$$ LANGUAGE plpgsql;
