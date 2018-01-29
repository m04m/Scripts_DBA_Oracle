select -- a.*,--, (a.RECLAIMABLE_SPACE/a.ALLOCATED_SPACE)*100 DESPERDICADO 
TABLESPACE_NAME,
SEGMENT_OWNER,
segment_type,
SEGMENT_NAME,
PARTITION_NAME,
ALLOCATED_SPACE/1024/1024 ALOC_MB,
USED_SPACE/1024/1024 USED_MB,
RECLAIMABLE_SPACE/1024/1024 REC_MB,
(a.RECLAIMABLE_SPACE/a.ALLOCATED_SPACE)*100 DESPERDICADO 
from table(DBMS_SPACE.ASA_RECOMMENDATIONS()) a
where SEGMENT_OWNER = 'TWPROCDB'
--AND SEGMENT_TYPE    ='TABLE'
--and SEGMENT_NAME    = 'LSW_PERF_DATA_TRANSFER'
and (a.reclaimable_space/a.allocated_space)*100 > 20
order by reclaimable_space desc;