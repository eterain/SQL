CREATE OR REPLACE PROCEDURE SNU.SP_ENRO410_CREA
(
     IN_ENTR_SCHYY      IN ENRO400.ENTR_SCHYY%TYPE      /* �����г⵵*/
    ,IN_ENTR_SHTM_FG    IN ENRO400.ENTR_SHTM_FG%TYPE    /* �����бⱸ��*/
    ,IN_SELECT_FG       IN ENRO400.SELECT_FG%TYPE       /* ��������*/
    ,IN_PASS_SEQ        IN ENRO400.PASS_SEQ%TYPE        /* �հ�����*/
    ,IN_REG_RESV_FG     IN VARCHAR2                     /* ��ġ�ݹݿ���*/
    ,IN_TRET_FG         IN VARCHAR2                     /* ó������*/
    ,IN_ID              IN ENRO400.INPT_ID%TYPE         /* ID */
    ,IN_IP              IN ENRO400.INPT_IP%TYPE         /* IP */
    ,OUT_TRET_CNT       OUT NUMBER
    ,OUT_NUM            OUT NUMBER
    ,OUT_MSG            OUT VARCHAR2
 )IS
/******************************************************************************
    ���α׷��� : SP_ENRO410_CREA
      ������� : ENRO410 ���Ի���ϴ���ڸ� ������ �Ѵ�.
      ������ : ENRO410    ����ڻ���
 ------------------------------------------------------------------------------
     ��������     ������    ��������
 ------------------------------------------------------------------------------
     2013.08.12   �����   ���� �ۼ�
     2015.08.05   �Ǽ���   ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ����(DELETE 1��, SELECT 8�� : ��9��)
     2015.08.26   �Ǽ���   ���Ի����м��߳���(SCHO530) ������ �Է�(INSERT, UPDATE) �� ��ϱ�(V_STD_ENTR_AMT, V_STD_LSN_AMT)�� �ƴ� ���б�(V_SCAL_ENTR_AMT, V_SCAL_LSN_AMT)���� �����ϵ��� ����(INSERT 3��, UPDATE 3�� : ��6��)
     2015.11.02   �Ǽ���   �հ���(���Ի�����ھ��ε�)����(ENRO400)�� �հ��ڹ�ǥ�ϷῩ��(ANUN_CLS_YN)�� 'Y'�� ��츸 �����ǵ��� ���� �߰�(SELECT 10��)
     2015.12.07   �Ǽ���   ENRO410 UPDATE ��, EDAMT_SUPP_BREU_CD(��������������ڵ�), STD_BUDEN_RATE(�л��δ����), BREU_BUDEN_RATE(����δ����)�� ������Ʈ �ǵ��� ����.
     2016.01.20   �Ǽ���   ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 )
 ******************************************************************************/
 /**********************************�����������*******************************/
tmpVar NUMBER;
V_PGM_ID                    VARCHAR2(100) := 'SP_ENRO410_CREA';
V_STD_BUDEN_RATE            ENRO170.STD_BUDEN_RATE %TYPE := 0;
V_BREU_BUDEN_RATE           ENRO170.BREU_BUDEN_RATE %TYPE := 0;
V_CSH_BUDEN_RATE            ENRO170.CSH_BUDEN_RATE %TYPE := 0;
V_ACTHNG_BUDEN_RATE         ENRO170.ACTHNG_BUDEN_RATE %TYPE := 0;

V_STD_ENTR_AMT              ENRO410.ENTR_AMT %TYPE := 0;                /* �л� ���б� */
V_STD_LSN_AMT               ENRO410.LSN_AMT %TYPE := 0;                 /* �л� ������ */
V_STD_REG_RESV_AMT          ENRO410.REG_RESV_AMT %TYPE := 0;            /* �л� ��Ͽ�ġ�� */
V_STD_REG_RESV_FG_AMT       ENRO410.REG_RESV_AMT %TYPE := 0;            /* �л� ��Ͽ�ġ�� */
V_BREU_ENTR_AMT             ENRO410.ENTR_AMT %TYPE := 0;                /* ��� ���б� */
V_BREU_LSN_AMT              ENRO410.LSN_AMT %TYPE := 0;                 /* ��� ������ */
V_BREU_REG_RESV_AMT         ENRO410.REG_RESV_AMT %TYPE := 0;            /* ��� ��Ͽ�ġ�� */
V_TEACHM_AMT                ENRO410.TEACHM_AMT %TYPE := 0;              /* ����� */
V_AUTO_REG_FG               ENRO410.AUTO_REG_FG %TYPE;                 /* �ڵ���ϱ��� */
V_GV_ST_FG                  ENRO410.GV_ST_FG %TYPE;                       /* ���Ի��±��� */


/*SCHO*/
V_SCAL_ENTR_AMT_RATE        SCHO110.ENTR_AMT_RATE %TYPE;                /* ���бݺ��� */
V_SCAL_LSN_AMT_RATE         SCHO110.LSN_AMT_RATE %TYPE;                 /* ��������� */
V_SCAL_ENTR_AMT             SCHO110.ENTR_AMT %TYPE;                     /* ���б� */
V_SCAL_LSN_AMT              SCHO110.LSN_AMT %TYPE;                      /* ������ */
V_SCAL_TT_AMT               ENRO410.SCAL_TT_AMT %TYPE;                      /* ���հ� */

V_ENRO100_ENTR_AMT          ENRO100.ENTR_AMT %TYPE := 0;                /* ���б� */
V_ENRO100_LSN_AMT           ENRO100.LSN_AMT %TYPE := 0;                 /* ������ */
V_ENRO100_SSO_AMT           ENRO100.SSO_AMT %TYPE := 0;                 /* �⼺ȸ�� */
V_ENRO100_REG_RESV_AMT      ENRO100.REG_RESV_AMT %TYPE := 0;            /* ��Ͽ�ġ�� */
V_ENRO100_STDUNI_AMT        ENRO100.STDUNI_AMT %TYPE := 0;              /* �л�ȸ�� */
V_ENRO100_MEDI_DUC_AMT      ENRO100.MEDI_DUC_AMT %TYPE := 0;            /* �Ƿ������ */
V_ENRO100_CMMN_TEACHM_AMT   ENRO100.CMMN_TEACHM_AMT %TYPE := 0;         /* ���뱳��� */
V_ENRO100_CHOICE_TEACHM_AMT ENRO100.CHOICE_TEACHM_AMT %TYPE := 0;       /* ���ñ���� */
V_BNSN011_USR_DEF_2         bsns011.USR_DEF_2 %TYPE := NULL;            /* ���������2 */

/*ENRO450*/
V_PAID_TO_DT                ENRO450.PAID_TO_DT %TYPE;                      /* ������������ */



V_GV_CNT                    NUMBER;                                     /* ���԰Ǽ� */
V_STUNO_CNT                 NUMBER;                                     /* ���԰Ǽ� */
V_RESV_GV_CNT               NUMBER;                                     /* ��Ͽ�ġ�ݳ��԰Ǽ� */
V_MSG                       VARCHAR2(2000):= NULL;
V_SCAL_CNT                  NUMBER;
V_ENRO100_YN                VARCHAR2(2) := NULL;
V_ROWID                     ROWID;
V_OUT_CODE                  VARCHAR2(10);
V_OUT_MSG                   VARCHAR2(2000);
/**********************************�������� ��*********************************/

BEGIN

V_MSG :='---------------64561--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
||'] IN_SELECT_FG['||IN_SELECT_FG||']'
||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
||'] IN_TRET_FG['||IN_TRET_FG||']'
||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;
OUT_TRET_CNT := 0;

 /* ������ �����Ͱ� �ִ��� üũ�� �Ѵ� . */
    SELECT  COUNT(1)
      INTO  V_STUNO_CNT
      FROM  ENRO400 T1
     WHERE  T1.ENTR_SCHYY       = IN_ENTR_SCHYY         /* �����г⵵ */
       AND  T1.ENTR_SHTM_FG     = IN_ENTR_SHTM_FG       /* �����бⱸ�� */
       AND  T1.SELECT_FG        = IN_SELECT_FG          /* �������� */
       AND  T1.PASS_SEQ         = IN_PASS_SEQ           /* �հ�����*/
       AND  T1.STUNO is null
     ;
    IF V_STUNO_CNT > 0  THEN
           SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')'||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
           OUT_NUM := '-1';
           OUT_MSG :='�й��� ���� ������ �ϼ���.';
           RETURN;
   END IF;

    if IN_TRET_FG = 'C' then /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

      /* ������ �����Ͱ� �ִ��� üũ�� �Ѵ� . */
        SELECT
        COUNT(1)
        INTO
        V_GV_CNT
        FROM
         ENRO400 T1
        ,ENRO430 T2
        WHERE T1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO
          AND T1.ENTR_SCHYY       = IN_ENTR_SCHYY         /* �����г⵵ */
          AND T1.ENTR_SHTM_FG     = IN_ENTR_SHTM_FG       /* �����бⱸ�� */
          AND T1.SELECT_FG        = IN_SELECT_FG          /* �������� */
          AND T1.PASS_SEQ         = IN_PASS_SEQ  ;        /* �հ�����*/

    end if;



    IF V_GV_CNT > 0  THEN
        SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')'||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
        OUT_NUM := '-1';
        OUT_MSG :='���� ó���� �����Ͱ� �־ ����� ���� �� ��ϱ� ������� �Ұ� �մϴ�.'||IN_TRET_FG;
        RETURN;

    END IF;

/* ��ϱ� ��ġ���� ����ϴ� ���� �������� ������ �������� USR_DEF_2 �̰� 1�� ��� ��ġ�� ����̰� 0�ΰ�� ��ġ�� ��� ���� */
    select
    nvl(USR_DEF_2,'0')
    into
    V_BNSN011_USR_DEF_2
    from bsns011
    where GRP_CD = 'U0618'
      and USE_YN = 'Y'
      and CMMN_CD = IN_SELECT_FG;


      /* ������ �����Ͱ� �ִ��� üũ�� �Ѵ� . */
            SELECT
            COUNT(1)
            INTO
            V_RESV_GV_CNT
            FROM
             ENRO400 T1
            ,ENRO410 T2
            WHERE T1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO
              AND T1.ENTR_SCHYY = IN_ENTR_SCHYY                               /* �����г⵵ */
              AND T1.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                           /* �����бⱸ�� */
              AND T1.SELECT_FG = IN_SELECT_FG                                 /* �������� */
              AND T1.PASS_SEQ  = IN_PASS_SEQ                                  /* �հ�����*/
              AND T2.REG_RESV_AMT_GV_ST_FG = 'U060500002';                    /* ��Ͽ�ġ�ݳ��Ի��±��� */



    V_MSG :='IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
            ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
            ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
            ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
            ||'] IN_TRET_FG['||IN_TRET_FG||']'
            ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
            ||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
            ||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;

/* ��ϱ� ó�������� ����ڻ���/������ ��� �����͸� ���� �� ������ ������ �ϸ�
   �׷��� ���� ��� �����Ϳ� ������Ʈ ó���� �Ѵ�. */
    if IN_TRET_FG = 'C' then  /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

        IF V_BNSN011_USR_DEF_2 = '1' THEN  /* ��ġ�� ��� �� */

            IF V_RESV_GV_CNT > 0  THEN

                SP_SSTM056_CREA(V_PGM_ID, '��ġ�ݳ��� ó���� �����Ͱ� �־ ����� ���� �� ��ϱ� ������� �Ұ� �մϴ�.'||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                OUT_NUM := '-1';
                OUT_MSG :='��ġ�ݳ��� ó���� �����Ͱ� �־ ����� ���� �� ��ϱ� ������� �Ұ� �մϴ�.';
                RETURN;

            END IF;

         if IN_REG_RESV_FG = 'E' then /* ��ϱ���(��ġ�ݹݿ�����) 'R'='��ϱݿ�ġ��', 'E'='��ϱ�' */


             OUT_NUM := '-1';
             OUT_MSG :='ó�������� ��ϱ� ������ ó�� �ϼ���. ';
              SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
             RETURN;

         END IF;

        END IF;

        BEGIN

            DELETE FROM SCHO530 T1                 /* ���Ի����м��߳��� */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* �г⵵ */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* �б� */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* �������� */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* ���� */
                                          );

            DELETE FROM ENRO440 T1                 /* ���Ի���ϱ�ȯ�ҳ��� */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* �г⵵ */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* �б� */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* �������� */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* ���� */
                                          );

            DELETE FROM ENRO430 T1                 /* ���Ի���ϱݼ���ȯ�ҳ��� */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* �г⵵ */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* �б� */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* �������� */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* ���� */
                                          );
            DELETE FROM ENRO431 T1                 /* ���Ի���ϱݼ���ȯ�ҳ��� */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* �г⵵ */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* �б� */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* �������� */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* ���� */
                                          );

            /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
            DELETE FROM ENRO410 T1                 /* ���Ի���ϴ���ڳ��� */
            WHERE T1.EXAM_STD_MNGT_NO IN(
                                        SELECT
                                        TA1.EXAM_STD_MNGT_NO
                                        FROM
                                        ENRO400 TA1
                                        WHERE   TA1.ENTR_SCHYY        = IN_ENTR_SCHYY            /* �г⵵ */
                                          AND   TA1.ENTR_SHTM_FG      = IN_ENTR_SHTM_FG          /* �б� */
                                          AND   TA1.SELECT_FG         = IN_SELECT_FG             /* �������� */
                                          AND   TA1.PASS_SEQ          = IN_PASS_SEQ              /* ���� */
                                          AND   NOT EXISTS (SELECT 1
                                                              FROM ENRO420 TB1
                                                             WHERE TB1.EXAM_STD_MNGT_NO = TA1.EXAM_STD_MNGT_NO)
                                          );

        EXCEPTION
                WHEN OTHERS THEN

                    OUT_NUM := -10000;
                    OUT_MSG := '���� ������ ������ ���� �Ͽ����ϴ�.';
                     SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                    RETURN;
        END;

    end if;


    V_MSG :='---------------2222--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
