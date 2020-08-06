CREATE OR REPLACE PROCEDURE SP_ESIN_TEST IS
(
     IN_SCHYY      IN ESIN310.SCHYY%TYPE   
    ,IN_SHTM_FG    IN ESIN310.SHTM_FG%TYPE 
    ,OUT_NUM            OUT NUMBER
    ,OUT_MSG            OUT VARCHAR2
 )IS 
    V_SCHYY   ESIN310.SCHYY %TYPE;
    V_SHTM_FG ESIN310.SHTM_FG %TYPE;

BEGIN

    FOR ESIN_DATA IN (  SELECT SCHYY,
                               SHTM_FG,
                               EXAM_NO,
                               APLIER_SELECT_FG_CD,
                               APLIER_KOR_NM,
                               APLIER_ENG_NM,
                               BIRTH_DT,
                               CORS_CD,
                               EXAM_COLL_UNIT_CD,
                               EXAM_COLL_UNIT_NM,
                               EXAM_COLL_DETA_NM,
                               REMK
                          FROM ESIN310 
                         WHERE SCHYY = IN_SCHYY
                           AND SHTM_FG = IN_SHTM_FG ) LOOP
       SELECT A1.RPST_PERS_NO, A1.RES_NO, A1.NM AS NM
         FROM HURT205 A1
        WHERE A1.RPST_PERS_NO IN ( SELECT DISTINCT PERS_NO FROM BSNS031 WHERE RPST_PERS_NO = A1.RPST_PERS_NO )
          AND NVL(A1.RES_NO,'N') != 'N'
          AND TRIM(ESIN_DATA.APLIER_KOR_NM) = A1.NM
          AND ESIN_DATA.BIRTH_DT = SUBSTR(A1.RES_NO,1,6)
       UNION
       SELECT A2.RPST_PERS_NO, A2.RES_NO, A2.KOR_NM AS NM
         FROM PAYM421 A2
        WHERE A2.FM_REL_CD != 'A034600001'
          AND A2.RPST_PERS_NO IN ( SELECT DISTINCT PERS_NO FROM BSNS031 WHERE RPST_PERS_NO = A2.RPST_PERS_NO )
          AND NVL(A2.RES_NO,'N') != 'N'
          AND A2.YY = ( SELECT MAX(YY) FROM PAYM421 A3 WHERE A3.RPST_PERS_NO = A2.RPST_PERS_NO ) 
                                                    
        /* SMS/EMAIL발송 */
        INSERT INTO SSTM070 /* SMS/EMAIL발송 */
            (SEND_NO /* 발송번호 */,
             SYSTEM_CD /* 시스템코드 */,
             UNIT_BUSS_CD /* 단위업무코드 */,
             SM_UNIT_BUSS_CD /* 소단위업무코드 */,
             PGM_CD /* 프로그램코드*/,
             SEND_USER_NO /* 발송사용자번호 */,
             RECP_USER_NO /* 수신사용자번호 */,
             MSG_TYPE /* 메세지유형 */,
             SEND_TYPE /* 발송유형 */,
             SEND_PSN_HAND_TELNO /* 발송자휴대전화번호 */,
             SEND_PSN_EMAIL_ADDR /* 발송자이메일주소 */,
             RECPR_HAND_TELNO /* 수신자휴대전화번호 */,
             RECPR_EMAIL_ADDR /* 수신자이메일주소 */,
             SEND_TTL /* 발송제목 */,
             SEND_CTNT /* 발송내용*/,
             RESER_YN /* 예약여부 */,
             SEND_RESER_DTTM /* 발송예약일시 */,
             SEND_YN /* 발송여부 */,
             ATTC_FILE_NO /* 첨부파일번 */,
             SEND_LOG /* 발송이력 */,
             SEND_RSLT_CD /* 발송결과코드 */,
             SEND_RPST_NO /* 발송대표번 */,
             INPT_ID /* 입력자ID */,
             INPT_DTTM /* 입력일시 */,
             INPT_IP /* 입력자IP */,
             SEND_USER_DEPT_CD /* 발송사용자부서코드 */)
        VALUES
            (V_SEND_NO,
             'C' /*시스템코드 */,
             '00' /* 단위업무코드 */,
             '00' /* 소단위업무코드 */,
             'C000000' /* 프로그램코드 */,
             '' /* 발송사용자번호*/,
             'B111428' /* 수신사용자번호 */,
             'C021100002' /* 메세지유형 */,
             'C021200002' /* 발송유형 */,
             '' /* 발송자휴대전화번호 */,
             'snu_haksa@snu.ac.kr' /* 발송자이메일주소 */,
             '' /* 수신자휴대전화번호*/,
             PERS_DATA.EMAIL /* 수신자이메일주소 */,
             '등록 에러 체크 점검결과 에러[' || V_ENRO_TOT_ERROR_COUNT || '건]' /* 발송제목 */,
             V_SEND_CTNT /* 발송내용 */,
             'N' /* 예약여부 */,
             SYSDATE /* 발송예약일시 */,
             'N' /* 발송여부*/,
             NULL /* 첨부파일번 */,
             NULL /* 발송이력 */,
             NULL /* 발송결과코드 */,
             V_SEND_RPST_NO /* 발송대표번 */,
             'batch job' /* 입력자ID*/,
             SYSDATE /* 입력일시 */,
             NULL /* 입력자IP */,
             '0040' /* 발송사용자부서코드 */);
    END LOOP;

    COMMIT;

END SP_ENRO_REG_CHECK;
/
