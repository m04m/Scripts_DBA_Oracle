grant select on sys.v_$session to dbamnt;
grant alter system to dbamnt;

CREATE TABLE DBAMNT.KILLED_SESSIONS
  (
    sid        NUMBER,
    serial#    NUMBER,
    username   VARCHAR2(30),
    osuser     VARCHAR2(30),
    machine    VARCHAR2(64),
    program    VARCHAR2(48),
    module     VARCHAR2(64),
    logon_time DATE,
    kill_time  DATE
  );

CREATE OR REPLACE
PROCEDURE dbamnt.kill_session(
    p_sid     IN VARCHAR2,
    p_serial# IN VARCHAR2)
IS
  cursor_name pls_integer DEFAULT dbms_sql.open_cursor;
  ignore pls_integer;
  v_ses v$session%rowtype;
BEGIN
  SELECT COUNT(*)
  INTO ignore
  FROM V$session
  WHERE username = USER
  AND sid        = p_sid
  AND serial#    = p_serial# ;
  IF ( ignore    = 1 ) THEN
    SELECT *
    INTO v_ses
    FROM V$session
    WHERE username = USER
    AND sid        = p_sid
    AND serial#    = p_serial# ;
    dbms_sql.parse(cursor_name, 'alter system kill session ''' ||p_sid||','||p_serial#||'''', dbms_sql.native);
    ignore := dbms_sql.execute(cursor_name);
    INSERT
    INTO KILLED_SESSIONS VALUES
      (
        v_ses.sid,
        v_ses.serial#,
        USER,
        v_ses.osuser,
        v_ses.machine,
		v_ses.program,
        v_ses.module,
        v_ses.logon_time,
		sysdate
      );
    COMMIT;
  ELSE
    raise_application_error( -20001, 'You do not own session ''' || p_sid || ',' || p_serial# || '''' );
  END IF;
END;
/


create public synonym kill_session for dbamnt.kill_session;
grant execute on dbamnt.kill_session to xxxxx;