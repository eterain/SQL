CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_UPDATE
/***************************************************************************************
객 체 명 : SP_PAYM410B_2019_DONATE_UPDATE
내    용 : 연말정산 기부금저장처리
작 성 일 : 2020.01.31.
작 성 자 : 박용주
수정내역
 1.수정일: 2020.01.31.
   수정자: 박용주
   내  용: 연말정산 기부금저장처리 신규
Return값 :
참고사항 :
****************************************************************************************/
(
    IN_BIZR_DEPT_CD          IN   PAYM423.BIZR_DEPT_CD    %TYPE, --사업자부서코드
    IN_YY                    IN   PAYM423.YY              %TYPE, --정산년도
    IN_SETT_FG               IN   PAYM423.SETT_FG         %TYPE, --정산구분(A031300001:연말정산, A031300002:중도정산, A031300003:연말정산 시뮬레이션)
    IN_RPST_PERS_NO          IN   PAYM423.RPST_PERS_NO    %TYPE, --대표개인번호

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
    V_DONATE_BASIC_AMT                      NUMBER(15) := 0;                   --기부금지출금액
    V_CNTRIB_PREAMT                         NUMBER(15) := 0;                   --기부금전년까지공제금액
    V_CNTRIB_GONGAMT                        NUMBER(15) := 0;                   --기부금당년공제금액
    V_CNTRIB_DESTAMT                        NUMBER(15) := 0;                   --기부금당년소멸금액
    V_CNTRIB_OVERAMT                        NUMBER(15) := 0;                   --기부금당년이월금액      
    
BEGIN
    
    BEGIN                

        V_DONATE_BASIC_AMT := IN_CNTRIB_GIAMT;
        V_CNTRIB_PREAMT    := IN_CNTRIB_PREAMT;
        V_CNTRIB_GONGAMT   := IN_CNTRIB_GONGAMT;
        V_CNTRIB_DESTAMT   := IN_CNTRIB_DESTAMT;
        V_CNTRIB_OVERAMT   := IN_CNTRIB_OVERAMT;
        
        IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
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
                     OUT_MSG := '정치자금기부금 계산결과 생성오류(대표개인번호 : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';
                 ELSIF IN_CNTRIB_TYPE_CD = 'A032400001' THEN
                     OUT_MSG := '법정기부금 계산결과 생성오류(대표개인번호 : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';
                 ELSIF IN_CNTRIB_TYPE_CD = 'A032400006' OR IN_CNTRIB_TYPE_CD = 'A032400007' THEN
                     OUT_MSG := '법정기부금 계산결과 생성오류(대표개인번호 : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';
                 ELSE
                     OUT_MSG := '우리사주기부금 계산결과 생성오류(대표개인번호 : ' || IN_RPST_PERS_NO || SQLCODE || ':' || SQLERRM || ')';                     
                 END IF;
                 RETURN;                        
    END;                           
        
END SP_PAYM410B_2019_DONATE_UPDATE;
/
