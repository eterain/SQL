SELECT * FROM bsns031 ;

  /*SSTM094.find01 화면에서 요청한 Action이 해당 사용자가 사용 가능한 Action인지 체크  */
  SELECT *
    FROM SSTM094
   WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE
         '%' ||
         REGEXP_REPLACE('/uni/ncrt/findStudInfo.action', '[[:punct:]]') || '%';

SELECT * FROM enro200 
WHERE schyy = '2020'
AND shtm_fg = 'U000200002'
;

SELECT * FROM BSNS031 WHERE rpst_pers_no = '2018-18738' ;

SELECT DECODE(COUNT(*), 0, 'N', 'Y') AS YN
FROM BSNS031 T1
WHERE T1.PERS_NO = '2018-18738'     /* 학번 */
AND (UPPER(TRIM(T1.PERS_KOR_NM)) = UPPER(TRIM('안현빈')) OR UPPER(TRIM(T1.PERS_ENG_NM)) LIKE '%' || UPPER(TRIM('안현빈')) || '%') /* 성명 */
AND T1.BIRTH_DT = '19990515'  /* 생년월일 */
;

/* NCRT000.find05 등록고지서 정보 조회 */     SELECT         T4.NOTI_FG       , T5.DEPT_CD       , NVL('2011-11941','-') AS STUNO       , NVL('','-') AS STUIP       , NVL('','-') AS STUDT     FROM     (         SELECT DISTINCT             CASE WHEN T2.BDEGR_SYSTEM_FG = 'U000100001'                       THEN CASE WHEN T1.REG_OBJ_FG = 'U060200002' THEN '02'                                 ELSE '01'                            END                  WHEN T2.BDEGR_SYSTEM_FG = 'U000100002'                       THEN CASE WHEN T1.DEPT_CD = '981A' THEN '06'                                 ELSE '07'                            END                  WHEN T2.BDEGR_SYSTEM_FG = 'U000100003' THEN '08'             END AS NOTI_FG             /* 01 : 재학생등록, 02 : 계약학과등록, 06 : GMBA, 07 : SMBA, 08 : EMBA */         FROM             ENRO200     T1  /* 등록대상자내역 */           , V_COMM111_4 T2  /* 부서VIEW */           , (                 SELECT                     SCHYY       /* 학년 */                   , SHTM_FG     /* 학기 */                   , NOTI_FG     /* 안내페이지구분(공지구분) */                   , NOTI_NM     /* 안내페이지명칭(공지명칭) */                   , DEPT_CD     /* 부서코드 - 계약학과 고지서에서만 사용 */                 FROM                     V_NOTI_SCHE /* 안내페이지 VIEW */             ) T3         WHERE 1=1         AND T1.DEPT_CD = T2.DEPT_CD         AND T1.SCHYY   = T3.SCHYY         AND T1.SHTM_FG = T3.SHTM_FG         AND T1.STUNO   = '2011-11941'     ) T4,     (         SELECT             SCHYY       /* 학년 */           , SHTM_FG     /* 학기 */           , NOTI_FG     /* 안내페이지구분(공지구분) */           , NOTI_NM     /* 안내페이지명칭(공지명칭) */           , DEPT_CD     /* 부서코드 - 계약학과 고지서에서만 사용 */         FROM             V_NOTI_SCHE /* 안내페이지 VIEW */     ) T5     WHERE 1=1     AND T4.NOTI_FG = T5.NOTI_FG     ;

SELECT USER_FG FROM SSTM094 GROUP BY USER_FG;

SELECT USER_FG FROM SSTM094 
WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE '%' || REGEXP_REPLACE('/uni/ncrt/findNcrtSchaffScheList.action', '[[:punct:]]') || '%' ;
SELECT USER_FG FROM SSTM094 
WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE '%' || REGEXP_REPLACE('/uni/gsin/cmmn/showError.action', '[[:punct:]]') || '%' ;
SELECT * FROM SSTM094 
WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE '%' || REGEXP_REPLACE('/uni/uni/ncrt/findStudInfo.action', '[[:punct:]]') || '%' ;

DELETE FROM SSTM094 
WHERE URL_NM LIKE '%' || 'ncrt' || '%' ;


