CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_W
/***************************************************************************************
객 체 명 : SP_PAYM410B_2019_DONATE_W
내    용 : 연말정산 우리사주기부금처리
작 성 일 : 2020.01.31.
작 성 자 : 박용주
수정내역
 1.수정일: 2020.01.31.
   수정자: 박용주
   내  용: 연말정산 우리사주기부금처리 신규
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
    IO_GONGJE_TAX_AMT        IN OUT NUMBER,                      --세액공제금액-합계

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
    
    V_GONGJE_SUM_AMT                        NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_SUM_TOT_AMT                    NUMBER(15) := 0;                   --공제대상금액-총합계    
    V_GONGJE_INCOME_AMT                     NUMBER(15) := 0;                   --공제대상금액-소득공제 대상 합계
    V_GONGJE_TAX_AMT                        NUMBER(15) := 0;                   --공제대상금액-세액공제 대상 합계    
    V_GONGJE_TAX_A_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 15% 비율적용분
    V_GONGJE_TAX_B_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 30(25)% 비율적용분
    V_GONGJE_TAX_C_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 기타(100/110)    
    V_GONGJE_SUM_RATEAMT                    NUMBER(15) := 0;                   --세액공제금액-합계
    V_GONGJE_TAX_A_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 15% 적용세액공제액
    V_GONGJE_TAX_B_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 30(25)% 적용세액공제액
    V_GONGJE_TAX_C_RATEAMT                  NUMBER(15) := 0;                   --세액공제금액-세액공제 기타 적용세액공제액

    V_CNTRIB_PREAMT                         NUMBER(15) := 0;                   --기부금전년까지공제금액
    V_CNTRIB_GONGAMT                        NUMBER(15) := 0;                   --기부금당년공제금액
    V_CNTRIB_DESTAMT                        NUMBER(15) := 0;                   --기부금당년소멸금액
    V_CNTRIB_OVERAMT                        NUMBER(15) := 0;                   --기부금당년이월금액      

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
           AND A.CNTRIB_TYPE_CD = 'A032400008'
           AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.SETT_FG        = IN_SETT_FG
           AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
           AND A.YY             = B.YY
           AND A.YRETXA_SEQ     = B.YRETXA_SEQ 
           AND A.SETT_FG        = B.SETT_FG
           AND A.RPST_PERS_NO   = B.RPST_PERS_NO
           AND A.FM_SEQ         = B.FM_SEQ
           AND B.FM_REL_CD      = 'A034600001'  -- 본인만
           AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')          --소득요건만 체크 또는 본인
        ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 V_DONATE_BASIC_AMT := 0;
    END;
    
    V_DONATE_AMT := IO_BASIC_AMT;                        --근로소득금액  
    V_EXPAND_AMT := IO_EXPAND_AMT - IO_GONGJE_SUM_AMT;   --기준소득금액  
    V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 0.3);       --한도
    V_CAL_TDUC_TEMP_AMT := IO_CAL_TDUC_TEMP_AMT;         --결정세액(산출세액)                     
    V_SPCL_DUC_AMT := IO_SPCL_DUC_AMT;                   --특별소득공제합계                    
    V_STAD_TAXDUC_OBJ_AMT := IO_STAD_TAXDUC_OBJ_AMT;     --표준세액공제합계                                 
        
    <<RECALCULATION>>
        
    IF V_DONATE_BASIC_AMT > 0 THEN
        -- 공제대상금액 합계
        V_GONGJE_SUM_AMT := LEAST(V_DONATE_BASIC_AMT, V_DONATE_MAX_AMT);                
        V_GONGJE_SUM_TOT_AMT := V_GONGJE_SUM_TOT_AMT + V_GONGJE_SUM_AMT;                    
        V_GONGJE_INCOME_AMT := 0;
        -- 공제대상금액-세액공제 대상 합계 
        V_GONGJE_TAX_AMT := V_GONGJE_SUM_AMT;                
        --공제대상금액-세액공제 15% 비율적용분
        IF (IO_GONGJE_TAX_AMT > 10000000) THEN 
            V_GONGJE_TAX_A_AMT := 0;
        ELSE
            V_GONGJE_TAX_A_AMT := LEAST((10000000 - IO_GONGJE_TAX_AMT),V_GONGJE_TAX_AMT);   
        END IF;            
        --공제대상금액-세액공제 30(25)% 비율적용분
        V_GONGJE_TAX_B_AMT := GREATEST(0, V_GONGJE_TAX_AMT - V_GONGJE_TAX_A_AMT);
        V_GONGJE_TAX_C_AMT := 0;                
        --세액공제금액-세액공제 15% 적용세액공제액
        V_GONGJE_TAX_A_RATEAMT := CEIL(V_GONGJE_TAX_A_AMT * 0.15);
        --세액공제금액-세액공제 30(25)% 적용세액공제액
        V_GONGJE_TAX_B_RATEAMT := CEIL(V_GONGJE_TAX_B_AMT * 0.30);
        V_GONGJE_TAX_C_RATEAMT := 0;
        --세액공제금액-합계
        V_GONGJE_SUM_RATEAMT := V_GONGJE_TAX_A_RATEAMT + V_GONGJE_TAX_B_RATEAMT + V_GONGJE_TAX_C_RATEAMT;                       
    END IF;
 
    IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 결정세액(산출세액) 잔액이 0이상이면                             
        IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_SUM_RATEAMT THEN  -- 결정세액(산출세액) 잔액이 세액공제금액-합계 보다 작다면                 
            IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_TAX_A_RATEAMT THEN               
                /*  재계산 처리 : 기부금지출금액 = (세액공제금액(합계) -  결정세액(산출세액)) / ( 100 / 110)(적용공제율) */
                V_DONATE_BASIC_AMT := CEIL((V_GONGJE_SUM_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 15) ;
            ELSE
                /*  재계산 처리 : 기부금지출금액 = (세액공제금액(합계) -  결정세액(산출세액)) * 100 / 15%(적용공제율) */
                V_DONATE_BASIC_AMT := CEIL((V_GONGJE_SUM_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 30) ;                
            END IF;                        
            GOTO RECALCULATION;               
        ELSE
            -- 기부금지출금액 이 한도 보다 크다면            
            IF (V_DONATE_BASIC_AMT > V_DONATE_MAX_AMT) THEN
                V_CNTRIB_PREAMT      := 0;                                           -- 기부금 전년까지 공제금액
                V_CNTRIB_GONGAMT     := V_DONATE_BASIC_AMT;                          -- 기부금 당년 공제금액
                V_CNTRIB_DESTAMT     := V_DONATE_BASIC_AMT - V_DONATE_MAX_AMT;       -- 기부금 당년 소멸금액
                V_CNTRIB_OVERAMT     := 0;                                           -- 기부금 당년 이월금액
            ELSE
                V_CNTRIB_PREAMT      := 0;                                           -- 기부금 전년까지 공제금액
                V_CNTRIB_GONGAMT     := V_DONATE_BASIC_AMT;                          -- 기부금 당년 공제금액
                V_CNTRIB_DESTAMT     := 0;                                           -- 기부금 당년 소멸금액
                V_CNTRIB_OVERAMT     := 0;                                           -- 기부금 당년 이월금액
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
        SP_PAYM410B_2019_DONATE_SAVE(IN_BIZR_DEPT_CD, IN_YY, IN_SETT_FG, IN_RPST_PERS_NO, 'A032400008', IN_YY, V_DONATE_BASIC_AMT, V_CNTRIB_PREAMT, V_CNTRIB_GONGAMT, V_CNTRIB_DESTAMT, V_CNTRIB_OVERAMT, IN_INPT_ID, IN_INPT_IP, OUT_RTN, OUT_MSG);                 
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
    --우리사주조합기부금에서 계산된 (기준금액, 공제대상금액-합계) 을 지정기부금 기준소득금액 계산시 사용됨 IN OUT
    IO_EXPAND_AMT := V_EXPAND_AMT;        
    IO_GONGJE_SUM_AMT := V_GONGJE_SUM_TOT_AMT;
/*
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S ***************************************************************************************' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 근로/기준/한도(100%) 금액 : ' || V_DONATE_AMT || ',' || V_EXPAND_AMT || ',' ||  V_DONATE_MAX_AMT);
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 기부금지출금액 : ' || V_DONATE_BASIC_AMT );    
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 공제대상금액-합계 : ' || V_GONGJE_SUM_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 공제대상금액-소득공제 대상 합계 : ' || V_GONGJE_INCOME_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 공제대상금액-세액공제 대상 합계 : ' || V_GONGJE_TAX_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 공제대상금액-세액공제 15% 비율적용분 : ' || V_GONGJE_TAX_A_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 공제대상금액-세액공제 30(25)% 비율적용분 : ' || V_GONGJE_TAX_B_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 공제대상금액-세액공제 기타(100/110) : ' || V_GONGJE_TAX_C_AMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 세액공제금액-합계 : ' || V_GONGJE_SUM_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 세액공제금액-세액공제 15% 적용세액공제액 : ' || V_GONGJE_TAX_A_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 세액공제금액-세액공제 30(25)% 적용세액공제액 : ' || V_GONGJE_TAX_B_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 세액공제금액-세액공제 기타 적용세액공제액 : ' || V_GONGJE_TAX_C_RATEAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W S --------------------------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 전년까지 공제금액 : ' || V_CNTRIB_PREAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 당년     공제금액 : ' || V_CNTRIB_GONGAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 당년     소멸금액 : ' || V_CNTRIB_DESTAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W ==> 당년     이월금액 : ' || V_CNTRIB_OVERAMT );
    DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_W E ***************************************************************************************' );
*/
END SP_PAYM410B_2019_DONATE_W;
/
