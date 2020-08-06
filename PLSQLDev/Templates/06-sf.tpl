CREATE OR REPLACE FUNCTION SP_...
/***************************************************************************************
�� ü �� : SF_...
��    �� : 
�� �� �� : 2019.07.31.
�� �� �� : �ڿ���
�� �� �� :
�� �� �� :
�������� :
������ü : 
RETURN�� : 
****************************************************************************************/
(
    IN_STUNO    VARCHAR2 DEFAULT '2019-10031',
    IN_DT       VARCHAR2 DEFAULT TO_CHAR(SYSDATE,'YYYYMMDD') -- ��������(DEFAULT : SYSDATE)
)
RETURN VARCHAR2
IS
    V_RTN      VARCHAR2(4);   --RETURN��
 
BEGIN
    BEGIN
        SELECT STUNO
          INTO V_RTN
          FROM ENRO200
         WHERE STUNO = IN_STUNO
        ;
 
    EXCEPTION
        WHEN OTHERS THEN
            V_RTN := '';
            RETURN V_RTN;
    END;
 
    RETURN V_RTN;
    
END;
