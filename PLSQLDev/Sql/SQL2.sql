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

/* COUR623.update03 ������������ �� Ȱ������ ���� */
UPDATE COUR625
   SET MOD_ID            = 'B111606' /* ������ID */,
       MOD_IP            = NULL /* ������IP */,
       MOD_DTTM          = SYSDATE /* �����Ͻ� */,
       STD_ACCP_YN       = '-',
       RESP_PROF_ACCP_YN = '-',
       CHIEF_ACCP_YN     = 'Y'
 WHERE OPEN_SCHYY = '2020' /* �����г⵵(PK1) 
      */
   AND OPEN_SHTM_FG = 'U000200001' /* �����бⱸ��(PK2) */
   AND OPEN_DETA_SHTM_FG = 'U000300001' /* 
      ���������бⱸ��(PK3) */
   AND MNGT_DEPT_CD = '601' /* �����μ��ڵ�(PK4) */
   AND STUNO = '93601-009' /* �й�(PK5) 
      */
   AND LT_ASSIST_INPT_SEQ = 1;

SELECT * FROM COUR624 ;

        SELECT T1.OPEN_SCHYY                                                              /* �����г⵵(PK1) */
              ,T1.OPEN_SHTM_FG
              ,T1.OPEN_DETA_SHTM_FG
              ,SF_BSNS011_CODENM(T1.OPEN_SHTM_FG,1) AS OPEN_SHTM_FG_KOR_NM                /* �����бⱸ��(PK2) */
              ,SF_BSNS011_CODENM(T1.OPEN_DETA_SHTM_FG,1) AS OPEN_DETA_SHTM_FG_KOR_NM      /* ���������бⱸ��(PK3) */
              ,T1.MNGT_DEPT_CD                                                            /* �����μ��ڵ�(PK4) */
              ,T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM                                         /* �����μ��� */
              ,T1.STUNO                                                                   /* �й�(PK5) */
              ,T1.LT_ASSIST_INPT_SEQ                                                      /* ���������Է¼���(PK6) */
              ,(SELECT TA.KOR_NM FROM HURT200 TA
                 WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM                       /* ���� */
              ,T3.UNIVS_KOR_NM                                                            /* ����(��) */
              ,T3.DEPARTMENT_KOR_NM                                                       /* �а�(��) */
              ,(SELECT SF_BSNS011_CODENM(T3.PROG_CORS_FG) FROM DUAL ) AS PROG_CORS_FG_NM  /* ������� */
              ,(SELECT SF_BSNS011_CODENM(T3.SCHREG_FG) FROM DUAL ) AS SCHREG_FG_NM        /* �������� */
              ,DECODE(T3.STD_FG, 'U030500002', '������') AS RECHER_YN                     /* ���������� */
              ,T1.LT_ASSIST_TYPE_FG
              ,T1.LT_ASSIST_ST_FG
              ,SF_BSNS011_CODENM(T1.LT_ASSIST_TYPE_FG,1) AS LT_ASSIST_TYPE_FG_KOR_NM      /* ���������������� */
              ,SF_BSNS011_CODENM(T1.LT_ASSIST_ST_FG,1) AS LT_ASSIST_ST_FG_KOR_NM          /* �����������±��� */
              ,T1.REAL_ACT_FR_DT                                                               /* Ȱ���������� */
              ,T1.REAL_ACT_TO_DT                                                               /* Ȱ���������� */
              ,T1.LT_ASSIST_LBCOST_DCNT                                                   /* ���������ΰǺ��ϼ� */
              ,T1.RESP_PROF_PERS_NO                                                       /* ��米�����ι�ȣ */
              ,(SELECT TA.KOR_NM FROM HURT200 TA
                 WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM        /* ��米������ */
              ,T1.RESP_PROF_WKPO_NM                                                       /* ��米������ */
              ,T1.RESP_PROF_POSI_NM                                                   /* ��米���Ҽ� */
              ,T1.CHIEF_PERS_NO                                                           /* ����尳�ι�ȣ */
              ,(SELECT TA.KOR_NM FROM HURT200 TA
                 WHERE TA.RPST_PERS_NO = T1.CHIEF_PERS_NO) AS CHIEF_KOR_NM                /* ����强�� */
              ,T1.CHIEF_WKPO_NM                                                           /* ��������� */
              ,T1.CHIEF_POSI_NM                                                           /* �����Ҽ� */
              ,T4.SBJT_FLD_CD                                                             /* ���翵�� */
              ,(SELECT SBJT_FLD_NM FROM COUR018
                 WHERE SBJT_FLD_CD = T4.SBJT_FLD_CD) AS SBJT_FLD_NM                       /* ���翵���� */
              ,T4.SBJT_NM                                                                 /* ������� */
              ,T1.SBJT_NO                                                                 /* �������ȣ */
              ,T1.LT_NO                                                                   /* ���¹�ȣ */
              ,T1.REMK                                                                    /* ��� */
              ,T1.INPT_ID                                                                 /* �Է�ID */
              ,T1.INPT_IP                                                                 /* �Է�IP */
              ,TO_CHAR(T1.INPT_DTTM, 'YYYYMMDD HH24:MI:SS') AS INPT_DTTM                  /* �Է��Ͻ� */
              ,T1.MOD_ID                                                                  /* ����ID */
              ,T1.MOD_IP                                                                  /* ����IP */
              ,TO_CHAR(T1.MOD_DTTM, 'YYYYMMDD HH24:MI:SS') AS MOD_DTTM                    /* �����Ͻ� */
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
