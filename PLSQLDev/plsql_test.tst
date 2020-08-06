PL/SQL Developer Test script 3.0
36
/*
DECLARE
    IN_STUNO            VARCHAR2(20);
    IN_ID               VARCHAR2(200);
    IN_IP               VARCHAR2(200);
    OUT_RTN             INTEGER;
    OUT_MSG             VARCHAR2(200);
BEGIN
    IN_STUNO            := '2020-29457';
    IN_ID               := 'id';
    IN_IP               := 'ip';
           
    PKG_SREG_STUNO_DEL.P_STUNO_DEL (  IN_STUNO,    
                                      IN_ID,
                                      IN_IP,
                                      OUT_RTN,
                                      OUT_MSG
                                   );

    COMMIT;
    --ROLLBACK;                              
                              
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------END');
                                 
END;
*/


DECLARE
   OUT_NUM    NUMBER ;       
   OUT_MSG    VARCHAR2(4000) ;         
BEGIN
   SP_ESIN604_ENG_CHK(OUT_NUM, OUT_MSG);
  --SNU.SP_STUD106_APPR('2020-73502','0','U001600002','','B111574','147.46.106.164',OUT_NUM,OUT_MSG) ;
  --DBMS_OUTPUT.PUT_LINE(OUT_RTN || ' : ' || OUT_MSG);
END;  
0
0
