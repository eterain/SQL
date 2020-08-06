
SP_ENRO200_REG_OBJ_CREA ;

SELECT * FROM ENRO200 WHERE stuno = '2015-10010' ;

SELECT * FROM  V_COMM111_4 WHERE  DEPT_CD = '991';

SELECT * FROM ENRO100 WHERE schyy = '2020' AND shtm_fg = 'U000200002' AND dept_cd = '991' ;

                    SELECT  T1.STUNO
                           ,T1.CPTN_CORS_FG
                           ,T1.PROG_CORS_FG
                           ,T1.DEPT_CD                  -- 부서코드(전공이 있으면 전공, 없으면 학과코드)
                           ,T1.DEPARTMENT_CD            -- 학과코드
                           ,T1.MAJOR_CD                 -- 전공코드
                           ,T1.DAYNGT_FG
                           ,T1.TMP_SHYR
                           ,NVL(T3.SCHREG_MOD_FG,T1.SCHREG_MOD_FG) AS SCHREG_MOD_FG
                           ,NVL(T3.SCHREG_MOD_DT,T1.SCHREG_MOD_DT) AS SCHREG_MOD_DT
                           ,T3.SCHREG_MOD_KND_FG
                           ,'N' AS THSS_SUBM_TERM_ELAPSE_YN
                      FROM   ( SELECT
                                     TB1.STUNO
                                   , TB1.CPTN_CORS_FG
                                   , TB1.PROG_CORS_FG
                                   , TB1.DEPT_CD
                                   , TB1.DEPARTMENT_CD
                                   , TB1.MAJOR_CD
                                   , TB1.TMP_SHYR
                                   , TB1.DAYNGT_FG
                                   , TB1.LSN_LMT_SHTM_CNT
                                   , TB1.EDAMT_SUPP_BREU_CD
                                   , TB2.SCHREG_MOD_FG AS SCHREG_MOD_FG
                                   , TB2.SCHREG_MOD_DT
                                   , TB1.STD_FG
                                  ,TB1.SCHREG_FG
                                  ,TB1.UNIVS_CD
                                  ,TB1.BDEGR_SYSTEM_FG
                                  , NVL(TB2.SCHREG_MOD_FG,TB1.SCHREG_MOD_FG) AS CUR_SCHREG_MOD_FG
                                  FROM  V_SREG101 TB1
                                        ,(
                                          SELECT
                                                  TB3.STUNO
                                                 ,TB3.SCHREG_MOD_FG
                                                 , TB3.SCHREG_MOD_DT
                                           FROM (
                                                 SELECT
                                                       TC1.STUNO
                                                      ,TC1.SCHREG_MOD_FG
                                                      , RANK() OVER(PARTITION BY TC1.STUNO ORDER BY TC1.SCHYY||TC1.SHTM_FG||LPAD(TC1.SCHREG_MOD_SEQ, 3, '0')||TC1.SCHREG_MOD_APLY_DT DESC) RK
                                                      , TC1.SCHREG_MOD_APLY_DT AS SCHREG_MOD_DT
                                                  FROM  SREG404 TC1
                                                       ,BSNS011 TC2
                                                WHERE TC1.SCHREG_ADPT_FG = 'U031000003'
                                                  and TC1.SCHREG_MOD_FG = TC2.CMMN_CD
                                                  --and TC1.CNCL_APLY_DT is null  /* 2015.02.27 취소일자기준(CNCL_APLY_DT)을 취소여부(CNCL_YN)로 변경. */
                                                  AND TC1.CNCL_YN = 'N'
                                                  AND TC1.SCHYY = '2020'
                                                  AND TC1.SHTM_FG = 'U000200002'
                                                  and TC1.SCHREG_ADPT_FG = 'U031000003'
                                                  AND TC2.USR_DEF_1 IN('U032600006','U032600003','U032600005')
                                                  /* S 2019-12-03 CH1909-00058 복학,복적,재입학자 조건 COMM201.진행상태'승인완료(U001600002)'로 수정 적용처리 */
                                                  AND SF_COMM201_ACCP(TC1.SCHAFF_ACCP_DMND_NO, '2') = 'U001600002'
                                                  /* E 2019-12-03 CH1909-00058 복학,복적,재입학자 조건 COMM201.진행상태'승인완료(U001600002)'로 수정 적용처리 */
                                               ) TB3
                                               WHERE TB3.RK = 1
                                          ) TB2
                                  WHERE TB1.STUNO = TB2.STUNO(+)
                                  ) T1
                           ,BSNS011 T2
                           ,(SELECT  STUNO
                                    ,SCHREG_MOD_FG
                                    ,SCHREG_MOD_DT
                                    ,SCHREG_MOD_KND_FG
                               FROM
                                     (SELECT  TA1.SCHYY
                                             ,TA1.SHTM_FG
                                             ,TA1.STUNO
                                             ,TA1.SCHREG_MOD_FG
                                             ,TA1.SCHREG_MOD_DT
                                             ,TA2.USR_DEF_1 AS SCHREG_MOD_KND_FG
                                             ,ROW_NUMBER() OVER(PARTITION BY SCHYY, SHTM_FG, STUNO ORDER BY SCHREG_MOD_DT||LPAD(SCHREG_MOD_SEQ, 3, '0') DESC) AS RANK  -- 2014.09.16 SCHREG_MOD_SEQ 기준 추가
                                        FROM  SREG405 TA1
                                             ,BSNS011 TA2
                                       WHERE  TA1.SCHREG_MOD_FG = TA2.CMMN_CD
                                         AND  SCHYY = '2020'
                                         AND  SHTM_FG = 'U000200002' ) TA1
                                       WHERE  RANK = 1 ) T3
                     WHERE  T1.CUR_SCHREG_MOD_FG = T2.CMMN_CD
                       AND  T1.STUNO = T3.STUNO(+)
                       AND  T1.SCHREG_FG = 'U030200001'                                 -- 학적구분: 재적
                       AND  T1.STD_FG = 'U030500001'                                    -- 학생구분: 정규학생
                       AND  T2.USR_DEF_1 <> 'U032600002'                                -- 학적변동종류구분 <> 휴학
                       AND  SF_ENRO200_REGUL_SHTM_EXCE_YN('2020','U000200002',T1.STUNO,T1.LSN_LMT_SHTM_CNT,NVL(T3.SCHREG_MOD_FG,T1.SCHREG_MOD_FG),'2',T1.CPTN_CORS_FG) = 'N'
                       AND  T1.DEPT_CD NOT IN (SELECT  DEPT_CD
                                                 FROM  COMM101
                                                WHERE  DEPT_CD = T1.DEPT_CD
                                                  AND  CNTR_SUST_YN = 'Y')              -- 계약학과 제외
                       AND  T1.STUNO NOT IN (SELECT  TA1.STUNO
                                               FROM  ENRO400 TA1
                                                    ,ENRO410 TA2
                                              WHERE  TA1.EXAM_STD_MNGT_NO = TA2.EXAM_STD_MNGT_NO
                                                AND  TA1.ENTR_SCHYY = '2020'
                                                AND  TA1.ENTR_SHTM_FG = 'U000200002'
                                                AND  TA2.GV_ST_FG = 'U060500002')
                       AND  T1.STUNO NOT IN (SELECT  TA1.STUNO
                                               FROM  SREG404 TA1
                                                    ,(SELECT  STUNO
                                                             ,COUNT(1) AS CNT
                                                        FROM  SCOR501
                                                       WHERE  MRKS_PNSH_KND_FG IN ('U050700002','U050700004')   -- 학사경고/성적경고
                                                         AND  MRKS_PNSH_TRET_FG = 'U053700002'                  -- 확정
                                                    GROUP BY  STUNO) TA2
                                              WHERE  TA1.STUNO = TA2.STUNO
                                                AND  TA1.SCHYY = '2020'
                                                AND  TA1.SHTM_FG = 'U000200002'
                                                AND  TA1.SCHREG_MOD_FG IN ('U030300030','U030300031')        -- 학사제명/학사제적
                                                AND  TA2.CNT >= 4)                                       -- 학사경고 4회 이상자 제외
                       AND  T1.STUNO NOT IN (SELECT  TA1.STUNO
                                               FROM  SREG404 TA1
                                                    ,(SELECT  STUNO
                                                             ,COUNT(1) AS CNT
                                                        FROM  SCOR501
                                                       WHERE  MRKS_PNSH_KND_FG = 'U050700003'            -- 유급
                                                         AND  MRKS_PNSH_TRET_FG = 'U053700002'
                                                    GROUP BY  STUNO) TA2
                                                 WHERE  TA1.STUNO = TA2.STUNO
                                                   AND  TA1.SCHYY = '2020'
                                                   AND  TA1.SHTM_FG = 'U000200002'
                                                   AND  TA1.SCHREG_MOD_FG IN ('U030300028','U030300029')     -- 유급제명/유급제적
                                                   AND  TA2.CNT >= 2)                                     -- 유급 2회 이상자 제외
                       AND  T1.STUNO NOT IN (SELECT TA1.STUNO
                                               FROM (SELECT  TB1.STUNO
                                                           , TB2.USR_DEF_1
                                                           , RANK() OVER(PARTITION BY TB1.STUNO ORDER BY TB1.SCHYY||TB1.SHTM_FG||LPAD(TB1.SCHREG_MOD_SEQ, 3, '0')||TB1.SCHREG_MOD_APLY_DT DESC) RK
                                                       FROM  SREG404 TB1,
                                                             BSNS011 TB2,
                                                             COMM201 TB3
                                                      WHERE  TB1.SCHREG_MOD_FG = TB2.CMMN_CD
                                                        AND  TB1.SCHAFF_ACCP_DMND_NO = TB3.SCHAFF_ACCP_DMND_NO(+)
                                                        AND  TB1.CNCL_YN = 'N'
                                                        AND  TB1.SCHREG_MOD_CNCL_APLY_RESN_FG IS NULL
                                                        AND  TB1.SCHYY = '2020'
                                                        AND  TB1.SHTM_FG = 'U000200002'
                                                        AND  TB2.USR_DEF_1 IN ('U032600002', 'U032600003') /* 휴학, 복학 */
                                                        AND  NVL(TB3.ACCP_ST_FG,'U001600000') = 'U001600002'  /* 2015.03.05 승인완료 */
                                                     ) TA1
                                              WHERE  TA1.RK = 1
                                                AND  TA1.USR_DEF_1 = 'U032600002' /* 휴학 */)   -- 휴학신청자제외(2014.09.16 같은 년도,학기에 휴학, 복학 신청 시 최종 학적변동구분으로 적용)
                       AND  T1.STUNO = '2015-10010' ;

SELECT SF_ENRO200_FREEMAJ('2020','U000200002','2015-10010','C013300001','4','1') FROM dual ;

SELECT SF_ENRO200_FREEMAJ('2020','U000200002','2015-10010','C013300001','4','2') FROM dual ;
