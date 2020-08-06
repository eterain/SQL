CREATE OR REPLACE PROCEDURE SP_ESIN604_ENG_CHK
(   -- IN_COLL_UNIT_NO			IN ESIN604.COLL_UNIT_NO%TYPE			/* ����������ȣ */
-- ,	IN_SCRN_STG_FG			IN ESIN604.SCRN_STG_FG%TYPE				/* �����ܰ豸�� */
-- ,	IN_SELECT_ELEMNT_FG		IN ESIN604.SELECT_ELEMNT_FG%TYPE		/* ������ұ��� */
-- ,	IN_GENRL_SELECT_CHG_YN	IN ESIN604.GENRL_SELECT_CHG_YN%TYPE		/* �Ϲ�������ȯ���� */
-- ,	IN_SELECT_YY            IN ESIN600.SELECT_YY%TYPE				/* �����⵵ */
-- ,   IN_SELECT_FG            IN ESIN600.SELECT_FG%TYPE               /* �������� */
-- ,   IN_COLL_FG              IN ESIN600.COLL_FG%TYPE					/* �������� */
-- ,   IN_APLY_QUAL_FG         IN ESIN600.APLY_QUAL_FG%TYPE			/* �����ڰ� */
-- ,   IN_DETA_APLY_QUAL_FG    IN ESIN600.DETA_APLY_QUAL_FG%TYPE		/* ���������ڰ� */
-- ,   IN_APLY_CORS_FG         IN ESIN600.APLY_CORS_FG%TYPE			/* ���� */
-- ,   IN_APLY_COLG_FG         IN ESIN600.APLY_COLG_FG%TYPE			/* �ܰ����� */
-- ,   IN_APLY_COLL_UNIT_CD    IN ESIN600.APLY_COLL_UNIT_CD%TYPE		/* ���������ڵ� */
-- ,   IN_EXAM_NO              IN ESIN600.EXAM_NO%TYPE					/* �����ȣ */
-- ,	IN_FL_SCOR				IN ESIN604.FL_SCOR%TYPE					/* �������� */
-- ,	IN_INPT_ID				IN ESIN604.INPT_ID%TYPE					/* ������ ID */
-- ,	IN_INPT_IP				IN ESIN604.INPT_IP%TYPE					/* ������ IP */
-- ,	IN_MOD_ID				IN ESIN604.MOD_ID%TYPE					/* ������ ID */
-- ,	IN_MOD_IP				IN ESIN604.MOD_IP%TYPE					/* ������ IP */
-- ,   
    OUT_RTN                 OUT INTEGER								/* �����(OUT) */
,   OUT_MSG                 OUT VARCHAR2							/* ��������(OUT) */
)
IS
/******************************************************************************
	���α׷���	: SP_ESIN604_ENG_CHK
	�������	: �����Է� ��ȿ�� �˻�.
	������	: �����Է� ��ȿ�� �˻�. TRUE = NULL, FALSE = ����ڸ�� [ �����ȣ , ����, �������� ]
------------------------------------------------------------------------------
	��������		������		��������
------------------------------------------------------------------------------
	2020.07.28      �ڿ��� 	���� �ۼ�
******************************************************************************/
       
