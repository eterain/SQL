CREATE OR REPLACE PROCEDURE SP_BUDG300_IMSI_CREA_02
/***************************************************************************************
�� ü �� : SP_BUDG300_IMSI_CREA_02
��    �� : �����̿�ó�� (�ڷγ�19 Ư�����б� ���� ����)
�� �� �� : 2020.09.18.
�� �� �� : �ڿ���
RETURN�� : �����̿�ó�� ���
������� : ���ϰ��� 0 : ����  1 : ����
****************************************************************************************/
(
        OUT_RTN         	OUT NUMBER,                   --ó����� RETURN��
        OUT_MSG         	OUT VARCHAR2                  --���� �޽���
)
IS
        V_BUDG_DVRS_NO      NUMBER(8);      -- ���������ȣ.(Sequence.SEQ_BUDG300) 
        V_BUDG_FORMA_NO 	NUMBER(8);      -- ��������ȣ.(Sequence.SEQ_BUDG100) 
        
        --V_PGM_ID        	VARCHAR2(20) := 'SP_BUDG300_IMSI_CREA_02';
        V_SR_RESN       	VARCHAR2(250):= '�ڷγ�19�� ���� ��ϱ� ȯ��';
		V_CONN_NO           VARCHAR2(80) := 'SNUA040300000000000120160302151813483';
        V_INPT_ID        	VARCHAR2(20) := 'TEMP_CREA_02';
        V_INPT_IP       	VARCHAR2(20) := '147.47.205.196';
        
        
