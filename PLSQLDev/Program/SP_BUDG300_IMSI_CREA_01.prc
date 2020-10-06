CREATE OR REPLACE PROCEDURE SP_BUDG300_IMSI_CREA_01
/***************************************************************************************
객 체 명 : SP_BUDG300_IMSI_CREA_01
내    용 : 예산재배정처리 (코로나19 특별장학금 지급 관련)
작 성 일 : 2020.09.17.
작 성 자 : 이민구
수정내역 :
1.수정일 :
2.수정자 :
3.내 용 :
참조객체 :   BUDG100              --예산편성

RETURN값 : 예산배정처리 결과
참고사항 : 리턴값이 0 일 경우는 에러사항이므로 각 서비스 부분에서 예외처리할 것!!!
****************************************************************************************/
(
		OUT_RTN         	   OUT NUMBER,                      --처리결과 RETURN값
		OUT_MSG         	   OUT VARCHAR2                     --에러 메시지
)
IS
		V_BUDG_DVRS_NO    NUMBER(8);
		--V_BUDG_FORMA_NO 	NUMBER(8);
		V_PGM_ID        	VARCHAR2(30) := 'SP_BUDG300_IMSI_CREA_01';
		V_STG_NM        	SSTM056.OCCR_LOC_NM%TYPE;
		V_INPT_ID        	VARCHAR2(20) := 'SR2009-17130_1';  /*  */
        V_SR_RESN       	VARCHAR2(250):= '등록금 환불 재원(수작업일괄처리, SR2009-17130)';
		V_INPT_IP       	VARCHAR2(20) := '147.47.205.196'; /*  */
		V_CONN_NO         VARCHAR2(80) := 'SNUA040300000000000120160302151813483';
		
		V_BUDG_FORMA_NO_CNT          NUMBER(8);
		
		/* 전출  */
		V_BUDG_FORMA_NO_BF           NUMBER(8);
		V_BUDG_SBJT_CD_SB_BF         VARCHAR2(6);
		V_BUDG_SBJT_NM_BF            VARCHAR2(400);
		V_CYOV_FG_BF                 VARCHAR2(10);
		V_CYOV_YY_BF                 VARCHAR2(4);
		V_BIZ_CD_BF                  VARCHAR2(10);
		V_BIZ_SEQ_BF                 NUMBER(20);
		V_ORGN_BUDG_FST_BF           NUMBER(15);
		V_ORGN_BUDG_VIEW_FST_BF      NUMBER(15);
		V_ORGN_BUDG_BF               NUMBER(15);
		V_ORGN_BUDG_VIEW_BF          NUMBER(15);
		V_ASGN_AMT_BF                NUMBER(15);
		V_ASGN_AMT_ORG_BF            NUMBER(15);
		V_WAIT_AMT_BF                NUMBER(15);
		
		/* 전입  */ 
		V_BUDG_FORMA_NO_AF           NUMBER(8);
		V_BUDG_SBJT_CD_SB_AF         VARCHAR2(6);
		V_BUDG_SBJT_NM_AF            VARCHAR2(400);
		V_CYOV_FG_AF                 VARCHAR2(10);
		V_CYOV_YY_AF                 VARCHAR2(4);
		V_BIZ_CD_AF                  VARCHAR2(10);
		V_BIZ_SEQ_AF                 NUMBER(20);
		V_ORGN_BUDG_FST_AF           NUMBER(15);
		V_ORGN_BUDG_VIEW_FST_AF      NUMBER(15);
		V_ORGN_BUDG_AF               NUMBER(15);
		V_ORGN_BUDG_VIEW_AF          NUMBER(15);
		V_ASGN_AMT_AF                NUMBER(15);
		V_ASGN_AMT_ORG_AF            NUMBER(30);
		V_WAIT_AMT_AF                NUMBER(30);
		
		V_BUDG_DEPT_CD							 VARCHAR2(10);
		V_BIZ_CD										 VARCHAR2(10);
		V_BUDG_SBJT_CD_SB						 VARCHAR2(6);
		V_BUDG_DEPT_NM							 VARCHAR2(400);
		V_BIZ_NM       							 VARCHAR2(400);
		V_BUDG_SBJT_NM							 VARCHAR2(400);