||'] IN_SELECT_FG['||IN_SELECT_FG||']'
||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
||'] IN_TRET_FG['||IN_TRET_FG||']'
||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;


    IF V_BNSN011_USR_DEF_2 = '0' THEN /* ���� */

        IF IN_REG_RESV_FG = 'E' then /* ��ϱ���(��ġ�ݹݿ�����) 'R'='��ϱݿ�ġ��', 'E'='��ϱ�' */

            IF IN_TRET_FG = 'C' THEN  /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

              FOR LIST_DATA IN (
                        SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                  /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD               /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY            /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG          /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG             /* ��������*/
                              AND   T2.PASS_SEQ     LIKE IN_PASS_SEQ||'%'              /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3 AS SELECT_USR_DEF                                   /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG    = T3.CMMN_CD                          /* �������� */
                              AND   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ  LIKE IN_PASS_SEQ||'%'                     /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND    T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                    FROM    SREG001 T1
                                                                          , ENRO400 T2
                                                                          , V_COMM111_4 T4
                                                                   WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                     AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                     AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                     AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                                                                     AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                                                                     AND    T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                                                                     AND    T2.PASS_SEQ     like IN_PASS_SEQ||'%'              /* �հ�����*/
                                                                     and    T2.STUNO is not null
                                                                     AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                    WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                               ELSE 'C013300002'
                                                                                               END)
                                                                     AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                     AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                     AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */

                        )
                    LOOP




                            BEGIN

                                /*���������⺻���̺��� �μ��ڵ�� ��ϱ�å������ ���� Ȯ��*/
                                SELECT
                                T1.ENTR_AMT                                     /* ���б� */
                                ,T1.LSN_AMT                                      /* ������ */
                                ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* ���б� */
                                ,V_ENRO100_LSN_AMT                               /* ������ */
                                ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*���������⺻�� �μ��ڵ�� ��ϱ�å���� �ȵ� ��� �����ڵ�� ���� Ȯ��*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* ���б� */
                                    ,T1.LSN_AMT                                      /* ������ */
                                    ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                    ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                    ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                    ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                    ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                    ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                    ,'Y' AS YN
                                    INTO
                                     V_ENRO100_ENTR_AMT                              /* ���б� */
                                    ,V_ENRO100_LSN_AMT                               /* ������ */
                                    ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                    ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                    ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '�ش� �а� ������ ���� ��ϱ�å�� ������ �����ϴ�[�й� = '|| LIST_DATA.STUNO
                                || ' / ����(�а�)�ڵ� = ' ||LIST_DATA.DEPARTMENT_CD||'('|| LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || ')].';
                                 SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                RETURN;

                                END;

                            END;




                             /*�л�*/
                            V_STD_ENTR_AMT := 0;       /* ���б� */
                            V_STD_LSN_AMT  := 0;       /* ������ */
                            V_STD_REG_RESV_AMT:= 0;    /* ��Ͽ�ġ�� */
                            V_STD_REG_RESV_FG_AMT:= 0; /* ��Ͽ�ġ�� */

                            /*���*/
                            V_BREU_ENTR_AMT := 0;     /* ���б� */
                            V_BREU_LSN_AMT  := 0;     /* ������ */
                            V_BREU_REG_RESV_AMT:= 0;  /* ��Ͽ�ġ�� */

                            /*����*/
                            V_SCAL_ENTR_AMT := 0;     /* ���б� */
                            V_SCAL_LSN_AMT  := 0;     /* ������ */



                            /*�⺻��ϱ� �Է�*/
                            V_STD_ENTR_AMT      := V_ENRO100_ENTR_AMT;      /* �л� ���б� */
                            V_STD_LSN_AMT       := V_ENRO100_LSN_AMT;       /* �л� ������ */
                            V_STD_REG_RESV_AMT  := V_ENRO100_REG_RESV_AMT;  /* �л� ��Ͽ�ġ�� */

                            V_MSG :='-----------------LIST_DATA.ENTR_SCHYY[' ||LIST_DATA.ENTR_SCHYY
                                                    ||'] LIST_DATA.ENTR_SHTM_FG['||LIST_DATA.ENTR_SHTM_FG||']'
                                                    ||'] LIST_DATA.DETA_SHTM_FG['||LIST_DATA.DETA_SHTM_FG||']'
                                                    ||'] LIST_DATA.CORS_FG['||LIST_DATA.CORS_FG||']'
                                                    ||'] LIST_DATA.DEPARTMENT_CD['||LIST_DATA.DEPARTMENT_CD||']'
                                                    ||'] LIST_DATA.SHYR['||LIST_DATA.SHYR||']'
                                                    ||'] LIST_DATA.DAYNGT_FG['||LIST_DATA.DAYNGT_FG||']'
                                                    ||'] LIST_DATA.EXAM_COLL_UNIT_DEPT_CD['||LIST_DATA.EXAM_COLL_UNIT_DEPT_CD||']'
                                                    ||'] LIST_DATA.STUNO['||LIST_DATA.STUNO||']'||V_MSG;


                             /* ��ϱ� ��å������ ���� ��� ,, ���� ó��*/
                            if V_STD_ENTR_AMT = 0 and V_STD_LSN_AMT = 0 AND V_STD_REG_RESV_AMT = 0 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '���Ի� ��ϱ�å�������� Ȯ�� �ϼ���.';
                                 SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                RETURN;

                            END IF;

                            /* �����*/
                            V_TEACHM_AMT := V_ENRO100_CMMN_TEACHM_AMT+V_ENRO100_CHOICE_TEACHM_AMT;

                            /* ����а� ������ ��� */
                            IF LIST_DATA.SELECT_DEPT_CD != '00000' THEN

                                IF LIST_DATA.EDAMT_SUPP_BREU_CD IS NULL THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '��������������� Ȯ�� �ϼ���.';
                                     SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                    RETURN;
                                END IF;

                                BEGIN

                                    SELECT
                                        T1.STD_BUDEN_RATE                                                        /* �л��δ���� */
                                       ,T1.BREU_BUDEN_RATE                                                       /* ����δ���� */
                                       ,T1.CSH_BUDEN_RATE                                                        /* ���ݺδ���� */
                                       ,T1.ACTHNG_BUDEN_RATE                                                     /* �����δ���� */
                                       INTO
                                        V_STD_BUDEN_RATE
                                       ,V_BREU_BUDEN_RATE
                                       ,V_CSH_BUDEN_RATE
                                       ,V_ACTHNG_BUDEN_RATE
                                    FROM ENRO170 T1
                                    WHERE T1.EDAMT_SUPP_BREU_CD = LIST_DATA.EDAMT_SUPP_BREU_CD
                                    AND T1.DEPT_CD = LIST_DATA.SELECT_DEPT_CD;

                                    V_STD_ENTR_AMT := 0;
                                    V_STD_LSN_AMT := 0;

                                     /*�л�*/
                                    V_STD_ENTR_AMT :=(V_STD_BUDEN_RATE/100)* V_ENRO100_ENTR_AMT;         /* �л� ���б� */
                                    V_STD_LSN_AMT  := (V_STD_BUDEN_RATE/100)* V_ENRO100_LSN_AMT;          /* �л� ������ */


                                     V_BREU_ENTR_AMT := 0;
                                    V_BREU_LSN_AMT := 0;

                                    /*���*/
                                    V_BREU_ENTR_AMT :=(V_BREU_BUDEN_RATE/100)*V_ENRO100_ENTR_AMT;         /* ��� ���б� */
                                    V_BREU_LSN_AMT  := (V_BREU_BUDEN_RATE/100)*V_ENRO100_LSN_AMT;          /* ��� ������ */


                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '��������������� �����ϴ�.';
                                         SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        RETURN;
                                    WHEN OTHERS THEN

                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '������������� �����͸� Ȯ�� �ϼ���';
                                         SP_SSTM056_CREA(V_PGM_ID, OUT_MSG||V_MSG , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        RETURN;
                                END;

                            END IF;

                            /*  ���б��� �ִ� ��� */
                            IF LIST_DATA.SCAL_CD is not null THEN

                                BEGIN

                                    SELECT
                                            T2.ENTR_AMT_RATE                                     /* ���бݺ��� */
                                          , T2.LSN_AMT_RATE                                      /* ��������� */
                                    INTO
                                             V_SCAL_ENTR_AMT_RATE                                /* ���бݺ��� */
                                          ,  V_SCAL_LSN_AMT_RATE                                 /* ��������� */
                                    FROM
                                    SCHO100 T1
                                   ,SCHO110 T2
                                    WHERE  T1.SCAL_CD =  T2.SCAL_CD
                                    AND T1.SCAL_CD = LIST_DATA.SCAL_CD
                                    AND T1.BDEGR_SYSTEM_FG = LIST_DATA.BDEGR_SYSTEM_FG
                                    AND T2.SUBMATT_CORS_FG = (CASE WHEN LIST_DATA.SELECT_USR_DEF = '1' THEN 'U040800001'
                                                                   WHEN LIST_DATA.SELECT_USR_DEF = '2' THEN 'U040800002'
                                                             ELSE ''
                                                             END)
                                    ;

                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '���б� �������� �����ϴ�.';
                                        RETURN;
                                    WHEN OTHERS THEN
                                        SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '���б� ó���� ���� �Ͽ����ϴ�.';
                                        RETURN;
                                END;

                                V_SCAL_ENTR_AMT := 0;
                                V_SCAL_LSN_AMT := 0;
                                V_SCAL_TT_AMT := 0;

                                 IF LIST_DATA.SCAL_CD is not null THEN
                                 /* ���� */
                                 V_SCAL_ENTR_AMT :=(V_SCAL_ENTR_AMT_RATE/100)* V_ENRO100_ENTR_AMT;      /* ���� ���б� */
                                 V_SCAL_LSN_AMT :=(V_SCAL_LSN_AMT_RATE/100)* V_ENRO100_LSN_AMT;         /* ���� ������ */
                                 V_SCAL_TT_AMT := V_SCAL_ENTR_AMT+V_SCAL_LSN_AMT;                        /*�ѱݾ�*/
                                 end if;

                            END IF;



                        IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* ��ϱݿ��� */




                          /*�л�*/
                            V_STD_ENTR_AMT := 0;       /* ���б� */
                            V_STD_LSN_AMT  := 0;       /* ������ */
                            V_STD_REG_RESV_AMT:= 0;    /* ��Ͽ�ġ�� */
                            V_STD_REG_RESV_FG_AMT:= 0; /* ��Ͽ�ġ�� */

                            /*���*/
                            V_BREU_ENTR_AMT := 0;     /* ���б� */
                            V_BREU_LSN_AMT  := 0;     /* ������ */
                            V_BREU_REG_RESV_AMT:= 0;  /* ��Ͽ�ġ�� */

                            /*����*/
                            V_SCAL_ENTR_AMT := 0;     /* ���б� */
                            V_SCAL_LSN_AMT  := 0;     /* ������ */




                        END IF;

                         V_GV_ST_FG := 'U060500001';
                         V_AUTO_REG_FG := NULL;

                        IF  LIST_DATA.SELECT_USR_DEF = '2' THEN

                            IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* ��ϱݿ��� */

                                     V_AUTO_REG_FG := 'U060600003';
                                     V_GV_ST_FG := 'U060500002';


                            ELSIF(V_SCAL_TT_AMT = (NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))) THEN

                                    V_AUTO_REG_FG := 'U060600001';
                                    V_GV_ST_FG := 'U060500002';


                             END IF;

                            IF V_AUTO_REG_FG IS NOT NULL THEN

                              SELECT  MIN(TO_CHAR(TO_DATE(T1.PAID_TO_DT,'YYYYMMDD'),'YYYYMMDD'))
                                INTO    V_PAID_TO_DT
                                FROM
                                ENRO450 T1
                                WHERE T1.ENTR_SCHYY = LIST_DATA.ENTR_SCHYY
                                AND T1.ENTR_SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND T1.SELECT_FG    = LIST_DATA.SELECT_FG
                                 and T1.PAID_FR_DT > to_char(sysdate,'YYYYMMDD')
                                ;



                              IF V_PAID_TO_DT IS NULL THEN

                                OUT_NUM := -10000;
                                OUT_MSG := '�����������ڸ� Ȯ�� �ϼ���.';
                                SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , OUT_NUM, OUT_MSG, IN_ID, IN_IP);
                                RETURN;

                              END IF;


                            END IF;

                        END IF;


                      INSERT INTO ENRO410(
                                 EXAM_STD_MNGT_NO                /* �����������ȣ(PK1) */
                                ,SCAL_CD                         /* �����ڵ� */
                                ,CNTR_SUST_YN                    /* ����а����� */
                                ,EDAMT_SUPP_BREU_CD              /* ��������������ڵ� */
                                ,STD_BUDEN_RATE                  /* �л��δ���� */
                                ,BREU_BUDEN_RATE                 /* ����δ���� */
                                ,CSH_BUDEN_RATE                  /* ���ݺδ���� */
                                ,ACTHNG_BUDEN_RATE               /* �����δ���� */
                                ,CAL_CLS_YN                      /* ����ϷῩ�� */
                                ,REG_RESV_AMT                    /* ��Ͽ�ġ�� */
                                ,ENTR_AMT                        /* ���б� */
                                ,LSN_AMT                         /* ������ */
                                ,REG_TT_AMT                      /* ����ѱݾ� */
                                ,BREU_ENTR_AMT                   /* ������б� */
                                ,BREU_LSN_AMT                    /* ��������� */
                                ,BREU_REG_TT_AMT                 /* �������ѱݾ� */
                                ,SCAL_ENTR_AMT                   /* �������б� */
                                ,SCAL_LSN_AMT                    /* ���м����� */
                                ,SCAL_TT_AMT                     /* �����ѱݾ� */
                                ,STDUNI_AMT                      /* �л�ȸ�� */
                                ,TEACHM_AMT                      /* ����� */
                                ,RECIV_REG_RESV_AMT              /* ������Ͽ�ġ�� */
                                ,RECIV_ENTR_AMT                  /* �������б� */
                                ,RECIV_LSN_AMT                   /* ���������� */
                                ,RECIV_TT_AMT                    /* �����ѱݾ� */
                                ,BREU_RECIV_ENTR_AMT             /* ����������б� */
                                ,BREU_RECIV_LSN_AMT              /* ������������� */
                                ,BREU_RECIV_TT_AMT               /* ��������ѱݾ� */
                                ,RECIV_STDUNI_AMT                /* �����л�ȸ�� */
                                ,RECIV_TEACHM_AMT                /* ��������� */
                                ,GV_ST_FG                        /* ���Ի��±��� */
                                ,AUTO_REG_FG                     /* �ڵ���ϱ��� */
                                ,RECIV_DT                        /* �������� */
                                ,REMK                            /* ��� */
                                ,SMS_SEND_SEQ                    /* SMS�߼ۼ��� */
                                ,EMAIL_SEND_SEQ                  /* �̸��Ϲ߼ۼ��� */
                                ,INPT_ID                         /* �Է�ID */
                                ,INPT_IP                         /* �Է�IP */
                                ,INPT_DTTM                       /* �Է��Ͻ� */
                        )VALUES(
                                 LIST_DATA.EXAM_STD_MNGT_NO                                         /* �����������ȣ(PK1) */
                                ,LIST_DATA.SCAL_CD                                                  /* �����ڵ� */
                                ,(CASE WHEN  LIST_DATA.SELECT_DEPT_CD !='00000' THEN 'Y'
                                  ELSE 'N'
                                  END )                                                             /* ����а����� */
                                ,LIST_DATA.EDAMT_SUPP_BREU_CD                                       /* ��������������ڵ� */
                                ,V_STD_BUDEN_RATE                                                   /* �л��δ���� */
                                ,V_BREU_BUDEN_RATE                                                  /* ����δ���� */
                                ,V_CSH_BUDEN_RATE                                                   /* ���ݺδ���� */
                                ,V_ACTHNG_BUDEN_RATE                                                /* �����δ���� */
                                ,'N'                                                                /* ����ϷῩ�� */
                                ,0                                                                  /* ��Ͽ�ġ�� */
                                ,NVL(V_STD_ENTR_AMT, 0)                                             /* ���б� */
                                ,NVL(V_STD_LSN_AMT, 0)                                              /* ������ */
                                ,(NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))                     /* (���б�+������) ����ѱݾ� */
                                ,NVL(V_BREU_ENTR_AMT, 0)                                            /* ������б� */
                                ,NVL(V_BREU_LSN_AMT, 0)                                             /* ��������� */
                                ,(NVL(V_BREU_ENTR_AMT, 0)+NVL(V_BREU_LSN_AMT, 0))                   /* (���б�+������) �������ѱݾ� */
                                ,NVL(V_SCAL_ENTR_AMT, 0)                                            /* �������б� */
                                ,NVL(V_SCAL_LSN_AMT, 0)                                             /* ���м����� */
                                ,(NVL(V_SCAL_ENTR_AMT, 0)+NVL(V_SCAL_LSN_AMT, 0))                   /* (���б�+������) ���е���ѱݾ� */
                                ,NVL(V_ENRO100_STDUNI_AMT, 0)                                       /* �л�ȸ�� */
                                ,(CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                    ELSE  NVL(V_TEACHM_AMT, 0)
                                  END )                                                             /* �����(����+����) */
                                ,0                                                                  /* ������Ͽ�ġ�� */
                                ,0                                                                  /* �������б� */
                                ,0                                                                  /* ���������� */
                                ,0                                                                  /* �����ѱݾ� */
                                ,0                                                                  /* ����������б� */
                                ,0                                                                  /* ������������� */
                                ,0                                                                  /* ��������ѱݾ� */
                                ,0                                                                  /* �����л�ȸ�� */
                                ,0                                                                  /* ��������� */
                                ,V_GV_ST_FG                                                         /* ���Ի��±���(�̵��) */
                                ,V_AUTO_REG_FG                                                      /* �ڵ���ϱ��� */
                                ,V_PAID_TO_DT                                                       /* �������� */
                                ,''                                                                 /* ��� */
                                ,''                                                                 /* SMS�߼ۼ��� */
                                ,''                                                                 /* �̸��Ϲ߼ۼ��� */
                                ,IN_ID                                                              /* �Է�ID */
                                ,IN_IP                                                              /* �Է�IP */
                                ,SYSDATE                                                            /* �Է��Ͻ� */
                            )
                            RETURNING ROWID
                            INTO V_ROWID;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200001'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                          IF  V_OUT_CODE <> '0' THEN
                              SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                              OUT_NUM := V_OUT_CODE;
                              OUT_MSG :='���Ի� ��� ����� ������ ���� �Ͽ����ϴ�.[�����̷� ���� ����]';
                              RETURN;
                          END IF;

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* ��ϱݿ��� */

                            /*  ���б��� �ִ� ��� */
                            IF LIST_DATA.SCAL_CD is not null THEN


                            SELECT COUNT(*)
                            INTO
                            V_SCAL_CNT
                            FROM SCHO530
                            WHERE
                            EXAM_STD_MNGT_NO = LIST_DATA.EXAM_STD_MNGT_NO
                            AND SCAL_CD  = LIST_DATA.SCAL_CD ;

                                IF V_SCAL_CNT < 1 THEN
                                    INSERT INTO SCHO530                                           /* ���Ի����м��߳��� */
                                         (  EXAM_STD_MNGT_NO                                  /* �����������ȣ */
                                          , SCAL_CD                                           /* �����ڵ� */
                                          , SLT_DT                                            /* �������� */
                                          , ENTR_AMT                                          /* ���б� */
                                          , LSN_AMT                                           /* ������ */
                                          , SSO_AMT                                           /* �⼺ȸ�� */
                                          , LIF_AMT                                           /* ��Ȱ�� */
                                          , STUDY_ENC_AMT                                     /* �о������ */
                                          , TEACHM_AMT                                        /* ����� */
                                          , ETC_SCAL_AMT                                      /* ��Ÿ���б� */
                                          , SCAL_TT_AMT                                       /* �����ѱݾ� */
                                          , SUBST_DED_NO                                      /* ��ü������ȣ */
                                          , SCAL_SLT_PROG_ST_FG                               /* ���м���������±��� */
                                          , ACCPR_PERS_NO                                     /* �����ڰ��ι�ȣ */
                                          , ACCP_DT                                           /* �������� */
                                          , SCAL_SLT_NO                                       /* ���м��߹�ȣ */
                                          , REMK                                              /* ��� */
                                          , INPT_ID                                           /* �Է�ID */
                                          , INPT_IP                                           /* �Է�IP */
                                          , INPT_DTTM                                         /* �Է��Ͻ� */
                                          , MOD_ID                                            /* ����ID */
                                          , MOD_IP                                            /* ����IP */
                                          , MOD_DTTM                                          /* �����Ͻ� */
                                         )
                                         VALUES
                                         (  LIST_DATA.EXAM_STD_MNGT_NO                              /* �����������ȣ */
                                          , LIST_DATA.SCAL_CD                                       /* �����ڵ� */
                                          , TO_CHAR(SYSDATE,'YYYYMMDD')                             /* �������� */
                                          , NVL(V_SCAL_ENTR_AMT,0)                                  /* �������б� */
                                          , NVL(V_SCAL_LSN_AMT,0)                                   /* ���м����� */
                                          , 0                                                       /* �⼺ȸ�� */
                                          , 0                                                       /* ��Ȱ�� */
                                          , 0                                                       /* �о������ */
                                          , nvl(V_TEACHM_AMT,0)                                     /* ����� */
                                          , 0                                                       /* ��Ÿ���б� */
                                          , NVL(V_SCAL_TT_AMT,0)                                    /* �����ѱݾ� */
                                          , ''                                                      /* ��ü������ȣ */
                                          , 'U073300004'                                            /* ���м���������±��� Ȯ��ó�� */
                                          , IN_ID                                                   /* �����ڰ��ι�ȣ */
                                          , ''                                                      /* �������� */
                                          , ''                                                      /* ���м��߹�ȣ */
                                          , ''                                                      /* ��� */
                                          , IN_ID                                                   /* �Է�ID */
                                          , IN_IP                                                   /* �Է�IP */
                                          , SYSDATE                                                 /* �Է��Ͻ� */
                                          , IN_ID                                                   /* �Է�ID */
                                          , IN_IP                                                   /* �Է�IP */
                                          , SYSDATE                                                 /* �Է��Ͻ� */
                                         ) ;
                                ELSE

                                UPDATE scho530                    /* ���Ի����м��߳��� */
                                   SET SLT_DT                    = TO_CHAR(SYSDATE,'YYYYMMDD')          /* �������� */
                                     , ENTR_AMT                  = NVL(V_SCAL_ENTR_AMT,0)               /* �������б� */
                                     , LSN_AMT                   = NVL(V_SCAL_LSN_AMT,0)                /* ���м����� */
                                     , SSO_AMT                   = 0                                    /* �⼺ȸ�� */
                                     , LIF_AMT                   = 0                                    /* ��Ȱ�� */
                                     , STUDY_ENC_AMT             = 0                                    /* �о������ */
                                     , TEACHM_AMT                = nvl(V_TEACHM_AMT,0)                  /* ����� */
                                     , ETC_SCAL_AMT              = 0                                    /* ��Ÿ���б� */
                                     , SCAL_TT_AMT               = NVL(V_SCAL_TT_AMT,0)                 /* �����ѱݾ� */
                                     , SUBST_DED_NO              = ''                                   /* ��ü������ȣ */
                                     , SCAL_SLT_PROG_ST_FG       = 'U073300004'                         /* ���м���������±��� */
                                     , ACCPR_PERS_NO             = IN_ID                                /* �����ڰ��ι�ȣ */
                                     , MOD_ID                    = IN_ID                                /* ����ID */
                                     , MOD_IP                    = IN_IP                                /* ����IP */
                                     , MOD_DTTM                  = SYSDATE                              /* �����Ͻ� */
                                 WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO           /* �����������ȣ */
                                   AND SCAL_CD                   = LIST_DATA.SCAL_CD                    /* �����ڵ� */
                                 ;

                                END IF;



                            END IF;

                        END IF;


                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                         V_MSG :='--------------33-3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] EXAM_STD_MNGT_NO['||LIST_DATA.EXAM_STD_MNGT_NO||']'
                              ||'] SCAL_CD['||LIST_DATA.SCAL_CD||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'||OUT_TRET_CNT;


                    END LOOP;

            ELSIF IN_TRET_FG IN('U','R') THEN  /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

             FOR LIST_DATA IN (
                            SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3   AS SELECT_USR_DEF                                  /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001  T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                      , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   T2.EXAM_STD_MNGT_NO  = T5.EXAM_STD_MNGT_NO
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T3.USR_DEF_3   AS SELECT_USR_DEF                                  /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   T2.EXAM_STD_MNGT_NO  = T5.EXAM_STD_MNGT_NO
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                   FROM    SREG001 T1
                                                                         , ENRO400 T2
                                                                         , V_COMM111_4 T4
                                                                  WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                    AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                    AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                    AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                                                                    AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                                                                    AND    T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                                                                    AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                                                                    AND    T2.STUNO IS NOT NULL
                                                                    AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                   WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                              ELSE 'C013300002'
                                                                                              END)
                                                                    AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                    AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                    AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )

                        )
                    LOOP

                             BEGIN

                                /*���������⺻���̺��� �μ��ڵ�� ��ϱ�å������ ���� Ȯ��*/
                                SELECT
                                T1.ENTR_AMT                                     /* ���б� */
                                ,T1.LSN_AMT                                      /* ������ */
                                ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* ���б� */
                                ,V_ENRO100_LSN_AMT                               /* ������ */
                                ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*���������⺻�� �μ��ڵ�� ��ϱ�å���� �ȵ� ��� �����ڵ�� ���� Ȯ��*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* ���б� */
                                    ,T1.LSN_AMT                                      /* ������ */
                                    ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                    ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                    ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                    ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                    ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                    ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                    ,'Y' AS YN
                                    INTO
                                    V_ENRO100_ENTR_AMT                              /* ���б� */
                                    ,V_ENRO100_LSN_AMT                               /* ������ */
                                    ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                    ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                    ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '�ش� �а� ������ ���� ��ϱ�å�� ������ �����ϴ�[�й� = ' || LIST_DATA.STUNO
                                 || ' / �а��ڵ� = ' || LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || '].';
                                RETURN;

                                END;

                            END;

                             /*�л�*/
                            V_STD_ENTR_AMT := 0;       /* ���б� */
                            V_STD_LSN_AMT  := 0;       /* ������ */
                            V_STD_REG_RESV_AMT:= 0;    /* ��Ͽ�ġ�� */
                            V_STD_REG_RESV_FG_AMT:= 0; /* ��Ͽ�ġ�� */

                            /*���*/
                            V_BREU_ENTR_AMT := 0;     /* ���б� */
                            V_BREU_LSN_AMT  := 0;     /* ������ */
                            V_BREU_REG_RESV_AMT:= 0;  /* ��Ͽ�ġ�� */

                            /*����*/
                            V_SCAL_ENTR_AMT := 0;     /* ���б� */
                            V_SCAL_LSN_AMT  := 0;     /* ������ */



                            /*�⺻��ϱ� �Է�*/
                            V_STD_ENTR_AMT      := V_ENRO100_ENTR_AMT;      /* �л� ���б� */
                            V_STD_LSN_AMT       := V_ENRO100_LSN_AMT;       /* �л� ������ */
                            V_STD_REG_RESV_AMT  := V_ENRO100_REG_RESV_AMT;  /* �л� ��Ͽ�ġ�� */

                             /* ��ϱ� ��å������ ���� ��� ,, ���� ó��*/
                            if V_STD_ENTR_AMT = 0 and V_STD_LSN_AMT = 0 AND V_STD_REG_RESV_AMT = 0 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '���Ի� ��ϱ�å�������� Ȯ�� �ϼ���.';
                                RETURN;

                            END IF;

                            /* �����*/
                            V_TEACHM_AMT := V_ENRO100_CMMN_TEACHM_AMT+V_ENRO100_CHOICE_TEACHM_AMT;

                            /* ����а� ������ ��� */
                            IF LIST_DATA.SELECT_DEPT_CD != '00000' THEN

                                IF LIST_DATA.EDAMT_SUPP_BREU_CD IS NULL THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '��������������� Ȯ�� �ϼ���.';
                                    RETURN;
                                END IF;

                                BEGIN

                                    SELECT
                                        T1.STD_BUDEN_RATE                                                        /* �л��δ���� */
                                       ,T1.BREU_BUDEN_RATE                                                       /* ����δ���� */
                                       ,T1.CSH_BUDEN_RATE                                                        /* ���ݺδ���� */
                                       ,T1.ACTHNG_BUDEN_RATE                                                     /* �����δ���� */
                                       INTO
                                        V_STD_BUDEN_RATE
                                       ,V_BREU_BUDEN_RATE
                                       ,V_CSH_BUDEN_RATE
                                       ,V_ACTHNG_BUDEN_RATE
                                    FROM ENRO170 T1
                                    WHERE T1.EDAMT_SUPP_BREU_CD = LIST_DATA.EDAMT_SUPP_BREU_CD
                                    AND T1.DEPT_CD = LIST_DATA.SELECT_DEPT_CD;

                                     /*�л�*/
                                    V_STD_ENTR_AMT :=(V_STD_BUDEN_RATE/100)* V_ENRO100_ENTR_AMT;         /* �л� ���б� */
                                    V_STD_LSN_AMT  := (V_STD_BUDEN_RATE/100)* V_ENRO100_LSN_AMT;          /* �л� ������ */

                                    /*���*/
                                    V_BREU_ENTR_AMT :=(V_BREU_BUDEN_RATE/100)*V_ENRO100_ENTR_AMT;         /* ��� ���б� */
                                    V_BREU_LSN_AMT  := (V_BREU_BUDEN_RATE/100)*V_ENRO100_LSN_AMT;          /* ��� ������ */


                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '��������������� �����ϴ�.';
                                        RETURN;
                                    WHEN OTHERS THEN
                                        SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '������������� �����͸� Ȯ�� �ϼ���';
                                        RETURN;
                                END;

                            END IF;

                            /*  ���б��� �ִ� ��� */
                            IF LIST_DATA.SCAL_CD is not null THEN

                                BEGIN
                                     SELECT
                                            T2.ENTR_AMT_RATE                                     /* ���бݺ��� */
                                          , T2.LSN_AMT_RATE                                      /* ��������� */
                                    INTO
                                             V_SCAL_ENTR_AMT_RATE                                /* ���бݺ��� */
                                          ,  V_SCAL_LSN_AMT_RATE                                 /* ��������� */
                                    FROM
                                    SCHO100 T1
                                   ,SCHO110 T2
                                    WHERE  T1.SCAL_CD =  T2.SCAL_CD
                                    AND T1.SCAL_CD = LIST_DATA.SCAL_CD
                                    AND T1.BDEGR_SYSTEM_FG = LIST_DATA.BDEGR_SYSTEM_FG
                                    AND T2.SUBMATT_CORS_FG = (CASE WHEN LIST_DATA.SELECT_USR_DEF = '1' THEN 'U040800001'
                                                                   WHEN LIST_DATA.SELECT_USR_DEF = '2' THEN 'U040800002'
                                                             ELSE ''
                                                             END)
                                    ;

                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        OUT_NUM := -1000;
                                        OUT_MSG := '���б� �������� �����ϴ�.';
                                        RETURN;
                                    WHEN OTHERS THEN
                                        SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                        OUT_NUM := SQLCODE;
                                        OUT_MSG := '���б� ó���� ���� �Ͽ����ϴ�.';
                                        RETURN;
                                END;

                                 /* ���� */
                                 V_SCAL_ENTR_AMT :=(V_SCAL_ENTR_AMT_RATE/100)* V_ENRO100_ENTR_AMT;      /* ���� ���б� */
                                 V_SCAL_LSN_AMT :=(V_SCAL_LSN_AMT_RATE/100)* V_ENRO100_LSN_AMT;         /* ���� ������ */
                                 V_SCAL_TT_AMT := V_SCAL_ENTR_AMT+V_SCAL_LSN_AMT;                        /*�ѱݾ�*/

                            END IF;



                         IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* ��ϱݿ��� */




                          /*�л�*/
                            V_STD_ENTR_AMT := 0;       /* ���б� */
                            V_STD_LSN_AMT  := 0;       /* ������ */
                            V_STD_REG_RESV_AMT:= 0;    /* ��Ͽ�ġ�� */
                            V_STD_REG_RESV_FG_AMT:= 0; /* ��Ͽ�ġ�� */

                            /*���*/
                            V_BREU_ENTR_AMT := 0;     /* ���б� */
                            V_BREU_LSN_AMT  := 0;     /* ������ */
                            V_BREU_REG_RESV_AMT:= 0;  /* ��Ͽ�ġ�� */

                            /*����*/
                            V_SCAL_ENTR_AMT := 0;     /* ���б� */
                            V_SCAL_LSN_AMT  := 0;     /* ������ */


                        END IF;


                         V_GV_ST_FG := 'U060500001';
                         V_AUTO_REG_FG := '';

                          IF  LIST_DATA.SELECT_USR_DEF = '2' THEN

                            IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* ��ϱݿ��� */

                                     V_AUTO_REG_FG := 'U060600003';
                                     V_GV_ST_FG := 'U060500002';

                            ELSIF(V_SCAL_TT_AMT = (NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))) THEN

                                    V_AUTO_REG_FG := 'U060600001';
                                    V_GV_ST_FG := 'U060500002';


                             END IF;

                            IF V_AUTO_REG_FG IS NOT NULL THEN

                             SELECT  MIN(TO_CHAR(TO_DATE(T1.PAID_TO_DT,'YYYYMMDD'),'YYYYMMDD'))
                                INTO    V_PAID_TO_DT
                                FROM
                                ENRO450 T1
                                WHERE T1.ENTR_SCHYY = LIST_DATA.ENTR_SCHYY
                                AND T1.ENTR_SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND T1.SELECT_FG    = LIST_DATA.SELECT_FG
                                 and T1.PAID_FR_DT > to_char(sysdate,'YYYYMMDD');

                              IF V_PAID_TO_DT IS NULL THEN

                                OUT_NUM := -10000;
                                OUT_MSG := '�����������ڸ� Ȯ�� �ϼ���.';
                                SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , OUT_NUM, OUT_MSG, IN_ID, IN_IP);
                                RETURN;

                              END IF;

                            END IF;

                        END IF;



                    /* 2015.12.07   �Ǽ���   ENRO410 UPDATE ��, EDAMT_SUPP_BREU_CD(��������������ڵ�), STD_BUDEN_RATE(�л��δ����), BREU_BUDEN_RATE(����δ����)�� ������Ʈ �ǵ��� ����. */
                    UPDATE ENRO410                                                                           /* ���Ի���ϴ���ڳ��� */
                       SET
                           CNTR_SUST_YN              = (CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                                             ELSE 'N'
                                                        END )                                                   /* ����а����� */
                         , EDAMT_SUPP_BREU_CD        = LIST_DATA.EDAMT_SUPP_BREU_CD                             /* ��������������ڵ� */
                         , STD_BUDEN_RATE            = V_STD_BUDEN_RATE                                         /* �л��δ���� */
                         , BREU_BUDEN_RATE           = V_BREU_BUDEN_RATE                                        /* ����δ���� */
                         , REG_RESV_AMT              = V_STD_REG_RESV_FG_AMT                                    /* ��Ͽ�ġ�� */
                         , ENTR_AMT                  = V_STD_ENTR_AMT                                           /* ���б� */
                         , LSN_AMT                   = V_STD_LSN_AMT                                            /* ������ */
                         , REG_TT_AMT                = (V_STD_REG_RESV_FG_AMT+V_STD_ENTR_AMT+V_STD_LSN_AMT)     /* ����ѱݾ� */
                         , BREU_ENTR_AMT             = V_BREU_ENTR_AMT                                          /* ������б� */
                         , BREU_LSN_AMT              = V_BREU_LSN_AMT                                           /* ��������� */
                         , BREU_REG_TT_AMT           = (V_BREU_ENTR_AMT+V_BREU_LSN_AMT)                         /* �������ѱݾ� */
                         , SCAL_ENTR_AMT             = V_SCAL_ENTR_AMT                                          /* �������б� */
                         , SCAL_LSN_AMT              = V_SCAL_LSN_AMT                                           /* ���м����� */
                         , SCAL_TT_AMT               = NVL(V_SCAL_TT_AMT,0)                                     /* �����ѱݾ� */
                         , STDUNI_AMT                = V_ENRO100_STDUNI_AMT                                     /* �л�ȸ��*/
                         , TEACHM_AMT                = (CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                                             ELSE NVL(V_TEACHM_AMT, 0)
                                                        END )                                                   /* ����� */
                         , MOD_ID                    = IN_ID                                                    /* ����ID */
                         , MOD_IP                    = IN_IP                                                    /* ����IP */
                         , MOD_DTTM                  = SYSDATE                                                  /* �����Ͻ� */
                     WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                              /* �����������ȣ */
                     RETURNING ROWID INTO  V_ROWID
                     ;

                              SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                        ,IN_ID => IN_ID
                                        ,IN_IP => IN_IP
                                        ,IN_CHG_FG => 'C015200002'
                                        ,IN_OWNER => 'SNU'
                                        ,IN_TABLE_ID => 'ENRO410'
                                        ,IN_ROWID => V_ROWID
                                        ,OUT_CODE => V_OUT_CODE
                                        ,OUT_MSG => V_OUT_MSG);

                              IF  V_OUT_CODE <> '0' THEN
                                  SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                  OUT_NUM := V_OUT_CODE;
                                  OUT_MSG :='���Ի� ��� ����� ������ ���� �Ͽ����ϴ�.[�����̷� ���� ����]';
                                  RETURN;
                              END IF;

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* ��ϱݿ��� */
                            /*  ���б��� �ִ� ��� */
                            IF LIST_DATA.SCAL_CD is not null AND IN_REG_RESV_FG = 'E' THEN  /* ��ϱ���(��ġ�ݹݿ�����) 'R'='��ϱݿ�ġ��', 'E'='��ϱ�' */


                            SELECT COUNT(*)
                            INTO
                            V_SCAL_CNT
                            FROM SCHO530
                            WHERE
                            EXAM_STD_MNGT_NO = LIST_DATA.EXAM_STD_MNGT_NO
                            AND SCAL_CD  = LIST_DATA.SCAL_CD ;

                                IF V_SCAL_CNT < 1 THEN
                                    INSERT INTO SCHO530                                           /* ���Ի����м��߳��� */
                                         (  EXAM_STD_MNGT_NO                                  /* �����������ȣ */
                                          , SCAL_CD                                           /* �����ڵ� */
                                          , SLT_DT                                            /* �������� */
                                          , ENTR_AMT                                          /* ���б� */
                                          , LSN_AMT                                           /* ������ */
                                          , SSO_AMT                                           /* �⼺ȸ�� */
                                          , LIF_AMT                                           /* ��Ȱ�� */
                                          , STUDY_ENC_AMT                                     /* �о������ */
                                          , TEACHM_AMT                                        /* ����� */
                                          , ETC_SCAL_AMT                                      /* ��Ÿ���б� */
                                          , SCAL_TT_AMT                                       /* �����ѱݾ� */
                                          , SUBST_DED_NO                                      /* ��ü������ȣ */
                                          , SCAL_SLT_PROG_ST_FG                               /* ���м���������±��� */
                                          , ACCPR_PERS_NO                                     /* �����ڰ��ι�ȣ */
                                          , ACCP_DT                                           /* �������� */
                                          , SCAL_SLT_NO                                       /* ���м��߹�ȣ */
                                          , REMK                                              /* ��� */
                                          , INPT_ID                                           /* �Է�ID */
                                          , INPT_IP                                           /* �Է�IP */
                                          , INPT_DTTM                                         /* �Է��Ͻ� */
                                          , MOD_ID                                            /* ����ID */
                                          , MOD_IP                                            /* ����IP */
                                          , MOD_DTTM                                          /* �����Ͻ� */
                                         )
                                         VALUES
                                         (  LIST_DATA.EXAM_STD_MNGT_NO                              /* �����������ȣ */
                                          , LIST_DATA.SCAL_CD                                       /* �����ڵ� */
                                          , TO_CHAR(SYSDATE,'YYYYMMDD')                             /* �������� */
                                          , NVL(V_SCAL_ENTR_AMT,0)                                  /* �������б� */
                                          , NVL(V_SCAL_LSN_AMT,0)                                   /* ���м����� */
                                          , 0                                                       /* �⼺ȸ�� */
                                          , 0                                                       /* ��Ȱ�� */
                                          , 0                                                       /* �о������ */
                                          , nvl(V_TEACHM_AMT,0)                                     /* ����� */
                                          , 0                                                       /* ��Ÿ���б� */
                                          , NVL(V_SCAL_TT_AMT,0)                                    /* �����ѱݾ� */
                                          , ''                                                      /* ��ü������ȣ */
                                          , 'U073300004'                                            /* ���м���������±��� Ȯ��ó�� */
                                          , IN_ID                                                   /* �����ڰ��ι�ȣ */
                                          , ''                                                      /* �������� */
                                          , ''                                                      /* ���м��߹�ȣ */
                                          , ''                                                      /* ��� */
                                          , IN_ID                                                   /* �Է�ID */
                                          , IN_IP                                                   /* �Է�IP */
                                          , SYSDATE                                                 /* �Է��Ͻ� */
                                          , IN_ID                                                   /* �Է�ID */
                                          , IN_IP                                                   /* �Է�IP */
                                          , SYSDATE                                                 /* �Է��Ͻ� */
                                         ) ;
                                ELSE

                                UPDATE scho530                    /* ���Ի����м��߳��� */
                                   SET SLT_DT                    = TO_CHAR(SYSDATE,'YYYYMMDD')          /* �������� */
                                     , ENTR_AMT                  = NVL(V_SCAL_ENTR_AMT,0)               /* �������б� */
                                     , LSN_AMT                   = NVL(V_SCAL_LSN_AMT,0)                /* ���м����� */
                                     , SSO_AMT                   = 0                                    /* �⼺ȸ�� */
                                     , LIF_AMT                   = 0                                    /* ��Ȱ�� */
                                     , STUDY_ENC_AMT             = 0                                    /* �о������ */
                                     , TEACHM_AMT                = nvl(V_TEACHM_AMT,0)                  /* ����� */
                                     , ETC_SCAL_AMT              = 0                                    /* ��Ÿ���б� */
                                     , SCAL_TT_AMT               = NVL(V_SCAL_TT_AMT,0)                 /* ��ü������ȣ */
                                     , SCAL_SLT_PROG_ST_FG       = 'U073300004'                         /* ���м���������±��� */
                                     , ACCPR_PERS_NO             = IN_ID                                /* �����ڰ��ι�ȣ */
                                     , MOD_ID                    = IN_ID                                /* ����ID */
                                     , MOD_IP                    = IN_IP                                /* ����IP */
                                     , MOD_DTTM                  = SYSDATE                              /* �����Ͻ� */
                                 WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO           /* �����������ȣ */
                                   AND SCAL_CD                   = LIST_DATA.SCAL_CD                    /* �����ڵ� */
                                 ;

                                END IF;



                            END IF;

                        END IF;

                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                         V_MSG :='---------------3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']';


                    END LOOP;


            END IF;

        END IF;

    ELSIF V_BNSN011_USR_DEF_2 = '1' THEN /* ����*/

        V_MSG :='---------------3--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
        ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
        ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
        ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
        ||'] IN_TRET_FG['||IN_TRET_FG||']'
        ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
        ||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
        ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
        ||'] IN_TRET_FG['||IN_TRET_FG||']'
        ||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']'
