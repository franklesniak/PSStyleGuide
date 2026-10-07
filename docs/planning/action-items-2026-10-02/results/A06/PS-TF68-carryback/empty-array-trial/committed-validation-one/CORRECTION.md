# Private temporary-path correction

D07 setup correction: the accepted checker could not initialize its effective-ignore fixture because the runner placed TEMP too deep for Git on Windows. Native exit1 is preserved; source/dependency/Git guards passed and all Jobs ended empty. Use one short, private task-owned TEMP root for the unfinished checks. Reuse the completed exact-H maintenance classifier; do not change product code, Git settings or repeat successful suites.
