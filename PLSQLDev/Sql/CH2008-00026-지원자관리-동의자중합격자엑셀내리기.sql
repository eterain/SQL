        SELECT B.SELECT_YY
             , B.SELECT_FG
             , B.COLL_FG
             , B.APLY_QUAL_FG
             , B.DETA_APLY_QUAL_FG
             , B.APLY_CORS_FG
             , B.APLY_COLG_FG
             , B.APLY_COLL_UNIT_CD
             , B.DAYNGT_FG
             , B.SPCMAJ_CD
             , B.RECV_NO
             , C.APLIER_KOR_NM
             , C.ENG_NM             
             , B.BIRTH_DT
             , A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.UNIVS_NM
             , A.SUST_NM
             , A.GRDT_DT
             , A.SCHCR_INQ_RESP_DEPT_NM
             , A.SCHCR_INQ_RESP_EMAIL
             , A.DEGR_NM
             , A.SCHCR_INQ_CONSNT_YN
             , A.INPT_ID
             , A.INPT_DTTM
             , A.INPT_IP
             , NVL2(A.MOD_ID, A.MOD_ID, A.INPT_ID) AS MOD_ID
             , NVL2(A.MOD_DTTM, A.MOD_DTTM, A.INPT_DTTM) AS MOD_DTTM
             , NVL2(A.MOD_IP, A.MOD_IP, A.INPT_IP) AS MOD_IP
             , SF_BSNS011_CODENM(B.SELECT_FG, '1') AS SELECT_FG_NM
             , SF_BSNS011_CODENM(B.COLL_FG, '1') AS COLL_FG_NM
             , SF_BSNS011_CODENM(B.APLY_QUAL_FG, '1') AS APLY_QUAL_FG_NM
             , SF_BSNS011_CODENM(B.DETA_APLY_QUAL_FG, '1') AS DETA_APLY_QUAL_FG_NM
             , SF_BSNS011_CODENM(B.APLY_CORS_FG, '1') AS APLY_CORS_FG_NM
             , SF_BSNS011_CODENM(B.APLY_COLG_FG, '1') AS APLY_COLG_FG_NM
             , DECODE(D.DEPT_TYPE, 'D', D.DEPT_KOR_NM, 'M', D.DEPARTMENT_KOR_NM||' > '||D.DEPT_KOR_NM) AS APLY_COLL_UNIT_CD_NM
             , SF_BSNS011_CODENM(B.DAYNGT_FG, '1') AS DAYNGT_FG_NM
             
             , SF_BSNS011_CODENM(E.PASS_SCRN_FG,'1') AS PASS_SCRN_FG                  /* 합격사정구분                            */
             , SF_BSNS011_CODENM(E.PASS_DISQ_FG,'1') AS PASS_DISQ_FG                 /* 합격불합격구분                          */
             , SF_BSNS011_CODENM(E.STP_PASS_SEQ_FG,'1')	AS STP_PASS_SEQ_FG           /* 충원합격차수구분                        */
             , SF_BSNS011_CODENM(E.STP_PASS_FG,'1') AS STP_PASS_FG	               /* 충원합격구분                            */
             ,E.PASS_SCRN_FG                  /* 합격사정구분                            */
             ,E.PASS_DISQ_FG                  /* 합격불합격구분                          */
             ,E.STP_PASS_SEQ_FG	              /* 충원합격차수구분                        */
             ,E.STP_PASS_FG	                  /* 충원합격구분                            */
             
          FROM ESIN690 A
             , ESIN600 B
             , ESIN601 C
             , V_COMM111_6 D
             , ESIN606 E
         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
           AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
           AND A.EXAM_NO = B.EXAM_NO
           AND A.EXAM_NO = C.EXAM_NO
           
           AND A.COLL_UNIT_NO = E.COLL_UNIT_NO 
           AND A.EXAM_NO = E.EXAM_NO 
           
           AND E.SCRN_STG_FG IN ('U027200002', 'U027200003')
           AND E.PASS_DISQ_FG = 'U024300005' 
           
           AND B.APLY_COLL_UNIT_CD = D.DEPT_CD(+) ;
           
           
