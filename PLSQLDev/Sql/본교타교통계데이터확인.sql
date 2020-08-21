/* ESIN600.find09 본교타교출신 통계 */
SELECT A.APLY_COLG_FG, SF_BSNS011_CODENM(A.APLY_COLG_FG) AS UNIV_NM,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                        1
                       ELSE
                        0
                   END)) AS APLY_CNT11,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                        1
                       ELSE
                        0
                   END)) AS APLY_CNT12,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG != '51480000' THEN
                        1
                       ELSE
                        0
                   END)) AS APLY_CNT13,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                        1
                       ELSE
                        0
                   END + CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                        1
                       ELSE
                        0
                   END + CASE
                       WHEN CHULSIN_SCH_FG != '51480000' THEN
                        1
                       ELSE
                        0
                   END)) AS APLY_TOT,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                            ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                        1
                       ELSE
                        0
                   END)) AS PASS_CNT11,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                            D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                        1
                       ELSE
                        0
                   END)) AS PASS_CNT12,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG != '51480000' AND
                            NVL(C.PASS_DISQ_FG, '-') = 'U024300005' THEN
                        1
                       ELSE
                        0
                   END)) AS PASS_CNT13,
       TO_CHAR(SUM(CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                            ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                        1
                       ELSE
                        0
                   END + CASE
                       WHEN CHULSIN_SCH_FG = '51480000' AND
                            NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                            D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                        1
                       ELSE
                        0
                   END + CASE
                       WHEN CHULSIN_SCH_FG != '51480000' AND
                            NVL(C.PASS_DISQ_FG, '-') = 'U024300005' THEN
                        1
                       ELSE
                        0
                   END)) AS PASS_TOT,
       TO_CHAR(ROUND(SUM(CASE
                             WHEN CHULSIN_SCH_FG = '51480000' AND
                                  ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                              1
                             ELSE
                              0
                         END) / SUM(CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG != '51480000' THEN
                                         1
                                        ELSE
                                         0
                                    END) * 100,
                     1)) || '%' AS APLY_PCNT11,
       TO_CHAR(ROUND(SUM(CASE
                             WHEN CHULSIN_SCH_FG = '51480000' AND
                                  D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                              1
                             ELSE
                              0
                         END) / SUM(CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG != '51480000' THEN
                                         1
                                        ELSE
                                         0
                                    END) * 100,
                     1)) || '%' AS APLY_PCNT12,
       TO_CHAR(ROUND(SUM(CASE
                             WHEN CHULSIN_SCH_FG != '51480000' THEN
                              1
                             ELSE
                              0
                         END) / SUM(CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG != '51480000' THEN
                                         1
                                        ELSE
                                         0
                                    END) * 100,
                     1)) || '%' AS APLY_PCNT13,
       '100.0%' AS APLY_PTOT,
       TO_CHAR(ROUND(SUM(CASE
                             WHEN CHULSIN_SCH_FG = '51480000' AND
                                  NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                  ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                              1
                             ELSE
                              0
                         END) / SUM(CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                             ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                             D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG != '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' THEN
                                         1
                                        ELSE
                                         0
                                    END) * 100,
                     1)) || '%' AS PASS_PCNT11,
       TO_CHAR(ROUND(SUM(CASE
                             WHEN CHULSIN_SCH_FG = '51480000' AND
                                  NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                  D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                              1
                             ELSE
                              0
                         END) / SUM(CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                             ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                             D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG != '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' THEN
                                         1
                                        ELSE
                                         0
                                    END) * 100,
                     1)) || '%' AS PASS_PCNT12,
       TO_CHAR(ROUND(SUM(CASE
                             WHEN CHULSIN_SCH_FG != '51480000' AND
                                  NVL(C.PASS_DISQ_FG, '-') = 'U024300005' THEN
                              1
                             ELSE
                              0
                         END) / SUM(CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                             ltrim(rtrim(D.DEPT_KOR_NM)) = ltrim(rtrim(CHULSIN_SUST_NM)) THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG = '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' AND
                                             D.DEPT_KOR_NM != CHULSIN_SUST_NM THEN
                                         1
                                        ELSE
                                         0
                                    END + CASE
                                        WHEN CHULSIN_SCH_FG != '51480000' AND
                                             NVL(C.PASS_DISQ_FG, '-') = 'U024300005' THEN
                                         1
                                        ELSE
                                         0
                                    END) * 100,
                     1)) || '%' AS PASS_PCNT13,
       '100.0%' AS PASS_PTOT
  FROM ESIN600 A,
       (SELECT COLL_UNIT_NO,
               EXAM_NO,
               CHULSIN_SCH_FG,
               SUBSTR(LTRIM(RTRIM(REPLACE(SF_BSNS011_CODENM(CHULSIN_SUST_FG),
                                          ' ',
                                          ''))),
                      1,
                      2) AS CHULSIN_SUST_NM
          FROM ESIN602
         WHERE NVL(FL_SCHCR_YN, 'N') = 'Y') B,
       (SELECT COLL_UNIT_NO,
               EXAM_NO,
               PASS_DISQ_FG
          FROM ESIN606
         WHERE SCRN_STG_FG IN ('U027200002', 'U027200003')
         /*
        UNION
        SELECT COLL_UNIT_NO,
               EXAM_NO,
               PASS_DISQ_FG
          FROM ESIN606
         WHERE SCRN_STG_FG = 'U027200001'
           AND PASS_DISQ_FG = 'U024300005'   */   ) C,
       (SELECT DEPT_CD,
               SUBSTR(LTRIM(RTRIM(REPLACE((DEPARTMENT_KOR_NM), ' ', ''))), 1, 2) AS DEPT_KOR_NM
          FROM V_COMM111_6
         WHERE NVL(USE_YN, 'N') = 'Y') D,
       ESIN520 Z
 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
   AND A.EXAM_NO = B.EXAM_NO
   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO(+)
   AND A.EXAM_NO = C.EXAM_NO(+)
   
   AND A.APLY_COLL_UNIT_CD = D.DEPT_CD (+)
   
   AND A.COLL_UNIT_NO = Z.COLL_UNIT_NO
   AND A.SELECT_YY = Z.SELECT_YY
   AND A.SELECT_FG = Z.SELECT_FG
   AND A.COLL_FG = Z.COLL_FG
   AND A.APLY_QUAL_FG = Z.APLY_QUAL_FG
   AND A.DETA_APLY_QUAL_FG = Z.DETA_APLY_QUAL_FG
   AND A.APLY_CORS_FG = Z.APLY_CORS_FG
   AND A.APLY_COLG_FG = Z.APLY_COLG_FG
   AND A.APLY_COLL_UNIT_CD = Z.APLY_COLL_UNIT_CD
   AND A.SELECT_YY = '2020'
   AND A.SELECT_FG = 'U025700001'
   AND A.COLL_FG = 'U025800002'
   --AND A.APLY_COLG_FG = 'U026200020'
   AND A.aply_Cors_Fg = 'U024400002'
   AND NVL(Z.WCU_YN, 'N') = 'N'
 GROUP BY A.APLY_COLG_FG
 --ORDER BY A.APLY_COLG_FG
