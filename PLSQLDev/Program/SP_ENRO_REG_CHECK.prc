CREATE OR REPLACE PROCEDURE SP_ESIN_TEST IS
(
     IN_ENTR_SCHYY      IN ESIN310.SCHYY%TYPE   
    ,IN_ENTR_SHTM_FG    IN ESIN310.SHTM_FG%TYPE 
    ,OUT_NUM            OUT NUMBER
    ,OUT_MSG            OUT VARCHAR2
 )IS 
    V_SCHYY   ESIN310.SCHYY %TYPE;
    V_SHTM_FG ESIN310.SHTM_FG %TYPE;

BEGIN

    FOR PERS_DATA IN (SELECT USER_ID,
                             USER_NO,
                             USER_NM,
                             EMAIL
                        FROM V_SNU_USER
                       WHERE 1 = 1
                            -- AND USER_NO in ('B111794','B111497','X000170','B111605','B002023','B111844') -- 안혜수, 김은하, 권순태, 성상호 , 정우성, 박가람
                            -- AND USER_NO in ('B111497','B111605','B002023','B111520', 'B111751', 'X001381') -- SR1902-09649 2019-02-28 제외 : 박가람(B111844), 안혜수(B111794), 권순태(X000170) / 추가 : 김정희(B111520), 김설희(B111751), 박용주(X001381)
                         AND USER_NO IN ('B111497',
                                         'B111605',
                                         'B002023',
                                         'B111520',
                                         'B111751',
                                         'B111354',
                                         'B111459',
                                         'B111829',
                                         'X001381') -- CH1906-00109 2019-08-22 추가  재무:김윤정, 학사:유진아 장학복지:이명철
                      ) LOOP
        
        /* SMS 발송번호 */
        SELECT SSTM070_SEQ.NEXTVAL INTO V_SEND_NO FROM DUAL;
        
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
