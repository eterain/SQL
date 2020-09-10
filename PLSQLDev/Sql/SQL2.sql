select * from comm121 where DETA_BUSS_CD in ( 'A0167','A0168')
;


select fr_dt || ' ~ ' || to_dt AS plan_date,
       fr_dt || ' ' || FR_HOUR || ' ~ ' || to_dt || ' ' || TO_HOUR AS plan_date_det
from comm121 
where SCHAFF_SCHE_FG = 'U000500003'
AND schyy = '2020'
AND shtm_fg = 'U000200002'
AND deta_shtm_fg = 'U000300001'
AND bdegr_system_fg = 'U000100001'
AND DETA_BUSS_CD = 'A0167'     -- 'A0168'
;


select * FROM cour018 ;
select * FROM cour100 ;

cour623;
cour624;
cour625;

hurt200;
hurt250;

COUR203 ;

SF_COUR208_PERS_NM('01'
                                          ,'02'
                                          ,T1.OPEN_SCHYY
                                          ,T1.OPEN_SHTM_FG
                                          ,T1.OPEN_DETA_SHTM_FG
                                          ,T1.SBJT_CD
                                          ,T1.LT_NO
                                          );
SELECT t1.pers_no, 
       SF_HURT200_PERS_INFO('1',T1.PERS_NO),
       T3.WKGD_NM, 
       (SELECT DEPT_KOR_NM FROM BSNS100 WHERE T2.POSI_BREU_CD = DEPT_CD) AS POSI_BREU_NM,
       '41' AS SBJT_FLD_CD,
       (SELECT SBJT_FLD_NM FROM COUR018 WHERE SBJT_FLD_CD = '41' ) AS SBJT_FLD_NM
FROM  COUR208 T1
     ,HURT250 T2
     ,HURT190 T3
WHERE T1.OPEN_SCHYY                 = '2020'
AND T1.OPEN_SHTM_FG               = 'U000200001'
AND T1.OPEN_DETA_SHTM_FG          = 'U000300001'
AND T1.SBJT_CD                    = '031.001'
AND T1.LT_NO                      = '001'
AND T1.PERS_NO                    = T2.PERS_NO
AND T2.WKGD_CD                    = T3.WKGD_CD
AND T1.SBJT_MA_RESP_YN = 'Y'
; 
                      
        SELECT T1.PERS_NO,
               SF_HURT200_PERS_INFO('1',T1.PERS_NO) AS RESP_PROF_KOR_NM,
               T3.WKGD_NM AS RESP_PROF_WKPO_NM,
               (SELECT DEPT_KOR_NM FROM BSNS100 WHERE T2.POSI_BREU_CD = DEPT_CD) AS RESP_PROF_POSI_NM,
               '41' AS SBJT_FLD_CD,
               (SELECT SBJT_FLD_NM FROM COUR018 WHERE SBJT_FLD_CD = '41' ) AS SBJT_FLD_NM
        FROM  COUR208 T1
             ,HURT250 T2
             ,HURT190 T3
        WHERE T1.PERS_NO                  = T2.PERS_NO
          AND T2.WKGD_CD                  = T3.WKGD_CD
          AND T1.SBJT_MA_RESP_YN = 'Y' ;                                                                
SELECT t1.pers_no, SF_HURT200_PERS_INFO('1',T1.PERS_NO)
                     FROM  COUR208 t1
                      AND T1.SBJT_MA_RESP_YN = 'Y';                                          
                                          

SELECT * FROM COUR208 WHERE open_schyy = '2020';

/* COUR623.update03 강의조교협약 및 활동관리 수정 */
UPDATE COUR625
   SET MOD_ID            = 'B111606' /* 수정자ID */,
       MOD_IP            = NULL /* 수정자IP */,
       MOD_DTTM          = SYSDATE /* 수정일시 */,
       STD_ACCP_YN       = '-',
       RESP_PROF_ACCP_YN = '-',
       CHIEF_ACCP_YN     = 'Y'
 WHERE OPEN_SCHYY = '2020' /* 개설학년도(PK1) 
      */
   AND OPEN_SHTM_FG = 'U000200001' /* 개설학기구분(PK2) */
   AND OPEN_DETA_SHTM_FG = 'U000300001' /* 
      개설세부학기구분(PK3) */
   AND MNGT_DEPT_CD = '601' /* 관리부서코드(PK4) */
   AND STUNO = '93601-009' /* 학번(PK5) 
      */
   AND LT_ASSIST_INPT_SEQ = 1;

