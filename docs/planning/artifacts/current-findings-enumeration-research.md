# PSStyleGuide enumeration research

## Primary sources

### Filesystem enumeration

- Source:
  [Microsoft Learn — Directory.GetFileSystemEntries remarks](https://learn.microsoft.com/en-us/dotnet/api/system.io.directory.getfilesystementries?view=netframework-4.8.1)
- Durable fact: `EnumerateFileSystemEntries` exposes entries before the whole
  collection is returned. `GetFileSystemEntries` waits for the complete array.
- Application: an exact count can stop after `N + 1` entries. An absence
  proof can consume the stream without storing every entry.

### Deferred sequence execution

- Source:
  [Microsoft Learn — Enumerable class](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable)
- Durable facts: sequence-returning LINQ operations use deferred execution, and
  `Take` returns a specified number of leading values.
- Application: production exact-count scans must not first convert the source
  to a list or array.

### PowerShell syntax trees

- Source:
  [Microsoft Learn — Parser.ParseFile](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.language.parser.parsefile)
- Durable facts: `ParseFile` returns a `ScriptBlockAst`, tokens, and parse
  errors. It is available in Windows PowerShell 5.1 and PowerShell 7.
- Application: the proof can bind a static rule to the exact supplied script.
  A traced copy and eager mutant remain necessary to show that the guard runs
  and that the proof can fail.

## Verification boundary

P1A is a planning issue. Its future helper and harness do not exist on this
branch, so the enumeration implementation cannot run in this pass. The issue
must require the implementation pull request to record exact script hashes,
runtime identities, commands, trace counts, mutant rejection, and results.
