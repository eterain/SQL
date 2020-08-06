CREATE OR REPLACE FUNCTION SF_PAYM421_HUM_DUC_AMT
(
    IN_BIZR_DEPT_CD       IN     VARCHAR2,     --����ںμ��ڵ�
    IN_YY                 IN     VARCHAR2,     --�⵵
    IN_YRETXA_SEQ         IN     VARCHAR2,     --��������(2017���߰�)
    IN_SETT_FG            IN     VARCHAR2,     --���걸��
    IN_ALLOW_DUC_CD       IN     VARCHAR2,     --����, �����ڵ�
    IN_RPST_PERS_NO       IN     VARCHAR2      --��ǥ���ι�ȣ 
)
RETURN  NUMBER IS

/*******************************************************************************************************
 ���ϸ�              : SF_PAYM421_HUM_DUC_AMT
 ����                : <<1.0.0.0>>
 ���� �ۼ���         : <<2011.12.06>>
 ���� �ۼ���         : �ּ���
 UseCase��           :
 ����                : << �ش米������ ������������ �����Ѵ�.>>
 ���� �ۼ���         :
 ���� �ۼ���         : 
 ��������            :
 INPUT               : 
 OUTPUT              : 
 <2017��>
 @VER.2017_0 : �������� INPUT������ �߰�
'924' : �����Ծ� ù°30����,��°50����,��°�̻� 70����(@VER.2017) 
*******************************************************************************************************/

/********** ����������� ***********************/
V_COUNT            NUMBER := 0;
V_COUNT2           NUMBER := 0;
V_COUNT3           NUMBER := 0;
V_HUM_DUC_AMT    NUMBER(15) := 0;
/********** ��������   ***********************/

