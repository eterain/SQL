CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_P
/***************************************************************************************
객 체 명 : SP_PAYM410B_2019_DONATE_P
내    용 : 연말정산 정치자금기부금처리
작 성 일 : 2020.01.31.
작 성 자 : 박용주
수정내역
 1.수정일: 2020.01.31.
   수정자: 박용주
   내  용: 연말정산 정치자금기부금처리 신규
Return값 :
참고사항 :
****************************************************************************************/
(
    IN_USING                 IN   VARCHAR2,
    IN_BIZR_DEPT_CD          IN   PAYM423.BIZR_DEPT_CD    %TYPE, --사업자부서코드
    IN_YY                    IN   PAYM423.YY              %TYPE, --정산년도
    IN_YRETXA_SEQ            IN   PAYM423.YRETXA_SEQ      %TYPE, --정산차수
    IN_SETT_FG               IN   PAYM423.SETT_FG         %TYPE, --정산구분(A031300001:연말정산, A031300002:중도정산, A031300003:연말정산 시뮬레이션)
    IN_RPST_PERS_NO          IN   PAYM423.RPST_PERS_NO    %TYPE, --대표개인번호

    IO_BASIC_AMT             IN OUT NUMBER,                      --근로소득금액
    IO_EXPAND_AMT            IN OUT NUMBER,                      --기준소득금액
    IO_DONATE_MAX_AMT        IN OUT NUMBER,                      --한도
    
    IO_TDUC_DUC_TT_AMT       IN OUT NUMBER,                      --결정세액(산출세액) 합산
    IO_CAL_TDUC_TEMP_AMT     IN OUT NUMBER,                      --결정세액(산출세액) 차감
    IO_SPCL_DUC_AMT          IN OUT NUMBER,                      --특별소득공제합계
    IO_STAD_TAXDUC_OBJ_AMT   IN OUT NUMBER,                      --표준세액공제합계
    
    IO_GONGJE_SUM_AMT        IN OUT NUMBER,                      --공제대상금액-합계
    
    IO_POLITICS_BLW_DUC_OBJ_AMT     IN OUT NUMBER,                      --정치한도이하공제대상금액
    IO_POLITICS_BLW_TAXDUC_AMT      IN OUT NUMBER,                      --정치한도이하세액공제액
    IO_POLITICS_EXCE_DUC_OBJ_AMT    IN OUT NUMBER,                      --정치한도초과공제대상금액
    IO_POLITICS_EXCE_TAXDUC_AMT     IN OUT NUMBER,                      --정치한도초과세액공제액
    
    IN_INPT_ID               IN   PAYM432.INPT_ID         %TYPE,
    IN_INPT_IP               IN   PAYM432.INPT_IP         %TYPE,
    OUT_RTN                  IN OUT INTEGER,
    OUT_MSG                  IN OUT VARCHAR2
)
IS
    V_DONATE_AMT                            NUMBER(15) := 0;                   --근로소득금액        
    V_EXPAND_AMT                            NUMBER(15) := 0;                   --기준소득금액
    V_DONATE_MAX_AMT                        NUMBER(15) := 0;                   --한도 
    V_DONATE_BASIC_AMT                      NUMBER(15) := 0;                   --기부금지출금액
    
    /* 합계 : 10만원 이하, 10 만원 초과 */
    V_GONGJE_SUM_AMT                        NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_INCOME_AMT                     NUMBER(15) := 0;                   --공제대상금액-소득공제 대상 합계
    V_GONGJE_TAX_AMT                        NUMBER(15) := 0;                   --공제대상금액-세액공제 대상 합계    
    V_GONGJE_TAX_A_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 15% 비율적용분
    V_GONGJE_TAX_B_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 30(25)% 비율적용분
    V_GONGJE_TAX_C_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 기타(100/110)    
    V_GONGJE_SUM_RATEAMT                    NUMBER(15) := 0;                   --세액공제금액-합계
    V_GONGJE_TAX_A_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 15% 적용세액공제액
    V_GONGJE_TAX_B_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 30(25)% 적용세액공제액
    V_GONGJE_TAX_C_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 기타 적용세액공제액

    /* 10만원 이하 */
    V_GONGJE_PSUM_AMT                        NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_PINCOME_AMT                     NUMBER(15) := 0;                   --공제대상금액-소득공제 대상 합계
    V_GONGJE_PTAX_AMT                        NUMBER(15) := 0;                   --공제대상금액-세액공제 대상 합계    
    V_GONGJE_PTAX_A_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 15% 비율적용분
    V_GONGJE_PTAX_B_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 30(25)% 비율적용분
    V_GONGJE_PTAX_C_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 기타(100/110)    
    V_GONGJE_PSUM_RATEAMT                    NUMBER(15) := 0;                   --세액공제금액-합계
    V_GONGJE_PTAX_A_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 15% 적용세액공제액
    V_GONGJE_PTAX_B_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 30(25)% 적용세액공제액
    V_GONGJE_PTAX_C_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 기타 적용세액공제액

    /* 10만원 초과 */
    V_GONGJE_NSUM_AMT                        NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_NINCOME_AMT                     NUMBER(15) := 0;                   --공제대상금액-소득공제 대상 합계
    V_GONGJE_NTAX_AMT                        NUMBER(15) := 0;                   --공제대상금액-세액공제 대상 합계    
    V_GONGJE_NTAX_A_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 15% 비율적용분
    V_GONGJE_NTAX_B_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 30(25)% 비율적용분
    V_GONGJE_NTAX_C_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 기타(100/110)    
    V_GONGJE_NSUM_RATEAMT                    NUMBER(15) := 0;                   --세액공제금액-합계
    V_GONGJE_NTAX_A_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 15% 적용세액공제액
    V_GONGJE_NTAX_B_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 30(25)% 적용세액공제액
    V_GONGJE_NTAX_C_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 기타 적용세액공제액
    
    V_CNTRIB_PREAMT                         NUMBER(15) := 0;                    --기부금전년까지공제금액
    V_CNTRIB_GONGAMT                        NUMBER(15) := 0;                    --기부금당년공제금액
    V_CNTRIB_DESTAMT                        NUMBER(15) := 0;                    --기부금당년소멸금액
    V_CNTRIB_OVERAMT                        NUMBER(15) := 0;                    --기부금당년이월금액 
    
    V_TDUC_DUC_TT_AMT                       NUMBER(15) := 0;                    --결정세액(산출세액) 합산 
    V_CAL_TDUC_TEMP_AMT                     NUMBER(15) := 0;                    --결정세액(산출세액) 차감
    V_SPCL_DUC_AMT                          NUMBER(15) := 0;                    --특별소득공제합계
    V_STAD_TAXDUC_OBJ_AMT                   NUMBER(15) := 0;                    --표준세액공제합계

