CREATE OR REPLACE PROCEDURE SP_ESIN604_OTH_RST_CREA
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
	프로그램명	: SP_ESIN604_OTH_RST_CREA
	수행목적	: 나머지 성적 환산점수 계산 및 결격.
	수행결과	: 
------------------------------------------------------------------------------
	수정일자		수정자		수정내용
------------------------------------------------------------------------------
	2019.12.18	유준식		최초 작성
	2019.12.27	박원희		프로시저 오류 수정
    2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요. 
*******************************************************************************/

--변수 선언
V_TMP1 NUMBER;
V_TMP2 NUMBER;
/*
U027100007		U0271	서류평가
U027100008		U0271	실기성적
U027100009		U0271	영어성적
U027100010		U0271	전공이론
U027100011		U0271	전공필답고사
U027100012		U0271	정성평가
U027100013		U0271	제2외국어
U027100014		U0271	학업성적
U027100017		U0271	전공선택1
U027100018		U0271	전공선택2
U027100019		U0271	전공선택3
*/

CURSOR CUR1 IS
	SELECT a.COLL_UNIT_NO
		 , a.SELECT_YY
		 , a.SELECT_FG
		 , a.COLL_FG
		 , a.APLY_QUAL_FG
		 , a.DETA_APLY_QUAL_FG
		 , a.APLY_CORS_FG
		 , a.APLY_COLG_FG
		 , a.APLY_COLL_UNIT_CD
		 , b.SELECT_ELEMNT_BASE_SCOR
		 , b.SELECT_ELEMNT_SCOR_SCOR
		 , b.SELECT_ELEMNT_DISQ_ADPT_YN
		 , b.SELECT_ELEMNT_DISQ_SCOR
		 , b.SELECT_ELEMNT_DISQ_GRD_FG
		 , b.SELECT_ELEMNT_FMAK_SCOR
		 , b.EXCH_MTHD_FG
		 , b.SELECT_ELEMNT_FG
         , DECODE(b.SELECT_ELEMNT_FG, 'U027100007', a.DOC_APPR_MEMB_MEMB_CNT, 'U027100005', a.INTRV_MEMB_RCNT) AS MEMB_RCNT
         , DECODE(b.SELECT_ELEMNT_FG, 'U027100007', 'U027500005', 'U027100005', 'U027500006') AS MRKS_MOD_CHART_FG
         , DECODE(b.SELECT_ELEMNT_FG, 'U027100007', 'U027500005', 'U027100005', 'U027500006') AS MRKS_MOD_FG
		 , b.ADPT_STG_FG AS SCRN_STG_FG
	  FROM ESIN520 a
		 , ESIN521 b
	 WHERE a.SELECT_YY = IN_SELECT_YY
	   AND a.SELECT_FG = IN_SELECT_FG
	   AND a.COLL_FG = NVL(IN_COLL_FG, a.COLL_FG)
	   AND a.COLL_UNIT_NO = b.COLL_UNIT_NO
	   AND b.SELECT_ELEMNT_FG = IN_SELECT_ELEMNT_FG
	   AND b.SELECT_ELEMNT_USE_YN = 'Y'
	   AND b.ADPT_STG_FG = IN_SCRN_STG_FG
	   AND a.APLY_COLG_FG = NVL(IN_APLY_COLG_FG, a.APLY_COLG_FG)
	   AND a.COLL_UNIT_NO = b.COLL_UNIT_NO
	   AND a.APLY_QUAL_FG = NVL(IN_APLY_QUAL_FG, a.APLY_QUAL_FG)
	   AND a.DETA_APLY_QUAL_FG = NVL(IN_DETA_APLY_QUAL_FG, a.DETA_APLY_QUAL_FG)
	   AND a.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, a.APLY_CORS_FG)
	   AND a.COLL_UNIT_NO = NVL(IN_COLL_UNIT_NO, a.COLL_UNIT_NO)
    ;