BEGIN

    
    DELETE BUDG210
     WHERE INPT_ID = V_INPT_ID;
      
		DELETE BUDG310
		 WHERE INPT_ID = V_INPT_ID;
		 
		DELETE BUDG100
		 WHERE INPT_ID = V_INPT_ID;
   
		DELETE BUDG300
		 WHERE INPT_ID = V_INPT_ID;
     
		BEGIN
				FOR REC IN (SELECT 
	  		  		  		  		 	 ACNT_YY					/* 회계년도 */
													  ,ACNT_FG          /* 회계구분 */
													  ,ACNT_FG_NM       /* 회계구분명 */
													  ,BUDG_FG          /* 예산구분 */
													  ,SEQ              /* 차수 */
													  ,QUTE             /* 분기 */
													  ,BUDG_DEPT_CD     /* 예산부서코드 */
													  ,BUDG_DEPT_NM     /* 예산분서명 */
													  ,ADJ_DT           /* 조정일자 */
													  ,CYOV_FG          /* 이월구분 */
													  ,CYOV_YY          /* 이월연도 */
													  ,BIZ_CD           /* 사업코드 */
													  ,BIZ_NM           /* 사업명 */
													  ,BUDG_SBJT_CD_SST /* 예산과목코드_관 */
													  ,BUDG_SBJT_CD_SB  /* 예산과목코드_세목 */
													  ,BUDG_SBJT_NM     /* 과목명 */
													  ,BUDGT_PRSNT_AMT  /* 현예산액 */
													  ,ALD_ASGN_AMT     /* 기배정액 */
													  ,BALN             /* 잔액 */
													  ,BUDG_FORMA_NO    /* 편성번호 */
											FROM   TEMP_TUIT_BUDG A 
				             WHERE  1 = 1
				               AND  A.BUDG_DEPT_CD    NOT IN   ('0056', '700') /* 재정전략실은 이용에서만 처리 하면 됨. 사범대학교는 자체 처리 */
											)
				LOOP
						V_BUDG_DEPT_CD		:= REC.BUDG_DEPT_CD;
						V_BIZ_CD					:= REC.BIZ_CD;
						V_BUDG_SBJT_CD_SB	:= REC.BUDG_SBJT_CD_SB;
						V_BUDG_DEPT_NM		:= REC.BUDG_DEPT_NM;
						V_BIZ_NM       		:= REC.BIZ_NM;
						V_BUDG_SBJT_NM		:= REC.BUDG_SBJT_NM;				 

						/* 1. 재배정 신청 번호 SEQ 추출  */
						SELECT SEQ_BUDG300.NEXTVAL
						  INTO V_BUDG_DVRS_NO
						  FROM DUAL;
		  

        	/* 2. 재배정 신청 목록 INSERT */
        	V_STG_NM := 'INSERT BUDG300';
				  INSERT INTO BUDG300
				        			       (
								                BUDG_DVRS_NO    /* 예산전용번호.(Sequence.SEQ_BUDG300) */
								               ,ACNT_YY         /* 회계연도 */
								               ,ACNT_FG         /* 회계구분.[A0601] */
								               ,BUDG_DEPT_CD    /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */									               
								               ,DVRS_FG         /* 전용구분.[A0405.1:부서내,2:부서간] */
								               ,APLY_DT         /* 신청일자 */
								               ,ADJ_RESN        /* 조정사유 */
								               ,EL_DOC_CONN_NO  /* 승인요청번호 */
								               ,TRET_DT         /* 처리일자 */
								               ,TRET_FG         /* 처리구분.[1:신청,2:확정,3:반려] */
								               ,INPT_ID         /* 입력ID */
								               ,INPT_DTTM       /* 입력일시 */
								               ,INPT_IP         /* 입력IP */
								               ,TRANS_FG        /* 이체구분.[A0408] */
								             )
								        VALUES
								        	   (
								                V_BUDG_DVRS_NO      /* 예산전용번호 */
								               ,REC.ACNT_YY         /* BUDG300회계연도 */
								               ,REC.ACNT_FG         /* 회계구분.[A0601] */
								               ,REC.BUDG_DEPT_CD    /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
								               ,'A040500002'        /* 전용구분.[1:부서내,2:부서간] */
								               ,REC.ADJ_DT          /* 신청일자 - TEMP_TUIT_BUDG.조정일자 */
								               ,V_SR_RESN           /* 조정사유 */
								               ,V_CONN_NO						/* 승인요청번호 */
								               ,REC.ADJ_DT          /* 처리일자 - TEMP_TUIT_BUDG.조정일자*/
								               ,'A041400002'        /* 처리구분.[1:신청,2:확정,3:반려] */
								               ,V_INPT_ID           /* 입력ID */
								               ,SYSDATE             /* 입력일시 */
								               ,V_INPT_IP           /* 입력IP */
								               ,'A040800004'        /* 이체구분.[4:재배정]*/
								             );
								             
					
					BEGIN
					V_STG_NM := 'SELECT BUDG100(전출)';
					

					SELECT  COUNT(*)
              INTO  V_BUDG_FORMA_NO_CNT
              FROM  BUDG100 A
             WHERE 1 = 1 
          		AND A.FORMA_FG         = 'A040400001'
           		AND A.BAL_FG           = '0'
           		AND A.SEQ              = 0
           		AND A.BUDG_FG          = 'A040100000' /*본예산-0차수*/
           		AND A.BUDG_DEPT_CD 		 = REC.BUDG_DEPT_CD
           		AND A.ACNT_YY   			 = REC.ACNT_YY
           		AND A.ACNT_FG          = REC.ACNT_FG
							AND A.BIZ_CD 					 = REC.BIZ_CD
							AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
  	          AND A.CYOV_YY          = REC.CYOV_YY
           		AND A.CYOV_FG          = REC.CYOV_FG;
           		

         IF  V_BUDG_FORMA_NO_CNT > 0 THEN 
					 SELECT A2.BUDG_FORMA_NO AS BUDG_FORMA_NO
             , A.BUDG_SBJT_CD_SB
             , SF_BUDG002_NM(A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.ACNT_YY,A.ACNT_FG, 4) AS BUDG_SBJT_NM
             , A.CYOV_FG
             , A.CYOV_YY
             , A.BIZ_CD
             , '0' AS BIZ_SEQ
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)))                  AS ORGN_BUDG_FST		     /* 예산액 = 편성액+추경액+전용액 */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)) / 1000)           AS ORGN_BUDG_VIEW_FST	 /* 예산액 = 편성액+추경액+전용액 */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)))    AS ORGN_BUDG            /* 집행잔액 = 편성액+추경액+전용액-집행액 */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)) / 1000 )    AS ORGN_BUDG_VIEW       /* 집행잔액 = 편성액+추경액+전용액-집행액 */
             , TRUNC((NVL(D.ASGN_AMT, 0)  +NVL(C.PRE_ADJ_AMT, 0)) / 1000 )                                   AS ASGN_AMT             /* 기배정액 = 해당 회계연도 해당분기 배정액까지 포함. 해당분기내 이전 조정액도 포함 */
             , NVL(D.ASGN_AMT, 0) + NVL(C.PRE_ADJ_AMT, 0)                                            AS ASGN_AMT_ORG         /* 기배정액 = 해당 회계연도 해당분기 배정액까지 포함. 해당분기내 이전 조정액도 포함 */
             , SF_BUDG100_CURR_AMT2(A.ACNT_YY, A.ACNT_FG, A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.BUDG_DEPT_CD, '', '', 1, '4', A.CYOV_FG, A.CYOV_YY, A2.BUDG_FORMA_NO) AS WAIT_AMT /* 대기액 */
             INTO  V_BUDG_FORMA_NO_BF
                  ,V_BUDG_SBJT_CD_SB_BF
                  ,V_BUDG_SBJT_NM_BF
                  ,V_CYOV_FG_BF
                  ,V_CYOV_YY_BF
                  ,V_BIZ_CD_BF
                  ,V_BIZ_SEQ_BF
                  ,V_ORGN_BUDG_FST_BF
                  ,V_ORGN_BUDG_VIEW_FST_BF
                  ,V_ORGN_BUDG_BF
                  ,V_ORGN_BUDG_VIEW_BF
                  ,V_ASGN_AMT_BF
                  ,V_ASGN_AMT_ORG_BF
                  ,V_WAIT_AMT_BF
          FROM ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , SUM(AMT) AS AMT /* 집행액 */
                   FROM BUDG400
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) F
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ASGN_AMT,0)) AS ASGN_AMT
                   FROM BUDG200
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND REC.ADJ_DT   >= ASGN_DT
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) D /*이전 배정액*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ADJ_AMT, 0)) AS PRE_ADJ_AMT /*해당분기 이전 및 해당분기 조정일자(조회조건) 이전 배정조정액*/
                   FROM BUDG210
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND REC.ADJ_DT   >= ADJ_DT
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND TRET_FG      = 'A041400002'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) C /*이전 배정조정액*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , SUBSTR(BUDG_SBJT_CD_SB,1,2) || '00' AS BUDG_SBJT_CD_SST /* 관 */
                      , BUDG_SBJT_CD_SB                     AS BUDG_SBJT_CD_SB  /* 세목 */
                      , sum(nvl(DVRS_AMT, 0))               AS DVRS_AMT         /* 전용액 */
                   FROM BUDG310
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND FXD_YN       = 'Y'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB ) B         /*전용액*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SST
                      , BUDG_SBJT_CD_SB        as BUDG_SBJT_CD_SB /*세목*/
                      , BUDG_FORMA_NO
                      , sum(FORMA_AMT)         as FORMA_AMT /*편성액*/
                      , sum(nvl(ABUDG_AMT, 0)) as ABUDG_AMT /*추경액*/
                   FROM BUDG100
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
                    AND FORMA_FG     = 'A040400001'
                    AND BAL_FG       = '0'
                    AND SEQ          = 0
                    AND BUDG_FG      = 'A040100000'   /*본예산-0차수*/
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD
                         , BUDG_SBJT_CD_SST, BUDG_SBJT_CD_SB, BUDG_FORMA_NO) A2 /*편성액*/
             , BUDG100 A
         WHERE A.ACNT_YY          = B.ACNT_YY(+)
           and A.ACNT_FG          = B.ACNT_FG(+)
           and A.CYOV_YY          = B.CYOV_YY(+)
           and A.CYOV_FG          = B.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = B.BUDG_SBJT_CD_SB(+) /*세목*/
           and A.BUDG_SBJT_CD_SST = B.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = B.BIZ_CD(+)
           and A.ACNT_YY          = A2.ACNT_YY(+)
           and A.ACNT_FG          = A2.ACNT_FG(+)
           and A.CYOV_YY          = A2.CYOV_YY(+)
           and A.CYOV_FG          = A2.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = A2.BUDG_SBJT_CD_SB(+)        /*세목*/
           and A.BUDG_SBJT_CD_SST = A2.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = A2.BIZ_CD(+)
           AND A.ACNT_YY          = C.ACNT_YY(+)
           and A.ACNT_FG          = C.ACNT_FG(+)
           and A.CYOV_YY          = C.CYOV_YY(+)
           and A.CYOV_FG          = C.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = C.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = C.BIZ_CD(+)
           AND A.ACNT_YY          = D.ACNT_YY(+)
           and A.ACNT_FG          = D.ACNT_FG(+)
           and A.CYOV_YY          = D.CYOV_YY(+)
           and A.CYOV_FG          = D.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = D.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = D.BIZ_CD(+)
           AND A.ACNT_YY          = F.ACNT_YY(+)
           and A.ACNT_FG          = F.ACNT_FG(+)
           AND A.BUDG_DEPT_CD     = F.BUDG_DEPT_CD(+)
           and A.CYOV_YY          = F.CYOV_YY(+)
           and A.CYOV_FG          = F.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = F.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = F.BIZ_CD(+)
           and A.FORMA_FG         = 'A040400001'
           and A.BAL_FG           = '0'
           and A.SEQ              = 0
           and A.BUDG_FG          = 'A040100000' /*본예산-0차수*/
           and A.BUDG_DEPT_CD     = REC.BUDG_DEPT_CD
           and A.ACNT_FG          = REC.ACNT_FG
           and A.ACNT_YY          = REC.ACNT_YY
           AND A.BIZ_CD           = REC.BIZ_CD
           AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
           AND A.CYOV_YY          = REC.CYOV_YY
           AND A.CYOV_FG          = REC.CYOV_FG
           AND ROWNUM             = 1
         order by A.ACNT_YY, A.ACNT_FG, A.BUDG_DEPT_CD, A.BIZ_CD
                , A.BUDG_SBJT_CD_SST, A.BUDG_SBJT_CD_SB, A.CYOV_FG, A.CYOV_YY;
