--��õ¡��������
SELECT --ROWID
      A.RPST_PERS_NO
--     , A.LABOR_EARN_AMT       
     , A.LABOR_EARN_TDUC_AMT                                  /* �ٷμ��װ����� */
     , A.APNT_CNTRIB_RELI_OBJ_AMT                             /* ����(����) ������� */
     , A.APNT_CNTRIB_RELI_DUC_AMT                             /* ����(����) ���װ��� */
     , A.APNT_CNTRIB_RELI_OUT_OBJ_AMT                         /* ����(������) ������� */
     , A.APNT_CNTRIB_RELI_OUT_DUC_AMT                         /* ����(������) ���װ��� */
     , A.FLAW_CNTRIB_DUC_OBJ_AMT                              /* ������� ������� */
     , A.FLAW_CNTRIB_TAXDUC_AMT                               /* ������� ���װ��� */
     , A.APNT_CNTRIB_TAXDUC_AMT                               /* (64)������μ��װ�����*/
-- ,A.GUARQL_INSU_TAXDUC_AMT                /*(61)�Ϲݺ��强���輼�װ����� */
 --,A.DSPSN_GUARQL_INSU_TAXDUC_AMT          /*(61)����κ��强���輼�װ����� */
 --,A.HFE_TAXDUC_AMT                        /*(62)�Ƿ�񼼾װ����� */
 --,A.EDAMT_TAXDUC_AMT                      /*(63)�����񼼾װ����� */
 --,A.POLITICS_LMT_BLW_TAXDUC_AMT           /*(64)��ġ�ѵ����ϼ��װ����� */
 --,A.POLITICS_LMT_EXCE_TAXDUC_AMT          /*(64)��ġ�ѵ��ʰ����װ����� */
     , A.TDUC_TT                                               /* (70)���� ������ */
     , A.DETM_EARN_AMT                                         /* (73)��������*/
     , A.DETM_IHTAX_AMT                                        /* (���漼) */
     , A.ALD_SBTR_EARN_AMT                                     /* (����¡�� �ҵ漼) */
     , A.ALD_SBTR_IHTAX_AMT                                    /* (����¡�� ���漼) */
  --,A.*
  FROM PAYM410 A
 WHERE YY = '2019'
   AND RPST_PERS_NO = 'D010816'
   ;

--��α�
--A032400002 : ��ġ�ڱ�(�ڵ�:20),
--A032400001 : ����(�ڵ�:10), 
--A032400006 : ����(�ڵ�:40), 
--A032400007 : ����(�ڵ�:41)
   
SELECT ROWID
     , CNTRIB_GIAMT - CNTRIB_PREAMT AS "2019����"
     , A.*
  FROM PAYM432 A
 WHERE YY = '2019'
   AND RPST_PERS_NO = 'D010816'
   ;
   
SELECT *
 FROM PAYM432 A
 WHERE A.YY           = '2019'
   AND A.YRETXA_SEQ   = 1
   --AND CNTRIB_YY      = '2018'
   AND A.BIZR_DEPT_CD = '00000'
   AND A.SETT_FG      = 'A031300001'
   --AND A.CNTRIB_TYPE_CD = 'A032400006'
   AND A.RPST_PERS_NO  = 'D010816'
ORDER BY CNTRIB_TYPE_CD, CNTRIB_YY   
;   
