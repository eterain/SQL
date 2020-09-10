SELECT TA1.SCHYY,
       TA1.SHTM_FG,
       TA1.DETA_SHTM_FG,
       TA1.BDEGR_SYSTEM_FG,
       MIN(CASE
               WHEN TA1.DETA_BUSS_CD = 'A0090' THEN
                TA1.FR_DT
           END) AS FR_DT,
       MAX(CASE
               WHEN TA1.DETA_BUSS_CD = 'A0091' THEN
                TA1.FR_DT
           END) AS TO_DT
  FROM COMM121 TA1,
       COMM131 TA2
 WHERE TA1.DETA_BUSS_CD IN ('A0090', 'A0091') /* 학기시작, 학기종료 */
   AND TA1.SCHAFF_SCHE_FG = 'U000500003' /* 관리일정 */
   AND TA1.BDEGR_SYSTEM_FG = (SELECT T2.BDEGR_SYSTEM_TYPE
                                FROM SREG101     T1,
                                     V_COMM111_2 T2 --, COMM131 T3
                               WHERE NVL(T1.MJ_CD, T1.SUST_CD) = T2.DEPT_CD
                                 AND T1.STUNO = '2019-39196')
   AND TA2.ADPT_CD_FG LIKE 'U0002%'
   AND TA1.DETA_SHTM_FG = 'U000300001'
 GROUP BY TA1.SCHYY,
          TA1.SHTM_FG,
          TA1.DETA_SHTM_FG,
          TA1.BDEGR_SYSTEM_FG
;

SELECT * FROM comm121 
WHERE schyy = '2020' AND shtm_fg = 'U000200002' AND SCHAFF_SCHE_FG = 'U000500003' AND DETA_SHTM_FG = 'U000300001' AND BDEGR_SYSTEM_FG = 'U000100001'
AND deta_buss_cd IN ( 'A0090', 'A0091' )
;


SELECT CASE WHEN '1' = '1' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '8') <> '3' THEN decode(T1.COURSE_ENTR_SCHYY,'', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'3', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
          WHEN '1' = '2' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '8') <> '3' THEN decode(T1.COURSE_ENTR_SCHYY , '', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'4', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
          WHEN '1' = '1' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '1') = 'Y' THEN decode(T1.COURSE_ENTR_SCHYY,'', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'3', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
          WHEN '1' = '2' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '1') = 'Y' THEN decode(T1.COURSE_ENTR_SCHYY,'', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'4', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
          WHEN SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '8') = '3' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '1') = 'N' THEN SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1')
   END
      FROM (SELECT MAX(STUNO) STUNO, MAX(T3.ADPT_CD_FG) ADPT_CD_FG, MAX(T4.SCHYY) COURSE_ENTR_SCHYY, MAX(T4.SHTM_FG) COURSE_ENTR_SHTM_FG
            FROM  SREG101 T1
                 ,V_COMM111_2 T2
                 ,COMM131 T3
                 ,SREG401 T4
           WHERE  NVL(T1.MJ_CD, T1.SUST_CD) = T2.DEPT_CD 
             AND  T2.BDEGR_SYSTEM_FG = T3.BDEGR_SYSTEM_FG
             AND  T3.ADPT_CD_FG LIKE 'U0002%'
             AND  T1.STUNO = '2019-39196' 
             AND T1.STUNO = T4.AFTCHG_STUNO(+)
             AND T4.SUST_STUNO_MOD_FG(+) = 'U030800004' /* 학과학번변동구분 : 본과진입 */
             AND T4.SCHREG_ADPT_FG(+) = 'U031000002' /* 학적반영구분 : 반영 */
             AND T4.SCHREG_ADPT_DT(+) IS NOT NULL ) T1 ;

 SELECT  SUBSTR(SSTR, 1, 4) AS SCHYY
                , SUBSTR(SSTR, 9, 1) AS SHTM 
           FROM (
                  SELECT TRIM(SUBSTR(STR
                   , INSTR (STR, DLM, 1, LEVEL) + 1
                   , INSTR (STR, DLM, 1, LEVEL + 1) - INSTR (STR, DLM, 1, LEVEL) - 1
                   )) SSTR
                    FROM (SELECT ','|| 
                              (SELECT CASE WHEN '2' = '1' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '8') <> '3' THEN decode(T1.COURSE_ENTR_SCHYY,'', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'3', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
                                          WHEN '2' = '2' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '8') <> '3' THEN decode(T1.COURSE_ENTR_SCHYY , '', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'4', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
                                          WHEN '2' = '1' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '1') = 'Y' THEN decode(T1.COURSE_ENTR_SCHYY,'', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'3', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
                                          WHEN '2' = '2' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '1') = 'Y' THEN decode(T1.COURSE_ENTR_SCHYY,'', SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1'), SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO,'4', T1.COURSE_ENTR_SCHYY, T1.COURSE_ENTR_SHTM_FG))
                                          WHEN SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '8') = '3' AND SF_SREG401_COURSE_AF_CHGSUB_YN(T1.STUNO, '1') = 'N' THEN SF_SCHREG_MOD_SCHYY_CERT3(T1.STUNO, '1')
                                   END
                                      FROM (SELECT MAX(STUNO) STUNO, MAX(T3.ADPT_CD_FG) ADPT_CD_FG, MAX(T4.SCHYY) COURSE_ENTR_SCHYY, MAX(T4.SHTM_FG) COURSE_ENTR_SHTM_FG
                                            FROM  SREG101 T1
                                                 ,V_COMM111_2 T2
                                                 ,COMM131 T3
                                                 ,SREG401 T4
                                           WHERE  NVL(T1.MJ_CD, T1.SUST_CD) = T2.DEPT_CD 
                                             AND  T2.BDEGR_SYSTEM_FG = T3.BDEGR_SYSTEM_FG
                                             AND  T3.ADPT_CD_FG LIKE 'U0002%'
                                             AND  T1.STUNO = '2019-39196' 
                                             AND T1.STUNO = T4.AFTCHG_STUNO(+)
                                             AND T4.SUST_STUNO_MOD_FG(+) = 'U030800004' /* 학과학번변동구분 : 본과진입 */
                                             AND T4.SCHREG_ADPT_FG(+) = 'U031000002' /* 학적반영구분 : 반영 */
                                             AND T4.SCHREG_ADPT_DT(+) IS NOT NULL /* 학적반영일자: NOT NULL */) T1)||',' STR, ',' DLM  FROM DUAL)
                    CONNECT BY LEVEL <= LENGTH (STR) - LENGTH (REPLACE (STR, ',')) -1) AA
         , (SELECT T1.SCHYY AS SCHYY, SUBSTR(T1.SHTM_FG, 10, 1) AS SHTM_FG
              FROM (  SELECT TA1.SCHYY
                                 , TA1.SHTM_FG
                                   , TA1.DETA_SHTM_FG
                                   , TA1.BDEGR_SYSTEM_FG
                                   , MIN(CASE WHEN TA1.DETA_BUSS_CD = 'A0090' THEN TA1.FR_DT END) AS FR_DT
                                   , MAX(CASE WHEN TA1.DETA_BUSS_CD = 'A0091' THEN TA1.FR_DT END) AS TO_DT
                              FROM COMM121 TA1, COMM131 TA2
                          WHERE TA1.DETA_BUSS_CD IN ('A0090', 'A0091') /* 학기시작, 학기종료 */
                               AND TA1.SCHAFF_SCHE_FG = 'U000500003' /* 관리일정 */
                               AND TA1.BDEGR_SYSTEM_FG = (SELECT T2.BDEGR_SYSTEM_TYPE
                                                                            FROM SREG101 T1, V_COMM111_2 T2 --, COMM131 T3
                                                                      WHERE NVL(T1.MJ_CD, T1.SUST_CD) = T2.DEPT_CD
                                                                            AND T1.STUNO = '2019-39196')
                               AND TA2.ADPT_CD_FG LIKE 'U0002%'
                               AND TA1.DETA_SHTM_FG = 'U000300001'
                            GROUP BY TA1.SCHYY, TA1.SHTM_FG, TA1.DETA_SHTM_FG, TA1.BDEGR_SYSTEM_FG) T1
             WHERE TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN T1.FR_DT AND T1.TO_DT) BB
    /* 2015.01.07 16:24분 ...현재 학년도까지만 나오도록 되어 있는 부분 주석처리...(고익재).. */
    /* 2015.02.02 ..현재 학년도까지만 나오도록 주석 해제(원복처리)...(김대종).. */
             WHERE   SUBSTR(aa.SSTR, 1, 4) || SUBSTR(aa.SSTR, 9, 1)  <= bb.SCHYY ||  bb.SHTM_FG 