--         EXCEPTION
--	        WHEN NO_DATA_FOUND THEN
--	            OUT_RTN := 0;
--	            OUT_MSG := '재배정상세(전출) 데이터가 없습니다.';
						

	        
--	        IF OUT_RTN = 0 THEN
				ELSE 
         /* 4.편성번호 시퀀스 가져오기  */				  				             
					SELECT SEQ_BUDG100.NEXTVAL
						INTO V_BUDG_FORMA_NO_BF 
					FROM DUAL;
						
     
     			/* 5.BUDG100 INSERT : 예산편성 번호가 없는 경우만  */
     			V_STG_NM := 'INSERT BUDG100(전출)';
						INSERT INTO BUDG100 ( 
						  		  		  		  	BUDG_FORMA_NO     /* 예산편성번호.(Sequence.SEQ_BUDG100) */
						                    , ACNT_YY           /* 회계연도 */
						                    , ACNT_FG           /* 회계구분.[A0601] */
						                    , BUDG_DEPT_CD      /* 예산부서코드 */
						                    , BUDG_FG           /* 예산구분.[A0401] */
						                    , SEQ               /* 차수 */
						                    , BAL_FG            /* 수지구분.[1:수입,0:지출] */
						                    , CYOV_FG           /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
						                    , CYOV_YY           /* 이월연도 */
						                    , BIZ_CD            /* 사업코드 */
						                    , BUDG_SBJT_CD_SST  /* 예산과목코드_관 */
						                    , BUDG_SBJT_CD_SECT /* 예산과목코드_항 */
						                    , BUDG_SBJT_CD_ITEM /* 예산과목코드_목 */
						                    , BUDG_SBJT_CD_SB   /* 예산과목코드_세목 */
						                    , FORMA_FG          /* 편성구분.[A0404.0:요구,1:편성,2:조정] */
						                    , DMND_AMT          /* 요구액 */
						                    , FORMA_AMT         /* 편성액 */
						                    , ABUDG_AMT			    /* 추경액 */
						                    , FORMA_DT          /* 편성일자 */
						                    , ABUDG_YN			    /* 추경여부 */
						                    , INPT_ID           /* 입력ID */
						                    , INPT_DTTM         /* 입력일시 */
						                    , INPT_IP           /* 입력IP */
						           ) VALUES ( V_BUDG_FORMA_NO_AF
						                    , REC.ACNT_YY                          /* 회계연도 */
						                    , REC.ACNT_FG                          /* 회계구분.[A0601] */
						                    , '0056'						                   /* 예산부서코드 재정전략실(고정) */
						                    , 'A040100000'                         /* 예산구분.[A0401] */
						                    , 0                                    /* 차수 */
						                    , 0                                    /* 수지구분.[1:수입,0:지출] */
						                    , REC.CYOV_FG                          /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] - 이월관련 차후작업. 일단 본예산은 0*/
						                    , REC.CYOV_YY                          /* 이월연도  - 이월관련 차후작업. 일단 본예산은  회계연도와 동일*/
						                    , REC.BIZ_CD                           /* 사업코드 */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 2)||'00'   /* 예산과목코드_관 */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 3)||'0'    /* 예산과목코드_항 */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 4)         /* 예산과목코드_목  : 목data 없을경우 세목 집계과목을 구해서 넣어준다*/
						                    , REC.BUDG_SBJT_CD_SB                  /* 예산과목코드_세목 */
						                    , 'A040400001'                         /* 편성구분.[A0404.0:요구,1:편성,2:조정] */
						                    , 0                                    /* 요구액 */
						                    , 0                                    /* 편성액 */
						                    , 0                     		           /* 추경액 */
						                    , TO_CHAR(SYSDATE, 'YYYYMMDD')         /* 편성일자 */
						                    , NULL     	             						   /* 추경여부 */
						                    , V_INPT_ID                            /* 입력ID */
						                    , SYSDATE                              /* 입력일시 */
						                    , V_INPT_IP                            /* 입력IP */
						           				);
						END IF;
					END;
                
          /* 7. BUDG310 INSERT(전출)*/
          V_STG_NM := 'INSERT BUDG310(전출)';
					INSERT INTO BUDG310 ( BUDG_DVRS_NO    /* 예산전용번호 */
		                    , SRNUM           /* 일련번호 */
        		            , ACNT_YY         /* 회계연도 */
		                    , ACNT_FG         /* 회계구분.[A0601] */
        		            , IO_FG           /* 입출구분.[0:전출,1:전입] */
		                    , BUDG_DEPT_CD    /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
		                    , CYOV_FG         /* 이월구분 */
		                    , CYOV_YY         /* 이월연도 */
		                    , BIZ_CD          /* 사업코드 */
        		            , BUDG_SBJT_CD_SB /* 예산과목코드_세목 */
		                    , ORGN_BUDG       /* 당초예산 */
		                    , DVRS_AMT        /* 전용액 */
        		            , DVRS_DT         /* 전용일자 */
		                    , FXD_YN		      /* 확정여부 */
		                    , BUDG_FORMA_NO   /* 예산편성번호 */
        		            , INPT_ID         /* 입력ID */
		                    , INPT_DTTM       /* 입력일시 */
		                    , INPT_IP         /* 입력IP */
		           ) VALUES ( V_BUDG_DVRS_NO                          /* 예산전용번호 */
        		            , ( SELECT lpad(nvl(max(SRNUM), 0) + 1, 2, 0)
		                          FROM BUDG310
		                         WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO) /* 일련번호 */
        		            , REC.ACNT_YY                              /* 회계연도 */
		                    , REC.ACNT_FG                              /* 회계구분.[A0601] */
		                    , '0'                                      /* 입출구분.[0:전출,1:전입] */
        		            , REC.BUDG_DEPT_CD                         /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
        		            , REC.CYOV_FG                              /* 이월구분 */
        		            , REC.CYOV_YY                              /* 이월연도 */
		                    , REC.BIZ_CD                               /* 사업코드 */
		                    , REC.BUDG_SBJT_CD_SB                      /* 예산과목코드_세목 */
        		            , NVL(V_ORGN_BUDG_FST_BF, 0)        			 /* 당초예산 - 단위로 보여주는 용도 따로있고 저장은 실액 그대로*/
		                    , NVL(REC.BALN, 0) * -1 * 1000             /* 전용액 - TEMP_TUIT_BUDG.BALN(차감액)  * -1 */
		                    , REC.ADJ_DT                               /* 전용일자 */
		                    , 'Y'                                      /* 확정여부 */
        			          , V_BUDG_FORMA_NO_BF                       /* 예산편성번호 */
		                    , V_INPT_ID                                /* 입력ID */
		                    , SYSDATE                                  /* 입력일시 */
        		            , V_INPT_IP                                /* 입력IP */
		           );
			           
         /* 8. BUDG210 INSERT(전출)*/
         V_STG_NM := 'INSERT BUDG210(전출)';
					INSERT INTO BUDG210 ( ACNT_YY   /* 회계연도 */
		                    , ACNT_FG         /* 회계구분.[A0601] */
		                    , QUTE            /* 분기 */
		                    , BUDG_DEPT_CD    /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
		                    , ADJ_DT          /* 조정일자 */
		                    , CYOV_FG         /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
		                    , CYOV_YY         /* 이월연도 */
		                    , BIZ_CD          /* 사업코드 */
		                    , BUDG_SBJT_CD_SB /* 예산과목코드_세목 */
		                    , BUDG_CURR_AMT   /* 예산현액 */
		                    , ALD_ASGN_AMT    /* 기배정액 */
		                    , ADJ_AMT         /* 조정액 */
		                    , ADJ_RESN        /* 조정사유 */
		                    , INPT_ID         /* 입력ID */
		                    , INPT_DTTM       /* 입력일시 */
		                    , INPT_IP         /* 입력IP */
		                    , TRET_FG         /* 처리구분 */
		                    , BUDG_DVRS_NO
		                    , SRNUM
		                    , SEQ
		           ) VALUES ( REC.ACNT_YY                  /* 회계연도 */
		                    , REC.ACNT_FG                  /* 회계구분.[A0601] */
		                    , REC.QUTE                     /* 분기 */
		                    , REC.BUDG_DEPT_CD             /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
		                    , REC.ADJ_DT                   /* 조정일자 */
		                    , REC.CYOV_FG                  /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
		                    , REC.CYOV_YY                  /* 이월연도 */
		                    , REC.BIZ_CD                   /* 사업코드 */
		                    , REC.BUDG_SBJT_CD_SB          /* 예산과목코드_세목 */
		                    , NVL(V_ORGN_BUDG_FST_BF, 0) + (NVL(REC.BALN, 0) * -1 * 1000)  /* 예산액 */
		                    , NVL(V_ASGN_AMT_ORG_BF, 0)    /* 기배정액 */
		                    , NVL(REC.BALN, 0) *-1 * 1000  /* 조정액 */
		                    , V_SR_RESN                    /* 조정사유 */
		                    , V_INPT_ID                    /* 입력ID */
		                    , SYSDATE                      /* 입력일시 */
		                    , V_INPT_IP                    /* 입력IP */
		                    , 'A041400002'                 /* 처리구분.[A0403. 2:확정] */
		                    , V_BUDG_DVRS_NO
		                    ,( SELECT lpad(nvl(max(SRNUM), 0), 2, 0)
		                         FROM BUDG310
		                        WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )
		                    ,( SELECT NVL(MAX(SEQ),0) + 1
												     FROM BUDG210
												    WHERE ACNT_YY = REC.ACNT_YY
												      AND ACNT_FG = REC.ACNT_FG
												      AND BUDG_DEPT_CD = REC.BUDG_DEPT_CD
												      AND ADJ_DT = REC.ADJ_DT)
		           );
		          
		       BEGIN 
		       V_BUDG_DEPT_CD		:= '0056';
		 		   V_STG_NM := 'SELEC BUDG100(전입)';
		 		         
		       SELECT  COUNT(*)
              INTO  V_BUDG_FORMA_NO_CNT
              FROM  BUDG100 A
             WHERE 1 = 1 
          		AND A.FORMA_FG         = 'A040400001'
           		AND A.BAL_FG           = '0'
           		AND A.SEQ              = 0
           		AND A.BUDG_FG          = 'A040100000' /*본예산-0차수*/
           		AND A.BUDG_DEPT_CD 		 = '0056'
           		AND A.ACNT_YY   			 = REC.ACNT_YY
           		AND A.ACNT_FG          = REC.ACNT_FG
							AND A.BIZ_CD 					 = REC.BIZ_CD
							AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
  	          AND A.CYOV_YY          = REC.CYOV_YY
           		AND A.CYOV_FG          = REC.CYOV_FG;
