#Requires -Version 5.1

<#
.SYNOPSIS
Generates the four repository-owned style-guide artifacts.

.DESCRIPTION
Builds every complete payload from the two fixed sources before replacing any
fixed destination. Serialization is UTF-8 without a BOM and normalizes CRLF
and lone CR to LF at the final payload boundary.

.NOTES
Version: 1.0.20260814.0
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:strGeneratorVersion = '1.0.20260814.0'
$script:strGeneratorResultSchema = 'PSStyleGuide.GeneratorResult.v2'
$script:objUtf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:objUtf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:objPathComparison = if ($env:OS -eq 'Windows_NT') {
    [System.StringComparison]::OrdinalIgnoreCase
} else {
    [System.StringComparison]::Ordinal
}

function Get-ScriptVersionRecord {
    # .SYNOPSIS
    # Validates and parses the script's canonical version marker.
    #
    # .DESCRIPTION
    # Locates the only pre-function .NOTES block and the only Version marker,
    # validates its four numeric components and build date, requires it to equal
    # the expected version, and returns the parsed version fields.
    #
    # .PARAMETER ScriptText
    # Complete text of the script whose version marker is validated.
    #
    # .PARAMETER ExpectedVersion
    # Exact canonical four-component version that the marker must contain.
    #
    # .EXAMPLE
    # $hashtableVersion = Get-ScriptVersionRecord -ScriptText $strScriptText -ExpectedVersion '1.0.20000229.0'
    #
    # # Returns the validated version fields when the marker is canonical and equal.
    #
    # .EXAMPLE
    # Get-ScriptVersionRecord -ScriptText $strScriptText -ExpectedVersion '1.0.20000229.1'
    #
    # # Throws 'unexpected-version' when the canonical marker does not equal the expected value.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Version, Major,
    # Minor, BuildDate, and Revision. Throws 'invalid-version' for malformed or
    # ambiguous metadata and 'unexpected-version' for an expected-value mismatch.
    # Parameter-binding and underlying regex or allocation failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: ScriptText
    #   Position 1: ExpectedVersion
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptText,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedVersion
    )

    $objFirstFunction = [regex]::Match($ScriptText, '(?m)^function[\x20\x09]+[A-Za-z0-9_-]+[\x20\x09]*\{')
    if (-not $objFirstFunction.Success) {
        throw 'invalid-version'
    }
    $strPreamble = $ScriptText.Substring(0, $objFirstFunction.Index)
    $arrNoteBlocks = @([regex]::Matches($strPreamble, '(?s)<#(?:(?!#>).)*\.NOTES(?:(?!#>).)*#>'))
    $arrAllMarkers = @([regex]::Matches($ScriptText, '(?m)^Version:[^\r\n]*$'))
    if ($arrNoteBlocks.Count -ne 1 -or $arrAllMarkers.Count -ne 1) {
        throw 'invalid-version'
    }
    $strNotes = $arrNoteBlocks[0].Value
    $arrMarkers = @([regex]::Matches(
        $strNotes,
        '(?m)^Version: ([0-9]+)\.([0-9]+)\.([0-9]{8})\.([0-9]+)$'
    ))
    if ($arrMarkers.Count -ne 1 -or $arrMarkers[0].Value -cne $arrAllMarkers[0].Value) {
        throw 'invalid-version'
    }

    $arrComponents = @(
        $arrMarkers[0].Groups[1].Value,
        $arrMarkers[0].Groups[2].Value,
        $arrMarkers[0].Groups[3].Value,
        $arrMarkers[0].Groups[4].Value
    )
    foreach ($strComponent in $arrComponents) {
        if (($strComponent.Length -gt 1 -and $strComponent[0] -eq '0') -or
            $strComponent -notmatch '^[0-9]+$') {
            throw 'invalid-version'
        }
        $intValue = 0L
        if (-not [int64]::TryParse(
            $strComponent,
            [System.Globalization.NumberStyles]::None,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [ref]$intValue
        ) -or $intValue -gt [int]::MaxValue) {
            throw 'invalid-version'
        }
    }

    $objBuildDate = [datetime]::MinValue
    if (-not [datetime]::TryParseExact(
        $arrComponents[2],
        'yyyyMMdd',
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$objBuildDate
    )) {
        throw 'invalid-version'
    }
    $strCanonicalVersion = $arrComponents -join '.'
    $objVersion = New-Object System.Version(
        [int]$arrComponents[0],
        [int]$arrComponents[1],
        [int]$arrComponents[2],
        [int]$arrComponents[3]
    )
    if ($objVersion.ToString() -cne $strCanonicalVersion) {
        throw 'invalid-version'
    }
    if ($strCanonicalVersion -cne $ExpectedVersion) {
        throw 'unexpected-version'
    }
    return [ordered]@{
        Version = $strCanonicalVersion
        Major = $objVersion.Major
        Minor = $objVersion.Minor
        BuildDate = $objBuildDate.ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
        Revision = $objVersion.Revision
    }
}

function Test-ScriptVersionParser {
    # .SYNOPSIS
    # Exercises the script-version parser against fixed acceptance fixtures.
    #
    # .DESCRIPTION
    # Confirms one leap-day version is accepted, a version mismatch is
    # categorized as unexpected, and malformed, duplicate, overflow, misplaced,
    # and non-date markers are rejected as invalid.
    #
    # .EXAMPLE
    # Test-ScriptVersionParser
    #
    # # Produces no output when every acceptance and rejection fixture behaves as expected.
    #
    # .EXAMPLE
    # [void](Test-ScriptVersionParser)
    #
    # # Re-runs the fixed parser self-test and discards its intentionally empty output.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'version-fixture-failure' when a mismatched or invalid fixture
    # is unexpectedly accepted and reaches its explicit sentinel. A valid-fixture
    # rejection, a wrong rejection category, and other parser exceptions propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function declares no parameters.
    param ()

    $strValid = "<#`n.NOTES`nVersion: 1.0.20000229.0`n#>`nfunction Test-Fixture {}`n"
    $arrInvalid = @(
        "<#`n.NOTES`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.0`nVersion: 1.0.20000229.0`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 01.0.20000229.0`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20010229.0`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.2147483648`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.0.1`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.-1`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`n#>`nfunction Test-Fixture {`n<#`n.NOTES`nVersion: 1.0.20000229.0`n#>`n}`n"
    )
    [void](Get-ScriptVersionRecord -ScriptText $strValid -ExpectedVersion '1.0.20000229.0')
    try {
        [void](Get-ScriptVersionRecord -ScriptText $strValid -ExpectedVersion '1.0.20000229.1')
        throw 'version-fixture-failure'
    } catch {
        if ($_.Exception.Message -cne 'unexpected-version') {
            throw
        }
    }
    foreach ($strFixture in $arrInvalid) {
        try {
            [void](Get-ScriptVersionRecord -ScriptText $strFixture -ExpectedVersion '1.0.20000229.0')
            throw 'version-fixture-failure'
        } catch {
            if ($_.Exception.Message -cne 'invalid-version') {
                throw
            }
        }
    }
}

function ConvertTo-LowerHex {
    # .SYNOPSIS
    # Converts bytes to lowercase hexadecimal text.
    #
    # .DESCRIPTION
    # Formats every byte as two hexadecimal digits, removes the separators that
    # BitConverter inserts, and normalizes the result to lowercase.
    #
    # .PARAMETER Bytes
    # Byte sequence to encode as hexadecimal text.
    #
    # .EXAMPLE
    # $strHex = ConvertTo-LowerHex -Bytes ([byte[]](0, 15, 255))
    #
    # # $strHex is '000fff'.
    #
    # .EXAMPLE
    # $strHex = ConvertTo-LowerHex -Bytes ([byte[]](16, 32))
    #
    # # $strHex is '1020'.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. Lowercase hexadecimal text with no separators. Parameter
    # binding or underlying .NET formatting failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    return ([System.BitConverter]::ToString($Bytes) -replace '-', '').ToLowerInvariant()
}

function Get-Sha256Hex {
    # .SYNOPSIS
    # Computes the SHA-256 digest of a byte sequence.
    #
    # .DESCRIPTION
    # Hashes the complete input byte sequence and returns its digest as exactly
    # 64 lowercase hexadecimal characters without separators.
    #
    # .PARAMETER Bytes
    # Byte sequence to hash.
    #
    # .EXAMPLE
    # $strDigest = Get-Sha256Hex -Bytes ([byte[]](0))
    #
    # # Returns the SHA-256 digest of the one-byte sequence.
    #
    # .EXAMPLE
    # $strDigest = Get-Sha256Hex -Bytes ([System.Text.Encoding]::UTF8.GetBytes('content'))
    #
    # # Returns the lowercase SHA-256 digest of the UTF-8 bytes.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. A 64-character lowercase SHA-256 digest. After provider
    # creation, hashing and formatting failures propagate after it is disposed.
    # Provider-creation failures propagate before the protected block, and
    # parameter-binding failures propagate before the function body runs.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    $objSha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ConvertTo-LowerHex -Bytes $objSha256.ComputeHash($Bytes)
    } finally {
        $objSha256.Dispose()
    }
}

