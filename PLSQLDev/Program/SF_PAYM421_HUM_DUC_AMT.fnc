CREATE OR REPLACE FUNCTION SF_PAYM421_HUM_DUC_AMT
(
    IN_BIZR_DEPT_CD       IN     VARCHAR2,     --사업자부서코드
    IN_YY                 IN     VARCHAR2,     --년도
    IN_YRETXA_SEQ         IN     VARCHAR2,     --정산차수(2017년추가)
    IN_SETT_FG            IN     VARCHAR2,     --정산구분
    IN_ALLOW_DUC_CD       IN     VARCHAR2,     --수당, 공제코드
    IN_RPST_PERS_NO       IN     VARCHAR2      --대표개인번호 
)
RETURN  NUMBER IS

/*******************************************************************************************************
 파일명              : SF_PAYM421_HUM_DUC_AMT
 버전                : <<1.0.0.0>>
 최초 작성일         : <<2011.12.06>>
 최초 작성자         : 최성준
 UseCase명           :
 내용                : << 해당교직원의 인적공제액을 발췌한다.>>
 수정 작성일         :
 수정 작성자         : 
 수정내용            :
 INPUT               : 
 OUTPUT              : 
 <2017년>
 @VER.2017_0 : 정산차수 INPUT변수로 추가
'924' : 출산ㆍ입양 첫째30만원,둘째50만원,셋째이상 70만원(@VER.2017) 
*******************************************************************************************************/

/********** 변수선언시작 ***********************/
V_COUNT            NUMBER := 0;
V_COUNT2           NUMBER := 0;
V_COUNT3           NUMBER := 0;
V_HUM_DUC_AMT    NUMBER(15) := 0;
/********** 변수선언끝   ***********************/

BEGIN
  IF IN_ALLOW_DUC_CD = '901' THEN    -- 기본공제
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
        END IF;
  ELSIF IN_ALLOW_DUC_CD = '902' THEN    -- 배우자공제  
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
           AND FM_REL_CD      = 'A034600002'                         --배우자
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
        END IF ; 
  ELSIF IN_ALLOW_DUC_CD = '903' THEN    -- 부양자공제  
      BEGIN  
       SELECT count(1)
          INTO V_COUNT
          FROM PAYM421
         WHERE BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND YY             = IN_YY
           AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND SETT_FG        = IN_SETT_FG
           AND RPST_PERS_NO   = IN_RPST_PERS_NO
           AND FM_REL_CD      NOT IN ('A034600001','A034600002')             -- 본인, 배우자 제외
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
  ELSIF IN_ALLOW_DUC_CD = '904' THEN    -- 장애인공제  
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
/*  ELSIF IN_ALLOW_DUC_CD = '905' THEN    -- 경로우대공제65  
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
  ELSIF IN_ALLOW_DUC_CD = '906' THEN    -- 경로우대공제70  
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
  ELSIF IN_ALLOW_DUC_CD = '907' THEN    -- 자녀양육공제6  
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
  ELSIF IN_ALLOW_DUC_CD = '908' THEN    -- 부녀자공제  
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
           AND ((B.HOUSEHOLDER_YN IN ('Y', '1')      /* 배우자 없이 기본공제대상 부양가족이 있는 세대주이거나 배우자가 있는자 */            
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
                       AND C.BASE_DUC_YN    IN ('Y', '1')) > 0 /* 본인외의 가족구성원중 기본공제자가 있는 경우 */
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ;
 
  ELSIF IN_ALLOW_DUC_CD = '909' THEN    -- 다자녀추가공제
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
           AND FM_REL_CD      = 'A034600003'                --직계비속
           --AND TO_NUMBER(YY) - SF_GET_AGE(RES_NO) <= 20 장애인 20세 초과 기본부양자에 대해서도 다자녀 추가공제 가능
        ;
      END; 
   
      IF  V_COUNT  > 1 THEN 
        V_HUM_DUC_AMT := 1000000 + ((V_COUNT -2) * 2000000) ;
      ELSE
        V_HUM_DUC_AMT := 0;  
      END IF ;      
           
        -- 자녀가 1명 이상일 경우 다자녀 추가공제인원은 자녀 
