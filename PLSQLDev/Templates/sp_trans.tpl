CREATE OR REPLACE PROCEDURE SP_TRANS_DORM
(
     IN_ID                  IN SSTM057.INPT_ID%TYPE                 /* ID */
)
IS
/***************************************************************************************
�� ü �� : SP_TRANS_DORM
��    �� : ����� �����͸� �->���� DB �� ��ü �̰�
������ü : 
Return�� : 
 ------------------------------------------------------------------------------
     ��������     ������    ��������
 ------------------------------------------------------------------------------
     2016.06.09  �輳��    ���� �ۼ�  (�� 4�� �ҿ�)
 
****************************************************************************************/

    V_TNAME       VARCHAR2(30) := 'DORM%';
--    V_COLUMN_NAME_SCHYY       VARCHAR2(30) := 'OPEN_SCHYY'; -- �����г⵵
--    V_COLUMN_NAME_SHTM_FG       VARCHAR2(30) := 'OPEN_SHTM_FG';  --�����б�
    V_TABLE_NAME  VARCHAR2(30);
    V_COL_EXIST   NUMBER := 0;
    V_SQL_DEL     VARCHAR2(2000) ; -- ���� SQL ��
    V_SQL_INS     VARCHAR2(2000) ; -- ���� SQL ��
    V_SID         VARCHAR2(30) ;
--    V_CUR_SCHYY         VARCHAR2(30);
--    V_CUR_SHTM_FG        VARCHAR2(30);
--    V_PREV_SCHYY         VARCHAR2(30) ;
--    V_PREV_SHTM_FG        VARCHAR2(30) ;
BEGIN

    IF TRIM(IN_ID) IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('ERROR : �������� ȣ�� �� �μ��� ���ι�ȣ�� �Է��� �ּ���.');
        RETURN;
    END IF;

    DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'yyyymmdd hh24:mi'));
    
    select sys_context('userenv','instance_name') into V_SID from dual;
    DBMS_OUTPUT.PUT_LINE(V_SID);    
    /* ���� db������ ���� */
    IF (V_SID = 'SNUDEV02') THEN

        /* ���̺�� '_'�� �ִ� ���̺��� ���ܵ� */
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

    /* DB�̰�ó���̷� */
    INSERT INTO SSTM057 (
           DB_TRANS_TRET_SEQ            /* DB�̰�ó������ */
          ,DB_PGM_ID                    /* DB���α׷�ID */
          ,TRET_DT                      /* ó������ */
          ,INPT_ID                      /* �Է�ID */
          ,INPT_DTTM                    /* �Է��Ͻ� */
    ) VALUES (
           SSTM057_SEQ.NEXTVAL          /* DB�̰�ó������ */
          ,'SP_TRANS_DORM'              /* DB���α׷�ID */
          ,TO_CHAR(SYSDATE, 'YYYYMMDD') /* ó������ */
          ,IN_ID                        /* �Է�ID */
          ,SYSDATE                      /* �Է��Ͻ� */
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'yyyymmdd hh24:mi'));
 
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OTHER EXCEPTION OCCURED!');  
        DBMS_OUTPUT.PUT_LINE('ERROR ���̺�='||V_TABLE_NAME||':'||SQLERRM) ;

END;
