SELECT * FROM ESIN520;
SELECT * FROM ESIN521;
SELECT * FROM ESIN603;
SELECT * FROM ESIN604;
SELECT * FROM BSNS011 WHERE GRP_CD = 'U0271' ;

/*
U027100005 : �����ױ�������
U027100007 : ������
U027100011 : �����ʴ����
U027100008 : �Ǳ⼺��
U027100013 : ��2�ܱ���
--U027100009 : ����� 
*/

SELECT T3.FL_SCOR,
       (SELECT SUM(SELECT_ELEMNT_FMAK_SCOR)
          FROM ESIN521
         WHERE COLL_UNIT_NO = T3.COLL_UNIT_NO
           AND ADPT_STG_FG = T3.SCRN_STG_FG
           AND SELECT_ELEMNT_FG = T3.SELECT_ELEMNT_FG) AS MAX_SCOR,
       T3.*
  FROM ESIN604 T3
 WHERE FL_SCOR > (SELECT NVL(SUM(SELECT_ELEMNT_FMAK_SCOR),999999)
                    FROM ESIN521
                   WHERE 1 = 1
                     AND COLL_UNIT_NO = T3.COLL_UNIT_NO
                     AND ADPT_STG_FG = T3.SCRN_STG_FG
                     AND SELECT_ELEMNT_FG = T3.SELECT_ELEMNT_FG)
AND T3.SELECT_ELEMNT_FG IN ('U027100005', 'U027100007', 'U027100011', 'U027100008', 'U027100013')                      
;

SELECT * FROM ESIN521 
WHERE COLL_UNIT_NO = '20200204011502930931';

SELECT * FROM snumob2.mobi040 ;

SELECT * FROM snumob2.mobi041 ;
