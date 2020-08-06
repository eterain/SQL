CREATE OR REPLACE FUNCTION SP_...
/***************************************************************************************
객 체 명 : SF_...
내    용 : 
작 성 일 : 2019.07.31.
작 성 자 : 박용주
수 정 일 :
수 정 자 :
수정내용 :
참조객체 : 
RETURN값 : 
****************************************************************************************/
(
    IN_STUNO    VARCHAR2 DEFAULT '2019-10031',
    IN_DT       VARCHAR2 DEFAULT TO_CHAR(SYSDATE,'YYYYMMDD') -- 지정일자(DEFAULT : SYSDATE)
)
RETURN VARCHAR2
IS
    V_RTN      VARCHAR2(4);   --RETURN값
 
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