CURSOR CUR2 IS
	WITH T1 AS (
		SELECT SELECT_FG
			 , COLL_FG
			 , APLY_QUAL_FG
			 , DETA_APLY_QUAL_FG
			 , APLY_CORS_FG
			 , APLY_COLG_FG
			 , APLY_COLL_UNIT_CD
			 , SELECT_ELEMNT_FG
             , DECODE(B.SELECT_ELEMNT_FG, 'U027100005', INTRV_MEMB_RCNT, 'U027100007', DOC_APPR_MEMB_MEMB_CNT) AS MEMB_RCNT
		  FROM ESIN520 A
			 , ESIN521 B
		 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
		   AND B.SELECT_ELEMNT_FG = IN_SELECT_ELEMNT_FG
		   AND B.SELECT_ELEMNT_FG IN ('U027100005', 'U027100007')
		   AND A.SELECT_YY = IN_SELECT_YY
		   AND A.SELECT_FG = IN_SELECT_FG
		   AND A.COLL_FG = IN_COLL_FG
		   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
		   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	)
	SELECT SF_BSNS011_CODENM(A.APLY_COLG_FG)||' '||SF_BSNS011_CODENM(A.APLY_CORS_FG)||' '||B.DEPT_CD||' '||B.DEPT_KOR_NM AS MSG
	  FROM T1 A
		 , V_COMM111_6 B
	 WHERE NVL(A.MEMB_RCNT, 0) < 1
	   AND A.APLY_COLL_UNIT_CD = B.DEPT_CD
    ;

-- 성적이 입력되지 않은 모집단위 조
CURSOR CUR3 IS
	WITH T1 AS (
		SELECT A.COLL_UNIT_NO
			 , B.APLY_COLL_UNIT_CD
             , B.SELECT_FG
			 , A.SELECT_ELEMNT_FG
			 , B.APLY_CORS_FG
			 , B.APLY_COLG_FG
			 , MAX(A.MEMB_1_SCOR_VAL) AS MEMB_1_SCOR_VAL
			 , MAX(NVL(A.MEMB_2_SCOR_VAL, 0)) AS MEMB_2_SCOR_VAL
			 , MAX(NVL(A.MEMB_3_SCOR_VAL, 0)) AS MEMB_3_SCOR_VAL
			 , MAX(NVL(A.MEMB_4_SCOR_VAL, 0)) AS MEMB_4_SCOR_VAL
			 , MAX(NVL(A.MEMB_5_SCOR_VAL, 0)) AS MEMB_5_SCOR_VAL
			 , MAX(NVL(A.MEMB_6_SCOR_VAL, 0)) AS MEMB_6_SCOR_VAL
             , DECODE(A.SELECT_ELEMNT_FG, 'U027100005', MAX(B.INTRV_MEMB_RCNT), 'U027100007', MAX(B.DOC_APPR_MEMB_MEMB_CNT)) AS MEMB_RCNT
             , A.EXAM_NO
		  FROM ESIN604 A
			 , ESIN520 B
		 WHERE B.SELECT_YY = IN_SELECT_YY
		   AND B.SELECT_FG = IN_SELECT_FG
		   AND B.COLL_FG = IN_COLL_FG
		   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
		   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
		   AND A.SCRN_STG_FG = IN_SCRN_STG_FG
		   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
		   AND A.SELECT_ELEMNT_FG IN ('U027100005', 'U027100007')
		   AND A.SELECT_ELEMNT_FG = IN_SELECT_ELEMNT_FG
	  GROUP BY A.COLL_UNIT_NO
             , B.SELECT_FG
			 , B.APLY_CORS_FG
			 , B.APLY_COLG_FG
			 , A.SELECT_ELEMNT_FG
			 , B.APLY_COLL_UNIT_CD
             , A.EXAM_NO
	), T2 AS (
		SELECT A.COLL_UNIT_NO
             , A.SELECT_FG
			 , A.APLY_CORS_FG
			 , A.APLY_COLG_FG
			 , A.SELECT_ELEMNT_FG
			 , B.DEPT_KOR_NM
			 , A.MEMB_RCNT
			 , A.MEMB_1_SCOR_VAL
			 , A.MEMB_3_SCOR_VAL
			 , A.MEMB_4_SCOR_VAL
			 , CASE WHEN A.MEMB_RCNT = 1 THEN A.MEMB_1_SCOR_VAL
					WHEN A.MEMB_RCNT = 2 THEN A.MEMB_2_SCOR_VAL
					WHEN A.MEMB_RCNT = 3 THEN A.MEMB_3_SCOR_VAL
					WHEN A.MEMB_RCNT = 4 THEN A.MEMB_4_SCOR_VAL
					WHEN A.MEMB_RCNT = 5 THEN A.MEMB_5_SCOR_VAL
					WHEN A.MEMB_RCNT = 6 THEN A.MEMB_6_SCOR_VAL
					ELSE '-1'
			   END AS SCOR_VAL
			 , '수험번호('||A.EXAM_NO||') '||SF_BSNS011_CODENM(A.APLY_COLG_FG)||' '||SF_BSNS011_CODENM(A.APLY_CORS_FG)||' '||B.DEPT_KOR_NM||'('||B.DEPT_CD||')' AS MSG
		  FROM T1 A
			 , V_COMM111_6 B
		 WHERE A.APLY_COLL_UNIT_CD = B.DEPT_CD
	)
	SELECT A.COLL_UNIT_NO
         , A.SELECT_FG
		 , A.APLY_CORS_FG
		 , A.APLY_COLG_FG
		 , A.SELECT_ELEMNT_FG
		 , A.DEPT_KOR_NM
         , A.MEMB_RCNT
		 , A.MSG
	  FROM T2 A
	 WHERE EXISTS (
				SELECT 1
				  FROM ESIN521 x
				 WHERE x.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND x.SELECT_ELEMNT_FG = IN_SELECT_ELEMNT_FG
				   AND x.ADPT_STG_FG = IN_SCRN_STG_FG
				   AND x.SELECT_ELEMNT_DISQ_GRD_FG IS NULL
		   )
	   AND NVL(A.SCOR_VAL, '') = ''
    ;

