/* 프로그램 목록 */
SELECT T1.SYSTEM_CD
     , T2.SYSTEM_NM
     , T3.UNIT_BUSS_ID
     , T3.UNIT_BUSS_NM
     , T4.SM_UNIT_BUSS_ID
     , T4.SM_UNIT_BUSS_NM
     , T1.PGM_NM
     , T1.PGM_PATH
     , T1.PGM_SRC_NM
     , T2.SYSTEM_NM || ' > ' || T3.UNIT_BUSS_NM || ' > ' || T4.SM_UNIT_BUSS_NM || ' > ' || T1.PGM_NM || '(' || T1.PGM_SRC_NM || ')' AS "화면명(메뉴경로)"
     , SF_BSNS011_CODENM(T1.PGM_FG) AS PGM_FG_NM
     , CASE WHEN T1.PGM_FG IN ('C020300001') AND T1.USE_YN = 'Y' THEN '메인프로그램'
            WHEN T1.PGM_FG IN ('C020300002')                     THEN '팝업'
            WHEN T1.PGM_FG IN ('C020300014')                     THEN '탭'
            WHEN T1.PGM_FG IN ('C020300011')                     THEN '보고서'
            WHEN T1.PGM_FG IN ('C020300010') AND T1.USE_YN = 'Y' THEN '메인프로그램(표준웹)'
            WHEN T1.PGM_FG IN ('C020300012')                     THEN '팝업        (표준웹)'
            WHEN T1.PGM_FG IN ('C020300013')                     THEN '탭          (표준웹)'
            WHEN T1.PGM_FG IN ('C020300003')                     THEN '보고서      (오즈)'
            ELSE '기타'
            END  AS PGM_TYPE
     , T1.USE_YN
  FROM SNU.SSTM020 T1
     , SNU.SSTM010 T2
     , SNU.SSTM011 T3
     , SNU.SSTM012 T4
 WHERE T1.SYSTEM_CD = T2.SYSTEM_CD
   AND T1.SYSTEM_CD = T3.SYSTEM_CD
   AND T1.UNIT_BUSS_CD = T3.UNIT_BUSS_CD
   AND T1.SYSTEM_CD = T4.SYSTEM_CD
   AND T1.UNIT_BUSS_CD = T4.UNIT_BUSS_CD
   AND T1.SM_UNIT_BUSS_CD = T4.SM_UNIT_BUSS_CD
--   AND SF_BSNS011_CODENM(T1.PGM_FG) LIKE '%표준웹%'
--   AND T1.PGM_SRC_NM LIKE 'LaborScalAtdcReg%'
--   AND T1.PGM_NM LIKE '%장학선발등록%'
   AND T1.USE_YN = 'Y'
ORDER BY T1.SYSTEM_CD, T1.UNIT_BUSS_CD, T1.SM_UNIT_BUSS_CD, T1.DISP_ORD
;

