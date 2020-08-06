CREATE OR REPLACE PROCEDURE SP_STUD106_APPR
(
       IN_STUNO                 IN STUD106.STUNO%TYPE               /* 학번 */
      ,IN_CHG_SEQ               IN STUD106.CHG_SEQ%TYPE             /* 진행상태구분 */
      ,IN_ACCP_ST_FG            IN VARCHAR2                         /* 승인구분 */
      ,IN_RECA_RESN             IN VARCHAR2                         /* 반려사유 */
      ,IN_ID                    IN SSTM070.INPT_ID%TYPE             /* 입력ID */
      ,IN_IP                    IN SSTM070.INPT_IP%TYPE             /* 입력IP */
      ,OUT_NUM    OUT NUMBER
      ,OUT_MSG    OUT VARCHAR2
)
IS


/******************************************************************************
    프로그램명 : SP_STUD106_APPR
      수행목적 :
      수행결과 : SSTM070 추가 (메일발송)
 ------------------------------------------------------------------------------
     수정일자     수정자    수정내용
 ------------------------------------------------------------------------------
     2017.05.25   전상현 최초 작성
     2019.05.17   이재엽 SP_LOG_CREA 로직으로 SLG.STUD105_LOG 데이터 insert 되지않는것으로 보여 함수에서 insert 구문으로 변경
     2020.06.08   박용주 SR2005-04895 학생사진승인문제로 쿼리수정 
 ******************************************************************************/

/**********************************변수선언시작********************************************************/
    V_PGM_ID             VARCHAR2(30) := 'SP_STUD106_APPR';
    V_OUT_CODE           VARCHAR(10);
    V_OUT_MSG            VARCHAR2(4000);
    V_ROWID              ROWID;
    V_STG_NM             VARCHAR2(200);   -- 진행단계 표시용
    V_SEND_TTL           SSTM070.SEND_TTL%TYPE  ;     /* 메일제목 */
    V_SEND_CTNT          SSTM070.SEND_CTNT%TYPE  ;    /* 메일내용 */
    V_APPR_EMAIL         VARCHAR2(100)  ;         /* 이메일 */
    V_STUNO_EMAIL        VARCHAR2(100)  ;         /* 이메일 */
    V_STUNO_KOR_NM       VARCHAR2(100)  ;
    V_SYSTEM_CD          VARCHAR2(1) ;
    V_UNIT_BUSS_CD       VARCHAR2(2) ;
    V_SM_UNIT_BUSS_CD    VARCHAR2(2) ;
    V_PGM_CD             VARCHAR2(10) ;
    V_CNT                NUMBER(10) ;
    V_STUNO              VARCHAR2(12) ;
    V_CHG_SEQ            NUMBER(5) ;
    V_PHT_FILE_NM        VARCHAR2(100) ;
    V_PHT_FILE           BLOB;
