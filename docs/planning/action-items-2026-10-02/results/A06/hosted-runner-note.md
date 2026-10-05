<!-- markdownlint-disable MD013 -->
# Hosted runner recovery

Validation: five exact-head workflows ended with GitHub runner-acquisition failure; affected jobs have no runner and no executed steps. This is an environment failure, not a passing test or product defect.
Root cause: GitHub could not allocate a hosted runner after its internal attempts. [Active Actions incident3q1yb5m7ltvb](https://www.githubstatus.com/incidents/3q1yb5m7ltvb), started19:11:58Z and updated19:50:50Z on2026-10-05, reports runner-assignment delays. Native annotations and missing-log errors remain in the saved round1 evidence.
Action: retry only failed jobs once per terminal run, after fresh head/body/base and run-attempt checks; record each native attempt before and after the request. Leave pending reviews and jobs alone. Further retries require new terminal diagnosis; no code, settings, privileges, deadline or review-round change.
Verification: confirm the next native attempt once, then require actual checks and logs. Reuse completed cells; do not convert a queue or service failure into success.
Reference: [GitHub re-run guidance](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs) preserves the event SHA/ref and original actor privileges; use the failed-jobs option.
