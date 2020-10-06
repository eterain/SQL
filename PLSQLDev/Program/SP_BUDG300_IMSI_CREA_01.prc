CREATE OR REPLACE PROCEDURE SP_BUDG300_IMSI_CREA_01
/***************************************************************************************
�� ü �� : SP_BUDG300_IMSI_CREA_01
��    �� : ���������ó�� (�ڷγ�19 Ư�����б� ���� ����)
�� �� �� : 2020.09.17.
�� �� �� : �̹α�
�������� :
1.������ :
2.������ :
3.�� �� :
������ü :   BUDG100              --������

RETURN�� : �������ó�� ���
������� : ���ϰ��� 0 �� ���� ���������̹Ƿ� �� ���� �κп��� ����ó���� ��!!!
****************************************************************************************/
(
		OUT_RTN         	   OUT NUMBER,                      --ó����� RETURN��
		OUT_MSG         	   OUT VARCHAR2                     --���� �޽���
)
IS
		V_BUDG_DVRS_NO    NUMBER(8);
		--V_BUDG_FORMA_NO 	NUMBER(8);
		V_PGM_ID        	VARCHAR2(30) := 'SP_BUDG300_IMSI_CREA_01';
		V_STG_NM        	SSTM056.OCCR_LOC_NM%TYPE;
		V_INPT_ID        	VARCHAR2(20) := 'SR2009-17130_1';  /*  */
        V_SR_RESN       	VARCHAR2(250):= '��ϱ� ȯ�� ���(���۾��ϰ�ó��, SR2009-17130)';
		V_INPT_IP       	VARCHAR2(20) := '147.47.205.196'; /*  */
		V_CONN_NO         VARCHAR2(80) := 'SNUA040300000000000120160302151813483';
		
		V_BUDG_FORMA_NO_CNT          NUMBER(8);
		
		/* ����  */
		V_BUDG_FORMA_NO_BF           NUMBER(8);
		V_BUDG_SBJT_CD_SB_BF         VARCHAR2(6);
		V_BUDG_SBJT_NM_BF            VARCHAR2(400);
		V_CYOV_FG_BF                 VARCHAR2(10);
		V_CYOV_YY_BF                 VARCHAR2(4);
		V_BIZ_CD_BF                  VARCHAR2(10);
		V_BIZ_SEQ_BF                 NUMBER(20);
		V_ORGN_BUDG_FST_BF           NUMBER(15);
		V_ORGN_BUDG_VIEW_FST_BF      NUMBER(15);
		V_ORGN_BUDG_BF               NUMBER(15);
		V_ORGN_BUDG_VIEW_BF          NUMBER(15);
		V_ASGN_AMT_BF                NUMBER(15);
		V_ASGN_AMT_ORG_BF            NUMBER(15);
		V_WAIT_AMT_BF                NUMBER(15);
		
		/* ����  */ 
		V_BUDG_FORMA_NO_AF           NUMBER(8);
		V_BUDG_SBJT_CD_SB_AF         VARCHAR2(6);
		V_BUDG_SBJT_NM_AF            VARCHAR2(400);
		V_CYOV_FG_AF                 VARCHAR2(10);
		V_CYOV_YY_AF                 VARCHAR2(4);
		V_BIZ_CD_AF                  VARCHAR2(10);
		V_BIZ_SEQ_AF                 NUMBER(20);
		V_ORGN_BUDG_FST_AF           NUMBER(15);
		V_ORGN_BUDG_VIEW_FST_AF      NUMBER(15);
		V_ORGN_BUDG_AF               NUMBER(15);
		V_ORGN_BUDG_VIEW_AF          NUMBER(15);
		V_ASGN_AMT_AF                NUMBER(15);
		V_ASGN_AMT_ORG_AF            NUMBER(30);
		V_WAIT_AMT_AF                NUMBER(30);
		
		V_BUDG_DEPT_CD							 VARCHAR2(10);
		V_BIZ_CD										 VARCHAR2(10);
		V_BUDG_SBJT_CD_SB						 VARCHAR2(6);
		V_BUDG_DEPT_NM							 VARCHAR2(400);
		V_BIZ_NM       							 VARCHAR2(400);
		V_BUDG_SBJT_NM							 VARCHAR2(400);