SELECT  *
FROM ESIN606 
WHERE STP_PASS_FG = 'U024300005'
;                  

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
   AND GRP_CD = 'U0243'
--   AND CMMN_CD = ''
--   AND KOR_NM LIKE '%' || '' || '%'
 ORDER BY GRP_CD,
          DISP_ORD;

 /* ESIN690.find02 지원사항관리 - 지원자관리 - 학력조회동의 - 합격자 조회 */ SELECT B.SELECT_YY , B.SELECT_FG , B.COLL_FG 
, B.APLY_QUAL_FG , B.DETA_APLY_QUAL_FG , B.APLY_CORS_FG , B.APLY_COLG_FG , B.APLY_COLL_UNIT_CD 
, B.DAYNGT_FG , B.SPCMAJ_CD , B.RECV_NO , C.APLIER_KOR_NM , B.BIRTH_DT , A.COLL_UNIT_NO , A.EXAM_NO 
, A.UNIVS_NM , A.SUST_NM , A.GRDT_DT , A.SCHCR_INQ_RESP_DEPT_NM , A.SCHCR_INQ_RESP_EMAIL , 
A.DEGR_NM , A.SCHCR_INQ_CONSNT_YN , A.INPT_ID , A.INPT_DTTM , A.INPT_IP , NVL2(A.MOD_ID, A.MOD_ID, 
A.INPT_ID) AS MOD_ID , NVL2(A.MOD_DTTM, A.MOD_DTTM, A.INPT_DTTM) AS MOD_DTTM , NVL2(A.MOD_IP, 
A.MOD_IP, A.INPT_IP) AS MOD_IP , SF_BSNS011_CODENM(B.SELECT_FG, '1') AS SELECT_FG_NM , SF_BSNS011_CODENM(B.COLL_FG, 
'1') AS COLL_FG_NM , SF_BSNS011_CODENM(B.APLY_QUAL_FG, '1') AS APLY_QUAL_FG_NM , SF_BSNS011_CODENM(B.DETA_APLY_QUAL_FG, 
'1') AS DETA_APLY_QUAL_FG_NM , SF_BSNS011_CODENM(B.APLY_CORS_FG, '1') AS APLY_CORS_FG_NM , 
SF_BSNS011_CODENM(B.APLY_COLG_FG, '1') AS APLY_COLG_FG_NM , DECODE(D.DEPT_TYPE, 'D', D.DEPT_KOR_NM, 
'M', D.DEPARTMENT_KOR_NM || ' > ' || D.DEPT_KOR_NM) AS APLY_COLL_UNIT_CD_NM , SF_BSNS011_CODENM(B.DAYNGT_FG, 
'1') AS DAYNGT_FG_NM , SF_BSNS011_CODENM(E.PASS_SCRN_FG,'1') AS PASS_SCRN_FG /* 합격사정구분 */ , 
SF_BSNS011_CODENM(E.PASS_DISQ_FG,'1') AS PASS_DISQ_FG /* 합격불합격구분 */ , SF_BSNS011_CODENM(E.STP_PASS_SEQ_FG,'1') 
AS STP_PASS_SEQ_FG /* 충원합격차수구분 */ , SF_BSNS011_CODENM(E.STP_PASS_FG,'1') AS STP_PASS_FG /* 
충원합격구분 */ FROM ESIN690 A , ESIN600 B , ESIN601 C , V_COMM111_6 D , ESIN606 E WHERE A.COLL_UNIT_NO 
= B.COLL_UNIT_NO AND A.COLL_UNIT_NO = C.COLL_UNIT_NO AND A.COLL_UNIT_NO = E.COLL_UNIT_NO AND 
A.EXAM_NO = B.EXAM_NO AND A.EXAM_NO = C.EXAM_NO AND A.EXAM_NO = E.EXAM_NO AND E.SCRN_STG_FG 
IN ('U027200002', 'U027200003') AND E.PASS_DISQ_FG = 'U024300005' AND B.APLY_COLL_UNIT_CD = 
D.DEPT_CD(+) AND SELECT_FG = 'U025700001' AND SELECT_YY = '2020' AND COLL_FG = 'U025800001' 
ORDER BY A.EXAM_NO ;
