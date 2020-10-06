CREATE OR REPLACE PROCEDURE SP_ESIN606_FL_CREA
(	IN_SELECT_YY 			IN VARCHAR2 /* �����⵵ */
,	IN_SELECT_FG 			IN VARCHAR2 /* �������� */
,	IN_COLL_FG 				IN VARCHAR2 /* �������� */
,	IN_APLY_QUAL_FG 		IN VARCHAR2 /* �����ڰ� */
,	IN_DETA_APLY_QUAL_FG 	IN VARCHAR2 /* ���������ڰ� */
,	IN_APLY_CORS_FG 		IN VARCHAR2 /* �������� */
,	IN_APLY_COLG_FG 		IN VARCHAR2 /* �����ܰ����� */
,	IN_APLY_COLL_UNIT_CD 	IN VARCHAR2 /* ������������ */
,	IN_INPT_ID 				IN VARCHAR2 /* �Է��� */
,	IN_INPT_IP 				IN VARCHAR2 /* �Է���IP*/
,	OUT_RTN 				OUT INTEGER
,	OUT_MSG 				OUT VARCHAR2
)
IS
/******************************************************************************
	���α׷���	: SP_ESIN606_FL_CREA
	�������	: ���� ���� ó���� �Ѵ�.
	������	: ESIN606 �հ������� ����
------------------------------------------------------------------------------
	��������     	������		��������
------------------------------------------------------------------------------
	2019.12.27	�ڿ���		���� �ۼ�
******************************************************************************/

V_STG1_SLT_YN               ESIN520.STG1_SLT_YN%TYPE;
V_COUNT                     NUMBER;
V_SELECT_ELEMNT_FG_GUBN     VARCHAR2(200);
V_IMSI                      VARCHAR2(200);
V_IMSI2                     VARCHAR2(200);
V_IMSI3                     VARCHAR2(200);
V_IMSI4                     VARCHAR2(200);
V_QUERY                     VARCHAR2(4000);
V_SPCMAJ_CNT                NUMBER;
V_SCRN_GRP_COLL_CNT         NUMBER;
V_CNT1                      NUMBER; --Ÿ�������ο�
V_CNT2                      NUMBER; --���������ο�

-- ���� �������������� �����´�.
CURSOR CUR_SOR IS
	SELECT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) AS SCRN_GRP_CD
		 , B.SELECT_YY
		 , B.SELECT_FG
		 , B.COLL_FG
		 , B.APLY_QUAL_FG
		 , B.APLY_COLG_FG
		 , B.APLY_CORS_FG
		 , A.ITEM_CD
		 , A.SORT_ORD_FG
		 , A.PREF_RANK
		 , B.STG1_SLT_YN
		 , A.SCRN_STG_FG
	  FROM ESIN523 A    -- �������������ڿ켱����
		 , ESIN520 B    -- ������������
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND B.SELECT_YY = IN_SELECT_YY
	   AND B.SELECT_FG = IN_SELECT_FG
	   AND B.COLL_FG = IN_COLL_FG
	   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND B.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, B.APLY_CORS_FG)
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
	   AND NVL(A.USE_YN, 'N') = 'Y'   --��뿩��
  ORDER BY B.APLY_CORS_FG
		 , NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
		 , A.PREF_RANK
	;