DELETE FROM SSTM094 
WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE '%' || REGEXP_REPLACE('/uni/ncrt/findNcrtSchaffScheList.action', '[[:punct:]]') || '%' ;
DELETE FROM SSTM094 
WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE '%' || REGEXP_REPLACE('/uni/gsin/cmmn/showError.action', '[[:punct:]]') || '%' ;
DELETE FROM SSTM094 
WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE '%' || REGEXP_REPLACE('/uni/uni/ncrt/findStudInfo.action', '[[:punct:]]') || '%' ;


INSERT INTO sstm094 ( url_nm, 
user_fg, 
inpt_id, 
inpt_dttm, 
inpt_ip, 
mod_id, 
mod_dttm, 
mod_ip )
SELECT '/uni/uni/ncrt/findStudInfo.action', 
user_fg, 
inpt_id, 
inpt_dttm, 
inpt_ip, 
mod_id, 
mod_dttm, 
mod_ip FROM sstm094 
WHERE REGEXP_REPLACE(URL_NM, '[[:punct:]]') LIKE '%' || REGEXP_REPLACE('adm/park/pkam/aplyParkTickNewAply.action', '[[:punct:]]') || '%' ;



SELECT to_char(SYSDATE,'MMDD') FROM dual ;


SELECT std_kor_nm, exam_no, SUBSTR(res_no,1,6) 
FROM enro400 WHERE entr_schyy = '2020' AND select_fg = 'U061800025' ;


SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'C0133'
ORDER BY A.DISP_ORD, A.CMMN_CD
;

SELECT * FROM esin601 ;
SELECT * FROM sreg101 ;
SELECT * FROM bsns031 ;


SELECT B.PERS_NO AS STUNO
     , B.STD_FG
     , C.PROG_CORS_FG
     , a.*
  FROM ESIN601_DAMO A
     , BSNS031_DAMO B
     , SREG101 C
 WHERE A.SEC_RES_NO  = B.SEC_RES_NO
   AND B.PERS_NO = C.STUNO 
   AND B.STD_FG IN ('U030500002', 'U030500001' ) -- 'U030500006', 'U030500007')  --정규, 연구, 국내교환IN, 국제교환IN
   
   AND C.PROG_CORS_FG = 'C013300001'    -- 학사 1 , 석사 2
   AND a.exam_no = '24010'
;

/* ESIN601.find02 지원사항관리 - 지원자관리 - 학력 - 성적표 출력키 위한 학번조회 */ SELECT B.PERS_NO AS STUNO FROM ESIN601_DAMO 
A , BSNS031_DAMO B , SREG101 C WHERE A.SEC_RES_NO = B.SEC_RES_NO AND B.PERS_NO = C.STUNO AND 
B.STD_FG IN ('U030500002', 'U030500001') AND C.PROG_CORS_FG = 'C013300002' AND A.COLL_UNIT_NO 
IN ( '202001020115028008011N' , '202001020115028008011N' , '202001020115028008011O' , '202001020115028008011S' 
, '202001020115028008011S' , '202001020115028008011S' , '202001020115028008011S' , '202001020115028008011S' 
, '202001020115028008012V' , '202001020115028008011X' , '202001020115028008011Z' ) AND A.EXAM_NO 
IN ( '24008' , '24010' , '24011' , '24012' , '24013' , '24014' , '24015' , '24017' , '24018' 
, '24019' , '24020' ) ORDER BY A.EXAM_NO;


SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0258'
ORDER BY A.DISP_ORD, A.CMMN_CD
;

		SELECT CMMN_CD
			 , KOR_NM
             , CASE WHEN TO_CHAR(SYSDATE,'MMDD') >= '0301' AND TO_CHAR(SYSDATE,'MMDD') < '0901' THEN '2' ELSE '1' END  AS DISP_ORD
		  FROM BSNS011 ;