/**********************************변수선언끝**********************************************************/
BEGIN
            V_STG_NM := '정보검색';

            SELECT NVL(EMAIL,EMAIL_2)
              INTO V_APPR_EMAIL
              FROM HURT200
             WHERE RPST_PERS_NO = SF_HURT200_PERS_INFO('6', IN_ID);


            /* 2020-06-03 SR2005-04895 학생사진승인문제로 쿼리수정 
            SELECT NVL(EMAIL,EMAIL_2)
                 , KOR_NM
              INTO V_STUNO_EMAIL
                 , V_STUNO_KOR_NM
              FROM HURT200
             WHERE (   RPST_PERS_NO = IN_STUNO
                    OR RPST_PERS_NO = (SELECT RPST_PERS_NO
                                         FROM BSNS031
                                        WHERE PERS_NO = IN_STUNO));
            */
            SELECT NVL(A.EMAIL,A.EMAIL_2)
                 , A.KOR_NM
              INTO V_STUNO_EMAIL
                 , V_STUNO_KOR_NM
              FROM ( SELECT EMAIL, EMAIL_2, KOR_NM, RPST_PERS_NO
                       FROM HURT200
                      ORDER BY RPST_PERS_NO DESC ) A
             WHERE ( A.RPST_PERS_NO = IN_STUNO OR
                     A.RPST_PERS_NO = ( SELECT RPST_PERS_NO
                                          FROM BSNS031
                                         WHERE PERS_NO = IN_STUNO ))
               AND ROWNUM = 1 ;

            IF  IN_ACCP_ST_FG  =  'U001600002'  THEN
                V_SYSTEM_CD := 'U';
                V_UNIT_BUSS_CD := '01';
                V_SM_UNIT_BUSS_CD := '02';
                V_PGM_CD := 'U010244';
                V_SEND_TTL := '[사진변경신청처리알림]';
                V_SEND_CTNT := '<html><body><div class=WordSection1><p class=MsoNormal><span>';
                V_SEND_CTNT := V_SEND_CTNT||V_STUNO_KOR_NM||' 학생이 신청한 사진변경이 승인되었음을 알려드립니다.';
                V_SEND_CTNT := V_SEND_CTNT||'<BR>'||'</span></p></div></body></html>' ;
            ELSE
                V_SYSTEM_CD := 'U';
                V_UNIT_BUSS_CD := '01';
                V_SM_UNIT_BUSS_CD := '02';
                V_PGM_CD := 'U010244';
                V_SEND_TTL := '[사진변경신청처리알림]';
                V_SEND_CTNT := '<html><body><div class=WordSection1><p class=MsoNormal><span>';
                V_SEND_CTNT := V_SEND_CTNT||V_STUNO_KOR_NM||' 학생이 신청한 사진변경이 반려되었음을 알려드립니다.';
                V_SEND_CTNT := V_SEND_CTNT||'<BR>'||' - 반려사유 : '|| IN_RECA_RESN;
                V_SEND_CTNT := V_SEND_CTNT||'<BR>'||'</span></p></div></body></html>' ;
            END IF ;

            V_STG_NM := '승인저장';

            IF  IN_ACCP_ST_FG  =  'U001600002' THEN

                SELECT COUNT(*)
                  INTO V_CNT
                  FROM STUD105
                 WHERE STUNO = IN_STUNO;

                IF V_CNT = 0 THEN

                    SELECT STUNO
                          ,PHT_FILE_NM
                          ,PHT_FILE
                          ,CHG_SEQ
                      INTO
                          V_STUNO,
                          V_PHT_FILE_NM,
                          V_PHT_FILE,
                          V_CHG_SEQ
                      FROM STUD106
                     WHERE STUNO = IN_STUNO
                       AND CHG_SEQ = IN_CHG_SEQ;

                    BEGIN
                        INSERT INTO STUD105
                            (
                            STUNO,
                            PHT_FILE_NM,
                            PHT_FILE,
                            INPT_ID,
                            INPT_DTTM,
                            INPT_IP,
                            CHG_SEQ
                            )
                        VALUES
                           (
                           V_STUNO,
                            V_PHT_FILE_NM,
                            V_PHT_FILE,
                            IN_ID,
                            SYSDATE,
                            IN_IP,
                            V_CHG_SEQ
                            )
                           RETURNING ROWID
                           INTO V_ROWID;

                         EXCEPTION
                         WHEN OTHERS THEN
                         OUT_NUM   := SQLCODE;
                         OUT_MSG   := ' STUD105 INSERT 오류: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                         ROLLBACK;
                         RETURN;


                    END;

                                                --로그테이블 생성
                         SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200001'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'STUD105'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                         IF V_OUT_CODE <> '0' THEN
                               OUT_NUM := -1;
                               OUT_MSG := '학생사진기본 로그 테이블 생성 오류: ' || V_OUT_MSG;
                               ROLLBACK;
                               RETURN;
                         END IF;

                ELSE

                    BEGIN
                        UPDATE STUD105
                           SET   PHT_FILE_NM = (SELECT PHT_FILE_NM FROM STUD106 WHERE STUNO = IN_STUNO AND CHG_SEQ = IN_CHG_SEQ)
                               , PHT_FILE = (SELECT PHT_FILE FROM STUD106 WHERE STUNO = IN_STUNO AND CHG_SEQ = IN_CHG_SEQ)
                               , CHG_SEQ = IN_CHG_SEQ
                               , MOD_ID = IN_ID
                               , MOD_IP = IN_IP
                               , MOD_DTTM = SYSDATE
                         WHERE   STUNO = IN_STUNO
                        RETURNING ROWID
                        INTO V_ROWID;

                        EXCEPTION
                            WHEN OTHERS THEN
                                OUT_NUM   := SQLCODE;
                                OUT_MSG   := ' STUD105 UPDATE 오류: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                                ROLLBACK;
                                RETURN;

                    END;

                    BEGIN
                        INSERT INTO SLG.STUD105_LOG                           /* 학생사진로그 */
                             (  LOG_SEQ                                           /* 로그순번 */
                              , LOG_CHG_FG                                        /* 로그변경구분 */
                              , LOG_REG_ID                                        /* 로그등록ID */
                              , LOG_REG_DTTM                                      /* 로그등록일시 */
                              , LOG_REG_IP                                        /* 로그등록IP */
                              , LOG_REG_FUNCTN_NM                                 /* 로그등록함수명 */
                              , STUNO                                             /* 학번 */
                              , PHT_FILE_NM                                       /* 사진파일명 */
                              , PHT_FILE                                          /* 사진파일 */
                              , REMK                                              /* 비고 */
                              , INPT_ID                                           /* 입력ID */
                              , INPT_DTTM                                         /* 입력일시 */
                              , INPT_IP                                           /* 입력IP */
                              , CHG_SEQ                                            /*  */
                              , MOD_ID
                              , MOD_DTTM
                              , MOD_IP
                             )
                             SELECT
                             
                                    --(SELECT NVL(MAX(LOG_SEQ),0)+1 FROM SLG.STUD105_LOG)
                                      SLG.STUD105_LOG_SEQ.NEXTVAL  

                                  , 'C015200002'
                                  , IN_ID
                                  , SYSDATE
                                  , IN_IP
                                  , 'SP_STUD106_APPR'
                                  , STUNO
                                  , PHT_FILE_NM
                                  , PHT_FILE
                                  , REMK
                                  , INPT_ID
                                  , INPT_DTTM
                                  , INPT_IP
                                  , CHG_SEQ
                                  , IN_ID
                                  , SYSDATE
                                  , IN_IP
                              FROM STUD105
                             WHERE STUNO = IN_STUNO;                 /* 학번(PK1) */

                         EXCEPTION
                         WHEN OTHERS THEN
                         OUT_NUM   := SQLCODE;
                         OUT_MSG   := ' STUD105_LOG INSERT 오류: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                         ROLLBACK;
                         RETURN;

                    END;

                    /*로그테이블 생성*/
                     /*   SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                   ,IN_ID => IN_ID
                                   ,IN_IP => IN_IP
                                   ,IN_CHG_FG => 'C015200002'
                                   ,IN_OWNER => 'SNU'
                                   ,IN_TABLE_ID => 'STUD105'
                                   ,IN_ROWID => V_ROWID
                                   ,OUT_CODE => V_OUT_CODE
                                   ,OUT_MSG => V_OUT_MSG);

                        IF V_OUT_CODE <> '0' THEN
                            OUT_NUM := -1;
                            OUT_MSG := '학생사진기본 로그 테이블 생성 오류: ' || V_OUT_MSG;
                            ROLLBACK;
                            RETURN;
                        END IF;*/
                END IF;


                BEGIN
                    UPDATE STUD106
                       SET ACCP_DT = TO_CHAR(SYSDATE,'YYYYMMDD')
                         , ACCPR_PERS_NO = IN_ID
                         , MOD_ID = IN_ID
                         , MOD_IP = IN_IP
                         , MOD_DTTM = SYSDATE
                     WHERE STUNO = IN_STUNO
                       AND CHG_SEQ = IN_CHG_SEQ
                       RETURNING ROWID
                       INTO V_ROWID;

                    EXCEPTION
                        WHEN OTHERS THEN
                            OUT_NUM   := SQLCODE;
                            OUT_MSG   := ' STUD106 UPDATE 오류: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                            ROLLBACK;
                            RETURN;
                END;

                --로그테이블 생성
                SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                           ,IN_ID => IN_ID
                           ,IN_IP => IN_IP
                           ,IN_CHG_FG => 'C015200002'
                           ,IN_OWNER => 'SNU'
                           ,IN_TABLE_ID => 'STUD106'
                           ,IN_ROWID => V_ROWID
                           ,OUT_CODE => V_OUT_CODE
                           ,OUT_MSG => V_OUT_MSG);

                IF V_OUT_CODE <> '0' THEN
                    OUT_NUM := -1;
                    OUT_MSG := '학생사진변경신청 로그 테이블 생성 오류: ' || V_OUT_MSG;
                    ROLLBACK;
                    RETURN;
                END IF;


            ElSE


                UPDATE STUD106
                   SET CNCL_APLY_DT = TO_CHAR(SYSDATE,'YYYYMMDD')
                     , MOD_ID = IN_ID
                     , MOD_IP = IN_IP
                     , MOD_DTTM = SYSDATE
                 WHERE STUNO = IN_STUNO
                   AND CHG_SEQ = IN_CHG_SEQ
                   RETURNING ROWID
                   INTO V_ROWID;

                --로그테이블 생성
                SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                           ,IN_ID => IN_ID
                           ,IN_IP => IN_IP
                           ,IN_CHG_FG => 'C015200002'
                           ,IN_OWNER => 'SNU'
                           ,IN_TABLE_ID => 'STUD106'
                           ,IN_ROWID => V_ROWID
                           ,OUT_CODE => V_OUT_CODE
                           ,OUT_MSG => V_OUT_MSG);

                IF V_OUT_CODE <> '0' THEN
                    OUT_NUM := -1;
                    OUT_MSG := '학생사진변경신청 로그 테이블 생성 오류: ' || V_OUT_MSG;
                    ROLLBACK;
                    RETURN;
                END IF;

            END IF;

            V_STG_NM := '메일발송';

            INSERT INTO SSTM070          /* SMS/EMAIL발송 */
                ( SEND_NO              /* 발송번호 */
                , SYSTEM_CD            /* 시스템코드 */
                , UNIT_BUSS_CD         /* 단위업무코드 */
                , SM_UNIT_BUSS_CD      /* 소단위업무코드 */
                , PGM_CD               /* 프로그램코드 */
                , SEND_USER_NO         /* 발송사용자번호 */
                , RECP_USER_NO         /* 수신사용자번호 */
                , MSG_TYPE             /* 메세지유형 */
                , SEND_TYPE            /* 발송유형 */
                , SEND_PSN_HAND_TELNO  /* 발송자휴대전화번호 */
                , SEND_PSN_EMAIL_ADDR  /* 발송자이메일주소 */
                , RECPR_HAND_TELNO     /* 수신자휴대전화번호 */
                , RECPR_EMAIL_ADDR     /* 수신자이메일주소 */
                , SEND_TTL             /* 발송제목 */
                , SEND_CTNT            /* 발송내용 */
                , RESER_YN             /* 예약여부 */
                , SEND_RESER_DTTM      /* 발송예약일시 */
                , SEND_YN              /* 발송여부 */
                , ATTC_FILE_NO         /* 첨부파일번 */
                , SEND_LOG             /* 발송이력 */
                , SEND_RSLT_CD         /* 발송결과코드 */
                , SEND_RPST_NO         /* 발송대표번 */
                , INPT_ID              /* 입력자ID */
                , INPT_DTTM            /* 입력일시 */
                , INPT_IP              /* 입력자IP */
                )
           VALUES
                (
                  SSTM070_SEQ.NEXTVAL
                , V_SYSTEM_CD
                , V_UNIT_BUSS_CD
                , V_SM_UNIT_BUSS_CD
                , V_PGM_CD
                , IN_ID
                , IN_STUNO
                , 'C021100002'
                , 'C021200002'
                , ''
                , V_APPR_EMAIL
                , ''
                , V_STUNO_EMAIL
                , V_SEND_TTL
                , V_SEND_CTNT
                , 'N'
                , SYSDATE
                , 'N'
                , ''
                , ''
                , ''
                , ''
                , IN_ID
                , SYSDATE
                , IN_IP
                ) ;
            OUT_NUM := 0;
            OUT_MSG := '정상 처리되었습니다.';

            EXCEPTION
                WHEN OTHERS THEN
                    SP_SSTM056_CREA(V_PGM_ID, V_STG_NM, SQLCODE, SQLERRM, '', '');
                    OUT_NUM := SQLCODE;
                    OUT_MSG := '지도학생 수강지도 승인 반영에 실패하였습니다.';
                    ROLLBACK;
                    RETURN;

END;
/