SELECT * FROM COUR624 ;

        SELECT T1.OPEN_SCHYY                                                              /* 개설학년도(PK1) */
              ,T1.OPEN_SHTM_FG
              ,T1.OPEN_DETA_SHTM_FG
              ,SF_BSNS011_CODENM(T1.OPEN_SHTM_FG,1) AS OPEN_SHTM_FG_KOR_NM                /* 개설학기구분(PK2) */
              ,SF_BSNS011_CODENM(T1.OPEN_DETA_SHTM_FG,1) AS OPEN_DETA_SHTM_FG_KOR_NM      /* 개설세부학기구분(PK3) */
              ,T1.MNGT_DEPT_CD                                                            /* 관리부서코드(PK4) */
              ,T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM                                         /* 관리부서명 */
              ,T1.STUNO                                                                   /* 학번(PK5) */
              ,T1.LT_ASSIST_INPT_SEQ                                                      /* 강의조교입력순번(PK6) */
              ,(SELECT TA.KOR_NM FROM HURT200 TA
                 WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM                       /* 성명 */
              ,T3.UNIVS_KOR_NM                                                            /* 대학(원) */
              ,T3.DEPARTMENT_KOR_NM                                                       /* 학과(부) */
              ,(SELECT SF_BSNS011_CODENM(T3.PROG_CORS_FG) FROM DUAL ) AS PROG_CORS_FG_NM  /* 진행과정 */
              ,(SELECT SF_BSNS011_CODENM(T3.SCHREG_FG) FROM DUAL ) AS SCHREG_FG_NM        /* 학적상태 */
              ,DECODE(T3.STD_FG, 'U030500002', '연구생') AS RECHER_YN                     /* 연구생여부 */
              ,T1.LT_ASSIST_TYPE_FG
              ,T1.LT_ASSIST_ST_FG
              ,SF_BSNS011_CODENM(T1.LT_ASSIST_TYPE_FG,1) AS LT_ASSIST_TYPE_FG_KOR_NM      /* 강의조교유형구분 */
              ,SF_BSNS011_CODENM(T1.LT_ASSIST_ST_FG,1) AS LT_ASSIST_ST_FG_KOR_NM          /* 강의조교상태구분 */
              ,T1.REAL_ACT_FR_DT                                                               /* 활동시작일자 */
              ,T1.REAL_ACT_TO_DT                                                               /* 활동종료일자 */
              ,T1.LT_ASSIST_LBCOST_DCNT                                                   /* 강의조교인건비일수 */
              ,T1.RESP_PROF_PERS_NO                                                       /* 담당교수개인번호 */
              ,(SELECT TA.KOR_NM FROM HURT200 TA
                 WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM        /* 담당교수성명 */
              ,T1.RESP_PROF_WKPO_NM                                                       /* 담당교수직위 */
              ,T1.RESP_PROF_POSI_NM                                                   /* 담당교수소속 */
              ,T1.CHIEF_PERS_NO                                                           /* 기관장개인번호 */
              ,(SELECT TA.KOR_NM FROM HURT200 TA
                 WHERE TA.RPST_PERS_NO = T1.CHIEF_PERS_NO) AS CHIEF_KOR_NM                /* 기관장성명 */
              ,T1.CHIEF_WKPO_NM                                                           /* 기관장직위 */
              ,T1.CHIEF_POSI_NM                                                           /* 기관장소속 */
              ,T4.SBJT_FLD_CD                                                             /* 교양영역 */
              ,(SELECT SBJT_FLD_NM FROM COUR018
                 WHERE SBJT_FLD_CD = T4.SBJT_FLD_CD) AS SBJT_FLD_NM                       /* 교양영역명 */
              ,T4.SBJT_NM                                                                 /* 교과목명 */
              ,T1.SBJT_NO                                                                 /* 교과목번호 */
              ,T1.LT_NO                                                                   /* 강좌번호 */
              ,T1.REMK                                                                    /* 비고 */
              ,T1.INPT_ID                                                                 /* 입력ID */
              ,T1.INPT_IP                                                                 /* 입력IP */
              ,TO_CHAR(T1.INPT_DTTM, 'YYYYMMDD HH24:MI:SS') AS INPT_DTTM                  /* 입력일시 */
              ,T1.MOD_ID                                                                  /* 수정ID */
              ,T1.MOD_IP                                                                  /* 수정IP */
              ,TO_CHAR(T1.MOD_DTTM, 'YYYYMMDD HH24:MI:SS') AS MOD_DTTM                    /* 수정일시 */
              ,T5.ACT_PLAN_ACCP_ST
              ,T5.ACT_RPRT_ACCP_ST
              ,NVL(SF_BSNS011_CODENM(T5.ACT_PLAN_ACCP_ST,1),'-') AS ACT_PLAN_ACCP_ST_KOR_NM
              ,NVL(SF_BSNS011_CODENM(T5.ACT_RPRT_ACCP_ST,1),'-') AS ACT_RPRT_ACCP_ST_KOR_NM
              ,T5.LT_ASSIST_ACT_CTNT
              ,T5.WRITE_HWORK_KND_CTNT
              ,T5.ETC_HWORK_KND_CTNT
              ,T5.WRITE_HWORK_COACH_CTNT
              ,T5.ETC_HWORK_COACH_CTNT
              ,T5.PRAC_COACH_CTNT
              ,T5.LT_TM_ACT_CTNT
              ,T5.LT_SUPP_CTNT
              ,T5.ETC_CTNT
              ,T5.RESP_BUSS_CTNT
              ,NVL(T6.STD_ACCP_YN,'-') AS STD_ACCP_YN
              ,T6.STD_ACCP_DTTM
              ,NVL(T6.RESP_PROF_ACCP_YN,'-') AS RESP_PROF_ACCP_YN
              ,T6.RESP_PROF_PERS_NO
              ,T6.RESP_PROF_POSI_NM
              ,T6.RESP_PROF_WKPO_NM
              ,T6.RESP_PROF_ACCP_DTTM
              ,NVL(T6.CHIEF_ACCP_YN,'-') AS CHIEF_ACCP_YN
              ,T6.CHIEF_PERS_NO
              ,T6.CHIEF_POSI_NM
              ,T6.CHIEF_WKPO_NM
              ,T6.CHIEF_ACCP_DTTM

              ,(select fr_dt || ' ~ ' || to_dt
                       /*  fr_dt || ' ' || FR_HOUR || ' ~ ' || to_dt || ' ' || TO_HOUR AS plan_date_det  */
                from comm121
                where SCHAFF_SCHE_FG = 'U000500003'
                and SCHYY           = T1.OPEN_SCHYY
                AND SHTM_FG         = T1.OPEN_SHTM_FG
                AND DETA_SHTM_FG  = T1.OPEN_DETA_SHTM_FG
                AND bdegr_system_fg = 'U000100001'
                AND DETA_BUSS_CD = 'A0167' ) as plan_date
              ,(select fr_dt || ' ~ ' || to_dt
                       /*  fr_dt || ' ' || FR_HOUR || ' ~ ' || to_dt || ' ' || TO_HOUR AS plan_date_det  */
                from comm121
                where SCHAFF_SCHE_FG = 'U000500003'
                and SCHYY           = T1.OPEN_SCHYY
                AND SHTM_FG         = T1.OPEN_SHTM_FG
                AND DETA_SHTM_FG  = T1.OPEN_DETA_SHTM_FG
                AND bdegr_system_fg = 'U000100001'
                AND DETA_BUSS_CD = 'A0168' ) as rprt_date

          FROM COUR623 T1
              ,BSNS100 T2
              ,V_SREG101 T3
              ,COUR100 T4
              ,COUR624 T5
              ,COUR625 T6
         WHERE T1.MNGT_DEPT_CD       = T2.DEPT_CD
           AND T1.STUNO              = T3.STUNO
           AND T1.SBJT_NO            = T4.SBJT_CD(+)
           AND T1.OPEN_SCHYY    = T5.OPEN_SCHYY (+)
           AND T1.OPEN_SHTM_FG      = T5.OPEN_SHTM_FG (+)
           AND T1.OPEN_DETA_SHTM_FG = T5.OPEN_DETA_SHTM_FG (+)
           AND T1.MNGT_DEPT_CD      = T5.MNGT_DEPT_CD (+)
           AND T1.STUNO             = T5.STUNO (+)
           AND T1.LT_ASSIST_INPT_SEQ = T5.LT_ASSIST_INPT_SEQ (+)
           AND T1.OPEN_SCHYY    = T6.OPEN_SCHYY (+)
           AND T1.OPEN_SHTM_FG      = T6.OPEN_SHTM_FG (+)
           AND T1.OPEN_DETA_SHTM_FG = T6.OPEN_DETA_SHTM_FG (+)
           AND T1.MNGT_DEPT_CD      = T6.MNGT_DEPT_CD (+)
           AND T1.STUNO             = T6.STUNO (+)
           AND T1.LT_ASSIST_INPT_SEQ = T6.LT_ASSIST_INPT_SEQ (+)

         and T1.STUNO              = '93601-009' ;

           
           
SELECT * FROM acck100      ;

select * FROM SREG101 ;

comm121 ;
comm123 ;
comm210 ;