SELECT CMMN_CD
             , KOR_NM
             , CASE WHEN CMMN_CD = 'U025800001' AND TO_CHAR(SYSDATE,'MMDD') >= '0301' AND TO_CHAR(SYSDATE,'MMDD') <'0901' THEN '2' 
                    WHEN CMMN_CD = 'U025800002' AND TO_CHAR(SYSDATE,'MMDD') >= '0301' AND TO_CHAR(SYSDATE,'MMDD') <'0901' THEN '1' 
               ELSE '1' END AS DISP_ORD
          FROM BSNS011
         WHERE CMMN_CD IN (
                SELECT COLL_FG
                  FROM ESIN502
                 WHERE SELECT_FG = 'U025700001'
                   AND SELECT_YY = '2020'
               )
      ORDER BY DISP_ORD, CMMN_CD ;


   /* ESIN690.find01 지원사항관리 - 지원자관리 - 학력조회동의 조회 */
   SELECT B.SELECT_YY,
          B.SELECT_FG,
          B.COLL_FG,
          B.APLY_QUAL_FG,
          B.DETA_APLY_QUAL_FG,
          B.APLY_CORS_FG,
          B.APLY_COLG_FG,
          B.APLY_COLL_UNIT_CD,
          B.DAYNGT_FG,
          B.SPCMAJ_CD,
          B.RECV_NO,
          C.APLIER_KOR_NM,
          C.ENG_NM,
          B.BIRTH_DT,
          A.COLL_UNIT_NO,
          A.EXAM_NO,
          A.UNIVS_NM,
          A.SUST_NM,
          A.GRDT_DT,
          A.SCHCR_INQ_RESP_DEPT_NM,
          A.SCHCR_INQ_RESP_EMAIL,
          A.DEGR_NM,
          A.SCHCR_INQ_CONSNT_YN,
          A.INPT_ID,
          A.INPT_DTTM,
          A.INPT_IP,
          NVL2(A.MOD_ID, A.MOD_ID, A.INPT_ID) AS MOD_ID,
          NVL2(A.MOD_DTTM, A.MOD_DTTM, A.INPT_DTTM) AS MOD_DTTM,
          NVL2(A.MOD_IP, A.MOD_IP, A.INPT_IP) AS MOD_IP,
          SF_BSNS011_CODENM(B.SELECT_FG, '1') AS SELECT_FG_NM,
          SF_BSNS011_CODENM(B.COLL_FG, '1') AS COLL_FG_NM,
          SF_BSNS011_CODENM(B.APLY_QUAL_FG, '1') AS APLY_QUAL_FG_NM,
          SF_BSNS011_CODENM(B.DETA_APLY_QUAL_FG, '1') AS DETA_APLY_QUAL_FG_NM,
          SF_BSNS011_CODENM(B.APLY_CORS_FG, '1') AS APLY_CORS_FG_NM,
          SF_BSNS011_CODENM(B.APLY_COLG_FG, '1') AS APLY_COLG_FG_NM,
          DECODE(D.DEPT_TYPE,
                 'D',
                 D.DEPT_KOR_NM,
                 'M',
                 D.DEPARTMENT_KOR_NM || ' > ' || D.DEPT_KOR_NM) AS APLY_COLL_UNIT_CD_NM,
          SF_BSNS011_CODENM(B.DAYNGT_FG, '1') AS DAYNGT_FG_NM,
               SF_BSNS011_CODENM(E.PASS_SCRN_FG,'1') AS PASS_SCRN_FG                  /* 합격사정구분                            */
             , SF_BSNS011_CODENM(E.PASS_DISQ_FG,'1') AS PASS_DISQ_FG                 /* 합격불합격구분                          */
             , SF_BSNS011_CODENM(E.STP_PASS_SEQ_FG,'1')	AS STP_PASS_SEQ_FG           /* 충원합격차수구분                        */
             , SF_BSNS011_CODENM(E.STP_PASS_FG,'1') AS STP_PASS_FG	               /* 충원합격구분                            */          
     FROM ESIN690     A,
          ESIN600     B,
          ESIN601     C,
          V_COMM111_6 D,
          ( SELECT COLL_UNIT_NO, EXAM_NO, PASS_SCRN_FG, PASS_DISQ_FG, STP_PASS_SEQ_FG, STP_PASS_FG  
            FROM ESIN606
            WHERE SCRN_STG_FG IN ('U027200002', 'U027200003' )
            --AND PASS_DISQ_FG = 'U024300005' 
            ) E
    WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
      AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
      AND A.COLL_UNIT_NO = E.COLL_UNIT_NO (+)
      AND A.EXAM_NO = B.EXAM_NO
      AND A.EXAM_NO = C.EXAM_NO
      AND A.EXAM_NO = E.EXAM_NO (+)
      AND B.APLY_COLL_UNIT_CD = D.DEPT_CD(+)
      AND SELECT_FG = 'U025700001'
      AND SELECT_YY = '2020'
      AND COLL_FG = 'U025800002'
    ORDER BY A.EXAM_NO;