BEGIN

    
    DELETE BUDG210
     WHERE INPT_ID = V_INPT_ID;
      
		DELETE BUDG310
		 WHERE INPT_ID = V_INPT_ID;
		 
		DELETE BUDG100
		 WHERE INPT_ID = V_INPT_ID;
   
		DELETE BUDG300
		 WHERE INPT_ID = V_INPT_ID;
     
		BEGIN
				FOR REC IN (SELECT 
	  		  		  		  		 	 ACNT_YY					/* ȸ��⵵ */
													  ,ACNT_FG          /* ȸ�豸�� */
													  ,ACNT_FG_NM       /* ȸ�豸�и� */
													  ,BUDG_FG          /* ���걸�� */
													  ,SEQ              /* ���� */
													  ,QUTE             /* �б� */
													  ,BUDG_DEPT_CD     /* ����μ��ڵ� */
													  ,BUDG_DEPT_NM     /* ����м��� */
													  ,ADJ_DT           /* �������� */
													  ,CYOV_FG          /* �̿����� */
													  ,CYOV_YY          /* �̿����� */
													  ,BIZ_CD           /* ����ڵ� */
													  ,BIZ_NM           /* ����� */
													  ,BUDG_SBJT_CD_SST /* ��������ڵ�_�� */
													  ,BUDG_SBJT_CD_SB  /* ��������ڵ�_���� */
													  ,BUDG_SBJT_NM     /* ����� */
													  ,BUDGT_PRSNT_AMT  /* ������� */
													  ,ALD_ASGN_AMT     /* ������� */
													  ,BALN             /* �ܾ� */
													  ,BUDG_FORMA_NO    /* ����ȣ */
											FROM   TEMP_TUIT_BUDG A 
				             WHERE  1 = 1
				               AND  A.BUDG_DEPT_CD    NOT IN   ('0056', '700') /* ������������ �̿뿡���� ó�� �ϸ� ��. ������б��� ��ü ó�� */
											)
				LOOP
						V_BUDG_DEPT_CD		:= REC.BUDG_DEPT_CD;
						V_BIZ_CD					:= REC.BIZ_CD;
						V_BUDG_SBJT_CD_SB	:= REC.BUDG_SBJT_CD_SB;
						V_BUDG_DEPT_NM		:= REC.BUDG_DEPT_NM;
						V_BIZ_NM       		:= REC.BIZ_NM;
						V_BUDG_SBJT_NM		:= REC.BUDG_SBJT_NM;				 

						/* 1. ����� ��û ��ȣ SEQ ����  */
						SELECT SEQ_BUDG300.NEXTVAL
						  INTO V_BUDG_DVRS_NO
						  FROM DUAL;
		  

        	/* 2. ����� ��û ��� INSERT */
        	V_STG_NM := 'INSERT BUDG300';
				  INSERT INTO BUDG300
				        			       (
								                BUDG_DVRS_NO    /* ���������ȣ.(Sequence.SEQ_BUDG300) */
								               ,ACNT_YY         /* ȸ�迬�� */
								               ,ACNT_FG         /* ȸ�豸��.[A0601] */
								               ,BUDG_DEPT_CD    /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */									               
								               ,DVRS_FG         /* ���뱸��.[A0405.1:�μ���,2:�μ���] */
								               ,APLY_DT         /* ��û���� */
								               ,ADJ_RESN        /* �������� */
								               ,EL_DOC_CONN_NO  /* ���ο�û��ȣ */
								               ,TRET_DT         /* ó������ */
								               ,TRET_FG         /* ó������.[1:��û,2:Ȯ��,3:�ݷ�] */
								               ,INPT_ID         /* �Է�ID */
								               ,INPT_DTTM       /* �Է��Ͻ� */
								               ,INPT_IP         /* �Է�IP */
								               ,TRANS_FG        /* ��ü����.[A0408] */
								             )
								        VALUES
								        	   (
								                V_BUDG_DVRS_NO      /* ���������ȣ */
								               ,REC.ACNT_YY         /* BUDG300ȸ�迬�� */
								               ,REC.ACNT_FG         /* ȸ�豸��.[A0601] */
								               ,REC.BUDG_DEPT_CD    /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
								               ,'A040500002'        /* ���뱸��.[1:�μ���,2:�μ���] */
								               ,REC.ADJ_DT          /* ��û���� - TEMP_TUIT_BUDG.�������� */
								               ,V_SR_RESN           /* �������� */
								               ,V_CONN_NO						/* ���ο�û��ȣ */
								               ,REC.ADJ_DT          /* ó������ - TEMP_TUIT_BUDG.��������*/
								               ,'A041400002'        /* ó������.[1:��û,2:Ȯ��,3:�ݷ�] */
								               ,V_INPT_ID           /* �Է�ID */
								               ,SYSDATE             /* �Է��Ͻ� */
								               ,V_INPT_IP           /* �Է�IP */
								               ,'A040800004'        /* ��ü����.[4:�����]*/
								             );
								             
					
					BEGIN
					V_STG_NM := 'SELECT BUDG100(����)';
					

					SELECT  COUNT(*)
              INTO  V_BUDG_FORMA_NO_CNT
              FROM  BUDG100 A
             WHERE 1 = 1 
          		AND A.FORMA_FG         = 'A040400001'
           		AND A.BAL_FG           = '0'
           		AND A.SEQ              = 0
           		AND A.BUDG_FG          = 'A040100000' /*������-0����*/
           		AND A.BUDG_DEPT_CD 		 = REC.BUDG_DEPT_CD
           		AND A.ACNT_YY   			 = REC.ACNT_YY
           		AND A.ACNT_FG          = REC.ACNT_FG
							AND A.BIZ_CD 					 = REC.BIZ_CD
							AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
  	          AND A.CYOV_YY          = REC.CYOV_YY
           		AND A.CYOV_FG          = REC.CYOV_FG;
           		

         IF  V_BUDG_FORMA_NO_CNT > 0 THEN 
					 SELECT A2.BUDG_FORMA_NO AS BUDG_FORMA_NO
             , A.BUDG_SBJT_CD_SB
             , SF_BUDG002_NM(A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.ACNT_YY,A.ACNT_FG, 4) AS BUDG_SBJT_NM
             , A.CYOV_FG
             , A.CYOV_YY
             , A.BIZ_CD
             , '0' AS BIZ_SEQ
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)))                  AS ORGN_BUDG_FST		     /* ����� = ����+�߰��+����� */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)) / 1000)           AS ORGN_BUDG_VIEW_FST	 /* ����� = ����+�߰��+����� */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)))    AS ORGN_BUDG            /* �����ܾ� = ����+�߰��+�����-����� */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)) / 1000 )    AS ORGN_BUDG_VIEW       /* �����ܾ� = ����+�߰��+�����-����� */
             , TRUNC((NVL(D.ASGN_AMT, 0)  +NVL(C.PRE_ADJ_AMT, 0)) / 1000 )                                   AS ASGN_AMT             /* ������� = �ش� ȸ�迬�� �ش�б� �����ױ��� ����. �ش�б⳻ ���� �����׵� ���� */
             , NVL(D.ASGN_AMT, 0) + NVL(C.PRE_ADJ_AMT, 0)                                            AS ASGN_AMT_ORG         /* ������� = �ش� ȸ�迬�� �ش�б� �����ױ��� ����. �ش�б⳻ ���� �����׵� ���� */
             , SF_BUDG100_CURR_AMT2(A.ACNT_YY, A.ACNT_FG, A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.BUDG_DEPT_CD, '', '', 1, '4', A.CYOV_FG, A.CYOV_YY, A2.BUDG_FORMA_NO) AS WAIT_AMT /* ���� */
             INTO  V_BUDG_FORMA_NO_BF
                  ,V_BUDG_SBJT_CD_SB_BF
                  ,V_BUDG_SBJT_NM_BF
                  ,V_CYOV_FG_BF
                  ,V_CYOV_YY_BF
                  ,V_BIZ_CD_BF
                  ,V_BIZ_SEQ_BF
                  ,V_ORGN_BUDG_FST_BF
                  ,V_ORGN_BUDG_VIEW_FST_BF
                  ,V_ORGN_BUDG_BF
                  ,V_ORGN_BUDG_VIEW_BF
                  ,V_ASGN_AMT_BF
                  ,V_ASGN_AMT_ORG_BF
                  ,V_WAIT_AMT_BF
          FROM ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , SUM(AMT) AS AMT /* ����� */
                   FROM BUDG400
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) F
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ASGN_AMT,0)) AS ASGN_AMT
                   FROM BUDG200
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND REC.ADJ_DT   >= ASGN_DT
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) D /*���� ������*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ADJ_AMT, 0)) AS PRE_ADJ_AMT /*�ش�б� ���� �� �ش�б� ��������(��ȸ����) ���� ����������*/
                   FROM BUDG210
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND REC.ADJ_DT   >= ADJ_DT
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND TRET_FG      = 'A041400002'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) C /*���� ����������*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , SUBSTR(BUDG_SBJT_CD_SB,1,2) || '00' AS BUDG_SBJT_CD_SST /* �� */
                      , BUDG_SBJT_CD_SB                     AS BUDG_SBJT_CD_SB  /* ���� */
                      , sum(nvl(DVRS_AMT, 0))               AS DVRS_AMT         /* ����� */
                   FROM BUDG310
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND FXD_YN       = 'Y'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB ) B         /*�����*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SST
                      , BUDG_SBJT_CD_SB        as BUDG_SBJT_CD_SB /*����*/
                      , BUDG_FORMA_NO
                      , sum(FORMA_AMT)         as FORMA_AMT /*����*/
                      , sum(nvl(ABUDG_AMT, 0)) as ABUDG_AMT /*�߰��*/
                   FROM BUDG100
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND FORMA_FG     = 'A040400001'
                    AND BAL_FG       = '0'
                    AND SEQ          = 0
                    AND BUDG_FG      = 'A040100000'   /*������-0����*/
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD
                         , BUDG_SBJT_CD_SST, BUDG_SBJT_CD_SB, BUDG_FORMA_NO) A2 /*����*/
             , BUDG100 A
         WHERE A.ACNT_YY          = B.ACNT_YY(+)
           and A.ACNT_FG          = B.ACNT_FG(+)
           and A.CYOV_YY          = B.CYOV_YY(+)
           and A.CYOV_FG          = B.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = B.BUDG_SBJT_CD_SB(+) /*����*/
           and A.BUDG_SBJT_CD_SST = B.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = B.BIZ_CD(+)
           and A.ACNT_YY          = A2.ACNT_YY(+)
           and A.ACNT_FG          = A2.ACNT_FG(+)
           and A.CYOV_YY          = A2.CYOV_YY(+)
           and A.CYOV_FG          = A2.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = A2.BUDG_SBJT_CD_SB(+)        /*����*/
           and A.BUDG_SBJT_CD_SST = A2.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = A2.BIZ_CD(+)
           AND A.ACNT_YY          = C.ACNT_YY(+)
           and A.ACNT_FG          = C.ACNT_FG(+)
           and A.CYOV_YY          = C.CYOV_YY(+)
           and A.CYOV_FG          = C.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = C.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = C.BIZ_CD(+)
           AND A.ACNT_YY          = D.ACNT_YY(+)
           and A.ACNT_FG          = D.ACNT_FG(+)
           and A.CYOV_YY          = D.CYOV_YY(+)
           and A.CYOV_FG          = D.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = D.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = D.BIZ_CD(+)
           AND A.ACNT_YY          = F.ACNT_YY(+)
           and A.ACNT_FG          = F.ACNT_FG(+)
           AND A.BUDG_DEPT_CD     = F.BUDG_DEPT_CD(+)
           and A.CYOV_YY          = F.CYOV_YY(+)
           and A.CYOV_FG          = F.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = F.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = F.BIZ_CD(+)
           and A.FORMA_FG         = 'A040400001'
           and A.BAL_FG           = '0'
           and A.SEQ              = 0
           and A.BUDG_FG          = 'A040100000' /*������-0����*/
           and A.BUDG_DEPT_CD     = REC.BUDG_DEPT_CD
           and A.ACNT_FG          = REC.ACNT_FG
           and A.ACNT_YY          = REC.ACNT_YY
           AND A.BIZ_CD           = REC.BIZ_CD
           AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
           AND A.CYOV_YY          = REC.CYOV_YY
           AND A.CYOV_FG          = REC.CYOV_FG
           AND ROWNUM             = 1
         order by A.ACNT_YY, A.ACNT_FG, A.BUDG_DEPT_CD, A.BIZ_CD
                , A.BUDG_SBJT_CD_SST, A.BUDG_SBJT_CD_SB, A.CYOV_FG, A.CYOV_YY;
