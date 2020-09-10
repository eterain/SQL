 

SELECT a.stuno,
       a.PERS_KOR_NM,
       a.SCHREG_MOD_FG AS "���������ڵ�",
       SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) AS "����������Ī",
       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018') 
                 THEN SUBSTR(SF_TEMP202009_TEMP(a.stuno),1,4) || '.' || DECODE(SUBSTR(SF_TEMP202009_TEMP(a.stuno),5,10),'U000200001','1','2') 
                 ELSE '2020.1'
       END AS "��ϱݳ����б�", 
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) AS "2020-1�б� ��ϱݾ�",
       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "���ͻ������б��ϱ�",
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  
                 THEN (SELECT SCAL_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "���ͻ������б����б�",
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')  
                 THEN (SELECT REG_TT_AMT - SCAL_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "���ͻ������бⳳ�Ա�",
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) +       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "������ϱݾ�",
       
       NVL((SELECT REG_TT_AMT - SCAL_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) +       
       CASE WHEN a.SCHREG_MOD_FG IN ('U030300017','U030300018')
                 THEN (SELECT REG_TT_AMT - SCAL_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "�������Աݾ�" 
FROM temp202009 a 
--WHERE stuno = '2013-10260'
;


SELECT a.stuno,
       a.PERS_KOR_NM,
       a.SCHREG_MOD_FG AS "���������ڵ�",
       SF_BSNS011_CODENM(a.SCHREG_MOD_FG,1) AS "����������Ī",
       --(SELECT SF_BSNS011_CODENM(SCHREG_MOD_FG,1) FROM ENRO200 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) AS "��������",
       
       CASE WHEN (SELECT SCHREG_MOD_FG FROM ENRO200 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno ) IN ('U030300017','U030300018') 
                 THEN SUBSTR(SF_TEMP202009_TEMP(a.stuno),1,4) || '.' || DECODE(SUBSTR(SF_TEMP202009_TEMP(a.stuno),5,10),'U000200001','1','2') 
                 ELSE '2020.1'
       END AS "��ϱݳ����б�", 
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) AS "2020-1�б� ��ϱݾ�",
       
       CASE WHEN (SELECT SCHREG_MOD_FG FROM ENRO200 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno ) IN ('U030300017','U030300018') 
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "���ͻ������б��ϱ�",
       
       NVL((SELECT REG_TT_AMT FROM ENRO200 
        WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001'        
        AND stuno = a.stuno
       ),0) +       
       CASE WHEN (SELECT SCHREG_MOD_FG FROM ENRO200 WHERE SCHYY = '2020' AND SHTM_FG = 'U000200001' AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno ) IN ('U030300017','U030300018') 
                 THEN (SELECT REG_TT_AMT FROM ENRO200 WHERE SCHYY || SHTM_FG = SF_TEMP202009_TEMP(a.stuno) AND DETA_SHTM_FG = 'U000300001' AND stuno = a.stuno) 
                 ELSE 0 
       END AS "������ϱݾ�"       
       
FROM temp202009 a
--WHERE stuno = '2013-10260'
;

SELECT STUNO,
       SF_BSNS011_CODENM(A.SCHREG_MOD_FG,1), SCHREG_MOD_FG,       
       A.REG_TT_AMT,
       A.SCAL_TT_AMT,
       A.REG_TT_AMT - A.SCAL_TT_AMT
       --BF_RECIV_LSN_AMT,
       --BF_RECIV_SSO_AMT
FROM enro200 A
WHERE SCHYY = '2016'
AND SHTM_FG = 'U000200002'
AND deta_shtm_fg = 'U000300001'
AND stuno = '2013-10260'
;


SELECT SF_BSNS011_CODENM(A.SCHREG_MOD_FG,1), SCHREG_MOD_FG,       
       A.REG_TT_AMT - A.SCAL_TT_AMT,
       A.*
FROM enro200 A
WHERE SCHYY = '2020'
AND SHTM_FG = 'U000200001'
AND deta_shtm_fg = 'U000300001'
AND stuno = '2013-10260'
;

SELECT SF_BSNS011_CODENM(A.SCHREG_MOD_FG,1), SCHREG_MOD_FG,       
       A.REG_TT_AMT - A.SCAL_TT_AMT,
       A.*
FROM enro200 A
WHERE SCHYY = '2016'
AND SHTM_FG = 'U000200002'
AND deta_shtm_fg = 'U000300001'
AND stuno = '2013-10260'
;
 
SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0326'
ORDER BY A.DISP_ORD, A.CMMN_CD
;

SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE a.USR_DEF_1 = 'U032600003'
;
