CREATE OR REPLACE PROCEDURE SP_ESIN604_ENG_CREA
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
	프로그램명	: SP_ESIN604_ENG_CREA
	수행목적	: 환산점수 계산, 결격여부 생성.
	수행결과	: ESIN603(외국어성적) -> ESIN604(성적)
------------------------------------------------------------------------------
	수정일자		수정자		수정내용
------------------------------------------------------------------------------
	2019.12.18	유준식		최초 작성
	2019.12.27	박원희		프로시저 오류 수정
    2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요. 
******************************************************************************/
       
-- 화면에서 받은 파라미터로 대상 모집단위를 구한다. 
CURSOR CUR1 IS
    SELECT COLL_UNIT_NO
         , IN_SCRN_STG_FG AS SCRN_STG_FG    -- 사정단계
         , A.SELECT_YY
         , A.SELECT_FG
         , A.COLL_FG
         , A.APLY_QUAL_FG
         , A.APLY_CORS_FG
         , 'U027100009' AS SELECT_ELEMNT_FG -- 영어성적
      FROM ESIN520 A
     WHERE A.SELECT_YY = IN_SELECT_YY
       AND A.SELECT_FG = IN_SELECT_FG
       AND A.COLL_FG = IN_COLL_FG
       AND A.APLY_QUAL_FG = NVL(IN_APLY_QUAL_FG, A.APLY_QUAL_FG)
       AND A.APLY_COLG_FG = NVL(IN_APLY_COLG_FG, A.APLY_COLG_FG)
       AND A.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, A.APLY_CORS_FG)
       AND A.COLL_UNIT_NO = NVL(IN_COLL_UNIT_NO, A.COLL_UNIT_NO)
       AND EXISTS (
                SELECT 1
                  FROM ESIN603 X
                 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
                   AND X.EXAM_NO = NVL(IN_EXAM_NO, X.EXAM_NO)
                   AND X.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002', 'U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009', 'U027800014')   -- TEPS, OLD_TEPS, TOEFL PBT, TOEFL CBT, TOEFL IBT, TOEFL_BEST, TOEIC, 면제
           )
    ;

