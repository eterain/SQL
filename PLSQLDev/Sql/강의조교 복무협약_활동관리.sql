HURT250 ;

SELECT * FROM cour221 ;         -- �������°�����������

SELECT * FROM cour620 ;         -- �⺻����
SELECT * FROM cour622 ;         -- ��������
SELECT * FROM cour623 ;         -- ��õ����

SELECT * FROM cour625 ;         -- ��������
SELECT * FROM cour624 ;         -- Ȱ����ȹ/����   
SELECT * FROM cour625 ;         -- ��������

SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0497'
ORDER BY A.DISP_ORD, A.CMMN_CD
;


   /* COUR623.find ??  ����������������, Ȱ������ ��� ��ȸ */   
   SELECT --T1.LT_ASSIST_ST_FG,                                                     /* �����������±��� */
          SF_BSNS011_CODENM(T1.LT_ASSIST_ST_FG, 1) AS LT_ASSIST_ST_FG_KOR_NM,
          T1.OPEN_SCHYY, /* �����г⵵(PK1) */
          SF_BSNS011_CODENM(T1.OPEN_SHTM_FG, 1) AS OPEN_SHTM_FG_KOR_NM, /* �����бⱸ��(PK2) */
          SF_BSNS011_CODENM(T1.OPEN_DETA_SHTM_FG, 1) AS OPEN_DETA_SHTM_FG_KOR_NM,  /* ���������бⱸ��(PK3) */
          --T1.MNGT_DEPT_CD, /* �����μ��ڵ�(PK4) */
          T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM, /* �����μ��� */
          T1.MNGT_DEPT_CD,
          T1.STUNO, /* �й�(PK5) */
          --T1.LT_ASSIST_INPT_SEQ, /* ���������Է¼���(PK6) */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM, /* ���� */
          T3.UNIVS_KOR_NM, /* ����(��) */
          T3.DEPARTMENT_KOR_NM, /* �а�(��) */
          SF_BSNS011_CODENM(T1.LT_ASSIST_TYPE_FG, 1) AS LT_ASSIST_TYPE_FG_KOR_NM,  /* ���������������� */
          
          T4.SBJT_NM, /* ������� */
          T1.SBJT_CD, /* �������ȣ */
          T1.LT_NO, /* ���¹�ȣ */
          (SELECT SF_COUR208_PERS_NM('01', '01', T1.OPEN_SCHYY, T1.OPEN_SHTM_FG, T1.OPEN_DETA_SHTM_FG, T1.SBJT_CD, T1.LT_NO) FROM DUAL) AS LT_PROF_KOR_NM, /* ���´�米�� */
          
          --T1.RESP_PROF_PERS_NO, /* ��米�����ι�ȣ */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM, /* ��米������ */
          
          T1.INPT_ID, /* �Է�ID */
          T1.INPT_IP, /* �Է�IP */
          TO_CHAR(T1.INPT_DTTM, 'YYYYMMDD HH24:MI:SS') AS INPT_DTTM, /* �Է��Ͻ� */
          T1.MOD_ID, /* ����ID */
          T1.MOD_IP, /* ����IP */
          TO_CHAR(T1.MOD_DTTM, 'YYYYMMDD HH24:MI:SS') AS MOD_DTTM /* �����Ͻ� */
     FROM COUR623   T1,
          BSNS100   T2,
          V_SREG101 T3,
          COUR100   T4
    WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
      AND T1.STUNO = T3.STUNO
      AND T1.SBJT_CD = T4.SBJT_CD (+)
      AND T1.OPEN_SCHYY = '2020' 
      /*
      AND T1.LT_ASSIST_ST_FG IN ( 'U049700002','U049700003' )
      AND EXISTS (SELECT 1
             FROM COUR622 TA1
            WHERE TA1.OPEN_SCHYY = T1.OPEN_SCHYY
              AND TA1.OPEN_SHTM_FG = T1.OPEN_SHTM_FG
              AND TA1.OPEN_DETA_SHTM_FG = T1.OPEN_DETA_SHTM_FG
              AND TA1.ASGN_FG = 'U049500001' 
              AND TA1.ASGN_BREU_FG = '0107'
              AND TA1.DEPT_CD = T1.MNGT_DEPT_CD) 
     */
   ;


   SELECT  '(���� ������)��(��) ���п��� ��������' || '(���� ������)��(��) ������ ����' AS info01,
          NVL(SUBSTR(T1.ACT_FR_DT,1,4),'0000') || '�� ' || NVL(SUBSTR(T1.ACT_FR_DT,5,2),'00') || '�� ' || NVL(SUBSTR(T1.ACT_FR_DT,7,2),'00') || '�Ϻ��� ' || 
          NVL(SUBSTR(T1.ACT_TO_DT,1,4),'0000') || '�� ' || NVL(SUBSTR(T1.ACT_FR_TO,5,2),'00') || '�� ' || NVL(SUBSTR(T1.ACT_TO_DT,7,2),'00') || '�ϱ��� ' AS info02,

          --T1.MNGT_DEPT_CD, /* �����μ��ڵ�(PK4) */
          T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM, /* �����μ��� */
          
          T1.STUNO, /* �й�(PK5) */
          --T1.LT_ASSIST_INPT_SEQ, /* ���������Է¼���(PK6) */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM, /* ���� */
          T3.UNIVS_KOR_NM, /* ����(��) */
          T3.DEPARTMENT_KOR_NM, /* �а�(��) */

          
          (SELECT SF_COUR208_PERS_NM('01', '01', T1.OPEN_SCHYY, T1.OPEN_SHTM_FG, T1.OPEN_DETA_SHTM_FG, T1.SBJT_CD, T1.LT_NO) FROM DUAL) AS info12
          
          --T1.RESP_PROF_PERS_NO, /* ��米�����ι�ȣ */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM /* ��米������ */
          
     FROM COUR623   T1,
          BSNS100   T2,
          V_SREG101 T3,
          COUR100   T4
    WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
      AND T1.STUNO = T3.STUNO
      AND T1.SBJT_CD = T4.SBJT_CD (+)
      AND T1.OPEN_SCHYY = '2020' 
      /*
      AND T1.LT_ASSIST_ST_FG IN ( 'U049700002','U049700003' )
      AND EXISTS (SELECT 1
             FROM COUR622 TA1
            WHERE TA1.OPEN_SCHYY = T1.OPEN_SCHYY
              AND TA1.OPEN_SHTM_FG = T1.OPEN_SHTM_FG
              AND TA1.OPEN_DETA_SHTM_FG = T1.OPEN_DETA_SHTM_FG
              AND TA1.ASGN_FG = 'U049500001' 
              AND TA1.ASGN_BREU_FG = '0107'
              AND TA1.DEPT_CD = T1.MNGT_DEPT_CD) 
     */
   ;




     /* COUR623.find01 ����������õ���� ��� ��ȸ */
     SELECT T1.OPEN_SCHYY /* �����г⵵(PK1) */,
            T1.OPEN_SHTM_FG /* �����бⱸ��(PK2) */,
            T1.OPEN_DETA_SHTM_FG /* ���������бⱸ��(PK3) */,
            T1.MNGT_DEPT_CD /* �����μ��ڵ�(PK4) */,
            T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM /* �����μ��� */,
            T1.STUNO /* �й�(PK5) */,
            T1.LT_ASSIST_INPT_SEQ /* ���������Է¼���(PK6) */,
            (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM /* ���� */,
            T3.UNIVS_KOR_NM /* ����(��) */,
            T3.DEPARTMENT_KOR_NM /* �а�(��) */,
            (SELECT SF_BSNS011_CODENM(T3.PROG_CORS_FG) FROM DUAL) AS PROG_CORS_FG_NM /* ������� */,
            (SELECT SF_BSNS011_CODENM(T3.SCHREG_FG) FROM DUAL) AS SCHREG_FG_NM /* �������� */,
            DECODE(T3.STD_FG, 'U030500002', '������') AS RECHER_YN /* ���������� */,
            T1.LT_ASSIST_TYPE_FG /* ���������������� */,
            T1.REAL_ACT_FR_DT /* Ȱ���������� */,
            T1.REAL_ACT_TO_DT /* Ȱ���������� */,
            T1.LT_ASSIST_LBCOST_DCNT /* ���������ΰǺ��ϼ� */,
            T1.RESP_PROF_PERS_NO /* ��米�����ι�ȣ */,
            (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM /* ��米������ */,
            T1.RESP_PROF_WKPO_NM /* ��米������ */,
            T1.RESP_PROF_POSI_NM /* ��米���Ҽ� */,
            T1.CHIEF_PERS_NO /* ����尳�ι�ȣ */,
            (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.CHIEF_PERS_NO) AS CHIEF_KOR_NM /* ����强�� */,
            T1.CHIEF_WKPO_NM /* ��������� */,
            T1.CHIEF_POSI_NM /* �����Ҽ� */,
            T4.SBJT_FLD_CD /* ���翵�� */,
            (SELECT SBJT_FLD_NM FROM COUR018 WHERE SBJT_FLD_CD = T4.SBJT_FLD_CD) AS SBJT_FLD_NM /* ���翵���� */,
            T4.SBJT_NM /* ������� */,
            T1.SBJT_NO /* �������ȣ */,
            T1.LT_NO /* ���¹�ȣ */ /*               ,(SELECT SF_COUR208_PERS_NM('01'                                          ,'01'                                          ,T1.OPEN_SCHYY                                          ,T1.OPEN_SHTM_FG                                          ,T1.OPEN_DETA_SHTM_FG                                          ,T1.SBJT_NO                                          ,T1.LT_NO                                          )                   FROM DUAL                ) AS LT_PROF_KOR_NM                                                        /* ���´�米�� */ * /,
            T1.LT_ASSIST_ST_FG /* �����������±��� */,
            T1.REMK /* ��� */,
            T1.INPT_ID /* �Է�ID */,
            T1.INPT_IP /* �Է�IP */,
            TO_CHAR(T1.INPT_DTTM, 'YYYYMMDD HH24:MI:SS') AS INPT_DTTM /* �Է��Ͻ� */,
            T1.MOD_ID /* ����ID */,
            T1.MOD_IP /* ����IP */,
            TO_CHAR(T1.MOD_DTTM, 'YYYYMMDD HH24:MI:SS') AS MOD_DTTM /* �����Ͻ� */
       FROM COUR623   T1,
            BSNS100   T2,
            V_SREG101 T3,
            COUR100   T4
      WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
        AND T1.STUNO = T3.STUNO
        AND T1.SBJT_NO = T4.SBJT_CD(+)
        AND T1.OPEN_SCHYY = '2020' /* �����г⵵(PK1) */
        AND T1.OPEN_SHTM_FG = 'U000200001' /* �����бⱸ��(PK2) */
        AND T1.OPEN_DETA_SHTM_FG = 'U000300001' /* ���������бⱸ��(PK3) */
        AND EXISTS (SELECT 1
               FROM COUR622 TA1
              WHERE TA1.OPEN_SCHYY = T1.OPEN_SCHYY
                AND TA1.OPEN_SHTM_FG = T1.OPEN_SHTM_FG
                AND TA1.OPEN_DETA_SHTM_FG = T1.OPEN_DETA_SHTM_FG
                AND TA1.ASGN_FG = 'U049500001' /* �⺻���� */
                AND TA1.ASGN_BREU_FG = '100'
                AND TA1.DEPT_CD = T1.MNGT_DEPT_CD) /* ����(��) */
;