--		  DBMS_OUTPUT.PUT_LINE('V_BUDG_FORMA_NO_CNT(전입) : '||V_BUDG_FORMA_NO_CNT);     
			IF V_BUDG_FORMA_NO_CNT > 0 THEN		
           /* 9. 재배정 상세 정보(전입) */
					 SELECT A2.BUDG_FORMA_NO AS BUDG_FORMA_NO
             , A.BUDG_SBJT_CD_SB
             , SF_BUDG002_NM(A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.ACNT_YY,A.ACNT_FG, 4) AS BUDG_SBJT_NM
             , A.CYOV_FG
             , A.CYOV_YY
             , A.BIZ_CD
             , '0' AS BIZ_SEQ
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)))                  AS ORGN_BUDG_FST		     /* 예산액 = 편성액+추경액+전용액 */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0)) / 1000)           AS ORGN_BUDG_VIEW_FST	 /* 예산액 = 편성액+추경액+전용액 */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)))    AS ORGN_BUDG            /* 집행잔액 = 편성액+추경액+전용액-집행액 */
             , TRUNC((NVL(A2.FORMA_AMT,0) +NVL(A2.ABUDG_AMT,0) +NVL(B.DVRS_AMT,0) -NVL(F.AMT,0)) / 1000 )    AS ORGN_BUDG_VIEW       /* 집행잔액 = 편성액+추경액+전용액-집행액 */
             , TRUNC((NVL(D.ASGN_AMT, 0)  +NVL(C.PRE_ADJ_AMT, 0)) / 1000 )                                   AS ASGN_AMT             /* 기배정액 = 해당 회계연도 해당분기 배정액까지 포함. 해당분기내 이전 조정액도 포함 */
             , NVL(D.ASGN_AMT, 0) + NVL(C.PRE_ADJ_AMT, 0)                                            AS ASGN_AMT_ORG         /* 기배정액 = 해당 회계연도 해당분기 배정액까지 포함. 해당분기내 이전 조정액도 포함 */
             , SF_BUDG100_CURR_AMT2(A.ACNT_YY, A.ACNT_FG, A.BIZ_CD, A.BUDG_SBJT_CD_SB, A.BUDG_DEPT_CD, '', '', 1, '4', A.CYOV_FG, A.CYOV_YY, A2.BUDG_FORMA_NO) AS WAIT_AMT /* 대기액 */
             INTO  V_BUDG_FORMA_NO_AF
                  ,V_BUDG_SBJT_CD_SB_AF
                  ,V_BUDG_SBJT_NM_AF
                  ,V_CYOV_FG_AF
                  ,V_CYOV_YY_AF
                  ,V_BIZ_CD_AF
                  ,V_BIZ_SEQ_AF
                  ,V_ORGN_BUDG_FST_AF
                  ,V_ORGN_BUDG_VIEW_FST_AF
                  ,V_ORGN_BUDG_AF
                  ,V_ORGN_BUDG_VIEW_AF
                  ,V_ASGN_AMT_AF
                  ,V_ASGN_AMT_ORG_AF
                  ,V_WAIT_AMT_AF
          FROM ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , SUM(AMT) AS AMT /* 집행액 */
                   FROM BUDG400
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = '0056' /* 재정전략실(고정)  */
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) F
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ASGN_AMT,0)) AS ASGN_AMT
                   FROM BUDG200
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = '0056' /* 재정전략실(고정) */
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND REC.ADJ_DT   >= ASGN_DT
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) D /*이전 배정액*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SB
                      , sum(nvl(ADJ_AMT, 0)) AS PRE_ADJ_AMT /*해당분기 이전 및 해당분기 조정일자(조회조건) 이전 배정조정액*/
                   FROM BUDG210
                  WHERE ACNT_YY      = REC.ACNT_YY
                    AND ACNT_FG      = REC.ACNT_FG
                    AND BUDG_DEPT_CD = '0056' /* 재정전략실(고정) */
                    AND REC.ADJ_DT   >= ADJ_DT
                    AND SIGN( REC.QUTE - QUTE ) != -1
                    AND TRET_FG      = 'A041400002'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB) C /*이전 배정조정액*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , SUBSTR(BUDG_SBJT_CD_SB,1,2) || '00' AS BUDG_SBJT_CD_SST /* 관 */
                      , BUDG_SBJT_CD_SB                     AS BUDG_SBJT_CD_SB  /* 세목 */
                      , sum(nvl(DVRS_AMT, 0))               AS DVRS_AMT         /* 전용액 */
                   FROM BUDG310
                  WHERE ACNT_YY      = REC.ACNT_YY
                    and ACNT_FG      = REC.ACNT_FG
                    and BUDG_DEPT_CD = '0056' /* 재정전략실(고정) */
                    and FXD_YN       = 'Y'
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD, BUDG_SBJT_CD_SB ) B         /*전용액*/
             , ( SELECT ACNT_YY
                      , ACNT_FG
                      , BUDG_DEPT_CD
                      , CYOV_FG
                      , CYOV_YY
                      , BIZ_CD
                      , BUDG_SBJT_CD_SST
                      , BUDG_SBJT_CD_SB        as BUDG_SBJT_CD_SB /*세목*/
                      , BUDG_FORMA_NO
                      , sum(FORMA_AMT)         as FORMA_AMT /*편성액*/
                      , sum(nvl(ABUDG_AMT, 0)) as ABUDG_AMT /*추경액*/
                   FROM BUDG100
                  WHERE ACNT_YY      = REC.ACNT_YY
                    and ACNT_FG      = REC.ACNT_FG
                    and BUDG_DEPT_CD = '0056' /* 재정전략실(고정) */
                    and FORMA_FG     = 'A040400001'
                    and BAL_FG       = '0'
                    and SEQ          = 0
                    and BUDG_FG      = 'A040100000'   /*본예산-0차수*/
                  GROUP BY ACNT_YY, ACNT_FG, BUDG_DEPT_CD, CYOV_FG, CYOV_YY, BIZ_CD
                         , BUDG_SBJT_CD_SST, BUDG_SBJT_CD_SB, BUDG_FORMA_NO) A2 /*편성액*/
             , BUDG100 A
         WHERE A.ACNT_YY          = B.ACNT_YY(+)
           and A.ACNT_FG          = B.ACNT_FG(+)
           and A.CYOV_YY          = B.CYOV_YY(+)
           and A.CYOV_FG          = B.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = B.BUDG_SBJT_CD_SB(+) /*세목*/
           and A.BUDG_SBJT_CD_SST = B.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = B.BIZ_CD(+)
           and A.ACNT_YY          = A2.ACNT_YY(+)
           and A.ACNT_FG          = A2.ACNT_FG(+)
           and A.CYOV_YY          = A2.CYOV_YY(+)
           and A.CYOV_FG          = A2.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = A2.BUDG_SBJT_CD_SB(+)        /*세목*/
           and A.BUDG_SBJT_CD_SST = A2.BUDG_SBJT_CD_SST(+)
           and A.BIZ_CD           = A2.BIZ_CD(+)
           AND A.ACNT_YY          = C.ACNT_YY(+)
           and A.ACNT_FG          = C.ACNT_FG(+)
           and A.CYOV_YY          = C.CYOV_YY(+)
           and A.CYOV_FG          = C.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = C.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = C.BIZ_CD(+)
           AND A.ACNT_YY          = D.ACNT_YY(+)
           and A.ACNT_FG          = D.ACNT_FG(+)
           and A.CYOV_YY          = D.CYOV_YY(+)
           and A.CYOV_FG          = D.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = D.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = D.BIZ_CD(+)
           AND A.ACNT_YY          = F.ACNT_YY(+)
           and A.ACNT_FG          = F.ACNT_FG(+)
           AND A.BUDG_DEPT_CD     = F.BUDG_DEPT_CD(+)
           and A.CYOV_YY          = F.CYOV_YY(+)
           and A.CYOV_FG          = F.CYOV_FG(+)
           and A.BUDG_SBJT_CD_SB  = F.BUDG_SBJT_CD_SB(+)
           and A.BIZ_CD           = F.BIZ_CD(+)
           and A.FORMA_FG         = 'A040400001'
           and A.BAL_FG           = '0'
           and A.SEQ              = 0
           and A.BUDG_FG          = 'A040100000' /*본예산-0차수*/
           and A.BUDG_DEPT_CD     = '0056' /* 재정전략실(고정) */
           and A.ACNT_FG          = REC.ACNT_FG
           and A.ACNT_YY          = REC.ACNT_YY
           AND A.BIZ_CD           = REC.BIZ_CD
           AND A.BUDG_SBJT_CD_SB  = REC.BUDG_SBJT_CD_SB
           AND A.CYOV_YY          = REC.CYOV_YY
           AND A.CYOV_FG          = REC.CYOV_FG
           AND ROWNUM             = 1
         order by A.ACNT_YY, A.ACNT_FG, A.BUDG_DEPT_CD, A.BIZ_CD
                , A.BUDG_SBJT_CD_SST, A.BUDG_SBJT_CD_SB, A.CYOV_FG, A.CYOV_YY;
