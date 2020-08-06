CREATE OR REPLACE PROCEDURE SNU.SP_ENRO410_CREA
(
     IN_ENTR_SCHYY      IN ENRO400.ENTR_SCHYY%TYPE      /* 입학학년도*/
    ,IN_ENTR_SHTM_FG    IN ENRO400.ENTR_SHTM_FG%TYPE    /* 입학학기구분*/
    ,IN_SELECT_FG       IN ENRO400.SELECT_FG%TYPE       /* 전형구분*/
    ,IN_PASS_SEQ        IN ENRO400.PASS_SEQ%TYPE        /* 합격차수*/
    ,IN_REG_RESV_FG     IN VARCHAR2                     /* 예치금반영구*/
    ,IN_TRET_FG         IN VARCHAR2                     /* 처리구분*/
    ,IN_ID              IN ENRO400.INPT_ID%TYPE         /* ID */
    ,IN_IP              IN ENRO400.INPT_IP%TYPE         /* IP */
    ,OUT_TRET_CNT       OUT NUMBER
    ,OUT_NUM            OUT NUMBER
    ,OUT_MSG            OUT VARCHAR2
 )IS
/******************************************************************************
    프로그램명 : SP_ENRO410_CREA
      수행목적 : ENRO410 신입생등록대상자를 생성을 한다.
      수행결과 : ENRO410    대상자생성
 ------------------------------------------------------------------------------
     수정일자     수정자    수정내용
 ------------------------------------------------------------------------------
     2013.08.12   김승훈   최초 작성
     2015.08.05   권순태   가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경(DELETE 1건, SELECT 8건 : 총9건)
     2015.08.26   권순태   신입생장학선발내역(SCHO530) 데이터 입력(INSERT, UPDATE) 시 등록금(V_STD_ENTR_AMT, V_STD_LSN_AMT)이 아닌 장학금(V_SCAL_ENTR_AMT, V_SCAL_LSN_AMT)으로 저장하도록 변경(INSERT 3건, UPDATE 3건 : 총6건)
     2015.11.02   권순태   합격자(신입생대상자업로드)내역(ENRO400)의 합격자발표완료여부(ANUN_CLS_YN)가 'Y'인 경우만 생성되도록 조건 추가(SELECT 10건)
     2015.12.07   권순태   ENRO410 UPDATE 시, EDAMT_SUPP_BREU_CD(교육비지원기관코드), STD_BUDEN_RATE(학생부담비율), BREU_BUDEN_RATE(기관부담비율)도 업데이트 되도록 수정.
     2016.01.20   권순태   등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 )
 ******************************************************************************/
 /**********************************변수선언시작*******************************/
tmpVar NUMBER;
V_PGM_ID                    VARCHAR2(100) := 'SP_ENRO410_CREA';
V_STD_BUDEN_RATE            ENRO170.STD_BUDEN_RATE %TYPE := 0;
V_BREU_BUDEN_RATE           ENRO170.BREU_BUDEN_RATE %TYPE := 0;
V_CSH_BUDEN_RATE            ENRO170.CSH_BUDEN_RATE %TYPE := 0;
V_ACTHNG_BUDEN_RATE         ENRO170.ACTHNG_BUDEN_RATE %TYPE := 0;

V_STD_ENTR_AMT              ENRO410.ENTR_AMT %TYPE := 0;                /* 학생 입학금 */
V_STD_LSN_AMT               ENRO410.LSN_AMT %TYPE := 0;                 /* 학생 수업료 */
V_STD_REG_RESV_AMT          ENRO410.REG_RESV_AMT %TYPE := 0;            /* 학생 등록예치금 */
V_STD_REG_RESV_FG_AMT       ENRO410.REG_RESV_AMT %TYPE := 0;            /* 학생 등록예치금 */
V_BREU_ENTR_AMT             ENRO410.ENTR_AMT %TYPE := 0;                /* 기관 입학금 */
V_BREU_LSN_AMT              ENRO410.LSN_AMT %TYPE := 0;                 /* 기관 수업료 */
V_BREU_REG_RESV_AMT         ENRO410.REG_RESV_AMT %TYPE := 0;            /* 기관 등록예치금 */
V_TEACHM_AMT                ENRO410.TEACHM_AMT %TYPE := 0;              /* 교재비 */
V_AUTO_REG_FG               ENRO410.AUTO_REG_FG %TYPE;                 /* 자동등록구분 */
V_GV_ST_FG                  ENRO410.GV_ST_FG %TYPE;                       /* 납입상태구분 */


/*SCHO*/
V_SCAL_ENTR_AMT_RATE        SCHO110.ENTR_AMT_RATE %TYPE;                /* 입학금비율 */
V_SCAL_LSN_AMT_RATE         SCHO110.LSN_AMT_RATE %TYPE;                 /* 수업료비율 */
V_SCAL_ENTR_AMT             SCHO110.ENTR_AMT %TYPE;                     /* 입학금 */
V_SCAL_LSN_AMT              SCHO110.LSN_AMT %TYPE;                      /* 수업료 */
V_SCAL_TT_AMT               ENRO410.SCAL_TT_AMT %TYPE;                      /* 총합계 */

V_ENRO100_ENTR_AMT          ENRO100.ENTR_AMT %TYPE := 0;                /* 입학금 */
V_ENRO100_LSN_AMT           ENRO100.LSN_AMT %TYPE := 0;                 /* 수업료 */
V_ENRO100_SSO_AMT           ENRO100.SSO_AMT %TYPE := 0;                 /* 기성회비 */
V_ENRO100_REG_RESV_AMT      ENRO100.REG_RESV_AMT %TYPE := 0;            /* 등록예치금 */
V_ENRO100_STDUNI_AMT        ENRO100.STDUNI_AMT %TYPE := 0;              /* 학생회비 */
V_ENRO100_MEDI_DUC_AMT      ENRO100.MEDI_DUC_AMT %TYPE := 0;            /* 의료공제비 */
V_ENRO100_CMMN_TEACHM_AMT   ENRO100.CMMN_TEACHM_AMT %TYPE := 0;         /* 공통교재비 */
V_ENRO100_CHOICE_TEACHM_AMT ENRO100.CHOICE_TEACHM_AMT %TYPE := 0;       /* 선택교재비 */
V_BNSN011_USR_DEF_2         bsns011.USR_DEF_2 %TYPE := NULL;            /* 사용자정의2 */

/*ENRO450*/
V_PAID_TO_DT                ENRO450.PAID_TO_DT %TYPE;                      /* 납부종료일자 */



V_GV_CNT                    NUMBER;                                     /* 납입건수 */
V_STUNO_CNT                 NUMBER;                                     /* 납입건수 */
V_RESV_GV_CNT               NUMBER;                                     /* 등록예치금납입건수 */
V_MSG                       VARCHAR2(2000):= NULL;
V_SCAL_CNT                  NUMBER;
V_ENRO100_YN                VARCHAR2(2) := NULL;
V_ROWID                     ROWID;
V_OUT_CODE                  VARCHAR2(10);
V_OUT_MSG                   VARCHAR2(2000);
/**********************************변수선언 끝*********************************/

BEGIN

V_MSG :='---------------64561--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
||'] IN_SELECT_FG['||IN_SELECT_FG||']'
||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
||'] IN_TRET_FG['||IN_TRET_FG||']'
||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;
OUT_TRET_CNT := 0;

 /* 납입한 데이터가 있는지 체크를 한다 . */
    SELECT  COUNT(1)
      INTO  V_STUNO_CNT
      FROM  ENRO400 T1
     WHERE  T1.ENTR_SCHYY       = IN_ENTR_SCHYY         /* 입학학년도 */
       AND  T1.ENTR_SHTM_FG     = IN_ENTR_SHTM_FG       /* 입학학기구분 */
       AND  T1.SELECT_FG        = IN_SELECT_FG          /* 전형구분 */
       AND  T1.PASS_SEQ         = IN_PASS_SEQ           /* 합격차수*/
       AND  T1.STUNO is null
     ;
    IF V_STUNO_CNT > 0  THEN
           SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')'||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
           OUT_NUM := '-1';
           OUT_MSG :='학번을 먼저 생성을 하세요.';
           RETURN;
   END IF;

    if IN_TRET_FG = 'C' then /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

      /* 납입한 데이터가 있는지 체크를 한다 . */
        SELECT
        COUNT(1)
        INTO
        V_GV_CNT
        FROM
         ENRO400 T1
        ,ENRO430 T2
        WHERE T1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO
          AND T1.ENTR_SCHYY       = IN_ENTR_SCHYY         /* 입학학년도 */
          AND T1.ENTR_SHTM_FG     = IN_ENTR_SHTM_FG       /* 입학학기구분 */
          AND T1.SELECT_FG        = IN_SELECT_FG          /* 전형구분 */
          AND T1.PASS_SEQ         = IN_PASS_SEQ  ;        /* 합격차수*/

    end if;



    IF V_GV_CNT > 0  THEN
        SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')'||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
        OUT_NUM := '-1';
        OUT_MSG :='납입 처리된 데이터가 있어서 대상자 생성 및 등록금 재산출이 불가 합니다.'||IN_TRET_FG;
        RETURN;

    END IF;

/* 등록금 예치금을 사용하는 전형 구분인지 구분자 가져오기 USR_DEF_2 이게 1인 경우 예치금 사용이고 0인경우 예치금 사용 안함 */
    select
    nvl(USR_DEF_2,'0')
    into
    V_BNSN011_USR_DEF_2
    from bsns011
    where GRP_CD = 'U0618'
      and USE_YN = 'Y'
      and CMMN_CD = IN_SELECT_FG;


      /* 납입한 데이터가 있는지 체크를 한다 . */
            SELECT
            COUNT(1)
            INTO
            V_RESV_GV_CNT
            FROM
             ENRO400 T1
            ,ENRO410 T2
            WHERE T1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO
              AND T1.ENTR_SCHYY = IN_ENTR_SCHYY                               /* 입학학년도 */
              AND T1.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                           /* 입학학기구분 */
              AND T1.SELECT_FG = IN_SELECT_FG                                 /* 전형구분 */
              AND T1.PASS_SEQ  = IN_PASS_SEQ                                  /* 합격차수*/
              AND T2.REG_RESV_AMT_GV_ST_FG = 'U060500002';                    /* 등록예치금납입상태구분 */



    V_MSG :='IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
            ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
            ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
            ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
            ||'] IN_TRET_FG['||IN_TRET_FG||']'
            ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
            ||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
            ||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;

/* 등록금 처리구분이 대상자생성/산출인 경우 데이터를 삭제 후 생성을 시작을 하며
   그렇지 않은 경우 데이터에 업데이트 처리를 한다. */
    if IN_TRET_FG = 'C' then  /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

        IF V_BNSN011_USR_DEF_2 = '1' THEN  /* 예치금 사용 예 */

            IF V_RESV_GV_CNT > 0  THEN

                SP_SSTM056_CREA(V_PGM_ID, '예치금납입 처리된 데이터가 있어서 대상자 생성 및 등록금 재산출이 불가 합니다.'||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                OUT_NUM := '-1';
                OUT_MSG :='예치금납입 처리된 데이터가 있어서 대상자 생성 및 등록금 재산출이 불가 합니다.';
                RETURN;

            END IF;

         if IN_REG_RESV_FG = 'E' then /* 등록구분(예치금반영구분) 'R'='등록금예치금', 'E'='등록금' */


             OUT_NUM := '-1';
             OUT_MSG :='처리구분을 등록금 재산출로 처리 하세요. ';
              SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
             RETURN;

         END IF;

        END IF;

        BEGIN

            DELETE FROM SCHO530 T1                 /* 신입생장학선발내역 */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* 학년도 */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* 학기 */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* 전형구분 */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* 차수 */
                                          );

            DELETE FROM ENRO440 T1                 /* 신입생들록금환불내역 */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* 학년도 */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* 학기 */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* 전형구분 */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* 차수 */
                                          );

            DELETE FROM ENRO430 T1                 /* 신입생들록금수납환불내역 */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* 학년도 */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* 학기 */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* 전형구분 */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* 차수 */
                                          );
            DELETE FROM ENRO431 T1                 /* 신입생들록금수납환불내역 */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* 학년도 */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* 학기 */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* 전형구분 */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* 차수 */
                                          );

            /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
            DELETE FROM ENRO410 T1                 /* 신입생들록대상자내역 */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* 학년도 */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* 학기 */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* 전형구분 */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* 차수 */
                                          AND   NOT EXISTS (SELECT 1
                                                              FROM ENRO420 TB1
                                                             WHERE TB1.EXAM_STD_MNGT_NO = TA1.EXAM_STD_MNGT_NO)
                                          );

        EXCEPTION
                WHEN OTHERS THEN

                    OUT_NUM := -10000;
                    OUT_MSG := '기존 데이터 삭제를 실패 하였습니다.';
                     SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                    RETURN;
        END;

    end if;


    V_MSG :='---------------2222--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
