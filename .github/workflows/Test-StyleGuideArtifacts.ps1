#Requires -Version 7.0

# .SYNOPSIS
# Checks that committed style-guide artifacts match deterministic generation.
#
# .DESCRIPTION
# Runs in the Linux CI checkout without credentials or publication authority.
# Checks native results, interface schemas, filesystem changes, Git control data,
# and runner communication files. Release comments do not select compatibility.
#
# .OUTPUTS
# None. A success diagnostic uses the Information stream; failures terminate.
#
# .NOTES
# Version: 1.1.20261001.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param()

$ErrorActionPreference = 'Stop'
if (Test-Path Variable:PSNativeCommandUseErrorActionPreference) {
    $PSNativeCommandUseErrorActionPreference = $false
}

# Do not load user/system Git credentials or hooks during anonymous acquisition.
$env:GIT_CONFIG_NOSYSTEM = '1'
$env:GIT_CONFIG_GLOBAL = '/dev/null'
$env:GIT_TERMINAL_PROMPT = '0'
if (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN) -or
    -not [string]::IsNullOrEmpty($env:GH_TOKEN) -or
    -not [string]::IsNullOrEmpty($env:ACTIONS_RUNTIME_TOKEN)) {
    throw 'credential-policy: a token was projected into a code job'
}
$arrArtifacts = @(
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
    'copilot-instructions.md'
    'powershell.instructions.md'
)

