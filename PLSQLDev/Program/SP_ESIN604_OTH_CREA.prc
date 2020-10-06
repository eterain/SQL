CREATE OR REPLACE PROCEDURE SP_ESIN604_OTH_CREA
(   IN_COLL_UNIT_NO			IN ESIN604.COLL_UNIT_NO%TYPE			/* ����������ȣ */
,	IN_SCRN_STG_FG			IN ESIN604.SCRN_STG_FG%TYPE				/* �����ܰ豸�� */
,	IN_SELECT_ELEMNT_FG		IN ESIN604.SELECT_ELEMNT_FG%TYPE		/* ������ұ��� */
,	IN_GENRL_SELECT_CHG_YN	IN ESIN604.GENRL_SELECT_CHG_YN%TYPE		/* �Ϲ�������ȯ���� */
,	IN_SELECT_YY            IN ESIN600.SELECT_YY%TYPE				/* �����⵵ */
,   IN_SELECT_FG            IN ESIN600.SELECT_FG%TYPE               /* �������� */
,   IN_COLL_FG              IN ESIN600.COLL_FG%TYPE					/* �������� */
,   IN_APLY_QUAL_FG         IN ESIN600.APLY_QUAL_FG%TYPE			/* �����ڰ� */
,   IN_DETA_APLY_QUAL_FG    IN ESIN600.DETA_APLY_QUAL_FG%TYPE		/* ���������ڰ� */
,   IN_APLY_CORS_FG         IN ESIN600.APLY_CORS_FG%TYPE			/* ���� */
,   IN_APLY_COLG_FG         IN ESIN600.APLY_COLG_FG%TYPE			/* �ܰ����� */
,   IN_APLY_COLL_UNIT_CD    IN ESIN600.APLY_COLL_UNIT_CD%TYPE		/* ���������ڵ� */
,   IN_EXAM_NO              IN ESIN600.EXAM_NO%TYPE					/* �����ȣ */
,	IN_FL_SCOR				IN ESIN604.FL_SCOR%TYPE					/* �������� */
,	IN_INPT_ID				IN ESIN604.INPT_ID%TYPE					/* ������ ID */
,	IN_INPT_IP				IN ESIN604.INPT_IP%TYPE					/* ������ IP */
,	IN_MOD_ID				IN ESIN604.MOD_ID%TYPE					/* ������ ID */
,	IN_MOD_IP				IN ESIN604.MOD_IP%TYPE					/* ������ IP */
,   OUT_RTN                 OUT INTEGER								/* �����(OUT) */
,   OUT_MSG                 OUT VARCHAR2							/* ��������(OUT) */
)
IS
/******************************************************************************
	���α׷���	: SP_ESIN604_OTH_CREA
	�������	: �����Թ�����, �������, �ܱ����, ������ ������� ���ν��� ����
	������	: 
------------------------------------------------------------------------------
	��������		������		��������
------------------------------------------------------------------------------
	2019.12.18	���ؽ�		���� �ۼ�
	2019.12.27	�ڿ���		���ν��� ���� ����
    2020.09.21  �ڿ���     ġ���д��п� -  ��� ��ư�� ������ ���� ������ ȯ������ �Ҽ��� 2��°�ڸ� ����(�ݿø�x)�� �ʿ�. 
******************************************************************************/

