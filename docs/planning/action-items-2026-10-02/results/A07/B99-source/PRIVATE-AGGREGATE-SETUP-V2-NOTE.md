# Private aggregate setup correction

D07: Aggregate95091 stopped before tests because the immutable-image comparison still required the peer comment.
Fix and check: the new packet binds both hashes and permits only that comment change; tests, limits and ownership functions stay unchanged.
Evidence: runtime-comment.patch, preparation evidence and AGGREGATE-FAILED-SETUP-RECONCILIATION.json.
