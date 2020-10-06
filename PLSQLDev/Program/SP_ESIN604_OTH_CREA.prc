CREATE OR REPLACE PROCEDURE SP_ESIN604_OTH_CREA
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
	프로그램명	: SP_ESIN604_OTH_CREA
	수행목적	: 교육입문시험, 국어시험, 외국어성적, 나머지 성적계산 프로시저 실행
	수행결과	: 
------------------------------------------------------------------------------
	수정일자		수정자		수정내용
------------------------------------------------------------------------------
	2019.12.18	유준식		최초 작성
	2019.12.27	박원희		프로시저 오류 수정
    2020.09.21  박용주     치의학대학원 -  계산 버튼을 눌렀을 때에 나오는 환산점수 소수점 2번째자리 절사(반올림x)가 필요. 
******************************************************************************/

BEGIN 
/*
U025700001  일반대학원
U025700002  법학전문대학원
U025700003  치의학대학원
U025700004  경영전문대학원
U025700005  경영전문대학원(EMBA)
U025700006  경영전문대학원(GMBA)
U025700007  공학전문대학원
U025700008  데이터사이언스대학원
U025700009  행정대학원(계약학과)
U025700010  의과대학(계약학과)
U025700011  융합과학기술대학원(계약학과)
U025700012  학사편입
U025700013  약학대학
U025700014  간호대학(계약학과)
U025700015  융합과학기술대학원(계약학과_)

U027100001	1단계총점
U027100002	2단계총점
U027100003	교육입문시험성적
U027100004	국어능력
U027100005	면접및구술고사
U027100006	법학적성시험
U027100007	서류평가
U027100008	실기성적
U027100009	영어성적
U027100010	전공이론
U027100011	전공필답고사
U027100012	정성평가
U027100013	제2외국어
U027100014	학업성적
U027100017	전공선택1
U027100018	전공선택2
U027100019	전공선택3
*/  
	OUT_RTN := 0;
    
	IF ('U027100003' =  IN_SELECT_ELEMNT_FG) THEN      -- 교육입문시험  
        SP_ESIN604_EET_CREA(
				IN_COLL_UNIT_NO				/* 모집단위번호 */
			,	IN_SCRN_STG_FG				/* 사정단계구분 */
			,	IN_SELECT_ELEMNT_FG			/* 전형요소구분 */
			,	IN_GENRL_SELECT_CHG_YN		/* 일반전형전환여부 */
		    ,	IN_SELECT_YY            	/* 전형년도 */
		    ,   IN_SELECT_FG                /* 전형구분 */
		    ,   IN_COLL_FG              	/* 모집구분 */
		    ,   IN_APLY_QUAL_FG         	/* 지원자격 */
		    ,   IN_DETA_APLY_QUAL_FG    	/* 세부지원자격 */
		    ,   IN_APLY_CORS_FG         	/* 과정 */
		    ,   IN_APLY_COLG_FG         	/* 단과대학 */
		    ,   IN_APLY_COLL_UNIT_CD    	/* 모집단위코드 */
		    ,   IN_EXAM_NO              	/* 수험번호 */
			,	IN_FL_SCOR					/* 최종점수 */
			,	IN_INPT_ID					/* 생성자 ID */
			,	IN_INPT_IP					/* 생성자 IP */
			,	IN_MOD_ID					/* 수정자 ID */
			,	IN_MOD_IP					/* 수정자 IP */
		    ,   OUT_RTN                 	/* 결과값(OUT) */
		    ,   OUT_MSG                 	/* 오류내용(OUT) */
		)
        ;
    ELSIF ('U027100004' = IN_SELECT_ELEMNT_FG) THEN    -- 국어시험 
        SP_ESIN604_KOR_CREA(
				IN_COLL_UNIT_NO				/* 모집단위번호 */
			,	IN_SCRN_STG_FG				/* 사정단계구분 */
			,	IN_SELECT_ELEMNT_FG			/* 전형요소구분 */
			,	IN_GENRL_SELECT_CHG_YN		/* 일반전형전환여부 */
		    ,	IN_SELECT_YY            	/* 전형년도 */
		    ,   IN_SELECT_FG                /* 전형구분 */
		    ,   IN_COLL_FG              	/* 모집구분 */
		    ,   IN_APLY_QUAL_FG         	/* 지원자격 */
		    ,   IN_DETA_APLY_QUAL_FG    	/* 세부지원자격 */
		    ,   IN_APLY_CORS_FG         	/* 과정 */
		    ,   IN_APLY_COLG_FG         	/* 단과대학 */
		    ,   IN_APLY_COLL_UNIT_CD    	/* 모집단위코드 */
		    ,   IN_EXAM_NO              	/* 수험번호 */
			,	IN_FL_SCOR					/* 최종점수 */
			,	IN_INPT_ID					/* 생성자 ID */
			,	IN_INPT_IP					/* 생성자 IP */
			,	IN_MOD_ID					/* 수정자 ID */
			,	IN_MOD_IP					/* 수정자 IP */
		    ,   OUT_RTN                 	/* 결과값(OUT) */
		    ,   OUT_MSG                 	/* 오류내용(OUT) */
        )
        ; 
	ELSIF ('U027100013' = IN_SELECT_ELEMNT_FG) THEN    -- 외국어시험  
      SP_ESIN604_FRN_LANG_CREA
		(       IN_COLL_UNIT_NO				/* 모집단위번호 */
			,	IN_SCRN_STG_FG				/* 사정단계구분 */
			,	IN_SELECT_ELEMNT_FG			/* 전형요소구분 */
			,	IN_GENRL_SELECT_CHG_YN		/* 일반전형전환여부 */
		    ,	IN_SELECT_YY            	/* 전형년도 */
		    ,   IN_SELECT_FG                /* 전형구분 */
		    ,   IN_COLL_FG              	/* 모집구분 */
		    ,   IN_APLY_QUAL_FG         	/* 지원자격 */
		    ,   IN_DETA_APLY_QUAL_FG    	/* 세부지원자격 */
		    ,   IN_APLY_CORS_FG         	/* 과정 */
		    ,   IN_APLY_COLG_FG         	/* 단과대학 */
		    ,   IN_APLY_COLL_UNIT_CD    	/* 모집단위코드 */
		    ,   IN_EXAM_NO              	/* 수험번호 */
			,	IN_FL_SCOR					/* 최종점수 */
			,	IN_INPT_ID					/* 생성자 ID */
			,	IN_INPT_IP					/* 생성자 IP */
			,	IN_MOD_ID					/* 수정자 ID */
			,	IN_MOD_IP					/* 수정자 IP */
		    ,   OUT_RTN                 	/* 결과값(OUT) */
		    ,   OUT_MSG                 	/* 오류내용(OUT) */
		) ;  	 
	ELSE --나머지
		SP_ESIN604_OTH_RST_CREA(
                IN_COLL_UNIT_NO				/* 모집단위번호 */
			,	IN_SCRN_STG_FG				/* 사정단계구분 */
			,	IN_SELECT_ELEMNT_FG			/* 전형요소구분 */
			,	IN_GENRL_SELECT_CHG_YN		/* 일반전형전환여부 */
		    ,	IN_SELECT_YY            	/* 전형년도 */
		    ,   IN_SELECT_FG                /* 전형구분 */
		    ,   IN_COLL_FG              	/* 모집구분 */
		    ,   IN_APLY_QUAL_FG         	/* 지원자격 */
		    ,   IN_DETA_APLY_QUAL_FG    	/* 세부지원자격 */
		    ,   IN_APLY_CORS_FG         	/* 과정 */
		    ,   IN_APLY_COLG_FG         	/* 단과대학 */
		    ,   IN_APLY_COLL_UNIT_CD    	/* 모집단위코드 */
		    ,   IN_EXAM_NO              	/* 수험번호 */
			,	IN_FL_SCOR					/* 최종점수 */
			,	IN_INPT_ID					/* 생성자 ID */
			,	IN_INPT_IP					/* 생성자 IP */
			,	IN_MOD_ID					/* 수정자 ID */
			,	IN_MOD_IP					/* 수정자 IP */
		    ,   OUT_RTN                 	/* 결과값(OUT) */
		    ,   OUT_MSG                 	/* 오류내용(OUT) */
		)
        ; 
    END IF;
    
	IF OUT_RTN = 0 THEN
        OUT_MSG := '처리에 성공하였습니다.';
	ELSE 
	  OUT_MSG := 'DD' || OUT_MSG ;
	END IF;

	EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;  
	RETURN;
END SP_ESIN604_OTH_CREA;
/
