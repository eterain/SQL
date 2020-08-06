FOR CUR_NM IN (
    SELECT USER_ID, ....
) LOOP 
    DBMS_OUTPUT.putline(CUR_NM.USER_ID);        
END LOOP;
