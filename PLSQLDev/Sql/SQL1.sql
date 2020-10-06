

SELECT CMMN_CD, KOR_NM, A.*
FROM BSNS011 A
WHERE A.GRP_CD = 'U0498'
ORDER BY A.DISP_ORD, A.CMMN_CD
;

SELECT * FROM cour622 ;


SELECT *
FROM COUR623 TA1
WHERE TA1.MNGT_DEPT_CD = '116' ;

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
         SF_HURT200_PERS_INFO('1', T1.RESP_PROF_PERS_NO) AS RESP_PROF_KOR_NM,
         T1.RESP_PROF_WKPO_NM /* 담당교수직위 */,
         T1.RESP_PROF_POSI_NM /* 담당교수소속 */,
         T1.CHIEF_PERS_NO /* 기관장개인번호 */,
         SF_HURT200_PERS_INFO('1', T1.CHIEF_PERS_NO) AS CHIEF_KOR_NM,
         T1.CHIEF_WKPO_NM /* 기관장직위 */,
         T1.CHIEF_POSI_NM /* 기관장소속 */,
         T5.OPEN_UP_SBJT_FLD_CD AS SBJT_FLD_CD /* 교양영역 */,
         (SELECT SBJT_FLD_NM FROM COUR018 WHERE SBJT_FLD_CD = T5.OPEN_UP_SBJT_FLD_CD) AS SBJT_FLD_NM /* 교양영역명 */,
         T4.SBJT_NM /* 교과목명 */,
         T1.SBJT_NO /* 교과목번호 */,
         T1.LT_NO /* 강좌번호 */,
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
         COUR100   T4,
         COUR203   T5
   WHERE T1.MNGT_DEPT_CD = T2.DEPT_CD
     AND T1.STUNO = T3.STUNO
     AND T1.SBJT_NO = T4.SBJT_CD(+)
     AND T1.OPEN_SCHYY = T5.OPEN_SCHYY(+)
     AND T1.OPEN_SHTM_FG = T5.OPEN_SHTM_FG(+)
     AND T1.OPEN_DETA_SHTM_FG = T5.OPEN_DETA_SHTM_FG(+)
     AND T1.SBJT_NO = T5.SBJT_CD(+)
     AND T1.LT_NO = T5.LT_NO(+)
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
             AND TA1.DEPT_CD = T1.MNGT_DEPT_CD
             ) /* 대학(원) */
     AND T1.MNGT_DEPT_CD = '116' /* 학과(부) */
