CREATE OR REPLACE FUNCTION SF_BUDG300_IMSI_CREA_02_1
/***************************************************************************************
객 체 명 : SF_BUDG300_IMSI_CREA_02_1
****************************************************************************************/
(
    IN_ACNT_YY          IN VARCHAR2,
    IN_ACNT_FG          IN VARCHAR2,
    IN_BUDG_DEPT_CD     IN VARCHAR2,
    
    IN_BUDG_SBJT_CD_SB  IN VARCHAR2,
    IN_BIZ_CD           IN VARCHAR2 
)
RETURN NUMBER 
IS 
    V_AMT                   BUDG100.FORMA_AMT%TYPE      := 0;          
    OUT_AMT                 BUDG100.FORMA_AMT%TYPE      := 0;           --리턴금액
    
BEGIN    

    SELECT NVL(A2.FORMA_AMT,0)+NVL(A2.ABUDG_AMT,0)+NVL(B.DVRS_AMT,0)
    INTO V_AMT  
    FROM     ( SELECT  ACNT_YY ,
                    ACNT_FG ,
                    BUDG_DEPT_CD ,
                    CYOV_FG ,
                    CYOV_YY ,
                    BIZ_CD ,
                    BUDG_SBJT_CD_SB ,
                    SUM(AMT) AS AMT
                    /* 집행액 */
           FROM     BUDG400
           WHERE    ACNT_YY      = IN_ACNT_YY
           AND      ACNT_FG      = IN_ACNT_FG
           AND      BUDG_DEPT_CD = IN_BUDG_DEPT_CD
           GROUP BY ACNT_YY,
                    ACNT_FG,
                    BUDG_DEPT_CD,
                    CYOV_FG,
                    CYOV_YY,
                    BIZ_CD,
                    BUDG_SBJT_CD_SB
           )
           F ,
           ( SELECT  B1.ACNT_YY ,
                    B1.ACNT_FG ,
                    B1.BUDG_DEPT_CD ,
                    B1.CYOV_FG ,
                    B1.CYOV_YY ,
                    B1.BIZ_CD ,
                    B1.BUDG_SBJT_CD_SB ,
                    SUM(NVL(B1.ADJ_AMT, 0)) AS EX_ADJ_AMT
           FROM     BUDG210 B1 ,
                    BUDG310 B2
           WHERE    B1.ACNT_YY                    = IN_ACNT_YY
           AND      B1.ACNT_FG                    = IN_ACNT_FG
           AND      B1.BUDG_DEPT_CD               = IN_BUDG_DEPT_CD
           AND      TO_CHAR(SYSDATE, 'YYYYMMDD') >= TO_CHAR(TO_DATE(B1.ADJ_DT, 'YYYYMMDD'), 'YYYYMMDD')
           AND      B1.TRET_FG                    = 'A041400002'
           AND      B1.BUDG_DVRS_NO               = B2.BUDG_DVRS_NO
           AND      B1.SRNUM                      = B2.SRNUM
           GROUP BY B1.ACNT_YY,
                    B1.ACNT_FG,
                    B1.BUDG_DEPT_CD,
                    B1.CYOV_FG,
                    B1.CYOV_YY,
                    B1.BIZ_CD,
                    B1.BUDG_SBJT_CD_SB
           )
           E
           /*재배정에서 처리한 배정조정액*/
           ,
           ( SELECT  ACNT_YY ,
                    ACNT_FG ,
                    BUDG_DEPT_CD ,
                    CYOV_FG ,
                    CYOV_YY ,
                    BIZ_CD ,
                    BUDG_SBJT_CD_SB ,
                    SUM(NVL(ASGN_AMT,0)) AS ASGN_AMT
           FROM     BUDG200
           WHERE    ACNT_YY                       = IN_ACNT_YY
           AND      ACNT_FG                       = IN_ACNT_FG
           AND      BUDG_DEPT_CD                  = IN_BUDG_DEPT_CD
           AND      TO_CHAR(SYSDATE, 'YYYYMMDD') >= TO_CHAR(TO_DATE(ASGN_DT, 'YYYYMMDD'), 'YYYYMMDD')
           GROUP BY ACNT_YY,
                    ACNT_FG,
                    BUDG_DEPT_CD,
                    CYOV_FG,
                    CYOV_YY,
                    BIZ_CD,
                    BUDG_SBJT_CD_SB
           )
           D
           /*이전 배정액*/
           ,
           ( SELECT  ACNT_YY ,
                    ACNT_FG ,
                    BUDG_DEPT_CD ,
                    CYOV_FG ,
                    CYOV_YY ,
                    BIZ_CD ,
                    BUDG_SBJT_CD_SB ,
                    SUM(NVL(ADJ_AMT, 0)) AS PRE_ADJ_AMT
                    /*해당분기 이전 및 해당분기 조정일자(조회조건) 이전 배정조정액*/
           FROM     BUDG210
           WHERE    ACNT_YY                       = IN_ACNT_YY
           AND      ACNT_FG                       = IN_ACNT_FG
           AND      BUDG_DEPT_CD                  = IN_BUDG_DEPT_CD
           AND      TO_CHAR(SYSDATE, 'YYYYMMDD') >= TO_CHAR(TO_DATE(ADJ_DT, 'YYYYMMDD'), 'YYYYMMDD')
           AND      TRET_FG                       = 'A041400002'
           GROUP BY ACNT_YY,
                    ACNT_FG,
                    BUDG_DEPT_CD,
                    CYOV_FG,
                    CYOV_YY,
                    BIZ_CD,
                    BUDG_SBJT_CD_SB
           )
           C
           /*이전 배정조정액*/
           ,
           ( SELECT  ACNT_YY ,
                    ACNT_FG ,
                    BUDG_DEPT_CD ,
                    CYOV_FG ,
                    CYOV_YY ,
                    BIZ_CD ,
                    SUBSTR(BUDG_SBJT_CD_SB,1,2)
                             || '00'      AS BUDG_SBJT_CD_SST ,
                    BUDG_SBJT_CD_SB       AS BUDG_SBJT_CD_SB ,
                    SUM(NVL(DVRS_AMT, 0)) AS DVRS_AMT
                    /*전용액*/
           FROM     BUDG310
           WHERE    ACNT_YY      = IN_ACNT_YY
           AND      ACNT_FG      = IN_ACNT_FG
           AND      BUDG_DEPT_CD = IN_BUDG_DEPT_CD
           AND      SUBSTR(BUDG_SBJT_CD_SB,1,2)
                             || '00' LIKE ''
                             || '%'
           AND      FXD_YN = 'Y'
           GROUP BY ACNT_YY,
                    ACNT_FG,
                    BUDG_DEPT_CD,
                    CYOV_FG,
                    CYOV_YY,
                    BIZ_CD,
                    BUDG_SBJT_CD_SB
           )
           B
           /*전용액*/
           ,
           ( SELECT  ACNT_YY ,
                    ACNT_FG ,
                    BUDG_DEPT_CD ,
                    CYOV_FG ,
                    CYOV_YY ,
                    BIZ_CD ,
                    BUDG_SBJT_CD_SST ,
                    BUDG_SBJT_CD_SB ,
                    BUDG_FORMA_NO ,
                    SUM(NVL(FORMA_AMT, 0)) AS FORMA_AMT
                    /*편성액*/
                    ,
                    SUM(NVL(ABUDG_AMT, 0)) AS ABUDG_AMT
                    /*추경액*/
           FROM     BUDG100
           WHERE    ACNT_YY             = IN_ACNT_YY
           AND      ACNT_FG             = IN_ACNT_FG
           AND      BUDG_DEPT_CD        = IN_BUDG_DEPT_CD
           AND      BUDG_SBJT_CD_SST LIKE ''
                             || '%'
           AND      BUDG_SBJT_CD_ITEM LIKE ''
                             || '%'
           AND      FORMA_FG = 'A040400001'
           AND      BAL_FG   = '0'
           AND      SEQ      = 0
           AND      BUDG_FG  = 'A040100000'
           GROUP BY ACNT_YY,
                    ACNT_FG,
                    BUDG_DEPT_CD,
                    CYOV_FG,
                    CYOV_YY,
                    BIZ_CD,
                    BUDG_SBJT_CD_SST,
                    BUDG_SBJT_CD_SB,
                    BUDG_FORMA_NO
           )
           A2
           /*편성액*/
           ,
           ( SELECT  B.ACNT_YY ,
                    B.ACNT_FG ,
                    B.BUDG_DEPT_CD ,
                    A.CYOV_FG ,
                    A.CYOV_YY ,
                    A.BIZ_CD ,
                    A.BUDG_SBJT_CD_SB ,
                    SUM(NVL(A.AMT, 0)) AS WAIT_AMT
           FROM     ACNT110 A ,
                    ACNT100 B ,
                    BUDG003 C
           WHERE    A.BAL_FG = '0'
           AND      A.PROG_FG IN ('A060700002',
                                  'A060700010')
           AND      A.UNIT_DEPT_CTRL_YN = 'Y'
           AND      A.DCD_DOC_NO        = B.DCD_DOC_NO
           AND      B.ACNT_YY           = IN_ACNT_YY
           AND      B.ACNT_FG           = IN_ACNT_FG
           AND      B.BUDG_DEPT_CD      = IN_BUDG_DEPT_CD
           AND      B.ACNT_YY           = C.ACNT_YY
           AND      B.ACNT_FG           = C.ACNT_FG
           AND      A.DMND_DEPT_CD      = C.DEPT_CD
                    /* 예산의 단위부서로 대기액 체크*/
           AND      B.BUDG_DEPT_CD = C.BUDG_RESP_DEPT_CD
           GROUP BY B.ACNT_YY,
                    B.ACNT_FG,
                    B.BUDG_DEPT_CD,
                    A.CYOV_FG,
                    A.CYOV_YY,
                    A.BIZ_CD,
                    A.BUDG_SBJT_CD_SB
           )
           DD
           /*대기액*/
           ,
           BUDG100 A
    WHERE    A.ACNT_YY         = B.ACNT_YY(+)
    AND      A.ACNT_FG         = B.ACNT_FG(+)
    AND      A.CYOV_YY         = B.CYOV_YY(+)
    AND      A.CYOV_FG         = B.CYOV_FG(+)
    AND      A.BUDG_SBJT_CD_SB = B.BUDG_SBJT_CD_SB(+)
           /*세목*/
    AND      A.BUDG_SBJT_CD_SST = B.BUDG_SBJT_CD_SST(+)
    AND      A.BIZ_CD           = B.BIZ_CD(+)
    AND      A.ACNT_YY          = A2.ACNT_YY(+)
    AND      A.ACNT_FG          = A2.ACNT_FG(+)
    AND      A.CYOV_YY          = A2.CYOV_YY(+)
    AND      A.CYOV_FG          = A2.CYOV_FG(+)
    AND      A.BUDG_SBJT_CD_SB  = A2.BUDG_SBJT_CD_SB(+)
           /*세목*/
    AND      A.BUDG_SBJT_CD_SST    = A2.BUDG_SBJT_CD_SST(+)
    AND      A.BIZ_CD              = A2.BIZ_CD(+)
    AND      A.ACNT_YY             = C.ACNT_YY(+)
    AND      A.ACNT_FG             = C.ACNT_FG(+)
    AND      A.CYOV_YY             = C.CYOV_YY(+)
    AND      A.CYOV_FG             = C.CYOV_FG(+)
    AND      A.BUDG_SBJT_CD_SB     = C.BUDG_SBJT_CD_SB(+)
    AND      A.BIZ_CD              = C.BIZ_CD(+)
    AND      A.ACNT_YY             = D.ACNT_YY(+)
    AND      A.ACNT_FG             = D.ACNT_FG(+)
    AND      A.CYOV_YY             = D.CYOV_YY(+)
    AND      A.CYOV_FG             = D.CYOV_FG(+)
    AND      A.BUDG_SBJT_CD_SB     = D.BUDG_SBJT_CD_SB(+)
    AND      A.BIZ_CD              = D.BIZ_CD(+)
    AND      A.ACNT_YY             = E.ACNT_YY(+)
    AND      A.ACNT_FG             = E.ACNT_FG(+)
    AND      A.CYOV_YY             = E.CYOV_YY(+)
    AND      A.CYOV_FG             = E.CYOV_FG(+)
    AND      A.BUDG_SBJT_CD_SB     = E.BUDG_SBJT_CD_SB(+)
    AND      A.BIZ_CD              = E.BIZ_CD(+)
    AND      A.ACNT_YY             = F.ACNT_YY(+)
    AND      A.ACNT_FG             = F.ACNT_FG(+)
    AND      A.BUDG_DEPT_CD        = F.BUDG_DEPT_CD(+)
    AND      A.CYOV_YY             = F.CYOV_YY(+)
    AND      A.CYOV_FG             = F.CYOV_FG(+)
    AND      A.BUDG_SBJT_CD_SB     = F.BUDG_SBJT_CD_SB(+)
    AND      A.BIZ_CD              = F.BIZ_CD(+)
    AND      A.ACNT_YY             = DD.ACNT_YY(+)
    AND      A.ACNT_FG             = DD.ACNT_FG(+)
    AND      A.BUDG_DEPT_CD        = DD.BUDG_DEPT_CD(+)
    AND      A.CYOV_YY             = DD.CYOV_YY(+)
    AND      A.CYOV_FG             = DD.CYOV_FG(+)
    AND      A.BUDG_SBJT_CD_SB     = DD.BUDG_SBJT_CD_SB(+)
    AND      A.BIZ_CD              = DD.BIZ_CD(+)
    AND      A.BUDG_SBJT_CD_SST LIKE '' || '%'
    AND      A.BUDG_SBJT_CD_SECT LIKE '' || '%'
    AND      A.BUDG_SBJT_CD_ITEM LIKE '' || '%'
    AND      A.BUDG_SBJT_CD_SB LIKE '' || '%'
    AND      A.BIZ_CD       LIKE IN_BIZ_CD || '%'
    AND      A.FORMA_FG     = 'A040400001'
    AND      A.BAL_FG       = '0'
    AND      A.SEQ          = 0
    AND      A.BUDG_FG      = 'A040100000'
    AND      A.BUDG_DEPT_CD = IN_BUDG_DEPT_CD
    AND      A.ACNT_FG      = IN_ACNT_FG
    AND      A.ACNT_YY      = IN_ACNT_YY
    AND      A.CYOV_FG      = '0'
    AND      A.CYOV_YY = IN_ACNT_YY
    AND      A.BUDG_SBJT_CD_SB = IN_BUDG_SBJT_CD_SB
   ;
    
    OUT_AMT := V_AMT;
     
    RETURN OUT_AMT;
END;
/
