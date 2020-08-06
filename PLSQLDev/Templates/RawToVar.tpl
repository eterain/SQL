CREATE OR REPLACE FUNCTION RAW_TO_VAL(I_RAW RAW, I_DATA_TYPE VARCHAR2) RETURN VARCHAR2
 AS
 M_V VARCHAR2(100);
 M_VC VARCHAR(100);
 M_VC2 VARCHAR2(100);
 M_NV2 NVARCHAR2(100);
 M_C CHAR(100);
 M_N NUMBER;
 M_D DATE;
 M_R ROWID;
BEGIN
 IF I_DATA_TYPE='NUMBER' THEN
   DBMS_STATS.CONVERT_RAW_VALUE(I_RAW,M_N);
   M_V := TO_CHAR(M_N);
 ELSIF I_DATA_TYPE='DATE' THEN
   DBMS_STATS.CONVERT_RAW_VALUE(I_RAW,M_D);
   M_V := TO_CHAR(M_D);
 ELSIF I_DATA_TYPE='NVARCHAR2' THEN
   DBMS_STATS.CONVERT_RAW_VALUE_nvarchar(I_RAW,M_NV2);
   M_V := TO_CHAR(M_NV2);
 ELSIF I_DATA_TYPE='VARCHAR2' THEN
   DBMS_STATS.CONVERT_RAW_VALUE(I_RAW,M_VC2);
   M_V := TO_CHAR(M_VC2);
 ELSIF I_DATA_TYPE='VARCHAR' THEN
   DBMS_STATS.CONVERT_RAW_VALUE(I_RAW,M_VC);
   M_V := TO_CHAR(M_VC);
 ELSIF I_DATA_TYPE='CHAR' THEN
   DBMS_STATS.CONVERT_RAW_VALUE(I_RAW,M_C);
   M_V := RTRIM(M_C);
 ELSIF I_DATA_TYPE='ROWID' THEN
   DBMS_STATS.CONVERT_RAW_VALUE(I_RAW,M_R);
   M_V := RTRIM(M_R);
 ELSE
   M_V := 'N/A';
 END IF;
 RETURN M_V;
END; 