function Get-FileSha256Hex {
    # .SYNOPSIS
    # Computes the SHA-256 digest of a file.
    #
    # .DESCRIPTION
    # Opens the literal file path for shared reading, hashes the complete stream,
    # and returns the digest as lowercase hexadecimal text. Once the stream and
    # hash provider are both created, the finally block disposes both resources.
    #
    # .PARAMETER LiteralPath
    # Literal path of the file to hash. Wildcards are not expanded.
    #
    # .EXAMPLE
    # $strDigest = Get-FileSha256Hex -LiteralPath './STYLE_GUIDE.md'
    #
    # # Returns the lowercase SHA-256 digest of the file bytes.
    #
    # .EXAMPLE
    # Get-FileSha256Hex -LiteralPath '.\missing-file'
    #
    # # Throws the underlying file-open exception when the file is unavailable.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. A 64-character lowercase SHA-256 digest. File-open and
    # provider-creation failures propagate before protected hashing begins. Read
    # and hashing failures propagate after both created resources are disposed;
    # parameter-binding failures propagate before the function body runs.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    $objStream = New-Object System.IO.FileStream(
        $LiteralPath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    $objSha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ConvertTo-LowerHex -Bytes $objSha256.ComputeHash($objStream)
    } finally {
        $objSha256.Dispose()
        $objStream.Dispose()
    }
}

function Test-PathTextIsSafe {
    # .SYNOPSIS
    # Tests whether path text is an acceptable absolute literal path.
    #
    # .DESCRIPTION
    # Rejects null, empty, whitespace-only, control-bearing, wildcard-bearing,
    # provider-qualified, relative, and drive-relative path text. The test is
    # lexical and does not access the filesystem.
    #
    # .PARAMETER RawPath
    # Path text to test. Null is accepted as input and returns false.
    #
    # .EXAMPLE
    # $boolSafe = Test-PathTextIsSafe -RawPath ([System.IO.Path]::GetFullPath('.'))
    #
    # # $boolSafe is true for an ordinary absolute path string.
    #
    # .EXAMPLE
    # $boolSafe = Test-PathTextIsSafe -RawPath '..\relative'
    #
    # # $boolSafe is false because the path is not rooted.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Boolean. True only when the supplied text passes every lexical
    # safety check; otherwise false. Parameter-binding or platform path-parser
    # failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: RawPath
    param (
        [AllowNull()]
        [string]$RawPath
    )

    if ($null -eq $RawPath -or $RawPath.Length -eq 0 -or $RawPath.Trim().Length -eq 0) {
        return $false
    }

    foreach ($chrCharacter in $RawPath.ToCharArray()) {
        $intCodePoint = [int]$chrCharacter
        if ($intCodePoint -lt 32 -or $intCodePoint -eq 127) {
            return $false
        }
    }

    if ($RawPath.IndexOfAny([char[]]'*?[]') -ge 0 -or $RawPath -match '^[^\\/]+::') {
        return $false
    }

    if (-not [System.IO.Path]::IsPathRooted($RawPath) -or $RawPath -match '^[A-Za-z]:[^\\/]') {
        return $false
    }

    return $true
}

function Assert-OrdinaryPathComponent {
    # .SYNOPSIS
    # Asserts that one path component has the required ordinary filesystem type.
    #
    # .DESCRIPTION
    # Requires the literal path to exist, rejects reparse points, and requires
    # its directory attribute to agree with the requested Directory or File type.
    #
    # .PARAMETER LiteralPath
    # Literal filesystem path to inspect. Wildcards are not expanded.
    #
    # .PARAMETER ExpectedType
    # Required component type: Directory or File.
    #
    # .EXAMPLE
    # Assert-OrdinaryPathComponent -LiteralPath $strRoot -ExpectedType Directory
    #
    # # Produces no output when the path is an ordinary directory.
    #
    # .EXAMPLE
    # Assert-OrdinaryPathComponent -LiteralPath $strLink -ExpectedType File
    #
    # # Throws 'reparse-path' when the component is a reparse point.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'missing-path' when both existence probes return false,
    # including when those APIs absorb an access or filesystem error. Throws
    # 'reparse-path' or 'nonordinary-path' for later assertion failures. Metadata
    # and access exceptions raised after existence is established are propagated;
    # parameter-binding failures occur before the function body runs.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    #   Position 1: ExpectedType
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Directory', 'File')]
        [string]$ExpectedType
    )

    if (-not [System.IO.File]::Exists($LiteralPath) -and -not [System.IO.Directory]::Exists($LiteralPath)) {
        throw "missing-path"
    }

    $objAttributes = [System.IO.File]::GetAttributes($LiteralPath)
    if (($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "reparse-path"
    }

    $boolIsDirectory = ($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0
    if (($ExpectedType -eq 'Directory' -and -not $boolIsDirectory) -or
        ($ExpectedType -eq 'File' -and $boolIsDirectory)) {
        throw "nonordinary-path"
    }

    # A required File component must be a regular file. On Unix a FIFO, socket, or
    # device carries neither the Directory nor ReparsePoint attribute, so the
    # checks above accept it, yet a later read of the validated path
    # (Get-FileSha256Hex or ReadAllBytes on the candidate) would block forever on a
    # FIFO. Reject the non-regular Unix types through the UnixMode string, matching
    # the Get-TreeEvidence guard; the check is a no-op where UnixMode is absent
    # (Windows) and never fires on a regular file ('-'). Directory components skip
    # it because a special entry can never satisfy the Directory attribute above.
    if ($ExpectedType -eq 'File') {
        $objFileComponentInfo = New-Object System.IO.FileInfo($LiteralPath)
        $objUnixModeProperty = $objFileComponentInfo.PSObject.Properties['UnixMode']
        if ($null -ne $objUnixModeProperty) {
            $strUnixMode = [string]$objUnixModeProperty.Value
            if ($strUnixMode.Length -gt 0 -and ($strUnixMode[0] -eq 'p' -or
                $strUnixMode[0] -eq 's' -or $strUnixMode[0] -eq 'b' -or
                $strUnixMode[0] -eq 'c')) {
                throw "nonordinary-path"
            }
        } elseif ($env:OS -ne 'Windows_NT') {
            # Non-Windows host that does not expose UnixMode (for example PowerShell
            # 7.0): the type cannot be read, so fail closed rather than accept a
            # potentially blocking special file.
            throw "nonordinary-path"
        }
    }
}

function Get-OrdinaryDestinationState {
    # .SYNOPSIS
    # Gets the permitted filesystem state of one fixed destination leaf.
    #
    # .DESCRIPTION
    # Reads the leaf attributes without following a link. Returns Absent only
    # for a missing leaf. Returns Existing only for an ordinary non-reparse
    # file. Rejects a directory, link, reparse point, or other unexpected entry.
    #
    # .PARAMETER LiteralPath
    # Absolute literal destination path to inspect. Wildcards are not expanded.
    #
    # .EXAMPLE
    # $strState = Get-OrdinaryDestinationState -LiteralPath $strDestinationPath
    #
    # # Returns Existing for one ordinary file or Absent for a missing leaf.
    #
    # .EXAMPLE
    # Get-OrdinaryDestinationState -LiteralPath $strLinkPath
    #
    # # Throws 'unexpected-destination' for a link or reparse point.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. Returns Existing or Absent. Throws
    # 'unexpected-destination' for every other filesystem state. Access and
    # metadata failures other than proved absence propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    try {
        $objAttributes = [System.IO.File]::GetAttributes($LiteralPath)
    } catch [System.IO.FileNotFoundException] {
        return 'Absent'
    } catch [System.IO.DirectoryNotFoundException] {
        return 'Absent'
    }

    if (($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or
        ($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
        throw 'unexpected-destination'
    }
    # On Unix an entry that is neither a directory nor a reparse point can still be
    # a FIFO, socket, or device, which file attributes report as Normal and do not
    # distinguish from a regular file. A later Get-FileSha256Hex opens the leaf for
    # reading, and opening a FIFO blocks until a writer appears, so a non-regular
    # entry must be refused here rather than classified as an ordinary file. Query
    # the type through PowerShell's UnixMode string (StrictMode-safe via
    # PSObject.Properties); the check is a no-op where UnixMode is absent (Windows,
    # which has no such entries in the filesystem namespace) and never fires on a
    # regular file ('-'). This mirrors the Get-TreeEvidence special-entry guard.
    $objLeafInfo = New-Object System.IO.FileInfo($LiteralPath)
    $objUnixModeProperty = $objLeafInfo.PSObject.Properties['UnixMode']
    if ($null -ne $objUnixModeProperty) {
        $strUnixMode = [string]$objUnixModeProperty.Value
        if ($strUnixMode.Length -gt 0 -and ($strUnixMode[0] -eq 'p' -or
            $strUnixMode[0] -eq 's' -or $strUnixMode[0] -eq 'b' -or
            $strUnixMode[0] -eq 'c')) {
            throw 'unexpected-destination'
        }
    } elseif ($env:OS -ne 'Windows_NT') {
        # Non-Windows host that does not expose UnixMode (for example PowerShell 7.0):
        # the type cannot be read, so fail closed rather than accept a potentially
        # blocking special destination.
        throw 'unexpected-destination'
    }
    return 'Existing'
}

function Test-FileSystemEntry {
    # .SYNOPSIS
    # Tests whether any filesystem entry occupies one literal path.
    #
    # .DESCRIPTION
    # Reads attributes without following a link. Returns false only when the
    # leaf or one parent is absent. Returns true for files, directories, links,
    # and reparse points. Other access or metadata failures propagate.
    #
    # .PARAMETER LiteralPath
    # Absolute literal path to inspect. Wildcards are not expanded.
    #
    # .EXAMPLE
    # $boolOccupied = Test-FileSystemEntry -LiteralPath $strCandidatePath
    #
    # # Returns true when any entry occupies the candidate path.
    #
    # .EXAMPLE
    # $boolOccupied = Test-FileSystemEntry -LiteralPath $strFreshPath
    #
    # # Returns false when the path is absent.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Boolean. True for an occupied path and false for proved absence.
    # Access and metadata failures other than absence propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    try {
        [void][System.IO.File]::GetAttributes($LiteralPath)
        return $true
    } catch [System.IO.FileNotFoundException] {
        return $false
    } catch [System.IO.DirectoryNotFoundException] {
        return $false
    }
}

function Assert-OrdinaryAbsolutePath {
    # .SYNOPSIS
    # Resolves and validates an absolute ordinary filesystem path.
    #
    # .DESCRIPTION
    # Applies the lexical path-safety check, normalizes the path to a full path,
    # and validates the leaf and every ancestor as non-reparse ordinary filesystem
    # objects of the required types.
    #
    # .PARAMETER LiteralPath
    # Absolute literal path to normalize and validate.
    #
    # .PARAMETER ExpectedLeafType
    # Required type of the leaf path: Directory or File.
    #
    # .EXAMPLE
    # $strRoot = Assert-OrdinaryAbsolutePath -LiteralPath $strCandidate -ExpectedLeafType Directory
    #
    # # Returns the normalized full path after validating the directory and its ancestors.
    #
    # .EXAMPLE
    # Assert-OrdinaryAbsolutePath -LiteralPath '..\relative' -ExpectedLeafType File
    #
    # # Throws 'invalid-path' because the supplied text is not an absolute safe path.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The normalized full path. Throws 'invalid-path' or a failure
    # from Assert-OrdinaryPathComponent; parameter-binding and path-normalization
    # failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    #   Position 1: ExpectedLeafType
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Directory', 'File')]
        [string]$ExpectedLeafType
    )

    if (-not (Test-PathTextIsSafe -RawPath $LiteralPath)) {
        throw "invalid-path"
    }

    $strFullPath = [System.IO.Path]::GetFullPath($LiteralPath)
    $listComponents = New-Object 'System.Collections.Generic.List[System.IO.FileSystemInfo]'
    if ($ExpectedLeafType -eq 'Directory') {
        $objLeaf = New-Object System.IO.DirectoryInfo($strFullPath)
        $objCurrent = $objLeaf
    } else {
        $objLeaf = New-Object System.IO.FileInfo($strFullPath)
        $listComponents.Add($objLeaf)
        $objCurrent = $objLeaf.Directory
    }
    while ($null -ne $objCurrent) {
        $listComponents.Add($objCurrent)
        $objCurrent = $objCurrent.Parent
    }

    for ($intIndex = $listComponents.Count - 1; $intIndex -ge 0; $intIndex--) {
        $strExpectedType = if ($intIndex -eq 0) { $ExpectedLeafType } else { 'Directory' }
        Assert-OrdinaryPathComponent -LiteralPath $listComponents[$intIndex].FullName -ExpectedType $strExpectedType
    }

    return $strFullPath
}

