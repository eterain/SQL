
/* DORM300.find01 기숙사(방배정 및 사상현황 방배정내역)목록 조회 */

SELECT T1.DORM_JOIN_PSN_NO /* 기숙사입사자번호(PK1) */,
       T1.DORM_FG /* 기숙사구분(PK4) */,
       T1.SCHYY /* 학년도(PK2) */,
       T1.SHTM_FG /* 학기구분(PK3) */,
       T1.DETA_SHTM_FG,
       (SELECT DEPT_KOR_NM FROM BSNS100 WHERE DEPT_CD = T1.THTM_COLG_CD) AS THTM_COLG_NM,
       (SELECT DEPT_KOR_NM FROM BSNS100 WHERE DEPT_CD = T1.THTM_SUST_CD) AS THTM_SUST_NM,
       T1.THTM_SHYR,
       (SELECT MAX(TA1.HANDP_NO) AS HANDP_NO
          FROM DORM205 TA1
         WHERE TA1.DORM_FG = 'F010900001'
           AND TA1.SCHYY = T1.SCHYY
           AND TA1.SHTM_FG = T1.SHTM_FG
           AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG
           AND TA1.DORM_JOIN_PSN_NO = T1.DORM_JOIN_PSN_NO
           AND TA1.FM_REL_FG = 'A016900003') AS FA_HAND_TELNO,
       (SELECT MAX(TA1.HANDP_NO) AS HANDP_NO
          FROM DORM205 TA1
         WHERE TA1.DORM_FG = 'F010900001'
           AND TA1.SCHYY = T1.SCHYY
           AND TA1.SHTM_FG = T1.SHTM_FG
           AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG
           AND TA1.DORM_JOIN_PSN_NO = T1.DORM_JOIN_PSN_NO
           AND TA1.FM_REL_FG = 'A016900004') AS MO_HAND_TELNO,
       T1.FOREIGNER_YN,
       T1.HANDICAP_YN,
       T1.GEN_FG,
       (SELECT KOR_NM FROM BSNS011 WHERE CMMN_CD = T1.GEN_FG) AS GEN_FG_NM,
       T1.SLEEP_TM_MNIGHT_BF_YN /* 취침시간자정이전여부 */,
       T2.DORM_ROOM_CD /* 기숙사호실코드(PK5) */,
       T2.DORM_ROOM_CD AS PRE_DORM_ROOM_CD /* 기숙사호실코드(PK5) */,
       T2.DORM_JOIN_ST_FG /* 기숙사입사상태구분 */,
       T2.JOIN_FR_DT /* 입사시작일자 */,
       T2.JOIN_TO_DT /* 입사종료일자 */,
       T2.TMP_LEAVDORM_APLY_DT /* 임시퇴사신청일자 */,
       T1.SINGLE_SHTM_APLY_YN,
       T2.LEAVDORM_EXPC_DT,
       T2.REMK /* 비고 */,
       T2.INPT_ID /* 입력ID */,
       T2.INPT_IP /* 입력IP */,
       TO_CHAR(T2.INPT_DTTM, 'YYYYMMDD HH24:MI:SS') AS INPT_DTTM /* 입력일시 */,
       T2.MOD_ID /* 수정ID */,
       T2.MOD_IP /* 수정IP */,
       TO_CHAR(T2.MOD_DTTM, 'YYYYMMDD HH24:MI:SS') AS MOD_DTTM /* 수정일시 */,
       NVL(T3.PERS_KOR_NM, T0.STD_KOR_NM) AS KOR_NM,
       NVL(T3.HANDP_NO, T0.HANDP_NO) AS HAND_TELNO,
       NVL(T3.EMAIL, T0.EMAIL) AS EMAIL,
       T4.DORM_ROOM_NM,
       T4.DORM_ROOM_SEAT_FG,
       (SELECT KOR_NM FROM BSNS011 WHERE CMMN_CD = T4.DORM_ROOM_SEAT_FG) AS DORM_ROOM_SEAT_FG_NM,
       T4.DORM_ROOM_RMM_FG,
       (SELECT KOR_NM FROM BSNS011 WHERE CMMN_CD = T4.DORM_ROOM_RMM_FG) AS DORM_ROOM_RMM_FG_NM,
       T5.DORM_DONG_CD,
       T5.DORM_DONG_NM,
       T2.DORM_JOIN_ST_FG /*입사상태구분*/,
       (SELECT KOR_NM FROM BSNS011 WHERE CMMN_CD = T2.DORM_JOIN_ST_FG) AS DORM_JOIN_ST_FG_NM /* 입사상태구분명 */,
       T1.DORM_JOIN_STD_FG /* 입사생구분 */,
       (SELECT KOR_NM FROM BSNS011 WHERE CMMN_CD = T1.DORM_JOIN_STD_FG) AS DORM_JOIN_STD_FG_NM /* 기숙사입사생구분명 */,
       DECODE((SELECT COUNT(*)
                FROM DORM320 TA1
               WHERE TA1.DORM_JOIN_PSN_NO = T1.DORM_JOIN_PSN_NO
                 AND TA1.DORM_FG = T1.DORM_FG
                 AND TA1.SCHYY = T1.SCHYY
                 AND TA1.SHTM_FG = T1.SHTM_FG
                 AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG
                 AND TA1.CMS_APLY_FG_CD = '1'
                 AND NOT EXISTS (SELECT '1'
                        FROM DORM320 TA2
                       WHERE TA1.DORM_JOIN_PSN_NO = TA2.DORM_JOIN_PSN_NO
                         AND TA1.DORM_FG = TA2.DORM_FG
                         AND TA1.SCHYY = TA2.SCHYY
                         AND TA1.SHTM_FG = TA2.SHTM_FG
                         AND TA1.DETA_SHTM_FG = TA2.DETA_SHTM_FG
                         AND TA1.BACCT_NO = TA2.BACCT_NO
                         AND TA1.CMS_APLY_FG_CD = '3'
                         AND TA2.APLY_DT > TA1.APLY_DT)),
              0,
              'N',
              'Y') AS CMS_APLY_YN,
       (SELECT COUNT(*)
          FROM DORM315 TA1
         WHERE TA1.DORM_JOIN_PSN_NO = T1.DORM_JOIN_PSN_NO
           AND TA1.DORM_FG = T1.DORM_FG
           AND TA1.SCHYY = T1.SCHYY
           AND TA1.SHTM_FG = T1.SHTM_FG
           AND TA1.DETA_SHTM_FG = T1.DETA_SHTM_FG) AS CNT,
       T3.BIRTH_DT
  FROM DORM200 T1,
       DORM300 T2,
       BSNS031 T3,
       ENRO400 T0,
       DORM115 T4,
       DORM110 T5
 WHERE T1.DORM_JOIN_PSN_NO = T2.DORM_JOIN_PSN_NO(+)
   AND T1.DORM_FG = T2.DORM_FG(+)
   AND T1.SCHYY = T2.SCHYY(+)
   AND T1.SHTM_FG = T2.SHTM_FG(+)
   AND T1.DETA_SHTM_FG = T2.DETA_SHTM_FG(+)
   AND T1.DORM_JOIN_PSN_NO = T3.PERS_NO(+)
   AND T1.DORM_JOIN_PSN_NO = T0.STUNO(+)
   AND T1.SCHYY = T0.ENTR_SCHYY(+)
   AND T1.SHTM_FG = T0.ENTR_SHTM_FG(+)
   AND T2.DORM_ROOM_CD = T4.DORM_ROOM_CD(+)
   AND T4.DORM_DONG_CD = T5.DORM_DONG_CD(+)
   AND T1.DORM_APLY_ST_FG IN ('F010300004', 'F010300005')
   AND T1.DORM_FG = 'F010900001'
   AND T1.SCHYY = '2020'
   AND T1.SHTM_FG = 'U000200002'
   AND T1.DETA_SHTM_FG = 'U000300001'
   AND T2.DORM_JOIN_ST_FG IN ('F010200003')
   AND T1.DOC_SUBM_YN = 'Y' /*2020-08-31 관악사의 경우 대학원생/학부생 이면서 학기이관일경우에는 가상계좌수납여부를 체크하지 않음 */
   AND 1 = (CASE
           WHEN (T1.DORM_JOIN_STD_FG = 'F010100002' OR T1.DORM_JOIN_STD_FG = 'F010100003' OR T1.DORM_JOIN_STD_FG = 'F010100001' OR /* 학부생 */
                T1.DORM_JOIN_STD_FG = 'F010100004' /* 학부신입생 */
                ) AND T1.SHTM_TRANS_YN = 'Y' THEN
            1
           WHEN (SELECT 1
                   FROM DORM315 S1
                  WHERE S1.DORM_FG = T1.DORM_FG
                    AND S1.SCHYY = T1.SCHYY
                    AND S1.SHTM_FG = T1.SHTM_FG
                    AND S1.DETA_SHTM_FG = T1.DETA_SHTM_FG
                    AND S1.DORM_JOIN_PSN_NO = T1.DORM_JOIN_PSN_NO
                    AND S1.RECIV_DT IS NOT NULL
                    AND ROWNUM = 1) = 1 THEN
            1
           ELSE
            0
       END) /*2015-08-26 관악사 아닌경우 대학원생 이면서 학기이관일경우에는 가상계좌수납여부를 체크하지 않음 */
   AND T5.DORM_DONG_CD IN ('GD002',
                           'GD003',
                           'GD004',
                           'GD005',
                           'GD006',
                           'GD007',
                           'GD008',
                           'GD013',
                           'GD014',
                           'GD015',
                           'GD016',
                           'GD017',
                           'GD018',
                           'GD019',
                           'GD020',
                           'GD021',
                           'GD022',
                           'GD023',
                           'GD024',
                           'GD025',
                           'GD026')
   AND T1.DORM_JOIN_STD_FG IN ('F010100001', 'F010100002', 'F010100003', 'F010100004', 'F010100005') /* 입사생구분 */
 ORDER BY THTM_COLG_NM,
          THTM_SUST_NM,
          KOR_NM
