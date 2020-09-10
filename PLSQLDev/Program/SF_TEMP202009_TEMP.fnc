CREATE OR REPLACE FUNCTION SF_TEMP202009_TEMP
(
      str_stuno  VARCHAR2     
)

RETURN VARCHAR2
AS
RTN VARCHAR2(14) := '' ;  
strStuno VARCHAR2(12) ;

BEGIN
    strStuno := TRIM(str_stuno) ;    
	IF strStuno IS NULL THEN    
       RTN := '-' ;    
    ELSE    
            SELECT MIN(SCHYY || SHTM_FG)
              INTO RTN
              FROM (SELECT SCHYY, SHTM_FG, AF_SCHREG_MOD_FG,
                           SUM(DECODE(AF_SCHREG_MOD_FG, 'U030300017', 0, 'U030300018', 0, 1)) OVER(PARTITION BY STUNO ORDER BY SCHYY DESC, SHTM_FG DESC) AS RANK
                      FROM (SELECT SCHYY, SHTM_FG, STUNO, SCHREG_MOD_FG,
                                   LEAD(SCHREG_MOD_FG) OVER(ORDER BY SCHYY, SHTM_FG) AS AF_SCHREG_MOD_FG
                              FROM ENRO200
                             WHERE GV_ST_FG = 'U060500002'
                               AND STUNO = strStuno
                               AND SCHYY || SHTM_FG < '2020' || 'U000200001'
                               AND DETA_SHTM_FG = 'U000300001'))
             WHERE RANK = '1' ;  
    END IF ;  
    RETURN RTN ;       
    
    EXCEPTION
        WHEN OTHERS THEN 
             RTN := '-' ;
             RETURN RTN ;       
END;
/