function Test-PathContainedByRoot {
    # .SYNOPSIS
    # Tests whether a candidate path is lexically below a root path.
    #
    # .DESCRIPTION
    # Appends one directory separator to the trimmed root and compares the
    # candidate prefix with the platform-specific ordinal path comparison. The
    # root itself is not considered contained by this test.
    #
    # .PARAMETER Root
    # Normalized absolute root path that defines the containment boundary.
    #
    # .PARAMETER Candidate
    # Normalized absolute candidate path to compare with the root boundary.
    #
    # .EXAMPLE
    # $boolContained = Test-PathContainedByRoot -Root $strRoot -Candidate (Join-Path $strRoot 'file.md')
    #
    # # $boolContained is true for a lexical descendant of the root.
    #
    # .EXAMPLE
    # $boolContained = Test-PathContainedByRoot -Root $strRoot -Candidate $strRoot
    #
    # # $boolContained is false because the root path is not its own descendant.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Boolean. True for a lexical descendant and false otherwise. String
    # operation or parameter-binding failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Root
    #   Position 1: Candidate
    param (
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$Candidate
    )

    $strRootWithSeparator = $Root.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar

    return $Candidate.StartsWith($strRootWithSeparator, $script:objPathComparison)
}

function Initialize-WindowsFileIdentityType {
    # .SYNOPSIS
    # Loads the Windows ordinary-file identity helper type when required.
    #
    # .DESCRIPTION
    # On Windows, compiles the PSStyleGuide.NativeFileIdentity type once. The
    # type reads volume and file-index identity from an open handle and rejects
    # files whose hard-link count is not exactly one. Other platforms are no-ops.
    #
    # .EXAMPLE
    # Initialize-WindowsFileIdentityType
    #
    # # Loads the helper on Windows or returns without output on another platform.
    #
    # .EXAMPLE
    # Initialize-WindowsFileIdentityType
    # Initialize-WindowsFileIdentityType
    #
    # # The second call returns without recompiling an already loaded type.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Add-Type compilation and type-loading failures are propagated on
    # Windows. Non-Windows and already-initialized calls return without failure.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function declares no parameters.
    param ()

    if ($env:OS -ne 'Windows_NT' -or ('PSStyleGuide.NativeFileIdentity' -as [type])) {
        return
    }

    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.IO;
using System.Runtime.InteropServices;

namespace PSStyleGuide {
    public static class NativeFileIdentity {
        [StructLayout(LayoutKind.Sequential)]
        private struct ByHandleFileInformation {
            public uint FileAttributes;
            public System.Runtime.InteropServices.ComTypes.FILETIME CreationTime;
            public System.Runtime.InteropServices.ComTypes.FILETIME LastAccessTime;
            public System.Runtime.InteropServices.ComTypes.FILETIME LastWriteTime;
            public uint VolumeSerialNumber;
            public uint FileSizeHigh;
            public uint FileSizeLow;
            public uint NumberOfLinks;
            public uint FileIndexHigh;
            public uint FileIndexLow;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetFileInformationByHandle(
            Microsoft.Win32.SafeHandles.SafeFileHandle handle,
            out ByHandleFileInformation information);

        public static string Read(string path) {
            using (FileStream stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read)) {
                ByHandleFileInformation information;
                if (!GetFileInformationByHandle(stream.SafeFileHandle, out information)) {
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                }
                if (information.NumberOfLinks != 1) {
                    throw new InvalidDataException("hardlink-alias");
                }
                ulong index = ((ulong)information.FileIndexHigh << 32) | information.FileIndexLow;
                return information.VolumeSerialNumber.ToString("x8") + ":" + index.ToString("x16");
            }
        }
    }
}
'@
}

function Get-OrdinaryFileIdentity {
    # .SYNOPSIS
    # Gets the stable ordinary-file identity of a literal path.
    #
    # .DESCRIPTION
    # Reads the Windows volume serial and file index or the Unix device and inode
    # from the supplied file. Both implementations require exactly one hard link
    # so aliases cannot pass as distinct ordinary files.
    #
    # .PARAMETER LiteralPath
    # Literal path of the ordinary file whose identity is required.
    #
    # .EXAMPLE
    # $strIdentity = Get-OrdinaryFileIdentity -LiteralPath './STYLE_GUIDE.md'
    #
    # # Returns a platform-specific stable identity string for the file.
    #
    # .EXAMPLE
    # Get-OrdinaryFileIdentity -LiteralPath $strHardLink
    #
    # # Throws 'hardlink-alias' when the file has more than one hard link.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. Windows returns volume:file-index text; Unix returns
    # device:inode text. Throws 'identity-failure' for a nonzero Unix stat exit,
    # unexpected output cardinality, or malformed output, and 'hardlink-alias'
    # for a non-unique link count. Parameter-binding, native invocation, and
    # identity-read failures that prevent those Unix checks from running propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    if ($env:OS -eq 'Windows_NT') {
        Initialize-WindowsFileIdentityType
        return [PSStyleGuide.NativeFileIdentity]::Read($LiteralPath)
    }

    $arrStatOutput = @(& stat '-Lc' '%h:%d:%i' '--' $LiteralPath)
    $intStatExit = $LASTEXITCODE
    if ($intStatExit -ne 0 -or $arrStatOutput.Count -ne 1 -or
        $arrStatOutput[0] -notmatch '^([1-9][0-9]*):([0-9]+):([0-9]+)$') {
        throw "identity-failure"
    }
    if ([uint64]$Matches[1] -ne 1) {
        throw "hardlink-alias"
    }
    return $Matches[2] + ':' + $Matches[3]
}

