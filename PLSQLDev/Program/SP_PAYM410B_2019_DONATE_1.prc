CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_P
/***************************************************************************************
�� ü �� : SP_PAYM410B_2019_DONATE_P
��    �� : �������� ��ġ�ڱݱ�α�ó��
�� �� �� : 2020.01.31.
�� �� �� : �ڿ���
��������   
 1.������: 2020.01.31.
   ������: �ڿ���
   ��  ��: �������� ��ġ�ڱݱ�α�ó�� �ű�
������ü : 
Return�� : 
������� : 
****************************************************************************************/
(
        IN_BIZR_DEPT_CD          IN   PAYM410.BIZR_DEPT_CD    %TYPE, --����ںμ��ڵ�
        IN_YY                    IN   PAYM410.YY              %TYPE, --����⵵
        IN_YRETXA_SEQ            IN   PAYM410.YRETXA_SEQ      %TYPE, --��������
        IN_SETT_FG               IN   PAYM410.SETT_FG         %TYPE, --���걸��(A031300001:��������, A031300002:�ߵ�����, A031300003:�������� �ùķ��̼�)
        IN_RPST_PERS_NO          IN   PAYM410.RPST_PERS_NO    %TYPE, --��ǥ���ι�ȣ
        IN_INPT_ID               IN   PAYM410.INPT_ID         %TYPE,
        IN_INPT_IP               IN   PAYM410.INPT_IP         %TYPE,
        IN_DEPT_CD               IN   BSNS100.MNGT_DEPT_CD    %TYPE DEFAULT null, --�����μ�
        
        V_FLAW_CNTRIB_AMT        IN OUT NUMBER(15),      --��ġ�ڱݱ�αݹ߻��ݾ�
        V_LABOR_EARN_AMT         IN OUT NUMBER(15),      --�ٷμҵ�ݾ�
        V_CNTRIB_DUC_AMT         IN OUT NUMBER(15),      --��αݰ����ݾ�
        V_CNTRIB_PREAMT          IN OUT NUMBER(15),      --��α�������������ݾ�
        V_CNTRIB_GONGAMT         IN OUT NUMBER(15),      --��αݴ������ݾ�
        V_CNTRIB_DESTAMT         IN OUT NUMBER(15),      --��αݴ��Ҹ�ݾ�
        V_CNTRIB_OVERAMT         IN OUT NUMBER(15),      --��αݴ���̿��ݾ�
        
        OUT_RTN                  OUT      INTEGER,
        OUT_MSG                  OUT      VARCHAR2
)
IS
    V_STUNO         ENRO200.STUNO%TYPE;
    V_YN            CHAR(1);    
    
BEGIN

    /** 1.1. ��ġ�ڱݱ�α�(20) ���װ���, �̿� ����**/
    BEGIN
        SELECT SUM(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0))
          INTO V_FLAW_CNTRIB_AMT
          FROM PAYM423 A, PAYM421 B --��⵵ ��� ���� ����
         WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
           AND A.YY             = IN_YY
           AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND A.CNTRIB_TYPE_CD = 'A032400002' /*��ġ�ڱ�(�ڵ�:20)*/
           AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.SETT_FG = V_SETT_FG
           AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
           AND A.YY             = B.YY
           AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
           AND A.SETT_FG        = B.SETT_FG
           AND A.RPST_PERS_NO   = B.RPST_PERS_NO
           AND A.FM_SEQ         = B.FM_SEQ
           AND B.FM_REL_CD      = 'A034600001'  -- ��ġ�ڱ��� ���θ�
           ;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                 V_FLAW_CNTRIB_AMT := 0;
    END;    
    
    BEGIN
        SELECT A.PROG_FG, A.BUSS_FG, ...
          INTO V_PROG_FG, V_BUSS_FG, ...
          FROM ENRO200 A
         WHERE A.STUNO = IN_STUNO;
        
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            OUT_RTN := 0;
            OUT_MSG := IN_STUNO||' ������ �����ϴ�.';
        WHEN OTHERS THEN
            OUT_RTN := 0;
            OUT_MSG := IN_STUNO||' ������ �߻��߽��ϴ�.('||SQLCODE||')';
    END;
    
    IF OUT_RTN = 0 THEN
        --OUT_MSG := OUT_MSG||CHR(13)||CHR(10)||CHR(13)||CHR(10)||'\nȮ�� �� ��õ� �ϼ���';
        OUT_MSG := OUT_MSG||'\nȮ�� �� ��õ� �ϼ���';
--        DBMS_OUTPUT.PUT_LINE(OUT_MSG);
        RETURN;
    END IF;

    OUT_RTN := 1;
    OUT_MSG := '���������� ó���Ǿ����ϴ�.';
    
    RETURN;
    
END SP_PAYM410B_2019_DONATE_P; 
/
