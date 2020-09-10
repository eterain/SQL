      SELECT
       A.CERT_CD,
       A.CERT_MNGT_BREU_CD,
       A.CERT_KOR_NM,
       A.CERT_ENG_NM,
       A.KOR_ISSU_AMT,
       A.ENG_ISSU_AMT,
       A.GRDT_45_YY_YN,
       A.GRDT_46_YY_86_YY_YN,
       A.GRDT_87_YY_YN,
       A.BDEGR_YN,
       A.MD_YN,
       A.PHD_YN,
       A.ENROLL_YN,
       A.GRDT_YN,
       A.CEAST_YN,
       A.EXPEL_YN,
       A.CETE_YN,
       A.HOOF_YN,
       A.NDTY_YN,
       A.RETI_YN,

       A.MVOT_YN,
       A.DTMT_YN,
       A.CHARG_YN,
       A.TRMN_YN,
       A.APNT_YN,
       A.CHARG_ACCP_YN,
       A.APNT_ACCP_YN,
       A.DISMIS_YN,
       A.EMPL_EXPC_YN,
       A.RECOMD_YN,
       A.ENG_CERT_ISSU_OBJ_YN,
       A.USE_YN,
       A.INPT_ID,
       A.INPT_DTTM,
       A.INPT_IP,
       A.MOD_ID,
       A.MOD_DTTM,
       A.MOD_IP,
       B.MNGT_BREU_NM
  FROM CERT001 A, CERT003 B
  WHERE A.CERT_MNGT_BREU_CD = B.CERT_MNGT_BREU_CD
          AND A.CERT_CD NOT IN('14','15')
