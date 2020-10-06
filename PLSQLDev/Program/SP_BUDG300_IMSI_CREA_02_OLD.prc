CREATE OR REPLACE PROCEDURE SP_BUDG300_IMSI_CREA_02
/***************************************************************************************
객 체 명 : SP_BUDG300_IMSI_CREA_02
내    용 : 예산이용처리 (코로나19 특별장학금 지급 관련)
작 성 일 : 2020.09.18.
작 성 자 : 박용주
RETURN값 : 예산이용처리 결과
참고사항 : 리턴값이 0 : 에러  1 : 정상
****************************************************************************************/
(
        OUT_RTN         	OUT NUMBER,                   --처리결과 RETURN값
        OUT_MSG         	OUT VARCHAR2                  --에러 메시지
)
IS
        V_BUDG_DVRS_NO      NUMBER(8);      -- 예산전용번호.(Sequence.SEQ_BUDG300) 
        V_BUDG_FORMA_NO 	NUMBER(8);      -- 예산편성번호.(Sequence.SEQ_BUDG100) 
        
        --V_PGM_ID        	VARCHAR2(20) := 'SP_BUDG300_IMSI_CREA_02';
        V_SR_RESN       	VARCHAR2(250):= '코로나19로 인한 등록금 환불';
		V_CONN_NO           VARCHAR2(80) := 'SNUA040300000000000120160302151813483';
        V_INPT_ID        	VARCHAR2(20) := 'TEMP_CREA_02';
        V_INPT_IP       	VARCHAR2(20) := '147.47.205.196';
        
        
