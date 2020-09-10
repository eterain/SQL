SELECT * FROM enro250 WHERE stuno = '2019-28921';

SELECT RECIV_DT, a.* FROM enro200 a
WHERE a.stuno = '2019-28921' 
AND a.DEPT_CD NOT IN (SELECT DEPT_CD FROM COMM101 WHERE CNTR_SUST_YN = 'Y') 
;

/*2. 등록금 */     
SELECT SUBSTR(T1.RECIV_DT, 1, 4) || '.' ||
       CASE WHEN SUBSTR(T1.RECIV_DT, 5, 2) IN ('01','02','03','04','05','06') THEN '02'
            WHEN SUBSTR(T1.RECIV_DT, 5, 2) IN ('07','08','09','10','11','12') THEN '08'
       END || '.' AS RECIV_YYYYMM     /* 납부연월 */
     , (SELECT DECODE(COLG_GRSC_FG, 'U030600001', '대학교', 'U030600002', '대학원', SF_BSNS011_CODENM(COLG_GRSC_FG))
          FROM SREG101
         WHERE STUNO = T1.STUNO)                                     AS COLG_GRSC_NM     /* 종류(대학교/대학원) */
     , '입학금 및 수업료 등'                                                AS ENTR_LSN_ETC     /* 구분 */
     , SUM(T1.ENTR_AMT)                                              AS ENTR_AMT         /* 입학금 */
     , SUM(T1.LSN_AMT)                                               AS LSN_AMT          /* 수업료 */
     , SUM(T1.REG_TT_AMT)                                            AS REG_TT_AMT       /* 등록총금액 (합계) */
