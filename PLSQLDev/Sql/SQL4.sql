
-- ������Ȱ�� ���񼭷�����

SELECT * FROM BSNS052 WHERE EQPD_DOC_BUSS_CD = 'BUSS000007' ;
SELECT * FROM BSNS050 ;
SELECT ( SELECT DISTINCT B.EQPD_DOC_NM FROM BSNS050 B WHERE B.EQPD_DOC_CD = A.EQPD_DOC_CD ) AS EQPD_DOC_NM,
       A.* 
FROM BSNS051 A
WHERE A.EQPD_DOC_BUSS_CD = 'BUSS000007' 
AND SUBM_OBJ_YN = 'Y' 
;
SELECT * FROM BSNS053 ;


SELECT * FROM DORM950 
WHERE stuno = '2019-27447'
;

SELECT * 
FROM bsns053
WHERE EQPD_DOC_SUBM_SEQ = '139896'
;


SELECT DECODE(NATI_FG,'C010200018','N','Y') AS FOR_YN
  FROM HURT200
 WHERE RPST_PERS_NO = (SELECT RPST_PERS_NO FROM SREG101 WHERE STUNO = '2019-27447' )
;

SELECT *
FROM BSNS050 T1
     , BSNS051 T2
 WHERE T1.EQPD_DOC_CD      = T2.EQPD_DOC_CD
   AND T2.SUBM_OBJ_YN      = 'Y'
   AND T2.NECE_EQPD_YN     = 'Y'                    /* �ʼ� */
   AND T2.EQPD_DOC_BUSS_CD = 'BUSS000007'
UNION ALL
SELECT *
FROM BSNS050 T1
     , BSNS051 T2
 WHERE T1.EQPD_DOC_CD      = T2.EQPD_DOC_CD
   AND T2.SUBM_OBJ_YN      = 'Y'
   AND T1.EQPD_DOC_CD      = 'DOC0000027'   /* ���񺰰��������� */
   AND T2.EQPD_DOC_BUSS_CD = 'BUSS000007'
;

SELECT *
FROM BSNS050 T1
     , BSNS051 T2
 WHERE T1.EQPD_DOC_CD      = T2.EQPD_DOC_CD
   AND T2.SUBM_OBJ_YN      = 'Y'
   AND T2.NECE_EQPD_YN     = 'Y'                    /* �ʼ� */
   AND T2.EQPD_DOC_BUSS_CD = 'BUSS000007'
UNION ALL
SELECT *
FROM BSNS050 T1
     , BSNS051 T2
 WHERE T1.EQPD_DOC_CD      = T2.EQPD_DOC_CD
   AND T2.SUBM_OBJ_YN      = 'Y'
   AND T1.EQPD_DOC_CD      IN ( 'DOC0000005', 'DOC0000011' )
   AND T2.EQPD_DOC_BUSS_CD = 'BUSS000007'
;

SELECT SYSDATE FROM dual ;
--SELECT DECODE(COUNT(*), 0, 'N', 'Y')
SELECT *
FROM DORM010 T2
WHERE 1=1
AND T2.DORM_SCHE_FG = 'F010800052'
AND ( to_char(T2.RECV_FR_DTTM,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD') AND to_char(T2.RECV_TO_DTTM,'YYYYMMDD') >= TO_CHAR(SYSDATE,'YYYYMMDD') )
;