BEGIN

    DELETE BUDG300 
     WHERE INPT_ID = V_INPT_ID;   
     
    DELETE BUDG100 
     WHERE INPT_ID = V_INPT_ID;   
     
    DELETE BUDG310 
     WHERE INPT_ID = V_INPT_ID;   
    
    BEGIN 
    
        -- BUDG300 (SELECT LOOP) : 예산전용. 편성된 예산에 대한 전용사유 발생시 전용기본정보를 등록 관리한다.
        FOR REC_MAIN IN ( SELECT ACNT_YY, 
                                 ACNT_FG, 
                                 ACNT_FG_NM, 
                                 BUDG_FG, 
                                 SEQ, 
                                 QUTE, 
                                 BUDG_DEPT_CD, 
                                 BUDG_DEPT_NM, 
                                 ADJ_DT, 
                                 CYOV_FG, 
                                 CYOV_YY, 
                                 BIZ_CD, 
                                 BIZ_NM, 
                                 BUDG_SBJT_CD_SST, 
                                 BUDG_SBJT_CD_SB, 
                                 BUDG_SBJT_NM, 
                                 BUDGT_PRSNT_AMT, 
                                 ALD_ASGN_AMT, 
                                 BALN, 
                                 BUDG_FORMA_NO
                          FROM TEMP_TUIT_BUDG A ) 
        LOOP 
        
            -- 예산전용번호생성
            SELECT SEQ_BUDG300.NEXTVAL INTO V_BUDG_DVRS_NO FROM DUAL ;
            
            -- BUDG300 : 예산전용. 편성된 예산에 대한 전용사유 발생시 전용기본정보를 등록 관리한다.
            INSERT INTO BUDG300 ( BUDG_DVRS_NO    /* 예산전용번호.(Sequence.SEQ_BUDG300) */
                               ,ACNT_YY         /* 회계연도 */
                               ,ACNT_FG         /* 회계구분.[A0601] */
                               ,BUDG_DEPT_CD    /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */                                                
                               ,DVRS_FG         /* 전용구분.[A0405.1:부서내,2:부서간] */
                               ,APLY_DT         /* 신청일자 */
                               ,ADJ_RESN        /* 조정사유 */
                               ,EL_DOC_CONN_NO  /* 승인요청번호 */
                               ,TRET_DT         /* 처리일자 */
                               ,TRET_FG         /* 처리구분.[1:신청,2:확정,3:반려] */
                               ,TRET_CTNT       
                               ,TRANS_FG        /* 이체구분.[A0408] */ 
                               ,INT_DVRS_YN     /* 자체전용여부 */
                               ,INPT_ID         /* 입력ID */
                               ,INPT_DTTM       /* 입력일시 */
                               ,INPT_IP         /* 입력IP */
                             ) VALUES (
                                V_BUDG_DVRS_NO      /* 예산전용번호 */
                               ,REC_MAIN.ACNT_YY         /* BUDG300회계연도 */
                               ,REC_MAIN.ACNT_FG         /* 회계구분.[A0601] */
                               ,'0056'                   /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
                               ,'A040500004'        /* 전용구분.[1:부서내,2:부서간] */
                               ,REC_MAIN.ADJ_DT          /* 신청일자 - TEMP_TUIT_BUDG.조정일자 */
                               ,V_SR_RESN           /* 조정사유 */
                               ,V_CONN_NO           /* 승인요청번호 */
                               ,REC_MAIN.ADJ_DT          /* 처리일자 - TEMP_TUIT_BUDG.조정일자 */
                               ,'A041400002'        /* 처리구분.[1:신청,2:확정,3:반려] */
                               ,V_SR_RESN
                               ,'A040800003'        /* 이체구분.[4:재배정]*/
                               ,'N'                 /* 자체전용여부 */
                               ,V_INPT_ID           /* 입력ID */
                               ,SYSDATE             /* 입력일시 */
                               ,V_INPT_IP           /* 입력IP */
                             ) ;     
        
            -- 예산편성번호생성
            SELECT SEQ_BUDG100.NEXTVAL INTO V_BUDG_FORMA_NO FROM DUAL ;
                     
            -- 예산편성 신규등록
            MERGE INTO BUDG100 A
            USING ( SELECT V_BUDG_FORMA_NO AS BUDG_FORMA_NO,
                           REC_MAIN.ACNT_YY AS ACNT_YY, 
                           REC_MAIN.ACNT_FG AS ACNT_FG, 
                           REC_MAIN.BUDG_DEPT_CD AS BUDG_DEPT_CD,        
                           REC_MAIN.BUDG_FG AS BUDG_FG,   
                           REC_MAIN.SEQ AS SEQ, 
                           '0' AS BAL_FG,                              /* 수지구분.[1:수입,0:지출] */
                           REC_MAIN.CYOV_FG AS CYOV_FG,                /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] - 이월관련 차후작업. 일단 본예산은 0*/                           
                           REC_MAIN.CYOV_YY AS CYOV_YY,                              
                           REC_MAIN.BIZ_CD AS BIZ_CD,                              
                           SUBSTR(REC_MAIN.BUDG_SBJT_CD_SB,1,2) || '00' AS BUDG_SBJT_CD_SST,   
                           SUBSTR(REC_MAIN.BUDG_SBJT_CD_SB,1,3) || '0' AS BUDG_SBJT_CD_SECT,   
                           SUBSTR(REC_MAIN.BUDG_SBJT_CD_SB,1,4) AS BUDG_SBJT_CD_ITEM,   
                           REC_MAIN.BUDG_SBJT_CD_SB AS BUDG_SBJT_CD_SB,   
                           'A040400001' AS FORMA_FG,                  /* 편성구분.[A0404.0:요구,1:편성,2:조정] */                           
                           0 AS DMND_AMT,                             /* 요구액 */
                           0 AS FORMA_AMT,                            /* 편성액 */
                           0 AS ABUDG_AMT,                            /* 추경액 */                            
                           NULL AS FORMA_DT,
                           'N' AS ABUDG_YN,                           /* 추경여부 */
                           V_INPT_ID AS INPT_ID,
                           SYSDATE AS INPT_DTTM,
                           V_INPT_IP AS INPT_IP
                    FROM DUAL
                  ) B
            ON ( A.ACNT_YY           = B.ACNT_YY
                 AND A.ACNT_FG       = B.ACNT_FG
                 AND A.BUDG_DEPT_CD  = B.BUDG_DEPT_CD
                 AND A.BUDG_FG       = B.BUDG_FG
                 AND A.SEQ           = B.SEQ
                 AND A.BIZ_CD        = B.BIZ_CD
                 AND A.BAL_FG        = B.BAL_FG
                 AND A.CYOV_FG       = B.CYOV_FG
                 AND A.CYOV_YY       = B.CYOV_YY
                 AND A.BUDG_SBJT_CD_SB = B.BUDG_SBJT_CD_SB ) 
            WHEN NOT MATCHED THEN  
                 INSERT ( A.BUDG_FORMA_NO                       /* 예산편성번호.(Sequence.SEQ_BUDG100) */
                        ,A.ACNT_YY                              /* 회계연도 */
                        ,A.ACNT_FG                              /* 회계구분.[A0601] */
                        ,A.BUDG_DEPT_CD                         /* 예산부서코드 */
                        ,A.BUDG_FG                              /* 예산구분.[A0401] */
                        ,A.SEQ                                  /* 차수 */
                        ,A.BAL_FG                               /* 수지구분.[1:수입,0:지출] */
                        ,A.CYOV_FG                              /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
                        ,A.CYOV_YY                              /* 이월연도 */
                        ,A.BIZ_CD
                        ,A.BUDG_SBJT_CD_SST                     /* 예산과목코드_관 */
                        ,A.BUDG_SBJT_CD_SECT                    /* 예산과목코드_항 */
                        ,A.BUDG_SBJT_CD_ITEM                    /* 예산과목코드_목 */
                        ,A.BUDG_SBJT_CD_SB                      /* 예산과목코드_세목 */
                        ,A.FORMA_FG                             /* 편성구분.[A0404.0:요구,1:편성,2:조정] */
                        ,A.DMND_AMT                             /* 요구액 */
                        ,A.FORMA_AMT                            /* 편성액 */
                        ,A.ABUDG_AMT                            /* 추경액 */
                        ,A.FORMA_DT                             /* 편성일자 */
                        ,A.ABUDG_YN                             /* 추경여부 */
                        ,A.INPT_ID                              /* 입력ID */
                        ,A.INPT_DTTM                            /* 입력일시 */
                        ,A.INPT_IP                              /* 입력IP */
                  ) VALUES ( B.BUDG_FORMA_NO                        /* 예산편성번호.(Sequence.SEQ_BUDG100) */
                            ,B.ACNT_YY                              /* 회계연도 */
                            ,B.ACNT_FG                              /* 회계구분.[A0601] */
                            ,B.BUDG_DEPT_CD                         /* 예산부서코드 */
                            ,B.BUDG_FG                              /* 예산구분.[A0401] */
                            ,B.SEQ                                  /* 차수 */
                            ,B.BAL_FG                               /* 수지구분.[1:수입,0:지출] */
                            ,B.CYOV_FG                              /* 이월구분.[A0403. 0:본예산,1:명시,2:사고] */
                            ,B.CYOV_YY                              /* 이월연도 */
                            ,B.BIZ_CD
                            ,B.BUDG_SBJT_CD_SST                     /* 예산과목코드_관 */
                            ,B.BUDG_SBJT_CD_SECT                    /* 예산과목코드_항 */
                            ,B.BUDG_SBJT_CD_ITEM                    /* 예산과목코드_목 */
                            ,B.BUDG_SBJT_CD_SB                      /* 예산과목코드_세목 */
                            ,B.FORMA_FG                             /* 편성구분.[A0404.0:요구,1:편성,2:조정] */                            
                            ,B.DMND_AMT                             /* 요구액 */
                            ,B.FORMA_AMT                            /* 편성액 */
                            ,B.ABUDG_AMT                            /* 추경액 */                            
                            ,B.FORMA_DT                             /* 편성일자 */
                            ,B.ABUDG_YN                             /* 추경여부 */
                            ,B.INPT_ID                              /* 입력ID */
                            ,B.INPT_DTTM                            /* 입력일시 */
                            ,B.INPT_IP                              /* 입력IP */
                  ) ;
                
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
                                   , FXD_YN          /* 확정여부 */
                                   , BUDG_FORMA_NO   /* 예산편성번호 */
                                   , INPT_ID         /* 입력ID */
                                   , INPT_DTTM       /* 입력일시 */
                                   , INPT_IP         /* 입력IP */
                             ) VALUES ( V_BUDG_DVRS_NO                         /* 예산전용번호 */
                                       , ( SELECT LPAD(NVL(MAX(SRNUM), 0) + 1, 2, 0)
                                           FROM BUDG310
                                           WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )  /* 일련번호 */
                                       , REC_MAIN.ACNT_YY
                                       , REC_MAIN.ACNT_FG                  
                                       , '0'                                  /* 입출구분.[0:전출,1:전입] */
                                       , REC_MAIN.BUDG_DEPT_CD                       /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
                                       , REC_MAIN.CYOV_FG                            /* 이월구분 */
                                       , REC_MAIN.CYOV_YY                            /* 이월연도 */
                                       , REC_MAIN.BIZ_CD                      /* 사업코드 */
                                       , REC_MAIN.BUDG_SBJT_CD_SB             /* 예산과목코드_세목 */                                       
                                       , NVL(REC_MAIN.BUDGT_PRSNT_AMT,0)        /* 당초예산 - 단위로 보여주는 용도 따로있고 저장은 실액 그대로*/
                                       , ABS(NVL(REC_MAIN.BALN,0) * 1000) * -1        /* 전용액 */                                       
                                       , REC_MAIN.ADJ_DT                      /* 전용일자 */
                                       , 'Y'                                  /* 확정여부 */                                       
                                       , V_BUDG_FORMA_NO                      /* 예산편성번호 */
                                       , V_INPT_ID                            /* 입력ID */
                                       , SYSDATE                              /* 입력일시 */
                                       , V_INPT_IP                            /* 입력IP */
                             ) ;
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
                                   , FXD_YN          /* 확정여부 */
                                   , BUDG_FORMA_NO   /* 예산편성번호 */
                                   , INPT_ID         /* 입력ID */
                                   , INPT_DTTM       /* 입력일시 */
                                   , INPT_IP         /* 입력IP */
                             ) VALUES ( V_BUDG_DVRS_NO                         /* 예산전용번호 */
                                       , ( SELECT LPAD(NVL(MAX(SRNUM), 0) + 1, 2, 0)
                                           FROM BUDG310
                                           WHERE BUDG_DVRS_NO = V_BUDG_DVRS_NO )  /* 일련번호 */
                                       , REC_MAIN.ACNT_YY
                                       , REC_MAIN.ACNT_FG                  
                                       , '1'                                  /* 입출구분.[0:전출,1:전입] */
                                       , REC_MAIN.BUDG_DEPT_CD                /* 예산부서코드.[부서코드.HURT100.DEPT_CD] */
                                       , REC_MAIN.CYOV_FG                     /* 이월구분 */
                                       , REC_MAIN.CYOV_YY                     /* 이월연도 */
                                       , '0207420'                            /* 사업코드 */
                                       , '431101'                             /* 예산과목코드_세목 */                                       
                                       , 0                                    /* 당초예산 - 단위로 보여주는 용도 따로있고 저장은 실액 그대로*/
                                       , NVL(REC_MAIN.BALN,0) * 1000          /* 전용액 */                                       
                                       , REC_MAIN.ADJ_DT                      /* 전용일자 */
                                       , 'Y'                                  /* 확정여부 */                                       
                                       , V_BUDG_FORMA_NO                      /* 예산편성번호 */
                                       , V_INPT_ID                            /* 입력ID */
                                       , SYSDATE                              /* 입력일시 */
                                       , V_INPT_IP                            /* 입력IP */
                             ) ;                
        
        END LOOP;            
        
        EXCEPTION
            WHEN OTHERS THEN
                OUT_RTN := 0;
                OUT_MSG := '예산이용 처리중 오류가 발생하였습니다.';
                RETURN;
    END; 

    OUT_RTN := 1;
    OUT_MSG := '정상적으로 처리되었습니다.';

    RETURN;
END;
/