BEGIN
	OUT_MSG := '';

	FOR C2 IN CUR2 LOOP
		OUT_MSG := OUT_MSG||' '||C2.MSG||'/';
	END LOOP;
	
	IF REPLACE(OUT_MSG, '/', '') IS NOT NULL THEN
		SELECT RTRIM(OUT_MSG, '/')||'의 위원수가 입력되지 않았습니다'
		  INTO OUT_MSG
		  FROM DUAL
        ;
		  
		OUT_RTN := '-1';
		RETURN;
	END IF;

	FOR C3 IN CUR3 LOOP
		OUT_MSG := OUT_MSG||' '||C3.MSG||'의 위원'||C3.MEMB_RCNT||' 성적이 입력되지 않았습니다.'||'/';
	END LOOP;

	IF REPLACE(OUT_MSG, '/', '') IS NOT NULL THEN
		SELECT RTRIM(OUT_MSG, '/')
		  INTO OUT_MSG
		  FROM DUAL
        ;
		  
		OUT_RTN := '-1';
		RETURN;
	END IF;

	FOR c1 IN CUR1 LOOP
		IF (c1.SELECT_ELEMNT_FG = 'U027100014') THEN
			DELETE
			  FROM ESIN604 X
			 WHERE X.COLL_UNIT_NO = c1.COLL_UNIT_NO
			   AND X.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
			   AND X.SCRN_STG_FG = c1.SCRN_STG_FG
			   AND NVL(X.FL_DISQ_FG, 'X') IN ('X', 'U027700005')
            ;

			INSERT INTO ESIN604
			(	COLL_UNIT_NO
			,	EXAM_NO
			,	SCRN_STG_FG
			,	SELECT_ELEMNT_FG
			,	GENRL_SELECT_CHG_YN
			)
			SELECT A.COLL_UNIT_NO
				 , A.EXAM_NO
				 , c1.SCRN_STG_FG AS SCRN_STG_FG
				 , c1.SELECT_ELEMNT_FG AS SELECT_ELEMNT_FG
				 , NVL(A.STG1_GENRL_SELECT_CHG_YN, 'N') AS GENRL_SELECT_CHG_YN
			  FROM V_ESIN600 A
			 WHERE A.COLL_UNIT_NO = c1.COLL_UNIT_NO
			   AND NOT EXISTS (
						SELECT 1
						  FROM ESIN604 B
						 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
						   AND A.EXAM_NO = B.EXAM_NO
						   AND B.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
						   AND B.SCRN_STG_FG = c1.SCRN_STG_FG
				   )
            ;
		END IF;
                
		UPDATE ESIN604 a
		   SET FL_SCOR = (CASE WHEN a.SELECT_ELEMNT_FG IN ('U027100007', 'U027100005') AND NVL(a.MEMB_1_SCOR_VAL, 0) < 'A'   --서류이거나 면접인경우
                                    THEN (  CASE WHEN c1.MEMB_RCNT = 1 THEN TRUNC(NVL(a.MEMB_1_SCOR_VAL, 0) / c1.MEMB_RCNT, 2)
                                                 WHEN c1.MEMB_RCNT = 2 THEN TRUNC((NVL(a.MEMB_1_SCOR_VAL, 0) + NVL(a.MEMB_2_SCOR_VAL, 0)) / c1.MEMB_RCNT , 2)
                                                 WHEN c1.MEMB_RCNT = 3 THEN TRUNC((NVL(a.MEMB_1_SCOR_VAL, 0) + NVL(a.MEMB_2_SCOR_VAL, 0) + NVL(a.MEMB_3_SCOR_VAL, 0)) / c1.MEMB_RCNT, 2)
                                                 WHEN c1.MEMB_RCNT = 4 THEN TRUNC((NVL(a.MEMB_1_SCOR_VAL, 0) + NVL(a.MEMB_2_SCOR_VAL, 0) + NVL(a.MEMB_3_SCOR_VAL, 0) + NVL(a.MEMB_4_SCOR_VAL, 0)) / c1.MEMB_RCNT, 2)
                                                 WHEN c1.MEMB_RCNT = 5 THEN TRUNC((NVL(a.MEMB_1_SCOR_VAL, 0) + NVL(a.MEMB_2_SCOR_VAL, 0) + NVL(a.MEMB_3_SCOR_VAL, 0) + NVL(a.MEMB_4_SCOR_VAL, 0) + NVL(a.MEMB_5_SCOR_VAL, 0)) / c1.MEMB_RCNT, 2)
                                                 WHEN c1.MEMB_RCNT = 6 THEN TRUNC((NVL(a.MEMB_1_SCOR_VAL, 0) + NVL(a.MEMB_2_SCOR_VAL, 0) + NVL(a.MEMB_3_SCOR_VAL, 0) + NVL(a.MEMB_4_SCOR_VAL, 0) + NVL(a.MEMB_5_SCOR_VAL, 0) + NVL(a.MEMB_6_SCOR_VAL, 0)) / c1.MEMB_RCNT, 2)
                                            END )
							   WHEN a.SELECT_ELEMNT_FG = 'U027100014' 
                                    THEN TRUNC(( SELECT x.TT_MRKS_AVG_SCOR FROM ESIN602 x
                                                  WHERE x.COLL_UNIT_NO = ( SELECT t1.REAL_COLL_UNIT_NO FROM V_ESIN600 t1
                                                                            WHERE t1.COLL_UNIT_NO = c1.COLL_UNIT_NO
                                                                              AND t1.EXAM_NO = a.EXAM_NO
                                                                              AND NVL(t1.STG1_GENRL_SELECT_CHG_YN, 'N') = a.GENRL_SELECT_CHG_YN )
                                                    AND x.EXAM_NO = a.EXAM_NO
                                                    AND x.MRKS_ADPT_YN = 'Y'
                                                    AND ROWNUM = 1 ), 2)
							   ELSE FL_SCOR
						  END )
			 , GRD_VAL = (CASE WHEN SELECT_ELEMNT_FG IN ('U027100007', 'U027100005') AND c1.SELECT_ELEMNT_DISQ_GRD_FG IS NOT NULL THEN MEMB_1_SCOR_VAL END)
			 , EXCH_PCT_SCOR = (CASE WHEN SELECT_ELEMNT_FG = 'U027100014' 
                                          THEN ( SELECT TRUNC(SUM(x.PCT_SCOR)/COUNT(1), 2)
                                                   FROM ESIN602 x
                                                  WHERE x.COLL_UNIT_NO = ( SELECT t1.REAL_COLL_UNIT_NO
                                                                             FROM V_ESIN600 t1
                                                                            WHERE t1.COLL_UNIT_NO = c1.COLL_UNIT_NO
                                                                              AND t1.EXAM_NO = a.EXAM_NO
                                                                              AND NVL(t1.STG1_GENRL_SELECT_CHG_YN, 'N') = a.GENRL_SELECT_CHG_YN )
                                                    AND x.EXAM_NO = a.EXAM_NO AND x.MRKS_ADPT_YN = 'Y' )
								END )
		 WHERE COLL_UNIT_NO = c1.COLL_UNIT_NO
		   AND SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
		   AND SCRN_STG_FG = c1.SCRN_STG_FG
		   ;

		SELECT MAX(FL_SCOR)
			 , MIN(FL_SCOR)
		  INTO V_TMP1
			 , V_TMP2
		  FROM ESIN604
		 WHERE COLL_UNIT_NO = C1.COLL_UNIT_NO
		   AND SELECT_ELEMNT_FG = C1.SELECT_ELEMNT_FG
		   ;

		--- 결격처리
		UPDATE ESIN604 a
           
        /* START 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
		   --- 배점이 있는 경우
		   SET a.EXCH_SCOR = (CASE WHEN NVL(c1.SELECT_ELEMNT_SCOR_SCOR, 0) > 0 
                                        THEN CASE WHEN c1.EXCH_MTHD_FG = 'U028700001' THEN ( -- 환산표 사용 방식 
                                                                                             SELECT CASE WHEN c1.SELECT_FG = 'U025700003' THEN TRUNC(NEW_TEPS_TO_SCOR,1) ELSE NEW_TEPS_TO_SCOR END
                                                                                               FROM ESIN540 x , ESIN520 y
                                                                                              WHERE x.SELECT_YY = c1.SELECT_YY
                                                                                                AND x.SELECT_FG = c1.SELECT_FG
                                                                                                AND x.COLL_FG = c1.COLL_FG
                                                                                                AND x.MRKS_MOD_CHART_FG = c1.MRKS_MOD_CHART_FG
                                                                                                AND x.MRKS_MOD_FG = c1.MRKS_MOD_FG
                                                                                                AND y.COLL_UNIT_NO = c1.COLL_UNIT_NO
                                                                                                AND x.APLY_QUAL_FG||x.DETA_APLY_QUAL_FG||x.APLY_CORS_FG||x.APLY_COLG_FG||x.APLY_COLL_UNIT_CD LIKE y.APLY_QUAL_FG||y.DETA_APLY_QUAL_FG||y.APLY_CORS_FG||y.APLY_COLG_FG||y.APLY_COLL_UNIT_CD||'%'
                                                                                                AND a.FL_SCOR BETWEEN FR_VAL AND TO_VAL )
                                                           -- defalut로 계산 방식(U028700002) --면접/서류/전공이론/실기/전공선택1/전공선택2/전공선택3
                                                 ELSE CASE WHEN SELECT_ELEMNT_FG IN ('U027100007', 'U027100005', 'U027100008', 'U027100010', 'U027100011', 'U027100012', 'U027100017', 'U027100018', 'U027100019') 
                                                                THEN CASE WHEN c1.SELECT_FG = 'U025700003' 
                                                                               THEN ( TRUNC(a.FL_SCOR * (c1.SELECT_ELEMNT_SCOR_SCOR - NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0)) / c1.SELECT_ELEMNT_FMAK_SCOR + NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0), 1) )
                                                                          ELSE ( TRUNC(a.FL_SCOR * (c1.SELECT_ELEMNT_SCOR_SCOR - NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0)) / c1.SELECT_ELEMNT_FMAK_SCOR + NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0), 2) )      
                                                                     END 
                                                           -- 학업성적 -- 100점 만점 기준
                                                           WHEN SELECT_ELEMNT_FG = 'U027100014' 
                                                                THEN CASE WHEN NVL(a.EXCH_PCT_SCOR, 0) > 0 
                                                                               THEN CASE WHEN c1.SELECT_FG = 'U025700003' 
                                                                                              THEN ( TRUNC(a.EXCH_PCT_SCOR * (c1.SELECT_ELEMNT_SCOR_SCOR - NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0)) / 100 + NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0), 1))
                                                                                         ELSE ( TRUNC(a.EXCH_PCT_SCOR * (c1.SELECT_ELEMNT_SCOR_SCOR - NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0)) / 100 + NVL(c1.SELECT_ELEMNT_BASE_SCOR, 0), 2)) 
                                                                                    END
                                                                          ELSE ( SELECT CASE WHEN c1.SELECT_FG = 'U025700003' 
                                                                                                  THEN (TRUNC(a.FL_SCOR * (c1.SELECT_ELEMNT_FMAK_SCOR - NVL(NULL, 0)) / NVL(f.USR_DEF_2, 1) + NVL(0, 0), 1))
                                                                                             ELSE (TRUNC(a.FL_SCOR * (c1.SELECT_ELEMNT_FMAK_SCOR - NVL(NULL, 0)) / NVL(f.USR_DEF_2, 1) + NVL(0, 0), 2))
                                                                                        END
                                                                                   FROM BSNS011 f, ESIN602 g
                                                                                  WHERE f.GRP_CD = 'U0265'
                                                                                    AND g.COLL_UNIT_NO = c1.COLL_UNIT_NO
                                                                                    AND g.EXAM_NO = a.EXAM_NO
                                                                                    AND f.CMMN_CD = g.MRKS_SYSTEM_FG
                                                                                    AND g.MRKS_ADPT_YN ='Y'
                                                                               )
                                                                     END
                                                           ELSE 0
                                                      END
                                            END
							  END)
        /* END 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
                              
		 WHERE a.COLL_UNIT_NO = c1.COLL_UNIT_NO
		   AND a.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
		   AND a.SCRN_STG_FG = c1.SCRN_STG_FG
		   ;
		-- 사용자가 입력한 경격은 업데이트 하지 않는다.

		IF  IN_SCRN_STG_FG  = 'U027200002' THEN
			UPDATE ESIN604 x
			   SET x.FL_DISQ_FG = (CASE WHEN c1.SELECT_ELEMNT_DISQ_GRD_FG IS NOT NULL THEN (
											SELECT 'U027700005' --- 과락
											  FROM BSNS011 a
												 , BSNS011 b
											 WHERE a.GRP_CD = 'U0276'
											   AND a.CMMN_CD = c1.SELECT_ELEMNT_DISQ_GRD_FG -- 서류과락등급 'U024800008'
											   AND a.GRP_CD = b.GRP_CD
											   AND a.USR_DEF_1 < b.USR_DEF_1
											   AND b.CMMN_CD = (
															SELECT y.CMMN_CD
															  FROM BSNS011 y
															 WHERE y.GRP_CD = 'U0276'
															   AND y.USR_DEF_2 = x.GRD_VAL
												   )
										)
										WHEN NVL(c1.SELECT_ELEMNT_DISQ_SCOR, 0) > 0 AND x.FL_SCOR < c1.SELECT_ELEMNT_DISQ_SCOR THEN 'U027700005' -- 과락
								   END)
				 , x.MOD_ID = IN_MOD_ID
				 , x.MOD_DTTM = SYSDATE
				 , x.MOD_IP = IN_MOD_IP
			 WHERE x.COLL_UNIT_NO = c1.COLL_UNIT_NO
			   AND x.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
			   AND x.SCRN_STG_FG = c1.SCRN_STG_FG
			   AND NVL(x.FL_DISQ_FG, 'X') IN ('X', 'U027700005')
			   AND NOT EXISTS (
						SELECT 1
						  FROM ESIN606 A
						 WHERE A.COLL_UNIT_NO = x.COLL_UNIT_NO
						   AND A.EXAM_NO = x.EXAM_NO
						   AND NVL(A.PREF_SLT_YN, 'N') = 'Y'
				   )
			;
		ELSE
			UPDATE ESIN604 x
			   SET x.FL_DISQ_FG = (CASE WHEN c1.SELECT_ELEMNT_DISQ_GRD_FG IS NOT NULL THEN (
											SELECT 'U027700005' --- 과락
											  FROM BSNS011 a
												 , BSNS011 b
											 WHERE a.GRP_CD = 'U0276'
											   AND a.CMMN_CD = c1.SELECT_ELEMNT_DISQ_GRD_FG -- 서류과락등급 'U024800008'
											   AND a.GRP_CD = b.GRP_CD
											   AND a.USR_DEF_1 < b.USR_DEF_1
											   AND b.CMMN_CD = (
														SELECT y.CMMN_CD
														  FROM BSNS011 y
														 WHERE y.GRP_CD = 'U0276'
														   AND y.USR_DEF_2 = x.GRD_VAL
												   )
										)
										WHEN nvl(c1.SELECT_ELEMNT_DISQ_SCOR, 0) > 0 and x.FL_SCOR < c1.SELECT_ELEMNT_DISQ_SCOR THEN 'U027700005' -- 과락
								   END)
				 , x.MOD_ID = IN_MOD_ID
				 , x.MOD_DTTM = SYSDATE
				 , x.MOD_IP = IN_MOD_IP
			 WHERE x.COLL_UNIT_NO = c1.COLL_UNIT_NO
			   AND x.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
			   AND x.SCRN_STG_FG = c1.SCRN_STG_FG
			   AND NVL(x.FL_DISQ_FG, 'X') IN ('X', 'U027700005')
			;
		END IF;
	END LOOP;

	OUT_RTN := 0;
	OUT_MSG := '처리에 성공하였습니다.';
	
	EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;  
    RETURN;
END SP_ESIN604_OTH_RST_CREA;
/