--         EXCEPTION
--	        WHEN NO_DATA_FOUND THEN
--	            OUT_RTN := 0;
--	            OUT_MSG := '�������(����) �����Ͱ� �����ϴ�.';
						

	        
--	        IF OUT_RTN = 0 THEN
				ELSE 
         /* 4.����ȣ ������ ��������  */				  				             
					SELECT SEQ_BUDG100.NEXTVAL
						INTO V_BUDG_FORMA_NO_BF 
					FROM DUAL;
						
     
     			/* 5.BUDG100 INSERT : ������ ��ȣ�� ���� ��츸  */
     			V_STG_NM := 'INSERT BUDG100(����)';
						INSERT INTO BUDG100 ( 
						  		  		  		  	BUDG_FORMA_NO     /* ��������ȣ.(Sequence.SEQ_BUDG100) */
						                    , ACNT_YY           /* ȸ�迬�� */
						                    , ACNT_FG           /* ȸ�豸��.[A0601] */
						                    , BUDG_DEPT_CD      /* ����μ��ڵ� */
						                    , BUDG_FG           /* ���걸��.[A0401] */
						                    , SEQ               /* ���� */
						                    , BAL_FG            /* ��������.[1:����,0:����] */
						                    , CYOV_FG           /* �̿�����.[A0403. 0:������,1:���,2:���] */
						                    , CYOV_YY           /* �̿����� */
						                    , BIZ_CD            /* ����ڵ� */
						                    , BUDG_SBJT_CD_SST  /* ��������ڵ�_�� */
						                    , BUDG_SBJT_CD_SECT /* ��������ڵ�_�� */
						                    , BUDG_SBJT_CD_ITEM /* ��������ڵ�_�� */
						                    , BUDG_SBJT_CD_SB   /* ��������ڵ�_���� */
						                    , FORMA_FG          /* ������.[A0404.0:�䱸,1:��,2:����] */
						                    , DMND_AMT          /* �䱸�� */
						                    , FORMA_AMT         /* ���� */
						                    , ABUDG_AMT			    /* �߰�� */
						                    , FORMA_DT          /* ������ */
						                    , ABUDG_YN			    /* �߰濩�� */
						                    , INPT_ID           /* �Է�ID */
						                    , INPT_DTTM         /* �Է��Ͻ� */
						                    , INPT_IP           /* �Է�IP */
						           ) VALUES ( V_BUDG_FORMA_NO_AF
						                    , REC.ACNT_YY                          /* ȸ�迬�� */
						                    , REC.ACNT_FG                          /* ȸ�豸��.[A0601] */
						                    , '0056'						                   /* ����μ��ڵ� ����������(����) */
						                    , 'A040100000'                         /* ���걸��.[A0401] */
						                    , 0                                    /* ���� */
						                    , 0                                    /* ��������.[1:����,0:����] */
						                    , REC.CYOV_FG                          /* �̿�����.[A0403. 0:������,1:���,2:���] - �̿����� �����۾�. �ϴ� �������� 0*/
						                    , REC.CYOV_YY                          /* �̿�����  - �̿����� �����۾�. �ϴ� ��������  ȸ�迬���� ����*/
						                    , REC.BIZ_CD                           /* ����ڵ� */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 2)||'00'   /* ��������ڵ�_�� */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 3)||'0'    /* ��������ڵ�_�� */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 4)         /* ��������ڵ�_��  : ��data ������� ���� ��������� ���ؼ� �־��ش�*/
						                    , REC.BUDG_SBJT_CD_SB                  /* ��������ڵ�_���� */
						                    , 'A040400001'                         /* ������.[A0404.0:�䱸,1:��,2:����] */
						                    , 0                                    /* �䱸�� */
						                    , 0                                    /* ���� */
						                    , 0                     		           /* �߰�� */
						                    , TO_CHAR(SYSDATE, 'YYYYMMDD')         /* ������ */
						                    , NULL     	             						   /* �߰濩�� */
						                    , V_INPT_ID                            /* �Է�ID */
						                    , SYSDATE                              /* �Է��Ͻ� */
						                    , V_INPT_IP                            /* �Է�IP */
						           				);
						END IF;
					END;
                
          /* 7. BUDG310 INSERT(����)*/
          V_STG_NM := 'INSERT BUDG310(����)';
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
		                    , FXD_YN		      /* Ȯ������ */
		                    , BUDG_FORMA_NO   /* ��������ȣ */
        		            , INPT_ID         /* �Է�ID */
		                    , INPT_DTTM       /* �Է��Ͻ� */
		                    , INPT_IP         /* �Է�IP */
		           ) VALUES ( V_BUDG_DVRS_NO                          /* ���������ȣ */
        		            , ( SELECT lpad(nvl(max(SRNUM), 0) + 1, 2, 0)
		                          FROM BUDG310
		                         WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO) /* �Ϸù�ȣ */
        		            , REC.ACNT_YY                              /* ȸ�迬�� */
		                    , REC.ACNT_FG                              /* ȸ�豸��.[A0601] */
		                    , '0'                                      /* ���ⱸ��.[0:����,1:����] */
        		            , REC.BUDG_DEPT_CD                         /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
        		            , REC.CYOV_FG                              /* �̿����� */
        		            , REC.CYOV_YY                              /* �̿����� */
		                    , REC.BIZ_CD                               /* ����ڵ� */
		                    , REC.BUDG_SBJT_CD_SB                      /* ��������ڵ�_���� */
        		            , NVL(V_ORGN_BUDG_FST_BF, 0)        			 /* ���ʿ��� - ������ �����ִ� �뵵 �����ְ� ������ �Ǿ� �״��*/
		                    , NVL(REC.BALN, 0) * -1 * 1000             /* ����� - TEMP_TUIT_BUDG.BALN(������)  * -1 */
		                    , REC.ADJ_DT                               /* �������� */
		                    , 'Y'                                      /* Ȯ������ */
        			          , V_BUDG_FORMA_NO_BF                       /* ��������ȣ */
		                    , V_INPT_ID                                /* �Է�ID */
		                    , SYSDATE                                  /* �Է��Ͻ� */
        		            , V_INPT_IP                                /* �Է�IP */
		           );
			           
         /* 8. BUDG210 INSERT(����)*/
         V_STG_NM := 'INSERT BUDG210(����)';
					INSERT INTO BUDG210 ( ACNT_YY   /* ȸ�迬�� */
		                    , ACNT_FG         /* ȸ�豸��.[A0601] */
		                    , QUTE            /* �б� */
		                    , BUDG_DEPT_CD    /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
		                    , ADJ_DT          /* �������� */
		                    , CYOV_FG         /* �̿�����.[A0403. 0:������,1:���,2:���] */
		                    , CYOV_YY         /* �̿����� */
		                    , BIZ_CD          /* ����ڵ� */
		                    , BUDG_SBJT_CD_SB /* ��������ڵ�_���� */
		                    , BUDG_CURR_AMT   /* �������� */
		                    , ALD_ASGN_AMT    /* ������� */
		                    , ADJ_AMT         /* ������ */
		                    , ADJ_RESN        /* �������� */
		                    , INPT_ID         /* �Է�ID */
		                    , INPT_DTTM       /* �Է��Ͻ� */
		                    , INPT_IP         /* �Է�IP */
		                    , TRET_FG         /* ó������ */
		                    , BUDG_DVRS_NO
		                    , SRNUM
		                    , SEQ
		           ) VALUES ( REC.ACNT_YY                  /* ȸ�迬�� */
		                    , REC.ACNT_FG                  /* ȸ�豸��.[A0601] */
		                    , REC.QUTE                     /* �б� */
		                    , REC.BUDG_DEPT_CD             /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
		                    , REC.ADJ_DT                   /* �������� */
		                    , REC.CYOV_FG                  /* �̿�����.[A0403. 0:������,1:���,2:���] */
		                    , REC.CYOV_YY                  /* �̿����� */
		                    , REC.BIZ_CD                   /* ����ڵ� */
		                    , REC.BUDG_SBJT_CD_SB          /* ��������ڵ�_���� */
		                    , NVL(V_ORGN_BUDG_FST_BF, 0) + (NVL(REC.BALN, 0) * -1 * 1000)  /* ����� */
		                    , NVL(V_ASGN_AMT_ORG_BF, 0)    /* ������� */
		                    , NVL(REC.BALN, 0) *-1 * 1000  /* ������ */
		                    , V_SR_RESN                    /* �������� */
		                    , V_INPT_ID                    /* �Է�ID */
		                    , SYSDATE                      /* �Է��Ͻ� */
		                    , V_INPT_IP                    /* �Է�IP */
		                    , 'A041400002'                 /* ó������.[A0403. 2:Ȯ��] */
		                    , V_BUDG_DVRS_NO
		                    ,( SELECT lpad(nvl(max(SRNUM), 0), 2, 0)
		                         FROM BUDG310
		                        WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )
		                    ,( SELECT NVL(MAX(SEQ),0) + 1
												     FROM BUDG210
												    WHERE ACNT_YY = REC.ACNT_YY
												      AND ACNT_FG = REC.ACNT_FG
												      AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
												      AND ADJ_DT = REC.ADJ_DT)
		           );
		          
		       BEGIN 
		       V_BUDG_DEPT_CD		:= '0056';
		 		   V_STG_NM := 'SELEC BUDG100(����)';
		 		         
		       SELECT  COUNT(*)
              INTO  V_BUDG_FORMA_NO_CNT
              FROM  BUDG100 A
             WHERE 1 = 1 
          		AND A.FORMA_FG         = 'A040400001'
           		AND A.BAL_FG           = '0'
           		AND A.SEQ              = 0
           		AND A.BUDG_FG          = 'A040100000' /*������-0����*/
           		AND A.BUDG_DEPT_CD 		 = '0056'
           		AND A.ACNT_YY   			 = REC.ACNT_YY
           		AND A.ACNT_FG          = REC.ACNT_FG
							AND A.BIZ_CD 					 = REC.BIZ_CD
							AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
  	          AND A.CYOV_YY          = REC.CYOV_YY
           		AND A.CYOV_FG          = REC.CYOV_FG;
