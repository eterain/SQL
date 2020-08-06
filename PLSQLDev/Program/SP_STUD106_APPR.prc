CREATE OR REPLACE PROCEDURE SP_STUD106_APPR
(
       IN_STUNO                 IN STUD106.STUNO%TYPE               /* �й� */
      ,IN_CHG_SEQ               IN STUD106.CHG_SEQ%TYPE             /* ������±��� */
      ,IN_ACCP_ST_FG            IN VARCHAR2                         /* ���α��� */
      ,IN_RECA_RESN             IN VARCHAR2                         /* �ݷ����� */
      ,IN_ID                    IN SSTM070.INPT_ID%TYPE             /* �Է�ID */
      ,IN_IP                    IN SSTM070.INPT_IP%TYPE             /* �Է�IP */
      ,OUT_NUM    OUT NUMBER
      ,OUT_MSG    OUT VARCHAR2
)
IS


/******************************************************************************
    ���α׷��� : SP_STUD106_APPR
      ������� :
      ������ : SSTM070 �߰� (���Ϲ߼�)
 ------------------------------------------------------------------------------
     ��������     ������    ��������
 ------------------------------------------------------------------------------
     2017.05.25   ������ ���� �ۼ�
     2019.05.17   ���翱 SP_LOG_CREA �������� SLG.STUD105_LOG ������ insert �����ʴ°����� ���� �Լ����� insert �������� ����
     2020.06.08   �ڿ��� SR2005-04895 �л��������ι����� �������� 
 ******************************************************************************/

