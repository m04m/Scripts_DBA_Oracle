COL USERNAME FORMAT A17 WRAP;
COL CLIENT_INFO FORMAT A20 ;
COL SERVER   FORMAT A9 WRAP;
COL STATUS   FORMAT A8  WRAP;
COL PROGRAM  FORMAT A25 WRAP;
COL MACHINE  FORMAT A10 ;
col SSE FORMAT a11;
col LAST_CALL_ET for a10;
col spid for a6;
col USERNAME for a9;
COL SQL_TEXT FORMAT A90;

undefine SID1

SELECT  ''''||TO_CHAR(S.SID)||','||TO_CHAR(S.SERIAL#)||'''' SSE,
	S.USERNAME USERNAME,
	S.STATUS STATUS,
	S.SQL_ADDRESS
FROM V$SESSION S, V$PROCESS P
WHERE   P.ADDR (+) = S.PADDR AND
        S.SID = &&SID1
union
(
SELECT ST.SQL_TEXT, 'A', 'B', ST.ADDRESS
            FROM V$SQLTEXT ST, V$SQL SQ
            WHERE ST.ADDRESS = SQ.ADDRESS AND 
             	  SQ.ADDRESS IN (	SELECT S.SQL_ADDRESS 
            			 	FROM V$SESSION S, V$PROCESS P
				 	WHERE   P.ADDR (+) = S.PADDR AND
        			 	S.SID = &&SID1
        			 )
            --ORDER BY ST.PIECE
);

undefine SID1
