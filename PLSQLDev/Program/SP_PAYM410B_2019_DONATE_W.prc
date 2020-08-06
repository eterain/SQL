CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_W
/***************************************************************************************
�� ü �� : SP_PAYM410B_2019_DONATE_W
��    �� : �������� �츮���ֱ�α�ó��
�� �� �� : 2020.01.31.
�� �� �� : �ڿ���
��������
 1.������: 2020.01.31.
   ������: �ڿ���
   ��  ��: �������� �츮���ֱ�α�ó�� �ű�
Return�� :
�������� :
****************************************************************************************/
(
    IN_USING                 IN   VARCHAR2,
    IN_BIZR_DEPT_CD          IN   PAYM423.BIZR_DEPT_CD    %TYPE, --����ںμ��ڵ�
    IN_YY                    IN   PAYM423.YY              %TYPE, --����⵵
    IN_YRETXA_SEQ            IN   PAYM423.YRETXA_SEQ      %TYPE, --��������
    IN_SETT_FG               IN   PAYM423.SETT_FG         %TYPE, --���걸��(A031300001:��������, A031300002:�ߵ�����, A031300003:�������� �ùķ��̼�)
    IN_RPST_PERS_NO          IN   PAYM423.RPST_PERS_NO    %TYPE, --��ǥ���ι�ȣ    
    
    IO_BASIC_AMT             IN OUT NUMBER,                      --�ٷμҵ�ݾ�
    IO_EXPAND_AMT            IN OUT NUMBER,                      --���ؼҵ�ݾ�
    IO_DONATE_MAX_AMT        IN OUT NUMBER,                      --�ѵ�

    IO_TDUC_DUC_TT_AMT       IN OUT NUMBER,                      --��������(���⼼��) �ջ�
    IO_CAL_TDUC_TEMP_AMT     IN OUT NUMBER,                      --��������(���⼼��) ����
    IO_SPCL_DUC_AMT          IN OUT NUMBER,                      --Ư���ҵ�����հ�
    IO_STAD_TAXDUC_OBJ_AMT   IN OUT NUMBER,                      --ǥ�ؼ��װ����հ�
    
    IO_GONGJE_SUM_AMT        IN OUT NUMBER,                      --�������ݾ�-�հ�    
    IO_GONGJE_TAX_AMT        IN OUT NUMBER,                      --���װ����ݾ�-�հ�

    IN_INPT_ID               IN   PAYM432.INPT_ID         %TYPE,
    IN_INPT_IP               IN   PAYM432.INPT_IP         %TYPE,
    OUT_RTN                  IN OUT INTEGER,
    OUT_MSG                  IN OUT VARCHAR2
)
IS
    V_DONATE_AMT                            NUMBER(15) := 0;                   --�ٷμҵ�ݾ�        
    V_EXPAND_AMT                            NUMBER(15) := 0;                   --���ؼҵ�ݾ�
    V_DONATE_MAX_AMT                        NUMBER(15) := 0;                   --�ѵ� 
    V_DONATE_BASIC_AMT                      NUMBER(15) := 0;                   --��α�����ݾ�
    
    V_GONGJE_SUM_AMT                        NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_SUM_TOT_AMT                    NUMBER(15) := 0;                   --�������ݾ�-���հ�    
    V_GONGJE_INCOME_AMT                     NUMBER(15) := 0;                   --�������ݾ�-�ҵ���� ��� �հ�
    V_GONGJE_TAX_AMT                        NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��� �հ�    
    V_GONGJE_TAX_A_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 15% ���������
    V_GONGJE_TAX_B_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 30(25)% ���������
    V_GONGJE_TAX_C_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��Ÿ(100/110)    
    V_GONGJE_SUM_RATEAMT                    NUMBER(15) := 0;                   --���װ����ݾ�-�հ�
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

    
BEGIN

    /* ���װ���, �̿� ���� */
    BEGIN
        SELECT NVL(SUM(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0)),0)
          INTO V_DONATE_BASIC_AMT
          FROM PAYM423 A, PAYM421 B --��⵵ ��� ���� ����
         WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
           AND A.YY             = IN_YY
           AND A.YRETXA_SEQ     = IN_YRETXA_SEQ 
           AND A.CNTRIB_TYPE_CD = 'A032400008'
           AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.SETT_FG        = IN_SETT_FG
           AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
           AND A.YY             = B.YY
           AND A.YRETXA_SEQ     = B.YRETXA_SEQ 
           AND A.SETT_FG        = B.SETT_FG
           AND A.RPST_PERS_NO   = B.RPST_PERS_NO
           AND A.FM_SEQ         = B.FM_SEQ
           AND B.FM_REL_CD      = 'A034600001'  -- ���θ�
           AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')          --�ҵ��Ǹ� üũ �Ǵ� ����
        ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 V_DONATE_BASIC_AMT := 0;
    END;
    
    V_DONATE_AMT := IO_BASIC_AMT;                        --�ٷμҵ�ݾ�  
    V_EXPAND_AMT := IO_EXPAND_AMT - IO_GONGJE_SUM_AMT;   --���ؼҵ�ݾ�  
    V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 0.3);       --�ѵ�
    V_CAL_TDUC_TEMP_AMT := IO_CAL_TDUC_TEMP_AMT;         --��������(���⼼��)                     
    V_SPCL_DUC_AMT := IO_SPCL_DUC_AMT;                   --Ư���ҵ�����հ�                    
    V_STAD_TAXDUC_OBJ_AMT := IO_STAD_TAXDUC_OBJ_AMT;     --ǥ�ؼ��װ����հ�                                 
        
    <<RECALCULATION>>
        
    IF V_DONATE_BASIC_AMT > 0 THEN
        -- �������ݾ� �հ�
        V_GONGJE_SUM_AMT := LEAST(V_DONATE_BASIC_AMT, V_DONATE_MAX_AMT);                
        V_GONGJE_SUM_TOT_AMT := V_GONGJE_SUM_TOT_AMT + V_GONGJE_SUM_AMT;                    
        V_GONGJE_INCOME_AMT := 0;
        -- �������ݾ�-���װ��� ��� �հ� 
        V_GONGJE_TAX_AMT := V_GONGJE_SUM_AMT;                
        --�������ݾ�-���װ��� 15% ���������
        IF (IO_GONGJE_TAX_AMT > 10000000) THEN 
            V_GONGJE_TAX_A_AMT := 0;
        ELSE
            V_GONGJE_TAX_A_AMT := LEAST((10000000 - IO_GONGJE_TAX_AMT),V_GONGJE_TAX_AMT);   
        END IF;            
        --�������ݾ�-���װ��� 30(25)% ���������
        V_GONGJE_TAX_B_AMT := GREATEST(0, V_GONGJE_TAX_AMT - V_GONGJE_TAX_A_AMT);
        V_GONGJE_TAX_C_AMT := 0;                
        --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
        V_GONGJE_TAX_A_RATEAMT := CEIL(V_GONGJE_TAX_A_AMT * 0.15);
        --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
        V_GONGJE_TAX_B_RATEAMT := CEIL(V_GONGJE_TAX_B_AMT * 0.30);
        V_GONGJE_TAX_C_RATEAMT := 0;
        --���װ����ݾ�-�հ�
        V_GONGJE_SUM_RATEAMT := V_GONGJE_TAX_A_RATEAMT + V_GONGJE_TAX_B_RATEAMT + V_GONGJE_TAX_C_RATEAMT;                       
    END IF;
 
    IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- ��������(���⼼��) �ܾ��� 0�̻��̸�                             
        IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_SUM_RATEAMT THEN  -- ��������(���⼼��) �ܾ��� ���װ����ݾ�-�հ� ���� �۴ٸ�                 
            IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_TAX_A_RATEAMT THEN               
                /*  ���� ó�� : ��α�����ݾ� = (���װ����ݾ�(�հ�) -  ��������(���⼼��)) / ( 100 / 110)(���������) */
                V_DONATE_BASIC_AMT := CEIL((V_GONGJE_SUM_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 15) ;
            ELSE
                /*  ���� ó�� : ��α�����ݾ� = (���װ����ݾ�(�հ�) -  ��������(���⼼��)) * 100 / 15%(���������) */
                V_DONATE_BASIC_AMT := CEIL((V_GONGJE_SUM_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 30) ;                
            END IF;                        
            GOTO RECALCULATION;               
        ELSE
            -- ��α�����ݾ� �� �ѵ� ���� ũ�ٸ�            
            IF (V_DONATE_BASIC_AMT > V_DONATE_MAX_AMT) THEN
                V_CNTRIB_PREAMT      := 0;                                           -- ��α� ������� �����ݾ�
                V_CNTRIB_GONGAMT     := V_DONATE_BASIC_AMT;                          -- ��α� ��� �����ݾ�
                V_CNTRIB_DESTAMT     := V_DONATE_BASIC_AMT - V_DONATE_MAX_AMT;       -- ��α� ��� �Ҹ�ݾ�
                V_CNTRIB_OVERAMT     := 0;                                           -- ��α� ��� �̿��ݾ�
            ELSE
                V_CNTRIB_PREAMT      := 0;                                           -- ��α� ������� �����ݾ�
                V_CNTRIB_GONGAMT     := V_DONATE_BASIC_AMT;                          -- ��α� ��� �����ݾ�
                V_CNTRIB_DESTAMT     := 0;                                           -- ��α� ��� �Ҹ�ݾ�
                V_CNTRIB_OVERAMT     := 0;                                           -- ��α� ��� �̿��ݾ�
            END IF;                
        END IF;          
    ELSE            
        V_CNTRIB_PREAMT      := 0;                                                   -- ��α� ������� �����ݾ�
        V_CNTRIB_GONGAMT     := 0;                                                   -- ��α� ��� �����ݾ�
        V_CNTRIB_DESTAMT     := V_DONATE_BASIC_AMT;                                  -- ��α� ��� �Ҹ�ݾ�
        V_CNTRIB_OVERAMT     := 0;                                                   -- ��α� ��� �̿��ݾ�                           
    END IF;

    /* �������� ��α�����ó�� */      
    IF IN_USING = 'T' THEN 
        SP_PAYM410B_2019_DONATE_SAVE(IN_BIZR_DEPT_CD, IN_YY, IN_SETT_FG, IN_RPST_PERS_NO, 'A032400008', IN_YY, V_DONATE_BASIC_AMT, V_CNTRIB_PREAMT, V_CNTRIB_GONGAMT, V_CNTRIB_DESTAMT, V_CNTRIB_OVERAMT, IN_INPT_ID, IN_INPT_IP, OUT_RTN, OUT_MSG);                 
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
    -- Ư���ҵ���� ���
    V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_GONGJE_SUM_RATEAMT;        
    IF V_SPCL_DUC_AMT  <= 0  THEN
         V_SPCL_DUC_AMT := 0 ;
    END IF;     
    -- ǥ�ؼ��װ��� ���
    V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_GONGJE_SUM_RATEAMT;
    IF V_STAD_TAXDUC_OBJ_AMT  <= 0  THEN
         V_STAD_TAXDUC_OBJ_AMT := 0 ;
    END IF; 

    -- ���⼼��(����, �ջ�), Ư���ҵ����, ǥ�ؼ��װ���     
    IO_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT; 
    IO_CAL_TDUC_TEMP_AMT := V_CAL_TDUC_TEMP_AMT;   
    IO_SPCL_DUC_AMT := V_SPCL_DUC_AMT; 
    IO_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT; 
    --
    IO_EXPAND_AMT := V_EXPAND_AMT;        
    IO_GONGJE_SUM_AMT := V_GONGJE_SUM_AMT;
    IO_GONGJE_TAX_AMT := V_GONGJE_TAX_AMT;
    IO_EXPAND_AMT := V_EXPAND_AMT;
    IO_DONATE_MAX_AMT := V_DONATE_MAX_AMT;
    --�츮�������ձ�αݿ��� ���� (���رݾ�, �������ݾ�-�հ�) �� ������α� ���ؼҵ�ݾ� ���� ���� IN OUT
    IO_EXPAND_AMT := V_EXPAND_AMT;        
    IO_GONGJE_SUM_AMT := V_GONGJE_SUM_TOT_AMT;
/*
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S ***************************************************************************************' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> �ٷ�/����/�ѵ�(100%) �ݾ� : ' || V_DONATE_AMT || ',' || V_EXPAND_AMT || ',' ||  V_DONATE_MAX_AMT);
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ��α�����ݾ� : ' || V_DONATE_BASIC_AMT );    
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> �������ݾ�-�հ� : ' || V_GONGJE_SUM_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> �������ݾ�-�ҵ���� ��� �հ� : ' || V_GONGJE_INCOME_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> �������ݾ�-���װ��� ��� �հ� : ' || V_GONGJE_TAX_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> �������ݾ�-���װ��� 15% ��������� : ' || V_GONGJE_TAX_A_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> �������ݾ�-���װ��� 30(25)% ��������� : ' || V_GONGJE_TAX_B_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> �������ݾ�-���װ��� ��Ÿ(100/110) : ' || V_GONGJE_TAX_C_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ���װ����ݾ�-�հ� : ' || V_GONGJE_SUM_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ���װ����ݾ�-���װ��� 15% ���뼼�װ����� : ' || V_GONGJE_TAX_A_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ���װ����ݾ�-���װ��� 30(25)% ���뼼�װ����� : ' || V_GONGJE_TAX_B_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ����� : ' || V_GONGJE_TAX_C_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ������� �����ݾ� : ' || V_CNTRIB_PREAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ���     �����ݾ� : ' || V_CNTRIB_GONGAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ���     �Ҹ�ݾ� : ' || V_CNTRIB_DESTAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> ���     �̿��ݾ� : ' || V_CNTRIB_OVERAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W E ***************************************************************************************' );
*/
END SP_PAYM410B_2019_DONATE_W;
/