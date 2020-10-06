CREATE OR REPLACE PROCEDURE SP_ESIN604_EET_CREA
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
	프로그램명	: SP_ESIN604_EET_CREA
	수행목적	: 교육입문시험 환산점수 계산, 결격여부 생성.
	수행결과	: ESIN650(교육입문시험) -> ESIN604(성적) 성적 이관
------------------------------------------------------------------------------
	수정일자		수정자		수정내용
------------------------------------------------------------------------------
	2019.12.18	유준식		최초 작성
	2019.12.27	박원희		프로시저 오류 수정
    2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요. 
******************************************************************************/

BEGIN     
    -- 성적 삭제 
	DELETE 
	  FROM ESIN604 X    -- 성적
	 WHERE X.COLL_UNIT_NO IN ( 
				SELECT A.COLL_UNIT_NO
				  FROM ESIN520 A    -- 모집관리단위
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
    
    -- 전형구분 - 치의학대학원 : 1단계합격선발에서 불합격은 계산 미포함
    IF IN_SELECT_FG = 'U025700003' THEN
        -- 성적 생성
        INSERT INTO ESIN604
        (	COLL_UNIT_NO
        ,	EXAM_NO
        ,	SCRN_STG_FG
        ,	SELECT_ELEMNT_FG
        ,	GENRL_SELECT_CHG_YN
        ,	FL_SCOR
        ,	EXCH_SCOR                    
        ,	FL_DISQ_FG
        ,   EXCH_PCT_SCOR
        ,	INPT_ID
        ,	INPT_DTTM
        ,	INPT_IP
        )
        WITH T1 AS (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , B.ADPT_STG_FG
                 , B.SELECT_ELEMNT_FG
                 , B.SELECT_ELEMNT_FMAK_SCOR
                 , B.EXCH_MTHD_FG
                 , B.SELECT_ELEMNT_BASE_SCOR
                 , B.SELECT_ELEMNT_SCOR_SCOR
                 , B.SELECT_ELEMNT_DISQ_ADPT_YN
                 , B.SELECT_ELEMNT_DISQ_SCOR
                 , C.SBJT_1_PCT_SCOR
                 , C.SBJT_2_PCT_SCOR
                 , C.SBJT_3_PCT_SCOR
                 , C.SBJT_4_PCT_SCOR
                 , C.SBJT_5_PCT_SCOR
                 , C.EET_FG
                 , A.STG1_GENRL_SELECT_CHG_YN
                 , A.STG2_GENRL_SELECT_CHG_YN
                 , C.STAD_SCOR_TT_SCOR_SCOR
                 , CASE WHEN C.EET_FG = 'U028000005' THEN TRUNC((SBJT_1_PCT_SCOR * 0.4 + SBJT_2_PCT_SCOR * 0.6) * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) -- LEET 법학적성시험: [(언어이해영역 백분위) × 0.4 + (추리논증영역 백분위) × 0.6] × 0.6
                        WHEN C.EET_FG = 'U028000001' THEN TRUNC((SBJT_1_STAD_SCOR + SBJT_2_STAD_SCOR) / 2, 2) --MDEET
                        WHEN C.EET_FG = 'U028000004' THEN TRUNC((SBJT_1_PCT_SCOR + SBJT_2_PCT_SCOR + SBJT_3_PCT_SCOR + SBJT_4_PCT_SCOR) / 4 * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) --PEET
                        ELSE NULL
                   END AS FL_SCOR
                 , CASE WHEN C.EET_FG = 'U028000005' THEN TRUNC((SBJT_1_PCT_SCOR * 0.4 + SBJT_2_PCT_SCOR * 0.6) * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) -- LEET 법학적성시험: [(언어이해영역 백분위) × 0.4 + (추리논증영역 백분위) × 0.6] × 0.6
                        WHEN C.EET_FG = 'U028000001' THEN TRUNC((SBJT_1_STAD_SCOR + SBJT_1_STAD_SCOR) / 2 , 2) --MDEET
                        WHEN C.EET_FG = 'U028000004' THEN TRUNC((SBJT_1_PCT_SCOR + SBJT_2_PCT_SCOR + SBJT_3_PCT_SCOR + SBJT_4_PCT_SCOR) / 4 * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) --PEET
                        ELSE NULL
                   END AS EXCH_PCT_SCOR
                   
                 /* START 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
                 , CASE WHEN C.EET_FG = 'U028000005' THEN TRUNC((SBJT_1_PCT_SCOR * 0.4 + SBJT_2_PCT_SCOR * 0.6) * (SELECT_ELEMNT_SCOR_SCOR - SELECT_ELEMNT_BASE_SCOR) / SELECT_ELEMNT_FMAK_SCOR + SELECT_ELEMNT_BASE_SCOR, 1) -- LEET 2개의 과목을 나누어서 계산
                        WHEN C.EET_FG = 'U028000001' THEN DECODE(NVL(STAD_SCOR_TT_SCOR_SCOR, 0), 0, 0, TRUNC((SBJT_1_STAD_SCOR + SBJT_2_STAD_SCOR) / 2 * (SELECT_ELEMNT_SCOR_SCOR - SELECT_ELEMNT_BASE_SCOR) / D.MAX_SCOR + SELECT_ELEMNT_BASE_SCOR, 1)) -- MDEET 2개의 과목을 나누어서 계산 ,
                        WHEN C.EET_FG = 'U028000004' THEN TRUNC((SBJT_1_PCT_SCOR + SBJT_2_PCT_SCOR + SBJT_3_PCT_SCOR + SBJT_4_PCT_SCOR) / 4 * (SELECT_ELEMNT_SCOR_SCOR - SELECT_ELEMNT_BASE_SCOR) / SELECT_ELEMNT_FMAK_SCOR + SELECT_ELEMNT_BASE_SCOR, 1) -- PEET 4개의 과목을 나누어서 계산
                        ELSE NULL                        
                   END AS EXCH_SCOR
                 /* END 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
                   
                  FROM V_ESIN600 A
                     , ESIN521 B
                     , ESIN650 C
                     , (
                        SELECT Z.COLL_UNIT_NO
                             , TRUNC(MAX(NVL(Z.SBJT_1_STAD_SCOR, 0) + NVL(Z.SBJT_2_STAD_SCOR, 0)) / 2, 2) AS MAX_SCOR
                          FROM ESIN650 Z
                         WHERE Z.COLL_UNIT_NO IN (
                                    SELECT X.COLL_UNIT_NO
                                      FROM ESIN520 X
                                     WHERE X.SELECT_YY = IN_SELECT_YY
                                       AND X.SELECT_FG = IN_SELECT_FG
                                       AND X.COLL_FG = IN_COLL_FG
                                       AND X.APLY_QUAL_FG = IN_APLY_QUAL_FG
                                       AND X.APLY_COLG_FG = IN_APLY_COLG_FG
                               )
                      GROUP BY Z.COLL_UNIT_NO
                        ) D
                 WHERE B.COLL_UNIT_NO IN (
                            SELECT X.COLL_UNIT_NO
                              FROM ESIN520 X
                             WHERE X.SELECT_YY = IN_SELECT_YY
                               AND X.SELECT_FG = IN_SELECT_FG
                               AND X.COLL_FG = IN_COLL_FG
                               AND X.APLY_QUAL_FG = IN_APLY_QUAL_FG
                               AND X.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, A.APLY_CORS_FG)
                               AND X.APLY_COLG_FG = IN_APLY_COLG_FG
                       )
                   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND B.SELECT_ELEMNT_FG = 'U027100003'    -- 전형요소구분 : 교육입문시험성적
                   AND NVL(B.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
                   AND B.ADPT_STG_FG = IN_SCRN_STG_FG
                   AND A.REAL_COLL_UNIT_NO = C.COLL_UNIT_NO(+)
                   AND A.EXAM_NO = C.EXAM_NO(+)
                   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO(+)
        )
        SELECT A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.ADPT_STG_FG AS SCRN_STG_FG
             , A.SELECT_ELEMNT_FG
             , NVL(A.STG1_GENRL_SELECT_CHG_YN, 'N')
             , A.FL_SCOR
             , A.EXCH_SCOR
             , CASE WHEN A.EET_FG IS NULL THEN 'U027700003' -- 서류 미제출
                    WHEN A.SELECT_ELEMNT_DISQ_SCOR > A.FL_SCOR THEN 'U027700005' -- 과락-- 원점수 기준 과락 점수
               END AS FL_DISQ_FG
             , A.STAD_SCOR_TT_SCOR_SCOR AS EXCH_PCT_SCOR
             , IN_INPT_ID AS INPT_ID
             , SYSDATE AS INPT_DTTM
             , IN_INPT_IP AS INPT_IP
          FROM T1 A
             , ESIN606 C    -- 합격자정보
         WHERE A.ADPT_STG_FG = IN_SCRN_STG_FG
           AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
           AND A.EXAM_NO = C.EXAM_NO
           AND C.PASS_DISQ_FG = 'U024300005'    -- 합불구분 : 합격
           AND C.SCRN_STG_FG = 'U027200001'     -- 사정단계 : 1단계(1차)
           AND NOT EXISTS (
                    SELECT 1
                      FROM ESIN604 B    -- 성적
                     WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                       AND A.EXAM_NO = B.EXAM_NO
                       AND A.SELECT_ELEMNT_FG = B.SELECT_ELEMNT_FG
                       AND A.ADPT_STG_FG = B.SCRN_STG_FG
              )
        ;
    ELSE
        -- 성적 생성
        INSERT INTO ESIN604
        (	COLL_UNIT_NO
        ,	EXAM_NO
        ,	SCRN_STG_FG
        ,	SELECT_ELEMNT_FG
        ,	GENRL_SELECT_CHG_YN
        ,	FL_SCOR
        ,	EXCH_SCOR
        ,	FL_DISQ_FG
        ,   EXCH_PCT_SCOR
        ,	INPT_ID
        ,	INPT_DTTM
        ,	INPT_IP
        )
        WITH T1 AS (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , B.ADPT_STG_FG
                 , B.SELECT_ELEMNT_FG
                 , B.SELECT_ELEMNT_FMAK_SCOR
                 , B.EXCH_MTHD_FG
                 , B.SELECT_ELEMNT_BASE_SCOR
                 , B.SELECT_ELEMNT_SCOR_SCOR
                 , B.SELECT_ELEMNT_DISQ_ADPT_YN
                 , B.SELECT_ELEMNT_DISQ_SCOR
                 , C.SBJT_1_PCT_SCOR
                 , C.SBJT_2_PCT_SCOR
                 , C.SBJT_3_PCT_SCOR
                 , C.SBJT_4_PCT_SCOR
                 , C.SBJT_5_PCT_SCOR
                 , C.EET_FG
                 , A.STG1_GENRL_SELECT_CHG_YN
                 , A.STG2_GENRL_SELECT_CHG_YN
                 , C.STAD_SCOR_TT_SCOR_SCOR
                 , CASE WHEN C.EET_FG = 'U028000005' THEN TRUNC((SBJT_1_PCT_SCOR * 0.4 + SBJT_2_PCT_SCOR * 0.6) * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) -- LEET 법학적성시험: [(언어이해영역 백분위) × 0.4 + (추리논증영역 백분위) × 0.6] × 0.6
                        WHEN C.EET_FG = 'U028000001' THEN TRUNC((SBJT_1_STAD_SCOR + SBJT_2_STAD_SCOR) / 2, 2) --MDEET
                        WHEN C.EET_FG = 'U028000004' THEN TRUNC((SBJT_1_PCT_SCOR + SBJT_2_PCT_SCOR + SBJT_3_PCT_SCOR + SBJT_4_PCT_SCOR) / 4 * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) --PEET
                        ELSE NULL
                   END AS FL_SCOR
                 , CASE WHEN C.EET_FG = 'U028000005' THEN TRUNC((SBJT_1_PCT_SCOR * 0.4 + SBJT_2_PCT_SCOR * 0.6) * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) -- LEET 법학적성시험: [(언어이해영역 백분위) × 0.4 + (추리논증영역 백분위) × 0.6] × 0.6
                        WHEN C.EET_FG = 'U028000001' THEN TRUNC((SBJT_1_STAD_SCOR + SBJT_1_STAD_SCOR) / 2 , 2) --MDEET
                        WHEN C.EET_FG = 'U028000004' THEN TRUNC((SBJT_1_PCT_SCOR + SBJT_2_PCT_SCOR + SBJT_3_PCT_SCOR + SBJT_4_PCT_SCOR) / 4 * (SELECT_ELEMNT_SCOR_SCOR) / SELECT_ELEMNT_FMAK_SCOR, 2) --PEET
                        ELSE NULL
                   END AS EXCH_PCT_SCOR
                 , CASE WHEN C.EET_FG = 'U028000005' THEN TRUNC((SBJT_1_PCT_SCOR * 0.4 + SBJT_2_PCT_SCOR * 0.6) * (SELECT_ELEMNT_SCOR_SCOR - SELECT_ELEMNT_BASE_SCOR) / SELECT_ELEMNT_FMAK_SCOR + SELECT_ELEMNT_BASE_SCOR, 2) -- LEET 2개의 과목을 나누어서 계산
                        WHEN C.EET_FG = 'U028000001' THEN DECODE(NVL(C.STAD_SCOR_TT_SCOR_SCOR, 0), 0, 0, TRUNC((SBJT_1_STAD_SCOR + SBJT_2_STAD_SCOR) / 2 * (SELECT_ELEMNT_SCOR_SCOR - SELECT_ELEMNT_BASE_SCOR) / D.MAX_SCOR + SELECT_ELEMNT_BASE_SCOR, 2)) -- MDEET 2개의 과목을 나누어서 계산 ,
                        WHEN C.EET_FG = 'U028000004' THEN TRUNC((SBJT_1_PCT_SCOR + SBJT_2_PCT_SCOR + SBJT_3_PCT_SCOR + SBJT_4_PCT_SCOR) / 4 * (SELECT_ELEMNT_SCOR_SCOR - SELECT_ELEMNT_BASE_SCOR) / SELECT_ELEMNT_FMAK_SCOR + SELECT_ELEMNT_BASE_SCOR, 2) -- PEET 4개의 과목을 나누어서 계산
                        ELSE NULL
                   END AS EXCH_SCOR
                  FROM V_ESIN600 A
                     , ESIN521 B
                     , ESIN650 C
                     , (
                        SELECT Z.COLL_UNIT_NO
                             , TRUNC(MAX(NVL(Z.SBJT_1_STAD_SCOR, 0) + NVL(Z.SBJT_2_STAD_SCOR, 0)) / 2, 2) AS MAX_SCOR
                          FROM ESIN650 Z
                         WHERE Z.COLL_UNIT_NO IN (
                                    SELECT COLL_UNIT_NO
                                      FROM ESIN520 X
                                     WHERE X.SELECT_YY = IN_SELECT_YY
                                       AND X.SELECT_FG = IN_SELECT_FG
                                       AND X.COLL_FG = IN_COLL_FG
                                       AND X.APLY_QUAL_FG = IN_APLY_QUAL_FG
                                       AND X.APLY_COLG_FG = IN_APLY_COLG_FG
                               )
                      GROUP BY Z.COLL_UNIT_NO
                        ) D
                 WHERE B.COLL_UNIT_NO IN (
                            SELECT COLL_UNIT_NO
                              FROM ESIN520 X
                             WHERE X.SELECT_YY = IN_SELECT_YY
                               AND X.SELECT_FG = IN_SELECT_FG
                               AND X.COLL_FG = IN_COLL_FG
                               AND X.APLY_QUAL_FG = IN_APLY_QUAL_FG
                               AND X.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, A.APLY_CORS_FG)
                               AND X.APLY_COLG_FG = IN_APLY_COLG_FG
                       )
                   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND B.SELECT_ELEMNT_FG = 'U027100003'
                   AND NVL(B.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
                   AND B.ADPT_STG_FG = IN_SCRN_STG_FG
                   AND A.REAL_COLL_UNIT_NO = C.COLL_UNIT_NO(+)
                   AND A.EXAM_NO = C.EXAM_NO(+)
                   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO(+)
        )
        SELECT A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.ADPT_STG_FG AS SCRN_STG_FG
             , A.SELECT_ELEMNT_FG
             , NVL(A.STG1_GENRL_SELECT_CHG_YN, 'N')
             , A.FL_SCOR
             , A.EXCH_SCOR
             , CASE WHEN A.EET_FG IS NULL THEN 'U027700003' -- 서류 미제출
                    WHEN A.SELECT_ELEMNT_DISQ_SCOR > A.FL_SCOR THEN 'U027700005' -- 과락-- 원점수 기준 과락 점수
               END AS FL_DISQ_FG
             , A.STAD_SCOR_TT_SCOR_SCOR AS EXCH_PCT_SCOR
             , IN_INPT_ID AS INPT_ID
             , SYSDATE AS INPT_DTTM
             , IN_INPT_IP AS INPT_IP
          FROM T1 A
         WHERE A.ADPT_STG_FG = IN_SCRN_STG_FG
           AND NOT EXISTS (
                    SELECT 1
                      FROM ESIN604 B
                     WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                       AND A.EXAM_NO = B.EXAM_NO
                       AND A.SELECT_ELEMNT_FG = B.SELECT_ELEMNT_FG
                       AND A.ADPT_STG_FG = B.SCRN_STG_FG
              )
        ;
    END IF;
  
	OUT_RTN := 0;
	OUT_MSG := '처리에 성공하였습니다.';
	
	EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;
	RETURN;
END SP_ESIN604_EET_CREA;
/
