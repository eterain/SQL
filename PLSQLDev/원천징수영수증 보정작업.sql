--원천징수영수증
SELECT --ROWID
      A.RPST_PERS_NO
--     , A.LABOR_EARN_AMT       
     , A.LABOR_EARN_TDUC_AMT                                  /* 근로세액공제액 */
     , A.APNT_CNTRIB_RELI_OBJ_AMT                             /* 지정(종교) 공제대상 */
     , A.APNT_CNTRIB_RELI_DUC_AMT                             /* 지정(종교) 세액공제 */
     , A.APNT_CNTRIB_RELI_OUT_OBJ_AMT                         /* 지정(종교외) 공제대상 */
     , A.APNT_CNTRIB_RELI_OUT_DUC_AMT                         /* 지정(종교외) 세액공제 */
     , A.FLAW_CNTRIB_DUC_OBJ_AMT                              /* 법정기부 공제대상 */
     , A.FLAW_CNTRIB_TAXDUC_AMT                               /* 법정기부 세액공제 */
     , A.APNT_CNTRIB_TAXDUC_AMT                               /* (64)지정기부세액공제액*/
-- ,A.GUARQL_INSU_TAXDUC_AMT                /*(61)일반보장성보험세액공제액 */
 --,A.DSPSN_GUARQL_INSU_TAXDUC_AMT          /*(61)장애인보장성보험세액공제액 */
 --,A.HFE_TAXDUC_AMT                        /*(62)의료비세액공제액 */
 --,A.EDAMT_TAXDUC_AMT                      /*(63)교육비세액공제액 */
 --,A.POLITICS_LMT_BLW_TAXDUC_AMT           /*(64)정치한도이하세액공제액 */
 --,A.POLITICS_LMT_EXCE_TAXDUC_AMT          /*(64)정치한도초과세액공제액 */
     , A.TDUC_TT                                               /* (70)세액 공제계 */
     , A.DETM_EARN_AMT                                         /* (73)결정세액*/
     , A.DETM_IHTAX_AMT                                        /* (지방세) */
     , A.ALD_SBTR_EARN_AMT                                     /* (차감징수 소득세) */
     , A.ALD_SBTR_IHTAX_AMT                                    /* (차감징수 지방세) */
  --,A.*
  FROM PAYM410 A
 WHERE YY = '2019'
   AND RPST_PERS_NO = 'D010816'
   ;

--기부금
--A032400002 : 정치자금(코드:20),
--A032400001 : 법정(코드:10), 
--A032400006 : 지정(코드:40), 
--A032400007 : 종교(코드:41)
   
SELECT ROWID
     , CNTRIB_GIAMT - CNTRIB_PREAMT AS "2019이전"
     , A.*
  FROM PAYM432 A
 WHERE YY = '2019'
   AND RPST_PERS_NO = 'D010816'
   ;
   
SELECT *
 FROM PAYM432 A
 WHERE A.YY           = '2019'
   AND A.YRETXA_SEQ   = 1
   --AND CNTRIB_YY      = '2018'
   AND A.BIZR_DEPT_CD = '00000'
   AND A.SETT_FG      = 'A031300001'
   --AND A.CNTRIB_TYPE_CD = 'A032400006'
   AND A.RPST_PERS_NO  = 'D010816'
ORDER BY CNTRIB_TYPE_CD, CNTRIB_YY   
;   
