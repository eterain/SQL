CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_P_CAL
/***************************************************************************************
객 체 명 : SP_PAYM410B_2019_DONATE_P_CAL
내    용 : 연말정산 정치자금기부금계산
작 성 일 : 2020.01.31.
작 성 자 : 박용주
수정내역
 1.수정일: 2020.01.31.
   수정자: 박용주
   내  용: 연말정산 정치자금기부금계산 신규
Return값 :
참고사항 :
****************************************************************************************/
(
    IN_DONATE_AMT            IN NUMBER,                      --근로소득금액
    IN_EXPAND_AMT            IN NUMBER,                      --기준소득금액
    IN_DONATE_MAX_AMT        IN NUMBER,                      --한도
    IN_DONATE_BASIC_AMT      IN NUMBER,                      --기부금지출금액
    IO_GONGJE_PSUM_RATEAMT   IN OUT NUMBER,                  --세액공제금액합계
    IN_DEBUG                 IN VARCHAR2                     --Debug(TRUE, FALSE)
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

BEGIN
    
    V_DONATE_AMT := NVL(IN_DONATE_AMT,0);                  --근로소득금액  
    V_EXPAND_AMT := V_DONATE_AMT;                          --기준소득금액  
    V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 100 / 100);   --한도  
    V_DONATE_BASIC_AMT := IN_DONATE_BASIC_AMT;             --기부금지출금액
    
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
            V_GONGJE_NTAX_A_RATEAMT := TRUNC(V_GONGJE_NTAX_A_AMT * 0.15);
            --세액공제금액-세액공제 30(25)% 적용세액공제액
            V_GONGJE_NTAX_B_RATEAMT := TRUNC(V_GONGJE_NTAX_B_AMT * 0.25);
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
    
    IF IN_DEBUG = TRUE THEN        
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
        DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_P E ***************************************************************************************' );
    END IF;
    
END SP_PAYM410B_2019_DONATE_P_CAL;
/