BEGIN

    DELETE BUDG300 
     WHERE INPT_ID = V_INPT_ID;   
     
    DELETE BUDG100 
     WHERE INPT_ID = V_INPT_ID;   
     
    DELETE BUDG310 
     WHERE INPT_ID = V_INPT_ID;   
    
    BEGIN 
    
        -- BUDG300 (SELECT LOOP) : ��������. ���� ���꿡 ���� ������� �߻��� ����⺻������ ��� �����Ѵ�.
        FOR REC_MAIN IN ( SELECT ACNT_YY, 
                                 ACNT_FG, 
                                 ACNT_FG_NM, 
                                 BUDG_FG, 
                                 SEQ, 
                                 QUTE, 
                                 BUDG_DEPT_CD, 
                                 BUDG_DEPT_NM, 
                                 ADJ_DT, 
                                 CYOV_FG, 
                                 CYOV_YY, 
                                 BIZ_CD, 
                                 BIZ_NM, 
                                 BUDG_SBJT_CD_SST, 
                                 BUDG_SBJT_CD_SB, 
                                 BUDG_SBJT_NM, 
                                 BUDGT_PRSNT_AMT, 
                                 ALD_ASGN_AMT, 
                                 BALN, 
                                 BUDG_FORMA_NO
                          FROM TEMP_TUIT_BUDG A ) 
        LOOP 
        
            -- ���������ȣ����
            SELECT SEQ_BUDG300.NEXTVAL INTO V_BUDG_DVRS_NO FROM DUAL ;
            
            -- BUDG300 : ��������. ���� ���꿡 ���� ������� �߻��� ����⺻������ ��� �����Ѵ�.
            INSERT INTO BUDG300 ( BUDG_DVRS_NO    /* ���������ȣ.(Sequence.SEQ_BUDG300) */
                               ,ACNT_YY         /* ȸ�迬�� */
                               ,ACNT_FG         /* ȸ�豸��.[A0601] */
                               ,BUDG_DEPT_CD    /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */                                                
                               ,DVRS_FG         /* ���뱸��.[A0405.1:�μ���,2:�μ���] */
                               ,APLY_DT         /* ��û���� */
                               ,ADJ_RESN        /* �������� */
                               ,EL_DOC_CONN_NO  /* ���ο�û��ȣ */
                               ,TRET_DT         /* ó������ */
                               ,TRET_FG         /* ó������.[1:��û,2:Ȯ��,3:�ݷ�] */
                               ,TRET_CTNT       
                               ,TRANS_FG        /* ��ü����.[A0408] */ 
                               ,INT_DVRS_YN     /* ��ü���뿩�� */
                               ,INPT_ID         /* �Է�ID */
                               ,INPT_DTTM       /* �Է��Ͻ� */
                               ,INPT_IP         /* �Է�IP */
                             ) VALUES (
                                V_BUDG_DVRS_NO      /* ���������ȣ */
                               ,REC_MAIN.ACNT_YY         /* BUDG300ȸ�迬�� */
                               ,REC_MAIN.ACNT_FG         /* ȸ�豸��.[A0601] */
                               ,'0056'                   /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
                               ,'A040500004'        /* ���뱸��.[1:�μ���,2:�μ���] */
                               ,REC_MAIN.ADJ_DT          /* ��û���� - TEMP_TUIT_BUDG.�������� */
                               ,V_SR_RESN           /* �������� */
                               ,V_CONN_NO           /* ���ο�û��ȣ */
                               ,REC_MAIN.ADJ_DT          /* ó������ - TEMP_TUIT_BUDG.�������� */
                               ,'A041400002'        /* ó������.[1:��û,2:Ȯ��,3:�ݷ�] */
                               ,V_SR_RESN
                               ,'A040800003'        /* ��ü����.[4:�����]*/
                               ,'N'                 /* ��ü���뿩�� */
                               ,V_INPT_ID           /* �Է�ID */
                               ,SYSDATE             /* �Է��Ͻ� */
                               ,V_INPT_IP           /* �Է�IP */
                             ) ;     
        
            -- ��������ȣ����
            SELECT SEQ_BUDG100.NEXTVAL INTO V_BUDG_FORMA_NO FROM DUAL ;
                     
            -- ������ �űԵ��
            MERGE INTO BUDG100 A
            USING ( SELECT V_BUDG_FORMA_NO AS BUDG_FORMA_NO,
                           REC_MAIN.ACNT_YY AS ACNT_YY, 
                           REC_MAIN.ACNT_FG AS ACNT_FG, 
                           REC_MAIN.BUDG_DEPT_CD AS BUDG_DEPT_CD,        
                           REC_MAIN.BUDG_FG AS BUDG_FG,   
                           REC_MAIN.SEQ AS SEQ, 
                           '0' AS BAL_FG,                              /* ��������.[1:����,0:����] */
                           REC_MAIN.CYOV_FG AS CYOV_FG,                /* �̿�����.[A0403. 0:������,1:���,2:���] - �̿����� �����۾�. �ϴ� �������� 0*/                           
                           REC_MAIN.CYOV_YY AS CYOV_YY,                              
                           REC_MAIN.BIZ_CD AS BIZ_CD,                              
                           SUBSTR(REC_MAIN.BUDG_SBJT_CD_SB,1,2) || '00' AS BUDG_SBJT_CD_SST,   
                           SUBSTR(REC_MAIN.BUDG_SBJT_CD_SB,1,3) || '0' AS BUDG_SBJT_CD_SECT,   
                           SUBSTR(REC_MAIN.BUDG_SBJT_CD_SB,1,4) AS BUDG_SBJT_CD_ITEM,   
                           REC_MAIN.BUDG_SBJT_CD_SB AS BUDG_SBJT_CD_SB,   
                           'A040400001' AS FORMA_FG,                  /* ������.[A0404.0:�䱸,1:��,2:����] */                           
                           0 AS DMND_AMT,                             /* �䱸�� */
                           0 AS FORMA_AMT,                            /* ���� */
                           0 AS ABUDG_AMT,                            /* �߰�� */                            
                           NULL AS FORMA_DT,
                           'N' AS ABUDG_YN,                           /* �߰濩�� */
                           V_INPT_ID AS INPT_ID,
                           SYSDATE AS INPT_DTTM,
                           V_INPT_IP AS INPT_IP
                    FROM DUAL
                  ) B
            ON ( A.ACNT_YY           = B.ACNT_YY
                 AND A.ACNT_FG       = B.ACNT_FG
                 AND A.BUDG_DEPT_CD  = B.BUDG_DEPT_CD
                 AND A.BUDG_FG       = B.BUDG_FG
                 AND A.SEQ           = B.SEQ
                 AND A.BIZ_CD        = B.BIZ_CD
                 AND A.BAL_FG        = B.BAL_FG
                 AND A.CYOV_FG       = B.CYOV_FG
                 AND A.CYOV_YY       = B.CYOV_YY
                 AND A.BUDG_SBJT_CD_SB = B.BUDG_SBJT_CD_SB ) 
            WHEN NOT MATCHED THEN  
                 INSERT ( A.BUDG_FORMA_NO                       /* ��������ȣ.(Sequence.SEQ_BUDG100) */
                        ,A.ACNT_YY                              /* ȸ�迬�� */
                        ,A.ACNT_FG                              /* ȸ�豸��.[A0601] */
                        ,A.BUDG_DEPT_CD                         /* ����μ��ڵ� */
                        ,A.BUDG_FG                              /* ���걸��.[A0401] */
                        ,A.SEQ                                  /* ���� */
                        ,A.BAL_FG                               /* ��������.[1:����,0:����] */
                        ,A.CYOV_FG                              /* �̿�����.[A0403. 0:������,1:���,2:���] */
                        ,A.CYOV_YY                              /* �̿����� */
                        ,A.BIZ_CD
                        ,A.BUDG_SBJT_CD_SST                     /* ��������ڵ�_�� */
                        ,A.BUDG_SBJT_CD_SECT                    /* ��������ڵ�_�� */
                        ,A.BUDG_SBJT_CD_ITEM                    /* ��������ڵ�_�� */
                        ,A.BUDG_SBJT_CD_SB                      /* ��������ڵ�_���� */
                        ,A.FORMA_FG                             /* ������.[A0404.0:�䱸,1:��,2:����] */
                        ,A.DMND_AMT                             /* �䱸�� */
                        ,A.FORMA_AMT                            /* ���� */
                        ,A.ABUDG_AMT                            /* �߰�� */
                        ,A.FORMA_DT                             /* ������ */
                        ,A.ABUDG_YN                             /* �߰濩�� */
                        ,A.INPT_ID                              /* �Է�ID */
                        ,A.INPT_DTTM                            /* �Է��Ͻ� */
                        ,A.INPT_IP                              /* �Է�IP */
                  ) VALUES ( B.BUDG_FORMA_NO                        /* ��������ȣ.(Sequence.SEQ_BUDG100) */
                            ,B.ACNT_YY                              /* ȸ�迬�� */
                            ,B.ACNT_FG                              /* ȸ�豸��.[A0601] */
                            ,B.BUDG_DEPT_CD                         /* ����μ��ڵ� */
                            ,B.BUDG_FG                              /* ���걸��.[A0401] */
                            ,B.SEQ                                  /* ���� */
                            ,B.BAL_FG                               /* ��������.[1:����,0:����] */
                            ,B.CYOV_FG                              /* �̿�����.[A0403. 0:������,1:���,2:���] */
                            ,B.CYOV_YY                              /* �̿����� */
                            ,B.BIZ_CD
                            ,B.BUDG_SBJT_CD_SST                     /* ��������ڵ�_�� */
                            ,B.BUDG_SBJT_CD_SECT                    /* ��������ڵ�_�� */
                            ,B.BUDG_SBJT_CD_ITEM                    /* ��������ڵ�_�� */
                            ,B.BUDG_SBJT_CD_SB                      /* ��������ڵ�_���� */
                            ,B.FORMA_FG                             /* ������.[A0404.0:�䱸,1:��,2:����] */                            
                            ,B.DMND_AMT                             /* �䱸�� */
                            ,B.FORMA_AMT                            /* ���� */
                            ,B.ABUDG_AMT                            /* �߰�� */                            
                            ,B.FORMA_DT                             /* ������ */
                            ,B.ABUDG_YN                             /* �߰濩�� */
                            ,B.INPT_ID                              /* �Է�ID */
                            ,B.INPT_DTTM                            /* �Է��Ͻ� */
                            ,B.INPT_IP                              /* �Է�IP */
                  ) ;
                
            INSERT INTO BUDG310 ( BUDG_DVRS_NO    /* ���������ȣ */
                                   , SRNUM           /* �Ϸù�ȣ */
                                   , ACNT_YY         /* ȸ�迬�� */
                                   , ACNT_FG         /* ȸ�豸��.[A0601] */
                                   , IO_FG           /* ���ⱸ��.[0:����,1:����] */
                                   , BUDG_DEPT_CD    /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
                                   , CYOV_FG         /* �̿����� */
                                   , CYOV_YY         /* �̿����� */
                                   , BIZ_CD          /* ����ڵ� */
                                   , BUDG_SBJT_CD_SB /* ��������ڵ�_���� */
                                   , ORGN_BUDG       /* ���ʿ��� */
                                   , DVRS_AMT        /* ����� */
                                   , DVRS_DT         /* �������� */
                                   , FXD_YN          /* Ȯ������ */
                                   , BUDG_FORMA_NO   /* ��������ȣ */
                                   , INPT_ID         /* �Է�ID */
                                   , INPT_DTTM       /* �Է��Ͻ� */
                                   , INPT_IP         /* �Է�IP */
                             ) VALUES ( V_BUDG_DVRS_NO                         /* ���������ȣ */
                                       , ( SELECT LPAD(NVL(MAX(SRNUM), 0) + 1, 2, 0)
                                           FROM BUDG310
                                           WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )  /* �Ϸù�ȣ */
                                       , REC_MAIN.ACNT_YY
                                       , REC_MAIN.ACNT_FG                  
                                       , '0'                                  /* ���ⱸ��.[0:����,1:����] */
                                       , REC_MAIN.BUDG_DEPT_CD                       /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
                                       , REC_MAIN.CYOV_FG                            /* �̿����� */
                                       , REC_MAIN.CYOV_YY                            /* �̿����� */
                                       , REC_MAIN.BIZ_CD                      /* ����ڵ� */
                                       , REC_MAIN.BUDG_SBJT_CD_SB             /* ��������ڵ�_���� */                                       
                                       , NVL(REC_MAIN.BUDGT_PRSNT_AMT,0)        /* ���ʿ��� - ������ �����ִ� �뵵 �����ְ� ������ �Ǿ� �״��*/
                                       , ABS(NVL(REC_MAIN.BALN,0) * 1000) * -1        /* ����� */                                       
                                       , REC_MAIN.ADJ_DT                      /* �������� */
                                       , 'Y'                                  /* Ȯ������ */                                       
                                       , V_BUDG_FORMA_NO                      /* ��������ȣ */
                                       , V_INPT_ID                            /* �Է�ID */
                                       , SYSDATE                              /* �Է��Ͻ� */
                                       , V_INPT_IP                            /* �Է�IP */
                             ) ;
            INSERT INTO BUDG310 ( BUDG_DVRS_NO    /* ���������ȣ */
                                   , SRNUM           /* �Ϸù�ȣ */
                                   , ACNT_YY         /* ȸ�迬�� */
                                   , ACNT_FG         /* ȸ�豸��.[A0601] */
                                   , IO_FG           /* ���ⱸ��.[0:����,1:����] */
                                   , BUDG_DEPT_CD    /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
                                   , CYOV_FG         /* �̿����� */
                                   , CYOV_YY         /* �̿����� */
                                   , BIZ_CD          /* ����ڵ� */
                                   , BUDG_SBJT_CD_SB /* ��������ڵ�_���� */
                                   , ORGN_BUDG       /* ���ʿ��� */
                                   , DVRS_AMT        /* ����� */
                                   , DVRS_DT         /* �������� */
                                   , FXD_YN          /* Ȯ������ */
                                   , BUDG_FORMA_NO   /* ��������ȣ */
                                   , INPT_ID         /* �Է�ID */
                                   , INPT_DTTM       /* �Է��Ͻ� */
                                   , INPT_IP         /* �Է�IP */
                             ) VALUES ( V_BUDG_DVRS_NO                         /* ���������ȣ */
                                       , ( SELECT LPAD(NVL(MAX(SRNUM), 0) + 1, 2, 0)
                                           FROM BUDG310
                                           WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )  /* �Ϸù�ȣ */
                                       , REC_MAIN.ACNT_YY
                                       , REC_MAIN.ACNT_FG                  
                                       , '1'                                  /* ���ⱸ��.[0:����,1:����] */
                                       , REC_MAIN.BUDG_DEPT_CD                /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
                                       , REC_MAIN.CYOV_FG                     /* �̿����� */
                                       , REC_MAIN.CYOV_YY                     /* �̿����� */
                                       , '0207420'                            /* ����ڵ� */
                                       , '431101'                             /* ��������ڵ�_���� */                                       
                                       , 0                                    /* ���ʿ��� - ������ �����ִ� �뵵 �����ְ� ������ �Ǿ� �״��*/
                                       , NVL(REC_MAIN.BALN,0) * 1000          /* ����� */                                       
                                       , REC_MAIN.ADJ_DT                      /* �������� */
                                       , 'Y'                                  /* Ȯ������ */                                       
                                       , V_BUDG_FORMA_NO                      /* ��������ȣ */
                                       , V_INPT_ID                            /* �Է�ID */
                                       , SYSDATE                              /* �Է��Ͻ� */
                                       , V_INPT_IP                            /* �Է�IP */
                             ) ;                
        
        END LOOP;            
        
        EXCEPTION
            WHEN OTHERS THEN
                OUT_RTN := 0;
                OUT_MSG := '�����̿� ó���� ������ �߻��Ͽ����ϴ�.';
                RETURN;
    END; 

    OUT_RTN := 1;
    OUT_MSG := '���������� ó���Ǿ����ϴ�.';

    RETURN;
END;
/
