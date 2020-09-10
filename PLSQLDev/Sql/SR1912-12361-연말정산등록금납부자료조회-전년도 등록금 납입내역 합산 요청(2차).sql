SELECT * FROM HURT200 WHERE rpst_pers_no = '2019-21811' ;
SELECT * FROM SREG101 WHERE stuno = '2019-21811' ;
SELECT * FROM SREG101 WHERE rpst_pers_no = '2019-21811' ;
SELECT * FROM ENRO400 WHERE stuno = '2019-21811' ;
SELECT * FROM ENRO400 WHERE rpst_pers_no = '2019-21811' ;


/* ENRO250.find09 연말정산등록금납부자료조회        (2014.01.22 수정) 조회항목 : 주민등록번호, 성명, 1~12월 (group by 주민등록번호) */
WITH V_YEON AS
 (SELECT (SELECT RES_NO FROM HURT200 WHERE RPST_PERS_NO = T1.RPST_PERS_NO) AS RES_NO,
                 T1.STUNO, T1.RPST_PERS_NO, T1.MJ_CD, T1.SUST_CD, T1.COLG_CD,
                 (SELECT KOR_NM FROM HURT200 WHERE RPST_PERS_NO = T1.RPST_PERS_NO) AS STUNM,
                 NVL(T3.SUM01, 0) - NVL(T4.SUM01, 0) + NVL(T5.SUM01, 0) - NVL(T6.SUM01, 0) - NVL(T7.SUM01, 0) AS SUM01,
                 NVL(T3.SUM02, 0) - NVL(T4.SUM02, 0) + NVL(T5.SUM02, 0) - NVL(T6.SUM02, 0) - NVL(T7.SUM02, 0) AS SUM02,
                 NVL(T3.SUM03, 0) - NVL(T4.SUM03, 0) + NVL(T5.SUM03, 0) - NVL(T6.SUM03, 0) - NVL(T7.SUM03, 0) AS SUM03,
                 NVL(T3.SUM04, 0) - NVL(T4.SUM04, 0) + NVL(T5.SUM04, 0) - NVL(T6.SUM04, 0) - NVL(T7.SUM04, 0) AS SUM04,
                 NVL(T3.SUM05, 0) - NVL(T4.SUM05, 0) + NVL(T5.SUM05, 0) - NVL(T6.SUM05, 0) - NVL(T7.SUM05, 0) AS SUM05,
                 NVL(T3.SUM06, 0) - NVL(T4.SUM06, 0) + NVL(T5.SUM06, 0) - NVL(T6.SUM06, 0) - NVL(T7.SUM06, 0) AS SUM06,
                 NVL(T3.SUM07, 0) - NVL(T4.SUM07, 0) + NVL(T5.SUM07, 0) - NVL(T6.SUM07, 0) - NVL(T7.SUM07, 0) AS SUM07,
                 NVL(T3.SUM08, 0) - NVL(T4.SUM08, 0) + NVL(T5.SUM08, 0) - NVL(T6.SUM08, 0) - NVL(T7.SUM08, 0) AS SUM08,
                 NVL(T3.SUM09, 0) - NVL(T4.SUM09, 0) + NVL(T5.SUM09, 0) - NVL(T6.SUM09, 0) - NVL(T7.SUM09, 0) AS SUM09,
                 NVL(T3.SUM10, 0) - NVL(T4.SUM10, 0) + NVL(T5.SUM10, 0) - NVL(T6.SUM10, 0) - NVL(T7.SUM10, 0) AS SUM10,
                 NVL(T3.SUM11, 0) - NVL(T4.SUM11, 0) + NVL(T5.SUM11, 0) - NVL(T6.SUM11, 0) - NVL(T7.SUM11, 0) AS SUM11,
                 NVL(T3.SUM12, 0) - NVL(T4.SUM12, 0) + NVL(T5.SUM12, 0) - NVL(T6.SUM12, 0) - NVL(T7.SUM12, 0) AS SUM12,
                 NVL(T3.SUM01, 0) - NVL(T4.SUM01, 0) + NVL(T5.SUM01, 0) - NVL(T6.SUM01, 0) - NVL(T7.SUM01, 0) + NVL(T3.SUM02, 0) -
                 NVL(T4.SUM02, 0) + NVL(T5.SUM02, 0) - NVL(T6.SUM02, 0) - NVL(T7.SUM02, 0) + NVL(T3.SUM03, 0) - NVL(T4.SUM03, 0) +
                 NVL(T5.SUM03, 0) - NVL(T6.SUM03, 0) - NVL(T7.SUM03, 0) + NVL(T3.SUM04, 0) - NVL(T4.SUM04, 0) + NVL(T5.SUM04, 0) -
                 NVL(T6.SUM04, 0) - NVL(T7.SUM04, 0) + NVL(T3.SUM05, 0) - NVL(T4.SUM05, 0) + NVL(T5.SUM05, 0) - NVL(T6.SUM05, 0) -
                 NVL(T7.SUM05, 0) + NVL(T3.SUM06, 0) - NVL(T4.SUM06, 0) + NVL(T5.SUM06, 0) - NVL(T6.SUM06, 0) - NVL(T7.SUM06, 0) +
                 NVL(T3.SUM07, 0) - NVL(T4.SUM07, 0) + NVL(T5.SUM07, 0) - NVL(T6.SUM07, 0) - NVL(T7.SUM07, 0) + NVL(T3.SUM08, 0) -
                 NVL(T4.SUM08, 0) + NVL(T5.SUM08, 0) - NVL(T6.SUM08, 0) - NVL(T7.SUM08, 0) + NVL(T3.SUM09, 0) - NVL(T4.SUM09, 0) +
                 NVL(T5.SUM09, 0) - NVL(T6.SUM09, 0) - NVL(T7.SUM09, 0) + NVL(T3.SUM10, 0) - NVL(T4.SUM10, 0) + NVL(T5.SUM10, 0) -
                 NVL(T6.SUM10, 0) - NVL(T7.SUM10, 0) + NVL(T3.SUM11, 0) - NVL(T4.SUM11, 0) + NVL(T5.SUM11, 0) - NVL(T6.SUM11, 0) -
                 NVL(T7.SUM11, 0) + NVL(T3.SUM12, 0) - NVL(T4.SUM12, 0) + NVL(T5.SUM12, 0) - NVL(T6.SUM12, 0) - NVL(T7.SUM12, 0) AS SUM_ALL
            FROM SREG101 T1,

         (SELECT DISTINCT STUNO FROM ENRO200 WHERE SUBSTR(RECIV_DT, 1, 4) = '2019') T2,

         /* 2019-12-17 박용주 SR1905-05039 S */
         /* 1. 등록금 : 해당 귀속년도에 수납또는 환불 금액만 조회 (귀속연도기준으로 수납일자처리) */
         /*             전년도 12월 금액이 다음해 귀속년도이면 01월 OR 02월 금액이 존재하는 월에 합산처리  */
         ( SELECT TA1.STUNO,
                  CASE
                      /* 2020-08-24 박용주 SR1912-12361  S */
                      /* 학부,대학원 구분에서 대학원 일 경우 치의학전문대학원 석사과정(당해년도 신입생) 의 경우만 당해연도 1월에 12월의 금액 합산처리 */
                      WHEN 'U030600002' = 'U030600002' AND ( SELECT NVL(A.SUST_CD,'-') FROM SREG101 A, ENRO400 B
                                                             WHERE A.STUNO = B.STUNO AND B.ENTR_SCHYY = '2019'
                                                             AND A.STUNO = TA1.STUNO ) = '861'  THEN
                       NVL(SUM(TA1.SUM01), 0) + NVL((SELECT SUM(B.RECIV_TT_AMT)
                                                      FROM SREG101 A,
                                                           ENRO250 B,
                                                           ENRO400 C
                                                     WHERE A.STUNO = B.STUNO
                                                       AND A.STUNO = C.STUNO
                                                       AND A.STUNO = TA1.STUNO
                                                       AND B.SCHYY = C.ENTR_SCHYY
                                                       AND B.SCHYY = '2019'
                                                       AND A.SUST_CD = '861'
                                                       AND SUBSTR(B.RECIV_DT, 1, 6) = TO_CHAR(TO_NUMBER('2019') - 1) || '12'
                                                       ),
                                                    0)
                      WHEN 'U030600002' = 'U030600002' AND ( SELECT NVL(A.SUST_CD,'-') FROM SREG101 A, ENRO400 B
                                                             WHERE A.STUNO = B.STUNO AND B.ENTR_SCHYY = '2019'
                                                             AND A.STUNO = TA1.STUNO ) != '861'  THEN
                       NVL(SUM(TA1.SUM01), 0) + NVL((SELECT SUM(RECIV_TT_AMT) 
                                                      FROM ENRO250
                                                     WHERE STUNO = TA1.STUNO
                                                       AND SCHYY = '2019'
                                                       AND SUBSTR(RECIV_DT, 1, 6) = TO_CHAR(TO_NUMBER('2019') - 1) || '12'
                                                       AND ABS(RECIV_TT_AMT) = (SELECT NVL(REG_RESV_AMT, 0)
                                                                                  FROM ENRO100   A,
                                                                                       V_SREG101 B
                                                                                 WHERE A.SCHYY = TO_CHAR(TO_NUMBER('2019'))
                                                                                   AND A.SHTM_FG = 'U000200001'
                                                                                   AND A.DETA_SHTM_FG = 'U000300001'
                                                                                   AND A.CORS_FG = B.ENTR_CORS_FG /* 입학과정, PROG_CORS_FG 진행과정  */
                                                                                   AND A.DEPT_CD = B.DEPT_CD
                                                                                   AND A.SHYR = B.SHYR
                                                                                   AND A.DAYNGT_FG = B.DAYNGT_FG
                                                                                   AND B.STUNO = TA1.STUNO)
                                                       ),
                                                    0)
                      /* 2020-08-24 박용주 SR1912-12361  E */

                      WHEN NVL(SUM(TA1.SUM01), 0) > 0 AND 'U030600002' = 'U030600001' THEN
                       NVL(SUM(TA1.SUM01), 0) + NVL((SELECT SUM(RECIV_TT_AMT)
                                                      FROM ENRO250
                                                     WHERE STUNO = TA1.STUNO
                                                       AND SCHYY = '2019'
                                                       AND SUBSTR(RECIV_DT, 1, 6) = TO_CHAR(TO_NUMBER('2019') - 1) || '12'
                                                       AND ABS(RECIV_TT_AMT) = (SELECT NVL(REG_RESV_AMT, 0)
                                                                                  FROM ENRO100   A,
                                                                                       V_SREG101 B
                                                                                 WHERE A.SCHYY = TO_CHAR(TO_NUMBER('2019'))
                                                                                   AND A.SHTM_FG = 'U000200001'
                                                                                   AND A.DETA_SHTM_FG = 'U000300001'
                                                                                   AND A.CORS_FG = B.ENTR_CORS_FG /* 입학과정, PROG_CORS_FG 진행과정  */
                                                                                   AND A.DEPT_CD = B.DEPT_CD
                                                                                   AND A.SHYR = B.SHYR
                                                                                   AND A.DAYNGT_FG = B.DAYNGT_FG
                                                                                   AND B.STUNO = TA1.STUNO)),
                                                    0)
                      ELSE
                       NVL(SUM(TA1.SUM01), 0)
                  END AS SUM01,
                  CASE
                      WHEN NVL(SUM(TA1.SUM02), 0) > 0 THEN
                       NVL(SUM(TA1.SUM02), 0) + NVL((SELECT SUM(RECIV_TT_AMT)
                                                      FROM ENRO250
                                                     WHERE STUNO = TA1.STUNO
                                                       AND SCHYY = '2019'
                                                       AND SUBSTR(RECIV_DT, 1, 6) = TO_CHAR(TO_NUMBER('2019') - 1) || '12'
                                                       AND ABS(RECIV_TT_AMT) = (SELECT NVL(REG_RESV_AMT, 0)
                                                                                  FROM ENRO100   A,
                                                                                       V_SREG101 B
                                                                                 WHERE A.SCHYY = TO_CHAR(TO_NUMBER('2019'))
                                                                                   AND A.SHTM_FG = 'U000200001'
                                                                                   AND A.DETA_SHTM_FG = 'U000300001'
                                                                                   AND A.CORS_FG = B.ENTR_CORS_FG /* 입학과정, PROG_CORS_FG 진행과정  */
                                                                                   AND A.DEPT_CD = B.DEPT_CD
                                                                                   AND A.SHYR = B.SHYR
                                                                                   AND A.DAYNGT_FG = B.DAYNGT_FG
                                                                                   AND B.STUNO = TA1.STUNO)),
                                                    0)
                      ELSE
                       NVL(SUM(TA1.SUM02), 0)
                  END AS SUM02,
                  NVL(SUM(TA1.SUM03), 0) AS SUM03,
                  NVL(SUM(TA1.SUM04), 0) AS SUM04,
                  NVL(SUM(TA1.SUM05), 0) AS SUM05,
                  NVL(SUM(TA1.SUM06), 0) AS SUM06,
                  NVL(SUM(TA1.SUM07), 0) AS SUM07,
                  NVL(SUM(TA1.SUM08), 0) AS SUM08,
                  NVL(SUM(TA1.SUM09), 0) AS SUM09,
                  NVL(SUM(TA1.SUM10), 0) AS SUM10,
                  NVL(SUM(TA1.SUM11), 0) AS SUM11,
                  NVL(SUM(TA1.SUM12), 0) AS SUM12
            FROM (SELECT TB1.STUNO,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '01' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM01,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '02' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM02,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '03' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM03,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '04' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM04,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '05' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM05,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '06' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM06,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '07' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM07,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '08' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM08,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '09' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM09,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '10' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM10,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '11' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM11,
                          CASE WHEN SUBSTR(TB1.RECIV_DT, 5, 2) = '12' THEN SUM(TB1.RECIV_TT_AMT) ELSE 0 END AS SUM12
                     FROM ENRO250 TB1
                    WHERE SUBSTR(TB1.RECIV_DT, 1, 4) = '2019'
                    GROUP BY TB1.STUNO,
                             TB1.SHTM_FG,
                             TB1.DETA_SHTM_FG,
                             TB1.RECIV_DT,
                             TB1.SCHYY) TA1
           GROUP BY TA1.STUNO
           ORDER BY TA1.STUNO
          ) T3,
         /* 2019-12-17 박용주 SR1905-05039 E */


         (SELECT TC1.STUNO,
                 SUM(TC1.SUM01) AS SUM01,
                 SUM(TC1.SUM02) AS SUM02,
                 SUM(TC1.SUM03) AS SUM03,
                 SUM(TC1.SUM04) AS SUM04,
                 SUM(TC1.SUM05) AS SUM05,
                 SUM(TC1.SUM06) AS SUM06,
                 SUM(TC1.SUM07) AS SUM07,
                 SUM(TC1.SUM08) AS SUM08,
                 SUM(TC1.SUM09) AS SUM09,
                 SUM(TC1.SUM10) AS SUM10,
                 SUM(TC1.SUM11) AS SUM11,
                 SUM(TC1.SUM12) AS SUM12
            FROM (SELECT TD1.STUNO,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '01', SUM(TD1.REPAY_TT_AMT), 0) AS SUM01,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '02', SUM(TD1.REPAY_TT_AMT), 0) AS SUM02,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '03', SUM(TD1.REPAY_TT_AMT), 0) AS SUM03,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '04', SUM(TD1.REPAY_TT_AMT), 0) AS SUM04,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '05', SUM(TD1.REPAY_TT_AMT), 0) AS SUM05,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '06', SUM(TD1.REPAY_TT_AMT), 0) AS SUM06,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '07', SUM(TD1.REPAY_TT_AMT), 0) AS SUM07,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '08', SUM(TD1.REPAY_TT_AMT), 0) AS SUM08,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '09', SUM(TD1.REPAY_TT_AMT), 0) AS SUM09,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '10', SUM(TD1.REPAY_TT_AMT), 0) AS SUM10,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '11', SUM(TD1.REPAY_TT_AMT), 0) AS SUM11,
                         DECODE(SUBSTR(TD1.REPAY_DT, 5, 2), '12', SUM(TD1.REPAY_TT_AMT), 0) AS SUM12
                    FROM ENRO260 TD1
                   WHERE SUBSTR(TD1.REPAY_DT, 1, 4) = '2019'
                   GROUP BY TD1.STUNO,
                            TD1.REPAY_DT) TC1
           GROUP BY TC1.STUNO
           ORDER BY TC1.STUNO) T4 /* 2. 계절학기 : 해당 귀속년도에 해당되는 개설 금액만 조회(수납일자가 아닌 개설기준) */,
         (SELECT TE1.STUNO,
                 SUM(TE1.SUM01) AS SUM01,
                 SUM(TE1.SUM02) AS SUM02,
                 SUM(TE1.SUM03) AS SUM03,
                 SUM(TE1.SUM04) AS SUM04,
                 SUM(TE1.SUM05) AS SUM05,
                 SUM(TE1.SUM06) AS SUM06,
                 SUM(TE1.SUM07) AS SUM07,
                 SUM(TE1.SUM08) AS SUM08,
                 SUM(TE1.SUM09) AS SUM09,
                 SUM(TE1.SUM10) AS SUM10,
                 SUM(TE1.SUM11) AS SUM11,
                 SUM(TE1.SUM12) AS SUM12
            FROM (SELECT TF1.STUNO,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '01', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM01,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '02', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM02,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '03', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM03,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '04', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM04,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '05', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM05,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '06', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM06,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '07', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM07,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '08', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM08,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '09', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM09,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '10', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM10,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '11', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM11,
                         DECODE(SUBSTR(MIN(TF1.SHTMSW_TUIT_RECIV_DT), 5, 2), '12', SUM(TF1.SHTMSW_TUIT_RECIV_AMT), 0) AS SUM12
                    FROM ENRO520 TF1
                   WHERE SUBSTR(TF1.SHTMSW_TUIT_RECIV_DT, 1, 4) = '2019'
                   GROUP BY TF1.STUNO,
                            TF1.OPEN_SCHYY,
                            TF1.OPEN_SHTM_FG) TE1
           GROUP BY TE1.STUNO
           ORDER BY TE1.STUNO) T5 /* 3. 추가장학금은 포함시키지 않음*/ /* 2014.12.31 교외장학은 제외(김나현) */ /* 2016.01.06 추가장학금 포함시킴(T1505060069 관련) - 납부확인서내용과 동일(입학금, 수업료, 기성회비) */ /* 2016.01.22 등록금 납부확인서와 동일하게(귀속년도에 등록수납일 기준(등록년도 기준)) */,
         (SELECT TC1.STUNO,
                 SUM(TC1.SUM01) AS SUM01,
                 SUM(TC1.SUM02) AS SUM02,
                 SUM(TC1.SUM03) AS SUM03,
                 SUM(TC1.SUM04) AS SUM04,
                 SUM(TC1.SUM05) AS SUM05,
                 SUM(TC1.SUM06) AS SUM06,
                 SUM(TC1.SUM07) AS SUM07,
                 SUM(TC1.SUM08) AS SUM08,
                 SUM(TC1.SUM09) AS SUM09,
                 SUM(TC1.SUM10) AS SUM10,
                 SUM(TC1.SUM11) AS SUM11,
                 SUM(TC1.SUM12) AS SUM12
            FROM (SELECT TB1.STUNO,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '01', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM01,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '02', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM02,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '03', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM03,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '04', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM04,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '05', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM05,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '06', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM06,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '07', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM07,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '08', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM08,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '09', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM09,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '10', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM10,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '11', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM11,
                         DECODE(SUBSTR(TA1.RECIV_DT, 5, 2), '12', SUM(TB1.ENTR_AMT + TB1.LSN_AMT + TB1.SSO_AMT), 0) AS SUM12
                    FROM ENRO200 TA1,
                         SCHO500 TB1
                   WHERE TA1.SCHYY = TB1.SCHYY(+)
                     AND TA1.STUNO = TB1.STUNO(+)
                     AND TA1.SHTM_FG = TB1.SHTM_FG(+)
                     AND TA1.DETA_SHTM_FG = TB1.DETA_SHTM_FG(+)
                     AND TA1.STUNO = TB1.STUNO(+)
                     AND TA1.DEPT_CD NOT IN (SELECT DEPT_CD FROM COMM101 WHERE CNTR_SUST_YN = 'Y')
                     AND TB1.SCHEXP_REDC_YN = 'N'
                     AND TB1.SCAL_SLT_PROG_ST_FG = 'U073300004'
                     AND NOT EXISTS (SELECT 1
                            FROM ENRO201
                           WHERE SCHYY = TB1.SCHYY
                             AND SHTM_FG = TB1.SHTM_FG
                             AND DETA_SHTM_FG = TB1.DETA_SHTM_FG
                             AND STUNO = TB1.STUNO
                             AND SCAL_CD = TB1.SCAL_CD)
                     AND SUBSTR(TA1.RECIV_DT, 1, 4) = '2019'
                   GROUP BY TB1.STUNO,
                            TA1.RECIV_DT) TC1
           GROUP BY TC1.STUNO
           ORDER BY TC1.STUNO) T6 /* 추가장학금 */,
         (SELECT TA1.STUNO,
                 SUM(TA1.SUM01) AS SUM01,
                 SUM(TA1.SUM02) AS SUM02,
                 SUM(TA1.SUM03) AS SUM03,
                 SUM(TA1.SUM04) AS SUM04,
                 SUM(TA1.SUM05) AS SUM05,
                 SUM(TA1.SUM06) AS SUM06,
                 SUM(TA1.SUM07) AS SUM07,
                 SUM(TA1.SUM08) AS SUM08,
                 SUM(TA1.SUM09) AS SUM09,
                 SUM(TA1.SUM10) AS SUM10,
                 SUM(TA1.SUM11) AS SUM11,
                 SUM(TA1.SUM12) AS SUM12
            FROM (SELECT TB1.STUNO,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '01', SUM(TB1.LOAN_AMT), 0) AS SUM01,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '02', SUM(TB1.LOAN_AMT), 0) AS SUM02,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '03', SUM(TB1.LOAN_AMT), 0) AS SUM03,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '04', SUM(TB1.LOAN_AMT), 0) AS SUM04,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '05', SUM(TB1.LOAN_AMT), 0) AS SUM05,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '06', SUM(TB1.LOAN_AMT), 0) AS SUM06,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '07', SUM(TB1.LOAN_AMT), 0) AS SUM07,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '08', SUM(TB1.LOAN_AMT), 0) AS SUM08,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '09', SUM(TB1.LOAN_AMT), 0) AS SUM09,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '10', SUM(TB1.LOAN_AMT), 0) AS SUM10,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '11', SUM(TB1.LOAN_AMT), 0) AS SUM11,
                         DECODE(SUBSTR(TB1.LOAN_RUN_DT, 5, 2), '12', SUM(TB1.LOAN_AMT), 0) AS SUM12
                    FROM SCHO850 TB1
                   WHERE SUBSTR(TB1.LOAN_RUN_DT, 1, 4) = '2019'
                   GROUP BY TB1.STUNO,
                            TB1.LOAN_RUN_DT) TA1
           GROUP BY TA1.STUNO
           ORDER BY TA1.STUNO) T7 /* 학자금대출 */
   WHERE T1.STUNO = T2.STUNO
     AND T1.STUNO = T3.STUNO(+)
     AND T1.STUNO = T4.STUNO(+)
     AND T1.STUNO = T5.STUNO(+) 
     AND T1.STUNO = T6.STUNO(+)
     AND T1.STUNO = T7.STUNO(+)

     AND T1.COLG_GRSC_FG = 'U030600002')               /*  학부,대학원    */