BEGIN
  IF IN_ALLOW_DUC_CD = '901' THEN    -- �⺻����
    BEGIN 
        SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD  = IN_BIZR_DEPT_CD
           AND YY            = IN_YY
           AND YRETXA_SEQ    = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG       = IN_SETT_FG
           AND RPST_PERS_NO  = IN_RPST_PERS_NO
           AND BASE_DUC_YN   IN ('Y','1')
         ;
        EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          V_HUM_DUC_AMT := 0;
    END;  
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400001' 
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
        END IF;
  ELSIF IN_ALLOW_DUC_CD = '902' THEN    -- ����ڰ���  
    BEGIN 
         SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND BASE_DUC_YN    IN ('Y','1')
           AND FM_REL_CD      = 'A034600002'                         --�����
        ;
    END;
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400002' 
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
        END IF ; 
  ELSIF IN_ALLOW_DUC_CD = '903' THEN    -- �ξ��ڰ���  
      BEGIN  
       SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND FM_REL_CD      NOT IN ('A034600001','A034600002')             -- ����, ����� ����
           AND BASE_DUC_YN IN ('Y','1')                       
        ;
      END;
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400003'
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
  ELSIF IN_ALLOW_DUC_CD = '904' THEN    -- ����ΰ���  
      BEGIN  
        SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD  = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND BASE_DUC_YN    IN ('Y','1')
           AND HIND_DUC_YN  IN ('Y','1')
        ;
      END;
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400004'
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
/*  ELSIF IN_ALLOW_DUC_CD = '905' THEN    -- ��ο�����65  
      BEGIN  
         SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE  BIZR_DEPT_CD  = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND BASE_DUC_YN  IN ('Y','1')
           AND TO_NUMBER(YY) - SF_GET_AGE(RES_NO) >= 65
        ;
      END;
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400005'  ;
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; */
  ELSIF IN_ALLOW_DUC_CD = '906' THEN    -- ��ο�����70  
      BEGIN  
        SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD  = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND BASE_DUC_YN    IN ('Y','1')
           AND PATH_PREF_DUC_YN IN ('Y','1')
        ;
      END;
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400006'
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
  ELSIF IN_ALLOW_DUC_CD = '907' THEN    -- �ڳ��������6  
      BEGIN  
        SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND BASE_DUC_YN    IN ('Y','1')
           AND BRED_DUC_YN    IN ('Y','1')
        ;
      END;
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400007'
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
  ELSIF IN_ALLOW_DUC_CD = '908' THEN    -- �γ��ڰ���  
      BEGIN  
        SELECT COUNT(*)
          INTO V_COUNT
          FROM PAYM421 A
             , PAYM420 B
         WHERE A.BIZR_DEPT_CD  = IN_BIZR_DEPT_CD
           AND A.YY             = IN_YY
           AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND A.SETT_FG        = IN_SETT_FG
           AND A.RPST_PERS_NO   = IN_RPST_PERS_NO
           AND A.BASE_DUC_YN    IN ('Y', '1')
           AND A.WOMN_DUC_YN    IN ('Y', '1')
           AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
           AND A.YY             = B.YY
           AND A.YRETXA_SEQ     = B.YRETXA_SEQ
           AND A.SETT_FG        = B.SETT_FG
           AND A.RPST_PERS_NO   = B.RPST_PERS_NO
           AND ((B.HOUSEHOLDER_YN IN ('Y', '1')      /* ����� ���� �⺻������� �ξ簡���� �ִ� �������̰ų� ����ڰ� �ִ��� */            
               AND (SELECT COUNT(*)
                      FROM PAYM421 C
                     WHERE C.BIZR_DEPT_CD = A.BIZR_DEPT_CD
                       AND C.YY           = A.YY
                       AND C.YRETXA_SEQ   = A.YRETXA_SEQ
                       AND C.SETT_FG      = A.SETT_FG
                       AND C.RPST_PERS_NO = A.RPST_PERS_NO
                       
                       --eterain
                       AND C.YRETXA_SEQ = IN_YRETXA_SEQ
                       --eterain
                       
                       AND C.FM_REL_CD    != 'A034600001'
                       AND C.BASE_DUC_YN    IN ('Y', '1')) > 0 /* ���ο��� ������������ �⺻�����ڰ� �ִ� ��� */
                AND NOT EXISTS (SELECT 1
                       FROM PAYM421 D
                       WHERE D.BIZR_DEPT_CD = A.BIZR_DEPT_CD
                       AND D.YY           = A.YY
                       AND D.YRETXA_SEQ   = A.YRETXA_SEQ
                       AND D.SETT_FG      = A.SETT_FG
                       AND D.RPST_PERS_NO = A.RPST_PERS_NO

                       --eterain
                       AND D.YRETXA_SEQ = IN_YRETXA_SEQ
                       --eterain
                       
                       AND D.FM_REL_CD    = 'A034600002')
                  ) 
               OR EXISTS (SELECT 1
                       FROM PAYM421 E
                       WHERE E.BIZR_DEPT_CD = A.BIZR_DEPT_CD
                       AND E.YY           = A.YY
                       AND E.YRETXA_SEQ   = A.YRETXA_SEQ
                       AND E.SETT_FG      = A.SETT_FG
                       AND E.RPST_PERS_NO = A.RPST_PERS_NO
                       
                       --eterain
                       AND E.YRETXA_SEQ = IN_YRETXA_SEQ
                       --eterain
                       
                       AND E.FM_REL_CD    = 'A034600002')
                  ) 
           ;
      END;
      
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
              SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400008'
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ;
 
  ELSIF IN_ALLOW_DUC_CD = '909' THEN    -- ���ڳ��߰�����
      BEGIN  
        SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND BASE_DUC_YN    IN ('Y','1') 
           AND FM_REL_CD      = 'A034600003'                --������
           --AND TO_NUMBER(YY) - SF_GET_AGE(RES_NO) <= 20 ����� 20�� �ʰ� �⺻�ξ��ڿ� ���ؼ��� ���ڳ� �߰����� ����
        ;
      END; 
   
      IF  V_COUNT  > 1 THEN 
        V_HUM_DUC_AMT := 1000000 + ((V_COUNT -2) * 2000000) ;
      ELSE
        V_HUM_DUC_AMT := 0;  
      END IF ;      
           
        -- �ڳడ 1�� �̻��� ��� ���ڳ� �߰������ο��� �ڳ� 
