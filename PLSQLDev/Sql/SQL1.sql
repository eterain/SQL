SELECT * FROM snumob2.mobi041 ;

SELECT * FROM mobi040 ;


        SELECT A.ROUTE_NM AS CD
		  FROM snumob2.MOBI041 A
	  GROUP BY A.ROUTE_NM
	  ORDER BY A.ROUTE_NM ;
      
        SELECT SEQ,PERS_KOR_NM,HANDP_NO,ROUTE_NM,TO_CHAR(CMG_DATE,'YYYY-MM-DD hh:mi:ss') AS CMG_DATE,
		       INPT_ID,INPT_DTTM,INPT_IP,MOD_ID,MOD_DTTM,MOD_IP
          FROM snumob2.MOBI041 A
	     WHERE 1 = 1 ;      
      
      
  /* MOBI041.find01 ¼ÅÆ²¹ö½ºÅ¾½Â±â·ÏÁ¶È¸ */
  SELECT SEQ,
         PERS_KOR_NM,
         HANDP_NO,
         ROUTE_NM,
         TO_CHAR(CMG_DATE, 'YYYY-MM-DD hh:mi:ss') AS CMG_DATE,
         INPT_ID,
         INPT_DTTM,
         INPT_IP,
         MOD_ID,
         MOD_DTTM,
         MOD_IP
    FROM snumob2.MOBI041 A
   WHERE 1 = 1
     AND TO_CHAR(A.CMG_DATE, 'YYYYMMDD') >=
         TO_CHAR(SYSDATE - 28, 'YYYYMMDD')
     AND TO_CHAR(A.CMG_DATE, 'YYYYMMDD') BETWEEN NVL('', '20000101') AND
         NVL('', '99999999')
   ORDER BY SEQ; 
   
	SELECT A.ROUTE_NM AS CD
	  FROM snumob2.MOBI041 A
	  GROUP BY A.ROUTE_NM
	  ORDER BY A.ROUTE_NM   ;
