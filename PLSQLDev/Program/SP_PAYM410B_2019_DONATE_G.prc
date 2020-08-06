CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_G
/***************************************************************************************
�� ü �� : SP_PAYM410B_2019_DONATE_G
��    �� : �������� ������α�ó��
�� �� �� : 2020.01.31.
�� �� �� : �ڿ���
��������
 1.������: 2020.01.31.
   ������: �ڿ���
   ��  ��: �������� ������α�ó�� �ű�Return�� :
�������� :
****************************************************************************************/
(
    IN_USING                 IN   VARCHAR2,
    IN_BIZR_DEPT_CD          IN   PAYM423.BIZR_DEPT_CD    %TYPE, --����ںμ��ڵ�
    IN_YY                    IN   PAYM423.YY              %TYPE, --����⵵
    IN_YRETXA_SEQ            IN   PAYM423.YRETXA_SEQ      %TYPE, --��������
    IN_SETT_FG               IN   PAYM423.SETT_FG         %TYPE, --���걸��(A031300001:��������, A031300002:�ߵ�����, A031300003:�������� �ùķ��̼�)
    IN_RPST_PERS_NO          IN   PAYM423.RPST_PERS_NO    %TYPE, --��ǥ���ι�ȣ
    IN_BIZR_REG_NO           IN   PAYM452.BIZR_REG_NO     %TYPE, --����ںμ������� ����ڹ�ȣ.    
    
    IO_BASIC_AMT             IN OUT NUMBER,                      --�ٷμҵ�ݾ�
    IO_EXPAND_AMT            IN OUT NUMBER,                      --���ؼҵ�ݾ�
    IO_DONATE_MAX_AMT        IN OUT NUMBER,                      --�ѵ�
    
    IO_TDUC_DUC_TT_AMT       IN OUT NUMBER,                      --��������(���⼼��) �ջ�
    IO_CAL_TDUC_TEMP_AMT     IN OUT NUMBER,                      --��������(���⼼��) ����
    IO_SPCL_DUC_AMT          IN OUT NUMBER,                      --Ư���ҵ�����հ�
    IO_STAD_TAXDUC_OBJ_AMT   IN OUT NUMBER,                      --ǥ�ؼ��װ����հ�
    
    IO_GONGJE_SUM_AMT        IN OUT NUMBER,                      --�������ݾ�-�հ�
    IO_GONGJE_TAX_AMT        IN OUT NUMBER,                      --���װ����ݾ�-�հ�
    IO_B_GONGJE_TAX_AMT      IN OUT NUMBER,                      --����-���װ����ݾ�-�հ�
    IO_W_GONGJE_TAX_AMT      IN OUT NUMBER,                      --�츮����-���װ����ݾ�-�հ�

    IO_APNT_CNTRIB40_DUC_OBJ_AMT   IN OUT NUMBER,                --�������(������)�������ݾ�
    IO_APNT_CNTRIB41_DUC_OBJ_AMT   IN OUT NUMBER,                --�������(����)�������ݾ�
    IO_APNT_CNTRIB40_TAXDUC_AMT    IN OUT NUMBER,                --�������(������)���װ�����
    IO_APNT_CNTRIB41_TAXDUC_AMT    IN OUT NUMBER,                --�������(����)���װ�����
    
    IO_GONGJE_INCOME_ACCU_AMT   IN OUT NUMBER,                   --�������ݾ�-�ҵ���� ��� �����հ�
    IO_SPCL_AMT              IN OUT NUMBER,                      --Ư���ҵ�����հ�
    
    IN_INPT_ID               IN   PAYM432.INPT_ID         %TYPE,
    IN_INPT_IP               IN   PAYM432.INPT_IP         %TYPE,
    OUT_RTN                  IN OUT INTEGER,
    OUT_MSG                  IN OUT VARCHAR2
)
IS
    V_DONATE_AMT                            NUMBER(15) := 0;                   --�ٷμҵ�ݾ�            
    V_EXPAND_AMT                            NUMBER(15) := 0;                   --���ؼҵ�ݾ�
    V_DONATE_MAX_AMT                        NUMBER(15) := 0;                   --�ѵ� 
    V_DONATE_MAX1_AMT                        NUMBER(15) := 0;                   --�ѵ� 
    V_DONATE_MAX2_AMT                        NUMBER(15) := 0;                   --�ѵ� 
    
    V_DONATE_BASIC_AMT                      NUMBER(15) := 0;                   --��α�����ݾ�
    V_DONATE_BASIC_J_ACCU_AMT               NUMBER(15) := 0;                   --��α�����ݾ�-����-�����հ�
    V_DONATE_BASIC_E_ACCU_AMT               NUMBER(15) := 0;                   --��α�����ݾ�-������-�����հ�
    
    V_GONGJE_SUM_AMT                        NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_SUM_TOTAMT                     NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_SUM1_TOTAMT                     NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_SUM2_TOTAMT                     NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_SUM_ACCU_AMT                   NUMBER(15) := 0;                   --�������ݾ�-�����հ�
    V_GONGJE_SUM_ACCU1_AMT                   NUMBER(15) := 0;                   --�������ݾ�-�����հ�
    V_GONGJE_SUM_ACCU2_AMT                   NUMBER(15) := 0;                   --�������ݾ�-�����հ�
    V_GONGJE_INCOME_AMT                     NUMBER(15) := 0;                   --�������ݾ�-�ҵ���� ��� �հ�
    V_GONGJE_INCOME_ACCU_AMT                NUMBER(15) := 0;                   --�������ݾ�-�ҵ���� ��� �����հ�
    V_GONGJE_TAX_AMT                        NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��� �հ�    
    V_GONGJE_TAX_A_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 15% ���������
    V_GONGJE_TAX_B_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 30(25)% ���������
    V_GONGJE_TAX_C_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��Ÿ(100/110)    
    V_GONGJE_SUM_RATEAMT                    NUMBER(15) := 0;                   --���װ����ݾ�-�հ�
    V_GONGJE_SUM_ACCU1_RATEAMT               NUMBER(15) := 0;                   --���װ����ݾ�-�հ�
    V_GONGJE_SUM_ACCU2_RATEAMT               NUMBER(15) := 0;                   --���װ����ݾ�-�հ�
    V_GONGJE_SUM_ACCU_RATEAMT               NUMBER(15) := 0;                   --���װ����ݾ�-�����հ�
    V_GONGJE_TAX_A_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
    V_GONGJE_TAX_B_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
    V_GONGJE_TAX_C_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ�����

    V_CNTRIB_PREAMT                         NUMBER(15) := 0;                   --��α�������������ݾ�
    V_CNTRIB_GONGAMT                        NUMBER(15) := 0;                   --��αݴ������ݾ�
    V_CNTRIB_DESTAMT                        NUMBER(15) := 0;                   --��αݴ��Ҹ�ݾ�
    V_CNTRIB_OVERAMT                        NUMBER(15) := 0;                   --��αݴ���̿��ݾ�      

    V_TDUC_DUC_TT_AMT                       NUMBER(15) := 0;                    --��������(���⼼��) �ջ� 
    V_CAL_TDUC_TEMP_AMT                     NUMBER(15) := 0;                    --��������(���⼼��) ����
    V_SPCL_DUC_AMT                          NUMBER(15) := 0;                    --Ư���ҵ�����հ�
    V_STAD_TAXDUC_OBJ_AMT                   NUMBER(15) := 0;                    --ǥ�ؼ��װ����հ�

    V_TempAmt                               NUMBER(15) := 0; 
    V_TempRate                              NUMBER(15) := 0; 
    V_TempCnt                               NUMBER(15) := 0; 
