CREATE OR REPLACE PROCEDURE SP_PAYM410B_TRET_2019_4
(
        IN_BIZR_DEPT_CD          IN   PAYM410.BIZR_DEPT_CD    %TYPE, --사업자부서코드
        IN_YY                    IN   PAYM410.YY              %TYPE, --정산년도
        IN_YRETXA_SEQ            IN   PAYM410.YRETXA_SEQ      %TYPE, --정산차수<2017년 추가됨 @VER.2017_0>
        IN_SETT_FG               IN   PAYM410.SETT_FG         %TYPE, --정산구분(A031300001:연말정산, A031300002:중도정산, A031300003:연말정산 시뮬레이션)
        IN_RPST_PERS_NO          IN   PAYM410.RPST_PERS_NO    %TYPE, --대표개인번호
        IN_INPT_ID               IN   PAYM410.INPT_ID         %TYPE,
        IN_INPT_IP               IN   PAYM410.INPT_IP         %TYPE,
        IN_DEPT_CD               IN   BSNS100.MNGT_DEPT_CD    %TYPE DEFAULT null, --_DY관리부서
        --  RETURN VALUE
        OUT_RTN                   OUT      INTEGER,
        OUT_MSG                   OUT      VARCHAR2
)
IS
/*******************************************************************************************************
 파일명              : SP_PAYM410B_TRET_2019 [2018년 연말정산 계산:SP_PAYM410B_TRET_2017 Copy해서 부분수정] 부분수정 키워드 :(@VER.2018)
 버전                : <<1.1.1.0>>
 최초 작성일         : <<2011.12.15>>
 최초 작성자         : 윤정화
 UseCase명           : <<연말정산>>
 내용                : <<연말정산 계산처리한다.-2014년 재계산>>
 수정 작성일         : <<2012.12.12>
 수정 작성자         : 윤정화
 수정내용            : 1. 90.특별공제주택임차원리금사인간상환액 공제액
                          91.특별공제월세액공제
                          총급여액 3천만원 -> 5천만원 으로 변경
                       2. 46.신용카드등소득공제
                          전통시장사용액 및 공제액 산출방법 변경
                       3. 38.기부금공제금액
                          기부금 유형별 공제 순서 변경
                       4. 45.투자조합출자등소득공제금액
                          벤처투자금액공제 20% 추가 및 공제한도 변경
                       5. 37-다.특별공제장기주택저당타입금 이자상환액 2012년 이후 고정금리(비거치식) 추가
                          37-다.특별공제장기주택저당타입금 이자상환액 2012년 이후 기타 추가ㅎ
                          44-가, 44-나, 44-다, 44-라 한도체크 변경
                       6. 외국인단일세율의 총급여액 계산 변경
                          4대보험료 회사부담금, 식대,유류비과세 추가

              2013년 수정사항.
                      1.한부모공제 추가          : 완료~~
                      2.월세액 인정비율(50%)변경 :완료~~
                      3.신용카드 비율변경        :완료~~
                           현금영수증 20% -> 30%
                           신용카드 20% -> 15%
                           학원비지로 납부액 폐지
                           대중교통 사용액 30% 추가
                      4.벤처투자금액 비율 30%로 상향 : 완료~~
                          2011년 이전 출자·투자액      출자·투자금액의 10%공제, 종합소득금액의 30%
                          2012년 출자·투자액           출자·투자금액의 10%공제, 종합소득금액의 40%
                          2013년 이후 출자·투자액      출자·투자금액의 10%공제, 종합소득금액의 40%  --추가
                          2012년 벤처기업 투자액       출자·투자금액의 20%공제, 종합소득금액의 40%
                          2013년 이후 벤처기업 투자액  출자·투자금액의 30%공제, 종합소득금액의 40%  --추가
                      5.장기주택마련저축 공제 종료(2012.12.31) . 삭제.  :완료~~
                      6.종합한도 적용제한. 2500만원.
                           보장성보험 + 의료비(장애인제외)+교육비(장애인제외)+주택자금+소기업소상공인공제+신용카드+투자조합출자+우리사주출연금
                           초과금액을 제외. 초과금액이 있고 기부금이 존재하는경우 공제우선순위 낮은것부터 이월처리 해줌.
                      7. 종근무지 감면처리 추가.   :완료~~
                      8. 목돈안드는 전세이자 상환액  :완료~~
                      9. 연금저축이 연금보험료로 위치 이동

            2014년 수정사항.

                    1. 추가공제-자녀양육비(6세이하)공제 세액공제로 전환
                    2. 추가공제-출산입양자공제 세액공제로 전환
                    3. 추가공제-부녀자공제시 소득금액 3천만원이하자에 한해 적용
                    4. 다자녀추가공제 세액공제로 전환 -> (2인이하자녀수 * 15만원) + 초과1인당 20만원
                    5. 연금저축 세액공제로 전환 -> MIN(연납입액, 400만원) * 0.12
                    6. 보장성보험료 세액공제로 전환 -> 일반 : MIN(연납입액, 100만원) * 0.12 + 장애인 : MIN(연납입액, 100만원) * 0.12
                    7. 의료비 세액공제로 전환 -> 기본공제대상자 중 본인, 65세이상, 장애인 의료비전액(공제대상 추가의료비가 - 이면 기본의료비에서 차감) * 0.15
                                               + 이외의 자를 위하여 지출한 의료비 : MIN(추가의료비 - 총급여액*0.03, 700만원) * 0.15
                    8. 교육비 세액공제로 전환 : (본인교육비 전액 + 대학생 1인당 900만원 + 초중고 1인당 300만원 + (장애인특수교육비 - 장애인국가지방단체지원비)) * 0.15
                    9. 월세소득공제 세액공제로 전환 : 총급여액 7천만원, 무주택세대원도 공제가능, 확정일자요건삭제,  MIN(연간월세지급액, 750만원) * 0.1
                    10. 주택소득공제
                      - 주택임차차입금에대한 원리금상환액 무주택세대원도 공제 가능
                      - 장기주택저당차입금 2014년 이후 차입분부터 주택규모 해당없음(2013년이전은 국민주택규모이하)
                      - 장기주택저당차입금 주택가격 2014년 이후 차입분부터 4억이하(2013년이전은 3억이하)
                      - 주택마련저축 중 정약저축, 주택청약종합저축은 2009년이전가입 청약저축을 제외하고 연중무주택이어야함
                      - 주택임차차입금, 월세액,  장기주택저당차입금(일반, 차입금이전, 전환 또는 만기연장, 신축주택, 주택양수도) 세대주->세대주+세대원 중복신청불가
                    11. 기부금 세액공제로 전환
                      - 정치자금 10만원이하 해당금액의 * 100/110, 10만원초과 금액 * 0.15
                      - 법정, 지정기부금 해당연도 지출한 기부금 소득금액의 100%~10% * 0.15
                        단, 정치자금 10만원초과 금액 + 법정, 지정기부금의 3000만원 초과분은 25%세액공제
                      - 법정, 지정기부금 2013년이전 이월기부금은 특별소득공제로 처리
                    12. 소기업소상공인공제기부금 불입한도 210만원-> 300만원으로 확대
                    13. 투자조합출자금 연말정산책자 633페이지 참조
                    14. 신용카드 : 체크카드등 소득공제율 확대 및 적용기간 연장
                      14년 하반기, 15년 상반기 체크카드, 현금영수증 본인사용액이 13년 사용분의 50%보다 증가한 금액의 40%
                    15. 장기집합투자증권저축소득공제 : 총급여 8천만원이하, 2015년 12월 31일이전 가입분
                      -> 자산총액40%이상을 국내주식에 투자하는 장기적립식펀드, 연간납입한도 600만원, 계약기간 10년이상
                      -> 공제금액 : 10년간 연납입액의 40%
                    16. 한도적용소득공제....
                    17. 중소기업취업자에대한소득세면제 : 종소득에 감면세액(소득세, 주민세) 입력하도록 수정
                    18. 표준세액공제 : 특별소득공제(건강보험료 등, 주태자금) 및 특별세액공제(보험료, 의료비, 교육비, 기부금(우리사주조합, 정치자금포함))를 신청하지 않는 경우 12만원
                    19. 농특세 : 661페이지

            2015년 수정사항.
                    1. 장기주택저당차입금이자 소득공제 확대 : 2015년 이후 차입분 4개 항목 (15년이상 고정금리 AND 비거치식, 고정금리OR비거치식, 기타, 10년이상 15년미만 고정금리OR비거치식)
                    2. 의료비 세액공제 : 한도미적용 대상 확대(난임시술비)
                    3. 소득공제 및 세액공제의 공제순서 변경 : 연금보험료공제, 경금계좌세액공제는 타 공제 보다 후순위로 공제
                    4. 세액공제대상 퇴직연금 납입한도 확대 : 연금계좌 세액공제 한도와는 별도로 퇴직연금에 납입하는 금액은 연300만원 추가 (통합 700만원, 단 연금저축은 400만원 기존 유지)
                    5. 중소기업 창업투자조합 출자 등에 대한 소득공제 확대 (적용기한 3년연장 (~'17.12.31까지)
                        개인투자조합 또는 벤처기업 직접투자 : 1500만원 이하 투자금액 기존 50% => 100% 인상
                                                              1500만원 초과 5000만원 이하분 : 50%
                                                              5000만원 초과분 : 30%
                    6. 주택청약종합저축 소득공제 확대
                       총급여 7000만원 이하 근로자인 무주택 세대주 (120만원 => 240만원)
                       * 기 가입자 (2014년이전 가입자) 중 총급여 7000만원 초과자에 대해서는 기존 한도(120만원)로 '17년 납입분까지 소득공제
                    7. 체크카드,현금영수증 사용액 증가분에 대한 소득공제율 확대
                       15년 하반기, 16년 상반기 체크카드,현금영수증,전통시장,대중교통 본인사용액이
                       14년 사용분의 50%보다 증가한 금액 : 50% (14년대비 15년 신용카드등 본인사용액 증가자에 한정)

            2016년 수정사항(@VER.2016_X)
                    1. 소기업,소상공인 공제부금 소득공제 [가입일 조건추가]
                       2015.12.31 이전 가입자의 해당연도의 공제부금 납부액
                       (2016.1.1 이후 가입자는 총급여액 7천만원 이하 조건)
                    2. 투자조합출자등 소득공제 [기간조건 변경]
                       (2014.1.1 ~ 2016.12.31 기강동안 출자(투자)분)
                    3. 기부금 한도 3000->2000 / 25->30%공제 (정치자금기부금은 3000,25%유지)
                    4. 부양가족 기부금 나이조건 삭제
                    5. 신용카드 로직 수정 (2016상반기)
                    6. 세액감면- 중소기업 취업자 (수정불필요)
                    7. 농어촌특별세 수정
                    8. 지정기부금 (종교,종교외) 대상금액,세액공제액 분리
                    9. 기부장려신청금 적용 (지정기부금)
                   10. 표준세액공제자 기부금 모두 이월처리
                   11. 기부금 자체직원 사업자부서 작년과 다를경우(사업자번호는 같지만) 예:Z007771 김효현 (2015년 연구처, 2016년 0055-연구윤리팀 : 사업자번호는 연구처와 동일)
                       작년 이월금액을 가져올수 없는 문제. (PAYM452 사업자정보관리 테이블의  사업자번호까지 체크하게 수정) -PAYM432, PAYM436 조회부분-
                   12. 주택자금. 외국인은 로직 처리 안되도록 함. (오류검증)에 걸림 @VER.2016_12
                   13. 조세감면액(기존 PAYM410.RTXLW) 추가로 국세청제출파일용(PAYM460) 조세감면대상금액 (PAYM410.RTXLW_OBJ_AMT) 적용 @VER.2016_13
                   14. 종전근무지 조세조약 감면액도 적용되도록 함.@VER.2016_14

            2017년 수정사항(@VER.2017_X)
                    0. 정산차수 INPUT 파라메터 처리
                    1. 과세표준 구간 추가 (5억원 초과):1억7060만원 + 5억원 초과액 * 40%
                       => 급여 > 연말정산 > 세금산출기준등록 산출구분(종합소득세율(기본세율)) 에서 관리(PAYM450 CAL_FG:A034500002)
                    2. 외국인근로자 과세특례 세율 변경 (19%)
                    [세액공제]
                    3. 출산,입양 세액공제 인당 세액공제금액 변경(첫째:30만원,둘째:50만원,셋째이상:70만원)
                    4. 연금계좌세액공제 공제한도 변경
                       연금저축계좌 공제한도 : 기존400만원 => 400만원(단, 총급여 1억2천만원 또는 종합소득금액 1억원 초과자는 300만원)
                    5. 의료비 세액공제 - 난임시술비 세제공제율 변경(20%)
                    6. 교육비 세액공제 - 본인교육비에 학자금대출상환액 추가 반영(본인교육비에 포함함 : SF_SETT_PAYMENT_AMT 펑션 '108' 수정)
                    7. 교육비 세액공제 - 초중고 체험학습비(1인당 연30만원한도) 추가 반영
                    8. 기타비과세 재정의 - 소득자별근로소득원천징수부 2페이지 지급명세서 기재 제외대상 비과세 소득
                                           (일직료,자가운전보조금,육아휴직비과세, 식대)
                    9. 직무발명보상금 비과세 (코드:R11) 항목추가
                   10. 신용카드 등 사용액 소득공제 공제한도 급여수준별 차등적용
                        총급여액 7천만원이하  : Min(총급여액20%, 300만원)
                                 7천~1.2억원  : 300만원(18.1.1 이후 250만원=>2018년 연말정산에 적용사항)
                                 1.2억원 초과 : 200만원
                   11. 신용카드 등 사용액 소득공제 공제율 변경 (전통시장,대중교통사용액 30%=>40% 상향)
                   12. 소상공인 공제부금 소득공제의 공제한도 조정(소득수준별 공제한도 차등화: 기준 근로소득금액:V_LABOR_EARN_AMT)
                       4천만원 이하 : 500만원
                       4천~1억원    : 300만원
                       1억원 초과   : 200만원
                   13. 기부금 공제순서 변경 [⑧,⑨ 기존순서와 변경됨]
                       ①정치자금 => ②당해 법정기부 => ③2014년 이후 이월 법정 => ④우리사주조합기부 =>
                       ⑤2013년 이전 이월 종교외 지정기부 => ⑥2013년 이전 이월 종교단체 =>
                       ⑦당해 종교외 지정기부  => ⑧2014년~이월 종교외 기부 =>
                       ⑨당해 종교단체 지정기부=> ⑩2014년~이월 종교단체 기부
                   14. 그 밖의 소득공제 : 투자조합출자 공제
                       2년전,1년전,당해 구분 없이 당해 컬럼 하나만 사용하게 변경 (2015~2017년 조건이 같음)
                   15. 장기집합투자증권 소득공제 총급여액 8천만원 이하 조건 반영 (여태 미반영됨)
                   16. 의료비 세액공제 계산식 수정 (난임시술비 존재할시 계산이 안맞음)
                   17. 종전근무지 우리사주조합인출금액(PAYM430.OSC_SOCT_WITHD_AMT) 항목추가, 총급여에 반영.
                   18. 영수증1페이지 (73)종(전)근무지(결정세액란의 세액기재) 때문에 종전근무지 3개이상인경우가 문제있어서 종전근무지사업자번호3, 근무시작일3, 근무종료일3 다시 부활
                   19. 외국인단일세율 근로소득계산시 V_CURR_SITE_FO_NOTAX_AMT=>V_ETC_AMT_TAX 대체
                   20. @VER.2017_MEDI 계산된 세액이 차감할수 있는 세액보다 많은경우 공제대상금액 계산에 오류가 있어 원계산된 대상금액이 필요함.
                   21. 전근무지농특세 반영 (@VER.2017_21)

            2018년 수정사항(@VER.2018_X)
                    1. 과세표준 구간 분리, 세율 상향 : 1억5천만원~3억원 * 38%, 3억원~5억원 * 40%, 5억원 초과 * 42%
                       => 급여 > 연말정산 > 세금산출기준등록 산출구분(종합소득세율(기본세율)) 에서 관리(PAYM450 CAL_FG:A034500002)
                    2. 대상금액 항목분리컬럼 추가(6개)
                       -국민연금보험료공제대상금액(NPN_DUC_OBJ_AMT)
                       -사학연금공제대상금액(NPN_INSU_DUC_OBJ_AMT)
                       -공무원연금공제대상금액(PUBPERS_PENS_DUC_OBJ_AMT)
                       -군인연금공제대상금액(MILITARY_PENS_DUC_OBJ_AMT)
                       -특별공제건강보험공제대상금액(SPCL_DUC_HINS_DUC_OBJ_AMT)
                       -특별공제고용보험공제대상금액(SPCL_DUC_EINS_DUC_OBJ_AMT)
                    3. 생산직근로자 등 초과근로수당 비과세금액 및 대상직종 추가 - 환경운영직(청소) 분들 월정액 190이하인건 확인 되었으나, 초과근무수당을 지급받은 인적이 없는것으로 확인.
                       - 야간근로수당 비과세(DELAY_NOTAX_AMT)에 V_DELAY_NOTAX_AMT 금액입력.
                       - 2019.01.21 야간근로수당 비과세(DELAY_NOTAX_AMT)항목 PAYM440.NGHT_LABOR_ALLOW_NOTAX값 조회로 변경(@VER.2018_3_1)
                    4. 자녀세액공제 6세 이하 자녀 추가공제 폐지
                    5. 의료비 세액공제 금액 및 대상 추가
                    6. 보장성보험료 세액공제 대상에 임차보증금 반환 보증보험료 추가
                    7. 엔젤투자 소득공제 공제 확대 및 적용기한 연장(~'20.12.31까지)
                       : 1500만원 기존 -> 3000만원 이하 투자금액 100%
                                          3000만원 초과 5000만원 이하분 : 50% -> 70%
                                          5000만원 초과분 : 30%
                    8. 월세세액공제율 인상(공제율 차등 인상)
                       - 총급여 5.5천만원 이하 : 12%(종합소득금액 4천만원 초과자 제외), 한도도 90만원으로 변경 (@VER.2019_1)
                       - 그 외 근로자 : 10%
                    9. 도서·공연비 지출에 대한 신용카드 등 소득공제 항목 신설
                       - 총급여 7천만원 이하자에 한해 도서.공연비* 지출분 : 30%, 도서.공연비 지출분도 100만원 추가
                       - 총급여 7천만원 초과자 : 도서.공연비(신용카드(12H1), 체크카드(12H2), 현금영수증(12H3)) 세가지로 분리(@VER.2018_9_1)
                   10. 중소기업 청년 취업자에 대한 소득세 감면 확대
                   11. 기부금 이월공제기간 확대
                       1)지정기부금
                        - 2013년도 기부금의 마지막 공제가능연도가 2018년도(올해)이기 때문에 올해 공제는 문제없음, 하지만 올해 공제되고 남은 금액은 소멸됨(5년 기간이 종료되기 때문)
                          그러므로, 남은금액이 소멸되지 않고 내년도 이월금액으로 처리되게 수정(이월공제기간이 10년으로 연장되었기 때문)(@VER.2018_11_1)
                       2)법정기부금(2013년도 기부금 - 2016년도 소멸된 금액 대상자 A000428(1명 퇴직)으로 서울대에 대상이 없음.
                       3)2019.01.30  10만원 초과분도 정치자금기부금 공제대학금엑에 포함(@VER.2018_11_3)
                   12. 연금, 저축, 주택 관련 소득공제
                   13. 직무발명보상금 비과세(PAYM410.DUTY_INVENT_CMPS_AMT_NOTAX)에 V_DUTY_INVENT_CMPS_AMT_NOTAX(PAYM440.DUTY_INVENT_CMPS_AMT_NOTAX)금액 입력
                   14. '167' 종전근무지 주식매수선택이익금액(PAYM430.STOCK_BUY_CHOICE_PROFIT_AMT) 항목추가, 총급여에 반영.

            2019년 수정사항(@VER.2019_X)
                    1. 투자조합 출자 등 소득공제 관련 연도 주석 수정(@VER.2019_1)
                    2. 장기주택저당차입금 이자지급액 소득공제 4억원 -> 5억원 관련 주석 수정(@VER.2019_2)
                    3. 고액기부금 기준 금액 변화(2천만원에서 1천만원으로 변경)(@VER.2019_3)
                    4. 실손의료비 추가. 의료비 대상금액에서 실손의료비 차감 처리(@VER.2019_4)
                    5. 2018년 12. 31 소득세법 개정에 따라, 기부금 이월은 5년 -> 10년으로 변경
                       법정기부금 => 2013년도에 지출한 법정기부금에 대해서도 이월공제기간이 10년으로 연장
                       2013.1.1 부터 지출한 법정, 종교단체외 지정기부금, 종교단체지정기부금(@VER.2019_5)
                    6. 전근무지 조특법(30조 외) 감면액(추가). 중소기업 핵심인력 성과보상기금은 분리 로직 필요시, 내년에 별도 개발 필요(@VER.2019_6)
                    7. 기부금 공제 순서 변경. 이월액 먼저 소멸되도록 변경됨 (@VER.2019_7)
                       (기존) 정치자금 -> 당해 법정 -> 2014 이후 이월 법정 -> 우리사주 -> 2013 이월 종교 외 지정 ->
                       2013 이월 종교 지정 -> 당해 종교 외 지정 -> 2014 이후 이월 종교 외 지정 -> 당해 종교 지정 -> 2014 이후 이월 종교 지정
                       (변경)정치자금 -> 2013 이월 법정 -> 2014 이후 이월 법정 -> 당해 법정 -> 우리사주 -> 2013 이월 종교 외 지정 ->
                       2013 이월 종교 지정 -> 2014 이후 이월 종교 외 지정 -> 당해 종교 외 지정 -> 2014 이후 이월 종교 지정 -> 당해 종교 지정
                    8. 추가소득(기관) PAYM441의 부설학교연구보조비('A035400007')에 대해 월20만원 한도로 비과세로 반영(소득세법시행령 12조12호)
                       월20만원 초과인 경우 추가소득으로 합산(@VER.2019_8)
                    9. 총급여 7천만원 이하의 산후조리원 200만원한도내 공제 적용.
                       추가공제자, 본인+65세이상+장애인을 산후조리원 비용을 나누어서 처리(@VER.2019_9)
                   10. 기부금 지정기부금 종교외, 종교의 전액공제를 > 0 에서 >= 0 으로 변경(@VER.2019_10). 다시 복원처리.
                   11. 기부금 법정이월 이월기부금에 추가 (@VER.2019_11)
                   12. 기부금 시뮬과 계산방식이 상이하여 수정 (@VER.2019_12)
                   13. 당해 지정기부금 계산시 잔여기부금이 0보다 작은 경우 UPDATE 하지 않는다. 기존 로직 삭제 (@VER.2019_13)
                   14. 장기주택저당차입금, 주택임차차입금의 본인명의의 차입금 체크 추가 (@VER.2019_14)

<2017.09.22 튜닝적용 검색어: @TUNING >
● 개선내역
비효율 원인 : SP_PAYM410B_TRET_2016 프로시저에서 수행하는 SQL로 필터링 효율이 좋은 조건을 선행으로 하는 인덱스가 없어 비효율적인 조인 순서로 실행됨.
해결 방안 : 필터링 효율이 좋은 조건을 선행으로 하는 인덱스를 생성해주고 힌트를 통해 조인 순서를 제어.

인덱스 생성
CREATE INDEX snu.IDX_PAYM432_01 ON snu.paym432( rpst_pers_no , yy , yretxa_seq , cntrib_yy )

힌트추가
/*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) /

 INPUT               :
 OUTPUT              : OUT_RTN   - 리턴 코드   1: Success, 0: Fail, : No Data
                       OUT_MSG   - 리턴 메세지
*******************************************************************************************************/

/********** 변수선언시작 ***********************/
--<< 필요한 변수를 이곳에 선언합니다 >>


V_RPST_PERS_NO                          VARCHAR2(100) := NULL;
V_PRE_RPST_PERS_NO                      VARCHAR2(100) := NULL;

V_SPRT_OBJ_PSN_CNT                      NUMBER(2) := 0;      --부양대상자수
V_HINDR_CNT                             NUMBER(1) := 0;      --장애인수
V_PATH_PREF_CNT_70                      NUMBER(1) := 0;      --경로우대70세상대상자수
V_BRED_CNT_6                            NUMBER(1) := 0;      --6세이하양육대상자수
V_BRED_EDU_CNT_6                        NUMBER(1) := 0;      --교육비취학전아동수
V_ADOP_CHIL_CNT                         NUMBER(1) := 0;      --출산,입양대상자수

V_MTI_CHILD_ADD_DUC_CNT                 NUMBER(2) := 0;      --다자녀추가공제자수
V_STD_CNT                               NUMBER(1) := 0;      --교육비초중고등학교인원수
V_LRG_STD_CNT                           NUMBER(1) := 0;      --교육비대학공납금인원수

V_SLF_DUC_AMT                           NUMBER(15) := 0;      --본인공제
V_WIFE_DUC_AMT                          NUMBER(15) := 0;      --배우자공제액
V_SPRT_FM_DUC_AMT                       NUMBER(15) := 0;      --부양자공제금액
V_HANDICAP_DUC_AMT                      NUMBER(15) := 0;      --장애자공제금액
V_PATH_PREF_DUC_AMT_70                  NUMBER(15) := 0;      --경로우대공제금액70세
V_CHILD_BREXPS_DUC_AMT_6                NUMBER(15) := 0;      --자녀양육비공제금액
V_WOMN_DUC_AMT                          NUMBER(15) := 0;      --부녀자공제액
V_MTI_CHILD_ADD_DUC_AMT                 NUMBER(15) := 0;      --다자녀추가공제금액
V_ADOP_CHIL_DUC_AMT                     NUMBER(15) := 0;      --출산입양자공제

V_CURR_SITE_SALY_AMT                    NUMBER(15) := 0;      --현근무지급여액
V_CURR_SITE_AMT_TAX_SETT_AMT            NUMBER(15) := 0;      --현근무지비과세정산액

V_BF_SITE_SALY_AMT                      NUMBER(15) := 0;      --전근무지급여액
V_BF_SITE_BONUS_AMT                     NUMBER(15) := 0;      --전근무지상여액
V_BF_SITE_DETM_BONUS_AMT                NUMBER(15) := 0;      --전근무지인정상여액
V_BF_OSC_SOCT_WITHD_AMT                 NUMBER(15) := 0;      --전근무지 우리사주조합인출금(@VER.2017_17)
V_BF_STOCK_BUY_AMT                      NUMBER(15) := 0;      --전근무지 주식매수선택이익금액(@VER.2018_14)
V_BF_SITE_INCOME_TAX                    NUMBER(15) := 0;      --전근무지소득세
V_BF_SITE_INHAB_TAX                     NUMBER(15) := 0;      --전근무지주민세
V_BF_SITE_FMTAX                         NUMBER(15) := 0;      --전근무지농특세(@VER.2017_21)

V_LABOR_EARN_TT_SALY_AMT                NUMBER(15) := 0;      --근로소득총급여액
V_LABOR_EARN_DUC_AMT                    NUMBER(15) := 0;      --근로소득공제금액
V_LABOR_EARN_AMT                        NUMBER(15) := 0;      --근로소득금액
V_PSCH_PESN_INSU_AMT                    NUMBER(15) := 0;      --종(전)근무지사학연금합산
V_ADD_PSCH_PESN_INSU_AMT                NUMBER(15) := 0;      --현근무지사학연금합산
V_NPN_INSU_AMT                          NUMBER(15) := 0;      --종(전)근무지국민연금합산
V_ADD_NPN_INSU_AMT                      NUMBER(15) := 0;      --현근무지국민연금합산
V_MILITARY_PENS_INSU_AMT                NUMBER(15) := 0;      --종(전)근무지군인연금합산

V_PUBPERS_PENS_AMT                      NUMBER(15) := 0;      --종(전)근무지공무원연금
V_ADD_PUBPERS_PENS_AMT                  NUMBER(15) := 0;      --현근무지공무원연금합산

V_HINS_AMT                              NUMBER(15) := 0;      --주(현)근무지건강보험료합산
V_EINS_AMT                              NUMBER(15) := 0;      --주(현)근무지고용보험료합산
V_SPCL_DUC_INSU_AMT                     NUMBER(15) := 0;      --특별공제보험료합산
V_HFE_DUC_AMT                           NUMBER(15) := 0;      --특별공제의료비합산
V_EDU_DUC_AMT                           NUMBER(15) := 0;      --특별공제교육비합산
V_HOUS_LOAMT_AMT1                       NUMBER(15) := 0;      --특별공제주택임차원리금대출기관상환액
V_HOUS_LOAMT_AMT2                       NUMBER(15) := 0;      --특별공제주택임차원리금사인간상환액
V_HOUS_FUND_DUC_2_AMT                   NUMBER(15) := 0;      --특별공제주택이자상환금액합계
V_SPCL_DUC_AMT                          NUMBER(15) := 0;      --특별공제합산

V_STAD_DUC_AMT                          NUMBER(15) := 0;      --표준공제
V_PERS_PESN_SAV_DUC_AMT                 NUMBER(15) := 0;      --개인연금저축공제
V_PESN_SAV_DUC_AMT                      NUMBER(15) := 0;      --연금저축공제
V_ICOMP_FINC_DUC_AMT                    NUMBER(15) := 0;      --투자조합출자공제금액
V_LMT_CREDIT_DUC_AMT                    NUMBER(15) := 0;      --신용카드공제 한도금액 @VER.2017_10 (소득별 차등 한도적용)
V_CREDIT_DUC_AMT                        NUMBER(15) := 0;      --신용카드공제금액
V_GNR_EARN_TAX_STAD_AMT                 NUMBER(15) := 0;      --종합소득과세표준금액
V_GNR_EARN_TAX_STAD_AMT_2               NUMBER(15) := 0;      --농특세를위한과세표준금액
V_GNR_EARN_TAX_STAD_AMT_3               NUMBER(15) := 0;      --농특세를위한이전과세표준금액
V_CAL_TDUC                              NUMBER(15) := 0;      --산출세액
V_LABOR_EARN_TDUC_DUC_AMT               NUMBER(15) := 0;      --세액공제근로소득세액공제
V_POLITICS_CNTRIB_TDUC_DUC              NUMBER(15) := 0;      --정치기부금세액공제

V_TDUC_DUC_TT_AMT                       NUMBER(15) := 0;      --세액공제계
V_DETM_INCOME_TAX                       NUMBER(15) := 0;      --결정소득세
V_DETM_INHAB_TAX                        NUMBER(15) := 0;      --결정주민세
V_DETM_FMTAX_AMT                        NUMBER(15) := 0;      --결정농특세
V_CAL_TDUC1                             NUMBER(15) := 0;      --투자조합출자공제전산출세액
V_CAL_TDUC2                             NUMBER(15) := 0;      --투자조합출자공제후산출세액
V_SBTR_COLT_FMTAX_TAX                   NUMBER(15) := 0;      --차감농특세
V_SBTR_COLT_INCOME_TAX                  NUMBER(15) := 0;      --차감소득세
V_SBTR_COLT_INHAB_TAX                   NUMBER(15) := 0;      --차감주민세
V_LABOR_TEMP_AMT                        NUMBER(15) := 0;      --임시근로소득
V_SBTR_EARN_AMT                         NUMBER(15) := 0;      --차감근로소득
V_CAL_TDUC_TEMP_AMT                     NUMBER(15) := 0;      --임시산출세액

V_SLF_ELDR_HIND_HFE                     NUMBER(15) := 0;      --본인.65세이상자.
V_HAND_DUC_HFE                          NUMBER(15) := 0;      --장애인의료비
V_ETC_DUC_PSN_HFE                       NUMBER(15) := 0;      --그밖의공제대상자의료비
V_SUBFER_MEDIPRC_HFE                    NUMBER(15) := 0;      --난임시술비 -- 2015 연말정산 추가 -- @VER.2015
V_REAL_LOSS_MED_AMT                     NUMBER(15) := 0;      --실손의료비 합계 -- 2019 연말정산 추가 -- @VER.2019_4

V_ETC_CARE_DUC_PSN_HFE                  NUMBER(15) := 0;      --추가공제자의 산후조리원 => 700만원 한도 적용을 위해 따로 관리 -- 2019 연말정산 추가 -- @VER.2019_9
V_SLF_ELDR_HIND_CARE_HFE                NUMBER(15) := 0;      --추가공제자 이외(본인, 65세이상, 장애인, 난임시술비)의 대상자의 산후조리원 -- 2019 연말정산 추가 -- @VER.2019_9

V_FLAW_CNTRIB_AMT                       NUMBER(15) := 0;      --정치자금기부금발생금액
V_FLAW_CNTRIB_100_RATE_AMT              NUMBER(15) := 0;      --정치자금100%세액공제기부금발생금액
V_FLAW_CNTRIB_15_RATE_AMT               NUMBER(15) := 0;      --정치자금15%세액공제기부금발생금액
V_FLAW_CNTRIB_25_RATE_AMT               NUMBER(15) := 0;      --정치자금25%세액공제기부금발생금액
V_LMT_CNTRIB_AMT                        NUMBER(15) := 0;      --기부금공제한도
V_POLITICS_FUND_CNTRIB_AMT              NUMBER(15) := 0;      --기부금전액공제(법정기부금+진흥기금출연)
V_PROM_GRP_CNTRIB_AMT                   NUMBER(15) := 0;      --기부금50%한도(조특법73)_특례기부금
V_PROM_GRP_CNTRIB_2_AMT                 NUMBER(15) := 0;      --기부금우리사주발생금액

V_ETC_CNTRIB_AMT                        NUMBER(15) := 0;      --기부금지정기부금(기타)

V_CREDIT_USE_AMT                        NUMBER(15) := 0;      --신용카드등(전통시장,대중교통제외신용카드)
V_CSH_RECPT_USE_AMT                     NUMBER(15) := 0;      --신용카드등(전통시장제외현금영수증)
V_ACMY_GIRO_PAID_AMT                    NUMBER(15) := 0;      --신용카드등(학원비지로납부)


V_CURR_SITE_SALY                        NUMBER(15) := 0;      --현근무지급여합계
V_CURR_SITE_SALY1                       NUMBER(15) := 0;      --현근무지급여내역(PAYM440)
V_CURR_SITE_SALY2                       NUMBER(15) := 0;      --현근무지추가급여(PAYM441)

V_CURR_SITE_BONUS_AMT                   NUMBER(15) := 0;      --현근무지상여
V_CURR_SITE_DETM_BONUS_AMT              NUMBER(15) := 0;      --현근무지인정상여
V_ETC_AMT_TAX                           NUMBER(15) := 0;      --현근무지기타비과세합계(모범수당(국고),육아휴직수당,정액급식비(국고),정액급식비(기금),정액급식비(기성회),직급보조비(국고))
V_RECH_ACT_AMT_TAX                      NUMBER(15) := 0;      --현근무지연구비과세합계
V_CHDBIRTH_CARE_AMT                     NUMBER(15) := 0;      --현근무지보육비비과세합계
V_DUTY_INVENT_CMPS_AMT_NOTAX            NUMBER(15) := 0;      --현근무지 직무발명보상금비과세 (@VER.2017_9)
V_DUTY_INVENT_CMPS_AMT                  NUMBER(15) := 0;      --현근무지 직무발명보상금 (@VER.2018)
V_DELAY_NOTAX_AMT                       NUMBER(15) := 0;      --현근무지 야간근로수당 비과세 (@VER.2018_3)
V_INCOME_TAX                            NUMBER(15) := 0;      --현근무지소득세
V_INHAB_TAX                             NUMBER(15) := 0;      --현근무지주민세

V_GUAR_INSU_PAY_INSU_AMT                NUMBER(15) := 0;      --일반보장성보험료합산
V_HANDICAP_INSU_PAY_INSU_AMT            NUMBER(15) := 0;      --장애인전용보장성보험합산
V_SLF_EDU_AMT                           NUMBER(15) := 0;      --본인교육비_전액공제
V_SCH_BF_CHILD_EDU_AMT                  NUMBER(15) := 0;      --취학전아동교육비
V_SCH_EDU_AMT                           NUMBER(15) := 0;      --초중고교육비
V_UNIV_PSN_EDU_AMT                      NUMBER(15) := 0;      --대학교교육비
V_HANDICAP_SPCL_EDU_AMT                 NUMBER(15) := 0;      --장애인교육비_전액공제
V_LMT_CO_DUC_AMT                        NUMBER(15) := 0;      --소기업ㆍ소상공인 공제부금 소득공제 한도액(소득수준별 공제한도 차등화 @VER.2017_12)
V_CO_DUC_AMT                            NUMBER(15) := 0;      --소기업ㆍ소상공인 공제부금 소득공제
V_LNTM_STCS_SAV_DUC_AMT                 NUMBER(15) := 0;      --장기주식형저축소득공제
V_LNTM_STCS_SAV_DUC_AMT1                NUMBER(15) := 0;      --장기주식형저축소득공제_불입분의20%공제
V_LNTM_STCS_SAV_DUC_AMT2                NUMBER(15) := 0;      --장기주식형저축소득공제_불입분의10%공제
V_LNTM_STCS_SAV_DUC_AMT3                NUMBER(15) := 0;      --장기주식형저축소득공제_불입분의5%공제
V_BASI_AMT_1                            NUMBER(15) := 0;
V_BASI_AMT_2                            NUMBER(15) := 0;
V_TRATE                                 NUMBER(5,2) := 0;
V_HSSV_AMT                              NUMBER(15) := 0;      --주택마련저축공제
V_CNT                                   NUMBER(3) := 0;
V_BF_WK_FIRM_NM_CNT_2                   VARCHAR2(100) := NULL;      --전근무지상호2외갯수
V_BF_WK_FIRM_NM_1                       VARCHAR2(100) := NULL;      --전근무지상호1
V_BF_WK_FIRM_NM_2                       VARCHAR2(100) := NULL;      --전근무지상호2
V_BF_WK_FIRM_NM_3                       VARCHAR2(100) := NULL;      --전근무지상호3
V_BF_WK_BIZR_NO_1                       VARCHAR2(13) := NULL;      --전근무지사업번호1
V_BF_WK_BIZR_NO_2                       VARCHAR2(13) := NULL;      --전근무지사업번호2
V_BF_WK_BIZR_NO_3                       VARCHAR2(13) := NULL;      --전근무지사업번호3
V_BF_WK_FR_DT_1                         VARCHAR2(08) := NULL;      --전근무지시작일자1
V_BF_WK_FR_DT_2                         VARCHAR2(08) := NULL;      --전근무지시작일자2
V_BF_WK_FR_DT_3                         VARCHAR2(08) := NULL;      --전근무지시작일자3
V_BF_WK_TO_DT_1                         VARCHAR2(08) := NULL;      --전근무지종료일자1
V_BF_WK_TO_DT_2                         VARCHAR2(08) := NULL;      --전근무지종료일자2
V_BF_WK_TO_DT_3                         VARCHAR2(08) := NULL;      --전근무지종료일자3

V_BF_REDC_FR_DT_1                       VARCHAR2(08) := NULL;      --전근무지감면시작일자1
V_BF_REDC_FR_DT_2                       VARCHAR2(08) := NULL;      --전근무지감면시작일자2
V_BF_REDC_FR_DT_3                       VARCHAR2(08) := NULL;      --전근무지감면시작일자3
V_BF_REDC_TO_DT_1                       VARCHAR2(08) := NULL;      --전근무지감면종료일자1
V_BF_REDC_TO_DT_2                       VARCHAR2(08) := NULL;      --전근무지감면종료일자2
V_BF_REDC_TO_DT_3                       VARCHAR2(08) := NULL;      --전근무지감면종료일자3

V_BF_SITE_SALY_AMT_1                    NUMBER(15) := 0;      --전근무지급여액1
V_BF_SITE_BONUS_AMT_1                   NUMBER(15) := 0;      --전근무지상여액1
V_BF_SITE_DETM_BONUS_AMT_1              NUMBER(15) := 0;      --전근무지인정상여액1
V_BF_SITE_UN_TAX_EARN_AMT_1             NUMBER(15) := 0;      --전근무지비과세금액1
V_BF_SITE_DELAY_NOTAX_AMT_1             NUMBER(15) := 0;      --전근무지연장비과세액1
V_BF_SITE_CARE_NOTAX_AMT_1              NUMBER(15) := 0;      --전근무지보육비과세1
V_BF_SITE_RECH_NOTAX_AMT_1              NUMBER(15) := 0;      --전근무지연구비과세1
V_BF_SITE_ETC_NOTAX_AMT_1               NUMBER(15) := 0;      --전근무지기타비과세1
V_BF_SITE_APNT_NOTAX_AMT_1              NUMBER(15) := 0;      --전근무지지정비과세1
V_BF_SITE_TRAING_ASSI_ALLOW_1           NUMBER(15) := 0;      --전근무지수련보조수당비과세1
V_BF_SITE_STXLW_NOTAX_1                 NUMBER(15) := 0;      --전근무지조특법30조소득세감면액1
V_BF_SITE_RTXLW_NOTAX_1                 NUMBER(15) := 0;      --전근무지조세규약소득세감면액1

V_BF_SITE_SALY_AMT_2                    NUMBER(15) := 0;      --전근무지급여액2
V_BF_SITE_BONUS_AMT_2                   NUMBER(15) := 0;      --전근무지상여액2
V_BF_SITE_DETM_BONUS_AMT_2              NUMBER(15) := 0;      --전근무지인정상여액2
V_BF_SITE_UN_TAX_EARN_AMT_2             NUMBER(15) := 0;      --전근무지비과세금액2
V_BF_SITE_DELAY_NOTAX_AMT_2             NUMBER(15) := 0;      --전근무지연장비과세액2
V_BF_SITE_CARE_NOTAX_AMT_2              NUMBER(15) := 0;      --전근무지보육비과세2
V_BF_SITE_RECH_NOTAX_AMT_2              NUMBER(15) := 0;      --전근무지연구비과세2
V_BF_SITE_ETC_NOTAX_AMT_2               NUMBER(15) := 0;      --전근무지기타비과세2
V_BF_SITE_APNT_NOTAX_AMT_2              NUMBER(15) := 0;      --전근무지지정비과세2
V_BF_SITE_TRAING_ASSI_ALLOW_2           NUMBER(15) := 0;      --전근무지수련보조수당비과세2
V_BF_SITE_STXLW_NOTAX_2                 NUMBER(15) := 0;      --전근무지조특법30조소득세감면액2
V_BF_SITE_RTXLW_NOTAX_2                 NUMBER(15) := 0;      --전근무지조세규약소득세감면액2

V_BF_SITE_SALY_AMT_3                    NUMBER(15) := 0;      --전근무지급여액3
V_BF_SITE_BONUS_AMT_3                   NUMBER(15) := 0;      --전근무지상여액3
V_BF_SITE_DETM_BONUS_AMT_3              NUMBER(15) := 0;      --전근무지인정상여액2
V_BF_SITE_UN_TAX_EARN_AMT_3             NUMBER(15) := 0;      --전근무지비과세금액3
V_BF_SITE_DELAY_NOTAX_AMT_3             NUMBER(15) := 0;      --전근무지연장비과세액3
V_BF_SITE_CARE_NOTAX_AMT_3              NUMBER(15) := 0;      --전근무지보육비과세3
V_BF_SITE_RECH_NOTAX_AMT_3              NUMBER(15) := 0;      --전근무지연구비과세3
V_BF_SITE_ETC_NOTAX_AMT_3               NUMBER(15) := 0;      --전근무지기타비과세3
V_BF_SITE_APNT_NOTAX_AMT_3              NUMBER(15) := 0;      --전근무지지정비과세3
V_BF_SITE_TRAING_ASSI_ALLOW_3           NUMBER(15) := 0;      --전근무지수련보조수당비과세3
V_BF_SITE_STXLW_NOTAX_3                 NUMBER(15) := 0;      --전근무지조특법30조소득세감면액3
V_BF_SITE_RTXLW_NOTAX_3                 NUMBER(15) := 0;      --전근무지조세규약소득세감면액3

V_SCI_TECH_RETI_PESN_AMT                NUMBER(15) := 0;      --퇴직연금과학기술인공제소득공제액
V_RETI_PESN_AMT                         NUMBER(15) := 0;      --현퇴직연금액(근로자)
V_PRE_RETI_PESN_AMT                     NUMBER(15) := 0;      --전근무지퇴직연금액(근로자)
V_RETI_PESN_DUC_AMT                     NUMBER(15) := 0;      --퇴직연금근로자퇴직급여보장법공제액
V_RETI_PESN_EARN_DUC_AMT                NUMBER(15) := 0;      --퇴직연금합산(과학기술인공제+근로자퇴직급여보장법)

V_PESN_HINS_AMT                         NUMBER(15) := 0;      --전근무지건강보험료
V_PESN_EINS_AMT                         NUMBER(15) := 0;      --전근무지고용보험료
V_HOUS_MOG_ITT_1                        NUMBER(15) := 0;      --장기주택저당차입금이자15년미만
V_HOUS_MOG_ITT_2                        NUMBER(15) := 0;      --장기주택저당차입금이자15년~29년이상
V_HOUS_MOG_ITT_3                        NUMBER(15) := 0;      --장기주택저당차입금이자30년이상
V_HOUS_MOG_ITT_4                        NUMBER(15) := 0;      --장기주택저당차입금이자2012년이후고정금리(비거치식)
V_HOUS_MOG_ITT_5                        NUMBER(15) := 0;      --장기주택저당차입금이자2012년이후일반
-- 2015년 연말정산. @VER.2015
V_HOUS_MOG_ITT_6                        NUMBER(15) := 0;      --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 AND 비거치식
V_HOUS_MOG_ITT_7                        NUMBER(15) := 0;      --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 OR 비거치식
V_HOUS_MOG_ITT_8                        NUMBER(15) := 0;      --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 일반적인 차입
V_HOUS_MOG_ITT_9                        NUMBER(15) := 0;      --장기주택저당차입금이자2015년 이후 차입분. 10년 이상~15년미만. 고정금리 OR 비거치식

V_CNTRIB_DUC_TMP_AMT                    NUMBER(15) := 0;      --기부금금액공제
V_BUSINESS_USE_AMT                      NUMBER(15) := 0;      --신용카드사업관련비용
--V_SCHL_UNIF_AMT                       NUMBER(15) := 0;      --교육비교복구입비
V_MEDI_LIMT_AMT                         NUMBER(15) := 0;      --의료비3%한도금액

V_UN_MINT_HOUS_ITT_RFND_AMT             NUMBER(15) := 0;      --미분양주택이자상환액
V_LABOR_TEMP_AMT2                       NUMBER(15) := 0;      --
V_CURR_WK_FR_DT                         VARCHAR2(08) := NULL;      --현근무기간
V_CURR_WK_TO_DT                         VARCHAR2(08) := NULL;      --현근무기간
V_FR_DT                                 VARCHAR2(08) := NULL;      --임용일자
V_TO_DT                                 VARCHAR2(08) := NULL;      --해임일자
--2011년추가
V_DEBIT_USE_AMT                         NUMBER(15) := 0;      --직불카드사용금액(전통시장제외)
V_MM_TAX_AMT                            NUMBER(15) := 0;      --월세액
V_HOUS_FUND_DUC_HAP_AMT                 NUMBER(15) := 0;      --주택임대차차입금원리금상환공제금액+월세액
V_SUBS_SAV                              NUMBER(15) := 0;      --청약저축
V_SUBS_SAV1                             NUMBER(15) := 0;      --2009년이전청약저축
V_SUBS_SAV2                             NUMBER(15) := 0;      --2010년이후청약저축
V_LABORR_HSSV                           NUMBER(15) := 0;      --근로자주택마련저축
V_HOUS_SUBS_GNR_SAV                     NUMBER(15) := 0;      --주택청약종합저축
V_LNTM_HSSV                             NUMBER(15) := 0;      --장기주택마련저축
--V_COMP                                NUMBER(15) := 0;
--V_CREDIT_HAP_AMT                      NUMBER(15) := 0;
--기부금                                관련
V_CNTRIB_DUC_AMT                        NUMBER(15) := 0;      --기부금공제금액
V_CNTRIB_DUC_SUM_AMT                    NUMBER(15) := 0;      --기부금누적금액
V_CNTRIB_DUC_SUM_AMT10                  NUMBER(15) := 0;      --법정기부금공제합계액
V_CNTRIB_DUC_SUM_AMT20                  NUMBER(15) := 0;      --정치자금기부금공제합계액
V_CNTRIB_DUC_SUM_AMT30                  NUMBER(15) := 0;      --특례기부금공제합계액
V_CNTRIB_DUC_SUM_AMT42                  NUMBER(15) := 0;      --우리사주조합기부금공제합계액
V_CNTRIB_DUC_SUM_AMT4041                NUMBER(15) := 0;      --지정기부금공제합계액(종교_종교외)

V_CNTRIB_PREAMT                         NUMBER(15) := 0;      --기부금전년까지공제금액
V_CNTRIB_GONGAMT                        NUMBER(15) := 0;      --기부금당년공제금액
V_CNTRIB_DESTAMT                        NUMBER(15) := 0;      --기부금당년소멸금액
V_CNTRIB_OVERAMT                        NUMBER(15) := 0;      --기부금당년이월금액
V_APNT_CNTRIB_AMT                       NUMBER(15) := 0;      --종교단체지정기부금당년도공제,소멸,이월금액
--주택자금                              및저축공제체크항목
V_HOUSEHOLDER_YN                        VARCHAR2(1) := 'N';      --세대주여부
V_HOUS_SCALE_YN                         VARCHAR2(1) := 'N';      --국민주택규모(전용85제곱미터)이하여부
V_BASI_MPRC_BLW                         VARCHAR2(1) := 'N';      --기준시가3억원이하여부
V_HOUS_SEC_YN                           VARCHAR2(1) := 'N';      --저당차입금3개월이내차입여부
V_HOUS_OWN_CNT                          NUMBER(15) := 0;      --연중소유주택수
--조세조약세액감면관련
V_RTXLW                                 NUMBER(15) := 0;      --조세조약세액감면액
V_RTXLW_OBJ_AMT                         NUMBER(15) := 0;      --조세조약세액감면 대상금액 (거의 99%가 산출세액으로 들어감)@VER.2016_13
V_RTXLW_CURR_REDC_AMT                   NUMBER(15) := 0;      --조세조약세액감면액(FOR 현근무지소득 대한 계산)@VER.2016_14
V_RTXLW_ALD_REDC_AMT                    NUMBER(15) := 0;      --조세조약세액감면액(FOR 종전근무지소득에 대한 계산)@VER.2016_14
V_RTXLW_AMT1                            NUMBER(15) := 0;      --감면기간내급여소득액
V_RTXLW_AMT2                            NUMBER(15) := 0;      --감면기간내추가소득액
V_RTXLW_AMT3                            NUMBER(15) := 0;      --종전근무지 조세조약 감면액@VER.2016_14
V_REDC_TAX_TT                           NUMBER(15) := 0;      --감면세액계
--2012년추가
V_CREDIT_TRADIMARKE_USE_AMT             NUMBER(15) := 0;      --신용카드(전통시장사용액)
V_CREDIT_TOT_USE_AMT                    NUMBER(15) := 0;      --신용카드총사용금액(신용카드+학원비+현금영수증)
V_CREDIT_DUC_EXC_AMT                    NUMBER(15) := 0;      --신용카드공제제외금액
V_CREDIT_DUC_POSS_AMT                   NUMBER(15) := 0;      --신용카드공제가능금액
V_CREDIT_MINI_USE_AMT                   NUMBER(15) := 0;      --신용카드최저사용금액
V_CREDIT_DUC_OVER_AMT                   NUMBER(15) := 0;      --신용카드공제한도초과금액
V_CREDIT_DUC_ADD_AMT                    NUMBER(15) := 0;      --신용카드추가공제금액
V_CNTRIB_DUC_SUM_AMT31                  NUMBER(15) := 0;      --공익법인기부신탁기부금공제합계액
V_ICOMP_FINC_DUC_AMT2                   NUMBER(15) := 0;      --벤쳐투자조합출자공제금액(20%)2012년분
V_CURR_SITE_INSUR_AMT                   NUMBER(15) := 0;      --현근무지4대보험료합계금액(외국인단일세율용)
V_BF_SITE_INSUR_AMT                     NUMBER(15) := 0;      --전근무지4대보험료합계금액(외국인단일세율용)
V_CURR_SITE_FO_NOTAX_AMT                NUMBER(15) := 0;      --현근무지식대,유류비과세합계금액(외국인단일세율용)
V_BF_SITE_FO_NOTAX_AMT                  NUMBER(15) := 0;      --전근무지식대,유류비과세합계금액(외국인단일세율용)
--------------
--2013년                                별도추가
V_CREDIT_PUBLIC_TRAF_AMT                NUMBER(15) := 0;      --신용카드(대중교통사용액):2013년추가
V_SINGLE_PARENT_DUC_AMT                 NUMBER(15) := 0;      --한부모공제.2013추가

V_CREDIT_BOOK_PFMC_AMT                  NUMBER(15) := 0;      --신용카드(도서.공연비):2018년추가(@VER.2018_9)
V_CREDIT_BOOK_PFMC_AMT1                 NUMBER(15) := 0;      --신용카드(도서.공연비):2018년추가(@VER.2018_9_1)
V_CREDIT_BOOK_PFMC_AMT2                 NUMBER(15) := 0;      --체크카드(도서.공연비):2018년추가(@VER.2018_9_1)
V_CREDIT_BOOK_PFMC_AMT3                 NUMBER(15) := 0;      --현금영수증(도서.공연비):2018년추가(@VER.2018_9_1)

V_CREDIT_DUC_ADD_AMT1                   NUMBER(15) := 0;      --신용카드추가공제금액(전통시장)
V_CREDIT_DUC_ADD_AMT2                   NUMBER(15) := 0;      --신용카드추가공제금액(대중교통)
V_CREDIT_DUC_ADD_AMT3                   NUMBER(15) := 0;      --신용카드추가공제금액(2013년비교상반기증가)
V_CREDIT_DUC_ADD_AMT4                   NUMBER(15) := 0;      --신용카드추가공제금액(2014년비교하반기증가)
V_CREDIT_DUC_ADD_AMT5                   NUMBER(15) := 0;      --신용카드추가공제금액(도서.공연비):2018년추가(@VER.2018_9)
V_ICOMP_FINC_DUC_AMT3                   NUMBER(15) := 0;      --벤쳐투자조합출자공제금액(종합소득30%한도)2013년분
V_ICOMP_FINC_DUC_AMT2011                NUMBER(15) := 0;      --출자·투자금액의10%공제,벤쳐투자조합출자공제금액(종합소득30%한도)2011년분
V_ICOMP_FINC_DUC_AMT2013                NUMBER(15) := 0;      --출자금액중2013년도분계산용,
V_LFSTS_ITT_RFND_AMT                    NUMBER(15) := 0;      --목돈안드는전세이자상환액(40%)



V_DUC_MAX_AMT                           NUMBER(15) := 0;      --소득공제종합한도금액2500만원
V_DUC_MAX_OVER_AMT                      NUMBER(15) := 0;      --소득공제종합한도초과액
V_DUC_MAX_OVER_TMP_AMT                  NUMBER(15) := 0;      --계산용임시변수

--아래                                  9개항목의합산금액이2500만원까지만공제됨.
V_DUC_MAX_GUAR_INSU_AMT                 NUMBER(15) := 0;      --1.보장성보험료공제액--V_GUAR_INSU_PAY_INSU_AMT일반보장성보험료와동일.
V_DUC_MAX_HFE_AMT                       NUMBER(15) := 0;      --2.의료비공제액(장애인제외)
V_DUC_MAX_EDU_AMT                       NUMBER(15) := 0;      --3.교육비공제액(장애인특수교육비제외)
V_DUC_MAX_HOUS_AMT                      NUMBER(15) := 0;      --4.주택자금공제액

V_DUC_MAX_CNTRIB_AMT                    NUMBER(15) := 0;      --5.지정기부금2013년지출분공제액(이월분은제외)
V_DUC_MAX_CNTRIB40_AMT                  NUMBER(15) := 0;      --종교외(40)지정기부금A032400006
V_DUC_MAX_CNTRIB41_AMT                  NUMBER(15) := 0;      --종교(41)지정기부금A032400007
V_DUC_MAX_CNTRIB40_OVERAMT              NUMBER(15) := 0;      --종교외(40)지정기부금이월금액
V_DUC_MAX_CNTRIB41_OVERAMT              NUMBER(15) := 0;      --종교(41)지정기부금이월금액
V_CNTRIB_DUC_SUM_AMT2                   NUMBER(15) := 0;      --기부금누적금액(올해이월금액제외분)

--V_POLITICS_TRSR_AMT                   NUMBER(15) := 0;      --정치자금
--V_THYR_FLAW_CNTRIB_AMT                NUMBER(15) := 0;      --법정기부금
--V_CNTRIB_AMT_OSC_SOCT                 NUMBER(15) := 0;      --우리사주조합기부금
--V_APNT_CNTRIB_AMT                     NUMBER(15) := 0;      --지정기부금

V_DUC_MAX_CO_AMT                        NUMBER(15) := 0;      --6.소기업/소상공인공제부금공제액
V_DUC_MAX_CREDIT_AMT                    NUMBER(15) := 0;      --7.신용카드사용공제액
V_DUC_MAX_ICOMP_AMT                     NUMBER(15) := 0;      --8.투자조합출자소득공제액(2013년분)
V_DUC_MAX_OSC_AMT                       NUMBER(15) := 0;      --9.우리사주출연금공제액:주식회사가아니므로실제적사용안함.

V_BF_SITE_STXLW_AMT                     NUMBER(15) := 0;      --전근무지감면액합계:조특법30조.원금..
V_BF_SITE_STXLW_TAX                     NUMBER(15) := 0;      --전근무지감면세액합계:조특법30조.최종감면금액
V_BF_SITE_SMBIZ_BONUS_AMT               NUMBER(15) := 0;      --전근무지감면액합계:조특법30조외.원금..          (@VER.2019_6)
V_BF_SITE_SMBIZ_BONUS_TAX               NUMBER(15) := 0;      --전근무지감면세액합계:조특법30조외.최종감면금액    (@VER.2019_6)

V_BF_SITE_RTXLW_TAX                     NUMBER(15) := 0;      --전근무지감면세액합계:조세규약
V_BF_SITE_REDC_TAX                      NUMBER(15) := 0;      --전근무지감면세액합계


V_MAN_CNT                               NUMBER(10) := 0;      --처리대상자수
V_SETT_FG                               VARCHAR2(10) := '';      --V_SETT_FG를대체하여시뮬레이션을A031300001:연말정산,A031300002:중도정산두가지값으로만변경.
V_TMP_CNT                               NUMBER(10) := 0;      --임시카운트변수,
V_REC_CNT                               NUMBER(10) := 0;      --FOR LOOP 총카운트변수,
V_TMP10_AMT                             NUMBER(15) := 0;      --임시변수(당해 법정기부금 공제금 계산용:2014년이후 특별세액공제)
V_TMP40_AMT                             NUMBER(15) := 0;      --임시변수(당해 지정기부금(종교외) 공제금 계산용:2014년이후 특별세액공제)
V_TMP41_AMT                             NUMBER(15) := 0;      --임시변수(당해 지정기부금(종교)   공제금 계산용:2014년이후 특별세액공제)
V_TMP_AMT_2013                          NUMBER(15) := 0;      --임시변수(2013년이전 이월 공제금 계산용:2013년이전 특별[소득]공제)
V_TMP10_AMT_2013                        NUMBER(15) := 0;      --임시변수(2013년 이월 법정 공제금 계산용:2013년 특별[세액]공제)
V_TMP10_AMT_2014                        NUMBER(15) := 0;      --임시변수(2014년이후 이월 법정 공제금 계산용:2014년이후 특별[세액]공제)
V_TMP40_AMT_2014                        NUMBER(15) := 0;      --임시변수(2014년이후 이월 지정기부금(종교외) 공제금 계산용:2014년이후 특별[세액]공제)
V_TMP41_AMT_2014                        NUMBER(15) := 0;      --임시변수(2014년이후 이월 지정기부금(종교)  공제금 계산용:2014년이후 특별[세액]공제)
V_TMP_AMT                               NUMBER := 0;
V_TMP_AMT_ETE                           NUMBER := 0;
--------
V_PAYM451_YY                            VARCHAR2(4) := '';
V_PAYM450_YY                            VARCHAR2(4) := '';
V_PAYM452_YY                            VARCHAR2(4) := '';

V_LOAN_DT                               VARCHAR2(8) := '';      --장기주택저당차입금차입일체크용.
V_HOUS_MOG_LOAMT_2005_BF_YN             VARCHAR2(1) := '';      --장기주택저당차입금주택수체크용...

V_ENT_DT                                VARCHAR2(8) := '';      --주택청약 가입일


/***                                    2014년추가****/
V_PAID_SPCLEX_TAX                       NUMBER(15) := 0;      --납부특례세액
V_BASE_DUC_CHILD_CNT                    NUMBER(10) := 0;      --기본공제자녀수
V_CHILD_TAXDUC_AMT                      NUMBER(15) := 0;      --자녀세액공제액
V_CHILD_ENC_AMT_ACCPT_YN                VARCHAR2(1) := '';    --자녀장려금수령여부 -- 2015 연말정산 추가 - @VER.2015

V_CNTRIB_AMT_CYOV_AMT                   NUMBER(15) := 0;      --기부금이월액
V_OSC_CNTRB_AMT                         NUMBER(15) := 0;      --우리사주출연금액
V_OSC_CNTRIB_AMT                        NUMBER(15) := 0;      --우리사주기부금
V_INVST_SEC_SAV_AMT                     NUMBER(15) := 0;      --장기집합투자증권저축액
V_SCI_DUC_OBJ_AMT                       NUMBER(15) := 0;      --과학기술인연금공제대상금액
V_SCI_TAXDUC_AMT                        NUMBER(15) := 0;      --과학기술인연금세액공제액
V_RETI_PENS_DUC_OBJ_AMT                 NUMBER(15) := 0;      --퇴직연금공제대상금액
V_RETI_PENS_TAXDUC_AMT                  NUMBER(15) := 0;      --퇴직연금세액공제액
V_PNSV_DUC_OBJ_AMT                      NUMBER(15) := 0;      --연금저축공제대상금액
V_PNSV_TAXDUC_AMT                       NUMBER(15) := 0;      --연금저축세액공제액
V_GUARQL_INSU_DUC_OBJ_AMT               NUMBER(15) := 0;      --보장성보험공제대상금액
V_GUARQL_INSU_TAXDUC_AMT                NUMBER(15) := 0;      --보장성보험세액공제액
V_DSP_GUARQL_INSU_DUC_OBJ_AMT           NUMBER(15) := 0;      --장애인보장성보험공제대상금액 (2014재계산)
V_DSP_GUARQL_INSU_TAXDUC_AMT            NUMBER(15) := 0;      --장애인보장성보험세액공제액 (2014재계산)
V_HFE_DUC_OBJ_AMT                       NUMBER(15) := 0;      --의료비공제대상금액
V_HFE_DUC_OBJ_AMT_ORG                   NUMBER(15) := 0;      --@VER.2017_MEDI 의료비공제대상금액(원계산보다 차감할 세액이 적은 경우 의료비공제대상금액 계산이 비율이 안맞아서 원계산된 의료공제대상금액 변수추가 함.@VER.2017 )
V_HFE_TAXDUC_AMT                        NUMBER(15) := 0;      --의료비세액공제액
V_EDAMT_DUC_OBJ_AMT                     NUMBER(15) := 0;      --교육비공제대상금액
V_EDAMT_TAXDUC_AMT                      NUMBER(15) := 0;      --교육비세액공제액
V_POLITICS_BLW_DUC_OBJ_AMT              NUMBER(15) := 0;      --정치한도이하공제대상금액
V_POLITICS_BLW_TAXDUC_AMT               NUMBER(15) := 0;      --정치한도이하세액공제액
V_POLITICS_EXCE_DUC_OBJ_AMT             NUMBER(15) := 0;      --정치한도초과공제대상금액
V_POLITICS_EXCE_TAXDUC_AMT              NUMBER(15) := 0;      --정치한도초과세액공제액
V_FLAW_CNTRIB_DUC_OBJ_AMT               NUMBER(15) := 0;      --법정기부공제대상금액
V_FLAW_CNTRIB_TAXDUC_AMT                NUMBER(15) := 0;      --법정기부세액공제액
V_APNT_CNTRIB_DUC_OBJ_AMT               NUMBER(15) := 0;      --지정기부공제대상금액
V_APNT_CNTRIB_TAXDUC_AMT                NUMBER(15) := 0;      --지정기부세액공제액
V_APNT_CNTRIB40_DUC_OBJ_AMT             NUMBER(15) := 0;      --지정기부(종교외)공제대상금액 @VER.2016_8
V_APNT_CNTRIB40_TAXDUC_AMT              NUMBER(15) := 0;      --지정기부(종교외)세액공제액 @VER.2016_8
V_APNT_CNTRIB41_DUC_OBJ_AMT             NUMBER(15) := 0;      --지정기부(종교)공제대상금액 @VER.2016_8
V_APNT_CNTRIB41_TAXDUC_AMT              NUMBER(15) := 0;      --지정기부(종교)세액공제액 @VER.2016_8

V_STAD_TAXDUC_OBJ_AMT                   NUMBER(15) := 0;      --표준세액공제대상금액
V_STAD_TAXDUC_AMT                       NUMBER(15) := 0;      --표준세액공제액
V_MNRT_TAXDUC_AMT                       NUMBER(15) := 0;      --월세세액공제액


V_SLF_DRWUP_CFM_YN                      VARCHAR2(1) := 'N';      --본인작성확인여부
V_HOUSEHOLDER_DUPL_DUC_YN               VARCHAR2(1) := 'N';      --세대주중복공제여부
V_SLF_LOAMT_YN                          VARCHAR2(1) := 'N';      --본인차입금여부
V_YY2_BF_INDREC_INVST_AMT               NUMBER(15) := 0;      --2년전간접투자금액
V_YY2_BF_DIRECT_INVST_AMT               NUMBER(15) := 0;      --2년전직접투자금액
V_YY1_BF_INDREC_INVST_AMT               NUMBER(15) := 0;      --1년전간접투자금액
V_YY1_BF_DIRECT_INVST_AMT               NUMBER(15) := 0;      --1년전직접투자금액
V_THYR_INDREC_INVST_AMT                 NUMBER(15) := 0;      --당해간접투자금액
V_THYR_DIRECT_INVST_AMT                 NUMBER(15) := 0;      --당해직접투자금액
V_ADDR_ACCORD_YN                        VARCHAR2(1) := 'N';      --주소지일치여부
V_SUBDP_BASI_MPRC_BLW_YN                VARCHAR2(1) := 'N';      --청약저축기준시가이하여부
v_HOUS_OWN_YN                           VARCHAR2(1) := 'N';      --연중무주택여부



V_BF_RECPT_DEBIT_ALL_AMT                NUMBER(15) := 0;      --전년도체크현금영수증합계
V_SHALF_RECPT_DEBIT_ALL_AMT             NUMBER(15) := 0;      --당해년도하반기체크현금영수증합계
V_FHALF_RECPT_DEBIT_ALL_AMT             NUMBER(15) := 0;      --당해년도상반기체크현금영수증합계  - @VER.2015
V_BF_PRVYY_RECPT_DEBIT_ALL_AMT          NUMBER(15) := 0;      --전전년도(Y-2)체크현금영수증합계  - @VER.2015

V_YY2_BF_INVST_AMT                      NUMBER(15) := 0;      --벤처등과거년도투자금액공제합계(재작년)
V_BF_INVST_AMT                          NUMBER(15) := 0;      --벤처등과거년도투자금액공제합계(작년)
V_THYR_INVST_AMT                        NUMBER(15) := 0;      --벤처등당해년도투자금액공제합계
V_INVST_FOR_DUC_MAX_AMT                 NUMBER(15) := 0;      --종합한도대상벤처등투자금액

V_SPCL_INCMDED_TT_AMT                   NUMBER(15) := 0;      --특별소득공제금액계
V_REST_INCMDED_TT_AMT                   NUMBER(15) := 0;      --그밖의소득공제금액계


V_BF_CNTRIB_TAXDUC_AMT                  NUMBER(15) := 0;      --기부금세액공제전 결정세액

V_FLAW_APNT_AFTER2014_ACCM_AMT      NUMBER(15) := 0;          --법정, 지정 기부금 누계액

V_CNTRIB_TAXDUC_AMT                     NUMBER := 0;          --기부금 실제공제세액
V_MOD_CNTRIB_TAXDUC_AMT                 NUMBER := 0;          --기부금 조정공제세액

V_MOD_CNTRIB_DUC_OBJ_AMT                NUMBER := 0;          --기부금 조정 공제대상액








/** 2019년도 기부금 세액계산을 위해 새롭게 만든 변수들 **/

GV_TAX_REMAIN_AMT     NUMBER := 0;

N_TOT_GIFT            NUMBER := 0;    -- 세액공제대상금액 합계액
N_CMLTV_GIFT          NUMBER := 0;    -- 세액공제대상금액 합계액

N_RT_GIFT             NUMBER := 0;    -- 기부금 세액공제액

N_DON_LAW_RT          NUMBER := 0;    -- 비율(법정기부금 세액공제대상금액             / 세액공제대상금액 합계액)
N_STOCK_RT            NUMBER := 0;    -- 비율(우리사주조합기부금 세액공제대상금액     / 세액공제대상금액 합계액)
N_PSA_APPNT_RT        NUMBER := 0;    -- 비율(지정기부금 종교단체 외 세액공제대상금액 / 세액공제대상금액 합계액)
N_PSA_RELGN_RT        NUMBER := 0;    -- 비율(지정기부금 종교단체 세액공제대상금액    / 세액공제대상금액 합계액)

-- 기부금 소득공제ㆍ세액공제로 결정세액이 "0"이 되는 경우 처리용 변수
N_SUB_RT_AMT          NUMBER := 0;    -- 환산공제대상금액
N_SUB_RT_DUC_AMT      NUMBER := 0;    -- 환산공제대상금액 차감용 변수
N_CALC_TAX_SUB        NUMBER;         -- 기부금 세액공제액 임시 계산
N_RE_CALC_TAX_OBJ     NUMBER;         -- 기부금 공제대상액 임시 역산

N_TAX_SUB_TMP         NUMBER;         -- 기부금 세액공제액 임시
N_TAX_SUB_OBJ_TMP     NUMBER;         -- 기부금 공제대상액 임시
    
GN_RT_TOTAL_CUR_SUB     NUMBER := 0;   -- 당해년도 법정 기부금
GN_RT_TOTAL_ETC_SUB_14  NUMBER := 0;   -- 2014년도 법정 이뤌 기부금
GN_RT_TOTAL_ETC_SUB_15  NUMBER := 0;   -- 2015년도 법정 이뤌 기부금
GN_RT_TOTAL_ETC_SUB_16  NUMBER := 0;   -- 2016년도 법정 이뤌 기부금
GN_RT_TOTAL_ETC_SUB_17  NUMBER := 0;   -- 2017년도 법정 이뤌 기부금
GN_RT_TOTAL_ETC_SUB_18  NUMBER := 0;   -- 2018년도 법정 이뤌 기부금

GN_STOCK_URSM           NUMBER := 0;   -- 우리사주조합기부금

GN_RT_PSA_CUR_APPNT     NUMBER := 0;   -- 당해년도 지정(종교단체외) 기부금
GN_RT_PSA_ETC_APPNT_14  NUMBER := 0;   -- 2014년도 지정(종교단체외) 이월 기부금
GN_RT_PSA_ETC_APPNT_15  NUMBER := 0;   -- 2015년도 지정(종교단체외) 이월 기부금
GN_RT_PSA_ETC_APPNT_16  NUMBER := 0;   -- 2016년도 지정(종교단체외) 이월 기부금
GN_RT_PSA_ETC_APPNT_17  NUMBER := 0;   -- 2017년도 지정(종교단체외) 이월 기부금
GN_RT_PSA_ETC_APPNT_18  NUMBER := 0;   -- 2018년도 지정(종교단체외) 이월 기부금

GN_RT_PSA_CUR_RELGN     NUMBER := 0;   -- 2019년도 지정(종교단체) 당월 기부금
GN_RT_PSA_ETC_RELGN_14  NUMBER := 0;   -- 2014년도 지정(종교단체) 이월 기부금
GN_RT_PSA_ETC_RELGN_15  NUMBER := 0;   -- 2015년도 지정(종교단체) 이월 기부금
GN_RT_PSA_ETC_RELGN_16  NUMBER := 0;   -- 2016년도 지정(종교단체) 이월 기부금
GN_RT_PSA_ETC_RELGN_17  NUMBER := 0;   -- 2017년도 지정(종교단체) 이월 기부금
GN_RT_PSA_ETC_RELGN_18  NUMBER := 0;   -- 2018년도 지정(종교단체) 이월 기부금

GV_CALC_RT_DON_LAW      NUMBER := 0;   -- 기부금 공제세액
GV_CALC_RT_STOCK_URSM   NUMBER := 0;   -- 우리사주조합기부금  공제세액
GV_CALC_RT_PSA          NUMBER := 0;   -- 종교단체외 공제세액
GV_CALC_RT_PSA_RELGN    NUMBER := 0;   -- 종교단체 공제세액

GV_CALC_SPCL_DON_LAW    NUMBER := 0;   --  법정기부금 세액공제 대상기부금 누계액  
GV_CALC_SPCL_STOCK_URSM NUMBER := 0;   --  우리사주조합기부금 세액공제 대상액
GV_CALC_SPCL_PSA        NUMBER := 0;   --  종교단체외 지정기부금 세액공제 대상액
GV_CALC_SPCL_PSA_RELGN_AMT NUMBER := 0;   -- 종교단체 지정기부금 세액공제 대상액


/** 2019년도 기부금 세액계산을 위해 새롭게 만든 변수들 **/








V_SLF_MNRT_PAY_YN                       VARCHAR2(1) := 'N';      --월세액공제 - 본인이 월세액 지급여부 확인
V_LESE_HOUS_SCALE_BLW_YN                VARCHAR2(1) := 'N';      --월세액 - 임차주택이 국민주택규모이하인지 여부확인
V_JOIN_THTM_HOUS_CNT                    NUMBER(2) := 0;          --2009년 12. 31일 이전 청약저축가입자의 경우 가입당시주택수
V_JOIN_THTM_HOUS_SCALE_BLW_YN           VARCHAR2(1) := 'N';      --2009년 12. 31일 이전 청약저축가입자의 경우 1주택자이면 가입당시 주택이 국민주택규모이하인지 여부 확인
V_JOIN_THTM_BASI_MPRC_BLW_YN            VARCHAR2(1) := 'N';      --2009년 12. 31일 이전 청약저축가입자의 경우 1주택자이면 가입당시 주택이 기준시가이하 여부확인

V_TMP_BF_CALC_TAXAMT                    NUMBER(15) := 0;       --차감전 세액

V_STD_DETM_INCOME_TAX                   NUMBER(15)  := -1;      -- 표준세액공제적용 결정세액 (2014재계산) : 기존 NUMBER(2)->NUMBER(15);

V_YRETXA_SEQ                            PAYM432.YRETXA_SEQ%TYPE := 1; --기부금 이월계산시 2014년의 경우 1,2차가 존재하여 더블로 계산되는 오류발생 (작년 max차수를 가지고 계산하도록 보완)

V_BIZR_REG_NO                           PAYM452.BIZR_REG_NO%TYPE := ''; --@VER.2016_11 사업자부서정보의 사업자번호.


V_OUT_RTN           NUMBER(5)     := 0;                -- 급여계산 프로시져 호출 Return 값
V_OUT_MSG           VARCHAR2(800) := '';               -- 급여계산 프로시져 호출 Return 값

V_TMP_STEP          VARCHAR2(100);

/*SSTM056 (DB프로그램오류로그:DBMS_OUTPUT.PUT_LINE 대체 ) 입력용 변수*/
V_DB_PGM_ID         VARCHAR2(100) := 'SP_PAYM410B_TRET_2019';
V_OCCR_LOC_NM       VARCHAR2(1000);
V_DB_ERROR_CTNT     VARCHAR2(4000);




/********** 변수선언끝   ***********************/

BEGIN

    /* 기부금 이월용 전년도 연말정산 차수*/
    /* @2016 개인별 처리로 변경.*/
    /*
    SELECT MAX(YRETXA_SEQ)
      INTO V_YRETXA_SEQ
    FROM PAYM432 WHERE YY = IN_YY - 1
    ;*/

    V_SETT_FG := CASE WHEN IN_SETT_FG = 'A031300001' THEN 'A031300001'  --연말정산
                      WHEN IN_SETT_FG = 'A031300002' THEN 'A031300002'  --중도정산
                      WHEN IN_SETT_FG = 'A031300003' THEN 'A031300001'  --연말정산 시뮬레이션 -> 연말정산
                      ELSE IN_SETT_FG END ;



    V_TMP_STEP := 'D01';

    -- 정산년도 공제한도 존재 여부 체크

    BEGIN

       SELECT YY
         INTO V_PAYM451_YY
         FROM PAYM451
        WHERE YY = IN_YY
          AND CAL_FG = 'A034400001' /*정산항목구분:기본공제*/
        ;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            OUT_RTN := 0;
            OUT_MSG := '정산년도의 공제한도 자료가 존재하지 않습니다. 공제한도 생성 후 재작업 하십시요.';
            RETURN;
    END;

    -- 정산년도 세금산출기준 존재 여부 체크
    BEGIN

       SELECT YY
         INTO V_PAYM450_YY
         FROM PAYM450
        WHERE YY = IN_YY
          AND ROWNUM = 1;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            OUT_RTN := 0;
            OUT_MSG := '정산년도의 세금산출기준 자료가 존재하지 않습니다. 세금산출기준 생성 후 재작업 하십시요.';
            RETURN;
    END;

    -- 정산년도 사업자정보 존재 여부 체크
    BEGIN

       SELECT YY
         INTO V_PAYM452_YY
         FROM PAYM452
        WHERE YY = IN_YY
          AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            OUT_RTN := 0;
            OUT_MSG := '정산년도의 사업자정보 자료가 존재하지 않습니다. 사업자정보 자료 생성 후 재작업 하십시오.['||IN_BIZR_DEPT_CD||']';
            RETURN;
    END;





    -- 기존 기발생된 데이타 삭제한다...
    -- 연말정산결과(PAYM410)

    IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
        --DELETE FROM PAYM410_TMP
        V_TMP_STEP := 'D02';
        DELETE FROM PAYM435 A
         WHERE A.YY             = IN_YY
           AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.SETT_FG        = V_SETT_FG
           AND A.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
           AND A.RPST_PERS_NO   = NVL(IN_RPST_PERS_NO, A.RPST_PERS_NO)
           AND A.RPST_PERS_NO IN ( SELECT RPST_PERS_NO --2013년 추가, 기관별 처리.
                                     FROM PAYM420 B
                                    WHERE B.YY         = IN_YY
                                      AND B.YRETXA_SEQ = IN_YRETXA_SEQ /*@VER.2017_0*/
                                      AND B.SETT_FG    = V_SETT_FG
                                      AND B.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
                                      AND NVL(B.SALY_DEPT_CD,' ') = NVL(IN_DEPT_CD, NVL(B.SALY_DEPT_CD,' '))  --2013년 추가, 기관별 처리.
               )
           ;

        -- 기부금결과(PAYM432_TMP)
        V_TMP_STEP := 'D03';
        DELETE FROM PAYM436 A
         WHERE A.YY           = IN_YY
           AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
           AND A.SETT_FG      = V_SETT_FG
           AND A.RPST_PERS_NO = NVL(IN_RPST_PERS_NO, A.RPST_PERS_NO)
           AND A.RPST_PERS_NO IN ( SELECT RPST_PERS_NO --2013년 추가, 기관별 처리.
                                     FROM PAYM420 B
                                    WHERE B.YY         = IN_YY
                                      AND B.YRETXA_SEQ = IN_YRETXA_SEQ /*@VER.2017_0*/
                                      AND B.SETT_FG    = V_SETT_FG
                                      AND B.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
                                      AND NVL(B.SALY_DEPT_CD,' ') = NVL(IN_DEPT_CD, NVL(B.SALY_DEPT_CD,' '))  --2013년 추가, 기관별 처리.
                                  )
           ;
    ELSE -- 정상 처리인경우
        V_TMP_STEP := 'D04';
        DELETE FROM PAYM410 A
         WHERE A.YY             = IN_YY
           AND A.YRETXA_SEQ     = IN_YRETXA_SEQ   /*@VER.2017_0*/
           AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
           AND A.SETT_FG        = V_SETT_FG
           AND A.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
           AND A.RPST_PERS_NO   = NVL(IN_RPST_PERS_NO, A.RPST_PERS_NO)
           AND A.RPST_PERS_NO IN ( SELECT RPST_PERS_NO --2013년 추가, 기관별 처리.
                                     FROM PAYM420 B
                                    WHERE B.YY         = IN_YY
                                      AND B.YRETXA_SEQ = IN_YRETXA_SEQ  /*@VER.2017_0*/
                                      AND B.SETT_FG    = V_SETT_FG
                                      AND B.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
                                      AND NVL(B.SALY_DEPT_CD,' ') = NVL(IN_DEPT_CD, NVL(B.SALY_DEPT_CD,' '))  --2013년 추가, 기관별 처리.
                                     UNION
                                   SELECT RPST_PERS_NO --2013년 추가, 기관별 처리.
                                     FROM PAYM431 B /* 연말정산 제외자 */
                                    WHERE B.YY        = IN_YY
                                      AND B.SETT_FG   = V_SETT_FG
                                      AND B.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
                                      AND B.SALY_DEPT_CD = NVL(IN_DEPT_CD, B.SALY_DEPT_CD)  --2013년 추가, 기관별 처리.
                                   )
         --eterain5                     
--           AND A.RPST_PERS_NO NOT IN ( SELECT C.RPST_PERS_NO --2019년 추가[임시데이터 보존]
--                                         FROM PAYM410_2019TMP C
--                                        WHERE C.YY         = IN_YY
--                                          AND C.YRETXA_SEQ = IN_YRETXA_SEQ
--                                          AND C.SETT_FG    = V_SETT_FG
--                                          AND C.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
--                                   )
         --eterain5                     
           ;

        -- 기부금결과(PAYM432)
        V_TMP_STEP := 'D05';
        DELETE FROM PAYM432 A
         WHERE A.YY           = IN_YY
           AND A.YRETXA_SEQ   = IN_YRETXA_SEQ   /*@VER.2017_0*/
           AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
           AND A.SETT_FG      = V_SETT_FG
           AND A.RPST_PERS_NO = NVL(IN_RPST_PERS_NO, A.RPST_PERS_NO)
           AND A.RPST_PERS_NO IN ( SELECT RPST_PERS_NO --2013년 추가, 기관별 처리.
                                     FROM PAYM420 B
                                    WHERE B.YY         = IN_YY
                                      AND B.YRETXA_SEQ = IN_YRETXA_SEQ   /*@VER.2017_0*/
                                      AND B.SETT_FG    = V_SETT_FG
                                      AND B.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
                                      AND NVL(B.SALY_DEPT_CD,' ') = NVL(IN_DEPT_CD, NVL(B.SALY_DEPT_CD,' '))  --2013년 추가, 기관별 처리.
                                    UNION
                                   SELECT RPST_PERS_NO --2013년 추가, 기관별 처리.
                                     FROM PAYM431 B /* 연말정산 제외자 */
                                    WHERE B.YY         = IN_YY
                                      AND B.SETT_FG    = V_SETT_FG
                                      AND B.LABOR_SCHLS_FG = 'N' --근로장학생이 아닌 사람만 연말정산 계산
                                      AND B.SALY_DEPT_CD = NVL(IN_DEPT_CD, B.SALY_DEPT_CD)  --2013년 추가, 기관별 처리.
               )
--         --eterain5                     
--           AND A.RPST_PERS_NO NOT IN ( SELECT C.RPST_PERS_NO --2019년 추가[임시데이터 보존]
--                                         FROM PAYM410_2019TMP C
--                                        WHERE C.YY         = IN_YY
--                                          AND C.YRETXA_SEQ = IN_YRETXA_SEQ
--                                          AND C.SETT_FG    = V_SETT_FG
--                                          AND C.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
--                                   )
         --eterain5                     
           ;
    END IF;

    -- 연말정산 대상자 발췌....

    BEGIN
        FOR REC IN (
                    SELECT
                           A.RPST_PERS_NO
                          ,A.BIZR_DEPT_CD --사업자부서코드
                          ,A.POSI_BREU_CD --소속기관코드
                          ,A.POSI_DEPT_CD --소속부서코드
                          ,A.NATI_FG      --국적구분

                          ,A.KOR_NM       --한글성명
                          ,A.RES_NO       --주민등록번호

                          ,A.RSD_FG          --거주자구분코드
                          ,A.RSD_NATI_FG    --거주지국코드

                          ,A.STTS_FG    --신분구분
                          ,A.BIZTP_FG    --직종구분
                          ,A.WKSP_FG    --직렬구분
                          ,A.LVLPT_FG    --급류구분
                          ,A.WKGD_CD    --직급코드
                          ,A.STEP_FG    --호봉구분
                          ,A.CWK_YCNT    --근속년수

                          ,A.HOUSEHOLDER_YN    --거주지국코드

                          ,NVL(D.HOUS_LOAMT_AMT1,0) HOUS_LOAMT_AMT1 --특별공제주택임차원리금대출기관상환액
                          ,NVL(D.HOUS_LOAMT_AMT2,0) HOUS_LOAMT_AMT2 --특별공제주택임차원리금사인간상환액
                          ,NVL(C.RETI_PESN_AMT,0) RETI_PESN_AMT   --퇴직연금불입금액 필드변경
                          ,NVL(C.PNSV,0) PNSV    -- 연금저축
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_1,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_1 --장기주택저당차입금이자상환액 15년 미만. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_2,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_2 --장기주택저당차입금이자상환액 15년~29년 미만. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_3,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_3 --장기주택저당차입금이자상환액 30년 이상. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_4,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_4 --장기주택저당차입금이자상환액 2012년 이후 고정금리 또는 비거취식. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_5,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_5 --장기주택저당차입금이자상환액 2012년 일반. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_6,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_6 --장기주택저당차입금이자상환액 2015년 15년이상 고정금리면서 비거치식 ＠VER.2015. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_7,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_7 --장기주택저당차입금이자상환액 2015년 15년이상 고정금리 또는 비거치식 ＠VER.2015. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_8,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_8 --장기주택저당차입금이자상환액 2015년 15년이상 기타 ＠VER.2015. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)
                          ,CASE WHEN NVL(A.SLF_LOAMT_YN,'N') = 'Y' THEN
                                     NVL(E.HOUS_MOG_ITT_9,0)
                                ELSE
                                     0
                            END AS HOUS_MOG_ITT_9 --장기주택저당차입금이자상환액 2015년 10년이상 15년미만 고정금리 또는 비거치식 ＠VER.2015. 본인차입금여부가 N인 경우 0원으로 처리(@VER.2019_14)

                          ,NVL(C.PERS_PENS,0)      AS PERS_PENS    --개인연금저축
                          ,NVL(A.DUC_INME,0)       AS DUC_INME     --소기업,소상공인 공제부금 소득공제
                          ,NVL(A.DUC_INME_JOIN_DT,'00000000') AS DUC_INME_JOIN_DT --소기업,소상공인 공제부금 가입일자 @VER.2016_1
                          ,NVL(C.LNTM_SEC_SAV,0) LNTM_SEC_SAV -- 장기주식형저축1년차 불입금액 필드변경
                          ,NVL(C.LNTM_SEC_SAV_2,0) LNTM_SEC_SAV_2 -- 장기주식형저축2년차 불입금액 필드변경
                          ,NVL(C.LNTM_SEC_SAV_3,0) LNTM_SEC_SAV_3 -- 장기주식형저축3년차 불입금액 필드변경
                          ,NVL(C.INVST_SEC_SAV_AMT,0) INVST_SEC_SAV_AMT -- 장기집합투자증권저축액
                          ,NVL(A.WONCR_AMT,0) WONCR_AMT--정치자금기부금 세액공제
                          ,NVL(A.UN_MINT_QTY_HOUS_ITT_RFND_AMT,0) UN_MINT_QTY_HOUS_ITT_RFND_AMT
                          ,NVL(A.WK_FR_DT, IN_YY || '0101') AS WK_FR_DT
                          ,A.WK_TO_DT WK_TO_DT
                          ,NVL((SELECT SUM(MNRT_YEAR_AMT)
                                 FROM PAYM428
                                WHERE RPST_PERS_NO = A.RPST_PERS_NO
                                  AND YY           = IN_YY
                                  AND YRETXA_SEQ   = IN_YRETXA_SEQ   /*@VER.2017_0*/
                                  AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                                  AND SETT_FG = 'A031300001'), 0 ) MM_TAX_GM   --  월세액 별도 테이블로 분리
                          ,NVL(C.SUBS_SAV1,0) SUBS_SAV1   --2009년이전청약저축불입액
                          ,NVL(C.SUBS_SAV2,0) SUBS_SAV2   --2010년이후청약저축불입액
                          ,NVL(C.LABORR_HSSV,0) LABORR_HSSV   --근로자주택마련저축불입액
                          ,NVL(C.HOUS_SUBS_GNR_SAV,0) HOUS_SUBS_GNR_SAV --주택청약종합저축 불입금액
                          ,NVL(C.LNTM_HSSV,0) LNTM_HSSV  -- 장기주택마련저축 불입금액
                          ,NVL(A.BASI_2008_YY_BF_FINC_INVST_AMT,0) FINC_2011_BF  -- 2011년이전출자투자분
                          ,NVL(A.BASI_2009_YY_AF_FINC_INVST_AMT,0) FINC_2012  --  2012년 출자투자분
                          ,NVL(A.BASI_2013_YY_AF_FINC_INVST_AMT,0) FINC_2013_AF  --  2013년이후출자투자분
                          ,NVL(A.BASI_2012_YY_AF_VENT_INVST_AMT,0) FINC_VENT_2012  --  2012년이후벤처투자금액
                          ,NVL(A.BASI_2013_YY_AF_VENT_INVST_AMT,0) FINC_VENT_2013  --  2013년이후벤처투자금액
                          ,NVL(C.SCI_TECH_RETI_PESN_AMT,0) SCI_TECH_RETI_PESN_AMT   -- 과학기술인공제회  일단 제외
                          ,NVL(A.LFSTS_ITT_RFND_AMT,0) LFSTS_ITT_RFND_AMT   -- 목돈안드는 전세이자상환액
                          ,A.REDC_FR_DT --감면시작일자
                          ,A.REDC_TO_DT --감면종료일자
                          ,NVL(A.FORE_TAX_RATE_YN,'N') FORE_TAX_RATE_YN  --외국인단일세율
                          ,NVL(A.SLF_DRWUP_CFM_YN,'N')  SLF_DRWUP_CFM_YN         --본인작성확인여부
                          ,NVL(A.HOUSEHOLDER_DUPL_DUC_YN,'N') HOUSEHOLDER_DUPL_DUC_YN   --세대주중복공제여부
                          ,NVL(A.SLF_LOAMT_YN,'N') SLF_LOAMT_YN             --본인차입금여부
                          ,NVL(A.CHILD_TAXDUC_AMT, 0) CHILD_TAXDUC_AMT       --자녀세액공제액
                          ,NVL(A.CHILD_ENC_AMT_ACCPT_YN, 'N') CHILD_ENC_AMT_ACCPT_YN       -- 자녀장려금 수령 여부 -- 20151217 2015 연말정산 추가
                          ,NVL(A.YY2_BF_INDREC_INVST_AMT, 0) YY2_BF_INDREC_INVST_AMT   --2년전간접투자금액
                          ,NVL(A.YY2_BF_DIRECT_INVST_AMT, 0) YY2_BF_DIRECT_INVST_AMT   --2년전직접투자금액
                          ,NVL(A.YY1_BF_INDREC_INVST_AMT, 0) YY1_BF_INDREC_INVST_AMT  --1년전간접투자금액
                          ,NVL(A.YY1_BF_DIRECT_INVST_AMT, 0) YY1_BF_DIRECT_INVST_AMT  --1년전직접투자금액
                          ,NVL(A.THYR_INDREC_INVST_AMT, 0) THYR_INDREC_INVST_AMT    --당해간접투자금액
                          ,NVL(A.THYR_DIRECT_INVST_AMT, 0) THYR_DIRECT_INVST_AMT    --당해직접투자금액
                          ,NVL(A.ADDR_ACCORD_YN,'N') ADDR_ACCORD_YN           --주소지일치여부
                          --,NVL(A.SUBDP_BASI_MPRC_BLW_YN,'N') SUBDP_BASI_MPRC_BLW_YN           --청약저축기준시가이하여부
                          ,NVL(A.HOUS_OWN_YN,'N') HOUS_OWN_YN           --연중무주택여부
                          ,NVL(A.HOUS_SCALE_YN,'N') HOUS_SCALE_YN           --국민주택규모이하여부
                          ,NVL(A.SLF_MNRT_PAY_YN,'N')             SLF_MNRT_PAY_YN    --월세액본인지급여부
                          ,NVL(A.LESE_HOUS_SCALE_BLW_YN,'N')      LESE_HOUS_SCALE_BLW_YN   --월세액 국민주택규모이하
                          ,NVL(A.JOIN_THTM_HOUS_CNT, 0)           JOIN_THTM_HOUS_CNT       -- 2009이전 청약저축의 경우 당시 주택소유수
                          ,NVL(A.JOIN_THTM_HOUS_SCALE_BLW_YN,'N') JOIN_THTM_HOUS_SCALE_BLW_YN -- 2009이전 청약저축의 경우 당시 국민주택규모이하
                          ,NVL(A.JOIN_THTM_BASI_MPRC_BLW_YN,'N')  JOIN_THTM_BASI_MPRC_BLW_YN  -- 2009이전 청약저축의 경우 당시 기준시가 이하
                          ,NVL(A.YRETXA_PART_APLY_YN,'N')         YRETXA_PART_APLY_YN         -- 분납신청여부(차감징수세액 10만원이상시 3개월분납가능)@VER.2015
                          ,P452.BIZR_REG_NO --@VER.2016_11 사업자번호
                      FROM PAYM420 A,
                           (SELECT YY, YRETXA_SEQ, BIZR_DEPT_CD, SETT_FG, RPST_PERS_NO
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900001', PAY_AMT, 0)),0) RETI_PESN_AMT --퇴직연금
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900002', PAY_AMT, 0)),0) SCI_TECH_RETI_PESN_AMT --과학기술인공제회
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900003', PAY_AMT, 0)),0) PERS_PENS     --개인연금저축
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900004', PAY_AMT, 0)),0) PNSV          --연금저축
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900005', (CASE WHEN ENT_DT < '20100101' THEN PAY_AMT ELSE 0 END), 0)),0) SUBS_SAV1    --2009년12월31일 이전 가입 청약저축
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900005', (CASE WHEN ENT_DT >= '20100101' THEN PAY_AMT ELSE 0 END), 0)),0) SUBS_SAV2   --2010년1월1일 이후 가입 청약저축
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900006', PAY_AMT, 0)),0) HOUS_SUBS_GNR_SAV   --주택청약종합저축
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900007', (CASE WHEN ENT_DT <= '20091231' THEN PAY_AMT ELSE 0 END), 0)),0) LNTM_HSSV   --장기주택마련저축(2009년12월31일 이전 가입금액만)
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900008', (CASE WHEN ENT_DT <= '20091231' THEN PAY_AMT ELSE 0 END), 0)),0) LABORR_HSSV --근로자주택마련저축(2009년12월31일 이전 가입금액만)
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900009', PAY_AMT, 0)),0) LNTM_SEC_SAV        --장기주식형저축1년차
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900010', PAY_AMT, 0)),0) LNTM_SEC_SAV_2      --장기주식형저축2년차
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900011', PAY_AMT, 0)),0) LNTM_SEC_SAV_3      --장기주식형저축3년차
                                  ,NVL(SUM(DECODE(PAY_CTNT_FG, 'A034900012', PAY_AMT, 0)),0) INVST_SEC_SAV_AMT      --장기집합투자증권저축액
                            FROM PAYM427
                            WHERE YY           = IN_YY
                              AND YRETXA_SEQ   = IN_YRETXA_SEQ   /*@VER.2017_0*/
                              AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                              AND SETT_FG      = V_SETT_FG
                              AND RPST_PERS_NO = NVL(IN_RPST_PERS_NO, RPST_PERS_NO)
                            GROUP BY YY, YRETXA_SEQ, BIZR_DEPT_CD, SETT_FG, RPST_PERS_NO
                           )C,
                           (SELECT YY, YRETXA_SEQ, BIZR_DEPT_CD, SETT_FG, RPST_PERS_NO
                                  ,NVL(SUM(DECODE(HOUS_LOAMT_FG, 'A035200001', HOUS_LOAMT_AMT, 0)),0) HOUS_LOAMT_AMT1 --특별공제주택임차원리금대출기관상환액
                                  ,NVL(SUM(DECODE(HOUS_LOAMT_FG, 'A035200002', HOUS_LOAMT_AMT, 0)),0) HOUS_LOAMT_AMT2 --특별공제주택임차원리금사인간상환액
                            FROM PAYM429
                            WHERE YY           = IN_YY
                              AND YRETXA_SEQ   = IN_YRETXA_SEQ   /*@VER.2017_0*/
                              AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                              AND SETT_FG      = V_SETT_FG
                              AND RPST_PERS_NO = NVL(IN_RPST_PERS_NO, RPST_PERS_NO)
                            GROUP BY YY, YRETXA_SEQ, BIZR_DEPT_CD, SETT_FG, RPST_PERS_NO
                           ) D,
                           (SELECT YY, YRETXA_SEQ, BIZR_DEPT_CD, SETT_FG, RPST_PERS_NO
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800001', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_1
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800002', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_2
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800003', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_3
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800004', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_4
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800005', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_5
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800006', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_6 --＠VER.2015 2015년이후 차입분 15년이상 고정금리 AND 비거치상환
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800007', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_7 --＠VER.2015 2015년이후 차입분 15년이상 고정금리 OR 비거치상환
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800008', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_8 --＠VER.2015 2015년이후 차입분 15년이상 그밖의 대출
                                 , NVL(SUM(DECODE(ITT_RFND_CD, 'A035800009', RFND_AMT, 0)),0) AS HOUS_MOG_ITT_9 --＠VER.2015 2015년이후 차입분 10년이상 고정금리 OR 비거치상환
                            FROM PAYM433
                            WHERE YY           = IN_YY
                              AND YRETXA_SEQ   = IN_YRETXA_SEQ   /*@VER.2017_0*/
                              AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                              AND SETT_FG      = V_SETT_FG
                              AND RPST_PERS_NO = NVL(IN_RPST_PERS_NO, RPST_PERS_NO)
                            GROUP BY YY, YRETXA_SEQ, BIZR_DEPT_CD, SETT_FG, RPST_PERS_NO
                           ) E,
                           PAYM452 P452 --사업자정보  /* @VER.2016_11 사업자번호 조회 추가함 */
                     WHERE A.YY           = IN_YY
                       AND A.YRETXA_SEQ   = IN_YRETXA_SEQ   /*@VER.2017_0*/
                       AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                       AND A.SETT_FG      = V_SETT_FG
                       AND NVL(A.SALY_DEPT_CD,' ') = NVL(IN_DEPT_CD, NVL(A.SALY_DEPT_CD,' ')) --2013. 관리기관 추가
                       AND NVL(A.NON_RECP_YN,'N') <> 'Y'
                       AND A.RPST_PERS_NO  = NVL(IN_RPST_PERS_NO, A.RPST_PERS_NO)
                       AND A.YY = C.YY (+) AND A.YRETXA_SEQ = C.YRETXA_SEQ (+) AND A.BIZR_DEPT_CD = C.BIZR_DEPT_CD (+) AND A.SETT_FG = C.SETT_FG (+) AND A.RPST_PERS_NO = C.RPST_PERS_NO (+)
                       AND A.YY = D.YY (+) AND A.YRETXA_SEQ = D.YRETXA_SEQ (+) AND A.BIZR_DEPT_CD = D.BIZR_DEPT_CD (+) AND A.SETT_FG = D.SETT_FG (+) AND A.RPST_PERS_NO = D.RPST_PERS_NO (+)
                       AND A.YY = E.YY (+) AND A.YRETXA_SEQ = E.YRETXA_SEQ (+) AND A.BIZR_DEPT_CD = E.BIZR_DEPT_CD (+) AND A.SETT_FG = E.SETT_FG (+) AND A.RPST_PERS_NO = E.RPST_PERS_NO (+)
                       AND A.YY           = P452.YY           --@VER.2016_11
                       AND A.BIZR_DEPT_CD = P452.BIZR_DEPT_CD --@VER.2016_11
                    ORDER BY A.RPST_PERS_NO
                  )
        LOOP

            V_RPST_PERS_NO := REC.RPST_PERS_NO;
            V_BIZR_REG_NO  := REC.BIZR_REG_NO; --@VER.2106_11 사업자번호



            --eterain5
            -- 임시테이블 대상 존재시 처리금지
            -- 2020.02.11 : 2019정산년도만 해당
            --
--            BEGIN
--               SELECT COUNT(1)
--                 INTO V_TMP_CNT
--                 FROM PAYM410_2019TMP
--                WHERE YY             = IN_YY
--                  AND YRETXA_SEQ     = IN_YRETXA_SEQ
--                  AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
--                  AND RPST_PERS_NO   = V_RPST_PERS_NO
--                  AND SETT_FG        = V_SETT_FG
--                ;
--               IF V_TMP_CNT > 0 THEN           
--                  CONTINUE;
--               END IF;
--            END;
            --
            -- 2020.02.11 : 2019정산년도만 해당
            --eterain5


            /*@VER.2016_4 개인별 전년도 기부금이월 MAX정산차수 (2012-2015 정산년도 재정산작업이 2016.10에 있어서 2014의경우 3차까지 존재함.*/
            SELECT NVL(MAX( YRETXA_SEQ ), 1)
              INTO V_YRETXA_SEQ
              FROM PAYM432 A
             WHERE A.YY           = IN_YY - 1
               AND A.SETT_FG      = V_SETT_FG
               AND A.RPST_PERS_NO = REC.RPST_PERS_NO
               AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD
            ;

            V_MAN_CNT := V_MAN_CNT + 1;

            --10건만 돌리는 경우(테스트용)
            --EXIT WHEN V_MAN_CNT > 100;

            -- 전근무지 정보 세팅....
            V_CNT := 0;
            BEGIN
                FOR REC2 IN (
                            SELECT SEQ         /* @VER.2017_18 순번으로 정렬 */
                                  ,FIRM
                                  ,BIZR_NO
                                  ,WK_FR_DT
                                  ,WK_TO_DT
                                  ,REDC_FR_DT --감면시작일
                                  ,REDC_TO_DT --감면종료일
                                  ,SALY_TT_AMT
                                  ,BONUS_TT_AMT
                                  ,DETM_BONUS
                                  ,DELAY_NOTAX_AMT --연장비과세액
                                  ,CARE_NOTAX_AMT  --보육비과세
                                  ,RECH_AMT        --연구비과세
                                  ,ETC_NOTAX_AMT   --기타비과세
                                  ,APNT_NOTAX_AMT  --지정비과세
                                  ,TRAING_ASSI_ALLOW_AMT --수련보조수당
                                  ,STXLW                 -- 조특법30법 감면(중소기업취업)
                                  ,RTXLW                 -- 조세조약 감면
                                  ,ROWNUM       /* @VER.2017_18 ROWNUM으로 LOOP 이후 로직사용 */
                              FROM PAYM430
                             WHERE YY           = IN_YY
                               AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                               AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                               AND SETT_FG      = V_SETT_FG
                               AND RPST_PERS_NO = REC.RPST_PERS_NO
                               AND BIZR_DEPT_CD = REC.BIZR_DEPT_CD
                               AND ROWNUM < 4
                              )
                LOOP

                    --종 근무지 감면시작일~종료일은 근무시작일~종료일과 같아야 함. 월별입력이 아니므로.
                    IF( REC2.REDC_FR_DT IS NOT NULL  AND REC2.REDC_TO_DT IS NOT NULL ) THEN
                        IF(       REC2.REDC_FR_DT BETWEEN REC2.WK_FR_DT AND REC2.WK_TO_DT
                              AND REC2.REDC_TO_DT  BETWEEN REC2.WK_FR_DT AND REC2.WK_TO_DT
                              AND REC2.REDC_TO_DT < REC2.REDC_TO_DT
                              ) THEN
                            OUT_RTN := 0;
                            OUT_MSG := '종 근무지의 감면기간은 근무기간 이내이어야 처리가 가능합니다.';
                            RETURN;
                        END IF;
                    END IF;


                    V_CNT := V_CNT + 1;
                    IF V_CNT = 1 THEN   -- 3건까지만 처리가능.
                        V_BF_WK_FIRM_NM_1 := REC2.FIRM;
                        V_BF_WK_BIZR_NO_1 := REC2.BIZR_NO;
                        V_BF_WK_FR_DT_1   := REC2.WK_FR_DT;
                        V_BF_WK_TO_DT_1   := REC2.WK_TO_DT;
                        V_BF_REDC_FR_DT_1 := REC2.REDC_FR_DT;
                        V_BF_REDC_TO_DT_1 := REC2.REDC_TO_DT;
                        V_BF_SITE_SALY_AMT_1        := NVL(REC2.SALY_TT_AMT,0);
                        V_BF_SITE_BONUS_AMT_1       := NVL(REC2.BONUS_TT_AMT,0);
                        V_BF_SITE_DETM_BONUS_AMT_1  := NVL(REC2.DETM_BONUS,0);
                        V_BF_SITE_DELAY_NOTAX_AMT_1 := NVL(REC2.DELAY_NOTAX_AMT,0);
                        V_BF_SITE_CARE_NOTAX_AMT_1  := NVL(REC2.CARE_NOTAX_AMT,0);
                        V_BF_SITE_RECH_NOTAX_AMT_1  := NVL(REC2.RECH_AMT,0);
                        V_BF_SITE_ETC_NOTAX_AMT_1   := NVL(REC2.ETC_NOTAX_AMT,0);
                        V_BF_SITE_APNT_NOTAX_AMT_1  := NVL(REC2.APNT_NOTAX_AMT,0);

                        V_BF_SITE_TRAING_ASSI_ALLOW_1   := NVL(REC2.TRAING_ASSI_ALLOW_AMT,0); --수련보조수당 비과세

                        V_BF_SITE_STXLW_NOTAX_1   := NVL(REC2.STXLW,0);  --전근무지 조특법30조 소득세 감면액1
                        V_BF_SITE_RTXLW_NOTAX_1   := NVL(REC2.RTXLW,0);  --전근무지 조세규약 소득세 감면액1

                    ELSE --V_CNT = 2 THEN
                        /* @VER.2017_18 두번째 종전근무지 변수 설정 조건 변경[항상 마지막 입력된 종전근무지가 종전근무지 2로 설정 되었음.*/
                       IF REC2.ROWNUM = 2 THEN
                            V_BF_WK_FIRM_NM_2 := REC2.FIRM;
                            V_BF_WK_BIZR_NO_2 := REC2.BIZR_NO;
                            V_BF_WK_FR_DT_2   := REC2.WK_FR_DT;
                            V_BF_WK_TO_DT_2   := REC2.WK_TO_DT;
                            V_BF_REDC_FR_DT_2 := REC2.REDC_FR_DT;
                            V_BF_REDC_TO_DT_2 := REC2.REDC_TO_DT;
                        END IF;

                        V_BF_SITE_SALY_AMT_2        := V_BF_SITE_SALY_AMT_2 + NVL(REC2.SALY_TT_AMT,0);
                        V_BF_SITE_BONUS_AMT_2       := V_BF_SITE_BONUS_AMT_2 + NVL(REC2.BONUS_TT_AMT,0);
                        V_BF_SITE_DETM_BONUS_AMT_2  := V_BF_SITE_DETM_BONUS_AMT_2 + NVL(REC2.DETM_BONUS,0);
                        V_BF_SITE_DELAY_NOTAX_AMT_2 := V_BF_SITE_DELAY_NOTAX_AMT_2 + NVL(REC2.DELAY_NOTAX_AMT,0);
                        V_BF_SITE_CARE_NOTAX_AMT_2  := V_BF_SITE_CARE_NOTAX_AMT_2 + NVL(REC2.CARE_NOTAX_AMT,0);
                        V_BF_SITE_RECH_NOTAX_AMT_2  := V_BF_SITE_RECH_NOTAX_AMT_2 + NVL(REC2.RECH_AMT,0);
                        V_BF_SITE_ETC_NOTAX_AMT_2   := V_BF_SITE_ETC_NOTAX_AMT_2 + NVL(REC2.ETC_NOTAX_AMT,0);
                        V_BF_SITE_APNT_NOTAX_AMT_2  := V_BF_SITE_APNT_NOTAX_AMT_2 + NVL(REC2.APNT_NOTAX_AMT,0);
                        V_BF_SITE_STXLW_NOTAX_2     := V_BF_SITE_STXLW_NOTAX_2 + NVL(REC2.STXLW,0);  --전근무지 조특법30조 소득세 감면액1
                        V_BF_SITE_RTXLW_NOTAX_2     := V_BF_SITE_RTXLW_NOTAX_2 + NVL(REC2.RTXLW,0);  --전근무지 조세규약 소득세 감면액1
                        V_BF_SITE_TRAING_ASSI_ALLOW_2   := V_BF_SITE_TRAING_ASSI_ALLOW_2 + NVL(REC2.TRAING_ASSI_ALLOW_AMT,0);

                        IF V_CNT > 2 THEN
                          V_BF_WK_FIRM_NM_CNT_2 := ' 외 ' || TO_CHAR(V_CNT -2) ;
                          V_BF_WK_FIRM_NM_2     := V_BF_WK_FIRM_NM_2 || V_BF_WK_FIRM_NM_CNT_2;

                          /* @VER.2017_18 1페이지 (73)종(전)근무지 (결정세액란의 세액 기재)란의 종전근무지3이 있을경우 출력안되서 해당 필요변수 다시 부활 */
                          IF REC2.ROWNUM = 3 THEN
                              V_BF_WK_BIZR_NO_3 := REC2.BIZR_NO;
                              V_BF_WK_FR_DT_3   := REC2.WK_FR_DT;
                              V_BF_WK_TO_DT_3   := REC2.WK_TO_DT;
                          END IF;
                        END IF;
/*                    ELSE
                        V_BF_WK_FIRM_NM_3 := REC2.FIRM;
                        V_BF_WK_BIZR_NO_3 := REC2.BIZR_NO;
                        V_BF_WK_FR_DT_3   := REC2.WK_FR_DT;
                        V_BF_WK_TO_DT_3   := REC2.WK_TO_DT;
                        V_BF_SITE_SALY_AMT_3        := NVL(REC2.SALY_TT_AMT,0);
                        V_BF_SITE_BONUS_AMT_3       := NVL(REC2.BONUS_TT_AMT,0);
                        V_BF_SITE_DETM_BONUS_AMT_3  := NVL(REC2.DETM_BONUS,0);
                        V_BF_SITE_DELAY_NOTAX_AMT_3 := NVL(REC2.DELAY_NOTAX_AMT,0);
                        V_BF_SITE_CARE_NOTAX_AMT_3  := NVL(REC2.CARE_NOTAX_AMT,0);
                        V_BF_SITE_RECH_NOTAX_AMT_3  := NVL(REC2.RECH_AMT,0);
                        V_BF_SITE_ETC_NOTAX_AMT_3   := NVL(REC2.ETC_NOTAX_AMT,0);*/
                    END IF;
                END LOOP;
                       EXCEPTION
           WHEN OTHERS THEN
                OUT_RTN := 0;
                OUT_MSG := '연말정산결과1 생성오류(대표개인번호 : '||V_RPST_PERS_NO ||', SQLCODE : '||SQLCODE || ':' || SQLERRM || ')';
                RETURN;
            END;
            -- 전근무지 내역을 발췌...
            /*V_BF_SITE_SALY_AMT       := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG, '140', REC.RPST_PERS_NO, null);    -- 전근무지 급여액
            V_BF_SITE_BONUS_AMT        := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG, '141', REC.RPST_PERS_NO, null);    -- 전근무지 상여액
            V_BF_SITE_DETM_BONUS_AMT   := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG, '152', REC.RPST_PERS_NO, null);    -- 전근무지 인정상여액
            V_BF_SITE_INCOME_TAX       := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG, '142', REC.RPST_PERS_NO, null);    -- 전근무지 소득세
            V_BF_SITE_INHAB_TAX        := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG, '143', REC.RPST_PERS_NO, null);    -- 전근무지 주민세*/

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '140', REC.RPST_PERS_NO, null)-- 전근무지 급여액
              INTO V_BF_SITE_SALY_AMT
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '141', REC.RPST_PERS_NO, null)-- 전근무지 상여액
              INTO V_BF_SITE_BONUS_AMT
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '152', REC.RPST_PERS_NO, null)    -- 전근무지 인정상여액
              INTO V_BF_SITE_DETM_BONUS_AMT
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '153', REC.RPST_PERS_NO, null)    -- 전근무지 우리사주조합인출금(@VER.2017_17)
              INTO V_BF_OSC_SOCT_WITHD_AMT
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '167', REC.RPST_PERS_NO, null)    -- 전근무지 주식매수선택이익금액(@VER.2018_14)
              INTO V_BF_STOCK_BUY_AMT
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '142', REC.RPST_PERS_NO, null)    -- 전근무지 소득세
              INTO V_BF_SITE_INCOME_TAX
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '143', REC.RPST_PERS_NO, null)    -- 전근무지 주민세
              INTO V_BF_SITE_INHAB_TAX
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '147', REC.RPST_PERS_NO, null)    -- 전근무지 농특세(@VER.2017_21)
              INTO V_BF_SITE_FMTAX
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '191', REC.RPST_PERS_NO, NULL)    -- 전근무지 감면액:조특법30조
              INTO V_BF_SITE_STXLW_AMT
              FROM DUAL ;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '193', REC.RPST_PERS_NO, NULL)    -- 전근무지 감면액:조특법30조외(@VER.2019_6)
              INTO V_BF_SITE_SMBIZ_BONUS_AMT
              FROM DUAL ;

            V_BF_SITE_STXLW_TAX := V_BF_SITE_STXLW_AMT;
            V_BF_SITE_SMBIZ_BONUS_TAX := V_BF_SITE_SMBIZ_BONUS_AMT;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '192', REC.RPST_PERS_NO, NULL)    -- 전근무지 감면액:조세조약
              INTO V_BF_SITE_RTXLW_TAX
              FROM DUAL ;

            V_BF_SITE_REDC_TAX := V_BF_SITE_STXLW_TAX + V_BF_SITE_RTXLW_TAX + V_BF_SITE_SMBIZ_BONUS_TAX;  -- @VER.2019_6

           --DBMS_OUTPUT.PUT_LINE('S2 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );
            -- 현근무기간 발췌....
--            V_CURR_WK_FR_DT := IN_YY||'0101';
--            V_CURR_WK_TO_DT := IN_YY||'1231';
            V_CURR_WK_FR_DT := REC.WK_FR_DT;
            V_CURR_WK_TO_DT := REC.WK_TO_DT;

            IF V_CURR_WK_FR_DT < IN_YY||'0101' THEN
              V_CURR_WK_FR_DT := IN_YY||'0101';
            ELSIF V_CURR_WK_FR_DT > IN_YY||'1231' THEN
              V_CURR_WK_FR_DT := IN_YY||'0101';
            END IF;

            IF V_CURR_WK_TO_DT < IN_YY||'0101' THEN
              V_CURR_WK_TO_DT := IN_YY||'0101';
            ELSIF V_CURR_WK_TO_DT > IN_YY||'1231' THEN
              V_CURR_WK_TO_DT := IN_YY||'1231';
            END IF;

            -- 현근무지 급여내역 발췌....
            BEGIN
                SELECT NVL(SUM(NVL(A.SALY_AMT,0)),0)
                  INTO V_CURR_SITE_SALY1
                  FROM PAYM440 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_CURR_SITE_SALY1 := 0;
            END;

            -- 현근무지 추가소득내역 발췌....
            -- 부설학교연구보조비('A035400007') 월20만원 초과인 경우 추가소득으로 합산(@VER.2019_8)
            -- 그외의 경우 추가소득으로 처리
            BEGIN
                SELECT NVL(SUM(NVL(
                                   CASE WHEN A.PAY_FG = 'A035400007' THEN
                                             CASE WHEN A.SALY_AMT > 200000 THEN
                                                       A.SALY_AMT - 200000
                                                  ELSE
                                                       0
                                              END
                                        ELSE
                                             A.SALY_AMT
                                    END
                                   ,0)),0)
                  INTO V_CURR_SITE_SALY2
                  FROM PAYM441 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_CURR_SITE_SALY2 := 0;

            END;




         -- 현근무지 급여 = 급여합계 + 추가소득 합계
            V_CURR_SITE_SALY := V_CURR_SITE_SALY1 + V_CURR_SITE_SALY2;


--            IF V_CURR_SITE_SALY < 0  THEN  --2014.1.27. 소득금액이 0 보다 작으면 0으로 만든다..
--                V_CURR_SITE_SALY := 0;
--            END IF;


            --현근무지상여 합계
            BEGIN
                SELECT NVL(SUM(A.BONUS_AMT),0)
                  INTO V_CURR_SITE_BONUS_AMT
                  FROM PAYM440 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_CURR_SITE_BONUS_AMT := 0;
            END;

            --현근무지인정상여 합계
            BEGIN
                SELECT NVL(SUM(A.DETM_BONUS),0)
                  INTO V_CURR_SITE_DETM_BONUS_AMT
                  FROM PAYM440 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_CURR_SITE_DETM_BONUS_AMT := 0;
            END;

            --DBMS_OUTPUT.PUT_LINE('S3 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );

            --현근무지기타비과세합계(모범수당(국고),육아휴직수당,정액급식비(국고),정액급식비(기금),정액급식비(기성회),직급보조비(국고))
            --@VER.2017_8 소득자별근로소득원천징수부(Withhoding_2017.ozr) 2페이지 기재 제외대상 비과세 소득으로 재정의
            BEGIN
                SELECT --NVL(SUM(A.ETC_NOTAX),0)
                       NVL(
                           SUM(NVL(A.ONDUTY_NOTAX,0))    /* 일직료(H02)*/
                          +SUM(NVL(A.OIL_AMT,0))         /* 자가운전보조금(H03)*/
                          +SUM(NVL(A.INFC_NDTY_NOTAX,0)) /* 육아휴직급여 비과세(E01)*/
                          +SUM(NVL(A.FOOD_AMT,0))        /* 비과세 식사대(월10만원이하) (P01) */
                          +SUM(NVL(A.ETC_NOTAX,0))       /* 기타비과세 */
                      ,0)
                  INTO V_ETC_AMT_TAX
                  FROM PAYM440 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_ETC_AMT_TAX := 0;
            END;
            --현근무지 연구보조비 비과세합계
            --추가소득(기관) PAYM441의 부설학교연구보조비('A035400007')에 대해 월20만원 한도로 비과세로 합산 (@VER.2019_8)
            BEGIN
                SELECT NVL(
                            (SELECT NVL(SUM(A.RECH_ACT_NOTAX),0)
                              FROM PAYM440 A
                             WHERE A.YY           = IN_YY
                               AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                               AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                               AND A.SETT_FG      = V_SETT_FG
                               AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                               AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD), 0)
                       +
                       NVL(
                           (SELECT NVL(SUM(LEAST(SALY_AMT, 200000)), 0)
                              FROM PAYM441
                             WHERE YY           = IN_YY
                               AND YRETXA_SEQ   = IN_YRETXA_SEQ
                               AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                               AND SETT_FG      = V_SETT_FG
                               AND RPST_PERS_NO = REC.RPST_PERS_NO
                               AND PAY_FG = 'A035400007'), 0)                            /* 지급구분코드:부설학교연구보조비 */
                       AS RECH_ACT_NOTAX
                  INTO V_RECH_ACT_AMT_TAX
                  FROM DUAL;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_RECH_ACT_AMT_TAX := 0;
            END;
            --현근무지 출산,6세이하자녀 보육 비과세액합계
            BEGIN
                SELECT NVL(SUM(A.CHDBIRTH_CARE_ALLOW),0)
                INTO V_CHDBIRTH_CARE_AMT
                  FROM PAYM440 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_CHDBIRTH_CARE_AMT := 0;
            END;

             --현근무지 직무발명보상금 비과세(R11) @VER.2017_9 -2017년 추가
            BEGIN
                SELECT NVL(SUM(A.DUTY_INVENT_CMPS_AMT_NOTAX),0)
                  INTO V_DUTY_INVENT_CMPS_AMT_NOTAX
                  FROM PAYM440 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_DUTY_INVENT_CMPS_AMT_NOTAX := 0;
            END;

            --현근무지 직무발명보상금 @VER.2018
            BEGIN
                SELECT NVL(SUM(TA1.PAY_AMT),0)
                  INTO V_DUTY_INVENT_CMPS_AMT
                  FROM PAYM571 TA1
                 WHERE SUBSTR(TA1.PAY_DT, 1, 4) = IN_YY
                   AND TA1.RPST_PERS_NO = REC.RPST_PERS_NO;

                V_DUTY_INVENT_CMPS_AMT := V_DUTY_INVENT_CMPS_AMT - V_DUTY_INVENT_CMPS_AMT_NOTAX;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_DUTY_INVENT_CMPS_AMT := 0;
            END;

            --현근무지 야간근로수당 비과세(DELAY_NOTAX_AMT) @VER.2018_3 -2018년 추가
            -- (PAYM280. PAYM281)에서 직접 조회 값을 PAYM440.NGHT_LABOR_ALLOW_NOTAX 조회로 변경(@VER.2018_3_1)
            BEGIN
                 SELECT NVL(SUM(A.NGHT_LABOR_ALLOW_NOTAX),0)
                  INTO V_DELAY_NOTAX_AMT
                  FROM PAYM440 A
                 WHERE A.YY           = IN_YY
                   AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND A.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND A.SETT_FG      = V_SETT_FG
                   AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                   AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD ;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    V_DELAY_NOTAX_AMT := 0;
            END;



            --DBMS_OUTPUT.PUT_LINE('S4 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '154', REC.RPST_PERS_NO, null) -- 현근무지 소득세
              INTO V_INCOME_TAX
              FROM DUAL;

            SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '155', REC.RPST_PERS_NO, null) -- 현근무지 주민세
              INTO V_INHAB_TAX
              FROM DUAL;

            --  현근무지급금액
            V_CURR_SITE_SALY_AMT := V_CURR_SITE_SALY;
            --  현근무지비과세정산액:기재대상 비과세 (@VER.2017_9 직무발명보상금 비과세 추가)
            V_CURR_SITE_AMT_TAX_SETT_AMT :=  V_RECH_ACT_AMT_TAX + V_CHDBIRTH_CARE_AMT + V_DUTY_INVENT_CMPS_AMT_NOTAX;

            --근로소득총급여액 (@VER.2017_17 V_BF_OSC_SOCT_WITHD_AMT 종전근무지 우리사주조합인출금 추가)
            --근로소득총급여액 (@VER.2018_14 V_BF_STOCK_BUY_AMT 종전근무지 주식매수선택이익금액 추가)
            V_LABOR_EARN_TT_SALY_AMT := V_CURR_SITE_SALY_AMT + V_CURR_SITE_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT +
                                        V_BF_SITE_SALY_AMT + V_BF_SITE_BONUS_AMT + V_BF_SITE_DETM_BONUS_AMT + V_BF_OSC_SOCT_WITHD_AMT + V_BF_STOCK_BUY_AMT;

            IF V_CURR_SITE_SALY_AMT + V_CURR_SITE_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT < 0  THEN  --2015.1.24. 근로소득총급여액이 0 보다 근로소득총금액, 현근무지 소득세, 현근무지 주민세를 0으로 만든다..
                V_LABOR_EARN_TT_SALY_AMT := 0;
                V_INCOME_TAX := 0;
                V_INHAB_TAX := 0;
            END IF;

            -- 야간근로수당 비과세(@VER.2018_3)
            -- 시설관리직(환경운영직-청소) 대상자중에 총급여 2500만원 미만 중 연간 240만원 이하의 연장근로, 야간근로수당은 비과세 처리
            IF V_LABOR_EARN_TT_SALY_AMT < 25000000 THEN
                V_DELAY_NOTAX_AMT := LEAST(V_DELAY_NOTAX_AMT, 2400000);
            ELSE
                V_DELAY_NOTAX_AMT := 0;
            END IF;
            --  현근무지비과세정산액:기재대상 비과세 (@VER.2018_3 야간근로수당 비과세 추가)
            V_CURR_SITE_AMT_TAX_SETT_AMT := V_CURR_SITE_AMT_TAX_SETT_AMT + V_DELAY_NOTAX_AMT;

            --DBMS_OUTPUT.PUT_LINE('S5 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );

            IF REC.FORE_TAX_RATE_YN = 'N' THEN --외국인단일세율 적용안할 경우
                 --근로소득공제금액
                /* V_LABOR_EARN_DUC_AMT := SF_SETT_PAYM450_DUC_AMT(IN_YY,'A034500001',V_LABOR_EARN_TT_SALY_AMT);*/
                SELECT SF_SETT_PAYM450_DUC_AMT(IN_YY,'A034500001',V_LABOR_EARN_TT_SALY_AMT)
                  INTO V_LABOR_EARN_DUC_AMT
                  FROM DUAL ;

                -- 근로소득금액
                V_LABOR_EARN_AMT := V_LABOR_EARN_TT_SALY_AMT - V_LABOR_EARN_DUC_AMT;
                -- 차감소득금액 (우선 근로소득금액으로 한다.)
                V_LABOR_TEMP_AMT := V_LABOR_EARN_AMT;

/*@@ZODEM*/
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.1 근로소득금액';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/


/* 인적공제 시작 */
                -- 부양대상자수
                /*V_SPRT_OBJ_PSN_CNT := SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'903',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '903', REC.RPST_PERS_NO)
                  INTO V_SPRT_OBJ_PSN_CNT
                  FROM DUAL;

                -- 장애인수
                /*V_HINDR_CNT := SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'904',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'904',REC.RPST_PERS_NO)
                  INTO V_HINDR_CNT
                  FROM DUAL;

                -- 경로우대 70이상 대상자수
                /*V_PATH_PREF_CNT_70 := SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'906',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'906',REC.RPST_PERS_NO)
                  INTO V_PATH_PREF_CNT_70
                  FROM DUAL;

                -- 교육비 취학전아동수
                /*V_BRED_edu_CNT_6 := SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'915',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'915',REC.RPST_PERS_NO)
                  INTO V_BRED_edu_CNT_6
                  FROM DUAL;

                -- 교육비 초중고등학교 인원수
                /*V_STD_CNT := SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'916',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'916',REC.RPST_PERS_NO)
                  INTO V_STD_CNT
                  FROM DUAL;

                -- 교육비 대학공납금 인원수
                /*V_LRG_STD_CNT := SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'917',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY,IN_YRETXA_SEQ,  V_SETT_FG,'917',REC.RPST_PERS_NO)
                  INTO V_LRG_STD_CNT
                  FROM DUAL;

                -- 본인공제
                /*V_SLF_DUC_AMT := SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'901',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'901',REC.RPST_PERS_NO)
                  INTO V_SLF_DUC_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SLF_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SLF_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_SLF_DUC_AMT
                  FROM DUAL;
/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.2 본인공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                -- 배우자공제액
                /*V_WIFE_DUC_AMT := SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'902',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'902',REC.RPST_PERS_NO)
                  INTO V_WIFE_DUC_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_WIFE_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_WIFE_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_WIFE_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.3 배우자공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- 부양자공제금액
                /*V_SPRT_FM_DUC_AMT := SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'903',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'903',REC.RPST_PERS_NO)
                  INTO V_SPRT_FM_DUC_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SPRT_FM_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SPRT_FM_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_SPRT_FM_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.4 부양자공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */


                -- 경로우대공제금액 70세
                /*V_PATH_PREF_DUC_AMT_70 := SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'906',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'906',REC.RPST_PERS_NO)
                  INTO V_PATH_PREF_DUC_AMT_70
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PATH_PREF_DUC_AMT_70,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PATH_PREF_DUC_AMT_70,2)
                  INTO V_LABOR_TEMP_AMT, V_PATH_PREF_DUC_AMT_70
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.4 공로우대공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/

                -- 장애자공제금액
                /*V_HANDICAP_DUC_AMT := SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'904',REC.RPST_PERS_NO);*/
                SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'904',REC.RPST_PERS_NO)
                  INTO V_HANDICAP_DUC_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HANDICAP_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HANDICAP_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_HANDICAP_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.5 장애인공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */


                -- 부녀자공제액
                IF V_LABOR_EARN_AMT < 30000000 THEN /* 2014년부터 부녀자공제 종합소득금액(근로소득금액) 3천만원 미만만 가능 */
                    SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'908',REC.RPST_PERS_NO)
                      INTO V_WOMN_DUC_AMT
                      FROM DUAL;

                    SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_WOMN_DUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_WOMN_DUC_AMT,2)
                      INTO V_LABOR_TEMP_AMT, V_WOMN_DUC_AMT
                      FROM DUAL;
                END IF;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.6 부녀자공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */


                -- 한부모 공제 : 2013 추가.
                SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '915', REC.RPST_PERS_NO)
                  INTO V_SINGLE_PARENT_DUC_AMT
                  FROM DUAL;
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SINGLE_PARENT_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SINGLE_PARENT_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_SINGLE_PARENT_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.7 한부모공제[인공공제끝]';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */


/* 인적공제 끝 */


--/* 연금보험료공제 시작 */   -- 20151217 연금보험료 소득공제 위치 변경.
                              -- 이동위치 :
--
--                -- 종(전)근무지 국민연금 합산
--                /*V_NPN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'146',REC.RPST_PERS_NO,null);*/
--                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'146',REC.RPST_PERS_NO,null)
--                  INTO V_NPN_INSU_AMT
--                  FROM DUAL;
--
--                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_NPN_INSU_AMT,1),
--                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_NPN_INSU_AMT,2)
--                  INTO V_LABOR_TEMP_AMT, V_NPN_INSU_AMT
--                  FROM DUAL;
--
--                -- 현근무지 국민연금 합산
--                /*V_ADD_NPN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'101',REC.RPST_PERS_NO,null);*/
--                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'101',REC.RPST_PERS_NO,null)
--                  INTO V_ADD_NPN_INSU_AMT
--                  FROM DUAL;
--
--                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_NPN_INSU_AMT,1),
--                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_NPN_INSU_AMT,2)
--                  INTO V_LABOR_TEMP_AMT, V_ADD_NPN_INSU_AMT
--                  FROM DUAL;
--
--                -- 종(전)근무지 공무원연금  합산
--                /*V_PUBPERS_PENS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'139',REC.RPST_PERS_NO,null);*/
--                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'139',REC.RPST_PERS_NO,null)
--                  INTO V_PUBPERS_PENS_AMT
--                  FROM DUAL;
--
--                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PUBPERS_PENS_AMT,1),
--                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PUBPERS_PENS_AMT,2)
--                  INTO V_LABOR_TEMP_AMT, V_PUBPERS_PENS_AMT
--                  FROM DUAL;
--
--                -- 현근무지 공무원연금 합산
--                /*V_ADD_PUBPERS_PENS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'103',REC.RPST_PERS_NO,null);*/
--                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'103',REC.RPST_PERS_NO,null)
--                  INTO V_ADD_PUBPERS_PENS_AMT
--                  FROM DUAL;
--
--                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PUBPERS_PENS_AMT,1),
--                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PUBPERS_PENS_AMT,2)
--                  INTO V_LABOR_TEMP_AMT, V_ADD_PUBPERS_PENS_AMT
--                  FROM DUAL;
--
--                -- 종(전)근무지 사학연금 합산
--                /*V_PSCH_PESN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'145',REC.RPST_PERS_NO,null);*/
--                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'145',REC.RPST_PERS_NO,null)
--                  INTO V_PSCH_PESN_INSU_AMT
--                  FROM DUAL;
--
--                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PSCH_PESN_INSU_AMT,1),
--                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PSCH_PESN_INSU_AMT,2)
--                  INTO V_LABOR_TEMP_AMT, V_PSCH_PESN_INSU_AMT
--                  FROM DUAL;
--
--                -- 현근무지 사학연금 합산
--                /*V_ADD_PSCH_PESN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'102',REC.RPST_PERS_NO,null);*/
--                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'102',REC.RPST_PERS_NO,null)
--                  INTO V_ADD_PSCH_PESN_INSU_AMT
--                  FROM DUAL;
--
--                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PSCH_PESN_INSU_AMT,1),
--                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PSCH_PESN_INSU_AMT,2)
--                  INTO V_LABOR_TEMP_AMT, V_ADD_PSCH_PESN_INSU_AMT
--                  FROM DUAL;
--
--                -- 종(전)근무지 군인연금 합산
--                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'190',REC.RPST_PERS_NO,null)
--                  INTO V_MILITARY_PENS_INSU_AMT
--                  FROM DUAL;
--
--                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_MILITARY_PENS_INSU_AMT,1),
--                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_MILITARY_PENS_INSU_AMT,2)
--                  INTO V_LABOR_TEMP_AMT, V_MILITARY_PENS_INSU_AMT
--                  FROM DUAL;
--
--/* 연금보험료공제 끝 */


/* 특별공제_ 국민건강, 고용, 노인장기요양보험료공제 시작 */
                -- 특별소득공제 합계
                V_SPCL_DUC_AMT := 0;
                -- 표준세액공제 대상금액
                V_STAD_TAXDUC_OBJ_AMT := 0;

                --종(전)근무지 건강보험료 합산
                /*V_PESN_HINS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'148',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'148',REC.RPST_PERS_NO,null)
                  INTO V_PESN_HINS_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PESN_HINS_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PESN_HINS_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_PESN_HINS_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.8 종전근무지 건강보험료 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */


                -- V_SPCL_DUC_AMT : 특별공제 합산 시작
                V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_PESN_HINS_AMT;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_PESN_HINS_AMT;


                --주(현)근무지 건강보험료 합산
                /*V_HINS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'104',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'104',REC.RPST_PERS_NO,null)
                  INTO V_HINS_AMT
                  FROM DUAL;


                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HINS_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HINS_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_HINS_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.9 주(현)근무지 건강보험료 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/


                -- V_SPCL_DUC_AMT : 특별공제 합산 시작
                V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_HINS_AMT;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HINS_AMT;


                --종(전)근무지 고용보험료 합산
                /*V_PESN_EINS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'149',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'149',REC.RPST_PERS_NO,null)
                  INTO V_PESN_EINS_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PESN_EINS_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PESN_EINS_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_PESN_EINS_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.10 종(전)근무지 고용보험료 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- V_SPCL_DUC_AMT : 특별공제 합산 시작
                V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_PESN_EINS_AMT;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_PESN_EINS_AMT;


                --주(현)근무지 고용보험료 합산
                /*V_EINS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'105',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY,IN_YRETXA_SEQ, V_SETT_FG,'105',REC.RPST_PERS_NO,null)
                  INTO V_EINS_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_EINS_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_EINS_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_EINS_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.11 주(현)근무지 고용보험료 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- V_SPCL_DUC_AMT : 특별공제 합산 시작
                V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_EINS_AMT;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_EINS_AMT;

/* 특별공제_ 국민건강, 고용, 노인장기요양보험료공제 끝 */


/** 특별공제 _ 주택자금 소득공제 시작**/

                 /*  공제한도
                         주택임차차입금원리금상환액(항목89+항목90),월세액소득공제(항목91),
                         주택마련저축공제금액(항목103+항목104+항목105+항목106)와 합하여 연 300만원
                         주택임차차입금원리금상환액(항목89+항목90),월세액소득공제(항목91),
                         장기주택저당차입금이자상환액(항목92+항목93+항목94),주택마련저축공제(항목103+항목104+항목105+항목106)와 합하여 연 1000만원
                          (단, 만기30년이상의 장기주택저당차입금이자비용이 포함된 경우 1500만원
                         ‘03.12.31이전 차입분으로 상환기간 10년이상 15년미만의 장기주택저당차입금이자비용이 포함된 경우는 600만원 한도)
                */

                /** 주택임차차입금 원리금상환액 **/

                /*2005년 12월 31일 이전 주택수 2주택 인경우 자 1주택으로 처리 : D022098(이청원)*/
                --2014.1.22 : 2005년 이전 주택취득여부 컬럼을 추가함....

            /*@VER.2016_12 주택자금 외국인은 로직 처리 안되도록 함. (오류검증)에 걸림 */
            IF REC.NATI_FG = 'C010200018' THEN
                BEGIN
                    SELECT NVL(HOUSEHOLDER_YN,'N'), NVL(HOUSEHOLDER_DUPL_DUC_YN, 'N'), NVL(SLF_LOAMT_YN, 'N'), --세대주여부, 세대중복공제여부, 본인차입여부
                           NVL(HOUS_SCALE_YN,'N'), NVL(BASI_MPRC_BLW,'N'),                                    --85제곱미터이하여부, 기준시가 3억이하여부,
                           NVL(HOUS_SEC_YN,'N'), DECODE(RPST_PERS_NO, 'D022098', 1, NVL(HOUS_OWN_CNT,0)),
                           NVL(HOUS_MOG_LOAMT_2005_BF_ACQ_YN, 'N'), NVL(ADDR_ACCORD_YN, 'N')                  --2005이전구입여부, 주소지일치여부
                      INTO V_HOUSEHOLDER_YN, V_HOUSEHOLDER_DUPL_DUC_YN, V_SLF_LOAMT_YN,
                           V_HOUS_SCALE_YN, V_BASI_MPRC_BLW, V_HOUS_SEC_YN, V_HOUS_OWN_CNT,
                           V_HOUS_MOG_LOAMT_2005_BF_YN, V_ADDR_ACCORD_YN
                      FROM PAYM420
                     WHERE BIZR_DEPT_CD = REC.BIZR_DEPT_CD
                       AND YY           = IN_YY
                       AND SETT_FG      = V_SETT_FG
                       AND RPST_PERS_NO = REC.RPST_PERS_NO;

                   EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        V_HOUSEHOLDER_YN := 'N';
                        V_HOUSEHOLDER_DUPL_DUC_YN := 'N';
                        V_SLF_LOAMT_YN := 'N';
                        V_HOUS_SCALE_YN := 'N';
                        V_BASI_MPRC_BLW := 'N';
                        V_HOUS_SEC_YN := 'N';
                        V_HOUS_OWN_CNT := 'N';
                        V_HOUS_MOG_LOAMT_2005_BF_YN := 'N';
                        V_ADDR_ACCORD_YN := 'N';
                END;


                 V_HOUS_LOAMT_AMT1 := REC.HOUS_LOAMT_AMT1;  --특별공제 주택임차원리금대출기관상환액
                 V_HOUS_LOAMT_AMT2 := REC.HOUS_LOAMT_AMT2;  --특별공제 주택임차원리금사인간상환액
                 V_MM_TAX_AMT := REC.MM_TAX_GM ;            --특별공제 월세액공제금액

                --89. 주택임차원리금상환액(대출기관) 공제금액
                   --금융기관 차입 => 세대주=Y(OR 세대주=N,중복공제아님=Y,본인차입=Y), 주택수=0, 국민주택규모이하=Y, 기준시가 3억원하=체크안함, 등기접수일 3개월 이내=Y
                IF V_HOUS_LOAMT_AMT1 > 0
                   AND ((V_HOUSEHOLDER_YN = 'Y' AND V_SLF_LOAMT_YN = 'Y')     -- 세대주이거나. 본인명의 차입금 추가(@VER.2019_14)
                        OR (V_HOUSEHOLDER_YN = 'N' AND V_HOUSEHOLDER_DUPL_DUC_YN = 'Y' AND V_SLF_LOAMT_YN = 'Y')) --세대원인경우 중복공제하지않고 본인임차차입금인경우
                   AND V_HOUS_OWN_CNT = 0 AND V_HOUS_SCALE_YN = 'Y' AND V_HOUS_SEC_YN = 'Y'
                THEN
                    V_HOUS_LOAMT_AMT1 := TRUNC(V_HOUS_LOAMT_AMT1 * 40 / 100);
                    IF V_HOUS_LOAMT_AMT1 > 3000000 THEN        -- 300만원 한도..
                        V_HOUS_LOAMT_AMT1 := 3000000;
                    END IF;
                ELSE
                    V_HOUS_LOAMT_AMT1 := 0;
                END IF;

                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                IF( V_HOUS_LOAMT_AMT1 > V_LABOR_TEMP_AMT ) THEN
                    V_HOUS_LOAMT_AMT1 := V_LABOR_TEMP_AMT;
                END IF;

                -- 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_LOAMT_AMT1,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_LOAMT_AMT1,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_LOAMT_AMT1
                  FROM DUAL;

                -- 특별공제합산
                V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_HOUS_LOAMT_AMT1;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_LOAMT_AMT1;


                --90. 주택임차원리금상환액(거주자) 공제금액
                IF V_HOUS_LOAMT_AMT2 > 0
                   AND ((V_HOUSEHOLDER_YN = 'Y' AND V_SLF_LOAMT_YN = 'Y')     -- 세대주이거나. 본인명의 차입금 추가(@VER.2019_14)
                        OR (V_HOUSEHOLDER_YN = 'N' AND V_HOUSEHOLDER_DUPL_DUC_YN = 'Y' AND V_SLF_LOAMT_YN = 'Y')) --세대원인경우 중복공제하지않고 본인임차차입금인경우
                   AND V_HOUS_OWN_CNT = 0 AND V_HOUS_SCALE_YN = 'Y' AND V_HOUS_SEC_YN = 'Y'
                THEN
                    V_HOUS_LOAMT_AMT2 := TRUNC(V_HOUS_LOAMT_AMT2 * 40 / 100);
                    IF V_LABOR_EARN_TT_SALY_AMT  >  50000000 THEN    -- 총급여 5천만원  이하
                          V_HOUS_LOAMT_AMT2 := 0;
                    END IF;
                    IF V_HOUS_LOAMT_AMT2 + V_HOUS_LOAMT_AMT1 > 3000000 THEN        -- 300만원 한도..
                        V_HOUS_LOAMT_AMT2 := 3000000 - V_HOUS_LOAMT_AMT1;
                    END IF;
                ELSE
                    V_HOUS_LOAMT_AMT2 := 0;
                END IF;

--                DBMS_OUTPUT.PUT_LINE('V_HOUS_LOAMT_AMT1 = '||TO_CHAR(V_HOUS_LOAMT_AMT1) );
--                DBMS_OUTPUT.PUT_LINE('V_HOUS_LOAMT_AMT2 = '||TO_CHAR(V_HOUS_LOAMT_AMT2) );


                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                IF( V_HOUS_LOAMT_AMT2 > V_LABOR_TEMP_AMT ) THEN
                    V_HOUS_LOAMT_AMT2 := V_LABOR_TEMP_AMT;
                END IF;

                -- 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_LOAMT_AMT2,1),
                      SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_LOAMT_AMT2,2)
                 INTO V_LABOR_TEMP_AMT, V_HOUS_LOAMT_AMT2
                 FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.13 주택임차원리금상환액(거주자)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                V_SPCL_DUC_AMT := V_SPCL_DUC_AMT + V_HOUS_LOAMT_AMT2;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_LOAMT_AMT2;

                /* 주택임차차입금 소득공제액 합계 */
                V_HOUS_FUND_DUC_HAP_AMT := V_HOUS_LOAMT_AMT1 + V_HOUS_LOAMT_AMT2;



                /** 장기주택 저당차임금 소득공제  **/

                --37-다.특별공제장기주택저당차입금 이자상환액 15년 미만
                --37-다.특별공제장기주택저당차입금 이자상환액 15년~29년
                --37-다.특별공제장기주택저당차입금 이자상환액 30년 이상
                --37-다.특별공제장기주택저당차입금 이자상환액 2012년 이후 고정금리(비거치식)
                --37-다.특별공제장기주택저당차입금 이자상환액 2012년 이후 기타
                -- 장기주택저당차입금 => 세대주=체크안함, 주택수=1, 국민주택규모이하=Y(2014년 무관), 기준시가 3억이하(2014년 4억이하)=Y

                V_HOUS_MOG_ITT_1   := REC.HOUS_MOG_ITT_1; --2011년 이전 15년 미만
                V_HOUS_MOG_ITT_2   := REC.HOUS_MOG_ITT_2; --2011년 이전 15년~29년
                V_HOUS_MOG_ITT_3   := REC.HOUS_MOG_ITT_3; --2011년 이전 30년 이상
                V_HOUS_MOG_ITT_4   := REC.HOUS_MOG_ITT_4; --2012년 이후 고정금리(비거치식)
                V_HOUS_MOG_ITT_5   := REC.HOUS_MOG_ITT_5; --2012년 이후 일반
                V_HOUS_MOG_ITT_6   := REC.HOUS_MOG_ITT_6; --2015년 이후 15년이상 고정금리 AND 비거치식 (＠VER.2015)
                V_HOUS_MOG_ITT_7   := REC.HOUS_MOG_ITT_7; --2015년 이후 15년이상 고정금리 OR 비거치식 (＠VER.2015)
                V_HOUS_MOG_ITT_8   := REC.HOUS_MOG_ITT_8; --2015년 이후 15년이상 그밖의 대출 (＠VER.2015)
                V_HOUS_MOG_ITT_9   := REC.HOUS_MOG_ITT_9; --2015년 이후 10년~15년미만 고정금리 OR 비거치식 (＠VER.2015)

--                DBMS_OUTPUT.PUT_LINE('V_HOUS_MOG_ITT_2 = '||TO_CHAR(V_HOUS_MOG_ITT_2) );
--                DBMS_OUTPUT.PUT_LINE('V_HOUS_MOG_ITT_3 = '||TO_CHAR(V_HOUS_MOG_ITT_3) );
                V_LOAN_DT := '';

                /* V_HOUS_MOG_ITT_1 : 2011년 이전 10년이상 15년미만 */
                IF V_HOUS_MOG_ITT_1 > 0 THEN
                      BEGIN
                        SELECT MAX(LOAN_DT) --2013년 추가. 차입일자에 따라 요구조건이 다름.
                          INTO V_LOAN_DT
                           FROM PAYM433
                          WHERE YY           = IN_YY
                            AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                            AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                            AND SETT_FG      = V_SETT_FG
                            AND RPST_PERS_NO = REC.RPST_PERS_NO
                            AND ITT_RFND_CD = 'A035800001' /*2011년 이전 차입분 10년이상~15년미만*/
                          ;
                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            V_LOAN_DT := '';
                    END;
                  IF( V_LOAN_DT >= '20060101' ) THEN
                      IF V_HOUS_OWN_CNT = 1 AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_1 > 6000000 THEN        --15년 미만 600만원 한도..
                              V_HOUS_MOG_ITT_1 := 6000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_1 := 0;
                      END IF;
                  ELSE
                      IF (V_HOUS_OWN_CNT = 1 OR (V_HOUS_OWN_CNT > 1 AND V_HOUS_MOG_LOAMT_2005_BF_YN ='Y')) AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101')  THEN
                          IF V_HOUS_MOG_ITT_1 > 6000000 THEN        --15년 미만 600만원 한도..
                              V_HOUS_MOG_ITT_1 := 6000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_1 := 0;
                      END IF;

                  END IF;
                END IF;

                /* V_HOUS_MOG_ITT_2 : 2011년 이전 15년~29년 */
                IF V_HOUS_MOG_ITT_2 > 0 THEN
                    BEGIN
                        SELECT MAX(LOAN_DT) --2013년 추가. 차입일자에 따라 요구조건이 다름.
                          INTO V_LOAN_DT
                           FROM PAYM433
                          WHERE YY           = IN_YY
                            AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                            AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                            AND SETT_FG      = V_SETT_FG
                            AND RPST_PERS_NO = REC.RPST_PERS_NO
                            AND ITT_RFND_CD = 'A035800002' /*2011년 이전 차입분 15년이상~30년미만*/
                          ;

                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            V_LOAN_DT := '';
                    END;

                  IF( V_LOAN_DT >= '20060101' ) THEN

                      IF V_HOUS_OWN_CNT = 1 AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_2 > 10000000 THEN        --15년~29년 1000만원 한도..
                              V_HOUS_MOG_ITT_2 := 10000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_2 := 0;
                      END IF;
                  ELSE
                      IF (V_HOUS_OWN_CNT = 1 OR (V_HOUS_OWN_CNT > 1 AND V_HOUS_MOG_LOAMT_2005_BF_YN ='Y')) AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') THEN
                          IF V_HOUS_MOG_ITT_2 > 10000000 THEN        --15년~29년 1000만원 한도..
                              V_HOUS_MOG_ITT_2 := 10000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_2 := 0;
                      END IF;
                  END IF;

                END IF;

                /* V_HOUS_MOG_ITT_3 : 2011년 이전 30년 이상 */
                IF V_HOUS_MOG_ITT_3 > 0 THEN
                    BEGIN
                        SELECT MAX(LOAN_DT) --2013년 추가. 차입일자에 따라 요구조건이 다름.
                          INTO V_LOAN_DT
                           FROM PAYM433
                          WHERE YY           = IN_YY
                            AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                            AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                            AND SETT_FG      = V_SETT_FG
                            AND RPST_PERS_NO = REC.RPST_PERS_NO
                            AND ITT_RFND_CD = 'A035800003' /*2011년 30년이상*/
                          ;
                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            V_LOAN_DT := '';
                     END;

                  IF( V_LOAN_DT >= '20060101' ) THEN
                          IF V_HOUS_OWN_CNT = 1 AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') AND V_BASI_MPRC_BLW = 'Y' THEN
                              IF V_HOUS_MOG_ITT_3 > 15000000 THEN        --30년 이상 1500만원 한도..
                                  V_HOUS_MOG_ITT_3 := 15000000;
                              END IF;
                          ELSE
                            V_HOUS_MOG_ITT_3 := 0;
                          END IF;

                  ELSE
                          IF (V_HOUS_OWN_CNT = 1 OR (V_HOUS_OWN_CNT > 1 AND V_HOUS_MOG_LOAMT_2005_BF_YN ='Y')) AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') THEN
                              IF V_HOUS_MOG_ITT_3 > 15000000 THEN        --30년 이상 1500만원 한도..
                                  V_HOUS_MOG_ITT_3 := 15000000;
                              END IF;
                          ELSE
                            V_HOUS_MOG_ITT_3 := 0;
                          END IF;
                  END IF;

                END IF;

                /* V_HOUS_MOG_ITT_4 : 2012년 이후 차입분 고정금리 또는 비거치식인 경우*/
                IF V_HOUS_MOG_ITT_4 > 0 THEN
                    SELECT MAX(LOAN_DT) --2013년 추가. 차입일자에 따라 요구조건이 다름.
                      INTO V_LOAN_DT
                       FROM PAYM433
                      WHERE YY           = IN_YY
                        AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                        AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                        AND SETT_FG      = V_SETT_FG
                        AND RPST_PERS_NO = REC.RPST_PERS_NO
                        AND ITT_RFND_CD = 'A035800004'
                      ;
                  IF( V_LOAN_DT >= '20060101' ) THEN
                      IF V_HOUS_OWN_CNT = 1 AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_4 > 15000000 THEN        --2012년 이후 고정금리(비거치식) 1500만원 한도..
                              V_HOUS_MOG_ITT_4 := 15000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_4 := 0;
                      END IF;
                  ELSE
                      IF (V_HOUS_OWN_CNT = 1 OR (V_HOUS_OWN_CNT > 1 AND V_HOUS_MOG_LOAMT_2005_BF_YN ='Y')) AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') THEN
                          IF V_HOUS_MOG_ITT_4 > 15000000 THEN        --2012년 이후 고정금리(비거치식) 1500만원 한도..
                              V_HOUS_MOG_ITT_4 := 15000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_4 := 0;
                      END IF;
                  END IF;
                END IF;

                /* V_HOUS_MOG_ITT_5 : 2012년 이후 차입분 일반적인 경우*/
                IF V_HOUS_MOG_ITT_5 > 0 THEN

                    SELECT MAX(LOAN_DT) --2013년 추가. 차입일자에 따라 요구조건이 다름.
                      INTO V_LOAN_DT
                       FROM PAYM433
                      WHERE YY           = IN_YY
                        AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                        AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                        AND SETT_FG      = V_SETT_FG
                        AND RPST_PERS_NO = REC.RPST_PERS_NO
                        AND ITT_RFND_CD = 'A035800005'
                      ;
                  IF( V_LOAN_DT >= '20060101' ) THEN
                      IF V_HOUS_OWN_CNT = 1 AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101') AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_5 > 5000000 THEN        --2012년 이후 일반 500만원 한도..
                              V_HOUS_MOG_ITT_5 := 5000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_5 := 0;
                      END IF;

                  ELSE
                      IF (V_HOUS_OWN_CNT = 1 OR (V_HOUS_OWN_CNT > 1 AND V_HOUS_MOG_LOAMT_2005_BF_YN ='Y')) AND (V_HOUS_SCALE_YN = 'Y' OR V_LOAN_DT >= '20140101')  THEN
                          IF V_HOUS_MOG_ITT_5 > 5000000 THEN        --2012년 이후 일반 500만원 한도..
                              V_HOUS_MOG_ITT_5 := 5000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_5 := 0;
                      END IF;
                  END IF;
                END IF;

                /*＠VER.2015 2015년 추가사항*/
                /* V_HOUS_MOG_ITT_6 : 2015년 이후 15년이상 고정금리 AND 비거치식*/
                IF V_HOUS_MOG_ITT_6 > 0 THEN

                      /* 1주택, 취득시기준시가5억원 이하 */
                      IF V_HOUS_OWN_CNT = 1 AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_6 > 18000000 THEN        --2015년 이후 15년이상 고정금리 AND 비거치식 1800만원 한도..
                              V_HOUS_MOG_ITT_6 := 18000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_6 := 0;
                      END IF;

                END IF;
                /* V_HOUS_MOG_ITT_7 : 2015년 이후 15년이상 고정금리 OR 비거치식*/
                IF V_HOUS_MOG_ITT_7 > 0 THEN

                      /* 1주택, 취득시기준시가5억원 이하 */
                      IF V_HOUS_OWN_CNT = 1 AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_7 > 15000000 THEN        --2015년 이후 15년이상 고정금리 OR 비거치식 1500만원 한도..
                              V_HOUS_MOG_ITT_7 := 15000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_7 := 0;
                      END IF;

                END IF;
                /* V_HOUS_MOG_ITT_8 : 2015년 이후 15년이상 기타대출*/
                IF V_HOUS_MOG_ITT_8 > 0 THEN

                      /* 1주택, 취득시기준시가5억원 이하 */
                      IF V_HOUS_OWN_CNT = 1 AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_8 > 5000000 THEN        --2015년 이후 15년이상 기타대출 500만원 한도..
                              V_HOUS_MOG_ITT_8 := 5000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_8 := 0;
                      END IF;

                END IF;
                 /* V_HOUS_MOG_ITT_9 : 2015년 이후 10년이상~15년미만 고정금리 OR 비거치식*/
                IF V_HOUS_MOG_ITT_9 > 0 THEN

                      /* 1주택, 취득시기준시가5억원 이하 */
                      IF V_HOUS_OWN_CNT = 1 AND V_BASI_MPRC_BLW = 'Y' THEN
                          IF V_HOUS_MOG_ITT_9 > 3000000 THEN        --2015년 이후 10년이상~15년미만 고정금리 OR 비거치식 300만원 한도..
                              V_HOUS_MOG_ITT_9 := 3000000;
                          END IF;
                      ELSE
                        V_HOUS_MOG_ITT_9 := 0;
                      END IF;

                END IF;

--                DBMS_OUTPUT.PUT_LINE('V_HOUS_MOG_ITT_2 = '||TO_CHAR(V_HOUS_MOG_ITT_2) );
--                DBMS_OUTPUT.PUT_LINE('V_HOUS_MOG_ITT_3 = '||TO_CHAR(V_HOUS_MOG_ITT_3) );

              /* ＠VER.2015 6(1800), 7(1500), 3(1500), 4(1500), 2(1000), 1(600), 5(500), 8(500), 9,(300) 한도 순 */
             IF V_HOUS_MOG_ITT_6 > 0 THEN
                IF V_HOUS_MOG_ITT_6 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN  --통합1800만원 한도..
                   V_HOUS_MOG_ITT_6 := 18000000 - V_HOUS_FUND_DUC_HAP_AMT;
                   V_HOUS_MOG_ITT_7 := 0;
                   V_HOUS_MOG_ITT_3 := 0;
                   V_HOUS_MOG_ITT_4 := 0;
                   V_HOUS_MOG_ITT_2 := 0;
                   V_HOUS_MOG_ITT_1 := 0;
                   V_HOUS_MOG_ITT_5 := 0;
                   V_HOUS_MOG_ITT_8 := 0;
                   V_HOUS_MOG_ITT_9 := 0;
                ELSE
                  IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                     V_HOUS_MOG_ITT_7 := 18000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_6);
                     V_HOUS_MOG_ITT_3 := 0;
                       V_HOUS_MOG_ITT_4 := 0;
                     V_HOUS_MOG_ITT_2 := 0;
                     V_HOUS_MOG_ITT_1 := 0;
                     V_HOUS_MOG_ITT_5 := 0;
                     V_HOUS_MOG_ITT_8 := 0;
                     V_HOUS_MOG_ITT_9 := 0;
                  ELSE
                    IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                       V_HOUS_MOG_ITT_3 := 18000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7);
                          V_HOUS_MOG_ITT_4 := 0;
                       V_HOUS_MOG_ITT_2 := 0;
                       V_HOUS_MOG_ITT_1 := 0;
                       V_HOUS_MOG_ITT_5 := 0;
                       V_HOUS_MOG_ITT_8 := 0;
                       V_HOUS_MOG_ITT_9 := 0;
                     ELSE
                       IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                          V_HOUS_MOG_ITT_4 := 18000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3);
                          V_HOUS_MOG_ITT_2 := 0;
                          V_HOUS_MOG_ITT_1 := 0;
                          V_HOUS_MOG_ITT_5 := 0;
                          V_HOUS_MOG_ITT_8 := 0;
                          V_HOUS_MOG_ITT_9 := 0;
                       ELSE
                         IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                            V_HOUS_MOG_ITT_2 := 18000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4);
                            V_HOUS_MOG_ITT_1 := 0;
                            V_HOUS_MOG_ITT_5 := 0;
                            V_HOUS_MOG_ITT_8 := 0;
                            V_HOUS_MOG_ITT_9 := 0;
                         ELSE
                           IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                              V_HOUS_MOG_ITT_1 := 18000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2);
                              V_HOUS_MOG_ITT_5 := 0;
                              V_HOUS_MOG_ITT_8 := 0;
                              V_HOUS_MOG_ITT_9 := 0;
                           ELSE
                             IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                                V_HOUS_MOG_ITT_5 := 18000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1);
                                V_HOUS_MOG_ITT_8 := 0;
                                V_HOUS_MOG_ITT_9 := 0;
                             ELSE
                               IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                                  V_HOUS_MOG_ITT_8 := 18000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5);
                                  V_HOUS_MOG_ITT_9 := 0;
                                ELSE
                                  IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 18000000 THEN
                                     V_HOUS_MOG_ITT_9 :=  18000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8);
                                  END IF;
                                END IF;
                              END IF;
                            END IF;
                          END IF;
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                ELSIF V_HOUS_MOG_ITT_7 > 0 AND V_HOUS_MOG_ITT_6 = 0  THEN
                   IF V_HOUS_MOG_ITT_7 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN --통합1500만원 한도..
                      V_HOUS_MOG_ITT_7 := 15000000 - V_HOUS_FUND_DUC_HAP_AMT;
                      V_HOUS_MOG_ITT_3 := 0;
                        V_HOUS_MOG_ITT_4 := 0;
                      V_HOUS_MOG_ITT_2 := 0;
                      V_HOUS_MOG_ITT_1 := 0;
                      V_HOUS_MOG_ITT_5 := 0;
                      V_HOUS_MOG_ITT_8 := 0;
                      V_HOUS_MOG_ITT_9 := 0;
                   ELSE
                     IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 > 15000000 THEN
                        V_HOUS_MOG_ITT_3 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_7);
                        V_HOUS_MOG_ITT_4 := 0;
                        V_HOUS_MOG_ITT_2 := 0;
                        V_HOUS_MOG_ITT_1 := 0;
                        V_HOUS_MOG_ITT_5 := 0;
                        V_HOUS_MOG_ITT_8 := 0;
                        V_HOUS_MOG_ITT_9 := 0;
                     ELSE
                       IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 > 15000000 THEN
                          V_HOUS_MOG_ITT_4 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 );
                          V_HOUS_MOG_ITT_2 := 0;
                          V_HOUS_MOG_ITT_1 := 0;
                          V_HOUS_MOG_ITT_5 := 0;
                          V_HOUS_MOG_ITT_8 := 0;
                          V_HOUS_MOG_ITT_9 := 0;
                       ELSE
                         IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 > 15000000 THEN
                            V_HOUS_MOG_ITT_2 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4);
                            V_HOUS_MOG_ITT_1 := 0;
                            V_HOUS_MOG_ITT_5 := 0;
                            V_HOUS_MOG_ITT_8 := 0;
                            V_HOUS_MOG_ITT_9 := 0;
                         ELSE
                           IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 > 15000000 THEN
                              V_HOUS_MOG_ITT_1 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 +V_HOUS_MOG_ITT_2 );
                              V_HOUS_MOG_ITT_5 := 0;
                              V_HOUS_MOG_ITT_8 := 0;
                              V_HOUS_MOG_ITT_9 := 0;
                           ELSE
                             IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5  > 15000000 THEN
                                V_HOUS_MOG_ITT_5 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 +V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1);
                                V_HOUS_MOG_ITT_8 := 0;
                                V_HOUS_MOG_ITT_9 := 0;
                             ELSE
                               IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8  > 15000000 THEN
                                  V_HOUS_MOG_ITT_8 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 +V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 );
                                  V_HOUS_MOG_ITT_9 := 0;
                               ELSE
                                 IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 > 15000000 THEN
                                    V_HOUS_MOG_ITT_9 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 +V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 );
                                 END IF;
                               END IF;
                             END IF;
                           END IF;
                         END IF;
                       END IF;
                     END IF;
                   END IF;
                ELSIF V_HOUS_MOG_ITT_3 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7) = 0 THEN
                   IF V_HOUS_MOG_ITT_3 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                      V_HOUS_MOG_ITT_3 := 15000000 - V_HOUS_FUND_DUC_HAP_AMT;
                      V_HOUS_MOG_ITT_4 := 0;
                      V_HOUS_MOG_ITT_2 := 0;
                      V_HOUS_MOG_ITT_1 := 0;
                      V_HOUS_MOG_ITT_5 := 0;
                      V_HOUS_MOG_ITT_8 := 0;
                      V_HOUS_MOG_ITT_9 := 0;
                  ELSE
                    IF V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                       V_HOUS_MOG_ITT_4 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_3);
                       V_HOUS_MOG_ITT_2 := 0;
                       V_HOUS_MOG_ITT_1 := 0;
                       V_HOUS_MOG_ITT_5 := 0;
                       V_HOUS_MOG_ITT_8 := 0;
                       V_HOUS_MOG_ITT_9 := 0;
                    ELSE
                      IF V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN
                         V_HOUS_MOG_ITT_2 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4);
                         V_HOUS_MOG_ITT_1 := 0;
                         V_HOUS_MOG_ITT_5 := 0;
                         V_HOUS_MOG_ITT_8 := 0;
                         V_HOUS_MOG_ITT_9 := 0;
                      ELSE
                        IF V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN
                           V_HOUS_MOG_ITT_1 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2);
                           V_HOUS_MOG_ITT_5 := 0;
                           V_HOUS_MOG_ITT_8 := 0;
                           V_HOUS_MOG_ITT_9 := 0;
                        ELSE
                          IF V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN
                             V_HOUS_MOG_ITT_5 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1);
                             V_HOUS_MOG_ITT_8 := 0;
                             V_HOUS_MOG_ITT_9 := 0;
                          ELSE
                            IF V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN
                               V_HOUS_MOG_ITT_8 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5);
                               V_HOUS_MOG_ITT_9 := 0;
                            ELSE
                              IF V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN
                                 V_HOUS_MOG_ITT_9 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8);
                              END IF;
                            END IF;
                          END IF;
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                ELSIF V_HOUS_MOG_ITT_4 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3) = 0 THEN
                   IF V_HOUS_MOG_ITT_4 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                      V_HOUS_MOG_ITT_4 := 15000000 - V_HOUS_FUND_DUC_HAP_AMT;
                      V_HOUS_MOG_ITT_2 := 0;
                      V_HOUS_MOG_ITT_1 := 0;
                      V_HOUS_MOG_ITT_5 := 0;
                      V_HOUS_MOG_ITT_8 := 0;
                      V_HOUS_MOG_ITT_9 := 0;
                   ELSE
                     IF V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                        V_HOUS_MOG_ITT_2 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_4);
                        V_HOUS_MOG_ITT_1 := 0;
                        V_HOUS_MOG_ITT_5 := 0;
                        V_HOUS_MOG_ITT_8 := 0;
                        V_HOUS_MOG_ITT_9 := 0;
                     ELSE
                       IF V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                          V_HOUS_MOG_ITT_1 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 );
                          V_HOUS_MOG_ITT_5 := 0;
                          V_HOUS_MOG_ITT_8 := 0;
                          V_HOUS_MOG_ITT_9 := 0;
                       ELSE
                         IF V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                            V_HOUS_MOG_ITT_5 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 );
                            V_HOUS_MOG_ITT_8 := 0;
                            V_HOUS_MOG_ITT_9 := 0;
                         ELSE
                           IF V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                              V_HOUS_MOG_ITT_8 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 );
                              V_HOUS_MOG_ITT_9 := 0;
                           ELSE
                             IF V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 15000000 THEN  --통합1500만원 한도..
                                V_HOUS_MOG_ITT_9 := 15000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8);
                             END IF;
                           END IF;
                         END IF;
                       END IF;
                     END IF;
                   END IF;
                ELSIF  V_HOUS_MOG_ITT_2 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4) = 0 THEN
                   IF V_HOUS_MOG_ITT_2 + V_HOUS_FUND_DUC_HAP_AMT > 10000000 THEN  --통합1000만원 한도..
                      V_HOUS_MOG_ITT_2 := 10000000 - V_HOUS_FUND_DUC_HAP_AMT;
                      V_HOUS_MOG_ITT_1 := 0;
                      V_HOUS_MOG_ITT_5 := 0;
                      V_HOUS_MOG_ITT_8 := 0;
                      V_HOUS_MOG_ITT_9 := 0;
                   ELSE
                     IF V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_FUND_DUC_HAP_AMT > 10000000 THEN  --통합1000만원 한도..
                        V_HOUS_MOG_ITT_1 := 10000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_2);
                        V_HOUS_MOG_ITT_5 := 0;
                        V_HOUS_MOG_ITT_8 := 0;
                        V_HOUS_MOG_ITT_9 := 0;
                     ELSE
                       IF V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_FUND_DUC_HAP_AMT > 10000000 THEN  --통합1000만원 한도..
                          V_HOUS_MOG_ITT_5 := 10000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1);
                          V_HOUS_MOG_ITT_8 := 0;
                          V_HOUS_MOG_ITT_9 := 0;
                       ELSE
                         IF V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_FUND_DUC_HAP_AMT > 10000000 THEN  --통합1000만원 한도..
                            V_HOUS_MOG_ITT_8 := 10000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5);
                            V_HOUS_MOG_ITT_9 := 0;
                         ELSE
                           IF V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 10000000 THEN  --통합1000만원 한도..
                              V_HOUS_MOG_ITT_9 := 10000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8);
                           END IF;
                         END IF;
                       END IF;
                     END IF;
                   END IF;
                ELSIF V_HOUS_MOG_ITT_1 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2) = 0 THEN
                  IF V_HOUS_MOG_ITT_1 + V_HOUS_FUND_DUC_HAP_AMT > 6000000 THEN  --통합600만원 한도..
                      V_HOUS_MOG_ITT_1 := 6000000 - V_HOUS_FUND_DUC_HAP_AMT;
                      V_HOUS_MOG_ITT_5 := 0;
                      V_HOUS_MOG_ITT_8 := 0;
                      V_HOUS_MOG_ITT_9 := 0;
                  ELSE
                    IF V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_FUND_DUC_HAP_AMT > 6000000 THEN  --통합600만원 한도..
                       V_HOUS_MOG_ITT_5 := 6000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_1);
                       V_HOUS_MOG_ITT_8 := 0;
                       V_HOUS_MOG_ITT_9 := 0;
                    ELSE
                      IF V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8+ V_HOUS_FUND_DUC_HAP_AMT > 6000000 THEN  --통합600만원 한도..
                         V_HOUS_MOG_ITT_8 := 6000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5);
                         V_HOUS_MOG_ITT_9 := 0;
                      ELSE
                        IF V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8+ V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 6000000 THEN  --통합600만원 한도..
                           V_HOUS_MOG_ITT_9 := 6000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8);
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                ELSIF V_HOUS_MOG_ITT_5 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1) = 0 THEN
                   IF V_HOUS_MOG_ITT_5 + V_HOUS_FUND_DUC_HAP_AMT > 5000000 THEN  --통합500만원 한도..
                      V_HOUS_MOG_ITT_5 := 5000000 - V_HOUS_FUND_DUC_HAP_AMT;
                      V_HOUS_MOG_ITT_8 := 0;
                      V_HOUS_MOG_ITT_9 := 0;
                   ELSE
                     IF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_FUND_DUC_HAP_AMT > 5000000 THEN  --통합500만원 한도..
                        V_HOUS_MOG_ITT_8 := 5000000 -(V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_5);
                        V_HOUS_MOG_ITT_9 := 0;
                     ELSE
                       IF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 5000000 THEN  --통합500만원 한도..
                          V_HOUS_MOG_ITT_9 := 5000000 -(V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8);
                       END IF;
                     END IF;
                   END IF;
                ELSIF V_HOUS_MOG_ITT_8 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5) = 0 THEN
                   IF V_HOUS_MOG_ITT_8 + V_HOUS_FUND_DUC_HAP_AMT > 5000000 THEN  --통합500만원 한도..
                      V_HOUS_MOG_ITT_8 := 5000000 - V_HOUS_FUND_DUC_HAP_AMT;
                      V_HOUS_MOG_ITT_9 := 0;
                   ELSE
                     IF V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 5000000 THEN  --통합500만원 한도..
                        V_HOUS_MOG_ITT_9 := 5000000 - (V_HOUS_FUND_DUC_HAP_AMT + V_HOUS_MOG_ITT_8);
                     END IF;
                   END IF;
                ELSIF V_HOUS_MOG_ITT_9 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8) = 0 THEN
                   IF V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT > 3000000 THEN  --통합300만원 한도..
                      V_HOUS_MOG_ITT_9 := 3000000 - V_HOUS_FUND_DUC_HAP_AMT;
                   END IF;
                END IF;

          -------------------------

                IF  V_HOUS_MOG_ITT_1 <  0 THEN
                    V_HOUS_MOG_ITT_1  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_1,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_1,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_1
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.14 장기주택저당1';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_1;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_1;

                IF  V_HOUS_MOG_ITT_2 <  0 THEN
                    V_HOUS_MOG_ITT_2  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_2,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_2,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_2
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.15 장기주택저당2';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );   */

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_2;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_2;

                IF  V_HOUS_MOG_ITT_3 <  0 THEN
                    V_HOUS_MOG_ITT_3  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_3,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_3,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_3
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.16 장기주택저당3';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );   */

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_3;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_3;


                IF  V_HOUS_MOG_ITT_4 <  0 THEN
                    V_HOUS_MOG_ITT_4  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_4,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_4,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_4
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.17 장기주택저당4';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_4;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_4;



                IF  V_HOUS_MOG_ITT_5 <  0 THEN
                    V_HOUS_MOG_ITT_5  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_5,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_5,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_5
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.18 장기주택저당5';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_5;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_5;

                /* ＠VER.2015 2015년 추가사항 */
                IF  V_HOUS_MOG_ITT_6 <  0 THEN
                    V_HOUS_MOG_ITT_6  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_6,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_6,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_6
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.19 장기주택저당6';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_6;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_6;

                IF  V_HOUS_MOG_ITT_7 <  0 THEN
                    V_HOUS_MOG_ITT_7  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_7,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_7,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_7
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.20 장기주택저당7';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_7;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_7;

                IF  V_HOUS_MOG_ITT_8 <  0 THEN
                    V_HOUS_MOG_ITT_8  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_8,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_8,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_8
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.21 장기주택저당8';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );    */

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_8;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_8;

                IF  V_HOUS_MOG_ITT_9 <  0 THEN
                    V_HOUS_MOG_ITT_9  :=  0;
                END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_9,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_MOG_ITT_9,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_MOG_ITT_9
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.22 장기주택저당9 [주택자금공제 끝]';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_HOUS_MOG_ITT_9;
                V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HOUS_MOG_ITT_9;

               --DBMS_OUTPUT.PUT_LINE('S11 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );

                --
                V_HOUS_FUND_DUC_2_AMT := V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_5 +
                                         V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 ;

                /* 주택자금 공제 종합한도 포함액 */
                V_DUC_MAX_HOUS_AMT :=  V_HOUS_FUND_DUC_HAP_AMT  --주택임대차차입금 원리금상환공제금액
                                       + V_HOUS_FUND_DUC_2_AMT; --특별공제주택이자상환합계액 = 15년 미만 + 15년~29년 + 30년 이상 + 2012년 고정금리(비거치식) + 2012년 일반 + 2015년(4개항목)
         END IF; /*  IF절 END @VER.2016_12 주택자금 외국인은 로직 처리 안되도록 함. (오류검증)에 걸림 */

/** 주택자금 소득공제 끝**/


/** 기부금공제 시작 **/



DBMS_OUTPUT.PUT_LINE('----- eterain 1 : 근로소득금액-V_LABOR_EARN_AMT:'||V_LABOR_EARN_AMT);
DBMS_OUTPUT.PUT_LINE('----- eterain 1 : 특별소득공제-V_SPCL_DUC_AMT:'||V_SPCL_DUC_AMT);
DBMS_OUTPUT.PUT_LINE('----- eterain 1 : 표준세액공제-V_STAD_TAXDUC_OBJ_AMT:'||V_STAD_TAXDUC_OBJ_AMT);
DBMS_OUTPUT.PUT_LINE('----- eterain 1 : 산출세액(합산)-V_TDUC_DUC_TT_AMT:'||V_TDUC_DUC_TT_AMT);
DBMS_OUTPUT.PUT_LINE('----- eterain 1 : 산출세액(차감)-V_CAL_TDUC_TEMP_AMT:'||V_CAL_TDUC_TEMP_AMT);

            /** 기부금 세액공제 **/
                --38.기부금공제금액

                /** 1.1. 정치자금기부금(20) 전액공제, 이월 없음**/
                 BEGIN
                    SELECT SUM(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0))
                      INTO V_FLAW_CNTRIB_AMT
                      FROM PAYM423 A, PAYM421 B --당년도 등록 공제 내역
                     WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                       AND A.YY             = IN_YY
                       AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                       AND A.CNTRIB_TYPE_CD = 'A032400002' /*정치자금(코드:20)*/
                       AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                       AND A.SETT_FG = V_SETT_FG
                       AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                       AND A.YY             = B.YY
                       AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                       AND A.SETT_FG        = B.SETT_FG
                       AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                       AND A.FM_SEQ         = B.FM_SEQ
                       AND B.FM_REL_CD      = 'A034600001'  -- 정치자금은 본인만
                       ;

                       EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                               V_FLAW_CNTRIB_AMT := 0;
                 END;

                 IF V_FLAW_CNTRIB_AMT <> 0 THEN
                   BEGIN

                    IF V_FLAW_CNTRIB_AMT > V_LABOR_EARN_AMT THEN            -- 정치자금기부금이 근로소득금액보다 큰경우...
                        V_CNTRIB_DUC_AMT     := V_LABOR_EARN_AMT;                          -- 근로소득금액까지만 공제
                        V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                        V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                        V_CNTRIB_DESTAMT     := V_FLAW_CNTRIB_AMT - V_LABOR_EARN_AMT;      -- 기부금 당년 소멸금액
                        V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                    ELSE
                        V_CNTRIB_DUC_AMT     := V_FLAW_CNTRIB_AMT;                         -- 정치기부금 전액공제
                        V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                        V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                        V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                        V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                    END IF;

                     IF V_FLAW_CNTRIB_AMT > V_LABOR_EARN_AMT THEN
                        V_FLAW_CNTRIB_AMT := V_LABOR_EARN_AMT;
                     END IF;

                     IF V_FLAW_CNTRIB_AMT > 100000 THEN
                        V_FLAW_CNTRIB_100_RATE_AMT := 100000;             -- 정치자금 10만원까지
                        V_FLAW_CNTRIB_15_RATE_AMT := LEAST(V_FLAW_CNTRIB_AMT - 100000, 30000000 - 100000);  -- 정치자금 10만원초과 29900000원까지
                        V_FLAW_CNTRIB_25_RATE_AMT := GREATEST(0, (V_FLAW_CNTRIB_AMT - V_FLAW_CNTRIB_100_RATE_AMT - V_FLAW_CNTRIB_15_RATE_AMT)); -- 정치자금 3천만원초과
                     ELSE
                        V_FLAW_CNTRIB_100_RATE_AMT := V_FLAW_CNTRIB_AMT;             -- 정치자금 10만원까지
                     END IF;             -- 정치자금 10만원까지

                     V_POLITICS_BLW_DUC_OBJ_AMT := V_FLAW_CNTRIB_100_RATE_AMT;                 --정치한도이하공제대상금액
                     V_POLITICS_BLW_TAXDUC_AMT := TRUNC(V_POLITICS_BLW_DUC_OBJ_AMT * 100/110); --정치한도이하세액공제액

                     V_POLITICS_EXCE_DUC_OBJ_AMT := V_FLAW_CNTRIB_15_RATE_AMT + V_FLAW_CNTRIB_25_RATE_AMT; --정치한도초과공제대상금액
                     V_POLITICS_EXCE_TAXDUC_AMT := TRUNC(V_FLAW_CNTRIB_15_RATE_AMT * 0.15) + TRUNC(V_FLAW_CNTRIB_25_RATE_AMT * 0.25); --정치한도초과세액공제액

                     /* 10만원 초과분만 정치자금기부금 공제대상금액에 포함*/
                     --V_CNTRIB_DUC_SUM_AMT20 := V_POLITICS_EXCE_DUC_OBJ_AMT;
                     --V_LMT_CNTRIB_AMT       := V_LABOR_EARN_AMT - V_POLITICS_EXCE_DUC_OBJ_AMT; --법정기부금 기준소득금액 = 근로소득금액 - 정치자금기부금 공제금액(10만원이하는 제외)
                     /* 2019.01.30  10만원 초과분도 정치자금기부금 공제대학금엑에 포함.(@VER.2018_11_3) */
                     V_CNTRIB_DUC_SUM_AMT20 := V_POLITICS_EXCE_DUC_OBJ_AMT + V_FLAW_CNTRIB_100_RATE_AMT;
                     V_LMT_CNTRIB_AMT       := V_LABOR_EARN_AMT - (V_POLITICS_EXCE_DUC_OBJ_AMT + V_FLAW_CNTRIB_100_RATE_AMT); --법정기부금 기준소득금액 = 근로소득금액 - 정치자금기부금 공제금액

                   END;
                 END IF;

                --DBMS_OUTPUT.PUT_LINE('S12 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );
                /** 1.2. 법정기부금(10) 전액공제, 5년 이월[2014년 이후분]**/
                /**                            @VER.2019_5 이월공제기간 10년으로 연장 **/
                BEGIN

                  V_CNTRIB_DUC_SUM_AMT10 := 0;

                  FOR CNTRIB1 IN (
                                   SELECT C1.RPST_PERS_NO, C1.CNTRIB_YY, C1.CNTRIB_TYPE_CD
                                        , C1.CNTRIB_GIAMT
                                        , C1.CNTRIB_PREAMT
                                        , C1.CNTRIB_GONGAMT
                                        , C1.CNTRIB_DESTAMT
                                        , C1.CNTRIB_OVERAMT
                                       -- , C1.APNT_CNTRIB_AMT -- 전년도 종교단체외 지정기부금 발생 금액
                                        , SUM(C1.CNTRIB_GIAMT) OVER (PARTITION BY C1.CNTRIB_TYPE_CD) AS CNTRIB_TYPE_TT_AMT --기부유형별 합계금액
                                   FROM (
                                         SELECT A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD
                                              , SUM(A1.CNTRIB_GIAMT)   CNTRIB_GIAMT
                                              , SUM(A1.CNTRIB_PREAMT)  CNTRIB_PREAMT
                                              , SUM(A1.CNTRIB_GONGAMT) CNTRIB_GONGAMT
                                              , SUM(A1.CNTRIB_DESTAMT) CNTRIB_DESTAMT
                                              , SUM(A1.CNTRIB_OVERAMT) CNTRIB_OVERAMT
                                              , A1.DUC_SORT
                                         FROM (
                                               SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                      A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD,
                                                      NVL(A.CNTRIB_GIAMT,0) CNTRIB_GIAMT,  --기부금액
                                                      NVL(A.CNTRIB_PREAMT,0) CNTRIB_PREAMT,   --전년까지 공제금액
                                                      NVL(A.CNTRIB_GONGAMT,0) CNTRIB_GONGAMT,  --당년 공제금액
                                                      NVL(A.CNTRIB_DESTAMT,0) CNTRIB_DESTAMT,  --당년 소멸금액
                                                      NVL(A.CNTRIB_OVERAMT,0) CNTRIB_OVERAMT   --당년 이월금액
                                                      , (A.CNTRIB_YY * -1) AS DUC_SORT --공제순서
                                                 FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                     ,PAYM452 B --사업자부서정보 @VER.2016_11
                                                WHERE A.RPST_PERS_NO = REC.RPST_PERS_NO
                                                  AND A.YY           = IN_YY - 1 
                                                  AND A.YRETXA_SEQ   = V_YRETXA_SEQ  /* 전년도는 차수 변수처리*/
                                                  AND A.YY           = B.YY
                                                  AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                  AND B.BIZR_REG_NO  = V_BIZR_REG_NO   /* @VER.2016_11 */
                                                  AND A.CNTRIB_TYPE_CD = 'A032400001'  --법정기부금
                                                  AND A.SETT_FG = 'A031300001'--연말정산인것만
                                                  AND NVL(A.CNTRIB_OVERAMT,0) <> 0 --전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴

                                                UNION ALL
                                               SELECT A.RPST_PERS_NO, A.YY, A.CNTRIB_TYPE_CD,
                                                      (NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) - NVL(A.CNTRIB_ENC_APLY_AMT, 0)),
                                                      0,0,0,0
                                                      , (A.YY * -1) AS DUC_SORT --공제순서
                                                 FROM PAYM423 A, PAYM421 B --당년도 등록 공제 내역
                                                WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                                                  AND A.YY             = IN_YY
                                                  AND A.YRETXA_SEQ     = IN_YRETXA_SEQ   /*@VER.2017_0*/
                                                  AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                  AND A.CNTRIB_TYPE_CD = 'A032400001'  --법정기부금
                                                  AND A.SETT_FG        = V_SETT_FG
                                                  AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                                                  AND A.YY             = B.YY
                                                  AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                                                  AND A.SETT_FG        = B.SETT_FG
                                                  AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                                                  AND A.FM_SEQ         = B.FM_SEQ
                                                  AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 기부금 부양가족 연령요건 삭제(소득요건만 체크 또는 본인)
                                              --  AND NVL(B.BASE_DUC_YN,'N') IN ('Y','1') --기본공제 체크된 사람의 기부금
                                               ) A1
                                       GROUP BY A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD, A1.DUC_SORT
                                         ) C1
                                  ORDER BY C1.DUC_SORT DESC
                                 /*ORDER BY (CASE WHEN (V_LABOR_EARN_AMT - CNTRIB_TYPE_TT_AMT) > 0 THEN  TO_NUMBER(C1.CNTRIB_YY)
                                                ELSE (TO_NUMBER(C1.CNTRIB_YY) * -1) END) DESC */
                                  )
                    LOOP
                        -- 법정기부금 공제 순서 변경(@VER.2019_7)
                        -- (기존) 당해 법정 -> 2014 이후 이월 법정
                        -- (변경) 2013 이월 법정 -> 2014 이후 이월 법정 -> 당해 법정

                         -- 2013년 이월된 금액
                         IF (CNTRIB1.CNTRIB_YY = '2013')  THEN    --2013년이후 법정기부금


                            IF CNTRIB1.CNTRIB_OVERAMT > V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20 THEN
                                V_CNTRIB_DUC_AMT     := V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20;
                                V_CNTRIB_PREAMT      := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                                V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                                V_CNTRIB_OVERAMT     := CNTRIB1.CNTRIB_OVERAMT - V_CNTRIB_DUC_AMT; -- 기부금 당년 이월금액
                            ELSE
                                V_CNTRIB_DUC_AMT     := CNTRIB1.CNTRIB_OVERAMT;
                                V_CNTRIB_PREAMT      := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                                V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                                V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                            END IF;

                            V_CNTRIB_DUC_SUM_AMT10 := V_CNTRIB_DUC_SUM_AMT10 + V_CNTRIB_DUC_AMT;
                            --V_FLAW_CNTRIB_DUC_OBJ_AMT := V_FLAW_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 법정기부금공제대상금액에서는 제외처리
                            V_LMT_CNTRIB_AMT     := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;
                            V_CNTRIB_AMT_CYOV_AMT := V_CNTRIB_GONGAMT + V_CNTRIB_AMT_CYOV_AMT; -- 기부금(이월분). @VER.2019_11

                         END IF;


                          -- 2014년이후 4년이내 이월된 금액
                          -- @VER.2019_5 이월공제기간 10년으로 연장(법정기부금, 종교단체외 지정기부금, 종교단체지정기부금) 법정기부금
                         IF (CNTRIB1.CNTRIB_YY >= '2014' AND CNTRIB1.CNTRIB_YY BETWEEN IN_YY - 9 AND IN_YY - 1)  THEN    --2014년이후 법정기부금은 5년간 세액공제.
                                                                                                                         --@VER.2019_5 이월공제기간 10년으로 연장(IN_YY - 4년에서 IN_YY - 9로 수정)
-- @VER.2019_5 이월공제기간 10년으로 연장에 따른 text 4년이내를 10년이내로 수정(5년이라고 해야 년수에 맞지만 매년 수정해야하는 번거로움을 위해 개정내용대로 10년이내로 수정)


                            /* @VER.2017_88 법정기부금이월계산 수정 [변수 잘못 사용 이월된 금액으로 비교해야 함] */
                            --IF CNTRIB1.CNTRIB_GIAMT > V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20 THEN
                            IF CNTRIB1.CNTRIB_OVERAMT > V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20 THEN
                                V_CNTRIB_DUC_AMT     := V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20;
                                V_CNTRIB_PREAMT      := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                                V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                                V_CNTRIB_OVERAMT     := CNTRIB1.CNTRIB_OVERAMT - V_CNTRIB_DUC_AMT; -- 기부금 당년 이월금액
                            ELSE
                                V_CNTRIB_DUC_AMT     := CNTRIB1.CNTRIB_OVERAMT;
                                V_CNTRIB_PREAMT      := CNTRIB1.CNTRIB_PREAMT + CNTRIB1.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                                V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                                V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                            END IF;

                            V_CNTRIB_DUC_SUM_AMT10 := V_CNTRIB_DUC_SUM_AMT10 + V_CNTRIB_DUC_AMT;
                            V_FLAW_CNTRIB_DUC_OBJ_AMT := V_FLAW_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 법정기부금공제대상금액
                            V_LMT_CNTRIB_AMT     := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;

                         END IF;



                         -- 당해년도 법정기부금 금액
                         IF CNTRIB1.CNTRIB_YY = IN_YY  THEN
                            /*V_OCCR_LOC_NM := '법정기부금(10) 당해년도';
                            V_DB_ERROR_CTNT := 'CNTRIB1.CNTRIB_GIAMT,V_LABOR_EARN_AMT,V_CNTRIB_DUC_SUM_AMT10,V_CNTRIB_DUC_SUM_AMT20 = ' || CNTRIB1.CNTRIB_GIAMT || ',' ||  V_LABOR_EARN_AMT || ',' || V_CNTRIB_DUC_SUM_AMT10 || ',' || V_CNTRIB_DUC_SUM_AMT20||']'||chr(13)||chr(10);
                            SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );
                            */

                            IF CNTRIB1.CNTRIB_GIAMT > V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20 THEN
                                V_CNTRIB_DUC_AMT     := V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20;
                                V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                                V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                                V_CNTRIB_OVERAMT     := CNTRIB1.CNTRIB_GIAMT - V_CNTRIB_DUC_AMT;  -- 기부금 당년 이월금액
                            ELSE
                                V_CNTRIB_DUC_AMT     := CNTRIB1.CNTRIB_GIAMT;
                                V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                                V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                                V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                            END IF;

                            V_CNTRIB_DUC_SUM_AMT10 := V_CNTRIB_DUC_SUM_AMT10 + V_CNTRIB_DUC_AMT;
                            V_FLAW_CNTRIB_DUC_OBJ_AMT := V_FLAW_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 법정기부금공제대상금액
                            V_LMT_CNTRIB_AMT     := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;
                         END IF;


                          IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
                               V_TMP_STEP := 'D06';
                              DELETE FROM PAYM436
                               WHERE YY             = IN_YY
                                 AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                 AND SETT_FG        = V_SETT_FG
                                 AND RPST_PERS_NO   = REC.RPST_PERS_NO
                                 AND CNTRIB_YY      = CNTRIB1.CNTRIB_YY
                                 AND CNTRIB_TYPE_CD = 'A032400001'
                                 ;

                              IF (CNTRIB1.CNTRIB_GIAMT <> 0 OR V_CNTRIB_PREAMT <> 0 OR V_CNTRIB_GONGAMT <> 0
                                  OR V_CNTRIB_DESTAMT <> 0 OR V_CNTRIB_OVERAMT <> 0) THEN
                                  V_TMP_STEP := '001';

                                  /*@@zodem*/
                                  /*V_OCCR_LOC_NM := '최종 법정기부금(10) INSERT시';
                                  V_DB_ERROR_CTNT :=
                                  'CNTRIB1.CNTRIB_YY:'||CNTRIB1.CNTRIB_YY||chr(13)||chr(10)||
                                  'CNTRIB1.CNTRIB_TYPE_CD:'||CNTRIB1.CNTRIB_TYPE_CD||chr(13)||chr(10)||
                                  'CNTRIB1.CNTRIB_GIAMT:'||CNTRIB1.CNTRIB_GIAMT||chr(13)||chr(10)||
                                  'V_CNTRIB_PREAMT:'||V_CNTRIB_PREAMT||chr(13)||chr(10)||
                                  'V_CNTRIB_GONGAMT:'||V_CNTRIB_GONGAMT||chr(13)||chr(10)||
                                  'V_CNTRIB_DESTAMT:'||V_CNTRIB_DESTAMT||chr(13)||chr(10)||
                                  'V_CNTRIB_OVERAMT:'||V_CNTRIB_OVERAMT||chr(13)||chr(10);
                                   SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */


                                  INSERT INTO PAYM436(BIZR_DEPT_CD     --사업자부서코드
                                                     ,YY               --년도
                                                     ,SETT_FG           --정산구분
                                                     ,RPST_PERS_NO     --대표개인번호
                                                     ,CNTRIB_YY         --기부년도
                                                     ,CNTRIB_TYPE_CD   --기부금유형
                                                     ,CNTRIB_GIAMT     --기부금액
                                                     ,CNTRIB_PREAMT     --전년까지 공제금액
                                                     ,CNTRIB_GONGAMT   --당년 공제금액
                                                     ,CNTRIB_DESTAMT   --당년 소멸금액
                                                     ,CNTRIB_OVERAMT   --당년 이월금액
                                                     ,INPT_ID           --입력자ID
                                                     ,INPT_DTTM         --입력일시
                                                     ,INPT_IP           --입력자IP
                                                      )
                                        VALUES(IN_BIZR_DEPT_CD
                                              ,IN_YY
                                              ,V_SETT_FG
                                              ,REC.RPST_PERS_NO
                                              ,CNTRIB1.CNTRIB_YY
                                              ,CNTRIB1.CNTRIB_TYPE_CD
                                              ,CNTRIB1.CNTRIB_GIAMT
                                              ,V_CNTRIB_PREAMT
                                              ,V_CNTRIB_GONGAMT
                                              ,V_CNTRIB_DESTAMT
                                              ,V_CNTRIB_OVERAMT
                                              ,IN_INPT_ID
                                              ,SYSDATE
                                              ,IN_INPT_IP
                                               );
                              END IF;
                          ELSE
                             V_TMP_STEP := 'D07';
                              DELETE FROM PAYM432
                               WHERE YY             = IN_YY
                                 AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                 AND SETT_FG        = V_SETT_FG
                                 AND RPST_PERS_NO   = REC.RPST_PERS_NO
                                 AND CNTRIB_YY      = CNTRIB1.CNTRIB_YY
                                 AND CNTRIB_TYPE_CD = 'A032400001'
                                 AND YRETXA_SEQ = 1 --(2014재계산):1차만 지웁니다.
                                 ;

                              IF (CNTRIB1.CNTRIB_GIAMT <> 0 OR V_CNTRIB_PREAMT <> 0 OR V_CNTRIB_GONGAMT <> 0
                                  OR V_CNTRIB_DESTAMT <> 0 OR V_CNTRIB_OVERAMT <> 0) THEN
                                  V_TMP_STEP := '002';
                                  INSERT INTO PAYM432(BIZR_DEPT_CD     --사업자부서코드
                                                     ,YY               --년도
                                                     ,SETT_FG           --정산구분
                                                     ,RPST_PERS_NO     --대표개인번호
                                                     ,CNTRIB_YY         --기부년도
                                                     ,CNTRIB_TYPE_CD   --기부금유형
                                                     ,CNTRIB_GIAMT     --기부금액
                                                     ,CNTRIB_PREAMT     --전년까지 공제금액
                                                     ,CNTRIB_GONGAMT   --당년 공제금액
                                                     ,CNTRIB_DESTAMT   --당년 소멸금액
                                                     ,CNTRIB_OVERAMT   --당년 이월금액
                                                     ,INPT_ID           --입력자ID
                                                     ,INPT_DTTM         --입력일시
                                                     ,INPT_IP           --입력자IP
                                                     ,YRETXA_SEQ        --(2014재계산) 차수
                                                      )
                                        VALUES(IN_BIZR_DEPT_CD
                                              ,IN_YY
                                              ,V_SETT_FG
                                              ,REC.RPST_PERS_NO
                                              ,CNTRIB1.CNTRIB_YY
                                              ,CNTRIB1.CNTRIB_TYPE_CD
                                              ,CNTRIB1.CNTRIB_GIAMT
                                              ,V_CNTRIB_PREAMT
                                              ,V_CNTRIB_GONGAMT
                                              ,V_CNTRIB_DESTAMT
                                              ,V_CNTRIB_OVERAMT
                                              ,IN_INPT_ID
                                              ,SYSDATE
                                              ,IN_INPT_IP
                                              ,1
                                               );
                              END IF;
                        END IF;

                    END LOOP;
                    EXCEPTION
                        WHEN OTHERS THEN
                             OUT_RTN := 0;
                             OUT_MSG := '법정기부금 정산결과 생성오류(대표개인번호 : '||V_RPST_PERS_NO||SQLCODE || ':' || SQLERRM || ')';
                             
--insert into tmp_msg values ('3272', '오류 ' || OUT_MSG , sysdate);
                             RETURN;
                END;

                /** 1.5. 우리사주조합기부금(63-㉰ ) 전액공제, 이월 없음**/
                BEGIN
                    SELECT SUM(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0))
                      INTO V_PROM_GRP_CNTRIB_2_AMT
                      FROM PAYM423 A, PAYM421 B --당년도 등록 공제 내역
                     WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                       AND A.YY             = IN_YY
                       AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                       AND A.CNTRIB_TYPE_CD = 'A032400008'
                       AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                       AND A.SETT_FG        = V_SETT_FG
                       AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                       AND A.YY             = B.YY
                       AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                       AND A.SETT_FG        = B.SETT_FG
                       AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                       AND A.FM_SEQ         = B.FM_SEQ
                       AND B.FM_REL_CD      = 'A034600001'  -- 본인만
                       AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 기부금 부양가족 연령요건 삭제(소득요건만 체크 또는 본인)
                     --AND NVL(B.BASE_DUC_YN,'N') IN ('Y','1') --기본공제 체크된 사람의 기부금
                      ;
                   EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        V_PROM_GRP_CNTRIB_2_AMT := 0;
                END;

                 IF V_PROM_GRP_CNTRIB_2_AMT <> 0 THEN
                   BEGIN
                     IF V_PROM_GRP_CNTRIB_2_AMT > TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20) * 30 /100) - V_CNTRIB_DUC_SUM_AMT42 THEN
                       V_CNTRIB_DUC_AMT     := TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT10 - V_CNTRIB_DUC_SUM_AMT20 ) * 30 /100) - V_CNTRIB_DUC_SUM_AMT42;
                       V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                       V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                       V_CNTRIB_DESTAMT     := V_PROM_GRP_CNTRIB_2_AMT - V_CNTRIB_DUC_AMT;  -- 기부금 당년 소멸금액
                       V_CNTRIB_OVERAMT     := 0;  -- 기부금 당년 이월금액
                     ELSE
                       V_CNTRIB_DUC_AMT     := V_PROM_GRP_CNTRIB_2_AMT;
                       V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                       V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                       V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                       V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                     END IF;

                    V_CNTRIB_DUC_SUM_AMT42 := V_CNTRIB_DUC_SUM_AMT42 + V_CNTRIB_DUC_AMT;
                    V_LMT_CNTRIB_AMT       := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;
                    
              
                    
                    
                     IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
                         V_TMP_STEP := 'D10';
                         DELETE FROM PAYM436
                           WHERE YY = IN_YY
                             AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                             AND SETT_FG      = V_SETT_FG
                             AND RPST_PERS_NO = REC.RPST_PERS_NO
                             AND CNTRIB_YY    = IN_YY
                             AND CNTRIB_TYPE_CD = 'A032400008'
                             ;
                         V_TMP_STEP := '005';
                         INSERT INTO PAYM436(BIZR_DEPT_CD     --사업자부서코드
                                             ,YY               --년도
                                             ,SETT_FG           --정산구분
                                             ,RPST_PERS_NO     --대표개인번호
                                             ,CNTRIB_YY         --기부년도
                                             ,CNTRIB_TYPE_CD   --기부금유형
                                             ,CNTRIB_GIAMT     --기부금액
                                             ,CNTRIB_PREAMT     --전년까지 공제금액
                                             ,CNTRIB_GONGAMT   --당년 공제금액
                                             ,CNTRIB_DESTAMT   --당년 소멸금액
                                             ,CNTRIB_OVERAMT   --당년 이월금액
                                             ,INPT_ID           --입력자ID
                                             ,INPT_DTTM         --입력일시
                                             ,INPT_IP           --입력자IP
                                              )
                                VALUES(IN_BIZR_DEPT_CD
                                      ,IN_YY
                                      ,V_SETT_FG
                                      ,REC.RPST_PERS_NO
                                      ,IN_YY
                                      ,'A032400008'
                                      ,V_PROM_GRP_CNTRIB_2_AMT
                                      ,V_CNTRIB_PREAMT
                                      ,V_CNTRIB_GONGAMT
                                      ,V_CNTRIB_DESTAMT
                                      ,V_CNTRIB_OVERAMT
                                      ,IN_INPT_ID
                                      ,SYSDATE
                                      ,IN_INPT_IP
                                       );
                     ELSE
                         V_TMP_STEP := 'D11';
                          DELETE FROM PAYM432
                           WHERE YY            = IN_YY
                             AND YRETXA_SEQ    = IN_YRETXA_SEQ /*@VER.2017_0*/
                             AND BIZR_DEPT_CD  = IN_BIZR_DEPT_CD
                             AND SETT_FG       = V_SETT_FG
                             AND RPST_PERS_NO  = REC.RPST_PERS_NO
                             AND CNTRIB_YY     = IN_YY
                             AND CNTRIB_TYPE_CD = 'A032400008'  /*우리사주(코드:42)    */
                             ;
                         V_TMP_STEP := '006';
                         INSERT INTO PAYM432(BIZR_DEPT_CD     --사업자부서코드
                                             ,YY               --년도
                                             ,SETT_FG           --정산구분
                                             ,RPST_PERS_NO     --대표개인번호
                                             ,CNTRIB_YY         --기부년도
                                             ,CNTRIB_TYPE_CD   --기부금유형
                                             ,CNTRIB_GIAMT     --기부금액
                                             ,CNTRIB_PREAMT     --전년까지 공제금액
                                             ,CNTRIB_GONGAMT   --당년 공제금액
                                             ,CNTRIB_DESTAMT   --당년 소멸금액
                                             ,CNTRIB_OVERAMT   --당년 이월금액
                                             ,INPT_ID           --입력자ID
                                             ,INPT_DTTM         --입력일시
                                             ,INPT_IP           --입력자IP
                                             ,YRETXA_SEQ        --(2014재계산) 차수
                                              )
                                VALUES(IN_BIZR_DEPT_CD
                                      ,IN_YY
                                      ,V_SETT_FG
                                      ,REC.RPST_PERS_NO
                                      ,IN_YY
                                      ,'A032400008'
                                      ,V_PROM_GRP_CNTRIB_2_AMT
                                      ,V_CNTRIB_PREAMT
                                      ,V_CNTRIB_GONGAMT
                                      ,V_CNTRIB_DESTAMT
                                      ,V_CNTRIB_OVERAMT
                                      ,IN_INPT_ID
                                      ,SYSDATE
                                      ,IN_INPT_IP
                                      ,1
                                       );
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                             OUT_RTN := 0;
                             OUT_MSG := '우리사주조합 기부금계산결과 생성오류(대표개인번호 : '||V_RPST_PERS_NO||SQLCODE || ':' || SQLERRM || ')';
                             RETURN;
                   END;
                 END IF;


                V_CNTRIB_DUC_SUM_AMT := V_CNTRIB_DUC_SUM_AMT10 + V_CNTRIB_DUC_SUM_AMT20 + V_CNTRIB_DUC_SUM_AMT42;

/* @@ZZODEM */
/*V_OCCR_LOC_NM   := '지정기부금 체크. STEP.0 ';
V_DB_ERROR_CTNT := 'V_CNTRIB_DUC_SUM_AMT:'||V_CNTRIB_DUC_SUM_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_SUM_AMT10:'||V_CNTRIB_DUC_SUM_AMT10||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_SUM_AMT20:'||V_CNTRIB_DUC_SUM_AMT20||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_SUM_AMT42:'||V_CNTRIB_DUC_SUM_AMT42||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                /** 1.6. 지정기부금(종교단체외(40), 종교단체(41))
                         지정기부금 공제 순서
                         => @VER.2017_13 공제순서 변경 [소득공제(2013년이전분) => 세액공제(종교외가 우선)]
                             [소득공제 SORT1:A1] 2013년이전 종교단체외
                             [소득공제 SORT1:A2] 2013년이전 종교단체
                             [세액공제 SORT1:B1] 당해 종교단체 외
                             [세액공제 SORT1:B2] 종교단체외 이월(2014년~)
                             [세액공제 SORT1:C1] 당해 종교단체
                             [세액공제 SORT1:C2] 종교단체 이월(2014년~)
                         => @VER.2019_7 공제순서 변경. 이월액 먼저 소멸되도록 변경
                             [소득공제 SORT1:A1] 2013년이전 종교단체외
                             [소득공제 SORT1:A2] 2013년이전 종교단체
                             [세액공제 SORT1:B1] 종교단체외 이월(2014년~)
                             [세액공제 SORT1:B2] 당해 종교단체 외
                             [세액공제 SORT1:C1] 종교단체 이월(2014년~)
                             [세액공제 SORT1:C2] 당해 종교단체

                        1)지정기부금(@VER.2018_11_1)
                        - 2013년도 기부금의 마지막 공제가능연도가 2018년도(올해)이기 때문에 올해 공제는 문제없음, 하지만 올해 공제되고 남은 금액은 소멸됨(5년 기간이 종료되기 때문)
                          그러므로, 남은금액이 소멸되지 않고 내년도 이월금액으로 처리되게 수정(이월공제기간이 10년으로 연장되었기 때문)(@VER.2018_11_1)
                 **/

                BEGIN
                  FOR CNTRIB4 IN (
                                   SELECT C1.RPST_PERS_NO, C1.CNTRIB_YY, C1.CNTRIB_TYPE_CD
                                        , C1.CNTRIB_GIAMT
                                        , NVL(C1.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                        , NVL(C1.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                        , NVL(C1.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                        , NVL(C1.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                        , SUM(C1.APNT_CNTRIB_AMT) OVER(PARTITION BY C1.RPST_PERS_NO) AS  APNT_CNTRIB_AMT -- 종교단체 지정기부금 발생(당년+이월) 금액
                                        , SUM(C1.APNT_CNTRIB_AMT2) OVER(PARTITION BY C1.RPST_PERS_NO) AS  APNT_CNTRIB_AMT2 -- 종교단체외 지정기부금 발생(당년+이월) 금액
                                        , SUM(C1.CNTRIB_GIAMT) OVER (PARTITION BY C1.CNTRIB_TYPE_CD) AS CNTRIB_TYPE_TT_AMT --기부유형별 합계금액
                                        , C1.SORT1
                                        , C1.SORT3
                                     FROM (
                                           SELECT A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD
                                                , SUM(A1.CNTRIB_GIAMT)   CNTRIB_GIAMT
                                                , SUM(A1.CNTRIB_PREAMT)  CNTRIB_PREAMT
                                                , SUM(A1.CNTRIB_GONGAMT) CNTRIB_GONGAMT
                                                , SUM(A1.CNTRIB_DESTAMT) CNTRIB_DESTAMT
                                                , SUM(A1.CNTRIB_OVERAMT) CNTRIB_OVERAMT
                                                , SUM(A1.APNT_CNTRIB_AMT) APNT_CNTRIB_AMT -- 종교단체 지정기부금 발생(당년+이월) 금액
                                                , SUM(A1.APNT_CNTRIB_AMT2) APNT_CNTRIB_AMT2 -- 종교단체외 지정기부금 발생(당년+이월) 금액
                                                , A1.SORT1
                                                , A1.SORT3
                                           FROM (
                                                 /*[소득공제 SORT1:A1] 2013년이전 종교단체외*/
                                                 SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                          A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                        , NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                        , NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                        , NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                        , NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                        , NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                        , 0                       AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                        , NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                        , 'A1'                    AS SORT1
                                                        , A.CNTRIB_YY             AS SORT3
                                                   FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                       ,PAYM452 B --사업자부서정보 @VER.2016_11
                                                  WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                                                    AND A.YY             = IN_YY - 1
                                                    AND A.YRETXA_SEQ     = V_YRETXA_SEQ     /* 전년도는 차수 변수처리 */
                                                    AND A.YY             = B.YY                        /* @VER.2016_11 */
                                                    AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                    AND B.BIZR_REG_NO    = V_BIZR_REG_NO   /* @VER.2016_11 */
                                                    AND A.CNTRIB_TYPE_CD = 'A032400006'    /* 기부금유형: 지정 종교외(40) */
                                                    AND A.SETT_FG        = 'A031300001'    /* 정산구분: 연말정산 */
                                                    AND NVL(A.CNTRIB_OVERAMT,0) <> 0       /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴 */
                                                    AND A.CNTRIB_YY <= '2013'              /* @2016R 2013년 이전 이월기부금 분리 (2015년 1차 계산시 분리 안되어있음:오류사항) */
                                                 UNION ALL
                                                  /*[소득공제 SORT1:A2] 2013년이전 종교단체*/
                                                 SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                        A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                       ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                       ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                       ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                       ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                       ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                       ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                       ,0                       AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                       ,'A2'                    AS SORT1
                                                       ,A.CNTRIB_YY             AS SORT3
                                                   FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                       ,PAYM452 B --사업자부서정보 @VER.2016_11
                                                  WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                                                    AND A.YY             = IN_YY - 1
                                                    AND A.YRETXA_SEQ     = V_YRETXA_SEQ    /* 전년도는 차수 변수처리 */
                                                    AND A.YY             = B.YY            /* @VER.2016_11 */
                                                    AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                    AND B.BIZR_REG_NO    = V_BIZR_REG_NO   /* @VER.2016_11 */
                                                    AND A.CNTRIB_TYPE_CD = 'A032400007'    /* 기부금유형: 지정 종교단체(41) */
                                                    AND A.SETT_FG        = 'A031300001'    /* 정산구분 : 연말정산 */
                                                    AND NVL(A.CNTRIB_OVERAMT,0) <> 0       /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴 */
                                                    AND A.CNTRIB_YY <= '2013'              /* @2016R 2013년 이전 이월기부금 분리 (2015년 1차 계산시 분리 안되어있음:오류사항) */
                                                 UNION ALL
                                                 /*[세액공제 SORT1:B1] 종교단체외 이월(2014년~) */
                                                 SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                        A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                       ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                       ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                       ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                       ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                       ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                       ,0                       AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                       ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                       ,'B1'        AS SORT1
                                                       ,A.CNTRIB_YY AS SORT3
                                                   FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                       ,PAYM452 B --사업자부서정보 @VER.2016_11
                                                  WHERE A.RPST_PERS_NO = REC.RPST_PERS_NO
                                                    AND A.YY           = IN_YY - 1
                                                    AND A.YRETXA_SEQ   = V_YRETXA_SEQ    /* 전년도는 차수 변수처리*/
                                                    AND A.YY           = B.YY            /* @VER.2016_11 */
                                                    AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                    AND B.BIZR_REG_NO  = V_BIZR_REG_NO   /* @VER.2016_11 */
                                                    AND A.CNTRIB_TYPE_CD = 'A032400006'  /* 지정(종교외:40) */
                                                    AND A.SETT_FG        = 'A031300001'  /* 정산구분:연말정산 */
                                                    AND NVL(A.CNTRIB_OVERAMT,0) <> 0     /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴*/
                                                    AND A.CNTRIB_YY >= '2014'            /* 2014년 이후 이월 기부금 */
                                                 UNION ALL
                                                 /*[세액공제 SORT1:B2] 당해 종교단체 외 */
                                                 SELECT A.RPST_PERS_NO, A.YY, A.CNTRIB_TYPE_CD
                                                       ,(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) - NVL(A.CNTRIB_ENC_APLY_AMT,0) ) AS CNTRIB_GIAMT /*@VER.2016_9 지정기부금 기부장려신청금액 차감.*/
                                                       ,0                                                 AS CNTRIB_PREAMT
                                                       ,0                                                 AS CNTRIB_GONGAMT
                                                       ,0                                                 AS CNTRIB_DESTAMT
                                                       ,0                                                 AS CNTRIB_OVERAMT
                                                       ,0                                                 AS APNT_CNTRIB_AMT1-- 당년도 종교단체 지정기부금 발생 금액
                                                       ,NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT2-- 당년도 종교단체외 지정기부금 발생 금액
                                                       ,'B2'  AS SORT1
                                                       ,A.YY  AS SORT3
                                                   FROM PAYM423 A --당년도 연말정산 기부내역
                                                       ,PAYM421 B --연말정산 가족사항
                                                  WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                                                    AND A.YY             = IN_YY
                                                    AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                    AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                    AND A.CNTRIB_TYPE_CD = 'A032400006' /* 지정(종교외:40) */
                                                    AND A.SETT_FG        = V_SETT_FG
                                                    AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                                                    AND A.YY             = B.YY
                                                    AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                                                    AND A.SETT_FG        = B.SETT_FG
                                                    AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                                                    AND A.FM_SEQ         = B.FM_SEQ
                                                    AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 기부금 부양가족 연령요건 삭제(소득요건만 체크 또는 본인)
                                                 UNION ALL
                                                 /*[세액공제 SORT1:C1] 종교단체 이월(2014년~) */
                                                 SELECT /*+ LEADING(a) USE_NL(b) INDEX(a IDX_PAYM432_01) */        --@TUNING
                                                        A.RPST_PERS_NO, A.CNTRIB_YY, A.CNTRIB_TYPE_CD
                                                       ,NVL(A.CNTRIB_GIAMT,0)   AS CNTRIB_GIAMT
                                                       ,NVL(A.CNTRIB_PREAMT,0)  AS CNTRIB_PREAMT
                                                       ,NVL(A.CNTRIB_GONGAMT,0) AS CNTRIB_GONGAMT
                                                       ,NVL(A.CNTRIB_DESTAMT,0) AS CNTRIB_DESTAMT
                                                       ,NVL(A.CNTRIB_OVERAMT,0) AS CNTRIB_OVERAMT
                                                       ,NVL(A.CNTRIB_OVERAMT,0) AS APNT_CNTRIB_AMT  -- 이월된 종교단체 지정기부금 금액
                                                       ,0                       AS APNT_CNTRIB_AMT2 -- 이월된 종교단체외 지정기부금 금액
                                                       ,'C1'                    AS SORT1
                                                       ,A.CNTRIB_YY             AS SORT3
                                                   FROM PAYM432 A --전년도 기부금 계산 결과 내역
                                                       ,PAYM452 B --사업자부서정보 @VER.2016_11
                                                  WHERE A.RPST_PERS_NO = REC.RPST_PERS_NO
                                                    AND A.YY           = IN_YY - 1
                                                    AND A.YRETXA_SEQ   = V_YRETXA_SEQ    /* 전년도는 차수 변수처리*/
                                                    AND A.YY           = B.YY            /* @VER.2016_11 */
                                                    AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD  /* @VER.2016_11 */
                                                    AND B.BIZR_REG_NO  = V_BIZR_REG_NO   /* @VER.2016_11 */
                                                    AND A.CNTRIB_TYPE_CD = 'A032400007'  /* 지정(종교단체:41) */
                                                    AND A.SETT_FG        = 'A031300001'  /* 정산구분:연말정산 */
                                                    AND NVL(A.CNTRIB_OVERAMT,0) <> 0     /* 전년도 결과 중 이월금액이 0 이 아닌 내역만 당년도 공제 내역에 갖고 옴*/
                                                    AND A.CNTRIB_YY >= '2014'            /* 2014년 이후 이월 기부금 */
                                                 UNION ALL
                                                 /*[세액공제 SORT1:C2] 당해 종교단체 */
                                                 SELECT A.RPST_PERS_NO, A.YY, A.CNTRIB_TYPE_CD
                                                       ,(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) - NVL(A.CNTRIB_ENC_APLY_AMT,0) ) AS CNTRIB_GIAMT/*@VER.2016_9 지정기부금 기부장려신청금액 차감.*/
                                                       ,0                                                 AS CNTRIB_PREAMT
                                                       ,0                                                 AS CNTRIB_GONGAMT
                                                       ,0                                                 AS CNTRIB_DESTAMT
                                                       ,0                                                 AS CNTRIB_OVERAMT
                                                       ,NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT1-- 당년도 종교단체 지정기부금 발생 금액
                                                       ,0                                                 AS APNT_CNTRIB_AMT2-- 당년도 종교단체외  지정기부금 발생 금액
                                                       ,'C2' SORT1
                                                       ,A.YY SORT3
                                                   FROM PAYM423 A --당년도 연말정산 기부내역
                                                      , PAYM421 B --연말정산 가족사항
                                                  WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                                                    AND A.YY             = IN_YY
                                                    AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                    AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                    AND A.CNTRIB_TYPE_CD = 'A032400007' /* 지정(종교단체:41)*/
                                                    AND A.SETT_FG        = V_SETT_FG
                                                    AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                                                    AND A.YY             = B.YY
                                                    AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                                                    AND A.SETT_FG        = B.SETT_FG
                                                    AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                                                    AND A.FM_SEQ         = B.FM_SEQ
                                                    AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 기부금 부양가족 연령요건 삭제(소득요건만 체크 또는 본인)
                                                  --AND NVL(B.BASE_DUC_YN,'N') IN ('Y','1') --기본공제 체크된 사람의 기부금
                                                 UNION ALL
                                                 /*[세액공제 SORT1:B2] 당해 급여노조비(지정:종교단체 외(41)로 분류) */
                                                 SELECT A.RPST_PERS_NO, A.YY, 'A032400006' AS CNTRIB_TYPE_CD
                                                       ,NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) AS CNTRIB_GIAMT
                                                       ,0                                AS CNTRIB_PREAMT
                                                       ,0                                AS CNTRIB_GONGAMT
                                                       ,0                                AS CNTRIB_DESTAMT
                                                       ,0                                AS CNTRIB_OVERAMT
                                                       ,0                                AS APNT_CNTRIB_AMT1 --당년도 종교단체  지정기부금 발생 금액
                                                       ,NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) AS APNT_CNTRIB_AMT2 --당년도 종교단체외  지정기부금 발생 금액
                                                       ,'B2'                             AS SORT1
                                                       ,A.YY                             AS SORT3
                                                   FROM PAYM440 A --당년도 급여 노조비 공제 내역
                                                  WHERE A.RPST_PERS_NO = REC.RPST_PERS_NO
                                                    AND A.YY           = IN_YY
                                                    AND A.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                                                    AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                                                    AND SETT_FG        = V_SETT_FG
                                                    AND NVL(A.EMP_LABUN_UN_CNTRIB_AMT,0) <> 0
                                                 ) A1
                                         GROUP BY A1.RPST_PERS_NO, A1.CNTRIB_YY, A1.CNTRIB_TYPE_CD, A1.SORT1, A1.SORT3
                                           ) C1
                                  ORDER BY C1.SORT1,C1.SORT3
                                )
                    LOOP

                       IF CNTRIB4.APNT_CNTRIB_AMT > 0  THEN --종교단체 기부금이 있는 경우(당해)
                               -- 기준소득금액(V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 10% + min (기준소득금액(V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT)*20%, 종교외지정기부금액(APNT_CNTRIB_AMT2))
                               /******************************************************************************************************************************
                                 종교단체 기부금이 있는 경우 공제한도
                                 기준소득금액 10% + MIN(기준소득금액 20%, 종교단체외지정기부금)

                                 기준소득금액 = 근로소득금액 - 정치자금기부금 공제대상기부금 - 법정기부금 공제대상기부금 - 우리사주조합기부금 공제대상기부금
                               ********************************************************************************************************************************/

                           IF CNTRIB4.CNTRIB_YY = IN_YY THEN     --올해 발생금액

                               IF CNTRIB4.CNTRIB_GIAMT  > (TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 10 /100)
                                                            + (CASE WHEN TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100) > CNTRIB4.APNT_CNTRIB_AMT2
                                                                    THEN CNTRIB4.APNT_CNTRIB_AMT2
                                                                    ELSE TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100)
                                                                    END))
                                                          - V_CNTRIB_DUC_SUM_AMT4041

                               THEN
                                   V_CNTRIB_DUC_AMT     := (TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 10 /100)
                                                              + (CASE WHEN TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100) > CNTRIB4.APNT_CNTRIB_AMT2
                                                                      THEN CNTRIB4.APNT_CNTRIB_AMT2
                                                                      ELSE TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100)
                                                                      END))
                                                            - V_CNTRIB_DUC_SUM_AMT4041 ;
                                   V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                                   V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                   V_CNTRIB_DESTAMT     := 0;  -- 기부금 당년 소멸금액
                                   V_CNTRIB_OVERAMT     := CNTRIB4.CNTRIB_GIAMT - V_CNTRIB_DUC_AMT;  -- 기부금 당년 이월금액
                               ELSE
                                   V_CNTRIB_DUC_AMT     := CNTRIB4.CNTRIB_GIAMT;
                                   V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                                   V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                                   V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                                   V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                               END IF;

                               V_CNTRIB_DUC_SUM_AMT4041 := V_CNTRIB_DUC_SUM_AMT4041 + V_CNTRIB_DUC_AMT; --지정기부금합계액
                               V_APNT_CNTRIB_DUC_OBJ_AMT := V_APNT_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 지정기부금 세액공제대상금액
                               V_LMT_CNTRIB_AMT := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;

                           END IF;

/* @@ZZODEM */
/*V_OCCR_LOC_NM   := '지정기부금 체크. STEP.1 ';
V_DB_ERROR_CTNT := 'V_APNT_CNTRIB_DUC_OBJ_AMT:'||V_APNT_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_AMT:'||V_CNTRIB_DUC_AMT||chr(13)||chr(10)||
                   'V_LABOR_EARN_AMT:'||V_LABOR_EARN_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_SUM_AMT:'||V_CNTRIB_DUC_SUM_AMT||chr(13)||chr(10)||
                   'CNTRIB4.APNT_CNTRIB_AMT2:'||CNTRIB4.APNT_CNTRIB_AMT2||chr(13)||chr(10)||
                   'CNTRIB4.CNTRIB_GIAMT:'||CNTRIB4.CNTRIB_GIAMT||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_SUM_AMT4041:'||V_CNTRIB_DUC_SUM_AMT4041||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                           --이월금액 다시 체크....

                           IF CNTRIB4.CNTRIB_YY < IN_YY AND CNTRIB4.CNTRIB_YY > IN_YY - 10 THEN   --1년전 ~ 4년전 이월금액
                           -- @VER.2019_5 이월공제기간 10년으로 연장(IN_YY - 5년에서 IN_YY - 10 으로 수정)

                               IF CNTRIB4.CNTRIB_OVERAMT > (TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 10 /100)
                                                              + (CASE WHEN TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100) > CNTRIB4.APNT_CNTRIB_AMT2
                                                                      THEN CNTRIB4.APNT_CNTRIB_AMT2
                                                                      ELSE TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100)
                                                                      END))
                                                            - V_CNTRIB_DUC_SUM_AMT4041
                                 THEN
                                 V_CNTRIB_DUC_AMT     := (TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 10 /100)
                                                            + (CASE WHEN TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100) > CNTRIB4.APNT_CNTRIB_AMT2
                                                                    THEN CNTRIB4.APNT_CNTRIB_AMT2
                                                                    ELSE TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100)
                                                                    END))
                                                          - V_CNTRIB_DUC_SUM_AMT4041;
                                 V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                                 V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                 -- 기부금 당년 공제금액
                                 V_CNTRIB_DESTAMT     := 0;                                                -- 기부금 당년 소멸금액
                                 V_CNTRIB_OVERAMT     := CNTRIB4.CNTRIB_OVERAMT - V_CNTRIB_DUC_AMT;       -- 기부금 당년 이월금액
                               ELSE
                                 V_CNTRIB_DUC_AMT     := CNTRIB4.CNTRIB_OVERAMT;
                                 V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                                 V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                 -- 기부금 당년 공제금액
                                 V_CNTRIB_DESTAMT     := 0;                                                -- 기부금 당년 소멸금액
                                 V_CNTRIB_OVERAMT     := 0;                                                -- 기부금 당년 이월금액
                               END IF;

                               --특별소득공제액에 포함
                               -- 2013년 이전 기부금만 특별소득공제액에 포함.--
                               IF CNTRIB4.CNTRIB_YY <= '2013' THEN
                                  --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                                  IF( V_CNTRIB_DUC_AMT > V_LABOR_TEMP_AMT ) THEN
                                      V_CNTRIB_DUC_AMT := V_LABOR_TEMP_AMT;
                                  END IF;

                                  -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                                  SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,1),
                                         SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,2)
                                    INTO V_LABOR_TEMP_AMT, V_CNTRIB_DUC_AMT
                                    FROM DUAL;


                                  V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_CNTRIB_DUC_AMT;
                                  V_CNTRIB_AMT_CYOV_AMT := V_CNTRIB_GONGAMT + V_CNTRIB_AMT_CYOV_AMT; -- 기부금(이월분)

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '>종합소득 과세표준 체크. STEP.26 기부금(이월분4)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_GONGAMT:'||V_CNTRIB_GONGAMT||chr(13)||chr(10)||
                   'V_CNTRIB_AMT_CYOV_AMT:'||V_CNTRIB_AMT_CYOV_AMT;
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */
                               END IF;

                               V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_CNTRIB_DUC_AMT;

                               V_CNTRIB_DUC_SUM_AMT4041 := V_CNTRIB_DUC_SUM_AMT4041 + V_CNTRIB_DUC_AMT; --지정기부금합계액
                               V_LMT_CNTRIB_AMT := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;

                               /*세액공제대상금액 2014년 기부금부터 적용되야 함.*/
                               -- (@VER.2018_11_1) : 2014 -> 2013
                               IF CNTRIB4.CNTRIB_YY >= '2014' THEN
                                  V_APNT_CNTRIB_DUC_OBJ_AMT := V_APNT_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 지정기부금 세액공제대상금액
                               END IF;

                           END IF;

                           -- 남은금액이 소멸되지 않고 내년도 이월금액으로 처리되게 수정(이월공제기간이 10년으로 연장되었기 때문)(@VER.2018_11_1)
                           IF CNTRIB4.CNTRIB_YY = IN_YY - 10 THEN   --5년전 이월금액[소멸대상] --> 2019년 연말정산에는 IN_YY - 6 으로(@VER.2018_11_1)
                           -- @VER.2019_5 이월공제기간 10년으로 연장(IN_YY - 5에서 개정내용대로 IN_YY -10으로 수정)

                               IF CNTRIB4.CNTRIB_OVERAMT > (TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 10 /100)
                                                              + (CASE WHEN TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100) > CNTRIB4.APNT_CNTRIB_AMT2
                                                                      THEN CNTRIB4.APNT_CNTRIB_AMT2
                                                                      ELSE TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100)
                                                                      END))
                                                            - V_CNTRIB_DUC_SUM_AMT4041

                               THEN
                                 V_CNTRIB_DUC_AMT     := (TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 10 /100)
                                                            + (CASE WHEN TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100) > CNTRIB4.APNT_CNTRIB_AMT2
                                                                    THEN CNTRIB4.APNT_CNTRIB_AMT2
                                                                    ELSE TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 20 /100)
                                                                    END))
                                                          - V_CNTRIB_DUC_SUM_AMT4041 ;
                                 V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT;  -- 기부금 전년까지 공제금액
                                 V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                -- 기부금 당년 공제금액
                                 V_CNTRIB_DESTAMT     := 0;                                               -- 기부금 당년 소멸금액(@VER.2018_11_1)
                                 V_CNTRIB_OVERAMT     := CNTRIB4.CNTRIB_OVERAMT - V_CNTRIB_DUC_AMT;       -- 기부금 당년 이월금액(@VER.2018_11_1)
                               ELSE
                                 V_CNTRIB_DUC_AMT     := CNTRIB4.CNTRIB_OVERAMT;
                                 V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT;   -- 기부금 전년까지 공제금액
                                 V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                 -- 기부금 당년 공제금액
                                 V_CNTRIB_DESTAMT     := 0;                                                -- 기부금 당년 소멸금액
                                 V_CNTRIB_OVERAMT     := 0;                                                -- 기부금 당년 이월금액
                               END IF;

                                --특별소득공제액에 포함
                                 --@VER.2015 ZODEM 2016.02.02 2013년 이전 기부금만 특별소득공제액에 포함.--
                                IF CNTRIB4.CNTRIB_YY <= '2013' THEN
                                  --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                                  IF( V_CNTRIB_DUC_AMT > V_LABOR_TEMP_AMT ) THEN
                                      V_CNTRIB_DUC_AMT := V_LABOR_TEMP_AMT;
                                  END IF;

                                  -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                                  SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,1),
                                         SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,2)
                                    INTO V_LABOR_TEMP_AMT, V_CNTRIB_DUC_AMT
                                    FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.27 기부금(이월분5)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                                  V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_CNTRIB_DUC_AMT;
                                  V_CNTRIB_AMT_CYOV_AMT := V_CNTRIB_GONGAMT + V_CNTRIB_AMT_CYOV_AMT; -- 기부금(이월분)

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '>종합소득 과세표준 체크. STEP.27 기부금(이월분5)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_AMT_CYOV_AMT:'||V_CNTRIB_AMT_CYOV_AMT;
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                                END IF;
                                  V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_CNTRIB_DUC_AMT;
                                  V_CNTRIB_DUC_SUM_AMT4041 := V_CNTRIB_DUC_SUM_AMT4041 + V_CNTRIB_DUC_AMT; --지정기부금합계액
                                  V_LMT_CNTRIB_AMT := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;

                                  /*@VER.2015 ZODEM 2016.02.17세액공제대상금액 2014년 기부금부터 적용되야 함.*/
                                  -- (@VER.2018_11_1) : 2014 -> 2013
                                  IF CNTRIB4.CNTRIB_YY >= '2014' THEN
                                     V_APNT_CNTRIB_DUC_OBJ_AMT := V_APNT_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 지정기부금 세액공제대상금액
                                  END IF;

                           END IF;


                       ELSE  --종교단체 기부금이 없는 경우
                         /******************************************************************************************************************************
                             종교단체 기부금이 업는 경우 공제한도 : 기준소득금액 30%
                             기준소득금액 = 근로소득금액 - 정치자금기부금 공제대상기부금 - 법정기부금 공제대상기부금 - 우리사주조합기부금 공제대상기부금
                         ********************************************************************************************************************************/
                         IF CNTRIB4.CNTRIB_YY = IN_YY THEN     --당년도 발생금액

                             IF CNTRIB4.CNTRIB_GIAMT > TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 30 /100) - V_CNTRIB_DUC_SUM_AMT4041 THEN
                               V_CNTRIB_DUC_AMT     := TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 30 /100) - V_CNTRIB_DUC_SUM_AMT4041;
                               V_CNTRIB_PREAMT      := 0;                                        -- 기부금 전년까지 공제금액
                               V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                         -- 기부금 당년 공제금액
                               V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                               V_CNTRIB_OVERAMT     := CNTRIB4.CNTRIB_GIAMT - V_CNTRIB_DUC_AMT;   -- 기부금 당년 이월금액
                             ELSE
                               V_CNTRIB_DUC_AMT     := CNTRIB4.CNTRIB_GIAMT;
                               V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                               V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                               V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                               V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                             END IF;

                             V_CNTRIB_DUC_SUM_AMT4041 := V_CNTRIB_DUC_SUM_AMT4041 + V_CNTRIB_DUC_AMT; --지정기부금합계액
                             V_APNT_CNTRIB_DUC_OBJ_AMT := V_APNT_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 지정기부금 세액공제대상금액
                             V_LMT_CNTRIB_AMT := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;

/*
V_OCCR_LOC_NM   := '지정기부금 (종교없을경우)';
V_DB_ERROR_CTNT := 'CNTRIB4.CNTRIB_GIAMT:'||CNTRIB4.CNTRIB_GIAMT||chr(13)||chr(10)||
                   'V_LABOR_EARN_AMT:'||V_LABOR_EARN_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_SUM_AMT:'||V_CNTRIB_DUC_SUM_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_SUM_AMT4041:'||V_CNTRIB_DUC_SUM_AMT4041||chr(13)||chr(10)||
                   'V_CNTRIB_DUC_AMT:'||V_CNTRIB_DUC_AMT||chr(13)||chr(10)||
                   'V_APNT_CNTRIB_DUC_OBJ_AMT:'||V_APNT_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10)||
                   'V_LMT_CNTRIB_AMT:'||V_LMT_CNTRIB_AMT||chr(13)||chr(10);

SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */


                         END IF;

                         IF CNTRIB4.CNTRIB_YY < IN_YY AND CNTRIB4.CNTRIB_YY > IN_YY - 10 THEN   --1년전 ~ 4년전 이월금액
                         -- @VER.2019_5 이월공제기간 10년으로 연장(IN_YY - 5에서 IN_YY -10으로 수정)
                             IF CNTRIB4.CNTRIB_OVERAMT > TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 30 /100) - V_CNTRIB_DUC_SUM_AMT4041 THEN
                               V_CNTRIB_DUC_AMT     := TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 30 /100) - V_CNTRIB_DUC_SUM_AMT4041;
                               V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                               V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                 -- 기부금 당년 공제금액
                               V_CNTRIB_DESTAMT     := 0;                                                -- 기부금 당년 소멸금액
                               V_CNTRIB_OVERAMT     := CNTRIB4.CNTRIB_OVERAMT - V_CNTRIB_DUC_AMT;       -- 기부금 당년 이월금액
                             ELSE
                               V_CNTRIB_DUC_AMT     := CNTRIB4.CNTRIB_OVERAMT;
                               V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                               V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                 -- 기부금 당년 공제금액
                               V_CNTRIB_DESTAMT     := 0;                                                -- 기부금 당년 소멸금액
                               V_CNTRIB_OVERAMT     := 0;                                                -- 기부금 당년 이월금액
                             END IF;


                             --특별소득공제액에 포함
                             --@VER.2015 ZODEM 2016.02.02 2013년 이전 기부금만 특별소득공제액에 포함.--
                             IF CNTRIB4.CNTRIB_YY <= '2013' THEN
                                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                                IF( V_CNTRIB_DUC_AMT > V_LABOR_TEMP_AMT ) THEN
                                    V_CNTRIB_DUC_AMT := V_LABOR_TEMP_AMT;
                                END IF;

                                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,1),
                                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,2)
                                  INTO V_LABOR_TEMP_AMT, V_CNTRIB_DUC_AMT
                                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.28 기부금(이월분6)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                               V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_CNTRIB_DUC_AMT;
                               V_CNTRIB_AMT_CYOV_AMT := V_CNTRIB_GONGAMT + V_CNTRIB_AMT_CYOV_AMT; -- 기부금(이월분)

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '>종합소득 과세표준 체크. STEP.28 기부금(이월분4)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_AMT_CYOV_AMT:'||V_CNTRIB_AMT_CYOV_AMT;
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */
                             END IF;
                               V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_CNTRIB_DUC_AMT;
                               V_CNTRIB_DUC_SUM_AMT4041 := V_CNTRIB_DUC_SUM_AMT4041 + V_CNTRIB_DUC_AMT; --지정기부금합계액
                               V_LMT_CNTRIB_AMT := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;

                               /*@VER.2015 ZODEM 2016.02.17세액공제대상금액 2014년 기부금부터 적용되야 함.*/
                               -- (@VER.2018_11_1) : 2014 -> 2013
                               IF CNTRIB4.CNTRIB_YY >= '2014' THEN
                                  V_APNT_CNTRIB_DUC_OBJ_AMT := V_APNT_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 지정기부금 세액공제대상금액
                               END IF;

                         END IF;

                         -- 남은금액이 소멸되지 않고 내년도 이월금액으로 처리되게 수정(이월공제기간이 10년으로 연장되었기 때문)(@VER.2018_11_1)
                         IF CNTRIB4.CNTRIB_YY = IN_YY - 10 THEN   --5년전[소멸대상] --> 2019년 연말정산에는 IN_YY - 6 으로(@VER.2018_11_1)
                         -- @VER.2019_5 이월공제기간 10년으로 연장(IN_YY - 5에서 IN_YY -10으로 수정)
                             IF CNTRIB4.CNTRIB_OVERAMT > TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 30 /100) - V_CNTRIB_DUC_SUM_AMT4041 THEN
                               V_CNTRIB_DUC_AMT     := TRUNC((V_LABOR_EARN_AMT - V_CNTRIB_DUC_SUM_AMT) * 30 /100) - V_CNTRIB_DUC_SUM_AMT4041;
                               V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                               V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                 -- 기부금 당년 공제금액
                               V_CNTRIB_DESTAMT     := 0;                                                -- 기부금 당년 소멸금액(@VER.2018_11_1)
                               V_CNTRIB_OVERAMT     := CNTRIB4.CNTRIB_OVERAMT - V_CNTRIB_DUC_AMT;        -- 기부금 당년 이월금액(@VER.2018_11_1)
                             ELSE
                               V_CNTRIB_DUC_AMT     := CNTRIB4.CNTRIB_OVERAMT;
                               V_CNTRIB_PREAMT      := CNTRIB4.CNTRIB_PREAMT + CNTRIB4.CNTRIB_GONGAMT; -- 기부금 전년까지 공제금액
                               V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                                 -- 기부금 당년 공제금액
                               V_CNTRIB_DESTAMT     := 0;                                                -- 기부금 당년 소멸금액
                               V_CNTRIB_OVERAMT     := 0;                                                -- 기부금 당년 이월금액
                             END IF;

                            --특별소득공제액에 포함
                            --@VER.2015 ZODEM 2016.02.02 2013년 이전 기부금만 특별소득공제액에 포함.--
                             IF CNTRIB4.CNTRIB_YY <= '2013' THEN
                                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                                IF( V_CNTRIB_DUC_AMT > V_LABOR_TEMP_AMT ) THEN
                                    V_CNTRIB_DUC_AMT := V_LABOR_TEMP_AMT;
                                END IF;

                                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,1),
                                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CNTRIB_DUC_AMT,2)
                                  INTO V_LABOR_TEMP_AMT, V_CNTRIB_DUC_AMT
                                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.29 기부금(이월분7)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                                V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_CNTRIB_DUC_AMT;
                                V_CNTRIB_AMT_CYOV_AMT := V_CNTRIB_GONGAMT + V_CNTRIB_AMT_CYOV_AMT; -- 기부금(이월분)

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '>종합소득 과세표준 체크. STEP.29 기부금(이월분4)';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  과세표준:'||V_LABOR_TEMP_AMT||chr(13)||chr(10)||
                   'V_CNTRIB_AMT_CYOV_AMT:'||V_CNTRIB_AMT_CYOV_AMT;
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */
                             END IF;

                             V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_CNTRIB_DUC_AMT;
                             V_CNTRIB_DUC_SUM_AMT4041 := V_CNTRIB_DUC_SUM_AMT4041 + V_CNTRIB_DUC_AMT; --지정기부금합계액
                             V_LMT_CNTRIB_AMT := V_LMT_CNTRIB_AMT - V_CNTRIB_DUC_AMT;

                             /*@VER.2015 ZODEM 2016.02.17세액공제대상금액 2014년 기부금부터 적용되야 함.*/
                             -- (@VER.2018_11_1) : 2014 -> 2013
                             IF CNTRIB4.CNTRIB_YY >= '2014' THEN
                                V_APNT_CNTRIB_DUC_OBJ_AMT := V_APNT_CNTRIB_DUC_OBJ_AMT + V_CNTRIB_DUC_AMT; -- 지정기부금 세액공제대상금액
                             END IF;

                         END IF;

                       END IF;


                      IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
                          V_TMP_STEP := 'D12';
                          DELETE FROM PAYM436
                           WHERE YY             = IN_YY
                             AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                             AND SETT_FG        = V_SETT_FG
                             AND RPST_PERS_NO   = REC.RPST_PERS_NO
                             AND CNTRIB_YY      = CNTRIB4.CNTRIB_YY
                             AND CNTRIB_TYPE_CD = CNTRIB4.CNTRIB_TYPE_CD
                             ;

                            IF (CNTRIB4.CNTRIB_GIAMT <> 0 OR V_CNTRIB_PREAMT <> 0 OR V_CNTRIB_GONGAMT <> 0
                              OR V_CNTRIB_DESTAMT <> 0 OR V_CNTRIB_OVERAMT <> 0) THEN
                              V_TMP_STEP := '007';
                              INSERT INTO PAYM436(BIZR_DEPT_CD     --사업자부서코드
                                                 ,YY               --년도
                                                 ,SETT_FG           --정산구분
                                                 ,RPST_PERS_NO     --대표개인번호
                                                 ,CNTRIB_YY         --기부년도
                                                 ,CNTRIB_TYPE_CD   --기부금유형
                                                 ,CNTRIB_GIAMT     --기부금액
                                                 ,CNTRIB_PREAMT     --전년까지 공제금액
                                                 ,CNTRIB_GONGAMT   --당년 공제금액
                                                 ,CNTRIB_DESTAMT   --당년 소멸금액
                                                 ,CNTRIB_OVERAMT   --당년 이월금액
                                                 ,INPT_ID           --입력자ID
                                                 ,INPT_DTTM         --입력일시
                                                 ,INPT_IP           --입력자IP
                                                  )
                                    VALUES(IN_BIZR_DEPT_CD
                                          ,IN_YY
                                          ,V_SETT_FG
                                          ,REC.RPST_PERS_NO
                                          ,CNTRIB4.CNTRIB_YY
                                          ,CNTRIB4.CNTRIB_TYPE_CD
                                          ,CNTRIB4.CNTRIB_GIAMT
                                          ,V_CNTRIB_PREAMT
                                          ,V_CNTRIB_GONGAMT
                                          ,V_CNTRIB_DESTAMT
                                          ,V_CNTRIB_OVERAMT
                                          ,IN_INPT_ID
                                          ,SYSDATE
                                          ,IN_INPT_IP
                                           );
                            END IF;
                      ELSE
                          V_TMP_STEP := 'D13';
                          DELETE FROM PAYM432
                           WHERE YY = IN_YY
                             AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                             AND SETT_FG        = V_SETT_FG
                             AND RPST_PERS_NO   = REC.RPST_PERS_NO
                             AND CNTRIB_YY      = CNTRIB4.CNTRIB_YY
                             AND CNTRIB_TYPE_CD = CNTRIB4.CNTRIB_TYPE_CD --IN ('A032400006', 'A032400007')
                             AND YRETXA_SEQ = 1 --(2014재계산):1차만 지웁니다.
                             ;

                            IF (CNTRIB4.CNTRIB_GIAMT <> 0 OR V_CNTRIB_PREAMT <> 0 OR V_CNTRIB_GONGAMT <> 0
                              OR V_CNTRIB_DESTAMT <> 0 OR V_CNTRIB_OVERAMT <> 0) THEN
                              V_TMP_STEP := '008';

                              INSERT INTO PAYM432(BIZR_DEPT_CD     --사업자부서코드
                                                 ,YY               --년도
                                                 ,YRETXA_SEQ       --정상차수(@VER.2017_0)
                                                 ,SETT_FG           --정산구분
                                                 ,RPST_PERS_NO     --대표개인번호
                                                 ,CNTRIB_YY         --기부년도
                                                 ,CNTRIB_TYPE_CD   --기부금유형
                                                 ,CNTRIB_GIAMT     --기부금액
                                                 ,CNTRIB_PREAMT     --전년까지 공제금액
                                                 ,CNTRIB_GONGAMT   --당년 공제금액
                                                 ,CNTRIB_DESTAMT   --당년 소멸금액
                                                 ,CNTRIB_OVERAMT   --당년 이월금액
                                                 ,INPT_ID           --입력자ID
                                                 ,INPT_DTTM         --입력일시
                                                 ,INPT_IP           --입력자IP
                                                  )
                                    VALUES(IN_BIZR_DEPT_CD
                                          ,IN_YY
                                          ,IN_YRETXA_SEQ --정상차수(@VER.2017_0)
                                          ,V_SETT_FG
                                          ,REC.RPST_PERS_NO
                                          ,CNTRIB4.CNTRIB_YY
                                          ,CNTRIB4.CNTRIB_TYPE_CD
                                          ,CNTRIB4.CNTRIB_GIAMT
                                          ,V_CNTRIB_PREAMT
                                          ,V_CNTRIB_GONGAMT
                                          ,V_CNTRIB_DESTAMT
                                          ,V_CNTRIB_OVERAMT
                                          ,IN_INPT_ID
                                          ,SYSDATE
                                          ,IN_INPT_IP
                                           );
                            END IF;
                        END IF;
                    END LOOP;
                    EXCEPTION
                        WHEN OTHERS THEN
                             OUT_RTN := 0;
                             OUT_MSG := '지정기부금계산결과 생성오류(대표개인번호 : '||V_RPST_PERS_NO||SQLCODE || ':' || SQLERRM || ')';
                             RETURN;
                END;




/* 특별소득공제계 */
                V_SPCL_INCMDED_TT_AMT := V_SPCL_DUC_AMT;
                /* 차감소득금액 */
                V_SBTR_EARN_AMT := V_LABOR_TEMP_AMT;


/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.30 차감소득금액';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/

                --DBMS_OUTPUT.PUT_LINE('V_SBTR_EARN_AMT 차감소득금액 = '||TO_CHAR(V_SBTR_EARN_AMT) );




                --투자조합출자공제 등 반영 전 과세표준
                V_GNR_EARN_TAX_STAD_AMT_2 := V_SBTR_EARN_AMT; --투자조합출자공제 전 과세표준

                --그밖의 소득공제

                V_REST_INCMDED_TT_AMT := 0;

                --개인연금저축공제
                V_PERS_PESN_SAV_DUC_AMT := REC.PERS_PENS;
                IF V_PERS_PESN_SAV_DUC_AMT > 0 THEN   -- 불입액의 40%
                    V_PERS_PESN_SAV_DUC_AMT := TRUNC(V_PERS_PESN_SAV_DUC_AMT * (40 / 100));
                    IF V_PERS_PESN_SAV_DUC_AMT > 720000 THEN    -- 72만원한도
                        V_PERS_PESN_SAV_DUC_AMT := 720000;
                    END IF;
                END IF;
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PERS_PESN_SAV_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PERS_PESN_SAV_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_PERS_PESN_SAV_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.31 개인연금저축공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/

                V_REST_INCMDED_TT_AMT := V_REST_INCMDED_TT_AMT + V_PERS_PESN_SAV_DUC_AMT;

                --투자조합출자공제 등 반영 전 과세표준
                V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_2 - V_PERS_PESN_SAV_DUC_AMT;


                --소기업ㆍ소상공인 공제부금 소득공제
                V_CO_DUC_AMT := REC.DUC_INME;

                /* @VER.2017_12 소기업ㆍ소상공인 공제부금 소득공제 소득수준별 공제한도 차등화 */
                /* 사업(근로)소득금액 4천만원 이하 : 500만원
                                      4천만원~1억원: 300만원
                                      1억원 초과 :   200만원  */
                IF V_LABOR_EARN_AMT <= 40000000 THEN
                   V_LMT_CO_DUC_AMT := 5000000;
                ELSIF V_LABOR_EARN_AMT > 40000000 AND V_LABOR_EARN_AMT <= 100000000 THEN
                   V_LMT_CO_DUC_AMT := 3000000;
                ELSIF V_LABOR_EARN_AMT > 100000000 THEN
                   V_LMT_CO_DUC_AMT := 2000000;
                END IF;

                --소기업ㆍ소상공인 공제부금 소득공제 공제한도 체크
                IF V_CO_DUC_AMT > V_LMT_CO_DUC_AMT THEN
                    V_CO_DUC_AMT := V_LMT_CO_DUC_AMT;
                END IF;

                /* @VER.2016_1 2015.12.31 이전가입자 이거나 2016.01.01 이후 가입자는 총급여액 7천만한원 이하인 경우 포함*/
                IF V_CO_DUC_AMT > 0 THEN
                  IF ( REC.DUC_INME_JOIN_DT < '20160101' OR (REC.DUC_INME_JOIN_DT >= '20160101' AND V_LABOR_EARN_TT_SALY_AMT <= 70000000 )) THEN
                    V_CO_DUC_AMT := V_CO_DUC_AMT;
                  ELSE
                    V_CO_DUC_AMT := 0;
                  END IF;
                END IF;

                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                IF( V_CO_DUC_AMT > V_LABOR_TEMP_AMT ) THEN
                    V_CO_DUC_AMT := V_LABOR_TEMP_AMT;
                END IF;

                --종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CO_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CO_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_CO_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.33 소기업공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                V_REST_INCMDED_TT_AMT := V_REST_INCMDED_TT_AMT + V_CO_DUC_AMT;

                --투자조합출자공제 등 반영 전 과세표준
                V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_2 - V_CO_DUC_AMT;

                V_DUC_MAX_CO_AMT := V_CO_DUC_AMT;



/** (40)주택마련 저축 소득공제  **/

            BEGIN
                --주택마련저축소득공제공제금액
                V_SUBS_SAV1 := REC.SUBS_SAV1;                   --2009년이전청약저축
                V_SUBS_SAV2 := REC.SUBS_SAV2;                   --2010년이후청약저축
                V_LABORR_HSSV := REC.LABORR_HSSV;             --근로자주택마련저축
                V_HOUS_SUBS_GNR_SAV := REC.HOUS_SUBS_GNR_SAV; --주택청약종합저축
                V_LNTM_HSSV := 0;                 --장기주택마련저축 : 2013년 삭제됨
                V_HOUS_SCALE_YN := REC.HOUS_SCALE_YN; --국민주택규모이하
                V_HOUS_OWN_YN := REC.HOUS_OWN_YN; --연중무주택여부
                V_SLF_MNRT_PAY_YN := REC.SLF_MNRT_PAY_YN;      --월세액공제 - 본인이 월세액 지급여부 확인
                V_LESE_HOUS_SCALE_BLW_YN := REC.LESE_HOUS_SCALE_BLW_YN;      --월세액 - 임차주택이 국민주택규모이하인지 여부확인
                V_JOIN_THTM_HOUS_CNT := REC.JOIN_THTM_HOUS_CNT;          --2009년 12. 31일 이전 청약저축가입자의 경우 가입당시주택수
                V_JOIN_THTM_HOUS_SCALE_BLW_YN := REC.JOIN_THTM_HOUS_SCALE_BLW_YN;      --2009년 12. 31일 이전 청약저축가입자의 경우 1주택자이면 가입당시 주택이 국민주택규모이하인지 여부 확인
                V_JOIN_THTM_BASI_MPRC_BLW_YN := REC.JOIN_THTM_BASI_MPRC_BLW_YN;



                --40-가.청약저축
                  --2009년이전청약저축 => 세대주=Y, 주택수 <= 1, 구입당시기준시가 3억이하 = Y, 국민주택이하 = 'Y'
                  --2010년이후청약저축 => 세대주=Y, 주택수 = 0, 연중무주택(HOUS_OWN_YN) = Y
                IF V_SUBS_SAV1 > 0 AND
                   ((V_JOIN_THTM_HOUS_CNT = 1 AND V_JOIN_THTM_BASI_MPRC_BLW_YN = 'Y' AND V_JOIN_THTM_HOUS_SCALE_BLW_YN = 'Y') OR
                     V_JOIN_THTM_HOUS_CNT  = 0)
                THEN
                    V_SUBS_SAV := V_SUBS_SAV1;
                END IF;

                IF V_SUBS_SAV2 > 0 AND V_HOUS_OWN_CNT = 0 AND V_HOUS_OWN_YN = 'Y' THEN
                    V_SUBS_SAV := V_SUBS_SAV2;
                END IF;


--                DBMS_OUTPUT.PUT_LINE('V_SUBS_SAV1 = '||TO_CHAR(V_SUBS_SAV1) );
--                DBMS_OUTPUT.PUT_LINE('V_SUBS_SAV2 = '||TO_CHAR(V_SUBS_SAV2) );
--                DBMS_OUTPUT.PUT_LINE('1V_SUBS_SAV = '||TO_CHAR(V_SUBS_SAV) );

                V_ENT_DT := NULL;
                 SELECT NVL(MAX(ENT_DT), '')  -- 가입일
                   INTO V_ENT_DT
                   FROM PAYM427
                  WHERE YY           = IN_YY
                    AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                    AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                    AND SETT_FG      = V_SETT_FG
                    AND RPST_PERS_NO = REC.RPST_PERS_NO
                    AND PAY_CTNT_FG  = 'A034900005' -- 청약저축
                  ;

                IF  V_SUBS_SAV > 0 AND V_HOUSEHOLDER_YN = 'Y' THEN

                    -- 2015 연말정산 수정 : 납입한도액 변경. 청약저축은 7천만원 이하자만 공제 - @VER.2015
--                    IF V_LABOR_EARN_TT_SALY_AMT > 70000000 THEN
--                        V_SUBS_SAV := 0;
--                    ELSE
--                        -- 총급여 7천만원 이하자는 240만원까지 공제
--                        IF V_SUBS_SAV  >  2400000  THEN
--                           V_SUBS_SAV  :=  2400000;
--                        END IF;

                      -- 2015 연말정산 수정 : 납입한도액 변경. 청약저축은 7천만원 이하자만 공제 - @VER.2015
                    IF V_LABOR_EARN_TT_SALY_AMT > 70000000  AND V_ENT_DT >= '20150101' THEN
                        V_SUBS_SAV := 0;
                    ELSE
                        IF V_LABOR_EARN_TT_SALY_AMT > 70000000 AND V_ENT_DT < '20150101' THEN
                            /* (@VER.2018_12) (2014년이전 가입자는 총급여 7000만원초과시 연120만원까지 가능) (삭제)
                            IF V_SUBS_SAV  >  1200000  THEN
                               V_SUBS_SAV  :=  1200000;
                            END IF;
                            */
                            V_SUBS_SAV := 0;
                        ELSE
                            -- 총급여 7천만원 이하자는 240만원까지 공제
                            IF V_SUBS_SAV  >  2400000  THEN
                               V_SUBS_SAV  :=  2400000;
                            END IF;
                        END IF;

                        V_SUBS_SAV := TRUNC( V_SUBS_SAV * 40 / 100);

                        IF  V_SUBS_SAV + V_HOUS_FUND_DUC_HAP_AMT > 3000000 THEN    -- 300만원 한도..
                            V_SUBS_SAV := 3000000 - V_HOUS_FUND_DUC_HAP_AMT;
                        END IF;

                        --DBMS_OUTPUT.PUT_LINE('2V_SUBS_SAV = '||TO_CHAR(V_SUBS_SAV) );
                        /* @VER.2015 2015년 기준 사항 */
                        IF V_HOUS_MOG_ITT_6 > 0 THEN
                           IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 +
                              V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV > 18000000 THEN
                              V_SUBS_SAV := 18000000 - ( V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 +
                                                         V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT );  --1800만원 한도..
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 > 0 AND V_HOUS_MOG_ITT_6 = 0 THEN
                           IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 +
                              V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV > 15000000 THEN --1500만원 한도..
                              V_SUBS_SAV := 15000000 - ( V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 +
                                                         V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT );
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_2 > 0  AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4) > 0 THEN
                           IF V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV  > 10000000 THEN -- 1000만원 한도..
                              V_SUBS_SAV := 10000000 - (V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_1 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2) > 0 THEN
                           IF V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV > 6000000 THEN -- 600만원 한도..
                              V_SUBS_SAV := 6000000 - ( V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1) > 0 THEN
                           IF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV > 5000000 THEN -- 500만원 한도..
                              V_SUBS_SAV := 5000000 - ( V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_9 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8) > 0 THEN
                           IF V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV > 3000000 THEN -- 300만원 한도..
                              V_SUBS_SAV := 3000000 - ( V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        END IF;



                        IF  V_SUBS_SAV <  0 THEN
                            V_SUBS_SAV  :=  0;
                        END IF;
                    END IF;
                ELSE
                  V_SUBS_SAV := 0;
                END IF;

                V_ENT_DT := NULL;
                SELECT NVL(MAX(ENT_DT), '')  -- 가입일
                  INTO V_ENT_DT
                   FROM PAYM427
                  WHERE YY           = IN_YY
                    AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                    AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                    AND SETT_FG      = V_SETT_FG
                    AND RPST_PERS_NO = REC.RPST_PERS_NO
                    AND PAY_CTNT_FG  = 'A034900006' -- 주택청약종합 저축
                  ;


                 --DBMS_OUTPUT.PUT_LINE('3V_SUBS_SAV = '||TO_CHAR(V_SUBS_SAV) );

                --40-나.주택청약종합저축
                  --주택청약종합저축 => 세대주=Y, 주택수=0, 연중무주택 = 'Y'
                IF V_HOUS_SUBS_GNR_SAV > 0 AND V_HOUSEHOLDER_YN = 'Y' AND V_HOUS_OWN_CNT = 0 AND V_HOUS_OWN_YN = 'Y' THEN

                    -- 2015 연말정산 수정 : 납입한도액 변경. 7천만원 초과자 중, 2014년까지 가입자는 120만원, 7천만원 이하자는 240만원 공 - @VER.2015
                    IF V_LABOR_EARN_TT_SALY_AMT > 70000000 AND V_ENT_DT >= '20150101' THEN
                        V_HOUS_SUBS_GNR_SAV := 0;  -- 2015. 1. 1 이후 가입자 중 총급여 7천만원 초과자는 공제하지 않음
                    ELSE
                        IF V_LABOR_EARN_TT_SALY_AMT > 70000000 AND V_ENT_DT < '20150101' THEN
                            /* (@VER.2018_12) (2014년이전 가입자는 총급여 7000만원초과시 연120만원까지 가능) (삭제)
                            IF V_HOUS_SUBS_GNR_SAV  >  1200000  THEN -- 2014. 12. 31 이전 가입자는 소득이 7천만원 넘어도 2017년까지 120만원까지 공제함
                               V_HOUS_SUBS_GNR_SAV  :=  1200000;
                            END IF;
                            */
                            V_HOUS_SUBS_GNR_SAV := 0;

                        ELSE -- 2015 연말정산 개선 : 납입한도액 변경(120만 -> 240만) - @VER.2015
                            IF V_HOUS_SUBS_GNR_SAV  >  2400000  THEN --(월 납입액 10만원 이하에 한함)
                               V_HOUS_SUBS_GNR_SAV  :=  2400000;
                            END IF;
                        END IF;

                        V_HOUS_SUBS_GNR_SAV := TRUNC(V_HOUS_SUBS_GNR_SAV * 40 / 100);

                        IF V_HOUS_SUBS_GNR_SAV + V_SUBS_SAV + V_HOUS_FUND_DUC_HAP_AMT > 3000000 THEN    -- 300만원 한도..
                           V_HOUS_SUBS_GNR_SAV := 3000000 - (V_HOUS_FUND_DUC_HAP_AMT +  V_SUBS_SAV);
                        END IF;

                        /* @VER.2015 2015년 기준 사항 */
                        IF V_HOUS_MOG_ITT_6 > 0 THEN
                           IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 +
                              V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV > 18000000 THEN
                              V_HOUS_SUBS_GNR_SAV := 18000000 - ( V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 +
                                                         V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV +  V_HOUS_FUND_DUC_HAP_AMT );  --1800만원 한도..
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 > 0 AND V_HOUS_MOG_ITT_6 = 0 THEN
                           IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 +
                              V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV > 15000000 THEN --1500만원 한도..
                              V_HOUS_SUBS_GNR_SAV := 15000000 - ( V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 +
                                                         V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_FUND_DUC_HAP_AMT );
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_2 > 0  AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4) > 0 THEN
                           IF V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV  > 10000000 THEN -- 1000만원 한도..
                              V_HOUS_SUBS_GNR_SAV := 10000000 - (V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_1 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2) > 0 THEN
                           IF V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV > 6000000 THEN -- 600만원 한도..
                              V_HOUS_SUBS_GNR_SAV := 6000000 - ( V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1) > 0 THEN
                           IF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV > 5000000 THEN -- 500만원 한도..
                              V_HOUS_SUBS_GNR_SAV := 5000000 - ( V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        ELSIF V_HOUS_MOG_ITT_9 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8) > 0 THEN
                           IF V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV > 3000000 THEN -- 300만원 한도..
                              V_HOUS_SUBS_GNR_SAV := 3000000 - ( V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_FUND_DUC_HAP_AMT);
                           END IF;
                        END IF;

                        IF  V_HOUS_SUBS_GNR_SAV < 0 THEN
                            V_HOUS_SUBS_GNR_SAV  :=  0;
                        END IF;
                    END IF;
                ELSE
                  V_HOUS_SUBS_GNR_SAV := 0;
                END IF;


               --40-라.근로자주택마련저축
                 --근로자주택마련저축 => 세대주=Y, 주택수=1이하, 국민주택규모이=Y, 기준시가 3억이하=체크안함
                  IF V_LABORR_HSSV > 0 AND V_HOUSEHOLDER_YN = 'Y' AND ((V_HOUS_OWN_CNT = 1 AND V_HOUS_SCALE_YN = 'Y') OR V_HOUS_OWN_YN = 'Y') THEN
                    IF V_LABORR_HSSV  >  1800000  THEN --(월 납입액 15만원 이하에 한함)
                       V_LABORR_HSSV  :=  1800000;
                    END IF;

                    V_LABORR_HSSV := TRUNC(V_LABORR_HSSV * 40 / 100);

                    IF V_LABORR_HSSV + V_LNTM_HSSV + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_HOUS_FUND_DUC_HAP_AMT > 3000000 THEN    -- 300만원 한도..
                       V_LABORR_HSSV := 3000000 - ( V_HOUS_FUND_DUC_HAP_AMT +  V_SUBS_SAV +  V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV);
                    END IF;

                     /* @VER.2015 2015년 기준 사항 */
                    IF V_HOUS_MOG_ITT_6 > 0 THEN
                       IF V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 +
                          V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_LABORR_HSSV > 18000000 THEN
                          V_LABORR_HSSV := 18000000 - ( V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 +
                                                     V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_HOUS_FUND_DUC_HAP_AMT );  --1800만원 한도..
                       END IF;
                    ELSIF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 > 0 AND V_HOUS_MOG_ITT_6 = 0 THEN
                       IF V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 +
                          V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_LABORR_HSSV> 15000000 THEN --1500만원 한도..
                          V_LABORR_HSSV := 15000000 - ( V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 +
                                                     V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_HOUS_FUND_DUC_HAP_AMT );
                       END IF;
                    ELSIF V_HOUS_MOG_ITT_2 > 0  AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4) > 0 THEN
                       IF V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_LABORR_HSSV  > 10000000 THEN -- 1000만원 한도..
                          V_LABORR_HSSV := 10000000 - (V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_HOUS_FUND_DUC_HAP_AMT);
                       END IF;
                    ELSIF V_HOUS_MOG_ITT_1 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2) > 0 THEN
                       IF V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_LABORR_HSSV > 6000000 THEN -- 600만원 한도..
                          V_LABORR_HSSV := 6000000 - ( V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_HOUS_FUND_DUC_HAP_AMT);
                       END IF;
                    ELSIF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1) > 0 THEN
                       IF V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_LABORR_HSSV > 5000000 THEN -- 500만원 한도..
                          V_LABORR_HSSV := 5000000 - ( V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8 + V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_HOUS_FUND_DUC_HAP_AMT);
                       END IF;
                    ELSIF V_HOUS_MOG_ITT_9 > 0 AND (V_HOUS_MOG_ITT_6 + V_HOUS_MOG_ITT_7 + V_HOUS_MOG_ITT_3 + V_HOUS_MOG_ITT_4 + V_HOUS_MOG_ITT_2 + V_HOUS_MOG_ITT_1 + V_HOUS_MOG_ITT_5 + V_HOUS_MOG_ITT_8) > 0 THEN
                       IF V_HOUS_MOG_ITT_9 + V_HOUS_FUND_DUC_HAP_AMT + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_LABORR_HSSV > 3000000 THEN -- 300만원 한도..
                          V_LABORR_HSSV := 3000000 - ( V_HOUS_MOG_ITT_9 + V_SUBS_SAV + V_HOUS_SUBS_GNR_SAV + V_LNTM_HSSV + V_HOUS_FUND_DUC_HAP_AMT);
                       END IF;
                    END IF;

                    IF   V_LABORR_HSSV <  0 THEN
                         V_LABORR_HSSV  :=  0;
                    END IF;
                ELSE
                  V_LABORR_HSSV := 0;
                END IF;



                -- 청약저축 소득공제
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SUBS_SAV,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_SUBS_SAV,2)
                  INTO V_LABOR_TEMP_AMT, V_SUBS_SAV
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.34 청약저축공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                --투자조합출자공제 등 반영 전 과세표준
                V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_2 - V_SUBS_SAV;

                -- 주택청약종합저축 소득공제
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_SUBS_GNR_SAV,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_HOUS_SUBS_GNR_SAV,2)
                  INTO V_LABOR_TEMP_AMT, V_HOUS_SUBS_GNR_SAV
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.35 주택청약종합저축';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                --투자조합출자공제 등 반영 전 과세표준
                V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_2 - V_HOUS_SUBS_GNR_SAV;

                -- 근로자주택마련저축 소득공제
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_LABORR_HSSV,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_LABORR_HSSV,2)
                  INTO V_LABOR_TEMP_AMT, V_LABORR_HSSV
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.36 근로자투잭마련저축 소득공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                --투자조합출자공제 등 반영 전 과세표준
                V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_2 - V_LABORR_HSSV;

                /* 종합한도 대상 - 특별공제_주택자금 + 청약저축 + 주택청약종합저축 + 근로자주택마련저축 */
                V_DUC_MAX_HOUS_AMT := V_DUC_MAX_HOUS_AMT + V_SUBS_SAV + V_LABORR_HSSV + V_HOUS_SUBS_GNR_SAV;


                V_REST_INCMDED_TT_AMT := V_REST_INCMDED_TT_AMT + V_SUBS_SAV + V_LABORR_HSSV + V_HOUS_SUBS_GNR_SAV;

            END;




/** 41.투자출자조합공제 시작 **/

                --(41)투자조합출자등소득공제금액 @VER.2017_14 : 당해(THYR_) 컬럼만 사용
                --(41)투자조합출자등소득공제금액 @VER.2018_7  : 당해(THYR_), 1년전, 2년전 컬럼 사용
                -- 간접 : 조합 등, 직접 : 벤처 등
                V_YY2_BF_INDREC_INVST_AMT := REC.YY2_BF_INDREC_INVST_AMT;   --2년전간접투자금액    (2016년)
                V_YY2_BF_DIRECT_INVST_AMT := REC.YY2_BF_DIRECT_INVST_AMT;   --2년전직접투자금액    (2016년)
                V_YY1_BF_INDREC_INVST_AMT := REC.YY1_BF_INDREC_INVST_AMT;   --1년전간접투자금액    (2017년)
                V_YY1_BF_DIRECT_INVST_AMT := REC.YY1_BF_DIRECT_INVST_AMT;   --1년전직접투자금액    (2017년)
                V_THYR_INDREC_INVST_AMT   := REC.THYR_INDREC_INVST_AMT  ;   --간접투자금액         (2018년)
                V_THYR_DIRECT_INVST_AMT   := REC.THYR_DIRECT_INVST_AMT  ;   --직접투자금액         (2018년)

                /* 간접(조합 등)투자(2017년)*/
                IF V_YY2_BF_INDREC_INVST_AMT > 0 THEN
                  V_YY2_BF_INDREC_INVST_AMT := TRUNC(V_YY2_BF_INDREC_INVST_AMT * 10 / 100);    -- 출자금액의 10% 공제 : 2017년 간접 출자·투자액
                ELSE
                  V_YY2_BF_INDREC_INVST_AMT := 0;
                END IF;

                /* 간접(조합 등)투자(2018년)*/
                IF V_YY1_BF_INDREC_INVST_AMT > 0 THEN
                  V_YY1_BF_INDREC_INVST_AMT := TRUNC(V_YY1_BF_INDREC_INVST_AMT * 10 / 100);    -- 출자금액의 10% 공제 : 2018년 간접 출자·투자액
                ELSE
                  V_YY1_BF_INDREC_INVST_AMT := 0;
                END IF;

                /* 간접(조합 등)투자(2019년)*/
                IF V_THYR_INDREC_INVST_AMT > 0 THEN
                  V_THYR_INDREC_INVST_AMT := TRUNC(V_THYR_INDREC_INVST_AMT * 10 / 100);    -- 출자금액의 10% 공제 : 2019년 간접 출자·투자액
                ELSE
                  V_THYR_INDREC_INVST_AMT := 0;
                END IF;

                /* (@VER.2018_7) 7. 엔젤투자 소득공제 공제 확대 및 적용기한 연장(~'20.12.31까지)
                      : 1500만원 기존 -> 3000만원 이하 투자금액 100%
                                         3000만원 초과 5000만원 이하분 : 50% -> 70%
                                         5000만원 초과분 : 30% */
                /* 직접(벤처 등)투자(2017년) */
                IF V_YY2_BF_DIRECT_INVST_AMT > 0 THEN
                  -- 출자금액의 5천만원 초과는 30%,  1천500만원 초과는 50%, 1천 500만원 이하는 100% 공제 : 2017년~2018년 투자액
                  IF V_YY2_BF_DIRECT_INVST_AMT > 50000000 THEN
                     V_YY2_BF_DIRECT_INVST_AMT := TRUNC((V_YY2_BF_DIRECT_INVST_AMT - 50000000) * 30 /100)
                                                + 35000000 * 50 /100  + 15000000;

                  ELSIF V_YY2_BF_DIRECT_INVST_AMT > 15000000 THEN
                     V_YY2_BF_DIRECT_INVST_AMT := TRUNC((V_YY2_BF_DIRECT_INVST_AMT - 15000000) * 50 /100) + 15000000;
                  ELSE
                     V_YY2_BF_DIRECT_INVST_AMT := V_YY2_BF_DIRECT_INVST_AMT;
                  END IF;

                ELSE
                  V_YY2_BF_DIRECT_INVST_AMT := 0;
                END IF;

                /* 직접(벤처 등)투자(2018년) */
                IF V_YY1_BF_DIRECT_INVST_AMT > 0 THEN
                  -- 출자금액의 5천만원 초과는 30%,  1천500만원 초과는 50%, 1천 500만원 이하는 100% 공제 : 2015년~ 직접 출자·투자액
                  /* (@VER.2018_7)
                     출자금액의 5천만원 초과는 30%,  3천만원 초과는 70%, 3천만원 이하는 100% 공제 */
                  IF V_YY1_BF_DIRECT_INVST_AMT > 50000000 THEN
                     V_YY1_BF_DIRECT_INVST_AMT := TRUNC((V_YY1_BF_DIRECT_INVST_AMT - 50000000) * 30 /100)
                                                + 20000000 * 70 /100  + 30000000;

                  ELSIF V_YY1_BF_DIRECT_INVST_AMT > 30000000 THEN
                     V_YY1_BF_DIRECT_INVST_AMT := TRUNC((V_YY1_BF_DIRECT_INVST_AMT - 30000000) * 70 /100) + 30000000;
                  ELSE
                     V_YY1_BF_DIRECT_INVST_AMT := V_YY1_BF_DIRECT_INVST_AMT;
                  END IF;

                ELSE
                  V_YY1_BF_DIRECT_INVST_AMT := 0;
                END IF;

                /* 직접(벤처 등)투자(2019년) */
                IF V_THYR_DIRECT_INVST_AMT > 0 THEN
                  -- 출자금액의 5천만원 초과는 30%,  1천500만원 초과는 50%, 1천 500만원 이하는 100% 공제 : 2015년~ 직접 출자·투자액
                  /* (@VER.2018_7)
                     출자금액의 5천만원 초과는 30%,  3천만원 초과는 70%, 3천만원 이하는 100% 공제 */
                  IF V_THYR_DIRECT_INVST_AMT > 50000000 THEN
                     V_THYR_DIRECT_INVST_AMT := TRUNC((V_THYR_DIRECT_INVST_AMT - 50000000) * 30 /100)
                                              + 20000000 * 70 /100  + 30000000;

                  ELSIF V_THYR_DIRECT_INVST_AMT > 30000000 THEN
                     V_THYR_DIRECT_INVST_AMT := TRUNC((V_THYR_DIRECT_INVST_AMT - 30000000) * 70 /100) + 30000000;
                  ELSE
                     V_THYR_DIRECT_INVST_AMT := V_THYR_DIRECT_INVST_AMT;
                  END IF;

                ELSE
                  V_THYR_DIRECT_INVST_AMT := 0;
                END IF;

                /* 투자조합 종합한도 대상 : 2017간접 + 2018간접 + 올해(2019) 간접 (간접투자만 해당)*/
                V_INVST_FOR_DUC_MAX_AMT := V_YY2_BF_INDREC_INVST_AMT + V_YY1_BF_INDREC_INVST_AMT + V_THYR_INDREC_INVST_AMT;


                /* 투자액 */
                V_YY2_BF_INVST_AMT := V_YY2_BF_INDREC_INVST_AMT + V_YY2_BF_DIRECT_INVST_AMT;  /* 2017년 */
                V_BF_INVST_AMT := V_YY1_BF_INDREC_INVST_AMT + V_YY1_BF_DIRECT_INVST_AMT ;     /* 2018년 */
                V_THYR_INVST_AMT := V_THYR_INDREC_INVST_AMT + V_THYR_DIRECT_INVST_AMT;        /* 2019년 */

                --근로소득금액의 50% 한도에서,,2017년
                IF V_YY2_BF_INVST_AMT > V_LABOR_EARN_AMT * 50 / 100 THEN
                    V_YY2_BF_INVST_AMT := TRUNC(V_LABOR_EARN_AMT * 50 / 100);
                END IF;
                --근로소득금액의 50% 한도에서,,2018년
                IF V_BF_INVST_AMT > V_LABOR_EARN_AMT * 50 / 100 THEN
                    V_BF_INVST_AMT := TRUNC(V_LABOR_EARN_AMT * 50 / 100);
                END IF;
                --근로소득금액의 50% 한도에서,,2019년
                IF V_THYR_INVST_AMT > V_LABOR_EARN_AMT * 50 / 100 THEN
                    V_THYR_INVST_AMT := TRUNC(V_LABOR_EARN_AMT * 50 / 100);
                END IF;

                V_ICOMP_FINC_DUC_AMT := V_YY2_BF_INVST_AMT + V_BF_INVST_AMT + V_THYR_INVST_AMT;

                V_TMP_AMT := V_ICOMP_FINC_DUC_AMT - V_INVST_FOR_DUC_MAX_AMT; --종합한도 비대상액

                --총 투자금액은 근로소득금액의 50% 한도에서,,
                IF V_ICOMP_FINC_DUC_AMT > V_LABOR_EARN_AMT * 50 / 100 THEN
                    V_ICOMP_FINC_DUC_AMT := TRUNC(V_LABOR_EARN_AMT * 50 / 100);
                END IF;


                IF V_ICOMP_FINC_DUC_AMT > V_TMP_AMT THEN
                    V_INVST_FOR_DUC_MAX_AMT := V_ICOMP_FINC_DUC_AMT - V_TMP_AMT;
                ELSE
                    V_INVST_FOR_DUC_MAX_AMT := 0;
                END IF;


                --DBMS_OUTPUT.PUT_LINE('V_ICOMP_FINC_DUC_AMT = '||TO_CHAR(V_ICOMP_FINC_DUC_AMT) );

                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                IF( V_ICOMP_FINC_DUC_AMT > V_LABOR_TEMP_AMT ) THEN
                    V_ICOMP_FINC_DUC_AMT := V_LABOR_TEMP_AMT;
                END IF;
                -- 간접투자 지출분은 종합한도 대상이므로  종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT, V_ICOMP_FINC_DUC_AMT   ,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT, V_ICOMP_FINC_DUC_AMT   ,2)
                  INTO V_LABOR_TEMP_AMT, V_ICOMP_FINC_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.37 간접투자 지출분';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                V_REST_INCMDED_TT_AMT := V_REST_INCMDED_TT_AMT + V_ICOMP_FINC_DUC_AMT;

                V_TMP_AMT := 0;
               --DBMS_OUTPUT.PUT_LINE('V_ICOMP_FINC_DUC_AMT = '||TO_CHAR(V_ICOMP_FINC_DUC_AMT) );
/** 투자출자조합 공제 끝 **/


--42.신용카드등소득공제

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'121',REC.RPST_PERS_NO,null)-- 신용카드등 (전통시장,대중교통 제외비용)
                  INTO V_CREDIT_USE_AMT
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'123',REC.RPST_PERS_NO,NULL)-- 현금영수증(전통시장,대중교통 제외)
                  INTO V_CSH_RECPT_USE_AMT
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'124',REC.RPST_PERS_NO,null)-- 신용카드등 (사업관련비용 )
                  INTO V_BUSINESS_USE_AMT
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'125',REC.RPST_PERS_NO,null)-- 직불카드 (전통시장,대중교통 제외)
                  INTO V_DEBIT_USE_AMT
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'128',REC.RPST_PERS_NO,null)-- 전통시장 사용액
                  INTO V_CREDIT_TRADIMARKE_USE_AMT
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'129',REC.RPST_PERS_NO,null)-- 대중교통 사용액
                  INTO V_CREDIT_PUBLIC_TRAF_AMT
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'12H',REC.RPST_PERS_NO,null)-- 도서.공연비 사용액(@VER.2018_9)
                  INTO V_CREDIT_BOOK_PFMC_AMT
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'12H1',REC.RPST_PERS_NO,null)-- 도서.공연비(신용카드) 사용액(@VER.2018_9_1)
                  INTO V_CREDIT_BOOK_PFMC_AMT1
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'12H2',REC.RPST_PERS_NO,null)-- 도서.공연비(체크카드) 사용액(@VER.2018_9_1)
                  INTO V_CREDIT_BOOK_PFMC_AMT2
                  FROM DUAL;

                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'12H3',REC.RPST_PERS_NO,null)-- 도서.공연비(현금영수증) 사용액(@VER.2018_9_1)
                  INTO V_CREDIT_BOOK_PFMC_AMT3
                  FROM DUAL;

                /* (@VER.2018_9) - 총급여 7천만원 이하자에 한해 도서.공연비 공제 : 총급여 7천만원 초과자 */
                IF V_LABOR_EARN_TT_SALY_AMT > 70000000 THEN
                    V_CREDIT_BOOK_PFMC_AMT := 0;
                    /* (@VER.2018_9_1) - 총급여 7천만원 초과자에 한해 도서.공연비(신용카드, 체크카드, 현금영수증)공제금 각 항목으로 추가 */
                    V_CREDIT_USE_AMT    := V_CREDIT_USE_AMT + V_CREDIT_BOOK_PFMC_AMT1;    -- 신용카드 + 도서.공연비(신용카드)
                    V_DEBIT_USE_AMT     := V_DEBIT_USE_AMT + V_CREDIT_BOOK_PFMC_AMT2;     -- 직불카드 + 도서.공연비(체크카드)
                    V_CSH_RECPT_USE_AMT := V_CSH_RECPT_USE_AMT + V_CREDIT_BOOK_PFMC_AMT3; -- 현금영수증 + 도서.공연비(현금영수증)
                END IF;

                --> 2013년 신용카드15%, 나머지는 30%로 변경됨.
                --V_CREDIT_TOT_USE_AMT := V_CREDIT_USE_AMT + V_ACMY_GIRO_PAID_AMT + V_CSH_RECPT_USE_AMT - V_BUSINESS_USE_AMT ;
                V_CREDIT_TOT_USE_AMT := V_CREDIT_USE_AMT - V_BUSINESS_USE_AMT ;   --신용카드 사용액= 사용액 - 사업관련비용
                IF V_CREDIT_TOT_USE_AMT < 0 THEN
                    V_CREDIT_TOT_USE_AMT := 0;
                END IF;

                --신용카드최저사용금액 계산(총급여액 * 25%)
                V_CREDIT_MINI_USE_AMT := TRUNC( V_LABOR_EARN_TT_SALY_AMT * 25 / 100 );

                --전체합산금액이 총급여의 25%  이상일 경우 신용카드공제금액 계산
                --직불카드공제금액(V_DEBIT_USE_AMT) 별도로 계산하지 않고 V_CREDIT_DUC_AMT 만 계산함
                --도서.공연비 사용액(총급여 7천만원 이하자) : V_CREDIT_BOOK_PFMC_AMT 추가(@VER.2018_9)
                IF V_CREDIT_TOT_USE_AMT + V_DEBIT_USE_AMT + V_CSH_RECPT_USE_AMT + V_CREDIT_TRADIMARKE_USE_AMT + V_CREDIT_PUBLIC_TRAF_AMT + V_CREDIT_BOOK_PFMC_AMT - V_CREDIT_MINI_USE_AMT > 0 THEN

                  --신용카드공제 제외금액 산출 방법 @VER.2017
                  IF V_CREDIT_MINI_USE_AMT <= V_CREDIT_TOT_USE_AMT THEN
                    /*최저사용금액 <= 신용카드사용분(전통시장,대중교통비제외) : 최저사용금액 * 15% */
                    V_CREDIT_DUC_EXC_AMT := TRUNC( V_CREDIT_MINI_USE_AMT * 15 / 100 );

                  ELSIF V_CREDIT_TOT_USE_AMT < V_CREDIT_MINI_USE_AMT AND V_CREDIT_MINI_USE_AMT <= V_CREDIT_TOT_USE_AMT + V_DEBIT_USE_AMT + V_CSH_RECPT_USE_AMT + V_CREDIT_BOOK_PFMC_AMT THEN
                    /* 신용카드사용분(전통시장,대중교통비제외) < 최저사용금액 <= 신용카드+직불카드+현금영수증+도서.공연비 사용액
                       :신용카드사용분*15% + {최저사용금액 - 신용카드사용분}*30%   */
                     V_CREDIT_DUC_EXC_AMT :=  TRUNC(V_CREDIT_TOT_USE_AMT * 15 / 100 )
                                            + TRUNC((V_CREDIT_MINI_USE_AMT - V_CREDIT_TOT_USE_AMT) * 30 / 100);

                  ELSIF V_CREDIT_MINI_USE_AMT > V_CREDIT_TOT_USE_AMT + V_DEBIT_USE_AMT + V_CSH_RECPT_USE_AMT + V_CREDIT_BOOK_PFMC_AMT THEN
                    /* 최저사용금액 > 신용카드+직불카드+현금영수증 사용액  : 신용카드*15% + (직불카드+현금영수증+도서.공연비)*30% + {최저사용금액-(신용카드+직불카드+현금영수증+도서공연비)}* 40% */
                     V_CREDIT_DUC_EXC_AMT :=  TRUNC( V_CREDIT_TOT_USE_AMT * 15 / 100 )
                                            + TRUNC((V_DEBIT_USE_AMT + V_CSH_RECPT_USE_AMT+ V_CREDIT_BOOK_PFMC_AMT) * 30 / 100)
                                            + TRUNC((V_CREDIT_MINI_USE_AMT - (V_CREDIT_TOT_USE_AMT+V_DEBIT_USE_AMT+V_CSH_RECPT_USE_AMT+V_CREDIT_BOOK_PFMC_AMT)) * 40 / 100);

                  END IF;


                  -- 전년도 신용카드 등 사용액이, 전전년도 신용카드 등 사용액보다 크면,
                  -- @VER.2017 2017년부터 해당없음.
                  /*IF SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'12C',REC.RPST_PERS_NO, '1') >
                     SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'12G',REC.RPST_PERS_NO, '1') THEN
                     --@VER.2016_5 (10% => 20% 공제비율 증가) (16년 상반기 체크 등 사용액 - 14년 사용분의 50%보다 증가한 금액)* 20% 를 추가 소득공제
                     V_CREDIT_DUC_ADD_AMT3 := GREATEST(TRUNC((V_FHALF_RECPT_DEBIT_ALL_AMT - (V_BF_PRVYY_RECPT_DEBIT_ALL_AMT * 50 / 100)) * 20 / 100), 0);

                  END IF;*/

                  /* VER.2016_5 2016년에는 해당사항 없음 [주석처리]*/
                  /*
                  -- 당년도 신용카드 등 사용액이, 전년도 신용카드 등 사용액보다 크면,
                  IF SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'12D',REC.RPST_PERS_NO, '1') >
                     SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'12C',REC.RPST_PERS_NO, '1') THEN
                     -- (15년 하반기 체크 등 사용액 - 14년 사용분의 50%보다 증가한 금액)* 20% 를 추가 소득공제
                     V_CREDIT_DUC_ADD_AMT4 := GREATEST(TRUNC((V_SHALF_RECPT_DEBIT_ALL_AMT - (V_BF_RECPT_DEBIT_ALL_AMT * 50 / 100)) * 20 / 100), 0);

                  END IF;
                  */

                  --신용카드공제가능금액 계산 = 신용카드 *15 + (현금+직불)*30% (전통시장+대중교통)*40% - 공제제외금액
                  /* 도서.공연비 사용액(총급여 7천만원 이하자) : V_CREDIT_BOOK_PFMC_AMT > 0 이면 (@VER.2018_9) */
                  IF V_CREDIT_BOOK_PFMC_AMT > 0 THEN
                      V_CREDIT_DUC_POSS_AMT :=   TRUNC( V_CREDIT_TOT_USE_AMT * 15 / 100 )  --2013년 20% -> 15% 로 변경
                                               + TRUNC( V_CSH_RECPT_USE_AMT * 30 / 100 )
                                               + TRUNC( V_DEBIT_USE_AMT * 30 / 100 )
                                               + TRUNC( V_CREDIT_BOOK_PFMC_AMT * 30 / 100 ) -- 도서.공연비(총급여 7천만원 이하자) 30% (@VER.2018_9)
                                               + TRUNC( V_CREDIT_TRADIMARKE_USE_AMT * 40 / 100 ) /* @VER.2017_11 전통시장사용분 30%=>40% 상향 */
                                               + TRUNC( V_CREDIT_PUBLIC_TRAF_AMT * 40 / 100 )    /* @VER.2017_11 대중교통사용분 30%=>40% 상향  */
                                               - V_CREDIT_DUC_EXC_AMT
                                               ;
                  ELSE
                      V_CREDIT_DUC_POSS_AMT :=   TRUNC( V_CREDIT_TOT_USE_AMT * 15 / 100 )  --2013년 20% -> 15% 로 변경
                                               + TRUNC( V_CSH_RECPT_USE_AMT * 30 / 100 )
                                               + TRUNC( V_DEBIT_USE_AMT * 30 / 100 )
                                               + TRUNC( V_CREDIT_TRADIMARKE_USE_AMT * 40 / 100 ) /* @VER.2017_11 전통시장사용분 30%=>40% 상향 */
                                               + TRUNC( V_CREDIT_PUBLIC_TRAF_AMT * 40 / 100 )    /* @VER.2017_11 대중교통사용분 30%=>40% 상향  */
                                               - V_CREDIT_DUC_EXC_AMT
                                               ;
                  END IF;

                  /* @VER.2017_10 신용카드등 소득공제 공제한도 소득별 차등적용
                     총급여액 7천만원이하  : Min(총급여액20%, 300만원)
                              7천~1.2억원  : 300만원(18.1.1 이후 250만원=>2018년 연말정산에 적용사항)
                              1.2억원 초과 : 200만원
                  */
                  IF V_LABOR_EARN_TT_SALY_AMT <= 70000000 THEN
                     V_LMT_CREDIT_DUC_AMT := LEAST(TRUNC(V_LABOR_EARN_TT_SALY_AMT * 20 / 100 ), 3000000);
                  ELSIF V_LABOR_EARN_TT_SALY_AMT > 70000000 AND V_LABOR_EARN_TT_SALY_AMT <= 120000000 THEN
                      V_LMT_CREDIT_DUC_AMT := 2500000;
                  ELSE
                      V_LMT_CREDIT_DUC_AMT := 2000000;
                  END IF;

                  IF V_CREDIT_DUC_POSS_AMT > V_LMT_CREDIT_DUC_AMT THEN
                     V_CREDIT_DUC_AMT := V_LMT_CREDIT_DUC_AMT;
                     V_CREDIT_DUC_OVER_AMT := V_CREDIT_DUC_POSS_AMT - V_CREDIT_DUC_AMT;
                  ELSE
                     V_CREDIT_DUC_AMT := V_CREDIT_DUC_POSS_AMT;
                     V_CREDIT_DUC_OVER_AMT := 0;
                  END IF;

                  /* 2016년 이전 로직 */
                  /*IF TRUNC(V_LABOR_EARN_TT_SALY_AMT * 20 / 100 ) > 3000000 THEN
                      IF V_CREDIT_DUC_POSS_AMT  > 3000000 THEN    -- 300만원 한도..
                        V_CREDIT_DUC_AMT := 3000000;
                        V_CREDIT_DUC_OVER_AMT := V_CREDIT_DUC_POSS_AMT - V_CREDIT_DUC_AMT;
                      ELSE
                        V_CREDIT_DUC_AMT := V_CREDIT_DUC_POSS_AMT;
                        V_CREDIT_DUC_OVER_AMT := 0;
                      END IF;
                  ELSE
                      IF V_CREDIT_DUC_POSS_AMT > TRUNC(V_LABOR_EARN_TT_SALY_AMT * 20 / 100) THEN
                        V_CREDIT_DUC_AMT := TRUNC(V_LABOR_EARN_TT_SALY_AMT * 20 / 100);
                        V_CREDIT_DUC_OVER_AMT := V_CREDIT_DUC_POSS_AMT - V_CREDIT_DUC_AMT;
                      ELSE
                        V_CREDIT_DUC_AMT := V_CREDIT_DUC_POSS_AMT;
                        V_CREDIT_DUC_OVER_AMT := 0;
                      END IF;
                  END IF;*/


                  /* 신용카드추가공제금액 - 도서.공연공제액(총급여액 7천만원 이하) 계산(@VER.2018_9) */
                  IF V_LABOR_EARN_TT_SALY_AMT <= 70000000 THEN
                      --도서.공연비 추가공제공제 : min {(공제가능금액-공제한도), 도서.공연사용분*30%, 100만원}
                      V_CREDIT_DUC_ADD_AMT5 := LEAST( GREATEST((V_CREDIT_DUC_POSS_AMT - V_LMT_CREDIT_DUC_AMT),0),
                                                     TRUNC( V_CREDIT_BOOK_PFMC_AMT * 30 / 100 ),
                                                     1000000); --셋중에 가장 작은 값을 사용함.

                      --전통시장 추가공제공제 :  min( (공제가능금액-공제한도-도서.공연비 추가공제액), 전통시장사용분*40%, 100만원 )
                      V_CREDIT_DUC_ADD_AMT1 := LEAST( GREATEST((V_CREDIT_DUC_POSS_AMT - V_LMT_CREDIT_DUC_AMT - V_CREDIT_DUC_ADD_AMT5),0),
                                                     TRUNC( V_CREDIT_TRADIMARKE_USE_AMT * 40 / 100 ),
                                                     1000000); --셋중에 가장 작은 값을 사용함.

                      --대중교통 추가공제공제 : min {(공제가능금액-공제한도-도서.공연비 추가공제액-전통시장 추가공제금액), 대중교통사용분*40%, 100만원}
                      V_CREDIT_DUC_ADD_AMT2 := LEAST( GREATEST((V_CREDIT_DUC_POSS_AMT - V_LMT_CREDIT_DUC_AMT - V_CREDIT_DUC_ADD_AMT5 - V_CREDIT_DUC_ADD_AMT1),0),
                                                     TRUNC( V_CREDIT_PUBLIC_TRAF_AMT * 40 / 100 ),
                                                     1000000); --셋중에 가장 작은 값을 사용함.

                      V_CREDIT_DUC_ADD_AMT := V_CREDIT_DUC_ADD_AMT5 + V_CREDIT_DUC_ADD_AMT1 + V_CREDIT_DUC_ADD_AMT2;

                  ELSE
                      --신용카드추가공제금액 계산 @VER.2017_11
                      --전통시장 추가공제공제 :  min( (공제가능금액 - 공제한도), 전통시장사용분*40%, 100만원 )
                      V_CREDIT_DUC_ADD_AMT1 := LEAST( GREATEST((V_CREDIT_DUC_POSS_AMT - V_LMT_CREDIT_DUC_AMT),0),
                                                     TRUNC( V_CREDIT_TRADIMARKE_USE_AMT * 40 / 100 ),
                                                     1000000); --셋중에 가장 작은 값을 사용함.
                      --DBMS_OUTPUT.PUT_LINE('V_CREDIT_DUC_POSS_AMT = '||TO_CHAR(V_CREDIT_DUC_POSS_AMT) );
                      --DBMS_OUTPUT.PUT_LINE('GREATEST(V_CREDIT_DUC_POSS_AMT - V_CREDIT_DUC_OVER_AMT,0) = '||TO_CHAR(GREATEST(V_CREDIT_DUC_POSS_AMT - V_CREDIT_DUC_OVER_AMT,0)) );
                      --DBMS_OUTPUT.PUT_LINE('TRUNC( V_CREDIT_TRADIMARKE_USE_AMT * 30 / 100 ) = '||TO_CHAR(TRUNC( V_CREDIT_TRADIMARKE_USE_AMT * 30 / 100 )) );
                      --DBMS_OUTPUT.PUT_LINE('V_CREDIT_DUC_ADD_AMT1 = '||TO_CHAR(V_CREDIT_DUC_ADD_AMT1) );
                      --대중교통 추가공제공제 : min {(공제가능금액-공제한도-전통시장 추가공제금액), 대중교통사용분*40%, 100만원}
                      V_CREDIT_DUC_ADD_AMT2 := LEAST( GREATEST((V_CREDIT_DUC_POSS_AMT - V_LMT_CREDIT_DUC_AMT - V_CREDIT_DUC_ADD_AMT1),0),
                                                     TRUNC( V_CREDIT_PUBLIC_TRAF_AMT * 40 / 100 ),
                                                     1000000); --셋중에 가장 작은 값을 사용함.
                      --DBMS_OUTPUT.PUT_LINE('V_CREDIT_DUC_POSS_AMT = '||TO_CHAR(V_CREDIT_DUC_POSS_AMT) );
                      --DBMS_OUTPUT.PUT_LINE('GREATEST(V_CREDIT_DUC_OVER_AMT,0) = '||TO_CHAR(GREATEST(V_CREDIT_DUC_OVER_AMT,0)) );
                      --DBMS_OUTPUT.PUT_LINE('V_CREDIT_DUC_ADD_AMT1 = '||TO_CHAR(V_CREDIT_DUC_ADD_AMT1) );
                      --DBMS_OUTPUT.PUT_LINE('TRUNC( V_CREDIT_PUBLIC_TRAF_AMT * 30 / 100 ) = '||TO_CHAR(TRUNC( V_CREDIT_PUBLIC_TRAF_AMT * 30 / 100 )) );
                      --DBMS_OUTPUT.PUT_LINE('V_CREDIT_DUC_ADD_AMT2 = '||TO_CHAR(V_CREDIT_DUC_ADD_AMT2) );

                      V_CREDIT_DUC_ADD_AMT := V_CREDIT_DUC_ADD_AMT1 + V_CREDIT_DUC_ADD_AMT2;
                  END IF;



                  --신용카드 최종공제금액 = 일반공제금액 + 추가공제금액
                  V_CREDIT_DUC_AMT := V_CREDIT_DUC_AMT + V_CREDIT_DUC_ADD_AMT;

                ELSE
                  V_CREDIT_DUC_AMT := 0;
                END IF;

                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                IF( V_CREDIT_DUC_AMT > V_LABOR_TEMP_AMT ) THEN
                    V_CREDIT_DUC_AMT := V_LABOR_TEMP_AMT;
                END IF;

                --신용카드도 종합한도 적용대상이므로 -- 주택관련 모든 공제는 종합한도 적용대상임.... 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                V_DUC_MAX_CREDIT_AMT := V_CREDIT_DUC_AMT;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CREDIT_DUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_CREDIT_DUC_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_CREDIT_DUC_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.38 신용카드 공제';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/

                V_REST_INCMDED_TT_AMT := V_REST_INCMDED_TT_AMT + V_CREDIT_DUC_AMT;

                --투자조합출자공제 등 반영 전 과세표준
                V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_2 - V_CREDIT_DUC_AMT;
/* --- 투자조합출자공제 등 반영전 과세표준에 1. 우리사주조합출연금 2. 우리사주 조합기부금 3 고용유지중소기업근로자 공제금을
여기에서 빼야함 --- */
                /* 우리사주조합 출연금금 */
                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                V_OSC_CNTRIB_AMT := V_CNTRIB_DUC_SUM_AMT42;
                IF( V_OSC_CNTRIB_AMT > V_LABOR_TEMP_AMT ) THEN
                        V_OSC_CNTRIB_AMT := V_LABOR_TEMP_AMT;
                    END IF;

                -- 종합한도 적용대상이므로 종합한도를 적용하여 초과시 과세표준에서 차감한다.
                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_OSC_CNTRIB_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_OSC_CNTRIB_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_OSC_CNTRIB_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.39 우리사주기부금';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                --그 밖의 소득공제액에 포함
                V_REST_INCMDED_TT_AMT  := V_REST_INCMDED_TT_AMT + V_OSC_CNTRIB_AMT;

                -- 장기집합투자증권저축 : 납입액 40% 공제, 240만원 한도.
                V_INVST_SEC_SAV_AMT := NVL(REC.INVST_SEC_SAV_AMT,0);
                IF ( V_INVST_SEC_SAV_AMT > 0 AND V_LABOR_EARN_TT_SALY_AMT <= 80000000) THEN /*@VER.2017_15 장기집합투자증권저축 공제: 총급여액 8천만원 이하자만  적용*/
                    V_INVST_SEC_SAV_AMT := LEAST( TRUNC(V_INVST_SEC_SAV_AMT * 40 / 100), 2400000) ; --40%와 300만원중 적은 금액으로 처리
                ELSE
                    V_INVST_SEC_SAV_AMT := 0;
                END IF;

                --  차감소득액보다 클수는 없으므로 공제액을 줄인다. 2013 추가.
                IF( V_INVST_SEC_SAV_AMT > V_LABOR_TEMP_AMT ) THEN
                    V_INVST_SEC_SAV_AMT := V_LABOR_TEMP_AMT;
                END IF;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT, V_INVST_SEC_SAV_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT, V_INVST_SEC_SAV_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_INVST_SEC_SAV_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.41 장기집합투자증권저축';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                V_REST_INCMDED_TT_AMT := V_REST_INCMDED_TT_AMT + V_INVST_SEC_SAV_AMT;




                /* 2015 연말정산 개선 - 20151217 연금보험료 공제 순서 변경*/
                /* 연금보험료공제 시작 */
                -- 종(전)근무지 국민연금 합산
                /*V_NPN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'146',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'146',REC.RPST_PERS_NO,null)
                  INTO V_NPN_INSU_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_NPN_INSU_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_NPN_INSU_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_NPN_INSU_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.42 [연금보험] 종(전) 근무지 국민연금 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );
*/
                -- 현근무지 국민연금 합산
                /*V_ADD_NPN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'101',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'101',REC.RPST_PERS_NO,null)
                  INTO V_ADD_NPN_INSU_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_NPN_INSU_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_NPN_INSU_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_ADD_NPN_INSU_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.43 [연금보험] 현근무지 국민연금 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- 종(전)근무지 공무원연금  합산
                /*V_PUBPERS_PENS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'139',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'139',REC.RPST_PERS_NO,null)
                  INTO V_PUBPERS_PENS_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PUBPERS_PENS_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PUBPERS_PENS_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_PUBPERS_PENS_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.44 [연금보험] 종(전)근무지 공무원연금 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- 현근무지 공무원연금 합산
                /*V_ADD_PUBPERS_PENS_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'103',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'103',REC.RPST_PERS_NO,null)
                  INTO V_ADD_PUBPERS_PENS_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PUBPERS_PENS_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PUBPERS_PENS_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_ADD_PUBPERS_PENS_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.45 [연금보험] 현근무지 공무원연금 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );   */

                -- 종(전)근무지 사학연금 합산
                /*V_PSCH_PESN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'145',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'145',REC.RPST_PERS_NO,null)
                  INTO V_PSCH_PESN_INSU_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PSCH_PESN_INSU_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_PSCH_PESN_INSU_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_PSCH_PESN_INSU_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.46 [연금보험] 종(전)근무지 사학연금 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- 현근무지 사학연금 합산
                /*V_ADD_PSCH_PESN_INSU_AMT := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'102',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'102',REC.RPST_PERS_NO,null)
                  INTO V_ADD_PSCH_PESN_INSU_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PSCH_PESN_INSU_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_ADD_PSCH_PESN_INSU_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_ADD_PSCH_PESN_INSU_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.47 [연금보험] 현근무지 사학연금 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- 종(전)근무지 군인연금 합산
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'190',REC.RPST_PERS_NO,null)
                  INTO V_MILITARY_PENS_INSU_AMT
                  FROM DUAL;

                SELECT SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_MILITARY_PENS_INSU_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_LABOR_TEMP_AMT,V_MILITARY_PENS_INSU_AMT,2)
                  INTO V_LABOR_TEMP_AMT, V_MILITARY_PENS_INSU_AMT
                  FROM DUAL;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.48 [연금보험] 종(전)근무지 군인연금 합산';
V_DB_ERROR_CTNT := 'V_LABOR_TEMP_AMT  차감소득금액:'||V_LABOR_TEMP_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                 -- 연금보험료 공제가 소득공제 제일 마지막에 진행 되므로, 차감소득금액(37)에 합산해서 보여줌.  - 20160106
                V_SBTR_EARN_AMT := NVL(V_SBTR_EARN_AMT,0) -  (NVL(V_NPN_INSU_AMT, 0) + NVL(V_ADD_NPN_INSU_AMT, 0) + NVL(V_PUBPERS_PENS_AMT, 0)
                                 + NVL(V_ADD_PUBPERS_PENS_AMT, 0) + NVL(V_PSCH_PESN_INSU_AMT, 0) + NVL(V_ADD_PSCH_PESN_INSU_AMT, 0) + NVL(V_MILITARY_PENS_INSU_AMT, 0));

                /* 연금보험료공제 끝 */




                -- 소득공제 종합한도 초과액 계산 : 2013년 신설.2500만원.
                -- 보장성보험 + 의료비(장애인제외)+교육비(장애인제외)+주택자금+소기업소상공인공제+신용카드+투자조합출자+우리사주출연금
                -- 초과금액은 제외. 초과금액이 있고 기부금이 존재하는경우 공제우선순서 낮은것부터 초과금액만큼 이월처리 해줌.
                -- 초과금액 표시, 이월처리금액 제외하지말고 표시.
                -- 긴급!!! : 2014.1.3. 세법개정안에 종합한도는 지정기부금을 제외하므로 이월처리도 필요없음.

                V_DUC_MAX_AMT :=  V_DUC_MAX_HOUS_AMT         --4. 주택자금공제액
                                  +V_DUC_MAX_CO_AMT         --6. 소기업/소상공인 공제부금 공제액
                                  +V_DUC_MAX_CREDIT_AMT         --7. 신용카드사용공제액
                                  +V_INVST_FOR_DUC_MAX_AMT       --8. 투자조합출자 소득공제액(2013년분)
                                  +V_DUC_MAX_OSC_AMT           --9. 우리사주출연금공제액 : 주식회사가 아니므로 실제적 사용안함.
                                  +V_INVST_SEC_SAV_AMT ;       -- 장기집합투자증권저축액



                IF( V_DUC_MAX_AMT > 25000000 ) THEN
                    V_DUC_MAX_OVER_AMT := V_DUC_MAX_AMT - 25000000;
                    V_DUC_MAX_AMT := 25000000;
                ELSIF( V_DUC_MAX_AMT < 0 ) THEN
                    V_DUC_MAX_OVER_AMT := 0;
                    V_DUC_MAX_AMT := 0;
                ELSE
                    V_DUC_MAX_OVER_AMT := 0;
                END IF;


                --종합한도 초과액만큼 과세표준 금액을 올려서 계산
                V_LABOR_TEMP_AMT := V_LABOR_TEMP_AMT + V_DUC_MAX_OVER_AMT;

                V_GNR_EARN_TAX_STAD_AMT_3 := V_LABOR_TEMP_AMT; --모든 공제 후  과세표준

             /* V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_2 +
                                             GREATEST((V_DUC_MAX_OVER_AMT - V_ICOMP_FINC_DUC_AMT - V_INVST_SEC_SAV_AMT),0);*/
             /*@VER.2015 2016.01.28 공제전 과세표준은 최종과세표준액에서 투자조합출자,목돈안드는전세이자상환액,장기집합투자증권저축의 소득공제만큼 더해주면 된다.*/
             /*@VER.2015 2016.01.28 농어촌특별세개정(15.12.15)에따라장기집합투자증권저축의경우, 농어촌특별세를부과하지아니함. */
             -- V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_3 + V_ICOMP_FINC_DUC_AMT + V_LFSTS_ITT_RFND_AMT + V_INVST_SEC_SAV_AMT ;
                V_GNR_EARN_TAX_STAD_AMT_2 := V_GNR_EARN_TAX_STAD_AMT_3 + V_ICOMP_FINC_DUC_AMT + V_LFSTS_ITT_RFND_AMT; --공제전 과세표준



/* 종합소득 과세표준금액 */
                V_GNR_EARN_TAX_STAD_AMT := V_LABOR_TEMP_AMT;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '종합소득 과세표준 체크. STEP.FINAL';
V_DB_ERROR_CTNT := 'V_GNR_EARN_TAX_STAD_AMT  과세표준:'||V_GNR_EARN_TAX_STAD_AMT||chr(13)||chr(10)||
                   'V_GNR_EARN_TAX_STAD_AMT_2 공제전(2) 과세표준:'||V_GNR_EARN_TAX_STAD_AMT_2||chr(13)||chr(10)||
                   'V_GNR_EARN_TAX_STAD_AMT_3 공제후(3) 과세표준:'||V_GNR_EARN_TAX_STAD_AMT_3||chr(13)||chr(10)||
                   'V_DUC_MAX_OVER_AMT 종합한도 초과액:'||V_DUC_MAX_OVER_AMT||chr(13)||chr(10)||
                   'V_ICOMP_FINC_DUC_AMT 투자조합출자:'||V_ICOMP_FINC_DUC_AMT||chr(13)||chr(10)||
                   'V_INVST_SEC_SAV_AMT 장기집합투자:'||V_INVST_SEC_SAV_AMT||chr(13)||chr(10)||
                   'V_LFSTS_ITT_RFND_AMT 목돈안드는:'||V_LFSTS_ITT_RFND_AMT||chr(13)||chr(10)
;
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );*/




                IF V_GNR_EARN_TAX_STAD_AMT < 0 THEN   -- 마이너스 금액은 0 으로 처리..
                    V_GNR_EARN_TAX_STAD_AMT := 0;
                END IF;
/* 산출세액 */
                BEGIN
                    SELECT NVL(BASI_AMT_1,0), NVL(BASI_AMT_2,0), NVL(TRATE,0)
                      INTO V_BASI_AMT_1,      V_BASI_AMT_2 ,     V_TRATE
                      FROM PAYM450
                     WHERE CAL_FG   =  'A034500002'
                       AND YY       =  IN_YY
                       AND V_GNR_EARN_TAX_STAD_AMT > ADPT_LOW_AMT
                       AND V_GNR_EARN_TAX_STAD_AMT <= ADPT_UPP_AMT;
                    EXCEPTION
                    WHEN NO_DATA_FOUND  THEN
                        V_BASI_AMT_1 := 0;
                        V_BASI_AMT_2 := 0;
                        V_TRATE := 0;
                END;


                IF NVL(V_GNR_EARN_TAX_STAD_AMT,0) > 0 THEN
                    V_CAL_TDUC := TRUNC(NVL(V_BASI_AMT_1,0) + (NVL(V_GNR_EARN_TAX_STAD_AMT,0) - NVL(V_BASI_AMT_2,0)) * NVL(V_TRATE,0) * 0.01);
                ELSE
                    V_CAL_TDUC  :=   0 ;
                END IF;

                V_CAL_TDUC_TEMP_AMT := V_CAL_TDUC;



/** 세액 감면 **/
                --118. [세액감면]-조특법30조 -중소기업취업 청년,60세이상,장애인 및 국가유공자 : 현근무지는 해당없으나 전근무지 때문에 자료가 있음.

                IF( V_BF_SITE_STXLW_TAX > 0 ) THEN
                    --2014.2.10. 전근무지의 조특법30조 감면세액
                    --@VER.2016_6 감면율 추가가 됬지만, 서울대학교에서 처리는 이전 근무지에서 받은 감면세액(감면율 이미 적용된 금액)을 받고 있으므로 로직 수정은 없다.
                    --            취업일기준 (2012~2013 : 100% [한도x], 2014~2015 : 50% [한도x], 2016~2018  : 70% [한도,150만원])
                    -- 감면세액 = 종합소득산출세액 * (근로소득금액/종합소득금액)*(중소기업총급여/총급여)*감면율(100%,50%,70%)
                    --         = 종합소득산출세액 * (1)                    *(중소기업감면액/총급여)
                    IF V_LABOR_EARN_TT_SALY_AMT > 0 THEN
                        V_BF_SITE_STXLW_TAX := TRUNC(V_CAL_TDUC_TEMP_AMT * 1.0 *  (V_BF_SITE_STXLW_TAX) / V_LABOR_EARN_TT_SALY_AMT);
                    ELSE
                        V_BF_SITE_STXLW_TAX := 0;
                    END IF;

                   -- DBMS_OUTPUT.PUT_LINE('V_BF_SITE_STXLW_TAX = '||TO_CHAR(V_BF_SITE_STXLW_TAX) );

                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_BF_SITE_STXLW_TAX,1),
                         SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_BF_SITE_STXLW_TAX,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_BF_SITE_STXLW_TAX
                    FROM DUAL;
                END IF;

                 --118-1. [세액감면]-조특법30조외 - 중소기업 핵심인력 성과보상기금 및 성과공유 중소기업 경영성과급에 대한 소득세 감면 : 현근무지는 해당없으나 전근무지 때문에 자료가 있음.
                 --                              중소기업 핵심인력 성과보상기금은 분리 로직 필요시, 내년에 별도 개발 필요(@VER.2019_6)

                -- 중소기업취업자 소득세 감면 적용받는 경우
                IF( V_BF_SITE_STXLW_TAX > 0 ) THEN
                     -- 감면세액 = [(산출세액 * 1) - 중소기업취업자 소득세감면세액 ] * 성과공유중소기업으로부터 받은 경영성과급(SMBIZ_BONUS_AMT) / 해당근로자의 총급여액 * 0.5
                    IF V_LABOR_EARN_TT_SALY_AMT > 0 THEN
                        V_BF_SITE_SMBIZ_BONUS_TAX := TRUNC((V_CAL_TDUC_TEMP_AMT * 1.0 - V_BF_SITE_STXLW_TAX ) * V_BF_SITE_SMBIZ_BONUS_TAX / V_LABOR_EARN_TT_SALY_AMT * 0.5);
                    ELSE
                        V_BF_SITE_SMBIZ_BONUS_TAX := 0;
                    END IF;

                ELSE -- 중소기업취업자 소득세 감면 적용받지 않는 경우
                    -- 감면세액 = 산출세액 * 1 * 성과공유중소기업으로부터 받은 경영성과급(SMBIZ_BONUS_AMT) / 해당근로자의 총급여액 * 0.5
                    IF V_LABOR_EARN_TT_SALY_AMT > 0 THEN
                        V_BF_SITE_SMBIZ_BONUS_TAX := TRUNC(V_CAL_TDUC_TEMP_AMT * 1.0 *  (V_BF_SITE_SMBIZ_BONUS_TAX) / V_LABOR_EARN_TT_SALY_AMT * 0.5) ;
                    ELSE
                        V_BF_SITE_SMBIZ_BONUS_TAX := 0;
                    END IF;

                END IF;

                SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_BF_SITE_SMBIZ_BONUS_TAX,1),
                     SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_BF_SITE_SMBIZ_BONUS_TAX,2)
                INTO V_CAL_TDUC_TEMP_AMT, V_BF_SITE_SMBIZ_BONUS_TAX
                FROM DUAL;

                --119. [세액감면]-조세조약
                V_RTXLW_AMT1 :=0;
                V_RTXLW_AMT2 :=0;
                V_RTXLW_AMT3 :=0; /*@VER.2016_14 종전근무지 조세조약감면액 적용*/

                /* STEP1. 현근무지 조세조약 감면액 계산*/
                IF REC.REDC_FR_DT IS NOT NULL THEN

                    BEGIN --감면기간내 과세소득 계산 : 현근무지의 감면세액은 무조건 조세조약으로 밖에 처리못함.
                        SELECT NVL(SUM(TT_AMT),0)
                          INTO V_RTXLW_AMT1
                          FROM PAYM440
                         WHERE YY           =  IN_YY
                           AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                           AND SETT_FG      = V_SETT_FG
                           AND RPST_PERS_NO = REC.RPST_PERS_NO
                           AND YYMM >= SUBSTR(REC.REDC_FR_DT,1,6)  --감면시작일자
                           AND YYMM <= SUBSTR(REC.REDC_TO_DT,1,6); --감면종료일자

                        EXCEPTION
                        WHEN NO_DATA_FOUND  THEN
                            V_RTXLW_AMT1 := 0;
                    END;

                    BEGIN --감면기간내 추가 소득액( 과세소득 계산)
                        SELECT NVL(SUM(SALY_AMT),0) + NVL(SUM(BONUS_AMT),0) + NVL(SUM(DETM_BONUS),0) + NVL(SUM(ETC_AMT),0)
                          INTO V_RTXLW_AMT2
                          FROM PAYM441
                         WHERE YY           =  IN_YY
                           AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                           AND SETT_FG      = V_SETT_FG
                           AND RPST_PERS_NO = REC.RPST_PERS_NO
                           AND YYMM >= SUBSTR(REC.REDC_FR_DT,1,6)  --감면시작일자
                           AND YYMM <= SUBSTR(REC.REDC_TO_DT,1,6); --감면종료일자

                        EXCEPTION
                        WHEN NO_DATA_FOUND  THEN
                            V_RTXLW_AMT2 := 0;
                    END;

               END IF;

              --V_RTXLW_AMT1  감면기간내 급여소득액
              V_RTXLW_AMT1 := V_RTXLW_AMT1 + V_RTXLW_AMT2 ;
              V_RTXLW := 0;
              V_RTXLW_OBJ_AMT := 0; /* @VER.2016_13 */

            IF( V_RTXLW_AMT1 > 0 ) THEN
                -- 감면세액 = 종합소득산출세액 * (근로소득금액/종합소득금액)
                V_RTXLW_CURR_REDC_AMT := TRUNC(V_CAL_TDUC * 1.0 *  (V_RTXLW_AMT1) / V_LABOR_EARN_TT_SALY_AMT);

                -- 조세조약 감면 대상액 @VER.2016_13
                V_RTXLW_OBJ_AMT := V_RTXLW_AMT1;

            END IF;

            /* STEP2. 종전근무지 조세조약 감면액 계산@VER.2106_14*/
            BEGIN
                  --종전 근무지 조세조약감면액
                  SELECT NVL(SUM(RTXLW),0)
                    INTO V_RTXLW_AMT3
                    FROM PAYM430
                   WHERE YY           =  IN_YY
                     AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                     AND SETT_FG      = V_SETT_FG
                     AND RPST_PERS_NO = REC.RPST_PERS_NO
                    ;

            END;

            IF V_RTXLW_AMT3 > 0 THEN
               -- 감면세액 = 종합소득산출세액 * (근로소득금액/종합소득금액)
                V_RTXLW_ALD_REDC_AMT := TRUNC(V_CAL_TDUC * 1.0 *  (V_RTXLW_AMT3) / V_LABOR_EARN_TT_SALY_AMT);
            END IF;

            --조세조약 감면액 = 현근무지 소득 감면액 + 종전근무지 소득 감면액
            V_RTXLW := V_RTXLW_CURR_REDC_AMT + V_RTXLW_ALD_REDC_AMT;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '(54)조세조약 세액감면 체크';
V_DB_ERROR_CTNT := 'V_CAL_TDUC  산출세액:'||V_CAL_TDUC||chr(13)||chr(10)||
                   'V_RTXLW_AMT3  감면대상 소득금액:'||V_RTXLW_AMT3||chr(13)||chr(10)||
                   'V_LABOR_EARN_TT_SALY_AMT  종합소득금액:'||V_LABOR_EARN_TT_SALY_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

            SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_RTXLW,1),
                   SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_RTXLW,2)
              INTO V_CAL_TDUC_TEMP_AMT, V_RTXLW
              FROM DUAL;




/* 세액감면계 */
              V_REDC_TAX_TT := V_RTXLW + V_BF_SITE_STXLW_TAX + V_BF_SITE_SMBIZ_BONUS_TAX;  -- 조세조약 + 조특법30조(중소기업청년- 이항목은 전근무지에만 있음.) + 조특법30조 외 감면액(추가 @VER.2019_6))




/**  세액공제 시작 **/

              -- 세액공제 계
              V_TDUC_DUC_TT_AMT := 0;


/* 근로소득 세액공제 (2014재계산)*/
--                  [소득세법 제59조]
--                   - 한도 : 50만원 => 130만원
--                   - 감면급여비율 : ((주)현+종(전)중소기업취업청년 소득세감면)/총급여 => ( C59 + D52 ) / C61
--                   - 근로소득세액공제계산값(번 계산값)
--                     가. 산출세액(항목127) 이
--                       * 50만원 이하 : (산출세액 × 55%)                  |수정=>|* 130만원 이하 : (산출세액 × 55%)
--                       * 50만원 초과 : (27만5천원 + 50만원초과금액의 30%)|수정=>|* 130만원 초과 : (71만5천원 + 130만원초과금액의 30%)
--                     나. MIN( 가.번 계산값, 500000) × (1-감면급여비율)

               /*  주석처리: 연말정산 > 세금산출기준등록 PAYM450 테이블에 정산차수 추가 없이 내부처리(2014재계산)
                BEGIN
                    SELECT NVL(BASI_AMT_1,0), NVL(BASI_AMT_2,0), NVL(DUC_RATE,0)
                      INTO V_BASI_AMT_1,      V_BASI_AMT_2 ,     V_TRATE
                      FROM PAYM450
                     WHERE CAL_FG   =  'A034500003' \*세금산출구분 : 근로소득세액공제*\
                       AND YY       =  IN_YY
                       AND V_CAL_TDUC > ADPT_LOW_AMT
                       AND V_CAL_TDUC <= ADPT_UPP_AMT;
                    EXCEPTION
                    WHEN NO_DATA_FOUND  THEN
                        V_BASI_AMT_1 := 0;
                        V_BASI_AMT_2 := 0;
                        V_TRATE := 0;
                END;   */


                /*연말정산 > 세금산출기준등록 PAYM450 테이블에 정산차수 추가 없이 내부처리 (2014재계산)*/
                IF V_CAL_TDUC > 0 AND V_CAL_TDUC <= 1300000 THEN /*130만원 이하 : (산출세액 × 55%) */
                       V_BASI_AMT_1 := 0;
                       V_BASI_AMT_2 := 0;
                       V_TRATE := 55;
                ELSIF  V_CAL_TDUC > 1300000 THEN                 /* 130만원 초과 : (71만5천원 + 130만원초과금액의 30%)*/
                       V_BASI_AMT_1 :=  715000;
                       V_BASI_AMT_2 := 1300000;
                       V_TRATE := 30;
                ELSE
                       V_BASI_AMT_1 := 0;
                       V_BASI_AMT_2 := 0;
                       V_TRATE := 0;
                END IF;

                /* @VER.2015 [56]세액감면계 존재시 (57)근로소득 계산시 산출세액에서 감산처리*/
                IF V_REDC_TAX_TT > 0 THEN
                    V_LABOR_EARN_TDUC_DUC_AMT := NVL(V_BASI_AMT_1,0) + TRUNC((NVL(V_CAL_TDUC,0)- V_REDC_TAX_TT - NVL(V_BASI_AMT_2,0)) * NVL(V_TRATE,0) * 0.01);
                ELSE
                  V_LABOR_EARN_TDUC_DUC_AMT := NVL(V_BASI_AMT_1,0) + TRUNC((NVL(V_CAL_TDUC,0) - NVL(V_BASI_AMT_2,0)) * NVL(V_TRATE,0) * 0.01);
                END IF;

                /* 근로소득세액공제 한도 적용 (@VER.2016)*/
                IF V_LABOR_EARN_TT_SALY_AMT <= 33000000 THEN /*3300만원이하 74만원*/

                    V_LABOR_EARN_TDUC_DUC_AMT := LEAST(V_LABOR_EARN_TDUC_DUC_AMT, 740000);

                ELSIF V_LABOR_EARN_TT_SALY_AMT > 33000000 AND V_LABOR_EARN_TT_SALY_AMT <= 70000000 THEN /*3300만원초과 7000만원 이하 74만원-(총급여액-3300만원)*8/1000 최저 66만원*/

                    V_LABOR_EARN_TDUC_DUC_AMT := TRUNC(LEAST(V_LABOR_EARN_TDUC_DUC_AMT, GREATEST(740000 - (V_LABOR_EARN_TT_SALY_AMT - 33000000) * 0.008, 660000)));

                ELSIF V_LABOR_EARN_TT_SALY_AMT > 70000000 THEN /*7000만원초과 66만원-(총급여액-7000만원)*0.5, 최저 50만원*/

                    V_LABOR_EARN_TDUC_DUC_AMT := TRUNC(LEAST(V_LABOR_EARN_TDUC_DUC_AMT, GREATEST(660000 - (V_LABOR_EARN_TT_SALY_AMT - 70000000) * 0.5, 500000)));

                END IF;


                IF V_LABOR_EARN_TDUC_DUC_AMT > 0 THEN

                      SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_LABOR_EARN_TDUC_DUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_LABOR_EARN_TDUC_DUC_AMT,2)
                      INTO V_CAL_TDUC_TEMP_AMT, V_LABOR_EARN_TDUC_DUC_AMT
                      FROM DUAL;

                      -- 세액공제 계
                      V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_LABOR_EARN_TDUC_DUC_AMT;

                END IF;

            V_CHILD_ENC_AMT_ACCPT_YN := REC.CHILD_ENC_AMT_ACCPT_YN;  -- 자녀장려금 수령 여부 -- 2015 연말정산 추가 - @VER.2015

            /* 자녀장려금을 수령한 경우, 자녀세액공제 불가(0원 처리)  2015 연말정산추가 - @VER.2015*/
            IF V_CHILD_ENC_AMT_ACCPT_YN = 'N' THEN
                /**자녀 세액공제 2명까지 1인당 15만원 2인초과는 1인당 20만원씩=>30만원씩 (2014재계산)**/
                BEGIN
                    -- 자녀세액공제대상자수
                    SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '921', REC.RPST_PERS_NO)
                      INTO V_BASE_DUC_CHILD_CNT
                      FROM DUAL;

                    -- 자녀세액공제액('921'->'921R') (2014재계산)
                    SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '921R', REC.RPST_PERS_NO)
                      INTO V_CHILD_TAXDUC_AMT
                      FROM DUAL;
                END;

                IF V_CHILD_TAXDUC_AMT > 0 THEN
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_CHILD_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_CHILD_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_CHILD_TAXDUC_AMT
                    FROM DUAL;

                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_CHILD_TAXDUC_AMT;
                 END IF
                 ;

                /** 4. 자녀세액공제 6세 이하 자녀 추가공제 폐지(@VER.2018_4)
                 -- 6세이하 세액공제 6세이하 2명이상 1명을 초과하는 1명당 15만원 (2014재계산) 신설
                BEGIN
                    -- 6세이하 세액공제대상자수 (2014재계산) 2013년계산식 부활.
                    SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'907',REC.RPST_PERS_NO)
                      INTO V_BRED_CNT_6
                      FROM DUAL;

                    -- 6세이하 세액 공제액('921'->'922R') (2014재계산) 신설
                    SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '922R', REC.RPST_PERS_NO)
                      INTO V_CHILD_BREXPS_DUC_AMT_6
                      FROM DUAL;
                END;

                IF V_CHILD_BREXPS_DUC_AMT_6 > 0 THEN
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_CHILD_BREXPS_DUC_AMT_6,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_CHILD_BREXPS_DUC_AMT_6,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_CHILD_BREXPS_DUC_AMT_6
                    FROM DUAL;

                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_CHILD_BREXPS_DUC_AMT_6;
                 END IF
                 ;
                -- 4. 자녀세액공제 6세 이하 자녀 추가공제 폐지(@VER.2018_4) */


                 /** 출산ㆍ입양 세액공제  1명당 30만원 (2014재계산) 신설 */
                BEGIN
                    -- 출산ㆍ입양 세액공제 대상자수 (2014재계산) 2013년계산식 부활.
                    SELECT SF_PAYM421_HUM_DUC_CNT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'914',REC.RPST_PERS_NO)
                      INTO V_ADOP_CHIL_CNT
                      FROM DUAL;

                    -- 출산ㆍ입양 세액공제액(923R) (2014재계산) 신설
                    -- @VER.2017_3 첫째(30만원),둘째(50만원),셋째이후(70만원) 자녀순서별 계산으로 변경('924')
                    SELECT SF_PAYM421_HUM_DUC_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '924', REC.RPST_PERS_NO)
                      INTO V_ADOP_CHIL_DUC_AMT
                      FROM DUAL;
                END;

                IF V_ADOP_CHIL_DUC_AMT > 0 THEN
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_ADOP_CHIL_DUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_ADOP_CHIL_DUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_ADOP_CHIL_DUC_AMT
                    FROM DUAL;

                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_ADOP_CHIL_DUC_AMT;
                 END IF
                 ;

            ELSE
                V_CHILD_TAXDUC_AMT := 0;
                V_BASE_DUC_CHILD_CNT := 0;
                V_BRED_CNT_6  := 0;
                V_CHILD_BREXPS_DUC_AMT_6  := 0;
                V_ADOP_CHIL_CNT  := 0;
                V_ADOP_CHIL_DUC_AMT  := 0;
            END IF;

            /** 보장성보험료 세액공제 시작 **/
            BEGIN

                V_GUAR_INSU_PAY_INSU_AMT := 0;
                V_HANDICAP_INSU_PAY_INSU_AMT := 0;

                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면
                    --일반 보장성보험료
                    SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'126',REC.RPST_PERS_NO,NULL)
                      INTO V_GUAR_INSU_PAY_INSU_AMT
                      FROM DUAL;
                    IF V_GUAR_INSU_PAY_INSU_AMT > 1000000 THEN    -- 100만원 한도..
                        V_GUAR_INSU_PAY_INSU_AMT := 1000000;
                    END IF;

                    --장애인전용보장성보험 합산(장애인만)
                    SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY,IN_YRETXA_SEQ,  V_SETT_FG,'127',REC.RPST_PERS_NO,null)
                      INTO V_HANDICAP_INSU_PAY_INSU_AMT
                      FROM DUAL;
                    IF V_HANDICAP_INSU_PAY_INSU_AMT > 1000000 THEN    -- 100만원 한도..
                        V_HANDICAP_INSU_PAY_INSU_AMT := 1000000;
                    END IF;

                    -- 보장성보험(일반+장애인전용) 공제대상금액
                 -- V_GUARQL_INSU_DUC_OBJ_AMT := V_GUAR_INSU_PAY_INSU_AMT + V_HANDICAP_INSU_PAY_INSU_AMT;
                   --2014재계산 일반,장애인 분리
                    V_GUARQL_INSU_DUC_OBJ_AMT := V_GUAR_INSU_PAY_INSU_AMT;
                    V_DSP_GUARQL_INSU_DUC_OBJ_AMT :=V_HANDICAP_INSU_PAY_INSU_AMT;
                    -- 보장성보험(일반+장애인전용) 세액공제액
                  /*V_GUARQL_INSU_TAXDUC_AMT := TRUNC(V_GUARQL_INSU_DUC_OBJ_AMT * 0.12);*/
                    V_GUARQL_INSU_TAXDUC_AMT := TRUNC(V_GUAR_INSU_PAY_INSU_AMT * 0.12);
                    V_DSP_GUARQL_INSU_TAXDUC_AMT :=TRUNC(V_HANDICAP_INSU_PAY_INSU_AMT * 0.15); /* (2014 재계산 장애인전용보장성보험료 12%->15%) */

                    -- 차감전 세액
                    V_TMP_BF_CALC_TAXAMT := V_GUARQL_INSU_TAXDUC_AMT ;
                    -- 산출세액 차감
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_GUARQL_INSU_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_GUARQL_INSU_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_GUARQL_INSU_TAXDUC_AMT
                    FROM DUAL;

                    IF V_TMP_BF_CALC_TAXAMT <> V_GUARQL_INSU_TAXDUC_AMT THEN
                       IF V_TMP_BF_CALC_TAXAMT > 0 THEN
                            V_GUARQL_INSU_DUC_OBJ_AMT := CEIL(V_GUARQL_INSU_DUC_OBJ_AMT * V_GUARQL_INSU_TAXDUC_AMT / V_TMP_BF_CALC_TAXAMT);
                       ELSE
                            V_GUARQL_INSU_DUC_OBJ_AMT := 0;
                       END IF;
                    END IF;

                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_GUARQL_INSU_TAXDUC_AMT;
                    V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_GUARQL_INSU_DUC_OBJ_AMT;

                    --장애인보장성보험료 로직 추가 (2014재계산)
                    -- 차감전 세액
                    V_TMP_BF_CALC_TAXAMT := V_DSP_GUARQL_INSU_TAXDUC_AMT ;
                    -- 산출세액 차감
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_DSP_GUARQL_INSU_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_DSP_GUARQL_INSU_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_DSP_GUARQL_INSU_TAXDUC_AMT
                    FROM DUAL;

                    IF V_TMP_BF_CALC_TAXAMT <> V_DSP_GUARQL_INSU_TAXDUC_AMT THEN
                       IF V_TMP_BF_CALC_TAXAMT > 0 THEN
                            V_DSP_GUARQL_INSU_DUC_OBJ_AMT := CEIL(V_DSP_GUARQL_INSU_DUC_OBJ_AMT * V_DSP_GUARQL_INSU_TAXDUC_AMT / V_TMP_BF_CALC_TAXAMT);
                       ELSE
                            V_DSP_GUARQL_INSU_DUC_OBJ_AMT := 0;
                       END IF;
                    END IF;

                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_DSP_GUARQL_INSU_TAXDUC_AMT;
                    V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_DSP_GUARQL_INSU_DUC_OBJ_AMT;

               END IF;

            END;

            /* 의료비 세액공제 시작 */
            BEGIN
                -- 그밖의 공제대상자 의료비 : 700만원 한도,
                V_MEDI_LIMT_AMT := TRUNC(V_LABOR_EARN_TT_SALY_AMT * 3 / 100);  -- 의료비 공제한도 3%

                SELECT SF_SETT_PAYMENT_AMT( REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '106C', REC.RPST_PERS_NO, null)
                  INTO V_ETC_DUC_PSN_HFE  -- 그밖의 공제대상자 의료비
                  FROM DUAL;

                /* @VER.2019_4  실손의료비 추가 */
                SELECT SF_SETT_PAYMENT_AMT( REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG, '106E', REC.RPST_PERS_NO, null)
                  INTO V_REAL_LOSS_MED_AMT  -- 실손의료비 합계
                  FROM DUAL;

                -- 추가공제자의 산후조리원  -- 2019 연말정산 추가 -- @VER.2019_9
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'106F',REC.RPST_PERS_NO,NULL)
                  INTO V_ETC_CARE_DUC_PSN_HFE
                  FROM DUAL;

                -- 추가공제자 이외(본인, 65세이상, 장애인, 난임시술비)의 산후조리원비  -- 2019 연말정산 추가 -- @VER.2019_9
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'106G',REC.RPST_PERS_NO,NULL)
                  INTO V_SLF_ELDR_HIND_CARE_HFE
                  FROM DUAL;

                -- 총급여 7천만원 초과인 경우 산후조리원 비용 0원 처리 @VER.2019_9
                IF V_LABOR_EARN_TT_SALY_AMT  >  70000000 THEN    -- 총급여 7천만원  이하
                      V_ETC_CARE_DUC_PSN_HFE := 0;
                      V_SLF_ELDR_HIND_CARE_HFE := 0;
                END IF;

                --의료비추가공제(본인, 65세이상, 장애인, 난임시술비 제외) 대상금액에서 총급여*3%를 제외한 금액 .
                --추가공제자의 산후조리원 비용을 추가공제금액에 추가(SF_SETT_PAYMENT_AMT에서 산후조리원을 따로 분리시켰음) @VER.2019_9
                IF V_ETC_DUC_PSN_HFE + V_ETC_CARE_DUC_PSN_HFE > V_MEDI_LIMT_AMT + V_REAL_LOSS_MED_AMT THEN    -- 총급여액의 3% + 실손보험 넘는금액. 실손의료비 추가 @VER.2019_4
                    V_ETC_DUC_PSN_HFE := V_ETC_DUC_PSN_HFE + V_ETC_CARE_DUC_PSN_HFE - V_MEDI_LIMT_AMT - V_REAL_LOSS_MED_AMT; -- 실손의료비 차감 추가 @VER.2019_4 --추가공제자 산후조리원 비용 추가 @VER.2019_9
                    IF V_ETC_DUC_PSN_HFE > 7000000 THEN    -- 700만원 한도..
                        V_ETC_DUC_PSN_HFE := 7000000;
                    END IF;
                ELSE
                    V_ETC_DUC_PSN_HFE := V_ETC_DUC_PSN_HFE + V_ETC_CARE_DUC_PSN_HFE - V_MEDI_LIMT_AMT - V_REAL_LOSS_MED_AMT;  --전액과 합산해야 하므로 - 로 유지. 실손의료비 차감 추가 @VER.2019_4
                    -- 추가공제자 산후조리원 비용 추가 @VER.2019_9
                END IF;

                -- 본인+65세 이상.
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'106A',REC.RPST_PERS_NO,null)
                  INTO V_SLF_ELDR_HIND_HFE
                  FROM DUAL;

                -- 장애인 의료비
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'106B',REC.RPST_PERS_NO,NULL)
                  INTO V_HAND_DUC_HFE
                  FROM DUAL;

                -- 난임시술비  -- 2015 연말정산 추가 -- @VER.2015
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'106D',REC.RPST_PERS_NO,NULL) --@VER.2017_5 난임시술비 20%로 변경
                  INTO V_SUBFER_MEDIPRC_HFE
                  FROM DUAL;

                V_DUC_MAX_HFE_AMT :=  V_SLF_ELDR_HIND_HFE + V_ETC_DUC_PSN_HFE + V_SLF_ELDR_HIND_CARE_HFE + V_SUBFER_MEDIPRC_HFE; -- 장애인 제외대상은 종합한도 적용대상
                                                                                                                                 -- 추가공제자 이외 산후조리원 비용 추가 @VER.2019_9

                --특별공제 의료비 합산(본인.65세이상자.장애인 의료비,그밖의 공제대상자 의료비의 합계)
                V_HFE_DUC_AMT := V_DUC_MAX_HFE_AMT + V_HAND_DUC_HFE;

                IF V_HFE_DUC_AMT < 0 THEN
                    V_HFE_DUC_AMT := 0;
                END IF;


                V_HFE_DUC_OBJ_AMT_ORG := V_HFE_DUC_AMT; /*@VER.2017_MEDI 계산된 세액이 차감할수 있는 세액보다 많은경우 공제대상금액 계산에 오류가 있어 원계산된 대상금액이 필요함.*/

                --2014.1.15 로직 추가...김수정 : 의료비 공제가 없으면, 장애인이든 뭐든 표시해줄필요가 없다.
                IF( V_HFE_DUC_AMT <= 0 ) THEN
                    V_DUC_MAX_HFE_AMT := 0;
                    V_HAND_DUC_HFE := 0;
                END IF;


                -- 최종 공제금액은 별도로 처리되고, 합산금액만큼 처리됨.
                --2014.1.17 장애인의료비 표시금액도 최종금액으로 표시... _ 줄어든경우는 작은금액으로, 늘어난경우는 원금액으로(늘어난금액은 기타에표시되므로),,,
                --@VER.2017_16_1 왜 있는지 모르겠음..주석처리
/*                IF(V_HFE_DUC_AMT <= 0) THEN
                   V_DUC_MAX_HFE_AMT := 0;
                   V_HAND_DUC_HFE := 0;
                   V_HFE_DUC_AMT := 0;
                ELSIF (V_DUC_MAX_HFE_AMT < 0) THEN
                   V_HAND_DUC_HFE := V_HAND_DUC_HFE + V_DUC_MAX_HFE_AMT;
                   V_DUC_MAX_HFE_AMT := 0;
                   IF( V_HAND_DUC_HFE < 0) THEN
                       V_HAND_DUC_HFE := 0;
                   END IF;
                END IF;*/

                --혹시나 근로소득금액을 초과하면 그 금액까지만. 세액공제라서 불필요@VER.2017
    /*            IF( V_LABOR_TEMP_AMT < V_DUC_MAX_HFE_AMT ) THEN

                   V_DUC_MAX_HFE_AMT := V_LABOR_TEMP_AMT;
                END IF;*/


/* @@ZODEM */
/*V_OCCR_LOC_NM   := '의료비 체크 -3';
V_DB_ERROR_CTNT := 'V_CAL_TDUC_TEMP_AMT:'||V_CAL_TDUC_TEMP_AMT||chr(13)||chr(10)||
                   'V_HFE_DUC_AMT:'||V_HFE_DUC_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면

                    V_HFE_DUC_OBJ_AMT  := V_HFE_DUC_AMT;                    --의료비공제대상금액
                 -- V_HFE_TAXDUC_AMT   := TRUNC((V_HFE_DUC_AMT - V_SUBFER_MEDIPRC_HFE) * 0.15) + TRUNC(V_SUBFER_MEDIPRC_HFE * 0.20);   --의료비세액공제액(난임제외15%+난임시술비20%) @VER.2017_5 난임시술비는 20%로 상향
                    /*@VER.2017_16 난임시술비 존재할시 계산로직이 틀려서 올바른 계산으로 수정[2017연말정산교육_의료비_엑셀로직 참조함]
                                   [본인등 금액 + 그밖의 금액(공제제외금액) => 음수면 0]의 15%
                                   [본인등 금액 + 그밖의 금액(공제제외금액)]이 양수 : 난임시술비 전체 20%
                                   [본인등 금액 + 그밖의 금액(공제제외금액)]이 음수 : 본인등금액+ 그밖의 금액(공제제외금액)+난임시술비의 20%
                    */

                    -- 추가공제자 이외 산후조리원 비용 추가 @VER.2019_9
                    IF V_HFE_DUC_OBJ_AMT > 0 THEN
                      SELECT TRUNC( GREATEST((V_SLF_ELDR_HIND_HFE + V_HAND_DUC_HFE + V_SLF_ELDR_HIND_CARE_HFE + V_ETC_DUC_PSN_HFE), 0 ) * 0.15 ) +
                             TRUNC( CASE WHEN (V_SLF_ELDR_HIND_HFE + V_HAND_DUC_HFE+ V_SLF_ELDR_HIND_CARE_HFE + V_ETC_DUC_PSN_HFE) > 0 THEN GREATEST(V_SUBFER_MEDIPRC_HFE, 0)
                                         ELSE (V_SLF_ELDR_HIND_HFE + V_HAND_DUC_HFE+ V_SLF_ELDR_HIND_CARE_HFE + V_ETC_DUC_PSN_HFE + V_SUBFER_MEDIPRC_HFE) END * 0.20 )
                        INTO V_HFE_TAXDUC_AMT
                        FROM DUAL
                      ;
                    ELSE
                        V_HFE_TAXDUC_AMT :=0 ;
                    END IF
                    ;


/* @@ZODEM */
/*V_OCCR_LOC_NM   := '의료비 체크 -2';
V_DB_ERROR_CTNT := 'V_HFE_TAXDUC_AMT:'||V_HFE_TAXDUC_AMT||chr(13)||chr(10)||
                   'V_HFE_DUC_OBJ_AMT_ORG:'||V_HFE_DUC_OBJ_AMT_ORG||chr(13)||chr(10)||
                   'V_TMP_BF_CALC_TAXAMT:'||V_TMP_BF_CALC_TAXAMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */

                    -- 차감전 세액
                    V_TMP_BF_CALC_TAXAMT := V_HFE_TAXDUC_AMT;   /******/

                    -- 산출세액 차감
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_HFE_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_HFE_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_HFE_TAXDUC_AMT
                    FROM DUAL;

                    /********/
                    IF V_TMP_BF_CALC_TAXAMT <> V_HFE_TAXDUC_AMT THEN
                        IF V_TMP_BF_CALC_TAXAMT > 0 THEN
                            /*V_HFE_DUC_OBJ_AMT := CEIL((V_HFE_DUC_OBJ_AMT * V_HFE_TAXDUC_AMT) / V_TMP_BF_CALC_TAXAMT); */
                            V_HFE_DUC_OBJ_AMT := CEIL((V_HFE_DUC_OBJ_AMT_ORG * V_HFE_TAXDUC_AMT) / V_TMP_BF_CALC_TAXAMT); /* @VER.2017_MEDI */
                        ELSE
                            V_HFE_DUC_OBJ_AMT := 0;
                        END IF;


                    END IF;
/* @@ZODEM */
/*V_OCCR_LOC_NM   := '의료비 체크 -1';
V_DB_ERROR_CTNT := 'V_TDUC_DUC_TT_AMT:'||V_TDUC_DUC_TT_AMT||chr(13)||chr(10)||
                   'V_HFE_TAXDUC_AMT:'||V_HFE_TAXDUC_AMT||chr(13)||chr(10)||
                   'V_STAD_TAXDUC_OBJ_AMT:'||V_STAD_TAXDUC_OBJ_AMT||chr(13)||chr(10)||
                   'V_HFE_DUC_OBJ_AMT:'||V_HFE_DUC_OBJ_AMT||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );  */


                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_HFE_TAXDUC_AMT;
                    V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_HFE_DUC_OBJ_AMT;
                END IF;
            END;




            /** 교육비 세액공제  **/
            BEGIN
                -- 본인교육비_전액공제 (@VER.2017_7 : 학자금대출상환액 추가함)
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'108',REC.RPST_PERS_NO,null)
                  INTO V_SLF_EDU_AMT
                  FROM DUAL;


               --DBMS_OUTPUT.PUT_LINE('S8 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );
                -- 취학전아동 교육비 (@VER_2017 주석처리 따로 계산안하고 초중고와 묶어서 한도계산하도록 함)
               /* BEGIN
                    SELECT NVL(SUM(S.EDAMT_AMT),0)
                      INTO V_SCH_BF_CHILD_EDU_AMT
                      FROM (
                            SELECT A.FM_SEQ, CASE WHEN SUM(NVL(A.EDAMT_NTS_AMT,0) + NVL(A.EDAMT_ETC_AMT,0)) > 3000000 THEN 3000000
                                                  ELSE SUM(NVL(A.EDAMT_NTS_AMT,0) + NVL(A.EDAMT_ETC_AMT,0)) END EDAMT_AMT
                              FROM PAYM425 A  교육비
                                 , PAYM421 B  연말정산 가족사항
                             WHERE A.YY           = IN_YY
                               AND A.YRETXA_SEQ   = IN_YRETXA_SEQ @VER.2017_0
                               AND A.RPST_PERS_NO = REC.RPST_PERS_NO
                               AND A.BIZR_DEPT_CD = REC.BIZR_DEPT_CD
                               AND A.SETT_FG      = V_SETT_FG
                               AND A.EDAMT_FG     = 'A032300002'   유치원_학원비
                               AND A.BIZR_DEPT_CD = B.BIZR_DEPT_CD
                               AND A.YY           = B.YY
                               AND A.YRETXA_SEQ   = B.YRETXA_SEQ @VER.2017_0
                               AND A.SETT_FG      = B.SETT_FG
                               AND A.RPST_PERS_NO = B.RPST_PERS_NO
                               AND A.FM_SEQ       = B.FM_SEQ
                               AND B.FM_REL_CD NOT IN ('A034600002','A034600005','A034600006')  배우자,직계존속 제외
                               AND NVL(B.INCOME_BELOW_YN,'N') = 'Y' --인적공제에서 100만원이하 사람
                             GROUP BY A.FM_SEQ  ) S
                        ;
                END;
                */


                --DBMS_OUTPUT.PUT_LINE('S9 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );
                -- 초중고 교육비_교복구입비,체험학습비(@VER.2017_7) 포함
                -- 유치원_학원비까지 같은 그룹으로 묶어서 계산 (초등1학년의 경우 때문에.. 보육기관이 존재할 수 있음)@ VER.2017
                BEGIN
                    SELECT NVL(SUM(S.EDAMT_AMT),0)
                      INTO V_SCH_EDU_AMT
                      FROM (
                            SELECT A.FM_SEQ
                                  ,CASE WHEN SUM(  CASE WHEN A.EDAMT_FG IN ('A032300002', 'A032300003') THEN NVL(A.EDAMT_NTS_AMT,0) ELSE 0 END
                                                 + CASE WHEN A.EDAMT_FG IN ('A032300002', 'A032300003') THEN NVL(A.EDAMT_ETC_AMT,0) ELSE 0 END)
                                             + (CASE WHEN SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'110A',REC.RPST_PERS_NO,A.FM_SEQ) > 300000
                                                     THEN 300000
                                                     ELSE SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'110A',REC.RPST_PERS_NO,A.FM_SEQ)
                                                END)   /* @VER.2017_7 체험학습비 (연30만원)*/
                                             + (CASE WHEN SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'120',REC.RPST_PERS_NO,A.FM_SEQ)> 500000
                                                     THEN 500000
                                                     ELSE SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'120',REC.RPST_PERS_NO,A.FM_SEQ)
                                                END)> 3000000 THEN 3000000 /* 인당 연300만원 한도 */
                                        ELSE SUM(  CASE WHEN A.EDAMT_FG IN ('A032300002', 'A032300003') THEN NVL(A.EDAMT_NTS_AMT,0) ELSE 0 END
                                                 + CASE WHEN A.EDAMT_FG IN ('A032300002', 'A032300003') THEN NVL(A.EDAMT_ETC_AMT,0) ELSE 0 END)
                                             + (CASE WHEN SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'110A',REC.RPST_PERS_NO,A.FM_SEQ) > 300000
                                                     THEN 300000
                                                ELSE SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'110A',REC.RPST_PERS_NO,A.FM_SEQ)
                                                END)   /* @VER.2017_7 체험학습비 (연30만원)*/
                                             + (CASE WHEN SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'120',REC.RPST_PERS_NO,A.FM_SEQ) > 500000
                                                     THEN 500000
                                                     ELSE SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'120',REC.RPST_PERS_NO,A.FM_SEQ)
                                                END)
                                   END AS EDAMT_AMT
                              FROM PAYM425 A /* 교육비 */
                                 , PAYM421 B /* 연말정산 가족사항 */
                             WHERE A.YY             = IN_YY
                               AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                               AND A.RPST_PERS_NO   = REC.RPST_PERS_NO
                               AND A.BIZR_DEPT_CD   = REC.BIZR_DEPT_CD
                               AND A.SETT_FG        = V_SETT_FG
                               AND A.EDAMT_FG      IN ('A032300002', 'A032300003', 'A032300006', 'A032300007') /* 유치원_학원비, 초중고공납금,교복구입비,체험학습비 */
                               AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                               AND A.YY             = B.YY
                               AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                               AND A.SETT_FG        = B.SETT_FG
                               AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                               AND A.FM_SEQ         = B.FM_SEQ
                               AND B.FM_REL_CD NOT IN ('A034600005','A034600006', 'A034600001', 'A034600002')  --소득자의직계존속, 배우자의 직계존속,본인,배우자 제외
                               AND NVL(B.INCOME_BELOW_YN,'N') = 'Y' --인적공제에서 100만원이하 사람
                               AND NOT EXISTS (SELECT 1
                                                FROM PAYM425 T
                                               WHERE T.YY           = A.YY
                                                 AND T.YRETXA_SEQ   = A.YRETXA_SEQ
                                                 AND T.RPST_PERS_NO = A.RPST_PERS_NO
                                                 AND T.FM_SEQ       = A.FM_SEQ
                                                 AND T.EDAMT_FG     = 'A032300004')/* 대학공납금 (대학생은 제외 : 대학생인데 교복구입비 입력데이터 존재해서 추가함.@VER.2017)*/
                             GROUP BY A.FM_SEQ  ) S
                        ;
                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            V_SCH_EDU_AMT := 0;
                END;
                -- 대학교 교육비
                BEGIN
                    SELECT NVL(SUM(S.EDAMT_AMT),0)
                      INTO V_UNIV_PSN_EDU_AMT
                      FROM (
                            SELECT A.FM_SEQ, CASE WHEN SUM(NVL(A.EDAMT_NTS_AMT,0) + NVL(A.EDAMT_ETC_AMT,0)) > 9000000 THEN 9000000
                                                  ELSE SUM(NVL(A.EDAMT_NTS_AMT,0) + NVL(A.EDAMT_ETC_AMT,0)) END EDAMT_AMT
                              FROM PAYM425 A /* 교육비 */
                                 , PAYM421 B /* 연말정산가족사항 */
                             WHERE A.YY             = IN_YY
                               AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                               AND A.RPST_PERS_NO   = REC.RPST_PERS_NO
                               AND A.BIZR_DEPT_CD   = REC.BIZR_DEPT_CD
                               AND A.SETT_FG        = V_SETT_FG
                               AND A.EDAMT_FG       = 'A032300004' /* 대학공납금 */
                               AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                               AND A.YY             = B.YY
                               AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                               AND A.SETT_FG        = B.SETT_FG
                               AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                               AND A.FM_SEQ         = B.FM_SEQ
                               AND B.FM_REL_CD NOT IN ('A034600005','A034600006')
                               AND NVL(B.INCOME_BELOW_YN,'N') = 'Y' --소득자의직계존속, 배우자의 직계존속이 아니면서 인적공제에서 100만원이하 사람
                             GROUP BY A.FM_SEQ  ) S
                        ;
                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            V_UNIV_PSN_EDU_AMT := 0;
                END;

                --DBMS_OUTPUT.PUT_LINE('S10 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );

                -- 장애인 교육비_전액공제
                /*V_HANDICAP_SPCL_EDU_AMT  := SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, V_SETT_FG,'112',REC.RPST_PERS_NO,null);*/
                SELECT SF_SETT_PAYMENT_AMT(REC.BIZR_DEPT_CD, IN_YY, IN_YRETXA_SEQ, V_SETT_FG,'112',REC.RPST_PERS_NO,NULL)
                  INTO V_HANDICAP_SPCL_EDU_AMT
                  FROM DUAL;

                --특별공제 교육비 합산(본인,취학전아동,초중고,대학교,장애인,교복구입 교육비의 합계)
                V_EDU_DUC_AMT := V_SLF_EDU_AMT + V_SCH_BF_CHILD_EDU_AMT + V_SCH_EDU_AMT + V_UNIV_PSN_EDU_AMT ;

-- 2014               V_SPCL_DUC_AMT  := V_SPCL_DUC_AMT + V_EDU_DUC_AMT + V_HANDICAP_SPCL_EDU_AMT;
-- 2014               V_DUC_MAX_EDU_AMT := V_EDU_DUC_AMT; -- 공제한도 체크는 장애인제외값
                V_EDU_DUC_AMT := V_EDU_DUC_AMT + V_HANDICAP_SPCL_EDU_AMT; --최종공제금액은 둘의 합산.

                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면


                    V_EDAMT_DUC_OBJ_AMT := V_EDU_DUC_AMT;                         --교육비공제대상금액
                    V_EDAMT_TAXDUC_AMT  := TRUNC(V_EDAMT_DUC_OBJ_AMT * 0.15);     --교육비세액공제액(15%)

                                        -- 차감전 세액
                    V_TMP_BF_CALC_TAXAMT := V_EDAMT_TAXDUC_AMT;   /******/

                    -- 산출세액 차감
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_EDAMT_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_EDAMT_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_EDAMT_TAXDUC_AMT
                    FROM DUAL;

                    /********/
                    IF V_TMP_BF_CALC_TAXAMT <> V_EDAMT_TAXDUC_AMT THEN
                        IF V_TMP_BF_CALC_TAXAMT > 0 THEN
                            V_EDAMT_DUC_OBJ_AMT := CEIL((V_EDAMT_DUC_OBJ_AMT * V_EDAMT_TAXDUC_AMT) / V_TMP_BF_CALC_TAXAMT);
                        ELSE
                            V_EDAMT_DUC_OBJ_AMT := 0;
                        END IF;
                    END IF;

                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_EDAMT_TAXDUC_AMT;
                    V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_EDAMT_DUC_OBJ_AMT;
                END IF;
            END;




/* 기부금 세액공제액 */

                /** 1.1. 정치자금기부금(20) 전액공제, 이월 없음**/
                 BEGIN
                    SELECT SUM(NVL(A.NTS_CNTRIB_AMT,0) + NVL(A.ETC_CNTRIB_AMT,0))
                      INTO V_FLAW_CNTRIB_AMT
                      FROM PAYM423 A --당년도 등록 공제 내역
                         , PAYM421 B --연말정산 가족사항
                     WHERE A.RPST_PERS_NO   = REC.RPST_PERS_NO
                       AND A.YY             = IN_YY
                       AND A.YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                       AND A.CNTRIB_TYPE_CD = 'A032400002'
                       AND A.BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                       AND A.SETT_FG        = V_SETT_FG
                       AND A.BIZR_DEPT_CD   = B.BIZR_DEPT_CD
                       AND A.YY             = B.YY
                       AND A.YRETXA_SEQ     = B.YRETXA_SEQ /*@VER.2017_0*/
                       AND A.SETT_FG        = B.SETT_FG
                       AND A.RPST_PERS_NO   = B.RPST_PERS_NO
                       AND A.FM_SEQ         = B.FM_SEQ
                       AND B.FM_REL_CD      = 'A034600001'  -- 정치자금은 본인만
                       AND (B.INCOME_BELOW_YN = 'Y' OR B.FM_REL_CD = 'A034600001')--@VER.2016_4 기부금 부양가족 연령요건 삭제(소득요건만 체크 또는 본인)
                     --AND NVL(B.BASE_DUC_YN,'N') IN ('Y','1') --기본공제 체크된 사람의 기부금
                       ;

                       EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                               V_FLAW_CNTRIB_AMT := 0;
                 END;

                 IF V_FLAW_CNTRIB_AMT <> 0 THEN
                   BEGIN

                    IF V_FLAW_CNTRIB_AMT > V_LABOR_EARN_AMT THEN            -- 정치자금기부금이 근로소득금액보다 큰경우...
                        V_CNTRIB_DUC_AMT     := V_LABOR_EARN_AMT;                          -- 근로소득금액까지만 공제
                        V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                        V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                        V_CNTRIB_DESTAMT     := V_FLAW_CNTRIB_AMT - V_LABOR_EARN_AMT;      -- 기부금 당년 소멸금액
                        V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                    ELSE
                        V_CNTRIB_DUC_AMT     := V_FLAW_CNTRIB_AMT;                         -- 정치기부금 전액공제
                        V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                        V_CNTRIB_GONGAMT     := V_CNTRIB_DUC_AMT;                          -- 기부금 당년 공제금액
                        V_CNTRIB_DESTAMT     := 0;                                         -- 기부금 당년 소멸금액
                        V_CNTRIB_OVERAMT     := 0;                                         -- 기부금 당년 이월금액
                    END IF;

                     IF V_FLAW_CNTRIB_AMT > V_LABOR_EARN_AMT THEN
                        V_FLAW_CNTRIB_AMT := V_LABOR_EARN_AMT;
                     END IF;

                     IF V_FLAW_CNTRIB_AMT > 100000 THEN
                        V_FLAW_CNTRIB_100_RATE_AMT := 100000;             -- 정치자금 10만원까지
                        V_FLAW_CNTRIB_15_RATE_AMT := LEAST(V_FLAW_CNTRIB_AMT - 100000, 30000000 - 100000);  -- 정치자금 10만원초과 29900000원까지
                        V_FLAW_CNTRIB_25_RATE_AMT := GREATEST(0, (V_FLAW_CNTRIB_AMT - V_FLAW_CNTRIB_100_RATE_AMT - V_FLAW_CNTRIB_15_RATE_AMT)); -- 정치자금 3천만원초과
                     ELSE
                        V_FLAW_CNTRIB_100_RATE_AMT := V_FLAW_CNTRIB_AMT;             -- 정치자금 10만원까지
                     END IF;             -- 정치자금 10만원까지

                     IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면 THEN
                        V_POLITICS_BLW_DUC_OBJ_AMT := V_FLAW_CNTRIB_100_RATE_AMT;
                        V_POLITICS_BLW_TAXDUC_AMT := TRUNC(V_POLITICS_BLW_DUC_OBJ_AMT * 100/110);

                        -- 차감전 세액
                        V_TMP_BF_CALC_TAXAMT := V_POLITICS_BLW_TAXDUC_AMT;   /******/

                        -- 산출세액 차감
                        SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_POLITICS_BLW_TAXDUC_AMT,1),
                               SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_POLITICS_BLW_TAXDUC_AMT,2)
                        INTO V_CAL_TDUC_TEMP_AMT, V_POLITICS_BLW_TAXDUC_AMT
                        FROM DUAL;

                        /********/
                        IF V_TMP_BF_CALC_TAXAMT <> V_POLITICS_BLW_TAXDUC_AMT THEN
                            IF V_TMP_BF_CALC_TAXAMT > 0 THEN
                                V_POLITICS_BLW_DUC_OBJ_AMT := CEIL((V_POLITICS_BLW_DUC_OBJ_AMT * V_POLITICS_BLW_TAXDUC_AMT) / V_TMP_BF_CALC_TAXAMT);
                            ELSE
                                V_POLITICS_BLW_DUC_OBJ_AMT := 0;
                            END IF;
                        END IF;


                        -- 세액공제 계
                        V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_POLITICS_BLW_TAXDUC_AMT;

                        V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_POLITICS_BLW_DUC_OBJ_AMT;  /*****/

                     ELSE
                        V_CNTRIB_DUC_AMT     := 0;                         -- 정치기부금 전액공제
                        V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                        V_CNTRIB_GONGAMT     := 0;                          -- 기부금 당년 공제금액
                        V_CNTRIB_DESTAMT     := V_FLAW_CNTRIB_AMT;    -- 기부금 당년 소멸금액
                        V_CNTRIB_OVERAMT     := 0;                    -- 기부금 당년 이월금액
                        V_POLITICS_BLW_DUC_OBJ_AMT := 0;
                        V_POLITICS_BLW_TAXDUC_AMT := 0;
                        V_POLITICS_EXCE_DUC_OBJ_AMT := 0;
                        V_POLITICS_EXCE_TAXDUC_AMT := 0;

                     END IF;


                     IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면 THEN

                        V_POLITICS_EXCE_DUC_OBJ_AMT := V_FLAW_CNTRIB_15_RATE_AMT + V_FLAW_CNTRIB_25_RATE_AMT;
                        V_POLITICS_EXCE_TAXDUC_AMT := TRUNC(V_FLAW_CNTRIB_15_RATE_AMT * 0.15 + V_FLAW_CNTRIB_25_RATE_AMT * 0.25);

                        -- 차감전 세액
                        V_TMP_BF_CALC_TAXAMT := V_POLITICS_EXCE_TAXDUC_AMT;   /******/

                        -- 산출세액 차감
                        SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_POLITICS_EXCE_TAXDUC_AMT,1),
                               SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_POLITICS_EXCE_TAXDUC_AMT,2)
                        INTO V_CAL_TDUC_TEMP_AMT, V_POLITICS_EXCE_TAXDUC_AMT
                        FROM DUAL;

                        /********/
                        IF V_TMP_BF_CALC_TAXAMT <> V_POLITICS_EXCE_TAXDUC_AMT THEN
                            IF V_TMP_BF_CALC_TAXAMT > 0 THEN
                                V_POLITICS_EXCE_DUC_OBJ_AMT := CEIL((V_POLITICS_EXCE_DUC_OBJ_AMT * V_POLITICS_EXCE_TAXDUC_AMT) / V_TMP_BF_CALC_TAXAMT);
                            ELSE
                                V_POLITICS_EXCE_DUC_OBJ_AMT := 0;
                            END IF;
                        END IF;


                        -- 세액공제 계
                        V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_POLITICS_EXCE_TAXDUC_AMT;
                        V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_POLITICS_EXCE_DUC_OBJ_AMT;  /*****/

                     ELSE
                        V_CNTRIB_DUC_AMT     := 0;                         -- 정치기부금 전액공제
                        V_CNTRIB_PREAMT      := 0;                                         -- 기부금 전년까지 공제금액
                        V_CNTRIB_GONGAMT     := 0;                          -- 기부금 당년 공제금액
                        V_CNTRIB_DESTAMT     := V_FLAW_CNTRIB_AMT;    -- 기부금 당년 소멸금액
                        V_CNTRIB_OVERAMT     := 0;                    -- 기부금 당년 이월금액
                        V_POLITICS_EXCE_DUC_OBJ_AMT := 0;
                        V_POLITICS_EXCE_TAXDUC_AMT := 0;

                     END IF;

                     IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
                        V_TMP_STEP := 'D14';
                        DELETE FROM PAYM436
                         WHERE YY             = IN_YY
                           AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                           AND SETT_FG        = V_SETT_FG
                           AND RPST_PERS_NO   = REC.RPST_PERS_NO
                           AND CNTRIB_YY      = IN_YY
                           AND CNTRIB_TYPE_CD = 'A032400002'
                           ;

                         V_TMP_STEP := '009';
                         INSERT INTO PAYM436(BIZR_DEPT_CD     --사업자부서코드
                                             ,YY               --년도
                                             ,SETT_FG           --정산구분
                                             ,RPST_PERS_NO     --대표개인번호
                                             ,CNTRIB_YY         --기부년도
                                             ,CNTRIB_TYPE_CD   --기부금유형
                                             ,CNTRIB_GIAMT     --기부금액
                                             ,CNTRIB_PREAMT     --전년까지 공제금액
                                             ,CNTRIB_GONGAMT   --당년 공제금액
                                             ,CNTRIB_DESTAMT   --당년 소멸금액
                                             ,CNTRIB_OVERAMT   --당년 이월금액
                                             ,INPT_ID           --입력자ID
                                             ,INPT_DTTM         --입력일자
                                             ,INPT_IP           --입력자IP
                                              )
                                VALUES(IN_BIZR_DEPT_CD
                                      ,IN_YY
                                      ,V_SETT_FG
                                      ,REC.RPST_PERS_NO
                                      ,IN_YY
                                      ,'A032400002'
                                      ,V_FLAW_CNTRIB_AMT
                                      ,V_CNTRIB_PREAMT
                                      ,V_CNTRIB_GONGAMT
                                      ,V_CNTRIB_DESTAMT
                                      ,V_CNTRIB_OVERAMT
                                      ,IN_INPT_ID
                                      ,SYSDATE
                                      ,IN_INPT_IP
                                       );
                     ELSE
                        V_TMP_STEP := 'D15';
                        DELETE FROM PAYM432
                         WHERE YY = IN_YY
                           AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                           AND SETT_FG        = V_SETT_FG
                           AND RPST_PERS_NO   = REC.RPST_PERS_NO
                           AND CNTRIB_YY      = IN_YY
                           AND CNTRIB_TYPE_CD = 'A032400002'
                           AND YRETXA_SEQ = 1 --(2014재계산):1차만 지웁니다.
                           ;

                         V_TMP_STEP := '010';
                         INSERT INTO PAYM432( BIZR_DEPT_CD     --사업자부서코드
                                             ,YY               --년도
                                             ,YRETXA_SEQ       --정산차수@VER.2017_0
                                             ,SETT_FG          --정산구분
                                             ,RPST_PERS_NO     --대표개인번호
                                             ,CNTRIB_YY        --기부년도
                                             ,CNTRIB_TYPE_CD   --기부금유형
                                             ,CNTRIB_GIAMT     --기부금액
                                             ,CNTRIB_PREAMT    --전년까지 공제금액
                                             ,CNTRIB_GONGAMT   --당년 공제금액
                                             ,CNTRIB_DESTAMT   --당년 소멸금액
                                             ,CNTRIB_OVERAMT   --당년 이월금액
                                             ,INPT_ID          --입력자ID
                                             ,INPT_DTTM        --입력일시
                                             ,INPT_IP          --입력자IP                                                                                      \
                                              )
                                VALUES(IN_BIZR_DEPT_CD
                                      ,IN_YY
                                      ,IN_YRETXA_SEQ           --정산차수@VER.2017_0
                                      ,V_SETT_FG
                                      ,REC.RPST_PERS_NO
                                      ,IN_YY
                                      ,'A032400002'
                                      ,V_FLAW_CNTRIB_AMT
                                      ,V_CNTRIB_PREAMT
                                      ,V_CNTRIB_GONGAMT
                                      ,V_CNTRIB_DESTAMT
                                      ,V_CNTRIB_OVERAMT
                                      ,IN_INPT_ID
                                      ,SYSDATE
                                      ,IN_INPT_IP
                                       );
                     END IF;

                    EXCEPTION
                        WHEN OTHERS THEN
                             OUT_RTN := 0;
                             OUT_MSG := '정치자금 기부금계산결과 생성오류(대표개인번호 : '||V_RPST_PERS_NO||SQLCODE || ':' || SQLERRM || ')';
                             RETURN;
                   END;
                 END IF;
                 

            -- 기부금 세액공제 전 결정세액
            V_BF_CNTRIB_TAXDUC_AMT := V_CAL_TDUC_TEMP_AMT;


            -- 올해 법정기부금 + 지정기부금 공제대상액
            V_TMP_AMT := V_FLAW_CNTRIB_DUC_OBJ_AMT + V_APNT_CNTRIB_DUC_OBJ_AMT;

 /* @ZZODEM */
--  /*V_OCCR_LOC_NM   := '법정기부금 체크 Step:1';
--  V_DB_ERROR_CTNT := 'V_BF_CNTRIB_TAXDUC_AMT:'||V_BF_CNTRIB_TAXDUC_AMT||chr(13)||chr(10)||
--                     'V_FLAW_CNTRIB_DUC_OBJ_AMT:'||V_FLAW_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10)||
--                     'V_APNT_CNTRIB_DUC_OBJ_AMT:'||V_APNT_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10);
--  SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */
--
--
--            /* @VER.2016_3  기부금 한도 3000->2000 / 25->30%공제 (정치자금기부금은 3000,25%유지)       */
--            /* @VER.2019_3  고액기부금 기준 금액 변화(2천만원에서 1천만원으로 변경) */
--            IF V_TMP_AMT > 10000000 THEN
--                V_CNTRIB_TAXDUC_AMT := ((V_TMP_AMT - 10000000) * 0.30) + (10000000 * 0.15);
--            ELSE
--                V_CNTRIB_TAXDUC_AMT := (V_TMP_AMT * 0.15);
--            END IF;
--
--            -- 조정세액공제액 계산
--            V_MOD_CNTRIB_TAXDUC_AMT := LEAST(V_BF_CNTRIB_TAXDUC_AMT, V_CNTRIB_TAXDUC_AMT);
--
--/* @ZZODEM */
--/*V_OCCR_LOC_NM   := '법정기부금 체크  step:2';
--V_DB_ERROR_CTNT := 'V_TMP_AMT:'||V_TMP_AMT||chr(13)||chr(10)||
--                   'V_CNTRIB_TAXDUC_AMT:'||V_CNTRIB_TAXDUC_AMT||chr(13)||chr(10)||
--                   'V_MOD_CNTRIB_TAXDUC_AMT:'||V_MOD_CNTRIB_TAXDUC_AMT||chr(13)||chr(10);
--SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */
--
--
--
--            -- 산출세액 차감
--            SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, CEIL(V_MOD_CNTRIB_TAXDUC_AMT),1),
--                   SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_MOD_CNTRIB_TAXDUC_AMT,2)
--            INTO V_CAL_TDUC_TEMP_AMT, V_MOD_CNTRIB_TAXDUC_AMT
--            FROM DUAL;
--
--            -- 세액공제 계
--            V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + TRUNC(V_MOD_CNTRIB_TAXDUC_AMT);
--
--            -- 조정세액공제액에 따른 조정 공제대상액 계산
--            /* 2015년 소스
--            IF V_MOD_CNTRIB_TAXDUC_AMT > (30000000 * 0.15) THEN
--                V_MOD_CNTRIB_DUC_OBJ_AMT := ((30000000 * 0.15)/0.15) + (V_MOD_CNTRIB_TAXDUC_AMT - (30000000 * 0.15))/0.25;
--            ELSE
--                V_MOD_CNTRIB_DUC_OBJ_AMT := V_MOD_CNTRIB_TAXDUC_AMT/0.15;
--            END IF; */
--
--            /* @VER.2016_3*/
--            /* @VER.2019_3  고액기부금 기준 금액 변화(2천만원에서 1천만원으로 변경) */
--            IF V_MOD_CNTRIB_TAXDUC_AMT > (10000000 * 0.15) THEN
--                V_MOD_CNTRIB_DUC_OBJ_AMT := ((10000000 * 0.15)/0.15) + (V_MOD_CNTRIB_TAXDUC_AMT - (10000000 * 0.15))/0.30;
--            ELSE
--                V_MOD_CNTRIB_DUC_OBJ_AMT := V_MOD_CNTRIB_TAXDUC_AMT/0.15;
--            END IF;
--
--/* @ZZODEM */
--/*V_OCCR_LOC_NM   := '법정기부금 체크:3';
--V_DB_ERROR_CTNT := 'V_FLAW_CNTRIB_DUC_OBJ_AMT:'||V_FLAW_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10)||
--                   'V_MOD_CNTRIB_DUC_OBJ_AMT:'||V_MOD_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10);
--SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */


--            /* 조정세액공제액일 경우 */
--            IF V_MOD_CNTRIB_TAXDUC_AMT > 0 THEN
--
--/* @ZZODEM */
--/*V_OCCR_LOC_NM   := '법정기부금 체크:4';
--V_DB_ERROR_CTNT := 'V_MOD_CNTRIB_TAXDUC_AMT:'||V_MOD_CNTRIB_TAXDUC_AMT||chr(13)||chr(10)||
--                   'V_MOD_CNTRIB_DUC_OBJ_AMT:'||V_MOD_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10)||
--                   'V_FLAW_CNTRIB_TAXDUC_AMT:'||V_FLAW_CNTRIB_TAXDUC_AMT||chr(13)||chr(10)||
--                   'V_FLAW_CNTRIB_DUC_OBJ_AMT:'||V_FLAW_CNTRIB_DUC_OBJ_AMT||chr(13)||chr(10)||
--                   'V_TMP_AMT:'||V_TMP_AMT||chr(13)||chr(10)
--                   ;
--SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */
--
--                /*법정기부금 세액공제액 = (조정세액공제액 * 법정기부금공제대상금액) / 실제 세액공제액 */
--                V_FLAW_CNTRIB_TAXDUC_AMT  := TRUNC((V_MOD_CNTRIB_TAXDUC_AMT * V_FLAW_CNTRIB_DUC_OBJ_AMT) / V_TMP_AMT);
--                V_FLAW_CNTRIB_DUC_OBJ_AMT := TRUNC(((V_MOD_CNTRIB_DUC_OBJ_AMT * V_MOD_CNTRIB_TAXDUC_AMT * V_FLAW_CNTRIB_DUC_OBJ_AMT) / V_TMP_AMT) / V_MOD_CNTRIB_TAXDUC_AMT);
--
--                /* @VER.2017_99 국세청파일생성(PAYM460)시 법정+지정합산 2000만원 초과 계산 보정 */
--                /* @VER.2019_3  고액기부금 기준 금액 변화(2천만원에서 1천만원으로 변경) */
--                IF V_FLAW_CNTRIB_DUC_OBJ_AMT > 10000000 THEN
--                -- V_FLAW_CNTRIB_TAXDUC_AMT  := TRUNC((V_MOD_CNTRIB_TAXDUC_AMT * V_FLAW_CNTRIB_DUC_OBJ_AMT) / V_TMP_AMT);
--                   V_FLAW_CNTRIB_TAXDUC_AMT  := TRUNC( (10000000*0.15)+(V_FLAW_CNTRIB_DUC_OBJ_AMT-10000000)*0.3 );
--
--                   V_APNT_CNTRIB_TAXDUC_AMT  := TRUNC(V_MOD_CNTRIB_TAXDUC_AMT - V_FLAW_CNTRIB_TAXDUC_AMT);
--                   V_APNT_CNTRIB_DUC_OBJ_AMT := TRUNC(V_MOD_CNTRIB_DUC_OBJ_AMT - V_FLAW_CNTRIB_DUC_OBJ_AMT);
--                ELSE
--                   V_FLAW_CNTRIB_TAXDUC_AMT  :=  V_FLAW_CNTRIB_DUC_OBJ_AMT * 0.15 ;
--
--                   V_APNT_CNTRIB_TAXDUC_AMT  := TRUNC(V_MOD_CNTRIB_TAXDUC_AMT - V_FLAW_CNTRIB_TAXDUC_AMT);
--                   V_APNT_CNTRIB_DUC_OBJ_AMT := TRUNC(V_MOD_CNTRIB_DUC_OBJ_AMT - V_FLAW_CNTRIB_DUC_OBJ_AMT);
--                END IF;
--
--
--                /*지정기부금 세액공제액 = 조정세액공제액 - 법정기부금 세액공제액*/
--                /*V_APNT_CNTRIB_TAXDUC_AMT  := TRUNC(V_MOD_CNTRIB_TAXDUC_AMT - V_FLAW_CNTRIB_TAXDUC_AMT);
--                V_APNT_CNTRIB_DUC_OBJ_AMT := TRUNC(V_MOD_CNTRIB_DUC_OBJ_AMT - V_FLAW_CNTRIB_DUC_OBJ_AMT);*/
--
--                /*
--                  @VER.2016_8 현단계에서 지정기부금 종교외(41),종교(40)의 대상금액과 세액공제액을 구하기 어렵다.
--                              하단 기부금이월 UPDATE문을 완료후에 계산한다.
--
--                V_APNT_CNTRIB41_TAXDUC_AMT  := TRUNC(V_MOD_CNTRIB_TAXDUC_AMT - V_FLAW_CNTRIB_TAXDUC_AMT);
--                V_APNT_CNTRIB41_DUC_OBJ_AMT := TRUNC(V_MOD_CNTRIB_DUC_OBJ_AMT - V_FLAW_CNTRIB_DUC_OBJ_AMT);
--
--                V_APNT_CNTRIB40_TAXDUC_AMT  := TRUNC(V_MOD_CNTRIB_TAXDUC_AMT - V_FLAW_CNTRIB_TAXDUC_AMT);
--                V_APNT_CNTRIB40_DUC_OBJ_AMT := TRUNC(V_MOD_CNTRIB_DUC_OBJ_AMT - V_FLAW_CNTRIB_DUC_OBJ_AMT);
--                 */
--            ELSE
--                V_FLAW_CNTRIB_TAXDUC_AMT := 0;
--                V_APNT_CNTRIB_TAXDUC_AMT := 0;
--                V_APNT_CNTRIB40_TAXDUC_AMT := 0;
--                V_APNT_CNTRIB41_TAXDUC_AMT := 0;
--
--                V_FLAW_CNTRIB_DUC_OBJ_AMT := 0;
--                V_APNT_CNTRIB_DUC_OBJ_AMT := 0;
--                V_APNT_CNTRIB40_DUC_OBJ_AMT := 0;
--                V_APNT_CNTRIB41_DUC_OBJ_AMT := 0;
--            END IF;
--
--  
/** 2019년도 법정, 우리사주, 지정 기부금 세액계산 **/                 
                 
                 
 /* 기부금세액공제전 결정세액 <= 정치자금기부금까지 처리된 결정세액 */
V_BF_CNTRIB_TAXDUC_AMT := V_CAL_TDUC_TEMP_AMT; 
GV_TAX_REMAIN_AMT  := V_CAL_TDUC_TEMP_AMT;  




        IF GV_TAX_REMAIN_AMT < 0 THEN
--            V_RSLT := '차감 가능 산출세액 잔액이 음수입니다[법정/우리사주/지정기부금 세액공제].';
--            RAISE USER_DEFINE_ERROR;
            GV_TAX_REMAIN_AMT := 0;
        ELSIF GV_TAX_REMAIN_AMT = 0 THEN

            GN_RT_TOTAL_CUR_SUB     := 0;   -- 당해년도 법정 기부금
            GN_RT_TOTAL_ETC_SUB_14  := 0;   -- 2014년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_15  := 0;   -- 2015년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_16  := 0;   -- 2016년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_17  := 0;   -- 2017년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_18  := 0;   -- 2018년도 법정 이뤌 기부금

            GN_STOCK_URSM           := 0;   -- 우리사주조합기부금
            
            GN_RT_PSA_CUR_APPNT     := 0;   -- 당해년도 지정(종교단체외) 기부금
            GN_RT_PSA_ETC_APPNT_14  := 0;   -- 2014년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_15  := 0;   -- 2015년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_16  := 0;   -- 2016년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_17  := 0;   -- 2017년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_18  := 0;   -- 2018년도 지정(종교단체외) 이월 기부금

            GN_RT_PSA_CUR_RELGN     := 0;   -- 2019년도 지정(종교단체) 당월 기부금
            GN_RT_PSA_ETC_RELGN_14  := 0;   -- 2014년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_15  := 0;   -- 2015년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_16  := 0;   -- 2016년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_17  := 0;   -- 2017년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_18  := 0;   -- 2018년도 지정(종교단체) 이월 기부금

            GV_CALC_RT_DON_LAW      := 0;   -- 기부금 공제세액
            GV_CALC_RT_STOCK_URSM   := 0;   -- 우리사주조합기부금  공제세액
            GV_CALC_RT_PSA          := 0;   -- 종교단체외 공제세액
            GV_CALC_RT_PSA_RELGN    := 0;   -- 종교단체 공제세액
        ELSIF GV_TAX_REMAIN_AMT > 0 THEN
        
        SELECT NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400001' AND CNTRIB_YY = '2019' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS  GN_RT_TOTAL_CUR_SUB     -- 당해년도 법정 기부금                ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400001' AND CNTRIB_YY = '2014' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_TOTAL_ETC_SUB_14  -- 2014년도 법정 이뤌 기부금            ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400001' AND CNTRIB_YY = '2015' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_TOTAL_ETC_SUB_15  -- 2015년도 법정 이뤌 기부금            ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400001' AND CNTRIB_YY = '2016' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_TOTAL_ETC_SUB_16  -- 2016년도 법정 이뤌 기부금            ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400001' AND CNTRIB_YY = '2017' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_TOTAL_ETC_SUB_17  -- 2017년도 법정 이뤌 기부금            ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400001' AND CNTRIB_YY = '2018' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_TOTAL_ETC_SUB_18  -- 2018년도 법정 이뤌 기부금            ,

             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400008' AND CNTRIB_YY = '2019' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_STOCK_URSM           -- 우리사주조합기부금                   ,

             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400006' AND CNTRIB_YY = '2019' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_CUR_APPNT     -- 당해년도 지정(종교단체외) 기부금     ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400006' AND CNTRIB_YY = '2014' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_APPNT_14  -- 2014년도 지정(종교단체외) 이월 기부금,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400006' AND CNTRIB_YY = '2015' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_APPNT_15  -- 2015년도 지정(종교단체외) 이월 기부금,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400006' AND CNTRIB_YY = '2016' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_APPNT_16  -- 2016년도 지정(종교단체외) 이월 기부금,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400006' AND CNTRIB_YY = '2017' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_APPNT_17  -- 2017년도 지정(종교단체외) 이월 기부금,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400006' AND CNTRIB_YY = '2018' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_APPNT_18  -- 2018년도 지정(종교단체외) 이월 기부금,

             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400007' AND CNTRIB_YY = '2019' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_CUR_RELGN     -- 2019년도 지정(종교단체) 당월 기부금  ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400007' AND CNTRIB_YY = '2014' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_RELGN_14  -- 2014년도 지정(종교단체) 이월 기부금  ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400007' AND CNTRIB_YY = '2015' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_RELGN_15  -- 2015년도 지정(종교단체) 이월 기부금  ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400007' AND CNTRIB_YY = '2016' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_RELGN_16  -- 2016년도 지정(종교단체) 이월 기부금  ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400007' AND CNTRIB_YY = '2017' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_RELGN_17  -- 2017년도 지정(종교단체) 이월 기부금  ,
             , NVL(SUM(CASE WHEN CNTRIB_TYPE_CD = 'A032400007' AND CNTRIB_YY = '2018' THEN NVL(CNTRIB_GONGAMT, 0) ELSE 0 END), 0) AS GN_RT_PSA_ETC_RELGN_18  -- 2018년도 지정(종교단체) 이월 기부금  ,

               
                INTO     GN_RT_TOTAL_CUR_SUB     -- 당해년도 법정 기부금
                        ,GN_RT_TOTAL_ETC_SUB_14  -- 2014년도 법정 이뤌 기부금
                        ,GN_RT_TOTAL_ETC_SUB_15  -- 2015년도 법정 이뤌 기부금
                        ,GN_RT_TOTAL_ETC_SUB_16  -- 2016년도 법정 이뤌 기부금
                        ,GN_RT_TOTAL_ETC_SUB_17  -- 2017년도 법정 이뤌 기부금
                        ,GN_RT_TOTAL_ETC_SUB_18  -- 2018년도 법정 이뤌 기부금
                        
                        ,GN_STOCK_URSM           -- 우리사주조합기부금
                        
                        ,GN_RT_PSA_CUR_APPNT     -- 당해년도 지정(종교단체외) 기부금
                        ,GN_RT_PSA_ETC_APPNT_14  -- 2014년도 지정(종교단체외) 이월 기부금
                        ,GN_RT_PSA_ETC_APPNT_15  -- 2015년도 지정(종교단체외) 이월 기부금
                        ,GN_RT_PSA_ETC_APPNT_16  -- 2016년도 지정(종교단체외) 이월 기부금
                        ,GN_RT_PSA_ETC_APPNT_17  -- 2017년도 지정(종교단체외) 이월 기부금
                        ,GN_RT_PSA_ETC_APPNT_18  -- 2018년도 지정(종교단체외) 이월 기부금
                        
                        ,GN_RT_PSA_CUR_RELGN     -- 2019년도 지정(종교단체) 당월 기부금
                        ,GN_RT_PSA_ETC_RELGN_14  -- 2014년도 지정(종교단체) 이월 기부금
                        ,GN_RT_PSA_ETC_RELGN_15  -- 2015년도 지정(종교단체) 이월 기부금
                        ,GN_RT_PSA_ETC_RELGN_16  -- 2016년도 지정(종교단체) 이월 기부금
                        ,GN_RT_PSA_ETC_RELGN_17  -- 2017년도 지정(종교단체) 이월 기부금
                        ,GN_RT_PSA_ETC_RELGN_18  -- 2018년도 지정(종교단체) 이월 기부금
             FROM PAYM432 A
             WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO;  /*법정(코드:10)*/
        
        

          /**************************************************************************************************************************
            법정기부금
           ***************************************************************************************************************************/
            GV_CALC_RT_DON_LAW      := 0;   --  법정기부금 공제세액 누계액
            GV_CALC_SPCL_DON_LAW    := 0;   --  법정기부금 세액공제 대상기부금 누계액  

            /*************** 법정기부금 (2014년 이월분) **********************/
            --  3000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_TOTAL_ETC_SUB_14), 0); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                 --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;                                                      -- 계산된 기부금 세액공제액 임시 저장

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                             --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP                        --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            --  세액누계
            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                        --  잔여세액에서 차감

            --  3000 만원 초과 25%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_14 - 30000000, 0), GN_RT_TOTAL_ETC_SUB_14); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 25 / 100);                                                          --  세액계산

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ                                                                             --  잔여세액과 비교하여 세액공제 대상액 재계산
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP                        --  공제대상금액 역산하여 누적 공제 기부금과 합산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;                                                          -- 공제세액 누계액에 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                          --  잔여세액에서 차감

            GN_RT_TOTAL_ETC_SUB_14      := N_RE_CALC_TAX_OBJ;                                                                            -- 당해 처리된 공제액 
            
            /*이월금 테이블에서 2019년도 2014년 이월 법정기부금의 처리(GN_RT_TOTAL_ETC_SUB_14 차감처리 로직 필요*/
--            SNU.SF_PAYM432_DON_UPDATE(
--                  IN_BIZR_DEPT_CD               -- 사업자부서코드 
--                , IN_YY                         -- 정산연도
--                , IN_YRETXA_SEQ                 -- 연말정산차수
--                , V_SETT_FG                     -- 정산구분
--                , REC.RPST_PERS_NO              -- 대표개인번호
--                , '2014'                        -- 기부연도
--                , 'A032400001'                  -- 기부유형코드(A0324)
--                , GN_RT_TOTAL_ETC_SUB_14        -- 당년공제금액
--                , 0    -- 소멸금액
--            );
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_14 > 0) THEN
            
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = GN_RT_TOTAL_ETC_SUB_14
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_DESTAMT - CNTRIB_PREAMT - GN_RT_TOTAL_ETC_SUB_14)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2014'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_14 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2014'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            END IF;            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_14;                                                        --  공제대상액 누적
            
            
            

            /*************** 법정기부금 (2015년 이월분) **********************/
            --  3000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_TOTAL_ETC_SUB_15), 0); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                 --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            --  세액누계
            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW + N_RE_CALC_TAX_OBJ;                                            --  공제대상금액 합산
            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                          --  잔여세액에서 차감

            --  3000 만원 초과 25%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_15 - 30000000, 0), GN_RT_TOTAL_ETC_SUB_15); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 25 / 100);                                                          --  세액계산

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ                                                                             --  잔여세액과 비교하여 세액공제 대상액 재계산
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                           --  잔여세액에서 차감

            GN_RT_TOTAL_ETC_SUB_15      := N_RE_CALC_TAX_OBJ;
            
            /*이월금 테이블에서 2019년도 2015년 이월 법정기부금의 처리  GN_RT_TOTAL_ETC_SUB_15 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_15 > 0) THEN
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_TOTAL_ETC_SUB_15
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_DESTAMT - CNTRIB_PREAMT - GN_RT_TOTAL_ETC_SUB_15)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2015'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_15 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2015'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_15;                                                        --  공제대상액 누적


            /*************** 법정기부금 (2016년 이월분) **********************/
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_TOTAL_ETC_SUB_16), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP      --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;                                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_16 - 20000000, 0), GN_RT_TOTAL_ETC_SUB_16);                      --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_TOTAL_ETC_SUB_16               := N_RE_CALC_TAX_OBJ;
            
            /*이월금 테이블에서 2019년도 2016년 이월 법정기부금의 처리 GN_RT_TOTAL_ETC_SUB_16 차감처리 로직 필요*/
            
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_16 > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_TOTAL_ETC_SUB_16
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_DESTAMT - CNTRIB_PREAMT - GN_RT_TOTAL_ETC_SUB_16)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2016'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_16 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2016'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_16;


            /*************** 법정기부금 (2017년 이월분) **********************/
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_TOTAL_ETC_SUB_17), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP      --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;                                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_17 - 20000000, 0), GN_RT_TOTAL_ETC_SUB_17);                      --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_TOTAL_ETC_SUB_17               := N_RE_CALC_TAX_OBJ;


            /*이월금 테이블에서 2019년도 2017년 이월 법정기부금의 처리 GN_RT_TOTAL_ETC_SUB_17 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_17 > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_TOTAL_ETC_SUB_17
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_DESTAMT - CNTRIB_PREAMT - GN_RT_TOTAL_ETC_SUB_17)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2017'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_17 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2017'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            END IF;
            

            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_17;

            /*************** 법정기부금 (2018년 이월분) **********************/
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_TOTAL_ETC_SUB_18), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP      --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;                                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_18 - 20000000, 0), GN_RT_TOTAL_ETC_SUB_18);                      --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액


            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_TOTAL_ETC_SUB_18               := N_RE_CALC_TAX_OBJ;

            /*이월금 테이블에서 2019년도 2018년 이월 법정기부금의 처리 GN_RT_TOTAL_ETC_SUB_18 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_18 > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_TOTAL_ETC_SUB_18
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_DESTAMT - CNTRIB_PREAMT - GN_RT_TOTAL_ETC_SUB_18)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2018'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_ETC_SUB_18 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2018'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            END IF;

            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_TOTAL_ETC_SUB_18;

            /*************** 법정기부금 (당해분) *****************************/
            --  1000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(10000000 - N_CMLTV_GIFT, GN_RT_TOTAL_CUR_SUB), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP      --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;                                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  1000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_TOTAL_CUR_SUB - 10000000, 0), GN_RT_TOTAL_CUR_SUB);                      --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_DON_LAW        := GV_CALC_SPCL_DON_LAW
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_DON_LAW          := GV_CALC_RT_DON_LAW + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_TOTAL_CUR_SUB         := N_RE_CALC_TAX_OBJ;
            
            /*이월금 테이블에서 2019년도 당해년도 법정기부금의 처리 GN_RT_TOTAL_CUR_SUB 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            
            
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_CUR_SUB > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_TOTAL_CUR_SUB
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_TOTAL_CUR_SUB)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_TOTAL_CUR_SUB = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400001';  /*법정(코드:10)*/
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_TOTAL_CUR_SUB;

            /**************************************************************************************************************************
            우리사주조합기부금
           ***************************************************************************************************************************/
            GV_CALC_RT_STOCK_URSM   := 0;   --  우리사주조합기부금 세액공제액
            GV_CALC_SPCL_STOCK_URSM := 0;   --  우리사주조합기부금 세액공제 대상액

            /*************** 우리사주조합기부금 ******************************/
            --  1000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(10000000 - N_CMLTV_GIFT, GN_STOCK_URSM), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP      --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_STOCK_URSM     := GV_CALC_SPCL_STOCK_URSM + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_STOCK_URSM              := GV_CALC_RT_STOCK_URSM + N_CALC_TAX_SUB;                                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  1000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_STOCK_URSM - 10000000, 0), GN_STOCK_URSM);                      --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_STOCK_URSM     := GV_CALC_SPCL_STOCK_URSM
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_STOCK_URSM       := GV_CALC_RT_STOCK_URSM + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_STOCK_URSM               := N_RE_CALC_TAX_OBJ;

            /*이월금 테이블에서 2019년도 당해년도 우리사주 긱부금의 처리 GN_STOCK_URSM 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_STOCK_URSM > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_STOCK_URSM
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_STOCK_URSM)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400008';  /*우리사주 (코드:42)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_STOCK_URSM = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400008';  /*우리사주 (코드:42)*/
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_STOCK_URSM;


            /**************************************************************************************************************************
            종교단체 외 지정기부금
           ***************************************************************************************************************************/
            GV_CALC_RT_PSA          := 0;   --  종교단체외 지정기부금 세액공제액
            GV_CALC_SPCL_PSA        := 0;   --  종교단체외 지정기부금 세액공제 대상액

            /*************** 종교단체외 지정기부금 (2014년) ******************/
--            IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체외 지정기부금 (14년도) : '||GN_RT_PSA_ETC_APPNT_14);
--                DBMS_OUTPUT.PUT_LINE('3000만원 이하                  : '||GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_14), 0));
--                DBMS_OUTPUT.PUT_LINE('3000만원 초과                  : '||LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_14 - 30000000, 0), GN_RT_PSA_ETC_APPNT_14));
--            END IF;

            --  3000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_14), 0); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                 --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            --  세액누계
            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA + N_RE_CALC_TAX_OBJ;                                              --  공제대상금액 합산
            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                          --  잔여세액에서 차감

            --  3000 만원 초과 25%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_14 - 30000000, 0), GN_RT_PSA_ETC_APPNT_14); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 25 / 100);                                                          --  세액계산

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ                                                                             --  잔여세액과 비교하여 세액공제 대상액 재계산
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                           --  잔여세액에서 차감

            GN_RT_PSA_ETC_APPNT_14      := N_RE_CALC_TAX_OBJ;
            
            /*이월금 테이블에서 2014년도 종교단체외 지정기부금의 처리 GN_RT_PSA_ETC_APPNT_14 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_14 > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_APPNT_14
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_APPNT_14)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2014'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_14 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2014'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_14;                                                        --  공제대상액 누적

            /*************** 종교단체외 지정기부금 (2015년) ******************/
--              IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체외 지정기부금 (15년도) : '||GN_RT_PSA_ETC_APPNT_15);
--                DBMS_OUTPUT.PUT_LINE('3000만원 이하                  : '||GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_15), 0));
--                DBMS_OUTPUT.PUT_LINE('3000만원 초과                  : '||LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_15 - 30000000, 0), GN_RT_PSA_ETC_APPNT_15));
--            END IF;
            --  3000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_15), 0); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                 --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            --  세액누계
            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA + N_RE_CALC_TAX_OBJ;                                              --  공제대상금액 합산
            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                          --  잔여세액에서 차감

            --  3000 만원 초과 25%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_15 - 30000000, 0), GN_RT_PSA_ETC_APPNT_15); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 25 / 100);                                                          --  세액계산

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ                                                                             --  잔여세액과 비교하여 세액공제 대상액 재계산
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;

            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                           --  잔여세액에서 차감

            GN_RT_PSA_ETC_APPNT_15      := N_RE_CALC_TAX_OBJ;
            
            /*이월금 테이블에서 2015년도 종교단체외 지정기부금의 처리 GN_RT_PSA_ETC_APPNT_15 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_15 > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_APPNT_15
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_APPNT_15)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2015'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_15 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2015'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
                   
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_15;                                                        --  공제대상액 누적


            /*************** 종교단체외 지정기부금 (2016년) ******************/
--              IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체외 지정기부금 (16년도) : '||GN_RT_PSA_ETC_APPNT_16);
--                DBMS_OUTPUT.PUT_LINE('2000만원 이하                  : '||GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_14), 0));
--                DBMS_OUTPUT.PUT_LINE('2000만원 초과                  : '||LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_16 - 20000000, 0), GN_RT_PSA_ETC_APPNT_16));
--            END IF;

            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_16), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;                                                                 --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_16 - 20000000, 0), GN_RT_PSA_ETC_APPNT_16);    --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_ETC_APPNT_16      := N_RE_CALC_TAX_OBJ;
            /*이월금 테이블에서 2016년도 종교단체외 지정기부금의 처리 GN_RT_PSA_ETC_APPNT_16 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_16 > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_APPNT_16
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_APPNT_16)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2016'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_16 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2016'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_16;

            /*************** 종교단체외 지정기부금 (2017년) ******************/
--        IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체외 지정기부금 (17년도) : '||GN_RT_PSA_ETC_APPNT_16);
--                DBMS_OUTPUT.PUT_LINE('2000만원 이하                  : '||GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_14), 0));
--                DBMS_OUTPUT.PUT_LINE('2000만원 초과                  : '||LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_16 - 20000000, 0), GN_RT_PSA_ETC_APPNT_16));
--            END IF;
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_17), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;                                                                 --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_17 - 20000000, 0), GN_RT_PSA_ETC_APPNT_17);    --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_ETC_APPNT_17      := N_RE_CALC_TAX_OBJ;
            /*이월금 테이블에서 2017년도 종교단체외 지정기부금의 처리 GN_RT_PSA_ETC_APPNT_17 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_17 > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_APPNT_17
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_APPNT_17)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2017'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_17 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2017'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
                   
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_17;

            /*************** 종교단체외 지정기부금 (2018년) ******************/
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_APPNT_18), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;                                                                 --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_18 - 20000000, 0), GN_RT_PSA_ETC_APPNT_18);    --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_ETC_APPNT_18      := N_RE_CALC_TAX_OBJ;
            /*이월금 테이블에서 2018년도 종교단체외 지정기부금의 처리 GN_RT_PSA_ETC_APPNT_18 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_18 > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_APPNT_18
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_APPNT_18)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2018'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_APPNT_18 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2018'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
            
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_APPNT_18;

            /*************** 종교단체외 지정기부금 (당해분) ******************/
            --  1000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(10000000 - N_CMLTV_GIFT, GN_RT_PSA_CUR_APPNT), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;                                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  1000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_CUR_APPNT - 10000000, 0), GN_RT_PSA_CUR_APPNT);          --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA            := GV_CALC_SPCL_PSA
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP          --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA              := GV_CALC_RT_PSA + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_CUR_APPNT         := N_RE_CALC_TAX_OBJ;

            /*이월금 테이블에서 2019년도 당년 종교단체외 지정기부금의 처리 GN_RT_PSA_CUR_APPNT 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_CUR_APPNT > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_CUR_APPNT
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_CUR_APPNT)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/                   
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_CUR_APPNT = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400006';  /*지정 (코드:40)*/
               
            END IF;               
               
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_CUR_APPNT;

            /**************************************************************************************************************************
            종교단체 지정기부금
           ***************************************************************************************************************************/
            GV_CALC_RT_PSA_RELGN        := 0;   --  종교단체 지정기부금 세액공제액
            GV_CALC_SPCL_PSA_RELGN_AMT  := 0;   --  종교단체 지정기부금 세액공제 대상액

            /*************** 종교단체 지정기부금 (2014년) ********************/
--            IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체 지정기부금 (2014) : '||GV_CALC_SPCL_PSA_RELGN_AMT);
--            END IF;
            --  3000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_RELGN_14), 0); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                 --  세액공제액
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;
            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;
            --  세액누계
            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT + N_RE_CALC_TAX_OBJ;                                              --  공제대상금액 합산
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;                                                       --  세액공제액 합산
            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                          --  잔여세액에서 차감

            --  3000 만원 초과 25%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_14 - 30000000, 0), GN_RT_PSA_ETC_RELGN_14); --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 25 / 100);                                                          --  세액계산
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;
            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ                                                                             --  잔여세액과 비교하여 세액공제 대상액 재계산
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;
            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;
            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                           --  잔여세액에서 차감
            GN_RT_PSA_ETC_RELGN_14      := N_RE_CALC_TAX_OBJ;
                        
            /*이월금 테이블에서 2014년도 당년 종교단체 지정기부금의 처리 GN_RT_PSA_ETC_RELGN_14 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_14 > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_RELGN_14
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_RELGN_14)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2014'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/              
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_14 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2014'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/      
               
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_14;                                                        --  공제대상액 누적

            /*************** 종교단체 지정기부금 (2015년) ********************/
--            IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체 지정기부금 (2015) : '||GV_CALC_SPCL_PSA_RELGN_AMT);
--            END IF;
            --  3000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(30000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_RELGN_15), 0); --  세액공제 대상액
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_TAX_SUB_OBJ_TMP : '||N_TAX_SUB_OBJ_TMP);  END IF;
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                 --  세액공제액
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_CALC_TAX_SUB : '||N_CALC_TAX_SUB);  END IF;
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_TAX_SUB_TMP : '||N_TAX_SUB_TMP);  END IF;
            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP   --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_RE_CALC_TAX_OBJ : '||N_RE_CALC_TAX_OBJ);  END IF;
            --  세액누계
            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT + N_RE_CALC_TAX_OBJ;                                              --  공제대상금액 합산
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;                                                       --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                          --  잔여세액에서 차감
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('GV_TAX_REMAIN_AMT : '||GV_TAX_REMAIN_AMT);  END IF;
            --  3000 만원 초과 25%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_15 - 30000000, 0), GN_RT_PSA_ETC_RELGN_15); --  세액공제 대상액
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_TAX_SUB_OBJ_TMP : '||N_TAX_SUB_OBJ_TMP);  END IF;
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 25 / 100);                                                          --  세액계산
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_CALC_TAX_SUB : '||N_CALC_TAX_SUB);  END IF;
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_TAX_SUB_TMP : '||N_TAX_SUB_TMP);  END IF;
            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산
            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ                                                                             --  잔여세액과 비교하여 세액공제 대상액 재계산
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_RE_CALC_TAX_OBJ : '||N_RE_CALC_TAX_OBJ);  END IF;
            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 25 * 100) END;
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('GV_CALC_SPCL_PSA_RELGN_AMT : '||GV_CALC_SPCL_PSA_RELGN_AMT);  END IF;
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                           --  잔여세액에서 차감

            GN_RT_PSA_ETC_RELGN_15      := N_RE_CALC_TAX_OBJ;
            
            /*이월금 테이블에서 2015년도 당년 종교단체 지정기부금의 처리 GN_RT_PSA_ETC_RELGN_15 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_15 > 0) THEN
            
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_RELGN_15
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_RELGN_15)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2015'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/  
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_15 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2015'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/   
                   
            END IF;
            
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_15;                                                        --  공제대상액 누적
--            IF A_DEBUG = 'Y' THEN DBMS_OUTPUT.PUT_LINE('N_CMLTV_GIFT : '||N_CMLTV_GIFT);  END IF;
            /*************** 종교단체 지정기부금 (2016년) ********************/
--            IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체 지정기부금 (2016) : '||GV_CALC_SPCL_PSA_RELGN_AMT);
--            END IF;
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_RELGN_16), 0);                             --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;                                                           --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_16 - 20000000, 0), GN_RT_PSA_ETC_RELGN_16);    --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액
            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_ETC_RELGN_16      := N_RE_CALC_TAX_OBJ;
            
            
            /*이월금 테이블에서 2016년도 당년 종교단체 지정기부금의 처리 GN_RT_PSA_ETC_RELGN_16 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_16 > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_RELGN_16
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_RELGN_16)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2016'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/  
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_16 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2016'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/   
                   
            END IF;

            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_16;


            /*************** 종교단체 지정기부금 (2017년) ********************/
--            IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체 지정기부금 (2017) : '||GV_CALC_SPCL_PSA_RELGN_AMT);
--            END IF;
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_RELGN_17), 0);                             --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;                                                           --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_17 - 20000000, 0), GN_RT_PSA_ETC_RELGN_17);    --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_ETC_RELGN_17      := N_RE_CALC_TAX_OBJ;
            
            
            /*이월금 테이블에서 2017년도 당년 종교단체 지정기부금의 처리 GN_RT_PSA_ETC_RELGN_17 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_17 > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_RELGN_17
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_RELGN_17)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2017'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/  
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_17 = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2017'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/   
                   
            END IF;

            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_17;

            /*************** 종교단체 지정기부금 (2018년) ********************/
            --  2000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(20000000 - N_CMLTV_GIFT, GN_RT_PSA_ETC_RELGN_18), 0);                             --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;                                                           --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  2000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_18 - 20000000, 0), GN_RT_PSA_ETC_RELGN_18);    --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);       --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT
                                            + CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_ETC_RELGN_18      := N_RE_CALC_TAX_OBJ;


            /*이월금 테이블에서 2018년도 당년 종교단체 지정기부금의 처리 GN_RT_PSA_ETC_RELGN_18 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_18 > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_ETC_RELGN_18
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_ETC_RELGN_18)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2018'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/  
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_ETC_RELGN_18= 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2018'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/   
                   
            END IF;       
               
            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_ETC_RELGN_18;

            /*************** 종교단체 지정기부금 (당해분) ********************/
--            IF A_DEBUG = 'Y' THEN
--                DBMS_OUTPUT.PUT_LINE('----종교단체 지정기부금-----');
--                DBMS_OUTPUT.PUT_LINE('누적금액                       : '||N_CMLTV_GIFT);
--                DBMS_OUTPUT.PUT_LINE('종교단체 지정기부금 (당해) : '||GV_CALC_SPCL_PSA_RELGN_AMT);
--            END IF;
            --  1000 만원 이하 15%
            N_TAX_SUB_OBJ_TMP           := GREATEST(LEAST(10000000 - N_CMLTV_GIFT, GN_RT_PSA_CUR_RELGN), 0);                                --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 15 / 100);                                                             --  세액공제액

            N_TAX_SUB_TMP               := N_CALC_TAX_SUB;

            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := CASE WHEN GV_TAX_REMAIN_AMT >= N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP       --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                ELSE CEIL(N_CALC_TAX_SUB / 15 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT + N_RE_CALC_TAX_OBJ;                                                  --  공제대상금액 합산
            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;                                                           --  세액공제액 합산

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감

            --  1000 만원 초과 30%
            N_TAX_SUB_OBJ_TMP           := LEAST(GREATEST(N_CMLTV_GIFT + GN_RT_PSA_CUR_RELGN - 10000000, 0), GN_RT_PSA_CUR_RELGN);    --  세액공제 대상액
            N_CALC_TAX_SUB              := FLOOR(N_TAX_SUB_OBJ_TMP * 30 / 100);                                                             --  세액공제액
                        N_TAX_SUB_TMP               := N_CALC_TAX_SUB;
            N_CALC_TAX_SUB              := LEAST(GV_TAX_REMAIN_AMT, N_TAX_SUB_TMP);                                                      --  잔여세액과 비교하여 세액공제액 재계산

            N_RE_CALC_TAX_OBJ           := N_RE_CALC_TAX_OBJ
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  잔여세액과 비교하여 세액공제 대상액 재계산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;

            GV_CALC_SPCL_PSA_RELGN_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT
                                            + CASE WHEN GV_TAX_REMAIN_AMT >=  N_TAX_SUB_TMP THEN N_TAX_SUB_OBJ_TMP    --  공제대상금액 역산
                                                   ELSE CEIL(N_CALC_TAX_SUB / 30 * 100) END;                                                --  세액누계

            GV_CALC_RT_PSA_RELGN        := GV_CALC_RT_PSA_RELGN + N_CALC_TAX_SUB;

            GV_TAX_REMAIN_AMT           := GV_TAX_REMAIN_AMT - N_CALC_TAX_SUB;                                                              --  잔여세액에서 차감
            GN_RT_PSA_CUR_RELGN         := N_RE_CALC_TAX_OBJ;

            /*이월금 테이블에서 2019년도 종교단체 지정기부금의 처리 GN_RT_PSA_CUR_RELGN 차감처리 로직 필요*/
            
            /* 잔여세액이 0이 아니거나, 잔여세액이 0이고 계산된세액이 0보다 크면 세금 차감*/
            V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;    -- 잔여 결정 세액을 기존 변수에 넣어줌
            IF V_CAL_TDUC_TEMP_AMT <> 0 OR (V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_CUR_RELGN > 0) THEN
                
                UPDATE PAYM432
                   SET CNTRIB_GONGAMT = GN_RT_PSA_CUR_RELGN
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_GIAMT - CNTRIB_PREAMT - GN_RT_PSA_CUR_RELGN)
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/  
            ELSIF  V_CAL_TDUC_TEMP_AMT = 0 AND GN_RT_PSA_CUR_RELGN = 0 THEN
                UPDATE PAYM432
                  SET CNTRIB_GONGAMT = 0
                     , CNTRIB_DESTAMT = CNTRIB_DESTAMT
                     , CNTRIB_OVERAMT = (CNTRIB_OVERAMT + CNTRIB_GONGAMT)                 
                 WHERE YY             = IN_YY
                   AND YRETXA_SEQ     = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND CNTRIB_YY      = '2019'
                   AND SETT_FG        = V_SETT_FG
                   AND BIZR_DEPT_CD   = IN_BIZR_DEPT_CD
                   AND RPST_PERS_NO   = REC.RPST_PERS_NO
                   AND CNTRIB_TYPE_CD = 'A032400007';  /*지정 (코드:41)*/   
            
            END IF;

            N_CMLTV_GIFT                := N_CMLTV_GIFT + GN_RT_PSA_CUR_RELGN;
          


        /* 세액공제 계 = 지금까지 계산된 세액고제액 + 법정기부금 + 지정기부금(종교단체 외) + 지정기부금(종교단체)*/
       END IF;      
       
       
        V_FLAW_CNTRIB_DUC_OBJ_AMT :=  GV_CALC_SPCL_DON_LAW;     --법정기부공제대상금액
        V_FLAW_CNTRIB_TAXDUC_AMT  :=  GV_CALC_RT_DON_LAW;      --법정기부세액공제액
        V_APNT_CNTRIB_DUC_OBJ_AMT :=  GV_CALC_SPCL_PSA + GV_CALC_SPCL_PSA_RELGN_AMT;     --지정기부공제대상금액
        V_APNT_CNTRIB_TAXDUC_AMT  :=  GV_CALC_RT_PSA + GV_CALC_RT_PSA_RELGN;       --지정기부세액공제액
         

        V_APNT_CNTRIB40_DUC_OBJ_AMT  := GV_CALC_SPCL_PSA;    --지정기부(종교외) 세액공제대상금액 @VER.2016_8
        V_APNT_CNTRIB40_TAXDUC_AMT   := GV_CALC_RT_PSA;   --지정기부(종교외) 세액공제금액 @VER.2016_8
        V_APNT_CNTRIB41_DUC_OBJ_AMT  := GV_CALC_SPCL_PSA_RELGN_AMT;    --지정기부(종교) 세액공제대상금액 @VER.2016_8
        V_APNT_CNTRIB41_TAXDUC_AMT   := GV_CALC_RT_PSA_RELGN;   --지정기부(종교) 세액공제금액 @VER.2016_8; 
            
            
        V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_FLAW_CNTRIB_TAXDUC_AMT + V_APNT_CNTRIB40_TAXDUC_AMT + V_APNT_CNTRIB41_TAXDUC_AMT;
        
        
        V_CAL_TDUC_TEMP_AMT := GV_TAX_REMAIN_AMT;
        
        
        V_STAD_TAXDUC_OBJ_AMT := V_STAD_TAXDUC_OBJ_AMT + V_FLAW_CNTRIB_DUC_OBJ_AMT + V_APNT_CNTRIB_DUC_OBJ_AMT;  /**표준세액공제 대상 금액***/

        /** 표준세액공제 (2014재계산) 12만원 => 13만원**/
        IF V_STAD_TAXDUC_OBJ_AMT <= 0 AND V_TDUC_DUC_TT_AMT > 0 THEN
            V_STAD_TAXDUC_AMT := 130000;
                -- 산출세액 차감
            SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_STAD_TAXDUC_AMT,1),
                   SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_STAD_TAXDUC_AMT,2)
            INTO V_CAL_TDUC_TEMP_AMT, V_STAD_TAXDUC_AMT
            FROM DUAL;

            -- 세액공제 계
            V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_STAD_TAXDUC_AMT;


        END IF;

            V_TMP_AMT := 0;         
                 
/** 2019년도 법정, 우리사주, 지정 기부금 세액계산 end **/                                  
                 
                 

/* 주택차입금 이자상환세액공제(미분양 주택취득관련 )                */
                IF V_CAL_TDUC_TEMP_AMT > 0 THEN

                    V_UN_MINT_HOUS_ITT_RFND_AMT := REC.UN_MINT_QTY_HOUS_ITT_RFND_AMT;
                    IF V_UN_MINT_HOUS_ITT_RFND_AMT > 0 THEN
                        V_UN_MINT_HOUS_ITT_RFND_AMT := TRUNC(V_UN_MINT_HOUS_ITT_RFND_AMT * 30 / 100); -- 불입분의 30% 공제

                        -- 산출세액 차감
                        SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT,V_UN_MINT_HOUS_ITT_RFND_AMT,1),
                               SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT,V_UN_MINT_HOUS_ITT_RFND_AMT,2)
                          INTO V_CAL_TDUC_TEMP_AMT, V_UN_MINT_HOUS_ITT_RFND_AMT
                          FROM DUAL;

                        -- 세액공제 계
                        V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_UN_MINT_HOUS_ITT_RFND_AMT;


                        V_DETM_FMTAX_AMT := V_DETM_FMTAX_AMT + TRUNC(V_UN_MINT_HOUS_ITT_RFND_AMT * 20 / 100); -- 공제대상의 20% 농어촌특별세
                    END IF;

                END IF;
/** 외국납부 세액공제 **/


                --DBMS_OUTPUT.PUT_LINE('S18 = '||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );
-- 농어촌특별세를 계산한다.
-- @VER.2015 농어촌특별세개정(15.12.15)에따라장기집합투자증권저축[V_INVST_SEC_SAV_AMT]의경우, 농어촌특별세를부과하지아니함.
--           V_LFSTS_ITT_RFND_AMT[목돈안드는전세이자상환액] 항목 추가.(2015년 주성희 한명존재)
--            IF (V_ICOMP_FINC_DUC_AMT > 0) OR (V_INVST_SEC_SAV_AMT> 0) THEN
              IF (V_ICOMP_FINC_DUC_AMT > 0) OR (V_LFSTS_ITT_RFND_AMT >0 )THEN
                    IF V_GNR_EARN_TAX_STAD_AMT_2 > 0 THEN
                        -- 반영 전 산출세액
                        BEGIN
                            SELECT NVL(BASI_AMT_1,0), NVL(BASI_AMT_2,0), NVL(TRATE,0)
                              INTO V_BASI_AMT_1,      V_BASI_AMT_2 ,     V_TRATE
                              FROM PAYM450
                             WHERE CAL_FG   =  'A034500002'
                               AND YY       =  IN_YY
                               AND V_GNR_EARN_TAX_STAD_AMT_2 > ADPT_LOW_AMT
                               AND V_GNR_EARN_TAX_STAD_AMT_2 <= ADPT_UPP_AMT;
                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_BASI_AMT_1 := 0;
                                V_BASI_AMT_2 := 0;
                                V_TRATE := 0;
                        END;
                        --투자조합출자공제 전 산출세액
                        V_CAL_TDUC1 := NVL(V_BASI_AMT_1,0) + TRUNC((NVL(V_GNR_EARN_TAX_STAD_AMT_2,0) - NVL(V_BASI_AMT_2,0)) * NVL(V_TRATE,0) * 0.01);
                        --V_CAL_TDUC1 := V_GNR_EARN_TAX_STAD_AMT_2;
                    END IF;

                    IF V_GNR_EARN_TAX_STAD_AMT_3 > 0 THEN
                        -- 반영 후 산출세액
                        BEGIN
                            SELECT NVL(BASI_AMT_1,0), NVL(BASI_AMT_2,0), NVL(TRATE,0)
                              INTO V_BASI_AMT_1,      V_BASI_AMT_2 ,     V_TRATE
                              FROM PAYM450
                             WHERE CAL_FG   =  'A034500002'
                               AND YY       =  IN_YY
                               AND V_GNR_EARN_TAX_STAD_AMT_3 > ADPT_LOW_AMT
                               AND V_GNR_EARN_TAX_STAD_AMT_3 <= ADPT_UPP_AMT;
                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_BASI_AMT_1 := 0;
                                V_BASI_AMT_2 := 0;
                                V_TRATE := 0;
                        END;
                        --투자조합출자공제 후  산출세액
                        V_CAL_TDUC2 := NVL(V_BASI_AMT_1,0) + TRUNC((NVL(V_GNR_EARN_TAX_STAD_AMT_3,0) - NVL(V_BASI_AMT_2,0)) * NVL(V_TRATE,0) * 0.01);

                       -- V_DETM_FMTAX_AMT := TRUNC((GREATEST(V_CAL_TDUC1 - V_CAL_TDUC2,0) + V_UN_MINT_HOUS_ITT_RFND_AMT) * 20 / 100);
                      /* @VER.2015 2016.1.28 V_UN_MINT_HOUS_ITT_RFND_AMT 금액은 위에서 이미 처리됨. */
                      /* @VER.2016_7 농특세에서 투자조합출자 소득공제 제외됨. [주석처리]*/
                       -- V_DETM_FMTAX_AMT := V_DETM_FMTAX_AMT + TRUNC((GREATEST(V_CAL_TDUC1 - V_CAL_TDUC2,0)) * 20 / 100);


                    END IF;
                END IF;


/** 월세액 세액공제 **/
            BEGIN
                --71.특별공제월세액공제금액
                -- 월세 => 세대주=Y(OR 세대주=N,중복공제아님=Y,본인차입=Y), 주택수=0, 국민주택규모이하(V_HOUS_SCALE_YN)=Y, 기준시가 3억이하(BASI_MPRC_BLW)=체크안함, 등기접수일 3개월 이내(HOUS_SEC_YN)=체크안함
                IF V_MM_TAX_AMT > 0
                   AND (V_HOUSEHOLDER_YN = 'Y'     -- 세대주이거나
                        OR (V_HOUSEHOLDER_YN = 'N' AND V_HOUSEHOLDER_DUPL_DUC_YN = 'Y')) --세대원인경우 중복공제하지않고 본인임차차입금인경우
                   AND V_SLF_MNRT_PAY_YN = 'Y'
                   AND V_HOUS_OWN_CNT = 0
                   AND V_LESE_HOUS_SCALE_BLW_YN = 'Y'
                THEN
                   IF V_LABOR_EARN_TT_SALY_AMT  >  70000000 THEN    -- 총급여 7천만원  이하
                       V_MM_TAX_AMT := 0;
                        V_MNRT_TAXDUC_AMT := 0;
                   ELSE
                        IF V_LABOR_EARN_TT_SALY_AMT > 55000000 THEN      -- 19.1.16. 안혜수수정 (한도변경) @VER.2019_1
                         V_MNRT_TAXDUC_AMT := TRUNC(V_MM_TAX_AMT  * 0.1);

                          IF TRUNC(V_MM_TAX_AMT  * 0.1) > 750000 THEN
                              V_MM_TAX_AMT      := 7500000;
                              V_MNRT_TAXDUC_AMT := 750000;
                            END IF;
                        ELSE
                           V_MNRT_TAXDUC_AMT := TRUNC(V_MM_TAX_AMT  * 0.12);
                           IF TRUNC(V_MM_TAX_AMT  * 0.12) > 900000 THEN

                             V_MM_TAX_AMT      := 7500000;
                             V_MNRT_TAXDUC_AMT := 900000;
                            END IF;


                        END IF;

                    -- IF V_LABOR_EARN_TT_SALY_AMT  >  70000000 THEN    -- 총급여 7천만원  이하
                    --    V_MM_TAX_AMT := 0;
                    --   V_MNRT_TAXDUC_AMT := 0;
                    -- ELSE
                      --  IF TRUNC(V_MM_TAX_AMT  * 0.1) > 750000 THEN
                          --  V_MM_TAX_AMT      := 7500000;
                         --   V_MNRT_TAXDUC_AMT := 750000; --2014. 월세세액공제 10% 최대 75만원
                      --  ELSE
                     --       /* (@VER.2018_8)
                         --      - 총급여 5.5천만원 이하 : 12%(종합소득금액 4천만원 초과자 제외)
                         --      - 그 외 근로자 : 10% */
                       --     IF V_LABOR_EARN_TT_SALY_AMT > 55000000 THEN  -- 총급여 5.5천만원 이하 12%(종합소득금액 4천만원 초과자 제외)
                         --       V_MNRT_TAXDUC_AMT := TRUNC(V_MM_TAX_AMT  * 0.1);
                        --    ELSE
                         --       V_MNRT_TAXDUC_AMT := TRUNC(V_MM_TAX_AMT  * 0.12); --2014. 월세세액공제 10% 최대 75만원
                          --      V_MNRT_TAXDUC_AMT :=900000;
                         --   END IF;
                     --  END IF;
                    END IF;
                ELSE
                    V_MM_TAX_AMT := 0;
                    V_MNRT_TAXDUC_AMT := 0;
                END IF;

/* @@ZODEM */
/*V_OCCR_LOC_NM   := '(70)월세 세액공제 체크';
V_DB_ERROR_CTNT := 'V_MM_TAX_AMT  :'||V_MM_TAX_AMT||chr(13)||chr(10)||
                   'V_HOUSEHOLDER_YN  세대주:'||V_HOUSEHOLDER_YN||chr(13)||chr(10)||
                   'V_HOUSEHOLDER_DUPL_DUC_YN  세대원중복여부:'||V_HOUSEHOLDER_DUPL_DUC_YN||chr(13)||chr(10)||
                   'V_SLF_MNRT_PAY_YN  본인지급여부:'||V_SLF_MNRT_PAY_YN||chr(13)||chr(10)||
                   'V_HOUS_OWN_CNT  주택수:'||V_HOUS_OWN_CNT||chr(13)||chr(10)||
                   'V_LESE_HOUS_SCALE_BLW_YN  국민주택규모:'||V_HOUS_OWN_CNT||chr(13)||chr(10)||
                   'V_LABOR_EARN_TT_SALY_AMT  총급여:'||V_LABOR_EARN_TT_SALY_AMT||chr(13)||chr(10)||
                   'V_MNRT_TAXDUC_AMT  계산된 월세공제액:'||V_MNRT_TAXDUC_AMT||chr(13)||chr(10)
                   ;
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP ); */

                -- 차감전 세액
                V_TMP_BF_CALC_TAXAMT := V_MNRT_TAXDUC_AMT;   /******/

                -- 산출세액 차감
                SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT,V_MNRT_TAXDUC_AMT,1),
                       SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT,V_MNRT_TAXDUC_AMT,2)
                  INTO V_CAL_TDUC_TEMP_AMT, V_MNRT_TAXDUC_AMT
                  FROM DUAL;

                /********/
                IF V_TMP_BF_CALC_TAXAMT <> V_MNRT_TAXDUC_AMT THEN
                    IF V_TMP_BF_CALC_TAXAMT > 0 THEN
                        V_MM_TAX_AMT := TRUNC((V_MM_TAX_AMT * V_MNRT_TAXDUC_AMT) / V_TMP_BF_CALC_TAXAMT);
                    ELSE
                        V_MM_TAX_AMT := 0;
                    END IF;
                END IF;

                -- 세액공제 계
                V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_MNRT_TAXDUC_AMT;


            END;



            -- 2015 연말정산 - 연금계좌세액공제는 맨 마지막에 수행하도록 변경 - @VER.2015
            /**연금계좌 세액공제(과학기술인, 근로자퇴직급여, 연금저축 연 납입금액(400만원한도) * 12% (2014재계산): 총급여액 5500만원 이하는 15% **/
            /* 2015년 연금계좌 세액공제 한도와는 별도로 퇴직연금에 납입하는 금액은 연300만원 한도 추가.(=>퇴직연금 납입액이 있을 경우 한도 연700만원)*/
            /* @VER.2017_4 2017년 연금저축계좌 공제한도 변경: 400만원한도(단, 총급여액 1억2천만원 또는 종합소득금액 1억원 초과자는 300만원)*/
            BEGIN

                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면

                    --57. 과학기술인공제 공제액 (과학기술인공제회법에 따른 퇴직연금 근로자 납입액) : 2015년 퇴직연금계좌 한도 700만원
                    V_SCI_TECH_RETI_PESN_AMT := REC.SCI_TECH_RETI_PESN_AMT;

                    IF V_SCI_TECH_RETI_PESN_AMT > 7000000 THEN    -- 700만원 한도..
                        V_SCI_DUC_OBJ_AMT := 7000000;             -- 700만원이 넘으면 공제액 700만원
                    ELSE
                        V_SCI_DUC_OBJ_AMT := V_SCI_TECH_RETI_PESN_AMT;  --700만원이 넘지않으면 공제액은 납부액
                    END IF;

                    IF V_LABOR_EARN_TT_SALY_AMT <= 55000000 THEN
                       V_SCI_TAXDUC_AMT := TRUNC(V_SCI_DUC_OBJ_AMT * 0.15);  --과학기술인공제회 세액 공제액 (2014재계산): 총급여액 5500만원 이하는 15%
                    ELSE
                       V_SCI_TAXDUC_AMT := TRUNC(V_SCI_DUC_OBJ_AMT * 0.12);  --과학기술인공제회 세액 공제액
                    END IF;

                    -- 산출세액 차감
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_SCI_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_SCI_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_SCI_TAXDUC_AMT
                    FROM DUAL;

                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_SCI_TAXDUC_AMT;

                END IF;

                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면

                    --58. 퇴직연금소득공제_근로자퇴직급여보장법 : 2015년 퇴직연금계좌 한도 700만원

                    V_RETI_PESN_AMT := REC.RETI_PESN_AMT; --현 퇴직연금
                    V_RETI_PESN_DUC_AMT := V_RETI_PESN_AMT; --퇴직연금 합산

                     /* @VER.2015
                        2015년 연금계좌 세액공제 한도와는 별도로 퇴직연금에 납입하는 금액은 연300만원 한도 추가 .(=>퇴직연금 납입액이 있을 경우 한도 연700만원)*/
                    IF V_RETI_PESN_DUC_AMT + V_SCI_DUC_OBJ_AMT > 7000000 THEN
                       V_RETI_PENS_DUC_OBJ_AMT := 7000000 - V_SCI_DUC_OBJ_AMT;
                    ELSE
                       V_RETI_PENS_DUC_OBJ_AMT := V_RETI_PESN_DUC_AMT;
                    END IF;

                    /* 2014년 버전
                    IF V_SCI_DUC_OBJ_AMT < 4000000 THEN --과학기술인공제회 공제대상금액이 400만원이 아니면
                      IF V_RETI_PESN_DUC_AMT + V_SCI_DUC_OBJ_AMT > 4000000 THEN    -- 퇴직연금이 과학기술인공제회와 합하여 400만원 한도..
                          V_RETI_PENS_DUC_OBJ_AMT := 4000000 - V_SCI_DUC_OBJ_AMT;
                      ELSE
                          V_RETI_PENS_DUC_OBJ_AMT := V_RETI_PESN_DUC_AMT;
                      END IF;
                    ELSE
                      V_RETI_PENS_DUC_OBJ_AMT := 0;
                    END IF;*/


                    IF V_LABOR_EARN_TT_SALY_AMT <= 55000000 THEN
                       V_RETI_PENS_TAXDUC_AMT := TRUNC(V_RETI_PENS_DUC_OBJ_AMT * 0.15); -- 퇴직연금 세액 공제액 (2014재계산): 총급여액 5500만원 이하는 15%
                    ELSE
                       V_RETI_PENS_TAXDUC_AMT := TRUNC(V_RETI_PENS_DUC_OBJ_AMT * 0.12); -- 퇴직연금 세액 공제액
                    END IF;

                    -- 산출세액 차감
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_RETI_PENS_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_RETI_PENS_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_RETI_PENS_TAXDUC_AMT
                    FROM DUAL;

                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_RETI_PENS_TAXDUC_AMT;
                END IF;

                -- 퇴직연금공제합산(과학기술인공제+근로자퇴직급여보장법)
                 V_RETI_PESN_EARN_DUC_AMT := V_SCI_DUC_OBJ_AMT + V_RETI_PENS_DUC_OBJ_AMT;


                IF V_CAL_TDUC_TEMP_AMT > 0 THEN  -- 산출세액 잔액이 0이상이면

                    --연금저축공제(400만원한도)  -- 그밖의 공제에서 이동
                    V_PESN_SAV_DUC_AMT := REC.PNSV;
                    IF V_PESN_SAV_DUC_AMT > 0 THEN
                        IF V_RETI_PESN_EARN_DUC_AMT > 7000000 THEN
                             V_PNSV_DUC_OBJ_AMT := 0; --퇴직연금공제합산 금액이 700만원을 초과시 연금저축공재액은 0원이다.
                        ELSE
                            /* @VER.2017_4 2017년 연금저축계좌 공제한도 변경: 400만원한도(단, 총급여액 1억2천만원 또는 종합소득금액 1억원 초과자는 300만원)*/
                           IF V_LABOR_EARN_TT_SALY_AMT > 120000000 THEN --OR V_LABOR_EARN_AMT > 100000000 THEN /* 종합소득금액 <> 근로소득금액 2018.01.15*/
                              IF V_PESN_SAV_DUC_AMT > 3000000 THEN
                                 V_PNSV_DUC_OBJ_AMT := 3000000; -- 300만원한도(총급여액 1억2천만원 또는 종합소득금액 1억원 초과자)
                              ELSE
                                 V_PNSV_DUC_OBJ_AMT := V_PESN_SAV_DUC_AMT;
                              END IF;
                           ELSE
                              IF V_PESN_SAV_DUC_AMT > 4000000 THEN
                                 V_PNSV_DUC_OBJ_AMT := 4000000; -- 400만원한도 (연금저축공제 자체는 400만원이 한도이다.)
                              ELSE
                                 V_PNSV_DUC_OBJ_AMT := V_PESN_SAV_DUC_AMT;
                              END IF;
                           END IF;
                        END IF;
                    END IF;

                    IF V_PNSV_DUC_OBJ_AMT + V_RETI_PESN_EARN_DUC_AMT > 7000000 THEN
                       V_PNSV_DUC_OBJ_AMT := 7000000 - V_RETI_PESN_EARN_DUC_AMT; -- 700만원한도 (퇴직연금 납입액, 연금저축 둘다 존재 하는 경우 )
                    END IF;

                    IF V_LABOR_EARN_TT_SALY_AMT <= 55000000 THEN
                       V_PNSV_TAXDUC_AMT := TRUNC(V_PNSV_DUC_OBJ_AMT * 0.15);  -- (2014재계산): 총급여액 5500만원 이하는 15%
                    ELSE
                       V_PNSV_TAXDUC_AMT := TRUNC(V_PNSV_DUC_OBJ_AMT * 0.12);
                    END IF;

                    -- 산출세액 차감
                    SELECT SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_PNSV_TAXDUC_AMT,1),
                           SF_SETT_CHAGAM_CAL(V_CAL_TDUC_TEMP_AMT, V_PNSV_TAXDUC_AMT,2)
                    INTO V_CAL_TDUC_TEMP_AMT, V_PNSV_TAXDUC_AMT
                    FROM DUAL;

                    -- 세액공제 계
                    V_TDUC_DUC_TT_AMT := V_TDUC_DUC_TT_AMT + V_PNSV_TAXDUC_AMT;
                END IF;
            END;



                /**결정세액은 소숫점 절사만 처리하고 차감징수에서 원단위 절사처리한다.**/
                -- 결정소득세 (산출세액 - 세액감면 - 세액공제)
                --V_DETM_INCOME_TAX := TRUNC(V_CAL_TDUC - V_TDUC_DUC_TT_AMT,-1);
                V_DETM_INCOME_TAX := TRUNC(V_CAL_TDUC - V_REDC_TAX_TT- V_TDUC_DUC_TT_AMT); --결정소득세는 원단위 절사하지 않음

--                DBMS_OUTPUT.PUT_LINE('V_CAL_TDUC = '||TO_CHAR(V_CAL_TDUC) );
--                DBMS_OUTPUT.PUT_LINE('V_REDC_TAX_TT = '||TO_CHAR(V_REDC_TAX_TT) );
--                DBMS_OUTPUT.PUT_LINE('V_TDUC_DUC_TT_AMT = '||TO_CHAR(V_TDUC_DUC_TT_AMT) );
--                DBMS_OUTPUT.PUT_LINE('V_DETM_INCOME_TAX = '||TO_CHAR(V_DETM_INCOME_TAX) );

                IF V_DETM_INCOME_TAX < 0 THEN
                    V_DETM_INCOME_TAX := 0 ;
                END IF;


/** 외국인 단일세율적용  ****/

            ELSE --외국인 단일세율적용
               --현근무지 4대보험료(국민연금+건강보험+고용보험+공무원연금+사학연금) 회사부담금 계산 -> 2014년부터 국민연금, 공무원연금, 사학연금 회사부담금은 제외
               --현근무지 식대, 자가운전보조금 계산
               BEGIN
                   SELECT NVL(SUM(HINS_AMT),0) + NVL(SUM(EINS_AMT),0) /*+ NVL(SUM(PUBPERS_PENS),0) + NVL(SUM(PSCH_PENS),0) 2014년 제외 */
                       --, NVL(SUM(FOOD_AMT),0) + NVL(SUM(OIL_AMT),0) /* @VER.2017_19 V_ETC_AMT_TAX 변수로 대체함 */
                     INTO V_CURR_SITE_INSUR_AMT
                       -- , V_CURR_SITE_FO_NOTAX_AMT
                     FROM PAYM440
                    WHERE BIZR_DEPT_CD = REC.BIZR_DEPT_CD
                      AND YY           = IN_YY
                      AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                      AND SETT_FG      = V_SETT_FG
                      AND RPST_PERS_NO = REC.RPST_PERS_NO;

                   EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        V_CURR_SITE_INSUR_AMT := 0;
                        V_CURR_SITE_FO_NOTAX_AMT := 0;
                END;

               --전근무지 4대보험료(국민연금+건강보험+장기요양보험+고용보험+공무원연금+사학연금) 회사부담금 계산
               --전근무지 식대, 자가운전보조금 계산
               BEGIN
                   SELECT NVL(SUM(HINS_AMT),0) + NVL(SUM(LNTM_RECU_INSU_AMT),0)+ NVL(SUM(EINS_AMT),0) /*+ NVL(SUM(PUBPERS_PENS),0)*/
                        , NVL(SUM(FOOD_AMT),0) + NVL(SUM(OIL_AMT),0)
                     INTO V_BF_SITE_INSUR_AMT
                        , V_BF_SITE_FO_NOTAX_AMT
                     FROM PAYM430
                    WHERE BIZR_DEPT_CD = REC.BIZR_DEPT_CD
                      AND YY           = IN_YY
                      AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                      AND SETT_FG      = V_SETT_FG
                      AND RPST_PERS_NO = REC.RPST_PERS_NO;


                   EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        V_BF_SITE_INSUR_AMT := 0;
                        V_BF_SITE_FO_NOTAX_AMT := 0;
                END;


              IF IN_YY = '2019' AND IN_BIZR_DEPT_CD = '00000' AND IN_YRETXA_SEQ = '1' AND IN_SETT_FG = 'A031300001' AND REC.RPST_PERS_NO = 'A072436' THEN   -- 신명진 예외 처리 . 종근무지 직무발명보상금 추가
                    V_LABOR_EARN_TT_SALY_AMT :=  V_LABOR_EARN_TT_SALY_AMT      /* 과세급여 */
                                              + V_CURR_SITE_AMT_TAX_SETT_AMT /* 현근무지 지급명세 작성 대상  비과세 (출산보육수당,연구지원비,직무발명보상금등,야간근로수당 비과세))*/
                                              + V_ETC_AMT_TAX                /* 현근무지 지급명세서 작성 비대상 비과세 (식대,유류비,일직료 등) @VER.2017_19 V_CURR_SITE_FO_NOTAX_AMT =>V_ETC_AMT_TAX 로 변경*/
                                              + V_CURR_SITE_INSUR_AMT        /* 현근무지 건강보험,고용보험료 회사부담금 */
                                              + V_BF_SITE_DELAY_NOTAX_AMT_1  /* 이하 전근무지 비과세 */
                                              + V_BF_SITE_CARE_NOTAX_AMT_1
                                              + V_BF_SITE_RECH_NOTAX_AMT_1
                                              + V_BF_SITE_ETC_NOTAX_AMT_1
                                              + V_BF_SITE_APNT_NOTAX_AMT_1
                                              + V_BF_SITE_TRAING_ASSI_ALLOW_1
                                              + V_BF_SITE_DELAY_NOTAX_AMT_2
                                              + V_BF_SITE_CARE_NOTAX_AMT_2
                                              + V_BF_SITE_RECH_NOTAX_AMT_2
                                              + V_BF_SITE_ETC_NOTAX_AMT_2
                                              + V_BF_SITE_APNT_NOTAX_AMT_2
                                              + V_BF_SITE_TRAING_ASSI_ALLOW_2
                                              + V_BF_SITE_INSUR_AMT
                                              + V_BF_SITE_FO_NOTAX_AMT
                                              + 970745;
              ELSE
                V_LABOR_EARN_TT_SALY_AMT :=  V_LABOR_EARN_TT_SALY_AMT      /* 과세급여 */
                                          + V_CURR_SITE_AMT_TAX_SETT_AMT /* 현근무지 지급명세 작성 대상  비과세 (출산보육수당,연구지원비,직무발명보상금등,야간근로수당 비과세))*/
                                          + V_ETC_AMT_TAX                /* 현근무지 지급명세서 작성 비대상 비과세 (식대,유류비,일직료 등) @VER.2017_19 V_CURR_SITE_FO_NOTAX_AMT =>V_ETC_AMT_TAX 로 변경*/
                                          + V_CURR_SITE_INSUR_AMT        /* 현근무지 건강보험,고용보험료 회사부담금 */
                                          + V_BF_SITE_DELAY_NOTAX_AMT_1  /* 이하 전근무지 비과세 */
                                          + V_BF_SITE_CARE_NOTAX_AMT_1
                                          + V_BF_SITE_RECH_NOTAX_AMT_1
                                          + V_BF_SITE_ETC_NOTAX_AMT_1
                                          + V_BF_SITE_APNT_NOTAX_AMT_1
                                          + V_BF_SITE_TRAING_ASSI_ALLOW_1
                                          + V_BF_SITE_DELAY_NOTAX_AMT_2
                                          + V_BF_SITE_CARE_NOTAX_AMT_2
                                          + V_BF_SITE_RECH_NOTAX_AMT_2
                                          + V_BF_SITE_ETC_NOTAX_AMT_2
                                          + V_BF_SITE_APNT_NOTAX_AMT_2
                                          + V_BF_SITE_TRAING_ASSI_ALLOW_2
                                          + V_BF_SITE_INSUR_AMT
                                          + V_BF_SITE_FO_NOTAX_AMT;
              END IF;

                V_SBTR_EARN_AMT           := V_LABOR_EARN_TT_SALY_AMT;
                V_GNR_EARN_TAX_STAD_AMT   := V_LABOR_EARN_TT_SALY_AMT;

                IF V_GNR_EARN_TAX_STAD_AMT > 0 THEN
                  V_CAL_TDUC := TRUNC(V_GNR_EARN_TAX_STAD_AMT * 0.19); --산출세액 = 과세합계금액 * 0.19 : 외국인 단일세율 2017년 17% -> 19%로 변경됨 @VER.2017_2
                  V_DETM_INCOME_TAX := V_CAL_TDUC; --결정세액이 산출세액
                END IF;

                --DBMS_OUTPUT.PUT_LINE('V_DETM_INCOME_TAX = '||TO_CHAR(V_DETM_INCOME_TAX) );

            END IF;


            -- 결정주민세 (결정소득세의 10%)
            V_DETM_INHAB_TAX := TRUNC(V_DETM_INCOME_TAX * 0.1); --결정주민세는 원단위 절사하지 않음


            --2013년, 소액부징수는 차감소득세등의 금액에만 적용한다....

            --차감소득세 (결정소득세 - ( 전소득세 + 현소득세))
            V_SBTR_COLT_INCOME_TAX := TRUNC(  V_DETM_INCOME_TAX   - ( V_BF_SITE_INCOME_TAX + V_INCOME_TAX ),-1);


            --차감주민세 (결정주민세 - ( 전주민세 + 현주민세 ))
            V_SBTR_COLT_INHAB_TAX := TRUNC( V_DETM_INHAB_TAX   - ( V_BF_SITE_INHAB_TAX + V_INHAB_TAX ),-1);


            --차감농특세 (결정농특세 - ( 전농특세 + 현농특세 ))/* @VER.2017_21 전근무지농특세는 반영이 안되어 있어서 추가(V_BF_SITE_FMTAX)*/
            V_SBTR_COLT_FMTAX_TAX := TRUNC(V_BF_SITE_FMTAX  ,-1)+TRUNC(V_DETM_FMTAX_AMT  ,-1);

            --2014.2.6. 결정세액은 소액징수부 적용안함. 차감소득세만 적용함.
            IF V_SBTR_COLT_INCOME_TAX < 1000 and V_SBTR_COLT_INCOME_TAX > 0 THEN   --소득세 기준
               V_SBTR_COLT_INCOME_TAX := 0;
               V_SBTR_COLT_INHAB_TAX  := 0;
            END IF;
            IF V_SBTR_COLT_FMTAX_TAX < 1000 and V_SBTR_COLT_FMTAX_TAX > 0 THEN --농특세기준
               V_SBTR_COLT_FMTAX_TAX := 0;
            END IF;
            -- 정산 마스터에 INSERT....
            --IF V_BF_SITE_SALY_AMT + V_CURR_SITE_SALY_AMT + V_BF_SITE_BONUS_AMT + V_CURR_SITE_BONUS_AMT + V_BF_SITE_DETM_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT != 0 THEN
            IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
                --DELETE FROM PAYM410_TMP
                V_TMP_STEP := 'D16';
                DELETE FROM PAYM435
                 WHERE YY = IN_YY
                   AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND SETT_FG   = V_SETT_FG
                   AND RPST_PERS_NO = REC.RPST_PERS_NO
                   ;
            ELSE
                V_TMP_STEP := 'D17';
                DELETE FROM PAYM410
                 WHERE YY           = IN_YY
                   AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                   AND SETT_FG      = V_SETT_FG
                   AND RPST_PERS_NO = REC.RPST_PERS_NO
                   ;
            END IF;

--            -- 예외자 처리 A078522(Pierre Martinez)
--            IF REC.RPST_PERS_NO IN ('A078522') AND IN_YY = '2012' THEN
--                V_BF_SITE_INCOME_TAX := 0;         -- 기전소득액
--                V_BF_SITE_INHAB_TAX := 0;          -- 기전주민세액
--                V_INCOME_TAX  := 0;                -- 기주소득액
--                V_INHAB_TAX   := 0;                -- 기주주민세액
--                V_SBTR_COLT_INCOME_TAX  := 0;      -- 기차감소득액
--                V_SBTR_COLT_FMTAX_TAX   := 0;      -- 기차감농특세액
--                V_SBTR_COLT_INHAB_TAX   := 0;      -- 기차감주민세액
--            END IF;

          /* 표준세액공제를 계산한다.*/
            SNU.SP_PAYM410B_TRET_STD_2019( REC.BIZR_DEPT_CD  --사업자부서코드
                                          ,IN_YY             --정산년도
                                          ,IN_YRETXA_SEQ     --정산차수@VER.2017_0
                                          ,V_SETT_FG         --정산구분(A031300001:연말정산, A031300002:중도정산, A031300003:연말정산 시뮬레이션)
                                          ,REC.RPST_PERS_NO  --대표개인번호
                                          ,IN_INPT_ID
                                          ,IN_INPT_IP
                                          ,IN_DEPT_CD        --관리부서
                                          ,V_OUT_RTN
                                          ,V_OUT_MSG );

            IF V_OUT_RTN <> '1' THEN
               OUT_RTN := V_OUT_RTN;
               OUT_MSG := V_OUT_MSG;
               RETURN;
            END IF;

            V_STD_DETM_INCOME_TAX := -1;

            BEGIN
                SELECT DETM_EARN_AMT
                  INTO V_STD_DETM_INCOME_TAX
                  FROM PAYM410_STD
                 WHERE YY           = IN_YY
                   AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                   AND RPST_PERS_NO = REC.RPST_PERS_NO
                   AND BIZR_DEPT_CD = REC.BIZR_DEPT_CD
                   AND SETT_FG      = V_SETT_FG
                   ;
            EXCEPTION
            WHEN OTHERS THEN
                 OUT_MSG := '표준세액오류 (대표개인번호 : '||V_RPST_PERS_NO ||', SQLCODE : '||SQLCODE || ':' || SQLERRM || ')';
                 DBMS_OUTPUT.PUT_LINE(OUT_MSG);
                 V_STD_DETM_INCOME_TAX := -2;
            END;


 /* 이런된장 */
/*V_OCCR_LOC_NM := '표준세액공제액 체크';
V_DB_ERROR_CTNT := 'V_STD_DETM_INCOME_TAX = ' || V_STD_DETM_INCOME_TAX ||chr(13)||chr(10)||
                   'V_DETM_INCOME_TAX = ' || V_DETM_INCOME_TAX ||chr(13)||chr(10);
SP_SSTM056_CREA(V_DB_PGM_ID, V_OCCR_LOC_NM, SQLCODE, V_DB_ERROR_CTNT, IN_INPT_ID , IN_INPT_IP );
*/

/* 표준세액공제액이 일반세액공제액보다 클경우 Robin Anderson 예외처리*/
            IF V_STD_DETM_INCOME_TAX >= 0 AND V_STD_DETM_INCOME_TAX < V_DETM_INCOME_TAX  THEN --AND REC.RPST_PERS_NO <> 'D031867' THEN
                SELECT
                    SPCL_DUC_HANDICAP_INSU_AMT         -- 특별공제장애인전용보장성보험료
                    ,SPCL_DUC_INSU_AMT         -- 특별공제보험료
                    ,SPCL_DUC_HFE_AMT             -- 특별공제의료비
                    ,SPCL_DUC_ED_AMT         -- 특별공제교육비
                    ,SPCL_DUC_HSFND_AMT     -- 특별공제주택자금액
                    ,SPCL_DUC_HOUS_ITT_AMT     -- 특별공제주택이자상환금액합계
                    ,SPCL_DUC_HOUS_ITT_AMT1     --특별공제주택이자상환15년미만
                    ,SPCL_DUC_HOUS_ITT_AMT2     --특별공제주택이자상환15년29년
                    ,SPCL_DUC_HOUS_ITT_AMT3     --특별공제주택이자상환30년이상
                    ,SPCL_DUC_HOUS_ITT_AMT4     --특별공제주택이자상환2012년고정금리(비거치식)
                    ,SPCL_DUC_HOUS_ITT_AMT5     --특별공제주택이자상환2012년일반
                    ,SPCL_DUC_HOUS_ITT_AMT6     --특별공제주택이자상환2015년 이후차입분 15년이상 고정금리 AND 비거치상환@VER.2015
                    ,SPCL_DUC_HOUS_ITT_AMT7     --특별공제주택이자상환2015년 이후차입분 15년이상 고정금리 OR 비거치상환@VER.2015
                    ,SPCL_DUC_HOUS_ITT_AMT8     --특별공제주택이자상환2015년 이후차입분 15년이상 그밖의대출@VER.2015
                    ,SPCL_DUC_HOUS_ITT_AMT9     --특별공제주택이자상환2015년 이후차입분 10~15년이상 고정금리 OR 비거치상환@VER.2015
                    ,SPCL_DUC_CNTRIB_AMT    -- 특별공제기부금액
                    ,STAD_DUC_AMT             -- 표준공제액
                    ,SBTR_EARN_AMT             -- 차감소득금액
                    ,LSTCS_SAV_DUC_AMT    --  장기주식형저축합계
                    ,LSTCS_SAV_DUC_AMT1    -- 장기주식형저축공제 1년차
                    ,LSTCS_SAV_DUC_AMT2    -- 장기주식형저축공제 2년차
                    ,LSTCS_SAV_DUC_AMT3    -- 장기주식형저축공제 3년차
                    ,TXSTD_AMT                 -- 과세표준액
                    ,CAL_TAX                 -- 산출세액
                    ,RTXLW_OBJ_AMT           --조세조약감면대상액(@VER.2016_13)
                    ,RTXLW                   --조세조약감면액
                    ,RTXLW_CURR_REDC_AMT     --현근무지 소득 조세조약감면액@VER.2016_14
                    ,RTXLW_ALD_REDC_AMT      --종전근무지 소득 조세조약감면액@VER.2016_14
                    ,REDC_TAX_TT             -- 감면세액계
                    ,LABOR_EARN_TDUC_AMT     -- 근로소득세액공제액
                    ,LESE_LOAMT_TDUC_AMT             -- 주택차입금세액공제액
                    ,CNTRIB_POLITICS_TDUC_AMT     -- 기부정치자금세액공제액
                    ,TDUC_TT                 -- 세액공제계
                    ,DETM_EARN_AMT             -- 결정소득액
                    ,DETM_FMTAX_AMT         -- 결정농특세액
                    ,DETM_IHTAX_AMT         -- 결정주민세액
                    ,ALD_BF_EARN_AMT         -- 기전소득액
                    ,ALD_BF_IHTAX_AMT         -- 기전주민세액
                    ,ALD_MA_EARN_AMT         -- 기주소득액
                    ,ALD_MA_IHTAX_AMT         -- 기주주민세액
                    ,ALD_SBTR_EARN_AMT     -- 기차감소득액
                    ,ALD_SBTR_FMTAX_AMT    -- 기차감농특세액
                    ,ALD_SBTR_IHTAX_AMT    -- 기차감주민세액
                    ,SPCL_DUC_HOUS_LOAMT_AMT1 -- 특별공제주택임차원리금대출기관상환액
                    ,SPCL_DUC_HOUS_LOAMT_AMT2 --특별공제주택임차원리금사인간상환액
                    ,SUBSCRP_SAV_DUC_AMT      -- 청약저축공제액
                    ,LABORR_HSSV_DUC_AMT   -- 근로자주택마련저축공제액
                    ,HOUS_SUBSCRP_GNR_SAV_DUC_AMT  -- 주택청약종합저축공제액
                    ,LNTM_HSSV_DUC_AMT    -- 장기주택마련저축공제액
                    ,SPCL_DUC_HINS_AMT   --특별공제건강보험료
                    ,SPCL_DUC_HINS_AMT   --특별공제건강보험료
                    ,SPCL_DUC_EINS_AMT    --특별공제고용보험료
                    ,SPCL_DUC_EINS_AMT    --특별공제고용보험료
                    ,SPCL_DUC_GUAR_INSU_AMT     --특별공제보장보험료
                    ,SPCL_DUC_GNR_LMT_AMT  -- 특별공제종합한도액
                    ,SPCL_DUC_GNR_LMT_EXCE_AMT  --특별공제종합한도초과액
                    ,POLITICS_TRSR_AMT  --정치자금
                    ,THYR_FLAW_CNTRIB_AMT   --법정기부금
                    ,CNTRIB_AMT_OSC_SOCT  --우리사주조합기부금
                    ,APNT_CNTRIB_AMT -- 지정기부금(종교+종교외)
                    ,SPCL_DUC_HANDICAP_HFE_AMT   --특별공제장애인의료비금액
                    ,SPCL_DUC_ETC_HFE_AMT   --특별공제기타의료비금액
                    ,SPCL_DUC_HANDICAP_EDU_AMT  --특별공제장애인교육비
                    ,SPCL_DUC_ETC_EDU_AMT  -- 특별공제기타교육비

                    ,STXLW -- 조특법 30조 감면 세액 합계(종근무지만 존재함)
                    ,SMBIZ_BONUS_TAX -- 조특법 30조외 감면 세액 합계(종근무지만 존재함). (@VER.2019_6)

                    ,SCI_TECH_PSN_PENS_DUC_OBJ_AMT --과학기술인연금공제대상금액@VER.2015 --2015년 추가
                    ,SCI_TECH_PSN_PENS_TAXDUC_AMT  --과학기술인연금세액공제액@VER.2015 --2015년 추가
                    ,RETI_PENS_DUC_OBJ_AMT         --퇴직연금공제대상금액@VER.2015 --2015년 추가
                    ,RETI_PENS_TAXDUC_AMT          --퇴직연금세액공제액@VER.2015 --2015년 추가
                    ,PNSV_DUC_OBJ_AMT              --연금저축공제대상금액@VER.2015 --2015년 추가
                    ,PNSV_TAXDUC_AMT               --연금저축세액공제액@VER.2015 --2015년 추가

                    ,GUARQL_INSU_DUC_OBJ_AMT       --보장성보험공제대상금액
                    ,GUARQL_INSU_TAXDUC_AMT        --보장성보험세액공제액
                    ,0                             --장애인보장성보험공제대상금액 (2014재계산)
                    ,0                             --장애인보장성보험세액공제액(2014재계산)
                    ,HFE_DUC_OBJ_AMT               --의료비공제대상금액
                    ,HFE_TAXDUC_AMT                --의료비세액공제액
                    ,EDAMT_DUC_OBJ_AMT             --교육비공제대상금액
                    ,EDAMT_TAXDUC_AMT              --교육비세액공제액
                    ,POLITICS_LMT_BLW_DUC_OBJ_AMT  --정치한도이하공제대상금액
                    ,POLITICS_LMT_BLW_TAXDUC_AMT   --정치한도이하세액공제액
                    ,POLITICS_LMT_EXCE_DUC_OBJ_AMT --정치한도초과공제대상금액
                    ,POLITICS_LMT_EXCE_TAXDUC_AMT  --정치한도초과세액공제액
                    ,FLAW_CNTRIB_DUC_OBJ_AMT       --법정기부공제대상금액
                    ,FLAW_CNTRIB_TAXDUC_AMT        --법정기부세액공제액
                    ,APNT_CNTRIB_DUC_OBJ_AMT       --지정기부공제대상금액
                    ,APNT_CNTRIB_TAXDUC_AMT        --지정기부세액공제액
                    ,STAD_TAXDUC_AMT               --표준세액공제액
                    ,CNTRIB_AMT_CYOV_AMT           --기부금(이월액)
                    ,0                             --지정기부(종교외) 세액공제대상금액 @VER.2016_8
                    ,0                             --지정기부(종교외) 세액공제금액 @VER.2016_8
                    ,0                             --지정기부(종교) 세액공제대상금액 @VER.2016_8
                    ,0                             --지정기부(종교) 세액공제금액 @VER.2016_8
                    ,0                             --월세세액공제대상금액@VER.2016 [변수처리 안되어 있었음]
                    ,0                             --월세세액공제액@VER.2016 [변수처리 안되어 있었음]
                    ,CREDIT_CARD_DUC_AMT           -- 신용카드공제액@VER.2017[변수처리 안되어 있었음]
                    ,DUTY_INVENT_CMPS_AMT_NOTAX    --직무발명보상금비과세(@VER.2018_13)
                INTO V_HANDICAP_INSU_PAY_INSU_AMT  -- 장애인보험료
                    ,V_GUAR_INSU_PAY_INSU_AMT      -- 특별공제보장보험료
                    ,V_HFE_DUC_AMT                 -- 특별공제의료비
                    ,V_EDU_DUC_AMT                 -- 특별공제교육비
                    ,V_HOUS_FUND_DUC_HAP_AMT       -- 특별공제주택자금액  (2010년수정)
                    ,V_HOUS_FUND_DUC_2_AMT         --특별공제주택이자상환금액합계
                    ,V_HOUS_MOG_ITT_1              --특별공제주택이자상환금액 15년 미만
                    ,V_HOUS_MOG_ITT_2              --특별공제주택이자상환금액 15년~29년
                    ,V_HOUS_MOG_ITT_3              --특별공제주택이자상환금액 30년 이상
                    ,V_HOUS_MOG_ITT_4              --특별공제주택이자상환2012년고정금리(비거치식)
                    ,V_HOUS_MOG_ITT_5              --특별공제주택이자상환2012년일반
                    ,V_HOUS_MOG_ITT_6     --특별공제주택이자상환2015년 이후차입분 15년이상 고정금리 AND 비거치상환@VER.2015
                    ,V_HOUS_MOG_ITT_7     --특별공제주택이자상환2015년 이후차입분 15년이상 고정금리 OR 비거치상환@VER.2015
                    ,V_HOUS_MOG_ITT_8     --특별공제주택이자상환2015년 이후차입분 15년이상 그밖의대출@VER.2015
                    ,V_HOUS_MOG_ITT_9     --특별공제주택이자상환2015년 이후차입분 10~15년이상 고정금리 OR 비거치상환@VER.2015
                    ,V_CNTRIB_DUC_SUM_AMT         -- 특별공제기부금액
                    ,V_STAD_DUC_AMT               -- 표준공제액
                    ,V_SBTR_EARN_AMT              -- 차감소득금액
                    ,V_LNTM_STCS_SAV_DUC_AMT      -- 장기주식형저축합계
                    ,V_LNTM_STCS_SAV_DUC_AMT1     -- 장기주식형저축공제 1년차
                    ,V_LNTM_STCS_SAV_DUC_AMT2     -- 장기주식형저축공제 2년차
                    ,V_LNTM_STCS_SAV_DUC_AMT3     -- 장기주식형저축공제 3년차
                    ,V_GNR_EARN_TAX_STAD_AMT      -- 과세표준액
                    ,V_CAL_TDUC                   -- 산출세액
                    ,V_RTXLW_OBJ_AMT              -- 조세조약감면대상액(@VER.2016_13)
                    ,V_RTXLW                      -- 조세조약감면액
                    ,V_RTXLW_CURR_REDC_AMT        -- 현근무지 소득 조세조약감면액@VER.2016_14
                    ,V_RTXLW_ALD_REDC_AMT         -- 종전근무지 소득 조세조약감면액@VER.2016_14
                    ,V_REDC_TAX_TT                -- 감면세액계
                    ,V_LABOR_EARN_TDUC_DUC_AMT    -- 근로소득세액공제액
                    ,V_UN_MINT_HOUS_ITT_RFND_AMT  -- 주택차입금세액공제액
                    ,V_POLITICS_CNTRIB_TDUC_DUC   -- 기부정치자금세액공제액
                    ,V_TDUC_DUC_TT_AMT            -- 세액공제계
                    ,V_DETM_INCOME_TAX            -- 결정소득액
                    ,V_DETM_FMTAX_AMT             -- 결정농특세액(주택차입금,투자조합공제액_더해서 20%)
                    ,V_DETM_INHAB_TAX             -- 결정주민세액
                    ,V_BF_SITE_INCOME_TAX         -- 기전소득액
                    ,V_BF_SITE_INHAB_TAX         -- 기전주민세액
                    ,V_INCOME_TAX                 -- 기주소득액
                    ,V_INHAB_TAX                 -- 기주민세액
                    ,V_SBTR_COLT_INCOME_TAX     -- 기차감소득액
                    ,V_SBTR_COLT_FMTAX_TAX    -- 기차감농특세액
                    ,V_SBTR_COLT_INHAB_TAX        -- 기차감주민세액
                    ,V_HOUS_LOAMT_AMT1          --특별공제주택임차원리금대출기관상환액
                    ,V_HOUS_LOAMT_AMT2            --특별공제주택임차원리금사인간상환액
                    ,V_SUBS_SAV                            -- 청약저축
                    ,V_LABORR_HSSV                       -- 근로자주택마련저축
                    ,V_HOUS_SUBS_GNR_SAV            -- 주택청약종합저축
                    ,V_LNTM_HSSV                           -- 장기주택마련저축
                    ,V_PESN_HINS_AMT
                    ,V_HINS_AMT   --특별공제건강보험료
                    ,V_PESN_EINS_AMT
                    ,V_EINS_AMT    --특별공제고용보험료
                    ,V_GUAR_INSU_PAY_INSU_AMT     --보장성보험,
                    ,V_DUC_MAX_AMT    --특별공제종합한도액
                    ,V_DUC_MAX_OVER_AMT  --특별공제종합한도초과액
                    ,V_CNTRIB_DUC_SUM_AMT20 --정치자금 기부금
                    ,V_CNTRIB_DUC_SUM_AMT10 --법정기부금
                    ,V_CNTRIB_DUC_SUM_AMT42  --우리사주조합기부금
                    ,V_CNTRIB_DUC_SUM_AMT4041 --지정기부금(종교+종교외)
                    ,V_HAND_DUC_HFE     --특별공제장애인의료비금액
                    ,V_DUC_MAX_HFE_AMT --특별공제 본인+기타의료비금액
                    ,V_HANDICAP_SPCL_EDU_AMT --장애인교육비
                    ,V_DUC_MAX_EDU_AMT --교육비공제(장애인제외)

                    ,V_BF_SITE_STXLW_TAX  -- 조특법 30조 감면 세액 합계(종근무지만 존재함)
                    ,V_BF_SITE_SMBIZ_BONUS_TAX -- 조특법 30조외 감면 세액 합계(종근무지만 존재함). (@VER.2019_6)

                    ,V_SCI_DUC_OBJ_AMT               --과학기술인연금공제대상금액@VER.2015
                    ,V_SCI_TAXDUC_AMT                --과학기술인연금세액공제액@VER.2015
                    ,V_RETI_PENS_DUC_OBJ_AMT         --퇴직연금공제대상금액@VER.2015
                    ,V_RETI_PENS_TAXDUC_AMT          --퇴직연금세액공제액@VER.2015
                    ,V_PNSV_DUC_OBJ_AMT              --연금저축공제대상금액@VER.2015
                    ,V_PNSV_TAXDUC_AMT               --연금저축세액공제액@VER.2015

                    ,V_GUARQL_INSU_DUC_OBJ_AMT       --보장성보험공제대상금액
                    ,V_GUARQL_INSU_TAXDUC_AMT        --보장성보험세액공제액
                    ,V_DSP_GUARQL_INSU_DUC_OBJ_AMT   --장애인보장성보험공제대상금액 (2014재계산)
                    ,V_DSP_GUARQL_INSU_TAXDUC_AMT    --장애인보장성보험세액공제액(2014재계산)

                    ,v_HFE_DUC_OBJ_AMT               --의료비공제대상금액
                    ,v_HFE_TAXDUC_AMT                --의료비세액공제액
                    ,v_EDAMT_DUC_OBJ_AMT             --교육비공제대상금액
                    ,v_EDAMT_TAXDUC_AMT              --교육비세액공제액
                    ,v_POLITICS_BLW_DUC_OBJ_AMT      --정치한도이하공제대상금액
                    ,v_POLITICS_BLW_TAXDUC_AMT       --정치한도이하세액공제액
                    ,v_POLITICS_EXCE_DUC_OBJ_AMT     --정치한도초과공제대상금액
                    ,v_POLITICS_EXCE_TAXDUC_AMT      --정치한도초과세액공제액
                    ,v_FLAW_CNTRIB_DUC_OBJ_AMT       --법정기부공제대상금액
                    ,v_FLAW_CNTRIB_TAXDUC_AMT        --법정기부세액공제액
                    ,v_APNT_CNTRIB_DUC_OBJ_AMT       --지정기부공제대상금액
                    ,v_APNT_CNTRIB_TAXDUC_AMT        --지정기부세액공제액
                    ,v_STAD_TAXDUC_AMT               --표준세액공제액
                    ,V_CNTRIB_AMT_CYOV_AMT           --기부금(이월액)
                    ,V_APNT_CNTRIB40_DUC_OBJ_AMT     --지정기부(종교외) 세액공제대상금액 @VER.2016_8
                    ,V_APNT_CNTRIB40_TAXDUC_AMT      --지정기부(종교외) 세액공제금액 @VER.2016_8
                    ,V_APNT_CNTRIB41_DUC_OBJ_AMT     --지정기부(종교) 세액공제대상금액 @VER.2016_8
                    ,V_APNT_CNTRIB41_TAXDUC_AMT      --지정기부(종교) 세액공제금액 @VER.2016_8
                    ,V_MM_TAX_AMT                    --월세세액공제대상금액VER.2016 [변수처리 안되어 있었음]
                    ,V_MNRT_TAXDUC_AMT               --월세세액공제액@VER.2016 [변수처리 안되어 있었음]
                    ,V_CREDIT_DUC_AMT                --신용카드공제액@VER.2017[변수처리 안되어 있었음]
                    ,V_DUTY_INVENT_CMPS_AMT_NOTAX    --직무발명보상금비과세(@VER.2018_13)
                FROM PAYM410_STD
               WHERE YY           = IN_YY
                 AND YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                 AND BIZR_DEPT_CD = REC.BIZR_DEPT_CD
                 AND SETT_FG      = V_SETT_FG
                 AND RPST_PERS_NO = REC.RPST_PERS_NO
                 ;


            END IF;


            IF ( IN_SETT_FG = 'A031300003' ) THEN  --연말정산 시뮬레이션인 경우
                V_TMP_STEP := '011';
                --INSERT INTO PAYM410_TMP (
                INSERT INTO PAYM435 (
                        BIZR_DEPT_CD               --사업자부서코드
                        ,YY                         -- 년도
                        ,RPST_PERS_NO                 -- 관리번호
                        ,SETT_FG                 -- 정산구분
                        ,RPRT_YYMM                 -- 신고년월
                        ,POSI_BREU_CD              --소속기관코드
                        ,POSI_DEPT_CD              --소속부서코드

                        ,KOR_NM                    --성명
                        ,RES_NO                    --주민등록번호
                        ,NATI_FG                   --국적코드
                        ,RSD_FG                    --거주지구분코드
                        ,RSD_NATI_FG               --거주지국코드

                        ,STTS_FG                   --신분구분
                        ,BIZTP_FG                   --직종구분
                        ,WKSP_FG                   --직렬구분
                        ,LVLPT_FG                   --급류구분
                        ,WKGD_CD                   --직급코드
                        ,STEP_FG                   --호봉구분
                        ,CWK_YCNT                   --근속년수

                        ,LABOR_SCHLS_FG            --근로장학생
                        ,HOUSEHOLDER_YN             --세대주여부

                        ,REDC_FR_DT             -- 감면시작일자
                        ,REDC_TO_DT             -- 감면종료일자
                        ,MA_WK_SALY_AMT         -- 주근무급여액
                        ,MA_WK_BONUS_AMT         -- 주근무상여액
                        ,MA_DETM_BONUS_AMT       --주근무인정상여액
                        ,MA_WK_TT_AMT             -- 주근무합계액

                        ,BF_WK_FIRM_NM          --전근무상호명
                        ,BF_WK_FR_DT_1          --전근무시작일자1
                        ,BF_WK_TO_DT_1          --전근무종료일자1
                        ,BF_REDC_FR_DT_1           -- 전근무감면시작일자1
                        ,BF_REDC_TO_DT_1           -- 전근무감면종료일자1
                        ,BF_WK_NO               --전근무번호
                        ,BF_WK_SALY_AMT         --전근무급여액
                        ,BF_WK_BONUS_AMT        --전근무상여액
                        ,BF_WK_DETM_BONUS_AMT   --전근무인정상여액

                        ,BF_WK_FIRM_2_NM         -- 전근무상호2명
                        ,BF_WK_FR_DT_2           -- 전근무시작일자2
                        ,BF_WK_TO_DT_2           -- 전근무종료일자2
                        ,BF_REDC_FR_DT_2           -- 전근무감면시작일자2
                        ,BF_REDC_TO_DT_2           -- 전근무감면종료일자2
                        ,BF_WK_NO_2              -- 전근무번호2
                        ,BF_WK_SALY_2_AMT        -- 전근무급여2액
                        ,BF_WK_BONUS_2_AMT       -- 전근무상여2액
                        ,BF_WK_DETM_BONUS_2_AMT  --전근무인정상여액2

                        ,BF_WK_FIRM_3_NM         -- 전근무상호3명
                        ,BF_WK_FR_DT_3           -- 전근무시작일자3
                        ,BF_WK_TO_DT_3           -- 전근무종료일자3
                        ,BF_REDC_FR_DT_3           -- 전근무감면시작일자3
                        ,BF_REDC_TO_DT_3           -- 전근무감면종료일자3
                        ,BF_WK_NO_3              -- 전근무번호3
                        ,BF_WK_SALY_3_AMT        -- 전근무급여3액
                        ,BF_WK_BONUS_3_AMT       -- 전근무상여3액
                        ,BF_WK_DETM_BONUS_3_AMT  --전근무인정상여액3

                        ,BF_WK_TT_AMT             -- 전근무합계액

                        ,SALY_TT_AMT             -- 급여총액
                        ,BONUS_TT_AMT             -- 상여총액
                        ,DETM_BONUS_TT_AMT         -- 인정상여총액
                        ,TAX_TT                 -- 과세합계
                        ,FRN_NOTAX_AMT             -- 국외비과세액
                        ,DELAY_NOTAX_AMT         -- 연장비과세액
                        ,ETC_NOTAX_AMT             -- 기타비과세액
                        ,RECH_NOTAX_AMT             --주근무지연구비비과세액
                        ,CARE_NOTAX_AMT           --주근무지보육비비과세액
                        ,NOTAX_TT_AMT             -- 비과세합계액

                        ,LABOR_EARN_AMT         -- 근로소득금액
                        ,LABOR_EARN_DUC_AMT     -- 근로소득공제액

                        ,SLF_DUC_AMT             -- 본인공제액
                        ,WIFE_DUC_AMT             -- 배우자공제액
                        ,SPRT_PSN_CNT             -- 부양자수
                        ,SPRT_DUC                 -- 부양공제
                        ,RSPT_DUC_CNT             -- 경로공제수
                        ,PATH_DUC_AMT             -- 경로우대공제액
                        ,HINDR_CNT                 -- 장애자수
                        ,HIND_DUC_AMT              -- 장애인공제액
                        ,WOMN_DUC_AMT              -- 부녀자공제액
                        ,BRED_CNT                 -- 자녀양육수
                        ,BRED_DUC_AMT             -- 자녀양육공제액
                        ,MULT_CHILD_ADD_DUC_CNT -- 다자녀추가공제수
                        ,MULT_CHILD_ADD_DUC_AMT   -- 다자녀추가공제액
                        ,CHDBIRTH_DUC_CNT         -- 출산입양공제수
                        ,CHDBIRTH_DUC_AMT         -- 출산공제금액
                        ,SINGLE_PARENT_DUC_AMT         -- 한부모공제금액

                        ,NPN_DUC_AMT             -- 국민연금공제액
                        ,NPN_DUC_OBJ_AMT         -- 국민연금보험료공제대상금액(@VER.2018_2)
                        ,NPN_INSU_AMT             -- 사학연금공제액
                        ,NPN_INSU_DUC_OBJ_AMT     -- 사학연금공제대상금액(@VER.2018_2)
                        ,PUBPERS_PENS_DUC_AMT      -- 공무원연금공제액
                        ,PUBPERS_PENS_DUC_OBJ_AMT  -- 공무원연금공제대상금액(@VER.2018_2)
                        ,MILITARY_PENS_DUC_AMT     -- 군인연금공제액
                        ,MILITARY_PENS_DUC_OBJ_AMT -- 군인연금공제대상금액(@VER.2018_2)

                        ,RETI_PENS_EARN_DUC_AMT     -- 퇴직연금소득공제액
                        ,RETI_SCI_PENS_EARN_DUC_AMT -- 퇴직연금소득공제액
                        ,SPCL_DUC_HANDICAP_INSU_AMT         -- 특별공제장애인전용보장성보험료
                        ,SPCL_DUC_INSU_AMT         -- 특별공제보험료
                        ,SPCL_DUC_HFE_AMT             -- 특별공제의료비
                        ,SPCL_DUC_ED_AMT         -- 특별공제교육비
                        ,SPCL_DUC_HSFND_AMT     -- 특별공제주택자금액

                        ,SPCL_DUC_HOUS_ITT_AMT     -- 특별공제주택이자상환금액합계
                        ,SPCL_DUC_HOUS_ITT_AMT1     --특별공제주택이자상환15년미만
                        ,SPCL_DUC_HOUS_ITT_AMT2     --특별공제주택이자상환15년29년
                        ,SPCL_DUC_HOUS_ITT_AMT3     --특별공제주택이자상환30년이상
                        ,SPCL_DUC_HOUS_ITT_AMT4     --특별공제주택이자상환2012년고정금리(비거치식)
                        ,SPCL_DUC_HOUS_ITT_AMT5     --특별공제주택이자상환2012년일반
                        ,SPCL_DUC_HOUS_ITT_AMT6     --특별공제주택이자상환2015년고정금리(비거치식)
                        ,SPCL_DUC_HOUS_ITT_AMT7     --특별공제주택이자상환2015년고정금리(or비거치식)
                        ,SPCL_DUC_HOUS_ITT_AMT8     --특별공제주택이자상환2015년일반
                        ,SPCL_DUC_HOUS_ITT_AMT9     --특별공제주택이자상환2015년10이상고정금리(비거치식)


                        ,SPCL_DUC_MAGE_MV_AMT     -- 특별공제혼인이사액
                        ,SPCL_DUC_CNTRIB_AMT    -- 특별공제기부금액
                        ,STAD_DUC_AMT             -- 표준공제액
                        ,SBTR_EARN_AMT             -- 차감소득금액
                        ,PERS_PESN_SAV_DUC_AMT      -- 개인연금저축공제
                        ,PESN_SAV_DUC_AMT                 -- 연금저축공제
                        ,DUC_INME_EARN_DUC_AMT     -- 공제부금소득공제액
                        ,HOUS_SAV_DUC_AMT         -- 주택마련저축공제액
                        ,ICOMP_DUC_AMT             -- 투자조합공제액
                        ,CREDIT_CARD_DUC_AMT    -- 신용카드공제액
                        ,OSC_EARN_DUC_AMT         -- 우리사주소득공제액
                        ,LSTCS_SAV_DUC_AMT    --  장기주식형저축합계
                        ,LSTCS_SAV_DUC_AMT1    -- 장기주식형저축공제 1년차
                        ,LSTCS_SAV_DUC_AMT2    -- 장기주식형저축공제 2년차
                        ,LSTCS_SAV_DUC_AMT3    -- 장기주식형저축공제 3년차
                        ,TXSTD_AMT                 -- 과세표준액
                        ,CAL_TAX                 -- 산출세액
                        ,RTXLW_OBJ_AMT           --조세조약감면대상세액@VER.2016_13
                        ,RTXLW                   --조세조약감면액
                        ,RTXLW_CURR_REDC_AMT     --현근무지 소득 조세조약감면액@VER.2016_14
                        ,RTXLW_ALD_REDC_AMT      --종전근무지 소득 조세조약감면액@VER.2016_14
                        ,REDC_TAX_TT             -- 감면세액계
                        ,LABOR_EARN_TDUC_AMT     -- 근로소득세액공제액
                        ,TXPYAS_TDUC_AMT         -- 납세조합세액공제액
                        ,LESE_LOAMT_TDUC_AMT             -- 주택차입금세액공제액
                        ,CNTRIB_POLITICS_TDUC_AMT     -- 기부정치자금세액공제액
                        ,FRNPAI_TDUC_AMT             -- 외국납부세액공제액
                        ,TDUC_TT                 -- 세액공제계
                        ,DETM_EARN_AMT             -- 결정소득액
                        ,DETM_FMTAX_AMT         -- 결정농특세액
                        ,DETM_IHTAX_AMT         -- 결정주민세액
                        ,DETM_TT_AMT             -- 결정합계액

                        ,ALD_BF_EARN_AMT         -- 기전소득액
                        ,ALD_BF_FMTAX_AMT         -- 기전농특세액
                        ,ALD_BF_IHTAX_AMT         -- 기전주민세액
                        ,ALD_BF_TT_AMT         -- 기전합계액
                        ,ALD_MA_EARN_AMT         -- 기주소득액
                        ,ALD_MA_FMTAX_AMT         -- 기주농특세액
                        ,ALD_MA_IHTAX_AMT         -- 기주주민세액
                        ,ALD_MA_TT_AMT         -- 기주합계액
                        ,ALD_SBTR_EARN_AMT     -- 기차감소득액
                        ,ALD_SBTR_FMTAX_AMT    -- 기차감농특세액
                        ,ALD_SBTR_IHTAX_AMT    -- 기차감주민세액

                        ,ALD_SBTR_TT_AMT             -- 차감합계액

                        ,RPRT_YN                 -- 신고여부

                        ,CURR_WK_FR_DT            -- 현근무시작일자
                        ,CURR_WK_TO_DT            -- 현근무종료일자
                        ,DEBIT_CARD_DUC_AMT       -- 직불카드공제액
                        ,SPCL_DUC_MNRT_AMT         -- 특별공제월세액공제금액
                        ,SPCL_DUC_HOUS_LOAMT_AMT1 -- 특별공제주택임차원리금대출기관상환액
                        ,SPCL_DUC_HOUS_LOAMT_AMT2 --특별공제주택임차원리금사인간상환액

                        ,SUBSCRP_SAV_DUC_AMT      -- 청약저축공제액
                        ,LABORR_HSSV_DUC_AMT   -- 근로자주택마련저축공제액
                        ,HOUS_SUBSCRP_GNR_SAV_DUC_AMT  -- 주택청약종합저축공제액
                        ,LNTM_HSSV_DUC_AMT    -- 장기주택마련저축공제액

                        ,SPCL_DUC_HINS_AMT           -- 특별공제건강보험료
                        ,SPCL_DUC_HINS_DUC_OBJ_AMT   -- 특별공제건강보험공제대상금액(@VER.2018_2)
                        ,SPCL_DUC_EINS_AMT           -- 특별공제고용보험료
                        ,SPCL_DUC_EINS_DUC_OBJ_AMT   -- 특별공제고용보험공제대상금액(@VER.2018_2)
                        ,SPCL_DUC_GUAR_INSU_AMT     --특별공제보장보험료

                        ,BF_DELAY_NOTAX_AMT_1   --전근무연장비과세액1
                        ,BF_CARE_NOTAX_AMT_1   --전근무보육비비과세액1
                        ,BF_RECH_NOTAX_AMT_1   --전근무연구비비과세1
                        ,BF_ETC_NOTAX_AMT_1     --전근무기타비과세액1  --> 전근무수련보조수당비과세로 사용함...
                        ,BF_APNT_NOTAX_AMT_1     --전근무지정비과세액1

                        ,BF_NOTAX_TT_AMT_1     --전근무비과세합계액1

                        ,BF_DELAY_NOTAX_AMT_2   --전근무연장비과세액2
                        ,BF_CARE_NOTAX_AMT_2   --전근무보육비비과세액2
                        ,BF_RECH_NOTAX_AMT_2   --전근무연구비비과세2
                        ,BF_ETC_NOTAX_AMT_2    --전근무기타비과세액2  --> 전근무수련보조수당비과세로 사용함...
                        ,BF_APNT_NOTAX_AMT_2     --전근무지정비과세액2
                        ,BF_NOTAX_TT_AMT_2     --전근무비과세합계액2

                        ,BF_DELAY_NOTAX_AMT_3  --전근무연장비과세액3
                        ,BF_CARE_NOTAX_AMT_3   --전근무보육비비과세액3
                        ,BF_RECH_NOTAX_AMT_3   --전근무연구비비과세3
                        ,BF_ETC_NOTAX_AMT_3    --전근무기타비과세액3
                        ,BF_APNT_NOTAX_AMT_3     --전근무지정비과세액3
                        ,BF_NOTAX_TT_AMT_3     --전근무비과세합계액3

                        ,FORE_TAX_RATE_YN --외국인단일세율
                        ,LFSTS_ITT_RFND_AMT --목돈안드는전세이자상환액

                        ,SPCL_DUC_GNR_LMT_AMT  -- 특별공제종합한도액
                        ,SPCL_DUC_GNR_LMT_EXCE_AMT  --특별공제종합한도초과액

                        ,POLITICS_TRSR_AMT  --정치자금
                        ,THYR_FLAW_CNTRIB_AMT   --법정기부금
                        ,CNTRIB_AMT_OSC_SOCT  --우리사주조합기부금
                        ,APNT_CNTRIB_AMT -- 지정기부금(종교+종교외)

                        ,SPCL_DUC_HANDICAP_HFE_AMT   --특별공제장애인의료비금액
                        ,SPCL_DUC_ETC_HFE_AMT   --특별공제기타의료비금액

                        ,SPCL_DUC_HANDICAP_EDU_AMT  --특별공제장애인교육비
                        ,SPCL_DUC_ETC_EDU_AMT  -- 특별공제기타교육비

                        ,BF_WK_REDC_TAX_AMT1  --종근무지1 감면액
                        ,BF_WK_REDC_TAX_AMT2  --종근무지2 감면액
                        ,BF_WK_REDC_TAX_AMT3  --종근무지3 감면액
                        ,BF_WK_REDC_TAX_TT_AMT --종근무지 감면액 합계

                        ,STXLW -- 조특법 30조 감면 세액 합계(종근무지만 존재함)
                        ,SMBIZ_BONUS_TAX -- 조특법 30조외 감면 세액 합계(종근무지만 존재함)(@VER.2019_6)

                        ,REDC_EARN_AMT  --현근무지 소득 감면액

                        ,BASE_DUC_CHILD_CNT            --기본공제자녀수
                        ,CHILD_TAXDUC_AMT              --자녀세액공제액
                        ,CNTRIB_AMT_CYOV_AMT           --기부금이월액
                        ,OSC_CNTRB_AMT                 --우리사주출연금액
                        ,OSC_CNTRIB_AMT                --우리사주기부금
                        ,LNTM_GATHER_INVST_SEC_SAV_AMT --장기집합투자증권저축액
                        ,SCI_TECH_PSN_PENS_DUC_OBJ_AMT --과학기술인연금공제대상금액
                        ,SCI_TECH_PSN_PENS_TAXDUC_AMT  --과학기술인연금세액공제액
                        ,RETI_PENS_DUC_OBJ_AMT         --퇴직연금공제대상금액
                        ,RETI_PENS_TAXDUC_AMT          --퇴직연금세액공제액
                        ,PNSV_DUC_OBJ_AMT              --연금저축공제대상금액
                        ,PNSV_TAXDUC_AMT               --연금저축세액공제액
                        ,GUARQL_INSU_DUC_OBJ_AMT       --보장성보험공제대상금액
                        ,GUARQL_INSU_TAXDUC_AMT        --보장성보험세액공제액
                        ,DSPSN_GUARQL_INSU_DUC_OBJ_AMT --장애인보장성보험공제대상금액 (2014재계산)
                        ,DSPSN_GUARQL_INSU_TAXDUC_AMT  --장애인보장성보험세액공제액(2014재계산)
                        ,HFE_DUC_OBJ_AMT               --의료비공제대상금액
                        ,HFE_TAXDUC_AMT                --의료비세액공제액
                        ,EDAMT_DUC_OBJ_AMT             --교육비공제대상금액
                        ,EDAMT_TAXDUC_AMT              --교육비세액공제액
                        ,POLITICS_LMT_BLW_DUC_OBJ_AMT  --정치한도이하공제대상금액
                        ,POLITICS_LMT_BLW_TAXDUC_AMT   --정치한도이하세액공제액
                        ,POLITICS_LMT_EXCE_DUC_OBJ_AMT --정치한도초과공제대상금액
                        ,POLITICS_LMT_EXCE_TAXDUC_AMT  --정치한도초과세액공제액
                        ,FLAW_CNTRIB_DUC_OBJ_AMT       --법정기부공제대상금액
                        ,FLAW_CNTRIB_TAXDUC_AMT        --법정기부세액공제액
                        ,APNT_CNTRIB_DUC_OBJ_AMT       --지정기부공제대상금액
                        ,APNT_CNTRIB_TAXDUC_AMT        --지정기부세액공제액
                        ,STAD_TAXDUC_AMT               --표준세액공제액
                        ,MNRT_TAXDUC_AMT               --월세세액공제액
--                        ,SPCL_INCMDED_TT_AMT           --특별소득공제합계액
--                        ,REST_INCMDED_TT_AMT           --그외소득공제합계액
                        ,APNT_CNTRIB_RELI_OUT_OBJ_AMT   --지정기부(종교외) 세액공제대상금액 @VER.2016_8
                        ,APNT_CNTRIB_RELI_OUT_DUC_AMT   --지정기부(종교외) 세액공제금액 @VER.2016_8
                        ,APNT_CNTRIB_RELI_OBJ_AMT       --지정기부(종교) 세액공제대상금액 @VER.2016_8
                        ,APNT_CNTRIB_RELI_DUC_AMT       --지정기부(종교) 세액공제금액 @VER.2016_8
                        ,DUTY_INVENT_CMPS_AMT_NOTAX     --직무발명보상금비과세(@VER.2018_13)
                        ,INPT_ID                 -- 등록자ID
                        ,INPT_DTTM                 -- 등록일시
                        ,INPT_IP                 -- 등록자IP
                        )
                VALUES (
                        REC.BIZR_DEPT_CD           --사업자부서코드
                        ,IN_YY                     -- 년도
                        ,REC.RPST_PERS_NO          --대표개인번호
                        ,V_SETT_FG                 -- 정산구분
                        ,CASE WHEN V_SETT_FG = 'A031300001' THEN TO_CHAR(TO_NUMBER(IN_YY) + 1)||'02'
                              ELSE IN_YY||'12' END  -- 신고년월
                        ,REC.POSI_BREU_CD      --소속기관코드
                        ,REC.POSI_DEPT_CD      --소속부서코드

                        ,REC.KOR_NM                  --성명
                        ,REC.RES_NO                  --주민등록번호
                        ,REC.NATI_FG                 --국적코드
                        ,REC.RSD_FG                  --거주자구분코드
                        ,REC.RSD_NATI_FG             --거주지국코드

                        ,REC.STTS_FG               --신분구분
                        ,REC.BIZTP_FG               --직종구분
                        ,REC.WKSP_FG               --직렬구분
                        ,REC.LVLPT_FG               --급류구분
                        ,REC.WKGD_CD               --직급코드
                        ,REC.STEP_FG               --호봉구분
                        ,REC.CWK_YCNT               --근속년수

                        ,'N'                         --근로장학생(Y=근로장학금,N=일반근로자)
                        ,REC.HOUSEHOLDER_YN           --세대주여부

                        ,REC.REDC_FR_DT               --감면시작일자
                        ,REC.REDC_TO_DT               --감면종료일자
                        ,V_CURR_SITE_SALY             -- 주근무급여액
                        ,V_CURR_SITE_BONUS_AMT        -- 주근무상여액
                        ,V_CURR_SITE_DETM_BONUS_AMT   --주근무인정상여액
                        ,V_CURR_SITE_SALY + V_CURR_SITE_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT -- 주근무합계액

                        ,V_BF_WK_FIRM_NM_1             -- 전근무상호명
                        ,V_BF_WK_FR_DT_1             -- 전근무시작일자1
                        ,V_BF_WK_TO_DT_1             -- 전근무종료일자1
                        ,V_BF_REDC_FR_DT_1             -- 전근무 감면시작일자1
                        ,V_BF_REDC_TO_DT_1             -- 전근무 감면종료일자1

                        ,V_BF_WK_BIZR_NO_1             -- 전근무번호
                        ,V_BF_SITE_SALY_AMT_1         -- 전근무급여액
                        ,V_BF_SITE_BONUS_AMT_1         -- 전근무상여액
                        ,V_BF_SITE_DETM_BONUS_AMT_1    --전근무인정상여액

                        ,V_BF_WK_FIRM_NM_2             -- 전근무상호2명
                        ,V_BF_WK_FR_DT_2             -- 전근무시작일자2
                        ,V_BF_WK_TO_DT_2             -- 전근무종료일자2
                        ,V_BF_REDC_FR_DT_2             -- 전근무 감면시작일자2
                        ,V_BF_REDC_TO_DT_2             -- 전근무 감면종료일자2

                        ,V_BF_WK_BIZR_NO_2             -- 전근무번호2
                        ,V_BF_SITE_SALY_AMT_2         -- 전근무급여2액
                        ,V_BF_SITE_BONUS_AMT_2         -- 전근무상여2액
                        ,V_BF_SITE_DETM_BONUS_AMT_2    --전근무인정상여액2

                        ,V_BF_WK_FIRM_NM_3             -- 전근무상호3명
                        ,V_BF_WK_FR_DT_3             -- 전근무시작일자3
                        ,V_BF_WK_TO_DT_3             -- 전근무종료일자3
                        ,V_BF_REDC_FR_DT_3             -- 전근무 감면시작일자3
                        ,V_BF_REDC_TO_DT_3             -- 전근무 감면종료일자3

                        ,V_BF_WK_BIZR_NO_3             -- 전근무번호3
                        ,V_BF_SITE_SALY_AMT_3         -- 전근무급여3액
                        ,V_BF_SITE_BONUS_AMT_3         -- 전근무상여3액
                        ,V_BF_SITE_DETM_BONUS_AMT_3    --전근무인정상여액3

                        ,V_BF_SITE_SALY_AMT + V_BF_SITE_BONUS_AMT + V_BF_SITE_DETM_BONUS_AMT + V_BF_STOCK_BUY_AMT -- 전근무합계액 + 주식매수선택이익금액

                        ,V_BF_SITE_SALY_AMT + V_CURR_SITE_SALY_AMT                           -- 급여총액
                        ,V_BF_SITE_BONUS_AMT + V_CURR_SITE_BONUS_AMT                         -- 상여총액
                        ,V_BF_SITE_DETM_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT               -- 인정상여금액
                        ,V_LABOR_EARN_TT_SALY_AMT                                            -- 과세합계
                        --V_BF_SITE_SALY_AMT + V_CURR_SITE_SALY_AMT + V_BF_SITE_BONUS_AMT + V_CURR_SITE_BONUS_AMT + V_BF_SITE_DETM_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT-- 과세합계
                        ,0                             -- 국외비과세액
                        --,0                             -- 연장비과세액
                        ,V_DELAY_NOTAX_AMT             -- 연장비과세액(@VER.2018_3)
                        ,V_ETC_AMT_TAX                 -- 기타비과세액
                        ,V_RECH_ACT_AMT_TAX         -- 연구비비과세액
                        ,V_CHDBIRTH_CARE_AMT             -- 보육비비과세액
                        ,V_CURR_SITE_AMT_TAX_SETT_AMT + V_ETC_AMT_TAX     -- 비과세합계액

                        ,V_LABOR_EARN_AMT             -- 근로소득금액
                        ,V_LABOR_EARN_DUC_AMT         -- 근로소득공제액

                        ,V_SLF_DUC_AMT                 -- 본인공제액
                        ,V_WIFE_DUC_AMT             -- 배우자공제액
                        ,V_SPRT_OBJ_PSN_CNT         -- 부양자수
                        ,V_SPRT_FM_DUC_AMT             -- 부양공제
                        ,V_PATH_PREF_CNT_70         -- 경로공제수
                        ,V_PATH_PREF_DUC_AMT_70     -- 경로우대공제액
                        ,V_HINDR_CNT                 -- 장애자수
                        ,V_HANDICAP_DUC_AMT         -- 장애인공제액
                        ,V_WOMN_DUC_AMT             -- 부녀자공제
                        ,V_BRED_CNT_6                 -- 자녀양육수(6세이하)
                        ,V_CHILD_BREXPS_DUC_AMT_6     -- 자녀양육공제액 (2014재계산) 6세이하 자녀세액공제로 처리
                        ,V_MTI_CHILD_ADD_DUC_CNT     -- 다자녀추가공제수
                        ,V_MTI_CHILD_ADD_DUC_AMT     -- 다자녀추가공제액
                        ,V_ADOP_CHIL_CNT             --출산입양공제수
                        ,V_ADOP_CHIL_DUC_AMT         -- 출산입양공제금액 (2014재계산) 세액공제로 처리
                        ,V_SINGLE_PARENT_DUC_AMT   --한부모공제금액

                        ,V_NPN_INSU_AMT + V_ADD_NPN_INSU_AMT            -- 국민연금공제액
                        ,V_NPN_INSU_AMT + V_ADD_NPN_INSU_AMT            -- 국민연금보험료공제대상금액(@VER.2018_2)
                        ,V_PSCH_PESN_INSU_AMT + V_ADD_PSCH_PESN_INSU_AMT     -- 사학연금보험료
                        ,V_PSCH_PESN_INSU_AMT + V_ADD_PSCH_PESN_INSU_AMT     -- 사학연금공제대상금액(@VER.2018_2)
                        ,V_PUBPERS_PENS_AMT + V_ADD_PUBPERS_PENS_AMT         -- 공무원연금공제액
                        ,V_PUBPERS_PENS_AMT + V_ADD_PUBPERS_PENS_AMT         -- 공무원연금공제대상금액(@VER.2018_2)
                        ,V_MILITARY_PENS_INSU_AMT                            -- 군인연금공제액
                        ,V_MILITARY_PENS_INSU_AMT                            -- 군인연금공제대상금액(@VER.2018_2)

                        ,V_RETI_PESN_DUC_AMT                   -- 퇴직연금소득공제액(근로자퇴직급여보장법)
                        ,V_SCI_TECH_RETI_PESN_AMT              -- 퇴직연금소득공제액(과학기술인공제)
                        ,V_HANDICAP_INSU_PAY_INSU_AMT     -- 장애인보험료
                        ,V_GUAR_INSU_PAY_INSU_AMT         -- 특별공제보장보험료
                        ,V_HFE_DUC_AMT                 -- 특별공제의료비
                        ,V_EDU_DUC_AMT                 -- 특별공제교육비

                        ,V_HOUS_FUND_DUC_HAP_AMT         -- 특별공제주택자금액  (2010년수정)
                        ,V_HOUS_FUND_DUC_2_AMT         --특별공제주택이자상환금액합계

                        ,V_HOUS_MOG_ITT_1              --특별공제주택이자상환금액 15년 미만
                        ,V_HOUS_MOG_ITT_2              --특별공제주택이자상환금액 15년~29년
                        ,V_HOUS_MOG_ITT_3              --특별공제주택이자상환금액 30년 이상
                        ,V_HOUS_MOG_ITT_4              --특별공제주택이자상환2012년고정금리(비거치식)
                        ,V_HOUS_MOG_ITT_5              --특별공제주택이자상환2012년일반
                        -- 2015년 연말정산. @VER.2015
                        ,V_HOUS_MOG_ITT_6              --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 AND 비거치식
                        ,V_HOUS_MOG_ITT_7              --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 OR 비거치식
                        ,V_HOUS_MOG_ITT_8              --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 일반적인 차입
                        ,V_HOUS_MOG_ITT_9              --장기주택저당차입금이자2015년 이후 차입분. 10년 이상~15년미만. 고정금리 OR 비거치식

                        ,0                             -- 특별공제혼인이사액
                        ,V_CNTRIB_DUC_SUM_AMT         -- 특별공제기부금액
                        ,V_STAD_DUC_AMT               -- 표준공제액
                        ,V_SBTR_EARN_AMT              -- 차감소득금액
                        ,V_PERS_PESN_SAV_DUC_AMT      -- 개인연금저축공제
                        ,V_PESN_SAV_DUC_AMT           -- 연금저축공제
                        ,V_CO_DUC_AMT                 -- 공제부금소득공제액
                        ,V_HSSV_AMT                   -- 주택저축공제액
                        ,V_ICOMP_FINC_DUC_AMT         -- 투자조합공제액
                        ,V_CREDIT_DUC_AMT             -- 신용카드공제액
                        ,0                            -- 우리사주소득공제액
                        ,V_LNTM_STCS_SAV_DUC_AMT      -- 장기주식형저축합계
                        ,V_LNTM_STCS_SAV_DUC_AMT1     -- 장기주식형저축공제 1년차
                        ,V_LNTM_STCS_SAV_DUC_AMT2     -- 장기주식형저축공제 2년차
                        ,V_LNTM_STCS_SAV_DUC_AMT3     -- 장기주식형저축공제 3년차
                        ,V_GNR_EARN_TAX_STAD_AMT      -- 과세표준액
                        ,V_CAL_TDUC                   -- 산출세액
                        ,V_RTXLW_OBJ_AMT              --조세조약감면대상세액@VER.2016_13
                        ,V_RTXLW                      --조세조약감면액
                        ,V_RTXLW_CURR_REDC_AMT        --현근무지 소득 조세조약감면액@VER.2016_14
                        ,V_RTXLW_ALD_REDC_AMT         --종전근무지 소득 조세조약감면액@VER.2016_14
                        ,V_REDC_TAX_TT                -- 감면세액계
                        ,V_LABOR_EARN_TDUC_DUC_AMT    -- 근로소득세액공제액
                        ,0                            -- 납세조합세액공제액
                        ,V_UN_MINT_HOUS_ITT_RFND_AMT  -- 주택차입금세액공제액
                        ,V_POLITICS_CNTRIB_TDUC_DUC   -- 기부정치자금세액공제액
                        ,0                            -- 외국납부세액공제액
                        ,V_TDUC_DUC_TT_AMT            -- 세액공제계
                        ,V_DETM_INCOME_TAX            -- 결정소득액
                        ,V_DETM_FMTAX_AMT             -- 결정농특세액(주택차입금,투자조합공제액_더해서 20%)
                        ,V_DETM_INHAB_TAX             -- 결정주민세액
                        ,V_DETM_INCOME_TAX + V_DETM_FMTAX_AMT + V_DETM_INHAB_TAX     -- 결정합계액
                        ,V_BF_SITE_INCOME_TAX          -- 기전소득액
                        ,V_BF_SITE_FMTAX               -- 기전농특세액@VER.2017_21
                        ,V_BF_SITE_INHAB_TAX           -- 기전주민세액
                        ,V_BF_SITE_INCOME_TAX + V_BF_SITE_INHAB_TAX        -- 기전합계액
                        ,V_INCOME_TAX                 -- 기주소득액
                        ,0                             -- 기주농특세액
                        ,V_INHAB_TAX                 -- 기주민세액
                        ,V_INCOME_TAX + V_INHAB_TAX -- 기주합계액
                        ,V_SBTR_COLT_INCOME_TAX     -- 기차감소득액
                        ,V_SBTR_COLT_FMTAX_TAX    -- 기차감농특세액
                        ,V_SBTR_COLT_INHAB_TAX        -- 기차감주민세액
                        ,V_SBTR_COLT_INCOME_TAX + V_SBTR_COLT_FMTAX_TAX + V_SBTR_COLT_INHAB_TAX     -- 차감합계액

                        ,'0'                     -- 신고여부

                        ,V_CURR_WK_FR_DT        -- 현근무시작일자
                        ,V_CURR_WK_TO_DT        -- 현근무종료일자
                        ,0                     -- 직불카드공제금액
                        ,V_MM_TAX_AMT                       -- 특별공제월세액공제금액
                        ,V_HOUS_LOAMT_AMT1          --특별공제주택임차원리금대출기관상환액
                        ,V_HOUS_LOAMT_AMT2            --특별공제주택임차원리금사인간상환액

                        ,V_SUBS_SAV                            -- 청약저축
                        ,V_LABORR_HSSV                       -- 근로자주택마련저축
                        ,V_HOUS_SUBS_GNR_SAV            -- 주택청약종합저축
                        ,V_LNTM_HSSV                           -- 장기주택마련저축

                        ,V_PESN_HINS_AMT + V_HINS_AMT   -- 특별공제건강보험료
                        ,V_PESN_HINS_AMT + V_HINS_AMT   -- 특별공제건강보험공제대상금액(@VER.2018_2)
                        ,V_PESN_EINS_AMT + V_EINS_AMT   -- 특별공제고용보험료
                        ,V_PESN_EINS_AMT + V_EINS_AMT   -- 특별공제고용보험공제대상금액(@VER.2018_2)

                        ,V_GUAR_INSU_PAY_INSU_AMT     --보장성보험,

                        ,V_BF_SITE_DELAY_NOTAX_AMT_1  --전근무지 연장비과세액1
                        ,V_BF_SITE_CARE_NOTAX_AMT_1   --전근무지 보육비과세1
                        ,V_BF_SITE_RECH_NOTAX_AMT_1   --전근무지 연구비과세1
                        --,V_BF_SITE_ETC_NOTAX_AMT_1    --전근무지 기타비과세1
                        --> 기타비과세컬럼을 수련보조수당비과세로 사용....
                        ,V_BF_SITE_TRAING_ASSI_ALLOW_1

                        ,V_BF_SITE_APNT_NOTAX_AMT_1    --전근무지 지정비과세1
                        --영수증에 표시되는 항목만 합산한다...2014.2.
                        ,V_BF_SITE_DELAY_NOTAX_AMT_1 + V_BF_SITE_CARE_NOTAX_AMT_1 + V_BF_SITE_RECH_NOTAX_AMT_1+V_BF_SITE_TRAING_ASSI_ALLOW_1
                        --,V_BF_SITE_DELAY_NOTAX_AMT_1 + V_BF_SITE_CARE_NOTAX_AMT_1 + V_BF_SITE_RECH_NOTAX_AMT_1 +V_BF_SITE_ETC_NOTAX_AMT_1 +V_BF_SITE_APNT_NOTAX_AMT_1

                        ,V_BF_SITE_DELAY_NOTAX_AMT_2   --전근무지 연장비과세액2
                        ,V_BF_SITE_CARE_NOTAX_AMT_2    --전근무지 보육비과세2
                        ,V_BF_SITE_RECH_NOTAX_AMT_2    --전근무지 연구비과세2
                        --,V_BF_SITE_ETC_NOTAX_AMT_2     --전근무지 기타비과세2
                        --> 기타비과세컬럼을 수련보조수당비과세로 사용....
                        ,V_BF_SITE_TRAING_ASSI_ALLOW_2
                        ,V_BF_SITE_APNT_NOTAX_AMT_2    --전근무지 지정비과세2
                        --영수증에 표시되는 항목만 합산한다...2014.2.
                        ,V_BF_SITE_DELAY_NOTAX_AMT_2 + V_BF_SITE_CARE_NOTAX_AMT_2 + V_BF_SITE_RECH_NOTAX_AMT_2+V_BF_SITE_TRAING_ASSI_ALLOW_2
                        --,V_BF_SITE_DELAY_NOTAX_AMT_2 + V_BF_SITE_CARE_NOTAX_AMT_2 + V_BF_SITE_RECH_NOTAX_AMT_2 + V_BF_SITE_ETC_NOTAX_AMT_2 +V_BF_SITE_APNT_NOTAX_AMT_2

                        ,V_BF_SITE_DELAY_NOTAX_AMT_3   --전근무지 연장비과세액3
                        ,V_BF_SITE_CARE_NOTAX_AMT_3    --전근무지 보육비과세3
                        ,V_BF_SITE_RECH_NOTAX_AMT_3    --전근무지 연구비과세3
                        --,V_BF_SITE_ETC_NOTAX_AMT_3     --전근무지 기타비과세3
                        ,V_BF_SITE_TRAING_ASSI_ALLOW_3
                        ,V_BF_SITE_APNT_NOTAX_AMT_3    --전근무지 지정비과세3
                        --영수증에 표시되는 항목만 합산한다...2014.2.
                        ,V_BF_SITE_DELAY_NOTAX_AMT_3 + V_BF_SITE_CARE_NOTAX_AMT_3 + V_BF_SITE_RECH_NOTAX_AMT_3+V_BF_SITE_TRAING_ASSI_ALLOW_3
                        --,V_BF_SITE_DELAY_NOTAX_AMT_3 + V_BF_SITE_CARE_NOTAX_AMT_3 + V_BF_SITE_RECH_NOTAX_AMT_3 + V_BF_SITE_ETC_NOTAX_AMT_3 + V_BF_SITE_APNT_NOTAX_AMT_3     --전근무지 기타비과세3

                        ,REC.FORE_TAX_RATE_YN  --외국인단일세율
                        ,V_LFSTS_ITT_RFND_AMT --목돈안드는전세이자상환액

                        ,V_DUC_MAX_AMT    --특별공제종합한도액
                        ,V_DUC_MAX_OVER_AMT  --특별공제종합한도초과액

                        ,V_CNTRIB_DUC_SUM_AMT20 --정치자금 기부금
                        ,V_CNTRIB_DUC_SUM_AMT10 --법정기부금
                        ,V_CNTRIB_DUC_SUM_AMT42  --우리사주조합기부금
                        ,V_CNTRIB_DUC_SUM_AMT4041 --지정기부금(종교+종교외)

                        ,V_HAND_DUC_HFE     --특별공제장애인의료비금액
                        ,V_DUC_MAX_HFE_AMT --특별공제 본인+기타의료비금액

                        ,V_HANDICAP_SPCL_EDU_AMT --장애인교육비
                        ,V_DUC_MAX_EDU_AMT --교육비공제(장애인제외)

                        ,V_BF_SITE_STXLW_NOTAX_1+V_BF_SITE_RTXLW_NOTAX_1  -- 종근무지1 감면액
                        ,V_BF_SITE_STXLW_NOTAX_2+V_BF_SITE_RTXLW_NOTAX_2  -- 종근무지2 감면액
                        ,V_BF_SITE_STXLW_NOTAX_3+V_BF_SITE_RTXLW_NOTAX_3  -- 종근무지3 감면액
                        ,V_BF_SITE_STXLW_NOTAX_1+V_BF_SITE_RTXLW_NOTAX_1
                         +V_BF_SITE_STXLW_NOTAX_2+V_BF_SITE_RTXLW_NOTAX_2
                         +V_BF_SITE_STXLW_NOTAX_3+V_BF_SITE_RTXLW_NOTAX_3-- 종근무지 감면액 합계

                        ,V_BF_SITE_STXLW_TAX  -- 조특법 30조 감면 세액 합계(종근무지만 존재함)
                        ,V_BF_SITE_SMBIZ_BONUS_TAX  -- 조특법 30조외 감면 세액 합계(종근무지만 존재함)(@VER.2019_6)
                        ,V_RTXLW_AMT1  --현근무지 소득 감면액

                        ,v_BASE_DUC_CHILD_CNT            --기본공제자녀수
                        ,v_CHILD_TAXDUC_AMT              --자녀세액공제액
                        ,v_CNTRIB_AMT_CYOV_AMT           --기부금이월액
                        ,v_OSC_CNTRB_AMT                 --우리사주출연금액
                        ,v_OSC_CNTRIB_AMT                --우리사주기부금
                        ,v_INVST_SEC_SAV_AMT             --장기집합투자증권저축액
                        ,v_SCI_DUC_OBJ_AMT               --과학기술인연금공제대상금액
                        ,v_SCI_TAXDUC_AMT                --과학기술인연금세액공제액
                        ,v_RETI_PENS_DUC_OBJ_AMT         --퇴직연금공제대상금액
                        ,v_RETI_PENS_TAXDUC_AMT          --퇴직연금세액공제액
                        ,v_PNSV_DUC_OBJ_AMT              --연금저축공제대상금액
                        ,v_PNSV_TAXDUC_AMT               --연금저축세액공제액
                        ,v_GUARQL_INSU_DUC_OBJ_AMT       --보장성보험공제대상금액
                        ,v_GUARQL_INSU_TAXDUC_AMT        --보장성보험세액공제액
                        ,V_DSP_GUARQL_INSU_DUC_OBJ_AMT   --장애인보장성보험공제대상금액 (2014재계산)
                        ,V_DSP_GUARQL_INSU_TAXDUC_AMT    --장애인보장성보험세액공제액(2014재계산)
                        ,v_HFE_DUC_OBJ_AMT               --의료비공제대상금액
                        ,v_HFE_TAXDUC_AMT                --의료비세액공제액
                        ,v_EDAMT_DUC_OBJ_AMT             --교육비공제대상금액
                        ,v_EDAMT_TAXDUC_AMT              --교육비세액공제액
                        ,v_POLITICS_BLW_DUC_OBJ_AMT      --정치한도이하공제대상금액
                        ,v_POLITICS_BLW_TAXDUC_AMT       --정치한도이하세액공제액
                        ,v_POLITICS_EXCE_DUC_OBJ_AMT     --정치한도초과공제대상금액
                        ,v_POLITICS_EXCE_TAXDUC_AMT      --정치한도초과세액공제액
                        ,v_FLAW_CNTRIB_DUC_OBJ_AMT       --법정기부공제대상금액
                        ,v_FLAW_CNTRIB_TAXDUC_AMT        --법정기부세액공제액
                        ,v_APNT_CNTRIB_DUC_OBJ_AMT       --지정기부공제대상금액
                        ,v_APNT_CNTRIB_TAXDUC_AMT        --지정기부세액공제액
                        ,v_STAD_TAXDUC_AMT               --표준세액공제액
                        ,v_MNRT_TAXDUC_AMT               --월세세액공제액
--                        ,v_SPCL_INCMDED_TT_AMT           --특별소득공제합계액
--                        ,v_REST_INCMDED_TT_AMT           --그외소득공제합계액
                        ,V_APNT_CNTRIB40_DUC_OBJ_AMT      --지정기부(종교외) 세액공제대상금액 @VER.2016_8
                        ,V_APNT_CNTRIB40_TAXDUC_AMT       --지정기부(종교외) 세액공제금액 @VER.2016_8
                        ,V_APNT_CNTRIB41_DUC_OBJ_AMT      --지정기부(종교) 세액공제대상금액 @VER.2016_8
                        ,V_APNT_CNTRIB41_TAXDUC_AMT       --지정기부(종교) 세액공제금액 @VER.2016_8
                        ,V_DUTY_INVENT_CMPS_AMT_NOTAX     --직무발명보상금비과세(@VER.2018_13)
                        ,IN_INPT_ID  -- 등록자ID
                        ,SYSDATE     -- 등록일시
                        ,IN_INPT_IP  -- 등록자IP
                        );


/* 연말정산 계산일 경우 */
            ELSE
                V_TMP_STEP := '013';
                INSERT INTO PAYM410 (
                        BIZR_DEPT_CD               -- 사업자부서코드
                        ,YY                        -- 년도
                        ,YRETXA_SEQ                -- 정산차수:@VER.2017_0
                        ,RPST_PERS_NO              -- 관리번호
                        ,SETT_FG                   -- 정산구분
                        ,RPRT_YYMM                 -- 신고년월
                        ,POSI_BREU_CD              -- 소속기관코드
                        ,POSI_DEPT_CD              -- 소속부서코드

                        ,KOR_NM                    --성명
                        ,RES_NO                    --주민등록번호
                        ,NATI_FG                   --국적코드
                        ,RSD_FG                    --거주자구분코드
                        ,RSD_NATI_FG               --거주지국코드

                        ,STTS_FG                   --신분구분
                        ,BIZTP_FG                   --직종구분
                        ,WKSP_FG                   --직렬구분
                        ,LVLPT_FG                   --급류구분
                        ,WKGD_CD                   --직급코드
                        ,STEP_FG                   --호봉구분
                        ,CWK_YCNT                   --근속년수

                        ,LABOR_SCHLS_FG            --근로장학생
                        ,HOUSEHOLDER_YN             --세대주여부

                        ,REDC_FR_DT             -- 감면시작일자
                        ,REDC_TO_DT             -- 감면종료일자
                        ,MA_WK_SALY_AMT         -- 주근무급여액
                        ,MA_WK_BONUS_AMT         -- 주근무상여액
                        ,MA_DETM_BONUS_AMT       --주근무인정상여액
                        ,MA_WK_TT_AMT             -- 주근무합계액

                        ,BF_WK_FIRM_NM          --전근무상호명
                        ,BF_WK_FR_DT_1          --전근무시작일자1
                        ,BF_WK_TO_DT_1          --전근무종료일자1
                        ,BF_REDC_FR_DT_1           -- 전근무감면시작일자1
                        ,BF_REDC_TO_DT_1           -- 전근무감면종료일자1
                        ,BF_WK_NO               --전근무번호
                        ,BF_WK_SALY_AMT         --전근무급여액
                        ,BF_WK_BONUS_AMT        --전근무상여액
                        ,BF_WK_DETM_BONUS_AMT   --전근무인정상여액

                        ,BF_WK_FIRM_2_NM         -- 전근무상호2명
                        ,BF_WK_FR_DT_2           -- 전근무시작일자2
                        ,BF_WK_TO_DT_2           -- 전근무종료일자2
                        ,BF_REDC_FR_DT_2           -- 전근무감면시작일자2
                        ,BF_REDC_TO_DT_2           -- 전근무감면종료일자2
                        ,BF_WK_NO_2              -- 전근무번호2
                        ,BF_WK_SALY_2_AMT        -- 전근무급여2액
                        ,BF_WK_BONUS_2_AMT       -- 전근무상여2액
                        ,BF_WK_DETM_BONUS_2_AMT  --전근무인정상여액2

                        ,BF_WK_FIRM_3_NM         -- 전근무상호3명
                        ,BF_WK_FR_DT_3           -- 전근무시작일자3
                        ,BF_WK_TO_DT_3           -- 전근무종료일자3
                        ,BF_REDC_FR_DT_3         -- 전근무감면시작일자3
                        ,BF_REDC_TO_DT_3         -- 전근무감면종료일자3
                        ,BF_WK_NO_3              -- 전근무번호3
                        ,BF_WK_SALY_3_AMT        -- 전근무급여3액
                        ,BF_WK_BONUS_3_AMT       -- 전근무상여3액
                        ,BF_WK_DETM_BONUS_3_AMT  --전근무인정상여액3

                        ,BF_WK_TT_AMT            -- 전근무합계액

                        ,SALY_TT_AMT             -- 급여총액
                        ,BONUS_TT_AMT            -- 상여총액
                        ,DETM_BONUS_TT_AMT       -- 인정상여총액
                        ,TAX_TT                  -- 과세합계
                        ,FRN_NOTAX_AMT           -- 국외비과세액
                        ,DELAY_NOTAX_AMT         -- 연장비과세액
                        ,ETC_NOTAX_AMT           -- 기타비과세액
                        ,RECH_NOTAX_AMT          -- 주근무지연구비비과세액
                        ,CARE_NOTAX_AMT          -- 주근무지보육비비과세액
                        ,NOTAX_TT_AMT            -- 비과세합계액

                        ,LABOR_EARN_AMT         -- 근로소득금액
                        ,LABOR_EARN_DUC_AMT     -- 근로소득공제액

                        ,SLF_DUC_AMT             -- 본인공제액
                        ,WIFE_DUC_AMT             -- 배우자공제액
                        ,SPRT_PSN_CNT             -- 부양자수
                        ,SPRT_DUC                 -- 부양공제
                        ,RSPT_DUC_CNT             -- 경로공제수
                        ,PATH_DUC_AMT             -- 경로우대공제액
                        ,HINDR_CNT                 -- 장애자수
                        ,HIND_DUC_AMT              -- 장애인공제액
                        ,WOMN_DUC_AMT              -- 부녀자공제액
                        ,BRED_CNT                 -- 자녀양육수
                        ,BRED_DUC_AMT             -- 자녀양육공제액
                        ,MULT_CHILD_ADD_DUC_CNT -- 다자녀추가공제수
                        ,MULT_CHILD_ADD_DUC_AMT   -- 다자녀추가공제액
                        ,CHDBIRTH_DUC_CNT         -- 출산입양공제수
                        ,CHDBIRTH_DUC_AMT         -- 출산공제금액
                        ,SINGLE_PARENT_DUC_AMT         -- 한부모공제금액

                        ,NPN_DUC_AMT             -- 국민연금공제액
                        ,NPN_DUC_OBJ_AMT         -- 국민연금보험료공제대상금액(@VER.2018_2)
                        ,NPN_INSU_AMT             -- 사학연금공제액
                        ,NPN_INSU_DUC_OBJ_AMT     -- 사학연금공제대상금액(@VER.2018_2)
                        ,PUBPERS_PENS_DUC_AMT      -- 공무원연금공제액
                        ,PUBPERS_PENS_DUC_OBJ_AMT  -- 공무원연금공제대상금액(@VER.2018_2)
                        ,MILITARY_PENS_DUC_AMT     -- 군인연금공제액
                        ,MILITARY_PENS_DUC_OBJ_AMT -- 군인연금공제대상금액(@VER.2018_2)

                        ,RETI_PENS_EARN_DUC_AMT     -- 퇴직연금소득공제액
                        ,RETI_SCI_PENS_EARN_DUC_AMT -- 퇴직연금소득공제액
                        ,SPCL_DUC_HANDICAP_INSU_AMT         -- 특별공제장애인전용보장성보험료
                        ,SPCL_DUC_INSU_AMT         -- 특별공제보험료
                        ,SPCL_DUC_HFE_AMT             -- 특별공제의료비
                        ,SPCL_DUC_ED_AMT         -- 특별공제교육비
                        ,SPCL_DUC_HSFND_AMT     -- 특별공제주택자금액

                        ,SPCL_DUC_HOUS_ITT_AMT     -- 특별공제주택이자상환금액합계
                        ,SPCL_DUC_HOUS_ITT_AMT1     --특별공제주택이자상환15년미만
                        ,SPCL_DUC_HOUS_ITT_AMT2     --특별공제주택이자상환15년29년
                        ,SPCL_DUC_HOUS_ITT_AMT3     --특별공제주택이자상환30년이상
                        ,SPCL_DUC_HOUS_ITT_AMT4     --특별공제주택이자상환2012년고정금리(비거치식)
                        ,SPCL_DUC_HOUS_ITT_AMT5     --특별공제주택이자상환2012년일반
                        ,SPCL_DUC_HOUS_ITT_AMT6     --특별공제주택이자상환2015년고정금리(비거치식)
                        ,SPCL_DUC_HOUS_ITT_AMT7     --특별공제주택이자상환2015년고정금리(or비거치식)
                        ,SPCL_DUC_HOUS_ITT_AMT8     --특별공제주택이자상환2015년일반
                        ,SPCL_DUC_HOUS_ITT_AMT9     --특별공제주택이자상환2015년10이상고정금리(비거치식)

                        ,SPCL_DUC_MAGE_MV_AMT     -- 특별공제혼인이사액
                        ,SPCL_DUC_CNTRIB_AMT    -- 특별공제기부금액
                        ,STAD_DUC_AMT             -- 표준공제액
                        ,SBTR_EARN_AMT             -- 차감소득금액
                        ,PERS_PESN_SAV_DUC_AMT      -- 개인연금저축공제
                        ,PESN_SAV_DUC_AMT                 -- 연금저축공제
                        ,DUC_INME_EARN_DUC_AMT     -- 공제부금소득공제액
                        ,HOUS_SAV_DUC_AMT         -- 주택마련저축공제액
                        ,ICOMP_DUC_AMT             -- 투자조합공제액
                        ,CREDIT_CARD_DUC_AMT    -- 신용카드공제액
                        ,OSC_EARN_DUC_AMT         -- 우리사주소득공제액
                        ,LSTCS_SAV_DUC_AMT    --  장기주식형저축합계
                        ,LSTCS_SAV_DUC_AMT1    -- 장기주식형저축공제 1년차
                        ,LSTCS_SAV_DUC_AMT2    -- 장기주식형저축공제 2년차
                        ,LSTCS_SAV_DUC_AMT3    -- 장기주식형저축공제 3년차
                        ,TXSTD_AMT               -- 과세표준액
                        ,CAL_TAX                 -- 산출세액
                        ,RTXLW_OBJ_AMT           --조세조약감면대상세액@VER.2016_13
                        ,RTXLW                   --조세조약감면액

                        ,RTXLW_CURR_REDC_AMT     --현근무지 소득 조세조약감면액@VER.2016_14
                        ,RTXLW_ALD_REDC_AMT      --종전근무지 소득 조세조약감면액@VER.2016_14
                        ,REDC_TAX_TT             -- 감면세액계
                        ,LABOR_EARN_TDUC_AMT     -- 근로소득세액공제액
                        ,TXPYAS_TDUC_AMT         -- 납세조합세액공제액
                        ,LESE_LOAMT_TDUC_AMT             -- 주택차입금세액공제액
                        ,CNTRIB_POLITICS_TDUC_AMT     -- 기부정치자금세액공제액
                        ,FRNPAI_TDUC_AMT             -- 외국납부세액공제액
                        ,TDUC_TT                 -- 세액공제계
                        ,DETM_EARN_AMT             -- 결정소득액
                        ,DETM_FMTAX_AMT         -- 결정농특세액
                        ,DETM_IHTAX_AMT         -- 결정주민세액
                        ,DETM_TT_AMT             -- 결정세계액

                        ,ALD_BF_EARN_AMT         -- 기전소득액
                        ,ALD_BF_FMTAX_AMT         -- 기전농특세액
                        ,ALD_BF_IHTAX_AMT         -- 기전주민세액
                        ,ALD_BF_TT_AMT         -- 기전합계액
                        ,ALD_MA_EARN_AMT         -- 기주소득액
                        ,ALD_MA_FMTAX_AMT         -- 기주농특세액
                        ,ALD_MA_IHTAX_AMT         -- 기주주민세액
                        ,ALD_MA_TT_AMT         -- 기주합계액
                        ,ALD_SBTR_EARN_AMT     -- 기차감소득액
                        ,ALD_SBTR_FMTAX_AMT    -- 기차감농특세액
                        ,ALD_SBTR_IHTAX_AMT    -- 기차감주민세액

                        ,ALD_SBTR_TT_AMT             -- 차감합계액

                        ,RPRT_YN                 -- 신고여부

                        ,CURR_WK_FR_DT            -- 현근무시작일자
                        ,CURR_WK_TO_DT            -- 현근무종료일자
                        ,DEBIT_CARD_DUC_AMT       -- 직불카드공제액
                        ,SPCL_DUC_MNRT_AMT         -- 특별공제월세액공제금액
                        ,SPCL_DUC_HOUS_LOAMT_AMT1 -- 특별공제주택임차원리금대출기관상환액
                        ,SPCL_DUC_HOUS_LOAMT_AMT2 --특별공제주택임차원리금사인간상환액

                        ,SUBSCRP_SAV_DUC_AMT      -- 청약저축공제액
                        ,LABORR_HSSV_DUC_AMT   -- 근로자주택마련저축공제액
                        ,HOUS_SUBSCRP_GNR_SAV_DUC_AMT  -- 주택청약종합저축공제액
                        ,LNTM_HSSV_DUC_AMT    -- 장기주택마련저축공제액

                        ,SPCL_DUC_HINS_AMT           -- 특별공제건강보험료
                        ,SPCL_DUC_HINS_DUC_OBJ_AMT   -- 특별공제건강보험공제대상금액(@VER.2018_2)
                        ,SPCL_DUC_EINS_AMT           -- 특별공제고용보험료
                        ,SPCL_DUC_EINS_DUC_OBJ_AMT   -- 특별공제고용보험공제대상금액(@VER.2018_2)
                        ,SPCL_DUC_GUAR_INSU_AMT     --특별공제보장보험료

                        ,BF_DELAY_NOTAX_AMT_1   --전근무연장비과세액1
                        ,BF_CARE_NOTAX_AMT_1   --전근무보육비비과세액1
                        ,BF_RECH_NOTAX_AMT_1   --전근무연구비비과세1
                        ,BF_ETC_NOTAX_AMT_1     --전근무기타비과세액1
                        ,BF_APNT_NOTAX_AMT_1   --전근무지정비과세액1
                        ,BF_NOTAX_TT_AMT_1     --전근무비과세합계액1

                        ,BF_DELAY_NOTAX_AMT_2   --전근무연장비과세액2
                        ,BF_CARE_NOTAX_AMT_2   --전근무보육비비과세액2
                        ,BF_RECH_NOTAX_AMT_2   --전근무연구비비과세2
                        ,BF_ETC_NOTAX_AMT_2    --전근무기타비과세액2
                        ,BF_APNT_NOTAX_AMT_2   --전근무지정비과세액2
                        ,BF_NOTAX_TT_AMT_2     --전근무비과세합계액2

                        ,BF_DELAY_NOTAX_AMT_3  --전근무연장비과세액3
                        ,BF_CARE_NOTAX_AMT_3   --전근무보육비비과세액3
                        ,BF_RECH_NOTAX_AMT_3   --전근무연구비비과세3
                        ,BF_ETC_NOTAX_AMT_3    --전근무기타비과세액3
                        ,BF_APNT_NOTAX_AMT_3    --전근무지정비과세액3
                        ,BF_NOTAX_TT_AMT_3     --전근무비과세합계액3

                        ,FORE_TAX_RATE_YN     --외국인단일세율
                        ,LFSTS_ITT_RFND_AMT   --목돈안드는전세이자상환액

                        ,SPCL_DUC_GNR_LMT_AMT  -- 특별공제종합한도액
                        ,SPCL_DUC_GNR_LMT_EXCE_AMT  --특별공제종합한도초과액

                        ,POLITICS_TRSR_AMT  --정치자금
                        ,THYR_FLAW_CNTRIB_AMT   --법정기부금
                        ,CNTRIB_AMT_OSC_SOCT  --우리사주조합기부금
                        ,APNT_CNTRIB_AMT -- 지정기부금(종교+종교외)

                        ,SPCL_DUC_HANDICAP_HFE_AMT   --특별공제장애인의료비금액
                        ,SPCL_DUC_ETC_HFE_AMT   --특별공제기타의료비금액

                        ,SPCL_DUC_HANDICAP_EDU_AMT  --특별공제장애인교육비
                        ,SPCL_DUC_ETC_EDU_AMT  -- 특별공제기타교육비

                        ,BF_WK_REDC_TAX_AMT1  --종근무지1 감면액
                        ,BF_WK_REDC_TAX_AMT2  --종근무지2 감면액
                        ,BF_WK_REDC_TAX_AMT3  --종근무지3 감면액
                        ,BF_WK_REDC_TAX_TT_AMT --종근무지 감면액 합계
                        ,STXLW -- 조특법 30조 감면 세액 합계(종근무지만 존재함)
                        ,SMBIZ_BONUS_TAX -- 조특법 30조외 감면 세액 합계(종근무지만 존재함)(@VER.2019_6)

                        ,REDC_EARN_AMT  --현근무지 소득 감면액

                        ,BASE_DUC_CHILD_CNT            --기본공제자녀수
                        ,CHILD_TAXDUC_AMT              --자녀세액공제액
                        ,CNTRIB_AMT_CYOV_AMT           --기부금이월액
                        ,OSC_CNTRB_AMT                 --우리사주출연금액
                        ,OSC_CNTRIB_AMT                --우리사주기부금
                        ,LNTM_GATHER_INVST_SEC_SAV_AMT --장기집합투자증권저축액
                        ,SCI_TECH_PSN_PENS_DUC_OBJ_AMT --과학기술인연금공제대상금액
                        ,SCI_TECH_PSN_PENS_TAXDUC_AMT  --과학기술인연금세액공제액
                        ,RETI_PENS_DUC_OBJ_AMT         --퇴직연금공제대상금액
                        ,RETI_PENS_TAXDUC_AMT          --퇴직연금세액공제액
                        ,PNSV_DUC_OBJ_AMT              --연금저축공제대상금액
                        ,PNSV_TAXDUC_AMT               --연금저축세액공제액
                        ,GUARQL_INSU_DUC_OBJ_AMT       --보장성보험공제대상금액
                        ,GUARQL_INSU_TAXDUC_AMT        --보장성보험세액공제액
                        ,DSPSN_GUARQL_INSU_DUC_OBJ_AMT --장애인보장성보험공제대상금액 (2014재계산)
                        ,DSPSN_GUARQL_INSU_TAXDUC_AMT  --장애인보장성보험세액공제액 (2014재계산)
                        ,HFE_DUC_OBJ_AMT               --의료비공제대상금액
                        ,HFE_TAXDUC_AMT                --의료비세액공제액
                        ,EDAMT_DUC_OBJ_AMT             --교육비공제대상금액
                        ,EDAMT_TAXDUC_AMT              --교육비세액공제액
                        ,POLITICS_LMT_BLW_DUC_OBJ_AMT  --정치한도이하공제대상금액
                        ,POLITICS_LMT_BLW_TAXDUC_AMT   --정치한도이하세액공제액
                        ,POLITICS_LMT_EXCE_DUC_OBJ_AMT --정치한도초과공제대상금액
                        ,POLITICS_LMT_EXCE_TAXDUC_AMT  --정치한도초과세액공제액
                        ,FLAW_CNTRIB_DUC_OBJ_AMT       --법정기부공제대상금액
                        ,FLAW_CNTRIB_TAXDUC_AMT        --법정기부세액공제액
                        ,APNT_CNTRIB_DUC_OBJ_AMT       --지정기부공제대상금액
                        ,APNT_CNTRIB_TAXDUC_AMT        --지정기부세액공제액
                        ,STAD_TAXDUC_AMT               --표준세액공제액
                        ,MNRT_TAXDUC_AMT               --월세세액공제액
--                        ,SPCL_INCMDED_TT_AMT           --특별소득공제합계액
--                        ,REST_INCMDED_TT_AMT           --그외소득공제합계액
                        ,APNT_CNTRIB_RELI_OUT_OBJ_AMT   --지정기부(종교외) 세액공제대상금액 @VER.2016_8
                        ,APNT_CNTRIB_RELI_OUT_DUC_AMT   --지정기부(종교외) 세액공제금액 @VER.2016_8
                        ,APNT_CNTRIB_RELI_OBJ_AMT       --지정기부(종교) 세액공제대상금액 @VER.2016_8
                        ,APNT_CNTRIB_RELI_DUC_AMT       --지정기부(종교) 세액공제금액 @VER.2016_8
                        ,DUTY_INVENT_CMPS_AMT_NOTAX     --직무발명보상금비과세(@VER.2018_13)

                        ,INPT_ID                 -- 등록자ID
                        ,INPT_DTTM               -- 등록일시
                        ,INPT_IP                 -- 등록자IP

                        ,YRETXA_PART_FXD_YN      --분납신청확정여부(차감징수세액10만원이상시 3개월분납가능)@VER.2015 ZODEM
                        )
                VALUES (
                        REC.BIZR_DEPT_CD            --사업자부서코드
                        ,IN_YY                      --년도
                        ,IN_YRETXA_SEQ              --정산차수 @VER.2017_0
                        ,REC.RPST_PERS_NO           --대표개인번호
                        ,V_SETT_FG                  --정산구분
                        ,CASE WHEN V_SETT_FG = 'A031300001' THEN TO_CHAR(TO_NUMBER(IN_YY) + 1)||'02'
                              ELSE IN_YY||'12' END  --신고년월
                        ,REC.POSI_BREU_CD           --소속기관코드
                        ,REC.POSI_DEPT_CD           --소속부서코드

                        ,REC.KOR_NM                  --성명
                        ,REC.RES_NO                  --주민등록번호
                        ,REC.NATI_FG                 --국적코드
                        ,REC.RSD_FG                  --거주자구분코드
                        ,REC.RSD_NATI_FG             --거주지국코드

                        ,REC.STTS_FG                 --신분구분
                        ,REC.BIZTP_FG                --직종구분
                        ,REC.WKSP_FG                 --직렬구분
                        ,REC.LVLPT_FG                --급류구분
                        ,REC.WKGD_CD                 --직급코드
                        ,REC.STEP_FG                 --호봉구분
                        ,REC.CWK_YCNT                --근속년수

                        ,'N'                         --근로장학생(Y=근로장학생,N=일반근로자)
                        ,REC.HOUSEHOLDER_YN          --세대주여부

                        ,REC.REDC_FR_DT               --감면시작일자
                        ,REC.REDC_TO_DT               --감면종료일자
                        ,V_CURR_SITE_SALY             -- 주근무급여액
                        ,V_CURR_SITE_BONUS_AMT        -- 주근무상여액
                        ,V_CURR_SITE_DETM_BONUS_AMT   --주근무인정상여액
                        ,V_CURR_SITE_SALY + V_CURR_SITE_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT  -- 주근무합계액

                        ,V_BF_WK_FIRM_NM_1             -- 전근무상호명
                        ,V_BF_WK_FR_DT_1             -- 전근무시작일자1
                        ,V_BF_WK_TO_DT_1             -- 전근무종료일자1
                        ,V_BF_REDC_FR_DT_1             -- 전근무 감면시작일자1
                        ,V_BF_REDC_TO_DT_1             -- 전근무 감면종료일자1

                        ,V_BF_WK_BIZR_NO_1             -- 전근무번호
                        ,V_BF_SITE_SALY_AMT_1         -- 전근무급여액
                        ,V_BF_SITE_BONUS_AMT_1         -- 전근무상여액
                        ,V_BF_SITE_DETM_BONUS_AMT_1    --전근무인정상여액

                        ,V_BF_WK_FIRM_NM_2             -- 전근무상호2명
                        ,V_BF_WK_FR_DT_2             -- 전근무시작일자2
                        ,V_BF_WK_TO_DT_2             -- 전근무종료일자2
                        ,V_BF_REDC_FR_DT_2             -- 전근무 감면시작일자2
                        ,V_BF_REDC_TO_DT_2             -- 전근무 감면종료일자2

                        ,V_BF_WK_BIZR_NO_2             -- 전근무번호2
                        ,V_BF_SITE_SALY_AMT_2         -- 전근무급여2액
                        ,V_BF_SITE_BONUS_AMT_2         -- 전근무상여2액
                        ,V_BF_SITE_DETM_BONUS_AMT_2    --전근무인정상여액2

                        ,V_BF_WK_FIRM_NM_3             -- 전근무상호3명
                        ,V_BF_WK_FR_DT_3             -- 전근무시작일자3
                        ,V_BF_WK_TO_DT_3             -- 전근무종료일자3
                        ,V_BF_REDC_FR_DT_3             -- 전근무 감면시작일자3
                        ,V_BF_REDC_TO_DT_3             -- 전근무 감면종료일자3

                        ,V_BF_WK_BIZR_NO_3             -- 전근무번호3
                        ,V_BF_SITE_SALY_AMT_3         -- 전근무급여3액
                        ,V_BF_SITE_BONUS_AMT_3         -- 전근무상여3액
                        ,V_BF_SITE_DETM_BONUS_AMT_3    --전근무인정상여액3

                        ,V_BF_SITE_SALY_AMT + V_BF_SITE_BONUS_AMT + V_BF_SITE_DETM_BONUS_AMT + V_BF_STOCK_BUY_AMT -- 전근무합계액 + 주식매수선택이익금액

                        ,V_BF_SITE_SALY_AMT + V_CURR_SITE_SALY_AMT                           -- 급여총액
                        ,V_BF_SITE_BONUS_AMT + V_CURR_SITE_BONUS_AMT                         -- 상여총액
                        ,V_BF_SITE_DETM_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT               -- 인정상여금액
                        ,V_LABOR_EARN_TT_SALY_AMT                                            -- 과세합계
                        --V_BF_SITE_SALY_AMT + V_CURR_SITE_SALY_AMT + V_BF_SITE_BONUS_AMT + V_CURR_SITE_BONUS_AMT + V_BF_SITE_DETM_BONUS_AMT + V_CURR_SITE_DETM_BONUS_AMT-- 과세합계
                        ,0                             -- 국외비과세액
                        --,0                             -- 연장비과세액
                        ,V_DELAY_NOTAX_AMT             -- 연장비과세액(@VER.2018_3)
                        ,V_ETC_AMT_TAX                 -- 기타비과세액
                        ,V_RECH_ACT_AMT_TAX         -- 연구비비과세액
                        ,V_CHDBIRTH_CARE_AMT             -- 보육비비과세액
                        ,V_CURR_SITE_AMT_TAX_SETT_AMT+V_ETC_AMT_TAX  -- 비과세합계액

                        ,V_LABOR_EARN_AMT             -- 근로소득금액
                        ,V_LABOR_EARN_DUC_AMT         -- 근로소득공제액

                        ,V_SLF_DUC_AMT                 -- 본인공제액
                        ,V_WIFE_DUC_AMT             -- 배우자공제액
                        ,V_SPRT_OBJ_PSN_CNT         -- 부양자수
                        ,V_SPRT_FM_DUC_AMT             -- 부양공제
                        ,V_PATH_PREF_CNT_70         -- 경로공제수
                        ,V_PATH_PREF_DUC_AMT_70     -- 경로우대공제액
                        ,V_HINDR_CNT                 -- 장애자수
                        ,V_HANDICAP_DUC_AMT         -- 장애인공제액
                        ,V_WOMN_DUC_AMT             -- 부녀자공제
                        ,V_BRED_CNT_6                 -- 자녀양육수
                        ,V_CHILD_BREXPS_DUC_AMT_6     -- 자녀양육공제액 (2014재계산) 6세이하 자녀세액공제로 처리
                        ,V_MTI_CHILD_ADD_DUC_CNT     -- 다자녀추가공제수
                        ,V_MTI_CHILD_ADD_DUC_AMT     -- 다자녀추가공제액
                        ,V_ADOP_CHIL_CNT             --출산입양공제수
                        ,V_ADOP_CHIL_DUC_AMT         -- 출산공제금액 (2014재계산) 세액공제로 처리
                        ,V_SINGLE_PARENT_DUC_AMT   --한부모공제금액

                        ,V_NPN_INSU_AMT + V_ADD_NPN_INSU_AMT            -- 국민연금공제액
                        ,V_NPN_INSU_AMT + V_ADD_NPN_INSU_AMT            -- 국민연금보험료공제대상금액(@VER.2018_2)
                        ,V_PSCH_PESN_INSU_AMT + V_ADD_PSCH_PESN_INSU_AMT     -- 사학연금보험료
                        ,V_PSCH_PESN_INSU_AMT + V_ADD_PSCH_PESN_INSU_AMT     -- 사학연금공제대상금액(@VER.2018_2)
                        ,V_PUBPERS_PENS_AMT + V_ADD_PUBPERS_PENS_AMT         -- 공무원연금공제액
                        ,V_PUBPERS_PENS_AMT + V_ADD_PUBPERS_PENS_AMT         -- 공무원연금공제대상금액(@VER.2018_2)
                        ,V_MILITARY_PENS_INSU_AMT                            -- 군인연금공제액
                        ,V_MILITARY_PENS_INSU_AMT                            -- 군인연금공제대상금액(@VER.2018_2)

                        ,V_RETI_PESN_DUC_AMT                   -- 퇴직연금소득공제액(근로자퇴직급여보장법)
                        ,V_SCI_TECH_RETI_PESN_AMT              -- 퇴직연금소득공제액(과학기술인공제)
                        ,V_HANDICAP_INSU_PAY_INSU_AMT     -- 장애인보험료
                        ,V_GUAR_INSU_PAY_INSU_AMT         -- 특별공제보장보험료
                        ,V_HFE_DUC_AMT                 -- 특별공제의료비
                        ,V_EDU_DUC_AMT                 -- 특별공제교육비
                        ,V_HOUS_FUND_DUC_HAP_AMT         -- 특별공제주택자금액  (2010년수정)

                        ,V_HOUS_FUND_DUC_2_AMT         --특별공제주택이자상환금액합계
                        ,V_HOUS_MOG_ITT_1              --특별공제주택이자상환금액 15년 미만
                        ,V_HOUS_MOG_ITT_2              --특별공제주택이자상환금액 15년~29년
                        ,V_HOUS_MOG_ITT_3              --특별공제주택이자상환금액 30년 이상
                        ,V_HOUS_MOG_ITT_4              --특별공제주택이자상환2012년고정금리(비거치식)
                        ,V_HOUS_MOG_ITT_5              --특별공제주택이자상환2012년일반
                        -- 2015년 연말정산. @VER.2015
                        ,V_HOUS_MOG_ITT_6              --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 AND 비거치식
                        ,V_HOUS_MOG_ITT_7              --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 OR 비거치식
                        ,V_HOUS_MOG_ITT_8              --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 일반적인 차입
                        ,V_HOUS_MOG_ITT_9              --장기주택저당차입금이자2015년 이후 차입분. 10년 이상~15년미만. 고정금리 OR 비거치식

                        ,0                             -- 특별공제혼인이사액
                        ,V_CNTRIB_DUC_SUM_AMT          -- 특별공제기부금액
                        ,V_STAD_DUC_AMT             -- 표준공제액
                        ,V_SBTR_EARN_AMT             -- 차감소득금액
                        ,V_PERS_PESN_SAV_DUC_AMT    -- 개인연금저축공제
                        ,V_PESN_SAV_DUC_AMT            -- 연금저축공제
                        ,V_CO_DUC_AMT                 -- 공제부금소득공제액
                        ,V_HSSV_AMT                    -- 주택저축공제액
                        ,V_ICOMP_FINC_DUC_AMT        -- 투자조합공제액
                        ,V_CREDIT_DUC_AMT            -- 신용카드공제액
                        ,0                             -- 우리사주소득공제액
                        ,V_LNTM_STCS_SAV_DUC_AMT     -- 장기주식형저축합계
                        ,V_LNTM_STCS_SAV_DUC_AMT1    -- 장기주식형저축공제 1년차
                        ,V_LNTM_STCS_SAV_DUC_AMT2    -- 장기주식형저축공제 2년차
                        ,V_LNTM_STCS_SAV_DUC_AMT3    -- 장기주식형저축공제 3년차
                        ,V_GNR_EARN_TAX_STAD_AMT    -- 과세표준액
                        ,V_CAL_TDUC                    -- 산출세액
                        ,V_RTXLW_OBJ_AMT           --조세조약감면대상세액@VER.2016_13
                        ,V_RTXLW                   --조세조약감면액
                        ,V_RTXLW_CURR_REDC_AMT     --현근무지 소득 조세조약감면액@VER.2016_14
                        ,V_RTXLW_ALD_REDC_AMT      --종전근무지 소득 조세조약감면액@VER.2016_14
                        ,V_REDC_TAX_TT             -- 감면세액계
                        ,V_LABOR_EARN_TDUC_DUC_AMT    -- 근로소득세액공제액
                        ,0                            -- 납세조합세액공제액
                        ,V_UN_MINT_HOUS_ITT_RFND_AMT -- 주택차입금세액공제액
                        ,V_POLITICS_CNTRIB_TDUC_DUC -- 기부정치자금세액공제액
                        ,0                             -- 외국납부세액공제액
                        ,V_TDUC_DUC_TT_AMT            -- 세액공제계
                        ,V_DETM_INCOME_TAX             -- 결정소득액
                        ,V_DETM_FMTAX_AMT            -- 결정농특세액(주택차입금,투자조합공제액_더새서 20%)
                        ,V_DETM_INHAB_TAX             -- 결정주민세액
                        ,V_DETM_INCOME_TAX + V_DETM_FMTAX_AMT + V_DETM_INHAB_TAX     -- 결정합계액
                        ,V_BF_SITE_INCOME_TAX          -- 기전소득액
                        ,V_BF_SITE_FMTAX             -- 기전농특세액@VER.2017_21
                        ,V_BF_SITE_INHAB_TAX         -- 기전주민세액
                        ,V_BF_SITE_INCOME_TAX + V_BF_SITE_INHAB_TAX        -- 기전합계액
                        ,V_INCOME_TAX                 -- 기주소득액
                        ,0                             -- 기주농특세액
                        ,V_INHAB_TAX                 -- 기주주민세액
                        ,V_INCOME_TAX + V_INHAB_TAX -- 기주합계액
                        ,V_SBTR_COLT_INCOME_TAX     -- 기차감소득액
                        ,V_SBTR_COLT_FMTAX_TAX    -- 기차감농특세액
                        ,V_SBTR_COLT_INHAB_TAX        -- 기차감주민세액
                        ,V_SBTR_COLT_INCOME_TAX + V_SBTR_COLT_FMTAX_TAX + V_SBTR_COLT_INHAB_TAX     -- 차감합계액

                        ,'0'                     -- 신고여부

                        ,V_CURR_WK_FR_DT        -- 현근무시작일자
                        ,V_CURR_WK_TO_DT        -- 현근무종료일자
                        ,0                     -- 직불카드공제금액
                        ,V_MM_TAX_AMT                       -- 특별공제월세액공제금액

                        ,V_HOUS_LOAMT_AMT1          --특별공제주택임차원리금대출기관상환액
                        ,V_HOUS_LOAMT_AMT2            --특별공제주택임차원리금사인간상환액

                        ,V_SUBS_SAV                            -- 청약저축
                        ,V_LABORR_HSSV                       -- 근로자주택마련저축
                        ,V_HOUS_SUBS_GNR_SAV            -- 주택청약종합저축
                        ,V_LNTM_HSSV                           -- 장기주택마련저축

                        ,V_PESN_HINS_AMT + V_HINS_AMT   -- 특별공제건강보험료
                        ,V_PESN_HINS_AMT + V_HINS_AMT   -- 특별공제건강보험공제대상금액(@VER.2018_2)
                        ,V_PESN_EINS_AMT + V_EINS_AMT   -- 특별공제고용보험료
                        ,V_PESN_EINS_AMT + V_EINS_AMT   -- 특별공제고용보험공제대상금액(@VER.2018_2)
                        ,V_GUAR_INSU_PAY_INSU_AMT     --보장성보험,

                        ,V_BF_SITE_DELAY_NOTAX_AMT_1  --전근무지 연장비과세액1
                        ,V_BF_SITE_CARE_NOTAX_AMT_1   --전근무지 보육비과세1
                        ,V_BF_SITE_RECH_NOTAX_AMT_1   --전근무지 연구비과세1
                        --,V_BF_SITE_ETC_NOTAX_AMT_1    --전근무지 기타비과세1
                        --> 기타비과세컬럼을 수련보조수당비과세로 사용....
                        ,V_BF_SITE_TRAING_ASSI_ALLOW_1
                        ,V_BF_SITE_APNT_NOTAX_AMT_1    --전근무지 지정비과세1
                        --영수증에 표시되는 항목만 합산한다...2014.2.
                        ,V_BF_SITE_DELAY_NOTAX_AMT_1 + V_BF_SITE_CARE_NOTAX_AMT_1 + V_BF_SITE_RECH_NOTAX_AMT_1+V_BF_SITE_TRAING_ASSI_ALLOW_1
                        --,V_BF_SITE_DELAY_NOTAX_AMT_1 + V_BF_SITE_CARE_NOTAX_AMT_1 + V_BF_SITE_RECH_NOTAX_AMT_1 +V_BF_SITE_ETC_NOTAX_AMT_1 +V_BF_SITE_APNT_NOTAX_AMT_1

                        ,V_BF_SITE_DELAY_NOTAX_AMT_2   --전근무지 연장비과세액2
                        ,V_BF_SITE_CARE_NOTAX_AMT_2    --전근무지 보육비과세2
                        ,V_BF_SITE_RECH_NOTAX_AMT_2    --전근무지 연구비과세2
                        --,V_BF_SITE_ETC_NOTAX_AMT_2     --전근무지 기타비과세2
                        --> 기타비과세컬럼을 수련보조수당비과세로 사용....
                        ,V_BF_SITE_TRAING_ASSI_ALLOW_2
                        ,V_BF_SITE_APNT_NOTAX_AMT_2    --전근무지 지정비과세2
                        --영수증에 표시되는 항목만 합산한다...2014.2.
                        ,V_BF_SITE_DELAY_NOTAX_AMT_2 + V_BF_SITE_CARE_NOTAX_AMT_2 + V_BF_SITE_RECH_NOTAX_AMT_2+V_BF_SITE_TRAING_ASSI_ALLOW_2
                        --,V_BF_SITE_DELAY_NOTAX_AMT_2 + V_BF_SITE_CARE_NOTAX_AMT_2 + V_BF_SITE_RECH_NOTAX_AMT_2 + V_BF_SITE_ETC_NOTAX_AMT_2+ V_BF_SITE_APNT_NOTAX_AMT_2

                        ,V_BF_SITE_DELAY_NOTAX_AMT_3   --전근무지 연장비과세액3
                        ,V_BF_SITE_CARE_NOTAX_AMT_3    --전근무지 보육비과세3
                        ,V_BF_SITE_RECH_NOTAX_AMT_3    --전근무지 연구비과세3
                        --,V_BF_SITE_ETC_NOTAX_AMT_3     --전근무지 기타비과세3
                        ,V_BF_SITE_TRAING_ASSI_ALLOW_3
                        ,V_BF_SITE_APNT_NOTAX_AMT_3    --전근무지 지정비과세3
                        --영수증에 표시되는 항목만 합산한다...2014.2.
                        ,V_BF_SITE_DELAY_NOTAX_AMT_3 + V_BF_SITE_CARE_NOTAX_AMT_3 + V_BF_SITE_RECH_NOTAX_AMT_3+V_BF_SITE_TRAING_ASSI_ALLOW_3
                        --,V_BF_SITE_DELAY_NOTAX_AMT_3 + V_BF_SITE_CARE_NOTAX_AMT_3 + V_BF_SITE_RECH_NOTAX_AMT_3 + V_BF_SITE_ETC_NOTAX_AMT_3+V_BF_SITE_APNT_NOTAX_AMT_3     --전근무지 기타비과세3

                        ,REC.FORE_TAX_RATE_YN  --외국인단일세율
                        ,V_LFSTS_ITT_RFND_AMT --목돈안드는전세이자상환액

                        ,V_DUC_MAX_AMT    --특별공제종합한도액
                        ,V_DUC_MAX_OVER_AMT  --특별공제종합한도초과액

                        ,V_CNTRIB_DUC_SUM_AMT20 --정치자금 기부금
                        ,V_CNTRIB_DUC_SUM_AMT10 --법정기부금
                        ,V_CNTRIB_DUC_SUM_AMT42  --우리사주조합기부금
                        ,V_CNTRIB_DUC_SUM_AMT4041 --지정기부금(종교+종교외)

                        ,V_HAND_DUC_HFE     --특별공제장애인의료비금액
                        ,V_DUC_MAX_HFE_AMT   --특별공제 본인+기타의료비금액

                        ,V_HANDICAP_SPCL_EDU_AMT --장애인교육비
                        ,V_DUC_MAX_EDU_AMT --교육비공제(장애인제외)

                        ,V_BF_SITE_STXLW_NOTAX_1+V_BF_SITE_RTXLW_NOTAX_1  -- 종근무지1 감면세액
                        ,V_BF_SITE_STXLW_NOTAX_2+V_BF_SITE_RTXLW_NOTAX_2  -- 종근무지2 감면세액
                        ,V_BF_SITE_STXLW_NOTAX_3+V_BF_SITE_RTXLW_NOTAX_3  -- 종근무지3 감면세액
                        ,V_BF_SITE_STXLW_NOTAX_1+V_BF_SITE_RTXLW_NOTAX_1
                         +V_BF_SITE_STXLW_NOTAX_2+V_BF_SITE_RTXLW_NOTAX_2
                         +V_BF_SITE_STXLW_NOTAX_3+V_BF_SITE_RTXLW_NOTAX_3-- 종근무지 감면세액 합계

                        ,V_BF_SITE_STXLW_TAX -- 조특법 30조 감면 액(종근무지만 존재함)
                        ,V_BF_SITE_SMBIZ_BONUS_TAX -- 조특법 30조외 감면 액(종근무지만 존재함)(@VER.2019_6)

                        ,V_RTXLW_AMT1  --현근무지 소득 감면액

                        ,v_BASE_DUC_CHILD_CNT            --기본공제자녀수
                        ,v_CHILD_TAXDUC_AMT              --자녀세액공제액
                        ,v_CNTRIB_AMT_CYOV_AMT           --기부금이월액
                        ,v_OSC_CNTRB_AMT                 --우리사주출연금액
                        ,v_OSC_CNTRIB_AMT                --우리사주기부금
                        ,v_INVST_SEC_SAV_AMT             --장기집합투자증권저축액
                        ,v_SCI_DUC_OBJ_AMT               --과학기술인연금공제대상금액
                        ,v_SCI_TAXDUC_AMT                --과학기술인연금세액공제액
                        ,v_RETI_PENS_DUC_OBJ_AMT         --퇴직연금공제대상금액
                        ,v_RETI_PENS_TAXDUC_AMT          --퇴직연금세액공제액
                        ,v_PNSV_DUC_OBJ_AMT              --연금저축공제대상금액
                        ,v_PNSV_TAXDUC_AMT               --연금저축세액공제액
                        ,v_GUARQL_INSU_DUC_OBJ_AMT       --보장성보험공제대상금액
                        ,v_GUARQL_INSU_TAXDUC_AMT        --보장성보험세액공제액
                        ,V_DSP_GUARQL_INSU_DUC_OBJ_AMT   --장애인보장성보험공제대상금액 (2014재계산)
                        ,V_DSP_GUARQL_INSU_TAXDUC_AMT    --장애인보장성보험세액공제액(2014재계산)
                        ,v_HFE_DUC_OBJ_AMT               --의료비공제대상금액
                        ,v_HFE_TAXDUC_AMT                --의료비세액공제액
                        ,v_EDAMT_DUC_OBJ_AMT             --교육비공제대상금액
                        ,v_EDAMT_TAXDUC_AMT              --교육비세액공제액
                        ,v_POLITICS_BLW_DUC_OBJ_AMT      --정치한도이하공제대상금액
                        ,v_POLITICS_BLW_TAXDUC_AMT       --정치한도이하세액공제액
                        ,v_POLITICS_EXCE_DUC_OBJ_AMT     --정치한도초과공제대상금액
                        ,v_POLITICS_EXCE_TAXDUC_AMT      --정치한도초과세액공제액
                        ,v_FLAW_CNTRIB_DUC_OBJ_AMT       --법정기부공제대상금액
                        ,v_FLAW_CNTRIB_TAXDUC_AMT        --법정기부세액공제액
                        --,v_APNT_CNTRIB_DUC_OBJ_AMT       --지정기부공제대상금액
                        --,v_APNT_CNTRIB_TAXDUC_AMT        --지정기부세액공제액
                        ,NVL(V_APNT_CNTRIB40_DUC_OBJ_AMT, 0) + NVL(V_APNT_CNTRIB41_DUC_OBJ_AMT, 0) --지정기부공제대상금액
                        ,NVL(V_APNT_CNTRIB40_TAXDUC_AMT, 0) + NVL(V_APNT_CNTRIB41_TAXDUC_AMT, 0)   --지정기부세액공제액
                        ,v_STAD_TAXDUC_AMT               --표준세액공제액
                        ,v_MNRT_TAXDUC_AMT               --월세세액공제액
--                        ,v_SPCL_INCMDED_TT_AMT           --특별소득공제합계액
--                        ,v_REST_INCMDED_TT_AMT           --그외소득공제합계액
                        ,V_APNT_CNTRIB40_DUC_OBJ_AMT      --지정기부(종교외) 세액공제대상금액 @VER.2016_8
                        ,V_APNT_CNTRIB40_TAXDUC_AMT       --지정기부(종교외) 세액공제금액 @VER.2016_8
                        ,V_APNT_CNTRIB41_DUC_OBJ_AMT      --지정기부(종교) 세액공제대상금액 @VER.2016_8
                        ,V_APNT_CNTRIB41_TAXDUC_AMT       --지정기부(종교) 세액공제금액 @VER.2016_8
                        ,V_DUTY_INVENT_CMPS_AMT_NOTAX     --직무발명보상금비과세(@VER.2018_13)

                        ,IN_INPT_ID  -- 등록자ID
                        ,SYSDATE     -- 등록일시
                        ,IN_INPT_IP  -- 등록자IP

                        ,CASE WHEN REC.YRETXA_PART_APLY_YN = 'Y'
                                   AND (V_SBTR_COLT_INCOME_TAX + V_SBTR_COLT_FMTAX_TAX + V_SBTR_COLT_INHAB_TAX)>=100000
                              THEN 'Y'
                              ELSE 'N'
                         END --분납신청확정여부(차감징수세액합계액이 10만원이상이고 분납신청했을 경우)@VER.2015 ZODEM
                        )
                       ;
            END IF;


/* @VER.2016_10 표준세액공제 적용자 기부금 이월처리.*/
            IF V_STAD_TAXDUC_AMT > 0 THEN
               IF IN_SETT_FG = 'A031300003' THEN
                   /* 시뮬레이션계산인 경우*/
                   UPDATE PAYM436 T /* 기부금 이월(시뮬)*/
                      SET T.CNTRIB_GONGAMT = 0
                         ,T.CNTRIB_OVERAMT = T.CNTRIB_GIAMT - NVL(T.CNTRIB_PREAMT, 0)
                    WHERE T.YY = IN_YY
                      AND T.SETT_FG = V_SETT_FG
                      AND T.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                      AND T.RPST_PERS_NO = REC.RPST_PERS_NO
                      AND T.CNTRIB_DESTAMT = 0   /* 소멸자료가 아닌것 */
                      AND T.CNTRIB_TYPE_CD <> 'A032400002' /* 정치자금 기부금제외 */
                    ;
                ELSE
                   /* 연말정산 계산인 경우*/
                   UPDATE PAYM432 T /* 기부금 이월*/
                      SET T.CNTRIB_GONGAMT = 0
                         ,T.CNTRIB_OVERAMT = T.CNTRIB_GIAMT - NVL(T.CNTRIB_PREAMT, 0)
                    WHERE T.YY           = IN_YY
                      AND T.YRETXA_SEQ   = IN_YRETXA_SEQ /*@VER.2017_0*/
                      AND T.SETT_FG      = V_SETT_FG
                      AND T.BIZR_DEPT_CD = IN_BIZR_DEPT_CD
                      AND T.RPST_PERS_NO = REC.RPST_PERS_NO
                      AND T.CNTRIB_DESTAMT = 0 /* 소멸자료가 아닌것 */
                      AND T.CNTRIB_TYPE_CD <> 'A032400002' /* 정치자금 기부금제외 */
                    ;
                END IF;
            END IF;


/* 다음 대상자 계산을 위해 변수 초기화 */

            V_PRE_RPST_PERS_NO       := REC.RPST_PERS_NO ;

            --V_RPST_PERS_NO                          := NULL;

            V_SPRT_OBJ_PSN_CNT                      := 0;      --부양대상자수
            V_HINDR_CNT                             := 0;      --장애인수
            V_PATH_PREF_CNT_70                      := 0;      --경로우대70세상대상자수
            V_BRED_CNT_6                            := 0;      --6세이하양육대상자수
            V_BRED_EDU_CNT_6                        := 0;      --교육비취학전아동수
            V_ADOP_CHIL_CNT                         := 0;      --출산,입양대상자수

            V_MTI_CHILD_ADD_DUC_CNT                 := 0;      --다자녀추가공제자수
            V_STD_CNT                               := 0;      --교육비초중고등학교인원수
            V_LRG_STD_CNT                           := 0;      --교육비대학공납금인원수

            V_SLF_DUC_AMT                           := 0;      --본인공제
            V_WIFE_DUC_AMT                          := 0;      --배우자공제액
            V_SPRT_FM_DUC_AMT                       := 0;      --부양자공제금액
            V_HANDICAP_DUC_AMT                      := 0;      --장애자공제금액
            V_PATH_PREF_DUC_AMT_70                  := 0;      --경로우대공제금액70세
            V_CHILD_BREXPS_DUC_AMT_6                := 0;      --자녀양육비공제금액
            V_WOMN_DUC_AMT                          := 0;      --부녀자공제액
            V_MTI_CHILD_ADD_DUC_AMT                 := 0;      --다자녀추가공제금액
            V_ADOP_CHIL_DUC_AMT                     := 0;      --출산입양자공제

            V_CURR_SITE_SALY_AMT                    := 0;      --현근무지급여액
            V_CURR_SITE_AMT_TAX_SETT_AMT            := 0;      --현근무지비과세정산액

            V_BF_SITE_SALY_AMT                      := 0;      --전근무지급여액
            V_BF_SITE_BONUS_AMT                     := 0;      --전근무지상여액
            V_BF_SITE_DETM_BONUS_AMT                := 0;      --전근무지인정상여액
            V_BF_SITE_INCOME_TAX                    := 0;      --전근무지소득세
            V_BF_SITE_INHAB_TAX                     := 0;      --전근무지주민세

            V_LABOR_EARN_TT_SALY_AMT                := 0;      --근로소득총급여액
            V_LABOR_EARN_DUC_AMT                    := 0;      --근로소득공제금액
            V_LABOR_EARN_AMT                        := 0;      --근로소득금액
            V_PSCH_PESN_INSU_AMT                    := 0;      --종(전)근무지사학연금합산
            V_ADD_PSCH_PESN_INSU_AMT                := 0;      --현근무지사학연금합산
            V_NPN_INSU_AMT                          := 0;      --종(전)근무지국민연금합산
            V_ADD_NPN_INSU_AMT                      := 0;      --현근무지국민연금합산
            V_MILITARY_PENS_INSU_AMT                := 0;      --종(전)근무지군인연금합산

            V_PUBPERS_PENS_AMT                      := 0;      --종(전)근무지공무원연금
            V_ADD_PUBPERS_PENS_AMT                  := 0;      --현근무지공무원연금합산

            V_HINS_AMT                              := 0;      --주(현)근무지건강보험료합산
            V_EINS_AMT                              := 0;      --주(현)근무지고용보험료합산
            V_SPCL_DUC_INSU_AMT                     := 0;      --특별공제보험료합산
            V_HFE_DUC_AMT                           := 0;      --특별공제의료비합산
            V_EDU_DUC_AMT                           := 0;      --특별공제교육비합산
            V_HOUS_LOAMT_AMT1                       := 0;      --특별공제주택임차원리금대출기관상환액
            V_HOUS_LOAMT_AMT2                       := 0;      --특별공제주택임차원리금사인간상환액
            V_HOUS_FUND_DUC_2_AMT                   := 0;      --특별공제주택이자상환금액합계
            V_SPCL_DUC_AMT                          := 0;      --특별공제합산

            V_STAD_DUC_AMT                          := 0;      --표준공제
            V_PERS_PESN_SAV_DUC_AMT                 := 0;      --개인연금저축공제
            V_PESN_SAV_DUC_AMT                      := 0;      --연금저축공제
            V_ICOMP_FINC_DUC_AMT                    := 0;      --투자조합출자공제금액
            V_CREDIT_DUC_AMT                        := 0;      --신용카드공제금액
            V_GNR_EARN_TAX_STAD_AMT                 := 0;      --종합소득과세표준금액
            V_GNR_EARN_TAX_STAD_AMT_2               := 0;      --농특세를위한과세표준금액
            V_GNR_EARN_TAX_STAD_AMT_3               := 0;      --농특세를위한이전과세표준금액
            V_CAL_TDUC                              := 0;      --산출세액
            V_LABOR_EARN_TDUC_DUC_AMT               := 0;      --세액공제근로소득세액공제
            V_POLITICS_CNTRIB_TDUC_DUC              := 0;      --정치기부금세액공제

            V_TDUC_DUC_TT_AMT                       := 0;      --세액공제계
            V_DETM_INCOME_TAX                       := 0;      --결정소득세
            V_DETM_INHAB_TAX                        := 0;      --결정주민세
            V_DETM_FMTAX_AMT                        := 0;      --결정농특세
            V_CAL_TDUC1                             := 0;      --투자조합출자공제전산출세액
            V_CAL_TDUC2                             := 0;      --투자조합출자공제후산출세액
            V_SBTR_COLT_FMTAX_TAX                   := 0;      --차감농특세
            V_SBTR_COLT_INCOME_TAX                  := 0;      --차감소득세
            V_SBTR_COLT_INHAB_TAX                   := 0;      --차감주민세
            V_LABOR_TEMP_AMT                        := 0;      --임시근로소득
            V_SBTR_EARN_AMT                         := 0;      --차감근로소득
            V_CAL_TDUC_TEMP_AMT                     := 0;      --임시산출세액

            V_SLF_ELDR_HIND_HFE                     := 0;      --본인.65세이상자.
            V_HAND_DUC_HFE                          := 0;      --장애인의료비
            V_ETC_DUC_PSN_HFE                       := 0;      --그밖의공제대상자의료비
            V_SUBFER_MEDIPRC_HFE                    := 0;      --난임시술비 -- 2015 연말정산 추가 -- @VER.2015
            V_REAL_LOSS_MED_AMT                     := 0;      --실손의료비 합계 -- 2019 연말정산 추가 -- @VER.2019_4

            V_ETC_CARE_DUC_PSN_HFE                  := 0;      --추가공제자의 산후조리원 => 700만원 한도 적용을 위해 따로 관리 -- 2019 연말정산 추가 -- @VER.2019_9
            V_SLF_ELDR_HIND_CARE_HFE                := 0;      --추가공제자 이외(본인, 65세이상, 장애인, 난임시술비)의 대상자의 산후조리원 -- 2019 연말정산 추가 -- @VER.2019_9

            V_FLAW_CNTRIB_AMT                       := 0;      --정치자금기부금발생금액
            V_FLAW_CNTRIB_100_RATE_AMT              := 0;      --정치자금100%세액공제기부금발생금액
            V_FLAW_CNTRIB_15_RATE_AMT               := 0;      --정치자금15%세액공제기부금발생금액
            V_FLAW_CNTRIB_25_RATE_AMT               := 0;      --정치자금25%세액공제기부금발생금액
            V_LMT_CNTRIB_AMT                        := 0;      --기부금공제한도
            V_POLITICS_FUND_CNTRIB_AMT              := 0;      --기부금전액공제(법정기부금+진흥기금출연)
            V_PROM_GRP_CNTRIB_AMT                   := 0;      --기부금50%한도(조특법73)_특례기부금
            V_PROM_GRP_CNTRIB_2_AMT                 := 0;      --기부금우리사주발생금액

            V_ETC_CNTRIB_AMT                        := 0;      --기부금지정기부금(기타)

            V_CREDIT_USE_AMT                        := 0;      --신용카드등(전통시장,대중교통제외신용카드)
            V_CSH_RECPT_USE_AMT                     := 0;      --신용카드등(전통시장제외현금영수증)
            V_ACMY_GIRO_PAID_AMT                    := 0;      --신용카드등(학원비지로납부)


            V_CURR_SITE_SALY                        := 0;      --현근무지급여합계
            V_CURR_SITE_SALY1                       := 0;      --현근무지급여내역(PAYM440)
            V_CURR_SITE_SALY2                       := 0;      --현근무지추가급여(PAYM441)
            V_CURR_SITE_BONUS_AMT                   := 0;      --현근무지상여
            V_CURR_SITE_DETM_BONUS_AMT              := 0;      --현근무지인정상여
            V_ETC_AMT_TAX                           := 0;      --현근무지기타비과세합계(모범수당(국고),육아휴직수당,정액급식비(국고),정액급식비(기금),정액급식비(기성회),직급보조비(국고))
            V_RECH_ACT_AMT_TAX                      := 0;      --현근무지연구비과세합계
            V_CHDBIRTH_CARE_AMT                     := 0;      --현근무지보육비비과세합계
            V_INCOME_TAX                            := 0;      --현근무지소득세
            V_INHAB_TAX                             := 0;      --현근무지주민세

            V_GUAR_INSU_PAY_INSU_AMT                := 0;      --일반보장성보험료합산
            V_HANDICAP_INSU_PAY_INSU_AMT            := 0;      --장애인전용보장성보험합산
            V_SLF_EDU_AMT                           := 0;      --본인교육비_전액공제
            V_SCH_BF_CHILD_EDU_AMT                  := 0;      --취학전아동교육비
            V_SCH_EDU_AMT                           := 0;      --초중고교육비
            V_UNIV_PSN_EDU_AMT                      := 0;      --대학교교육비
            V_HANDICAP_SPCL_EDU_AMT                 := 0;      --장애인교육비_전액공제
            V_CO_DUC_AMT                            := 0;      --소기업공제부금소득공제
            V_LNTM_STCS_SAV_DUC_AMT                 := 0;      --장기주식형저축소득공제
            V_LNTM_STCS_SAV_DUC_AMT1                := 0;      --장기주식형저축소득공제_불입분의20%공제
            V_LNTM_STCS_SAV_DUC_AMT2                := 0;      --장기주식형저축소득공제_불입분의10%공제
            V_LNTM_STCS_SAV_DUC_AMT3                := 0;      --장기주식형저축소득공제_불입분의5%공제
            V_BASI_AMT_1                            := 0;
            V_BASI_AMT_2                            := 0;
            V_TRATE                                 := 0;
            V_HSSV_AMT                              := 0;      --주택마련저축공제
            V_CNT                                   := 0;
            V_BF_WK_FIRM_NM_CNT_2                   := NULL;      --전근무지상호2외갯수
            V_BF_WK_FIRM_NM_1                       := NULL;      --전근무지상호1
            V_BF_WK_FIRM_NM_2                       := NULL;      --전근무지상호2
            V_BF_WK_FIRM_NM_3                       := NULL;      --전근무지상호3
            V_BF_WK_BIZR_NO_1                       := NULL;      --전근무지사업번호1
            V_BF_WK_BIZR_NO_2                       := NULL;      --전근무지사업번호2
            V_BF_WK_BIZR_NO_3                       := NULL;      --전근무지사업번호3
            V_BF_WK_FR_DT_1                         := NULL;      --전근무지시작일자1
            V_BF_WK_FR_DT_2                         := NULL;      --전근무지시작일자2
            V_BF_WK_FR_DT_3                         := NULL;      --전근무지시작일자3
            V_BF_WK_TO_DT_1                         := NULL;      --전근무지종료일자1
            V_BF_WK_TO_DT_2                         := NULL;      --전근무지종료일자2
            V_BF_WK_TO_DT_3                         := NULL;      --전근무지종료일자3

            V_BF_REDC_FR_DT_1                       := NULL;      --전근무지감면시작일자1
            V_BF_REDC_FR_DT_2                       := NULL;      --전근무지감면시작일자2
            V_BF_REDC_FR_DT_3                       := NULL;      --전근무지감면시작일자3
            V_BF_REDC_TO_DT_1                       := NULL;      --전근무지감면종료일자1
            V_BF_REDC_TO_DT_2                       := NULL;      --전근무지감면종료일자2
            V_BF_REDC_TO_DT_3                       := NULL;      --전근무지감면종료일자3

            V_BF_SITE_SALY_AMT_1                    := 0;      --전근무지급여액1
            V_BF_SITE_BONUS_AMT_1                   := 0;      --전근무지상여액1
            V_BF_SITE_DETM_BONUS_AMT_1              := 0;      --전근무지인정상여액1
            V_BF_SITE_UN_TAX_EARN_AMT_1             := 0;      --전근무지비과세금액1
            V_BF_SITE_DELAY_NOTAX_AMT_1             := 0;      --전근무지연장비과세액1
            V_BF_SITE_CARE_NOTAX_AMT_1              := 0;      --전근무지보육비과세1
            V_BF_SITE_RECH_NOTAX_AMT_1              := 0;      --전근무지연구비과세1
            V_BF_SITE_ETC_NOTAX_AMT_1               := 0;      --전근무지기타비과세1
            V_BF_SITE_APNT_NOTAX_AMT_1              := 0;      --전근무지지정비과세1
            V_BF_SITE_TRAING_ASSI_ALLOW_1           := 0;      --전근무지수련보조수당비과세1
            V_BF_SITE_STXLW_NOTAX_1                 := 0;      --전근무지조특법30조소득세감면액1
            V_BF_SITE_RTXLW_NOTAX_1                 := 0;      --전근무지조세규약소득세감면액1

            V_BF_SITE_SALY_AMT_2                    := 0;      --전근무지급여액2
            V_BF_SITE_BONUS_AMT_2                   := 0;      --전근무지상여액2
            V_BF_SITE_DETM_BONUS_AMT_2              := 0;      --전근무지인정상여액2
            V_BF_SITE_UN_TAX_EARN_AMT_2             := 0;      --전근무지비과세금액2
            V_BF_SITE_DELAY_NOTAX_AMT_2             := 0;      --전근무지연장비과세액2
            V_BF_SITE_CARE_NOTAX_AMT_2              := 0;      --전근무지보육비과세2
            V_BF_SITE_RECH_NOTAX_AMT_2              := 0;      --전근무지연구비과세2
            V_BF_SITE_ETC_NOTAX_AMT_2               := 0;      --전근무지기타비과세2
            V_BF_SITE_APNT_NOTAX_AMT_2              := 0;      --전근무지지정비과세2
            V_BF_SITE_TRAING_ASSI_ALLOW_2           := 0;      --전근무지수련보조수당비과세2
            V_BF_SITE_STXLW_NOTAX_2                 := 0;      --전근무지조특법30조소득세감면액2
            V_BF_SITE_RTXLW_NOTAX_2                 := 0;      --전근무지조세규약소득세감면액2

            V_BF_SITE_SALY_AMT_3                    := 0;      --전근무지급여액3
            V_BF_SITE_BONUS_AMT_3                   := 0;      --전근무지상여액3
            V_BF_SITE_DETM_BONUS_AMT_3              := 0;      --전근무지인정상여액2
            V_BF_SITE_UN_TAX_EARN_AMT_3             := 0;      --전근무지비과세금액3
            V_BF_SITE_DELAY_NOTAX_AMT_3             := 0;      --전근무지연장비과세액3
            V_BF_SITE_CARE_NOTAX_AMT_3              := 0;      --전근무지보육비과세3
            V_BF_SITE_RECH_NOTAX_AMT_3              := 0;      --전근무지연구비과세3
            V_BF_SITE_ETC_NOTAX_AMT_3               := 0;      --전근무지기타비과세3
            V_BF_SITE_APNT_NOTAX_AMT_3              := 0;      --전근무지지정비과세3
            V_BF_SITE_TRAING_ASSI_ALLOW_3           := 0;      --전근무지수련보조수당비과세3
            V_BF_SITE_STXLW_NOTAX_3                 := 0;      --전근무지조특법30조소득세감면액3
            V_BF_SITE_RTXLW_NOTAX_3                 := 0;      --전근무지조세규약소득세감면액3


            V_SCI_TECH_RETI_PESN_AMT                := 0;      --퇴직연금과학기술인공제소득공제액
            V_RETI_PESN_AMT                         := 0;      --현퇴직연금액(근로자)
            V_PRE_RETI_PESN_AMT                     := 0;      --전근무지퇴직연금액(근로자)
            V_RETI_PESN_DUC_AMT                     := 0;      --퇴직연금근로자퇴직급여보장법공제액
            V_RETI_PESN_EARN_DUC_AMT                := 0;      --퇴직연금합산(과학기술인공제+근로자퇴직급여보장법)

            V_PESN_HINS_AMT                         := 0;      --전근무지건강보험료
            V_PESN_EINS_AMT                         := 0;      --전근무지고용보험료
            V_HOUS_MOG_ITT_1                        := 0;      --장기주택저당차입금이자15년미만
            V_HOUS_MOG_ITT_2                        := 0;      --장기주택저당차입금이자15년~29년이상
            V_HOUS_MOG_ITT_3                        := 0;      --장기주택저당차입금이자30년이상
            V_HOUS_MOG_ITT_4                        := 0;      --장기주택저당차입금이자2012년이후고정금리(비거치식)
            V_HOUS_MOG_ITT_5                        := 0;      --장기주택저당차입금이자2012년이후일반
            -- 2015 연말정산 추가 - @VER.2015
            V_HOUS_MOG_ITT_6                        := 0;      --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 AND 비거치식
            V_HOUS_MOG_ITT_7                        := 0;      --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 고정금리 OR 비거치식
            V_HOUS_MOG_ITT_8                        := 0;      --장기주택저당차입금이자2015년 이후 차입분. 15년 이상. 일반적인 차입
            V_HOUS_MOG_ITT_9                        := 0;      --장기주택저당차입금이자2015년 이후 차입분. 10년 이상~15년미만. 고정금리 OR 비거치식

            V_CNTRIB_DUC_TMP_AMT                    := 0;      --기부금금액공제
            V_BUSINESS_USE_AMT                      := 0;      --신용카드사업관련비용
            --V_SCHL_UNIF_AMT                       := 0;      --교육비교복구입비
            V_MEDI_LIMT_AMT                         := 0;      --의료비3%한도금액

            V_UN_MINT_HOUS_ITT_RFND_AMT             := 0;      --미분양주택이자상환액
            V_LABOR_TEMP_AMT2                       := 0;      --
            V_CURR_WK_FR_DT                         := NULL;      --현근무기간
            V_CURR_WK_TO_DT                         := NULL;      --현근무기간
            V_FR_DT                                 := NULL;      --임용일자
            V_TO_DT                                 := NULL;      --해임일자
            --2011년추가
            V_DEBIT_USE_AMT                         := 0;      --직불카드사용금액(전통시장제외)
            V_MM_TAX_AMT                            := 0;      --월세액
            V_HOUS_FUND_DUC_HAP_AMT                 := 0;      --주택임대차차입금원리금상환공제금액+월세액
            V_SUBS_SAV                              := 0;      --청약저축
            V_SUBS_SAV1                             := 0;      --2009년이전청약저축
            V_SUBS_SAV2                             := 0;      --2010년이후청약저축
            V_LABORR_HSSV                           := 0;      --근로자주택마련저축
            V_HOUS_SUBS_GNR_SAV                     := 0;      --주택청약종합저축
            V_LNTM_HSSV                             := 0;      --장기주택마련저축
            --V_COMP                                := 0;
            --V_CREDIT_HAP_AMT                      := 0;
            --기부금
            V_CNTRIB_DUC_AMT                        := 0;      --기부금공제금액
            V_CNTRIB_DUC_SUM_AMT                    := 0;      --기부금누적금액
            V_CNTRIB_DUC_SUM_AMT10                  := 0;      --법정기부금공제합계액
            V_CNTRIB_DUC_SUM_AMT20                  := 0;      --정치자금기부금공제합계액
            V_CNTRIB_DUC_SUM_AMT30                  := 0;      --특례기부금공제합계액
            V_CNTRIB_DUC_SUM_AMT42                  := 0;      --우리사주조합기부금공제합계액
            V_CNTRIB_DUC_SUM_AMT4041                := 0;      --지정기부금공제합계액(종교_종교외)
            V_CNTRIB_PREAMT                         := 0;      --기부금전년까지공제금액
            V_CNTRIB_GONGAMT                        := 0;      --기부금당년공제금액
            V_CNTRIB_DESTAMT                        := 0;      --기부금당년소멸금액
            V_CNTRIB_OVERAMT                        := 0;      --기부금당년이월금액
            V_APNT_CNTRIB_AMT                       := 0;      --종교단체지정기부금당년도공제,소멸,이월금액
            --주택자금
            V_HOUSEHOLDER_YN                        := 'N';      --세대주여부
            V_HOUS_SCALE_YN                         := 'N';      --국민주택규모(전용85제곱미터)이하여부
            V_BASI_MPRC_BLW                         := 'N';      --기준시가3억원이하여부
            V_HOUS_SEC_YN                           := 'N';      --저당차입금3개월이내차입여부
            V_HOUS_OWN_CNT                          := 0;      --연중소유주택수
            --조세조약세액감면관련
            V_RTXLW_OBJ_AMT                         := 0;      --조세조약세액감면 대상소득액
            V_RTXLW                                 := 0;      --조세조약세액감면액
            V_RTXLW_CURR_REDC_AMT                   := 0;      --조세조약 현근무지감면액
            V_RTXLW_ALD_REDC_AMT                    := 0;      --조세조약 종전근무지감면액
            V_RTXLW_AMT1                            := 0;      --감면기간내급여소득액
            V_RTXLW_AMT2                            := 0;      --감면기간내추가소득액
            V_RTXLW_AMT3                            := 0;      --종전근무지 조세조약 감면액
            V_REDC_TAX_TT                           := 0;      --감면세액계
            --2012년추가
            V_CREDIT_TRADIMARKE_USE_AMT             := 0;      --신용카드(전통시장사용액)
            V_CREDIT_TOT_USE_AMT                    := 0;      --신용카드총사용금액(신용카드+학원비+현금영수증)
            V_CREDIT_DUC_EXC_AMT                    := 0;      --신용카드공제제외금액
            V_CREDIT_DUC_POSS_AMT                   := 0;      --신용카드공제가능금액
            V_CREDIT_MINI_USE_AMT                   := 0;      --신용카드최저사용금액
            V_CREDIT_DUC_OVER_AMT                   := 0;      --신용카드공제한도초과금액
            V_CREDIT_DUC_ADD_AMT                    := 0;      --신용카드추가공제금액
            V_CNTRIB_DUC_SUM_AMT31                  := 0;      --공익법인기부신탁기부금공제합계액
            V_ICOMP_FINC_DUC_AMT2                   := 0;      --벤쳐투자조합출자공제금액(20%)2012년분
            V_CURR_SITE_INSUR_AMT                   := 0;      --현근무지4대보험료합계금액(외국인단일세율용)
            V_BF_SITE_INSUR_AMT                     := 0;      --전근무지4대보험료합계금액(외국인단일세율용)
            V_CURR_SITE_FO_NOTAX_AMT                := 0;      --현근무지식대,유류비과세합계금액(외국인단일세율용)
            V_BF_SITE_FO_NOTAX_AMT                  := 0;      --전근무지식대,유류비과세합계금액(외국인단일세율용)
            --------------
            --2013년
            V_CREDIT_PUBLIC_TRAF_AMT                := 0;      --신용카드(대중교통사용액):2013년추가
            V_SINGLE_PARENT_DUC_AMT                 := 0;      --한부모공제.2013추가

            V_CREDIT_DUC_ADD_AMT1                   := 0;      --신용카드추가공제금액(전통시장)
            V_CREDIT_DUC_ADD_AMT2                   := 0;      --신용카드추가공제금액(대중교통)
            V_CREDIT_DUC_ADD_AMT3                   := 0;      --신용카드추가공제금액(2013년비교상반기증가)
            V_CREDIT_DUC_ADD_AMT4                   := 0;      --신용카드추가공제금액(2014년비교하반기증가)
            V_ICOMP_FINC_DUC_AMT3                   := 0;      --벤쳐투자조합출자공제금액(종합소득30%한도)2013년분
            V_ICOMP_FINC_DUC_AMT2011                := 0;      --출자·투자금액의10%공제,벤쳐투자조합출자공제금액(종합소득30%한도)2011년분
            V_ICOMP_FINC_DUC_AMT2013                := 0;      --출자금액중2013년도분계산용,
            V_LFSTS_ITT_RFND_AMT                    := 0;      --목돈안드는전세이자상환액(40%)



            V_DUC_MAX_AMT                           := 0;      --소득공제종합한도금액2500만원
            V_DUC_MAX_OVER_AMT                      := 0;      --소득공제종합한도초과액
            V_DUC_MAX_OVER_TMP_AMT                  := 0;      --계산용임시변수

            --아래
            V_DUC_MAX_GUAR_INSU_AMT                 := 0;      --1.보장성보험료공제액--V_GUAR_INSU_PAY_INSU_AMT일반보장성보험료와동일.
            V_DUC_MAX_HFE_AMT                       := 0;      --2.의료비공제액(장애인제외)
            V_DUC_MAX_EDU_AMT                       := 0;      --3.교육비공제액(장애인특수교육비제외)
            V_DUC_MAX_HOUS_AMT                      := 0;      --4.주택자금공제액

            V_DUC_MAX_CNTRIB_AMT                    := 0;      --5.지정기부금2013년지출분공제액(이월분은제외)
            V_DUC_MAX_CNTRIB40_AMT                  := 0;      --종교외(40)지정기부금A032400006
            V_DUC_MAX_CNTRIB41_AMT                  := 0;      --종교(41)지정기부금A032400007
            V_DUC_MAX_CNTRIB40_OVERAMT              := 0;      --종교외(40)지정기부금이월금액
            V_DUC_MAX_CNTRIB41_OVERAMT              := 0;      --종교(41)지정기부금이월금액
            V_CNTRIB_DUC_SUM_AMT2                   := 0;      --기부금누적금액(올해이월금액제외분)

            --V_POLITICS_TRSR_AMT                   := 0;      --정치자금
            --V_THYR_FLAW_CNTRIB_AMT                := 0;      --법정기부금
            --V_CNTRIB_AMT_OSC_SOCT                 := 0;      --우리사주조합기부금
            --V_APNT_CNTRIB_AMT                     := 0;      --지정기부금

            V_DUC_MAX_CO_AMT                        := 0;      --6.소기업/소상공인공제부금공제액
            V_DUC_MAX_CREDIT_AMT                    := 0;      --7.신용카드사용공제액
            V_DUC_MAX_ICOMP_AMT                     := 0;      --8.투자조합출자소득공제액(2013년분)
            V_DUC_MAX_OSC_AMT                       := 0;      --9.우리사주출연금공제액:주식회사가아니므로실제적사용안함.

            V_BF_SITE_STXLW_AMT                     := 0;      --전근무지감면액합계:조특법30조.원금..
            V_BF_SITE_STXLW_TAX                     := 0;      --전근무지감면세액합계:조특법30조.최종감면금액
            V_BF_SITE_STXLW_AMT                     := 0;      --전근무지감면액합계:조특법30조.원금..
            V_BF_SITE_SMBIZ_BONUS_TAX               := 0;      --전근무지감면세액합계:조특법30조외.최종감면금액(@VER.2019_6)
            V_BF_SITE_SMBIZ_BONUS_AMT               := 0;      --전근무지감면세액합계:조세규약(@VER.2019_6)
            V_BF_SITE_REDC_TAX                      := 0;      --전근무지감면세액합계


--            V_MAN_CNT                               := 0;      --처리대상자수
            --V_SETT_FG                               := '';      --V_SETT_FG를대체하여시뮬레이션을A031300001:연말정산,A031300002:중도정산두가지값으로만변경.
            V_TMP_CNT                               := 0;      --임시카운트변수,
            V_TMP40_AMT                             := 0;      --임시변수
            V_TMP41_AMT                             := 0;      --임시변수
            V_TMP_AMT                               := 0;
            --------
--            V_PAYM451_YY                            := '';
--            V_PAYM450_YY                            := '';
--            V_PAYM452_YY                            := '';

            V_LOAN_DT                               := '';      --장기주택저당차입금차입일체크용.
            V_HOUS_MOG_LOAMT_2005_BF_YN             := '';      --장기주택저당차입금주택수체크용...

            V_ENT_DT                                := '';      --주택청약 가입일자



            /**  2014 추가 **/
            V_PAID_SPCLEX_TAX                       := 0;      --납부특례세액
            V_BASE_DUC_CHILD_CNT                    := 0;      --기본공제자녀수
            V_CHILD_TAXDUC_AMT                      := 0;      --자녀세액공제액
            V_CNTRIB_AMT_CYOV_AMT                   := 0;      --기부금이월액
            V_OSC_CNTRB_AMT                         := 0;      --우리사주출연금액
            V_OSC_CNTRIB_AMT                        := 0;      --우리사주기부금
            V_INVST_SEC_SAV_AMT                     := 0;      --장기집합투자증권저축액
            V_SCI_DUC_OBJ_AMT                       := 0;      --과학기술인연금공제대상금액
            V_SCI_TAXDUC_AMT                        := 0;      --과학기술인연금세액공제액
            V_RETI_PENS_DUC_OBJ_AMT                 := 0;      --퇴직연금공제대상금액
            V_RETI_PENS_TAXDUC_AMT                  := 0;      --퇴직연금세액공제액
            V_PNSV_DUC_OBJ_AMT                      := 0;      --연금저축공제대상금액
            V_PNSV_TAXDUC_AMT                       := 0;      --연금저축세액공제액
            V_GUARQL_INSU_DUC_OBJ_AMT               := 0;      --보장성보험공제대상금액
            V_GUARQL_INSU_TAXDUC_AMT                := 0;      --보장성보험세액공제액
            V_DSP_GUARQL_INSU_DUC_OBJ_AMT           := 0;      --장애인보장성보험공제대상금액 (2014재계산)
            V_DSP_GUARQL_INSU_TAXDUC_AMT            := 0;      --장애인보장성보험세액공제액 (2014재계산)
            V_HFE_DUC_OBJ_AMT                       := 0;      --의료비공제대상금액
            V_HFE_TAXDUC_AMT                        := 0;      --의료비세액공제액
            V_EDAMT_DUC_OBJ_AMT                     := 0;      --교육비공제대상금액
            V_EDAMT_TAXDUC_AMT                      := 0;      --교육비세액공제액
            V_POLITICS_BLW_DUC_OBJ_AMT              := 0;      --정치한도이하공제대상금액
            V_POLITICS_BLW_TAXDUC_AMT               := 0;      --정치한도이하세액공제액
            V_POLITICS_EXCE_DUC_OBJ_AMT             := 0;      --정치한도초과공제대상금액
            V_POLITICS_EXCE_TAXDUC_AMT              := 0;      --정치한도초과세액공제액
            V_FLAW_CNTRIB_DUC_OBJ_AMT               := 0;      --법정기부공제대상금액
            V_FLAW_CNTRIB_TAXDUC_AMT                := 0;      --법정기부세액공제액
            V_APNT_CNTRIB_DUC_OBJ_AMT               := 0;      --지정기부공제대상금액
            V_APNT_CNTRIB_TAXDUC_AMT                := 0;      --지정기부세액공제액
            V_STAD_TAXDUC_OBJ_AMT                   := 0;      --표준세액공제대상금액
            V_STAD_TAXDUC_AMT                       := 0;      --표준세액공제액
            V_MNRT_TAXDUC_AMT                       := 0;      --월세세액공제액


            V_SLF_DRWUP_CFM_YN                      := 'N';      --본인작성확인여부
            V_HOUSEHOLDER_DUPL_DUC_YN               := 'N';      --세대주중복공제여부
            V_SLF_LOAMT_YN                          := 'N';      --본인차입금여부
            V_YY2_BF_INDREC_INVST_AMT               := 0;      --2년전간접투자금액
            V_YY2_BF_DIRECT_INVST_AMT               := 0;      --2년전직접투자금액
            V_YY1_BF_INDREC_INVST_AMT               := 0;      --1년전간접투자금액
            V_YY1_BF_DIRECT_INVST_AMT               := 0;      --1년전직접투자금액
            V_THYR_INDREC_INVST_AMT                 := 0;      --당해간접투자금액
            V_THYR_DIRECT_INVST_AMT                 := 0;      --당해직접투자금액
            V_ADDR_ACCORD_YN                        := 'N';      --주소지일치여부
            V_SUBDP_BASI_MPRC_BLW_YN                := 'N';      --청약저축기준시가이하여부
            v_HOUS_OWN_YN                           := 'N';      --연중무주택여부



            V_BF_RECPT_DEBIT_ALL_AMT                := 0;      --전년도체크현금영수증합계
            V_SHALF_RECPT_DEBIT_ALL_AMT             := 0;      --당해년도하반기체크현금영수증합계
            V_FHALF_RECPT_DEBIT_ALL_AMT             := 0;      --당해년도상반기체크현금영수증합계
            V_BF_PRVYY_RECPT_DEBIT_ALL_AMT          := 0;      --전전년도체크현금영수증합계

            V_BF_INVST_AMT                          := 0;      --벤처등과거년도투자금액공제합계
            V_THYR_INVST_AMT                        := 0;      --벤처등당해년도투자금액공제합계
            V_INVST_FOR_DUC_MAX_AMT                 := 0;      --종합한도대상벤처등투자금액

            V_SPCL_INCMDED_TT_AMT                   := 0;      --특별소득공제금액계
            V_REST_INCMDED_TT_AMT                   := 0;      --그밖의소득공제금액계
            V_BF_CNTRIB_TAXDUC_AMT                  := 0;      --기부금세액공제전 결정세액
            V_CNTRIB_TAXDUC_AMT                     := 0;      --기부금 실제공제세액
            V_MOD_CNTRIB_TAXDUC_AMT                 := 0;      --기부금 조정공제세액
            V_MOD_CNTRIB_DUC_OBJ_AMT                := 0;      --기부금 조정 공제대상액

            V_SLF_MNRT_PAY_YN := 'N';                  --월세액공제 - 본인이 월세액 지급여부 확인
            V_LESE_HOUS_SCALE_BLW_YN := 'N';           --월세액 - 임차주택이 국민주택규모이하인지 여부확인
            V_JOIN_THTM_HOUS_CNT := 0;                 --2009년 12. 31일 이전 청약저축가입자의 경우 가입당시주택수
            V_JOIN_THTM_HOUS_SCALE_BLW_YN := 'N';      --2009년 12. 31일 이전 청약저축가입자의 경우 1주택자이면 가입당시 주택이 국민주택규모이하인지 여부 확인
            V_JOIN_THTM_BASI_MPRC_BLW_YN := 'N';

            V_TMP_BF_CALC_TAXAMT                    := 0;      --차감전 세액
            V_STD_DETM_INCOME_TAX                   := -1;     --표준세액공제적용 결정세액

            V_APNT_CNTRIB40_DUC_OBJ_AMT             := 0;      --지정기부(종교외) 세액공제대상금액 @VER.2016_8
            V_APNT_CNTRIB40_TAXDUC_AMT              := 0;      --지정기부(종교외) 세액공제금액 @VER.2016_8
            V_APNT_CNTRIB41_DUC_OBJ_AMT             := 0;      --지정기부(종교) 세액공제대상금액 @VER.2016_8
            V_APNT_CNTRIB41_TAXDUC_AMT              := 0;      --지정기부(종교) 세액공제금액 @VER.2016_8

            V_DUTY_INVENT_CMPS_AMT_NOTAX            := 0;      --직무발명보상금비과세(@VER.2018_13)
            V_DUTY_INVENT_CMPS_AMT                  := 0;      --직무발명보상금(@VER.2018)
            V_DELAY_NOTAX_AMT                       := 0;      --연장비과세액(@VER.2018_3)
            V_TMP_AMT_ETE                           := 0;
            
            
            /** 2019년도 기부금 세액계산을 위해 새롭게 만든 변수들 **/

            GV_TAX_REMAIN_AMT      := 0;

            N_TOT_GIFT             := 0;    -- 세액공제대상금액 합계액
            N_CMLTV_GIFT           := 0;    -- 세액공제대상금액 합계액

            N_RT_GIFT              := 0;    -- 기부금 세액공제액

            N_DON_LAW_RT           := 0;    -- 비율(법정기부금 세액공제대상금액             / 세액공제대상금액 합계액)
            N_STOCK_RT             := 0;    -- 비율(우리사주조합기부금 세액공제대상금액     / 세액공제대상금액 합계액)
            N_PSA_APPNT_RT         := 0;    -- 비율(지정기부금 종교단체 외 세액공제대상금액 / 세액공제대상금액 합계액)
            N_PSA_RELGN_RT         := 0;    -- 비율(지정기부금 종교단체 세액공제대상금액    / 세액공제대상금액 합계액)

            -- 기부금 소득공제ㆍ세액공제로 결정세액이 "0"이 되는 경우 처리용 변수
            N_SUB_RT_AMT           := 0;    -- 환산공제대상금액
            N_SUB_RT_DUC_AMT       := 0;    -- 환산공제대상금액 차감용 변수
            N_CALC_TAX_SUB         := 0;          -- 기부금 세액공제액 임시 계산
            N_RE_CALC_TAX_OBJ      := 0;         -- 기부금 공제대상액 임시 역산

            N_TAX_SUB_TMP          := 0;          -- 기부금 세액공제액 임시
            N_TAX_SUB_OBJ_TMP      := 0;          -- 기부금 공제대상액 임시
                
            GN_RT_TOTAL_CUR_SUB      := 0;   -- 당해년도 법정 기부금
            GN_RT_TOTAL_ETC_SUB_14   := 0;   -- 2014년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_15   := 0;   -- 2015년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_16   := 0;   -- 2016년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_17   := 0;   -- 2017년도 법정 이뤌 기부금
            GN_RT_TOTAL_ETC_SUB_18   := 0;   -- 2018년도 법정 이뤌 기부금

            GN_STOCK_URSM            := 0;   -- 우리사주조합기부금

            GN_RT_PSA_CUR_APPNT      := 0;   -- 당해년도 지정(종교단체외) 기부금
            GN_RT_PSA_ETC_APPNT_14   := 0;   -- 2014년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_15   := 0;   -- 2015년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_16   := 0;   -- 2016년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_17   := 0;   -- 2017년도 지정(종교단체외) 이월 기부금
            GN_RT_PSA_ETC_APPNT_18   := 0;   -- 2018년도 지정(종교단체외) 이월 기부금

            GN_RT_PSA_CUR_RELGN      := 0;   -- 2019년도 지정(종교단체) 당월 기부금
            GN_RT_PSA_ETC_RELGN_14   := 0;   -- 2014년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_15   := 0;   -- 2015년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_16   := 0;   -- 2016년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_17   := 0;   -- 2017년도 지정(종교단체) 이월 기부금
            GN_RT_PSA_ETC_RELGN_18   := 0;   -- 2018년도 지정(종교단체) 이월 기부금

            GV_CALC_RT_DON_LAW       := 0;   -- 기부금 공제세액
            GV_CALC_RT_STOCK_URSM    := 0;   -- 우리사주조합기부금  공제세액
            GV_CALC_RT_PSA           := 0;   -- 종교단체외 공제세액
            GV_CALC_RT_PSA_RELGN     := 0;   -- 종교단체 공제세액

            GV_CALC_SPCL_DON_LAW     := 0;   --  법정기부금 세액공제 대상기부금 누계액  
            GV_CALC_SPCL_STOCK_URSM  := 0;   --  우리사주조합기부금 세액공제 대상액
            GV_CALC_SPCL_PSA         := 0;   --  종교단체외 지정기부금 세액공제 대상액
            GV_CALC_SPCL_PSA_RELGN_AMT  := 0;   -- 종교단체 지정기부금 세액공제 대상액


/** 2019년도 기부금 세액계산을 위해 새롭게 만든 변수들 **/

            V_TMP_STEP := '014';

        --COMMIT;

        END LOOP;

       EXCEPTION
       WHEN OTHERS THEN
            OUT_RTN := 0;
            OUT_MSG := '연말정산결과2 생성오류(대표개인번호 : '||V_RPST_PERS_NO ||', SQLCODE : '||SQLCODE || ':' || SQLERRM || ')'||'V_TMP_STEP:'||V_TMP_STEP;
            RETURN;

    END;

   -- DBMS_OUTPUT.PUT_LINE('PAYM410 계산 END='||TO_CHAR(SYSDATE,'yyyymmdd hh24miss.ss') );

    OUT_RTN := 1 ;
    OUT_MSG := '연말정산 결과 '||to_char(V_MAN_CNT)|| ' 건을 생성완료 하였습니다.';
    
    
    
    

END SP_PAYM410B_TRET_2019_4;
/
