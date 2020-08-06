/* ESIN603 find02 전형요소별 성적관리 - 영어지원자격 조회 */
SELECT T1.COLL_UNIT_NO,
       T1.SELECT_YY,
       T1.COLL_FG,
       T1.APLY_QUAL_FG,
       T1.DETA_APLY_QUAL_FG,
       SF_BSNS011_CODENM(T1.APLY_QUAL_FG, 1) AS APLY_QUAL_FG_NM,
       SF_BSNS011_CODENM(T1.DETA_APLY_QUAL_FG, 1) AS DETA_APLY_QUAL_FG_NM,
       T1.APLY_CORS_FG,
       T1.APLY_COLG_FG,
       T1.APLY_COLL_UNIT_CD,
       DECODE(C1.DEPT_TYPE,
              'D',
              C1.DEPT_KOR_NM,
              'M',
              C1.DEPARTMENT_KOR_NM || ' > ' || C1.DEPT_KOR_NM) AS APLY_COLL_UNIT_CD_NM,
       T3.EXAM_NO,
       T2.APLIER_KOR_NM,
       T3.FRN_LANG_VLD_EXAM_FG,
       T3.VLD_EXAM_PERF_DT,
       T3.VLD_EXAM_ACQ_SCOR,
       T4.NEW_TEPS_EXCH_SCOR,
       T4.EXCH_SCOR,
       T4.FL_DISQ_FG,
       T4.FL_SCOR,
       (SELECT SELECT_ELEMNT_FMAK_SCOR
          FROM ESIN521 A
         WHERE T1.COLL_UNIT_NO = A.COLL_UNIT_NO
           AND NVL(A.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
           AND A.SELECT_ELEMNT_FG = 'U027100009'
           AND A.ADPT_STG_FG = 'U027200001') AS FMAK_SCOR,       
       T1.SELECT_FG,
       NVL2(T4.SCRN_STG_FG, T4.SCRN_STG_FG, 'U027200001') AS SCRN_STG_FG,
       'U027100009' AS SELECT_ELEMNT_FG,
       CASE
           WHEN 'U027200001' = 'U027200001' THEN
            NVL2(T1.STG1_GENRL_SELECT_CHG_YN,
                 T1.STG1_GENRL_SELECT_CHG_YN,
                 'N')
           WHEN 'U027200001' = 'U027200002' THEN
            NVL2(T1.STG2_GENRL_SELECT_CHG_YN,
                 T1.STG2_GENRL_SELECT_CHG_YN,
                 'N')
           ELSE
            'N'
       END AS GENRL_SELECT_CHG_YN,
       T3.APLIER_INPT_SCOR,
       T1.MNGT_NO,
       T5.ENG_FLD_COLG_YN,
       T5.LRN_COUN_FG,
       T5.CHULSIN_SCH_NM,
       T3.ENG_EXMP_YN,
       T3.APLIER_INPT_DT,
       SF_BSNS011_CODENM(T1.SELECT_FG, 1) AS SELECT_FG_NM,
       SF_BSNS011_CODENM(T1.COLL_FG, 1) AS COLL_FG_NM,
       SF_BSNS011_CODENM(T1.APLY_CORS_FG, 1) AS APLY_CORS_FG_NM,
       SF_BSNS011_CODENM(T1.APLY_COLG_FG, 1) AS APLY_COLG_FG_NM,
       SF_BSNS011_CODENM(T3.FRN_LANG_VLD_EXAM_FG, '1') AS FRN_LANG_VLD_EXAM_FG_NM,
       SF_BSNS011_CODENM(T4.FL_DISQ_FG, '1') AS FL_DISQ_FG_NM,
       SF_BSNS011_CODENM(T5.LRN_COUN_FG, '1') AS LRN_COUN_FG_NM
  FROM V_ESIN600 T1
 INNER JOIN ESIN601 T2
    ON T1.REAL_COLL_UNIT_NO = T2.COLL_UNIT_NO
   AND T1.EXAM_NO = T2.EXAM_NO
  LEFT OUTER JOIN ESIN603 T3
    ON T1.REAL_COLL_UNIT_NO = T3.COLL_UNIT_NO
   AND T1.EXAM_NO = T3.EXAM_NO
  LEFT OUTER JOIN ESIN604 T4
    ON T1.COLL_UNIT_NO = T4.COLL_UNIT_NO
   AND T1.EXAM_NO = T4.EXAM_NO
   AND T4.SELECT_ELEMNT_FG = 'U027100009'
   AND T4.SCRN_STG_FG = 'U027200001'
  LEFT OUTER JOIN (SELECT A.COLL_UNIT_NO,
                          A.EXAM_NO,
                          A.ENG_FLD_COLG_YN,
                          A.LRN_COUN_FG,
                          A.CHULSIN_SCH_NM
                     FROM ESIN602 A
                     JOIN (SELECT X.COLL_UNIT_NO,
                                 X.EXAM_NO,
                                 X.SCHCR_INFO_SEQ,
                                 X.ENG_FLD_COLG_YN
                            FROM (SELECT COLL_UNIT_NO,
                                         EXAM_NO,
                                         SCHCR_INFO_SEQ,
                                         RANK() OVER(PARTITION BY COLL_UNIT_NO, EXAM_NO ORDER BY NVL(ENG_FLD_COLG_YN, 'N') DESC, GRDT_DT DESC) AS RANK_ORD,
                                         NVL(ENG_FLD_COLG_YN, 'N') AS ENG_FLD_COLG_YN
                                    FROM ESIN602) X
                            JOIN ESIN603 Y
                              ON X.COLL_UNIT_NO = Y.COLL_UNIT_NO
                             AND X.EXAM_NO = Y.EXAM_NO
                           WHERE NVL(X.ENG_FLD_COLG_YN, 'N') = 'Y'
                             AND Y.FRN_LANG_VLD_EXAM_FG = 'U027800014' /* 면제 */
                             AND X.RANK_ORD = 1) B
                       ON A.COLL_UNIT_NO = B.COLL_UNIT_NO
                      AND A.EXAM_NO = B.EXAM_NO
                      AND A.SCHCR_INFO_SEQ = B.SCHCR_INFO_SEQ) T5
    ON T1.REAL_COLL_UNIT_NO = T5.COLL_UNIT_NO
   AND T1.EXAM_NO = T5.EXAM_NO
  LEFT OUTER JOIN ESIN520 T6
    ON T1.REAL_COLL_UNIT_NO = T6.COLL_UNIT_NO
  LEFT OUTER JOIN V_COMM111_6 C1
    ON T1.APLY_COLL_UNIT_CD = C1.DEPT_CD
 WHERE T3.FRN_LANG_VLD_EXAM_FG NOT IN ('U027800003', 'U027800013') /* SNULT, 제2외국어 제외 */
   AND NVL(T3.FL_ADPT_YN, 'N') = 'Y'
   AND T1.SELECT_FG = 'U025700008'
   AND T1.SELECT_YY = '2020'
   AND T1.COLL_FG = 'U025800006'
   AND T1.COLL_UNIT_NO IN
       (SELECT A.COLL_UNIT_NO
          FROM ESIN521 A
         WHERE T1.COLL_UNIT_NO = A.COLL_UNIT_NO
           AND NVL(A.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
           AND A.SELECT_ELEMNT_FG = 'U027100009'
           AND A.ADPT_STG_FG = 'U027200001')
   AND T1.APLY_QUAL_FG = 'U024700001'
   AND T1.DETA_APLY_QUAL_FG IN ('U025900015')
   AND T1.APLY_COLG_FG = 'U026200028'
   AND T4.FL_SCOR < (SELECT SELECT_ELEMNT_FMAK_SCOR
                       FROM ESIN521 A
                      WHERE T1.COLL_UNIT_NO = A.COLL_UNIT_NO
                        AND NVL(A.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
                        AND A.SELECT_ELEMNT_FG = 'U027100009'
                        AND A.ADPT_STG_FG = 'U027200001') 
 ORDER BY T3.EXAM_NO 
;
