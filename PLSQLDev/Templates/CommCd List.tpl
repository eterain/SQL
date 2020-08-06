SELECT GRP_CD,
       CMMN_CD,
       KOR_NM,
       KOR_DESC,
       DISP_ORD,
       USR_DEF_1,
       USR_DEF_DESC_1 USE_YN,
       ENG_NM
  FROM BSNS011
 WHERE 1 = 1
   AND GRP_CD = 'U0002'
--   AND CMMN_CD = ''
--   AND KOR_NM LIKE '%' || '' || '%'
 ORDER BY GRP_CD,
          DISP_ORD;