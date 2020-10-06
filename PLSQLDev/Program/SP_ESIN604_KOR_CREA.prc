CREATE OR REPLACE PROCEDURE SP_ESIN604_KOR_CREA
(   IN_COLL_UNIT_NO			IN ESIN604.COLL_UNIT_NO%TYPE			/* 모집단위번호 */
,	IN_SCRN_STG_FG			IN ESIN604.SCRN_STG_FG%TYPE				/* 사정단계구분 */
,	IN_SELECT_ELEMNT_FG		IN ESIN604.SELECT_ELEMNT_FG%TYPE		/* 전형요소구분 */
,	IN_GENRL_SELECT_CHG_YN	IN ESIN604.GENRL_SELECT_CHG_YN%TYPE		/* 일반전형전환여부 */
,	IN_SELECT_YY            IN ESIN600.SELECT_YY%TYPE				/* 전형년도 */
,   IN_SELECT_FG            IN ESIN600.SELECT_FG%TYPE               /* 전형구분 */
,   IN_COLL_FG              IN ESIN600.COLL_FG%TYPE					/* 모집구분 */
,   IN_APLY_QUAL_FG         IN ESIN600.APLY_QUAL_FG%TYPE			/* 지원자격 */
,   IN_DETA_APLY_QUAL_FG    IN ESIN600.DETA_APLY_QUAL_FG%TYPE		/* 세부지원자격 */
,   IN_APLY_CORS_FG         IN ESIN600.APLY_CORS_FG%TYPE			/* 과정 */
,   IN_APLY_COLG_FG         IN ESIN600.APLY_COLG_FG%TYPE			/* 단과대학 */
,   IN_APLY_COLL_UNIT_CD    IN ESIN600.APLY_COLL_UNIT_CD%TYPE		/* 모집단위코드 */
,   IN_EXAM_NO              IN ESIN600.EXAM_NO%TYPE					/* 수험번호 */
,	IN_FL_SCOR				IN ESIN604.FL_SCOR%TYPE					/* 최종점수 */
,	IN_INPT_ID				IN ESIN604.INPT_ID%TYPE					/* 생성자 ID */
,	IN_INPT_IP				IN ESIN604.INPT_IP%TYPE					/* 생성자 IP */
,	IN_MOD_ID				IN ESIN604.MOD_ID%TYPE					/* 수정자 ID */
,	IN_MOD_IP				IN ESIN604.MOD_IP%TYPE					/* 수정자 IP */
,   OUT_RTN                 OUT INTEGER								/* 결과값(OUT) */
,   OUT_MSG                 OUT VARCHAR2							/* 오류내용(OUT) */
)
IS
/******************************************************************************
	프로그램명	: SP_ESIN604_KOR_CREA
	수행목적	: 국어능력성적 환산점수 계산 및 결격.
	수행결과	: ESIN665(국어능력성적) -> ESIN604(성적)
------------------------------------------------------------------------------
	수정일자		수정자		수정내용
------------------------------------------------------------------------------
	2019.12.18	유준식		최초 작성
	2019.12.27	박원희		프로시저 오류 수정
    2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요. 
******************************************************************************/

