--- Troubleshooting Database Contention With V$Wait_Chains (Doc ID 1428210.1)

--set pages 1000
--set lines 120
--set heading off
column w_proc format a50 tru
column instance format a20 tru
column inst format a28 tru
column wait_event format a50 tru
column p1 format a16 tru
column p2 format a16 tru
column p3 format a15 tru
column Seconds format a50 tru
column sincelw format a50 tru
column blocker_proc format a50 tru
column waiters format a50 tru
column chain_signature format a100 wra
column blocker_chain format a100 wra


SELECT chain_id, num_waiters, in_wait_secs, osid, blocker_osid, substr(wait_event_text,1,30) FROM v$wait_chains; 

SELECT * 
FROM (SELECT 'Current Process: '||osid W_PROC, 'SID '||i.instance_name INSTANCE, 
'INST #: '||instance INST,'Blocking Process: '||decode(blocker_osid,null,'<none>',blocker_osid)|| 
' from Instance '||blocker_instance BLOCKER_PROC,'Number of waiters: '||num_waiters waiters,
'Wait Event: ' ||wait_event_text wait_event, 'P1: '||p1 p1, 'P2: '||p2 p2, 'P3: '||p3 p3,
'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait: '||time_since_last_wait_secs sincelw,
'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking Wait Chain: '||decode(blocker_chain_id,null,
'<none>',blocker_chain_id) blocker_chain
FROM v$wait_chains wc,
v$instance i
WHERE wc.instance = i.instance_number (+)
AND ( num_waiters > 0
OR ( blocker_osid IS NOT NULL
AND in_wait_secs > 10 ) )
ORDER BY chain_id,
num_waiters DESC)
WHERE ROWNUM < 101;

column w_proc format clear
column instance format clear
column inst format clear
column wait_event format clear
column p1 format clear
column p2 format clear
column p3 format clear
column Seconds format clear
column sincelw format clear
column blocker_proc format clear
column waiters format clear
column chain_signature format clear
column blocker_chain format clear