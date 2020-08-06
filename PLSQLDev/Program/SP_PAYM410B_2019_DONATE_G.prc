CREATE OR REPLACE PROCEDURE SP_PAYM410B_2019_DONATE_G
/***************************************************************************************
객 체 명 : SP_PAYM410B_2019_DONATE_G
내    용 : 연말정산 지정기부금처리
작 성 일 : 2020.01.31.
작 성 자 : 박용주
수정내역
 1.수정일: 2020.01.31.
   수정자: 박용주
   내  용: 연말정산 지정기부금처리 신규Return값 :
참고사항 :
****************************************************************************************/
(
    IN_USING                 IN   VARCHAR2,
    IN_BIZR_DEPT_CD          IN   PAYM423.BIZR_DEPT_CD    %TYPE, --사업자부서코드
    IN_YY                    IN   PAYM423.YY              %TYPE, --정산년도
    IN_YRETXA_SEQ            IN   PAYM423.YRETXA_SEQ      %TYPE, --정산차수
    IN_SETT_FG               IN   PAYM423.SETT_FG         %TYPE, --정산구분(A031300001:연말정산, A031300002:중도정산, A031300003:연말정산 시뮬레이션)
    IN_RPST_PERS_NO          IN   PAYM423.RPST_PERS_NO    %TYPE, --대표개인번호
    IN_BIZR_REG_NO           IN   PAYM452.BIZR_REG_NO     %TYPE, --사업자부서정보의 사업자번호.    
    
    IO_BASIC_AMT             IN OUT NUMBER,                      --근로소득금액
    IO_EXPAND_AMT            IN OUT NUMBER,                      --기준소득금액
    IO_DONATE_MAX_AMT        IN OUT NUMBER,                      --한도
    
    IO_TDUC_DUC_TT_AMT       IN OUT NUMBER,                      --결정세액(산출세액) 합산
    IO_CAL_TDUC_TEMP_AMT     IN OUT NUMBER,                      --결정세액(산출세액) 차감
    IO_SPCL_DUC_AMT          IN OUT NUMBER,                      --특별소득공제합계
    IO_STAD_TAXDUC_OBJ_AMT   IN OUT NUMBER,                      --표준세액공제합계
    
    IO_GONGJE_SUM_AMT        IN OUT NUMBER,                      --공제대상금액-합계
    IO_GONGJE_TAX_AMT        IN OUT NUMBER,                      --세액공제금액-합계
    IO_B_GONGJE_TAX_AMT      IN OUT NUMBER,                      --법정-세액공제금액-합계
    IO_W_GONGJE_TAX_AMT      IN OUT NUMBER,                      --우리사주-세액공제금액-합계

    IO_APNT_CNTRIB40_DUC_OBJ_AMT   IN OUT NUMBER,                --지정기부(종교외)공제대상금액
    IO_APNT_CNTRIB41_DUC_OBJ_AMT   IN OUT NUMBER,                --지정기부(종교)공제대상금액
    IO_APNT_CNTRIB40_TAXDUC_AMT    IN OUT NUMBER,                --지정기부(종교외)세액공제액
    IO_APNT_CNTRIB41_TAXDUC_AMT    IN OUT NUMBER,                --지정기부(종교)세액공제액
    
    IO_GONGJE_INCOME_ACCU_AMT   IN OUT NUMBER,                   --공제대상금액-소득공제 대상 누적합계
    IO_SPCL_AMT              IN OUT NUMBER,                      --특별소득공제합계
    
    IN_INPT_ID               IN   PAYM432.INPT_ID         %TYPE,
    IN_INPT_IP               IN   PAYM432.INPT_IP         %TYPE,
    OUT_RTN                  IN OUT INTEGER,
    OUT_MSG                  IN OUT VARCHAR2
)
IS
    V_DONATE_AMT                            NUMBER(15) := 0;                   --근로소득금액            
    V_EXPAND_AMT                            NUMBER(15) := 0;                   --기준소득금액
    V_DONATE_MAX_AMT                        NUMBER(15) := 0;                   --한도 
    V_DONATE_MAX1_AMT                        NUMBER(15) := 0;                   --한도 
    V_DONATE_MAX2_AMT                        NUMBER(15) := 0;                   --한도 
    
    V_DONATE_BASIC_AMT                      NUMBER(15) := 0;                   --기부금지출금액
    V_DONATE_BASIC_J_ACCU_AMT               NUMBER(15) := 0;                   --기부금지출금액-종교-누적합계
    V_DONATE_BASIC_E_ACCU_AMT               NUMBER(15) := 0;                   --기부금지출금액-종교외-누적합계
    
    V_GONGJE_SUM_AMT                        NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_SUM_TOTAMT                     NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_SUM1_TOTAMT                     NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_SUM2_TOTAMT                     NUMBER(15) := 0;                   --공제대상금액-합계
    V_GONGJE_SUM_ACCU_AMT                   NUMBER(15) := 0;                   --공제대상금액-누적합계
    V_GONGJE_SUM_ACCU1_AMT                   NUMBER(15) := 0;                   --공제대상금액-누적합계
    V_GONGJE_SUM_ACCU2_AMT                   NUMBER(15) := 0;                   --공제대상금액-누적합계
    V_GONGJE_INCOME_AMT                     NUMBER(15) := 0;                   --공제대상금액-소득공제 대상 합계
    V_GONGJE_INCOME_ACCU_AMT                NUMBER(15) := 0;                   --공제대상금액-소득공제 대상 누적합계
    V_GONGJE_TAX_AMT                        NUMBER(15) := 0;                   --공제대상금액-세액공제 대상 합계    
    V_GONGJE_TAX_A_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 15% 비율적용분
    V_GONGJE_TAX_B_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 30(25)% 비율적용분
    V_GONGJE_TAX_C_AMT                      NUMBER(15) := 0;                   --공제대상금액-세액공제 기타(100/110)    
    V_GONGJE_SUM_RATEAMT                    NUMBER(15) := 0;                   --세액공제금액-합계
    V_GONGJE_SUM_ACCU1_RATEAMT               NUMBER(15) := 0;                   --세액공제금액-합계
    V_GONGJE_SUM_ACCU2_RATEAMT               NUMBER(15) := 0;                   --세액공제금액-합계
    V_GONGJE_SUM_ACCU_RATEAMT               NUMBER(15) := 0;                   --세액공제금액-누적합계
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

    V_TempAmt                               NUMBER(15) := 0; 
    V_TempRate                              NUMBER(15) := 0; 
    V_TempCnt                               NUMBER(15) := 0; 
