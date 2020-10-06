CREATE OR REPLACE PROCEDURE SP_ESIN606_FL_CREA
(	IN_SELECT_YY 			IN VARCHAR2 /* 전형년도 */
,	IN_SELECT_FG 			IN VARCHAR2 /* 전형구분 */
,	IN_COLL_FG 				IN VARCHAR2 /* 모집구분 */
,	IN_APLY_QUAL_FG 		IN VARCHAR2 /* 지원자격 */
,	IN_DETA_APLY_QUAL_FG 	IN VARCHAR2 /* 세부지원자격 */
,	IN_APLY_CORS_FG 		IN VARCHAR2 /* 지원과정 */
,	IN_APLY_COLG_FG 		IN VARCHAR2 /* 지원단과대학 */
,	IN_APLY_COLL_UNIT_CD 	IN VARCHAR2 /* 지원모집단위 */
,	IN_INPT_ID 				IN VARCHAR2 /* 입력자 */
,	IN_INPT_IP 				IN VARCHAR2 /* 입력자IP*/
,	OUT_RTN 				OUT INTEGER
,	OUT_MSG 				OUT VARCHAR2
)
IS
/******************************************************************************
	프로그램명	: SP_ESIN606_FL_CREA
	수행목적	: 최종 선발 처리를 한다.
	수행결과	: ESIN606 합격자정보 생성
------------------------------------------------------------------------------
	수정일자     	수정자		수정내용
------------------------------------------------------------------------------
	2019.12.27	박원희		최초 작성
******************************************************************************/

V_STG1_SLT_YN               ESIN520.STG1_SLT_YN%TYPE;
V_COUNT                     NUMBER;
V_SELECT_ELEMNT_FG_GUBN     VARCHAR2(200);
V_IMSI                      VARCHAR2(200);
V_IMSI2                     VARCHAR2(200);
V_IMSI3                     VARCHAR2(200);
V_IMSI4                     VARCHAR2(200);
V_QUERY                     VARCHAR2(4000);
V_SPCMAJ_CNT                NUMBER;
V_SCRN_GRP_COLL_CNT         NUMBER;
V_CNT1                      NUMBER; --타교선발인원
V_CNT2                      NUMBER; --본교선발인원

-- 최종 성적기준정보를 가져온다.
CURSOR CUR_SOR IS
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
	   AND B.SELECT_YY = IN_SELECT_YY
	   AND B.SELECT_FG = IN_SELECT_FG
	   AND B.COLL_FG = IN_COLL_FG
	   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND B.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, B.APLY_CORS_FG)
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
	   AND NVL(A.USE_YN, 'N') = 'Y'   --사용여부
  ORDER BY B.APLY_CORS_FG
		 , NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
		 , A.PREF_RANK
	;