BEGIN 
/*
U025700001  �Ϲݴ��п�
U025700002  �����������п�
U025700003  ġ���д��п�
U025700004  �濵�������п�
U025700005  �濵�������п�(EMBA)
U025700006  �濵�������п�(GMBA)
U025700007  �����������п�
U025700008  �����ͻ��̾𽺴��п�
U025700009  �������п�(����а�)
U025700010  �ǰ�����(����а�)
U025700011  ���հ��б�����п�(����а�)
U025700012  �л�����
U025700013  ���д���
U025700014  ��ȣ����(����а�)
U025700015  ���հ��б�����п�(����а�_)

U027100001	1�ܰ�����
U027100002	2�ܰ�����
U027100003	�����Թ����輺��
U027100004	����ɷ�
U027100005	�����ױ������
U027100006	������������
U027100007	������
U027100008	�Ǳ⼺��
U027100009	�����
U027100010	�����̷�
U027100011	�����ʴ���
U027100012	������
U027100013	��2�ܱ���
U027100014	�о�����
U027100017	��������1
U027100018	��������2
U027100019	��������3
*/  
	OUT_RTN := 0;
    
	IF ('U027100003' =  IN_SELECT_ELEMNT_FG) THEN      -- �����Թ�����  
        SP_ESIN604_EET_CREA(
				IN_COLL_UNIT_NO				/* ����������ȣ */
			,	IN_SCRN_STG_FG				/* �����ܰ豸�� */
			,	IN_SELECT_ELEMNT_FG			/* ������ұ��� */
			,	IN_GENRL_SELECT_CHG_YN		/* �Ϲ�������ȯ���� */
		    ,	IN_SELECT_YY            	/* �����⵵ */
		    ,   IN_SELECT_FG                /* �������� */
		    ,   IN_COLL_FG              	/* �������� */
		    ,   IN_APLY_QUAL_FG         	/* �����ڰ� */
		    ,   IN_DETA_APLY_QUAL_FG    	/* ���������ڰ� */
		    ,   IN_APLY_CORS_FG         	/* ���� */
		    ,   IN_APLY_COLG_FG         	/* �ܰ����� */
		    ,   IN_APLY_COLL_UNIT_CD    	/* ���������ڵ� */
		    ,   IN_EXAM_NO              	/* �����ȣ */
			,	IN_FL_SCOR					/* �������� */
			,	IN_INPT_ID					/* ������ ID */
			,	IN_INPT_IP					/* ������ IP */
			,	IN_MOD_ID					/* ������ ID */
			,	IN_MOD_IP					/* ������ IP */
		    ,   OUT_RTN                 	/* �����(OUT) */
		    ,   OUT_MSG                 	/* ��������(OUT) */
		)
        ;
    ELSIF ('U027100004' = IN_SELECT_ELEMNT_FG) THEN    -- ������� 
        SP_ESIN604_KOR_CREA(
				IN_COLL_UNIT_NO				/* ����������ȣ */
			,	IN_SCRN_STG_FG				/* �����ܰ豸�� */
			,	IN_SELECT_ELEMNT_FG			/* ������ұ��� */
			,	IN_GENRL_SELECT_CHG_YN		/* �Ϲ�������ȯ���� */
		    ,	IN_SELECT_YY            	/* �����⵵ */
		    ,   IN_SELECT_FG                /* �������� */
		    ,   IN_COLL_FG              	/* �������� */
		    ,   IN_APLY_QUAL_FG         	/* �����ڰ� */
		    ,   IN_DETA_APLY_QUAL_FG    	/* ���������ڰ� */
		    ,   IN_APLY_CORS_FG         	/* ���� */
		    ,   IN_APLY_COLG_FG         	/* �ܰ����� */
		    ,   IN_APLY_COLL_UNIT_CD    	/* ���������ڵ� */
		    ,   IN_EXAM_NO              	/* �����ȣ */
			,	IN_FL_SCOR					/* �������� */
			,	IN_INPT_ID					/* ������ ID */
			,	IN_INPT_IP					/* ������ IP */
			,	IN_MOD_ID					/* ������ ID */
			,	IN_MOD_IP					/* ������ IP */
		    ,   OUT_RTN                 	/* �����(OUT) */
		    ,   OUT_MSG                 	/* ��������(OUT) */
        )
        ; 
	ELSIF ('U027100013' = IN_SELECT_ELEMNT_FG) THEN    -- �ܱ������  
      SP_ESIN604_FRN_LANG_CREA
		(       IN_COLL_UNIT_NO				/* ����������ȣ */
			,	IN_SCRN_STG_FG				/* �����ܰ豸�� */
			,	IN_SELECT_ELEMNT_FG			/* ������ұ��� */
			,	IN_GENRL_SELECT_CHG_YN		/* �Ϲ�������ȯ���� */
		    ,	IN_SELECT_YY            	/* �����⵵ */
		    ,   IN_SELECT_FG                /* �������� */
		    ,   IN_COLL_FG              	/* �������� */
		    ,   IN_APLY_QUAL_FG         	/* �����ڰ� */
		    ,   IN_DETA_APLY_QUAL_FG    	/* ���������ڰ� */
		    ,   IN_APLY_CORS_FG         	/* ���� */
		    ,   IN_APLY_COLG_FG         	/* �ܰ����� */
		    ,   IN_APLY_COLL_UNIT_CD    	/* ���������ڵ� */
		    ,   IN_EXAM_NO              	/* �����ȣ */
			,	IN_FL_SCOR					/* �������� */
			,	IN_INPT_ID					/* ������ ID */
			,	IN_INPT_IP					/* ������ IP */
			,	IN_MOD_ID					/* ������ ID */
			,	IN_MOD_IP					/* ������ IP */
		    ,   OUT_RTN                 	/* �����(OUT) */
		    ,   OUT_MSG                 	/* ��������(OUT) */
		) ;  	 
	ELSE --������
		SP_ESIN604_OTH_RST_CREA(
                IN_COLL_UNIT_NO				/* ����������ȣ */
			,	IN_SCRN_STG_FG				/* �����ܰ豸�� */
			,	IN_SELECT_ELEMNT_FG			/* ������ұ��� */
			,	IN_GENRL_SELECT_CHG_YN		/* �Ϲ�������ȯ���� */
		    ,	IN_SELECT_YY            	/* �����⵵ */
		    ,   IN_SELECT_FG                /* �������� */
		    ,   IN_COLL_FG              	/* �������� */
		    ,   IN_APLY_QUAL_FG         	/* �����ڰ� */
		    ,   IN_DETA_APLY_QUAL_FG    	/* ���������ڰ� */
		    ,   IN_APLY_CORS_FG         	/* ���� */
		    ,   IN_APLY_COLG_FG         	/* �ܰ����� */
		    ,   IN_APLY_COLL_UNIT_CD    	/* ���������ڵ� */
		    ,   IN_EXAM_NO              	/* �����ȣ */
			,	IN_FL_SCOR					/* �������� */
			,	IN_INPT_ID					/* ������ ID */
			,	IN_INPT_IP					/* ������ IP */
			,	IN_MOD_ID					/* ������ ID */
			,	IN_MOD_IP					/* ������ IP */
		    ,   OUT_RTN                 	/* �����(OUT) */
		    ,   OUT_MSG                 	/* ��������(OUT) */
		)
        ; 
    END IF;
    
	IF OUT_RTN = 0 THEN
        OUT_MSG := 'ó���� �����Ͽ����ϴ�.';
	ELSE 
	  OUT_MSG := 'DD' || OUT_MSG ;
	END IF;

	EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;  
	RETURN;
END SP_ESIN604_OTH_CREA;
/