-- ȭ�鿡�� ���� �Ķ���ͷ� ��� ���������� ���Ѵ�. 
CURSOR CUR1 IS
    SELECT COLL_UNIT_NO
           ,'U027200001' AS SCRN_STG_FG      --  IN_SCRN_STG_FG AS SCRN_STG_FG    -- �����ܰ�
         , A.SELECT_YY
         , A.SELECT_FG
         , A.COLL_FG
         , A.APLY_QUAL_FG
         , A.APLY_CORS_FG
         , 'U027100009' AS SELECT_ELEMNT_FG -- �����
      FROM ESIN520 A
     WHERE A.SELECT_YY = '2020'         -- IN_SELECT_YY                 
       AND A.SELECT_FG = 'U025700001'   -- IN_SELECT_FG
       AND A.COLL_FG = 'U025800002'     -- IN_COLL_FG
       -- AND A.APLY_QUAL_FG = NVL(IN_APLY_QUAL_FG, A.APLY_QUAL_FG)
       -- AND A.APLY_COLG_FG = NVL(IN_APLY_COLG_FG, A.APLY_COLG_FG)
       -- AND A.APLY_CORS_FG = NVL(IN_APLY_CORS_FG, A.APLY_CORS_FG)
       -- AND A.COLL_UNIT_NO = NVL(IN_COLL_UNIT_NO, A.COLL_UNIT_NO)
       AND EXISTS (
                SELECT 1
                  FROM ESIN603 X
                 WHERE X.COLL_UNIT_NO = A.COLL_UNIT_NO
                   -- AND X.EXAM_NO = NVL(IN_EXAM_NO, X.EXAM_NO)
                   AND X.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002', 'U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009', 'U027800014')   -- TEPS, OLD_TEPS, TOEFL PBT, TOEFL CBT, TOEFL IBT, TOEFL_BEST, TOEIC, ����
           )
    ;

