CREATE OR REPLACE FUNCTION SF_YUN_TEMP
(
    IN_STUNO        IN            VARCHAR2,
    IN_SCHYY        IN            VARCHAR2,
    IN_TYPE         IN            VARCHAR2    
)
RETURN VARCHAR2

AS

V_RESULT        VARCHAR2(100);
V_RESULT1       VARCHAR2(100);
V_RESULT2       VARCHAR2(100);
V_REG1          VARCHAR2(100);
V_REG2          VARCHAR2(100);

BEGIN

    SELECT NVL(SF_BSNS011_CODENM(SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8),1),  
               CASE WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600001' THEN '재학(입학)'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600002' THEN '휴학'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600003' THEN '재학(복학)'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600004' THEN '제적'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600005' THEN '재학(복적)'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600006' THEN '재학(재입학)'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600007' THEN '졸업'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600008' THEN '수료'
                    WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600009' THEN '재학(규정학기초과)'
               ELSE '-' END ),
           CASE WHEN T4.SCHREG_MOD_FG IS NULL THEN CASE WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) IS NULL THEN CASE WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600001' THEN '재학(입학)'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600002' THEN '휴학'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600003' THEN '재학(복학)'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600004' THEN '제적'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600005' THEN '재학(복적)'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600006' THEN '재학(재입학)'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600007' THEN '졸업'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600008' THEN '수료'
                                                                                                                     WHEN SF_BSNS011_CODENM(T2.SCHREG_MOD_FG,8) = 'U032600009' THEN '재학(규정학기초과)'
                                                                                                                ELSE '-' END
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600001' THEN '재학(입학)'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600002' THEN '휴학'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600003' THEN '재학(복학)'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600004' THEN '제적'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600005' THEN '재학(복적)'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600006' THEN '재학(재입학)'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600007' THEN '졸업'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600008' THEN '수료'
                                                        WHEN SF_BSNS011_CODENM(T3.SCHREG_MOD_FG,8) = 'U032600009' THEN '재학(규정학기초과)'  
                                                   ELSE '-' END                                                             
                ELSE SF_BSNS011_CODENM(SF_BSNS011_CODENM((T4.SCHREG_MOD_FG),8),1) END,
         NVL((SELECT SF_BSNS011_CODENM(gv_st_fg,1) FROM enro200 
              WHERE SCHYY = IN_SCHYY AND shtm_fg = 'U000200001' AND stuno = IN_STUNO),'-'),
         NVL((SELECT SF_BSNS011_CODENM(gv_st_fg,1) FROM enro200 
              WHERE SCHYY = IN_SCHYY AND shtm_fg = 'U000200002' AND stuno = IN_STUNO),'-')
    INTO V_RESULT1, 
         V_RESULT2,                
         V_REG1,                
         V_REG2
    FROM YUN_TEMP_20200615_V1 T1,
    
    /* REG405 , SREG404 기준 */
    /* 
         (SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
            FROM YUN_TEMP_20200615_V1 T1,
                 ( SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
                   FROM SREG405 A, SREG404 B
                   WHERE A.STUNO = B.STUNO (+)
                   AND A.SCHYY = B.SCHYY (+)
                   AND A.SHTM_FG = B.SHTM_FG (+)
                   AND A.SCHREG_MOD_FG = B.SCHREG_MOD_FG (+)
                   AND B.SCHREG_ADPT_FG (+) ='U031000002'
                   AND B.CNCL_APLY_DT IS NULL
                   ORDER BY A.SCHREG_MOD_SEQ ASC ) A
            WHERE A.STUNO = T1.STUNO
            AND A.SCHYY = T1.SCHYY        
            AND A.STUNO = IN_STUNO
            AND A.SCHYY < IN_SCHYY           
            AND ROWNUM = 1   
            ORDER BY SCHREG_MOD_SEQ DESC) T2,
         (SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
            FROM YUN_TEMP_20200615_V1 T1,
                 ( SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
                   FROM SREG405 A, SREG404 B
                   WHERE A.STUNO = B.STUNO (+)
                   AND A.SCHYY = B.SCHYY (+)
                   AND A.SHTM_FG = B.SHTM_FG (+)
                   AND A.SCHREG_MOD_FG = B.SCHREG_MOD_FG (+)
                   AND B.SCHREG_ADPT_FG (+) ='U031000002'
                   AND B.CNCL_APLY_DT IS NULL
                   ORDER BY A.SCHREG_MOD_SEQ ASC ) A
            WHERE A.STUNO = T1.STUNO
            AND A.SCHYY = T1.SCHYY        
            AND A.STUNO = IN_STUNO
            AND A.SCHYY = IN_SCHYY        
            AND A.SHTM_FG = 'U000200001'
            AND ROWNUM = 1   
            ORDER BY SCHREG_MOD_SEQ DESC
            ) T3,
         (SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
            FROM YUN_TEMP_20200615_V1 T1,
                 ( SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
                   FROM SREG405 A, SREG404 B
                   WHERE A.STUNO = B.STUNO (+)
                   AND A.SCHYY = B.SCHYY (+)
                   AND A.SHTM_FG = B.SHTM_FG (+)
                   AND A.SCHREG_MOD_FG = B.SCHREG_MOD_FG (+)
                   AND B.SCHREG_ADPT_FG (+) ='U031000002'
                   AND B.CNCL_APLY_DT IS NULL
                   ORDER BY A.SCHREG_MOD_SEQ ASC ) A
            WHERE A.STUNO = T1.STUNO
            AND A.SCHYY = T1.SCHYY        
            AND A.STUNO = IN_STUNO
            AND A.SCHYY = IN_SCHYY   
            AND A.SHTM_FG = 'U000200002'
            AND ROWNUM = 1   
            ORDER BY SCHREG_MOD_SEQ DESC
            ) T4
    */
    
    /* REG405 기준 SREG404제외 */
     (SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.REG_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
      FROM ( SELECT STUNO, SCHYY, SHTM_FG, REG_FG, SCHREG_MOD_FG, SCHREG_MOD_SEQ FROM SREG405 ORDER BY SCHREG_MOD_SEQ DESC ) A
      WHERE A.SCHYY < IN_SCHYY       
      and A.STUNO = IN_STUNO
      AND ROWNUM = 1) T2,
     (SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.REG_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
      FROM ( SELECT STUNO, SCHYY, SHTM_FG, REG_FG, SCHREG_MOD_FG, SCHREG_MOD_SEQ FROM SREG405 ORDER BY SCHREG_MOD_SEQ DESC ) A
      WHERE A.SCHYY = IN_SCHYY       
      AND A.SHTM_FG = 'U000200001'
      and A.STUNO = IN_STUNO
      AND ROWNUM = 1 ) T3,
     (SELECT A.STUNO, A.SCHYY, A.SHTM_FG, A.REG_FG, A.SCHREG_MOD_FG, A.SCHREG_MOD_SEQ
      FROM ( SELECT STUNO, SCHYY, SHTM_FG, REG_FG, SCHREG_MOD_FG, SCHREG_MOD_SEQ FROM SREG405 ORDER BY SCHREG_MOD_SEQ DESC ) A
      WHERE A.SCHYY = IN_SCHYY       
      AND A.SHTM_FG = 'U000200002'
      and A.STUNO = IN_STUNO
      AND ROWNUM = 1 ) T4    
    
    WHERE T1.STUNO = T2.STUNO (+)
    AND T1.STUNO = T3.STUNO (+)
    AND T1.STUNO = T4.STUNO (+)
    AND T1.STUNO = IN_STUNO
    ; 

    IF IN_TYPE = '1' THEN
        V_RESULT := V_RESULT1;
    ELSIF IN_TYPE = '2' THEN
        V_RESULT := V_RESULT2;
    ELSIF IN_TYPE = 'REG1' THEN
        V_RESULT := V_REG1;
    ELSIF IN_TYPE = 'REG2' THEN
        V_RESULT := V_REG2;
    ELSE
        V_RESULT := '-';
    END IF;

    RETURN V_RESULT;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '-';
        WHEN OTHERS THEN
            RETURN '-';
            
END SF_YUN_TEMP;
/
