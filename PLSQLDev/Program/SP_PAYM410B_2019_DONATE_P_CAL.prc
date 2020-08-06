CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_P_CAL
/***************************************************************************************
�� ü �� : SP_PAYM410B_2019_DONATE_P_CAL
��    �� : �������� ��ġ�ڱݱ�αݰ��
�� �� �� : 2020.01.31.
�� �� �� : �ڿ���
��������
 1.������: 2020.01.31.
   ������: �ڿ���
   ��  ��: �������� ��ġ�ڱݱ�αݰ�� �ű�
Return�� :
������� :
****************************************************************************************/
(
    IN_DONATE_AMT            IN NUMBER,                      --�ٷμҵ�ݾ�
    IN_EXPAND_AMT            IN NUMBER,                      --���ؼҵ�ݾ�
    IN_DONATE_MAX_AMT        IN NUMBER,                      --�ѵ�
    IN_DONATE_BASIC_AMT      IN NUMBER,                      --��α�����ݾ�
    IO_GONGJE_PSUM_RATEAMT   IN OUT NUMBER,                  --���װ����ݾ��հ�
    IN_DEBUG                 IN VARCHAR2                     --Debug(TRUE, FALSE)
)
IS
    V_DONATE_AMT                            NUMBER(15) := 0;                   --�ٷμҵ�ݾ�        
    V_EXPAND_AMT                            NUMBER(15) := 0;                   --���ؼҵ�ݾ�
    V_DONATE_MAX_AMT                        NUMBER(15) := 0;                   --�ѵ� 
    V_DONATE_BASIC_AMT                      NUMBER(15) := 0;                   --��α�����ݾ�
    
    /* �հ� : 10���� ����, 10 ���� �ʰ� */
    V_GONGJE_SUM_AMT                        NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_INCOME_AMT                     NUMBER(15) := 0;                   --�������ݾ�-�ҵ���� ��� �հ�
    V_GONGJE_TAX_AMT                        NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��� �հ�    
    V_GONGJE_TAX_A_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 15% ���������
    V_GONGJE_TAX_B_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 30(25)% ���������
    V_GONGJE_TAX_C_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��Ÿ(100/110)    
    V_GONGJE_SUM_RATEAMT                    NUMBER(15) := 0;                   --���װ����ݾ�-�հ�
    V_GONGJE_TAX_A_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
    V_GONGJE_TAX_B_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
    V_GONGJE_TAX_C_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ�����

    /* 10���� ���� */
    V_GONGJE_PSUM_AMT                        NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_PINCOME_AMT                     NUMBER(15) := 0;                   --�������ݾ�-�ҵ���� ��� �հ�
    V_GONGJE_PTAX_AMT                        NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��� �հ�    
    V_GONGJE_PTAX_A_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 15% ���������
    V_GONGJE_PTAX_B_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 30(25)% ���������
    V_GONGJE_PTAX_C_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��Ÿ(100/110)    
    V_GONGJE_PSUM_RATEAMT                    NUMBER(15) := 0;                   --���װ����ݾ�-�հ�
    V_GONGJE_PTAX_A_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
    V_GONGJE_PTAX_B_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
    V_GONGJE_PTAX_C_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ�����

    /* 10���� �ʰ� */
    V_GONGJE_NSUM_AMT                        NUMBER(15) := 0;                   --�������ݾ�-�հ�
    V_GONGJE_NINCOME_AMT                     NUMBER(15) := 0;                   --�������ݾ�-�ҵ���� ��� �հ�
    V_GONGJE_NTAX_AMT                        NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��� �հ�    
    V_GONGJE_NTAX_A_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 15% ���������
    V_GONGJE_NTAX_B_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� 30(25)% ���������
    V_GONGJE_NTAX_C_AMT                      NUMBER(15) := 0;                   --�������ݾ�-���װ��� ��Ÿ(100/110)    
    V_GONGJE_NSUM_RATEAMT                    NUMBER(15) := 0;                   --���װ����ݾ�-�հ�
    V_GONGJE_NTAX_A_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
    V_GONGJE_NTAX_B_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
    V_GONGJE_NTAX_C_RATEAMT                  NUMBER(15) := 0;                   --���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ�����

BEGIN
    
    V_DONATE_AMT := NVL(IN_DONATE_AMT,0);                  --�ٷμҵ�ݾ�  
    V_EXPAND_AMT := V_DONATE_AMT;                          --���ؼҵ�ݾ�  
    V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 100 / 100);   --�ѵ�  
    V_DONATE_BASIC_AMT := IN_DONATE_BASIC_AMT;             --��α�����ݾ�
    
    IF V_DONATE_BASIC_AMT > 0 THEN

        -- �������ݾ� �հ�
        V_GONGJE_SUM_AMT := LEAST(V_DONATE_BASIC_AMT, V_DONATE_MAX_AMT);                
        
        IF V_DONATE_BASIC_AMT < 100000 THEN
                
            /* 10�������� */  
            -- �������ݾ� 10�������� �հ�
            V_GONGJE_PSUM_AMT := LEAST(V_GONGJE_SUM_AMT, 100000);        
            V_GONGJE_PINCOME_AMT := 0;
            -- �������ݾ�-���װ��� ��� �հ�
            V_GONGJE_PTAX_AMT := V_GONGJE_PSUM_AMT;
                            
            V_GONGJE_PTAX_A_AMT := 0;
            V_GONGJE_PTAX_B_AMT := 0;
            --�������ݾ�-���װ��� ��Ÿ(100/110)
            V_GONGJE_PTAX_C_AMT := V_GONGJE_PTAX_AMT;
                
            V_GONGJE_PTAX_A_RATEAMT := 0;
            V_GONGJE_PTAX_B_RATEAMT := 0;
            --���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ�����
            V_GONGJE_PTAX_C_RATEAMT := TRUNC(V_GONGJE_PTAX_C_AMT * 100 / 110);
            --���װ����ݾ�-�հ�
            V_GONGJE_PSUM_RATEAMT := V_GONGJE_PTAX_A_RATEAMT + V_GONGJE_PTAX_B_RATEAMT + V_GONGJE_PTAX_C_RATEAMT;
                
        ELSE
            
            /* 10�������� */  
            -- �������ݾ� 10�������� �հ�
            V_GONGJE_PSUM_AMT := LEAST(V_GONGJE_SUM_AMT, 100000);        
            V_GONGJE_PINCOME_AMT := 0;
            -- �������ݾ�-���װ��� ��� �հ�
            V_GONGJE_PTAX_AMT := V_GONGJE_PSUM_AMT;
                            
            V_GONGJE_PTAX_A_AMT := 0;
            V_GONGJE_PTAX_B_AMT := 0;
            --�������ݾ�-���װ��� ��Ÿ(100/110)
            V_GONGJE_PTAX_C_AMT := V_GONGJE_PTAX_AMT;
                
            V_GONGJE_PTAX_A_RATEAMT := 0;
            V_GONGJE_PTAX_B_RATEAMT := 0;
            --���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ�����
            V_GONGJE_PTAX_C_RATEAMT := TRUNC(V_GONGJE_PTAX_C_AMT * 100 / 110);
            --���װ����ݾ�-�հ�
            V_GONGJE_PSUM_RATEAMT := V_GONGJE_PTAX_A_RATEAMT + V_GONGJE_PTAX_B_RATEAMT + V_GONGJE_PTAX_C_RATEAMT;            
            
            /* 10���� �ʰ� */
            -- �������ݾ� 10�����ʰ� �հ�                        
            V_GONGJE_NSUM_AMT := V_GONGJE_SUM_AMT - V_GONGJE_PSUM_AMT;
            V_GONGJE_NINCOME_AMT := 0;
            -- �������ݾ�-���װ��� ��� �հ� 
            V_GONGJE_NTAX_AMT := V_GONGJE_NSUM_AMT;
                
            --�������ݾ�-���װ��� 15% ���������
            V_GONGJE_NTAX_A_AMT := LEAST(V_GONGJE_NTAX_AMT, (30000000 - V_GONGJE_PTAX_AMT));        
            --�������ݾ�-���װ��� 30(25)% ���������
            V_GONGJE_NTAX_B_AMT := GREATEST(0, V_GONGJE_NTAX_AMT - V_GONGJE_NTAX_A_AMT);
            V_GONGJE_NTAX_C_AMT := 0;
                
            --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
            V_GONGJE_NTAX_A_RATEAMT := TRUNC(V_GONGJE_NTAX_A_AMT * 0.15);
            --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
            V_GONGJE_NTAX_B_RATEAMT := TRUNC(V_GONGJE_NTAX_B_AMT * 0.25);
            V_GONGJE_NTAX_C_RATEAMT := 0;
            --���װ����ݾ�-�հ�
            V_GONGJE_NSUM_RATEAMT := V_GONGJE_NTAX_A_RATEAMT + V_GONGJE_NTAX_B_RATEAMT + V_GONGJE_NTAX_C_RATEAMT;
                
        END IF;

        V_GONGJE_SUM_AMT := V_GONGJE_PSUM_AMT + V_GONGJE_NSUM_AMT;                       --�������ݾ�-�հ�
        V_GONGJE_INCOME_AMT := V_GONGJE_PINCOME_AMT + V_GONGJE_NINCOME_AMT;              --�������ݾ�-�ҵ���� ��� �հ�
        V_GONGJE_TAX_AMT := V_GONGJE_PTAX_AMT + V_GONGJE_NTAX_AMT;                       --�������ݾ�-���װ��� ��� �հ�    
        V_GONGJE_TAX_A_AMT := V_GONGJE_PTAX_A_AMT + V_GONGJE_NTAX_A_AMT;                 --�������ݾ�-���װ��� 15% ���������
        V_GONGJE_TAX_B_AMT := V_GONGJE_PTAX_B_AMT + V_GONGJE_NTAX_B_AMT;                 --�������ݾ�-���װ��� 30(25)% ���������
        V_GONGJE_TAX_C_AMT := V_GONGJE_PTAX_C_AMT + V_GONGJE_NTAX_C_AMT;                 --�������ݾ�-���װ��� ��Ÿ(100/110)
        V_GONGJE_SUM_RATEAMT := V_GONGJE_PSUM_RATEAMT + V_GONGJE_NSUM_RATEAMT;           --���װ����ݾ�-�հ�
        V_GONGJE_TAX_A_RATEAMT := V_GONGJE_PTAX_A_RATEAMT + V_GONGJE_NTAX_A_RATEAMT;     --���װ����ݾ�-���װ��� 15% ���뼼�װ�����
        V_GONGJE_TAX_B_RATEAMT := V_GONGJE_PTAX_B_RATEAMT + V_GONGJE_NTAX_B_RATEAMT;     --���װ����ݾ�-���װ��� 30(25)% ���뼼�װ�����
        V_GONGJE_TAX_C_RATEAMT := V_GONGJE_PTAX_C_RATEAMT + V_GONGJE_NTAX_C_RATEAMT;     --���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ�����
                
    END IF;
    
    IF IN_DEBUG = TRUE THEN        
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S ***************************************************************************************' );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> �ٷ�/����/�ѵ�(100%) �ݾ� : ' || V_DONATE_AMT || ',' || V_EXPAND_AMT || ',' ||  V_DONATE_MAX_AMT);
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> ��α�����ݾ� : ' || V_DONATE_BASIC_AMT );    
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> �������ݾ�-�հ� : ' || V_GONGJE_SUM_AMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> �������ݾ�-�ҵ���� ��� �հ� : ' || V_GONGJE_INCOME_AMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> �������ݾ�-���װ��� ��� �հ� : ' || V_GONGJE_TAX_AMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> �������ݾ�-���װ��� 15% ��������� : ' || V_GONGJE_TAX_A_AMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> �������ݾ�-���װ��� 30(25)% ��������� : ' || V_GONGJE_TAX_B_AMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> �������ݾ�-���װ��� ��Ÿ(100/110) : ' || V_GONGJE_TAX_C_AMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> ���װ����ݾ�-�հ� : ' || V_GONGJE_SUM_RATEAMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> ���װ����ݾ�-���װ��� 15% ���뼼�װ����� : ' || V_GONGJE_TAX_A_RATEAMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> ���װ����ݾ�-���װ��� 30(25)% ���뼼�װ����� : ' || V_GONGJE_TAX_B_RATEAMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> ���װ����ݾ�-���װ��� ��Ÿ ���뼼�װ����� : ' || V_GONGJE_TAX_C_RATEAMT );
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P E ***************************************************************************************' );
    END IF;
    
END SP_PAYM410B_2019_DONATE_P_CAL;
/