||'] IN_SELECT_FG['||IN_SELECT_FG||']'
||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
||'] IN_TRET_FG['||IN_TRET_FG||']'
||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;


    IF V_BNSN011_USR_DEF_2 = '0' THEN /* 정시 */

        IF IN_REG_RESV_FG = 'E' then /* 등록구분(예치금반영구분) 'R'='등록금예치금', 'E'='등록금' */

            IF IN_TRET_FG = 'C' THEN  /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

              FOR LIST_DATA IN (
                        SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                  /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD               /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY            /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG          /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG             /* 전형구분*/
                              AND   T2.PASS_SEQ     LIKE IN_PASS_SEQ||'%'              /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3 AS SELECT_USR_DEF                                   /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG    = T3.CMMN_CD                          /* 전형구분 */
                              AND   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ  LIKE IN_PASS_SEQ||'%'                     /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND    T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                    FROM    SREG001 T1
                                                                          , ENRO400 T2
                                                                          , V_COMM111_4 T4
                                                                   WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                     AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                     AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                     AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                                                                     AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                                                                     AND    T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                                                                     AND    T2.PASS_SEQ     like IN_PASS_SEQ||'%'              /* 합격차수*/
                                                                     and    T2.STUNO is not null
                                                                     AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                    WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                               ELSE 'C013300002'
                                                                                               END)
                                                                     AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                     AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                     AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */

                        )
                    LOOP




                            BEGIN

                                /*학적인적기본테이블의 부서코드로 등록금책정내역 유무 확인*/
                                SELECT
                                T1.ENTR_AMT                                     /* 입학금 */
                                ,T1.LSN_AMT                                      /* 수업료 */
                                ,T1.SSO_AMT                                      /* 기성회비 */
                                ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                ,T1.STDUNI_AMT                                   /* 학생회비 */
                                ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* 입학금 */
                                ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*학적인적기본의 부서코드로 등록금책정이 안된 경우 전공코드로 유무 확인*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* 입학금 */
                                    ,T1.LSN_AMT                                      /* 수업료 */
                                    ,T1.SSO_AMT                                      /* 기성회비 */
                                    ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                    ,T1.STDUNI_AMT                                   /* 학생회비 */
                                    ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                    ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                    ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                    ,'Y' AS YN
                                    INTO
                                     V_ENRO100_ENTR_AMT                              /* 입학금 */
                                    ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                    ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                    ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                    ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '해당 학과 전공에 대한 등록금책정 정보가 없습니다[학번 = '|| LIST_DATA.STUNO
                                || ' / 전공(학과)코드 = ' ||LIST_DATA.DEPARTMENT_CD||'('|| LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || ')].';
                                 SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                RETURN;

                                END;

                            END;




                             /*학생*/
                            V_STD_ENTR_AMT := 0;       /* 입학금 */
                            V_STD_LSN_AMT  := 0;       /* 수업료 */
                            V_STD_REG_RESV_AMT:= 0;    /* 등록예치금 */
                            V_STD_REG_RESV_FG_AMT:= 0; /* 등록예치금 */

                            /*기관*/
                            V_BREU_ENTR_AMT := 0;     /* 입학금 */
                            V_BREU_LSN_AMT  := 0;     /* 수업료 */
                            V_BREU_REG_RESV_AMT:= 0;  /* 등록예치금 */

                            /*장학*/
                            V_SCAL_ENTR_AMT := 0;     /* 입학금 */
                            V_SCAL_LSN_AMT  := 0;     /* 수업료 */



                            /*기본등록금 입력*/
                            V_STD_ENTR_AMT      := V_ENRO100_ENTR_AMT;      /* 학생 입학금 */
                            V_STD_LSN_AMT       := V_ENRO100_LSN_AMT;       /* 학생 수업료 */
                            V_STD_REG_RESV_AMT  := V_ENRO100_REG_RESV_AMT;  /* 학생 등록예치금 */

                            V_MSG :='-----------------LIST_DATA.ENTR_SCHYY[' ||LIST_DATA.ENTR_SCHYY
                                                    ||'] LIST_DATA.ENTR_SHTM_FG['||LIST_DATA.ENTR_SHTM_FG||']'
                                                    ||'] LIST_DATA.DETA_SHTM_FG['||LIST_DATA.DETA_SHTM_FG||']'
                                                    ||'] LIST_DATA.CORS_FG['||LIST_DATA.CORS_FG||']'
                                                    ||'] LIST_DATA.DEPARTMENT_CD['||LIST_DATA.DEPARTMENT_CD||']'
                                                    ||'] LIST_DATA.SHYR['||LIST_DATA.SHYR||']'
                                                    ||'] LIST_DATA.DAYNGT_FG['||LIST_DATA.DAYNGT_FG||']'
                                                    ||'] LIST_DATA.EXAM_COLL_UNIT_DEPT_CD['||LIST_DATA.EXAM_COLL_UNIT_DEPT_CD||']'
                                                    ||'] LIST_DATA.STUNO['||LIST_DATA.STUNO||']'||V_MSG;


                             /* 등록금 정책기준이 없는 경우 ,, 오류 처리*/
                            if V_STD_ENTR_AMT = 0 and V_STD_LSN_AMT = 0 AND V_STD_REG_RESV_AMT = 0 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '신입생 등록금책정기준을 확인 하세요.';
                                 SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                RETURN;

                            END IF;

                            /* 교재비*/
                            V_TEACHM_AMT := V_ENRO100_CMMN_TEACHM_AMT+V_ENRO100_CHOICE_TEACHM_AMT;

                            /* 계약학과 모집인 경우 */
                            IF LIST_DATA.SELECT_DEPT_CD != '00000' THEN

                                IF LIST_DATA.EDAMT_SUPP_BREU_CD IS NULL THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '교육비지원기관을 확인 하세요.';
                                     SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                    RETURN;
                                END IF;

                                BEGIN

                                    SELECT
                                        T1.STD_BUDEN_RATE                                                        /* 학생부담비율 */
                                       ,T1.BREU_BUDEN_RATE                                                       /* 기관부담비율 */
                                       ,T1.CSH_BUDEN_RATE                                                        /* 현금부담비율 */
                                       ,T1.ACTHNG_BUDEN_RATE                                                     /* 현물부담비율 */
                                       INTO
                                        V_STD_BUDEN_RATE
                                       ,V_BREU_BUDEN_RATE
                                       ,V_CSH_BUDEN_RATE
                                       ,V_ACTHNG_BUDEN_RATE
                                    FROM ENRO170 T1
                                    WHERE T1.EDAMT_SUPP_BREU_CD = LIST_DATA.EDAMT_SUPP_BREU_CD
                                    AND T1.DEPT_CD = LIST_DATA.SELECT_DEPT_CD;

                                    V_STD_ENTR_AMT := 0;
                                    V_STD_LSN_AMT := 0;

                                     /*학생*/
                                    V_STD_ENTR_AMT :=(V_STD_BUDEN_RATE/100)* V_ENRO100_ENTR_AMT;         /* 학생 입학금 */
                                    V_STD_LSN_AMT  := (V_STD_BUDEN_RATE/100)* V_ENRO100_LSN_AMT;          /* 학생 수업료 */


                                     V_BREU_ENTR_AMT := 0;
                                    V_BREU_LSN_AMT := 0;

                                    /*기관*/
                                    V_BREU_ENTR_AMT :=(V_BREU_BUDEN_RATE/100)*V_ENRO100_ENTR_AMT;         /* 기관 입학금 */
                                    V_BREU_LSN_AMT  := (V_BREU_BUDEN_RATE/100)*V_ENRO100_LSN_AMT;          /* 기관 수업료 */


                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '교육비지원기관가 없습니다.';
                                         SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        RETURN;
                                    WHEN OTHERS THEN

                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '교육비지원기관 데이터를 확인 하세요';
                                         SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        RETURN;
                                END;

                            END IF;

                            /*  장학금이 있는 경우 */
                            IF LIST_DATA.SCAL_CD is not null THEN

                                BEGIN

                                    SELECT
                                            T2.ENTR_AMT_RATE                                     /* 입학금비율 */
                                          , T2.LSN_AMT_RATE                                      /* 수업료비율 */
                                    INTO
                                             V_SCAL_ENTR_AMT_RATE                                /* 입학금비율 */
                                          ,  V_SCAL_LSN_AMT_RATE                                 /* 수업료비율 */
                                    FROM
                                    SCHO100 T1
                                   ,SCHO110 T2
                                    WHERE  T1.SCAL_CD =  T2.SCAL_CD
                                    AND T1.SCAL_CD = LIST_DATA.SCAL_CD
                                    AND T1.BDEGR_SYSTEM_FG = LIST_DATA.BDEGR_SYSTEM_FG
                                    AND T2.SUBMATT_CORS_FG = (CASE WHEN LIST_DATA.SELECT_USR_DEF = '1' THEN 'U040800001'
                                                                   WHEN LIST_DATA.SELECT_USR_DEF = '2' THEN 'U040800002'
                                                             ELSE ''
                                                             END)
                                    ;

                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '장학금 상세정보가 없습니다.';
                                        RETURN;
                                    WHEN OTHERS THEN
                                        SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '장학금 처리를 실패 하였습니다.';
                                        RETURN;
                                END;

                                V_SCAL_ENTR_AMT := 0;
                                V_SCAL_LSN_AMT := 0;
                                V_SCAL_TT_AMT := 0;

                                 IF LIST_DATA.SCAL_CD is not null THEN
                                 /* 장학 */
                                 V_SCAL_ENTR_AMT :=(V_SCAL_ENTR_AMT_RATE/100)* V_ENRO100_ENTR_AMT;      /* 장학 입학금 */
                                 V_SCAL_LSN_AMT :=(V_SCAL_LSN_AMT_RATE/100)* V_ENRO100_LSN_AMT;         /* 장학 수업료 */
                                 V_SCAL_TT_AMT := V_SCAL_ENTR_AMT+V_SCAL_LSN_AMT;                        /*총금액*/
                                 end if;

                            END IF;



                        IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* 등록금여부 */




                          /*학생*/
                            V_STD_ENTR_AMT := 0;       /* 입학금 */
                            V_STD_LSN_AMT  := 0;       /* 수업료 */
                            V_STD_REG_RESV_AMT:= 0;    /* 등록예치금 */
                            V_STD_REG_RESV_FG_AMT:= 0; /* 등록예치금 */

                            /*기관*/
                            V_BREU_ENTR_AMT := 0;     /* 입학금 */
                            V_BREU_LSN_AMT  := 0;     /* 수업료 */
                            V_BREU_REG_RESV_AMT:= 0;  /* 등록예치금 */

                            /*장학*/
                            V_SCAL_ENTR_AMT := 0;     /* 입학금 */
                            V_SCAL_LSN_AMT  := 0;     /* 수업료 */




                        END IF;

                         V_GV_ST_FG := 'U060500001';
                         V_AUTO_REG_FG := NULL;

                        IF  LIST_DATA.SELECT_USR_DEF = '2' THEN

                            IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* 등록금여부 */

                                     V_AUTO_REG_FG := 'U060600003';
                                     V_GV_ST_FG := 'U060500002';


                            ELSIF(V_SCAL_TT_AMT = (NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))) THEN

                                    V_AUTO_REG_FG := 'U060600001';
                                    V_GV_ST_FG := 'U060500002';


                             END IF;

                            IF V_AUTO_REG_FG IS NOT NULL THEN

                              SELECT  MIN(TO_CHAR(TO_DATE(T1.PAID_TO_DT,'YYYYMMDD'),'YYYYMMDD'))
                                INTO    V_PAID_TO_DT
                                FROM
                                ENRO450 T1
                                WHERE T1.ENTR_SCHYY = LIST_DATA.ENTR_SCHYY
                                AND T1.ENTR_SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND T1.SELECT_FG    = LIST_DATA.SELECT_FG
                                 and T1.PAID_FR_DT > to_char(sysdate,'YYYYMMDD')
                                ;



                              IF V_PAID_TO_DT IS NULL THEN

                                OUT_NUM := -10000;
                                OUT_MSG := '납부종료일자를 확인 하세요.';
                                SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , OUT_NUM, OUT_MSG, IN_ID, IN_IP);
                                RETURN;

                              END IF;


                            END IF;

                        END IF;


                      INSERT INTO ENRO410(
                                 EXAM_STD_MNGT_NO                /* 수험생관리번호(PK1) */
                                ,SCAL_CD                         /* 장학코드 */
                                ,CNTR_SUST_YN                    /* 계약학과여부 */
                                ,EDAMT_SUPP_BREU_CD              /* 교육비지원기관코드 */
                                ,STD_BUDEN_RATE                  /* 학생부담비율 */
                                ,BREU_BUDEN_RATE                 /* 기관부담비율 */
                                ,CSH_BUDEN_RATE                  /* 현금부담비율 */
                                ,ACTHNG_BUDEN_RATE               /* 현물부담비율 */
                                ,CAL_CLS_YN                      /* 산출완료여부 */
                                ,REG_RESV_AMT                    /* 등록예치금 */
                                ,ENTR_AMT                        /* 입학금 */
                                ,LSN_AMT                         /* 수업료 */
                                ,REG_TT_AMT                      /* 등록총금액 */
                                ,BREU_ENTR_AMT                   /* 기관입학금 */
                                ,BREU_LSN_AMT                    /* 기관수업료 */
                                ,BREU_REG_TT_AMT                 /* 기관등록총금액 */
                                ,SCAL_ENTR_AMT                   /* 장학입학금 */
                                ,SCAL_LSN_AMT                    /* 장학수업료 */
                                ,SCAL_TT_AMT                     /* 장학총금액 */
                                ,STDUNI_AMT                      /* 학생회비 */
                                ,TEACHM_AMT                      /* 교재비 */
                                ,RECIV_REG_RESV_AMT              /* 수납등록예치금 */
                                ,RECIV_ENTR_AMT                  /* 수납입학금 */
                                ,RECIV_LSN_AMT                   /* 수납수업료 */
                                ,RECIV_TT_AMT                    /* 수납총금액 */
                                ,BREU_RECIV_ENTR_AMT             /* 기관수납입학금 */
                                ,BREU_RECIV_LSN_AMT              /* 기관수납수업료 */
                                ,BREU_RECIV_TT_AMT               /* 기관수납총금액 */
                                ,RECIV_STDUNI_AMT                /* 수납학생회비 */
                                ,RECIV_TEACHM_AMT                /* 수납교재비 */
                                ,GV_ST_FG                        /* 납입상태구분 */
                                ,AUTO_REG_FG                     /* 자동등록구분 */
                                ,RECIV_DT                        /* 수납일자 */
                                ,REMK                            /* 비고 */
                                ,SMS_SEND_SEQ                    /* SMS발송순번 */
                                ,EMAIL_SEND_SEQ                  /* 이메일발송순번 */
                                ,INPT_ID                         /* 입력ID */
                                ,INPT_IP                         /* 입력IP */
                                ,INPT_DTTM                       /* 입력일시 */
                        )VALUES(
                                 LIST_DATA.EXAM_STD_MNGT_NO                                         /* 수험생관리번호(PK1) */
                                ,LIST_DATA.SCAL_CD                                                  /* 장학코드 */
                                ,(CASE WHEN  LIST_DATA.SELECT_DEPT_CD !='00000' THEN 'Y'
                                  ELSE 'N'
                                  END )                                                             /* 계약학과여부 */
                                ,LIST_DATA.EDAMT_SUPP_BREU_CD                                       /* 교육비지원기관코드 */
                                ,V_STD_BUDEN_RATE                                                   /* 학생부담비율 */
                                ,V_BREU_BUDEN_RATE                                                  /* 기관부담비율 */
                                ,V_CSH_BUDEN_RATE                                                   /* 현금부담비율 */
                                ,V_ACTHNG_BUDEN_RATE                                                /* 현물부담비율 */
                                ,'N'                                                                /* 산출완료여부 */
                                ,0                                                                  /* 등록예치금 */
                                ,NVL(V_STD_ENTR_AMT, 0)                                             /* 입학금 */
                                ,NVL(V_STD_LSN_AMT, 0)                                              /* 수업료 */
                                ,(NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))                     /* (입학금+수업료) 등록총금액 */
                                ,NVL(V_BREU_ENTR_AMT, 0)                                            /* 기관입학금 */
                                ,NVL(V_BREU_LSN_AMT, 0)                                             /* 기관수업료 */
                                ,(NVL(V_BREU_ENTR_AMT, 0)+NVL(V_BREU_LSN_AMT, 0))                   /* (입학금+수업료) 기관등록총금액 */
                                ,NVL(V_SCAL_ENTR_AMT, 0)                                            /* 장학입학금 */
                                ,NVL(V_SCAL_LSN_AMT, 0)                                             /* 장학수업료 */
                                ,(NVL(V_SCAL_ENTR_AMT, 0)+NVL(V_SCAL_LSN_AMT, 0))                   /* (입학금+수업료) 장학등록총금액 */
                                ,NVL(V_ENRO100_STDUNI_AMT, 0)                                       /* 학생회비 */
                                ,(CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                    ELSE  NVL(V_TEACHM_AMT, 0)
                                  END )                                                             /* 교재비(공통+선택) */
                                ,0                                                                  /* 수납등록예치금 */
                                ,0                                                                  /* 수납입학금 */
                                ,0                                                                  /* 수납수업료 */
                                ,0                                                                  /* 수납총금액 */
                                ,0                                                                  /* 기관수납입학금 */
                                ,0                                                                  /* 기관수납수업료 */
                                ,0                                                                  /* 기관수납총금액 */
                                ,0                                                                  /* 수납학생회비 */
                                ,0                                                                  /* 수납교재비 */
                                ,V_GV_ST_FG                                                         /* 납입상태구분(미등록) */
                                ,V_AUTO_REG_FG                                                      /* 자동등록구분 */
                                ,V_PAID_TO_DT                                                       /* 수납일자 */
                                ,''                                                                 /* 비고 */
                                ,''                                                                 /* SMS발송순번 */
                                ,''                                                                 /* 이메일발송순번 */
                                ,IN_ID                                                              /* 입력ID */
                                ,IN_IP                                                              /* 입력IP */
                                ,SYSDATE                                                            /* 입력일시 */
                            )
                            RETURNING ROWID
                            INTO V_ROWID;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200001'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                          IF  V_OUT_CODE <> '0' THEN
                              SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                              OUT_NUM := V_OUT_CODE;
                              OUT_MSG :='신입생 등록 대상자 생성을 실패 하였습니다.[변경이력 생성 오류]';
                              RETURN;
                          END IF;

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* 등록금여부 */

                            /*  장학금이 있는 경우 */
                            IF LIST_DATA.SCAL_CD is not null THEN


                            SELECT COUNT(*)
                            INTO
                            V_SCAL_CNT
                            FROM SCHO530
                            WHERE
                            EXAM_STD_MNGT_NO = LIST_DATA.EXAM_STD_MNGT_NO
                            AND SCAL_CD  = LIST_DATA.SCAL_CD ;

                                IF V_SCAL_CNT < 1 THEN
                                    INSERT INTO SCHO530                                           /* 신입생장학선발내역 */
                                         (  EXAM_STD_MNGT_NO                                  /* 수험생관리번호 */
                                          , SCAL_CD                                           /* 장학코드 */
                                          , SLT_DT                                            /* 선발일자 */
                                          , ENTR_AMT                                          /* 입학금 */
                                          , LSN_AMT                                           /* 수업료 */
                                          , SSO_AMT                                           /* 기성회비 */
                                          , LIF_AMT                                           /* 생활비 */
                                          , STUDY_ENC_AMT                                     /* 학업장려비 */
                                          , TEACHM_AMT                                        /* 교재비 */
                                          , ETC_SCAL_AMT                                      /* 기타장학금 */
                                          , SCAL_TT_AMT                                       /* 장학총금액 */
                                          , SUBST_DED_NO                                      /* 대체증서번호 */
                                          , SCAL_SLT_PROG_ST_FG                               /* 장학선발진행상태구분 */
                                          , ACCPR_PERS_NO                                     /* 승인자개인번호 */
                                          , ACCP_DT                                           /* 승인일자 */
                                          , SCAL_SLT_NO                                       /* 장학선발번호 */
                                          , REMK                                              /* 비고 */
                                          , INPT_ID                                           /* 입력ID */
                                          , INPT_IP                                           /* 입력IP */
                                          , INPT_DTTM                                         /* 입력일시 */
                                          , MOD_ID                                            /* 수정ID */
                                          , MOD_IP                                            /* 수정IP */
                                          , MOD_DTTM                                          /* 수정일시 */
                                         )
                                         VALUES
                                         (  LIST_DATA.EXAM_STD_MNGT_NO                              /* 수험생관리번호 */
                                          , LIST_DATA.SCAL_CD                                       /* 장학코드 */
                                          , TO_CHAR(SYSDATE,'YYYYMMDD')                             /* 선발일자 */
                                          , NVL(V_SCAL_ENTR_AMT,0)                                  /* 장학입학금 */
                                          , NVL(V_SCAL_LSN_AMT,0)                                   /* 장학수업료 */
                                          , 0                                                       /* 기성회비 */
                                          , 0                                                       /* 생활비 */
                                          , 0                                                       /* 학업장려비 */
                                          , nvl(V_TEACHM_AMT,0)                                     /* 교재비 */
                                          , 0                                                       /* 기타장학금 */
                                          , NVL(V_SCAL_TT_AMT,0)                                    /* 장학총금액 */
                                          , ''                                                      /* 대체증서번호 */
                                          , 'U073300004'                                            /* 장학선발진행상태구분 확정처리 */
                                          , IN_ID                                                   /* 승인자개인번호 */
                                          , ''                                                      /* 승인일자 */
                                          , ''                                                      /* 장학선발번호 */
                                          , ''                                                      /* 비고 */
                                          , IN_ID                                                   /* 입력ID */
                                          , IN_IP                                                   /* 입력IP */
                                          , SYSDATE                                                 /* 입력일시 */
                                          , IN_ID                                                   /* 입력ID */
                                          , IN_IP                                                   /* 입력IP */
                                          , SYSDATE                                                 /* 입력일시 */
                                         ) ;
                                ELSE

                                UPDATE scho530                    /* 신입생장학선발내역 */
                                   SET SLT_DT                    = TO_CHAR(SYSDATE,'YYYYMMDD')          /* 선발일자 */
                                     , ENTR_AMT                  = NVL(V_SCAL_ENTR_AMT,0)               /* 장학입학금 */
                                     , LSN_AMT                   = NVL(V_SCAL_LSN_AMT,0)                /* 장학수업료 */
                                     , SSO_AMT                   = 0                                    /* 기성회비 */
                                     , LIF_AMT                   = 0                                    /* 생활비 */
                                     , STUDY_ENC_AMT             = 0                                    /* 학업장려비 */
                                     , TEACHM_AMT                = nvl(V_TEACHM_AMT,0)                  /* 교재비 */
                                     , ETC_SCAL_AMT              = 0                                    /* 기타장학금 */
                                     , SCAL_TT_AMT               = NVL(V_SCAL_TT_AMT,0)                 /* 장학총금액 */
                                     , SUBST_DED_NO              = ''                                   /* 대체증서번호 */
                                     , SCAL_SLT_PROG_ST_FG       = 'U073300004'                         /* 장학선발진행상태구분 */
                                     , ACCPR_PERS_NO             = IN_ID                                /* 승인자개인번호 */
                                     , MOD_ID                    = IN_ID                                /* 수정ID */
                                     , MOD_IP                    = IN_IP                                /* 수정IP */
                                     , MOD_DTTM                  = SYSDATE                              /* 수정일시 */
                                 WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO           /* 수험생관리번호 */
                                   AND SCAL_CD                   = LIST_DATA.SCAL_CD                    /* 장학코드 */
                                 ;

                                END IF;



                            END IF;

                        END IF;


                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                         V_MSG :='--------------33-3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] EXAM_STD_MNGT_NO['||LIST_DATA.EXAM_STD_MNGT_NO||']'
                              ||'] SCAL_CD['||LIST_DATA.SCAL_CD||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'||OUT_TRET_CNT;


                    END LOOP;

            ELSIF IN_TRET_FG IN('U','R') THEN  /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

             FOR LIST_DATA IN (
                            SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3   AS SELECT_USR_DEF                                  /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001  T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                      , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   T2.EXAM_STD_MNGT_NO  = T5.EXAM_STD_MNGT_NO
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T3.USR_DEF_3   AS SELECT_USR_DEF                                  /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   T2.EXAM_STD_MNGT_NO  = T5.EXAM_STD_MNGT_NO
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                   FROM    SREG001 T1
                                                                         , ENRO400 T2
                                                                         , V_COMM111_4 T4
                                                                  WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                    AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                    AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                    AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                                                                    AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                                                                    AND    T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                                                                    AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                                                                    AND    T2.STUNO IS NOT NULL
                                                                    AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                   WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                              ELSE 'C013300002'
                                                                                              END)
                                                                    AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                    AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                    AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )

                        )
                    LOOP

                             BEGIN

                                /*학적인적기본테이블의 부서코드로 등록금책정내역 유무 확인*/
                                SELECT
                                T1.ENTR_AMT                                     /* 입학금 */
                                ,T1.LSN_AMT                                      /* 수업료 */
                                ,T1.SSO_AMT                                      /* 기성회비 */
                                ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                ,T1.STDUNI_AMT                                   /* 학생회비 */
                                ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* 입학금 */
                                ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*학적인적기본의 부서코드로 등록금책정이 안된 경우 전공코드로 유무 확인*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* 입학금 */
                                    ,T1.LSN_AMT                                      /* 수업료 */
                                    ,T1.SSO_AMT                                      /* 기성회비 */
                                    ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                    ,T1.STDUNI_AMT                                   /* 학생회비 */
                                    ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                    ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                    ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                    ,'Y' AS YN
                                    INTO
                                    V_ENRO100_ENTR_AMT                              /* 입학금 */
                                    ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                    ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                    ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                    ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '해당 학과 전공에 대한 등록금책정 정보가 없습니다[학번 = ' || LIST_DATA.STUNO
                                 || ' / 학과코드 = ' || LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || '].';
                                RETURN;

                                END;

                            END;

                             /*학생*/
                            V_STD_ENTR_AMT := 0;       /* 입학금 */
                            V_STD_LSN_AMT  := 0;       /* 수업료 */
                            V_STD_REG_RESV_AMT:= 0;    /* 등록예치금 */
                            V_STD_REG_RESV_FG_AMT:= 0; /* 등록예치금 */

                            /*기관*/
                            V_BREU_ENTR_AMT := 0;     /* 입학금 */
                            V_BREU_LSN_AMT  := 0;     /* 수업료 */
                            V_BREU_REG_RESV_AMT:= 0;  /* 등록예치금 */

                            /*장학*/
                            V_SCAL_ENTR_AMT := 0;     /* 입학금 */
                            V_SCAL_LSN_AMT  := 0;     /* 수업료 */



                            /*기본등록금 입력*/
                            V_STD_ENTR_AMT      := V_ENRO100_ENTR_AMT;      /* 학생 입학금 */
                            V_STD_LSN_AMT       := V_ENRO100_LSN_AMT;       /* 학생 수업료 */
                            V_STD_REG_RESV_AMT  := V_ENRO100_REG_RESV_AMT;  /* 학생 등록예치금 */

                             /* 등록금 정책기준이 없는 경우 ,, 오류 처리*/
                            if V_STD_ENTR_AMT = 0 and V_STD_LSN_AMT = 0 AND V_STD_REG_RESV_AMT = 0 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '신입생 등록금책정기준을 확인 하세요.';
                                RETURN;

                            END IF;

                            /* 교재비*/
                            V_TEACHM_AMT := V_ENRO100_CMMN_TEACHM_AMT+V_ENRO100_CHOICE_TEACHM_AMT;

                            /* 계약학과 모집인 경우 */
                            IF LIST_DATA.SELECT_DEPT_CD != '00000' THEN

                                IF LIST_DATA.EDAMT_SUPP_BREU_CD IS NULL THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '교육비지원기관을 확인 하세요.';
                                    RETURN;
                                END IF;

                                BEGIN

                                    SELECT
                                        T1.STD_BUDEN_RATE                                                        /* 학생부담비율 */
                                       ,T1.BREU_BUDEN_RATE                                                       /* 기관부담비율 */
                                       ,T1.CSH_BUDEN_RATE                                                        /* 현금부담비율 */
                                       ,T1.ACTHNG_BUDEN_RATE                                                     /* 현물부담비율 */
                                       INTO
                                        V_STD_BUDEN_RATE
                                       ,V_BREU_BUDEN_RATE
                                       ,V_CSH_BUDEN_RATE
                                       ,V_ACTHNG_BUDEN_RATE
                                    FROM ENRO170 T1
                                    WHERE T1.EDAMT_SUPP_BREU_CD = LIST_DATA.EDAMT_SUPP_BREU_CD
                                    AND T1.DEPT_CD = LIST_DATA.SELECT_DEPT_CD;

                                     /*학생*/
                                    V_STD_ENTR_AMT :=(V_STD_BUDEN_RATE/100)* V_ENRO100_ENTR_AMT;         /* 학생 입학금 */
                                    V_STD_LSN_AMT  := (V_STD_BUDEN_RATE/100)* V_ENRO100_LSN_AMT;          /* 학생 수업료 */

                                    /*기관*/
                                    V_BREU_ENTR_AMT :=(V_BREU_BUDEN_RATE/100)*V_ENRO100_ENTR_AMT;         /* 기관 입학금 */
                                    V_BREU_LSN_AMT  := (V_BREU_BUDEN_RATE/100)*V_ENRO100_LSN_AMT;          /* 기관 수업료 */


                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '교육비지원기관가 없습니다.';
                                        RETURN;
                                    WHEN OTHERS THEN
                                        SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '교육비지원기관 데이터를 확인 하세요';
                                        RETURN;
                                END;

                            END IF;

                            /*  장학금이 있는 경우 */
                            IF LIST_DATA.SCAL_CD is not null THEN

                                BEGIN
                                     SELECT
                                            T2.ENTR_AMT_RATE                                     /* 입학금비율 */
                                          , T2.LSN_AMT_RATE                                      /* 수업료비율 */
                                    INTO
                                             V_SCAL_ENTR_AMT_RATE                                /* 입학금비율 */
                                          ,  V_SCAL_LSN_AMT_RATE                                 /* 수업료비율 */
                                    FROM
                                    SCHO100 T1
                                   ,SCHO110 T2
                                    WHERE  T1.SCAL_CD =  T2.SCAL_CD
                                    AND T1.SCAL_CD = LIST_DATA.SCAL_CD
                                    AND T1.BDEGR_SYSTEM_FG = LIST_DATA.BDEGR_SYSTEM_FG
                                    AND T2.SUBMATT_CORS_FG = (CASE WHEN LIST_DATA.SELECT_USR_DEF = '1' THEN 'U040800001'
                                                                   WHEN LIST_DATA.SELECT_USR_DEF = '2' THEN 'U040800002'
                                                             ELSE ''
                                                             END)
                                    ;

                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '장학금 상세정보가 없습니다.';
                                        RETURN;
                                    WHEN OTHERS THEN
                                        SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '장학금 처리를 실패 하였습니다.';
                                        RETURN;
                                END;

                                 /* 장학 */
                                 V_SCAL_ENTR_AMT :=(V_SCAL_ENTR_AMT_RATE/100)* V_ENRO100_ENTR_AMT;      /* 장학 입학금 */
                                 V_SCAL_LSN_AMT :=(V_SCAL_LSN_AMT_RATE/100)* V_ENRO100_LSN_AMT;         /* 장학 수업료 */
                                 V_SCAL_TT_AMT := V_SCAL_ENTR_AMT+V_SCAL_LSN_AMT;                        /*총금액*/

                            END IF;



                         IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* 등록금여부 */




                          /*학생*/
                            V_STD_ENTR_AMT := 0;       /* 입학금 */
                            V_STD_LSN_AMT  := 0;       /* 수업료 */
                            V_STD_REG_RESV_AMT:= 0;    /* 등록예치금 */
                            V_STD_REG_RESV_FG_AMT:= 0; /* 등록예치금 */

                            /*기관*/
                            V_BREU_ENTR_AMT := 0;     /* 입학금 */
                            V_BREU_LSN_AMT  := 0;     /* 수업료 */
                            V_BREU_REG_RESV_AMT:= 0;  /* 등록예치금 */

                            /*장학*/
                            V_SCAL_ENTR_AMT := 0;     /* 입학금 */
                            V_SCAL_LSN_AMT  := 0;     /* 수업료 */


                        END IF;


                         V_GV_ST_FG := 'U060500001';
                         V_AUTO_REG_FG := '';

                          IF  LIST_DATA.SELECT_USR_DEF = '2' THEN

                            IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* 등록금여부 */

                                     V_AUTO_REG_FG := 'U060600003';
                                     V_GV_ST_FG := 'U060500002';

                            ELSIF(V_SCAL_TT_AMT = (NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))) THEN

                                    V_AUTO_REG_FG := 'U060600001';
                                    V_GV_ST_FG := 'U060500002';


                             END IF;

                            IF V_AUTO_REG_FG IS NOT NULL THEN

                             SELECT  MIN(TO_CHAR(TO_DATE(T1.PAID_TO_DT,'YYYYMMDD'),'YYYYMMDD'))
                                INTO    V_PAID_TO_DT
                                FROM
                                ENRO450 T1
                                WHERE T1.ENTR_SCHYY = LIST_DATA.ENTR_SCHYY
                                AND T1.ENTR_SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND T1.SELECT_FG    = LIST_DATA.SELECT_FG
                                 and T1.PAID_FR_DT > to_char(sysdate,'YYYYMMDD');

                              IF V_PAID_TO_DT IS NULL THEN

                                OUT_NUM := -10000;
                                OUT_MSG := '납부종료일자를 확인 하세요.';
                                SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , OUT_NUM, OUT_MSG, IN_ID, IN_IP);
                                RETURN;

                              END IF;

                            END IF;

                        END IF;



                    /* 2015.12.07   권순태   ENRO410 UPDATE 시, EDAMT_SUPP_BREU_CD(교육비지원기관코드), STD_BUDEN_RATE(학생부담비율), BREU_BUDEN_RATE(기관부담비율)도 업데이트 되도록 수정. */
                    UPDATE ENRO410                                                                           /* 신입생등록대상자내역 */
                       SET
                           CNTR_SUST_YN              = (CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                                             ELSE 'N'
                                                        END )                                                   /* 계약학과여부 */
                         , EDAMT_SUPP_BREU_CD        = LIST_DATA.EDAMT_SUPP_BREU_CD                             /* 교육비지원기관코드 */
                         , STD_BUDEN_RATE            = V_STD_BUDEN_RATE                                         /* 학생부담비율 */
                         , BREU_BUDEN_RATE           = V_BREU_BUDEN_RATE                                        /* 기관부담비율 */
                         , REG_RESV_AMT              = V_STD_REG_RESV_FG_AMT                                    /* 등록예치금 */
                         , ENTR_AMT                  = V_STD_ENTR_AMT                                           /* 입학금 */
                         , LSN_AMT                   = V_STD_LSN_AMT                                            /* 수업료 */
                         , REG_TT_AMT                = (V_STD_REG_RESV_FG_AMT+V_STD_ENTR_AMT+V_STD_LSN_AMT)     /* 등록총금액 */
                         , BREU_ENTR_AMT             = V_BREU_ENTR_AMT                                          /* 기관입학금 */
                         , BREU_LSN_AMT              = V_BREU_LSN_AMT                                           /* 기관수업료 */
                         , BREU_REG_TT_AMT           = (V_BREU_ENTR_AMT+V_BREU_LSN_AMT)                         /* 기관등록총금액 */
                         , SCAL_ENTR_AMT             = V_SCAL_ENTR_AMT                                          /* 장학입학금 */
                         , SCAL_LSN_AMT              = V_SCAL_LSN_AMT                                           /* 장학수업료 */
                         , SCAL_TT_AMT               = NVL(V_SCAL_TT_AMT,0)                                     /* 장학총금액 */
                         , STDUNI_AMT                = V_ENRO100_STDUNI_AMT                                     /* 학생회비*/
                         , TEACHM_AMT                = (CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                                             ELSE NVL(V_TEACHM_AMT, 0)
                                                        END )                                                   /* 교재비 */
                         , MOD_ID                    = IN_ID                                                    /* 수정ID */
                         , MOD_IP                    = IN_IP                                                    /* 수정IP */
                         , MOD_DTTM                  = SYSDATE                                                  /* 수정일시 */
                     WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                              /* 수험생관리번호 */
                     RETURNING ROWID INTO  V_ROWID
                     ;

                              SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                        ,IN_ID => IN_ID
                                        ,IN_IP => IN_IP
                                        ,IN_CHG_FG => 'C015200002'
                                        ,IN_OWNER => 'SNU'
                                        ,IN_TABLE_ID => 'ENRO410'
                                        ,IN_ROWID => V_ROWID
                                        ,OUT_CODE => V_OUT_CODE
                                        ,OUT_MSG => V_OUT_MSG);

                              IF  V_OUT_CODE <> '0' THEN
                                  SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                  OUT_NUM := V_OUT_CODE;
                                  OUT_MSG :='신입생 등록 대상자 생성을 실패 하였습니다.[변경이력 생성 오류]';
                                  RETURN;
                              END IF;

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* 등록금여부 */
                            /*  장학금이 있는 경우 */
                            IF LIST_DATA.SCAL_CD is not null AND IN_REG_RESV_FG = 'E' THEN  /* 등록구분(예치금반영구분) 'R'='등록금예치금', 'E'='등록금' */


                            SELECT COUNT(*)
                            INTO
                            V_SCAL_CNT
                            FROM SCHO530
                            WHERE
                            EXAM_STD_MNGT_NO = LIST_DATA.EXAM_STD_MNGT_NO
                            AND SCAL_CD  = LIST_DATA.SCAL_CD ;

                                IF V_SCAL_CNT < 1 THEN
                                    INSERT INTO SCHO530                                           /* 신입생장학선발내역 */
                                         (  EXAM_STD_MNGT_NO                                  /* 수험생관리번호 */
                                          , SCAL_CD                                           /* 장학코드 */
                                          , SLT_DT                                            /* 선발일자 */
                                          , ENTR_AMT                                          /* 입학금 */
                                          , LSN_AMT                                           /* 수업료 */
                                          , SSO_AMT                                           /* 기성회비 */
                                          , LIF_AMT                                           /* 생활비 */
                                          , STUDY_ENC_AMT                                     /* 학업장려비 */
                                          , TEACHM_AMT                                        /* 교재비 */
                                          , ETC_SCAL_AMT                                      /* 기타장학금 */
                                          , SCAL_TT_AMT                                       /* 장학총금액 */
                                          , SUBST_DED_NO                                      /* 대체증서번호 */
                                          , SCAL_SLT_PROG_ST_FG                               /* 장학선발진행상태구분 */
                                          , ACCPR_PERS_NO                                     /* 승인자개인번호 */
                                          , ACCP_DT                                           /* 승인일자 */
                                          , SCAL_SLT_NO                                       /* 장학선발번호 */
                                          , REMK                                              /* 비고 */
                                          , INPT_ID                                           /* 입력ID */
                                          , INPT_IP                                           /* 입력IP */
                                          , INPT_DTTM                                         /* 입력일시 */
                                          , MOD_ID                                            /* 수정ID */
                                          , MOD_IP                                            /* 수정IP */
                                          , MOD_DTTM                                          /* 수정일시 */
                                         )
                                         VALUES
                                         (  LIST_DATA.EXAM_STD_MNGT_NO                              /* 수험생관리번호 */
                                          , LIST_DATA.SCAL_CD                                       /* 장학코드 */
                                          , TO_CHAR(SYSDATE,'YYYYMMDD')                             /* 선발일자 */
                                          , NVL(V_SCAL_ENTR_AMT,0)                                  /* 장학입학금 */
                                          , NVL(V_SCAL_LSN_AMT,0)                                   /* 장학수업료 */
                                          , 0                                                       /* 기성회비 */
                                          , 0                                                       /* 생활비 */
                                          , 0                                                       /* 학업장려비 */
                                          , nvl(V_TEACHM_AMT,0)                                     /* 교재비 */
                                          , 0                                                       /* 기타장학금 */
                                          , NVL(V_SCAL_TT_AMT,0)                                    /* 장학총금액 */
                                          , ''                                                      /* 대체증서번호 */
                                          , 'U073300004'                                            /* 장학선발진행상태구분 확정처리 */
                                          , IN_ID                                                   /* 승인자개인번호 */
                                          , ''                                                      /* 승인일자 */
                                          , ''                                                      /* 장학선발번호 */
                                          , ''                                                      /* 비고 */
                                          , IN_ID                                                   /* 입력ID */
                                          , IN_IP                                                   /* 입력IP */
                                          , SYSDATE                                                 /* 입력일시 */
                                          , IN_ID                                                   /* 입력ID */
                                          , IN_IP                                                   /* 입력IP */
                                          , SYSDATE                                                 /* 입력일시 */
                                         ) ;
                                ELSE

                                UPDATE scho530                    /* 신입생장학선발내역 */
                                   SET SLT_DT                    = TO_CHAR(SYSDATE,'YYYYMMDD')          /* 선발일자 */
                                     , ENTR_AMT                  = NVL(V_SCAL_ENTR_AMT,0)               /* 장학입학금 */
                                     , LSN_AMT                   = NVL(V_SCAL_LSN_AMT,0)                /* 장학수업료 */
                                     , SSO_AMT                   = 0                                    /* 기성회비 */
                                     , LIF_AMT                   = 0                                    /* 생활비 */
                                     , STUDY_ENC_AMT             = 0                                    /* 학업장려비 */
                                     , TEACHM_AMT                = nvl(V_TEACHM_AMT,0)                  /* 교재비 */
                                     , ETC_SCAL_AMT              = 0                                    /* 기타장학금 */
                                     , SCAL_TT_AMT               = NVL(V_SCAL_TT_AMT,0)                 /* 대체증서번호 */
                                     , SCAL_SLT_PROG_ST_FG       = 'U073300004'                         /* 장학선발진행상태구분 */
                                     , ACCPR_PERS_NO             = IN_ID                                /* 승인자개인번호 */
                                     , MOD_ID                    = IN_ID                                /* 수정ID */
                                     , MOD_IP                    = IN_IP                                /* 수정IP */
                                     , MOD_DTTM                  = SYSDATE                              /* 수정일시 */
                                 WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO           /* 수험생관리번호 */
                                   AND SCAL_CD                   = LIST_DATA.SCAL_CD                    /* 장학코드 */
                                 ;

                                END IF;



                            END IF;

                        END IF;

                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                         V_MSG :='---------------3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']';


                    END LOOP;


            END IF;

        END IF;

    ELSIF V_BNSN011_USR_DEF_2 = '1' THEN /* 수시*/

        V_MSG :='---------------3--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
        ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
        ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
        ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
        ||'] IN_TRET_FG['||IN_TRET_FG||']'
        ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
        ||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
        ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
        ||'] IN_TRET_FG['||IN_TRET_FG||']'
        ||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;

        IF IN_REG_RESV_FG = 'R' then /* 등록구분(예치금반영구분) 'R'='등록금예치금', 'E'='등록금' */

            IF IN_TRET_FG = 'C' THEN  /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

              FOR LIST_DATA IN (
                         SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3   AS SELECT_USR_DEF                                  /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3  AS SELECT_USR_DEF                                   /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                    FROM    SREG001 T1
                                                                          , ENRO400 T2
                                                                          , V_COMM111_4 T4
                                                                   WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                     AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                     AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                     AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                                                                     AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                                                                     AND    T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                                                                     AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                                                                     and    T2.STUNO is not null
                                                                     AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                    WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                               ELSE 'C013300002'
                                                                                               END)
                                                                     AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                     AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                     AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
                        )
                    LOOP

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* 등록금여부 */

                             BEGIN

                                /*학적인적기본테이블의 부서코드로 등록금책정내역 유무 확인*/
                                SELECT
                                T1.ENTR_AMT                                     /* 입학금 */
                                ,T1.LSN_AMT                                      /* 수업료 */
                                ,T1.SSO_AMT                                      /* 기성회비 */
                                ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                ,T1.STDUNI_AMT                                   /* 학생회비 */
                                ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* 입학금 */
                                ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*학적인적기본의 부서코드로 등록금책정이 안된 경우 전공코드로 유무 확인*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* 입학금 */
                                    ,T1.LSN_AMT                                      /* 수업료 */
                                    ,T1.SSO_AMT                                      /* 기성회비 */
                                    ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                    ,T1.STDUNI_AMT                                   /* 학생회비 */
                                    ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                    ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                    ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                    ,'Y' AS YN
                                    INTO
                                    V_ENRO100_ENTR_AMT                              /* 입학금 */
                                    ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                    ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                    ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                    ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '해당 학과 전공에 대한 등록금책정 정보가 없습니다[학번 = ' || LIST_DATA.STUNO
                                 ||'ENTR_SCHYY  '||LIST_DATA.ENTR_SCHYY
                                ||'ENTR_SHTM_FG '||LIST_DATA.ENTR_SHTM_FG
                                ||'DETA_SHTM_FG  '||LIST_DATA.DETA_SHTM_FG
                                ||'CORS_FG  '||LIST_DATA.CORS_FG
                                ||'SHYR'||LIST_DATA.SHYR
                                ||'DAYNGT_FG'||LIST_DATA.DAYNGT_FG
                                || ' / 전공(학과)코드 = ' ||LIST_DATA.DEPARTMENT_CD||'('|| LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || ')].';
                                RETURN;

                                END;

                            END;

                             /* 등록금 정책기준이 없는 경우 ,, 오류 처리*/
                            if V_ENRO100_REG_RESV_AMT = 0 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '신입생 등록금책정기준을 확인 하세요.';
                                RETURN;

                            END IF;

                        END IF;

                         V_MSG :='---------------44--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
                            ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                            ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                            ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                            ||'] IN_TRET_FG['||IN_TRET_FG||']'
                            ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
                            ||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
                            ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
                            ||'] IN_TRET_FG['||IN_TRET_FG||']'
                            ||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']';


                       INSERT INTO ENRO410(
                                     EXAM_STD_MNGT_NO                /* 수험생관리번호(PK1) */
                                    ,SCAL_CD                         /* 장학코드 */
                                    ,CNTR_SUST_YN                    /* 계약학과여부 */
                                    ,EDAMT_SUPP_BREU_CD              /* 교육비지원기관코드 */
                                    ,STD_BUDEN_RATE                  /* 학생부담비율 */
                                    ,BREU_BUDEN_RATE                 /* 기관부담비율 */
                                    ,CSH_BUDEN_RATE                  /* 현금부담비율 */
                                    ,ACTHNG_BUDEN_RATE               /* 현물부담비율 */
                                    ,CAL_CLS_YN                      /* 산출완료여부 */
                                    ,REG_RESV_AMT                    /* 등록예치금 */
                                    ,ENTR_AMT                        /* 입학금 */
                                    ,LSN_AMT                         /* 수업료 */
                                    ,REG_TT_AMT                      /* 등록총금액 */
                                    ,BREU_ENTR_AMT                   /* 기관입학금 */
                                    ,BREU_LSN_AMT                    /* 기관수업료 */
                                    ,BREU_REG_TT_AMT                 /* 기관등록총금액 */
                                    ,SCAL_ENTR_AMT                   /* 장학입학금 */
                                    ,SCAL_LSN_AMT                    /* 장학수업료 */
                                    ,SCAL_TT_AMT                     /* 장학총금액 */
                                    ,STDUNI_AMT                      /* 학생회비 */
                                    ,TEACHM_AMT                      /* 교재비 */
                                    ,RECIV_REG_RESV_AMT              /* 수납등록예치금 */
                                    ,RECIV_ENTR_AMT                  /* 수납입학금 */
                                    ,RECIV_LSN_AMT                   /* 수납수업료 */
                                    ,RECIV_TT_AMT                    /* 수납총금액 */
                                    ,BREU_RECIV_ENTR_AMT             /* 기관수납입학금 */
                                    ,BREU_RECIV_LSN_AMT              /* 기관수납수업료 */
                                    ,BREU_RECIV_TT_AMT               /* 기관수납총금액 */
                                    ,RECIV_STDUNI_AMT                /* 수납학생회비 */
                                    ,RECIV_TEACHM_AMT                /* 수납교재비 */
                                    ,GV_ST_FG                        /* 납입상태구분 */
                                    ,AUTO_REG_FG                     /* 자동등록구분 */
                                    ,RECIV_DT                        /* 수납일자 */
                                    ,REMK                            /* 비고 */
                                    ,SMS_SEND_SEQ                    /* SMS발송순번 */
                                    ,EMAIL_SEND_SEQ                  /* 이메일발송순번 */
                                    ,INPT_ID                         /* 입력ID */
                                    ,INPT_IP                         /* 입력IP */
                                    ,INPT_DTTM                       /* 입력일시 */
                                    ,REG_RESV_AMT_GV_ST_FG
                            )VALUES(
                                     LIST_DATA.EXAM_STD_MNGT_NO                                         /* 수험생관리번호(PK1) */
                                    ,LIST_DATA.SCAL_CD                                                  /* 장학코드 */
                                    ,(CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                      ELSE 'N'
                                      END )                                                             /* 계약학과여부 */
                                    ,LIST_DATA.EDAMT_SUPP_BREU_CD                                       /* 교육비지원기관코드 */
                                    ,V_STD_BUDEN_RATE                                                   /* 학생부담비율 */
                                    ,V_BREU_BUDEN_RATE                                                  /* 기관부담비율 */
                                    ,V_CSH_BUDEN_RATE                                                   /* 현금부담비율 */
                                    ,V_ACTHNG_BUDEN_RATE                                                /* 현물부담비율 */
                                    ,'N'                                                                /* 산출완료여부 */
                                    ,NVL(V_ENRO100_REG_RESV_AMT, 0)                                      /* 등록예치금 */
                                    ,0                                                                  /* 입학금 */
                                    ,0                                                                  /* 수업료 */
                                    ,0                                                                  /* (입학금+수업료) 등록총금액 */
                                    ,0                                                                  /* 기관입학금 */
                                    ,0                                                                  /* 기관수업료 */
                                    ,0                                                                  /* (입학금+수업료) 기관등록총금액 */
                                    ,0                                                                  /* 장학입학금 */
                                    ,0                                                                  /* 장학수업료 */
                                    ,0                                                                  /* (입학금+수업료) 장학등록총금액 */
                                    ,0                                                                  /* 학생회비 */
                                    ,0                                                                  /* 교재비(공통+선택) */
                                    ,0                                                                  /* 수납등록예치금 */
                                    ,0                                                                  /* 수납입학금 */
                                    ,0                                                                  /* 수납수업료 */
                                    ,0                                                                  /* 수납총금액 */
                                    ,0                                                                  /* 기관수납입학금 */
                                    ,0                                                                  /* 기관수납수업료 */
                                    ,0                                                                  /* 기관수납총금액 */
                                    ,0                                                                  /* 수납학생회비 */
                                    ,0                                                                  /* 수납교재비 */
                                    ,'U060500001'                                                       /* 납입상태구분(미등록) */
                                    ,''                                                                 /* 자동등록구분 */
                                    ,''                                                                 /* 수납일자 */
                                    ,''                                                                 /* 비고 */
                                    ,''                                                                 /* SMS발송순번 */
                                    ,''                                                                 /* 이메일발송순번 */
                                    ,IN_ID                                                              /* 입력ID */
                                    ,IN_IP                                                              /* 입력IP */
                                    ,SYSDATE                                                            /* 입력일시 */
                                    ,'U060500001'                                                       /* 등록예치금납입상태구분*/
                                )
                            RETURNING ROWID
                            INTO V_ROWID;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200001'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                          IF  V_OUT_CODE <> '0' THEN
                              SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                              OUT_NUM := V_OUT_CODE;
                              OUT_MSG :='신입생 등록 대상자 생성을 실패 하였습니다.[변경이력 생성 오류]';
                              RETURN;
                          END IF;

                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                    END LOOP;

            ELSIF IN_TRET_FG IN('U','R') THEN  /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

             FOR LIST_DATA IN (
                            SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- end */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,t3.USR_DEF_3   AS SELECT_USR_DEF                                  /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG    = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                   FROM    SREG001 T1
                                                                         , ENRO400 T2
                                                                         , V_COMM111_4 T4
                                                                  WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                    AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                    AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                    AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                                                                    AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                                                                    AND    T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                                                                    AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                                                                    AND    T2.STUNO IS NOT NULL
                                                                    AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                   WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                              ELSE 'C013300002'
                                                                                              END)
                                                                    AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                    AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                    AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- end */
                    )
                    LOOP

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* 등록금여부 */

                           BEGIN

                                /*학적인적기본테이블의 부서코드로 등록금책정내역 유무 확인*/
                                SELECT
                                T1.ENTR_AMT                                     /* 입학금 */
                                ,T1.LSN_AMT                                      /* 수업료 */
                                ,T1.SSO_AMT                                      /* 기성회비 */
                                ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                ,T1.STDUNI_AMT                                   /* 학생회비 */
                                ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* 입학금 */
                                ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                           EXCEPTION
                                WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*학적인적기본의 부서코드로 등록금책정이 안된 경우 전공코드로 유무 확인*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* 입학금 */
                                    ,T1.LSN_AMT                                      /* 수업료 */
                                    ,T1.SSO_AMT                                      /* 기성회비 */
                                    ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                    ,T1.STDUNI_AMT                                   /* 학생회비 */
                                    ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                    ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                    ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                    ,'Y' AS YN
                                    INTO
                                    V_ENRO100_ENTR_AMT                              /* 입학금 */
                                    ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                    ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                    ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                    ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                    OUT_NUM := -1;
                                    OUT_MSG := '해당 학과 전공에 대한 등록금책정 정보가 없습니다[학번 = ' || LIST_DATA.STUNO || ' / 학과코드 = ' || LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || '].';
                                    RETURN;

                                END;

                           END;

                             /* 등록금 정책기준이 없는 경우 ,, 오류 처리*/
                            if V_ENRO100_REG_RESV_AMT < 1 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '신입생 등록금책정기준을 확인 하세요.';
                                RETURN;

                            END IF;

                        END IF;

                    UPDATE enro410                                                                        /* 신입생등록대상자내역 */
                       SET
                           REG_RESV_AMT              = V_ENRO100_REG_RESV_AMT                             /* 등록예치금*/
                         , MOD_ID                    = IN_ID                                              /* 수정ID */
                         , MOD_IP                    = IN_IP                                              /* 수정IP */
                         , MOD_DTTM                  = SYSDATE                                            /* 수정일시 */
                     WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                         /* 수험생관리번호 */
                     RETURNING ROWID INTO  V_ROWID
                     ;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200002'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                      IF  V_OUT_CODE <> '0' THEN
                          SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                          OUT_NUM := V_OUT_CODE;
                          OUT_MSG :='신입생 등록 대상자 생성을 실패 하였습니다.[변경이력 생성 오류]';
                          RETURN;
                      END IF;




                         V_MSG :='---------------3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']';



                      OUT_TRET_CNT := OUT_TRET_CNT+1;

                    END LOOP;

            END IF;


        ELSIF IN_REG_RESV_FG = 'E' then /* 등록구분(예치금반영구분) 'R'='등록금예치금', 'E'='등록금' */



            IF V_RESV_GV_CNT < 1  THEN

                SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                OUT_NUM := '-1';
                OUT_MSG :='예치금납입 처리된 데이터가 없어서 대상자 생성 및 등록금 재산출이 불가 합니다.';
                RETURN;

            END IF;

             FOR LIST_DATA IN (
                        SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,T5.REG_RESV_AMT
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              AND   T5.REG_RESV_AMT_GV_ST_FG = 'U060500002'
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- end */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* 수험생관리번호(PK1) */
                               ,T2.ENTR_SCHYY                                   /* 입학학년도 */
                               ,T2.ENTR_SHTM_FG                                 /* 입학학기구분 */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* 전형구분 */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* 전형구분부서*/
                               ,T2.EXAM_NO                                      /* 수험번호 */
                               ,T2.RES_NO                                       /* 주민등록번호 */
                               ,T2.STUNO                                        /* 학번 */
                               ,T2.SHYR                                         /* 학년*/
                               ,T2.RPST_PERS_NO                                 /* 대표개인번호 */
                               ,T2.STD_KOR_NM                                   /* 학생한글명 */
                               ,T2.STD_CHA_NM                                   /* 학생한자명 */
                               ,T2.STD_ENG_NM                                   /* 학생영문명 */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* 과정구분 */
                               ,T2.DAYNGT_FG                                    /* 주야구분 */
                               ,T2.NATI_FG                                      /* 국적구분 */
                               ,T2.PASS_SEQ                                     /* 합격차수 */
                               ,T2.EXAM_COLL_UNIT_CD                            /* 입시모집단위코드 */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* 입시모집부서*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* 입시모집단위명 */
                               ,T2.SPCMAJ_NM                                    /* 세부전공명 */
                               ,T2.SCAL_CD                                      /* 장학코드 */
                               ,T2.TRANS_YN                                     /* 이관여부 */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* 교육비지원기관코드 */
                               ,T4.BDEGR_SYSTEM_FG                              /* 학사시스템구분 */
                               ,T4.DEPARTMENT_CD                                /*학과*/
                               ,T4.MAJOR_CD                                     /*전공*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,T5.REG_RESV_AMT                                 /* 등록예치금 */
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* 사용자 정의3 1이면 학부 2이면 대학원*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* 전형구분 */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T5.REG_RESV_AMT_GV_ST_FG = 'U060500002'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 발표완료여부가 'Y'인 경우만 생성 */
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                    FROM    SREG001 T1
                                                                          , ENRO400 T2
                                                                          , V_COMM111_4 T4
                                                                   WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                     AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                     AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                     AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* 입학학년도*/
                                                                     AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* 입학학기구분*/
                                                                     AND    T2.SELECT_FG    = IN_SELECT_FG                         /* 전형구분*/
                                                                     AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* 합격차수*/
                                                                     and    T2.STUNO is not null
                                                                     AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                    WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                                   ELSE 'C013300002'
                                                                                                   END)
                                                                     AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                     AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                     AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 가상계좌가 부여된 내역이 있으면 미부여된 대상자만 생성하도록 변경 */
                              /* 2016.01.20 등록금, (예치금반영산출, 등록금재산출) 처리기능 수정( T1601190083 ) -- end */
                    )
                    LOOP

                        BEGIN

                            /*학적인적기본테이블의 부서코드로 등록금책정내역 유무 확인*/
                            SELECT T1.ENTR_AMT                                     /* 입학금 */
                                  ,T1.LSN_AMT                                      /* 수업료 */
                                  ,T1.SSO_AMT                                      /* 기성회비 */
                                  ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                  ,T1.STDUNI_AMT                                   /* 학생회비 */
                                  ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                  ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                  ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                  ,'Y' AS YN
                              INTO V_ENRO100_ENTR_AMT                              /* 입학금 */
                                  ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                  ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                  ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                  ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                  ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                  ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                  ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                  ,V_ENRO100_YN
                              FROM ENRO100 T1
                             WHERE T1.SCHYY = LIST_DATA.ENTR_SCHYY
                               AND T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                               AND T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                               AND T1.CORS_FG = LIST_DATA.CORS_FG
                               AND T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                               AND T1.SHYR = LIST_DATA.SHYR
                               AND T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN

                            BEGIN
                                /*학적인적기본의 부서코드로 등록금책정이 안된 경우 전공코드로 유무 확인*/
                                SELECT T1.ENTR_AMT                                     /* 입학금 */
                                      ,T1.LSN_AMT                                      /* 수업료 */
                                      ,T1.SSO_AMT                                      /* 기성회비 */
                                      ,T1.REG_RESV_AMT                                 /* 등록예치금 */
                                      ,T1.STDUNI_AMT                                   /* 학생회비 */
                                      ,T1.MEDI_DUC_AMT                                 /* 의료공제비 */
                                      ,T1.CMMN_TEACHM_AMT                              /* 공통교재비 */
                                      ,T1.CHOICE_TEACHM_AMT                            /* 선택교재비 */
                                      ,'Y' AS YN
                                  INTO V_ENRO100_ENTR_AMT                              /* 입학금 */
                                      ,V_ENRO100_LSN_AMT                               /* 수업료 */
                                      ,V_ENRO100_SSO_AMT                               /* 기성회비 */
                                      ,V_ENRO100_REG_RESV_AMT                          /* 등록예치금 */
                                      ,V_ENRO100_STDUNI_AMT                            /* 학생회비 */
                                      ,V_ENRO100_MEDI_DUC_AMT                          /* 의료공제비 */
                                      ,V_ENRO100_CMMN_TEACHM_AMT                       /* 공통교재비 */
                                      ,V_ENRO100_CHOICE_TEACHM_AMT                     /* 선택교재비 */
                                      ,V_ENRO100_YN
                                  FROM ENRO100 T1
                                 WHERE T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                   AND T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                   AND T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                   AND T1.CORS_FG = LIST_DATA.CORS_FG
                                   AND T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                   AND T1.SHYR = LIST_DATA.SHYR
                                   AND T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '해당 학과 전공에 대한 등록금책정 정보가 없습니다[학번 = ' || LIST_DATA.STUNO || ' / 학과코드 = ' || LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || '].';
                                RETURN;

                            END;

                        END;

                         /*학생*/
                        V_STD_ENTR_AMT := 0;       /* 입학금 */
                        V_STD_LSN_AMT  := 0;       /* 수업료 */
                        V_STD_REG_RESV_AMT:= 0;    /* 등록예치금 */
                        V_STD_REG_RESV_FG_AMT:= 0; /* 등록예치금 */

                        /*기관*/
                        V_BREU_ENTR_AMT := 0;     /* 입학금 */
                        V_BREU_LSN_AMT  := 0;     /* 수업료 */
                        V_BREU_REG_RESV_AMT:= 0;  /* 등록예치금 */

                        /*장학*/
                        V_SCAL_ENTR_AMT := 0;     /* 입학금 */
                        V_SCAL_LSN_AMT  := 0;     /* 수업료 */



                        /*기본등록금 입력*/
                        V_STD_ENTR_AMT      := V_ENRO100_ENTR_AMT;      /* 학생 입학금 */
                        V_STD_LSN_AMT       := V_ENRO100_LSN_AMT;       /* 학생 수업료 */
                        V_STD_REG_RESV_AMT  := V_ENRO100_REG_RESV_AMT;  /* 학생 등록예치금 */

                         /* 등록금 정책기준이 없는 경우 ,, 오류 처리*/
                        if V_STD_ENTR_AMT = 0 and V_STD_LSN_AMT = 0 AND V_STD_REG_RESV_AMT = 0 THEN

                            OUT_NUM := -1000;
                            OUT_MSG := '신입생 등록금책정기준을 확인 하세요.';
                            RETURN;

                        END IF;

                        /* 교재비*/
                        V_TEACHM_AMT := V_ENRO100_CMMN_TEACHM_AMT+V_ENRO100_CHOICE_TEACHM_AMT;

                        /* 계약학과 모집인 경우 */
                        IF LIST_DATA.SELECT_DEPT_CD != '00000' THEN

                            IF LIST_DATA.EDAMT_SUPP_BREU_CD IS NULL THEN
                                OUT_NUM := -1000;
                                OUT_MSG := '교육비지원기관을 확인 하세요.';
                                RETURN;
                            END IF;

                            BEGIN

                                SELECT
                                    T1.STD_BUDEN_RATE                                                        /* 학생부담비율 */
                                   ,T1.BREU_BUDEN_RATE                                                       /* 기관부담비율 */
                                   ,T1.CSH_BUDEN_RATE                                                        /* 현금부담비율 */
                                   ,T1.ACTHNG_BUDEN_RATE                                                     /* 현물부담비율 */
                                   INTO
                                    V_STD_BUDEN_RATE
                                   ,V_BREU_BUDEN_RATE
                                   ,V_CSH_BUDEN_RATE
                                   ,V_ACTHNG_BUDEN_RATE
                                FROM ENRO170 T1
                                WHERE T1.EDAMT_SUPP_BREU_CD = LIST_DATA.EDAMT_SUPP_BREU_CD
                                AND T1.DEPT_CD = LIST_DATA.SELECT_DEPT_CD;

                                 /*학생*/
                                V_STD_ENTR_AMT :=(V_STD_BUDEN_RATE/100)* V_ENRO100_ENTR_AMT;         /* 학생 입학금 */
                                V_STD_LSN_AMT  := (V_STD_BUDEN_RATE/100)* V_ENRO100_LSN_AMT;          /* 학생 수업료 */

                                /*기관*/
                                V_BREU_ENTR_AMT :=(V_BREU_BUDEN_RATE/100)*V_ENRO100_ENTR_AMT;         /* 기관 입학금 */
                                V_BREU_LSN_AMT  := (V_BREU_BUDEN_RATE/100)*V_ENRO100_LSN_AMT;          /* 기관 수업료 */


                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '교육비지원기관가 없습니다.';
                                    RETURN;
                                WHEN OTHERS THEN
                                    SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                    OUT_NUM := SQLCODE;
                                    OUT_MSG := '교육비지원기관 데이터를 확인 하세요';
                                    RETURN;
                            END;

                        END IF;

                        /*  장학금이 있는 경우 */
                        IF LIST_DATA.SCAL_CD is not null THEN

                            BEGIN
                                 SELECT
                                        T2.ENTR_AMT_RATE                                     /* 입학금비율 */
                                      , T2.LSN_AMT_RATE                                      /* 수업료비율 */
                                INTO
                                         V_SCAL_ENTR_AMT_RATE                                /* 입학금비율 */
                                      ,  V_SCAL_LSN_AMT_RATE                                 /* 수업료비율 */
                                FROM
                                SCHO100 T1
                               ,SCHO110 T2
                                WHERE  T1.SCAL_CD =  T2.SCAL_CD
                                AND T1.SCAL_CD = LIST_DATA.SCAL_CD
                                AND T1.BDEGR_SYSTEM_FG = LIST_DATA.BDEGR_SYSTEM_FG
                                AND T2.SUBMATT_CORS_FG = (CASE WHEN LIST_DATA.SELECT_USR_DEF = '1' THEN 'U040800001'
                                                               WHEN LIST_DATA.SELECT_USR_DEF = '2' THEN 'U040800002'
                                                         ELSE ''
                                                         END)
                                ;

                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '장학금 상세정보가 없습니다.';
                                    RETURN;
                                WHEN OTHERS THEN
                                    SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                    OUT_NUM := SQLCODE;
                                    OUT_MSG := '장학금 처리를 실패 하였습니다.';
                                    RETURN;
                            END;



                            /* 장학 */
                             V_SCAL_ENTR_AMT :=(V_SCAL_ENTR_AMT_RATE/100)* V_ENRO100_ENTR_AMT;      /* 장학 입학금 */
                             V_SCAL_LSN_AMT :=(V_SCAL_LSN_AMT_RATE/100)* V_ENRO100_LSN_AMT;         /* 장학 수업료 */
                             V_SCAL_TT_AMT := V_SCAL_ENTR_AMT+V_SCAL_LSN_AMT;                        /*총금액*/

                        END IF;


                        IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* 등록금여부 */

                            /*학생*/
                            V_STD_ENTR_AMT := 0;       /* 입학금 */
                            V_STD_LSN_AMT  := 0;       /* 수업료 */
                            V_STD_REG_RESV_AMT:= 0;    /* 등록예치금 */
                            V_STD_REG_RESV_FG_AMT:= 0; /* 등록예치금 */

                            /*기관*/
                            V_BREU_ENTR_AMT := 0;     /* 입학금 */
                            V_BREU_LSN_AMT  := 0;     /* 수업료 */
                            V_BREU_REG_RESV_AMT:= 0;  /* 등록예치금 */

                            /*장학*/
                            V_SCAL_ENTR_AMT := 0;     /* 입학금 */
                            V_SCAL_LSN_AMT  := 0;     /* 수업료 */

                        END IF;


                        V_GV_ST_FG := 'U060500001';
                        V_AUTO_REG_FG := NULL;

                        IF  LIST_DATA.SELECT_USR_DEF = '2' THEN

                            IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* 등록금여부 */

                                V_AUTO_REG_FG := 'U060600003';
                                V_GV_ST_FG := 'U060500002';

                            ELSIF(V_SCAL_TT_AMT = (NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))) THEN

                                V_AUTO_REG_FG := 'U060600001';
                                V_GV_ST_FG := 'U060500002';

                             END IF;

                            IF V_AUTO_REG_FG IS NOT NULL THEN


                                SELECT MAX(TO_CHAR(TO_DATE(T1.PAID_TO_DT,'YYYYMMDD')+1,'YYYYMMDD'))
                                  INTO V_PAID_TO_DT
                                  FROM ENRO450 T1
                                 WHERE T1.ENTR_SCHYY   = LIST_DATA.ENTR_SCHYY
                                   AND T1.ENTR_SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                   AND T1.SELECT_FG    = LIST_DATA.SELECT_FG
                                   AND T1.REG_KND_FG   = 'U060300001'
                                ;

                                IF V_PAID_TO_DT IS NULL THEN

                                    OUT_NUM := -10000;
                                    OUT_MSG := '납부종료일자를 확인 하세요.';
                                    SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , OUT_NUM, OUT_MSG, IN_ID, IN_IP);
                                    RETURN;

                                END IF;

                            END IF;

                        END IF;


                        IF IN_TRET_FG =  'U' THEN /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

                            /* 2015.12.07   권순태   ENRO410 UPDATE 시, EDAMT_SUPP_BREU_CD(교육비지원기관코드), STD_BUDEN_RATE(학생부담비율), BREU_BUDEN_RATE(기관부담비율)도 업데이트 되도록 수정. */
                            UPDATE ENRO410                                                                           /* 신입생등록대상자내역 */
                               SET
                                   CNTR_SUST_YN              = (CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                                                     ELSE 'N'
                                                                END )                                                   /* 계약학과여부 */
                                 , EDAMT_SUPP_BREU_CD        = LIST_DATA.EDAMT_SUPP_BREU_CD                             /* 교육비지원기관코드 */
                                 , STD_BUDEN_RATE            = V_STD_BUDEN_RATE                                         /* 학생부담비율 */
                                 , BREU_BUDEN_RATE           = V_BREU_BUDEN_RATE                                        /* 기관부담비율 */
                                 , ENTR_AMT                  = V_STD_ENTR_AMT                                           /* 입학금 */
                                 , LSN_AMT                   = V_STD_LSN_AMT                                            /* 수업료 */
                                 , REG_TT_AMT                = (V_STD_REG_RESV_FG_AMT+V_STD_ENTR_AMT+V_STD_LSN_AMT)     /* 등록총금액 */
                                 , BREU_ENTR_AMT             = V_BREU_ENTR_AMT                                          /* 기관입학금 */
                                 , BREU_LSN_AMT              = V_BREU_LSN_AMT                                           /* 기관수업료 */
                                 , BREU_REG_TT_AMT           = (V_BREU_ENTR_AMT+V_BREU_LSN_AMT)                         /* 기관등록총금액 */
                                 , SCAL_ENTR_AMT             = V_SCAL_ENTR_AMT                                          /* 장학입학금 */
                                 , SCAL_LSN_AMT              = V_SCAL_LSN_AMT                                           /* 장학수업료 */
                                 , SCAL_TT_AMT               = nvl(V_SCAL_TT_AMT,0)                                     /* 장학총금액 */
                                 , STDUNI_AMT                = V_ENRO100_STDUNI_AMT                                     /* 학생회비*/
                                 , TEACHM_AMT                = (CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                                                     ELSE NVL(V_TEACHM_AMT, 0)
                                                                END )                                                       /* 교재비 */
                                 , RECIV_REG_RESV_AMT        = 0                                                            /* 예치금*/
                                 , RECIV_LSN_AMT            = nvl(LIST_DATA.RECIV_REG_RESV_AMT,0) +nvl(RECIV_LSN_AMT,0)     /* 수업료*/

                                 /* 2019-01-29 박용주 신입생등록금고지서 예치금 처리관려 수정 */
                                 , RECIV_TT_AMT              = ( CASE WHEN ( ( RECIV_TT_AMT != LIST_DATA.RECIV_REG_RESV_AMT ) AND ( RECIV_TT_AMT != LIST_DATA.REG_RESV_AMT ) ) THEN LIST_DATA.RECIV_REG_RESV_AMT
                                                                      ELSE RECIV_TT_AMT END )                           /* 수납총금액*/

                                 , MOD_ID                    = IN_ID                                                    /* 수정ID */
                                 , MOD_IP                    = IN_IP                                                    /* 수정IP */
                                 , MOD_DTTM                  = SYSDATE                                                  /* 수정일시 */
                             WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                               /* 수험생관리번호 */
                             RETURNING ROWID INTO
                             V_ROWID
                             ;

                        ELSIF IN_TRET_FG = 'R' THEN  /* 처리구분 'C'='대상자생성/산출', 'U'='예치금반영산출', 'R'='등록금재산출' */

                             /* 2015.12.07   권순태   ENRO410 UPDATE 시, EDAMT_SUPP_BREU_CD(교육비지원기관코드), STD_BUDEN_RATE(학생부담비율), BREU_BUDEN_RATE(기관부담비율)도 업데이트 되도록 수정. */
                             UPDATE ENRO410                                                                           /* 신입생등록대상자내역 */
                               SET
                                   CNTR_SUST_YN              = (CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                                                     ELSE 'N'
                                                                END )                                                   /* 계약학과여부 */
                                 , EDAMT_SUPP_BREU_CD        = LIST_DATA.EDAMT_SUPP_BREU_CD                             /* 교육비지원기관코드 */
                                 , STD_BUDEN_RATE            = V_STD_BUDEN_RATE                                         /* 학생부담비율 */
                                 , BREU_BUDEN_RATE           = V_BREU_BUDEN_RATE                                        /* 기관부담비율 */
                                 , ENTR_AMT                  = V_STD_ENTR_AMT                                           /* 입학금 */
                                 , LSN_AMT                   = V_STD_LSN_AMT                                            /* 수업료 */
                                 , REG_TT_AMT                = (V_STD_REG_RESV_FG_AMT+V_STD_ENTR_AMT+V_STD_LSN_AMT)     /* 등록총금액 */
                                 , BREU_ENTR_AMT             = V_BREU_ENTR_AMT                                          /* 기관입학금 */
                                 , BREU_LSN_AMT              = V_BREU_LSN_AMT                                           /* 기관수업료 */
                                 , BREU_REG_TT_AMT           = (V_BREU_ENTR_AMT+V_BREU_LSN_AMT)                         /* 기관등록총금액 */
                                 , SCAL_ENTR_AMT             = V_SCAL_ENTR_AMT                                          /* 장학입학금 */
                                 , SCAL_LSN_AMT              = V_SCAL_LSN_AMT                                           /* 장학수업료 */
                                 , SCAL_TT_AMT               = nvl(V_SCAL_TT_AMT,0)                                     /* 장학총금액 */
                                 , STDUNI_AMT                = V_ENRO100_STDUNI_AMT                                     /* 학생회비*/
                                 , TEACHM_AMT                = (CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                                                     ELSE NVL(V_TEACHM_AMT, 0)
                                                                END )                                                   /* 교재비 */
                                 , GV_ST_FG                  = V_GV_ST_FG                                               /* 납입상태구분*/
                                 , AUTO_REG_FG               = V_AUTO_REG_FG                                            /* 자동등록구분*/
                                 , RECIV_DT                  = V_PAID_TO_DT                                             /* 수납일자*/
                                 , MOD_ID                    = IN_ID                                                    /* 수정ID */
                                 , MOD_IP                    = IN_IP                                                    /* 수정IP */
                                 , MOD_DTTM                  = SYSDATE                                                  /* 수정일시 */
                             WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                               /* 수험생관리번호 */
                             RETURNING ROWID INTO  V_ROWID
                             ;

                        END IF;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200002'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                        IF  V_OUT_CODE <> '0' THEN
                          SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                          OUT_NUM := V_OUT_CODE;
                          OUT_MSG :='신입생 등록 대상자 생성을 실패 하였습니다.[변경이력 생성 오류]';
                          RETURN;
                        END IF;

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* 등록금여부 */

                            /*  장학금이 있는 경우 */
                            IF LIST_DATA.SCAL_CD is not null THEN

                                SELECT COUNT(*)
                                  INTO V_SCAL_CNT
                                  FROM SCHO530
                                 WHERE EXAM_STD_MNGT_NO = LIST_DATA.EXAM_STD_MNGT_NO
                                   AND SCAL_CD = LIST_DATA.SCAL_CD;

                                IF V_SCAL_CNT < 1 THEN
                                    INSERT INTO SCHO530                                           /* 신입생장학선발내역 */
                                         (  EXAM_STD_MNGT_NO                                  /* 수험생관리번호 */
                                          , SCAL_CD                                           /* 장학코드 */
                                          , SLT_DT                                            /* 선발일자 */
                                          , ENTR_AMT                                          /* 입학금 */
                                          , LSN_AMT                                           /* 수업료 */
                                          , SSO_AMT                                           /* 기성회비 */
                                          , LIF_AMT                                           /* 생활비 */
                                          , STUDY_ENC_AMT                                     /* 학업장려비 */
                                          , TEACHM_AMT                                        /* 교재비 */
                                          , ETC_SCAL_AMT                                      /* 기타장학금 */
                                          , SCAL_TT_AMT                                       /* 장학총금액 */
                                          , SUBST_DED_NO                                      /* 대체증서번호 */
                                          , SCAL_SLT_PROG_ST_FG                               /* 장학선발진행상태구분 */
                                          , ACCPR_PERS_NO                                     /* 승인자개인번호 */
                                          , ACCP_DT                                           /* 승인일자 */
                                          , SCAL_SLT_NO                                       /* 장학선발번호 */
                                          , REMK                                              /* 비고 */
                                          , INPT_ID                                           /* 입력ID */
                                          , INPT_IP                                           /* 입력IP */
                                          , INPT_DTTM                                         /* 입력일시 */
                                          , MOD_ID                                            /* 수정ID */
                                          , MOD_IP                                            /* 수정IP */
                                          , MOD_DTTM                                          /* 수정일시 */
                                         )
                                         VALUES
                                         (  LIST_DATA.EXAM_STD_MNGT_NO                              /* 수험생관리번호 */
                                          , LIST_DATA.SCAL_CD                                       /* 장학코드 */
                                          , TO_CHAR(SYSDATE,'YYYYMMDD')                             /* 선발일자 */
                                          , NVL(V_SCAL_ENTR_AMT,0)                                  /* 장학입학금 */
                                          , NVL(V_SCAL_LSN_AMT,0)                                   /* 장학수업료 */
                                          , 0                                                       /* 기성회비 */
                                          , 0                                                       /* 생활비 */
                                          , 0                                                       /* 학업장려비 */
                                          , nvl(V_TEACHM_AMT,0)                                     /* 교재비 */
                                          , 0                                                       /* 기타장학금 */
                                          , nvl(V_SCAL_TT_AMT,0)                                    /* 장학총금액 */
                                          , ''                                                      /* 대체증서번호 */
                                          , 'U073300004'                                            /* 장학선발진행상태구분 확정처리 */
                                          , IN_ID                                                   /* 승인자개인번호 */
                                          , ''                                                      /* 승인일자 */
                                          , ''                                                      /* 장학선발번호 */
                                          , ''                                                      /* 비고 */
                                          , IN_ID                                                   /* 입력ID */
                                          , IN_IP                                                   /* 입력IP */
                                          , SYSDATE                                                 /* 입력일시 */
                                          , IN_ID                                                   /* 입력ID */
                                          , IN_IP                                                   /* 입력IP */
                                          , SYSDATE                                                 /* 입력일시 */
                                         ) ;
                                ELSE

                                    UPDATE scho530                    /* 신입생장학선발내역 */
                                       SET SLT_DT                    = TO_CHAR(SYSDATE,'YYYYMMDD')          /* 선발일자 */
                                         , ENTR_AMT                  = NVL(V_SCAL_ENTR_AMT,0)               /* 장학입학금 */
                                         , LSN_AMT                   = NVL(V_SCAL_LSN_AMT,0)                /* 장학수업료 */
                                         , SSO_AMT                   = 0                                    /* 기성회비 */
                                         , LIF_AMT                   = 0                                    /* 생활비 */
                                         , STUDY_ENC_AMT             = 0                                    /* 학업장려비 */
                                         , TEACHM_AMT                = nvl(V_TEACHM_AMT,0)                  /* 교재비 */
                                         , ETC_SCAL_AMT              = 0                                    /* 기타장학금 */
                                         , SCAL_TT_AMT               = nvl(V_SCAL_TT_AMT,0)                 /* 장학총금액 */
                                         , SUBST_DED_NO              = ''                                   /* 대체증서번호 */
                                         , SCAL_SLT_PROG_ST_FG       = 'U073300004'                         /* 장학선발진행상태구분 */
                                         , ACCPR_PERS_NO             = IN_ID                                /* 승인자개인번호 */
                                         , MOD_ID                    = IN_ID                                /* 수정ID */
                                         , MOD_IP                    = IN_IP                                /* 수정IP */
                                         , MOD_DTTM                  = SYSDATE                              /* 수정일시 */
                                     WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO           /* 수험생관리번호 */
                                       AND SCAL_CD                   = LIST_DATA.SCAL_CD                    /* 장학코드 */
                                     ;

                                END IF;

                            END IF;

                        END IF;

                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                         V_MSG :='---------------3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']';

                    END LOOP;


        END IF;

    END IF;


    OUT_NUM := 0;
    OUT_MSG :='정상 처리 되었습니다.'||V_MSG;

EXCEPTION
    WHEN OTHERS THEN
    SP_SSTM056_CREA(V_PGM_ID, '입학학년도(' || IN_ENTR_SCHYY || ') 입학학기구분('||IN_ENTR_SHTM_FG||') 전형구분('||IN_SELECT_FG||') 합격차수('||IN_PASS_SEQ||')' ||V_MSG, SQLCODE, SQLERRM, IN_ID, IN_IP);
    OUT_NUM := SQLCODE;
    OUT_MSG :='신입생 등록 대상자 생성을 실패 하였습니다.['||V_MSG||']';
    RETURN;
END SP_ENRO410_CREA;
/
