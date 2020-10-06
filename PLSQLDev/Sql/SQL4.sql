SELECT * FROM BKIN400 ;
SELECT * FROM BKIN420 ;

SELECT * FROM enro300 WHERE RECHER_REG_SUST_ACCP_YN = 'Y' ;


CALL SP_ESIN606_FL_CREA ;

SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0271'
ORDER BY A.DISP_ORD, A.CMMN_CD
;

--A220900001	관리비
--A220900002	월사용료





-- 2012-23620 이정무 농협은행 79005871659013

SELECT * FROM REG_MASTER WHERE FYEAR = '2020' AND FNOSTUDENT = '2012-23620';

SELECT * FROM REG_ONLINE WHERE FYEAR = '2020' ;
SELECT * FROM REG_ONLINE WHERE FNOSTUDENT = '201223620';

-- SELECT * FROM comm620 ;

SELECT * FROM slg.enro300_log WHERE schyy = '2020' AND shtm_fg = 'U000200002' AND stuno = '2012-23620';

SELECT * FROM enro300 WHERE schyy = '2020' AND shtm_fg = 'U000200002' AND stuno = '2012-23620';

--SELECT * FROM slg.enro300_log 
SELECT * FROM enro300
WHERE schyy = '2020' AND shtm_fg = 'U000200002' AND GV_ST_FG = 'U060500002'
--AND stuno = '2012-23620'
--AND mod_id = 'B111549'
ORDER BY mod_dttm 
;

SELECT * FROM V_SREG101 WHERE stuno = '2012-23620' ;