BEGIN

    BEGIN
        
        V_DONATE_AMT := IO_BASIC_AMT;                          --근로소득금액  
        V_EXPAND_AMT := IO_EXPAND_AMT;                         --기준소득금액          
        V_CAL_TDUC_TEMP_AMT := IO_CAL_TDUC_TEMP_AMT;           --결정세액(산출세액)                     
        V_SPCL_DUC_AMT := IO_SPCL_DUC_AMT;                     --특별소득공제합계                    
        V_STAD_TAXDUC_OBJ_AMT := IO_STAD_TAXDUC_OBJ_AMT;       --표준세액공제합계                     
        
        V_DONATE_BASIC_AMT := 0;
        V_GONGJE_SUM_ACCU_AMT := 0;
        V_GONGJE_SUM_ACCU1_AMT := 0;
        V_GONGJE_SUM_ACCU2_AMT := 0;
        V_GONGJE_SUM_ACCU_RATEAMT := 0;
        V_DONATE_BASIC_J_ACCU_AMT := 0;
        V_DONATE_BASIC_E_ACCU_AMT := 0;
        V_GONGJE_SUM_TOTAMT := 0;
        V_TempCnt := 0;
        
        FOR CNTRIB1 IN ( SELECT C1.RPST_PERS_NO, C1.CNTRIB_YY, C1.CNTRIB_TYPE_CD
                                , C1.CNTRIB_GIAMT
                                , NVL(C1.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                , NVL(C1.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                , NVL(C1.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                , NVL(C1.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                , SUM(C1.APNT_CNTRIB_AMT) OVER(PARTITION BY C1.RPST_PERS_NO) AS  APNT_CNTRIB_AMT -- 종교단체 지정기부금 발생(당년+이월) 금액
                                , SUM(C1.APNT_CNTRIB_AMT2) OVER(PARTITION BY C1.RPST_PERS_NO) AS  APNT_CNTRIB_AMT2 -- 종교단체외 지정기부금 발생(당년+이월) 금액
                                , SUM(C1.CNTRIB_GIAMT) OVER (PARTITION BY C1.CNTRIB_TYPE_CD) AS CNTRIB_TYPE_TT_AMT --기부유형별 합계금액
                                , C1.SORT1, C1.SORT3
                           FROM ( SELECT A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD
                                         , SUM(A1.CNTRIB_GIAMT)   CNTRIB_GIAMT
                                         , SUM(A1.CNTRIB_PREAMT)  CNTRIB_PREAMT
                                         , SUM(A1.CNTRIB_GONGAMT) CNTRIB_GONGAMT
                                         , SUM(A1.CNTRIB_DESTAMT) CNTRIB_DESTAMT
                                         , SUM(A1.CNTRIB_OVERAMT) CNTRIB_OVERAMT
                                         , SUM(A1.APNT_CNTRIB_AMT) APNT_CNTRIB_AMT -- 종교단체 지정기부금 발생(당년+이월) 금액
                                         , SUM(A1.APNT_CNTRIB_AMT2) APNT_CNTRIB_AMT2 -- 종교단체외 지정기부금 발생(당년+이월) 금액
                                         , A1.SORT1, A1.SORT3
                                    FROM ( /*[소득공제 SORT1:A1] 2013년이전 종교단체외*/
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,0                       AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                   ,'A1'                    AS SORT1
                                                   ,A.CNTRIB_YY             AS SORT3
                                               FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                   ,PAYM452 B --사업자부서정보 @VER.2016_11
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY - 1
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ     /* 전년도는 차수 변수처리 */
                                                AND A.YY             = B.YY                        /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO    = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400006'    /* 기부금유형: 지정 종교외(40) */
                                                AND A.SETT_FG        = 'A031300001'    /* 정산구분: 연말정산 */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0       /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴 */
                                                AND A.CNTRIB_YY <= '2013'              /* @2016R 2013년 이전 이월기부금 분리 (2015년 1차 계산시 분리 안되어있음:오류사항) */
                                             UNION ALL
                                              /*[소득공제 SORT1:A2] 2013년이전 종교단체*/
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                   ,0                       AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                   ,'A2'                    AS SORT1
                                                   ,A.CNTRIB_YY             AS SORT3
                                               FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                   ,PAYM452 B --사업자부서정보 @VER.2016_11
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY - 1
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ    /* 전년도는 차수 변수처리 */
                                                AND A.YY             = B.YY            /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO    = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400007'    /* 기부금유형: 지정 종교단체(41) */
                                                AND A.SETT_FG        = 'A031300001'    /* 정산구분 : 연말정산 */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0       /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴 */
                                                AND A.CNTRIB_YY <= '2013'              /* @2016R 2013년 이전 이월기부금 분리 (2015년 1차 계산시 분리 안되어있음:오류사항) */
                                             UNION ALL
                                             /*[세액공제 SORT1:B1] 종교단체외 이월(2014년~) */
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,0                       AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                   ,'B1'        AS SORT1
                                                   ,A.CNTRIB_YY AS SORT3
                                               FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                   ,PAYM452 B --사업자부서정보 @VER.2016_11
                                              WHERE A.RPST_PERS_NO = IN_RPST_PERS_NO
                                                AND A.YY           = IN_YY - 1
                                                AND A.YRETXA_SEQ   = IN_YRETXA_SEQ    /* 전년도는 차수 변수처리*/
                                                AND A.YY           = B.YY            /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO  = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400006'  /* 지정(종교외:40) */
                                                AND A.SETT_FG        = 'A031300001'  /* 정산구분:연말정산 */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0     /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴*/
                                                AND A.CNTRIB_YY >= '2014'            /* 2014년 이후 이월 기부금 */
                                             UNION ALL
                                             /*[세액공제 SORT1:B2] 당해 종교단체 외 */
                                             SELECT A.RPST_PERS_NO, A.YY, A.CNTRIB_TYPE_CD
                                                   ,(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) - NVL(A.CNTRIB_ENC_APLY_AMT,0) ) AS CNTRIB_GIAMT /*@VER.2016_9 지정기부금 기부장려신청금액 차감.*/
                                                   ,0                                                 AS CNTRIB_PREAMT
                                                   ,0                                                 AS CNTRIB_GONGAMT
                                                   ,0                                                 AS CNTRIB_DESTAMT
                                                   ,0                                                 AS CNTRIB_OVERAMT
                                                   ,0                                                 AS APNT_CNTRIB_AMT  -- 당년도 종교단체 지정기부금 발생 금액
                                                   ,NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT2 -- 당년도 종교단체외 지정기부금 발생 금액
                                                   ,'B2'  AS SORT1
                                                   ,A.YY  AS SORT3
                                               FROM PAYM423 A --당년도 연말정산 기부내역
                                                   ,PAYM421 B --연말정산 가족사항
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                AND A.CNTRIB_TYPE_CD = 'A032400006' /* 지정(종교외:40) */
                                                AND A.SETT_FG        = IN_SETT_FG
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                                                AND A.YY             = B.YY
                                                AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.SETT_FG        = B.SETT_FG
                                                AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                                                AND A.FM_SEQ         = B.FM_SEQ
                                                AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 기부금 부양가족 연령요건 삭제(소득요건만 체크 또는 본인)
                                             UNION ALL
                                             /*[세액공제 SORT1:C1] 종교단체 이월(2014년~) */
                                             SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                    A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                   ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                   ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                   ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                   ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                   ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                   ,0                       AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                   ,'C1'                    AS SORT1
                                                   ,A.CNTRIB_YY             AS SORT3
                                               FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                   ,PAYM452 B --사업자부서정보 @VER.2016_11
                                              WHERE A.RPST_PERS_NO = IN_RPST_PERS_NO
                                                AND A.YY           = IN_YY - 1
                                                AND A.YRETXA_SEQ   = IN_YRETXA_SEQ    /* 전년도는 차수 변수처리*/
                                                AND A.YY           = B.YY            /* @VER.2016_11 */
                                                AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                AND B.BIZR_REG_NO  = IN_BIZR_REG_NO   /* @VER.2016_11 */
                                                AND A.CNTRIB_TYPE_CD = 'A032400007'  /* 지정(종교단체:41) */
                                                AND A.SETT_FG        = 'A031300001'  /* 정산구분:연말정산 */
                                                AND NVL(A.CNTRIB_OVERAMT,0) <> 0     /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴*/
                                                AND A.CNTRIB_YY >= '2014'            /* 2014년 이후 이월 기부금 */
                                             UNION ALL
                                             /*[세액공제 SORT1:C2] 당해 종교단체 */
                                             SELECT A.RPST_PERS_NO, A.YY, A.CNTRIB_TYPE_CD
                                                   ,(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) - NVL(A.CNTRIB_ENC_APLY_AMT,0) ) AS CNTRIB_GIAMT/*@VER.2016_9 지정기부금 기부장려신청금액 차감.*/
                                                   ,0                                                 AS CNTRIB_PREAMT
                                                   ,0                                                 AS CNTRIB_GONGAMT
                                                   ,0                                                 AS CNTRIB_DESTAMT
                                                   ,0                                                 AS CNTRIB_OVERAMT
                                                   ,NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT  -- 당년도 종교단체 지정기부금 발생 금액
                                                   ,0                                                 AS APNT_CNTRIB_AMT2 -- 당년도 종교단체외  지정기부금 발생 금액
                                                   ,'C2' SORT1
                                                   ,A.YY SORT3
                                               FROM PAYM423 A --당년도 연말정산 기부내역
                                                  , PAYM421 B --연말정산 가족사항
                                              WHERE A.RPST_PERS_NO   = IN_RPST_PERS_NO
                                                AND A.YY             = IN_YY
                                                AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                AND A.CNTRIB_TYPE_CD = 'A032400007' /* 지정(종교단체:41)*/
                                                AND A.SETT_FG        = IN_SETT_FG
                                                AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                                                AND A.YY             = B.YY
                                                AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                                                AND A.SETT_FG        = B.SETT_FG
                                                AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                                                AND A.FM_SEQ         = B.FM_SEQ
                                                AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 기부금 부양가족 연령요건 삭제(소득요건만 체크 또는 본인)
                                              --AND NVL(B.BASE_DUC_YN,'N') IN ('Y','1') --기본공제 체크된 사람의 기부금
                                             UNION ALL
                                             /*[세액공제 SORT1:B2] 당해 급여노조비(지정:종교단체 외(41)로 분류) */
                                             SELECT A.RPST_PERS_NO, A.YY, 'A032400006' AS CNTRIB_TYPE_CD
                                                   ,NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) AS CNTRIB_GIAMT
                                                   ,0                                AS CNTRIB_PREAMT
                                                   ,0                                AS CNTRIB_GONGAMT
                                                   ,0                                AS CNTRIB_DESTAMT
                                                   ,0                                AS CNTRIB_OVERAMT
                                                   ,0                                AS APNT_CNTRIB_AMT  --당년도 종교단체  지정기부금 발생 금액
                                                   ,NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT2 --당년도 종교단체외  지정기부금 발생 금액
                                                   ,'B2'                             AS SORT1
                                                   ,A.YY                             AS SORT3
                                               FROM PAYM440 A --당년도 급여 노조비 공제 내역
                                              WHERE A.RPST_PERS_NO = IN_RPST_PERS_NO
                                                AND A.YY           = IN_YY
                                                AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                AND SETT_FG        = IN_SETT_FG
                                                AND NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) <> 0
                                     ) A1
                               GROUP BY A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD, A1.SORT1, A1.SORT3
                               ) C1
                    ORDER BY C1.SORT1,C1.SORT3
                    )
        LOOP
            
            <<RECALCULATION>>

            V_CNTRIB_PREAMT  := 0;
            V_CNTRIB_GONGAMT := 0;
            V_CNTRIB_DESTAMT := 0;
            V_CNTRIB_OVERAMT := 0;
                    
            --기부금지출금액
            V_DONATE_BASIC_AMT := CNTRIB1.CNTRIB_GIAMT;                                    --기부금지출금액    
            -- 한도
            IF (V_DONATE_BASIC_J_ACCU_AMT = 0) THEN
                V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 0.1 + LEAST(V_EXPAND_AMT * 0.2,V_DONATE_BASIC_E_ACCU_AMT));
            ELSE
                V_DONATE_MAX_AMT := TRUNC(V_EXPAND_AMT * 0.3);
            END IF;            
            --V_DONATE_MAX1_AMT := TRUNC(V_EXPAND_AMT * 0.1 + LEAST(V_EXPAND_AMT * 0.2,V_DONATE_BASIC_E_ACCU_AMT));
            --V_DONATE_MAX2_AMT := TRUNC(V_EXPAND_AMT * 0.3); 
            -- 기부금지출누적금액합계(종교단체, 종교외)
            IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN   -- 종교단체
                V_DONATE_BASIC_J_ACCU_AMT := V_DONATE_BASIC_J_ACCU_AMT + V_DONATE_BASIC_AMT;
            ELSE
                V_DONATE_BASIC_E_ACCU_AMT := V_DONATE_BASIC_E_ACCU_AMT + V_DONATE_BASIC_AMT;
            END IF;                                                           
            -- 공제대상금액 합계 한도율(종교단체, 종교외)
            IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN   -- 종교단체
                V_TempRate := 10;  
            ELSE
                V_TempRate := 30;  
            END IF;           
            -- 공제대상금액 합계
            IF V_GONGJE_SUM_ACCU_AMT >= V_DONATE_MAX_AMT THEN 
                V_GONGJE_SUM_AMT := 0;
                --V_DONATE_BASIC_AMT := 0; 
            ELSE 
                IF (CNTRIB1.CNTRIB_YY <= '2013' ) THEN               
                    V_GONGJE_SUM_AMT := V_DONATE_BASIC_AMT; 
                ELSE
                    V_GONGJE_SUM_AMT := LEAST(V_DONATE_BASIC_AMT,V_DONATE_MAX_AMT - V_GONGJE_SUM_ACCU_AMT, ROUND(V_EXPAND_AMT * V_TempRate / V_TempRate));                 
                END IF;                        
            END IF;
            IF (CNTRIB1.CNTRIB_YY <= '2013' ) THEN               
                --공제대상금액-소득공제 대상 합계
                V_GONGJE_INCOME_AMT := V_GONGJE_SUM_AMT;
                V_GONGJE_INCOME_ACCU_AMT := V_GONGJE_INCOME_ACCU_AMT + V_GONGJE_INCOME_AMT;
                V_GONGJE_TAX_AMT := 0;
                V_GONGJE_TAX_A_AMT := 0;
                V_GONGJE_TAX_B_AMT := 0;
                V_GONGJE_TAX_C_AMT := 0;
                V_GONGJE_SUM_RATEAMT := 0;
                V_GONGJE_SUM_ACCU1_RATEAMT := 0;
                V_GONGJE_SUM_ACCU2_RATEAMT := 0;
                V_GONGJE_TAX_A_RATEAMT := 0;
                V_GONGJE_TAX_B_RATEAMT := 0;
                V_GONGJE_TAX_C_RATEAMT := 0;                
                -- 공제대상금액 누적합계
                V_GONGJE_SUM_ACCU_AMT := V_GONGJE_SUM_ACCU_AMT + V_GONGJE_SUM_AMT;                                
            ELSE                    
                V_GONGJE_INCOME_AMT := 0;
                V_GONGJE_INCOME_ACCU_AMT := V_GONGJE_INCOME_ACCU_AMT + V_GONGJE_INCOME_AMT;
                -- 공제대상금액-세액공제 대상 합계
                V_GONGJE_TAX_AMT := V_GONGJE_SUM_AMT;                
                -- 연도별 고액기부금 세액공제율
                IF (CNTRIB1.CNTRIB_YY = '2015') THEN
                    V_TempAmt := 30000000;
                ELSIF (CNTRIB1.CNTRIB_YY = '2016' OR CNTRIB1.CNTRIB_YY = '2017' OR CNTRIB1.CNTRIB_YY = '2018') THEN
                    V_TempAmt := 20000000;
                ELSIF (CNTRIB1.CNTRIB_YY = IN_YY) THEN
                    V_TempAmt := 10000000;
                END IF;                    
                --공제대상금액-세액공제 15% 비율적용분
                IF ((IO_B_GONGJE_TAX_AMT + IO_W_GONGJE_TAX_AMT) > V_TempAmt) THEN 
                    V_GONGJE_TAX_A_AMT := 0;    
                ELSE
                    V_GONGJE_TAX_A_AMT := LEAST(V_TempAmt - IO_B_GONGJE_TAX_AMT - IO_W_GONGJE_TAX_AMT, V_GONGJE_TAX_AMT);     
                END IF;
                --공제대상금액-세액공제 30(25)% 비율적용분
                V_GONGJE_TAX_B_AMT := GREATEST(0, V_GONGJE_TAX_AMT - V_GONGJE_TAX_A_AMT);
                V_GONGJE_TAX_C_AMT := 0;                
                --세액공제금액-세액공제 15% 적용세액공제액
                V_GONGJE_TAX_A_RATEAMT := CEIL(V_GONGJE_TAX_A_AMT * 0.15);                                        
                --세액공제금액-세액공제 30(25)% 적용세액공제액
                IF (CNTRIB1.CNTRIB_YY = '2014' OR CNTRIB1.CNTRIB_YY = '2015') THEN
                    V_GONGJE_TAX_B_RATEAMT := CEIL(V_GONGJE_TAX_B_AMT * 0.25);
                ELSE
                    V_GONGJE_TAX_B_RATEAMT := CEIL(V_GONGJE_TAX_B_AMT * 0.30);
                END IF;                    
                V_GONGJE_TAX_C_RATEAMT := 0;
                --세액공제금액-합계
                V_GONGJE_SUM_RATEAMT := V_GONGJE_TAX_A_RATEAMT + V_GONGJE_TAX_B_RATEAMT + V_GONGJE_TAX_C_RATEAMT;                    
                --IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN  -- 종교단체
                --    V_GONGJE_SUM_ACCU1_RATEAMT := V_GONGJE_SUM_ACCU1_RATEAMT + V_GONGJE_SUM_RATEAMT;
                --ELSE 
                --    V_GONGJE_SUM_ACCU2_RATEAMT := V_GONGJE_SUM_ACCU2_RATEAMT + V_GONGJE_SUM_RATEAMT;
                --END IF;
                -- 공제대상금액 누적합계
                V_GONGJE_SUM_ACCU_AMT := V_GONGJE_SUM_ACCU_AMT + V_GONGJE_SUM_AMT;
                -- 세액공제금액-누적합계
                V_GONGJE_SUM_ACCU_RATEAMT := V_GONGJE_SUM_ACCU_RATEAMT + V_GONGJE_SUM_RATEAMT;                                                          

                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 결정세액(산출세액) 0 보다 크면                                                              
                    IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_SUM_RATEAMT THEN  -- 결정세액(산출세액) 잔액이 세액공제금액-합계 보다 작다면                             
                        IF V_CAL_TDUC_TEMP_AMT < V_GONGJE_TAX_A_RATEAMT THEN               
                            /*  재계산 처리 : 기부금지출금액 = (세액공제금액(합계) -  결정세액(산출세액)) * 100 / 15%(적용공제율) */
                            V_DONATE_BASIC_AMT := CEIL((V_GONGJE_TAX_A_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 15) ;
                        ELSE
                            /*  재계산 처리 : 기부금지출금액 = (세액공제금액(합계) -  결정세액(산출세액)) * 100 / 30(25)%(적용공제율) */
                            IF (CNTRIB1.CNTRIB_YY = '2014' OR CNTRIB1.CNTRIB_YY = '2015') THEN
                               V_DONATE_BASIC_AMT := CEIL((V_GONGJE_TAX_B_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 25) ;                
                            ELSE
                               V_DONATE_BASIC_AMT := CEIL((V_GONGJE_TAX_B_RATEAMT - V_CAL_TDUC_TEMP_AMT) * 100 / 30) ;                 
                            END IF;
                        END IF;
                        GOTO RECALCULATION;    
                    ELSE
                        IF CNTRIB1.CNTRIB_YY = IN_YY THEN
                            IF CNTRIB1.CNTRIB_GIAMT > V_DONATE_BASIC_AMT THEN
                                V_CNTRIB_PREAMT  := 0;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := CNTRIB1.CNTRIB_GIAMT - V_DONATE_BASIC_AMT;
                            ELSE
                                V_CNTRIB_PREAMT  := 0;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := 0;                                
                            END IF; 
                        ELSIF CNTRIB1.CNTRIB_YY <= '2013' THEN
                            IF CNTRIB1.CNTRIB_OVERAMT > V_DONATE_BASIC_AMT THEN
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := CNTRIB1.CNTRIB_OVERAMT - V_DONATE_BASIC_AMT;
                                V_CNTRIB_OVERAMT := 0;
                            ELSE
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_OVERAMT;
                                V_CNTRIB_GONGAMT := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;                           
                                V_CNTRIB_DESTAMT := V_DONATE_BASIC_AMT;
                                V_CNTRIB_OVERAMT := 0;                                
                            END IF;                            
                        ELSIF CNTRIB1.CNTRIB_YY > '2013' AND  CNTRIB1.CNTRIB_YY < IN_YY THEN
                            IF CNTRIB1.CNTRIB_OVERAMT > V_DONATE_BASIC_AMT THEN
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := CNTRIB1.CNTRIB_OVERAMT - V_DONATE_BASIC_AMT;
                            ELSE
                                V_CNTRIB_PREAMT  := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT;
                                V_CNTRIB_GONGAMT := V_DONATE_BASIC_AMT;                           
                                V_CNTRIB_DESTAMT := 0;
                                V_CNTRIB_OVERAMT := 0;                                
                            END IF;                              
                        END IF;                           
                    END IF;
                ELSE              
                    IF CNTRIB1.CNTRIB_YY = IN_YY THEN
                        V_CNTRIB_PREAMT      := 0;                                               -- 기부금 전년까지 공제금액
                    ELSE
                        V_CNTRIB_PREAMT      := CNTRIB1.CNTRIB_PREAMT;                           -- 기부금 전년까지 공제금액 
                    END IF;
                    V_CNTRIB_GONGAMT     := 0;                                                   -- 기부금 당년 공제금액
                    V_CNTRIB_DESTAMT     := 0;                                                   -- 기부금 당년 소멸금액
                    V_CNTRIB_OVERAMT     := V_DONATE_BASIC_AMT;                                  -- 기부금 당년 이월금액                  
                END IF;                         
            END IF;
    
            /* 연말정산 기부금저장처리 */   
            IF IN_USING = 'T' THEN    
               SP_PAYM410B_2019_DONATE_SAVE(IN_BIZR_DEPT_CD, IN_YY, IN_SETT_FG, IN_RPST_PERS_NO, CNTRIB1.CNTRIB_TYPE_CD, CNTRIB1.CNTRIB_YY, V_DONATE_BASIC_AMT, V_CNTRIB_PREAMT, V_CNTRIB_GONGAMT, V_CNTRIB_DESTAMT, V_CNTRIB_OVERAMT, IN_INPT_ID, IN_INPT_IP, OUT_RTN, OUT_MSG);                                
            END IF;
            
            IF V_CNTRIB_GONGAMT > 0 THEN                                                        
                IF (CNTRIB1.CNTRIB_TYPE_CD = 'A032400007') THEN 
                   V_GONGJE_SUM2_TOTAMT := V_GONGJE_SUM2_TOTAMT + V_CNTRIB_GONGAMT;
                ELSE
                   V_GONGJE_SUM1_TOTAMT := V_GONGJE_SUM1_TOTAMT + V_CNTRIB_GONGAMT; 
                END IF;
                DBMS_OUTPUT.PUT_LINE('공제대상금액 합계 종교    : ' || V_GONGJE_SUM2_TOTAMT );
                DBMS_OUTPUT.PUT_LINE('공제대상금액 합계 종교-외 : ' || V_GONGJE_SUM1_TOTAMT );
            END IF;     
            
            IF V_CNTRIB_GONGAMT > 0 THEN             
                -- 표준세액공제 계산
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_GONGJE_SUM_RATEAMT;
                IF V_STAD_TAXDUC_OBJ_AMT  <= 0  THEN
                     V_STAD_TAXDUC_OBJ_AMT := 0 ;
                END IF;   
                -- 특별소득공제 계산
                IF CNTRIB1.CNTRIB_YY = '2013' THEN  
                    V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_DONATE_BASIC_AMT;        
                    IF V_SPCL_DUC_AMT  <= 0  THEN
                         V_SPCL_DUC_AMT := 0 ;
                    END IF;     
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
            END IF;            
                                   
            
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S ***************************************************************************************' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 근로/기준/한도(100%) 금액 : ' || V_DONATE_AMT || ',' || V_EXPAND_AMT || ',' ||  V_DONATE_MAX_AMT);
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> ' || CNTRIB1.CNTRIB_YY || ' - ' || CNTRIB1.CNTRIB_TYPE_CD);    
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 기부금지출금액 : ' || V_DONATE_BASIC_AMT );    
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 공제대상금액-합계 : ' || V_GONGJE_SUM_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 공제대상금액-소득공제 대상 합계 : ' || V_GONGJE_INCOME_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 공제대상금액-세액공제 대상 합계 : ' || V_GONGJE_TAX_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 공제대상금액-세액공제 15% 비율적용분 : ' || V_GONGJE_TAX_A_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 공제대상금액-세액공제 30(25)% 비율적용분 : ' || V_GONGJE_TAX_B_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 공제대상금액-세액공제 기타(100/110) : ' || V_GONGJE_TAX_C_AMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 세액공제금액-합계 : ' || V_GONGJE_SUM_RATEAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 세액공제금액-세액공제 15% 적용세액공제액 : ' || V_GONGJE_TAX_A_RATEAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 세액공제금액-세액공제 30(25)% 적용세액공제액 : ' || V_GONGJE_TAX_B_RATEAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 세액공제금액-세액공제 기타 적용세액공제액 : ' || V_GONGJE_TAX_C_RATEAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G S --------------------------------------------------------------' );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 전년까지 공제금액 : ' || V_CNTRIB_PREAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 당년     공제금액 : ' || V_CNTRIB_GONGAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 당년     소멸금액 : ' || V_CNTRIB_DESTAMT );
            --DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G ==> 당년     이월금액 : ' || V_CNTRIB_OVERAMT );
            DBMS_OUTPUT.PUT_LINE('SP_PAYM410B_2019_DONATE_G E ***************************************************************************************' );
              
          
        END LOOP;   
        
    END;

    -- 산출세액(차감, 합산), 특별소득공제, 표준세액공제     
    IO_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT; 
    IO_CAL_TDUC_TEMP_AMT := V_CAL_TDUC_TEMP_AMT;   
    IO_SPCL_DUC_AMT := V_SPCL_DUC_AMT; 
    IO_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT;
    --    
    IO_GONGJE_SUM_AMT := V_GONGJE_SUM_ACCU_AMT;    
    IO_GONGJE_TAX_AMT := V_GONGJE_SUM_ACCU_RATEAMT;
    --공제대상금액-소득공제 대상 누적합계
    IO_GONGJE_INCOME_ACCU_AMT := IO_GONGJE_INCOME_ACCU_AMT - V_GONGJE_INCOME_ACCU_AMT;
    IF IO_GONGJE_INCOME_ACCU_AMT <= 0 THEN 
        IO_GONGJE_INCOME_ACCU_AMT := 0;
    ELSE
        IO_GONGJE_INCOME_ACCU_AMT := IO_GONGJE_INCOME_ACCU_AMT - V_GONGJE_INCOME_ACCU_AMT;    
    END IF;    
        
    IO_APNT_CNTRIB40_DUC_OBJ_AMT := V_GONGJE_SUM2_TOTAMT; --V_GONGJE_SUM_ACCU2_AMT;                  --지정기부(종교외)공제대상금액
    IO_APNT_CNTRIB41_DUC_OBJ_AMT := V_GONGJE_SUM1_TOTAMT; --V_GONGJE_SUM_ACCU1_AMT;                  --지정기부(종교)공제대상금액
    IO_APNT_CNTRIB40_TAXDUC_AMT := V_GONGJE_SUM_ACCU2_RATEAMT;               --지정기부(종교외)세액공제액
    IO_APNT_CNTRIB41_TAXDUC_AMT := V_GONGJE_SUM_ACCU1_RATEAMT;               --지정기부(종교)세액공제액   
             
    IO_SPCL_AMT := IO_SPCL_AMT + V_GONGJE_INCOME_ACCU_AMT;
    
END SP_PAYM410B_2019_DONATE_G;
/