--		  DBMS_OUTPUT.PUT_LINE('V_BUDG_FORMA_NO_CNT(����) : '||V_BUDG_FORMA_NO_CNT);     
			IF V_BUDG_FORMA_NO_CNT > 0 THEN		
           /* 9. ����� �� ����(����) */
					 SELECT A2.BUDG_FORMA_NO AS BUDG_FORMA_NO
             , A.BUDG_SBJT_CD_SB
             , SF_BUDG002_NM(A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.ACNT_YY,A.ACNT_FG, 4) AS BUDG_SBJT_NM
             , A.CYOV_FG
             , A.CYOV_YY
             , A.BIZ_CD
             , '0' AS BIZ_SEQ
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)))                  AS ORGN_BUDG_FST		     /* ����� = ����+�߰��+����� */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)) / 1000)           AS ORGN_BUDG_VIEW_FST	 /* ����� = ����+�߰��+����� */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)))    AS ORGN_BUDG            /* �����ܾ� = ����+�߰��+�����-����� */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)) / 1000 )    AS ORGN_BUDG_VIEW       /* �����ܾ� = ����+�߰��+�����-����� */
             , TRUNC((NVL(D.ASGN_AMT, 0)  +NVL(C.PRE_ADJ_AMT, 0)) / 1000 )                                   AS ASGN_AMT             /* ������� = �ش� ȸ�迬�� �ش�б� �����ױ��� ����. �ش�б⳻ ���� �����׵� ���� */
             , NVL(D.ASGN_AMT, 0) + NVL(C.PRE_ADJ_AMT, 0)                                            AS ASGN_AMT_ORG         /* ������� = �ش� ȸ�迬�� �ش�б� �����ױ��� ����. �ش�б⳻ ���� �����׵� ���� */
             , SF_BUDG100_CURR_AMT2(A.ACNT_YY, A.ACNT_FG, A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.BUDG_DEPT_CD, '', '', 1, '4', A.CYOV_FG, A.CYOV_YY, A2.BUDG_FORMA_NO) AS WAIT_AMT /* ���� */
             INTO  V_BUDG_FORMA_NO_AF
                  ,V_BUDG_SBJT_CD_SB_AF
                  ,V_BUDG_SBJT_NM_AF
                  ,V_CYOV_FG_AF
                  ,V_CYOV_YY_AF
                  ,V_BIZ_CD_AF
                  ,V_BIZ_SEQ_AF
                  ,V_ORGN_BUDG_FST_AF
                  ,V_ORGN_BUDG_VIEW_FST_AF
                  ,V_ORGN_BUDG_AF
                  ,V_ORGN_BUDG_VIEW_AF
                  ,V_ASGN_AMT_AF
                  ,V_ASGN_AMT_ORG_AF
                  ,V_WAIT_AMT_AF
          FROM ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , SUM(AMT) AS AMT /* ����� */
                   FROM BUDG400
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = '0056' /* ����������(����)  */
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) F
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ASGN_AMT,0)) AS ASGN_AMT
                   FROM BUDG200
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = '0056' /* ����������(����) */
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND REC.ADJ_DT   >= ASGN_DT
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) D /*���� ������*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ADJ_AMT, 0)) AS PRE_ADJ_AMT /*�ش�б� ���� �� �ش�б� ��������(��ȸ����) ���� ����������*/
                   FROM BUDG210
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = '0056' /* ����������(����) */
                    AND REC.ADJ_DT   >= ADJ_DT
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND TRET_FG      = 'A041400002'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) C /*���� ����������*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , SUBSTR(BUDG_SBJT_CD_SB,1,2) || '00' AS BUDG_SBJT_CD_SST /* �� */
                      , BUDG_SBJT_CD_SB                     AS BUDG_SBJT_CD_SB  /* ���� */
                      , sum(nvl(DVRS_AMT, 0))               AS DVRS_AMT         /* ����� */
                   FROM BUDG310
                  WHERE ACNT_YY      = REC.ACNT_YY
                    and ACNT_FG      = REC.ACNT_FG
                    and BUDG_DEPT_CD = '0056' /* ����������(����) */
                    and FXD_YN       = 'Y'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB ) B         /*�����*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SST
                      , BUDG_SBJT_CD_SB        as BUDG_SBJT_CD_SB /*����*/
                      , BUDG_FORMA_NO
                      , sum(FORMA_AMT)         as FORMA_AMT /*����*/
                      , sum(nvl(ABUDG_AMT, 0)) as ABUDG_AMT /*�߰��*/
                   FROM BUDG100
                  WHERE ACNT_YY      = REC.ACNT_YY
                    and ACNT_FG      = REC.ACNT_FG
                    and BUDG_DEPT_CD = '0056' /* ����������(����) */
                    and FORMA_FG     = 'A040400001'
                    and BAL_FG       = '0'
                    and SEQ          = 0
                    and BUDG_FG      = 'A040100000'   /*������-0����*/
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD
                         , BUDG_SBJT_CD_SST, BUDG_SBJT_CD_SB, BUDG_FORMA_NO) A2 /*����*/
             , BUDG100 A
         WHERE A.ACNT_YY          = B.ACNT_YY(+)
           and A.ACNT_FG          = B.ACNT_FG(+)
           and A.CYOV_YY          = B.CYOV_YY(+)
           and A.CYOV_FG          = B.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = B.BUDG_SBJT_CD_SB(+) /*����*/
           and A.BUDG_SBJT_CD_SST = B.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = B.BIZ_CD(+)
           and A.ACNT_YY          = A2.ACNT_YY(+)
           and A.ACNT_FG          = A2.ACNT_FG(+)
           and A.CYOV_YY          = A2.CYOV_YY(+)
           and A.CYOV_FG          = A2.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = A2.BUDG_SBJT_CD_SB(+)        /*����*/
           and A.BUDG_SBJT_CD_SST = A2.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = A2.BIZ_CD(+)
           AND A.ACNT_YY          = C.ACNT_YY(+)
           and A.ACNT_FG          = C.ACNT_FG(+)
           and A.CYOV_YY          = C.CYOV_YY(+)
           and A.CYOV_FG          = C.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = C.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = C.BIZ_CD(+)
           AND A.ACNT_YY          = D.ACNT_YY(+)
           and A.ACNT_FG          = D.ACNT_FG(+)
           and A.CYOV_YY          = D.CYOV_YY(+)
           and A.CYOV_FG          = D.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = D.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = D.BIZ_CD(+)
           AND A.ACNT_YY          = F.ACNT_YY(+)
           and A.ACNT_FG          = F.ACNT_FG(+)
           AND A.BUDG_DEPT_CD     = F.BUDG_DEPT_CD(+)
           and A.CYOV_YY          = F.CYOV_YY(+)
           and A.CYOV_FG          = F.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = F.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = F.BIZ_CD(+)
           and A.FORMA_FG         = 'A040400001'
           and A.BAL_FG           = '0'
           and A.SEQ              = 0
           and A.BUDG_FG          = 'A040100000' /*������-0����*/
           and A.BUDG_DEPT_CD     = '0056' /* ����������(����) */
           and A.ACNT_FG          = REC.ACNT_FG
           and A.ACNT_YY          = REC.ACNT_YY
           AND A.BIZ_CD           = REC.BIZ_CD
           AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
           AND A.CYOV_YY          = REC.CYOV_YY
           AND A.CYOV_FG          = REC.CYOV_FG
           AND ROWNUM             = 1
         order by A.ACNT_YY, A.ACNT_FG, A.BUDG_DEPT_CD, A.BIZ_CD
                , A.BUDG_SBJT_CD_SST, A.BUDG_SBJT_CD_SB, A.CYOV_FG, A.CYOV_YY;