/*      IF V_COUNT > 0 THEN
         V_COUNT := V_COUNT - 1;
      END IF;    

      IF  V_COUNT  > 0 AND V_COUNT  <= 5 THEN 
      BEGIN
            SELECT NVL(MAX(LMT_AMT),0) 
              INTO V_HUM_DUC_AMT 
              FROM PAYM451
             WHERE YY     = IN_YY
               AND CAL_FG = CASE WHEN V_COUNT = 1 THEN 'A034400009'              -- �ڳ� 2��
                                 WHEN V_COUNT = 2 THEN 'A034400010'              -- �ڳ� 3��
                                 WHEN V_COUNT = 3 THEN 'A034400011'              -- �ڳ� 4��
                                 WHEN V_COUNT = 4 THEN 'A034400012'              -- �ڳ� 5��
                                 ELSE 'A034400013'                               -- �ڳ� 6��
                            END 
             ;
        EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          V_HUM_DUC_AMT := 0;
      END;
      ELSIF V_COUNT  > 5 THEN     -- �ڳ� 7�� �̻��ϰ��
        V_HUM_DUC_AMT := 1000000 + ((V_COUNT -1) * 2000000) ;
      ELSE
        V_HUM_DUC_AMT := 0;  
      END IF  ; */

  ELSIF IN_ALLOW_DUC_CD = '914' THEN    -- �Ծ�/������  
      BEGIN  
         SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND CHDBIRTH_DUC_YN IN ('Y','1')
        ;
      END;
        IF  V_COUNT  = 0  THEN 
          V_HUM_DUC_AMT := 0;  
        ELSE 
        BEGIN
               SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400014'
                 AND SEQ    > 0 ;  --�̱�ö
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
        
        
  ELSIF IN_ALLOW_DUC_CD = '922' THEN    -- �����ѵ���
      BEGIN
            SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400922'
                 AND SEQ    > 0 ;  --�̱�ö
        EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          V_HUM_DUC_AMT := 0;
      END;
      

  ELSIF IN_ALLOW_DUC_CD = '915' THEN    -- �Ѻθ� ����  
   -- 2019. ������ �� �⺻��������ڰ� ���� ��� �Ѻθ� ���� ������ ����.
  
    BEGIN 
         SELECT COUNT(1)
          INTO V_COUNT
          FROM PAYM421 A
         WHERE A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.YY             = IN_YY
           AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND A.SETT_FG        = IN_SETT_FG
           AND A.RPST_PERS_NO   = IN_RPST_PERS_NO
           AND A.SINGLE_PARENT_YN  IN ('Y','1')
           AND A.FM_REL_CD      = 'A034600001'   --��������
           AND (
                SELECT COUNT(*)
                  FROM PAYM421 B
                 WHERE B.BIZR_DEPT_CD = A.BIZR_DEPT_CD
                   AND B.YY           = A.YY
                   AND B.YRETXA_SEQ   = A.YRETXA_SEQ
                   AND B.SETT_FG      = A.SETT_FG
                   AND B.RPST_PERS_NO = A.RPST_PERS_NO
                   AND B.FM_REL_CD    != 'A034600001'
                   AND B.FM_REL_CD    IN ('A034600003', 'A034600004') /* ������ */
                   AND B.BASE_DUC_YN  IN ('Y', '1')) > 0 /* ���ο��� ������������ �⺻�����ڰ� �ִ� ��� */               
        ;
    END;
    
    IF  V_COUNT  = 0  THEN 
      V_HUM_DUC_AMT := 0;  
    ELSE 
      BEGIN
            SELECT NVL(MAX(LMT_AMT),0) 
              INTO V_HUM_DUC_AMT 
              FROM PAYM451
             WHERE YY = IN_YY
               AND CAL_FG = 'A034400015' 
               AND SEQ    > 0 ;  
        EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          V_HUM_DUC_AMT := 0;
      END;
      
    END IF ; 
    
  ELSIF IN_ALLOW_DUC_CD = '921' THEN    -- �ڳ༼�װ�����
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '921', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;
                  
      IF V_COUNT >= 2 THEN
        V_HUM_DUC_AMT := (2 * 150000) + ((V_COUNT - 2) * 200000);
      ELSE
        V_HUM_DUC_AMT := V_COUNT * 150000; 
      END IF;
      
  ELSIF IN_ALLOW_DUC_CD = '921R' THEN    -- �ڳ༼�װ�����(2014����) 
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '921', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;
                  
      IF V_COUNT >= 2 THEN /*(2014����)�ڳ� 2���ʰ� 1��� 20����=> 30����*/
        V_HUM_DUC_AMT := (2 * 150000) + ((V_COUNT - 2) * 300000);
      ELSE
        V_HUM_DUC_AMT := V_COUNT * 150000; 
      END IF;    
      
  ELSIF IN_ALLOW_DUC_CD = '922R' THEN    -- 6������ 2���̻� (2014����) 
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '907', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;
                  
      IF V_COUNT >= 2 THEN /*(2014����) 6������ 2���̻�  1���� �ʰ��ϴ� 1��� 15����=*/
        V_HUM_DUC_AMT := (V_COUNT-1) * 150000; 
      END IF;        
      
  ELSIF IN_ALLOW_DUC_CD = '923R' THEN    -- �����Ծ� 1��� 30���� (2014����) 
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;                  

        V_HUM_DUC_AMT := V_COUNT * 300000;                   
        
  ELSIF IN_ALLOW_DUC_CD = '924' THEN    -- �����Ծ� ù°30����,��°50����,��°�̻� 70����(@VER.2017) 
      /* ù°�ڳ� */
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914F', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;                  
      /* ��°�ڳ� */
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914S', IN_RPST_PERS_NO)
        INTO V_COUNT2
       FROM DUAL;   
      /* ��°�̻� �ڳ� */  
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914T', IN_RPST_PERS_NO)
        INTO V_COUNT3
        FROM DUAL;  

        V_HUM_DUC_AMT := (V_COUNT * 300000) + (V_COUNT2 * 500000) + (V_COUNT3 * 700000);                   
      
  END IF;
  
  
  
  
  RETURN V_HUM_DUC_AMT;
        
END SF_PAYM421_HUM_DUC_AMT;
/
