DBMS_OUTPUT.PUT_LINE('eterain ----- >> 기부금2019 하단 법정,지정 Start');
DBMS_OUTPUT.PUT_LINE('eterain 기부금 세액공제 전 결정세액 V_CAL_TDUC_TEMP_AMT : ' || V_CAL_TDUC_TEMP_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 기부금 세액공제 전 결정세액 V_BF_CNTRIB_TAXDUC_AMT  := V_CAL_TDUC_TEMP_AMT : ' || V_BF_CNTRIB_TAXDUC_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 올해 법정기부금 + 지정기부금 공제대상액 V_TMP_AMT := V_FLAW_CNTRIB_DUC_OBJ_AMT + V_APNT_CNTRIB_DUC_OBJ_AMT : ' || V_TMP_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 올해 법정기부금 공제대상액 V_FLAW_CNTRIB_DUC_OBJ_AMT' || V_FLAW_CNTRIB_DUC_OBJ_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 올해 지정기부금 공제대상액 V_APNT_CNTRIB_DUC_OBJ_AMT' || V_APNT_CNTRIB_DUC_OBJ_AMT);
--DBMS_OUTPUT.PUT_LINE('eterain V_CNTRIB_DUC_AMT : ' || V_CNTRIB_DUC_AMT);
--DBMS_OUTPUT.PUT_LINE('eterain V_CNTRIB_PREAMT : ' || V_CNTRIB_PREAMT);
--DBMS_OUTPUT.PUT_LINE('eterain V_CNTRIB_GONGAMT : ' || V_CNTRIB_GONGAMT);
--DBMS_OUTPUT.PUT_LINE('eterain V_CNTRIB_DESTAMT : ' || V_CNTRIB_DESTAMT);
--DBMS_OUTPUT.PUT_LINE('eterain V_CNTRIB_OVERAMT : ' || V_CNTRIB_OVERAMT);
DBMS_OUTPUT.PUT_LINE('eterain 지정기부공제대상금액 V_APNT_CNTRIB_DUC_OBJ_AMT : ' || V_APNT_CNTRIB_DUC_OBJ_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 지정기부세액공제액 V_APNT_CNTRIB_DUC_OBJ_AMT : ' || V_APNT_CNTRIB_TAXDUC_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 지정기부(종교외)공제대상금액 V_APNT_CNTRIB_DUC_OBJ_AMT : ' || V_APNT_CNTRIB40_DUC_OBJ_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 지정기부(종교외)세액공제액 V_APNT_CNTRIB_DUC_OBJ_AMT : ' || V_APNT_CNTRIB40_TAXDUC_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 지정기부(종교)공제대상금액 V_APNT_CNTRIB_DUC_OBJ_AMT : ' || V_APNT_CNTRIB41_DUC_OBJ_AMT);
DBMS_OUTPUT.PUT_LINE('eterain 지정기부(종교)세액공제액 V_APNT_CNTRIB_DUC_OBJ_AMT : ' || V_APNT_CNTRIB41_TAXDUC_AMT);
