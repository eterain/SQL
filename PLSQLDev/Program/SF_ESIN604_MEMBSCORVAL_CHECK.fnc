CREATE OR REPLACE FUNCTION SF_ESIN604_MEMBSCORVAL_CHECK
(
      str_var  VARCHAR2     /* 심사위원 입력값 */
)

RETURN VARCHAR2
AS
/******************************************************************************
 파일명              : SF_ESIN604_MEMBSCORVAL_CHECK
 내용                : << 심사위원 평가입력 값의 CHECK >>
 INPUT               : 심사위원평가입력값
 OUTPUT              : RTN - 리턴 코드   1: True, 0: FALSE                       
 작성일자    작성자     내용
------------------------------------------------------------------------------
 2020.08.13  박용주     최초작성

******************************************************************************/

RTN VARCHAR2(1) := '1' ;  
RET NUMBER ;
strVar VARCHAR2(10) ;

BEGIN
    strVar := TRIM(str_var) ;    
	IF strVar IS NULL THEN    
       RTN := '0' ;    
    ELSE    
       SELECT REGEXP_INSTR(strVar,'^[+-]?\d*(\.?\d*)$')
         INTO RET
         FROM DUAL ;        
       IF  RET  =  0  THEN
           RTN := '0' ;
       ELSE
           RTN := '1' ;         
       END IF ;        
    END IF ;  
    RETURN RTN ;       
    
    EXCEPTION
        WHEN OTHERS THEN 
             RTN := '0' ;
             RETURN RTN ;       
END;
/