--   , SUM(T1.SCAL_TT_AMT)                                           AS SCAL_TT_AMT      /* 장학총금액 (학비감면) */
--   , SUM(T1.ADD_SCAL_AMT)                                          AS ADD_SCAL_AMT     /* 추가장학금 (직접지급액) */
     , CASE WHEN SUM(T1.REG_TT_AMT) - SUM(T1.REG_SHTMSW_AMT) > 0
            THEN CASE WHEN SUM(T1.REG_TT_AMT) - SUM(T1.REG_SHTMSW_AMT) <= SUM(T1.SCAL_TT_AMT)
                      THEN SUM(T1.REG_TT_AMT) - SUM(T1.REG_SHTMSW_AMT)
                      ELSE SUM(T1.SCAL_TT_AMT)
                 END
            ELSE 0
       END                                                           AS SCAL_TT_AMT      /* 장학총금액 (학비감면) */
     , CASE WHEN SUM(T1.REG_TT_AMT) - SUM(T1.REG_SHTMSW_AMT) > 0
            THEN CASE WHEN SUM(T1.REG_TT_AMT) - SUM(T1.REG_SHTMSW_AMT) <= SUM(T1.SCAL_TT_AMT)
                      THEN SUM(T1.SCAL_TT_AMT) - (SUM(T1.REG_TT_AMT) - SUM(T1.REG_SHTMSW_AMT))
                      ELSE 0
                 END
            ELSE SUM(T1.SCAL_TT_AMT)
       END + SUM(T1.ADD_SCAL_AMT)                                    AS ADD_SCAL_AMT     /* 추가장학금 (직접지급액) */
     , SUM(T1.LOAN_AMT)                                              AS LOAN_AMT         /* 학자금대출 */
     , SUM(NVL(T1.REG_TT_AMT, 0) - NVL(T1.SCAL_TT_AMT, 0) - NVL(T1.ADD_SCAL_AMT, 0) - NVL(T1.LOAN_AMT, 0))
                                                                     AS DUC_OBJ_EDAMT    /* 공제대상교육비 */
  FROM (SELECT 1 AS FLAG
             , TA1.SCHYY
             , TA1.SHTM_FG
             , TA1.DETA_SHTM_FG
             , TA1.STUNO
             
             --, TA1.RECIV_DT 
             , CASE WHEN SUBSTR(TA1.RECIV_DT, 1, 6) = ( '2019' - 1 || '12' ) THEN '2019' || '0100' ELSE TA1.RECIV_DT END AS RECIV_DT
             
             , TA1.ENTR_AMT
             , TA1.LSN_AMT + TA1.SSO_AMT                  AS LSN_AMT
             , TA1.ENTR_AMT + TA1.LSN_AMT + TA1.SSO_AMT   AS REG_TT_AMT
             , 0                                          AS REG_SHTMSW_AMT
             , 0                                          AS SCAL_TT_AMT
             , 0                                          AS ADD_SCAL_AMT
             , 0                                          AS LOAN_AMT
          FROM ENRO200 TA1
         WHERE TA1.STUNO        = '2019-28921'
           AND TA1.DEPT_CD NOT IN (SELECT DEPT_CD FROM COMM101 WHERE CNTR_SUST_YN = 'Y') /* 계약학과여부 */
        UNION ALL
        SELECT 2 AS FLAG
             , TA1.SCHYY
             , TA1.SHTM_FG
             , TA1.DETA_SHTM_FG
             , TA1.STUNO
             , TA1.SLT_DT                                 AS RECIV_DT
             , 0                                          AS ENTR_AMT
             , 0                                          AS LSN_AMT
             , 0                                          AS REG_TT_AMT
             , 0                                          AS REG_SHTMSW_AMT
             , DECODE(TA1.SCHEXP_REDC_YN, 'Y'
                                        , TA1.SCAL_TT_AMT
                                        , 0
                             )                            AS SCAL_TT_AMT
             , DECODE(TA1.SCHEXP_REDC_YN, 'Y'
                                        , 0
                                        , TA1.SCAL_TT_AMT
                             )                            AS ADD_SCAL_AMT
             , 0                                          AS LOAN_AMT
          FROM SCHO500 TA1
         WHERE TA1.STUNO               = '2019-28921'
           AND TA1.SCAL_SLT_PROG_ST_FG = 'U073300004' /* 확정 */
           AND TA1.DEPT_CD NOT IN (SELECT DEPT_CD FROM COMM101 WHERE CNTR_SUST_YN = 'Y') /* 계약학과여부 */
           AND TA1.SCAL_TT_AMT        != 0
        UNION ALL
        SELECT 3 AS FLAG
             , TA1.SCHYY
             , TA1.SHTM_FG
             , TA1.DETA_SHTM_FG
             , TA1.STUNO
             , TA3.PAY_DT                                 AS RECIV_DT
             , 0                                          AS ENTR_AMT
             , 0                                          AS LSN_AMT
             , 0                                          AS REG_TT_AMT
             , 0                                          AS REG_SHTMSW_AMT
             , DECODE(TA1.SCHEXP_REDC_YN, 'Y'
                                        , TA3.PAY_AMT
                                        , 0
                             )                            AS SCAL_TT_AMT
             , DECODE(TA1.SCHEXP_REDC_YN, 'Y'
                                        , 0
                                        , TA3.PAY_AMT
                             )                            AS ADD_SCAL_AMT
             , 0                                          AS LOAN_AMT
          FROM SCHO500 TA1
             , SCHO100 TA2
             , SCHO510 TA3
         WHERE TA1.SCAL_CD             = TA2.SCAL_CD
           AND TA1.SCAL_SLT_NO         = TA3.SCAL_SLT_NO
           AND TA1.STUNO               = '2019-28921'
           AND TA1.SCAL_SLT_PROG_ST_FG = 'U073300004' /* 확정 */
           AND TA1.DEPT_CD NOT IN (SELECT DEPT_CD FROM COMM101 WHERE CNTR_SUST_YN = 'Y') /* 계약학과여부 */
           AND TA2.MM_PAY_INCL_YN      = 'Y'
           AND TA3.SCAL_PAY_FG IN ('U070900002', 'U070900003') /* 생활비/월정, 근로장학 */
           AND TA3.SCAL_AMT_PAY_PROG_ST_FG = 'U073400002'      /* 지급 */
           AND TA3.PAY_AMT            != 0
        UNION ALL
        SELECT 4 AS FLAG
             , TA1.SCHYY
             , TA1.SHTM_FG
             , 'U000300001' AS DETA_SHTM_FG
             , TA1.STUNO
             , TA1.LOAN_RUN_DT                            AS RECIV_DT
             , 0                                          AS ENTR_AMT
             , 0                                          AS LSN_AMT
             , 0                                          AS REG_TT_AMT
             , 0                                          AS REG_SHTMSW_AMT
             , 0                                          AS SCAL_TT_AMT
             , 0                                          AS ADD_SCAL_AMT
             , TA1.LOAN_AMT                               AS LOAN_AMT
          FROM SCHO850 TA1
         WHERE TA1.STUNO               = '2019-28921'
        UNION ALL
        SELECT 5 AS FLAG
             , TA1.OPEN_SCHYY                             AS SCHYY            /* 학년도 */
             , TA1.OPEN_SHTM_FG                           AS SHTM_FG          /* 학기구분 */
             , TA1.OPEN_DETA_SHTM_FG                      AS DETA_SHTM_FG     /* 세부학기구분 */
             , TA1.STUNO                                                      /* 학번 */
             , TA2.SHTMSW_TUIT_RECIV_DT                   AS RECIV_DT         /* 수납일자*/
             , 0                                          AS ENTR_AMT         /* 입학금 */
             , TA1.SHTMSW_SBJT_TLSN_AMT                   AS LSN_AMT          /* 수업료 */
             , TA1.SHTMSW_SBJT_TLSN_AMT                   AS REG_TT_AMT       /* 등록총금액 (합계) */
             , TA1.SHTMSW_SBJT_TLSN_AMT                   AS REG_SHTMSW_AMT   /* 계절학기등록금 (내부계산용) */
             , 0                                          AS SCAL_TT_AMT      /* 장학총금액 (학비감면) */
             , 0                                          AS ADD_SCAL_AMT     /* 추가장학금 (직접지급액) */
             , 0                                          AS LOAN_AMT         /* 학자금대출 */
          FROM (
                SELECT OPEN_SCHYY
                     , OPEN_SHTM_FG
                     , OPEN_DETA_SHTM_FG
                     , STUNO
                     , SUM(SHTMSW_SBJT_TLSN_AMT) AS SHTMSW_SBJT_TLSN_AMT
                  FROM ENRO501
                 WHERE STUNO                     = '2019-28921'
                   AND NOTI_THTM_TLSN_APLY_ST_FG = 'U043100001'
                   AND SHTMSW_TUIT_NOTI_SEQ      = '1'
                 GROUP BY OPEN_SCHYY, OPEN_SHTM_FG, OPEN_DETA_SHTM_FG, STUNO
                 ORDER BY OPEN_SCHYY, OPEN_SHTM_FG, OPEN_DETA_SHTM_FG, STUNO
               ) TA1
             , (
                SELECT OPEN_SCHYY
                     , OPEN_SHTM_FG
                     , OPEN_DETA_SHTM_FG
                     , STUNO
                     , MIN(SHTMSW_TUIT_RECIV_DT)  AS SHTMSW_TUIT_RECIV_DT
                     , SUM(SHTMSW_TUIT_RECIV_AMT) AS SHTMSW_TUIT_RECIV_AMT
                  FROM ENRO520
                 WHERE STUNO                     = '2019-28921'
                 GROUP BY OPEN_SCHYY, OPEN_SHTM_FG, OPEN_DETA_SHTM_FG, STUNO
                 ORDER BY OPEN_SCHYY, OPEN_SHTM_FG, OPEN_DETA_SHTM_FG, STUNO
               ) TA2
         WHERE TA1.OPEN_SCHYY        = TA2.OPEN_SCHYY
           AND TA1.OPEN_SHTM_FG      = TA2.OPEN_SHTM_FG
           AND TA1.OPEN_DETA_SHTM_FG = TA2.OPEN_DETA_SHTM_FG
           AND TA1.STUNO             = TA2.STUNO
       ) T1
 WHERE SUBSTR(T1.RECIV_DT, 1, 4) = '2019'
 GROUP BY T1.STUNO                                                  --, T1.SCHYY
     , SUBSTR(T1.RECIV_DT, 1, 4) || '.' ||
       CASE WHEN SUBSTR(T1.RECIV_DT, 5, 2) IN ('01','02','03','04','05','06') THEN '02'
            WHEN SUBSTR(T1.RECIV_DT, 5, 2) IN ('07','08','09','10','11','12') THEN '08'
       END || '.'
 ORDER BY T1.STUNO
     , RECIV_YYYYMM