--         EXCEPTION
--	        WHEN NO_DATA_FOUND THEN
--	            OUT_RTN := 0;
--	            OUT_MSG := '�������(����) �����Ͱ� �����ϴ�.';

    	
		
--			IF OUT_RTN = 0 THEN
			ELSE 
         /* 10.����ȣ ������ ��������  */				  				             
					SELECT SEQ_BUDG100.NEXTVAL
						INTO V_BUDG_FORMA_NO_AF 
					FROM DUAL;
						
     
     			/* 11.BUDG100 INSERT : ������ ��ȣ�� ���� ��츸  */
						INSERT INTO BUDG100 ( 
						  		  		  		  	BUDG_FORMA_NO     /* ��������ȣ.(Sequence.SEQ_BUDG100) */
						                    , ACNT_YY           /* ȸ�迬�� */
						                    , ACNT_FG           /* ȸ�豸��.[A0601] */
						                    , BUDG_DEPT_CD      /* ����μ��ڵ� */
						                    , BUDG_FG           /* ���걸��.[A0401] */
						                    , SEQ               /* ���� */
						                    , BAL_FG            /* ��������.[1:����,0:����] */
						                    , CYOV_FG           /* �̿�����.[A0403. 0:������,1:���,2:���] */
						                    , CYOV_YY           /* �̿����� */
						                    , BIZ_CD            /* ����ڵ� */
						                    , BUDG_SBJT_CD_SST  /* ��������ڵ�_�� */
						                    , BUDG_SBJT_CD_SECT /* ��������ڵ�_�� */
						                    , BUDG_SBJT_CD_ITEM /* ��������ڵ�_�� */
						                    , BUDG_SBJT_CD_SB   /* ��������ڵ�_���� */
						                    , FORMA_FG          /* ������.[A0404.0:�䱸,1:��,2:����] */
						                    , DMND_AMT          /* �䱸�� */
						                    , FORMA_AMT         /* ���� */
						                    , ABUDG_AMT			    /* �߰�� */
						                    , FORMA_DT          /* ������ */
						                    , ABUDG_YN			    /* �߰濩�� */
						                    , INPT_ID           /* �Է�ID */
						                    , INPT_DTTM         /* �Է��Ͻ� */
						                    , INPT_IP           /* �Է�IP */
						           ) VALUES ( V_BUDG_FORMA_NO_AF
						                    , REC.ACNT_YY                          /* ȸ�迬�� */
						                    , REC.ACNT_FG                          /* ȸ�豸��.[A0601] */
						                    , '0056'						                   /* ����μ��ڵ� ����������(����) */
						                    , 'A040100000'                         /* ���걸��.[A0401] */
						                    , 0                                    /* ���� */
						                    , 0                                    /* ��������.[1:����,0:����] */
						                    , REC.CYOV_FG                          /* �̿�����.[A0403. 0:������,1:���,2:���] - �̿����� �����۾�. �ϴ� �������� 0*/
						                    , REC.CYOV_YY                          /* �̿�����  - �̿����� �����۾�. �ϴ� ��������  ȸ�迬���� ����*/
						                    , REC.BIZ_CD                           /* ����ڵ� */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 2)||'00'   /* ��������ڵ�_�� */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 3)||'0'    /* ��������ڵ�_�� */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 4)         /* ��������ڵ�_��  : ��data ������� ���� ��������� ���ؼ� �־��ش�*/
						                    , REC.BUDG_SBJT_CD_SB                  /* ��������ڵ�_���� */
						                    , 'A040400001'                         /* ������.[A0404.0:�䱸,1:��,2:����] */
						                    , 0                                    /* �䱸�� */
						                    , 0                                    /* ���� */
						                    , 0                     		           /* �߰�� */
						                    , TO_CHAR(SYSDATE, 'YYYYMMDD')         /* ������ */
						                    , NULL     	             						   /* �߰濩�� */
						                    , V_INPT_ID                            /* �Է�ID */
						                    , SYSDATE                              /* �Է��Ͻ� */
						                    , V_INPT_IP                            /* �Է�IP */
						           				);
					       
						END IF;
					END;
					
          /* 12. BUDG310 INSERT(����)*/
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
		                    , FXD_YN		  /* Ȯ������ */
		                    , BUDG_FORMA_NO   /* ��������ȣ */
        		            , INPT_ID         /* �Է�ID */
		                    , INPT_DTTM       /* �Է��Ͻ� */
		                    , INPT_IP         /* �Է�IP */
		           ) VALUES ( V_BUDG_DVRS_NO                           /* ���������ȣ */
        		            , ( SELECT lpad(nvl(max(SRNUM), 0) + 1, 2, 0)
		                          FROM BUDG310
		                         WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO)  /* �Ϸù�ȣ */
        		            , REC.ACNT_YY                              /* ȸ�迬�� */
		                    , REC.ACNT_FG                              /* ȸ�豸��.[A0601] */
		                    , '1'                                      /* ���ⱸ��.[0:����,1:����] */
        		            , '0056'		                               /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] - 0056:����������(����) */
        		            , REC.CYOV_FG                              /* �̿����� */
        		            , REC.CYOV_YY                              /* �̿����� */
		                    , REC.BIZ_CD                               /* ����ڵ� */
		                    , REC.BUDG_SBJT_CD_SB                      /* ��������ڵ�_���� */
        		            , 0                                        /* ���ʿ��� - ������ �����ִ� �뵵 �����ְ� ������ �Ǿ� �״��*/
		                    , REC.BALN * 1000                          /* ����� */
		                    , REC.ADJ_DT                               /* �������� */
		                    , 'Y'                                      /* Ȯ������ */
        			          ,V_BUDG_FORMA_NO_AF		                     /* ��������ȣ */
		                    , V_INPT_ID                                /* �Է�ID */
		                    , SYSDATE                                  /* �Է��Ͻ� */
        		            , V_INPT_IP                                /* �Է�IP */
		           );
			           
         /* 10. BUDG210 INSERT(����)*/
					INSERT INTO BUDG210 ( ACNT_YY         /* ȸ�迬�� */
		                    , ACNT_FG         /* ȸ�豸��.[A0601] */
		                    , QUTE            /* �б� */
		                    , BUDG_DEPT_CD    /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] */
		                    , ADJ_DT          /* �������� */
		                    , CYOV_FG         /* �̿�����.[A0403. 0:������,1:���,2:���] */
		                    , CYOV_YY         /* �̿����� */
		                    , BIZ_CD          /* ����ڵ� */
		                    , BUDG_SBJT_CD_SB /* ��������ڵ�_���� */
		                    , BUDG_CURR_AMT   /* �������� */
		                    , ALD_ASGN_AMT    /* ������� */
		                    , ADJ_AMT         /* ������ */
		                    , ADJ_RESN        /* �������� */
		                    , INPT_ID         /* �Է�ID */
		                    , INPT_DTTM       /* �Է��Ͻ� */
		                    , INPT_IP         /* �Է�IP */
		                    , TRET_FG         /* ó������ */
		                    , BUDG_DVRS_NO
		                    , SRNUM
		                    , SEQ
		           ) VALUES ( REC.ACNT_YY                  /* ȸ�迬�� */
		                    , REC.ACNT_FG                  /* ȸ�豸��.[A0601] */
		                    , REC.QUTE                     /* �б� */
		                    , '0056'                       /* ����μ��ڵ�.[�μ��ڵ�.HURT100.DEPT_CD] - 0056:����������(����) */
		                    , REC.ADJ_DT                   /* �������� */
		                    , REC.CYOV_FG                  /* �̿�����.[A0403. 0:������,1:���,2:���] */
		                    , REC.CYOV_YY                  /* �̿����� */
		                    , REC.BIZ_CD                   /* ����ڵ� */
		                    , REC.BUDG_SBJT_CD_SB          /* ��������ڵ�_���� */
		                    , NVL(V_ORGN_BUDG_FST_AF, 0) + (NVL(REC.BALN, 0) * 1000)  /* ����� */
		                    , NVL(V_ASGN_AMT_ORG_AF, 0)    /* ������� */
		                    , NVL(REC.BALN, 0) * 1000      /* ������ */ 
		                    , V_SR_RESN                    /* �������� */
		                    , V_INPT_ID                    /* �Է�ID */
		                    , SYSDATE                      /* �Է��Ͻ� */
		                    , V_INPT_IP                    /* �Է�IP */
		                    , 'A041400002'                 /* ó������ */
		                    , V_BUDG_DVRS_NO
		                    ,( SELECT lpad(nvl(max(SRNUM), 0), 2, 0)
		                         FROM BUDG310
		                        WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )
		                    ,( SELECT NVL(MAX(SEQ),0) + 1
												     FROM BUDG210
												    WHERE ACNT_YY = REC.ACNT_YY
												      AND ACNT_FG = REC.ACNT_FG
												      AND BUDG_DEPT_CD = '0056'  /* 0056:����������(����)*/
												      AND ADJ_DT = REC.ADJ_DT)
		           );


        END LOOP;
        EXCEPTION
	        WHEN OTHERS THEN
	            OUT_RTN := 0;
	            V_STG_NM := 'V_STG_NM    = '||CHR(39)|| V_STG_NM ||CHR(39)||CHR(13)||CHR(10)||