-- 최종 대상자의 순위를 정한다.  년도, 전형구분, 모집구분, 지원자격, 과정, 단대코드, 사정그룹
CURSOR CUR_SOR_RANK IS
	SELECT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , RANK() OVER(
                PARTITION BY A.SELECT_YY
                           , A.SELECT_FG
                           , A.COLL_FG
                           , A.APLY_QUAL_FG
                           , A.APLY_CORS_FG
                           , A.APLY_COLG_FG
                           , NVL(D.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
                    ORDER BY B.TT_SCOR_SCOR DESC
                           , C.SMSC_PSN_BASI_RANK1
                           , C.SMSC_PSN_BASI_RANK2
                           , C.SMSC_PSN_BASI_RANK3
                           , C.SMSC_PSN_BASI_RANK4
                           , C.SMSC_PSN_BASI_RANK5
                           , C.SMSC_PSN_BASI_RANK6
                           , C.SMSC_PSN_BASI_RANK7
                           , C.SMSC_PSN_BASI_RANK8
                           , C.SMSC_PSN_BASI_RANK9
                           , C.SMSC_PSN_BASI_RANK10
		   ) AS TT_SCOR_RANK
	  FROM ESIN600 A    -- 지원자정보
		 , ESIN606 B    -- 합격자정보
		 , ESIN607 C    -- 동점자 우선순위
		 , ESIN520 D    -- 모집단위관리
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.EXAM_NO = B.EXAM_NO
	   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO
	   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND B.EXAM_NO = C.EXAM_NO
	   AND B.SCRN_STG_FG = C.SCRN_STG_FG
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')	-- 사정단계 : 최종, 단계없음
	   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')	-- 결격구분 : 면제도 허용
	   AND NVL(B.PREF_SLT_YN, 'N') = 'N'	--우선선발자제외
	;

-- 예비합격 대상자의 순위를 정한다.
CURSOR CUR_SOR_RANK_STP IS
	SELECT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , RANK() OVER(
                PARTITION BY A.SELECT_YY
                           , A.SELECT_FG
                           , A.COLL_FG
                           , A.APLY_QUAL_FG
                           , A.APLY_CORS_FG
                           , A.APLY_COLG_FG
                           , NVL(D.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
                    ORDER BY B.TT_SCOR_RANK
		   ) AS TT_SCOR_RANK
	  FROM ESIN600 A    -- 지원자정보
		 , ESIN606 B    -- 합격자정보
		 , ESIN607 C    -- 동점자 우선순위
		 , ESIN520 D    -- 모집단위관리
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.EXAM_NO = B.EXAM_NO
	   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND B.EXAM_NO = C.EXAM_NO
	   AND B.SCRN_STG_FG = C.SCRN_STG_FG
	   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')	-- 사정단계 : 최종, 단계없음
	   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')	-- 결격구분 : 면제도 허용
	   AND NVL(B.PREF_SLT_YN, 'N') = 'N'	-- 우선선발자제외
	   AND B.PASS_DISQ_FG = 'U024300006'	-- 합격불합격구분 : 불합격자
	   AND NVL(D.STP_SLT_YN, 'N') = 'Y' -- 충원선발여부
       AND NVL(D.PREPR_PASS_RCNT, 0) > 0	-- 예비순위선발시
	;

-- 사정대상 모집단위를 가져 온다.
CURSOR CUR_SOR_COLL_UNIT_NO IS
	SELECT DISTINCT A.COLL_UNIT_NO
	  FROM ESIN520 A    -- 모집단위관리
		 , ESIN521 B    -- 성적기준정보
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND B.ADPT_STG_FG IN ('U027200002', 'U027200003')    -- 적용단계구분 : 최종, 단계없음
	;

-- 사정그룹코드, 모집인원, 예비합격인원 조회
CURSOR CUR_SOR_SCRN_GRP IS
	SELECT A.SELECT_YY
		 , A.SELECT_FG
		 , A.COLL_FG
		 , A.APLY_QUAL_FG
		 , A.APLY_CORS_FG
		 , A.APLY_COLG_FG
		 , NVL(A.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD) AS SCRN_GRP
		 , SUM(NVL(A.COLL_RCNT, 0)) AS COLL_RCNT
		 , SUM(NVL(A.PREPR_PASS_RCNT, 0)) AS PREPR_PASS_RCNT
	  FROM ESIN520 A    -- 모집단위관리
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
  GROUP BY A.SELECT_YY
		 , A.SELECT_FG
		 , A.COLL_FG
		 , A.APLY_QUAL_FG
		 , A.APLY_CORS_FG
		 , A.APLY_COLG_FG
		 , NVL(A.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
	;

-- 과정, 단과대학, 사정그룹코드 조회
CURSOR CUR_SOR_SCRN_GRP_CD IS
	SELECT DISTINCT A.APLY_CORS_FG
		 , A.APLY_COLG_FG
		 , NVL(A.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD) AS SCRN_GRP_CD
	  FROM ESIN520 A    -- 모집단위관리
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	;

-- 합산과락 조회
CURSOR COR_SOR_ADUP_DISQ_OBJ_YN IS
    WITH V_ESIN521 AS (
        SELECT A.COLL_UNIT_NO
             , B.SELECT_ELEMNT_FG
             , B.ADPT_STG_FG
          FROM ESIN520 A
             , ESIN521 B
         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
           AND NVL(B.ADUP_DISQ_OBJ_YN, 'N') = 'Y'   -- 합산과락여부
           AND A.SELECT_YY = IN_SELECT_YY
           AND A.SELECT_FG = IN_SELECT_FG
           AND A.COLL_FG = IN_COLL_FG
           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
           AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
           AND A.APLY_COLG_FG = IN_APLY_COLG_FG
    ), V_ESIN604 AS (
        SELECT A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.GENRL_SELECT_CHG_YN
             , SUM(A.FL_SCOR) AS FL_SCOR
             , SUM(A.EXCH_SCOR) AS EXCH_SCOR
          FROM ESIN604 A
             , V_ESIN521 B
         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
           AND A.SELECT_ELEMNT_FG = B.SELECT_ELEMNT_FG
           AND A.SCRN_STG_FG = B.ADPT_STG_FG
      GROUP BY A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.GENRL_SELECT_CHG_YN
    )
    SELECT A.COLL_UNIT_NO
         , A.EXAM_NO
         , A.GENRL_SELECT_CHG_YN
         , A.FL_SCOR
         , A.EXCH_SCOR
      FROM V_ESIN604 A
     WHERE A.FL_SCOR < (
                SELECT TRUNC(Z.SELECT_ELEMNT_DISQ_SCOR, 2)
                  FROM ESIN521 Z
                 WHERE Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                   AND Z.SELECT_ELEMNT_FG = 'U027100024'    -- 전형요소구분 : 합산과락
           )
    ;
BEGIN
	--성적계산여부
	--현재년도 자료여부 확인
	SELECT COUNT(*)
	  INTO V_COUNT
	  FROM ESIN606 A    -- 합격자정보
         , ESIN520 B    -- 모집단위관리
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
	   AND B.SELECT_YY = IN_SELECT_YY
	   AND B.SELECT_FG = IN_SELECT_FG
	   AND B.COLL_FG = IN_COLL_FG
	   AND B.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND B.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND B.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
	;

	-- 성적 - 우선설발자의 2단계 과락 적용을 위한 불필요한 성적 삭제
	DELETE
	  FROM ESIN604 A -- 성적
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND A.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
	   AND EXISTS (
				SELECT 1
				  FROM ESIN606 X    -- 합격자 정보
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.SCRN_STG_FG = A.SCRN_STG_FG
				   AND X.EXAM_NO = A.EXAM_NO
				   AND NVL(X.PREF_SLT_YN, 'N') = 'Y'    -- 우선선발여부
		   )
	   AND NOT EXISTS (
				SELECT 1
				  FROM ESIN521 X    -- 성적기준정보
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.ADPT_STG_FG = 'U027200002' -- 사정단계 : 최종
				   AND X.SELECT_ELEMNT_FG = A.SELECT_ELEMNT_FG
				   AND X.SELECT_ELEMNT_USE_YN = 'Y' -- 전형요소사용여부
				   AND X.PREF_SLT_DISQ_ADPT_YN = 'Y'    -- 우선선발과락적용여부
           )
	;

	-- 합격자정보 - 사정처리전 테이블 초기화
	DELETE
	  FROM ESIN606  -- 합격자정보
	 WHERE COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND SCRN_STG_FG IN ('U027200002', 'U027200003')  -- 사정단계 : 최종, 단계없음
	;
    
	DELETE
	  FROM ESIN607  -- 동점자 우선순위
	 WHERE COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- 모집단위관리
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND SCRN_STG_FG IN ('U027200002', 'U027200003')  -- 사정단계 : 최종, 단계없음
	;
    
    -- 합격자 정보
	INSERT INTO ESIN606 -- 합격자 정보
	(	COLL_UNIT_NO
	,	EXAM_NO
	,	SCRN_STG_FG
	,	GENRL_SELECT_CHG_YN
	,	PREF_SLT_YN
	,	INPT_ID
	,	INPT_DTTM
	,	INPT_IP
	)
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , ADPT_STG_FG
		 , NVL(A.STG2_GENRL_SELECT_CHG_YN, 'N')
		 , C.PREF_SLT_YN
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- 지원자정보(VIEW 법전원 일반전환 포함)
		 , ESIN521 B    -- 성적기준정보
		 , ESIN606 C    -- 합격자 정보
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND A.EXAM_NO = C.EXAM_NO
	   AND C.SCRN_STG_FG = 'U027200001' -- 사정단계 : 1단계(1차)
	   AND C.PASS_DISQ_FG = 'U024300005'	-- 합격불합격구분 : 합격자
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200002' -- 적용단계구분 : 최종
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	 UNION
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG
		 , NVL(A.STG2_GENRL_SELECT_CHG_YN, 'N')
		 , NULL AS PREF_SLT_YN
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- 지원자정보(VIEW 법전원 일반전환 포함)
		 , ESIN521 B    -- 성적기준정보
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200003' -- 적용단계구분 : 단계없음
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	;

	--- 1단계 합격자를 동점자 처리기준 테이블로 넣는다.
	INSERT INTO ESIN607 -- 동점자 우선순위
	(	COLL_UNIT_NO
	,	EXAM_NO
	,	SCRN_STG_FG
	,	INPT_ID
	,	INPT_DTTM
	,	INPT_IP
	)
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- 지원자정보(VIEW 법전원 일반전환 포함)
		 , ESIN521 B    -- 성적기준정보
		 , ESIN606 C    -- 합격자 정보
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO(+)
	   AND A.EXAM_NO = C.EXAM_NO
	   AND C.SCRN_STG_FG = 'U027200001' -- 사정단계 : 최종
	   AND C.PASS_DISQ_FG = 'U024300005'	-- 합격불합격구분 : 합격자
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200002' -- 적용단계구분 : 최종
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	 UNION
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- 지원자정보(VIEW 법전원 일반전환 포함)
		 , ESIN521 B    -- 성적기준정보
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200003' -- 적용단계구분 : 단계없음
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	;
    
	-- 2단계 총점계산(= 최종 총점) 삭제
	DELETE
	  FROM ESIN604 A    -- 성적
	 WHERE A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
	   AND A.SELECT_ELEMNT_FG = 'U027100002'    -- 전형요소구분 : 최종총점
	   AND A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- 모집단위관리
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	;

	-- 1단계 합격자를 대상으로 2단계 총점을 생성한다.
	INSERT INTO ESIN604 -- 성적
	(	COLL_UNIT_NO
	,	EXAM_NO
	,	SCRN_STG_FG
	,	SELECT_ELEMNT_FG
	,	GENRL_SELECT_CHG_YN
	,	FL_SCOR
	,	EXCH_SCOR
	,	INPT_ID
	,	INPT_DTTM
	,	INPT_IP
	)
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG AS SCRN_STG_FG
		 , 'U027100002' AS SELECT_ELEMNT_FG -- 전형요소구분 : 최종총점
		 , A.GENRL_SELECT_CHG_YN
		 , TRUNC(SUM(NVL(A.FL_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS FL_SCOR
		 , TRUNC(SUM(NVL(A.EXCH_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS EXCH_SCOR
		 , IN_INPT_ID AS INPT_ID
		 , SYSDATE AS INPD_DTTM
		 , IN_INPT_IP AS INPT_IP
	  FROM ESIN604 A    -- 성적
		 , ESIN521 B    -- 성적기준정보
		 , ESIN521 C    -- 성적기준정보
	 WHERE A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- 모집단위관리
					 , ESIN521 C    -- 성적기준정보
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
				   AND C.ADPT_STG_FG = 'U027200002' -- 적용단계구분 : 최종
				   AND c.SELECT_ELEMNT_FG = 'U027100002' -- 전형요소구분 : 2단계 총점
				   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- 전형요소사용여부
		   )
	   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND A.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
	   AND C.SELECT_ELEMNT_USE_YN = 'Y'
	   AND C.SELECT_ELEMNT_ADUP_FG IN ('U027300002')	-- 전형요소합산구분 : 최종포함
	   AND A.SCRN_STG_FG IN ('U027200001', 'U027200002')	-- 사정단계 : 1단계(1차), 최종
	   AND B.SELECT_ELEMNT_FG = 'U027100002' -- 전형요소구분 : 최종 총점
	   AND NVL(B.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
	   AND B.ADPT_STG_FG = 'U027200002'	-- 적용단계구분 : 최종
	   AND EXISTS (
				SELECT 1
				  FROM ESIN606 B	-- 합격자 정보
				 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
				   AND B.EXAM_NO = A.EXAM_NO
                   AND B.SCRN_STG_FG = 'U027200001' -- 사정단계 : 1단계(1차)
				   AND B.PASS_DISQ_FG  = 'U024300005'   -- 합격불합격구분 : 합격
		   )
	 UNION
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG AS SCRN_STG_FG
		 , 'U027100002' AS SELECT_ELEMNT_FG -- 전형요소구분 : 최종총점
		 , A.GENRL_SELECT_CHG_YN
		 , TRUNC(SUM(NVL(A.FL_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS FL_SCOR
		 , TRUNC(SUM(NVL(A.EXCH_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS EXCH_SCOR
		 , IN_INPT_ID AS INPT_ID
		 , SYSDATE AS INPD_DTTM
		 , IN_INPT_IP AS INPT_IP
	  FROM ESIN604 A    -- 성적
         , ESIN521 B    -- 성적기준정보
         , ESIN521 C    -- 성적기준정보
	 WHERE A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- 모집단위관리
					 , ESIN521 C    -- 성적기준정보
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
				   AND C.ADPT_STG_FG = 'U027200003' -- 적용단계구분 : 단계없음
				   AND C.SELECT_ELEMNT_FG = 'U027100002' -- 전형요소구분 : 최종 총점
				   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
		   )
	   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND A.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
	   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
	   AND C.SELECT_ELEMNT_ADUP_FG IN ('U027300002')	-- 전형요소합산구분 : 최종포함
	   AND A.SCRN_STG_FG = 'U027200003'	-- 사정단계 : 단계 없음
	   AND B.SELECT_ELEMNT_FG = 'U027100002'	-- 전형요소구분 : 최종총점
	   AND B.SELECT_ELEMNT_USE_YN = 'Y'
	   AND B.ADPT_STG_FG = 'U027200003'	--  적용단계구분 : 단계없음
	;

	-- 2단계 총점과 최종총점의 과락처리
	UPDATE ESIN604 A    -- 성적
	   SET A.FL_DISQ_FG = 'U027700005'  -- 최종결격구분 : 과락
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- 모집단위관리
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
				   AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
		   )
	   AND EXISTS (
				SELECT 1
				  FROM ESIN521 X    -- 성적기준정보
					 , ESIN604 Y    -- 성적
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.ADPT_STG_FG IN ('U027200002', 'U027200003')    -- 적용단계구분 : 최종, 단계없음
				   AND NVL(X.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- 전형요소사용여부
				   AND X.ADPT_STG_FG = A.SCRN_STG_FG
				   AND NVL(X.SELECT_ELEMNT_DISQ_ADPT_YN, 'N') = 'Y' -- 전형요소과락반영여부
				   AND X.SELECT_ELEMNT_FG = A.SELECT_ELEMNT_FG
				   AND X.SELECT_ELEMNT_FG IN ('U027100002', 'U027100023')   -- 전형요소구분 : 최종총점, 전체총점
				   AND X.COLL_UNIT_NO = Y.COLL_UNIT_NO
				   AND X.ADPT_STG_FG = Y.SCRN_STG_FG
				   AND X.SELECT_ELEMNT_FG = Y.SELECT_ELEMNT_FG
				   AND Y.EXAM_NO = A.EXAM_NO
				   AND Y.EXCH_SCOR < X.SELECT_ELEMNT_DISQ_SCOR
		   )
	   AND NOT EXISTS (
				SELECT 1
				  FROM ESIN606 X    -- 합격자 정보
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.EXAM_NO = A.EXAM_NO
				   AND X.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
				   AND NVL(X.PREF_SLT_YN, 'N') = 'Y'    -- 우선선발여부
		   )
	;
    
    -- 최종 합산과락 삭제
    DELETE
      FROM ESIN604 A    -- 성적
	 WHERE A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
	   AND A.SELECT_ELEMNT_FG = 'U027100024'    -- 전형요소구분 : 합산과락
	   AND A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- 모집단위관리
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	;
    
    -- 1단계 합산과락 처리
    FOR D1 IN COR_SOR_ADUP_DISQ_OBJ_YN LOOP
        INSERT INTO ESIN604
        (   COLL_UNIT_NO
        ,	EXAM_NO
        ,	SCRN_STG_FG
        ,	SELECT_ELEMNT_FG
        ,   GENRL_SELECT_CHG_YN
        ,	FL_SCOR
        ,	EXCH_SCOR
        ,	FL_DISQ_FG
        ,	INPT_ID
        ,	INPT_DTTM
        ,	INPT_IP
        )
        VALUES
        (   D1.COLL_UNIT_NO
        ,   D1.EXAM_NO
        ,   (
            SELECT MAX(SCRN_STG_FG)
              FROM ESIN604
             WHERE COLL_UNIT_NO = D1.COLL_UNIT_NO
               AND EXAM_NO = D1.EXAM_NO
            )
        ,   'U027100024'
        ,   D1.GENRL_SELECT_CHG_YN
        ,   D1.FL_SCOR
        ,   D1.EXCH_SCOR
        ,   'U027700005'
        ,   IN_INPT_ID
        ,   SYSDATE
        ,   IN_INPT_IP
        )
        ;
    END LOOP;
    
	--최종결격반영
	--BSNS011.USR_DEF2(U0271)순으로 반영
	FOR C1 IN CUR_SOR_COLL_UNIT_NO LOOP
		MERGE INTO ESIN606 A    -- 합격자 정보
		USING (
			WITH T1 AS (
				SELECT SCRN_STG_FG
					 , B.COLL_UNIT_NO
					 , B.EXAM_NO
					 , D.USR_DEF_2
					 , RANK() OVER(PARTITION BY B.EXAM_NO ORDER BY D.USR_DEF_2) AS RA
					 , B.FL_DISQ_FG
                     , NVL(F.QUAL_LACK_YN, 'N') AS QUAL_LACK_YN
				  FROM ESIN604 B    -- 성적
					 , BSNS011 D    -- 공통코드
                     , V_ESIN600 F
				 WHERE B.SELECT_ELEMNT_FG = D.CMMN_CD
				   AND B.COLL_UNIT_NO = C1.COLL_UNIT_NO
                   AND B.COLL_UNIT_NO = F.COLL_UNIT_NO
                   AND B.EXAM_NO = F.EXAM_NO
				   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')	-- 사정단계 : 최종, 단계없음.
				   AND NVL(B.FL_DISQ_FG, 'X') NOT IN ('X', 'U027700006')    -- 최종결격구분 : 불합격
				   AND D.GRP_CD = 'U0271'
                   AND NVL(D.USE_YN, 'N') = 'Y'
			)
			SELECT B.COLL_UNIT_NO
				 , B.SCRN_STG_FG
				 , B.EXAM_NO
				 , B.FL_DISQ_FG
                 , B.QUAL_LACK_YN
			  FROM ESIN606 A    -- 합격자 정보
				 , T1 B
			 WHERE A.COLL_UNIT_NO = C1.COLL_UNIT_NO
			   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음.
			   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
			   AND A.EXAM_NO = B.EXAM_NO
			   AND B.RA = 1
		) B	--- 결격이 동일한 경우
		ON (
				A.COLL_UNIT_NO = B.COLL_UNIT_NO
			AND A.EXAM_NO = B.EXAM_NO
			AND A.SCRN_STG_FG = B.SCRN_STG_FG
		)
		WHEN MATCHED THEN
			UPDATE
			   SET A.DISQ_FG = CASE WHEN B.QUAL_LACK_YN = 'Y' THEN 'U027700007' ELSE B.FL_DISQ_FG END
		;
	END LOOP;

	-- 합격자 정보 - 총점 (2단계 합격자를 대상으로 처리)
	UPDATE ESIN606 A    -- 합격자 정보
	   SET A.TT_SCOR_SCOR = (
				SELECT NVL(SUM(NVL(B.EXCH_SCOR,0)), 0)
				  FROM ESIN604 B
				 WHERE B.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND B.EXAM_NO = A.EXAM_NO
				   AND (B.SELECT_ELEMNT_FG, B.SCRN_STG_FG) IN (
							SELECT C.SELECT_ELEMNT_FG
								 , C.ADPT_STG_FG
							  FROM ESIN521 C    -- 성적기준정보
							 WHERE C.COLL_UNIT_NO = A.COLL_UNIT_NO
							   AND C.SELECT_ELEMNT_ADUP_FG = 'U027300002' -- 전형요소합산구분 : 최종포함
							   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- 전형요소사용여부
					   )
		   )
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- 모집단위관리
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
				   AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
--				   AND APLY_COLL_UNIT_CD LIKE IN_APLY_COLL_UNIT_CD||'%'
		   )
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음.
	   AND NVL(A.PREF_SLT_YN, 'N') = 'N'    -- 우선선발여부
	;

	-- 순위계산을 위한 동점자용 자료생성
	FOR C1 IN CUR_SOR LOOP
		V_QUERY := '';
		V_IMSI := 'SMSC_PSN_BASI_RANK'||C1.PREF_RANK;
		V_IMSI2 := CASE WHEN NVL(V_STG1_SLT_YN, 'N') = 'Y' THEN 'U027200002' ELSE 'U027200003' END;
		V_IMSI3 := CASE WHEN C1.SORT_ORD_FG = 'U027400001' THEN 'DESC' ELSE 'ASC' END;
		V_IMSI4 := '%';
        
        -- 항목코드
		IF C1.ITEM_CD LIKE 'U0271%' THEN
            -- 항목코드 : 영어성적
			IF C1.ITEM_CD = 'U027100009' THEN
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					SELECT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
						 , B.COLL_UNIT_NO
						 , C.EXAM_NO
						 , C.SCRN_STG_FG
						 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY NVL(C.NEW_TEPS_EXCH_SCOR, 0) '||V_IMSI3||') AS RANKS
					  FROM ESIN604 C
						 , ESIN520 B
					 WHERE NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = :A
					   AND C.COLL_UNIT_NO = B.COLL_UNIT_NO
					   AND B.SELECT_YY = :A
					   AND B.SELECT_FG = :A
					   AND B.COLL_FG = :A
					   AND B.APLY_QUAL_FG = :A
					   AND B.APLY_COLG_FG = :A
					   AND B.APLY_CORS_FG = :A
					   AND EXISTS (
								SELECT 1
								  FROM ESIN521 X
								 WHERE X.COLL_UNIT_NO = B.COLL_UNIT_NO
								   AND X.COLL_UNIT_NO = C.COLL_UNIT_NO
								   AND X.ADPT_STG_FG IN (''U027200001'', ''U027200003'')
								   AND X.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
								   AND X.SELECT_ELEMNT_FG = :A
								   AND ROWNUM = 1
						   )
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG IN (''U027200002'', ''U027200003'')
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_GRP_CD, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG, C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG, C1.ITEM_CD;
			ELSE
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					SELECT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
						 , B.COLL_UNIT_NO
						 , C.EXAM_NO
						 , :A AS SCRN_STG_FG
						 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) 
                                       ORDER BY CASE WHEN NVL(C.EXCH_SCOR, 0) = 0 THEN NVL(C.FL_SCOR, 0) ELSE NVL(C.EXCH_SCOR, 0) END ' || V_IMSI3 || ') AS RANKS
					  FROM ESIN604 C
						 , ESIN520 B
					 WHERE NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = :A
					   AND C.COLL_UNIT_NO = B.COLL_UNIT_NO
					   AND B.SELECT_YY = :A
					   AND B.SELECT_FG = :A
					   AND B.COLL_FG = :A
					   AND B.APLY_QUAL_FG = :A
					   AND B.APLY_COLG_FG = :A
					   AND B.APLY_CORS_FG = :A
					   AND C.SCRN_STG_FG = (
								SELECT MAX(X.ADPT_STG_FG)
								  FROM ESIN521 X
								 WHERE X.COLL_UNIT_NO = B.COLL_UNIT_NO
								   AND X.COLL_UNIT_NO = C.COLL_UNIT_NO
								   AND X.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
								   AND X.SELECT_ELEMNT_FG = :A
						   )
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG = B.SCRN_STG_FG
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

                -- 2020-10-06 박용주 석차구할시 환산점수와 점수의 null or 0 값 으로 order by 처리 부분 오류 수정                       
				-- old :		 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY NVL(NVL(C.EXCH_SCOR, 0), NVL(C.FL_SCOR, 0)) '||V_IMSI3||') AS RANKS
				-- new :		 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY case when nvl(c.exch_scor, 0) = 0 then nvl(c.fl_scor, 0) else nvl(c.exch_scor, 0) end '||V_IMSI3||') AS RANKS
                
				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_STG_FG, C1.SCRN_GRP_CD, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG, C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG, C1.ITEM_CD;
			END IF;
		ELSIF C1.ITEM_CD LIKE 'U0281%' THEN
            -- 항목코드 : 생년월일
			IF C1.ITEM_CD = 'U028100001' THEN
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					SELECT C.COLL_UNIT_NO
						 , C.EXAM_NO
						 , :A AS SCRN_STG_FG
						 , RANK() OVER(PARTITION BY NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY REPLACE(C.BIRTH_DT, '-', '') '||V_IMSI3||') AS RANKS
					  FROM V_ESIN600 C
						 , ESIN520 B
					 WHERE C.COLL_UNIT_NO = B.COLL_UNIT_NO
					   AND B.SELECT_YY = :A
					   AND B.SELECT_FG = :A
					   AND B.COLL_FG = :A
					   AND B.APLY_QUAL_FG = :A
					   AND B.APLY_COLG_FG = :A
					   AND B.APLY_CORS_FG = :A
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG = B.SCRN_STG_FG
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_STG_FG, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG,C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG;
            -- 항목코드 : 면접및구술고사+서류평가
			ELSIF C1.ITEM_CD = 'U028100002' THEN
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					WITH T1 AS (
						SELECT DISTINCT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) AS SCRN_GRP_CD
							 , B.COLL_UNIT_NO
							 , C.EXAM_NO
							 , :A AS SCRN_STG_FG
							 , SUM(NVL(C.EXCH_SCOR, 0)) OVER(PARTITION BY B.COLL_UNIT_NO, C.EXAM_NO) AS EXCH_SCOR
						  FROM ESIN604 C
							 , ESIN520 B
						 WHERE NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = :A
						   AND C.COLL_UNIT_NO = B.COLL_UNIT_NO
						   AND B.SELECT_YY = :A
						   AND B.SELECT_FG = :A
						   AND B.COLL_FG = :A
						   AND B.APLY_QUAL_FG = :A
						   AND B.APLY_COLG_FG = :A
						   AND B.APLY_CORS_FG = :A
						   AND C.SELECT_ELEMNT_FG IN ('||'''U027100005'', ''U027100007'''||')
						   AND EXISTS (
									SELECT 1
									  FROM ESIN521 X
									 WHERE X.COLL_UNIT_NO = B.COLL_UNIT_NO
									   AND X.COLL_UNIT_NO = C.COLL_UNIT_NO
									   AND X.ADPT_STG_FG = C.SCRN_STG_FG
									   AND X.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
									   AND X.SELECT_ELEMNT_FG IN ('||'''U027100005'', ''U027100007'''||')
									   AND ROWNUM = 1
							   )
					)
					SELECT SCRN_GRP_CD
						 , COLL_UNIT_NO
						 , EXAM_NO
						 , SCRN_STG_FG
						 , EXCH_SCOR
						 , RANK() OVER(ORDER BY EXCH_SCOR '||V_IMSI3||') AS RANKS
					  FROM T1 A
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG = B.SCRN_STG_FG
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_STG_FG, C1.SCRN_GRP_CD, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG, C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG;
			END IF;
		END IF;
	END LOOP;
    
    -- 법전원/일반(일반전환대상까지) 순위 계산 및 합불
    IF IN_SELECT_FG = 'U025700002' AND IN_APLY_QUAL_FG = 'U024700001' THEN
        -- 타교선발인원 / 본교선발인원(모집인원 + 이월인원 - 타교선발인원)
        SELECT NVL(OTSCH_PASS_RCNT, 0)
             , NVL(COLL_RCNT, 0) + NVL(CYOV_RCNT, 0) - NVL(OTSCH_PASS_RCNT, 0)
          INTO V_CNT1
             , V_CNT2
          FROM ESIN520  -- 모집단위관리
         WHERE SELECT_YY = IN_SELECT_YY
           AND SELECT_FG = IN_SELECT_FG
           AND COLL_FG = IN_COLL_FG
           AND APLY_QUAL_FG = 'U024700001'  -- 지원자격 : 일반
           AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
           AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
           AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
        ;
        
        FOR CUR IN (
            SELECT RANK() OVER(
                    ORDER BY Z.TT_SCOR_SCOR DESC
                        , X.SMSC_PSN_BASI_RANK1
                        , X.SMSC_PSN_BASI_RANK2
                        , X.SMSC_PSN_BASI_RANK3
                        , X.SMSC_PSN_BASI_RANK4
                        , X.SMSC_PSN_BASI_RANK5
                        , X.SMSC_PSN_BASI_RANK6
                        , X.SMSC_PSN_BASI_RANK7
                        , X.SMSC_PSN_BASI_RANK8
                        , X.SMSC_PSN_BASI_RANK9
                        , X.SMSC_PSN_BASI_RANK10
                   ) AS TT_SCOR_RANK
                 , Z.EXAM_NO
                 , Z.COLL_UNIT_NO
                 , Z.TT_SCOR_SCOR
                 , Z.SCRN_STG_FG
              FROM (
                    SELECT T1.EXAM_NO
                         , T1.TT_SCOR_SCOR
                         , T1.RNK
                         , T1.COLL_UNIT_NO
                         , T1.SCRN_STG_FG
                      FROM (
                            SELECT RANK() OVER(
                                    ORDER BY NVL(B.TT_SCOR_SCOR, 0) DESC
                                           , C.SMSC_PSN_BASI_RANK1
                                           , C.SMSC_PSN_BASI_RANK2
                                           , C.SMSC_PSN_BASI_RANK3
                                           , C.SMSC_PSN_BASI_RANK4
                                           , C.SMSC_PSN_BASI_RANK5
                                           , C.SMSC_PSN_BASI_RANK6
                                           , C.SMSC_PSN_BASI_RANK7
                                           , C.SMSC_PSN_BASI_RANK8
                                           , C.SMSC_PSN_BASI_RANK9
                                           , C.SMSC_PSN_BASI_RANK10
                                   ) AS RNK
                                 , A.COLL_UNIT_NO
                                 , A.EXAM_NO
                                 , NVL(B.TT_SCOR_SCOR, 0) AS TT_SCOR_SCOR
                                 , B.SCRN_STG_FG
                              FROM V_ESIN600 A  -- 지원자 정보(법전원 일반전환 대상까지)
                                 , ESIN606 B    -- 합격자 정보
                                 , ESIN607 C    -- 동점자 우선순위
                             WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                               AND A.EXAM_NO = B.EXAM_NO
                               AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
                               AND A.EXAM_NO = C.EXAM_NO
                               AND B.SCRN_STG_FG = C.SCRN_STG_FG
                               AND B.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종단계
                               AND A.SELECT_YY = IN_SELECT_YY
                               AND A.SELECT_FG = IN_SELECT_FG
                               AND A.COLL_FG = IN_COLL_FG
                               AND A.APLY_QUAL_FG = 'U024700001'    -- 지원자격 : 일반
                               AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                               AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                               AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                               AND NVL(A.MSCH_OTSCH_YN, 'N') = 'Y'  -- 본교여부
                               AND EXISTS (
                                        SELECT 1
                                          FROM ESIN606 Z
                                         WHERE Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                                           AND Z.EXAM_NO = A.EXAM_NO
                                           AND Z.SCRN_STG_FG = 'U027200001' -- 사정단계 : 1단계(1차)
                                           AND Z.PASS_DISQ_FG = 'U024300005'    -- 합불 : 합격
                                   )
                           ) T1
                     WHERE T1.RNK <= V_CNT2
                     UNION
                    SELECT T2.EXAM_NO
                         , T2.TT_SCOR_SCOR
                         , T2.RNK
                         , T2.COLL_UNIT_NO
                         , T2.SCRN_STG_FG
                      FROM (
                            SELECT RANK() OVER(
                                    ORDER BY NVL(B.TT_SCOR_SCOR, 0) DESC
                                           , C.SMSC_PSN_BASI_RANK1
                                           , C.SMSC_PSN_BASI_RANK2
                                           , C.SMSC_PSN_BASI_RANK3
                                           , C.SMSC_PSN_BASI_RANK4
                                           , C.SMSC_PSN_BASI_RANK5
                                           , C.SMSC_PSN_BASI_RANK6
                                           , C.SMSC_PSN_BASI_RANK7
                                           , C.SMSC_PSN_BASI_RANK8
                                           , C.SMSC_PSN_BASI_RANK9
                                           , C.SMSC_PSN_BASI_RANK10
                                   ) AS RNK
                                 , A.COLL_UNIT_NO
                                 , A.EXAM_NO
                                 , NVL(B.TT_SCOR_SCOR, 0) AS TT_SCOR_SCOR
                                 , B.SCRN_STG_FG
                              FROM V_ESIN600 A  -- 지원자 정보(법전원 일반전환 대상까지)
                                 , ESIN606 B    -- 합격자 정보
                                 , ESIN607 C    -- 동점자 우선순위
                             WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                               AND A.EXAM_NO = B.EXAM_NO
                               AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
                               AND A.EXAM_NO = C.EXAM_NO
                               AND B.SCRN_STG_FG = C.SCRN_STG_FG
                               AND B.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
                               AND A.SELECT_YY = IN_SELECT_YY
                               AND A.SELECT_FG = IN_SELECT_FG
                               AND A.COLL_FG = IN_COLL_FG
                               AND A.APLY_QUAL_FG = 'U024700001'    -- 지원자격 : 일반
                               AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                               AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                               AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                               AND NVL(A.MSCH_OTSCH_YN, 'N') <> 'Y' -- 타교
                               AND EXISTS (
                                        SELECT 1
                                          FROM ESIN606 Z
                                         WHERE Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                                           AND Z.EXAM_NO = A.EXAM_NO
                                           AND Z.SCRN_STG_FG = 'U027200001' -- 사정단계 : 1단계(1차)
                                           AND Z.PASS_DISQ_FG = 'U024300005'    -- 합불 : 합격
                                   )
                           ) T2
                     WHERE T2.RNK <= V_CNT1
                   ) Z
                 , ESIN607 X    -- 동점자 우선순위
             WHERE Z.COLL_UNIT_NO = X.COLL_UNIT_NO
               AND Z.EXAM_NO = X.EXAM_NO
               AND Z.SCRN_STG_FG = X.SCRN_STG_FG
		) LOOP
            UPDATE ESIN606 X
               SET X.TT_SCOR_RANK = CUR.TT_SCOR_RANK
                 , X.PASS_DISQ_FG = 'U024300005'    -- 합격불합격구분  : 합격
                 , X.PASS_SCRN_FG = 'U028500001'    -- 합격사정구분 : 최초
             WHERE X.COLL_UNIT_NO = CUR.COLL_UNIT_NO
               AND X.EXAM_NO = CUR.EXAM_NO
               AND X.SCRN_STG_FG = CUR.SCRN_STG_FG
            ;
        END LOOP;
        
        -- 불합격자 처리
        FOR CUR1 IN (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SCRN_STG_FG
              FROM ESIN606 A    -- 합격자 정보
                 , V_ESIN600 B  -- 지원자 정보(법전원 일반전환 대상까지)
             WHERE A.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
               AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND A.EXAM_NO = B.EXAM_NO
               AND B.SELECT_YY = IN_SELECT_YY
               AND B.SELECT_FG = IN_SELECT_FG
               AND B.COLL_FG = IN_COLL_FG
               AND B.APLY_QUAL_FG = 'U024700001'    -- 지원자격 : 일반
               AND B.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
               AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
               AND B.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
               AND A.PASS_DISQ_FG IS NULL
        )
        LOOP
            UPDATE ESIN606  -- 합격자 정보
               SET PASS_DISQ_FG = 'U024300006'  -- 합격불합격구분  : 불합격
             WHERE COLL_UNIT_NO = CUR1.COLL_UNIT_NO
               AND EXAM_NO = CUR1.EXAM_NO
               AND SCRN_STG_FG = CUR1.SCRN_STG_FG
        ;
        END LOOP;
        
        --예비합격
        FOR C1 IN CUR_SOR_SCRN_GRP LOOP
            MERGE INTO ESIN606 T1   -- 합격자 정보
            USING (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SCRN_STG_FG
                 , RANK() OVER(
                        PARTITION BY B.SELECT_YY
                                   , B.SELECT_FG
                                   , B.COLL_FG
                                   , B.APLY_QUAL_FG
                                   , B.APLY_CORS_FG
                                   , B.APLY_COLG_FG
                                   , NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
                            ORDER BY NVL(A.TT_SCOR_SCOR, 0) DESC
                   ) AS TT_SCOR_RANK
              FROM ESIN606 A    -- 합격자 정보
                 , ESIN520 B    -- 모집단위관리
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B
                         WHERE B.SELECT_YY = C1.SELECT_YY
                           AND B.SELECT_FG = C1.SELECT_FG
                           AND B.COLL_FG = C1.COLL_FG
                           AND B.APLY_QUAL_FG = C1.APLY_QUAL_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND B.APLY_COLG_FG = C1.APLY_COLG_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP
                   )
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
               AND A.PASS_DISQ_FG = 'U024300006'    -- 합격불합격구분 : 불합격
               AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND NVL(B.STP_SLT_YN, 'N') = 'Y' -- 충원선발여부
            ) T2
            ON (
                    T1.COLL_UNIT_NO = T2.COLL_UNIT_NO
                AND T1.EXAM_NO = T2.EXAM_NO
                AND T1.SCRN_STG_FG = T2.SCRN_STG_FG
                AND T2.TT_SCOR_RANK <= C1.PREPR_PASS_RCNT
            )
            WHEN MATCHED THEN
                UPDATE
                   SET T1.PREPR_PASS_RCPN_YN = 'Y'
                     , T1.PREPR_PASS_RANK = T2.TT_SCOR_RANK
                     , T1.MOD_ID = IN_INPT_ID
                     , T1.MOD_DTTM = SYSDATE
            ;
        END LOOP;
    -- 법전원 일반을 제외 한 나머지 전형구분
    ELSE
        -- 합격자 정보 - 순위 계산
        FOR C1 IN CUR_SOR_SCRN_GRP_CD LOOP
            MERGE INTO ESIN606 X    -- 합격자 정보
            USING (
                SELECT A.COLL_UNIT_NO
                     , B.SCRN_STG_FG
                     , A.EXAM_NO
                     , RANK() OVER(
                            PARTITION BY A.SELECT_YY
                                       , A.SELECT_FG
                                       , A.COLL_FG
                                       , A.APLY_QUAL_FG
                                       , A.APLY_CORS_FG
                                       , A.APLY_COLG_FG
                                       , NVL(D.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
                                ORDER BY B.TT_SCOR_SCOR DESC
                                       , C.SMSC_PSN_BASI_RANK1
                                       , C.SMSC_PSN_BASI_RANK2
                                       , C.SMSC_PSN_BASI_RANK3
                                       , C.SMSC_PSN_BASI_RANK4
                                       , C.SMSC_PSN_BASI_RANK5
                                       , C.SMSC_PSN_BASI_RANK6
                                       , C.SMSC_PSN_BASI_RANK7
                                       , C.SMSC_PSN_BASI_RANK8
                                       , C.SMSC_PSN_BASI_RANK9
                                       , C.SMSC_PSN_BASI_RANK10
                       ) AS TT_SCOR_RANK
                  FROM V_ESIN600 A  -- 지원자 정보(특전원 일반전환대상 포함)
                     , ESIN606 B    -- 합격자 정보
                     , ESIN607 C    -- 동점자 우선순위
                     , ESIN520 D    -- 모집단위관리
                 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND A.EXAM_NO = B.EXAM_NO
                   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO
                   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
                   AND B.EXAM_NO = C.EXAM_NO
                   AND B.SCRN_STG_FG = C.SCRN_STG_FG
                   AND A.SELECT_YY = IN_SELECT_YY
                   AND A.SELECT_FG = IN_SELECT_FG
                   AND A.COLL_FG = IN_COLL_FG
                   AND A.APLY_CORS_FG = C1.APLY_CORS_FG
                   AND A.APLY_COLG_FG = C1.APLY_COLG_FG
                   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
                   AND NVL(B.PREF_SLT_YN, 'N') = 'N'
                   AND B.SCRN_STG_FG  IN ('U027200002', 'U027200003') -- 사정단계 : 최종,단계없음
                   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')   -- 결격구분 : 면제
            ) B
            ON (
                    X.COLL_UNIT_NO = B.COLL_UNIT_NO
                AND X.EXAM_NO = B.EXAM_NO
                AND X.SCRN_STG_FG = B.SCRN_STG_FG
            )
            WHEN MATCHED THEN
                UPDATE
                   SET X.TT_SCOR_RANK = B.TT_SCOR_RANK
            ;
        END LOOP;
    
        --합불처리
        --결격사유 있으면 불합격
        FOR C1 IN CUR_SOR_SCRN_GRP_CD LOOP
            SELECT COUNT(1)
              INTO V_SPCMAJ_CNT
              FROM ESIN606 A    -- 합격자 정보
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B    -- 모집단위관리
                         WHERE B.SELECT_YY = IN_SELECT_YY
                           AND B.SELECT_FG = IN_SELECT_FG
                           AND B.COLL_FG = IN_COLL_FG
                           AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND B.APLY_COLG_FG = IN_APLY_COLG_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
                   )
               AND NVL(A.PREF_SLT_YN, 'N') = 'Y'    -- 우선선발여부
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
            ;
    
            SELECT SUM(NVL(B.COLL_RCNT, 0) + NVL(B.CYOV_RCNT, 0))
              INTO V_SCRN_GRP_COLL_CNT
              FROM ESIN520 B    -- 모집단위관리
             WHERE B.SELECT_YY = IN_SELECT_YY
               AND B.SELECT_FG = IN_SELECT_FG
               AND B.COLL_FG = IN_COLL_FG
               AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
               AND B.APLY_COLG_FG = IN_APLY_COLG_FG
               AND B.APLY_CORS_FG = C1.APLY_CORS_FG
               AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
            ;
    
            MERGE INTO ESIN606 A    -- 합격자 정보
            USING (
                SELECT COLL_UNIT_NO
                     , EXAM_NO
                     , SCRN_STG_FG
                     , RANK1
                  FROM (
                    SELECT COLL_UNIT_NO
                         , EXAM_NO
                         , SCRN_STG_FG
                         , RANK() OVER(ORDER BY TT_SCOR_RANK) AS RANK1
                      FROM ESIN606 A    -- 합격자 정보
                     WHERE A.COLL_UNIT_NO IN (
                                SELECT B.COLL_UNIT_NO
                                  FROM ESIN520 B
                                 WHERE B.SELECT_YY = IN_SELECT_YY
                                   AND B.SELECT_FG = IN_SELECT_FG
                                   AND B.COLL_FG = IN_COLL_FG
                                   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
                                   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
                                   AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                                   AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
                           )
                       AND A.PREF_SLT_YN IS NULL
                       AND A.SCRN_STG_FG  IN ('U027200002', 'U027200003')   -- 사정단계 : 최종, 단계없음
                       AND NVL(A.DISQ_FG, 'X') IN ('X', 'U027700006')   -- 결격구분 : 면제
                       )
                WHERE RANK1 <= (V_SCRN_GRP_COLL_CNT - V_SPCMAJ_CNT)   --- 1단계 모집인원 - 우선순위 합격자 인원
            ) B
            ON (
                    A.COLL_UNIT_NO = B.COLL_UNIT_NO
                AND A.EXAM_NO = B.EXAM_NO
                AND A.SCRN_STG_FG = B.SCRN_STG_FG
            )
            WHEN MATCHED THEN
                UPDATE
                   SET A.PASS_DISQ_FG = 'U024300005'    -- 합격불합격구분 : 합격
                     , A.PASS_SCRN_FG = 'U028500001'    -- 합격사정구분 : 최초
            ;
    
            UPDATE ESIN606 A    -- 합격자 정보
               SET A.PASS_DISQ_FG = 'U024300006'    -- 합격불합격구분 : 불합격
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B    -- 모집단위관리
                         WHERE B.SELECT_YY = IN_SELECT_YY
                           AND B.SELECT_FG = IN_SELECT_FG
                           AND B.COLL_FG = IN_COLL_FG
                           AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND B.APLY_COLG_FG = IN_APLY_COLG_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
                   )
               AND A.PASS_DISQ_FG IS NULL
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
               AND NVL(A.PREF_SLT_YN, 'N') = 'N'    -- 우선선발여부
            ;
        END LOOP;
    
        --예비합격 순위 계산
        FOR C1 IN CUR_SOR_SCRN_GRP LOOP
            MERGE INTO ESIN606 T1   -- 합격자 정보
            USING (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SCRN_STG_FG
                 , RANK() OVER(
                        PARTITION BY B.SELECT_YY
                                   , B.SELECT_FG
                                   , B.COLL_FG
                                   , B.APLY_QUAL_FG
                                   , B.APLY_CORS_FG
                                   , B.APLY_COLG_FG
                                   , NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
                            ORDER BY A.TT_SCOR_RANK
                   ) AS TT_SCOR_RANK
              FROM ESIN606 A    -- 합격자 정보
                 , ESIN520 B    -- 모집단위관리
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B    -- 모집단위관리
                         WHERE B.SELECT_YY = C1.SELECT_YY
                           AND B.SELECT_FG = C1.SELECT_FG
                           AND B.COLL_FG = C1.COLL_FG
                           AND B.APLY_QUAL_FG = C1.APLY_QUAL_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND B.APLY_COLG_FG = C1.APLY_COLG_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP
                   )
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
               AND A.PASS_DISQ_FG = 'U024300006'    -- 합격불합격구분 : 불합격
               AND NVL(A.PREF_SLT_YN, 'N') = 'N'    -- 우선선발여부
               AND NVL(A.DISQ_FG, 'X') IN ('X', 'U027700006')	-- 결격구분 : 면제
               AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND NVL(B.STP_SLT_YN, 'N') = 'Y' -- 충원선발여부
            ) T2
            ON (
                    T1.COLL_UNIT_NO = T2.COLL_UNIT_NO
                AND T1.EXAM_NO = T2.EXAM_NO
                AND T1.SCRN_STG_FG = T2.SCRN_STG_FG
                AND T2.TT_SCOR_RANK <= C1.PREPR_PASS_RCNT
            )
            WHEN MATCHED THEN
                UPDATE
                   SET T1.PREPR_PASS_RCPN_YN = 'Y'
                     , T1.PREPR_PASS_RANK = T2.TT_SCOR_RANK
                     , T1.MOD_ID = IN_INPT_ID
                     , T1.MOD_DTTM = SYSDATE
            ;
        END LOOP;
    END IF;
    
	--최종사정대상인원수, 최종합격인원수, 여석합격인원수, 여석사정대상인원수 초기화
	UPDATE ESIN520 A    -- 모집단위관리
	   SET A.FL_SCRN_OBJ_RCNT = NULL
	     , A.FL_PASS_RCNT = NULL
         , A.VACANT_PASS_RCNT = NULL
         , A.VACANT_SCRN_OBJ_RCNT = NULL
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
	;

	--최종사정대상인원수, 최종합격인원수 반영
	UPDATE ESIN520 A    -- 모집단위관리
	   SET A.FL_SCRN_OBJ_RCNT = (
				SELECT COUNT(*)
				  FROM ESIN606 B    -- 합격자 정보
				 WHERE B.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND B.DISQ_FG IS NULL
				   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
		   )
		 , A.FL_PASS_RCNT = (
				SELECT COUNT(*)
				  FROM ESIN606 B    -- 합격자 정보
				 WHERE B.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')	-- 결격구분 : 면제
				   AND B.PASS_DISQ_FG = 'U024300005'    -- 합격불합격구분 : 합격
				   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
		   )
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
	;

	-- 합격일자, 불합격일자 , 사정일자 반영
	UPDATE ESIN606 A    -- 합격자 정보
	   SET A.PASS_DT = CASE WHEN PASS_DISQ_FG = 'U024300005' THEN TO_CHAR(SYSDATE, 'YYYYMMDD') END  -- 합격불합격구분 : 합격
		 , A.DISQ_DT = CASE WHEN PASS_DISQ_FG = 'U024300006' THEN TO_CHAR(SYSDATE, 'YYYYMMDD') END  -- 합격불합격구분 : 불합격
		 , A.SCRN_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
				   AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
--				   AND APLY_COLL_UNIT_CD LIKE IN_APLY_COLL_UNIT_CD||'%'
		   )
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- 사정단계 : 최종, 단계없음
	   AND NVL(A.PREF_SLT_YN, 'N') = 'Y'    -- 우선선발여부
	;

	--우선선발 불합격처리 (우선선발시 과락 처리)
	UPDATE ESIN606 A    -- 합격자 정보
	   SET A.PASS_DISQ_FG = 'U024300006'    -- 합격불합격구분 : 불합격
		 , A.DISQ_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
		 , A.SCRN_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
         , A.PREF_SLT_YN = 'N'  -- 우선선발여부
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- 모집단위관리
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND NVL(A.PREF_SLT_YN, 'N') = 'Y'
	   AND EXISTS (
				SELECT 1
				  FROM ESIN604 X    -- 성적
					 , ESIN521 B    -- 성적기준정보
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.EXAM_NO = A.EXAM_NO
				   AND X.COLL_UNIT_NO = B.COLL_UNIT_NO
				   AND X.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
				   AND X.SELECT_ELEMNT_FG = B.SELECT_ELEMNT_FG
				   AND X.GENRL_SELECT_CHG_YN = A.GENRL_SELECT_CHG_YN
				   AND NVL(X.FL_DISQ_FG, 'X') NOT IN ('X', 'U027700006')    -- 결격구분 : 면제
				   AND NVL(B.PREF_SLT_DISQ_ADPT_YN, 'N') = 'Y'  -- 우선선발합산여부
		   )
	;

	--우선선발 합격처리 (과락 제외 우선 선발 합격처리)
	UPDATE ESIN606 A    -- 합격자 정보
	   SET A.PASS_DISQ_FG = 'U024300005'    -- 합격불합격구분 : 합격
		 , A.PASS_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
		 , A.SCRN_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- 모집단위관리
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND A.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
	   AND NVL(A.PASS_DISQ_FG, 'X') IN ('X', 'U024300005')  -- 합격불합격구분 : 합격
	   AND NVL(A.PREF_SLT_YN, 'N') = 'Y'
	;
    
    -- 우선선발합격인원수, 최종합격인원수(최종합격인원수 + 우선선발합격인원수) 반영
    UPDATE ESIN520 A    -- 모집단위관리
       SET A.PREF_SLT_PASS_RCNT = (
                SELECT COUNT(*)
                  FROM ESIN606 B    -- 합격자 정보
                 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND NVL(B.PASS_DISQ_FG, 'X') IN ('X', 'U024300005')  -- 합격불합격구분 : 합격
                   AND NVL(B.PREF_SLT_YN, 'N') = 'Y'    -- 우선선발여부
                   AND B.SCRN_STG_FG = 'U027200001' -- 사정단계 : 1단계(1차)
           )
         , A.FL_PASS_RCNT = A.FL_PASS_RCNT + (
                SELECT COUNT(*)
                  FROM ESIN606 B    -- 합격자 정보
                 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND NVL(B.PASS_DISQ_FG, 'X') IN ('X', 'U024300005')  -- 합격불합격구분 : 합격
                   AND NVL(B.PREF_SLT_YN, 'N') = 'Y'    -- 우선선발여부
                   AND B.SCRN_STG_FG = 'U027200001' -- 사정단계 : 1단계(1차)
           )
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
    ;
    
	-- 법학전문대학원
    IF IN_SELECT_FG = 'U025700002' THEN
        -- 1단계일반전형전환여부, 2단계일반전형전환여부 초기화
        UPDATE ESIN600 A    -- 지원자 정보
           SET A.STG1_GENRL_SELECT_CHG_YN = NULL
             , A.STG2_GENRL_SELECT_CHG_YN = NULL
         WHERE A.SELECT_YY = IN_SELECT_YY
           AND A.SELECT_FG = IN_SELECT_FG
           AND A.COLL_FG = IN_COLL_FG
           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG  -- 특별
           AND A.APLY_COLG_FG = IN_APLY_COLG_FG
        ;
        
        -- 지원자격 : 특별
        IF IN_APLY_QUAL_FG = 'U024700002' THEN
             -- T1 : 특별전환 모집단위
            -- T2 : 일반전환 모집단위
            -- T3 : 특별대상자의 영어점수
            -- T4 : 일반전환 과락 점수(20200204011502930931) SELECT_ELEMNT_DISQ_SCOR : 387
            -- T5 : 환산표 기준 과락점수
            MERGE INTO ESIN600 A    -- 지원자 정보
            USING (
                WITH T1 AS (
                    SELECT COLL_UNIT_NO
                         , SELECT_YY
                         , SELECT_FG
                         , COLL_FG
                         , APLY_QUAL_FG
                         , APLY_CORS_FG
                         , APLY_COLG_FG
                         , APLY_COLL_UNIT_CD
                      FROM ESIN520  -- 모집단위관리
                     WHERE SELECT_YY = IN_SELECT_YY
                       AND SELECT_FG = IN_SELECT_FG
                       AND COLL_FG = IN_COLL_FG
                       AND APLY_QUAL_FG = IN_APLY_QUAL_FG
                       AND APLY_COLG_FG = IN_APLY_COLG_FG
                ), T2 AS (
                    SELECT COLL_UNIT_NO
                         , SELECT_YY
                         , SELECT_FG
                         , COLL_FG
                         , APLY_QUAL_FG
                         , APLY_CORS_FG
                         , APLY_COLG_FG
                         , APLY_COLL_UNIT_CD
                      FROM ESIN520  -- 모집단위관리
                     WHERE SELECT_YY = IN_SELECT_YY
                       AND SELECT_FG = IN_SELECT_FG
                       AND COLL_FG = IN_COLL_FG
                       AND APLY_QUAL_FG = 'U024700001'  -- 지원자격 : 일반
                       AND APLY_COLG_FG = IN_APLY_COLG_FG
                ), T3 AS (
                    SELECT X.COLL_UNIT_NO
                         , X.EXAM_NO
                         , X.ENTR_FRN_LANG_MRKS_SEQ
                         , X.FRN_LANG_VLD_EXAM_FG
                         , X.VLD_EXAM_PERF_DT
                         , X.VLD_EXAM_ACQ_SCOR
                      FROM ESIN603 X    -- 외국어 성적
                         , T1 A
                     WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
                       AND X.FRN_LANG_VLD_EXAM_FG IN (
                                SELECT CMMN_CD
                                  FROM BSNS011
                                 WHERE GRP_CD = 'U0278'
                                   AND UP_CD = '01'
                                   AND NVL(USE_YN, 'N') = 'Y'
                           )
                       AND NVL(X.FL_ADPT_YN, 'N') = 'Y' -- 최종반영여부
                       AND EXISTS (
                                SELECT 1
                                  FROM ESIN606 B    -- 합격자 정보
                                 WHERE B.COLL_UNIT_NO = X.COLL_UNIT_NO
                                   AND B.EXAM_NO = X.EXAM_NO
                                   AND B.PASS_DISQ_FG = 'U024300006'    -- 합격불합격구분 : 불합격
                                   AND ROWNUM = 1
                           )
                       AND NOT EXISTS (
                                --- 면제나 결격이외의 것이 없으면
                                SELECT 1
                                  FROM ESIN604 B    -- 성적
                                 WHERE B.COLL_UNIT_NO = X.COLL_UNIT_NO
                                   AND B.EXAM_NO = X.EXAM_NO
                                   AND NVL(B.FL_DISQ_FG, 'X') NOT IN ('X', 'U027700006')    -- 최종결격구분 : 면제
                           )
                ), T4 AS (
                    SELECT A.SELECT_ELEMNT_DISQ_SCOR
                      FROM ESIN521 A    -- 성적기준정보
                         , T2 B
                     WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                       AND A.SELECT_ELEMNT_FG = 'U027100009'    -- 전형요소구분 : 영어성적
                       AND NVL(A.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- 전형요소사용여부
                ), T5 AS (
                    SELECT A.MRKS_MOD_FG
                         , MIN(A.TO_VAL) VAL
                      FROM ESIN540 A
                         , T2 B
                         , T4 C
                     WHERE A.SELECT_YY = IN_SELECT_YY
                       AND A.SELECT_FG = B.SELECT_FG
                       AND A.COLL_FG = B.COLL_FG
                       AND B.APLY_QUAL_FG LIKE A.APLY_QUAL_FG||'%'
                       AND B.APLY_COLG_FG LIKE A.APLY_COLG_FG||'%'
                       AND B.APLY_CORS_FG LIKE A.APLY_CORS_FG||'%'
                       AND B.APLY_COLL_UNIT_CD LIKE A.APLY_CORS_FG||'%'
                       AND A.MRKS_MOD_CHART_FG = 'U027500001'   -- 성적변환표구분 : 영어
                       AND C.SELECT_ELEMNT_DISQ_SCOR BETWEEN A.NEW_TEPS_FR_SCOR AND A.NEW_TEPS_TO_SCOR
                       AND A.MRKS_MOD_FG NOT IN ('U027800001', 'U027800002')    -- 성적변환구분 : TEPS, OLD_TEPS
                  GROUP BY A.MRKS_MOD_FG
                         , A.TO_VAL
                 UNION ALL
                    SELECT 'U027800001' AS MRKS_MOD_FG  -- TEPS
                         , TO_CHAR(C.SELECT_ELEMNT_DISQ_SCOR) VAL
                      FROM T4 C
                 UNION ALL
                    SELECT 'U027800002' AS MRKS_MOD_FG  -- OLD_TEPS
                         , MAX(A.TO_VAL) AS VAL
                      FROM ESIN542 A    -- 구텝스신텝스 환산표
                         , T4 C
                     WHERE A.EXCH_SCOR = C.SELECT_ELEMNT_DISQ_SCOR
                  GROUP BY 'U027800002'
                         , A.TO_VAL
                )
                SELECT COLL_UNIT_NO
                     , EXAM_NO
                     , ENTR_FRN_LANG_MRKS_SEQ
                     , FRN_LANG_VLD_EXAM_FG
                     , VLD_EXAM_PERF_DT
                     , VLD_EXAM_ACQ_SCOR
                     , MRKS_MOD_FG
                     , VAL
                  FROM T3 A
                     , T5 B
                 WHERE A.FRN_LANG_VLD_EXAM_FG = B.MRKS_MOD_FG
                   AND A.VLD_EXAM_ACQ_SCOR > VAL
            ) B
            ON (
                    A.COLL_UNIT_NO = B.COLL_UNIT_NO
                AND A.EXAM_NO = B.EXAM_NO
            )
            WHEN MATCHED THEN
                UPDATE
                   SET A.STG1_GENRL_SELECT_CHG_YN = 'Y'
                     , A.STG2_GENRL_SELECT_CHG_YN = 'Y'
                     , A.MOD_ID = IN_INPT_ID
                     , A.MOD_DTTM = SYSDATE
            ;
        
            -- 모집단위 타교선발인원, 비법학사합격인원
            UPDATE ESIN520 Z    -- 모집단위관리
               SET Z.OTSCH_PASS_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A    -- 지원자 정보
                             , ESIN606 B    -- 합격자 정보
                         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                           AND A.EXAM_NO = B.EXAM_NO
                           AND A.SELECT_YY = IN_SELECT_YY
                           AND A.SELECT_FG = IN_SELECT_FG
                           AND A.COLL_FG = IN_COLL_FG
                           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                           AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                           AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                           AND B.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
                           AND B.PASS_SCRN_FG = 'U028500001'    -- 합격사정구분 : 최초
                           AND B.PASS_DISQ_FG = 'U024300005'    -- 합격불합격구분 : 합격
                           AND NVL(A.MSCH_OTSCH_YN, 'N') <> 'Y' -- 본교타교여부
                   )
                 , Z.NON_LAW_BDEGR_PASS_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A    -- 지원자 정보
                             , ESIN606 B    -- 합격자 정보
                         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                           AND A.EXAM_NO = B.EXAM_NO
                           AND A.SELECT_YY = IN_SELECT_YY
                           AND A.SELECT_FG = IN_SELECT_FG
                           AND A.COLL_FG = IN_COLL_FG
                           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                           AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                           AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                           AND B.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
                           AND B.PASS_SCRN_FG = 'U028500001'    -- 합격사정구분 : 최초
                           AND B.PASS_DISQ_FG = 'U024300005'    -- 합격불합격구분 : 합격
                           AND NVL(A.JURIS_YN, 'N') <> 'Y'  -- 법학여부
                   )
                 , GENRL_CHG_OBJ_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A
                         WHERE NVL(A.STG1_GENRL_SELECT_CHG_YN, 'N') = 'Y'
                           AND A.SELECT_YY = Z.SELECT_YY
                           AND A.SELECT_FG = Z.SELECT_FG
                           AND A.COLL_FG = Z.COLL_FG
                           AND A.APLY_QUAL_FG = Z.APLY_QUAL_FG
                   )
             WHERE Z.SELECT_YY = IN_SELECT_YY
               AND Z.SELECT_FG = IN_SELECT_FG
               AND Z.COLL_FG = IN_COLL_FG
               AND Z.APLY_QUAL_FG = IN_APLY_QUAL_FG
               AND Z.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
               AND Z.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
               AND Z.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
               AND NVL(Z.RPST_SCRN_GRP_YN, 'N') = 'Y'   -- 대표사정그룹여부
            ;
        -- 지원자격 : 일반
        ELSIF IN_APLY_QUAL_FG = 'U024700001' THEN
            UPDATE ESIN520 Z    -- 모집단위관리
               SET Z.NON_LAW_BDEGR_PASS_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A
                             , ESIN606 B
                         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                           AND A.EXAM_NO = B.EXAM_NO
                           AND Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                           AND B.SCRN_STG_FG = 'U027200002' -- 사정단계 : 최종
                           AND B.PASS_SCRN_FG = 'U028500001'    -- 합격사정구분 : 최초
                           AND B.PASS_DISQ_FG = 'U024300005'    -- 합격불합격구분 : 합격
                           AND NVL(A.JURIS_YN, 'N') <> 'Y'  -- 법학여부
                   )
             WHERE Z.SELECT_YY = IN_SELECT_YY
               AND Z.SELECT_FG = IN_SELECT_FG
               AND Z.COLL_FG = IN_COLL_FG
               AND Z.APLY_QUAL_FG = IN_APLY_QUAL_FG
               AND Z.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
               AND Z.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
               AND Z.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
            ;
        END IF;
	END IF;
    
	OUT_MSG := '최종 합격자 선발처리되었습니다.';
	OUT_RTN := 0;

	EXCEPTION WHEN OTHERS THEN
		OUT_MSG := '최종 합격자 선발처리중 오류가 발생하였습니다.' ||SQLCODE;
		OUT_RTN := -1;
		ROLLBACK;
		RAISE;
	RETURN;
END SP_ESIN606_FL_CREA;
/
