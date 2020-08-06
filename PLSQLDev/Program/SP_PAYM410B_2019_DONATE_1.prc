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
참조객체 : 
Return값 : 
참고사항 : 
****************************************************************************************/
(
        IN_BIZR_DEPT_CD          IN   PAYM410.BIZR_DEPT_CD    %TYPE, --사업자부서코드
        IN_YY                    IN   PAYM410.YY              %TYPE, --정산년도
        IN_YRETXA_SEQ            IN   PAYM410.YRETXA_SEQ      %TYPE, --정산차수
        IN_SETT_FG               IN   PAYM410.SETT_FG         %TYPE, --정산구분(A031300001:연말정산, A031300002:중도정산, A031300003:연말정산 시뮬레이션)
        IN_RPST_PERS_NO          IN   PAYM410.RPST_PERS_NO    %TYPE, --대표개인번호
        IN_INPT_ID               IN   PAYM410.INPT_ID         %TYPE,
        IN_INPT_IP               IN   PAYM410.INPT_IP         %TYPE,
        IN_DEPT_CD               IN   BSNS100.MNGT_DEPT_CD    %TYPE DEFAULT null, --관리부서
        
        V_FLAW_CNTRIB_AMT        IN OUT NUMBER(15),      --정치자금기부금발생금액
        V_LABOR_EARN_AMT         IN OUT NUMBER(15),      --근로소득금액
        V_CNTRIB_DUC_AMT         IN OUT NUMBER(15),      --기부금공제금액
        V_CNTRIB_PREAMT          IN OUT NUMBER(15),      --기부금전년까지공제금액
        V_CNTRIB_GONGAMT         IN OUT NUMBER(15),      --기부금당년공제금액
        V_CNTRIB_DESTAMT         IN OUT NUMBER(15),      --기부금당년소멸금액
        V_CNTRIB_OVERAMT         IN OUT NUMBER(15),      --기부금당년이월금액
        
        OUT_RTN                  OUT      INTEGER,
        OUT_MSG                  OUT      VARCHAR2
)
IS
    V_STUNO         ENRO200.STUNO%TYPE;
    V_YN            CHAR(1);    
    
BEGIN

    /** 1.1. 정치자금기부금(20) 전액공제, 이월 없음**/
    BEGIN
        SELECT SUM(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0))
          INTO V_FLAW_CNTRIB_AMT
          FROM PAYM423 A, PAYM421 B --당년도 등록 공제 내역
         WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
           AND A.YY             = IN_YY
           AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
           AND A.CNTRIB_TYPE_CD = 'A032400002' /*정치자금(코드:20)*/
           AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.SETT_FG = V_SETT_FG
           AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
           AND A.YY             = B.YY
           AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
           AND A.SETT_FG        = B.SETT_FG
           AND A.RPST_PERS_NO   = B.RPST_PERS_NO
           AND A.FM_SEQ         = B.FM_SEQ
           AND B.FM_REL_CD      = 'A034600001'  -- 정치자금은 본인만
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
            OUT_MSG := IN_STUNO||' 정보가 없습니다.';
        WHEN OTHERS THEN
            OUT_RTN := 0;
            OUT_MSG := IN_STUNO||' 오류가 발생했습니다.('||SQLCODE||')';
    END;
    
    IF OUT_RTN = 0 THEN
        --OUT_MSG := OUT_MSG||CHR(13)||CHR(10)||CHR(13)||CHR(10)||'\n확인 후 재시도 하세요';
        OUT_MSG := OUT_MSG||'\n확인 후 재시도 하세요';
--        DBMS_OUTPUT.PUT_LINE(OUT_MSG);
        RETURN;
    END IF;

    OUT_RTN := 1;
    OUT_MSG := '정상적으로 처리되었습니다.';
    
    RETURN;
    
END SP_PAYM410B_2019_DONATE_P; 
/
