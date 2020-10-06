

SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0498'
ORDER BY A.DISP_ORD, A.CMMN_CD
;

SELECT * FROM cour622 ;


SELECT *
FROM COUR623 TA1
WHERE TA1.MNGT_DEPT_CD = '116' ;

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
         SF_HURT200_PERS_INFO('1', T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM,
         T1.RESP_PROF_WKPO_NM /* ��米������ */,
         T1.RESP_PROF_POSI_NM /* ��米���Ҽ� */,
         T1.CHIEF_PERS_NO /* ����尳�ι�ȣ */,
         SF_HURT200_PERS_INFO('1', T1.CHIEF_PERS_NO) AS CHIEF_KOR_NM,
         T1.CHIEF_WKPO_NM /* ��������� */,
         T1.CHIEF_POSI_NM /* �����Ҽ� */,
         T5.OPEN_UP_SBJT_FLD_CD AS SBJT_FLD_CD /* ���翵�� */,
         (SELECT SBJT_FLD_NM FROM COUR018 WHERE SBJT_FLD_CD = T5.OPEN_UP_SBJT_FLD_CD) AS SBJT_FLD_NM /* ���翵���� */,
         T4.SBJT_NM /* ������� */,
         T1.SBJT_NO /* �������ȣ */,
         T1.LT_NO /* ���¹�ȣ */,
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
         COUR100   T4,
         COUR203   T5
   WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
     AND T1.STUNO = T3.STUNO
     AND T1.SBJT_NO = T4.SBJT_CD(+)
     AND T1.OPEN_SCHYY = T5.OPEN_SCHYY(+)
     AND T1.OPEN_SHTM_FG = T5.OPEN_SHTM_FG(+)
     AND T1.OPEN_DETA_SHTM_FG = T5.OPEN_DETA_SHTM_FG(+)
     AND T1.SBJT_NO = T5.SBJT_CD(+)
     AND T1.LT_NO = T5.LT_NO(+)
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
             AND TA1.DEPT_CD = T1.MNGT_DEPT_CD
             ) /* ����(��) */
     AND T1.MNGT_DEPT_CD = '116' /* �а�(��) */