;

SELECT 
              '('||DECODE(IS_DATE(SCHREG_MOD_DT), 1, NVL(TO_CHAR(TO_DATE(SCHREG_MOD_DT,'yyyy-mm-dd'),'yyyy. fmmm. ddfm.'),''), 
         NVL(trim(substr(SCHREG_MOD_DT,1,4) ||'. '||substr(SCHREG_MOD_DT,5,2)||'. '||substr(SCHREG_MOD_DT,7,2)),''))||')' SCHREG_MOD_DT /* 학적변동일자 */     
          ,'('||DECODE(IS_DATE(SCHREG_MOD_DT), 1, TRIM(TO_CHAR(TO_DATE(SCHREG_MOD_DT,'yyyy-mm-dd'), 'Month', 'NLS_DATE_LANGUAGE=ENGLISH'))||
          TO_CHAR(TO_DATE(SCHREG_MOD_DT,'yyyy-mm-dd'), ' fmdd, yyyy', 'NLS_DATE_LANGUAGE=ENGLISH'), 
          NVL(trim(substr(SCHREG_MOD_DT,5,2) ||' '||substr(SCHREG_MOD_DT,7,2)||', '||substr(SCHREG_MOD_DT,1,4)),''))||')' SCHREG_MOD_DT_ENG
                      FROM SREG405 T1
                         , COMM112 T2
                         , SREG101 T3
                         , V_COMM111_4 T4
                     WHERE T1.STUNO     = '2019-39196'
                 AND 'Y' = 'Y' 
                       AND T1.STUNO     = T3.STUNO
                       AND NVL(T3.MJ_CD, T3.SUST_CD) = T4.DEPT_CD
                       AND T4.BDEGR_SYSTEM_FG = T2.BDEGR_SYSTEM_FG
                       AND T2.DETA_BUSS_CD    = 'F0065' 
                       AND T1.SCHREG_MOD_FG IN ('U030300004', 'U030300005', 'U030300008', 'U030300009')
                       AND T1.SCHREG_MOD_OCCR_ORD = (SELECT MAX(TA1.SCHREG_MOD_OCCR_ORD)
                                                       FROM SREG405 TA1
                                                          , BSNS011 TA2
                                                      WHERE TA1.STUNO = T1.STUNO
                                                        AND TA1.SCHREG_MOD_FG = TA2.CMMN_CD)
;


SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'A0090'
ORDER BY A.DISP_ORD, A.CMMN_CD
;


SELECT SUST_STUNO_MOD_FG, SCHREG_ADPT_FG,SUST_STUNO_MOD_FG, A.* FROM SREG401 A WHERE AFTCHG_STUNO = '2019-39196' ;
