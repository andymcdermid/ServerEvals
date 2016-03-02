SELECT trc_evnt.name as event ,count(*) as occurence 
FROM fn_trace_gettable((select path from sys.traces where id = 1), NULL) AS dflt_trc 
INNER JOIN sys.trace_events AS trc_evnt ON dflt_trc.EventClass = trc_evnt.trace_event_id 
group by trc_evnt.name order by trc_evnt.name