SELECT  T1.SCHYY
                   ,T1.SHTM_FG
                   ,T1.DETA_SHTM_FG
                   ,T1.STUNO
                   ,T1.PROG_CORS_FG
                   ,T1.DEPT_CD
                   ,NVL((SELECT TB3.RECHER_PNFE
                          FROM COMM106 TB1
                              ,ENRO120 TB3
                         WHERE TB3.SCHYY = T1.SCHYY /* 학년도(PK1) */
                           AND TB3.SHTM_FG = T1.SHTM_FG /* 학기구분(PK2) */
                           AND TB3.DETA_SHTM_FG = T1.DETA_SHTM_FG
                           AND TB3.BDEGR_SYSTEM_FG = 'U000100001' --#strBdegrSystemFg#  /* 학사시스템구분(PK4) */
                           AND TB1.PART_FG = TB3.RECHER_PNFE_PART_FG
                           AND TB1.CORS_FG = TB3.CORS_FG
                           AND TB1.CORS_FG = T1.PROG_CORS_FG
                           AND TB1.DEPT_CD = T1.DEPT_CD
                           AND TB3.SCHYY || (SELECT SF_BSNS011_CODENM(TB3.SHTM_FG, 4) FROM DUAL) BETWEEN
                               TB1.FR_SCHYY ||  (SELECT SF_BSNS011_CODENM(TB1.FR_SHTM_FG, 4) FROM DUAL) AND
                               TB1.TO_SCHYY ||  (SELECT SF_BSNS011_CODENM(TB1.TO_SHTM_FG, 4) FROM DUAL)
                         )
                       ,T1.RECHER_PNFE) AS RECHER_PNFE
                   ,T1.RECIV_RECHER_PNFE
                   ,T1.GV_ST_FG
              FROM (WITH W_SREG101 AS (
                        SELECT  TA1.STUNO, TA1.PROG_CORS_FG, TA1.DEPT_CD, TA1.STD_FG, TA1.SCHREG_FG
                               ,(SELECT SF_SREG103_THSS_SUBM_LMT('2020'
                                                                       ,'U000200002'
                                                                       ,Ta1.STUNO
                                                                       ,Ta1.DEPT_CD
                                                                       ,'U083100002'
                                                                       ,'1')
                                          FROM DUAL) AS THSS_SUBM_SCHYY_SHTM
                               ,(SELECT  /*+ INDEX_DESC(SREG103 PK_SREG103) */
                                         CETE_SCHYY
                                   FROM  SREG103
                                  WHERE  STUNO = TA1.STUNO
                                    AND  ROWNUM < 2
                                ) AS CETE_SCHYY
                          FROM  V_SREG101 TA1
                              -- ,(SELECT  DEPT_CD
                              --     FROM  TABLE(PKG_UNI_COMM_DEPT.F_ROLE_DEPT_CD(#strUserNo#, #strPgmCd#, #strBdegrSystemFg#))
                              --  ) TA2
                         WHERE  TA1.PROG_CORS_FG IN ('C013300002', 'C013300003')     /* 석사, 박사*/
                           AND  TA1.STD_FG IN ('U030500001', 'U030500002', 'U030500003')              /* 정규학생, 연구생, 논문제출기한경과자연구생 */
                           --AND  TA2.DEPT_CD = TA1.DEPT_CD
                           /* 연구생등록 제외대상자 */
                           AND  NOT EXISTS (SELECT  1
                                              FROM  ENRO330
                                             WHERE  '2020' || 'U000200002' BETWEEN    REG_LMT_FR_SCHYY
                                                                                              || REG_LMT_FR_SHTM_FG
                                                                                          AND    REG_LMT_TO_SCHYY
                                                                                              || REG_LMT_TO_SHTM_FG
                                               AND  SYSDATE >= ADPT_FR_DT
                                               AND  ALLW_YN = 'Y'
                                               AND  STUNO = TA1.STUNO
                                           )
                              /* 수료확정자 포함 */
                           AND  NOT EXISTS (SELECT  1
                                              FROM  ENRO300
                                             WHERE  SCHYY = '2020'
                                               AND  SHTM_FG = 'U000200002'
                                               AND  DETA_SHTM_FG = 'U000300001'
                                               AND  STUNO = TA1.STUNO
                                               
                                               AND GV_ST_FG = 'U060500002'
                                           )
                           AND  NOT EXISTS (SELECT  1
                                              FROM  ENRO200
                                             WHERE  SCHYY = '2020'
                                               AND  SHTM_FG = 'U000200002'
                                               AND  DETA_SHTM_FG = 'U000300001'
                                               AND  STUNO = TA1.STUNO
                                               AND  TA1.STD_FG = 'U030500003'
                                           )
                           AND  NOT EXISTS (SELECT  1   /* 논문제출제한일자가 학기시작일 보다 작은경우 제외 */
                                              FROM  SREG103 TB1
                                             WHERE  TB1.STUNO = TA1.STUNO
                                              /* AND  TA1.STD_FG = 'U030500003' */
                                               AND  TB1.THSS_SUBM_LMT_DT  <  (SELECT MIN(TC1.FR_DT)
                                                                                            FROM COMM121 TC1
                                                                                           WHERE TC1.SCHYY = '2020'
                                                                                             AND TC1.SHTM_FG = 'U000200002'
                                                                                             AND TC1.DETA_SHTM_FG = 'U000300001'
                                                                                             AND TC1.SCHAFF_SCHE_FG = 'U000500001' /* 학사일정구분(공통학사력) */)
                                           )
                     )
                    SELECT  '2020' AS SCHYY /* 학년도*/
                          ,'U000200002' AS SHTM_FG /* 학기 */
                          ,'U000300001' AS DETA_SHTM_FG /* 세부학기 정규*/
                          ,TB1.STUNO /* 학번*/
                          ,TB1.PROG_CORS_FG /* 진행과정*/
                          ,TB1.DEPT_CD /*부서코드*/
                          ,0 AS RECHER_PNFE /* 연구생부담금*/
                          ,0 AS RECIV_RECHER_PNFE /*수납연구생부담금 0원*/
                          ,'U060500001' AS GV_ST_FG /*납입상태 미등록 */
                       FROM  W_SREG101 TB1
                      WHERE  TB1.SCHREG_FG = 'U030200004' /* 수료 */
                        AND  TB1.CETE_SCHYY IS NOT NULL /* 수료학년도*/
                        AND  TB1.THSS_SUBM_SCHYY_SHTM = 'Y'
                        AND  NOT EXISTS
                                (SELECT 1
                                  FROM GRDT730 TA1
                                      ,BSNS011 TA2
                                 WHERE TA1.STUNO = TB1.STUNO
                                   AND TA1.FNSS_FG = TA2.CMMN_CD
                                   AND TA1.GRDT_SCRN_FG = 'U084500001'
                                      /* 졸업사정구분 : 졸업사정 */
                                   AND TA1.EXCP_OBJ_YN = 'N'
                                   AND TA1.SCRN_FXD_GRDT_JUDT_FG = 'U084800001'
                                      /* 심의확정졸업판정구분(사정확정구분) : 합격 */
                                   AND TA1.GRDT_FG = 'U083100001' /* 졸업구분 : 졸업 */
                                   AND TA1.GRDT_SCHYY = '2020' - '1' /* 졸업학년도 : 파라미터로 넘어온 힉년도 - 1 */
                                   AND TA2.KOR_ABB_NM_1 = SUBSTR('U000200002', 10)
                                )
                        /* 전후기구분 : 파라미터로 넘어온 학기의 끝자리와 비교 */
                        UNION ALL
                        SELECT '2020' AS SCHYY /* 학년도*/
                              ,'U000200002' AS SHTM_FG /* 학기 */
                              ,'U000300001' AS DETA_SHTM_FG /* 세부학기 정규*/
                              ,TB1.STUNO /* 학번*/
                              ,TB1.PROG_CORS_FG /* 진행과정*/
                              ,TB1.DEPT_CD /*부서코드*/
                              ,0 AS RECHER_PNFE /* 연구생부담금*/
                              ,0 AS RECIV_RECHER_PNFE /*수납연구생부담금
                               0원*/
                              ,'U060500001' AS GV_ST_FG /*납입상태 미등록 */
                          FROM W_SREG101 TB1
                         WHERE TB1.SCHREG_FG = 'U030200001' /* 재적*/
                           AND TB1.STD_FG = 'U030500001'
                           AND EXISTS
                                 (SELECT 1
                                  FROM GRDT730 TA1
                                      ,BSNS011 TA2
                                 WHERE TA1.STUNO = TB1.STUNO
                                   AND TA1.FNSS_FG = TA2.CMMN_CD
                                   AND TA1.GRDT_SCRN_FG = 'U084500001'
                                      /* 졸업사정구분 : 졸업사정 */
                                   AND TA1.EXCP_OBJ_YN = 'N'
                                   AND TA1.SCRN_FXD_GRDT_JUDT_FG = 'U084800001'
                                      /* 심의확정졸업판정구분(사정확정구분) : 합격 */
                                   AND TA1.GRDT_FG = 'U083100002' /* 졸업구분 : 수료 */
                                   AND TA1.GRDT_SCHYY = '2020' - '1' /* 졸업학년도 : 파라미터로 넘어온 힉년도 - 1 */
                                   AND TA2.KOR_ABB_NM_1 = SUBSTR('U000200002', 10)
                                 )
                        /* 전후기구분 : 파라미터로 넘어온 학기의 끝자리와 비교 */
                 ) T1
                group by   T1.SCHYY
                          ,T1.SHTM_FG
                          ,T1.DETA_SHTM_FG
                          ,T1.STUNO
                          ,T1.PROG_CORS_FG
                          ,T1.DEPT_CD
                          ,T1.RECHER_PNFE
                          ,T1.RECIV_RECHER_PNFE
                          ,T1.GV_ST_FG
