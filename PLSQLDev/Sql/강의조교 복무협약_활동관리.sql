HURT250 ;

SELECT * FROM cour221 ;         -- 개설강좌강의조교내역

SELECT * FROM cour620 ;         -- 기본정보
SELECT * FROM cour622 ;         -- 배정내역
SELECT * FROM cour623 ;         -- 추천내역

SELECT * FROM cour625 ;         -- 복무협약
SELECT * FROM cour624 ;         -- 활동계획/보고   
SELECT * FROM cour625 ;         -- 복무협약

SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0497'
ORDER BY A.DISP_ORD, A.CMMN_CD
;


   /* COUR623.find ??  강의조교복무협약, 활동관리 목록 조회 */   
   SELECT --T1.LT_ASSIST_ST_FG,                                                     /* 강의조교상태구분 */
          SF_BSNS011_CODENM(T1.LT_ASSIST_ST_FG, 1) AS LT_ASSIST_ST_FG_KOR_NM,
          T1.OPEN_SCHYY, /* 개설학년도(PK1) */
          SF_BSNS011_CODENM(T1.OPEN_SHTM_FG, 1) AS OPEN_SHTM_FG_KOR_NM, /* 개설학기구분(PK2) */
          SF_BSNS011_CODENM(T1.OPEN_DETA_SHTM_FG, 1) AS OPEN_DETA_SHTM_FG_KOR_NM,  /* 개설세부학기구분(PK3) */
          --T1.MNGT_DEPT_CD, /* 관리부서코드(PK4) */
          T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM, /* 관리부서명 */
          T1.MNGT_DEPT_CD,
          T1.STUNO, /* 학번(PK5) */
          --T1.LT_ASSIST_INPT_SEQ, /* 강의조교입력순번(PK6) */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM, /* 성명 */
          T3.UNIVS_KOR_NM, /* 대학(원) */
          T3.DEPARTMENT_KOR_NM, /* 학과(부) */
          SF_BSNS011_CODENM(T1.LT_ASSIST_TYPE_FG, 1) AS LT_ASSIST_TYPE_FG_KOR_NM,  /* 강의조교유형구분 */
          
          T4.SBJT_NM, /* 교과목명 */
          T1.SBJT_CD, /* 교과목번호 */
          T1.LT_NO, /* 강좌번호 */
          (SELECT SF_COUR208_PERS_NM('01', '01', T1.OPEN_SCHYY, T1.OPEN_SHTM_FG, T1.OPEN_DETA_SHTM_FG, T1.SBJT_CD, T1.LT_NO) FROM DUAL) AS LT_PROF_KOR_NM, /* 강좌담당교수 */
          
          --T1.RESP_PROF_PERS_NO, /* 담당교수개인번호 */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM, /* 담당교수성명 */
          
          T1.INPT_ID, /* 입력ID */
          T1.INPT_IP, /* 입력IP */
          TO_CHAR(T1.INPT_DTTM, 'YYYYMMDD HH24:MI:SS') AS INPT_DTTM, /* 입력일시 */
          T1.MOD_ID, /* 수정ID */
          T1.MOD_IP, /* 수정IP */
          TO_CHAR(T1.MOD_DTTM, 'YYYYMMDD HH24:MI:SS') AS MOD_DTTM /* 수정일시 */
     FROM COUR623   T1,
          BSNS100   T2,
          V_SREG101 T3,
          COUR100   T4
    WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
      AND T1.STUNO = T3.STUNO
      AND T1.SBJT_CD = T4.SBJT_CD (+)
      AND T1.OPEN_SCHYY = '2020' 
      /*
      AND T1.LT_ASSIST_ST_FG IN ( 'U049700002','U049700003' )
      AND EXISTS (SELECT 1
             FROM COUR622 TA1
            WHERE TA1.OPEN_SCHYY = T1.OPEN_SCHYY
              AND TA1.OPEN_SHTM_FG = T1.OPEN_SHTM_FG
              AND TA1.OPEN_DETA_SHTM_FG = T1.OPEN_DETA_SHTM_FG
              AND TA1.ASGN_FG = 'U049500001' 
              AND TA1.ASGN_BREU_FG = '0107'
              AND TA1.DEPT_CD = T1.MNGT_DEPT_CD) 
     */
   ;


   SELECT  '(이하 “갑”)과(와) 대학원생 강의조교' || '(이하 “을”)은(는) 다음과 같이' AS info01,
          NVL(SUBSTR(T1.ACT_FR_DT,1,4),'0000') || '년 ' || NVL(SUBSTR(T1.ACT_FR_DT,5,2),'00') || '월 ' || NVL(SUBSTR(T1.ACT_FR_DT,7,2),'00') || '일부터 ' || 
          NVL(SUBSTR(T1.ACT_TO_DT,1,4),'0000') || '년 ' || NVL(SUBSTR(T1.ACT_FR_TO,5,2),'00') || '월 ' || NVL(SUBSTR(T1.ACT_TO_DT,7,2),'00') || '일까지 ' AS info02,

          --T1.MNGT_DEPT_CD, /* 관리부서코드(PK4) */
          T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM, /* 관리부서명 */
          
          T1.STUNO, /* 학번(PK5) */
          --T1.LT_ASSIST_INPT_SEQ, /* 강의조교입력순번(PK6) */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM, /* 성명 */
          T3.UNIVS_KOR_NM, /* 대학(원) */
          T3.DEPARTMENT_KOR_NM, /* 학과(부) */

          
          (SELECT SF_COUR208_PERS_NM('01', '01', T1.OPEN_SCHYY, T1.OPEN_SHTM_FG, T1.OPEN_DETA_SHTM_FG, T1.SBJT_CD, T1.LT_NO) FROM DUAL) AS info12
          
          --T1.RESP_PROF_PERS_NO, /* 담당교수개인번호 */
          (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM /* 담당교수성명 */
          
     FROM COUR623   T1,
          BSNS100   T2,
          V_SREG101 T3,
          COUR100   T4
    WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
      AND T1.STUNO = T3.STUNO
      AND T1.SBJT_CD = T4.SBJT_CD (+)
      AND T1.OPEN_SCHYY = '2020' 
      /*
      AND T1.LT_ASSIST_ST_FG IN ( 'U049700002','U049700003' )
      AND EXISTS (SELECT 1
             FROM COUR622 TA1
            WHERE TA1.OPEN_SCHYY = T1.OPEN_SCHYY
              AND TA1.OPEN_SHTM_FG = T1.OPEN_SHTM_FG
              AND TA1.OPEN_DETA_SHTM_FG = T1.OPEN_DETA_SHTM_FG
              AND TA1.ASGN_FG = 'U049500001' 
              AND TA1.ASGN_BREU_FG = '0107'
              AND TA1.DEPT_CD = T1.MNGT_DEPT_CD) 
     */
   ;




     /* COUR623.find01 강의조교추천관리 목록 조회 */
     SELECT T1.OPEN_SCHYY /* 개설학년도(PK1) */,
            T1.OPEN_SHTM_FG /* 개설학기구분(PK2) */,
            T1.OPEN_DETA_SHTM_FG /* 개설세부학기구분(PK3) */,
            T1.MNGT_DEPT_CD /* 관리부서코드(PK4) */,
            T2.DEPT_KOR_NM AS MNGT_DEPT_KOR_NM /* 관리부서명 */,
            T1.STUNO /* 학번(PK5) */,
            T1.LT_ASSIST_INPT_SEQ /* 강의조교입력순번(PK6) */,
            (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T3.RPST_PERS_NO) AS KOR_NM /* 성명 */,
            T3.UNIVS_KOR_NM /* 대학(원) */,
            T3.DEPARTMENT_KOR_NM /* 학과(부) */,
            (SELECT SF_BSNS011_CODENM(T3.PROG_CORS_FG) FROM DUAL) AS PROG_CORS_FG_NM /* 진행과정 */,
            (SELECT SF_BSNS011_CODENM(T3.SCHREG_FG) FROM DUAL) AS SCHREG_FG_NM /* 학적상태 */,
            DECODE(T3.STD_FG, 'U030500002', '연구생') AS RECHER_YN /* 연구생여부 */,
            T1.LT_ASSIST_TYPE_FG /* 강의조교유형구분 */,
            T1.REAL_ACT_FR_DT /* 활동시작일자 */,
            T1.REAL_ACT_TO_DT /* 활동종료일자 */,
            T1.LT_ASSIST_LBCOST_DCNT /* 강의조교인건비일수 */,
            T1.RESP_PROF_PERS_NO /* 담당교수개인번호 */,
            (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM /* 담당교수성명 */,
            T1.RESP_PROF_WKPO_NM /* 담당교수직위 */,
            T1.RESP_PROF_POSI_NM /* 담당교수소속 */,
            T1.CHIEF_PERS_NO /* 기관장개인번호 */,
            (SELECT TA.KOR_NM FROM HURT200 TA WHERE TA.RPST_PERS_NO = T1.CHIEF_PERS_NO) AS CHIEF_KOR_NM /* 기관장성명 */,
            T1.CHIEF_WKPO_NM /* 기관장직위 */,
            T1.CHIEF_POSI_NM /* 기관장소속 */,
            T4.SBJT_FLD_CD /* 교양영역 */,
            (SELECT SBJT_FLD_NM FROM COUR018 WHERE SBJT_FLD_CD = T4.SBJT_FLD_CD) AS SBJT_FLD_NM /* 교양영역명 */,
            T4.SBJT_NM /* 교과목명 */,
            T1.SBJT_NO /* 교과목번호 */,
            T1.LT_NO /* 강좌번호 */ /*               ,(SELECT SF_COUR208_PERS_NM('01'                                          ,'01'                                          ,T1.OPEN_SCHYY                                          ,T1.OPEN_SHTM_FG                                          ,T1.OPEN_DETA_SHTM_FG                                          ,T1.SBJT_NO                                          ,T1.LT_NO                                          )                   FROM DUAL                ) AS LT_PROF_KOR_NM                                                        /* 강좌담당교수 */ * /,
            T1.LT_ASSIST_ST_FG /* 강의조교상태구분 */,
            T1.REMK /* 비고 */,
            T1.INPT_ID /* 입력ID */,
            T1.INPT_IP /* 입력IP */,
            TO_CHAR(T1.INPT_DTTM, 'YYYYMMDD HH24:MI:SS') AS INPT_DTTM /* 입력일시 */,
            T1.MOD_ID /* 수정ID */,
            T1.MOD_IP /* 수정IP */,
            TO_CHAR(T1.MOD_DTTM, 'YYYYMMDD HH24:MI:SS') AS MOD_DTTM /* 수정일시 */
       FROM COUR623   T1,
            BSNS100   T2,
            V_SREG101 T3,
            COUR100   T4
      WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
        AND T1.STUNO = T3.STUNO
        AND T1.SBJT_NO = T4.SBJT_CD(+)
        AND T1.OPEN_SCHYY = '2020' /* 개설학년도(PK1) */
        AND T1.OPEN_SHTM_FG = 'U000200001' /* 개설학기구분(PK2) */
        AND T1.OPEN_DETA_SHTM_FG = 'U000300001' /* 개설세부학기구분(PK3) */
        AND EXISTS (SELECT 1
               FROM COUR622 TA1
              WHERE TA1.OPEN_SCHYY = T1.OPEN_SCHYY
                AND TA1.OPEN_SHTM_FG = T1.OPEN_SHTM_FG
                AND TA1.OPEN_DETA_SHTM_FG = T1.OPEN_DETA_SHTM_FG
                AND TA1.ASGN_FG = 'U049500001' /* 기본배정 */
                AND TA1.ASGN_BREU_FG = '100'
                AND TA1.DEPT_CD = T1.MNGT_DEPT_CD) /* 대학(원) */
;
