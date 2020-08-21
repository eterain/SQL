/* Formatted on 2020-08-12 오전 8:46:38 (QP5 v5.185.11230.41888) */
   /* ESIN780.find01 자료연계관리 - 입학영어성적 - 입학영어성적 조회 */

  SELECT A.COLL_FG,
         A.APLY_QUAL_FG,
         A.DETA_APLY_QUAL_FG,
         A.APLY_CORS_FG,
         A.APLY_COLG_FG,
         A.APLY_COLL_UNIT_CD,
         A.SPCMAJ_CD,
         (SELECT SPCMAJ_NM
          FROM ESIN530 
          WHERE 1 = 1 
          AND COLL_UNIT_NO = A.COLL_UNIT_NO 
          AND SPCMAJ_CD = A.SPCMAJ_CD ) AS SPCMAJ_NM,
         A.EXAM_NO,
         (SELECT APLIER_KOR_NM
          FROM ESIN601 
          WHERE 1 = 1 
          AND COLL_UNIT_NO = A.REAL_COLL_UNIT_NO 
          AND EXAM_NO = A.EXAM_NO ) AS APLIER_KOR_NM,
         C.ENTR_SCHYY,
         C.ENTR_SHTM_FG,
         C.STUNO,
         C.ENG_PASS_YN,
         C.ENG_MRKS_DETM_FG,
         C.ENG_EXAM_SCOR,
         C.ENG_PASS_DT,
         C.TOEFL_SUBST_YN,
         C.TOEFL_AEXAM_DT,
         C.TEPS_AEXAM_DT,
         C.SECOND_FOREXAM_SBJT_FG,
         C.SECOND_FRN_LANG_PASS_YN,
         C.SECOND_FRN_LANG_PASS_DT,
         C.SECOND_FRN_LANG_SCOR,
         C.CUML_MRKS_TRANS_YN,
         C.CUML_MRKS_TRANS_DT,
         A.COLL_UNIT_NO
    FROM V_ESIN600 A,
         ESIN780 C
   WHERE A.COLL_UNIT_NO = C.COLL_UNIT_NO 
     AND A.EXAM_NO = C.EXAM_NO     
     AND A.SELECT_FG = 'U025700008'
     AND A.SELECT_YY = '2020'
     AND A.COLL_FG = 'U025800006'
ORDER BY A.EXAM_NO
;