BEGIN           

    FOR C1 IN CUR1 LOOP      
    
        FOR CUR2 IN (
        
            WITH t1 AS (
                SELECT b.COLL_UNIT_NO
                     , c1.SCRN_STG_FG AS SCRN_STG_FG
                     , c1.SELECT_YY AS SELECT_YY
                     , c1.SELECT_FG AS SELECT_FG
                     , c1.COLL_FG AS COLL_FG
                     , NVL(b.STG1_GENRL_SELECT_CHG_YN, 'N') AS GENRL_SELECT_CHG_YN
                     , c1.SELECT_ELEMNT_FG AS SELECT_ELEMNT_FG
                     , a.EXAM_NO
                     , a.FRN_LANG_VLD_EXAM_FG
                     , a.VLD_EXAM_PERF_DT
                     , b.HEAR_HIND_YN
                     , CASE WHEN b.HEAR_HIND_YN = 'Y' AND a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002') THEN
                                        -- teps �̰� û������� ���
                                        CASE WHEN TO_NUMBER(a.VLD_EXAM_PERF_DT) < TO_NUMBER('20180512') THEN TRUNC(990 * (NVL(a.GRMR_SCOR, 0) + NVL(a.VCBLR_SCOR, 0) + NVL(a.RC_SCOR, 0)) / 594, 2)
                                             ELSE TRUNC(600 * (NVL(a.GRMR_SCOR, 0) + NVL(a.VCBLR_SCOR, 0) + NVL(a.RC_SCOR, 0)) / 360, 2)
                                        END
                            ELSE NVL(a.VLD_EXAM_ACQ_SCOR, 0)
                       END AS VLD_EXAM_ACQ_SCOR
                     , c.SELECT_ELEMNT_DISQ_SCOR
                     , c.EXCH_MTHD_FG
                     , c.SELECT_ELEMNT_FMAK_SCOR
                     , c.SELECT_ELEMNT_BASE_SCOR
                     , c.SELECT_ELEMNT_SCOR_SCOR
                     , c.SELECT_ELEMNT_DISQ_ADPT_YN
                     , NVL(a.ENG_EXMP_YN, 'N') AS ENG_EXMP_YN
                  FROM ESIN603 a
                     , V_ESIN600 b
                     , ESIN521 c
                 WHERE c.COLL_UNIT_NO = c1.COLL_UNIT_NO
                   AND a.COLL_UNIT_NO = b.REAL_COLL_UNIT_NO
                   AND a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002', 'U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009', 'U027800014')
                   AND a.EXAM_NO = b.EXAM_NO
                   -- AND a.EXAM_NO = NVL(IN_EXAM_NO, b.EXAM_NO)
                   AND b.COLL_UNIT_NO = c.COLL_UNIT_NO
                   AND c.SELECT_ELEMNT_FG = c1.SELECT_ELEMNT_FG -- �����
                   AND c.ADPT_STG_FG = c1.SCRN_STG_FG
                   AND a.FL_ADPT_YN = 'Y'
                   AND EXISTS (
                            SELECT 1
                              FROM ESIN603 X
                             WHERE X.COLL_UNIT_NO = B.REAL_COLL_UNIT_NO
                               -- AND X.EXAM_NO = NVL(IN_EXAM_NO, X.EXAM_NO)
                               AND X.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002', 'U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009', 'U027800014')
                    )
            ), t2 AS (
                SELECT a.COLL_UNIT_NO
                     , a.SCRN_STG_FG
                     , a.SELECT_YY
                     , a.SELECT_FG
                     , a.COLL_FG
                     , a.SELECT_ELEMNT_FG
                     , a.GENRL_SELECT_CHG_YN
                     , a.EXAM_NO
                     , a.FRN_LANG_VLD_EXAM_FG
                     , a.VLD_EXAM_PERF_DT
                     , a.VLD_EXAM_ACQ_SCOR
                     , a.HEAR_HIND_YN
                     , CASE WHEN a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002') THEN 
                                        CASE WHEN a.VLD_EXAM_PERF_DT < '20180512' THEN (
                                                    SELECT NVL(MAX(z.EXCH_SCOR), 0)
                                                      FROM ESIN542 z
                                                     WHERE a.VLD_EXAM_ACQ_SCOR BETWEEN z.FR_VAL AND z.TO_VAL
                                             )
                                             ELSE a.VLD_EXAM_ACQ_SCOR
                                        END
                            WHEN a.FRN_LANG_VLD_EXAM_FG IN ('U027800005', 'U027800006', 'U027800007', 'U027800008', 'U027800009') THEN (
                                        --- ibt_toefl/cbt/toeic
                                        SELECT NVL(MAX(x.NEW_TEPS_TO_SCOR), 0)
                                          FROM ESIN540 x
                                             , ESIN520 y
                                         WHERE x.SELECT_YY = a.SELECT_YY
                                           AND x.SELECT_FG = a.SELECT_FG
                                           AND x.COLL_FG = a.COLL_FG
                                           AND x.MRKS_MOD_CHART_FG = 'U027500001' -- ����
                                           AND x.MRKS_MOD_FG = a.FRN_LANG_VLD_EXAM_FG -- ibt toefl
                                           AND y.COLL_UNIT_NO = a.COLL_UNIT_NO
                                           AND y.APLY_QUAL_FG LIKE x.APLY_QUAL_FG||'%'
                                           AND y.DETA_APLY_QUAL_FG LIKE x.DETA_APLY_QUAL_FG||'%'
                                           AND y.APLY_CORS_FG LIKE x.APLY_CORS_FG||'%'
                                           AND y.APLY_COLG_FG LIKE x.APLY_COLG_FG||'%'
                                           AND y.APLY_COLL_UNIT_CD LIKE x.APLY_COLL_UNIT_CD||'%'
                                           AND a.VLD_EXAM_ACQ_SCOR BETWEEN x.FR_VAL AND x.TO_VAL
                            )
                            WHEN a.FRN_LANG_VLD_EXAM_FG = 'U027800014' THEN (
                                        SELECT NVL(X.ENG_DETM_SCOR, 0)
                                          FROM ESIN521 X
                                         WHERE X.COLL_UNIT_NO = a.COLL_UNIT_NO
                                           AND X.ADPT_STG_FG = a.SCRN_STG_FG
                                           AND X.SELECT_ELEMNT_FG = 'U027100009'
                            )
                      END AS NEW_TEPS_EXCH_SCOR
                    , a.SELECT_ELEMNT_DISQ_SCOR
                    , a.EXCH_MTHD_FG
                    , a.SELECT_ELEMNT_FMAK_SCOR
                    , a.SELECT_ELEMNT_BASE_SCOR
                    , a.SELECT_ELEMNT_SCOR_SCOR
                    , a.ENG_EXMP_YN
                 FROM t1 a
             GROUP BY a.COLL_UNIT_NO
                    , a.SCRN_STG_FG
                    , a.SELECT_YY
                    , a.SELECT_FG
                    , a.COLL_FG
                    , a.SELECT_ELEMNT_FG
                    , a.GENRL_SELECT_CHG_YN
                    , a.EXAM_NO
                    , a.FRN_LANG_VLD_EXAM_FG
                    , a.VLD_EXAM_PERF_DT
                    , a.VLD_EXAM_ACQ_SCOR
                    , a.HEAR_HIND_YN
                    , a.SELECT_ELEMNT_DISQ_SCOR
                    , a.EXCH_MTHD_FG
                    , a.SELECT_ELEMNT_FMAK_SCOR
                    , a.SELECT_ELEMNT_BASE_SCOR
                    , a.SELECT_ELEMNT_SCOR_SCOR
                    , a.ENG_EXMP_YN
            ), t3 AS (
                SELECT a.COLL_UNIT_NO
                     , a.SCRN_STG_FG
                     , a.SELECT_YY
                     , a.COLL_FG
                     , a.SELECT_ELEMNT_FG
                     , a.GENRL_SELECT_CHG_YN
                     , a.EXAM_NO
                     , a.FRN_LANG_VLD_EXAM_FG
                     , a.VLD_EXAM_PERF_DT
                     , a.VLD_EXAM_ACQ_SCOR
                     , a.HEAR_HIND_YN
                     , a.NEW_TEPS_EXCH_SCOR
                     , a.SELECT_ELEMNT_DISQ_SCOR
                     , a.EXCH_MTHD_FG
                     , a.SELECT_ELEMNT_FMAK_SCOR
                     , CASE WHEN a.SELECT_ELEMNT_SCOR_SCOR > 0 THEN
                                -- ������ �ִ� ���
                                CASE WHEN a.EXCH_MTHD_FG = 'U028700001' THEN
                                            -- ȯ��ǥ ���  ���
                                            CASE WHEN a.FRN_LANG_VLD_EXAM_FG IN ('U027800001', 'U027800002') THEN (
                                                        SELECT MAX(X.EXCH_SCOR)
                                                          FROM ESIN540 x
                                                             , ESIN520 y
                                                         WHERE x.SELECT_YY = a.SELECT_YY
                                                           AND x.SELECT_FG = a.SELECT_FG
                                                           AND x.COLL_FG = a.COLL_FG
                                                           AND x.MRKS_MOD_CHART_FG = 'U027500001' -- ����
                                                           AND x.MRKS_MOD_FG = 'U027800001'  -- teps
                                                           AND y.COLL_UNIT_NO = a.COLL_UNIT_NO
                                                           AND y.APLY_QUAL_FG LIKE x.APLY_QUAL_FG||'%'
                                                           AND y.DETA_APLY_QUAL_FG LIKE x.DETA_APLY_QUAL_FG||'%'
                                                           AND y.APLY_CORS_FG LIKE x.APLY_CORS_FG||'%'
                                                           AND y.APLY_COLG_FG LIKE x.APLY_COLG_FG||'%'
                                                           AND y.APLY_COLL_UNIT_CD LIKE x.APLY_COLL_UNIT_CD||'%'
                                                           AND a.NEW_TEPS_EXCH_SCOR BETWEEN x.FR_VAL AND x.TO_VAL
                                                )
                                                ELSE (
                                                        SELECT MAX(X.EXCH_SCOR)
                                                          FROM ESIN540 x
                                                             , ESIN520 y
                                                         WHERE x.SELECT_YY = a.SELECT_YY
                                                           AND x.SELECT_FG = a.SELECT_FG
                                                           AND x.COLL_FG = a.COLL_FG
                                                           AND x.MRKS_MOD_CHART_FG = 'U027500001' -- ����
                                                           AND x.MRKS_MOD_FG = a.FRN_LANG_VLD_EXAM_FG --  teps �̿� ����
                                                           AND y.COLL_UNIT_NO = a.COLL_UNIT_NO
                                                           AND y.APLY_QUAL_FG LIKE x.APLY_QUAL_FG||'%'
                                                           AND y.DETA_APLY_QUAL_FG LIKE x.DETA_APLY_QUAL_FG||'%'
                                                           AND y.APLY_CORS_FG LIKE x.APLY_CORS_FG||'%'
                                                           AND y.APLY_COLG_FG LIKE x.APLY_COLG_FG||'%'
                                                           AND y.APLY_COLL_UNIT_CD LIKE x.APLY_COLL_UNIT_CD||'%'
                                                           AND a.VLD_EXAM_ACQ_SCOR BETWEEN x.fr_val AND x.to_val
                                                )
                                            END
                                    --- defalut�� ��� ���(U028700002)
                                    ELSE TRUNC(a.NEW_TEPS_EXCH_SCOR * (a.SELECT_ELEMNT_SCOR_SCOR - NVL(a.SELECT_ELEMNT_BASE_SCOR, 0)) / a.SELECT_ELEMNT_FMAK_SCOR + NVL(a.SELECT_ELEMNT_BASE_SCOR, 0), 2)
                                END
                                --- ������ ���� ���
                            ELSE 0
                       END AS EXCH_SCOR
                     , CASE WHEN NVL(a.SELECT_ELEMNT_DISQ_SCOR, 0) > 0 THEN
                                --- ���������� ������
                                CASE WHEN a.FRN_LANG_VLD_EXAM_FG = 'U027800014' THEN 'U027700006' -- ���豸���� ������
                                     -- ������ �ƴϸ�
                                     ELSE 
                                        CASE WHEN a.NEW_TEPS_EXCH_SCOR < a.SELECT_ELEMNT_DISQ_SCOR THEN 'U027700007'
                                        -- ���ó��
                                        END
                                END
                       END AS FL_DISQ_FG
                 FROM t2 a
            )
            --- �����Է� ��ȿ�� �˻�.
            /*
            SELECT CASE WHEN NVL(a.EXCH_SCOR,0) <= NVL(a.SELECT_ELEMNT_FMAK_SCOR,0) THEN NULL
                        ELSE '[ �����ȣ : ' || a.EXAM_NO || ' ] : ' || NVL(a.EXCH_SCOR,0) || ' / ' || NVL(a.SELECT_ELEMNT_FMAK_SCOR,0) || ' ] ������������ ������ �ʰ�.' END AS INFO
              FROM t3 a
            WHERE NVL(a.EXCH_SCOR,0) > NVL(a.SELECT_ELEMNT_FMAK_SCOR,0)             
            */
            --test
            SELECT CASE WHEN NVL(a.EXCH_SCOR,0) <= NVL(a.SELECT_ELEMNT_FMAK_SCOR,0) THEN '[ �����ȣ : ' || a.EXAM_NO || ' ] : ' || NVL(a.EXCH_SCOR,0) || ' / ' || NVL(a.SELECT_ELEMNT_FMAK_SCOR,0) || ' ] ������������ ������ �ʰ�.'
                        ELSE '[ �����ȣ : ' || a.EXAM_NO || ' ]' END AS INFO
              FROM t3 a
            WHERE NVL(a.EXCH_SCOR,0) <= NVL(a.SELECT_ELEMNT_FMAK_SCOR,0)             
            
        ) LOOP     
         
DBMS_OUTPUT.PUT_LINE(CUR2.INFO);
            IF CUR2.INFO IS NOT NULL THEN 
               OUT_MSG := OUT_MSG || CUR2.INFO || '<BR>';        
            END IF;
            
        END LOOP;
        
        IF OUT_MSG IS NOT NULL THEN
            OUT_RTN := '-1';
DBMS_OUTPUT.PUT_LINE(OUT_RTN || ' : ' || OUT_MSG);
            RETURN;
        END IF;            
          
    END LOOP;

	OUT_RTN := 0;
	OUT_MSG := '�����Է� ��ȿ�� �˻�Ȯ�ο� �����Ͽ����ϴ�.';

DBMS_OUTPUT.PUT_LINE(OUT_RTN || ' : ' || OUT_MSG);
	
	EXCEPTION WHEN OTHERS THEN
        OUT_RTN := -1;
        OUT_MSG := TO_CHAR(SQLCODE)|| ' : ' || SQLERRM;
        
DBMS_OUTPUT.PUT_LINE(OUT_RTN || ' : ' || OUT_MSG);    

        RETURN;
        
END SP_ESIN604_ENG_CHK;
/