;

SELECT A.APLY_COLG_FG, B.*, D.DEPT_KOR_NM, NVL(C.PASS_DISQ_FG, '-')
  FROM ESIN600 A,
       (SELECT COLL_UNIT_NO,
               EXAM_NO,
               CHULSIN_SCH_FG,
               FL_SCHCR_YN,
               SUBSTR(LTRIM(RTRIM(REPLACE(CHULSIN_SUST_NM,
                                          ' ',
                                          ''))),
                      1,
                      2) AS CHULSIN_SUST_NM
          FROM ESIN602
         WHERE NVL(FL_SCHCR_YN, 'N') = 'Y') B,
       (SELECT COLL_UNIT_NO,
               EXAM_NO,
               PASS_DISQ_FG
          FROM ESIN606
         WHERE SCRN_STG_FG IN ('U027200002', 'U027200003')
      ) C,
       (SELECT DEPT_CD,
               SUBSTR(LTRIM(RTRIM(REPLACE((DEPARTMENT_KOR_NM), ' ', ''))), 1, 2) AS DEPT_KOR_NM
               --SUBSTR(LTRIM(RTRIM(REPLACE((DEPT_KOR_NM), ' ', ''))), 1, 2) AS DEPT_KOR_NM
          FROM V_COMM111_6
         WHERE NVL(USE_YN, 'N') = 'Y') D,
       ESIN520 Z
 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
   AND A.EXAM_NO = B.EXAM_NO
   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO(+)
   AND A.EXAM_NO = C.EXAM_NO(+)
   
   AND A.APLY_COLL_UNIT_CD = D.DEPT_CD(+)
   
   AND A.COLL_UNIT_NO = Z.COLL_UNIT_NO
   AND A.SELECT_YY = Z.SELECT_YY
   AND A.SELECT_FG = Z.SELECT_FG
   AND A.COLL_FG = Z.COLL_FG
   AND A.APLY_QUAL_FG = Z.APLY_QUAL_FG
   AND A.DETA_APLY_QUAL_FG = Z.DETA_APLY_QUAL_FG
   AND A.APLY_CORS_FG = Z.APLY_CORS_FG
   AND A.APLY_COLG_FG = Z.APLY_COLG_FG
   AND A.APLY_COLL_UNIT_CD = Z.APLY_COLL_UNIT_CD
   AND A.SELECT_YY = '2020'
   AND A.SELECT_FG = 'U025700001'
   
   AND A.COLL_FG = 'U025800002'                             
   --AND A.APLY_COLG_FG = 'U026200006'
   AND A.aply_Cors_Fg = 'U024400002'
   
   AND NVL(Z.WCU_YN, 'N') = 'N'
   
   AND B.CHULSIN_SCH_FG = '51480000'
   AND CHULSIN_SUST_NM != DEPT_KOR_NM
   
-- GROUP BY A.APLY_COLG_FG
 ORDER BY A.APLY_COLG_FG
 ;
 
--에너지자원공학과

select CHULSIN_SUST_NM, a.* from ESIN602 a
where exam_no = '16021'
AND FL_SCHCR_YN = 'Y'
;

SELECT COLL_UNIT_NO,
       EXAM_NO,
       CHULSIN_SCH_FG,
       FL_SCHCR_YN,
       SUBSTR(LTRIM(RTRIM(REPLACE(SF_BSNS011_CODENM(CHULSIN_SUST_FG),
                                  ' ',
                                  ''))),
              1,
              2) AS CHULSIN_SUST_NM
  FROM ESIN602
 WHERE NVL(FL_SCHCR_YN, 'N') = 'Y'
 AND exam_no = '16021' ;

SELECT DEPT_CD,
               SUBSTR(LTRIM(RTRIM(REPLACE((DEPARTMENT_KOR_NM), ' ', ''))), 1, 2) AS DEPARTMENT_KOR_NM,
               SUBSTR(LTRIM(RTRIM(REPLACE((DEPT_KOR_NM), ' ', ''))), 1, 2) AS DEPT_KOR_NM
          FROM V_COMM111_6
         WHERE NVL(USE_YN, 'N') = 'Y'