BEGIN           
    FOR C1 IN CUR1 LOOP
        IF IN_EXAM_NO IS NULL THEN
            DELETE
              FROM ESIN604 A
             WHERE A.COLL_UNIT_NO = c1.COLL_UNIT_NO
               AND A.SCRN_STG_FG = c1.SCRN_STG_FG
               AND A.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
            ;
        ELSE
            DELETE
              FROM ESIN604 A
             WHERE A.COLL_UNIT_NO = c1.COLL_UNIT_NO
               AND A.SCRN_STG_FG = c1.SCRN_STG_FG
               AND A.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
               AND A.EXAM_NO = IN_EXAM_NO
            ;
        END IF;
        
        INSERT INTO ESIN604
        (	COLL_UNIT_NO
        ,	EXAM_NO
        ,	SCRN_STG_FG
        ,	SELECT_ELEMNT_FG
        ,	GENRL_SELECT_CHG_YN
        ,	FL_SCOR
        ,	GRD_VAL
        ,	EXCH_SCOR
        ,	FL_DISQ_FG
        ,	INPT_ID
        ,	INPT_DTTM
        ,   INPT_IP
        ,	EXCH_PCT_SCOR
        ,	NEW_TEPS_EXCH_SCOR
        )
        WITH t1 AS (
            SELECT b.COLL_UNIT_NO
                 , c1.SCRN_STG_FG AS SCRN_STG_FG
                 , c1.SELECT_YY AS SELECT_YY
                 , c1.SELECT_FG AS SELECT_FG
                 , c1.COLL_FG AS COLL_FG
                 , NVL(b.STG1_GENRL_SELECT_CHG_YN, 'N') AS GENRL_SELECT_CHG_YN
                 , c1.SELECT_ELEMNT_FG AS SELECT_ELEMNT_FG
                 , a.EXAM_NO
                 , a.FRN_LANG_VLD_EXAM_FG
                 , a.VLD_EXAM_PERF_DT
                 , b.HEAR_HIND_YN
                 , CASE WHEN b.HEAR_HIND_YN = 'Y' AND a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002') THEN
                                    -- teps 이고 청각장애인 경우
                                    CASE WHEN TO_NUMBER(a.VLD_EXAM_PERF_DT) < TO_NUMBER('20180512') THEN TRUNC(990 * (NVL(a.GRMR_SCOR, 0) + NVL(a.VCBLR_SCOR, 0) + NVL(a.RC_SCOR, 0)) / 594, 2)
                                         ELSE TRUNC(600 * (NVL(a.GRMR_SCOR, 0) + NVL(a.VCBLR_SCOR, 0) + NVL(a.RC_SCOR, 0)) / 360, 2)
                                    END
                        ELSE NVL(a.VLD_EXAM_ACQ_SCOR, 0)
                   END AS VLD_EXAM_ACQ_SCOR
                 , c.SELECT_ELEMNT_DISQ_SCOR
                 , c.EXCH_MTHD_FG
                 , c.SELECT_ELEMNT_FMAK_SCOR
                 , c.SELECT_ELEMNT_BASE_SCOR
                 , c.SELECT_ELEMNT_SCOR_SCOR
                 , c.SELECT_ELEMNT_DISQ_ADPT_YN
                 , NVL(a.ENG_EXMP_YN, 'N') AS ENG_EXMP_YN
              FROM ESIN603 a
                 , V_ESIN600 b
                 , ESIN521 c
             WHERE c.COLL_UNIT_NO = c1.COLL_UNIT_NO
               AND a.COLL_UNIT_NO = b.REAL_COLL_UNIT_NO
               AND a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002', 'U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009', 'U027800014')
               AND a.EXAM_NO = b.EXAM_NO
               AND a.EXAM_NO = NVL(IN_EXAM_NO, b.EXAM_NO)
               AND b.COLL_UNIT_NO = c.COLL_UNIT_NO
               AND c.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG -- 영어성적
               AND c.ADPT_STG_FG = c1.SCRN_STG_FG
               AND a.FL_ADPT_YN = 'Y'
               AND EXISTS (
                        SELECT 1
                          FROM ESIN603 X
                         WHERE X.COLL_UNIT_NO = B.REAL_COLL_UNIT_NO
                           AND X.EXAM_NO = NVL(IN_EXAM_NO, X.EXAM_NO)
                           AND X.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002', 'U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009', 'U027800014')
                )
        ), t2 AS (
            SELECT a.COLL_UNIT_NO
                 , a.SCRN_STG_FG
                 , a.SELECT_YY
                 , a.SELECT_FG
                 , a.COLL_FG
                 , a.SELECT_ELEMNT_FG
                 , a.GENRL_SELECT_CHG_YN
                 , a.EXAM_NO
                 , a.FRN_LANG_VLD_EXAM_FG
                 , a.VLD_EXAM_PERF_DT
                 , a.VLD_EXAM_ACQ_SCOR
                 , a.HEAR_HIND_YN
                 , CASE WHEN a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002') THEN 
                                    CASE WHEN a.VLD_EXAM_PERF_DT < '20180512' THEN (
                                                SELECT NVL(MAX(z.EXCH_SCOR), 0)
                                                  FROM ESIN542 z
                                                 WHERE a.VLD_EXAM_ACQ_SCOR BETWEEN z.FR_VAL AND z.TO_VAL
                                         )
                                         ELSE a.VLD_EXAM_ACQ_SCOR
                                    END
                        WHEN a.FRN_LANG_VLD_EXAM_FG IN ('U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009') THEN (
                                    --- ibt_toefl/cbt/toeic
                                    SELECT NVL(MAX(x.NEW_TEPS_TO_SCOR), 0)
                                      FROM ESIN540 x
                                         , ESIN520 y
                                     WHERE x.SELECT_YY = a.SELECT_YY
                                       AND x.SELECT_FG = a.SELECT_FG
                                       AND x.COLL_FG = a.COLL_FG
                                       AND x.MRKS_MOD_CHART_FG = 'U027500001' -- 영어
                                       AND x.MRKS_MOD_FG = a.FRN_LANG_VLD_EXAM_FG -- ibt toefl
                                       AND y.COLL_UNIT_NO = a.COLL_UNIT_NO
                                       AND y.APLY_QUAL_FG LIKE x.APLY_QUAL_FG||'%'
                                       AND y.DETA_APLY_QUAL_FG LIKE x.DETA_APLY_QUAL_FG||'%'
                                       AND y.APLY_CORS_FG LIKE x.APLY_CORS_FG||'%'
                                       AND y.APLY_COLG_FG LIKE x.APLY_COLG_FG||'%'
                                       AND y.APLY_COLL_UNIT_CD LIKE x.APLY_COLL_UNIT_CD||'%'
                                       AND a.VLD_EXAM_ACQ_SCOR BETWEEN x.FR_VAL AND x.TO_VAL
                        )
                        WHEN a.FRN_LANG_VLD_EXAM_FG = 'U027800014' THEN (
                                    SELECT NVL(X.ENG_DETM_SCOR, 0)
                                      FROM ESIN521 X
                                     WHERE X.COLL_UNIT_NO = a.COLL_UNIT_NO
                                       AND X.ADPT_STG_FG = a.SCRN_STG_FG
                                       AND X.SELECT_ELEMNT_FG = 'U027100009'
                        )
                  END AS NEW_TEPS_EXCH_SCOR
                , a.SELECT_ELEMNT_DISQ_SCOR
                , a.EXCH_MTHD_FG
                , a.SELECT_ELEMNT_FMAK_SCOR
                , a.SELECT_ELEMNT_BASE_SCOR
                , a.SELECT_ELEMNT_SCOR_SCOR
                , a.ENG_EXMP_YN
             FROM t1 a
         GROUP BY a.COLL_UNIT_NO
                , a.SCRN_STG_FG
                , a.SELECT_YY
                , a.SELECT_FG
                , a.COLL_FG
                , a.SELECT_ELEMNT_FG
                , a.GENRL_SELECT_CHG_YN
                , a.EXAM_NO
                , a.FRN_LANG_VLD_EXAM_FG
                , a.VLD_EXAM_PERF_DT
                , a.VLD_EXAM_ACQ_SCOR
                , a.HEAR_HIND_YN
                , a.SELECT_ELEMNT_DISQ_SCOR
                , a.EXCH_MTHD_FG
                , a.SELECT_ELEMNT_FMAK_SCOR
                , a.SELECT_ELEMNT_BASE_SCOR
                , a.SELECT_ELEMNT_SCOR_SCOR
                , a.ENG_EXMP_YN
        ), t3 AS (
            SELECT a.COLL_UNIT_NO
                 , a.SCRN_STG_FG
                 , a.SELECT_YY                 
                 , a.SELECT_FG                 
                 , a.COLL_FG
                 , a.SELECT_ELEMNT_FG
                 , a.GENRL_SELECT_CHG_YN
                 , a.EXAM_NO
                 , a.FRN_LANG_VLD_EXAM_FG
                 , a.VLD_EXAM_PERF_DT
                 , a.VLD_EXAM_ACQ_SCOR
                 , a.HEAR_HIND_YN
                 , a.NEW_TEPS_EXCH_SCOR
                 , a.SELECT_ELEMNT_DISQ_SCOR
                 , a.EXCH_MTHD_FG
                 , a.SELECT_ELEMNT_FMAK_SCOR
                 , CASE WHEN a.SELECT_ELEMNT_SCOR_SCOR > 0 THEN
                            -- 배점이 있는 경우
                            CASE WHEN a.EXCH_MTHD_FG = 'U028700001' THEN
                                        -- 환산표 사용  방식
                                        CASE WHEN a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002') THEN (
                                                    SELECT MAX(X.EXCH_SCOR)
                                                      FROM ESIN540 x, ESIN520 y
                                                     WHERE x.SELECT_YY = a.SELECT_YY
                                                       AND x.SELECT_FG = a.SELECT_FG
                                                       AND x.COLL_FG = a.COLL_FG
                                                       AND x.MRKS_MOD_CHART_FG = 'U027500001' -- 영어
                                                       AND x.MRKS_MOD_FG = 'U027800001'  -- teps
                                                       AND y.COLL_UNIT_NO = a.COLL_UNIT_NO
                                                       AND y.APLY_QUAL_FG LIKE x.APLY_QUAL_FG||'%'
                                                       AND y.DETA_APLY_QUAL_FG LIKE x.DETA_APLY_QUAL_FG||'%'
                                                       AND y.APLY_CORS_FG LIKE x.APLY_CORS_FG||'%'
                                                       AND y.APLY_COLG_FG LIKE x.APLY_COLG_FG||'%'
                                                       AND y.APLY_COLL_UNIT_CD LIKE x.APLY_COLL_UNIT_CD||'%'
                                                       AND a.NEW_TEPS_EXCH_SCOR BETWEEN x.FR_VAL AND x.TO_VAL
                                            )
                                            ELSE (
                                                    SELECT MAX(X.EXCH_SCOR)
                                                      FROM ESIN540 x, ESIN520 y
                                                     WHERE x.SELECT_YY = a.SELECT_YY
                                                       AND x.SELECT_FG = a.SELECT_FG
                                                       AND x.COLL_FG = a.COLL_FG
                                                       AND x.MRKS_MOD_CHART_FG = 'U027500001' -- 영어
                                                       AND x.MRKS_MOD_FG = a.FRN_LANG_VLD_EXAM_FG --  teps 이외 시험
                                                       AND y.COLL_UNIT_NO = a.COLL_UNIT_NO
                                                       AND y.APLY_QUAL_FG LIKE x.APLY_QUAL_FG||'%'
                                                       AND y.DETA_APLY_QUAL_FG LIKE x.DETA_APLY_QUAL_FG||'%'
                                                       AND y.APLY_CORS_FG LIKE x.APLY_CORS_FG||'%'
                                                       AND y.APLY_COLG_FG LIKE x.APLY_COLG_FG||'%'
                                                       AND y.APLY_COLL_UNIT_CD LIKE x.APLY_COLL_UNIT_CD||'%'
                                                       AND a.VLD_EXAM_ACQ_SCOR BETWEEN x.fr_val AND x.to_val
                                            )
                                        END
                                --- defalut로 계산 방식(U028700002)
                                ELSE TRUNC(a.NEW_TEPS_EXCH_SCOR * (a.SELECT_ELEMNT_SCOR_SCOR - NVL(a.SELECT_ELEMNT_BASE_SCOR, 0)) / a.SELECT_ELEMNT_FMAK_SCOR + NVL(a.SELECT_ELEMNT_BASE_SCOR, 0), 2)
                            END
                            --- 배점이 없는 경우
                        ELSE 0
                   END AS EXCH_SCOR
                 , CASE WHEN NVL(a.SELECT_ELEMNT_DISQ_SCOR, 0) > 0 THEN
                            --- 과락점수가 있으면
                            CASE WHEN a.FRN_LANG_VLD_EXAM_FG = 'U027800014' THEN 'U027700006' -- 시험구분이 면제면
                                 -- 면제가 아니면
                                 ELSE 
                                    CASE WHEN a.NEW_TEPS_EXCH_SCOR < a.SELECT_ELEMNT_DISQ_SCOR THEN 'U027700007'
                                    -- 결격처리
                                    END
                            END
                   END AS FL_DISQ_FG
             FROM t2 a
        )
        --- 환산점수/과락을 구한다.
        SELECT a.COLL_UNIT_NO
             , a.EXAM_NO
             , a.SCRN_STG_FG AS SCRN_STG_FG
             , a.SELECT_ELEMNT_FG AS SELECT_ELEMNT_FG
             , a.GENRL_SELECT_CHG_YN AS GENRL_SELECT_CHG_YN
             , a.EXCH_SCOR AS FL_SCOR
             , '' AS GRD_FG
             
             /* START 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
             , CASE WHEN a.SELECT_FG = 'U025700003' THEN TRUNC(a.EXCH_SCOR,1) 
                    ELSE a.EXCH_SCOR 
               END AS EXCH_SCOR
             /* END 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
             
             , a.FL_DISQ_FG
             , IN_INPT_ID AS INPT_ID
             , SYSDATE AS INPT_DTTM
             , IN_INPT_IP AS INPT_IP
             , '' AS EXCH_PCT_SCOR
             , a.NEW_TEPS_EXCH_SCOR
          FROM t3 a
        ;
        
        -- 영어권 대학여부가 체크가 안된 경우는 결격처리
        UPDATE ESIN604 A
           SET A.FL_DISQ_FG = 'U027700007'
             , A.EXCH_SCOR = 0
         WHERE A.COLL_UNIT_NO = c1.COLL_UNIT_NO
           AND A.SCRN_STG_FG = c1.SCRN_STG_FG
           AND A.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG
           AND A.EXAM_NO = NVL(IN_EXAM_NO, A.EXAM_NO)
           AND A.FL_DISQ_FG = 'U027700006'  -- 면제인 경우에만
           -- 학력 대학여부
           AND NOT EXISTS (
                    SELECT 1
                      FROM ESIN602 X
                         , V_ESIN600 Y
                     WHERE X.EXAM_NO = A.EXAM_NO
                       AND Y.COLL_UNIT_NO = A.COLL_UNIT_NO
                       AND X.COLL_UNIT_NO = Y.REAL_COLL_UNIT_NO
                       AND NVL(X.ENG_FLD_COLG_YN, 'N') = 'Y'
               )
           -- 외국어 면제 체크
           AND NOT EXISTS (
                    SELECT 1
                      FROM ESIN603 X
                         , V_ESIN600 Y
                     WHERE X.EXAM_NO = A.EXAM_NO
                       AND Y.COLL_UNIT_NO = A.COLL_UNIT_NO
                       AND X.COLL_UNIT_NO = Y.REAL_COLL_UNIT_NO
                       AND NVL(X.ENG_EXMP_YN, 'N') = 'Y'
               )
           ;
    END LOOP;

	OUT_RTN := 0;
	OUT_MSG := '처리에 성공하였습니다.';
	
	EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;
    RETURN;
END SP_ESIN604_ENG_CREA;
/
