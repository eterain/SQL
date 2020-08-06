
SELECT select_yy, select_fg, coll_fg, aply_qual_fg, deta_aply_qual_fg, aply_cors_fg, aply_colg_fg  
FROM ESIN600 WHERE EXAM_NO = '901063' ;

SELECT * FROM esin600 ;

SELECT SF_BSNS011_CODENM(A.APLY_COLG_FG) AS UNIV_NM,
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
               ELSE 0 END)) AS APLY_CNT11, 
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
               ELSE 0 END)) AS APLY_CNT12, 
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG != '51480000' THEN 1 
               ELSE 0 END)) AS APLY_CNT13,             
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
               ELSE 0 END +
               CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
               ELSE 0 END +
               CASE WHEN CHULSIN_SCH_FG != '51480000' THEN 1 
               ELSE 0 END)) AS APLY_TOT,             
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
               ELSE 0 END)) AS PASS_CNT11, 
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
               ELSE 0 END)) AS PASS_CNT12, 
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG != '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' THEN 1 
               ELSE 0 END)) AS PASS_CNT13, 
       TO_CHAR(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
               ELSE 0 END +
               CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
               ELSE 0 END +
               CASE WHEN CHULSIN_SCH_FG != '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' THEN 1 
               ELSE 0 END)) AS PASS_TOT,

       TO_CHAR(ROUND(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END) / 
                SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG != '51480000' THEN 1 
                     ELSE 0 END) * 100, 1)) || '%' AS APLY_PCNT11, 
       TO_CHAR(ROUND(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END) /
                SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG != '51480000' THEN 1 
                     ELSE 0 END) * 100, 1)) || '%' AS APLY_PCNT12,              
       TO_CHAR(ROUND(SUM( CASE WHEN CHULSIN_SCH_FG != '51480000' THEN 1 
                     ELSE 0 END) /
                SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG = '51480000' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG != '51480000' THEN 1 
                     ELSE 0 END) * 100, 1)) || '%' AS APLY_PCNT13,                   
       '100.0%' AS APLY_PTOT,                    
       TO_CHAR(ROUND(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END) /
                SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG != '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' THEN 1 
                     ELSE 0 END) * 100, 1)) || '%' AS PASS_PCNT11, 
       TO_CHAR(ROUND(SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END) /
                SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG != '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' THEN 1 
                     ELSE 0 END) * 100, 1)) || '%' AS PASS_PCNT12, 
       TO_CHAR(ROUND(SUM( CASE WHEN CHULSIN_SCH_FG != '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' THEN 1 
                        ELSE 0 END) /
                SUM( CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM = CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG = '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' AND D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN 1 
                     ELSE 0 END +
                     CASE WHEN CHULSIN_SCH_FG != '51480000' AND NVL(C.PASS_DISQ_FG,'-') = 'U024300005' THEN 1 
                     ELSE 0 END) * 100, 1)) || '%' AS PASS_PCNT13,             
       '100.0%'  AS PASS_PTOT                 
FROM ESIN600 A,  
     ( SELECT COLL_UNIT_NO,
              EXAM_NO,                     
              CHULSIN_SCH_FG,
              SUBSTR(LTRIM(RTRIM(REPLACE(SF_BSNS011_CODENM(CHULSIN_SUST_FG),' ',''))),1,2) AS CHULSIN_SUST_NM              
       FROM ESIN602 
       WHERE NVL(FL_SCHCR_YN,'N') = 'Y' ) B,
     ( SELECT COLL_UNIT_NO, EXAM_NO, PASS_DISQ_FG  FROM ESIN606
       WHERE SCRN_STG_FG IN ('U027200002', 'U027200003')
       UNION 
       SELECT COLL_UNIT_NO, EXAM_NO, PASS_DISQ_FG  FROM ESIN606
       WHERE SCRN_STG_FG = 'U027200001'
       AND PASS_DISQ_FG = 'U024300005' ) C,
     ( SELECT DEPT_CD, SUBSTR(LTRIM(RTRIM(REPLACE((DEPT_KOR_NM ),' ',''))),1,2) AS DEPT_KOR_NM 
       FROM V_COMM111_6 
       WHERE NVL(USE_YN, 'N') = 'Y' ) D,  
     ESIN520 Z        
WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
AND A.EXAM_NO = B.EXAM_NO     
AND A.COLL_UNIT_NO = C.COLL_UNIT_NO (+)
AND A.EXAM_NO = C.EXAM_NO (+)   
AND A.APLY_COLL_UNIT_CD = D.DEPT_CD
AND A.COLL_UNIT_NO = Z.COLL_UNIT_NO
AND A.SELECT_YY = Z.SELECT_YY
AND A.SELECT_FG = Z.SELECT_FG
AND A.COLL_FG = Z.COLL_FG
AND A.APLY_QUAL_FG = Z.APLY_QUAL_FG
AND A.DETA_APLY_QUAL_FG = Z.DETA_APLY_QUAL_FG
AND A.APLY_CORS_FG = Z.APLY_CORS_FG
AND A.APLY_COLG_FG = Z.APLY_COLG_FG
AND A.APLY_COLL_UNIT_CD = Z.APLY_COLL_UNIT_CD
/*
<isNotEmpty property="selectYy">
    AND A.SELECT_YY = #selectYy#
</isNotEmpty>
<isNotEmpty property="selectFg">
    AND A.SELECT_FG = #selectFg#
</isNotEmpty>
<isNotEmpty property="collFg">
    AND A.COLL_FG = #collFg#
</isNotEmpty>
<isNotEmpty property="aplyQualFg">
    AND A.APLY_QUAL_FG = #aplyQualFg#
</isNotEmpty>
<isNotEmpty property="detaAplyQualFg">
    AND A.DETA_APLY_QUAL_FG = #detaAplyQualFg#
</isNotEmpty>
<isNotEmpty property="aplyCorsFg">
    AND A.APLY_CORS_FG = #aplyCorsFg#
</isNotEmpty>
<isNotEmpty property="aplyColgFg">
    AND A.APLY_COLG_FG = #aplyColgFg#
</isNotEmpty>
<isNotEmpty property="wcuYn">
    AND NVL(Z.WCU_YN,'N') = #wcuYn#  
</isNotEmpty>
*/
GROUP BY A.APLY_COLG_FG
;

