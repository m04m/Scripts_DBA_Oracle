--------------------------------------------------------------------------------------
-- Oracle Ask Tom --------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- Shrinking System ------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- https://asktom.oracle.com/pls/asktom/f?p=100:11:::::P11_QUESTION_ID:153612348067 --
--------------------------------------------------------------------------------------

set verify off
column file_name format a60 word_wrapped
column smallest format 999,990 heading "Smallest|Size|Poss."
column currsize format 999,990 heading "Current|Size"
column savings  format 999,990 heading "Poss.|Savings"
break on report
compute sum of savings on report

column value new_val blksize
select value from v$parameter where name = 'db_block_size'
/

select file_name,
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) smallest,
       ceil( blocks*&&blksize/1024/1024) currsize,
       ceil( blocks*&&blksize/1024/1024) -
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) savings
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
/

column cmd format a100 word_wrapped

select 'alter database datafile '''||file_name||''' resize ' ||
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 )  || 'm;' cmd
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
  and ceil( blocks*&&blksize/1024/1024) -
      ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) > 0
/