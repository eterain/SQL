CREATE OR REPLACE PROCEDURE SP_ESIN604_FRN_LANG_CREA
(   IN_COLL_UNIT_NO            IN ESIN604.COLL_UNIT_NO%TYPE            /* 모집단위번호 */
,    IN_SCRN_STG_FG            IN ESIN604.SCRN_STG_FG%TYPE                /* 사정단계구분 */
,    IN_SELECT_ELEMNT_FG        IN ESIN604.SELECT_ELEMNT_FG%TYPE        /* 전형요소구분 */
,    IN_GENRL_SELECT_CHG_YN    IN ESIN604.GENRL_SELECT_CHG_YN%TYPE        /* 일반전형전환여부 */
,    IN_SELECT_YY            IN ESIN600.SELECT_YY%TYPE                /* 전형년도 */
,   IN_SELECT_FG            IN ESIN600.SELECT_FG%TYPE               /* 전형구분 */
,   IN_COLL_FG              IN ESIN600.COLL_FG%TYPE                    /* 모집구분 */
,   IN_APLY_QUAL_FG         IN ESIN600.APLY_QUAL_FG%TYPE            /* 지원자격 */
,   IN_DETA_APLY_QUAL_FG    IN ESIN600.DETA_APLY_QUAL_FG%TYPE        /* 세부지원자격 */
,   IN_APLY_CORS_FG         IN ESIN600.APLY_CORS_FG%TYPE            /* 과정 */
,   IN_APLY_COLG_FG         IN ESIN600.APLY_COLG_FG%TYPE            /* 단과대학 */
,   IN_APLY_COLL_UNIT_CD    IN ESIN600.APLY_COLL_UNIT_CD%TYPE        /* 모집단위코드 */
,   IN_EXAM_NO              IN ESIN600.EXAM_NO%TYPE                    /* 수험번호 */
,    IN_FL_SCOR                IN ESIN604.FL_SCOR%TYPE                    /* 최종점수 */
,    IN_INPT_ID                IN ESIN604.INPT_ID%TYPE                    /* 생성자 ID */
,    IN_INPT_IP                IN ESIN604.INPT_IP%TYPE                    /* 생성자 IP */
,    IN_MOD_ID                IN ESIN604.MOD_ID%TYPE                    /* 수정자 ID */
,    IN_MOD_IP                IN ESIN604.MOD_IP%TYPE                    /* 수정자 IP */
,   OUT_RTN                 OUT INTEGER                                /* 결과값(OUT) */
,   OUT_MSG                 OUT VARCHAR2                            /* 오류내용(OUT) */
)
IS
/******************************************************************************
    프로그램명    : SP_ESIN604_FRN_LANG_CREA
    수행목적    : 제2외국어 환산점수 계산 및 결격사유.
    수행결과    : ESIN603(외국어성적) -> ESIN604(성적)
------------------------------------------------------------------------------
    수정일자        수정자        수정내용
------------------------------------------------------------------------------
    2019.12.18    유준식        최초 작성
    2019.12.27    박원희        프로시저 오류 수정
    2020.09.21    박용주        치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요. 
******************************************************************************/

