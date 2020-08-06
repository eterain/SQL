CREATE OR REPLACE FUNCTION is_date(v_str_date IN VARCHAR2 )
RETURN NUMBER
IS 
        V_DATE DATE;
BEGIN
    V_DATE := TO_DATE(v_str_date, 'YYYY-MM-DD');
    RETURN 1;
EXCEPTION
    WHEN OTHERS THEN RETURN 0;
END;