function Assert-TrackedFile {
    # .SYNOPSIS
    # Asserts that one exact repository path is tracked by Git.
    #
    # .DESCRIPTION
    # Resolves the Git application and runs ls-files with error-on-unmatched-path.
    # The assertion succeeds only when Git returns exactly one case-sensitive path
    # equal to the supplied repository-relative path.
    #
    # .PARAMETER RepositoryRoot
    # Absolute worktree root in which Git is invoked.
    #
    # .PARAMETER RepositoryPath
    # Canonical repository-relative path that must be tracked exactly once.
    #
    # .EXAMPLE
    # Assert-TrackedFile -RepositoryRoot $strRoot -RepositoryPath 'STYLE_GUIDE.md'
    #
    # # Produces no output when Git reports the exact tracked path.
    #
    # .EXAMPLE
    # Assert-TrackedFile -RepositoryRoot $strRoot -RepositoryPath 'missing.md'
    #
    # # Throws 'untracked-destination' when Git does not report exactly that path.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'untracked-destination' for a nonzero Git result, unexpected
    # cardinality, or case mismatch. Parameter-binding, Git discovery, and native
    # invocation failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: RepositoryRoot
    #   Position 1: RepositoryPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath
    )

    $arrGitCommands = @(Get-Command -Name git -CommandType Application -ErrorAction Stop)
    $strGitPath = [string]$arrGitCommands[0].Source
    $arrOutput = @(& $strGitPath -C $RepositoryRoot ls-files --error-unmatch -- $RepositoryPath 2>$null)
    $intGitExit = $LASTEXITCODE
    if ($intGitExit -ne 0 -or $arrOutput.Count -ne 1 -or $arrOutput[0] -cne $RepositoryPath) {
        throw "untracked-destination"
    }
}

function ConvertFrom-StrictUtf8 {
    # .SYNOPSIS
    # Decodes BOM-free bytes as strict UTF-8 text.
    #
    # .DESCRIPTION
    # Rejects the UTF-8 byte-order mark and decodes the complete byte sequence
    # with the script's exception-throwing UTF-8 decoder.
    #
    # .PARAMETER Bytes
    # Complete byte sequence to decode.
    #
    # .EXAMPLE
    # $strText = ConvertFrom-StrictUtf8 -Bytes ([System.Text.Encoding]::UTF8.GetBytes('text'))
    #
    # # $strText is 'text'.
    #
    # .EXAMPLE
    # ConvertFrom-StrictUtf8 -Bytes ([byte[]](0xEF, 0xBB, 0xBF, 0x41))
    #
    # # Throws 'utf8-bom' because a byte-order mark is forbidden.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. Strictly decoded UTF-8 text. Throws 'utf8-bom' for a BOM and
    # propagates DecoderFallbackException for malformed UTF-8. Parameter-binding
    # failures occur before the function body runs.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        throw "utf8-bom"
    }
    return $script:objUtf8Strict.GetString($Bytes)
}

function ConvertTo-NormalizedUtf8 {
    # .SYNOPSIS
    # Serializes complete payload text as normalized BOM-free UTF-8 bytes.
    #
    # .DESCRIPTION
    # Converts CRLF and lone CR line endings to LF in memory, then encodes the
    # complete resulting text with the script's UTF-8-without-BOM encoder.
    #
    # .PARAMETER CompleteFinalPayload
    # Complete final payload text to normalize and encode. An empty string is allowed.
    #
    # .EXAMPLE
    # $arrBytes = @(ConvertTo-NormalizedUtf8 -CompleteFinalPayload "a`r`nb`r")
    #
    # # Contains one System.Byte success-stream object per UTF-8 byte for "a`nb`n".
    #
    # .EXAMPLE
    # $arrBytes = @(ConvertTo-NormalizedUtf8 -CompleteFinalPayload '')
    #
    # # $arrBytes.Count is 0 because an empty payload emits no success-stream objects.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Byte success-stream objects, one per normalized LF-only UTF-8 byte
    # without a BOM; an empty payload emits no output. String replacement,
    # encoding, and parameter-binding failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: CompleteFinalPayload
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$CompleteFinalPayload
    )

    $strNormalizedContent = $CompleteFinalPayload -replace "`r`n?", "`n"
    return $script:objUtf8NoBom.GetBytes($strNormalizedContent)
}

function New-CopilotPayload {
    # .SYNOPSIS
    # Builds the repository Copilot-instructions payload.
    #
    # .DESCRIPTION
    # Returns the complete normative guide content unchanged for use as the
    # repository's root Copilot instruction artifact.
    #
    # .PARAMETER GuideContent
    # Complete decoded normative style-guide text.
    #
    # .EXAMPLE
    # $strPayload = New-CopilotPayload -GuideContent $strGuideContent
    #
    # # Returns the supplied guide content unchanged.
    #
    # .EXAMPLE
    # $strPayload = New-CopilotPayload -GuideContent 'guide'
    #
    # # $strPayload is 'guide'.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The exact GuideContent value. Parameter-binding failures are
    # propagated; the function defines no categorized runtime failure.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GuideContent
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent
    )

    return $GuideContent
}

function New-PowerShellInstructionsPayload {
    # .SYNOPSIS
    # Builds the scoped PowerShell-instructions payload.
    #
    # .DESCRIPTION
    # Prefixes the complete normative guide content with the fixed YAML
    # frontmatter that scopes the generated instructions to PowerShell scripts.
    #
    # .PARAMETER GuideContent
    # Complete decoded normative style-guide text.
    #
    # .EXAMPLE
    # $strPayload = New-PowerShellInstructionsPayload -GuideContent $strGuideContent
    #
    # # Returns the fixed frontmatter followed by the complete guide content.
    #
    # .EXAMPLE
    # $strPayload = New-PowerShellInstructionsPayload -GuideContent 'guide'
    #
    # # The payload ends with the supplied text 'guide'.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The fixed instruction frontmatter and GuideContent.
    # Parameter-binding and string-construction failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GuideContent
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent
    )

    $arrFrontmatterLines = @(
        '---',
        'applyTo:  "**/*.ps1"',
        'description: "PowerShell coding standards"',
        '---',
        '',
        ''
    )
    return ($arrFrontmatterLines -join "`n") + $GuideContent
}

function New-ChatPayload {
    # .SYNOPSIS
    # Builds the copy-and-paste chat payload around the normative guide.
    #
    # .DESCRIPTION
    # Removes one trailing LF or CRLF sequence, finds the longest backtick run
    # in the guide, selects a longer outer Markdown fence with a minimum length
    # of four, and wraps the guide with the fixed chat-artifact heading and
    # language tag.
    #
    # .PARAMETER GuideContent
    # Complete decoded normative style-guide text to place inside the outer fence.
    #
    # .EXAMPLE
    # $strPayload = New-ChatPayload -GuideContent $strGuideContent
    #
    # # Returns the heading and safely fenced complete guide.
    #
    # .EXAMPLE
    # $strPayload = New-ChatPayload -GuideContent ('text with ```` backticks' + "`n")
    #
    # # Uses an outer fence longer than the four-backtick run in the content.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. A newline-terminated Markdown chat payload. Regular-expression,
    # string-construction, and parameter-binding failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GuideContent
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent
    )

    $strContent = $GuideContent -replace '\r?\n$', ''
    $arrMatches = [regex]::Matches($strContent, '``+')
    $intMaximumBackticks = 0
    foreach ($objMatch in $arrMatches) {
        if ($objMatch.Length -gt $intMaximumBackticks) {
            $intMaximumBackticks = $objMatch.Length
        }
    }
    $intOuterFenceLength = [System.Math]::Max(4, $intMaximumBackticks + 1)
    $strOuterFence = '`' * $intOuterFenceLength
    return "# PowerShell Writing Style Guide - Formatted for Copy-Paste Into LLM Chat`n`n$strOuterFence" +
        "markdown`n$strContent`n$strOuterFence`n"
}

