
SELECT * FROM ESIN641 ;
SELECT * FROM ESIN607 WHERE coll_unit_no = '20200901011502920925' AND exam_no  IN ( '40011','40038' )  ;
SELECT * FROM ESIN523 ;


SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0271'
ORDER BY A.DISP_ORD, A.CMMN_CD
;
SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0274'
ORDER BY A.DISP_ORD, A.CMMN_CD
;


-- 쿼리 확인 2020-10-06
SELECT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD),
       B.COLL_UNIT_NO,
       C.EXAM_NO,       
       C.exch_scor,       
       C.fl_scor,       
       RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY case when nvl(c.exch_scor, 0) = 0 then nvl(c.fl_scor, 0) else nvl(c.exch_scor, 0) end  DESC ) AS RANKS
  FROM ESIN604 C,
       ESIN520 B
 WHERE C.COLL_UNIT_NO = B.COLL_UNIT_NO
   AND B.SELECT_YY = '2020'
   AND B.SELECT_FG = 'U025700009'
   AND B.COLL_FG = 'U025800001'
   AND B.APLY_QUAL_FG = 'U024700001'
   AND B.APLY_COLG_FG = 'U026200018'
   --AND B.APLY_CORS_FG = :A
   AND C.SCRN_STG_FG = (SELECT MAX(X.ADPT_STG_FG)
                          FROM ESIN521 X
                         WHERE X.COLL_UNIT_NO = B.COLL_UNIT_NO
                           AND X.COLL_UNIT_NO = C.COLL_UNIT_NO
                           AND X.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
                           --AND X.SELECT_ELEMNT_FG = 'U027100002'
                           AND X.SELECT_ELEMNT_FG = 'U027100020'
                           )
   AND exam_no  IN ( '40011','40038' )                           
;

    SELECT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) AS SCRN_GRP_CD
         , B.SELECT_YY
         , B.SELECT_FG
         , B.COLL_FG
         , B.APLY_QUAL_FG
         , B.APLY_COLG_FG
         , B.APLY_CORS_FG
         , A.ITEM_CD
         , A.SORT_ORD_FG
         , A.PREF_RANK
         , B.STG1_SLT_YN
         , A.SCRN_STG_FG
      FROM ESIN523 A    -- 모집단위동점자우선순위
         , ESIN520 B    -- 모집단위관리
     WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
       AND B.SELECT_YY = '2020'
       AND B.SELECT_FG = 'U025700009'
       AND B.COLL_FG = 'U025800001'
       AND B.APLY_QUAL_FG = 'U024700001'
       AND B.APLY_COLG_FG = 'U026200018'
       AND B.APLY_CORS_FG = B.APLY_CORS_FG
       AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
       AND NVL(A.USE_YN, 'N') = 'Y'   --사용여부
  ORDER BY B.APLY_CORS_FG
         , NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
         , A.PREF_RANK
    ;
