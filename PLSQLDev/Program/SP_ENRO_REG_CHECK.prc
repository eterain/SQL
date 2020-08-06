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
                            -- AND USER_NO in ('B111794','B111497','X000170','B111605','B002023','B111844') -- ������, ������, �Ǽ���, ����ȣ , ���켺, �ڰ���
                            -- AND USER_NO in ('B111497','B111605','B002023','B111520', 'B111751', 'X001381') -- SR1902-09649 2019-02-28 ���� : �ڰ���(B111844), ������(B111794), �Ǽ���(X000170) / �߰� : ������(B111520), �輳��(B111751), �ڿ���(X001381)
                         AND USER_NO IN ('B111497',
                                         'B111605',
                                         'B002023',
                                         'B111520',
                                         'B111751',
                                         'B111354',
                                         'B111459',
                                         'B111829',
                                         'X001381') -- CH1906-00109 2019-08-22 �߰�  �繫:������, �л�:������ ���к���:�̸�ö
                      ) LOOP
        
        /* SMS �߼۹�ȣ */
        SELECT SSTM070_SEQ.NEXTVAL INTO V_SEND_NO FROM DUAL;
        
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
