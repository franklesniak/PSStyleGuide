"""Strict receipt judgment only; no operation runs on import."""
def require_successful_exited_children(receipt):
    assert receipt['failure'] is None,'Ownership collection or cleanup failed'
    assert receipt['empty_after'] and not receipt['members_after'],'Owned descendants remain'
    assert not receipt['signals'],'Live owned descendants required signals'
    before=receipt['members_before'];waits=receipt['waits'];owner=receipt['owner_pid']
    assert all(row['state']=='Z' for row in before),'Live or unknown owned descendant existed before cleanup'
    for wait in waits:
        row=wait['identity']
        assert row['state']=='Z' and row['ppid']==owner,'Unknown adopted wait ownership/state'
        assert wait['wait_pid']==row['pid'] and wait['exited'] and wait['exit']==0 and not wait['signaled'] and wait['signal'] is None,'Unsuccessful adopted exit'
    for row in before:
        matching=[wait for wait in waits if wait['wait_pid']==row['pid'] and wait['identity']['start_ticks']==row['start_ticks']]
        assert len(matching)==1,'Missing or ambiguous owned exit receipt'
    return True