BEGIN     
	--- 국어성적 삭제
	DELETE
	  FROM ESIN604 X
	 WHERE X.COLL_UNIT_NO IN (
				SELECT A.COLL_UNIT_NO
				  FROM ESIN520 A
				 WHERE A.SELECT_YY = IN_SELECT_YY
				   AND A.SELECT_FG = IN_SELECT_FG
				   AND A.COLL_FG = IN_COLL_FG
				   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND A.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, A.APLY_CORS_FG)
                   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
		   )
	   AND X.SELECT_ELEMNT_FG = IN_SELECT_ELEMNT_FG
	   AND X.SCRN_STG_FG = IN_SCRN_STG_FG
	;

	-- 국어성적 등록
	INSERT INTO ESIN604
	(	COLL_UNIT_NO
	,	EXAM_NO
	,	SCRN_STG_FG
	,	SELECT_ELEMNT_FG
	,	GENRL_SELECT_CHG_YN
	,	FL_SCOR
	,	EXCH_SCOR
	,	FL_DISQ_FG
	,	INPT_ID
	,	INPT_DTTM
	,	INPT_IP
	)
	WITH t1 AS (
        SELECT a.COLL_UNIT_NO
			 , a.EXAM_NO
			 , b.ADPT_STG_FG
			 , b.SELECT_ELEMNT_FG
			 , b.SELECT_ELEMNT_FMAK_SCOR
			 , b.EXCH_MTHD_FG
			 , b.SELECT_ELEMNT_BASE_SCOR
			 , b.SELECT_ELEMNT_SCOR_SCOR
			 , b.SELECT_ELEMNT_DISQ_ADPT_YN
			 , b.SELECT_ELEMNT_DISQ_SCOR
			 , c.GRD_VAL
			 , c.KOREAN_FG
			 , a.STG1_GENRL_SELECT_CHG_YN
			 , a.STG2_GENRL_SELECT_CHG_YN
			 , (
             
             /* START 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
                SELECT CASE WHEN MAX(A.SELECT_FG) = 'U025700003' THEN TRUNC(MAX(B.EXCH_SCOR),1)
                            ELSE MAX(B.EXCH_SCOR) 
                       END
             /* END 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
                
                  FROM ESIN520 A
                     , ESIN540 B
                 WHERE A.SELECT_YY = B.SELECT_YY
                   AND A.SELECT_FG = B.SELECT_FG
                   AND A.COLL_FG = B.COLL_FG
                   AND A.APLY_QUAL_FG LIKE B.APLY_QUAL_FG||'%'
                   AND A.DETA_APLY_QUAL_FG LIKE B.DETA_APLY_QUAL_FG||'%'
                   AND A.APLY_CORS_FG LIKE B.APLY_CORS_FG||'%'
                   AND A.APLY_COLG_FG LIKE B.APLY_COLG_FG||'%'
                   AND A.APLY_COLL_UNIT_CD LIKE B.APLY_COLL_UNIT_CD||'%'
                   AND B.MRKS_MOD_CHART_FG = 'U027500003'
                   AND B.MRKS_MOD_FG = C.KOREAN_FG
                   AND A.SELECT_YY = IN_SELECT_YY
                   AND A.SELECT_FG = IN_SELECT_FG
                   AND A.COLL_FG = IN_COLL_FG
                   AND C.GRD_VAL BETWEEN B.FR_VAL AND B.TO_VAL
			   ) AS FL_SCOR
			 , (
                SELECT MAX(B.EXCH_SCOR)
                  FROM ESIN520 A
                     , ESIN540 B
                 WHERE A.SELECT_YY = B.SELECT_YY
                   AND A.SELECT_FG = B.SELECT_FG
                   AND A.COLL_FG = B.COLL_FG
                   AND A.APLY_QUAL_FG LIKE B.APLY_QUAL_FG||'%'
                   AND A.DETA_APLY_QUAL_FG LIKE B.DETA_APLY_QUAL_FG||'%'
                   AND A.APLY_CORS_FG LIKE B.APLY_CORS_FG||'%'
                   AND A.APLY_COLG_FG LIKE B.APLY_COLG_FG||'%'
                   AND A.APLY_COLL_UNIT_CD LIKE B.APLY_COLL_UNIT_CD||'%'
                   AND B.MRKS_MOD_CHART_FG = 'U027500003'
                   AND B.MRKS_MOD_FG = C.KOREAN_FG
                   AND A.SELECT_YY = IN_SELECT_YY
                   AND A.SELECT_FG = IN_SELECT_FG
                   AND A.COLL_FG = IN_COLL_FG
                   AND C.GRD_VAL BETWEEN B.FR_VAL AND B.TO_VAL
			   ) AS EXCH_PCT_SCOR
			 , (
                SELECT MAX(B.EXCH_SCOR)
                  FROM ESIN520 A
                     , ESIN540 B
                 WHERE A.SELECT_YY = B.SELECT_YY
                   AND A.SELECT_FG = B.SELECT_FG
                   AND A.COLL_FG = B.COLL_FG
                   AND A.APLY_QUAL_FG LIKE B.APLY_QUAL_FG||'%'
                   AND A.DETA_APLY_QUAL_FG LIKE B.DETA_APLY_QUAL_FG||'%'
                   AND A.APLY_CORS_FG LIKE B.APLY_CORS_FG||'%'
                   AND A.APLY_COLG_FG LIKE B.APLY_COLG_FG||'%'
                   AND A.APLY_COLL_UNIT_CD LIKE B.APLY_COLL_UNIT_CD||'%'
                   AND B.MRKS_MOD_CHART_FG = 'U027500003'
                   AND B.MRKS_MOD_FG = C.KOREAN_FG
                   AND A.SELECT_YY = IN_SELECT_YY
                   AND A.SELECT_FG = IN_SELECT_FG
                   AND A.COLL_FG = IN_COLL_FG
                   AND C.GRD_VAL BETWEEN B.FR_VAL AND B.TO_VAL
			   ) AS EXCH_SCOR
		  FROM V_ESIN600 a
			 , ESIN521 b
			 , ESIN665 c
		 WHERE a.COLL_UNIT_NO IN (
					SELECT COLL_UNIT_NO
					  FROM ESIN520 X
					 WHERE X.SELECT_YY = IN_SELECT_YY
					   AND X.SELECT_FG = IN_SELECT_FG
					   AND X.COLL_FG = IN_COLL_FG
					   AND X.APLY_QUAL_FG = IN_APLY_QUAL_FG
					   AND X.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, X.APLY_CORS_FG)
                       AND X.APLY_COLG_FG = IN_APLY_COLG_FG
			   )
		   AND a.COLL_UNIT_NO = b.COLL_UNIT_NO
		   AND b.SELECT_ELEMNT_FG = IN_SELECT_ELEMNT_FG
		   AND b.SELECT_ELEMNT_USE_YN = 'Y'
		   AND a.REAL_COLL_UNIT_NO = c.COLL_UNIT_NO(+)
		   AND a.EXAM_NO = c.EXAM_NO(+)
	)
	SELECT a.COLL_UNIT_NO
		 , a.EXAM_NO
		 , a.ADPT_STG_FG AS SCRN_STG_FG
		 , a.SELECT_ELEMNT_FG
		 , CASE WHEN a.ADPT_STG_FG = 'U027200001' THEN NVL2(a.STG1_GENRL_SELECT_CHG_YN, a.STG1_GENRL_SELECT_CHG_YN, 'N')
				WHEN a.ADPT_STG_FG IN ('U027200002', 'U027200003') THEN NVL2(a.STG2_GENRL_SELECT_CHG_YN, a.STG2_GENRL_SELECT_CHG_YN, 'N')
		   END AS GENRL_SELECT_CHG_YN
		 , a.FL_SCOR
		 , a.EXCH_SCOR
		 , CASE WHEN a.KOREAN_FG IS NULL THEN 'U027700003' -- 서류 미제출
				WHEN a.SELECT_ELEMNT_DISQ_SCOR > a.FL_SCOR THEN 'U027700005' -- 과락 --원점수 기준 과락 점수
		   END AS FL_DISQ_FG
		 , IN_INPT_ID AS INPT_ID
		 , SYSDATE AS INPT_DTTM
		 , IN_INPT_IP AS INPT_IP
	  FROM T1 a
	 WHERE a.ADPT_STG_FG = IN_SCRN_STG_FG
	   AND NOT EXISTS (
				SELECT 1
				  FROM ESIN604 B
				 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
				   AND A.EXAM_NO = B.EXAM_NO
				   AND A.ADPT_STG_FG = B.SCRN_STG_FG
				   AND B.SELECT_ELEMNT_FG = IN_SELECT_ELEMNT_FG
		   )
	;

	OUT_RTN := 0;
	OUT_MSG := '처리에 성공하였습니다.';
	
	EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;
    RETURN;
END SP_ESIN604_KOR_CREA;
/