--         EXCEPTION
--	        WHEN NO_DATA_FOUND THEN
--	            OUT_RTN := 0;
--	            OUT_MSG := '재배정상세(전입) 데이터가 없습니다.';

    	
		
--			IF OUT_RTN = 0 THEN
			ELSE 
         /* 10.편성번호 시퀀스 가져오기  */				  				             
					SELECT SEQ_BUDG100.NEXTVAL
						INTO V_BUDG_FORMA_NO_AF 
					FROM DUAL;
						
     
     			/* 11.BUDG100 INSERT : 예산편성 번호가 없는 경우만  */
						INSERT INTO BUDG100 ( 
						  		  		  		  	BUDG_FORMA_NO     /* 예산편성번호.(Sequence.SEQ_BUDG100) */
						                    , ACNT_YY           /* 회계연도 */
						                    , ACNT_FG           /* 회계구분.[A0601] */
						                    , BUDG_DEPT_CD      /* 예산부서코드 */
						                    , BUDG_FG           /* 예산구분.[A0401] */
						                    , SEQ               /* 차수 */
						                    , BAL_FG            /* 수지구분.[1:수입,0:지출] */
						                    , CYOV_FG           /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
						                    , CYOV_YY           /* 이월연도 */
						                    , BIZ_CD            /* 사업코드 */
						                    , BUDG_SBJT_CD_SST  /* 예산과목코드_관 */
						                    , BUDG_SBJT_CD_SECT /* 예산과목코드_항 */
						                    , BUDG_SBJT_CD_ITEM /* 예산과목코드_목 */
						                    , BUDG_SBJT_CD_SB   /* 예산과목코드_세목 */
						                    , FORMA_FG          /* 편성구분.[A0404.0:요구,1:편성,2:조정] */
						                    , DMND_AMT          /* 요구액 */
						                    , FORMA_AMT         /* 편성액 */
						                    , ABUDG_AMT			    /* 추경액 */
						                    , FORMA_DT          /* 편성일자 */
						                    , ABUDG_YN			    /* 추경여부 */
						                    , INPT_ID           /* 입력ID */
						                    , INPT_DTTM         /* 입력일시 */
						                    , INPT_IP           /* 입력IP */
						           ) VALUES ( V_BUDG_FORMA_NO_AF
						                    , REC.ACNT_YY                          /* 회계연도 */
						                    , REC.ACNT_FG                          /* 회계구분.[A0601] */
						                    , '0056'						                   /* 예산부서코드 재정전략실(고정) */
						                    , 'A040100000'                         /* 예산구분.[A0401] */
						                    , 0                                    /* 차수 */
						                    , 0                                    /* 수지구분.[1:수입,0:지출] */
						                    , REC.CYOV_FG                          /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] - 이월관련 차후작업. 일단 본예산은 0*/
						                    , REC.CYOV_YY                          /* 이월연도  - 이월관련 차후작업. 일단 본예산은  회계연도와 동일*/
						                    , REC.BIZ_CD                           /* 사업코드 */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 2)||'00'   /* 예산과목코드_관 */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 3)||'0'    /* 예산과목코드_항 */
						                    , SUBSTR(REC.BUDG_SBJT_CD_SB, 1, 4)         /* 예산과목코드_목  : 목data 없을경우 세목 집계과목을 구해서 넣어준다*/
						                    , REC.BUDG_SBJT_CD_SB                  /* 예산과목코드_세목 */
						                    , 'A040400001'                         /* 편성구분.[A0404.0:요구,1:편성,2:조정] */
						                    , 0                                    /* 요구액 */
						                    , 0                                    /* 편성액 */
						                    , 0                     		           /* 추경액 */
						                    , TO_CHAR(SYSDATE, 'YYYYMMDD')         /* 편성일자 */
						                    , NULL     	             						   /* 추경여부 */
						                    , V_INPT_ID                            /* 입력ID */
						                    , SYSDATE                              /* 입력일시 */
						                    , V_INPT_IP                            /* 입력IP */
						           				);
					       
						END IF;
					END;
					
          /* 12. BUDG310 INSERT(전입)*/
					INSERT INTO BUDG310 ( BUDG_DVRS_NO    /* 예산전용번호 */
		                    , SRNUM           /* 일련번호 */
        		            , ACNT_YY         /* 회계연도 */
		                    , ACNT_FG         /* 회계구분.[A0601] */
        		            , IO_FG           /* 입출구분.[0:전출,1:전입] */
		                    , BUDG_DEPT_CD    /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
		                    , CYOV_FG         /* 이월구분 */
		                    , CYOV_YY         /* 이월연도 */
		                    , BIZ_CD          /* 사업코드 */
        		            , BUDG_SBJT_CD_SB /* 예산과목코드_세목 */
		                    , ORGN_BUDG       /* 당초예산 */
		                    , DVRS_AMT        /* 전용액 */
        		            , DVRS_DT         /* 전용일자 */
		                    , FXD_YN		  /* 확정여부 */
		                    , BUDG_FORMA_NO   /* 예산편성번호 */
        		            , INPT_ID         /* 입력ID */
		                    , INPT_DTTM       /* 입력일시 */
		                    , INPT_IP         /* 입력IP */
		           ) VALUES ( V_BUDG_DVRS_NO                           /* 예산전용번호 */
        		            , ( SELECT lpad(nvl(max(SRNUM), 0) + 1, 2, 0)
		                          FROM BUDG310
		                         WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO)  /* 일련번호 */
        		            , REC.ACNT_YY                              /* 회계연도 */
		                    , REC.ACNT_FG                              /* 회계구분.[A0601] */
		                    , '1'                                      /* 입출구분.[0:전출,1:전입] */
        		            , '0056'		                               /* 예산부서코드.[부서코드.HURT100.DEPT_CD] - 0056:재정전략실(고정) */
        		            , REC.CYOV_FG                              /* 이월구분 */
        		            , REC.CYOV_YY                              /* 이월연도 */
		                    , REC.BIZ_CD                               /* 사업코드 */
		                    , REC.BUDG_SBJT_CD_SB                      /* 예산과목코드_세목 */
        		            , 0                                        /* 당초예산 - 단위로 보여주는 용도 따로있고 저장은 실액 그대로*/
		                    , REC.BALN * 1000                          /* 전용액 */
		                    , REC.ADJ_DT                               /* 전용일자 */
		                    , 'Y'                                      /* 확정여부 */
        			          ,V_BUDG_FORMA_NO_AF		                     /* 예산편성번호 */
		                    , V_INPT_ID                                /* 입력ID */
		                    , SYSDATE                                  /* 입력일시 */
        		            , V_INPT_IP                                /* 입력IP */
		           );
			           
         /* 10. BUDG210 INSERT(전입)*/
					INSERT INTO BUDG210 ( ACNT_YY         /* 회계연도 */
		                    , ACNT_FG         /* 회계구분.[A0601] */
		                    , QUTE            /* 분기 */
		                    , BUDG_DEPT_CD    /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
		                    , ADJ_DT          /* 조정일자 */
		                    , CYOV_FG         /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
		                    , CYOV_YY         /* 이월연도 */
		                    , BIZ_CD          /* 사업코드 */
		                    , BUDG_SBJT_CD_SB /* 예산과목코드_세목 */
		                    , BUDG_CURR_AMT   /* 예산현액 */
		                    , ALD_ASGN_AMT    /* 기배정액 */
		                    , ADJ_AMT         /* 조정액 */
		                    , ADJ_RESN        /* 조정사유 */
		                    , INPT_ID         /* 입력ID */
		                    , INPT_DTTM       /* 입력일시 */
		                    , INPT_IP         /* 입력IP */
		                    , TRET_FG         /* 처리구분 */
		                    , BUDG_DVRS_NO
		                    , SRNUM
		                    , SEQ
		           ) VALUES ( REC.ACNT_YY                  /* 회계연도 */
		                    , REC.ACNT_FG                  /* 회계구분.[A0601] */
		                    , REC.QUTE                     /* 분기 */
		                    , '0056'                       /* 예산부서코드.[부서코드.HURT100.DEPT_CD] - 0056:재정전략실(고정) */
		                    , REC.ADJ_DT                   /* 조정일자 */
		                    , REC.CYOV_FG                  /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
		                    , REC.CYOV_YY                  /* 이월연도 */
		                    , REC.BIZ_CD                   /* 사업코드 */
		                    , REC.BUDG_SBJT_CD_SB          /* 예산과목코드_세목 */
		                    , NVL(V_ORGN_BUDG_FST_AF, 0) + (NVL(REC.BALN, 0) * 1000)  /* 예산액 */
		                    , NVL(V_ASGN_AMT_ORG_AF, 0)    /* 기배정액 */
		                    , NVL(REC.BALN, 0) * 1000      /* 조정액 */ 
		                    , V_SR_RESN                    /* 조정사유 */
		                    , V_INPT_ID                    /* 입력ID */
		                    , SYSDATE                      /* 입력일시 */
		                    , V_INPT_IP                    /* 입력IP */
		                    , 'A041400002'                 /* 처리구분 */
		                    , V_BUDG_DVRS_NO
		                    ,( SELECT lpad(nvl(max(SRNUM), 0), 2, 0)
		                         FROM BUDG310
		                        WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )
		                    ,( SELECT NVL(MAX(SEQ),0) + 1
												     FROM BUDG210
												    WHERE ACNT_YY = REC.ACNT_YY
												      AND ACNT_FG = REC.ACNT_FG
												      AND BUDG_DEPT_CD = '0056'  /* 0056:재정전략실(고정)*/
												      AND ADJ_DT = REC.ADJ_DT)
		           );


        END LOOP;
        EXCEPTION
	        WHEN OTHERS THEN
	            OUT_RTN := 0;
	            V_STG_NM := 'V_STG_NM    = '||CHR(39)|| V_STG_NM ||CHR(39)||CHR(13)||CHR(10)||