/**********************************�����������********************************************************/
    V_PGM_ID             VARCHAR2(30) := 'SP_STUD106_APPR';
    V_OUT_CODE           VARCHAR(10);
    V_OUT_MSG            VARCHAR2(4000);
    V_ROWID              ROWID;
    V_STG_NM             VARCHAR2(200);   -- ����ܰ� ǥ�ÿ�
    V_SEND_TTL           SSTM070.SEND_TTL%TYPE  ;     /* �������� */
    V_SEND_CTNT          SSTM070.SEND_CTNT%TYPE  ;    /* ���ϳ��� */
    V_APPR_EMAIL         VARCHAR2(100)  ;         /* �̸��� */
    V_STUNO_EMAIL        VARCHAR2(100)  ;         /* �̸��� */
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
/**********************************��������**********************************************************/
BEGIN
            V_STG_NM := '�����˻�';

            SELECT NVL(EMAIL,EMAIL_2)
              INTO V_APPR_EMAIL
              FROM HURT200
             WHERE RPST_PERS_NO = SF_HURT200_PERS_INFO('6', IN_ID);


            /* 2020-06-03 SR2005-04895 �л��������ι����� �������� 
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
                V_SEND_TTL := '[���������ûó���˸�]';
                V_SEND_CTNT := '<html><body><div class=WordSection1><p class=MsoNormal><span>';
                V_SEND_CTNT := V_SEND_CTNT||V_STUNO_KOR_NM||' �л��� ��û�� ���������� ���εǾ����� �˷��帳�ϴ�.';
                V_SEND_CTNT := V_SEND_CTNT||'<BR>'||'</span></p></div></body></html>' ;
            ELSE
                V_SYSTEM_CD := 'U';
                V_UNIT_BUSS_CD := '01';
                V_SM_UNIT_BUSS_CD := '02';
                V_PGM_CD := 'U010244';
                V_SEND_TTL := '[���������ûó���˸�]';
                V_SEND_CTNT := '<html><body><div class=WordSection1><p class=MsoNormal><span>';
                V_SEND_CTNT := V_SEND_CTNT||V_STUNO_KOR_NM||' �л��� ��û�� ���������� �ݷ��Ǿ����� �˷��帳�ϴ�.';
                V_SEND_CTNT := V_SEND_CTNT||'<BR>'||' - �ݷ����� : '|| IN_RECA_RESN;
                V_SEND_CTNT := V_SEND_CTNT||'<BR>'||'</span></p></div></body></html>' ;
            END IF ;

            V_STG_NM := '��������';

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
                         OUT_MSG   := ' STUD105 INSERT ����: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                         ROLLBACK;
                         RETURN;


                    END;

                                                --�α����̺� ����
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
                               OUT_MSG := '�л������⺻ �α� ���̺� ���� ����: ' || V_OUT_MSG;
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
                                OUT_MSG   := ' STUD105 UPDATE ����: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                                ROLLBACK;
                                RETURN;

                    END;

                    BEGIN
                        INSERT INTO SLG.STUD105_LOG                           /* �л������α� */
                             (  LOG_SEQ                                           /* �α׼��� */
                              , LOG_CHG_FG                                        /* �α׺��汸�� */
                              , LOG_REG_ID                                        /* �α׵��ID */
                              , LOG_REG_DTTM                                      /* �α׵���Ͻ� */
                              , LOG_REG_IP                                        /* �α׵��IP */
                              , LOG_REG_FUNCTN_NM                                 /* �α׵���Լ��� */
                              , STUNO                                             /* �й� */
                              , PHT_FILE_NM                                       /* �������ϸ� */
                              , PHT_FILE                                          /* �������� */
                              , REMK                                              /* ��� */
                              , INPT_ID                                           /* �Է�ID */
                              , INPT_DTTM                                         /* �Է��Ͻ� */
                              , INPT_IP                                           /* �Է�IP */
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
                             WHERE STUNO = IN_STUNO;                 /* �й�(PK1) */

                         EXCEPTION
                         WHEN OTHERS THEN
                         OUT_NUM   := SQLCODE;
                         OUT_MSG   := ' STUD105_LOG INSERT ����: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                         ROLLBACK;
                         RETURN;

                    END;

                    /*�α����̺� ����*/
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
                            OUT_MSG := '�л������⺻ �α� ���̺� ���� ����: ' || V_OUT_MSG;
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
                            OUT_MSG   := ' STUD106 UPDATE ����: ' || TO_CHAR(SQLCODE) || '...  ' || SQLERRM;
                            ROLLBACK;
                            RETURN;
                END;

                --�α����̺� ����
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
                    OUT_MSG := '�л����������û �α� ���̺� ���� ����: ' || V_OUT_MSG;
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

                --�α����̺� ����
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
                    OUT_MSG := '�л����������û �α� ���̺� ���� ����: ' || V_OUT_MSG;
                    ROLLBACK;
                    RETURN;
                END IF;

            END IF;

            V_STG_NM := '���Ϲ߼�';

            INSERT INTO SSTM070          /* SMS/EMAIL�߼� */
                ( SEND_NO              /* �߼۹�ȣ */
                , SYSTEM_CD            /* �ý����ڵ� */
                , UNIT_BUSS_CD         /* ���������ڵ� */
                , SM_UNIT_BUSS_CD      /* �Ҵ��������ڵ� */
                , PGM_CD               /* ���α׷��ڵ� */
                , SEND_USER_NO         /* �߼ۻ���ڹ�ȣ */
                , RECP_USER_NO         /* ���Ż���ڹ�ȣ */
                , MSG_TYPE             /* �޼������� */
                , SEND_TYPE            /* �߼����� */
                , SEND_PSN_HAND_TELNO  /* �߼����޴���ȭ��ȣ */
                , SEND_PSN_EMAIL_ADDR  /* �߼����̸����ּ� */
                , RECPR_HAND_TELNO     /* �������޴���ȭ��ȣ */
                , RECPR_EMAIL_ADDR     /* �������̸����ּ� */
                , SEND_TTL             /* �߼����� */
                , SEND_CTNT            /* �߼۳��� */
                , RESER_YN             /* ���࿩�� */
                , SEND_RESER_DTTM      /* �߼ۿ����Ͻ� */
                , SEND_YN              /* �߼ۿ��� */
                , ATTC_FILE_NO         /* ÷�����Ϲ� */
                , SEND_LOG             /* �߼��̷� */
                , SEND_RSLT_CD         /* �߼۰���ڵ� */
                , SEND_RPST_NO         /* �߼۴�ǥ�� */
                , INPT_ID              /* �Է���ID */
                , INPT_DTTM            /* �Է��Ͻ� */
                , INPT_IP              /* �Է���IP */
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
            OUT_MSG := '���� ó���Ǿ����ϴ�.';

            EXCEPTION
                WHEN OTHERS THEN
                    SP_SSTM056_CREA(V_PGM_ID, V_STG_NM, SQLCODE, SQLERRM, '', '');
                    OUT_NUM := SQLCODE;
                    OUT_MSG := '�����л� �������� ���� �ݿ��� �����Ͽ����ϴ�.';
                    ROLLBACK;
                    RETURN;

END;
/