function New-FullPayload {
    # .SYNOPSIS
    # Builds the full style guide by combining normative and rationale content.
    #
    # .DESCRIPTION
    # Indexes rationale sections by normalized heading anchors, removes
    # repository-only cross-references and boundary markers, injects matching
    # rationale at explicit markers and headings, and normalizes excess blank lines.
    #
    # .PARAMETER GuideContent
    # Complete decoded normative style-guide text that defines output ordering.
    #
    # .PARAMETER RationaleContent
    # Complete decoded rationale text whose indexed sections are injected.
    #
    # .EXAMPLE
    # $strFull = New-FullPayload -GuideContent $strGuideContent -RationaleContent $strRationaleContent
    #
    # # Returns the combined newline-terminated full style guide.
    #
    # .EXAMPLE
    # New-FullPayload -GuideContent '<!-- rationale-anchor: absent -->' -RationaleContent '## Other'
    #
    # # Throws 'missing-rationale-anchor' for an explicit marker without a matching section.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The combined full-guide payload with LF-oriented text and one
    # final LF. Throws 'missing-rationale-anchor' for an unresolved explicit
    # rationale marker; parameter-binding, regex, collection, and string-operation
    # failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GuideContent
    #   Position 1: RationaleContent
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent,

        [Parameter(Mandatory = $true)]
        [string]$RationaleContent
    )

    $arrRationaleLines = $RationaleContent -split '\r?\n'
    $hashtableSections = @{}
    $hashtableRationaleHeadings = @{}
    $strCurrentAnchor = $null
    $intCurrentLevel = 0
    $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'

    foreach ($strLine in $arrRationaleLines) {
        if ($strLine -match '^(#{2,4}) (.+)$') {
            $intLevel = $Matches[1].Length
            $strHeadingText = $Matches[2]
            if ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
                $hashtableSections[$strCurrentAnchor] = $listCurrentBody.ToArray()
            }
            $strAnchor = $strHeadingText.ToLower() -replace '[^a-z0-9 -]', '' -replace ' ', '-'
            $strAnchor = $strAnchor -replace '-+', '-' -replace '^-|-$', ''
            if ($intLevel -eq 3) {
                $strCurrentAnchor = $strAnchor
                $intCurrentLevel = 3
                $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'
                $hashtableRationaleHeadings[$strAnchor] = '### ' + $strHeadingText
            } elseif ($intLevel -eq 2) {
                $strCurrentAnchor = $null
                $intCurrentLevel = 2
            } elseif ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
                $listCurrentBody.Add($strLine)
            }
        } elseif ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
            $listCurrentBody.Add($strLine)
        }
    }
    if ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
        $hashtableSections[$strCurrentAnchor] = $listCurrentBody.ToArray()
    }

    $boolInExecutiveSummary = $false
    $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'
    foreach ($strLine in $arrRationaleLines) {
        if ($strLine -match '^## Executive Summary: Author Profile') {
            $boolInExecutiveSummary = $true
            $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'
        } elseif ($boolInExecutiveSummary -and $strLine -match '^## ') {
            $hashtableSections['executive-summary-author-profile'] = $listCurrentBody.ToArray()
            $hashtableRationaleHeadings['executive-summary-author-profile'] = '## Executive Summary: Author Profile'
            $boolInExecutiveSummary = $false
        } elseif ($boolInExecutiveSummary) {
            $listCurrentBody.Add($strLine)
        }
    }
    if ($boolInExecutiveSummary) {
        $hashtableSections['executive-summary-author-profile'] = $listCurrentBody.ToArray()
        $hashtableRationaleHeadings['executive-summary-author-profile'] = '## Executive Summary: Author Profile'
    }

    $hashtableCleanSections = @{}
    foreach ($strKey in $hashtableSections.Keys) {
        $arrFiltered = @($hashtableSections[$strKey] | Where-Object {
            -not ($_ -match '^> For .+\(STYLE_GUIDE\.md#')
        })
        $arrConverted = @($arrFiltered | ForEach-Object {
            $_ -replace 'STYLE_GUIDE\.md#', '#' -replace '\[([^\]]+)\]\(STYLE_GUIDE\.md\)', '[$1](#powershell-writing-style)'
        })
        $intStart = 0
        while ($intStart -lt $arrConverted.Count -and $arrConverted[$intStart].Trim() -eq '') {
            $intStart++
        }
        $intEnd = $arrConverted.Count - 1
        while ($intEnd -ge 0 -and
            ($arrConverted[$intEnd].Trim() -eq '' -or $arrConverted[$intEnd].Trim() -eq '---')) {
            $intEnd--
        }
        if ($intStart -le $intEnd) {
            $hashtableCleanSections[$strKey] = $arrConverted[$intStart..$intEnd]
        }
    }

    $arrGuideLines = $GuideContent -split '\r?\n'
    $listOutputLines = New-Object 'System.Collections.Generic.List[string]'
    foreach ($strLine in $arrGuideLines) {
        if ($strLine.Trim() -eq '*This section intentionally left blank.*') {
            continue
        }
        if ($strLine -match '^\s*<!--\s*rationale-toc:\s*(.+?)\s*-->\s*$') {
            $listOutputLines.Add($Matches[1].Trim())
            continue
        }
        if ($strLine -match '^\s*<!--\s*rationale-anchor:\s*(.+?)\s*-->\s*$') {
            $strCommentAnchor = $Matches[1].Trim()
            if (-not $hashtableCleanSections.ContainsKey($strCommentAnchor) -or
                -not $hashtableRationaleHeadings.ContainsKey($strCommentAnchor)) {
                throw "missing-rationale-anchor"
            }
            $listOutputLines.Add('')
            $listOutputLines.Add($hashtableRationaleHeadings[$strCommentAnchor])
            $listOutputLines.Add('')
            foreach ($strRationaleLine in $hashtableCleanSections[$strCommentAnchor]) {
                $listOutputLines.Add($strRationaleLine)
            }
            continue
        }

        $listOutputLines.Add($strLine)
        if ($strLine -match '^(#{2,3}) (.+)$') {
            $strHeadingText = $Matches[2]
            $strAnchor = $strHeadingText.ToLower() -replace '[^a-z0-9 -]', '' -replace ' ', '-'
            $strAnchor = $strAnchor -replace '-+', '-' -replace '^-|-$', ''
            if ($hashtableCleanSections.ContainsKey($strAnchor)) {
                $listOutputLines.Add('')
                foreach ($strRationaleLine in $hashtableCleanSections[$strAnchor]) {
                    $listOutputLines.Add($strRationaleLine)
                }
            }
        }
    }

    $strOutput = $listOutputLines.ToArray() -join "`n"
    while ($strOutput -match "`n`n`n") {
        $strOutput = $strOutput -replace "`n`n`n", "`n`n"
    }
    return $strOutput.TrimEnd("`n") + "`n"
}

function New-StyleGuidePayloadMap {
    # .SYNOPSIS
    # Builds all four serialized style-guide payloads in memory.
    #
    # .DESCRIPTION
    # Strictly decodes the two source byte sequences, constructs the Copilot,
    # PowerShell-instructions, chat, and full text payloads, normalizes each to
    # BOM-free LF-only UTF-8 bytes, and verifies the serialization invariants.
    #
    # .PARAMETER GuideBytes
    # Complete BOM-free UTF-8 bytes of the normative style guide.
    #
    # .PARAMETER RationaleBytes
    # Complete BOM-free UTF-8 bytes of the style-guide rationale.
    #
    # .EXAMPLE
    # $hashtablePayload = New-StyleGuidePayloadMap -GuideBytes $arrGuideBytes -RationaleBytes $arrRationaleBytes
    #
    # # Returns four artifact identifiers mapped to their complete serialized bytes.
    #
    # .EXAMPLE
    # New-StyleGuidePayloadMap -GuideBytes ([byte[]](0xEF, 0xBB, 0xBF)) -RationaleBytes $arrRationaleBytes
    #
    # # Throws 'utf8-bom' because source byte-order marks are forbidden.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Keys are copilot,
    # powershell-instructions, chat, and full. Every value is System.Byte[],
    # including zero- or one-byte payloads. Throws 'utf8-bom', 'payload-bom',
    # 'payload-cr', or a payload-builder failure. Parameter-binding and strict
    # UTF-8 decoding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GuideBytes
    #   Position 1: RationaleBytes
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$GuideBytes,

        [Parameter(Mandatory = $true)]
        [byte[]]$RationaleBytes
    )

    $strGuideContent = ConvertFrom-StrictUtf8 -Bytes $GuideBytes
    $strRationaleContent = ConvertFrom-StrictUtf8 -Bytes $RationaleBytes
    $hashtablePayloadStrings = [ordered]@{
        copilot = New-CopilotPayload -GuideContent $strGuideContent
        'powershell-instructions' = New-PowerShellInstructionsPayload -GuideContent $strGuideContent
        chat = New-ChatPayload -GuideContent $strGuideContent
        full = New-FullPayload -GuideContent $strGuideContent -RationaleContent $strRationaleContent
    }

    $hashtablePayloadBytes = [ordered]@{}
    foreach ($strArtifactId in $hashtablePayloadStrings.Keys) {
        [byte[]]$arrBytes = @(
            ConvertTo-NormalizedUtf8 -CompleteFinalPayload $hashtablePayloadStrings[$strArtifactId]
        )
        if ($arrBytes.Length -ge 3 -and $arrBytes[0] -eq 0xEF -and $arrBytes[1] -eq 0xBB -and $arrBytes[2] -eq 0xBF) {
            throw "payload-bom"
        }
        if ($arrBytes -contains [byte]0x0D) {
            throw "payload-cr"
        }
        $hashtablePayloadBytes[$strArtifactId] = $arrBytes
    }
    return $hashtablePayloadBytes
}

function New-ArtifactRecord {
    # .SYNOPSIS
    # Creates the initial evidence record for one generated artifact.
    #
    # .DESCRIPTION
    # Returns the fixed ordered record schema with the artifact identity and path,
    # null measurement fields, false publication evidence, initial temporary and
    # cleanup dispositions, and a NotAttempted status.
    #
    # .PARAMETER ArtifactId
    # Internal artifact identifier stored in the record.
    #
    # .PARAMETER RepositoryPath
    # Canonical repository-relative destination path stored in the record.
    #
    # .EXAMPLE
    # $hashtableRecord = New-ArtifactRecord -ArtifactId copilot -RepositoryPath 'copilot-instructions.md'
    #
    # # Returns a NotAttempted record with all measurement fields set to null.
    #
    # .EXAMPLE
    # $hashtableRecord = New-ArtifactRecord -ArtifactId full -RepositoryPath 'STYLE_GUIDE_FULL.md'
    #
    # # $hashtableRecord.PublicationReturned is false and CleanupResult is 'NotRequired'.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains the fixed artifact
    # evidence fields in serialization order. Parameter-binding or allocation
    # failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: ArtifactId
    #   Position 1: RepositoryPath
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ArtifactId,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath
    )

    return [ordered]@{
        ArtifactId = $ArtifactId
        Path = $RepositoryPath
        OriginalState = 'Unknown'
        OriginalLength = $null
        OriginalSha256 = $null
        OriginalOrdinaryIdentity = $null
        CandidateLength = $null
        CandidateSha256 = $null
        CandidateOrdinaryIdentity = $null
        FinalLength = $null
        FinalSha256 = $null
        FinalOrdinaryIdentity = $null
        FinalState = 'Unknown'
        PublicationMethod = 'NotAttempted'
        PublicationReturned = $false
        TemporaryDisposition = 'NotCreated'
        CleanupResult = 'NotRequired'
        Status = 'NotAttempted'
    }
}

