PL/SQL Developer Test script 3.0
10
DECLARE
    p_code NUMBER;
    p_msg  VARCHAR2(500);
BEGIN
    SP_BUDG300_IMSI_CREA_01(p_code, p_msg);
    COMMIT ;    
    SP_BUDG300_IMSI_CREA_02(p_code, p_msg);
    COMMIT ;
    dbms_output.put_line(p_code || ':' || p_msg);
END;
0
0
