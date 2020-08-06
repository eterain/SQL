CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_UPDATE
/***************************************************************************************
�� ü �� : SP_PAYM410B_2019_DONATE_UPDATE
��    �� : �������� ��α�����ó��
�� �� �� : 2020.01.31.
�� �� �� : �ڿ���
��������
 1.������: 2020.01.31.
   ������: �ڿ���
   ��  ��: �������� ��α�����ó�� �ű�
Return�� :
������� :
****************************************************************************************/
(
    IN_BIZR_DEPT_CD          IN   PAYM423.BIZR_DEPT_CD    %TYPE, --����ںμ��ڵ�
    IN_YY                    IN   PAYM423.YY              %TYPE, --����⵵
    IN_SETT_FG               IN   PAYM423.SETT_FG         %TYPE, --���걸��(A031300001:��������, A031300002:�ߵ�����, A031300003:�������� �ùķ��̼�)
    IN_RPST_PERS_NO          IN   PAYM423.RPST_PERS_NO    %TYPE, --��ǥ���ι�ȣ

    IN_CNTRIB_TYPE_CD        IN   VARCHAR2,
    IN_CNTRIB_YY             IN   VARCHAR2, 
    IN_CNTRIB_GIAMT          IN   PAYM432.CNTRIB_GIAMT    %TYPE, 
    IN_CNTRIB_PREAMT         IN   PAYM432.CNTRIB_PREAMT   %TYPE, 
    IN_CNTRIB_GONGAMT        IN   PAYM432.CNTRIB_GONGAMT  %TYPE, 
    IN_CNTRIB_DESTAMT        IN   PAYM432.CNTRIB_DESTAMT  %TYPE, 
    IN_CNTRIB_OVERAMT        IN   PAYM432.CNTRIB_OVERAMT  %TYPE, 
    
    IN_INPT_ID               IN   PAYM432.INPT_ID         %TYPE,
    IN_INPT_IP               IN   PAYM432.INPT_IP         %TYPE,
    
    OUT_RTN                  OUT      INTEGER,
    OUT_MSG                  OUT      VARCHAR2
)
IS
    V_DONATE_BASIC_AMT                      NUMBER(15) := 0;                   --��α�����ݾ�
    V_CNTRIB_PREAMT                         NUMBER(15) := 0;                   --��α�������������ݾ�
    V_CNTRIB_GONGAMT                        NUMBER(15) := 0;                   --��αݴ������ݾ�
    V_CNTRIB_DESTAMT                        NUMBER(15) := 0;                   --��αݴ��Ҹ�ݾ�
    V_CNTRIB_OVERAMT                        NUMBER(15) := 0;                   --��αݴ���̿��ݾ�      
    
BEGIN
    
    BEGIN                

        V_DONATE_BASIC_AMT := IN_CNTRIB_GIAMT;
        V_CNTRIB_PREAMT    := IN_CNTRIB_PREAMT;
        V_CNTRIB_GONGAMT   := IN_CNTRIB_GONGAMT;
        V_CNTRIB_DESTAMT   := IN_CNTRIB_DESTAMT;
        V_CNTRIB_OVERAMT   := IN_CNTRIB_OVERAMT;
        
        IF ( IN_SETT_FG = 'A031300003' ) THEN  --�������� �ùķ��̼��� ���
            UPDATE PAYM436
               SET CNTRIB_GIAMT = V_DONATE_BASIC_AMT, 
                   CNTRIB_PREAMT = V_CNTRIB_PREAMT, 
                   CNTRIB_GONGAMT = V_CNTRIB_GONGAMT, 
                   CNTRIB_DESTAMT = V_CNTRIB_DESTAMT, 
                   CNTRIB_OVERAMT = V_CNTRIB_OVERAMT 
             WHERE YY = IN_YY
               AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
               AND SETT_FG        = IN_SETT_FG
               AND RPST_PERS_NO   = IN_RPST_PERS_NO
               AND CNTRIB_YY      = IN_CNTRIB_YY
               AND CNTRIB_TYPE_CD = IN_CNTRIB_TYPE_CD
            ;      
        ELSE
            UPDATE PAYM432
               SET CNTRIB_GIAMT = V_DONATE_BASIC_AMT, 
                   CNTRIB_PREAMT = V_CNTRIB_PREAMT, 
                   CNTRIB_GONGAMT = V_CNTRIB_GONGAMT, 
                   CNTRIB_DESTAMT = V_CNTRIB_DESTAMT, 
                   CNTRIB_OVERAMT = V_CNTRIB_OVERAMT 
             WHERE YY = IN_YY
               AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
               AND SETT_FG        = IN_SETT_FG
               AND RPST_PERS_NO   = IN_RPST_PERS_NO
               AND CNTRIB_YY      = IN_CNTRIB_YY
               AND CNTRIB_TYPE_CD = IN_CNTRIB_TYPE_CD
            ;      
        END IF;
        
        OUT_RTN := 1;
        OUT_MSG := 'OK';
        
        COMMIT;
        
        --DBMS_OUTPUT.PUT_LINE('MSG -> ' || SQLCODE || ':' || SQLERRM );
        --DBMS_OUTPUT.PUT_LINE('MSG -> ' || IN_YY || ':' || IN_BIZR_DEPT_CD || ',' || IN_SETT_FG || ',' || IN_RPST_PERS_NO || ',' || IN_CNTRIB_YY || ',' || IN_CNTRIB_TYPE_CD );
         
        EXCEPTION
            WHEN OTHERS THEN
                 OUT_RTN := 0;
                 IF IN_CNTRIB_TYPE_CD = 'A032400002' THEN
                     OUT_MSG := '��ġ�ڱݱ�α� ����� ��������(��ǥ���ι�ȣ : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';
                 ELSIF IN_CNTRIB_TYPE_CD = 'A032400001' THEN
                     OUT_MSG := '������α� ����� ��������(��ǥ���ι�ȣ : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';
                 ELSIF IN_CNTRIB_TYPE_CD = 'A032400006' OR IN_CNTRIB_TYPE_CD = 'A032400007' THEN
                     OUT_MSG := '������α� ����� ��������(��ǥ���ι�ȣ : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';
                 ELSE
                     OUT_MSG := '�츮���ֱ�α� ����� ��������(��ǥ���ι�ȣ : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';                     
                 END IF;
                 RETURN;                        
    END;                           
        
END SP_PAYM410B_2019_DONATE_UPDATE;
/