--	            			'OUT_MSG				   = '||CHR(39)|| OUT_MSG ||CHR(39)||CHR(13)||CHR(10)||
	            			'V_BUDG_DEPT_CD    = '||CHR(39)|| V_BUDG_DEPT_CD ||CHR(39)||CHR(13)||CHR(10)||
	            			'V_BUDG_DEPT_NM    = '||CHR(39)|| V_BUDG_DEPT_NM ||CHR(39)||CHR(13)||CHR(10)||
                    'V_BIZ_CD          = '||CHR(39)|| V_BIZ_CD ||CHR(39)||CHR(13)||CHR(10)||
                    'V_BIZ_NM          = '||CHR(39)|| V_BIZ_NM ||CHR(39)||CHR(13)||CHR(10)||
                    'V_BUDG_SBJT_CD_SB = '||CHR(39)|| V_BUDG_SBJT_CD_SB||CHR(39)||CHR(10)||
                    'V_BUDG_SBJT_NM    = '||CHR(39)|| V_BUDG_SBJT_NM||CHR(39);
	            
	            SP_SSTM056_CREA(V_PGM_ID, V_STG_NM , SQLCODE, SQLERRM, '', '');

	            OUT_MSG := OUT_MSG||CHR(13)||CHR(10)||CHR(13)||CHR(10)||'Ȯ�� �� ��õ� �ϼ���';
	            RETURN;
    END; 


    OUT_RTN := 1;
    OUT_MSG := '���������� ó���Ǿ����ϴ�.';

    RETURN;
END;
/
