-- SR2009-21894 : 교육국제화역량 인증제 등록금 자료 요청건
SELECT A.SCHYY,
       A.SHTM_FG,
       A.STUNO,
       B.LSN_AMT AS "등록금의수업료",
       B.REGUL_SHTM_EXCE_YN AS "수업연한초과여부",
       B.TLSN_APLY_PNT AS "수강학점", 
       B.AUTO_REG_FG || DECODE(NVL(B.AUTO_REG_FG,'-'),'-','','(') || SF_BSNS011_CODENM(B.AUTO_REG_FG, 1) || DECODE(NVL(B.AUTO_REG_FG,'-'),'-','',')') AS "자동등록",
       CASE WHEN B.PART_YN = 'Y' THEN ( SELECT MAX(RECIV_DT) FROM ENRO230 X
                                         WHERE X.SCHYY = A.SCHYY
                                           AND X.SHTM_FG = A.SHTM_FG 
                                           AND X.STUNO = A.STUNO
                                           AND X.RECIV_YN = 'Y' )
            ELSE ( SELECT MAX(RECIV_DT) FROM ENRO250 X
                    WHERE X.SCHYY = A.SCHYY
                      AND X.SHTM_FG = A.SHTM_FG 
                      AND DETA_SHTM_FG = 'U000300001'
                      AND X.STUNO = A.STUNO )
       END AS "등록금수납일자",
       B.PART_YN AS "분납여부",
       ( SELECT MAX(RECIV_DT) FROM ENRO230 X
          WHERE X.SCHYY = A.SCHYY
            AND X.SHTM_FG = A.SHTM_FG 
            AND DETA_SHTM_FG = 'U000300001'
            AND X.STUNO = A.STUNO
            AND X.RECIV_YN = 'Y' ) AS "분납자최종입금일자"       
            
  FROM TEMP_20200925 A,           -- TEMP TABLE 정의
       ENRO200 B
       
 WHERE A.SCHYY = B.SCHYY (+)
   AND A.SHTM_FG = B.SHTM_FG (+)
   AND A.STUNO = B.STUNO (+)
   AND A.SCHYY = '2020'
   AND A.SHTM_FG = 'U000200001'
   AND B.DETA_SHTM_FG = 'U000300001'
;


SELECT RECIV_DT FROM ENRO250
WHERE SCHYY = '2019'
AND SHTM_FG = 'U000200001'
AND DETA_SHTM_FG = 'U000300001'
AND stuno = '2019-29396'
;


SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0612'
ORDER BY A.DISP_ORD, A.CMMN_CD
;

  /* ENRO250.find01 등록금수납환불내역 조회 */
  SELECT DECODE(T1.RN, 1, T1.STUNO, '') AS STUNO,
         T1.RECIV_DT,
    FROM (SELECT TA1.SCHYY /* 학년도(PK1) */,
                 TA1.SHTM_FG /* 학기구분(PK2) */,
                 TA1.DETA_SHTM_FG /* 세부학기구분(PK3) */,
                 TA1.STUNO /* 학번(PK4) */,
                 (SELECT KOR_NM FROM HURT200 WHERE RPST_PERS_NO = (SELECT RPST_PERS_NO FROM SREG101 WHERE STUNO = TA1.STUNO)) AS STUNM /* 성명 */,
                 ROW_NUMBER() OVER(PARTITION BY TA1.STUNO ORDER BY TA1.UNIVS_KOR_NM, TA1.DEPARTMENT_KOR_NM, TA1.MAJOR_KOR_NM, TA1.STUNO, TA1.SHYR, TA3.PART_SEQ) AS RN,
                 TA1.PROG_CORS_FG /* 진행과정구분 */,
                 (SELECT SF_BSNS011_CODENM(TA1.PROG_CORS_FG, 1) FROM DUAL) AS PROG_CORS_NM /* 진행과정구분명 */,
                 TA1.DEPT_CD /* 부서코드 */,
                 TA1.UNIVS_CD,
                 TA1.UNIVS_KOR_NM,
                 TA1.DEPARTMENT_CD,
                 TA1.DEPARTMENT_KOR_NM,
                 TA1.MAJOR_CD,
                 TA1.MAJOR_KOR_NM,
                 TA1.SHYR /* 학년 */,
                 TA1.PART_YN /* 분납여부 */,
                 TA1.PART_CNT /* 분납횟수 */,
                 TA3.PART_SEQ /* 분납차수 */,
                 TA2.RECIV_ENTR_AMT /* 수납입학금 */,
                 TA2.RECIV_LSN_AMT /* 수납수업료 */,
                 TA2.RECIV_SSO_AMT /* 수납기성회비 */,
                 TA2.RECIV_TT_AMT /* 수납총금액 */,
                 TA3.PART_ENTR_AMT,
                 TA3.PART_LSN_AMT,
                 TA3.PART_SSO_AMT,
                 TA3.PART_TT_AMT,
                 TA3.RECIV_YN /* 수납여부 */,
                 TA3.RECIV_DT /* 수납일자 */,
                 DECODE(TA3.RECIV_YN, 'Y', NVL(TA2.RECIV_TYPE_FG, 'U061200001'), '') AS RECIV_TYPE_FG /* 수납유형구분 */,
                 (SELECT SF_BSNS011_CODENM(DECODE(TA3.RECIV_YN, 'Y', NVL(TA2.RECIV_TYPE_FG, 'U061200001'), ''), 1) FROM DUAL) AS RECIV_TYPE_NM /* 진행과정구분명 */
            FROM (SELECT TB1.SCHYY,
                         TB1.SHTM_FG,
                         TB1.DETA_SHTM_FG,
                         TB1.STUNO,
                         TB1.PROG_CORS_FG,
                         TB1.DEPT_CD,
                         TB1.SHYR,
                         TB1.PART_YN,
                         TB1.PART_CNT,
                         TB2.UNIVS_CD,
                         (SELECT SF_BSNS100_GET_INFO(TB2.UNIVS_CD, 1) FROM DUAL) AS UNIVS_KOR_NM,
                         TB2.DEPARTMENT_CD,
                         (SELECT SF_BSNS100_GET_INFO(TB2.DEPARTMENT_CD, 1) FROM DUAL) AS DEPARTMENT_KOR_NM,
                         TB2.MAJOR_CD,
                         (SELECT SF_BSNS100_GET_INFO(TB2.MAJOR_CD, 1) FROM DUAL) AS MAJOR_KOR_NM
                    FROM ENRO200     TB1,
                         V_COMM111_4 TB2
                   WHERE TB1.DEPT_CD = TB2.DEPT_CD
                     AND TB1.SCHYY = '2019' /* 학년도 */
                     AND TB1.SHTM_FG = 'U000200001' /* 학기구분 */ /* 2018-12-12 박용주 SR1811-12966 분납대상자등록금명부조회 일부휴학 또는 분납취소자 조회 제외처리 S*/ /*                                가사, 질병, 출산, 권고, 군, 창업, 육아, 임신출산 휴학자 제외     */
                     AND TB1.PART_YN = 'Y'
                     AND NOT EXISTS (SELECT STUNO
                            FROM SREG101
                           WHERE STUNO = TB1.STUNO
                             AND SCHREG_MOD_FG IN ('U030300004',
                                                   'U030300005',
                                                   'U030300008',
                                                   'U030300009',
                                                   'U030300014',
                                                   'U030300045',
                                                   'U030300046',
                                                   'U030300047')) /* 2018-12-12 박용주 SR1811-12966 분납대상자등록금명부조회 일부휴학 또는 분납취소자 조회 제외처리 E*/
                  ) TA1,
                 (SELECT SCHYY,
                         SHTM_FG,
                         DETA_SHTM_FG,
                         STUNO,
                         PART_SEQ,
                         RECIV_SEQ,
                         RECIV_ENTR_AMT,
                         RECIV_LSN_AMT,
                         RECIV_SSO_AMT,
                         RECIV_TT_AMT,
                         RECIV_DT,
                         RECIV_TYPE_FG
                    FROM ENRO250
                   WHERE SCHYY = '2019' /* 학년도 */
                     AND SHTM_FG = 'U000200001' /* 학기구분 */
                  ) TA2,
                 (SELECT SCHYY,
                         SHTM_FG,
                         DETA_SHTM_FG,
                         STUNO,
                         PART_SEQ,
                         RECIV_YN,
                         PART_ENTR_AMT,
                         PART_LSN_AMT,
                         PART_SSO_AMT,
                         PART_TT_AMT,
                         RECIV_DT
                    FROM ENRO230
                   WHERE SCHYY = '2019' /* 학년도 */
                     AND SHTM_FG = 'U000200001' /* 학기구분 */
                  ) TA3
           WHERE TA3.SCHYY = TA1.SCHYY(+)
             AND TA3.SHTM_FG = TA1.SHTM_FG(+)
             AND TA3.DETA_SHTM_FG = TA1.DETA_SHTM_FG(+)
             AND TA3.STUNO = TA1.STUNO
             AND TA3.SCHYY = TA2.SCHYY(+)
             AND TA3.SHTM_FG = TA2.SHTM_FG(+)
             AND TA3.DETA_SHTM_FG = TA2.DETA_SHTM_FG(+)
             AND TA3.STUNO = TA2.STUNO(+)
             AND TA3.PART_SEQ = TA2.PART_SEQ(+)
             AND EXISTS (SELECT 1
                    FROM TABLE(PKG_UNI_COMM_DEPT.F_ROLE_DEPT_CD('B111606', 'U060302', 'U000100001')) TB
                   WHERE TB.DEPT_CD = TA1.DEPT_CD)
           ORDER BY TA1.PROG_CORS_FG,
                    TA1.UNIVS_CD,
                    TA1.DEPARTMENT_CD,
                    TA1.MAJOR_CD,
                    TA1.SHYR,
                    TA1.STUNO,
                    TA3.PART_SEQ) T1