BEGIN
    -- 성적
    MERGE INTO ESIN604 Z
    USING (
        WITH T1 AS (
            -- 외국어 성적 대상 조회
            SELECT DISTINCT a.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SELECT_FG
                 , C.VLD_EXAM_ACQ_SCOR
                 , A.STG1_GENRL_SELECT_CHG_YN
                 , A.STG2_GENRL_SELECT_CHG_YN
                 , DECODE(C.FRN_LANG_VLD_EXAM_FG, 'U027800003', C.RC_SCOR, C.VLD_EXAM_ACQ_SCOR) AS FL_SCOR          -- 외국어인증시험구분 : SNULT일 경우 독해점수 아니면 인증시험취득점수
                 , DECODE(C.FRN_LANG_VLD_EXAM_FG, 'U027800003', C.RC_SCOR, C.VLD_EXAM_ACQ_SCOR) AS EXCH_PCT_SCOR    -- 외국어인증시험구분 : SNULT일 경우 독해점수 아니면 인증시험취득점수
                 , DECODE(C.FRN_LANG_VLD_EXAM_FG, 'U027800003', C.RC_SCOR, C.VLD_EXAM_ACQ_SCOR) AS EXCH_SCOR        -- 외국어인증시험구분 : SNULT일 경우 독해점수 아니면 인증시험취득점수
                 , C.FRN_LANG_FG
              FROM V_ESIN600 A  -- 지원자 정보(법전원 일반전형전환 포함)
                 , ESIN521 B    -- 성적기준정보
                 , ESIN603 C    -- 외국어 성적
             WHERE A.COLL_UNIT_NO IN (
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
               AND B.SELECT_ELEMNT_FG = 'U027100013'
               AND NVL(B.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
               AND A.REAL_COLL_UNIT_NO = C.COLL_UNIT_NO(+)
               AND A.EXAM_NO = C.EXAM_NO(+)
               AND C.FRN_LANG_VLD_EXAM_FG(+) IN ('U027800003', 'U027800013')    -- 외국어인증시험구분 : SNULT ,제2외국어
               AND NVL(C.FL_ADPT_YN(+), 'N') = 'Y'  -- 최종반영여부
               AND C.FRN_LANG_FG IS NOT NULL
        ), T2 AS (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SELECT_FG
                 , A.VLD_EXAM_ACQ_SCOR
                 , A.STG1_GENRL_SELECT_CHG_YN
                 , A.STG2_GENRL_SELECT_CHG_YN
                 , A.FL_SCOR
                 , A.EXCH_PCT_SCOR
                 , A.EXCH_SCOR
                 , A.FRN_LANG_FG
                 , B.ADPT_STG_FG
                 , B.SELECT_ELEMNT_FG
                 , B.SELECT_ELEMNT_FMAK_SCOR
                 , B.EXCH_MTHD_FG
                 , B.SELECT_ELEMNT_BASE_SCOR
                 , B.SELECT_ELEMNT_SCOR_SCOR
                 , B.SELECT_ELEMNT_DISQ_ADPT_YN
                 , B.SELECT_ELEMNT_DISQ_SCOR
                 , B.SELECT_ELEMNT_SBJT_FG
              FROM T1 A         -- 외국어 성적 대상
                 , ESIN521 B    -- 성적기준정보
             WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND B.SELECT_ELEMNT_FG = 'U027100013'    -- 전형요소구분 : 제2외국어
               AND A.FRN_LANG_FG = B.SELECT_ELEMNT_SBJT_FG
               AND NVL(B.SELECT_ELEMNT_USE_YN, 'N') = 'Y' -- 전형요소사용여부
             UNION
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SELECT_FG
                 , A.VLD_EXAM_ACQ_SCOR
                 , A.STG1_GENRL_SELECT_CHG_YN
                 , A.STG2_GENRL_SELECT_CHG_YN
                 , A.FL_SCOR
                 , A.EXCH_PCT_SCOR
                 , A.EXCH_SCOR
                 , A.FRN_LANG_FG
                 , B.ADPT_STG_FG
                 , B.SELECT_ELEMNT_FG
                 , B.SELECT_ELEMNT_FMAK_SCOR
                 , B.EXCH_MTHD_FG
                 , B.SELECT_ELEMNT_BASE_SCOR
                 , B.SELECT_ELEMNT_SCOR_SCOR
                 , B.SELECT_ELEMNT_DISQ_ADPT_YN
                 , B.SELECT_ELEMNT_DISQ_SCOR
                 , B.SELECT_ELEMNT_SBJT_FG
              FROM T1 A
                 , ESIN521 B
             WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND B.SELECT_ELEMNT_SBJT_FG = '999'  -- 전형요소과목구분 : 기타
               AND B.SELECT_ELEMNT_FG = 'U027100013'    -- 전형요소구분 : 제2외국어
               AND NVL(B.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
               AND A.FRN_LANG_FG NOT IN (
                        SELECT X.SELECT_ELEMNT_SBJT_FG
                          FROM ESIN521 X
                         WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
                           AND X.SELECT_ELEMNT_FG = 'U027100013'
                           AND X.SELECT_ELEMNT_SBJT_FG <> '999'
                   )
        )
        SELECT A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.ADPT_STG_FG AS SCRN_STG_FG
             , A.SELECT_ELEMNT_FG
             , CASE WHEN A.ADPT_STG_FG = 'U027200001' THEN NVL2(A.STG1_GENRL_SELECT_CHG_YN, A.STG1_GENRL_SELECT_CHG_YN, 'N')
                    WHEN A.ADPT_STG_FG IN ('U027200002', 'U027200003') THEN NVL2(A.STG2_GENRL_SELECT_CHG_YN, A.STG2_GENRL_SELECT_CHG_YN, 'N')
               END AS GENRL_SELECT_CHG_YN
             , NVL(A.FL_SCOR, 0)AS FL_SCOR
             
             /* START 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
             , CASE WHEN A.SELECT_FG = 'U025700003' THEN TRUNC(NVL(A.EXCH_SCOR, 0),1)
                    ELSE NVL(A.EXCH_SCOR, 0) 
               END AS EXCH_SCOR
             /* END 2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요.  */ 
             
             , CASE WHEN NVL(A.SELECT_ELEMNT_DISQ_SCOR, 0) > NVL(A.FL_SCOR, 0) THEN 'U027700005' -- 과락 --- 원점수 기준 과락 점수
               END AS FL_DISQ_FG
             , IN_INPT_ID AS INPT_ID
             , SYSDATE AS INPT_DTTM
             , IN_INPT_IP AS INPT_IP
          FROM T2 A
         WHERE A.ADPT_STG_FG = IN_SCRN_STG_FG
        ) X
        ON (
                Z.COLL_UNIT_NO = X.COLL_UNIT_NO
            AND Z.EXAM_NO = X.EXAM_NO
            AND Z.SCRN_STG_FG = X.SCRN_STG_FG
            AND Z.SELECT_ELEMNT_FG = X.SELECT_ELEMNT_FG
        )
        WHEN MATCHED THEN
            UPDATE
               SET Z.GENRL_SELECT_CHG_YN = X.GENRL_SELECT_CHG_YN
                 , Z.FL_SCOR = X.FL_SCOR
                 , Z.EXCH_SCOR = X.EXCH_SCOR
                 , Z.FL_DISQ_FG = CASE WHEN Z.FL_DISQ_FG <> 'U027700005' THEN Z.FL_DISQ_FG ELSE X.FL_DISQ_FG END
                 , Z.MOD_ID = IN_INPT_ID
                 , Z.MOD_DTTM = SYSDATE
                 , Z.MOD_IP = INPT_IP
    ;
    
    OUT_RTN := 0;
    OUT_MSG := '처리에 성공하였습니다.';
    
    EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;
    RETURN;
END SP_ESIN604_FRN_LANG_CREA;
/