BEGIN

    BEGIN
        
        V_DONATE_AMT := IO_BASIC_AMT;                          --�ٷμҵ�ݾ�  
        V_EXPAND_AMT := IO_EXPAND_AMT;                         --���ؼҵ�ݾ�          
        V_CAL_TDUC_TEMP_AMT := IO_CAL_TDUC_TEMP_AMT;           --��������(���⼼��)                     
        V_SPCL_DUC_AMT := IO_SPCL_DUC_AMT;                     --Ư���ҵ�����հ�                    
        V_STAD_TAXDUC_OBJ_AMT := IO_STAD_TAXDUC_OBJ_AMT;       --ǥ�ؼ��װ����հ�                     
        
        V_DONATE_BASIC_AMT := 0;
        V_GONGJE_SUM_ACCU_AMT := 0;
        V_GONGJE_SUM_ACCU1_AMT := 0;
        V_GONGJE_SUM_ACCU2_AMT := 0;
        V_GONGJE_SUM_ACCU_RATEAMT := 0;
        V_DONATE_BASIC_J_ACCU_AMT := 0;
        V_DONATE_BASIC_E_ACCU_AMT := 0;
        V_GONGJE_SUM_TOTAMT := 0;
        V_TempCnt := 0;
        
        FOR CNTRIB1 IN ( SELECT C1.RPST_PERS_NO, C1.CNTRIB_YY, C1.CNTRIB_TYPE_CD
                                , C1.CNTRIB_GIAMT
                                , NVL(C1.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                , NVL(C1.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                , NVL(C1.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                , NVL(C1.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                , SUM(C1.APNT_CNTRIB_AMT) OVER(PARTITION BY C1.RPST_PERS_NO) AS  APNT_CNTRIB_AMT -- ������ü ������α� �߻�(���+�̿�) �ݾ�
                                , SUM(C1.APNT_CNTRIB_AMT2) OVER(PARTITION BY C1.RPST_PERS_NO) AS  APNT_CNTRIB_AMT2 -- ������ü�� ������α� �߻�(���+�̿�) �ݾ�
                                , SUM(C1.CNTRIB_GIAMT) OVER (PARTITION BY C1.CNTRIB_TYPE_CD) AS CNTRIB_TYPE_TT_AMT --��������� �հ�ݾ�
                                , C1.SORT1, C1.SORT3
                           FROM ( SELECT A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD
                                         , SUM(A1.CNTRIB_GIAMT)   CNTRIB_GIAMT
                                         , SUM(A1.CNTRIB_PREAMT)  CNTRIB_PREAMT
                                         , SUM(A1.CNTRIB_GONGAMT) CNTRIB_GONGAMT
                                         , SUM(A1.CNTRIB_DESTAMT) CNTRIB_DESTAMT
                                         , SUM(A1.CNTRIB_OVERAMT) CNTRIB_OVERAMT
                                         , SUM(A1.APNT_CNTRIB_AMT) APNT_CNTRIB_AMT -- ������ü ������α� �߻�(���+�̿�) �ݾ�
                                         , SUM(A1.APNT_CNTRIB_AMT2) APNT_CNTRIB_AMT2 -- ������ü�� ������α� �߻�(���+�̿�) �ݾ�
                                         , A1.SORT1, A1.SORT3
                                    FROM ( /*[�ҵ���� SORT1:A1] 2013������ ������ü��*/
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,0                       AS APNT_CNTRIB_AMT  -- �̿��� ������ü ������α� �ݾ�
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT2 -- �̿��� ������ü�� ������α� �ݾ�
                                                   ,'A1'                    AS SORT1
                                                   ,A.CNTRIB_YY             AS SORT3
                                               FROM PAYM432 A --���⵵ ��α� ��� ��� ����
                                                   ,PAYM452 B --����ںμ����� @VER.2016_11
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY - 1
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ     /* ���⵵�� ���� ����ó�� */
                                                AND A.YY             = B.YY                        /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO    = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400006'    /* ��α�����: ���� ������(40) */
                                                AND A.SETT_FG        = 'A031300001'    /* ���걸��: �������� */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0       /* ���⵵ ��� �� �̿��ݾ��� 0 �� �ƴ� ������ ��⵵ ���� ������ ���� �� */
                                                AND A.CNTRIB_YY <= '2013'              /* @2016R 2013�� ���� �̿���α� �и� (2015�� 1�� ���� �и� �ȵǾ�����:��������) */
                                             UNION ALL
                                              /*[�ҵ���� SORT1:A2] 2013������ ������ü*/
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT  -- �̿��� ������ü ������α� �ݾ�
                                                   ,0                       AS APNT_CNTRIB_AMT2 -- �̿��� ������ü�� ������α� �ݾ�
                                                   ,'A2'                    AS SORT1
                                                   ,A.CNTRIB_YY             AS SORT3
                                               FROM PAYM432 A --���⵵ ��α� ��� ��� ����
                                                   ,PAYM452 B --����ںμ����� @VER.2016_11
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY - 1
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ    /* ���⵵�� ���� ����ó�� */
                                                AND A.YY             = B.YY            /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO    = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400007'    /* ��α�����: ���� ������ü(41) */
                                                AND A.SETT_FG        = 'A031300001'    /* ���걸�� : �������� */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0       /* ���⵵ ��� �� �̿��ݾ��� 0 �� �ƴ� ������ ��⵵ ���� ������ ���� �� */
                                                AND A.CNTRIB_YY <= '2013'              /* @2016R 2013�� ���� �̿���α� �и� (2015�� 1�� ���� �и� �ȵǾ�����:��������) */
                                             UNION ALL
                                             /*[���װ��� SORT1:B1] ������ü�� �̿�(2014��~) */
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,0                       AS APNT_CNTRIB_AMT  -- �̿��� ������ü ������α� �ݾ�
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT2 -- �̿��� ������ü�� ������α� �ݾ�
                                                   ,'B1'        AS SORT1
                                                   ,A.CNTRIB_YY AS SORT3
                                               FROM PAYM432 A --���⵵ ��α� ��� ��� ����
                                                   ,PAYM452 B --����ںμ����� @VER.2016_11
                                              WHERE A.RPST_PERS_NO = IN_RPST_PERS_NO
                                                AND A.YY           = IN_YY - 1
                                                AND A.YRETXA_SEQ   = IN_YRETXA_SEQ    /* ���⵵�� ���� ����ó��*/
                                                AND A.YY           = B.YY            /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO  = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400006'  /* ����(������:40) */
                                                AND A.SETT_FG        = 'A031300001'  /* ���걸��:�������� */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0     /* ���⵵ ��� �� �̿��ݾ��� 0 �� �ƴ� ������ ��⵵ ���� ������ ���� ��*/
                                                AND A.CNTRIB_YY >= '2014'            /* 2014�� ���� �̿� ��α� */
                                             UNION ALL
                                             /*[���װ��� SORT1:B2] ���� ������ü �� */
                                             SELECT A.RPST_PERS_NO, A.YY, A.CNTRIB_TYPE_CD
                                                   ,(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) - NVL(A.CNTRIB_ENC_APLY_AMT,0) ) AS CNTRIB_GIAMT /*@VER.2016_9 ������α� ��������û�ݾ� ����.*/
                                                   ,0                                                 AS CNTRIB_PREAMT
                                                   ,0                                                 AS CNTRIB_GONGAMT
                                                   ,0                                                 AS CNTRIB_DESTAMT
                                                   ,0                                                 AS CNTRIB_OVERAMT
                                                   ,0                                                 AS APNT_CNTRIB_AMT  -- ��⵵ ������ü ������α� �߻� �ݾ�
                                                   ,NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT2 -- ��⵵ ������ü�� ������α� �߻� �ݾ�
                                                   ,'B2'  AS SORT1
                                                   ,A.YY  AS SORT3
                                               FROM PAYM423 A --��⵵ �������� ��γ���
                                                   ,PAYM421 B --�������� ��������
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                AND A.CNTRIB_TYPE_CD = 'A032400006' /* ����(������:40) */
                                                AND A.SETT_FG        = IN_SETT_FG
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                                                AND A.YY             = B.YY
                                                AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.SETT_FG        = B.SETT_FG
                                                AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                                                AND A.FM_SEQ         = B.FM_SEQ
                                                AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 ��α� �ξ簡�� ���ɿ�� ����(�ҵ��Ǹ� üũ �Ǵ� ����)
                                             UNION ALL
                                             /*[���װ��� SORT1:C1] ������ü �̿�(2014��~) */
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT  -- �̿��� ������ü ������α� �ݾ�
                                                   ,0                       AS APNT_CNTRIB_AMT2 -- �̿��� ������ü�� ������α� �ݾ�
                                                   ,'C1'                    AS SORT1
                                                   ,A.CNTRIB_YY             AS SORT3
                                               FROM PAYM432 A --���⵵ ��α� ��� ��� ����
                                                   ,PAYM452 B --����ںμ����� @VER.2016_11
                                              WHERE A.RPST_PERS_NO = IN_RPST_PERS_NO
                                                AND A.YY           = IN_YY - 1
                                                AND A.YRETXA_SEQ   = IN_YRETXA_SEQ    /* ���⵵�� ���� ����ó��*/
                                                AND A.YY           = B.YY            /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO  = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400007'  /* ����(������ü:41) */
                                                AND A.SETT_FG        = 'A031300001'  /* ���걸��:�������� */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0     /* ���⵵ ��� �� �̿��ݾ��� 0 �� �ƴ� ������ ��⵵ ���� ������ ���� ��*/
                                                AND A.CNTRIB_YY >= '2014'            /* 2014�� ���� �̿� ��α� */
                                             UNION ALL
                                             /*[���װ��� SORT1:C2] ���� ������ü */
                                             SELECT A.RPST_PERS_NO, A.YY, A.CNTRIB_TYPE_CD
                                                   ,(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) - NVL(A.CNTRIB_ENC_APLY_AMT,0) ) AS CNTRIB_GIAMT/*@VER.2016_9 ������α� ��������û�ݾ� ����.*/
                                                   ,0                                                 AS CNTRIB_PREAMT
                                                   ,0                                                 AS CNTRIB_GONGAMT
                                                   ,0                                                 AS CNTRIB_DESTAMT
                                                   ,0                                                 AS CNTRIB_OVERAMT
                                                   ,NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT  -- ��⵵ ������ü ������α� �߻� �ݾ�
                                                   ,0                                                 AS APNT_CNTRIB_AMT2 -- ��⵵ ������ü��  ������α� �߻� �ݾ�
                                                   ,'C2' SORT1
                                                   ,A.YY SORT3
                                               FROM PAYM423 A --��⵵ �������� ��γ���
                                                  , PAYM421 B --�������� ��������
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                AND A.CNTRIB_TYPE_CD = 'A032400007' /* ����(������ü:41)*/
                                                AND A.SETT_FG        = IN_SETT_FG
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                                                AND A.YY             = B.YY
                                                AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.SETT_FG        = B.SETT_FG
                                                AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                                                AND A.FM_SEQ         = B.FM_SEQ
                                                AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 ��α� �ξ簡�� ���ɿ�� ����(�ҵ��Ǹ� üũ �Ǵ� ����)
                                              --AND NVL(B.BASE_DUC_YN,'N') IN ('Y','1') --�⺻���� üũ�� ����� ��α�
                                             UNION ALL
                                             /*[���װ��� SORT1:B2] ���� �޿�������(����:������ü ��(41)�� �з�) */
                                             SELECT A.RPST_PERS_NO, A.YY, 'A032400006' AS CNTRIB_TYPE_CD
                                                   ,NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) AS CNTRIB_GIAMT
                                                   ,0                                AS CNTRIB_PREAMT
                                                   ,0                                AS CNTRIB_GONGAMT
                                                   ,0                                AS CNTRIB_DESTAMT
                                                   ,0                                AS CNTRIB_OVERAMT
                                                   ,0                                AS APNT_CNTRIB_AMT  --��⵵ ������ü  ������α� �߻� �ݾ�
                                                   ,NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT2 --��⵵ ������ü��  ������α� �߻� �ݾ�
                                                   ,'B2'                             AS SORT1
                                                   ,A.YY                             AS SORT3
                                               FROM PAYM440 A --��⵵ �޿� ������ ���� ����
                                              WHERE A.RPST_PERS_NO = IN_RPST_PERS_NO
                                                AND A.YY           = IN_YY
                                                AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                AND SETT_FG        = IN_SETT_FG
                                                AND NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) <> 0
                                     ) A1
                               GROUP BY A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD, A1.SORT1, A1.SORT3
                               ) C1
                    ORDER BY C1.SORT1,C1.SORT3
                    )
        LOOP
            
            <<RECALCULATION>>

            V_CNTRIB_PREAMT  := 0;
            V_CNTRIB_GONGAMT := 0;
            V_CNTRIB_DESTAMT := 0;
            V_CNTRIB_OVERAMT := 0;
                    
            --��α�����ݾ�
            V_DONATE_BASIC_AMT := CNTRIB1.CNTRIB_GIAMT;                                    --��α�����ݾ�    
            -- �ѵ�
            IF (V_DONATE_BASIC_J_ACCU_AMT = 0) THEN
                V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 0.1 + LEAST(V_EXPAND_AMT * 0.2,V_DONATE_BASIC_E_ACCU_AMT));
            ELSE
                V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 0.3);
            END IF;            
            --V_DONATE_MAX1_AMT := TRUNC(V_EXPAND_AMT * 0.1 + LEAST(V_EXPAND_AMT * 0.2,V_DONATE_BASIC_E_ACCU_AMT));
            --V_DONATE_MAX2_AMT := TRUNC(V_EXPAND_AMT * 0.3); 
            -- ��α����⴩���ݾ��հ�(������ü, ������)
            IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN   -- ������ü
                V_DONATE_BASIC_J_ACCU_AMT := V_DONATE_BASIC_J_ACCU_AMT + V_DONATE_BASIC_AMT;
            ELSE
                V_DONATE_BASIC_E_ACCU_AMT := V_DONATE_BASIC_E_ACCU_AMT + V_DONATE_BASIC_AMT;
            END IF;                                                           
            -- �������ݾ� �հ� �ѵ���(������ü, ������)
            IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN   -- ������ü
                V_TempRate := 10;  
            ELSE
                V_TempRate := 30;  
            END IF;           
            -- �������ݾ� �հ�
            IF V_GONGJE_SUM_ACCU_AMT >= V_DONATE_MAX_AMT THEN 
                V_GONGJE_SUM_AMT := 0;
                --V_DONATE_BASIC_AMT := 0; 
            ELSE 
                IF (CNTRIB1.CNTRIB_YY <= '2013' ) THEN               
                    V_GONGJE_SUM_AMT := V_DONATE_BASIC_AMT; 
                ELSE
                    V_GONGJE_SUM_AMT := LEAST(V_DONATE_BASIC_AMT,V_DONATE_MAX_AMT - V_GONGJE_SUM_ACCU_AMT, ROUND(V_EXPAND_AMT * V_TempRate / V_TempRate));                 
                END IF;                        
            END IF;
            IF (CNTRIB1.CNTRIB_YY <= '2013' ) THEN               
                --�������ݾ�-�ҵ���� ��� �հ�
                V_GONGJE_INCOME_AMT := V_GONGJE_SUM_AMT;
                V_GONGJE_INCOME_ACCU_AMT := V_GONGJE_INCOME_ACCU_AMT + V_GONGJE_INCOME_AMT;
                V_GONGJE_TAX_AMT := 0;
                V_GONGJE_TAX_A_AMT := 0;
                V_GONGJE_TAX_B_AMT := 0;
                V_GONGJE_TAX_C_AMT := 0;
                V_GONGJE_SUM_RATEAMT := 0;
                V_GONGJE_SUM_ACCU1_RATEAMT := 0;
                V_GONGJE_SUM_ACCU2_RATEAMT := 0;
                V_GONGJE_TAX_A_RATEAMT := 0;
                V_GONGJE_TAX_B_RATEAMT := 0;
                V_GONGJE_TAX_C_RATEAMT := 0;                
                -- �������ݾ� �����հ�
                V_GONGJE_SUM_ACCU_AMT := V_GONGJE_SUM_ACCU_AMT + V_GONGJE_SUM_AMT;                                
            ELSE                    
                V_GONGJE_INCOME_AMT := 0;
                V_GONGJE_INCOME_ACCU_AMT := V_GONGJE_INCOME_ACCU_AMT + V_GONGJE_INCOME_AMT;
                -- �������ݾ�-���װ��� ��� �հ�
                V_GONGJE_TAX_AMT := V_GONGJE_SUM_AMT;                
                -- ������ ���ױ�α� ���װ�����
                IF (CNTRIB1.CNTRIB_YY = '2015') THEN
                    V_TempAmt := 30000000;
                ELSIF (CNTRIB1.CNTRIB_YY = '2016' OR CNTRIB1.CNTRIB_YY = '2017' OR CNTRIB1.CNTRIB_YY = '2018') THEN
                    V_TempAmt := 20000000;
                ELSIF (CNTRIB1.CNTRIB_YY = IN_YY) THEN
                    V_TempAmt := 10000000;
                END IF;                    
                --�������ݾ�-���װ��� 15% ���������
                IF ((IO_B_GONGJE_TAX_AMT + IO_W_GONGJE_TAX_AMT) > V_TempAmt) THEN 
                    V_GONGJE_TAX_A_AMT := 0;    
                ELSE
                    V_GONGJE_TAX_A_AMT := LEAST(V_TempAmt - IO_B_GONGJE_TAX_AMT - IO_W_GONGJE_TAX_AMT, V_GONGJE_TAX_AMT);     
                END IF;
                --�������ݾ�-���װ��� 30(25)% ���������
                V_GONGJE_TAX_B_AMT := GREATEST(0, V_GONGJE_TAX_AMT - V_GONGJE_TAX_A_AMT);
                V_GONGJE_TAX_C_AMT := 0;                
                --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
                V_GONGJE_TAX_A_RATEAMT := CEIL(V_GONGJE_TAX_A_AMT * 0.15);                                        
                --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
                IF (CNTRIB1.CNTRIB_YY = '2014' OR CNTRIB1.CNTRIB_YY = '2015') THEN
                    V_GONGJE_TAX_B_RATEAMT := CEIL(V_GONGJE_TAX_B_AMT * 0.25);
                ELSE
                    V_GONGJE_TAX_B_RATEAMT := CEIL(V_GONGJE_TAX_B_AMT * 0.30);
                END IF;                    
                V_GONGJE_TAX_C_RATEAMT := 0;
                --���װ����ݾ�-�հ�
                V_GONGJE_SUM_RATEAMT := V_GONGJE_TAX_A_RATEAMT + V_GONGJE_TAX_B_RATEAMT + V_GONGJE_TAX_C_RATEAMT;                    
                --IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN  -- ������ü
                --    V_GONGJE_SUM_ACCU1_RATEAMT := V_GONGJE_SUM_ACCU1_RATEAMT + V_GONGJE_SUM_RATEAMT;
                --ELSE 
                --    V_GONGJE_SUM_ACCU2_RATEAMT := V_GONGJE_SUM_ACCU2_RATEAMT + V_GONGJE_SUM_RATEAMT;
                --END IF;
                -- �������ݾ� �����հ�
                V_GONGJE_SUM_ACCU_AMT := V_GONGJE_SUM_ACCU_AMT + V_GONGJE_SUM_AMT;
                -- ���װ����ݾ�-�����հ�
                V_GONGJE_SUM_ACCU_RATEAMT := V_GONGJE_SUM_ACCU_RATEAMT + V_GONGJE_SUM_RATEAMT;                                                          

                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- ��������(���⼼��) 0 ���� ũ��                                                              
                    IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_SUM_RATEAMT THEN  -- ��������(���⼼��) �ܾ��� ���װ����ݾ�-�հ� ���� �۴ٸ�                             
                        IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_TAX_A_RATEAMT THEN               
                            /*  ���� ó�� : ��α�����ݾ� = (���װ����ݾ�(�հ�) -  ��������(���⼼��)) * 100 / 15%(���������) */
                            V_DONATE_BASIC_AMT := CEIL((V_GONGJE_TAX_A_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 15) ;
                        ELSE
                            /*  ���� ó�� : ��α�����ݾ� = (���װ����ݾ�(�հ�) -  ��������(���⼼��)) * 100 / 30(25)%(���������) */
                            IF (CNTRIB1.CNTRIB_YY = '2014' OR CNTRIB1.CNTRIB_YY = '2015') THEN
                               V_DONATE_BASIC_AMT := CEIL((V_GONGJE_TAX_B_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 25) ;                
                            ELSE
                               V_DONATE_BASIC_AMT := CEIL((V_GONGJE_TAX_B_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 30) ;                 
                            END IF;
                        END IF;
                        GOTO RECALCULATION;    
                    ELSE
                        IF CNTRIB1.CNTRIB_YY = IN_YY THEN
                            IF CNTRIB1.CNTRIB_GIAMT > V_DONATE_BASIC_AMT THEN
                                V_CNTRIB_PREAMT  := 0;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := CNTRIB1.CNTRIB_GIAMT - V_DONATE_BASIC_AMT;
                            ELSE
                                V_CNTRIB_PREAMT  := 0;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := 0;                                
                            END IF; 
                        ELSIF CNTRIB1.CNTRIB_YY <= '2013' THEN
                            IF CNTRIB1.CNTRIB_OVERAMT > V_DONATE_BASIC_AMT THEN
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := CNTRIB1.CNTRIB_OVERAMT - V_DONATE_BASIC_AMT;
                                V_CNTRIB_OVERAMT := 0;
                            ELSE
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_OVERAMT;
                                V_CNTRIB_GONGAMT := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;                           
                                V_CNTRIB_DESTAMT := V_DONATE_BASIC_AMT;
                                V_CNTRIB_OVERAMT := 0;                                
                            END IF;                            
                        ELSIF CNTRIB1.CNTRIB_YY > '2013' AND  CNTRIB1.CNTRIB_YY < IN_YY THEN
                            IF CNTRIB1.CNTRIB_OVERAMT > V_DONATE_BASIC_AMT THEN
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := CNTRIB1.CNTRIB_OVERAMT - V_DONATE_BASIC_AMT;
                            ELSE
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := 0;                                
                            END IF;                              
                        END IF;                           
                    END IF;
                ELSE              
                    IF CNTRIB1.CNTRIB_YY = IN_YY THEN
                        V_CNTRIB_PREAMT      := 0;                                               -- ��α� ������� �����ݾ�
                    ELSE
                        V_CNTRIB_PREAMT      := CNTRIB1.CNTRIB_PREAMT;                           -- ��α� ������� �����ݾ� 
                    END IF;
                    V_CNTRIB_GONGAMT     := 0;                                                   -- ��α� ��� �����ݾ�
                    V_CNTRIB_DESTAMT     := 0;                                                   -- ��α� ��� �Ҹ�ݾ�
                    V_CNTRIB_OVERAMT     := V_DONATE_BASIC_AMT;                                  -- ��α� ��� �̿��ݾ�                  
                END IF;                         
            END IF;
    
            /* �������� ��α�����ó�� */   
            IF IN_USING = 'T' THEN    
               SP_PAYM410B_2019_DONATE_SAVE(IN_BIZR_DEPT_CD, IN_YY, IN_SETT_FG, IN_RPST_PERS_NO, CNTRIB1.CNTRIB_TYPE_CD, CNTRIB1.CNTRIB_YY, V_DONATE_BASIC_AMT, V_CNTRIB_PREAMT, V_CNTRIB_GONGAMT, V_CNTRIB_DESTAMT, V_CNTRIB_OVERAMT, IN_INPT_ID, IN_INPT_IP, OUT_RTN, OUT_MSG);                                
            END IF;
            
            IF V_CNTRIB_GONGAMT > 0 THEN                                                        
                IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN 
                   V_GONGJE_SUM2_TOTAMT := V_GONGJE_SUM2_TOTAMT + V_CNTRIB_GONGAMT;
                ELSE
                   V_GONGJE_SUM1_TOTAMT := V_GONGJE_SUM1_TOTAMT + V_CNTRIB_GONGAMT; 
                END IF;
                DBMS_OUTPUT.PUT_LINE('�������ݾ� �հ� ����    : ' || V_GONGJE_SUM2_TOTAMT );
                DBMS_OUTPUT.PUT_LINE('�������ݾ� �հ� ����-�� : ' || V_GONGJE_SUM1_TOTAMT );
            END IF;     
            
            IF V_CNTRIB_GONGAMT > 0 THEN             
                -- ǥ�ؼ��װ��� ���
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_GONGJE_SUM_RATEAMT;
                IF V_STAD_TAXDUC_OBJ_AMT  <= 0  THEN
                     V_STAD_TAXDUC_OBJ_AMT := 0 ;
                END IF;   
                -- Ư���ҵ���� ���
                IF CNTRIB1.CNTRIB_YY = '2013' THEN  
                    V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_DONATE_BASIC_AMT;        
                    IF V_SPCL_DUC_AMT  <= 0  THEN
                         V_SPCL_DUC_AMT := 0 ;
                    END IF;     
                END IF;
                -- ���⼼�� ���
                V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_GONGJE_SUM_RATEAMT;                
                IF V_TDUC_DUC_TT_AMT  <= 0  THEN
                     V_TDUC_DUC_TT_AMT := 0 ;
                END IF;    
                V_CAL_TDUC_TEMP_AMT := V_CAL_TDUC_TEMP_AMT - V_GONGJE_SUM_RATEAMT;
                IF V_CAL_TDUC_TEMP_AMT  <= 0  THEN
                     V_CAL_TDUC_TEMP_AMT := 0 ;
                END IF;            
            END IF;            
                                   
            
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S ***************************************************************************************' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> �ٷ�/����/�ѵ�(100%) �ݾ� : ' || V_DONATE_AMT || ',' || V_EXPAND_AMT || ',' ||  V_DONATE_MAX_AMT);
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ' || CNTRIB1.CNTRIB_YY || ' - ' || CNTRIB1.CNTRIB_TYPE_CD);    
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ��α�����ݾ� : ' || V_DONATE_BASIC_AMT );    
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> �������ݾ�-�հ� : ' || V_GONGJE_SUM_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> �������ݾ�-�ҵ���� ��� �հ� : ' || V_GONGJE_INCOME_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> �������ݾ�-���װ��� ��� �հ� : ' || V_GONGJE_TAX_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> �������ݾ�-���װ��� 15% ��������� : ' || V_GONGJE_TAX_A_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> �������ݾ�-���װ��� 30(25)% ��������� : ' || V_GONGJE_TAX_B_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> �������ݾ�-���װ��� ��Ÿ(100/110) : ' || V_GONGJE_TAX_C_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ���װ����ݾ�-�հ� : ' || V_GONGJE_SUM_RATEAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ���װ����ݾ�-���װ��� 15% ���뼼�װ����� : ' || V_GONGJE_TAX_A_RATEAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ���װ����ݾ�-���װ��� 30(25)% ���뼼�װ����� : ' || V_GONGJE_TAX_B_RATEAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ����� : ' || V_GONGJE_TAX_C_RATEAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ������� �����ݾ� : ' || V_CNTRIB_PREAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ���     �����ݾ� : ' || V_CNTRIB_GONGAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ���     �Ҹ�ݾ� : ' || V_CNTRIB_DESTAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ���     �̿��ݾ� : ' || V_CNTRIB_OVERAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G E ***************************************************************************************' );
              
          
        END LOOP;   
        
    END;

    -- ���⼼��(����, �ջ�), Ư���ҵ����, ǥ�ؼ��װ���     
    IO_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT; 
    IO_CAL_TDUC_TEMP_AMT := V_CAL_TDUC_TEMP_AMT;   
    IO_SPCL_DUC_AMT := V_SPCL_DUC_AMT; 
    IO_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT;
    --    
    IO_GONGJE_SUM_AMT := V_GONGJE_SUM_ACCU_AMT;    
    IO_GONGJE_TAX_AMT := V_GONGJE_SUM_ACCU_RATEAMT;
    --�������ݾ�-�ҵ���� ��� �����հ�
    IO_GONGJE_INCOME_ACCU_AMT := IO_GONGJE_INCOME_ACCU_AMT - V_GONGJE_INCOME_ACCU_AMT;
    IF IO_GONGJE_INCOME_ACCU_AMT <= 0 THEN 
        IO_GONGJE_INCOME_ACCU_AMT := 0;
    ELSE
        IO_GONGJE_INCOME_ACCU_AMT := IO_GONGJE_INCOME_ACCU_AMT - V_GONGJE_INCOME_ACCU_AMT;    
    END IF;    
        
    IO_APNT_CNTRIB40_DUC_OBJ_AMT := V_GONGJE_SUM2_TOTAMT; --V_GONGJE_SUM_ACCU2_AMT;                  --�������(������)�������ݾ�
    IO_APNT_CNTRIB41_DUC_OBJ_AMT := V_GONGJE_SUM1_TOTAMT; --V_GONGJE_SUM_ACCU1_AMT;                  --�������(����)�������ݾ�
    IO_APNT_CNTRIB40_TAXDUC_AMT := V_GONGJE_SUM_ACCU2_RATEAMT;               --�������(������)���װ�����
    IO_APNT_CNTRIB41_TAXDUC_AMT := V_GONGJE_SUM_ACCU1_RATEAMT;               --�������(����)���װ�����   
             
    IO_SPCL_AMT := IO_SPCL_AMT + V_GONGJE_INCOME_ACCU_AMT;
    
END SP_PAYM410B_2019_DONATE_G;
/