BEGIN

    /* 전액공제, 이월 없음 */
    BEGIN
        SELECT NVL(SUM(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0)),0)
          INTO V_DONATE_BASIC_AMT
          FROM PAYM423 A, PAYM421 B --당년도 등록 공제 내역
         WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
           AND A.YY             = IN_YY
           AND A.YRETXA_SEQ     = IN_YRETXA_SEQ
           AND A.CNTRIB_TYPE_CD = 'A032400002' /*정치자금(코드:20)*/
           AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.SETT_FG        = IN_SETT_FG
           AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
           AND A.YY             = B.YY
           AND A.YRETXA_SEQ     = B.YRETXA_SEQ 
           AND A.SETT_FG        = B.SETT_FG
           AND A.RPST_PERS_NO   = B.RPST_PERS_NO
           AND A.FM_SEQ         = B.FM_SEQ
           AND B.FM_REL_CD      = 'A034600001'  -- 정치자금은 본인만
           ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 V_DONATE_BASIC_AMT := 0;
    END;
    
    V_DONATE_AMT := IO_BASIC_AMT;                          --근로소득금액  
    V_EXPAND_AMT := V_DONATE_AMT;                          --기준소득금액  
    V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 100 / 100);   --한도  
    V_CAL_TDUC_TEMP_AMT := IO_CAL_TDUC_TEMP_AMT;           --결정세액(산출세액)                     
    V_SPCL_DUC_AMT := IO_SPCL_DUC_AMT;                     --특별소득공제합계                    
    V_STAD_TAXDUC_OBJ_AMT := IO_STAD_TAXDUC_OBJ_AMT;       --표준세액공제합계                     
    
    <<RECALCULATION>>
    
    IF V_DONATE_BASIC_AMT > 0 THEN

        -- 공제대상금액 합계
        V_GONGJE_SUM_AMT := LEAST(V_DONATE_BASIC_AMT, V_DONATE_MAX_AMT);                            
        IF V_DONATE_BASIC_AMT < 100000 THEN                
            /* 10만원이하 */  
            -- 공제대상금액 10만원이하 합계
            V_GONGJE_PSUM_AMT := LEAST(V_GONGJE_SUM_AMT, 100000);        
            V_GONGJE_PINCOME_AMT := 0;
            -- 공제대상금액-세액공제 대상 합계
            V_GONGJE_PTAX_AMT := V_GONGJE_PSUM_AMT;                            
            V_GONGJE_PTAX_A_AMT := 0;
            V_GONGJE_PTAX_B_AMT := 0;
            --공제대상금액-세액공제 기타(100/110)
            V_GONGJE_PTAX_C_AMT := V_GONGJE_PTAX_AMT;                
            V_GONGJE_PTAX_A_RATEAMT := 0;
            V_GONGJE_PTAX_B_RATEAMT := 0;
            --세액공제금액-세액공제 기타 적용세액공제액
            V_GONGJE_PTAX_C_RATEAMT := TRUNC(V_GONGJE_PTAX_C_AMT * 100 / 110);
            --세액공제금액-합계
            V_GONGJE_PSUM_RATEAMT := V_GONGJE_PTAX_A_RATEAMT + V_GONGJE_PTAX_B_RATEAMT + V_GONGJE_PTAX_C_RATEAMT;     
                                   
        ELSE                    
            /* 10만원이하 */  
            -- 공제대상금액 10만원이하 합계
            V_GONGJE_PSUM_AMT := LEAST(V_GONGJE_SUM_AMT, 100000);        
            V_GONGJE_PINCOME_AMT := 0;
            -- 공제대상금액-세액공제 대상 합계
            V_GONGJE_PTAX_AMT := V_GONGJE_PSUM_AMT;                            
            V_GONGJE_PTAX_A_AMT := 0;
            V_GONGJE_PTAX_B_AMT := 0;
            --공제대상금액-세액공제 기타(100/110)
            V_GONGJE_PTAX_C_AMT := V_GONGJE_PTAX_AMT;                
            V_GONGJE_PTAX_A_RATEAMT := 0;
            V_GONGJE_PTAX_B_RATEAMT := 0;
            --세액공제금액-세액공제 기타 적용세액공제액
            V_GONGJE_PTAX_C_RATEAMT := TRUNC(V_GONGJE_PTAX_C_AMT * 100 / 110);
            --세액공제금액-합계
            V_GONGJE_PSUM_RATEAMT := V_GONGJE_PTAX_A_RATEAMT + V_GONGJE_PTAX_B_RATEAMT + V_GONGJE_PTAX_C_RATEAMT;   
                                             
            /* 10만원 초과 */
            -- 공제대상금액 10만원초과 합계                        
            V_GONGJE_NSUM_AMT := V_GONGJE_SUM_AMT - V_GONGJE_PSUM_AMT;
            V_GONGJE_NINCOME_AMT := 0;
            -- 공제대상금액-세액공제 대상 합계 
            V_GONGJE_NTAX_AMT := V_GONGJE_NSUM_AMT;                
            --공제대상금액-세액공제 15% 비율적용분
            V_GONGJE_NTAX_A_AMT := LEAST(V_GONGJE_NTAX_AMT, (30000000 - V_GONGJE_PTAX_AMT));        
            --공제대상금액-세액공제 30(25)% 비율적용분
            V_GONGJE_NTAX_B_AMT := GREATEST(0, V_GONGJE_NTAX_AMT - V_GONGJE_NTAX_A_AMT);
            V_GONGJE_NTAX_C_AMT := 0;                
            --세액공제금액-세액공제 15% 적용세액공제액
            V_GONGJE_NTAX_A_RATEAMT := CEIL(V_GONGJE_NTAX_A_AMT * 0.15);
            --세액공제금액-세액공제 30(25)% 적용세액공제액
            V_GONGJE_NTAX_B_RATEAMT := CEIL(V_GONGJE_NTAX_B_AMT * 0.25);
            V_GONGJE_NTAX_C_RATEAMT := 0;
            --세액공제금액-합계
            V_GONGJE_NSUM_RATEAMT := V_GONGJE_NTAX_A_RATEAMT + V_GONGJE_NTAX_B_RATEAMT + V_GONGJE_NTAX_C_RATEAMT;                
            
        END IF;
        
        V_GONGJE_SUM_AMT := V_GONGJE_PSUM_AMT + V_GONGJE_NSUM_AMT;                       --공제대상금액-합계
        V_GONGJE_INCOME_AMT := V_GONGJE_PINCOME_AMT + V_GONGJE_NINCOME_AMT;              --공제대상금액-소득공제 대상 합계
        V_GONGJE_TAX_AMT := V_GONGJE_PTAX_AMT + V_GONGJE_NTAX_AMT;                       --공제대상금액-세액공제 대상 합계    
        V_GONGJE_TAX_A_AMT := V_GONGJE_PTAX_A_AMT + V_GONGJE_NTAX_A_AMT;                 --공제대상금액-세액공제 15% 비율적용분
        V_GONGJE_TAX_B_AMT := V_GONGJE_PTAX_B_AMT + V_GONGJE_NTAX_B_AMT;                 --공제대상금액-세액공제 30(25)% 비율적용분
        V_GONGJE_TAX_C_AMT := V_GONGJE_PTAX_C_AMT + V_GONGJE_NTAX_C_AMT;                 --공제대상금액-세액공제 기타(100/110)
        V_GONGJE_SUM_RATEAMT := V_GONGJE_PSUM_RATEAMT + V_GONGJE_NSUM_RATEAMT;           --세액공제금액-합계
        V_GONGJE_TAX_A_RATEAMT := V_GONGJE_PTAX_A_RATEAMT + V_GONGJE_NTAX_A_RATEAMT;     --세액공제금액-세액공제 15% 적용세액공제액
        V_GONGJE_TAX_B_RATEAMT := V_GONGJE_PTAX_B_RATEAMT + V_GONGJE_NTAX_B_RATEAMT;     --세액공제금액-세액공제 30(25)% 적용세액공제액
        V_GONGJE_TAX_C_RATEAMT := V_GONGJE_PTAX_C_RATEAMT + V_GONGJE_NTAX_C_RATEAMT;     --세액공제금액-세액공제 기타 적용세액공제액
            
    END IF;
    
    IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 결정세액(산출세액) 0 보다 크면             
        IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_SUM_RATEAMT THEN  -- 결정세액(산출세액) 이 세액공제금액-합계 보다 작다면      
            IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_PSUM_RATEAMT THEN               
                /*  재계산 처리 : 기부금지출금액 = (세액공제금액(합계) -  결정세액(산출세액)) / ( 100 / 110)(적용공제율) */
                V_DONATE_BASIC_AMT := CEIL((V_GONGJE_SUM_RATEAMT - V_CAL_TDUC_TEMP_AMT) / ( 100 / 110) ) ;
            ELSE
                /*  재계산 처리 : 기부금지출금액 = (세액공제금액(합계) -  결정세액(산출세액)) * 100 / 15%(적용공제율) */
                V_DONATE_BASIC_AMT := CEIL((V_GONGJE_SUM_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 15) ;                
            END IF;
            GOTO RECALCULATION;    
        ELSE
            -- 기부금지출금액 이 한도보다 크다면
            IF (V_DONATE_BASIC_AMT > V_DONATE_AMT) THEN                                       
                V_CNTRIB_PREAMT      := 0;                                                   -- 기부금 전년까지 공제금액
                V_CNTRIB_GONGAMT     := V_DONATE_BASIC_AMT;                                  -- 기부금 당년 공제금액
                V_CNTRIB_DESTAMT     := V_DONATE_BASIC_AMT - V_DONATE_AMT;                   -- 기부금 당년 소멸금액
                V_CNTRIB_OVERAMT     := 0;                                                   -- 기부금 당년 이월금액
            ELSE
                V_CNTRIB_PREAMT      := 0;                                                   -- 기부금 전년까지 공제금액
                V_CNTRIB_GONGAMT     := V_DONATE_BASIC_AMT;                                  -- 기부금 당년 공제금액
                V_CNTRIB_DESTAMT     := 0;                                                   -- 기부금 당년 소멸금액
                V_CNTRIB_OVERAMT     := 0;                                                   -- 기부금 당년 이월금액
            END IF;                                    
        END IF;
    ELSE
        V_CNTRIB_PREAMT      := 0;                                                   -- 기부금 전년까지 공제금액
        V_CNTRIB_GONGAMT     := 0;                                                   -- 기부금 당년 공제금액
        V_CNTRIB_DESTAMT     := V_DONATE_BASIC_AMT;                                  -- 기부금 당년 소멸금액
        V_CNTRIB_OVERAMT     := 0;                                                   -- 기부금 당년 이월금액               
    END IF;  
     
    /* 연말정산 기부금저장처리 */    
    IF IN_USING = 'T' THEN  
       SP_PAYM410B_2019_DONATE_SAVE(IN_BIZR_DEPT_CD, IN_YY, IN_SETT_FG, IN_RPST_PERS_NO, 'A032400002', IN_YY, V_DONATE_BASIC_AMT, V_CNTRIB_PREAMT, V_CNTRIB_GONGAMT, V_CNTRIB_DESTAMT, V_CNTRIB_OVERAMT, IN_INPT_ID, IN_INPT_IP, OUT_RTN, OUT_MSG);                 
    END IF;
        
    -- 산출세액 계산
    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_GONGJE_SUM_RATEAMT;                
    IF V_TDUC_DUC_TT_AMT  <= 0  THEN
         V_TDUC_DUC_TT_AMT := 0 ;
    END IF;    
    V_CAL_TDUC_TEMP_AMT := V_CAL_TDUC_TEMP_AMT - V_GONGJE_SUM_RATEAMT;
    IF V_CAL_TDUC_TEMP_AMT  <= 0  THEN
         V_CAL_TDUC_TEMP_AMT := 0 ;
    END IF;    
    -- 특별소득공제 계산
    V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_GONGJE_SUM_RATEAMT;        
    IF V_SPCL_DUC_AMT  <= 0  THEN
         V_SPCL_DUC_AMT := 0 ;
    END IF;     
    -- 표준세액공제 계산
    V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_GONGJE_SUM_RATEAMT;
    IF V_STAD_TAXDUC_OBJ_AMT  <= 0  THEN
         V_STAD_TAXDUC_OBJ_AMT := 0 ;
    END IF;     
    
    -- 산출세액(차감, 합산), 특별소득공제, 표준세액공제     
    IO_TDUC_DUC_TT_AMT := IO_TDUC_DUC_TT_AMT + V_TDUC_DUC_TT_AMT; 
    IO_CAL_TDUC_TEMP_AMT := V_CAL_TDUC_TEMP_AMT;   
    IO_SPCL_DUC_AMT := IO_SPCL_DUC_AMT - V_SPCL_DUC_AMT; 
    IO_STAD_TAXDUC_OBJ_AMT := IO_STAD_TAXDUC_OBJ_AMT + V_STAD_TAXDUC_OBJ_AMT; 
    --
    --정치자금기부금에서 계산된 (공제대상금액-합계) 을 법정기부금 기준소득금액 계산시 사용됨 IN OUT
    IO_GONGJE_SUM_AMT := V_GONGJE_SUM_AMT; 
    
    IO_POLITICS_BLW_DUC_OBJ_AMT     := V_GONGJE_PSUM_AMT;                     --정치한도이하공제대상금액
    IO_POLITICS_BLW_TAXDUC_AMT      := V_GONGJE_PSUM_RATEAMT;                 --정치한도이하세액공제액
    IO_POLITICS_EXCE_DUC_OBJ_AMT    := V_GONGJE_NSUM_AMT;                     --정치한도초과공제대상금액
    IO_POLITICS_EXCE_TAXDUC_AMT     := V_GONGJE_NSUM_RATEAMT;                 --정치한도초과세액공제액                        
                
/*
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S ***************************************************************************************' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 근로/기준/한도(100%) 금액 : ' || V_DONATE_AMT || ',' || V_EXPAND_AMT || ',' ||  V_DONATE_MAX_AMT);
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 기부금지출금액 : ' || V_DONATE_BASIC_AMT );    
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 공제대상금액-합계 : ' || V_GONGJE_SUM_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 공제대상금액-소득공제 대상 합계 : ' || V_GONGJE_INCOME_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 공제대상금액-세액공제 대상 합계 : ' || V_GONGJE_TAX_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 공제대상금액-세액공제 15% 비율적용분 : ' || V_GONGJE_TAX_A_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 공제대상금액-세액공제 30(25)% 비율적용분 : ' || V_GONGJE_TAX_B_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 공제대상금액-세액공제 기타(100/110) : ' || V_GONGJE_TAX_C_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 세액공제금액-합계 : ' || V_GONGJE_SUM_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 세액공제금액-세액공제 15% 적용세액공제액 : ' || V_GONGJE_TAX_A_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 세액공제금액-세액공제 30(25)% 적용세액공제액 : ' || V_GONGJE_TAX_B_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 세액공제금액-세액공제 기타 적용세액공제액 : ' || V_GONGJE_TAX_C_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 전년까지 공제금액 : ' || V_CNTRIB_PREAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 당년     공제금액 : ' || V_CNTRIB_GONGAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 당년     소멸금액 : ' || V_CNTRIB_DESTAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P ==> 당년     이월금액 : ' || V_CNTRIB_OVERAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P E ***************************************************************************************' );
*/
END SP_PAYM410B_2019_DONATE_P;
/
