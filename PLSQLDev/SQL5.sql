
SELECT * FROM hurt200 WHERE rpst_pers_no = '2020-19816' ;


SF_DORM200_FOREIGNER_YN ;

SELECT dorm_fg, schyy, shtm_fg, DORM_JOIN_PSN_NO, FOREIGNER_YN OLD_FOREIGNER_YN, SF_DORM200_FOREIGNER_YN(DORM_JOIN_PSN_NO) NEW_FOREIGNER_YN  
FROM dorm200 
WHERE dorm_fg = 'F010900001'
AND schyy = '2020'
AND shtm_fg = 'U000200002'
AND FOREIGNER_YN != SF_DORM200_FOREIGNER_YN(DORM_JOIN_PSN_NO)
;



SELECT * FROM dorm200 WHERE dorm_join_psn_no IN ( '2020-19816', '2020-18565' ) ;
SELECT rpst_pers_no, nati_fg FROM hurt200_damo WHERE rpst_pers_no IN ( '2020-19816', '2020-18565' ) ;

SELECT stuno, entr_fg FROM sreg102 WHERE stuno IN ( '2020-19816', '2020-18565' ) ;
SELECT stuno, entr_fg FROM enro400 WHERE stuno IN ( '2020-19816', '2020-18565' ) ;
SELECT stuno, 'U030100007' FROM sreg601 WHERE stuno IN ( '2020-19816', '2020-18565' ) ;


SELECT * FROM dorm200 WHERE DORM_JOIN_PSN_NO IN ( '2020-19816', '2020-18565' ) ;

SELECT * FROM slg.dorm200_log WHERE DORM_JOIN_PSN_NO = '2020-19816' ;
SELECT * FROM slg.dorm200_log WHERE DORM_JOIN_PSN_NO = '2020-18565' ;


-- ���б��� 
SELECT * FROM bsns011 WHERE grp_cd = 'U0301' ;

-- ���б��� 
    SELECT MAX(NVL(USR_DEF_2,'N')) AS USR_DEF_2 
      FROM (SELECT ENTR_FG from SREG102
             WHERE STUNO = '2020-19816'
            UNION
            SELECT ENTR_FG  FROM ENRO400
            WHERE  STUNO = '2020-19816'
            UNION 
            SELECT 'U030100007' FROM SREG601          --- ����л���� ������(�ܱ���) ���� ������ �������� �ܱ������� üũ �ǰ� ��
            WHERE STUNO = '2020-19816'          
           ) T1,
           BSNS011 T2
     WHERE T1.ENTR_FG = T2.CMMN_CD;
     
    SELECT MAX(NVL(USR_DEF_2,'N')) AS USR_DEF_2 
      FROM (SELECT ENTR_FG from SREG102
             WHERE STUNO = '2020-18565'
            UNION
            SELECT ENTR_FG  FROM ENRO400
            WHERE  STUNO = '2020-18565'
            UNION 
            SELECT 'U030100007' FROM SREG601          --- ����л���� ������(�ܱ���) ���� ������ �������� �ܱ������� üũ �ǰ� ��
            WHERE STUNO = '2020-18565'          
           ) T1,
           BSNS011 T2
     WHERE T1.ENTR_FG = T2.CMMN_CD;
     