/* 조회항목 : 주민등록번호, 성명, 1~12월 (group by 주민등록번호) */
SELECT STUNO,
       RPST_PERS_NO,
       RES_NO,
       STUNM,
       SF_BSNS100_GET_INFO(MAX(COLG_CD), 1) AS "CONM",
       SF_BSNS100_GET_INFO(MAX(SUST_CD), 1) AS "SUNM",
       SF_BSNS100_GET_INFO(MAX(MJ_CD), 1) AS "MJNM",
       MAX(COLG_CD) AS "CO",
       MAX(SUST_CD) AS "SU",
       MAX(MJ_CD) AS "MJ",
       (SELECT HAND_TELNO FROM HURT200 WHERE RPST_PERS_NO = V_YEON.RPST_PERS_NO) AS "STEL",
       (SELECT DECODE(NVL(EMAIL, 'N'), 'N', EMAIL_2, EMAIL) FROM HURT200 WHERE RPST_PERS_NO = V_YEON.RPST_PERS_NO) AS "EMAIL",
       SUM(SUM01) AS SUM01,
       SUM(SUM02) AS SUM02,
       SUM(SUM03) AS SUM03,
       SUM(SUM04) AS SUM04,
       SUM(SUM05) AS SUM05,
       SUM(SUM06) AS SUM06,
       SUM(SUM07) AS SUM07,
       SUM(SUM08) AS SUM08,
       SUM(SUM09) AS SUM09,
       SUM(SUM10) AS SUM10,
       SUM(SUM11) AS SUM11,
       SUM(SUM12) AS SUM12,
       SUM(SUM_ALL) AS SUM_ALL
  FROM V_YEON
  WHERE SUST_CD = '861'
  AND stuno = '2019-21811'
HAVING SUM (SUM_ALL) > 0  
 GROUP BY STUNO,
          RPST_PERS_NO,
          RES_NO,
          STUNM
;




SELECT * FROM enro250 WHERE stuno = '2019-21811' ;

SELECT * FROM enro100 ;
SELECT * FROM enro400 ;

SELECT * FROM enro300 ;