function Initialize-AtomicFileReplacementType {
    # .SYNOPSIS
    # Loads the atomic file-replacement helper type when required.
    #
    # .DESCRIPTION
    # Compiles PSStyleGuide.AtomicFileReplacement once. Its Replace method calls
    # System.IO.File.Replace without a backup path so the candidate replaces the
    # existing destination atomically on the same filesystem.
    #
    # .EXAMPLE
    # Initialize-AtomicFileReplacementType
    #
    # # Loads the replacement type without producing success output.
    #
    # .EXAMPLE
    # Initialize-AtomicFileReplacementType
    # Initialize-AtomicFileReplacementType
    #
    # # The second call returns without recompiling the loaded type.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Add-Type compilation and type-loading failures are propagated; an
    # already initialized call returns without failure.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function declares no parameters.
    param ()

    if ('PSStyleGuide.AtomicFileReplacement' -as [type]) {
        return
    }

    Add-Type -TypeDefinition @'
using System.IO;

namespace PSStyleGuide {
    public static class AtomicFileReplacement {
        public static void Replace(string candidatePath, string destinationPath) {
            File.Replace(candidatePath, destinationPath, null);
        }
    }
}
'@
}

function Write-StyleGuideArtifact {
    # .SYNOPSIS
    # Publishes one complete style-guide payload to its fixed destination.
    #
    # .DESCRIPTION
    # Validates the authorized index-tracked destination as absent or one
    # ordinary file. Returns NoChange for identical bytes. Otherwise, creates,
    # durably writes, closes, and verifies one unique sibling candidate. It
    # revalidates all filesystem state before one File.Replace or File.Move call.
    # It records bounded final evidence and never attempts rollback after the
    # publication call returns.
    #
    # .PARAMETER ArtifactId
    # Authorized artifact identifier: copilot, powershell-instructions, chat, or full.
    #
    # .PARAMETER RawDestinationPath
    # Absolute literal destination path supplied for the selected artifact.
    #
    # .PARAMETER CompletePayloadBytes
    # Complete normalized payload bytes to compare and, when needed, publish.
    #
    # .PARAMETER RepositoryRoot
    # Validated absolute repository root that bounds and anchors the destination.
    #
    # .PARAMETER DestinationMap
    # Artifact identifier to canonical repository-relative destination mapping.
    #
    # .EXAMPLE
    # $hashtableRecord = Write-StyleGuideArtifact -ArtifactId copilot -RawDestinationPath $strPath -CompletePayloadBytes $arrBytes -RepositoryRoot $strRoot -DestinationMap $hashtableMap
    #
    # # Returns a NoChange or Success artifact evidence record.
    #
    # .EXAMPLE
    # Write-StyleGuideArtifact -ArtifactId full -RawDestinationPath $strWrongPath -CompletePayloadBytes $arrBytes -RepositoryRoot $strRoot -DestinationMap $hashtableMap
    #
    # # Throws InvalidOperationException with ArtifactRecord and Phase data after validation fails.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Status is NoChange or
    # Success. After artifact-record initialization, any failure throws
    # System.InvalidOperationException whose Data contains ArtifactRecord and
    # Phase; the record status is Failed or ReplacementStateUncertain and retains
    # cleanup and publication evidence. Parameter binding, destination-map lookup,
    # and record-initialization failures propagate without those Data entries.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: ArtifactId
    #   Position 1: RawDestinationPath
    #   Position 2: CompletePayloadBytes
    #   Position 3: RepositoryRoot
    #   Position 4: DestinationMap
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('copilot', 'powershell-instructions', 'chat', 'full')]
        [string]$ArtifactId,

        [Parameter(Mandatory = $true)]
        [string]$RawDestinationPath,

        [Parameter(Mandatory = $true)]
        [byte[]]$CompletePayloadBytes,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$DestinationMap
    )

    $strExpectedRepositoryPath = $DestinationMap[$ArtifactId]
    $hashtableRecord = New-ArtifactRecord -ArtifactId $ArtifactId -RepositoryPath $strExpectedRepositoryPath
    $hashtableRecord.Status = 'Pending'
    $strTemporaryPath = $null
    $strCandidateIdentity = $null
    $boolTemporaryIdentityProven = $false
    $objCandidateStream = $null
    $strPhase = 'validate-destination'

    try {
        if (-not (Test-PathTextIsSafe -RawPath $RawDestinationPath)) {
            throw 'invalid-destination'
        }
        $strExpectedFullPath = [System.IO.Path]::GetFullPath(
            (Join-Path $RepositoryRoot ($strExpectedRepositoryPath -replace '/', [System.IO.Path]::DirectorySeparatorChar))
        )
        $strDestinationPath = [System.IO.Path]::GetFullPath($RawDestinationPath)
        if (-not (Test-PathContainedByRoot -Root $RepositoryRoot -Candidate $strDestinationPath) -or
            -not $strDestinationPath.Equals($strExpectedFullPath, $script:objPathComparison)) {
            throw 'artifact-path-mismatch'
        }

        $strParentPath = [System.IO.Path]::GetDirectoryName($strDestinationPath)
        $strParentPath = Assert-OrdinaryAbsolutePath -LiteralPath $strParentPath -ExpectedLeafType Directory
        Assert-TrackedFile -RepositoryRoot $RepositoryRoot -RepositoryPath $strExpectedRepositoryPath
        $hashtableRecord.OriginalState = Get-OrdinaryDestinationState -LiteralPath $strDestinationPath
        if ($hashtableRecord.OriginalState -eq 'Existing') {
            $hashtableRecord.OriginalLength = (New-Object System.IO.FileInfo($strDestinationPath)).Length
            $hashtableRecord.OriginalSha256 = Get-FileSha256Hex -LiteralPath $strDestinationPath
            $hashtableRecord.OriginalOrdinaryIdentity = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath
        }

        $hashtableRecord.CandidateLength = $CompletePayloadBytes.Length
        $hashtableRecord.CandidateSha256 = Get-Sha256Hex -Bytes $CompletePayloadBytes
        if ($hashtableRecord.OriginalState -eq 'Existing' -and
            $hashtableRecord.OriginalLength -eq $hashtableRecord.CandidateLength -and
            $hashtableRecord.OriginalSha256 -ceq $hashtableRecord.CandidateSha256) {
            $hashtableRecord.FinalState = 'Existing'
            $hashtableRecord.FinalLength = $hashtableRecord.OriginalLength
            $hashtableRecord.FinalSha256 = $hashtableRecord.OriginalSha256
            $hashtableRecord.FinalOrdinaryIdentity = $hashtableRecord.OriginalOrdinaryIdentity
            $hashtableRecord.PublicationMethod = 'NotRequired'
            $hashtableRecord.Status = 'NoChange'
            return $hashtableRecord
        }

        if ($hashtableRecord.OriginalState -eq 'Existing') {
            $strPhase = 'initialize-publication'
            Initialize-AtomicFileReplacementType
        }

        $strPhase = 'create-candidate'
        for ($intAttempt = 1; $intAttempt -le 16; $intAttempt++) {
            $strCandidateLeaf = '.psstyleguide-' + [guid]::NewGuid().ToString('N') + '.tmp'
            $strTemporaryPath = Join-Path $strParentPath $strCandidateLeaf
            try {
                $objCandidateStream = New-Object System.IO.FileStream(
                    $strTemporaryPath,
                    [System.IO.FileMode]::CreateNew,
                    [System.IO.FileAccess]::Write,
                    [System.IO.FileShare]::None
                )
                $hashtableRecord.TemporaryDisposition = 'Created'
                break
            } catch [System.IO.IOException] {
                $boolCollision = Test-FileSystemEntry -LiteralPath $strTemporaryPath
                $strTemporaryPath = $null
                if (-not $boolCollision) {
                    throw
                }
                if ($intAttempt -eq 16) {
                    throw 'candidate-collision-limit'
                }
            }
        }
        if ($null -eq $objCandidateStream) {
            throw 'candidate-create-failure'
        }

        # Write and flush through the retained CreateNew handle rather than closing it
        # and reopening the path. A path-based reopen (FileMode.Open) would follow a
        # symlink that another process could substitute at the candidate path after
        # the close, sending the payload to the link target; the CreateNew handle is
        # bound to the file this process created, so the write cannot be redirected.
        # The ordinary-path assertion and identity capture below then confirm the
        # on-disk candidate and fail closed if the path was replaced during the write.
        $strPhase = 'write-candidate'
        try {
            $objCandidateStream.Write($CompletePayloadBytes, 0, $CompletePayloadBytes.Length)
            $strPhase = 'flush-candidate'
            $objCandidateStream.Flush($true)
        } finally {
            $objCandidateStream.Dispose()
            $objCandidateStream = $null
        }

        # The write and flush have already returned; this block captures the
        # candidate's proven identity, so a failure here is not a flush failure.
        # Tag it under its own phase rather than 'flush-candidate' so the artifact
        # evidence names the step accurately. This phase ends exactly where
        # $boolTemporaryIdentityProven becomes true, which is the same boundary the
        # cleanup path uses to decide a retained candidate can be safely removed.
        $strPhase = 'capture-candidate'
        $strCandidateFullPath = Assert-OrdinaryAbsolutePath -LiteralPath $strTemporaryPath -ExpectedLeafType File
        if (-not [System.IO.Path]::GetDirectoryName($strCandidateFullPath).Equals($strParentPath, $script:objPathComparison)) {
            throw 'candidate-parent-mismatch'
        }
        $strCandidateIdentity = Get-OrdinaryFileIdentity -LiteralPath $strCandidateFullPath
        $boolTemporaryIdentityProven = $true
        $hashtableRecord.CandidateOrdinaryIdentity = $strCandidateIdentity

        $strPhase = 'verify-candidate'
        $strCandidateFullPath = Assert-OrdinaryAbsolutePath -LiteralPath $strTemporaryPath -ExpectedLeafType File
        if (-not [System.IO.Path]::GetDirectoryName($strCandidateFullPath).Equals($strParentPath, $script:objPathComparison) -or
            (Get-OrdinaryFileIdentity -LiteralPath $strCandidateFullPath) -cne $strCandidateIdentity) {
            throw 'candidate-identity-drift'
        }
        $arrCandidateBytes = [System.IO.File]::ReadAllBytes($strCandidateFullPath)
        if ($arrCandidateBytes.Length -ne $CompletePayloadBytes.Length -or
            (Get-Sha256Hex -Bytes $arrCandidateBytes) -cne $hashtableRecord.CandidateSha256) {
            throw 'candidate-byte-mismatch'
        }
        if (($arrCandidateBytes.Length -ge 3 -and $arrCandidateBytes[0] -eq 0xEF -and
            $arrCandidateBytes[1] -eq 0xBB -and $arrCandidateBytes[2] -eq 0xBF) -or
            $arrCandidateBytes -contains [byte]0x0D -or $arrCandidateBytes.Length -eq 0 -or
            $arrCandidateBytes[$arrCandidateBytes.Length - 1] -ne 0x0A) {
            throw 'candidate-serialization'
        }

        $strPhase = 'revalidate-publication'
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strParentPath -ExpectedLeafType Directory)
        $strCurrentDestinationState = Get-OrdinaryDestinationState -LiteralPath $strDestinationPath
        if ($strCurrentDestinationState -cne $hashtableRecord.OriginalState) {
            throw 'destination-state-drift'
        }
        if ($strCurrentDestinationState -eq 'Existing') {
            [void](Assert-OrdinaryAbsolutePath -LiteralPath $strDestinationPath -ExpectedLeafType File)
            if ((Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath) -cne
                $hashtableRecord.OriginalOrdinaryIdentity -or
                (New-Object System.IO.FileInfo($strDestinationPath)).Length -ne $hashtableRecord.OriginalLength -or
                (Get-FileSha256Hex -LiteralPath $strDestinationPath) -cne $hashtableRecord.OriginalSha256) {
                throw 'destination-content-drift'
            }
        }
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strTemporaryPath -ExpectedLeafType File)
        if ((Get-OrdinaryFileIdentity -LiteralPath $strTemporaryPath) -cne $strCandidateIdentity -or
            (Get-FileSha256Hex -LiteralPath $strTemporaryPath) -cne $hashtableRecord.CandidateSha256) {
            throw 'candidate-content-drift'
        }

        # ACCEPTED BOUNDED RESIDUAL (publication substitution window). The revalidation
        # above re-proves the candidate identity and bytes, but File.Replace and
        # File.Move resolve the source by PATH. Between that final proof and the
        # rename below, a second writer with write access to the parent directory
        # could rename the verified candidate away and place different bytes at the
        # same temporary path; the path-based rename would then publish the
        # substituted bytes. No portable mechanism closes this: .NET exposes no
        # handle-bound rename, POSIX rename is not fd-bound and does not honor a
        # share mode, and a delete-denying handle held across the call would instead
        # block the very rename this code must perform. The residual is bounded and
        # never yields a false success -- the verify-publication phase below reads
        # the published bytes and reports final-byte-drift / ReplacementStateUncertain
        # on any mismatch, so a substitution fails closed with truthful evidence. The
        # window requires a concurrent second writer racing a sub-second interval,
        # which the single-actor CI trust root (docs/decisions/0001) does not have,
        # and such a writer already has directory write access and so gains nothing
        # beyond a truthfully reported failure it could cause by writing directly.
        $strPhase = 'publish-destination'
        if ($hashtableRecord.OriginalState -eq 'Existing') {
            $hashtableRecord.PublicationMethod = 'File.Replace'
            [PSStyleGuide.AtomicFileReplacement]::Replace($strTemporaryPath, $strDestinationPath)
            $hashtableRecord.TemporaryDisposition = 'ConsumedByReplace'
        } else {
            $hashtableRecord.PublicationMethod = 'File.Move'
            [System.IO.File]::Move($strTemporaryPath, $strDestinationPath)
            $hashtableRecord.TemporaryDisposition = 'ConsumedByMove'
        }
        $hashtableRecord.PublicationReturned = $true
        $hashtableRecord.CleanupResult = 'NotRequired'

        $strPhase = 'verify-publication'
        if (Test-FileSystemEntry -LiteralPath $strTemporaryPath) {
            $hashtableRecord.TemporaryDisposition = 'RetainedForRecovery'
            $hashtableRecord.CleanupResult = 'NotAttempted'
            throw 'candidate-not-consumed'
        }
        $hashtableRecord.FinalState = Get-OrdinaryDestinationState -LiteralPath $strDestinationPath
        if ($hashtableRecord.FinalState -cne 'Existing') {
            throw 'final-state-drift'
        }
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strDestinationPath -ExpectedLeafType File)
        $arrFinalBytes = [System.IO.File]::ReadAllBytes($strDestinationPath)
        $hashtableRecord.FinalLength = $arrFinalBytes.Length
        $hashtableRecord.FinalSha256 = Get-Sha256Hex -Bytes $arrFinalBytes
        $hashtableRecord.FinalOrdinaryIdentity = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath
        if ($hashtableRecord.FinalLength -ne $CompletePayloadBytes.Length -or
            $hashtableRecord.FinalSha256 -cne $hashtableRecord.CandidateSha256 -or
            ($arrFinalBytes.Length -ge 3 -and $arrFinalBytes[0] -eq 0xEF -and
            $arrFinalBytes[1] -eq 0xBB -and $arrFinalBytes[2] -eq 0xBF) -or
            $arrFinalBytes -contains [byte]0x0D -or $arrFinalBytes.Length -eq 0 -or
            $arrFinalBytes[$arrFinalBytes.Length - 1] -ne 0x0A) {
            throw 'final-byte-drift'
        }
        $hashtableRecord.Status = 'Success'
        return $hashtableRecord
    } catch {
        $objOriginalError = $_
        if ($null -ne $objCandidateStream) {
            try {
                $objCandidateStream.Dispose()
            } catch {
                $hashtableRecord.CleanupResult = 'Failed'
            }
            $objCandidateStream = $null
        }

        if ($hashtableRecord.PublicationReturned) {
            $hashtableRecord.Status = 'ReplacementStateUncertain'
        } elseif ($null -ne $strTemporaryPath) {
            # Probe candidate existence in a guarded step. Test-FileSystemEntry
            # propagates access and metadata failures other than absence, so an
            # unguarded probe in the branch condition would escape this catch and
            # bypass the ArtifactRecord wrapper below, leaving a retained candidate
            # reported as never attempted. On probe failure the candidate state is
            # unknown, so record it as retained for recovery and uncertain.
            $boolCandidatePresent = $false
            $boolProbeFailed = $false
            try {
                $boolCandidatePresent = Test-FileSystemEntry -LiteralPath $strTemporaryPath
            } catch {
                $boolProbeFailed = $true
            }
            if ($boolProbeFailed) {
                $hashtableRecord.TemporaryDisposition = 'RetainedForRecovery'
                $hashtableRecord.CleanupResult = 'Failed'
                $hashtableRecord.Status = 'ReplacementStateUncertain'
            } elseif ($boolCandidatePresent) {
                if ($boolTemporaryIdentityProven) {
                    try {
                        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strTemporaryPath -ExpectedLeafType File)
                        if ((Get-OrdinaryFileIdentity -LiteralPath $strTemporaryPath) -cne $strCandidateIdentity) {
                            throw 'candidate-identity-drift'
                        }
                        [System.IO.File]::Delete($strTemporaryPath)
                        if (Test-FileSystemEntry -LiteralPath $strTemporaryPath) {
                            throw 'candidate-cleanup-failure'
                        }
                        $hashtableRecord.TemporaryDisposition = 'RemovedAfterFailure'
                        $hashtableRecord.CleanupResult = 'Success'
                    } catch {
                        $hashtableRecord.TemporaryDisposition = 'RetainedForRecovery'
                        $hashtableRecord.CleanupResult = 'Failed'
                    }
                } else {
                    $hashtableRecord.TemporaryDisposition = 'IdentityUnproven'
                    $hashtableRecord.CleanupResult = 'NotAttempted'
                }
            }
        }

        if (-not $hashtableRecord.PublicationReturned -and
            $hashtableRecord.OriginalState -in @('Existing', 'Absent') -and
            $hashtableRecord.TemporaryDisposition -cne 'NotCreated') {
            $boolOriginalStateProven = $false
            try {
                $strFailureDestinationState = Get-OrdinaryDestinationState -LiteralPath $strDestinationPath
                if ($hashtableRecord.OriginalState -eq 'Absent') {
                    $boolOriginalStateProven = $strFailureDestinationState -eq 'Absent'
                } elseif ($strFailureDestinationState -eq 'Existing') {
                    $boolOriginalStateProven = (
                        (Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath) -ceq
                            $hashtableRecord.OriginalOrdinaryIdentity -and
                        (New-Object System.IO.FileInfo($strDestinationPath)).Length -eq
                            $hashtableRecord.OriginalLength -and
                        (Get-FileSha256Hex -LiteralPath $strDestinationPath) -ceq
                            $hashtableRecord.OriginalSha256
                    )
                }
            } catch {
                $boolOriginalStateProven = $false
            }
            if (-not $boolOriginalStateProven) {
                $hashtableRecord.Status = 'ReplacementStateUncertain'
            }
        }
        if ($hashtableRecord.Status -eq 'Pending') {
            $hashtableRecord.Status = 'Failed'
        }
        $objException = New-Object System.InvalidOperationException(
            ($strPhase + ':' + $objOriginalError.Exception.Message),
            $objOriginalError.Exception
        )
        $objException.Data['ArtifactRecord'] = $hashtableRecord
        $objException.Data['Phase'] = $strPhase
        throw $objException
    }
}

