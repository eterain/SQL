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
                                                    
        /* SMS/EMAIL�߼� */
        INSERT INTO SSTM070 /* SMS/EMAIL�߼� */
            (SEND_NO /* �߼۹�ȣ */,
             SYSTEM_CD /* �ý����ڵ� */,
             UNIT_BUSS_CD /* ���������ڵ� */,
             SM_UNIT_BUSS_CD /* �Ҵ��������ڵ� */,
             PGM_CD /* ���α׷��ڵ�*/,
             SEND_USER_NO /* �߼ۻ���ڹ�ȣ */,
             RECP_USER_NO /* ���Ż���ڹ�ȣ */,
             MSG_TYPE /* �޼������� */,
             SEND_TYPE /* �߼����� */,
             SEND_PSN_HAND_TELNO /* �߼����޴���ȭ��ȣ */,
             SEND_PSN_EMAIL_ADDR /* �߼����̸����ּ� */,
             RECPR_HAND_TELNO /* �������޴���ȭ��ȣ */,
             RECPR_EMAIL_ADDR /* �������̸����ּ� */,
             SEND_TTL /* �߼����� */,
             SEND_CTNT /* �߼۳���*/,
             RESER_YN /* ���࿩�� */,
             SEND_RESER_DTTM /* �߼ۿ����Ͻ� */,
             SEND_YN /* �߼ۿ��� */,
             ATTC_FILE_NO /* ÷�����Ϲ� */,
             SEND_LOG /* �߼��̷� */,
             SEND_RSLT_CD /* �߼۰���ڵ� */,
             SEND_RPST_NO /* �߼۴�ǥ�� */,
             INPT_ID /* �Է���ID */,
             INPT_DTTM /* �Է��Ͻ� */,
             INPT_IP /* �Է���IP */,
             SEND_USER_DEPT_CD /* �߼ۻ���ںμ��ڵ� */)
        VALUES
            (V_SEND_NO,
             'C' /*�ý����ڵ� */,
             '00' /* ���������ڵ� */,
             '00' /* �Ҵ��������ڵ� */,
             'C000000' /* ���α׷��ڵ� */,
             '' /* �߼ۻ���ڹ�ȣ*/,
             'B111428' /* ���Ż���ڹ�ȣ */,
             'C021100002' /* �޼������� */,
             'C021200002' /* �߼����� */,
             '' /* �߼����޴���ȭ��ȣ */,
             'snu_haksa@snu.ac.kr' /* �߼����̸����ּ� */,
             '' /* �������޴���ȭ��ȣ*/,
             PERS_DATA.EMAIL /* �������̸����ּ� */,
             '��� ���� üũ ���˰�� ����[' || V_ENRO_TOT_ERROR_COUNT || '��]' /* �߼����� */,
             V_SEND_CTNT /* �߼۳��� */,
             'N' /* ���࿩�� */,
             SYSDATE /* �߼ۿ����Ͻ� */,
             'N' /* �߼ۿ���*/,
             NULL /* ÷�����Ϲ� */,
             NULL /* �߼��̷� */,
             NULL /* �߼۰���ڵ� */,
             V_SEND_RPST_NO /* �߼۴�ǥ�� */,
             'batch job' /* �Է���ID*/,
             SYSDATE /* �Է��Ͻ� */,
             NULL /* �Է���IP */,
             '0040' /* �߼ۻ���ںμ��ڵ� */);
    END LOOP;

    COMMIT;

END SP_ENRO_REG_CHECK;
/