-- ���� ������� ������ ���Ѵ�.  �⵵, ��������, ��������, �����ڰ�, ����, �ܴ��ڵ�, �����׷�
CURSOR CUR_SOR_RANK IS
	SELECT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , RANK() OVER(
                PARTITION BY A.SELECT_YY
                           , A.SELECT_FG
                           , A.COLL_FG
                           , A.APLY_QUAL_FG
                           , A.APLY_CORS_FG
                           , A.APLY_COLG_FG
                           , NVL(D.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
                    ORDER BY B.TT_SCOR_SCOR DESC
                           , C.SMSC_PSN_BASI_RANK1
                           , C.SMSC_PSN_BASI_RANK2
                           , C.SMSC_PSN_BASI_RANK3
                           , C.SMSC_PSN_BASI_RANK4
                           , C.SMSC_PSN_BASI_RANK5
                           , C.SMSC_PSN_BASI_RANK6
                           , C.SMSC_PSN_BASI_RANK7
                           , C.SMSC_PSN_BASI_RANK8
                           , C.SMSC_PSN_BASI_RANK9
                           , C.SMSC_PSN_BASI_RANK10
		   ) AS TT_SCOR_RANK
	  FROM ESIN600 A    -- ����������
		 , ESIN606 B    -- �հ�������
		 , ESIN607 C    -- ������ �켱����
		 , ESIN520 D    -- ������������
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.EXAM_NO = B.EXAM_NO
	   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO
	   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND B.EXAM_NO = C.EXAM_NO
	   AND B.SCRN_STG_FG = C.SCRN_STG_FG
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')	-- �����ܰ� : ����, �ܰ����
	   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')	-- ��ݱ��� : ������ ���
	   AND NVL(B.PREF_SLT_YN, 'N') = 'N'	--�켱����������
	;

-- �����հ� ������� ������ ���Ѵ�.
CURSOR CUR_SOR_RANK_STP IS
	SELECT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , RANK() OVER(
                PARTITION BY A.SELECT_YY
                           , A.SELECT_FG
                           , A.COLL_FG
                           , A.APLY_QUAL_FG
                           , A.APLY_CORS_FG
                           , A.APLY_COLG_FG
                           , NVL(D.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
                    ORDER BY B.TT_SCOR_RANK
		   ) AS TT_SCOR_RANK
	  FROM ESIN600 A    -- ����������
		 , ESIN606 B    -- �հ�������
		 , ESIN607 C    -- ������ �켱����
		 , ESIN520 D    -- ������������
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.EXAM_NO = B.EXAM_NO
	   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND B.EXAM_NO = C.EXAM_NO
	   AND B.SCRN_STG_FG = C.SCRN_STG_FG
	   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')	-- �����ܰ� : ����, �ܰ����
	   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')	-- ��ݱ��� : ������ ���
	   AND NVL(B.PREF_SLT_YN, 'N') = 'N'	-- �켱����������
	   AND B.PASS_DISQ_FG = 'U024300006'	-- �հݺ��հݱ��� : ���հ���
	   AND NVL(D.STP_SLT_YN, 'N') = 'Y' -- ������߿���
       AND NVL(D.PREPR_PASS_RCNT, 0) > 0	-- ����������߽�
	;

-- ������� ���������� ���� �´�.
CURSOR CUR_SOR_COLL_UNIT_NO IS
	SELECT DISTINCT A.COLL_UNIT_NO
	  FROM ESIN520 A    -- ������������
		 , ESIN521 B    -- ������������
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND B.ADPT_STG_FG IN ('U027200002', 'U027200003')    -- ����ܰ豸�� : ����, �ܰ����
	;

-- �����׷��ڵ�, �����ο�, �����հ��ο� ��ȸ
CURSOR CUR_SOR_SCRN_GRP IS
	SELECT A.SELECT_YY
		 , A.SELECT_FG
		 , A.COLL_FG
		 , A.APLY_QUAL_FG
		 , A.APLY_CORS_FG
		 , A.APLY_COLG_FG
		 , NVL(A.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD) AS SCRN_GRP
		 , SUM(NVL(A.COLL_RCNT, 0)) AS COLL_RCNT
		 , SUM(NVL(A.PREPR_PASS_RCNT, 0)) AS PREPR_PASS_RCNT
	  FROM ESIN520 A    -- ������������
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
  GROUP BY A.SELECT_YY
		 , A.SELECT_FG
		 , A.COLL_FG
		 , A.APLY_QUAL_FG
		 , A.APLY_CORS_FG
		 , A.APLY_COLG_FG
		 , NVL(A.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
	;

-- ����, �ܰ�����, �����׷��ڵ� ��ȸ
CURSOR CUR_SOR_SCRN_GRP_CD IS
	SELECT DISTINCT A.APLY_CORS_FG
		 , A.APLY_COLG_FG
		 , NVL(A.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD) AS SCRN_GRP_CD
	  FROM ESIN520 A    -- ������������
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	;

-- �ջ���� ��ȸ
CURSOR COR_SOR_ADUP_DISQ_OBJ_YN IS
    WITH V_ESIN521 AS (
        SELECT A.COLL_UNIT_NO
             , B.SELECT_ELEMNT_FG
             , B.ADPT_STG_FG
          FROM ESIN520 A
             , ESIN521 B
         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
           AND NVL(B.ADUP_DISQ_OBJ_YN, 'N') = 'Y'   -- �ջ��������
           AND A.SELECT_YY = IN_SELECT_YY
           AND A.SELECT_FG = IN_SELECT_FG
           AND A.COLL_FG = IN_COLL_FG
           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
           AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
           AND A.APLY_COLG_FG = IN_APLY_COLG_FG
    ), V_ESIN604 AS (
        SELECT A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.GENRL_SELECT_CHG_YN
             , SUM(A.FL_SCOR) AS FL_SCOR
             , SUM(A.EXCH_SCOR) AS EXCH_SCOR
          FROM ESIN604 A
             , V_ESIN521 B
         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
           AND A.SELECT_ELEMNT_FG = B.SELECT_ELEMNT_FG
           AND A.SCRN_STG_FG = B.ADPT_STG_FG
      GROUP BY A.COLL_UNIT_NO
             , A.EXAM_NO
             , A.GENRL_SELECT_CHG_YN
    )
    SELECT A.COLL_UNIT_NO
         , A.EXAM_NO
         , A.GENRL_SELECT_CHG_YN
         , A.FL_SCOR
         , A.EXCH_SCOR
      FROM V_ESIN604 A
     WHERE A.FL_SCOR < (
                SELECT TRUNC(Z.SELECT_ELEMNT_DISQ_SCOR, 2)
                  FROM ESIN521 Z
                 WHERE Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                   AND Z.SELECT_ELEMNT_FG = 'U027100024'    -- ������ұ��� : �ջ����
           )
    ;
BEGIN
	--������꿩��
	--����⵵ �ڷῩ�� Ȯ��
	SELECT COUNT(*)
	  INTO V_COUNT
	  FROM ESIN606 A    -- �հ�������
         , ESIN520 B    -- ������������
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
	   AND B.SELECT_YY = IN_SELECT_YY
	   AND B.SELECT_FG = IN_SELECT_FG
	   AND B.COLL_FG = IN_COLL_FG
	   AND B.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND B.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND B.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
	;

	-- ���� - �켱�������� 2�ܰ� ���� ������ ���� ���ʿ��� ���� ����
	DELETE
	  FROM ESIN604 A -- ����
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND A.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
	   AND EXISTS (
				SELECT 1
				  FROM ESIN606 X    -- �հ��� ����
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.SCRN_STG_FG = A.SCRN_STG_FG
				   AND X.EXAM_NO = A.EXAM_NO
				   AND NVL(X.PREF_SLT_YN, 'N') = 'Y'    -- �켱���߿���
		   )
	   AND NOT EXISTS (
				SELECT 1
				  FROM ESIN521 X    -- ������������
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.ADPT_STG_FG = 'U027200002' -- �����ܰ� : ����
				   AND X.SELECT_ELEMNT_FG = A.SELECT_ELEMNT_FG
				   AND X.SELECT_ELEMNT_USE_YN = 'Y' -- ������һ�뿩��
				   AND X.PREF_SLT_DISQ_ADPT_YN = 'Y'    -- �켱���߰������뿩��
           )
	;

	-- �հ������� - ����ó���� ���̺� �ʱ�ȭ
	DELETE
	  FROM ESIN606  -- �հ�������
	 WHERE COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND SCRN_STG_FG IN ('U027200002', 'U027200003')  -- �����ܰ� : ����, �ܰ����
	;
    
	DELETE
	  FROM ESIN607  -- ������ �켱����
	 WHERE COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- ������������
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND SCRN_STG_FG IN ('U027200002', 'U027200003')  -- �����ܰ� : ����, �ܰ����
	;
    
    -- �հ��� ����
	INSERT INTO ESIN606 -- �հ��� ����
	(	COLL_UNIT_NO
	,	EXAM_NO
	,	SCRN_STG_FG
	,	GENRL_SELECT_CHG_YN
	,	PREF_SLT_YN
	,	INPT_ID
	,	INPT_DTTM
	,	INPT_IP
	)
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , ADPT_STG_FG
		 , NVL(A.STG2_GENRL_SELECT_CHG_YN, 'N')
		 , C.PREF_SLT_YN
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- ����������(VIEW ������ �Ϲ���ȯ ����)
		 , ESIN521 B    -- ������������
		 , ESIN606 C    -- �հ��� ����
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND A.EXAM_NO = C.EXAM_NO
	   AND C.SCRN_STG_FG = 'U027200001' -- �����ܰ� : 1�ܰ�(1��)
	   AND C.PASS_DISQ_FG = 'U024300005'	-- �հݺ��հݱ��� : �հ���
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200002' -- ����ܰ豸�� : ����
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	 UNION
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG
		 , NVL(A.STG2_GENRL_SELECT_CHG_YN, 'N')
		 , NULL AS PREF_SLT_YN
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- ����������(VIEW ������ �Ϲ���ȯ ����)
		 , ESIN521 B    -- ������������
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200003' -- ����ܰ豸�� : �ܰ����
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	;

	--- 1�ܰ� �հ��ڸ� ������ ó������ ���̺�� �ִ´�.
	INSERT INTO ESIN607 -- ������ �켱����
	(	COLL_UNIT_NO
	,	EXAM_NO
	,	SCRN_STG_FG
	,	INPT_ID
	,	INPT_DTTM
	,	INPT_IP
	)
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- ����������(VIEW ������ �Ϲ���ȯ ����)
		 , ESIN521 B    -- ������������
		 , ESIN606 C    -- �հ��� ����
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO(+)
	   AND A.EXAM_NO = C.EXAM_NO
	   AND C.SCRN_STG_FG = 'U027200001' -- �����ܰ� : ����
	   AND C.PASS_DISQ_FG = 'U024300005'	-- �հݺ��հݱ��� : �հ���
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200002' -- ����ܰ豸�� : ����
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	 UNION
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG
		 , IN_INPT_ID
		 , SYSDATE
		 , IN_INPT_IP
	  FROM V_ESIN600 A  -- ����������(VIEW ������ �Ϲ���ȯ ����)
		 , ESIN521 B    -- ������������
	 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND B.ADPT_STG_FG = 'U027200003' -- ����ܰ豸�� : �ܰ����
	   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
	   AND A.APLY_COLG_FG = IN_APLY_COLG_FG
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	;
    
	-- 2�ܰ� �������(= ���� ����) ����
	DELETE
	  FROM ESIN604 A    -- ����
	 WHERE A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
	   AND A.SELECT_ELEMNT_FG = 'U027100002'    -- ������ұ��� : ��������
	   AND A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- ������������
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	;

	-- 1�ܰ� �հ��ڸ� ������� 2�ܰ� ������ �����Ѵ�.
	INSERT INTO ESIN604 -- ����
	(	COLL_UNIT_NO
	,	EXAM_NO
	,	SCRN_STG_FG
	,	SELECT_ELEMNT_FG
	,	GENRL_SELECT_CHG_YN
	,	FL_SCOR
	,	EXCH_SCOR
	,	INPT_ID
	,	INPT_DTTM
	,	INPT_IP
	)
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG AS SCRN_STG_FG
		 , 'U027100002' AS SELECT_ELEMNT_FG -- ������ұ��� : ��������
		 , A.GENRL_SELECT_CHG_YN
		 , TRUNC(SUM(NVL(A.FL_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS FL_SCOR
		 , TRUNC(SUM(NVL(A.EXCH_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS EXCH_SCOR
		 , IN_INPT_ID AS INPT_ID
		 , SYSDATE AS INPD_DTTM
		 , IN_INPT_IP AS INPT_IP
	  FROM ESIN604 A    -- ����
		 , ESIN521 B    -- ������������
		 , ESIN521 C    -- ������������
	 WHERE A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- ������������
					 , ESIN521 C    -- ������������
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
				   AND C.ADPT_STG_FG = 'U027200002' -- ����ܰ豸�� : ����
				   AND c.SELECT_ELEMNT_FG = 'U027100002' -- ������ұ��� : 2�ܰ� ����
				   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- ������һ�뿩��
		   )
	   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND A.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
	   AND C.SELECT_ELEMNT_USE_YN = 'Y'
	   AND C.SELECT_ELEMNT_ADUP_FG IN ('U027300002')	-- ��������ջ걸�� : ��������
	   AND A.SCRN_STG_FG IN ('U027200001', 'U027200002')	-- �����ܰ� : 1�ܰ�(1��), ����
	   AND B.SELECT_ELEMNT_FG = 'U027100002' -- ������ұ��� : ���� ����
	   AND NVL(B.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
	   AND B.ADPT_STG_FG = 'U027200002'	-- ����ܰ豸�� : ����
	   AND EXISTS (
				SELECT 1
				  FROM ESIN606 B	-- �հ��� ����
				 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
				   AND B.EXAM_NO = A.EXAM_NO
                   AND B.SCRN_STG_FG = 'U027200001' -- �����ܰ� : 1�ܰ�(1��)
				   AND B.PASS_DISQ_FG  = 'U024300005'   -- �հݺ��հݱ��� : �հ�
		   )
	 UNION
	SELECT DISTINCT A.COLL_UNIT_NO
		 , A.EXAM_NO
		 , B.ADPT_STG_FG AS SCRN_STG_FG
		 , 'U027100002' AS SELECT_ELEMNT_FG -- ������ұ��� : ��������
		 , A.GENRL_SELECT_CHG_YN
		 , TRUNC(SUM(NVL(A.FL_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS FL_SCOR
		 , TRUNC(SUM(NVL(A.EXCH_SCOR, 0)) OVER(PARTITION BY A.COLL_UNIT_NO, A.EXAM_NO), 2) AS EXCH_SCOR
		 , IN_INPT_ID AS INPT_ID
		 , SYSDATE AS INPD_DTTM
		 , IN_INPT_IP AS INPT_IP
	  FROM ESIN604 A    -- ����
         , ESIN521 B    -- ������������
         , ESIN521 C    -- ������������
	 WHERE A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- ������������
					 , ESIN521 C    -- ������������
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
				   AND C.ADPT_STG_FG = 'U027200003' -- ����ܰ豸�� : �ܰ����
				   AND C.SELECT_ELEMNT_FG = 'U027100002' -- ������ұ��� : ���� ����
				   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
		   )
	   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
	   AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
	   AND A.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
	   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'
	   AND C.SELECT_ELEMNT_ADUP_FG IN ('U027300002')	-- ��������ջ걸�� : ��������
	   AND A.SCRN_STG_FG = 'U027200003'	-- �����ܰ� : �ܰ� ����
	   AND B.SELECT_ELEMNT_FG = 'U027100002'	-- ������ұ��� : ��������
	   AND B.SELECT_ELEMNT_USE_YN = 'Y'
	   AND B.ADPT_STG_FG = 'U027200003'	--  ����ܰ豸�� : �ܰ����
	;

	-- 2�ܰ� ������ ���������� ����ó��
	UPDATE ESIN604 A    -- ����
	   SET A.FL_DISQ_FG = 'U027700005'  -- ������ݱ��� : ����
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- ������������
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
				   AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
		   )
	   AND EXISTS (
				SELECT 1
				  FROM ESIN521 X    -- ������������
					 , ESIN604 Y    -- ����
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.ADPT_STG_FG IN ('U027200002', 'U027200003')    -- ����ܰ豸�� : ����, �ܰ����
				   AND NVL(X.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- ������һ�뿩��
				   AND X.ADPT_STG_FG = A.SCRN_STG_FG
				   AND NVL(X.SELECT_ELEMNT_DISQ_ADPT_YN, 'N') = 'Y' -- ������Ұ����ݿ�����
				   AND X.SELECT_ELEMNT_FG = A.SELECT_ELEMNT_FG
				   AND X.SELECT_ELEMNT_FG IN ('U027100002', 'U027100023')   -- ������ұ��� : ��������, ��ü����
				   AND X.COLL_UNIT_NO = Y.COLL_UNIT_NO
				   AND X.ADPT_STG_FG = Y.SCRN_STG_FG
				   AND X.SELECT_ELEMNT_FG = Y.SELECT_ELEMNT_FG
				   AND Y.EXAM_NO = A.EXAM_NO
				   AND Y.EXCH_SCOR < X.SELECT_ELEMNT_DISQ_SCOR
		   )
	   AND NOT EXISTS (
				SELECT 1
				  FROM ESIN606 X    -- �հ��� ����
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.EXAM_NO = A.EXAM_NO
				   AND X.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
				   AND NVL(X.PREF_SLT_YN, 'N') = 'Y'    -- �켱���߿���
		   )
	;
    
    -- ���� �ջ���� ����
    DELETE
      FROM ESIN604 A    -- ����
	 WHERE A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
	   AND A.SELECT_ELEMNT_FG = 'U027100024'    -- ������ұ��� : �ջ����
	   AND A.COLL_UNIT_NO IN (
				SELECT B.COLL_UNIT_NO
				  FROM ESIN520 B    -- ������������
				 WHERE B.SELECT_YY = IN_SELECT_YY
				   AND B.SELECT_FG = IN_SELECT_FG
				   AND B.COLL_FG = IN_COLL_FG
				   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
				   AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	;
    
    -- 1�ܰ� �ջ���� ó��
    FOR D1 IN COR_SOR_ADUP_DISQ_OBJ_YN LOOP
        INSERT INTO ESIN604
        (   COLL_UNIT_NO
        ,	EXAM_NO
        ,	SCRN_STG_FG
        ,	SELECT_ELEMNT_FG
        ,   GENRL_SELECT_CHG_YN
        ,	FL_SCOR
        ,	EXCH_SCOR
        ,	FL_DISQ_FG
        ,	INPT_ID
        ,	INPT_DTTM
        ,	INPT_IP
        )
        VALUES
        (   D1.COLL_UNIT_NO
        ,   D1.EXAM_NO
        ,   (
            SELECT MAX(SCRN_STG_FG)
              FROM ESIN604
             WHERE COLL_UNIT_NO = D1.COLL_UNIT_NO
               AND EXAM_NO = D1.EXAM_NO
            )
        ,   'U027100024'
        ,   D1.GENRL_SELECT_CHG_YN
        ,   D1.FL_SCOR
        ,   D1.EXCH_SCOR
        ,   'U027700005'
        ,   IN_INPT_ID
        ,   SYSDATE
        ,   IN_INPT_IP
        )
        ;
    END LOOP;
    
	--������ݹݿ�
	--BSNS011.USR_DEF2(U0271)������ �ݿ�
	FOR C1 IN CUR_SOR_COLL_UNIT_NO LOOP
		MERGE INTO ESIN606 A    -- �հ��� ����
		USING (
			WITH T1 AS (
				SELECT SCRN_STG_FG
					 , B.COLL_UNIT_NO
					 , B.EXAM_NO
					 , D.USR_DEF_2
					 , RANK() OVER(PARTITION BY B.EXAM_NO ORDER BY D.USR_DEF_2) AS RA
					 , B.FL_DISQ_FG
                     , NVL(F.QUAL_LACK_YN, 'N') AS QUAL_LACK_YN
				  FROM ESIN604 B    -- ����
					 , BSNS011 D    -- �����ڵ�
                     , V_ESIN600 F
				 WHERE B.SELECT_ELEMNT_FG = D.CMMN_CD
				   AND B.COLL_UNIT_NO = C1.COLL_UNIT_NO
                   AND B.COLL_UNIT_NO = F.COLL_UNIT_NO
                   AND B.EXAM_NO = F.EXAM_NO
				   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')	-- �����ܰ� : ����, �ܰ����.
				   AND NVL(B.FL_DISQ_FG, 'X') NOT IN ('X', 'U027700006')    -- ������ݱ��� : ���հ�
				   AND D.GRP_CD = 'U0271'
                   AND NVL(D.USE_YN, 'N') = 'Y'
			)
			SELECT B.COLL_UNIT_NO
				 , B.SCRN_STG_FG
				 , B.EXAM_NO
				 , B.FL_DISQ_FG
                 , B.QUAL_LACK_YN
			  FROM ESIN606 A    -- �հ��� ����
				 , T1 B
			 WHERE A.COLL_UNIT_NO = C1.COLL_UNIT_NO
			   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����.
			   AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
			   AND A.EXAM_NO = B.EXAM_NO
			   AND B.RA = 1
		) B	--- ����� ������ ���
		ON (
				A.COLL_UNIT_NO = B.COLL_UNIT_NO
			AND A.EXAM_NO = B.EXAM_NO
			AND A.SCRN_STG_FG = B.SCRN_STG_FG
		)
		WHEN MATCHED THEN
			UPDATE
			   SET A.DISQ_FG = CASE WHEN B.QUAL_LACK_YN = 'Y' THEN 'U027700007' ELSE B.FL_DISQ_FG END
		;
	END LOOP;

	-- �հ��� ���� - ���� (2�ܰ� �հ��ڸ� ������� ó��)
	UPDATE ESIN606 A    -- �հ��� ����
	   SET A.TT_SCOR_SCOR = (
				SELECT NVL(SUM(NVL(B.EXCH_SCOR,0)), 0)
				  FROM ESIN604 B
				 WHERE B.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND B.EXAM_NO = A.EXAM_NO
				   AND (B.SELECT_ELEMNT_FG, B.SCRN_STG_FG) IN (
							SELECT C.SELECT_ELEMNT_FG
								 , C.ADPT_STG_FG
							  FROM ESIN521 C    -- ������������
							 WHERE C.COLL_UNIT_NO = A.COLL_UNIT_NO
							   AND C.SELECT_ELEMNT_ADUP_FG = 'U027300002' -- ��������ջ걸�� : ��������
							   AND NVL(C.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- ������һ�뿩��
					   )
		   )
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- ������������
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
				   AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
--				   AND APLY_COLL_UNIT_CD LIKE IN_APLY_COLL_UNIT_CD||'%'
		   )
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����.
	   AND NVL(A.PREF_SLT_YN, 'N') = 'N'    -- �켱���߿���
	;

	-- ��������� ���� �����ڿ� �ڷ����
	FOR C1 IN CUR_SOR LOOP
		V_QUERY := '';
		V_IMSI := 'SMSC_PSN_BASI_RANK'||C1.PREF_RANK;
		V_IMSI2 := CASE WHEN NVL(V_STG1_SLT_YN, 'N') = 'Y' THEN 'U027200002' ELSE 'U027200003' END;
		V_IMSI3 := CASE WHEN C1.SORT_ORD_FG = 'U027400001' THEN 'DESC' ELSE 'ASC' END;
		V_IMSI4 := '%';
        
        -- �׸��ڵ�
		IF C1.ITEM_CD LIKE 'U0271%' THEN
            -- �׸��ڵ� : �����
			IF C1.ITEM_CD = 'U027100009' THEN
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					SELECT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
						 , B.COLL_UNIT_NO
						 , C.EXAM_NO
						 , C.SCRN_STG_FG
						 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY NVL(C.NEW_TEPS_EXCH_SCOR, 0) '||V_IMSI3||') AS RANKS
					  FROM ESIN604 C
						 , ESIN520 B
					 WHERE NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = :A
					   AND C.COLL_UNIT_NO = B.COLL_UNIT_NO
					   AND B.SELECT_YY = :A
					   AND B.SELECT_FG = :A
					   AND B.COLL_FG = :A
					   AND B.APLY_QUAL_FG = :A
					   AND B.APLY_COLG_FG = :A
					   AND B.APLY_CORS_FG = :A
					   AND EXISTS (
								SELECT 1
								  FROM ESIN521 X
								 WHERE X.COLL_UNIT_NO = B.COLL_UNIT_NO
								   AND X.COLL_UNIT_NO = C.COLL_UNIT_NO
								   AND X.ADPT_STG_FG IN (''U027200001'', ''U027200003'')
								   AND X.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
								   AND X.SELECT_ELEMNT_FG = :A
								   AND ROWNUM = 1
						   )
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG IN (''U027200002'', ''U027200003'')
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_GRP_CD, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG, C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG, C1.ITEM_CD;
			ELSE
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					SELECT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
						 , B.COLL_UNIT_NO
						 , C.EXAM_NO
						 , :A AS SCRN_STG_FG
						 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) 
                                       ORDER BY CASE WHEN NVL(C.EXCH_SCOR, 0) = 0 THEN NVL(C.FL_SCOR, 0) ELSE NVL(C.EXCH_SCOR, 0) END ' || V_IMSI3 || ') AS RANKS
					  FROM ESIN604 C
						 , ESIN520 B
					 WHERE NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = :A
					   AND C.COLL_UNIT_NO = B.COLL_UNIT_NO
					   AND B.SELECT_YY = :A
					   AND B.SELECT_FG = :A
					   AND B.COLL_FG = :A
					   AND B.APLY_QUAL_FG = :A
					   AND B.APLY_COLG_FG = :A
					   AND B.APLY_CORS_FG = :A
					   AND C.SCRN_STG_FG = (
								SELECT MAX(X.ADPT_STG_FG)
								  FROM ESIN521 X
								 WHERE X.COLL_UNIT_NO = B.COLL_UNIT_NO
								   AND X.COLL_UNIT_NO = C.COLL_UNIT_NO
								   AND X.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
								   AND X.SELECT_ELEMNT_FG = :A
						   )
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG = B.SCRN_STG_FG
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

                -- 2020-10-06 �ڿ��� �������ҽ� ȯ�������� ������ null or 0 �� ���� order by ó�� �κ� ���� ����                       
				-- old :		 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY NVL(NVL(C.EXCH_SCOR, 0), NVL(C.FL_SCOR, 0)) '||V_IMSI3||') AS RANKS
				-- new :		 , RANK() OVER(PARTITION BY B.APLY_CORS_FG, NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY case when nvl(c.exch_scor, 0) = 0 then nvl(c.fl_scor, 0) else nvl(c.exch_scor, 0) end '||V_IMSI3||') AS RANKS
                
				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_STG_FG, C1.SCRN_GRP_CD, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG, C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG, C1.ITEM_CD;
			END IF;
		ELSIF C1.ITEM_CD LIKE 'U0281%' THEN
            -- �׸��ڵ� : �������
			IF C1.ITEM_CD = 'U028100001' THEN
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					SELECT C.COLL_UNIT_NO
						 , C.EXAM_NO
						 , :A AS SCRN_STG_FG
						 , RANK() OVER(PARTITION BY NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) ORDER BY REPLACE(C.BIRTH_DT, '-', '') '||V_IMSI3||') AS RANKS
					  FROM V_ESIN600 C
						 , ESIN520 B
					 WHERE C.COLL_UNIT_NO = B.COLL_UNIT_NO
					   AND B.SELECT_YY = :A
					   AND B.SELECT_FG = :A
					   AND B.COLL_FG = :A
					   AND B.APLY_QUAL_FG = :A
					   AND B.APLY_COLG_FG = :A
					   AND B.APLY_CORS_FG = :A
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG = B.SCRN_STG_FG
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_STG_FG, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG,C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG;
            -- �׸��ڵ� : �����ױ������+������
			ELSIF C1.ITEM_CD = 'U028100002' THEN
				V_QUERY := '
				MERGE INTO ESIN607 X
				USING (
					WITH T1 AS (
						SELECT DISTINCT NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) AS SCRN_GRP_CD
							 , B.COLL_UNIT_NO
							 , C.EXAM_NO
							 , :A AS SCRN_STG_FG
							 , SUM(NVL(C.EXCH_SCOR, 0)) OVER(PARTITION BY B.COLL_UNIT_NO, C.EXAM_NO) AS EXCH_SCOR
						  FROM ESIN604 C
							 , ESIN520 B
						 WHERE NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = :A
						   AND C.COLL_UNIT_NO = B.COLL_UNIT_NO
						   AND B.SELECT_YY = :A
						   AND B.SELECT_FG = :A
						   AND B.COLL_FG = :A
						   AND B.APLY_QUAL_FG = :A
						   AND B.APLY_COLG_FG = :A
						   AND B.APLY_CORS_FG = :A
						   AND C.SELECT_ELEMNT_FG IN ('||'''U027100005'', ''U027100007'''||')
						   AND EXISTS (
									SELECT 1
									  FROM ESIN521 X
									 WHERE X.COLL_UNIT_NO = B.COLL_UNIT_NO
									   AND X.COLL_UNIT_NO = C.COLL_UNIT_NO
									   AND X.ADPT_STG_FG = C.SCRN_STG_FG
									   AND X.SELECT_ELEMNT_FG = C.SELECT_ELEMNT_FG
									   AND X.SELECT_ELEMNT_FG IN ('||'''U027100005'', ''U027100007'''||')
									   AND ROWNUM = 1
							   )
					)
					SELECT SCRN_GRP_CD
						 , COLL_UNIT_NO
						 , EXAM_NO
						 , SCRN_STG_FG
						 , EXCH_SCOR
						 , RANK() OVER(ORDER BY EXCH_SCOR '||V_IMSI3||') AS RANKS
					  FROM T1 A
				) B
				ON (
						X.COLL_UNIT_NO = B.COLL_UNIT_NO
					AND X.EXAM_NO = B.EXAM_NO
					AND X.SCRN_STG_FG = B.SCRN_STG_FG
				)
				WHEN MATCHED THEN
					UPDATE
					   SET X.'||V_IMSI|| ' = B.RANKS'
				;

				EXECUTE IMMEDIATE V_QUERY USING C1.SCRN_STG_FG, C1.SCRN_GRP_CD, C1.SELECT_YY, C1.SELECT_FG, C1.COLL_FG, C1.APLY_QUAL_FG, C1.APLY_COLG_FG, C1.APLY_CORS_FG;
			END IF;
		END IF;
	END LOOP;
    
    -- ������/�Ϲ�(�Ϲ���ȯ������) ���� ��� �� �պ�
    IF IN_SELECT_FG = 'U025700002' AND IN_APLY_QUAL_FG = 'U024700001' THEN
        -- Ÿ�������ο� / ���������ο�(�����ο� + �̿��ο� - Ÿ�������ο�)
        SELECT NVL(OTSCH_PASS_RCNT, 0)
             , NVL(COLL_RCNT, 0) + NVL(CYOV_RCNT, 0) - NVL(OTSCH_PASS_RCNT, 0)
          INTO V_CNT1
             , V_CNT2
          FROM ESIN520  -- ������������
         WHERE SELECT_YY = IN_SELECT_YY
           AND SELECT_FG = IN_SELECT_FG
           AND COLL_FG = IN_COLL_FG
           AND APLY_QUAL_FG = 'U024700001'  -- �����ڰ� : �Ϲ�
           AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
           AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
           AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
        ;
        
        FOR CUR IN (
            SELECT RANK() OVER(
                    ORDER BY Z.TT_SCOR_SCOR DESC
                        , X.SMSC_PSN_BASI_RANK1
                        , X.SMSC_PSN_BASI_RANK2
                        , X.SMSC_PSN_BASI_RANK3
                        , X.SMSC_PSN_BASI_RANK4
                        , X.SMSC_PSN_BASI_RANK5
                        , X.SMSC_PSN_BASI_RANK6
                        , X.SMSC_PSN_BASI_RANK7
                        , X.SMSC_PSN_BASI_RANK8
                        , X.SMSC_PSN_BASI_RANK9
                        , X.SMSC_PSN_BASI_RANK10
                   ) AS TT_SCOR_RANK
                 , Z.EXAM_NO
                 , Z.COLL_UNIT_NO
                 , Z.TT_SCOR_SCOR
                 , Z.SCRN_STG_FG
              FROM (
                    SELECT T1.EXAM_NO
                         , T1.TT_SCOR_SCOR
                         , T1.RNK
                         , T1.COLL_UNIT_NO
                         , T1.SCRN_STG_FG
                      FROM (
                            SELECT RANK() OVER(
                                    ORDER BY NVL(B.TT_SCOR_SCOR, 0) DESC
                                           , C.SMSC_PSN_BASI_RANK1
                                           , C.SMSC_PSN_BASI_RANK2
                                           , C.SMSC_PSN_BASI_RANK3
                                           , C.SMSC_PSN_BASI_RANK4
                                           , C.SMSC_PSN_BASI_RANK5
                                           , C.SMSC_PSN_BASI_RANK6
                                           , C.SMSC_PSN_BASI_RANK7
                                           , C.SMSC_PSN_BASI_RANK8
                                           , C.SMSC_PSN_BASI_RANK9
                                           , C.SMSC_PSN_BASI_RANK10
                                   ) AS RNK
                                 , A.COLL_UNIT_NO
                                 , A.EXAM_NO
                                 , NVL(B.TT_SCOR_SCOR, 0) AS TT_SCOR_SCOR
                                 , B.SCRN_STG_FG
                              FROM V_ESIN600 A  -- ������ ����(������ �Ϲ���ȯ ������)
                                 , ESIN606 B    -- �հ��� ����
                                 , ESIN607 C    -- ������ �켱����
                             WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                               AND A.EXAM_NO = B.EXAM_NO
                               AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
                               AND A.EXAM_NO = C.EXAM_NO
                               AND B.SCRN_STG_FG = C.SCRN_STG_FG
                               AND B.SCRN_STG_FG = 'U027200002' -- �����ܰ� : �����ܰ�
                               AND A.SELECT_YY = IN_SELECT_YY
                               AND A.SELECT_FG = IN_SELECT_FG
                               AND A.COLL_FG = IN_COLL_FG
                               AND A.APLY_QUAL_FG = 'U024700001'    -- �����ڰ� : �Ϲ�
                               AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                               AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                               AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                               AND NVL(A.MSCH_OTSCH_YN, 'N') = 'Y'  -- ��������
                               AND EXISTS (
                                        SELECT 1
                                          FROM ESIN606 Z
                                         WHERE Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                                           AND Z.EXAM_NO = A.EXAM_NO
                                           AND Z.SCRN_STG_FG = 'U027200001' -- �����ܰ� : 1�ܰ�(1��)
                                           AND Z.PASS_DISQ_FG = 'U024300005'    -- �պ� : �հ�
                                   )
                           ) T1
                     WHERE T1.RNK <= V_CNT2
                     UNION
                    SELECT T2.EXAM_NO
                         , T2.TT_SCOR_SCOR
                         , T2.RNK
                         , T2.COLL_UNIT_NO
                         , T2.SCRN_STG_FG
                      FROM (
                            SELECT RANK() OVER(
                                    ORDER BY NVL(B.TT_SCOR_SCOR, 0) DESC
                                           , C.SMSC_PSN_BASI_RANK1
                                           , C.SMSC_PSN_BASI_RANK2
                                           , C.SMSC_PSN_BASI_RANK3
                                           , C.SMSC_PSN_BASI_RANK4
                                           , C.SMSC_PSN_BASI_RANK5
                                           , C.SMSC_PSN_BASI_RANK6
                                           , C.SMSC_PSN_BASI_RANK7
                                           , C.SMSC_PSN_BASI_RANK8
                                           , C.SMSC_PSN_BASI_RANK9
                                           , C.SMSC_PSN_BASI_RANK10
                                   ) AS RNK
                                 , A.COLL_UNIT_NO
                                 , A.EXAM_NO
                                 , NVL(B.TT_SCOR_SCOR, 0) AS TT_SCOR_SCOR
                                 , B.SCRN_STG_FG
                              FROM V_ESIN600 A  -- ������ ����(������ �Ϲ���ȯ ������)
                                 , ESIN606 B    -- �հ��� ����
                                 , ESIN607 C    -- ������ �켱����
                             WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                               AND A.EXAM_NO = B.EXAM_NO
                               AND A.COLL_UNIT_NO = C.COLL_UNIT_NO
                               AND A.EXAM_NO = C.EXAM_NO
                               AND B.SCRN_STG_FG = C.SCRN_STG_FG
                               AND B.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
                               AND A.SELECT_YY = IN_SELECT_YY
                               AND A.SELECT_FG = IN_SELECT_FG
                               AND A.COLL_FG = IN_COLL_FG
                               AND A.APLY_QUAL_FG = 'U024700001'    -- �����ڰ� : �Ϲ�
                               AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                               AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                               AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                               AND NVL(A.MSCH_OTSCH_YN, 'N') <> 'Y' -- Ÿ��
                               AND EXISTS (
                                        SELECT 1
                                          FROM ESIN606 Z
                                         WHERE Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                                           AND Z.EXAM_NO = A.EXAM_NO
                                           AND Z.SCRN_STG_FG = 'U027200001' -- �����ܰ� : 1�ܰ�(1��)
                                           AND Z.PASS_DISQ_FG = 'U024300005'    -- �պ� : �հ�
                                   )
                           ) T2
                     WHERE T2.RNK <= V_CNT1
                   ) Z
                 , ESIN607 X    -- ������ �켱����
             WHERE Z.COLL_UNIT_NO = X.COLL_UNIT_NO
               AND Z.EXAM_NO = X.EXAM_NO
               AND Z.SCRN_STG_FG = X.SCRN_STG_FG
		) LOOP
            UPDATE ESIN606 X
               SET X.TT_SCOR_RANK = CUR.TT_SCOR_RANK
                 , X.PASS_DISQ_FG = 'U024300005'    -- �հݺ��հݱ���  : �հ�
                 , X.PASS_SCRN_FG = 'U028500001'    -- �հݻ������� : ����
             WHERE X.COLL_UNIT_NO = CUR.COLL_UNIT_NO
               AND X.EXAM_NO = CUR.EXAM_NO
               AND X.SCRN_STG_FG = CUR.SCRN_STG_FG
            ;
        END LOOP;
        
        -- ���հ��� ó��
        FOR CUR1 IN (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SCRN_STG_FG
              FROM ESIN606 A    -- �հ��� ����
                 , V_ESIN600 B  -- ������ ����(������ �Ϲ���ȯ ������)
             WHERE A.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
               AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND A.EXAM_NO = B.EXAM_NO
               AND B.SELECT_YY = IN_SELECT_YY
               AND B.SELECT_FG = IN_SELECT_FG
               AND B.COLL_FG = IN_COLL_FG
               AND B.APLY_QUAL_FG = 'U024700001'    -- �����ڰ� : �Ϲ�
               AND B.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
               AND B.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
               AND B.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
               AND A.PASS_DISQ_FG IS NULL
        )
        LOOP
            UPDATE ESIN606  -- �հ��� ����
               SET PASS_DISQ_FG = 'U024300006'  -- �հݺ��հݱ���  : ���հ�
             WHERE COLL_UNIT_NO = CUR1.COLL_UNIT_NO
               AND EXAM_NO = CUR1.EXAM_NO
               AND SCRN_STG_FG = CUR1.SCRN_STG_FG
        ;
        END LOOP;
        
        --�����հ�
        FOR C1 IN CUR_SOR_SCRN_GRP LOOP
            MERGE INTO ESIN606 T1   -- �հ��� ����
            USING (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SCRN_STG_FG
                 , RANK() OVER(
                        PARTITION BY B.SELECT_YY
                                   , B.SELECT_FG
                                   , B.COLL_FG
                                   , B.APLY_QUAL_FG
                                   , B.APLY_CORS_FG
                                   , B.APLY_COLG_FG
                                   , NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
                            ORDER BY NVL(A.TT_SCOR_SCOR, 0) DESC
                   ) AS TT_SCOR_RANK
              FROM ESIN606 A    -- �հ��� ����
                 , ESIN520 B    -- ������������
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B
                         WHERE B.SELECT_YY = C1.SELECT_YY
                           AND B.SELECT_FG = C1.SELECT_FG
                           AND B.COLL_FG = C1.COLL_FG
                           AND B.APLY_QUAL_FG = C1.APLY_QUAL_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND B.APLY_COLG_FG = C1.APLY_COLG_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP
                   )
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
               AND A.PASS_DISQ_FG = 'U024300006'    -- �հݺ��հݱ��� : ���հ�
               AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND NVL(B.STP_SLT_YN, 'N') = 'Y' -- ������߿���
            ) T2
            ON (
                    T1.COLL_UNIT_NO = T2.COLL_UNIT_NO
                AND T1.EXAM_NO = T2.EXAM_NO
                AND T1.SCRN_STG_FG = T2.SCRN_STG_FG
                AND T2.TT_SCOR_RANK <= C1.PREPR_PASS_RCNT
            )
            WHEN MATCHED THEN
                UPDATE
                   SET T1.PREPR_PASS_RCPN_YN = 'Y'
                     , T1.PREPR_PASS_RANK = T2.TT_SCOR_RANK
                     , T1.MOD_ID = IN_INPT_ID
                     , T1.MOD_DTTM = SYSDATE
            ;
        END LOOP;
    -- ������ �Ϲ��� ���� �� ������ ��������
    ELSE
        -- �հ��� ���� - ���� ���
        FOR C1 IN CUR_SOR_SCRN_GRP_CD LOOP
            MERGE INTO ESIN606 X    -- �հ��� ����
            USING (
                SELECT A.COLL_UNIT_NO
                     , B.SCRN_STG_FG
                     , A.EXAM_NO
                     , RANK() OVER(
                            PARTITION BY A.SELECT_YY
                                       , A.SELECT_FG
                                       , A.COLL_FG
                                       , A.APLY_QUAL_FG
                                       , A.APLY_CORS_FG
                                       , A.APLY_COLG_FG
                                       , NVL(D.SCRN_GRP_CD, A.APLY_COLL_UNIT_CD)
                                ORDER BY B.TT_SCOR_SCOR DESC
                                       , C.SMSC_PSN_BASI_RANK1
                                       , C.SMSC_PSN_BASI_RANK2
                                       , C.SMSC_PSN_BASI_RANK3
                                       , C.SMSC_PSN_BASI_RANK4
                                       , C.SMSC_PSN_BASI_RANK5
                                       , C.SMSC_PSN_BASI_RANK6
                                       , C.SMSC_PSN_BASI_RANK7
                                       , C.SMSC_PSN_BASI_RANK8
                                       , C.SMSC_PSN_BASI_RANK9
                                       , C.SMSC_PSN_BASI_RANK10
                       ) AS TT_SCOR_RANK
                  FROM V_ESIN600 A  -- ������ ����(Ư���� �Ϲ���ȯ��� ����)
                     , ESIN606 B    -- �հ��� ����
                     , ESIN607 C    -- ������ �켱����
                     , ESIN520 D    -- ������������
                 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND A.EXAM_NO = B.EXAM_NO
                   AND A.COLL_UNIT_NO = D.COLL_UNIT_NO
                   AND B.COLL_UNIT_NO = C.COLL_UNIT_NO
                   AND B.EXAM_NO = C.EXAM_NO
                   AND B.SCRN_STG_FG = C.SCRN_STG_FG
                   AND A.SELECT_YY = IN_SELECT_YY
                   AND A.SELECT_FG = IN_SELECT_FG
                   AND A.COLL_FG = IN_COLL_FG
                   AND A.APLY_CORS_FG = C1.APLY_CORS_FG
                   AND A.APLY_COLG_FG = C1.APLY_COLG_FG
                   AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
                   AND NVL(B.PREF_SLT_YN, 'N') = 'N'
                   AND B.SCRN_STG_FG  IN ('U027200002', 'U027200003') -- �����ܰ� : ����,�ܰ����
                   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')   -- ��ݱ��� : ����
            ) B
            ON (
                    X.COLL_UNIT_NO = B.COLL_UNIT_NO
                AND X.EXAM_NO = B.EXAM_NO
                AND X.SCRN_STG_FG = B.SCRN_STG_FG
            )
            WHEN MATCHED THEN
                UPDATE
                   SET X.TT_SCOR_RANK = B.TT_SCOR_RANK
            ;
        END LOOP;
    
        --�պ�ó��
        --��ݻ��� ������ ���հ�
        FOR C1 IN CUR_SOR_SCRN_GRP_CD LOOP
            SELECT COUNT(1)
              INTO V_SPCMAJ_CNT
              FROM ESIN606 A    -- �հ��� ����
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B    -- ������������
                         WHERE B.SELECT_YY = IN_SELECT_YY
                           AND B.SELECT_FG = IN_SELECT_FG
                           AND B.COLL_FG = IN_COLL_FG
                           AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND B.APLY_COLG_FG = IN_APLY_COLG_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
                   )
               AND NVL(A.PREF_SLT_YN, 'N') = 'Y'    -- �켱���߿���
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
            ;
    
            SELECT SUM(NVL(B.COLL_RCNT, 0) + NVL(B.CYOV_RCNT, 0))
              INTO V_SCRN_GRP_COLL_CNT
              FROM ESIN520 B    -- ������������
             WHERE B.SELECT_YY = IN_SELECT_YY
               AND B.SELECT_FG = IN_SELECT_FG
               AND B.COLL_FG = IN_COLL_FG
               AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
               AND B.APLY_COLG_FG = IN_APLY_COLG_FG
               AND B.APLY_CORS_FG = C1.APLY_CORS_FG
               AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
            ;
    
            MERGE INTO ESIN606 A    -- �հ��� ����
            USING (
                SELECT COLL_UNIT_NO
                     , EXAM_NO
                     , SCRN_STG_FG
                     , RANK1
                  FROM (
                    SELECT COLL_UNIT_NO
                         , EXAM_NO
                         , SCRN_STG_FG
                         , RANK() OVER(ORDER BY TT_SCOR_RANK) AS RANK1
                      FROM ESIN606 A    -- �հ��� ����
                     WHERE A.COLL_UNIT_NO IN (
                                SELECT B.COLL_UNIT_NO
                                  FROM ESIN520 B
                                 WHERE B.SELECT_YY = IN_SELECT_YY
                                   AND B.SELECT_FG = IN_SELECT_FG
                                   AND B.COLL_FG = IN_COLL_FG
                                   AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
                                   AND B.APLY_COLG_FG = IN_APLY_COLG_FG
                                   AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                                   AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
                           )
                       AND A.PREF_SLT_YN IS NULL
                       AND A.SCRN_STG_FG  IN ('U027200002', 'U027200003')   -- �����ܰ� : ����, �ܰ����
                       AND NVL(A.DISQ_FG, 'X') IN ('X', 'U027700006')   -- ��ݱ��� : ����
                       )
                WHERE RANK1 <= (V_SCRN_GRP_COLL_CNT - V_SPCMAJ_CNT)   --- 1�ܰ� �����ο� - �켱���� �հ��� �ο�
            ) B
            ON (
                    A.COLL_UNIT_NO = B.COLL_UNIT_NO
                AND A.EXAM_NO = B.EXAM_NO
                AND A.SCRN_STG_FG = B.SCRN_STG_FG
            )
            WHEN MATCHED THEN
                UPDATE
                   SET A.PASS_DISQ_FG = 'U024300005'    -- �հݺ��հݱ��� : �հ�
                     , A.PASS_SCRN_FG = 'U028500001'    -- �հݻ������� : ����
            ;
    
            UPDATE ESIN606 A    -- �հ��� ����
               SET A.PASS_DISQ_FG = 'U024300006'    -- �հݺ��հݱ��� : ���հ�
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B    -- ������������
                         WHERE B.SELECT_YY = IN_SELECT_YY
                           AND B.SELECT_FG = IN_SELECT_FG
                           AND B.COLL_FG = IN_COLL_FG
                           AND B.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND B.APLY_COLG_FG = IN_APLY_COLG_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP_CD
                   )
               AND A.PASS_DISQ_FG IS NULL
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
               AND NVL(A.PREF_SLT_YN, 'N') = 'N'    -- �켱���߿���
            ;
        END LOOP;
    
        --�����հ� ���� ���
        FOR C1 IN CUR_SOR_SCRN_GRP LOOP
            MERGE INTO ESIN606 T1   -- �հ��� ����
            USING (
            SELECT A.COLL_UNIT_NO
                 , A.EXAM_NO
                 , A.SCRN_STG_FG
                 , RANK() OVER(
                        PARTITION BY B.SELECT_YY
                                   , B.SELECT_FG
                                   , B.COLL_FG
                                   , B.APLY_QUAL_FG
                                   , B.APLY_CORS_FG
                                   , B.APLY_COLG_FG
                                   , NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD)
                            ORDER BY A.TT_SCOR_RANK
                   ) AS TT_SCOR_RANK
              FROM ESIN606 A    -- �հ��� ����
                 , ESIN520 B    -- ������������
             WHERE A.COLL_UNIT_NO IN (
                        SELECT B.COLL_UNIT_NO
                          FROM ESIN520 B    -- ������������
                         WHERE B.SELECT_YY = C1.SELECT_YY
                           AND B.SELECT_FG = C1.SELECT_FG
                           AND B.COLL_FG = C1.COLL_FG
                           AND B.APLY_QUAL_FG = C1.APLY_QUAL_FG
                           AND B.APLY_CORS_FG = C1.APLY_CORS_FG
                           AND B.APLY_COLG_FG = C1.APLY_COLG_FG
                           AND NVL(B.SCRN_GRP_CD, B.APLY_COLL_UNIT_CD) = C1.SCRN_GRP
                   )
               AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
               AND A.PASS_DISQ_FG = 'U024300006'    -- �հݺ��հݱ��� : ���հ�
               AND NVL(A.PREF_SLT_YN, 'N') = 'N'    -- �켱���߿���
               AND NVL(A.DISQ_FG, 'X') IN ('X', 'U027700006')	-- ��ݱ��� : ����
               AND A.COLL_UNIT_NO = B.COLL_UNIT_NO
               AND NVL(B.STP_SLT_YN, 'N') = 'Y' -- ������߿���
            ) T2
            ON (
                    T1.COLL_UNIT_NO = T2.COLL_UNIT_NO
                AND T1.EXAM_NO = T2.EXAM_NO
                AND T1.SCRN_STG_FG = T2.SCRN_STG_FG
                AND T2.TT_SCOR_RANK <= C1.PREPR_PASS_RCNT
            )
            WHEN MATCHED THEN
                UPDATE
                   SET T1.PREPR_PASS_RCPN_YN = 'Y'
                     , T1.PREPR_PASS_RANK = T2.TT_SCOR_RANK
                     , T1.MOD_ID = IN_INPT_ID
                     , T1.MOD_DTTM = SYSDATE
            ;
        END LOOP;
    END IF;
    
	--������������ο���, �����հ��ο���, �����հ��ο���, ������������ο��� �ʱ�ȭ
	UPDATE ESIN520 A    -- ������������
	   SET A.FL_SCRN_OBJ_RCNT = NULL
	     , A.FL_PASS_RCNT = NULL
         , A.VACANT_PASS_RCNT = NULL
         , A.VACANT_SCRN_OBJ_RCNT = NULL
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
	;

	--������������ο���, �����հ��ο��� �ݿ�
	UPDATE ESIN520 A    -- ������������
	   SET A.FL_SCRN_OBJ_RCNT = (
				SELECT COUNT(*)
				  FROM ESIN606 B    -- �հ��� ����
				 WHERE B.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND B.DISQ_FG IS NULL
				   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
		   )
		 , A.FL_PASS_RCNT = (
				SELECT COUNT(*)
				  FROM ESIN606 B    -- �հ��� ����
				 WHERE B.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND NVL(B.DISQ_FG, 'X') IN ('X', 'U027700006')	-- ��ݱ��� : ����
				   AND B.PASS_DISQ_FG = 'U024300005'    -- �հݺ��հݱ��� : �հ�
				   AND B.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
		   )
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
	;

	-- �հ�����, ���հ����� , �������� �ݿ�
	UPDATE ESIN606 A    -- �հ��� ����
	   SET A.PASS_DT = CASE WHEN PASS_DISQ_FG = 'U024300005' THEN TO_CHAR(SYSDATE, 'YYYYMMDD') END  -- �հݺ��հݱ��� : �հ�
		 , A.DISQ_DT = CASE WHEN PASS_DISQ_FG = 'U024300006' THEN TO_CHAR(SYSDATE, 'YYYYMMDD') END  -- �հݺ��հݱ��� : ���հ�
		 , A.SCRN_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
				   AND DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
				   AND APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
--				   AND APLY_COLL_UNIT_CD LIKE IN_APLY_COLL_UNIT_CD||'%'
		   )
	   AND A.SCRN_STG_FG IN ('U027200002', 'U027200003')    -- �����ܰ� : ����, �ܰ����
	   AND NVL(A.PREF_SLT_YN, 'N') = 'Y'    -- �켱���߿���
	;

	--�켱���� ���հ�ó�� (�켱���߽� ���� ó��)
	UPDATE ESIN606 A    -- �հ��� ����
	   SET A.PASS_DISQ_FG = 'U024300006'    -- �հݺ��հݱ��� : ���հ�
		 , A.DISQ_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
		 , A.SCRN_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
         , A.PREF_SLT_YN = 'N'  -- �켱���߿���
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- ������������
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND NVL(A.PREF_SLT_YN, 'N') = 'Y'
	   AND EXISTS (
				SELECT 1
				  FROM ESIN604 X    -- ����
					 , ESIN521 B    -- ������������
				 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
				   AND X.EXAM_NO = A.EXAM_NO
				   AND X.COLL_UNIT_NO = B.COLL_UNIT_NO
				   AND X.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
				   AND X.SELECT_ELEMNT_FG = B.SELECT_ELEMNT_FG
				   AND X.GENRL_SELECT_CHG_YN = A.GENRL_SELECT_CHG_YN
				   AND NVL(X.FL_DISQ_FG, 'X') NOT IN ('X', 'U027700006')    -- ��ݱ��� : ����
				   AND NVL(B.PREF_SLT_DISQ_ADPT_YN, 'N') = 'Y'  -- �켱�����ջ꿩��
		   )
	;

	--�켱���� �հ�ó�� (���� ���� �켱 ���� �հ�ó��)
	UPDATE ESIN606 A    -- �հ��� ����
	   SET A.PASS_DISQ_FG = 'U024300005'    -- �հݺ��հݱ��� : �հ�
		 , A.PASS_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
		 , A.SCRN_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
	 WHERE A.COLL_UNIT_NO IN (
				SELECT COLL_UNIT_NO
				  FROM ESIN520  -- ������������
				 WHERE SELECT_YY = IN_SELECT_YY
				   AND SELECT_FG = IN_SELECT_FG
				   AND COLL_FG = IN_COLL_FG
				   AND APLY_QUAL_FG = IN_APLY_QUAL_FG
				   AND APLY_COLG_FG = IN_APLY_COLG_FG
				   AND APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
		   )
	   AND A.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
	   AND NVL(A.PASS_DISQ_FG, 'X') IN ('X', 'U024300005')  -- �հݺ��հݱ��� : �հ�
	   AND NVL(A.PREF_SLT_YN, 'N') = 'Y'
	;
    
    -- �켱�����հ��ο���, �����հ��ο���(�����հ��ο��� + �켱�����հ��ο���) �ݿ�
    UPDATE ESIN520 A    -- ������������
       SET A.PREF_SLT_PASS_RCNT = (
                SELECT COUNT(*)
                  FROM ESIN606 B    -- �հ��� ����
                 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND NVL(B.PASS_DISQ_FG, 'X') IN ('X', 'U024300005')  -- �հݺ��հݱ��� : �հ�
                   AND NVL(B.PREF_SLT_YN, 'N') = 'Y'    -- �켱���߿���
                   AND B.SCRN_STG_FG = 'U027200001' -- �����ܰ� : 1�ܰ�(1��)
           )
         , A.FL_PASS_RCNT = A.FL_PASS_RCNT + (
                SELECT COUNT(*)
                  FROM ESIN606 B    -- �հ��� ����
                 WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                   AND NVL(B.PASS_DISQ_FG, 'X') IN ('X', 'U024300005')  -- �հݺ��հݱ��� : �հ�
                   AND NVL(B.PREF_SLT_YN, 'N') = 'Y'    -- �켱���߿���
                   AND B.SCRN_STG_FG = 'U027200001' -- �����ܰ� : 1�ܰ�(1��)
           )
	 WHERE A.SELECT_YY = IN_SELECT_YY
	   AND A.SELECT_FG = IN_SELECT_FG
	   AND A.COLL_FG = IN_COLL_FG
	   AND A.APLY_QUAL_FG LIKE IN_APLY_QUAL_FG||'%'
	   AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
	   AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
	   AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
    ;
    
	-- �����������п�
    IF IN_SELECT_FG = 'U025700002' THEN
        -- 1�ܰ��Ϲ�������ȯ����, 2�ܰ��Ϲ�������ȯ���� �ʱ�ȭ
        UPDATE ESIN600 A    -- ������ ����
           SET A.STG1_GENRL_SELECT_CHG_YN = NULL
             , A.STG2_GENRL_SELECT_CHG_YN = NULL
         WHERE A.SELECT_YY = IN_SELECT_YY
           AND A.SELECT_FG = IN_SELECT_FG
           AND A.COLL_FG = IN_COLL_FG
           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG  -- Ư��
           AND A.APLY_COLG_FG = IN_APLY_COLG_FG
        ;
        
        -- �����ڰ� : Ư��
        IF IN_APLY_QUAL_FG = 'U024700002' THEN
             -- T1 : Ư����ȯ ��������
            -- T2 : �Ϲ���ȯ ��������
            -- T3 : Ư��������� ��������
            -- T4 : �Ϲ���ȯ ���� ����(20200204011502930931) SELECT_ELEMNT_DISQ_SCOR : 387
            -- T5 : ȯ��ǥ ���� ��������
            MERGE INTO ESIN600 A    -- ������ ����
            USING (
                WITH T1 AS (
                    SELECT COLL_UNIT_NO
                         , SELECT_YY
                         , SELECT_FG
                         , COLL_FG
                         , APLY_QUAL_FG
                         , APLY_CORS_FG
                         , APLY_COLG_FG
                         , APLY_COLL_UNIT_CD
                      FROM ESIN520  -- ������������
                     WHERE SELECT_YY = IN_SELECT_YY
                       AND SELECT_FG = IN_SELECT_FG
                       AND COLL_FG = IN_COLL_FG
                       AND APLY_QUAL_FG = IN_APLY_QUAL_FG
                       AND APLY_COLG_FG = IN_APLY_COLG_FG
                ), T2 AS (
                    SELECT COLL_UNIT_NO
                         , SELECT_YY
                         , SELECT_FG
                         , COLL_FG
                         , APLY_QUAL_FG
                         , APLY_CORS_FG
                         , APLY_COLG_FG
                         , APLY_COLL_UNIT_CD
                      FROM ESIN520  -- ������������
                     WHERE SELECT_YY = IN_SELECT_YY
                       AND SELECT_FG = IN_SELECT_FG
                       AND COLL_FG = IN_COLL_FG
                       AND APLY_QUAL_FG = 'U024700001'  -- �����ڰ� : �Ϲ�
                       AND APLY_COLG_FG = IN_APLY_COLG_FG
                ), T3 AS (
                    SELECT X.COLL_UNIT_NO
                         , X.EXAM_NO
                         , X.ENTR_FRN_LANG_MRKS_SEQ
                         , X.FRN_LANG_VLD_EXAM_FG
                         , X.VLD_EXAM_PERF_DT
                         , X.VLD_EXAM_ACQ_SCOR
                      FROM ESIN603 X    -- �ܱ��� ����
                         , T1 A
                     WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
                       AND X.FRN_LANG_VLD_EXAM_FG IN (
                                SELECT CMMN_CD
                                  FROM BSNS011
                                 WHERE GRP_CD = 'U0278'
                                   AND UP_CD = '01'
                                   AND NVL(USE_YN, 'N') = 'Y'
                           )
                       AND NVL(X.FL_ADPT_YN, 'N') = 'Y' -- �����ݿ�����
                       AND EXISTS (
                                SELECT 1
                                  FROM ESIN606 B    -- �հ��� ����
                                 WHERE B.COLL_UNIT_NO = X.COLL_UNIT_NO
                                   AND B.EXAM_NO = X.EXAM_NO
                                   AND B.PASS_DISQ_FG = 'U024300006'    -- �հݺ��հݱ��� : ���հ�
                                   AND ROWNUM = 1
                           )
                       AND NOT EXISTS (
                                --- ������ ����̿��� ���� ������
                                SELECT 1
                                  FROM ESIN604 B    -- ����
                                 WHERE B.COLL_UNIT_NO = X.COLL_UNIT_NO
                                   AND B.EXAM_NO = X.EXAM_NO
                                   AND NVL(B.FL_DISQ_FG, 'X') NOT IN ('X', 'U027700006')    -- ������ݱ��� : ����
                           )
                ), T4 AS (
                    SELECT A.SELECT_ELEMNT_DISQ_SCOR
                      FROM ESIN521 A    -- ������������
                         , T2 B
                     WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                       AND A.SELECT_ELEMNT_FG = 'U027100009'    -- ������ұ��� : �����
                       AND NVL(A.SELECT_ELEMNT_USE_YN, 'N') = 'Y'   -- ������һ�뿩��
                ), T5 AS (
                    SELECT A.MRKS_MOD_FG
                         , MIN(A.TO_VAL) VAL
                      FROM ESIN540 A
                         , T2 B
                         , T4 C
                     WHERE A.SELECT_YY = IN_SELECT_YY
                       AND A.SELECT_FG = B.SELECT_FG
                       AND A.COLL_FG = B.COLL_FG
                       AND B.APLY_QUAL_FG LIKE A.APLY_QUAL_FG||'%'
                       AND B.APLY_COLG_FG LIKE A.APLY_COLG_FG||'%'
                       AND B.APLY_CORS_FG LIKE A.APLY_CORS_FG||'%'
                       AND B.APLY_COLL_UNIT_CD LIKE A.APLY_CORS_FG||'%'
                       AND A.MRKS_MOD_CHART_FG = 'U027500001'   -- ������ȯǥ���� : ����
                       AND C.SELECT_ELEMNT_DISQ_SCOR BETWEEN A.NEW_TEPS_FR_SCOR AND A.NEW_TEPS_TO_SCOR
                       AND A.MRKS_MOD_FG NOT IN ('U027800001', 'U027800002')    -- ������ȯ���� : TEPS, OLD_TEPS
                  GROUP BY A.MRKS_MOD_FG
                         , A.TO_VAL
                 UNION ALL
                    SELECT 'U027800001' AS MRKS_MOD_FG  -- TEPS
                         , TO_CHAR(C.SELECT_ELEMNT_DISQ_SCOR) VAL
                      FROM T4 C
                 UNION ALL
                    SELECT 'U027800002' AS MRKS_MOD_FG  -- OLD_TEPS
                         , MAX(A.TO_VAL) AS VAL
                      FROM ESIN542 A    -- ���ܽ����ܽ� ȯ��ǥ
                         , T4 C
                     WHERE A.EXCH_SCOR = C.SELECT_ELEMNT_DISQ_SCOR
                  GROUP BY 'U027800002'
                         , A.TO_VAL
                )
                SELECT COLL_UNIT_NO
                     , EXAM_NO
                     , ENTR_FRN_LANG_MRKS_SEQ
                     , FRN_LANG_VLD_EXAM_FG
                     , VLD_EXAM_PERF_DT
                     , VLD_EXAM_ACQ_SCOR
                     , MRKS_MOD_FG
                     , VAL
                  FROM T3 A
                     , T5 B
                 WHERE A.FRN_LANG_VLD_EXAM_FG = B.MRKS_MOD_FG
                   AND A.VLD_EXAM_ACQ_SCOR > VAL
            ) B
            ON (
                    A.COLL_UNIT_NO = B.COLL_UNIT_NO
                AND A.EXAM_NO = B.EXAM_NO
            )
            WHEN MATCHED THEN
                UPDATE
                   SET A.STG1_GENRL_SELECT_CHG_YN = 'Y'
                     , A.STG2_GENRL_SELECT_CHG_YN = 'Y'
                     , A.MOD_ID = IN_INPT_ID
                     , A.MOD_DTTM = SYSDATE
            ;
        
            -- �������� Ÿ�������ο�, ����л��հ��ο�
            UPDATE ESIN520 Z    -- ������������
               SET Z.OTSCH_PASS_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A    -- ������ ����
                             , ESIN606 B    -- �հ��� ����
                         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                           AND A.EXAM_NO = B.EXAM_NO
                           AND A.SELECT_YY = IN_SELECT_YY
                           AND A.SELECT_FG = IN_SELECT_FG
                           AND A.COLL_FG = IN_COLL_FG
                           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                           AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                           AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                           AND B.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
                           AND B.PASS_SCRN_FG = 'U028500001'    -- �հݻ������� : ����
                           AND B.PASS_DISQ_FG = 'U024300005'    -- �հݺ��հݱ��� : �հ�
                           AND NVL(A.MSCH_OTSCH_YN, 'N') <> 'Y' -- ����Ÿ������
                   )
                 , Z.NON_LAW_BDEGR_PASS_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A    -- ������ ����
                             , ESIN606 B    -- �հ��� ����
                         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                           AND A.EXAM_NO = B.EXAM_NO
                           AND A.SELECT_YY = IN_SELECT_YY
                           AND A.SELECT_FG = IN_SELECT_FG
                           AND A.COLL_FG = IN_COLL_FG
                           AND A.APLY_QUAL_FG = IN_APLY_QUAL_FG
                           AND A.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
                           AND A.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
                           AND A.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
                           AND B.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
                           AND B.PASS_SCRN_FG = 'U028500001'    -- �հݻ������� : ����
                           AND B.PASS_DISQ_FG = 'U024300005'    -- �հݺ��հݱ��� : �հ�
                           AND NVL(A.JURIS_YN, 'N') <> 'Y'  -- ���п���
                   )
                 , GENRL_CHG_OBJ_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A
                         WHERE NVL(A.STG1_GENRL_SELECT_CHG_YN, 'N') = 'Y'
                           AND A.SELECT_YY = Z.SELECT_YY
                           AND A.SELECT_FG = Z.SELECT_FG
                           AND A.COLL_FG = Z.COLL_FG
                           AND A.APLY_QUAL_FG = Z.APLY_QUAL_FG
                   )
             WHERE Z.SELECT_YY = IN_SELECT_YY
               AND Z.SELECT_FG = IN_SELECT_FG
               AND Z.COLL_FG = IN_COLL_FG
               AND Z.APLY_QUAL_FG = IN_APLY_QUAL_FG
               AND Z.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
               AND Z.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
               AND Z.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
               AND NVL(Z.RPST_SCRN_GRP_YN, 'N') = 'Y'   -- ��ǥ�����׷쿩��
            ;
        -- �����ڰ� : �Ϲ�
        ELSIF IN_APLY_QUAL_FG = 'U024700001' THEN
            UPDATE ESIN520 Z    -- ������������
               SET Z.NON_LAW_BDEGR_PASS_RCNT = (
                        SELECT COUNT(*)
                          FROM ESIN600 A
                             , ESIN606 B
                         WHERE A.COLL_UNIT_NO = B.COLL_UNIT_NO
                           AND A.EXAM_NO = B.EXAM_NO
                           AND Z.COLL_UNIT_NO = A.COLL_UNIT_NO
                           AND B.SCRN_STG_FG = 'U027200002' -- �����ܰ� : ����
                           AND B.PASS_SCRN_FG = 'U028500001'    -- �հݻ������� : ����
                           AND B.PASS_DISQ_FG = 'U024300005'    -- �հݺ��հݱ��� : �հ�
                           AND NVL(A.JURIS_YN, 'N') <> 'Y'  -- ���п���
                   )
             WHERE Z.SELECT_YY = IN_SELECT_YY
               AND Z.SELECT_FG = IN_SELECT_FG
               AND Z.COLL_FG = IN_COLL_FG
               AND Z.APLY_QUAL_FG = IN_APLY_QUAL_FG
               AND Z.DETA_APLY_QUAL_FG LIKE IN_DETA_APLY_QUAL_FG||'%'
               AND Z.APLY_CORS_FG LIKE IN_APLY_CORS_FG||'%'
               AND Z.APLY_COLG_FG LIKE IN_APLY_COLG_FG||'%'
            ;
        END IF;
	END IF;
    
	OUT_MSG := '���� �հ��� ����ó���Ǿ����ϴ�.';
	OUT_RTN := 0;

	EXCEPTION WHEN OTHERS THEN
		OUT_MSG := '���� �հ��� ����ó���� ������ �߻��Ͽ����ϴ�.' ||SQLCODE;
		OUT_RTN := -1;
		ROLLBACK;
		RAISE;
	RETURN;
END SP_ESIN606_FL_CREA;
/
