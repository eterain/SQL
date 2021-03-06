CREATE OR REPLACE PROCEDURE SP_...
/***************************************************************************************
객 체 명 : SP_...
내    용 : ...
작 성 일 : 2019.07.31.
작 성 자 : 박용주
수정내역   
 1.수정일: 2019.07.31.
   수정자: 박용주
   내  용: ...
참조객체 : 
Return값 : 
참고사항 : 
****************************************************************************************/
(
    IN_STUNO        IN  ENRO200.STUNO%TYPE,  
    OUT_RTN         OUT NUMBER,
    OUT_MSG         OUT VARCHAR2
)
IS
    V_STUNO         ENRO200.STUNO%TYPE;
    V_YN            CHAR(1);    
    
BEGIN
    -- ...
    BEGIN
        SELECT A.PROG_FG, A.BUSS_FG, ...
          INTO V_PROG_FG, V_BUSS_FG, ...
          FROM ENRO200 A
         WHERE A.STUNO = IN_STUNO;
        
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            OUT_RTN := 0;
            OUT_MSG := IN_STUNO||' 정보가 없습니다.';
        WHEN OTHERS THEN
            OUT_RTN := 0;
            OUT_MSG := IN_STUNO||' 오류가 발생했습니다.('||SQLCODE||')';
    END;
    
    IF OUT_RTN = 0 THEN
        --OUT_MSG := OUT_MSG||CHR(13)||CHR(10)||CHR(13)||CHR(10)||'\n확인 후 재시도 하세요';
        OUT_MSG := OUT_MSG||'\n확인 후 재시도 하세요';
--        DBMS_OUTPUT.PUT_LINE(OUT_MSG);
        RETURN;
    END IF;

    OUT_RTN := 1;
    OUT_MSG := '정상적으로 처리되었습니다.';
    
    RETURN;
    
END; 
