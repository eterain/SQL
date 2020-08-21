CREATE OR REPLACE FUNCTION SF_ESIN604_MEMBSCORVAL_CHECK
(
      str_var  VARCHAR2     /* �ɻ����� �Է°� */
)

RETURN VARCHAR2
AS
/******************************************************************************
 ���ϸ�              : SF_ESIN604_MEMBSCORVAL_CHECK
 ����                : << �ɻ����� ���Է� ���� CHECK >>
 INPUT               : �ɻ��������Է°�
 OUTPUT              : RTN - ���� �ڵ�   1: True, 0: FALSE                       
 �ۼ�����    �ۼ���     ����
------------------------------------------------------------------------------
 2020.08.13  �ڿ���     �����ۼ�

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
