CREATE OR REPLACE PROCEDURE SP_ESIN320_CREATE
/***************************************************************************************
�� ü �� : SP_ESIN320_CREATE
��    �� : �Խ���ô�����Ͽ� ��ô�ڷ� �����Ѵ�.
�� �� �� : 2019.11.29.
�� �� �� : �ڿ���
��������   
 1.������: 2019.11.29.
   ������: �ڿ���
   ��  ��: START
������ü : 
Return�� : 
������� : 
****************************************************************************************/
(
    IN_SCHYY        IN  VARCHAR2,  
    IN_SHTM_FG      IN  VARCHAR2,  
    IN_UNIV_CD      IN  VARCHAR2,  
    OUT_RTN         OUT NUMBER,
    OUT_MSG         OUT VARCHAR2
)
IS
    V_YN            CHAR(1);    
    
BEGIN
    BEGIN
        SELECT A.PROG_FG, A.BUSS_FG, ...
          INTO V_PROG_FG, V_BUSS_FG, ...
          FROM ENRO200 A
         WHERE A.STUNO = IN_STUNO;
        
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            OUT_RTN := 0;
            OUT_MSG := IN_STUNO||' ������ �����ϴ�.';
        WHEN OTHERS THEN
            OUT_RTN := 0;
            OUT_MSG := IN_STUNO||' ������ �߻��߽��ϴ�.('||SQLCODE||')';
    END;
    
    IF OUT_RTN = 0 THEN
        --OUT_MSG := OUT_MSG||CHR(13)||CHR(10)||CHR(13)||CHR(10)||'\nȮ�� �� ��õ� �ϼ���';
        OUT_MSG := OUT_MSG||'\nȮ�� �� ��õ� �ϼ���';
--        DBMS_OUTPUT.PUT_LINE(OUT_MSG);
        RETURN;
    END IF;

    OUT_RTN := 1;
    OUT_MSG := '���������� ó���Ǿ����ϴ�.';
    
    RETURN;
    
END; 
/