--	            			'OUT_MSG				   = '||CHR(39)|| OUT_MSG ||CHR(39)||CHR(13)||CHR(10)||
	            			'V_BUDG_DEPT_CD    = '||CHR(39)|| V_BUDG_DEPT_CD ||CHR(39)||CHR(13)||CHR(10)||
	            			'V_BUDG_DEPT_NM    = '||CHR(39)|| V_BUDG_DEPT_NM ||CHR(39)||CHR(13)||CHR(10)||
                    'V_BIZ_CD          = '||CHR(39)|| V_BIZ_CD ||CHR(39)||CHR(13)||CHR(10)||
                    'V_BIZ_NM          = '||CHR(39)|| V_BIZ_NM ||CHR(39)||CHR(13)||CHR(10)||
                    'V_BUDG_SBJT_CD_SB = '||CHR(39)|| V_BUDG_SBJT_CD_SB||CHR(39)||CHR(10)||
                    'V_BUDG_SBJT_NM    = '||CHR(39)|| V_BUDG_SBJT_NM||CHR(39);
	            
	            SP_SSTM056_CREA(V_PGM_ID, V_STG_NM , SQLCODE, SQLERRM, '', '');

	            OUT_MSG := OUT_MSG||CHR(13)||CHR(10)||CHR(13)||CHR(10)||'확인 후 재시도 하세요';
	            RETURN;
    END; 


    OUT_RTN := 1;
    OUT_MSG := '정상적으로 처리되었습니다.';

    RETURN;
END;
/