function Write-GeneratorResult {
    # .SYNOPSIS
    # Writes the generator result as one compact JSON line.
    #
    # .DESCRIPTION
    # Serializes the complete ordered result with a depth of eight and writes it
    # directly to standard output as one newline-terminated compact JSON document.
    #
    # .PARAMETER Result
    # Complete generator result dictionary to serialize.
    #
    # .EXAMPLE
    # Write-GeneratorResult -Result $hashtableResult
    #
    # # Writes one compact JSON result line to standard output and returns no pipeline output.
    #
    # .EXAMPLE
    # Write-GeneratorResult -Result ([ordered]@{ Overall = 'NoChange' })
    #
    # # Writes {"Overall":"NoChange"} followed by the platform newline.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None on the PowerShell success stream. Writes one System.String line to
    # standard output. Parameter-binding, JSON serialization, and console-write
    # failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Result
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Result
    )

    [Console]::Out.WriteLine(($Result | ConvertTo-Json -Depth 8 -Compress))
}

$hashtableSourceMap = [ordered]@{
    guide = 'STYLE_GUIDE.md'
    rationale = 'STYLE_GUIDE_RATIONALE.md'
}
$hashtableDestinationMap = [ordered]@{
    copilot = 'copilot-instructions.md'
    'powershell-instructions' = 'powershell.instructions.md'
    chat = 'STYLE_GUIDE_CHAT.md'
    full = 'STYLE_GUIDE_FULL.md'
}
$listArtifactRecords = New-Object 'System.Collections.Generic.List[object]'
foreach ($strArtifactId in $hashtableDestinationMap.Keys) {
    $listArtifactRecords.Add((New-ArtifactRecord `
        -ArtifactId $strArtifactId `
        -RepositoryPath $hashtableDestinationMap[$strArtifactId]))
}
$strOverall = 'Failed'
$strResultPhase = 'initialize'
$strResultCategory = 'tool-failure'
$strNativeOutcome = 'NotApplicable'
$intExitCode = 1

