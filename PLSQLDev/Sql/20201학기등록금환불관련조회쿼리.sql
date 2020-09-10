SELECT a.stuno,
       a.PERS_KOR_NM,
       a.SCHREG_MOD_FG || DECODE(a.SCHREG_MOD_FG,NULL,'','(') || SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) || DECODE(a.SCHREG_MOD_FG,NULL,'',')') AS "학적변동",
       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018') AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                 THEN SUBSTR(SF_TEMP202009_TEMP(a.stuno),1,4) || '.' || DECODE(SUBSTR(SF_TEMP202009_TEMP(a.stuno),5,10),'U000200001','1','2') 
                 ELSE '2020.1'
       END AS "등록금납부학기", 
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) AS "2020-1학기 등록금액",
       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "복귀생납부학기등록금",
       /*
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                 THEN (SELECT SCAL_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "복귀생납부학기장학금",
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                 THEN (SELECT REG_TT_AMT - SCAL_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "복귀생납부학기납입금",
       */
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) +       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "최종등록금액"
       /*
       NVL((SELECT REG_TT_AMT - SCAL_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) +       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND  stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                 THEN (SELECT REG_TT_AMT - SCAL_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "최종납입금액" 
       */
FROM temp202009_2 a 
--WHERE stuno = '2012-17605'
WHERE stuno = '2013-10260'
;

SELECT a.SCHREG_MOD_FG, a.* FROM sreg101 a WHERE stuno = '2012-17605' ;

SELECT SCHREG_MOD_FG FROM SREG405 
--SELECT REG_TT_AMT FROM ENRO200
WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' 
--WHERE SCHYY = '2019' AND SHTM_FG = 'U000200002' 
AND stuno = '2012-11829'
--'2015-16535' ) 
;

--운영테스트용
SELECT a.stuno,
       --a.PERS_KOR_NM,
       a.SCHREG_MOD_FG AS "학적변동코드",       
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                 AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'Y'  
                 THEN SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) || ' ,휴학'
           ELSE  SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) 
       END AS "학적변동명칭",       
       
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                 THEN SUBSTR(SF_TEMP202009_TEMP(a.stuno),1,4) || '.' || DECODE(SUBSTR(SF_TEMP202009_TEMP(a.stuno),5,10),'U000200001','1','2') 
            WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'Y'  
                 THEN ( SELECT CEAST_TO_SCHYY || '.' || DECODE(CEAST_TO_SHTM_FG,'U000200001','1','2')  FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' )
                      || ' 휴학종료'
            ELSE '2020.1'
       END AS "등록금납부학기", 
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) AS "2020-1학기 등록금액",
       
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'  
                                                           --     AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                           --              AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
            ELSE 0 
       END AS "복귀생납부학기등록금",
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno ),0) 
       +       
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                                                                  AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                           AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
            ELSE 0 
       END AS "최종등록금액"
FROM sreg101 a 
--WHERE stuno = '2012-17605'
--WHERE stuno = '2013-10260'
--WHERE stuno IN ( '2019-11840','2019-15791' )
--WHERE stuno = '2016-12866'
--'2014-15892',
WHERE stuno IN ( '2012-11829','2015-16535' )
; 


