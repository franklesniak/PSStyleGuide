# Private aggregate release correction

D07: Release78781 stopped before tests because peer configuration has a different repository-name comment.
Fix and check: bind both raw hashes and permit only the exact first-comment substitution; all hook bytes match.
Evidence: original release-aggregate.py, preserved v2, accepted source catalogs and AGGREGATE-RELEASE.json.