try {
    Test-ScriptVersionParser
    $strSelfPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'Generate-StyleGuideArtifacts.ps1'))
    $arrSelfBytes = [System.IO.File]::ReadAllBytes($strSelfPath)
    $strSelfText = $script:objUtf8Strict.GetString($arrSelfBytes)
    [void](Get-ScriptVersionRecord -ScriptText $strSelfText -ExpectedVersion $script:strGeneratorVersion)

    $strResultPhase = 'validate-fixed-authority'
    $strWorkflowRoot = Assert-OrdinaryAbsolutePath -LiteralPath $PSScriptRoot -ExpectedLeafType Directory
    $strRepositoryRootCandidate = Join-Path -Path (
        Join-Path -Path $strWorkflowRoot -ChildPath '..'
    ) -ChildPath '..'
    $strRepositoryRoot = Assert-OrdinaryAbsolutePath -LiteralPath (
        [System.IO.Path]::GetFullPath($strRepositoryRootCandidate)
    ) -ExpectedLeafType Directory

    $hashtableIdentities = @{}
    $hashtableSourceBytes = @{}
    foreach ($strSourceId in $hashtableSourceMap.Keys) {
        $strRepositoryPath = $hashtableSourceMap[$strSourceId]
        $strSourcePath = [System.IO.Path]::GetFullPath((Join-Path $strRepositoryRoot $strRepositoryPath))
        if (-not (Test-PathContainedByRoot -Root $strRepositoryRoot -Candidate $strSourcePath)) {
            throw "source-containment"
        }
        $strSourcePath = Assert-OrdinaryAbsolutePath -LiteralPath $strSourcePath -ExpectedLeafType File
        $strIdentity = Get-OrdinaryFileIdentity -LiteralPath $strSourcePath
        if ($hashtableIdentities.ContainsKey($strIdentity)) {
            throw "duplicate-source-identity"
        }
        $hashtableIdentities[$strIdentity] = $strRepositoryPath
        $hashtableSourceBytes[$strSourceId] = [System.IO.File]::ReadAllBytes($strSourcePath)
    }
    foreach ($strArtifactId in $hashtableDestinationMap.Keys) {
        $strRepositoryPath = $hashtableDestinationMap[$strArtifactId]
        $strDestinationPath = [System.IO.Path]::GetFullPath((Join-Path $strRepositoryRoot $strRepositoryPath))
        if (-not (Test-PathContainedByRoot -Root $strRepositoryRoot -Candidate $strDestinationPath)) {
            throw "destination-containment"
        }
        $strDestinationParentPath = [System.IO.Path]::GetDirectoryName($strDestinationPath)
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strDestinationParentPath -ExpectedLeafType Directory)
        Assert-TrackedFile -RepositoryRoot $strRepositoryRoot -RepositoryPath $strRepositoryPath
        $strDestinationState = Get-OrdinaryDestinationState -LiteralPath $strDestinationPath
        if ($strDestinationState -eq 'Existing') {
            $strIdentity = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath
            if ($hashtableIdentities.ContainsKey($strIdentity)) {
                throw 'duplicate-path-identity'
            }
            $hashtableIdentities[$strIdentity] = $strRepositoryPath
        }
    }

    $strResultPhase = 'compute-complete-payloads'
    $hashtablePayloads = New-StyleGuidePayloadMap `
        -GuideBytes $hashtableSourceBytes.guide `
        -RationaleBytes $hashtableSourceBytes.rationale
    if ($hashtablePayloads.Count -ne 4) {
        throw "payload-cardinality"
    }

    $strResultPhase = 'replace-artifacts'
    $intArtifactIndex = 0
    foreach ($strArtifactId in $hashtableDestinationMap.Keys) {
        $strDestinationPath = [System.IO.Path]::GetFullPath(
            (Join-Path $strRepositoryRoot $hashtableDestinationMap[$strArtifactId])
        )
        try {
            $hashtableRecord = Write-StyleGuideArtifact `
                -ArtifactId $strArtifactId `
                -RawDestinationPath $strDestinationPath `
                -CompletePayloadBytes $hashtablePayloads[$strArtifactId] `
                -RepositoryRoot $strRepositoryRoot `
                -DestinationMap $hashtableDestinationMap
            $listArtifactRecords[$intArtifactIndex] = $hashtableRecord
        } catch {
            if ($_.Exception.Data.Contains('ArtifactRecord')) {
                $listArtifactRecords[$intArtifactIndex] = $_.Exception.Data['ArtifactRecord']
                $strResultPhase = [string]$_.Exception.Data['Phase']
                if ($_.Exception.Data['ArtifactRecord'].Status -eq 'ReplacementStateUncertain') {
                    $strOverall = 'ReplacementStateUncertain'
                    $strResultCategory = 'filesystem-state-uncertain'
                } else {
                    $strOverall = 'Failed'
                    $strResultCategory = 'artifact-write-failure'
                }
            }
            throw
        }
        $intArtifactIndex++
    }

    $boolAnyReplacement = @($listArtifactRecords | Where-Object { $_.Status -eq 'Success' }).Count -gt 0
    $strOverall = if ($boolAnyReplacement) { 'Success' } else { 'NoChange' }
    $strResultPhase = 'complete'
    $strResultCategory = 'none'
    $strNativeOutcome = 'Success'
    $intExitCode = 0
} catch {
    if ($strOverall -notin @('Failed', 'ReplacementStateUncertain')) {
        $strOverall = 'Failed'
    }
    if ($strResultCategory -eq 'tool-failure') {
        $strResultCategory = 'validation-failure'
    }
    $strNativeOutcome = $_.Exception.GetType().FullName
    $intExitCode = 1
}

$hashtableResult = [ordered]@{
    Schema = $script:strGeneratorResultSchema
    GeneratorVersion = $script:strGeneratorVersion
    Overall = $strOverall
    Phase = $strResultPhase
    Category = $strResultCategory
    NativeOutcome = $strNativeOutcome
    ExitCode = $intExitCode
    Artifacts = $listArtifactRecords.ToArray()
}
Write-GeneratorResult -Result $hashtableResult
exit $intExitCode