/*      IF V_COUNT > 0 THEN
         V_COUNT := V_COUNT - 1;
      END IF;    

      IF  V_COUNT  > 0 AND V_COUNT  <= 5 THEN 
      BEGIN
            SELECT NVL(MAX(LMT_AMT),0) 
              INTO V_HUM_DUC_AMT 
              FROM PAYM451
             WHERE YY     = IN_YY
               AND CAL_FG = CASE WHEN V_COUNT = 1 THEN 'A034400009'              -- 자녀 2명
                                 WHEN V_COUNT = 2 THEN 'A034400010'              -- 자녀 3명
                                 WHEN V_COUNT = 3 THEN 'A034400011'              -- 자녀 4명
                                 WHEN V_COUNT = 4 THEN 'A034400012'              -- 자녀 5명
                                 ELSE 'A034400013'                               -- 자녀 6명
                            END 
             ;
        EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          V_HUM_DUC_AMT := 0;
      END;
      ELSIF V_COUNT  > 5 THEN     -- 자녀 7명 이상일경우
        V_HUM_DUC_AMT := 1000000 + ((V_COUNT -1) * 2000000) ;
      ELSE
        V_HUM_DUC_AMT := 0;  
      END IF  ; */

  ELSIF IN_ALLOW_DUC_CD = '914' THEN    -- 입양/출산공제  
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
                 AND SEQ    > 0 ;  --이근철
          EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            V_HUM_DUC_AMT := 0;
        END;
            V_HUM_DUC_AMT  :=  V_COUNT * NVL(V_HUM_DUC_AMT,0) ;           
        END IF  ; 
        
        
  ELSIF IN_ALLOW_DUC_CD = '922' THEN    -- 보험한도액
      BEGIN
            SELECT NVL(MAX(LMT_AMT),0) 
                INTO V_HUM_DUC_AMT 
                FROM PAYM451
               WHERE YY = IN_YY
                 AND CAL_FG = 'A034400922'
                 AND SEQ    > 0 ;  --이근철
        EXCEPTION
        WHEN NO_DATA_FOUND  THEN
          V_HUM_DUC_AMT := 0;
      END;
      

  ELSIF IN_ALLOW_DUC_CD = '915' THEN    -- 한부모 공제  
   -- 2019. 직계비속 중 기본공제대상자가 없을 경우 한부모 공제 받을수 없음.
  
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
           AND A.FM_REL_CD      = 'A034600001'   --본인정보
           AND (
                SELECT COUNT(*)
                  FROM PAYM421 B
                 WHERE B.BIZR_DEPT_CD = A.BIZR_DEPT_CD
                   AND B.YY           = A.YY
                   AND B.YRETXA_SEQ   = A.YRETXA_SEQ
                   AND B.SETT_FG      = A.SETT_FG
                   AND B.RPST_PERS_NO = A.RPST_PERS_NO
                   AND B.FM_REL_CD    != 'A034600001'
                   AND B.FM_REL_CD    IN ('A034600003', 'A034600004') /* 직계비속 */
                   AND B.BASE_DUC_YN  IN ('Y', '1')) > 0 /* 본인외의 가족구성원중 기본공제자가 있는 경우 */               
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
    
  ELSIF IN_ALLOW_DUC_CD = '921' THEN    -- 자녀세액공제액
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '921', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;
                  
      IF V_COUNT >= 2 THEN
        V_HUM_DUC_AMT := (2 * 150000) + ((V_COUNT - 2) * 200000);
      ELSE
        V_HUM_DUC_AMT := V_COUNT * 150000; 
      END IF;
      
  ELSIF IN_ALLOW_DUC_CD = '921R' THEN    -- 자녀세액공제액(2014재계산) 
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '921', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;
                  
      IF V_COUNT >= 2 THEN /*(2014재계산)자녀 2명초과 1명당 20만원=> 30만원*/
        V_HUM_DUC_AMT := (2 * 150000) + ((V_COUNT - 2) * 300000);
      ELSE
        V_HUM_DUC_AMT := V_COUNT * 150000; 
      END IF;    
      
  ELSIF IN_ALLOW_DUC_CD = '922R' THEN    -- 6세이하 2명이상 (2014재계산) 
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '907', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;
                  
      IF V_COUNT >= 2 THEN /*(2014재계산) 6세이하 2명이상  1명을 초과하는 1명당 15만원=*/
        V_HUM_DUC_AMT := (V_COUNT-1) * 150000; 
      END IF;        
      
  ELSIF IN_ALLOW_DUC_CD = '923R' THEN    -- 출산ㆍ입양 1명당 30만원 (2014재계산) 
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;                  

        V_HUM_DUC_AMT := V_COUNT * 300000;                   
        
  ELSIF IN_ALLOW_DUC_CD = '924' THEN    -- 출산ㆍ입양 첫째30만원,둘째50만원,셋째이상 70만원(@VER.2017) 
      /* 첫째자녀 */
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914F', IN_RPST_PERS_NO)
        INTO V_COUNT
        FROM DUAL;                  
      /* 둘째자녀 */
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914S', IN_RPST_PERS_NO)
        INTO V_COUNT2
       FROM DUAL;   
      /* 셋째이상 자녀 */  
      SELECT SF_PAYM421_HUM_DUC_CNT(IN_BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, IN_SETT_FG, '914T', IN_RPST_PERS_NO)
        INTO V_COUNT3
        FROM DUAL;  

        V_HUM_DUC_AMT := (V_COUNT * 300000) + (V_COUNT2 * 500000) + (V_COUNT3 * 700000);                   
      
  END IF;
  
  
  
  
  RETURN V_HUM_DUC_AMT;
        
END SF_PAYM421_HUM_DUC_AMT;
/