--20200904_재학생등록납부내역_v6_sql.txt
SELECT a.stuno "학번",
       a.PERS_KOR_NM "성명",
       --a.SCHREG_MOD_FG || DECODE(a.SCHREG_MOD_FG,NULL,'','(') || SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) || DECODE(a.SCHREG_MOD_FG,NULL,'',')') AS "학적변동",
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                 AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'Y'  
                 THEN a.SCHREG_MOD_FG || ' ' || SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) || ' ,휴학'
           ELSE  a.SCHREG_MOD_FG || ' ' || SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) 
       END AS "학적변동",         
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                 THEN SUBSTR(SF_TEMP202009_TEMP(a.stuno),1,4) || '.' || DECODE(SUBSTR(SF_TEMP202009_TEMP(a.stuno),5,10),'U000200001','1','2') 
            WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'Y'  
                 THEN ( SELECT CEAST_TO_SCHYY || '.' || DECODE(CEAST_TO_SHTM_FG,'U000200001','1','2')  FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' )
                      || ' 휴학종료'
            ELSE '2020.1'
       END AS "등록금납부학기",  
             
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) AS "2020-1학기 등록금액",   
           
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
            ELSE 0 
       END AS "복귀생납부학기등록금",
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) +       
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y'
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
            ELSE 0 
       END AS "최종등록금액",
      
       NVL((SELECT SUM(T1.LSN_AMT)
              FROM SCHO500 T1, ENRO300 T5, SCHO400 T6
             WHERE T1.STUNO = a.stuno
               AND T1.SCHYY = '2020'
               AND T1.SHTM_FG = 'U000200001'
               AND T1.DETA_SHTM_FG = 'U000300001'
               AND T1.SCAL_SLT_PROG_ST_FG = 'U073300004' /* 확정 */
               AND T1.ENTR_AMT + T1.LSN_AMT + T1.SSO_AMT > 0
               AND T1.SCHYY = T5.SCHYY(+)
               AND T1.SHTM_FG = T5.SHTM_FG(+)
               AND T1.DETA_SHTM_FG = T5.DETA_SHTM_FG(+)
               AND T1.STUNO = T5.STUNO(+)
               AND T5.GV_ST_FG(+) = 'U060500002'
               AND EXISTS (SELECT TA1.STUNO
                             FROM ENRO200 TA1
                            WHERE TA1.SCHYY = T1.SCHYY
                              AND TA1.SHTM_FG = T1.SHTM_FG
                              AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG
                              AND TA1.STUNO = T1.STUNO
                              AND TA1.GV_ST_FG = 'U060500002')
               AND T1.STUNO = T6.STUNO(+)
               AND T1.SCHYY = T6.SCHYY(+)
               AND T1.SHTM_FG = T6.SHTM_FG(+)
               AND T1.DETA_SHTM_FG = T6.DETA_SHTM_FG(+)), 0) AS "2020-1장학금(수업료)",
      
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                    THEN NVL((SELECT SUM(T1.LSN_AMT)
                                FROM SCHO500 T1, ENRO300 T5, SCHO400 T6
                               WHERE T1.STUNO = a.stuno
                                 AND T1.SCHYY || T1.SHTM_FG = SF_TEMP202009_TEMP(a.stuno)
                                 AND T1.DETA_SHTM_FG = 'U000300001'
                                 AND T1.SCAL_SLT_PROG_ST_FG = 'U073300004' /* 확정 */
                                 AND T1.ENTR_AMT + T1.LSN_AMT + T1.SSO_AMT > 0
                                 AND T1.SCHYY = T5.SCHYY(+)
                                 AND T1.SHTM_FG = T5.SHTM_FG(+)
                                 AND T1.DETA_SHTM_FG = T5.DETA_SHTM_FG(+)
                                 AND T1.STUNO = T5.STUNO(+)
                                 AND T5.GV_ST_FG(+) = 'U060500002'
                                 AND EXISTS (SELECT TA1.STUNO
                                               FROM ENRO200 TA1
                                              WHERE TA1.SCHYY = T1.SCHYY
                                                AND TA1.SHTM_FG = T1.SHTM_FG
                                                AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG
                                                AND TA1.STUNO = T1.STUNO
                                                AND TA1.GV_ST_FG = 'U060500002')
                                 AND T1.STUNO = T6.STUNO(+)
                                 AND T1.SCHYY = T6.SCHYY(+)
                                 AND T1.SHTM_FG = T6.SHTM_FG(+)
                                 AND T1.DETA_SHTM_FG = T6.DETA_SHTM_FG(+)), 0)
            ELSE 0
       END AS "복귀생납부수업료",
      
       NVL((SELECT SUM(T1.LSN_AMT)
              FROM SCHO500 T1, ENRO300 T5, SCHO400 T6
             WHERE T1.STUNO = a.stuno
               AND T1.SCHYY = '2020'
               AND T1.SHTM_FG = 'U000200001'
               AND T1.DETA_SHTM_FG = 'U000300001'
               AND T1.SCAL_SLT_PROG_ST_FG = 'U073300004' /* 확정 */
               AND T1.ENTR_AMT + T1.LSN_AMT + T1.SSO_AMT > 0
               AND T1.SCHYY = T5.SCHYY(+)
               AND T1.SHTM_FG = T5.SHTM_FG(+)
               AND T1.DETA_SHTM_FG = T5.DETA_SHTM_FG(+)
               AND T1.STUNO = T5.STUNO(+)
               AND T5.GV_ST_FG(+) = 'U060500002'
               AND EXISTS (SELECT TA1.STUNO
                             FROM ENRO200 TA1
                            WHERE TA1.SCHYY = T1.SCHYY
                              AND TA1.SHTM_FG = T1.SHTM_FG
                              AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG
                              AND TA1.STUNO = T1.STUNO
                              AND TA1.GV_ST_FG = 'U060500002')
               AND T1.STUNO = T6.STUNO(+)
               AND T1.SCHYY = T6.SCHYY(+)
               AND T1.SHTM_FG = T6.SHTM_FG(+)
               AND T1.DETA_SHTM_FG = T6.DETA_SHTM_FG(+)), 0)
      +
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                    THEN NVL((SELECT SUM(T1.LSN_AMT)
                                FROM SCHO500 T1, ENRO300 T5, SCHO400 T6
                               WHERE T1.STUNO = a.stuno
                                 AND T1.SCHYY || T1.SHTM_FG = SF_TEMP202009_TEMP(a.stuno)
                                 AND T1.DETA_SHTM_FG = 'U000300001'
                                 AND T1.SCAL_SLT_PROG_ST_FG = 'U073300004' /* 확정 */
                                 AND T1.ENTR_AMT + T1.LSN_AMT + T1.SSO_AMT > 0
                                 AND T1.SCHYY = T5.SCHYY(+)
                                 AND T1.SHTM_FG = T5.SHTM_FG(+)
                                 AND T1.DETA_SHTM_FG = T5.DETA_SHTM_FG(+)
                                 AND T1.STUNO = T5.STUNO(+)
                                 AND T5.GV_ST_FG(+) = 'U060500002'
                                 AND EXISTS (SELECT TA1.STUNO
                                               FROM ENRO200 TA1
                                              WHERE TA1.SCHYY = T1.SCHYY
                                                AND TA1.SHTM_FG = T1.SHTM_FG
                                                AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG
                                                AND TA1.STUNO = T1.STUNO
                                                AND TA1.GV_ST_FG = 'U060500002')
                                 AND T1.STUNO = T6.STUNO(+)
                                 AND T1.SCHYY = T6.SCHYY(+)
                                 AND T1.SHTM_FG = T6.SHTM_FG(+)
                                 AND T1.DETA_SHTM_FG = T6.DETA_SHTM_FG(+)), 0)
            ELSE 0
       END AS "최종 장학금(수업료)",
      
       (SELECT (SELECT SF_BSNS011_CODENM(T1.EARN_DECILE_FG) FROM DUAL)
          FROM SCHO400 T1
         WHERE T1.STUNO = a.stuno
           AND T1.SCHYY = '2020'
           AND T1.SHTM_FG = 'U000200001'
           AND T1.DETA_SHTM_FG = 'U000300001') AS "2020-1소득분위",
      
       CASE WHEN ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno AND SCHREG_MOD_FG IN ('U030300017','U030300018') ) = 'Y' 
                                                                AND ( SELECT CASE WHEN COUNT(1) = 0 THEN 'N' ELSE 'Y' END FROM SREG405 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND stuno = a.stuno 
                                                                         AND ( SELECT USR_DEF_1 FROM BSNS011 WHERE CMMN_CD = SREG405.SCHREG_MOD_FG ) = 'U032600002' ) = 'N'  
                    THEN (SELECT (SELECT SF_BSNS011_CODENM(T1.EARN_DECILE_FG) FROM DUAL)
                            FROM SCHO400 T1
                           WHERE T1.STUNO = a.stuno
                             AND T1.SCHYY || T1.SHTM_FG = SF_TEMP202009_TEMP(a.stuno)
                             AND T1.DETA_SHTM_FG = 'U000300001')
            ELSE NULL
       END AS "복귀생납부소득분위"
       
--FROM temp202009_2 a
FROM temp202009_2@DBLINK_SNUDEV02_SNU a
;