function Invoke-GitRaw {
    # .SYNOPSIS
    # Invokes the fixed Git executable and captures raw output bytes.
    #
    # .DESCRIPTION
    # Starts the already resolved Git executable without a shell, isolates
    # system and global Git configuration, and drains standard output and
    # standard error concurrently. It returns the exact native exit code,
    # raw standard-output bytes, and standard-error text. It throws
    # native-tool when Process.Start returns false. Process, task, stream,
    # allocation, and parameter-binding failures propagate.
    #
    # .PARAMETER GitArguments
    # Complete Git argument array. Each element is added without shell
    # interpretation.
    #
    # .EXAMPLE
    # $objWorking = Invoke-GitRaw @('diff', '--name-only', '-z', '--')
    # # Captures working-tree path records and the exact Git exit code.
    #
    # .EXAMPLE
    # $objUntracked = Invoke-GitRaw @('ls-files', '--others', '--exclude-standard', '-z', '--')
    # # Captures raw NUL-delimited untracked-path records.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # System.Management.Automation.PSCustomObject. One object with
    # System.Int32 ExitCode, System.Byte[] Bytes, and System.String Error.
    # A nonzero native exit remains data and is not converted to success.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.1.20261001.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GitArguments
    [CmdletBinding(PositionalBinding = $true)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param([string[]]$GitArguments)
    $objStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
    # Resolved once before the generator ran, and held in a constant.
    # Resolving here instead would consult PATH and the command table
    # after repository code has executed, and both are things that
    # code can steer. See the resolution below.
    $objStartInfo.FileName = $strGitPath
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    # Git loads system, global, and repository-local configuration on
    # every invocation, and settings such as core.fsmonitor name a
    # program Git runs to decide which paths changed. The digest taken
    # across the generator covers the repository-local file only, so
    # the other two locations are removed rather than inspected: a
    # generator that writes core.fsmonitor to ~/.gitconfig would
    # otherwise steer every probe below while .git/config stayed
    # byte-identical. With local digested and these two neutralised,
    # all three documented configuration sources are accounted for.
    $objStartInfo.Environment['GIT_CONFIG_GLOBAL'] = '/dev/null'
    $objStartInfo.Environment['GIT_CONFIG_NOSYSTEM'] = '1'
    foreach ($strArgument in $GitArguments) {
        [void]$objStartInfo.ArgumentList.Add($strArgument)
    }
    $objProcess = [System.Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    $objOutput = [System.IO.MemoryStream]::new()
    try {
        if (-not $objProcess.Start()) {
            throw 'native-tool: Git did not start'
        }
        # Both redirected pipes must drain concurrently. Reading one to
        # completion first deadlocks when the child fills the other.
        $objCopyTask = $objProcess.StandardOutput.BaseStream.CopyToAsync($objOutput)
        $objErrorTask = $objProcess.StandardError.ReadToEndAsync()
        [void]$objCopyTask.GetAwaiter().GetResult()
        $strError = $objErrorTask.GetAwaiter().GetResult()
        $objProcess.WaitForExit()
        return [pscustomobject]@{
            ExitCode = $objProcess.ExitCode
            Bytes = $objOutput.ToArray()
            Error = $strError
        }
    } finally {
        $objOutput.Dispose()
        $objProcess.Dispose()
    }
}

function ConvertFrom-NulPathRecordStream {
    # .SYNOPSIS
    # Converts one raw NUL-delimited path-record stream.
    #
    # .DESCRIPTION
    # Splits the supplied bytes only at NUL delimiters and copies each
    # nonempty record without text decoding. Empty input produces no
    # records. The function throws git-paths: missing final NUL for an
    # unterminated stream and git-paths: empty or duplicate record for an
    # empty record. Allocation, copy, and parameter-binding failures
    # propagate. Duplicate byte records remain visible for the path-set
    # validator to reject after strict decoding.
    #
    # .PARAMETER PathRecordBytes
    # Complete raw byte stream returned by one NUL-delimited Git query.
    #
    # .EXAMPLE
    # $arrPathRecords = @(ConvertFrom-NulPathRecordStream ([byte[]]@(0x61, 0x00)))
    # # Returns one System.Byte[] record containing 0x61.
    #
    # .EXAMPLE
    # $arrPathRecords = @(ConvertFrom-NulPathRecordStream ([byte[]]::new(0)))
    # # Returns an empty array for an empty Git result.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # System.Byte[]. Writes one byte-array object for each raw path record.
    # Empty input writes no success-stream object.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.1.20261001.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: PathRecordBytes
    [CmdletBinding(PositionalBinding = $true)]
    [OutputType([System.Array])]
    param([byte[]]$PathRecordBytes)
    if ($PathRecordBytes.Length -eq 0) {
        return
    }
    if ($PathRecordBytes[$PathRecordBytes.Length - 1] -ne 0) {
        throw 'git-paths: missing final NUL'
    }

    $intStart = 0
    for ($intIndex = 0; $intIndex -lt $PathRecordBytes.Length; $intIndex++) {
        if ($PathRecordBytes[$intIndex] -eq 0) {
            if ($intIndex -eq $intStart) {
                throw 'git-paths: empty or duplicate record'
            }
            $intStart = $intIndex + 1
        }
    }

    $intStart = 0
    for ($intIndex = 0; $intIndex -lt $PathRecordBytes.Length; $intIndex++) {
        if ($PathRecordBytes[$intIndex] -eq 0) {
            $arrRecord = [byte[]]::new($intIndex - $intStart)
            [System.Array]::Copy($PathRecordBytes, $intStart, $arrRecord, 0, $arrRecord.Length)
            Write-Output -NoEnumerate -InputObject $arrRecord
            $intStart = $intIndex + 1
        }
    }
}

function Assert-AllowedPathSet {
    # .SYNOPSIS
    # Asserts one decoded Git path set against an exact allowlist.
    #
    # .DESCRIPTION
    # Strictly decodes each raw record as UTF-8, requires byte-for-byte
    # round-trip equality, rejects duplicate decoded paths, and requires
    # case-sensitive membership in the supplied allowlist. It returns the
    # observed paths in case-sensitive sort order. It throws a git-paths
    # category for undecodable, ambiguous, duplicate, or unexpected
    # records. Encoding, collection, sorting, and binding failures
    # propagate.
    #
    # .PARAMETER PathRecords
    # Raw System.Byte[] path records from ConvertFrom-NulPathRecordStream.
    #
    # .PARAMETER AllowedPaths
    # Exact case-sensitive path allowlist for the selected surface.
    #
    # .PARAMETER SurfaceName
    # Diagnostic surface name, such as working, staged, or untracked.
    #
    # .EXAMPLE
    # $arrObservedPaths = @(Assert-AllowedPathSet $arrPathRecords $arrArtifacts 'working')
    # # Returns the allowed decoded paths in case-sensitive sort order.
    #
    # .EXAMPLE
    # $arrStagedPaths = @(Assert-AllowedPathSet @() @() 'staged')
    # # Returns an empty array for an empty clean surface.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # System.String. Writes each validated path in case-sensitive sort
    # order. An empty record set writes no success-stream object.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.1.20261001.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: PathRecords
    #   Position 1: AllowedPaths
    #   Position 2: SurfaceName
    [CmdletBinding(PositionalBinding = $true)]
    [OutputType([string])]
    param([byte[][]]$PathRecords, [string[]]$AllowedPaths, [string]$SurfaceName)
    $objUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
    $listObservedPaths = [System.Collections.Generic.List[string]]::new()
    foreach ($arrRecord in $PathRecords) {
        try {
            $strPath = $objUtf8.GetString($arrRecord)
        } catch {
            throw "git-paths: undecodable $SurfaceName record"
        }
        $arrRoundTrip = $objUtf8.GetBytes($strPath)
        if ([Convert]::ToBase64String($arrRecord) -cne [Convert]::ToBase64String($arrRoundTrip)) {
            throw "git-paths: ambiguous $SurfaceName record"
        }
        if ($listObservedPaths -ccontains $strPath) {
            throw "git-paths: duplicate $SurfaceName record"
        }
        if ($AllowedPaths -cnotcontains $strPath) {
            throw "git-paths: unexpected $SurfaceName path"
        }
        $listObservedPaths.Add($strPath)
    }
    return $listObservedPaths | Sort-Object -CaseSensitive
}

# Everything below this line runs after repository-controlled code, so
# the tool it uses is fixed before that code runs. A fixed candidate
# list rather than a PATH lookup, because PATH is writable by anything
# that executes first; Constant rather than an ordinary variable,
# because a script invoked with the call operator runs in a child
# scope whose parent is this block and can therefore reassign an
# ordinary variable here through Set-Variable -Scope 1.
$strResolvedGit = @('/usr/bin/git', '/bin/git') |
    Where-Object {
        [System.IO.File]::Exists($_)
    } |
    Select-Object -First 1
if ([string]::IsNullOrEmpty($strResolvedGit)) {
    throw 'native-tool: Git application was not resolved'
}
New-Variable -Name strGitPath -Value $strResolvedGit -Option Constant

# Pinning the executable does not pin what it will do. Git loads
# repository-local configuration on every invocation regardless of
# which binary runs, and core.fsmonitor names a program Git executes
# to decide which paths changed -- a hostile value makes the probes
# below report a clean tree over modified files. Hooks are the same
# shape of problem. Rather than enumerate the dangerous keys, the
# repository's own control surface is digested and required to be
# unchanged: the generator has no legitimate reason to touch .git.
function Get-GitControlSurfaceDigest {
    # .SYNOPSIS
    # Measures the repository-local Git control surface.
    #
    # .DESCRIPTION
    # Reads the local Git configuration and every hook file, frames the
    # component count and each component length in big-endian form, and
    # returns a Base64-encoded SHA-256 digest. It throws git-state when
    # the Git metadata path is not a directory. Directory, file, hashing, stream, and
    # allocation failures propagate.
    #
    # .EXAMPLE
    # $strControlSurfaceBefore = Get-GitControlSurfaceDigest
    # # Records the repository-local configuration and hook state.
    #
    # .EXAMPLE
    # if ((Get-GitControlSurfaceDigest) -cne $strControlSurfaceBefore) {
    #     throw 'git-state changed'
    # }
    # # Compares a later measurement with the recorded digest.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # System.String. One Base64-encoded SHA-256 digest of the injectively
    # framed repository-local Git control surface.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.1.20261001.0
    #
    # This function declares no parameters.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param ()
    $strGitDirectory = [System.IO.Path]::Combine($PWD.Path, '.git')
    if (-not [System.IO.Directory]::Exists($strGitDirectory)) {
        throw 'git-state: .git is not a directory'
    }
    # Components are collected first, then written length-prefixed.
    # Concatenating them raw would not be injective: renaming
    # pre-commit.sample to pre-commit and prepending '.sample' to its
    # content produces the identical byte stream, turning an inert
    # sample into an active hook with the digest unchanged. Framing
    # each component with its length removes the boundary ambiguity,
    # so the encoding determines the contents uniquely.
    $listComponents = [System.Collections.Generic.List[byte[]]]::new()
    $strConfigPath = [System.IO.Path]::Combine($strGitDirectory, 'config')
    if ([System.IO.File]::Exists($strConfigPath)) {
        $listComponents.Add([System.IO.File]::ReadAllBytes($strConfigPath))
    } else {
        $listComponents.Add([byte[]]::new(0))
    }
    $strHooksDirectory = [System.IO.Path]::Combine($strGitDirectory, 'hooks')
    if ([System.IO.Directory]::Exists($strHooksDirectory)) {
        foreach ($strHook in ([System.IO.Directory]::GetFiles($strHooksDirectory) | Sort-Object -CaseSensitive)) {
            $listComponents.Add([System.Text.Encoding]::UTF8.GetBytes([System.IO.Path]::GetFileName($strHook)))
            $listComponents.Add([System.IO.File]::ReadAllBytes($strHook))
        }
    }
    $objSha = [System.Security.Cryptography.SHA256]::Create()
    $objBuffer = [System.IO.MemoryStream]::new()
    try {
        $arrCount = [System.BitConverter]::GetBytes([long]$listComponents.Count)
        if ([System.BitConverter]::IsLittleEndian) {
            [System.Array]::Reverse($arrCount)
        }
        $objBuffer.Write($arrCount, 0, $arrCount.Length)
        foreach ($arrComponent in $listComponents) {
            $arrLength = [System.BitConverter]::GetBytes([long]$arrComponent.Length)
            if ([System.BitConverter]::IsLittleEndian) {
                [System.Array]::Reverse($arrLength)
            }
            $objBuffer.Write($arrLength, 0, $arrLength.Length)
            $objBuffer.Write($arrComponent, 0, $arrComponent.Length)
        }
        return [Convert]::ToBase64String($objSha.ComputeHash($objBuffer.ToArray()))
    } finally {
        $objBuffer.Dispose()
        $objSha.Dispose()
    }
}
$strControlSurfaceBefore = Get-GitControlSurfaceDigest

# No later authored step or action receives repository-code job state.
# The final channel check detects writes during this step, not after exit.
# Publication uses another runner and independently fetches committed bytes.
New-Variable -Name arrChannelPaths -Value @($env:GITHUB_ENV, $env:GITHUB_PATH, $env:GITHUB_OUTPUT, $env:GITHUB_STEP_SUMMARY) -Option Constant

# Every Git probe below reports on state the generator can move. It can
# stage and commit its own output, which advances HEAD and empties the
# working, cached, and untracked sets; it can set the advisory
# assume-unchanged bit, which Git documents as "not working as
# expected" for exactly this purpose. Either makes a stale artifact
# look clean.
#
# The properties actually needed are about bytes on disk, so they are
# measured on disk. If the committed artifacts already equal generator
# output, running the generator changes nothing -- so the assertion is
# that the generator is a no-op on the working tree. One comparison
# covers both "no drift" and "nothing else was touched", and it asks
# Git nothing. A map is compared entry by entry rather than by a
# combined digest, so there is no encoding to get wrong.
#
# What this establishes is the state of the tree at the moment the
# step ends, and no in-process check can establish more than that: a
# descendant the generator detached is still running and can rewrite
# any of it afterwards. That is why this job publishes nothing. The
# bytes that reach consumers come from the commit, fetched by a job
# that never runs the generator, so the window this comparison cannot
# cover has nothing downstream to act on.
# The walk descends one directory at a time rather than calling
# EnumerateFiles with AllDirectories, because that overload reports
# files and never the directories it passed through: given a link to
# somewhere outside the workspace it happily yields the files behind
# it, and there is no entry to refuse. Holding the frontier here means
# a link is seen before anything is read through it.
#
# A link is refused rather than skipped. Skipping drops it from both
# maps, so a generator that creates one leaves the comparison looking
# exactly like a generator that did nothing; refusing keeps the signal.
# The repository tracks no links, so this cannot fire on honest input.
function Get-WorktreeFileDigestMap {
    # .SYNOPSIS
    # Measures the ordinary files in the current working tree.
    #
    # .DESCRIPTION
    # Walks the working tree without recursive filesystem APIs, refuses
    # every reparse point, excludes only the exact .git directory, and
    # hashes each file through a bounded stream. It uses file length to
    # avoid opening an empty FIFO and returns an ordinally sorted mapping
    # from relative path to Base64 SHA-256 digest. It throws worktree when
    # a link is present. Enumeration, metadata, file, hashing, stream,
    # collection, and allocation failures propagate.
    #
    # .EXAMPLE
    # $objInitialDigestMap = Get-WorktreeFileDigestMap
    # # Records every ordinary working-tree file before generation.
    #
    # .EXAMPLE
    # $objFinalDigestMap = Get-WorktreeFileDigestMap
    # # Records the same map shape after generation for exact comparison.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # System.Collections.Generic.SortedDictionary[System.String,System.String].
    # One non-enumerated ordinal map from repository-relative path to a
    # Base64-encoded SHA-256 digest.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.1.20261001.0
    #
    # This function declares no parameters.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Collections.Generic.SortedDictionary[string, string]])]
    param ()
    $strRoot = $PWD.Path
    $strGitDirectory = [System.IO.Path]::Combine($strRoot, '.git')
    $objDigestMap = [System.Collections.Generic.SortedDictionary[string, string]]::new([System.StringComparer]::Ordinal)
    $objSha = [System.Security.Cryptography.SHA256]::Create()
    $objPending = [System.Collections.Generic.Stack[string]]::new()
    $objPending.Push($strRoot)
    try {
        while ($objPending.Count -ne 0) {
            foreach ($strEntry in [System.IO.Directory]::EnumerateFileSystemEntries($objPending.Pop())) {
                $objAttributes = [System.IO.File]::GetAttributes($strEntry)
                if (($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                    throw 'worktree: the working tree contains a link'
                }
                if (($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
                    if ($strEntry -cne $strGitDirectory) {
                        $objPending.Push($strEntry)
                    }
                } else {
                    $strRelative = $strEntry.Substring($strRoot.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
                    # Length comes from stat, which answers for a FIFO
                    # immediately, while reading one never returns at
                    # all. Both an empty regular file and a FIFO digest
                    # as empty: correct for the first, and it turns the
                    # second from a step that hangs to the job timeout
                    # into a mismatch against a non-empty artifact.
                    # Content is streamed rather than loaded whole, so
                    # a large file costs a buffer instead of its size.
                    $objFile = [System.IO.FileInfo]::new($strEntry)
                    if ($objFile.Length -eq 0) {
                        $objDigestMap[$strRelative] = [Convert]::ToBase64String($objSha.ComputeHash([byte[]]::new(0)))
                    } else {
                        $objStream = [System.IO.File]::OpenRead($strEntry)
                        try {
                            $objDigestMap[$strRelative] = [Convert]::ToBase64String($objSha.ComputeHash($objStream))
                        } finally {
                            $objStream.Dispose()
                        }
                    }
                }
            }
        }
    } finally {
        $objSha.Dispose()
    }
    return $objDigestMap
}
$objWorktreeBefore = Get-WorktreeFileDigestMap

# The semantic check runs in its own process after the integrity snapshot.
# Its exit status is authoritative; any worktree side effect is detected by
# the existing comparison after generation completes.
try {
    $strSemanticPowerShellPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
} catch {
    $strSemanticPowerShellPath = $null
}
if ([string]::IsNullOrEmpty($strSemanticPowerShellPath) -or
    -not [System.IO.File]::Exists($strSemanticPowerShellPath)) {
    throw 'The current PowerShell executable could not be resolved for semantic validation.'
}
$arrSemanticResult = @(& $strSemanticPowerShellPath `
    -NoLogo `
    -NoProfile `
    -NonInteractive `
    -File './.github/workflows/Test-BlankLineExamples.ps1')
$intSemanticExit = $LASTEXITCODE
if ($intSemanticExit -isnot [int] -or $intSemanticExit -ne 0) {
    throw 'The blank-line semantic check failed.'
}
if ($arrSemanticResult.Count -ne 1 -or
    $arrSemanticResult[0] -cne 'Blank-line example semantics passed, including focused mutation checks.') {
    throw 'The blank-line semantic check returned an unexpected result.'
}

# The generator runs in its own process, not in this session. In-session
# it could shadow a cmdlet with a function, reassign a variable in this
# scope, or prepend a directory to PATH, and every check below would
# then be reading what it chose. A process boundary removes the class
# rather than naming its members: a child process cannot reach this
# session's functions, variables, or environment.
try {
    $strPowerShellPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
} catch {
    # Any MainModule resolution failure falls through to the deterministic guard below.
    $strPowerShellPath = $null
}
if ([string]::IsNullOrEmpty($strPowerShellPath) -or
    -not [System.IO.File]::Exists($strPowerShellPath)) {
    throw 'The current PowerShell executable could not be resolved.'
}
$arrResult = @(& $strPowerShellPath `
    -NoLogo `
    -NoProfile `
    -NonInteractive `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1')
$intGeneratorExit = $LASTEXITCODE
if ($arrResult.Count -ne 1) {
    throw 'The generator returned an unexpected output shape.'
}
# BEGIN P1 GENERATOR RESULT
try {
    $objResult = $arrResult[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop
} catch {
    throw 'The generator returned invalid JSON.'
}
if ($null -eq $objResult -or $objResult.GetType() -ne [System.Management.Automation.PSCustomObject]) {
    throw 'The generator returned a non-object JSON result.'
}
# Only fixed labels enter this list; result values must never reach the diagnostic.
$listFailedChecks = [System.Collections.Generic.List[string]]::new()
if ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {
    [void]($listFailedChecks.Add('NativeExit'))
}
if ($objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {
    [void]($listFailedChecks.Add('Schema'))
}
if ($objResult.Overall -isnot [string] -or $objResult.Overall -notin @('Success', 'NoChange')) {
    [void]($listFailedChecks.Add('Overall'))
}
if ($objResult.Phase -isnot [string] -or $objResult.Phase -cne 'complete') {
    [void]($listFailedChecks.Add('Phase'))
}
if ($objResult.Category -isnot [string] -or $objResult.Category -cne 'none') {
    [void]($listFailedChecks.Add('Category'))
}
if ($objResult.NativeOutcome -isnot [string] -or $objResult.NativeOutcome -cne 'Success') {
    [void]($listFailedChecks.Add('NativeOutcome'))
}
if (($objResult.ExitCode -isnot [int] -and $objResult.ExitCode -isnot [long]) -or $objResult.ExitCode -ne 0) {
    [void]($listFailedChecks.Add('ResultExitCode'))
}
if ($listFailedChecks.Count -ne 0) {
    throw ('Artifact generation failed result checks: {0}.' -f ($listFailedChecks -join ', '))
}
# END P1 GENERATOR RESULT
$arrExpectedArtifactRecords = @(
    @('copilot', 'copilot-instructions.md'),
    @('powershell-instructions', 'powershell.instructions.md'),
    @('chat', 'STYLE_GUIDE_CHAT.md'),
    @('full', 'STYLE_GUIDE_FULL.md')
)
if ($objResult.Artifacts.Count -ne $arrExpectedArtifactRecords.Count) {
    throw 'generator: unexpected artifact record count'
}
for ($intArtifactIndex = 0; $intArtifactIndex -lt $arrExpectedArtifactRecords.Count; $intArtifactIndex++) {
    $objArtifactRecord = $objResult.Artifacts[$intArtifactIndex]
    if ($objArtifactRecord.ArtifactId -isnot [string] -or
        $objArtifactRecord.ArtifactId -cne $arrExpectedArtifactRecords[$intArtifactIndex][0] -or
        $objArtifactRecord.Path -isnot [string] -or
        $objArtifactRecord.Path -cne $arrExpectedArtifactRecords[$intArtifactIndex][1] -or
        $objArtifactRecord.Status -isnot [string] -or
        $objArtifactRecord.Status -notin @('Success', 'NoChange')) {
        throw 'generator: invalid artifact record'
    }
}

# Include this child in the final integrity checks, but defer its generic
# clean-state result until after the specific artifact drift diagnostic.
$strVerifierCommand = '& ''./.github/workflows/Test-ExactGitPathSet.ps1'' -RepositoryRoot $env:GITHUB_WORKSPACE -GitExecutablePath ''/usr/bin/git'' -ExpectedPath @() -Mode Both -RequireCleanWorkingAgainstIndex'
$strEncodedVerifierCommand = [System.Convert]::ToBase64String(
    [System.Text.Encoding]::Unicode.GetBytes($strVerifierCommand)
)
$arrPathSetResult = @(& $strPowerShellPath -NoLogo -NoProfile -NonInteractive -EncodedCommand $strEncodedVerifierCommand)
$intPathSetExit = $LASTEXITCODE

if ((Get-GitControlSurfaceDigest) -cne $strControlSurfaceBefore) {
    throw 'git-state: the generator or verifier changed repository Git configuration or hooks'
}

foreach ($strChannel in $arrChannelPaths) {
    if ([string]::IsNullOrEmpty($strChannel)) {
        throw 'runner-state: a step communication file path is unset'
    }
    if ([System.IO.FileInfo]::new($strChannel).Length -ne 0) {
        throw 'runner-state: the generator or verifier wrote to a runner step communication file'
    }
}

# The authoritative drift and blast-radius gate. The Git probes that
# follow are retained for their path-level diagnostics, but this is the
# check that decides, because it reads bytes rather than asking Git.
$objWorktreeAfter = Get-WorktreeFileDigestMap
$listChanged = [System.Collections.Generic.List[string]]::new()
foreach ($strPath in $objWorktreeBefore.Keys) {
    if ((-not $objWorktreeAfter.ContainsKey($strPath)) -or ($objWorktreeAfter[$strPath] -cne $objWorktreeBefore[$strPath])) {
        $listChanged.Add($strPath)
    }
}
foreach ($strPath in $objWorktreeAfter.Keys) {
    if (-not $objWorktreeBefore.ContainsKey($strPath)) {
        $listChanged.Add($strPath)
    }
}
if ($listChanged.Count -ne 0) {
    $arrOutside = @(
        $listChanged | Where-Object {
            $arrArtifacts -cnotcontains $_
        } | Sort-Object -CaseSensitive
    )
    if ($arrOutside.Count -ne 0) {
        throw "git-state: the generator or verifier changed $($arrOutside.Count) path(s) outside the four generated artifacts"
    }
    throw 'generated-artifacts: committed artifacts do not match generator output. Run ./.github/workflows/Generate-StyleGuideArtifacts.ps1 and commit the four regenerated files.'
}

# Check the saved verifier result after the specific integrity diagnostics.
if ($arrPathSetResult.Count -ne 1) {
    throw 'Exact-path verification returned an invalid shape.'
}
try {
    $objPathSetResult = $arrPathSetResult[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop
} catch {
    throw 'Exact-path verification returned invalid JSON.'
}
if ($null -eq $objPathSetResult -or $objPathSetResult.GetType() -ne [System.Management.Automation.PSCustomObject] -or
    $intPathSetExit -isnot [int] -or $intPathSetExit -ne 0 -or
    $objPathSetResult.Schema -isnot [string] -or $objPathSetResult.Schema -cne 'PSStyleGuide.ExactGitPathSetResult.v2' -or
    $objPathSetResult.Success -isnot [bool] -or -not $objPathSetResult.Success) {
    throw 'Exact-path verification did not confirm a clean worktree and index.'
}

$objWorking = Invoke-GitRaw @('diff', '--no-ext-diff', '--no-textconv', '--no-renames', '--name-only', '-z', '--')
$objStaged = Invoke-GitRaw @('diff', '--cached', '--no-ext-diff', '--no-textconv', '--no-renames', '--name-only', '-z', '--')
$objUntracked = Invoke-GitRaw @('ls-files', '--others', '--exclude-standard', '-z', '--')
foreach ($objGitResult in @($objWorking, $objStaged, $objUntracked)) {
    if ($objGitResult.ExitCode -ne 0) {
        throw "native-tool: Git path query failed with exit $($objGitResult.ExitCode)"
    }
}
$null = Assert-AllowedPathSet -PathRecords (ConvertFrom-NulPathRecordStream -PathRecordBytes $objWorking.Bytes) -AllowedPaths $arrArtifacts -SurfaceName 'working'
$arrStagedPaths = @(Assert-AllowedPathSet -PathRecords (ConvertFrom-NulPathRecordStream -PathRecordBytes $objStaged.Bytes) -AllowedPaths @() -SurfaceName 'staged')
$arrUntrackedPaths = @(Assert-AllowedPathSet -PathRecords (ConvertFrom-NulPathRecordStream -PathRecordBytes $objUntracked.Bytes) -AllowedPaths @() -SurfaceName 'untracked')
if ($arrStagedPaths.Count -ne 0 -or $arrUntrackedPaths.Count -ne 0) {
    throw 'git-paths: checkout is not clean'
}

$objDiff = Invoke-GitRaw (@('diff', '--no-ext-diff', '--no-textconv', '--quiet', '--') + $arrArtifacts)
if ($objDiff.ExitCode -ne 0 -and $objDiff.ExitCode -ne 1) {
    throw "native-tool: git diff failed with exit $($objDiff.ExitCode)"
}
# Status 1 means committed artifacts differ from generator output.
# This read-only workflow has no writer to repair that drift; it must fail.
if ($objDiff.ExitCode -eq 1) {
    throw 'generated-artifacts: committed artifacts do not match generator output. Run ./.github/workflows/Generate-StyleGuideArtifacts.ps1 and commit the four regenerated files.'
}
Write-Information 'generated-artifacts: committed bytes match generator output' -InformationAction Continue