;

        IF IN_REG_RESV_FG = 'R' then /* ��ϱ���(��ġ�ݹݿ�����) 'R'='��ϱݿ�ġ��', 'E'='��ϱ�' */

            IF IN_TRET_FG = 'C' THEN  /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

              FOR LIST_DATA IN (
                         SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3   AS SELECT_USR_DEF                                  /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,t3.USR_DEF_3  AS SELECT_USR_DEF                                   /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                    FROM    SREG001 T1
                                                                          , ENRO400 T2
                                                                          , V_COMM111_4 T4
                                                                   WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                     AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                     AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                     AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                                                                     AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                                                                     AND    T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                                                                     AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                                                                     and    T2.STUNO is not null
                                                                     AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                    WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                               ELSE 'C013300002'
                                                                                               END)
                                                                     AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                     AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                     AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              AND   NOT EXISTS (SELECT 1
                                                  FROM ENRO420 TA1
                                                 WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
                        )
                    LOOP

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* ��ϱݿ��� */

                             BEGIN

                                /*���������⺻���̺��� �μ��ڵ�� ��ϱ�å������ ���� Ȯ��*/
                                SELECT
                                T1.ENTR_AMT                                     /* ���б� */
                                ,T1.LSN_AMT                                      /* ������ */
                                ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* ���б� */
                                ,V_ENRO100_LSN_AMT                               /* ������ */
                                ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*���������⺻�� �μ��ڵ�� ��ϱ�å���� �ȵ� ��� �����ڵ�� ���� Ȯ��*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* ���б� */
                                    ,T1.LSN_AMT                                      /* ������ */
                                    ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                    ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                    ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                    ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                    ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                    ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                    ,'Y' AS YN
                                    INTO
                                    V_ENRO100_ENTR_AMT                              /* ���б� */
                                    ,V_ENRO100_LSN_AMT                               /* ������ */
                                    ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                    ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                    ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '�ش� �а� ������ ���� ��ϱ�å�� ������ �����ϴ�[�й� = ' || LIST_DATA.STUNO
                                 ||'ENTR_SCHYY  '||LIST_DATA.ENTR_SCHYY
                                ||'ENTR_SHTM_FG '||LIST_DATA.ENTR_SHTM_FG
                                ||'DETA_SHTM_FG  '||LIST_DATA.DETA_SHTM_FG
                                ||'CORS_FG  '||LIST_DATA.CORS_FG
                                ||'SHYR'||LIST_DATA.SHYR
                                ||'DAYNGT_FG'||LIST_DATA.DAYNGT_FG
                                || ' / ����(�а�)�ڵ� = ' ||LIST_DATA.DEPARTMENT_CD||'('|| LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || ')].';
                                RETURN;

                                END;

                            END;

                             /* ��ϱ� ��å������ ���� ��� ,, ���� ó��*/
                            if V_ENRO100_REG_RESV_AMT = 0 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '���Ի� ��ϱ�å�������� Ȯ�� �ϼ���.';
                                RETURN;

                            END IF;

                        END IF;

                         V_MSG :='---------------44--IN_ENTR_SCHYY[' ||IN_ENTR_SCHYY
                            ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                            ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                            ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                            ||'] IN_TRET_FG['||IN_TRET_FG||']'
                            ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
                            ||'] V_BNSN011_USR_DEF_2['||V_BNSN011_USR_DEF_2||']'
                            ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']'
                            ||'] IN_TRET_FG['||IN_TRET_FG||']'
                            ||'] V_SCAL_ENTR_AMT['||V_SCAL_ENTR_AMT||']';


                       INSERT INTO ENRO410(
                                     EXAM_STD_MNGT_NO                /* �����������ȣ(PK1) */
                                    ,SCAL_CD                         /* �����ڵ� */
                                    ,CNTR_SUST_YN                    /* ����а����� */
                                    ,EDAMT_SUPP_BREU_CD              /* ��������������ڵ� */
                                    ,STD_BUDEN_RATE                  /* �л��δ���� */
                                    ,BREU_BUDEN_RATE                 /* ����δ���� */
                                    ,CSH_BUDEN_RATE                  /* ���ݺδ���� */
                                    ,ACTHNG_BUDEN_RATE               /* �����δ���� */
                                    ,CAL_CLS_YN                      /* ����ϷῩ�� */
                                    ,REG_RESV_AMT                    /* ��Ͽ�ġ�� */
                                    ,ENTR_AMT                        /* ���б� */
                                    ,LSN_AMT                         /* ������ */
                                    ,REG_TT_AMT                      /* ����ѱݾ� */
                                    ,BREU_ENTR_AMT                   /* ������б� */
                                    ,BREU_LSN_AMT                    /* ��������� */
                                    ,BREU_REG_TT_AMT                 /* �������ѱݾ� */
                                    ,SCAL_ENTR_AMT                   /* �������б� */
                                    ,SCAL_LSN_AMT                    /* ���м����� */
                                    ,SCAL_TT_AMT                     /* �����ѱݾ� */
                                    ,STDUNI_AMT                      /* �л�ȸ�� */
                                    ,TEACHM_AMT                      /* ����� */
                                    ,RECIV_REG_RESV_AMT              /* ������Ͽ�ġ�� */
                                    ,RECIV_ENTR_AMT                  /* �������б� */
                                    ,RECIV_LSN_AMT                   /* ���������� */
                                    ,RECIV_TT_AMT                    /* �����ѱݾ� */
                                    ,BREU_RECIV_ENTR_AMT             /* ����������б� */
                                    ,BREU_RECIV_LSN_AMT              /* ������������� */
                                    ,BREU_RECIV_TT_AMT               /* ��������ѱݾ� */
                                    ,RECIV_STDUNI_AMT                /* �����л�ȸ�� */
                                    ,RECIV_TEACHM_AMT                /* ��������� */
                                    ,GV_ST_FG                        /* ���Ի��±��� */
                                    ,AUTO_REG_FG                     /* �ڵ���ϱ��� */
                                    ,RECIV_DT                        /* �������� */
                                    ,REMK                            /* ��� */
                                    ,SMS_SEND_SEQ                    /* SMS�߼ۼ��� */
                                    ,EMAIL_SEND_SEQ                  /* �̸��Ϲ߼ۼ��� */
                                    ,INPT_ID                         /* �Է�ID */
                                    ,INPT_IP                         /* �Է�IP */
                                    ,INPT_DTTM                       /* �Է��Ͻ� */
                                    ,REG_RESV_AMT_GV_ST_FG
                            )VALUES(
                                     LIST_DATA.EXAM_STD_MNGT_NO                                         /* �����������ȣ(PK1) */
                                    ,LIST_DATA.SCAL_CD                                                  /* �����ڵ� */
                                    ,(CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                      ELSE 'N'
                                      END )                                                             /* ����а����� */
                                    ,LIST_DATA.EDAMT_SUPP_BREU_CD                                       /* ��������������ڵ� */
                                    ,V_STD_BUDEN_RATE                                                   /* �л��δ���� */
                                    ,V_BREU_BUDEN_RATE                                                  /* ����δ���� */
                                    ,V_CSH_BUDEN_RATE                                                   /* ���ݺδ���� */
                                    ,V_ACTHNG_BUDEN_RATE                                                /* �����δ���� */
                                    ,'N'                                                                /* ����ϷῩ�� */
                                    ,NVL(V_ENRO100_REG_RESV_AMT, 0)                                      /* ��Ͽ�ġ�� */
                                    ,0                                                                  /* ���б� */
                                    ,0                                                                  /* ������ */
                                    ,0                                                                  /* (���б�+������) ����ѱݾ� */
                                    ,0                                                                  /* ������б� */
                                    ,0                                                                  /* ��������� */
                                    ,0                                                                  /* (���б�+������) �������ѱݾ� */
                                    ,0                                                                  /* �������б� */
                                    ,0                                                                  /* ���м����� */
                                    ,0                                                                  /* (���б�+������) ���е���ѱݾ� */
                                    ,0                                                                  /* �л�ȸ�� */
                                    ,0                                                                  /* �����(����+����) */
                                    ,0                                                                  /* ������Ͽ�ġ�� */
                                    ,0                                                                  /* �������б� */
                                    ,0                                                                  /* ���������� */
                                    ,0                                                                  /* �����ѱݾ� */
                                    ,0                                                                  /* ����������б� */
                                    ,0                                                                  /* ������������� */
                                    ,0                                                                  /* ��������ѱݾ� */
                                    ,0                                                                  /* �����л�ȸ�� */
                                    ,0                                                                  /* ��������� */
                                    ,'U060500001'                                                       /* ���Ի��±���(�̵��) */
                                    ,''                                                                 /* �ڵ���ϱ��� */
                                    ,''                                                                 /* �������� */
                                    ,''                                                                 /* ��� */
                                    ,''                                                                 /* SMS�߼ۼ��� */
                                    ,''                                                                 /* �̸��Ϲ߼ۼ��� */
                                    ,IN_ID                                                              /* �Է�ID */
                                    ,IN_IP                                                              /* �Է�IP */
                                    ,SYSDATE                                                            /* �Է��Ͻ� */
                                    ,'U060500001'                                                       /* ��Ͽ�ġ�ݳ��Ի��±���*/
                                )
                            RETURNING ROWID
                            INTO V_ROWID;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200001'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                          IF  V_OUT_CODE <> '0' THEN
                              SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                              OUT_NUM := V_OUT_CODE;
                              OUT_MSG :='���Ի� ��� ����� ������ ���� �Ͽ����ϴ�.[�����̷� ���� ����]';
                              RETURN;
                          END IF;

                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                    END LOOP;

            ELSIF IN_TRET_FG IN('U','R') THEN  /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

             FOR LIST_DATA IN (
                            SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- end */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,t3.USR_DEF_3   AS SELECT_USR_DEF                                  /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG    = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.STUNO IS NOT NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                   FROM    SREG001 T1
                                                                         , ENRO400 T2
                                                                         , V_COMM111_4 T4
                                                                  WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                    AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                    AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                    AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                                                                    AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                                                                    AND    T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                                                                    AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                                                                    AND    T2.STUNO IS NOT NULL
                                                                    AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                   WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                              ELSE 'C013300002'
                                                                                              END)
                                                                    AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                    AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                    AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- end */
                    )
                    LOOP

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* ��ϱݿ��� */

                           BEGIN

                                /*���������⺻���̺��� �μ��ڵ�� ��ϱ�å������ ���� Ȯ��*/
                                SELECT
                                T1.ENTR_AMT                                     /* ���б� */
                                ,T1.LSN_AMT                                      /* ������ */
                                ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                ,'Y' AS YN
                                INTO
                                V_ENRO100_ENTR_AMT                              /* ���б� */
                                ,V_ENRO100_LSN_AMT                               /* ������ */
                                ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                ,V_ENRO100_YN
                                FROM  ENRO100 T1
                                WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                AND  T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                                AND  T1.SHYR = LIST_DATA.SHYR
                                AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;


                           EXCEPTION
                                WHEN NO_DATA_FOUND THEN

                                BEGIN
                                    /*���������⺻�� �μ��ڵ�� ��ϱ�å���� �ȵ� ��� �����ڵ�� ���� Ȯ��*/
                                    SELECT
                                    T1.ENTR_AMT                                     /* ���б� */
                                    ,T1.LSN_AMT                                      /* ������ */
                                    ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                    ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                    ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                    ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                    ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                    ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                    ,'Y' AS YN
                                    INTO
                                    V_ENRO100_ENTR_AMT                              /* ���б� */
                                    ,V_ENRO100_LSN_AMT                               /* ������ */
                                    ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                    ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                    ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                    ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                    ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                    ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                    ,V_ENRO100_YN
                                    FROM  ENRO100 T1
                                    WHERE  T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                    AND  T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                    AND  T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                    AND  T1.CORS_FG = LIST_DATA.CORS_FG
                                    AND  T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                    AND  T1.SHYR = LIST_DATA.SHYR
                                    AND  T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                    OUT_NUM := -1;
                                    OUT_MSG := '�ش� �а� ������ ���� ��ϱ�å�� ������ �����ϴ�[�й� = ' || LIST_DATA.STUNO || ' / �а��ڵ� = ' || LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || '].';
                                    RETURN;

                                END;

                           END;

                             /* ��ϱ� ��å������ ���� ��� ,, ���� ó��*/
                            if V_ENRO100_REG_RESV_AMT < 1 THEN

                                OUT_NUM := -1000;
                                OUT_MSG := '���Ի� ��ϱ�å�������� Ȯ�� �ϼ���.';
                                RETURN;

                            END IF;

                        END IF;

                    UPDATE enro410                                                                        /* ���Ի���ϴ���ڳ��� */
                       SET
                           REG_RESV_AMT              = V_ENRO100_REG_RESV_AMT                             /* ��Ͽ�ġ��*/
                         , MOD_ID                    = IN_ID                                              /* ����ID */
                         , MOD_IP                    = IN_IP                                              /* ����IP */
                         , MOD_DTTM                  = SYSDATE                                            /* �����Ͻ� */
                     WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                         /* �����������ȣ */
                     RETURNING ROWID INTO  V_ROWID
                     ;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200002'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                      IF  V_OUT_CODE <> '0' THEN
                          SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                          OUT_NUM := V_OUT_CODE;
                          OUT_MSG :='���Ի� ��� ����� ������ ���� �Ͽ����ϴ�.[�����̷� ���� ����]';
                          RETURN;
                      END IF;




                         V_MSG :='---------------3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']';



                      OUT_TRET_CNT := OUT_TRET_CNT+1;

                    END LOOP;

            END IF;


        ELSIF IN_REG_RESV_FG = 'E' then /* ��ϱ���(��ġ�ݹݿ�����) 'R'='��ϱݿ�ġ��', 'E'='��ϱ�' */



            IF V_RESV_GV_CNT < 1  THEN

                SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                OUT_NUM := '-1';
                OUT_MSG :='��ġ�ݳ��� ó���� �����Ͱ� ��� ����� ���� �� ��ϱ� ������� �Ұ� �մϴ�.';
                RETURN;

            END IF;

             FOR LIST_DATA IN (
                        SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,T5.REG_RESV_AMT
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                              AND   T2.SPCMAJ_NM = T1.SPCMAJ_NM
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              AND   T5.REG_RESV_AMT_GV_ST_FG = 'U060500002'
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- end */
                        union
                       SELECT
                                T2.EXAM_STD_MNGT_NO                             /* �����������ȣ(PK1) */
                               ,T2.ENTR_SCHYY                                   /* �����г⵵ */
                               ,T2.ENTR_SHTM_FG                                 /* �����бⱸ�� */
                               , 'U000300001' AS DETA_SHTM_FG
                               ,T2.SELECT_FG                                    /* �������� */
                               ,T3.USR_DEF_1 AS SELECT_DEPT_CD                    /* �������кμ�*/
                               ,T2.EXAM_NO                                      /* �����ȣ */
                               ,T2.RES_NO                                       /* �ֹε�Ϲ�ȣ */
                               ,T2.STUNO                                        /* �й� */
                               ,T2.SHYR                                         /* �г�*/
                               ,T2.RPST_PERS_NO                                 /* ��ǥ���ι�ȣ */
                               ,T2.STD_KOR_NM                                   /* �л��ѱ۸� */
                               ,T2.STD_CHA_NM                                   /* �л����ڸ� */
                               ,T2.STD_ENG_NM                                   /* �л������� */
                               ,T1.ENTR_CORS_FG AS CORS_FG                      /* �������� */
                               ,T2.DAYNGT_FG                                    /* �־߱��� */
                               ,T2.NATI_FG                                      /* �������� */
                               ,T2.PASS_SEQ                                     /* �հ����� */
                               ,T2.EXAM_COLL_UNIT_CD                            /* �Խø��������ڵ� */
                               ,T1.DEPT_CD AS EXAM_COLL_UNIT_DEPT_CD            /* �Խø����μ�*/
                               ,T2.EXAM_COLL_UNIT_NM                            /* �Խø��������� */
                               ,T2.SPCMAJ_NM                                    /* ���������� */
                               ,T2.SCAL_CD                                      /* �����ڵ� */
                               ,T2.TRANS_YN                                     /* �̰����� */
                               ,T2.EDAMT_SUPP_BREU_CD                           /* ��������������ڵ� */
                               ,T4.BDEGR_SYSTEM_FG                              /* �л�ý��۱��� */
                               ,T4.DEPARTMENT_CD                                /*�а�*/
                               ,T4.MAJOR_CD                                     /*����*/
                               ,NVL(T2.TUIT_EXMP_YN,'N') AS TUIT_EXMP_YN
                               ,T5.RECIV_REG_RESV_AMT
                               ,T5.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                               ,t3.USR_DEF_3    AS SELECT_USR_DEF                                 /* ����� ����3 1�̸� �к� 2�̸� ���п�*/
                            FROM      SREG001 T1
                                    , ENRO400 T2
                                    , BSNS011 t3
                                    , V_COMM111_4 T4
                                    , ENRO410 T5
                            WHERE   T2.SELECT_FG     = T3.CMMN_CD                          /* �������� */
                              and   T1.SCHYY        = T2.ENTR_SCHYY
                              AND   T1.SHTM_FG      = T2.ENTR_SHTM_FG
                              AND   T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                              AND   T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                              AND   T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                              AND   T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                              AND   T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                              AND   T2.EXAM_STD_MNGT_NO      = T5.EXAM_STD_MNGT_NO
                              AND   T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                            WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                       ELSE 'C013300002'
                                                       END)
                              AND   T4.DEPT_CD      = T1.DEPT_CD
                              AND   T1.EXAM_SUST_SLT_EXCP_FG <> 'U032800003'
                              AND   T5.REG_RESV_AMT_GV_ST_FG = 'U060500002'
                              AND   T1.SPCMAJ_NM    IS NULL
                              AND   T2.ANUN_CLS_YN = 'Y'   /* 2015.11.02 ��ǥ�ϷῩ�ΰ� 'Y'�� ��츸 ���� */
                              AND   T2.EXAM_STD_MNGT_NO NOT IN ( SELECT T2.EXAM_STD_MNGT_NO
                                                                    FROM    SREG001 T1
                                                                          , ENRO400 T2
                                                                          , V_COMM111_4 T4
                                                                   WHERE    T1.SCHYY        = T2.ENTR_SCHYY
                                                                     AND    T1.SHTM_FG      = T2.ENTR_SHTM_FG
                                                                     AND    T1.COLL_UNIT_CD = T2.EXAM_COLL_UNIT_CD
                                                                     AND    T2.ENTR_SCHYY   = IN_ENTR_SCHYY                        /* �����г⵵*/
                                                                     AND    T2.ENTR_SHTM_FG = IN_ENTR_SHTM_FG                      /* �����бⱸ��*/
                                                                     AND    T2.SELECT_FG    = IN_SELECT_FG                         /* ��������*/
                                                                     AND    T2.PASS_SEQ     = IN_PASS_SEQ                          /* �հ�����*/
                                                                     and    T2.STUNO is not null
                                                                     AND    T1.ENTR_CORS_FG = (CASE WHEN T2.CORS_FG IN ('C013300001', 'C013300002', 'C013300003') THEN  T2.CORS_FG
                                                                                                    WHEN T2.CORS_FG = 'C013300006' THEN 'C013300001'
                                                                                                   ELSE 'C013300002'
                                                                                                   END)
                                                                     AND    T4.DEPT_CD      = T1.EXAM_CONN_OBJ_DEPT_CD
                                                                     AND    T1.EXAM_SUST_SLT_EXCP_FG = 'U032800003'
                                                                     AND    T2.SPCMAJ_NM = T1.SPCMAJ_NM  )
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- start */
                              --AND   NOT EXISTS (SELECT 1
                              --                    FROM ENRO420 TA1
                              --                   WHERE TA1.EXAM_STD_MNGT_NO = T2.EXAM_STD_MNGT_NO) /* 2015.08.05 ������°� �ο��� ������ ������ �̺ο��� ����ڸ� �����ϵ��� ���� */
                              /* 2016.01.20 ��ϱ�, (��ġ�ݹݿ�����, ��ϱ������) ó����� ����( T1601190083 ) -- end */
                    )
                    LOOP

                        BEGIN

                            /*���������⺻���̺��� �μ��ڵ�� ��ϱ�å������ ���� Ȯ��*/
                            SELECT T1.ENTR_AMT                                     /* ���б� */
                                  ,T1.LSN_AMT                                      /* ������ */
                                  ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                  ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                  ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                  ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                  ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                  ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                  ,'Y' AS YN
                              INTO V_ENRO100_ENTR_AMT                              /* ���б� */
                                  ,V_ENRO100_LSN_AMT                               /* ������ */
                                  ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                  ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                  ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                  ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                  ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                  ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                  ,V_ENRO100_YN
                              FROM ENRO100 T1
                             WHERE T1.SCHYY = LIST_DATA.ENTR_SCHYY
                               AND T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                               AND T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                               AND T1.CORS_FG = LIST_DATA.CORS_FG
                               AND T1.DEPT_CD = LIST_DATA.EXAM_COLL_UNIT_DEPT_CD
                               AND T1.SHYR = LIST_DATA.SHYR
                               AND T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN

                            BEGIN
                                /*���������⺻�� �μ��ڵ�� ��ϱ�å���� �ȵ� ��� �����ڵ�� ���� Ȯ��*/
                                SELECT T1.ENTR_AMT                                     /* ���б� */
                                      ,T1.LSN_AMT                                      /* ������ */
                                      ,T1.SSO_AMT                                      /* �⼺ȸ�� */
                                      ,T1.REG_RESV_AMT                                 /* ��Ͽ�ġ�� */
                                      ,T1.STDUNI_AMT                                   /* �л�ȸ�� */
                                      ,T1.MEDI_DUC_AMT                                 /* �Ƿ������ */
                                      ,T1.CMMN_TEACHM_AMT                              /* ���뱳��� */
                                      ,T1.CHOICE_TEACHM_AMT                            /* ���ñ���� */
                                      ,'Y' AS YN
                                  INTO V_ENRO100_ENTR_AMT                              /* ���б� */
                                      ,V_ENRO100_LSN_AMT                               /* ������ */
                                      ,V_ENRO100_SSO_AMT                               /* �⼺ȸ�� */
                                      ,V_ENRO100_REG_RESV_AMT                          /* ��Ͽ�ġ�� */
                                      ,V_ENRO100_STDUNI_AMT                            /* �л�ȸ�� */
                                      ,V_ENRO100_MEDI_DUC_AMT                          /* �Ƿ������ */
                                      ,V_ENRO100_CMMN_TEACHM_AMT                       /* ���뱳��� */
                                      ,V_ENRO100_CHOICE_TEACHM_AMT                     /* ���ñ���� */
                                      ,V_ENRO100_YN
                                  FROM ENRO100 T1
                                 WHERE T1.SCHYY = LIST_DATA.ENTR_SCHYY
                                   AND T1.SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                   AND T1.DETA_SHTM_FG = LIST_DATA.DETA_SHTM_FG
                                   AND T1.CORS_FG = LIST_DATA.CORS_FG
                                   AND T1.DEPT_CD = LIST_DATA.DEPARTMENT_CD
                                   AND T1.SHYR = LIST_DATA.SHYR
                                   AND T1.DAYNGT_FG = LIST_DATA.DAYNGT_FG;

                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                OUT_NUM := -1;
                                OUT_MSG := '�ش� �а� ������ ���� ��ϱ�å�� ������ �����ϴ�[�й� = ' || LIST_DATA.STUNO || ' / �а��ڵ� = ' || LIST_DATA.EXAM_COLL_UNIT_DEPT_CD || '].';
                                RETURN;

                            END;

                        END;

                         /*�л�*/
                        V_STD_ENTR_AMT := 0;       /* ���б� */
                        V_STD_LSN_AMT  := 0;       /* ������ */
                        V_STD_REG_RESV_AMT:= 0;    /* ��Ͽ�ġ�� */
                        V_STD_REG_RESV_FG_AMT:= 0; /* ��Ͽ�ġ�� */

                        /*���*/
                        V_BREU_ENTR_AMT := 0;     /* ���б� */
                        V_BREU_LSN_AMT  := 0;     /* ������ */
                        V_BREU_REG_RESV_AMT:= 0;  /* ��Ͽ�ġ�� */

                        /*����*/
                        V_SCAL_ENTR_AMT := 0;     /* ���б� */
                        V_SCAL_LSN_AMT  := 0;     /* ������ */



                        /*�⺻��ϱ� �Է�*/
                        V_STD_ENTR_AMT      := V_ENRO100_ENTR_AMT;      /* �л� ���б� */
                        V_STD_LSN_AMT       := V_ENRO100_LSN_AMT;       /* �л� ������ */
                        V_STD_REG_RESV_AMT  := V_ENRO100_REG_RESV_AMT;  /* �л� ��Ͽ�ġ�� */

                         /* ��ϱ� ��å������ ���� ��� ,, ���� ó��*/
                        if V_STD_ENTR_AMT = 0 and V_STD_LSN_AMT = 0 AND V_STD_REG_RESV_AMT = 0 THEN

                            OUT_NUM := -1000;
                            OUT_MSG := '���Ի� ��ϱ�å�������� Ȯ�� �ϼ���.';
                            RETURN;

                        END IF;

                        /* �����*/
                        V_TEACHM_AMT := V_ENRO100_CMMN_TEACHM_AMT+V_ENRO100_CHOICE_TEACHM_AMT;

                        /* ����а� ������ ��� */
                        IF LIST_DATA.SELECT_DEPT_CD != '00000' THEN

                            IF LIST_DATA.EDAMT_SUPP_BREU_CD IS NULL THEN
                                OUT_NUM := -1000;
                                OUT_MSG := '��������������� Ȯ�� �ϼ���.';
                                RETURN;
                            END IF;

                            BEGIN

                                SELECT
                                    T1.STD_BUDEN_RATE                                                        /* �л��δ���� */
                                   ,T1.BREU_BUDEN_RATE                                                       /* ����δ���� */
                                   ,T1.CSH_BUDEN_RATE                                                        /* ���ݺδ���� */
                                   ,T1.ACTHNG_BUDEN_RATE                                                     /* �����δ���� */
                                   INTO
                                    V_STD_BUDEN_RATE
                                   ,V_BREU_BUDEN_RATE
                                   ,V_CSH_BUDEN_RATE
                                   ,V_ACTHNG_BUDEN_RATE
                                FROM ENRO170 T1
                                WHERE T1.EDAMT_SUPP_BREU_CD = LIST_DATA.EDAMT_SUPP_BREU_CD
                                AND T1.DEPT_CD = LIST_DATA.SELECT_DEPT_CD;

                                 /*�л�*/
                                V_STD_ENTR_AMT :=(V_STD_BUDEN_RATE/100)* V_ENRO100_ENTR_AMT;         /* �л� ���б� */
                                V_STD_LSN_AMT  := (V_STD_BUDEN_RATE/100)* V_ENRO100_LSN_AMT;          /* �л� ������ */

                                /*���*/
                                V_BREU_ENTR_AMT :=(V_BREU_BUDEN_RATE/100)*V_ENRO100_ENTR_AMT;         /* ��� ���б� */
                                V_BREU_LSN_AMT  := (V_BREU_BUDEN_RATE/100)*V_ENRO100_LSN_AMT;          /* ��� ������ */


                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '��������������� �����ϴ�.';
                                    RETURN;
                                WHEN OTHERS THEN
                                    SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                    OUT_NUM := SQLCODE;
                                    OUT_MSG := '������������� �����͸� Ȯ�� �ϼ���';
                                    RETURN;
                            END;

                        END IF;

                        /*  ���б��� �ִ� ��� */
                        IF LIST_DATA.SCAL_CD is not null THEN

                            BEGIN
                                 SELECT
                                        T2.ENTR_AMT_RATE                                     /* ���бݺ��� */
                                      , T2.LSN_AMT_RATE                                      /* ��������� */
                                INTO
                                         V_SCAL_ENTR_AMT_RATE                                /* ���бݺ��� */
                                      ,  V_SCAL_LSN_AMT_RATE                                 /* ��������� */
                                FROM
                                SCHO100 T1
                               ,SCHO110 T2
                                WHERE  T1.SCAL_CD =  T2.SCAL_CD
                                AND T1.SCAL_CD = LIST_DATA.SCAL_CD
                                AND T1.BDEGR_SYSTEM_FG = LIST_DATA.BDEGR_SYSTEM_FG
                                AND T2.SUBMATT_CORS_FG = (CASE WHEN LIST_DATA.SELECT_USR_DEF = '1' THEN 'U040800001'
                                                               WHEN LIST_DATA.SELECT_USR_DEF = '2' THEN 'U040800002'
                                                         ELSE ''
                                                         END)
                                ;

                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    OUT_NUM := -1000;
                                    OUT_MSG := '���б� �������� �����ϴ�.';
                                    RETURN;
                                WHEN OTHERS THEN
                                    SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                                    OUT_NUM := SQLCODE;
                                    OUT_MSG := '���б� ó���� ���� �Ͽ����ϴ�.';
                                    RETURN;
                            END;



                            /* ���� */
                             V_SCAL_ENTR_AMT :=(V_SCAL_ENTR_AMT_RATE/100)* V_ENRO100_ENTR_AMT;      /* ���� ���б� */
                             V_SCAL_LSN_AMT :=(V_SCAL_LSN_AMT_RATE/100)* V_ENRO100_LSN_AMT;         /* ���� ������ */
                             V_SCAL_TT_AMT := V_SCAL_ENTR_AMT+V_SCAL_LSN_AMT;                        /*�ѱݾ�*/

                        END IF;


                        IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* ��ϱݿ��� */

                            /*�л�*/
                            V_STD_ENTR_AMT := 0;       /* ���б� */
                            V_STD_LSN_AMT  := 0;       /* ������ */
                            V_STD_REG_RESV_AMT:= 0;    /* ��Ͽ�ġ�� */
                            V_STD_REG_RESV_FG_AMT:= 0; /* ��Ͽ�ġ�� */

                            /*���*/
                            V_BREU_ENTR_AMT := 0;     /* ���б� */
                            V_BREU_LSN_AMT  := 0;     /* ������ */
                            V_BREU_REG_RESV_AMT:= 0;  /* ��Ͽ�ġ�� */

                            /*����*/
                            V_SCAL_ENTR_AMT := 0;     /* ���б� */
                            V_SCAL_LSN_AMT  := 0;     /* ������ */

                        END IF;


                        V_GV_ST_FG := 'U060500001';
                        V_AUTO_REG_FG := NULL;

                        IF  LIST_DATA.SELECT_USR_DEF = '2' THEN

                            IF LIST_DATA.TUIT_EXMP_YN ='Y' THEN /* ��ϱݿ��� */

                                V_AUTO_REG_FG := 'U060600003';
                                V_GV_ST_FG := 'U060500002';

                            ELSIF(V_SCAL_TT_AMT = (NVL(V_STD_ENTR_AMT, 0)+NVL(V_STD_LSN_AMT, 0))) THEN

                                V_AUTO_REG_FG := 'U060600001';
                                V_GV_ST_FG := 'U060500002';

                             END IF;

                            IF V_AUTO_REG_FG IS NOT NULL THEN


                                SELECT MAX(TO_CHAR(TO_DATE(T1.PAID_TO_DT,'YYYYMMDD')+1,'YYYYMMDD'))
                                  INTO V_PAID_TO_DT
                                  FROM ENRO450 T1
                                 WHERE T1.ENTR_SCHYY   = LIST_DATA.ENTR_SCHYY
                                   AND T1.ENTR_SHTM_FG = LIST_DATA.ENTR_SHTM_FG
                                   AND T1.SELECT_FG    = LIST_DATA.SELECT_FG
                                   AND T1.REG_KND_FG   = 'U060300001'
                                ;

                                IF V_PAID_TO_DT IS NULL THEN

                                    OUT_NUM := -10000;
                                    OUT_MSG := '�����������ڸ� Ȯ�� �ϼ���.';
                                    SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , OUT_NUM, OUT_MSG, IN_ID, IN_IP);
                                    RETURN;

                                END IF;

                            END IF;

                        END IF;


                        IF IN_TRET_FG =  'U' THEN /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

                            /* 2015.12.07   �Ǽ���   ENRO410 UPDATE ��, EDAMT_SUPP_BREU_CD(��������������ڵ�), STD_BUDEN_RATE(�л��δ����), BREU_BUDEN_RATE(����δ����)�� ������Ʈ �ǵ��� ����. */
                            UPDATE ENRO410                                                                           /* ���Ի���ϴ���ڳ��� */
                               SET
                                   CNTR_SUST_YN              = (CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                                                     ELSE 'N'
                                                                END )                                                   /* ����а����� */
                                 , EDAMT_SUPP_BREU_CD        = LIST_DATA.EDAMT_SUPP_BREU_CD                             /* ��������������ڵ� */
                                 , STD_BUDEN_RATE            = V_STD_BUDEN_RATE                                         /* �л��δ���� */
                                 , BREU_BUDEN_RATE           = V_BREU_BUDEN_RATE                                        /* ����δ���� */
                                 , ENTR_AMT                  = V_STD_ENTR_AMT                                           /* ���б� */
                                 , LSN_AMT                   = V_STD_LSN_AMT                                            /* ������ */
                                 , REG_TT_AMT                = (V_STD_REG_RESV_FG_AMT+V_STD_ENTR_AMT+V_STD_LSN_AMT)     /* ����ѱݾ� */
                                 , BREU_ENTR_AMT             = V_BREU_ENTR_AMT                                          /* ������б� */
                                 , BREU_LSN_AMT              = V_BREU_LSN_AMT                                           /* ��������� */
                                 , BREU_REG_TT_AMT           = (V_BREU_ENTR_AMT+V_BREU_LSN_AMT)                         /* �������ѱݾ� */
                                 , SCAL_ENTR_AMT             = V_SCAL_ENTR_AMT                                          /* �������б� */
                                 , SCAL_LSN_AMT              = V_SCAL_LSN_AMT                                           /* ���м����� */
                                 , SCAL_TT_AMT               = nvl(V_SCAL_TT_AMT,0)                                     /* �����ѱݾ� */
                                 , STDUNI_AMT                = V_ENRO100_STDUNI_AMT                                     /* �л�ȸ��*/
                                 , TEACHM_AMT                = (CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                                                     ELSE NVL(V_TEACHM_AMT, 0)
                                                                END )                                                       /* ����� */
                                 , RECIV_REG_RESV_AMT        = 0                                                            /* ��ġ��*/
                                 , RECIV_LSN_AMT            = nvl(LIST_DATA.RECIV_REG_RESV_AMT,0) +nvl(RECIV_LSN_AMT,0)     /* ������*/

                                 /* 2019-01-29 �ڿ��� ���Ի���ϱݰ����� ��ġ�� ó������ ���� */
                                 , RECIV_TT_AMT              = ( CASE WHEN ( ( RECIV_TT_AMT != LIST_DATA.RECIV_REG_RESV_AMT ) AND ( RECIV_TT_AMT != LIST_DATA.REG_RESV_AMT ) ) THEN LIST_DATA.RECIV_REG_RESV_AMT
                                                                      ELSE RECIV_TT_AMT END )                           /* �����ѱݾ�*/

                                 , MOD_ID                    = IN_ID                                                    /* ����ID */
                                 , MOD_IP                    = IN_IP                                                    /* ����IP */
                                 , MOD_DTTM                  = SYSDATE                                                  /* �����Ͻ� */
                             WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                               /* �����������ȣ */
                             RETURNING ROWID INTO
                             V_ROWID
                             ;

                        ELSIF IN_TRET_FG = 'R' THEN  /* ó������ 'C'='����ڻ���/����', 'U'='��ġ�ݹݿ�����', 'R'='��ϱ������' */

                             /* 2015.12.07   �Ǽ���   ENRO410 UPDATE ��, EDAMT_SUPP_BREU_CD(��������������ڵ�), STD_BUDEN_RATE(�л��δ����), BREU_BUDEN_RATE(����δ����)�� ������Ʈ �ǵ��� ����. */
                             UPDATE ENRO410                                                                           /* ���Ի���ϴ���ڳ��� */
                               SET
                                   CNTR_SUST_YN              = (CASE WHEN  LIST_DATA.SELECT_DEPT_CD != '00000' THEN 'Y'
                                                                     ELSE 'N'
                                                                END )                                                   /* ����а����� */
                                 , EDAMT_SUPP_BREU_CD        = LIST_DATA.EDAMT_SUPP_BREU_CD                             /* ��������������ڵ� */
                                 , STD_BUDEN_RATE            = V_STD_BUDEN_RATE                                         /* �л��δ���� */
                                 , BREU_BUDEN_RATE           = V_BREU_BUDEN_RATE                                        /* ����δ���� */
                                 , ENTR_AMT                  = V_STD_ENTR_AMT                                           /* ���б� */
                                 , LSN_AMT                   = V_STD_LSN_AMT                                            /* ������ */
                                 , REG_TT_AMT                = (V_STD_REG_RESV_FG_AMT+V_STD_ENTR_AMT+V_STD_LSN_AMT)     /* ����ѱݾ� */
                                 , BREU_ENTR_AMT             = V_BREU_ENTR_AMT                                          /* ������б� */
                                 , BREU_LSN_AMT              = V_BREU_LSN_AMT                                           /* ��������� */
                                 , BREU_REG_TT_AMT           = (V_BREU_ENTR_AMT+V_BREU_LSN_AMT)                         /* �������ѱݾ� */
                                 , SCAL_ENTR_AMT             = V_SCAL_ENTR_AMT                                          /* �������б� */
                                 , SCAL_LSN_AMT              = V_SCAL_LSN_AMT                                           /* ���м����� */
                                 , SCAL_TT_AMT               = nvl(V_SCAL_TT_AMT,0)                                     /* �����ѱݾ� */
                                 , STDUNI_AMT                = V_ENRO100_STDUNI_AMT                                     /* �л�ȸ��*/
                                 , TEACHM_AMT                = (CASE WHEN LIST_DATA.SHYR != '1' THEN 0
                                                                     ELSE NVL(V_TEACHM_AMT, 0)
                                                                END )                                                   /* ����� */
                                 , GV_ST_FG                  = V_GV_ST_FG                                               /* ���Ի��±���*/
                                 , AUTO_REG_FG               = V_AUTO_REG_FG                                            /* �ڵ���ϱ���*/
                                 , RECIV_DT                  = V_PAID_TO_DT                                             /* ��������*/
                                 , MOD_ID                    = IN_ID                                                    /* ����ID */
                                 , MOD_IP                    = IN_IP                                                    /* ����IP */
                                 , MOD_DTTM                  = SYSDATE                                                  /* �����Ͻ� */
                             WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO                               /* �����������ȣ */
                             RETURNING ROWID INTO  V_ROWID
                             ;

                        END IF;

                          SP_LOG_CREA(IN_FUNC_NM => V_PGM_ID
                                    ,IN_ID => IN_ID
                                    ,IN_IP => IN_IP
                                    ,IN_CHG_FG => 'C015200002'
                                    ,IN_OWNER => 'SNU'
                                    ,IN_TABLE_ID => 'ENRO410'
                                    ,IN_ROWID => V_ROWID
                                    ,OUT_CODE => V_OUT_CODE
                                    ,OUT_MSG => V_OUT_MSG);

                        IF  V_OUT_CODE <> '0' THEN
                          SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' , SQLCODE, SQLERRM, IN_ID, IN_IP);
                          OUT_NUM := V_OUT_CODE;
                          OUT_MSG :='���Ի� ��� ����� ������ ���� �Ͽ����ϴ�.[�����̷� ���� ����]';
                          RETURN;
                        END IF;

                        IF LIST_DATA.TUIT_EXMP_YN ='N' THEN /* ��ϱݿ��� */

                            /*  ���б��� �ִ� ��� */
                            IF LIST_DATA.SCAL_CD is not null THEN

                                SELECT COUNT(*)
                                  INTO V_SCAL_CNT
                                  FROM SCHO530
                                 WHERE EXAM_STD_MNGT_NO = LIST_DATA.EXAM_STD_MNGT_NO
                                   AND SCAL_CD = LIST_DATA.SCAL_CD;

                                IF V_SCAL_CNT < 1 THEN
                                    INSERT INTO SCHO530                                           /* ���Ի����м��߳��� */
                                         (  EXAM_STD_MNGT_NO                                  /* �����������ȣ */
                                          , SCAL_CD                                           /* �����ڵ� */
                                          , SLT_DT                                            /* �������� */
                                          , ENTR_AMT                                          /* ���б� */
                                          , LSN_AMT                                           /* ������ */
                                          , SSO_AMT                                           /* �⼺ȸ�� */
                                          , LIF_AMT                                           /* ��Ȱ�� */
                                          , STUDY_ENC_AMT                                     /* �о������ */
                                          , TEACHM_AMT                                        /* ����� */
                                          , ETC_SCAL_AMT                                      /* ��Ÿ���б� */
                                          , SCAL_TT_AMT                                       /* �����ѱݾ� */
                                          , SUBST_DED_NO                                      /* ��ü������ȣ */
                                          , SCAL_SLT_PROG_ST_FG                               /* ���м���������±��� */
                                          , ACCPR_PERS_NO                                     /* �����ڰ��ι�ȣ */
                                          , ACCP_DT                                           /* �������� */
                                          , SCAL_SLT_NO                                       /* ���м��߹�ȣ */
                                          , REMK                                              /* ��� */
                                          , INPT_ID                                           /* �Է�ID */
                                          , INPT_IP                                           /* �Է�IP */
                                          , INPT_DTTM                                         /* �Է��Ͻ� */
                                          , MOD_ID                                            /* ����ID */
                                          , MOD_IP                                            /* ����IP */
                                          , MOD_DTTM                                          /* �����Ͻ� */
                                         )
                                         VALUES
                                         (  LIST_DATA.EXAM_STD_MNGT_NO                              /* �����������ȣ */
                                          , LIST_DATA.SCAL_CD                                       /* �����ڵ� */
                                          , TO_CHAR(SYSDATE,'YYYYMMDD')                             /* �������� */
                                          , NVL(V_SCAL_ENTR_AMT,0)                                  /* �������б� */
                                          , NVL(V_SCAL_LSN_AMT,0)                                   /* ���м����� */
                                          , 0                                                       /* �⼺ȸ�� */
                                          , 0                                                       /* ��Ȱ�� */
                                          , 0                                                       /* �о������ */
                                          , nvl(V_TEACHM_AMT,0)                                     /* ����� */
                                          , 0                                                       /* ��Ÿ���б� */
                                          , nvl(V_SCAL_TT_AMT,0)                                    /* �����ѱݾ� */
                                          , ''                                                      /* ��ü������ȣ */
                                          , 'U073300004'                                            /* ���м���������±��� Ȯ��ó�� */
                                          , IN_ID                                                   /* �����ڰ��ι�ȣ */
                                          , ''                                                      /* �������� */
                                          , ''                                                      /* ���м��߹�ȣ */
                                          , ''                                                      /* ��� */
                                          , IN_ID                                                   /* �Է�ID */
                                          , IN_IP                                                   /* �Է�IP */
                                          , SYSDATE                                                 /* �Է��Ͻ� */
                                          , IN_ID                                                   /* �Է�ID */
                                          , IN_IP                                                   /* �Է�IP */
                                          , SYSDATE                                                 /* �Է��Ͻ� */
                                         ) ;
                                ELSE

                                    UPDATE scho530                    /* ���Ի����м��߳��� */
                                       SET SLT_DT                    = TO_CHAR(SYSDATE,'YYYYMMDD')          /* �������� */
                                         , ENTR_AMT                  = NVL(V_SCAL_ENTR_AMT,0)               /* �������б� */
                                         , LSN_AMT                   = NVL(V_SCAL_LSN_AMT,0)                /* ���м����� */
                                         , SSO_AMT                   = 0                                    /* �⼺ȸ�� */
                                         , LIF_AMT                   = 0                                    /* ��Ȱ�� */
                                         , STUDY_ENC_AMT             = 0                                    /* �о������ */
                                         , TEACHM_AMT                = nvl(V_TEACHM_AMT,0)                  /* ����� */
                                         , ETC_SCAL_AMT              = 0                                    /* ��Ÿ���б� */
                                         , SCAL_TT_AMT               = nvl(V_SCAL_TT_AMT,0)                 /* �����ѱݾ� */
                                         , SUBST_DED_NO              = ''                                   /* ��ü������ȣ */
                                         , SCAL_SLT_PROG_ST_FG       = 'U073300004'                         /* ���м���������±��� */
                                         , ACCPR_PERS_NO             = IN_ID                                /* �����ڰ��ι�ȣ */
                                         , MOD_ID                    = IN_ID                                /* ����ID */
                                         , MOD_IP                    = IN_IP                                /* ����IP */
                                         , MOD_DTTM                  = SYSDATE                              /* �����Ͻ� */
                                     WHERE EXAM_STD_MNGT_NO          = LIST_DATA.EXAM_STD_MNGT_NO           /* �����������ȣ */
                                       AND SCAL_CD                   = LIST_DATA.SCAL_CD                    /* �����ڵ� */
                                     ;

                                END IF;

                            END IF;

                        END IF;

                        OUT_TRET_CNT := OUT_TRET_CNT+1;

                         V_MSG :='---------------3--IN_ENTR_SCHYY['||IN_ENTR_SCHYY
                              ||'] IN_ENTR_SHTM_FG['||IN_ENTR_SHTM_FG||']'
                              ||'] IN_SELECT_FG['||IN_SELECT_FG||']'
                              ||'] IN_PASS_SEQ['||IN_PASS_SEQ||']'
                              ||'] IN_TRET_FG['||IN_TRET_FG||']'
                              ||'] IN_REG_RESV_FG['||IN_REG_RESV_FG||']';

                    END LOOP;


        END IF;

    END IF;


    OUT_NUM := 0;
    OUT_MSG :='���� ó�� �Ǿ����ϴ�.'||V_MSG;

EXCEPTION
    WHEN OTHERS THEN
    SP_SSTM056_CREA(V_PGM_ID, '�����г⵵(' || IN_ENTR_SCHYY || ') �����бⱸ��('||IN_ENTR_SHTM_FG||') ��������('||IN_SELECT_FG||') �հ�����('||IN_PASS_SEQ||')' ||V_MSG, SQLCODE, SQLERRM, IN_ID, IN_IP);
    OUT_NUM := SQLCODE;
    OUT_MSG :='���Ի� ��� ����� ������ ���� �Ͽ����ϴ�.['||V_MSG||']';
    RETURN;
END SP_ENRO410_CREA;
/
