CREATE OR REPLACE PROCEDURE SP_TRANS_DORM
(
     IN_ID                  IN SSTM057.INPT_ID%TYPE                 /* ID */
)
IS
/***************************************************************************************
객 체 명 : SP_TRANS_DORM
내    용 : 기숙사 데이터를 운영->개발 DB 로 전체 이관
참조객체 : 
Return값 : 
 ------------------------------------------------------------------------------
     수정일자     수정자    수정내용
 ------------------------------------------------------------------------------
     2016.06.09  김설희    최초 작성  (약 4분 소요)
 
****************************************************************************************/

    V_TNAME       VARCHAR2(30) := 'DORM%';
--    V_COLUMN_NAME_SCHYY       VARCHAR2(30) := 'OPEN_SCHYY'; -- 개설학년도
--    V_COLUMN_NAME_SHTM_FG       VARCHAR2(30) := 'OPEN_SHTM_FG';  --개설학기
    V_TABLE_NAME  VARCHAR2(30);
    V_COL_EXIST   NUMBER := 0;
    V_SQL_DEL     VARCHAR2(2000) ; -- 동적 SQL 용
    V_SQL_INS     VARCHAR2(2000) ; -- 동적 SQL 용
    V_SID         VARCHAR2(30) ;
--    V_CUR_SCHYY         VARCHAR2(30);
--    V_CUR_SHTM_FG        VARCHAR2(30);
--    V_PREV_SCHYY         VARCHAR2(30) ;
--    V_PREV_SHTM_FG        VARCHAR2(30) ;
BEGIN

    IF TRIM(IN_ID) IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('ERROR : 프러시저 호출 시 인수에 개인번호를 입력해 주세요.');
        RETURN;
    END IF;

    DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'yyyymmdd hh24:mi'));
    
    select sys_context('userenv','instance_name') into V_SID from dual;
    DBMS_OUTPUT.PUT_LINE(V_SID);    
    /* 개발 db에서만 실행 */
    IF (V_SID = 'SNUDEV02') THEN

        /* 테이블명에 '_'가 있는 테이블은 제외됨 */
            FOR V IN (SELECT TABLE_NAME
                        FROM USER_TABLES
                       WHERE 1=1
                         AND TABLE_NAME LIKE V_TNAME
                         AND INSTR(TABLE_NAME,'_') = 0
                      UNION ALL
                      SELECT REPLACE(TABLE_NAME,'_DAMO','') AS TABLE_NAME
                        FROM USER_TABLES
                       WHERE 1=1
                         AND TABLE_NAME LIKE V_TNAME
                         AND TABLE_NAME LIKE '%_DAMO'
                      )
            LOOP
                BEGIN
                    V_TABLE_NAME := V.TABLE_NAME ;
                    SELECT COUNT(*) INTO V_COL_EXIST
                        FROM USER_TAB_COLS
                        WHERE  TABLE_NAME = V_TABLE_NAME;
                    
                    DBMS_OUTPUT.PUT_LINE('V_COL_EXIST = '||V_COL_EXIST) ;
                    
                    IF (V_COL_EXIST > 0)        
                        THEN
                            V_SQL_DEL := 'DELETE FROM '||V_TABLE_NAME ;
                            DBMS_OUTPUT.PUT_LINE('V_SQL_DEL1 = '||V_SQL_DEL) ;
                            EXECUTE IMMEDIATE V_SQL_DEL;
                            --V_SQL_DEL := 'DELETE FROM '||V_TABLE_NAME || ' WHERE '||V_COLUMN_NAME_SCHYY||' = ''' ||V_PREV_SCHYY||''' AND '||V_COLUMN_NAME_SHTM_FG||' = ''' ||V_PREV_SHTM_FG||'''';
                            --DBMS_OUTPUT.PUT_LINE('V_SQL_DEL2 = '||V_SQL_DEL) ;
                            --EXECUTE IMMEDIATE V_SQL_DEL;
                             V_SQL_INS := 'INSERT INTO '||V_TABLE_NAME||' SELECT * FROM '||V_TABLE_NAME||'@DBLINK_NUISDB1_SNU' ;
                            DBMS_OUTPUT.PUT_LINE('V_SQL_INS1 = '||V_SQL_INS) ;
                            EXECUTE IMMEDIATE V_SQL_INS;
                            --V_SQL_INS := 'INSERT INTO '||V_TABLE_NAME||' SELECT * FROM '||V_TABLE_NAME||'@DBLINK_NUISDB1_SNU' || ' WHERE '||V_COLUMN_NAME_SCHYY||' = ''' ||V_PREV_SCHYY||''' AND '||V_COLUMN_NAME_SHTM_FG||' = ''' ||V_PREV_SHTM_FG||'''';
                            --DBMS_OUTPUT.PUT_LINE('V_SQL_INS2 = '||V_SQL_INS) ;
                            --EXECUTE IMMEDIATE V_SQL_INS;
                            COMMIT;
                        END IF;
                    
                    DBMS_OUTPUT.PUT_LINE('OK = '||V_TABLE_NAME||':'||SQLERRM) ;
                END ;
            END LOOP ;
            
    END IF;

    /* DB이관처리이력 */
    INSERT INTO SSTM057 (
           DB_TRANS_TRET_SEQ            /* DB이관처리순번 */
          ,DB_PGM_ID                    /* DB프로그램ID */
          ,TRET_DT                      /* 처리일자 */
          ,INPT_ID                      /* 입력ID */
          ,INPT_DTTM                    /* 입력일시 */
    ) VALUES (
           SSTM057_SEQ.NEXTVAL          /* DB이관처리순번 */
          ,'SP_TRANS_DORM'              /* DB프로그램ID */
          ,TO_CHAR(SYSDATE, 'YYYYMMDD') /* 처리일자 */
          ,IN_ID                        /* 입력ID */
          ,SYSDATE                      /* 입력일시 */
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'yyyymmdd hh24:mi'));
 
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OTHER EXCEPTION OCCURED!');  
        DBMS_OUTPUT.PUT_LINE('ERROR 테이블='||V_TABLE_NAME||':'||SQLERRM) ;

END;
