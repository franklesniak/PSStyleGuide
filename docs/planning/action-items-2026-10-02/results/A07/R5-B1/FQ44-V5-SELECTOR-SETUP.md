# V5 selector setup reconciliation

Failed: the binder stopped1/3b7a5b at its first Docker image read, before any test, probe, authorized manifest or launcher.
Cause and fix: Docker Desktop was stopped; root started the installed app. Readback1b54eb found engine29.8.2 and no named probe/run container; the failed binding is preserved.
Preparation correction: the readiness contract now explicitly records accepted_donor_deltas=[] because donor metadata is unchanged; prior bytes are preserved and digest-only helper bindings updated. Result: binder10dc99 passed; [selectors6](current-main-validation/pr239-round3-v5-selectors-runtime.json) passed at53679/721db6 with all original gates. See private pr239-round3-v5-root-validation/selectors-setup-reconciliation.json.
