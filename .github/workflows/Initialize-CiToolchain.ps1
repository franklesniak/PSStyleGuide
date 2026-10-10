#Requires -Version 7.3
# .SYNOPSIS
# Acquires reviewed Linux/Windows x64 runtimes and requested locked dependencies.
#
# .DESCRIPTION
# Requires a reviewed PowerShell host, native Linux or Windows x64, empty candidate permissions, and an anonymous credential-free checkout. Validates declarations and staging/communication paths, then acquires digest-verified runtime archives with a fixed 64 MiB compressed limit. Requires curl and libcurl 8.5 or later; Windows retains curl major version 8. Installs requested locked roots only with the preferred runtime. Publishes ready.json and runner records after all checks succeed. Throws on refusal or native failure. Retains uncertain failed staging. Node 22 is a separate optional Linux recovery executable, never an install/PATH runtime. Changes this process environment for Git/npm isolation and the completed handoff.
#
# .PARAMETER WorkflowDependencies
# Installs locked .github/workflows dependencies with the preferred runtime.
#
# .PARAMETER InstructionDependencies
# Installs locked repository dependencies with the preferred runtime.
#
# .PARAMETER IncludeRecoveryCompatibility
# Acquires the separate reviewed Node 22 runtime on Linux x64 without a PATH entry.
#
# .EXAMPLE
# & "$PSScriptRoot/Initialize-CiToolchain.ps1" -WorkflowDependencies -InstructionDependencies
#
# # Internal workflow example: verifies the preferred runtime and both locked roots. The runner must supply an ordinary RUNNER_TEMP outside the checkout and two distinct single-link command files directly in its _runner_file_commands directory.
#
# .EXAMPLE
# & "$PSScriptRoot/Initialize-CiToolchain.ps1" -IncludeRecoveryCompatibility
#
# # Internal Linux workflow example: publishes the preferred and separate recovery paths. Windows refuses this switch before acquisition. No dependencies are requested.
#
# .INPUTS
# None. Pipeline input is not supported.
#
# .OUTPUTS
# [string] Reviewed runtime setup completed. Emitted once after successful publication. Provenance and dependency-command stdout use the information stream. Native stderr remains separate. Failures throw; uncertain cleanup can warn. Also writes ready.json and runner communication files.
#
# .NOTES
# No positional parameters are supported. Use declared parameter names, if any.
# The workflow must initialize the required host, checkout, and runner environment.
# Version: 1.0.20261010.0
[CmdletBinding(PositionalBinding = $false)]
[OutputType([string])]
param(
    [Parameter()][switch] $WorkflowDependencies,
    [Parameter()][switch] $InstructionDependencies,
    [Parameter()][switch] $IncludeRecoveryCompatibility
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$objStrictUtf8Encoding = [Text.UTF8Encoding]::new($false, $true)
New-Variable -Name intMaximumRuntimeArchiveBytes -Value 67108864 -Option Constant -WhatIf:$false -Confirm:$false

function Assert-OrdinaryPath {
    # .SYNOPSIS
    # Returns an ordinary absolute local path.
    #
    # .DESCRIPTION
    # Checks single-line absolute local syntax and Windows aliases, then resolves the FileSystem provider path and requires equality with the normalized native path using the platform case model. Checks the required file or directory type and every ancestor for reparse points. Provider errors, mismatches, and invalid, missing, linked, or uninspectable paths throw without fallback.
    #
    # .PARAMETER Path
    # Absolute local path of an existing file or directory.
    #
    # .PARAMETER Directory
    # Requires a directory. Omit the named switch to require a file.
    #
    # .EXAMPLE
    # $strPath = Assert-OrdinaryPath -Path $env:RUNNER_TEMP -Directory
    #
    # # Returns the ordinary directory when the runner is initialized.
    #
    # .EXAMPLE
    # Assert-OrdinaryPath -Path 'relative/file'
    #
    # # Throws because the path is relative.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [string] Normalized absolute path after all checks. Failures throw without a path.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #
    # Directory is a named-only switch.
    #
    # Version: 1.0.20261008.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Position = 0)][string] $Path, [switch] $Directory)
    if ([string]::IsNullOrWhiteSpace($Path) -or $Path -match '[\r\n]' -or
        -not [IO.Path]::IsPathFullyQualified($Path) -or $Path.StartsWith('\\') -or
        ($IsWindows -and $Path.Replace('/', '\').StartsWith('\\'))) {
        throw 'toolchain: an absolute local single-line path is required'
    }
    $strFullPath = [IO.Path]::GetFullPath($Path)
    if ($IsWindows -and $strFullPath -cnotmatch '\A[A-Za-z]:\\') {
        throw 'toolchain: an absolute local single-line path is required'
    }
    if ($IsWindows -and ($strFullPath.Substring(2).Contains(':') -or
        @($strFullPath.Substring(3).Split('\') | Where-Object {
            $_ -match '[. ]$|~'
        }).Count)) {
        throw 'toolchain: path aliases are not supported'
    }
    [Management.Automation.ProviderInfo] $objPathProvider = $null
    [Management.Automation.PSDriveInfo] $objPathDrive = $null
    $strProviderPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $strFullPath, [ref]$objPathProvider, [ref]$objPathDrive)
    $objPathComparison = if ($IsWindows) {
        [StringComparison]::OrdinalIgnoreCase
    } else {
        [StringComparison]::Ordinal
    }
    if ($null -eq $objPathProvider -or $objPathProvider.Name -cne 'FileSystem' -or
        -not [string]::Equals($strProviderPath, $strFullPath, $objPathComparison)) {
        throw 'toolchain: the FileSystem provider path must match the normalized native path'
    }
    $objPathItem = Get-Item -LiteralPath $strFullPath -Force -ErrorAction Stop
    if ($objPathItem.PSIsContainer -ne [bool]$Directory) {
        throw "toolchain: wrong path type: $strFullPath"
    }
    for ($objPathComponent = $objPathItem; $null -ne $objPathComponent; $objPathComponent = if ($objPathComponent -is [IO.DirectoryInfo]) {
        $objPathComponent.Parent
    } else {
        $objPathComponent.Directory
    }) {
        if ($objPathComponent.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "toolchain: linked path: $strFullPath"
        }
    }
    return $strFullPath
}
function Get-OwnedPathIdentity {
    # .SYNOPSIS
    # Reads the native identity of an ordinary owned path.
    #
    # .DESCRIPTION
    # Checks the path before and after reading Windows volume/file IDs or Linux device/inode values. Loads the PowerShell native identity library on Linux. Native and path failures throw. Sampled identities do not isolate hostile code with the same user token.
    #
    # .PARAMETER Path
    # Absolute existing owned file or directory path.
    #
    # .PARAMETER Directory
    # Selects directory identity. Omit the named switch for file identity.
    #
    # .EXAMPLE
    # $strIdentity = Get-OwnedPathIdentity -Path $env:RUNNER_TEMP -Directory
    #
    # # Returns a native directory identity on the initialized supported host.
    #
    # .EXAMPLE
    # Get-OwnedPathIdentity -Path 'relative/file'
    #
    # # Throws before the native query.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [string] windows:volume:file-ID or unix:device:inode identity. Failures throw without an identity.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #
    # Directory is a named-only switch.
    #
    # Version: 1.0.20261008.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Position = 0)][string] $Path, [switch] $Directory)
    $null = Assert-OrdinaryPath $Path -Directory:$Directory
    if (-not ('StyleGuide.RuntimePathIdentity' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
namespace StyleGuide {
    public static class RuntimePathIdentity {
        [UnmanagedFunctionPointer(CallingConvention.Cdecl, SetLastError = true)]
        private delegate int UnixIdentity([MarshalAs(UnmanagedType.LPUTF8Str)] string path,
            out ulong device, out ulong inode);
        [StructLayout(LayoutKind.Sequential)]
        private struct FileId { public ulong Volume, Low, High; }
        [StructLayout(LayoutKind.Sequential)]
        private struct FileAttributes { public uint Attributes, Tag; }
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, ExactSpelling = true, SetLastError = true)]
        [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
        private static extern SafeFileHandle CreateFileW(string path, uint access, uint share,
            IntPtr security, uint disposition, uint flags, IntPtr template);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, SetLastError = true)]
        [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetId(SafeFileHandle handle, int informationClass, out FileId info, uint size);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, SetLastError = true)]
        [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetAttributes(SafeFileHandle handle, int informationClass,
            out FileAttributes info, uint size);
        public static string ReadUnix(string library, string path) {
            IntPtr module = NativeLibrary.Load(library);
            try {
                var query = Marshal.GetDelegateForFunctionPointer<UnixIdentity>(
                    NativeLibrary.GetExport(module, "GetInodeData"));
                ulong device, inode;
                if (query(path, out device, out inode) != 0)
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                return String.Format(CultureInfo.InvariantCulture, "unix:{0}:{1}", device, inode);
            } finally { NativeLibrary.Free(module); }
        }
        public static string ReadWindows(string path, bool directory) {
            // OPEN_EXISTING; backup semantics permits directories; open the reparse point itself.
            using (var handle = CreateFileW(path, 0, 7, IntPtr.Zero, 3, 0x02200000, IntPtr.Zero)) {
                if (handle.IsInvalid) throw new Win32Exception(Marshal.GetLastWin32Error());
                FileAttributes attributes;
                if (!GetAttributes(handle, 9, out attributes, 8))
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                if ((attributes.Attributes & 0x400) != 0 || ((attributes.Attributes & 0x10) != 0) != directory)
                    throw new IOException("Runtime ownership path type changed.");
                FileId id;
                if (!GetId(handle, 18, out id, 24))
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                return String.Format(CultureInfo.InvariantCulture, "windows:{0:x16}:{1:x16}{2:x16}",
                    id.Volume, id.High, id.Low);
            }
        }
    }
}
'@
    }
    $strPathIdentity = if ($IsWindows) {
        [StyleGuide.RuntimePathIdentity]::ReadWindows($Path, [bool]$Directory)
    } else {
        $strNativeLibraryPath = Assert-OrdinaryPath (Join-Path $PSHOME 'libpsl-native.so')
        [StyleGuide.RuntimePathIdentity]::ReadUnix($strNativeLibraryPath, $Path)
    }
    $null = Assert-OrdinaryPath $Path -Directory:$Directory
    return $strPathIdentity
}
function Get-RuntimeNativeApi {
    # .SYNOPSIS
    # Returns the internal native channel and effective-UID adapter type.
    #
    # .DESCRIPTION
    # Defines the adapter once in this process. Windows queries ordinary single-link files by handle. Linux resolves statx and the live effective-UID export through the exact admitted runtime library supplied by each caller. Native failures throw without fallback. This does not isolate hostile code running with the same user token.
    #
    # .EXAMPLE
    # $null = Get-RuntimeNativeApi
    #
    # # Loads the internal type before its methods are used.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [type] The StyleGuide.RuntimeNativeApi type. Compilation errors throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters and return shape may change without notice.
    # No parameters are supported.
    # Version: 1.0.20261010.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([type])]
    param()
    if (-not ('StyleGuide.RuntimeNativeApi' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
namespace StyleGuide {
    public static class RuntimeNativeApi {
        [UnmanagedFunctionPointer(CallingConvention.Cdecl, SetLastError = true)]
        private delegate int Statx(int descriptor, [MarshalAs(UnmanagedType.LPUTF8Str)] string path,
            int flags, uint mask, IntPtr buffer);
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        private delegate uint EffectiveUid();
        [StructLayout(LayoutKind.Sequential)]
        private struct FileId { public ulong Volume, Low, High; }
        [StructLayout(LayoutKind.Sequential)]
        private struct FileAttributes { public uint Attributes, Tag; }
        [StructLayout(LayoutKind.Sequential)]
        private struct FileStandard {
            public long AllocationSize, EndOfFile;
            public uint NumberOfLinks;
            public byte DeletePending, Directory;
        }
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, ExactSpelling = true, SetLastError = true)]
        [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
        private static extern SafeFileHandle CreateFileW(string path, uint access, uint share,
            IntPtr security, uint disposition, uint flags, IntPtr template);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, SetLastError = true)]
        [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetId(SafeFileHandle handle, int informationClass, out FileId info, uint size);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, SetLastError = true)]
        [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetAttributes(SafeFileHandle handle, int informationClass,
            out FileAttributes info, uint size);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, SetLastError = true)]
        [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetStandard(SafeFileHandle handle, int informationClass,
            out FileStandard info, uint size);
        public static uint ReadEffectiveUid(string library) {
            IntPtr module = NativeLibrary.Load(library);
            try {
                var query = Marshal.GetDelegateForFunctionPointer<EffectiveUid>(
                    NativeLibrary.GetExport(module, "SystemNative_GetEUid"));
                return query();
            } finally { NativeLibrary.Free(module); }
        }
        private static string ReadUnix(string library, int descriptor, string path, int flags) {
            IntPtr module = NativeLibrary.Load(library);
            IntPtr buffer = IntPtr.Zero;
            try {
                var query = Marshal.GetDelegateForFunctionPointer<Statx>(
                    NativeLibrary.GetExport(module, "statx"));
                // The Linux UAPI statx buffer is 256 bytes, including reserved fields.
                buffer = Marshal.AllocHGlobal(256);
                Marshal.Copy(new byte[256], 0, buffer, 256);
                if (query(descriptor, path, flags, 0x105, buffer) != 0)
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                uint mask = unchecked((uint)Marshal.ReadInt32(buffer, 0));
                uint links = unchecked((uint)Marshal.ReadInt32(buffer, 16));
                ushort mode = unchecked((ushort)Marshal.ReadInt16(buffer, 28));
                if ((mask & 0x105) != 0x105 || (mode & 0xf000) != 0x8000)
                    throw new IOException("Runner channel metadata is incomplete or not an ordinary file.");
                if (links != 1)
                    throw new IOException("Runner channel must have exactly one hard link.");
                ulong inode = unchecked((ulong)Marshal.ReadInt64(buffer, 32));
                uint major = unchecked((uint)Marshal.ReadInt32(buffer, 136));
                uint minor = unchecked((uint)Marshal.ReadInt32(buffer, 140));
                return String.Format(CultureInfo.InvariantCulture, "unix:{0}:{1}:{2}", major, minor, inode);
            } finally {
                if (buffer != IntPtr.Zero) Marshal.FreeHGlobal(buffer);
                NativeLibrary.Free(module);
            }
        }
        public static string ReadUnixPath(string library, string path) {
            // AT_FDCWD and AT_SYMLINK_NOFOLLOW; no data access or file creation.
            return ReadUnix(library, -100, path, 0x100);
        }
        public static string ReadUnixHandle(string library, SafeFileHandle handle) {
            bool retained = false;
            try {
                handle.DangerousAddRef(ref retained);
                if (handle.IsInvalid || handle.IsClosed) throw new IOException("Runner channel handle is unavailable.");
                // AT_EMPTY_PATH queries this held descriptor rather than resolving its pathname.
                return ReadUnix(library, handle.DangerousGetHandle().ToInt32(), "", 0x1000);
            } finally { if (retained) handle.DangerousRelease(); }
        }
        public static string ReadWindowsPath(string path) {
            // Zero data access, OPEN_EXISTING and OPEN_REPARSE_POINT; do not open for writing.
            using (var handle = CreateFileW(path, 0, 7, IntPtr.Zero, 3, 0x00200000, IntPtr.Zero)) {
                if (handle.IsInvalid) throw new Win32Exception(Marshal.GetLastWin32Error());
                return ReadWindowsHandle(handle);
            }
        }
        public static string ReadWindowsHandle(SafeFileHandle handle) {
            FileAttributes attributes;
            if (!GetAttributes(handle, 9, out attributes, 8))
                throw new Win32Exception(Marshal.GetLastWin32Error());
            FileStandard standard;
            if (!GetStandard(handle, 1, out standard, 24))
                throw new Win32Exception(Marshal.GetLastWin32Error());
            if ((attributes.Attributes & 0x410) != 0 || standard.Directory != 0 || standard.DeletePending != 0)
                throw new IOException("Runner channel metadata is incomplete or not an ordinary file.");
            if (standard.NumberOfLinks != 1)
                throw new IOException("Runner channel must have exactly one hard link.");
            FileId id;
            if (!GetId(handle, 18, out id, 24))
                throw new Win32Exception(Marshal.GetLastWin32Error());
            return String.Format(CultureInfo.InvariantCulture, "windows:{0:x16}:{1:x16}{2:x16}",
                id.Volume, id.High, id.Low);
        }
    }
}
'@
    }
    return ('StyleGuide.RuntimeNativeApi' -as [type])
}


function Get-RunnerChannelIdentity {
    # .SYNOPSIS
    # Reads an ordinary single-link runner channel identity.
    #
    # .DESCRIPTION
    # Checks the concrete path before and after a native metadata query. Without Stream, reads metadata without write access. With Stream, queries its held handle. Native errors, non-regular files, and link counts other than one throw. The caller must compare the result with its admitted identity and validate directory membership.
    #
    # .PARAMETER Path
    # Absolute existing channel path to validate.
    #
    # .PARAMETER Stream
    # Optional open channel stream. Omit this parameter for a pathname sample.
    #
    # .EXAMPLE
    # $strIdentity = Get-RunnerChannelIdentity -Path $env:GITHUB_PATH
    #
    # # Returns the file identity only when the channel has one link.
    #
    # .EXAMPLE
    # $strIdentity = Get-RunnerChannelIdentity -Path $env:GITHUB_PATH -Stream $objPathChannel
    #
    # # Queries the held file instead of reopening its path for data access.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [string] Native volume/file-ID or device-major/device-minor/inode identity. Refusals throw without an identity.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters and return shape may change without notice.
    # No positional parameters are supported.
    # Version: 1.0.20261010.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $Path,
        [Parameter()][IO.FileStream] $Stream
    )
    $strChannelPath = Assert-OrdinaryPath -Path $Path
    $null = Get-RuntimeNativeApi
    $strIdentity = if ($IsWindows) {
        if ($null -eq $Stream) {
            [StyleGuide.RuntimeNativeApi]::ReadWindowsPath($strChannelPath)
        } else {
            [StyleGuide.RuntimeNativeApi]::ReadWindowsHandle($Stream.SafeFileHandle)
        }
    } elseif ($IsLinux) {
        $strNativeLibraryPath = Assert-OrdinaryPath (Join-Path $PSHOME 'libSystem.Native.so')
        if ($null -eq $Stream) {
            [StyleGuide.RuntimeNativeApi]::ReadUnixPath($strNativeLibraryPath, $strChannelPath)
        } else {
            [StyleGuide.RuntimeNativeApi]::ReadUnixHandle($strNativeLibraryPath, $Stream.SafeFileHandle)
        }
    } else {
        throw 'Runner channel identity requires Linux or Windows.'
    }
    $null = Assert-OrdinaryPath -Path $strChannelPath
    return $strIdentity
}


function Get-LinuxEffectiveUserId {
    # .SYNOPSIS
    # Returns this Linux process's current effective user ID.
    #
    # .DESCRIPTION
    # Loads the dedicated live UID export from the ordinary native library in the admitted PowerShell runtime. Reads the effective UID on every call. Missing libraries or exports and native invocation failures throw without a name, cached-value, or executable fallback.
    #
    # .EXAMPLE
    # $uintEffectiveUserId = Get-LinuxEffectiveUserId
    #
    # # Returns the live numeric effective UID on the admitted Linux host.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [uint32] Current Linux effective UID. Zero identifies a privileged process. Failures throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters and return shape may change without notice.
    # No parameters are supported.
    # Version: 1.0.20261010.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([uint32])]
    param()
    if (-not $IsLinux) { throw 'Effective UID admission requires Linux.' }
    $strNativeLibraryPath = Assert-OrdinaryPath (Join-Path $PSHOME 'libSystem.Native.so')
    $null = Get-RuntimeNativeApi
    return [StyleGuide.RuntimeNativeApi]::ReadEffectiveUid($strNativeLibraryPath)
}


function Assert-JsonMember {
    # .SYNOPSIS
    # Rejects duplicate decoded JSON member names.
    #
    # .DESCRIPTION
    # Recursively checks object and array value kinds with ordinal name comparison. Scalar value kinds require no member check. Throws on duplicate names. The caller must supply a live JsonElement from an undisposed JsonDocument.
    #
    # .PARAMETER Element
    # JsonElement whose object, array, or scalar value kind is inspected.
    #
    # .EXAMPLE
    # $objDocument = [Text.Json.JsonDocument]::Parse('{"field":1}')
    # try {
    #     Assert-JsonMember -Element $objDocument.RootElement
    # } finally {
    #     $objDocument.Dispose()
    # }
    #
    # # Completes for unique member names.
    #
    # .EXAMPLE
    # $objDocument = [Text.Json.JsonDocument]::Parse('{"field":1,"field":2}')
    # try {
    #     Assert-JsonMember -Element $objDocument.RootElement
    # } finally {
    #     $objDocument.Dispose()
    # }
    #
    # # Throws because field occurs twice.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Duplicate names cause a terminating error.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Element
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([void])]
    param([Text.Json.JsonElement] $Element)
    if ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Object) {
        $objJsonMemberNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($objJsonProperty in $Element.EnumerateObject()) {
            if (-not $objJsonMemberNames.Add($objJsonProperty.Name)) {
                throw 'toolchain: duplicate JSON member'
            }
            Assert-JsonMember $objJsonProperty.Value
        }
    } elseif ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Array) {
        foreach ($objJsonValue in $Element.EnumerateArray()) {
            Assert-JsonMember $objJsonValue
        }
    }
}
function Read-BoundedJson {
    # .SYNOPSIS
    # Reads a bounded JSON object with unique member names.
    #
    # .DESCRIPTION
    # Checks an ordinary file and its byte limit. Decodes strict UTF-8, requires an object root, and checks duplicate names before hashtable conversion. Disposes the JsonDocument even on refusal. Path, size, decoding, parsing, member, and conversion errors throw.
    #
    # .PARAMETER Path
    # Absolute path of the existing JSON file.
    #
    # .PARAMETER Limit
    # Maximum file length in bytes. Defaults to 1048576.
    #
    # .EXAMPLE
    # $hashtableDeclaration = Read-BoundedJson -Path $strDeclarationPath -Limit 16384
    #
    # # Reads an existing ordinary declaration within the byte limit. The caller supplies its absolute path.
    #
    # .EXAMPLE
    # Read-BoundedJson -Path $strDeclarationPath -Limit 0
    #
    # # Throws if the existing declaration contains any bytes.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [hashtable] Converted JSON object with original data keys and values. Failures throw without a converted object.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #   Position 1: Limit
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([string] $Path, [long] $Limit = 1048576)
    $null = Assert-OrdinaryPath $Path
    if ((Get-Item -LiteralPath $Path).Length -gt $Limit) {
        throw 'toolchain: JSON input exceeds its limit'
    }
    $strJsonText = [IO.File]::ReadAllText($Path, [Text.UTF8Encoding]::new($false, $true))
    $objJsonDocument = [Text.Json.JsonDocument]::Parse($strJsonText)
    try {
        if ($objJsonDocument.RootElement.ValueKind -ne [Text.Json.JsonValueKind]::Object) {
            throw 'toolchain: JSON input must be an object'
        }
        Assert-JsonMember $objJsonDocument.RootElement
    } finally {
        $objJsonDocument.Dispose()
    }
    return ConvertFrom-Json -InputObject $strJsonText -AsHashtable -Depth 64 -ErrorAction Stop
}
function Assert-Shape {
    # .SYNOPSIS
    # Requires exactly the declared dictionary keys.
    #
    # .DESCRIPTION
    # Accepts polymorphic inputs so invalid scalar, array, and null values reach the explicit dictionary check. Compares actual base dictionary count and keys with the case-sensitive complete key set. Throws on an invalid type or key set. The caller validates values.
    #
    # .PARAMETER Object
    # Input to inspect; valid dictionary values may have different types.
    #
    # .PARAMETER Keys
    # Complete array of allowed case-sensitive key names.
    #
    # .EXAMPLE
    # Assert-Shape -Object @{ field = 1 } -Keys @('field')
    #
    # # Completes for the exact key set.
    #
    # .EXAMPLE
    # Assert-Shape -Object @{ field = 1; extra = 2 } -Keys @('field')
    #
    # # Throws because an extra key exists.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Invalid object type or shape causes a terminating error.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Object
    #   Position 1: Keys
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([void])]
    param([object] $Object, [string[]] $Keys)
    if ($Object -isnot [Collections.IDictionary] -or $Object.psbase.Count -ne $Keys.Count -or
        @($Object.psbase.Keys | Where-Object {
            $_ -cnotin $Keys
        }).Count) {
        throw 'The reviewed runtime declaration is invalid: unexpected object fields.'
    }
}
function Assert-WindowsWriter {
    # .SYNOPSIS
    # Rejects unreviewed Windows owners and write authority.
    #
    # .DESCRIPTION
    # Requires Windows. Trusts the current user, SYSTEM, Administrators, and TrustedInstaller. Checks the owner and effective allow rules, including inherited rules. Protects file append rights and permits ancestor directory-creation grants. ACL inspection and untrusted mutation grants throw.
    #
    # .PARAMETER Path
    # Absolute path of the existing Windows file or directory.
    #
    # .EXAMPLE
    # Assert-WindowsWriter -Path $strReviewedPath
    #
    # # Completes for a Windows path whose owner and grants satisfy the policy.
    #
    # .EXAMPLE
    # Assert-WindowsWriter -Path $strUntrustedPath
    #
    # # Throws for a Windows path with an untrusted owner or write grant.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Unreviewed owner or write authority causes a terminating error.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([void])]
    param([string] $Path)
    $objAccessControl = Get-Acl -LiteralPath $Path
    $arrTrustedSecurityIdentifiers = @([Security.Principal.WindowsIdentity]::GetCurrent().User.Value,
        'S-1-5-18', 'S-1-5-32-544', 'S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464')
    if ($objAccessControl.GetOwner([Security.Principal.SecurityIdentifier]).Value -cnotin $arrTrustedSecurityIdentifiers) {
        throw "toolchain: unreviewed Windows path owner: $Path"
    }
    $objMutationRights = [Security.AccessControl.FileSystemRights]'WriteData,DeleteSubdirectoriesAndFiles,Delete,ChangePermissions,TakeOwnership'
    # Bit 4 appends to files but only creates subdirectories on directories.
    # Keep legitimate ancestor CreateDirectories grants; protect file contents.
    if (-not (Get-Item -LiteralPath $Path -Force -ErrorAction Stop).PSIsContainer) {
        $objMutationRights = $objMutationRights -bor [Security.AccessControl.FileSystemRights]::AppendData
    }
    foreach ($objAccessRule in $objAccessControl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
        if ($objAccessRule.AccessControlType -eq 'Allow' -and
            -not ($objAccessRule.PropagationFlags -band [Security.AccessControl.PropagationFlags]::InheritOnly) -and
            ($objAccessRule.FileSystemRights -band $objMutationRights) -and $objAccessRule.IdentityReference.Value -cnotin $arrTrustedSecurityIdentifiers) {
            throw "toolchain: unreviewed Windows write authority: $Path"
        }
    }
}
function New-PrivateDirectory {
    # .SYNOPSIS
    # Creates a new restricted runtime directory.
    #
    # .DESCRIPTION
    # Requires an absent absolute destination outside the checkout. Creates a protected Windows DACL for the current user, SYSTEM, and Administrators, or a Linux directory with mode 0700. Verifies permissions and the ordinary path. Throws on existing destinations, creation failure, or failed checks. Requires ShouldProcess approval before any creation or permission change. Declining or inherited WhatIf throws before mutation, so mandatory callers cannot proceed with absent staging.
    #
    # .PARAMETER Path
    # Absolute FileSystem path of the absent private destination.
    #
    # .EXAMPLE
    # New-PrivateDirectory -Path $strNewStagingPath -Confirm:$false -WhatIf:$WhatIfPreference
    #
    # # Creates restricted staging when the internal caller supplies an absent absolute path.
    #
    # .EXAMPLE
    # New-PrivateDirectory -Path $strNewStagingPath -WhatIf -Confirm:$false
    #
    # # Reports the proposed creation and throws before creating the absent path.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Creates a directory after ShouldProcess approval or throws. A declined operation cannot publish or continue. A failed post-creation check can leave a directory for caller-owned cleanup.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #
    # Mandatory production callers disable confirmation prompts and propagate the inherited WhatIf preference explicitly.
    #
    # Version: 1.0.20261008.0
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([void])]
    param([string] $Path)
    if ($null -ne (Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue)) {
        throw 'The runtime staging destination already exists.'
    }
    if (-not $PSCmdlet.ShouldProcess($Path, 'Create restricted staging directory')) {
        throw 'Restricted staging directory creation was declined.'
    }
    if ($IsWindows) {
        $objAccessControl = [Security.AccessControl.DirectorySecurity]::new()
        $objOwnerSecurityIdentifier = [Security.Principal.WindowsIdentity]::GetCurrent().User
        $objAccessControl.SetOwner($objOwnerSecurityIdentifier)
        $objAccessControl.SetAccessRuleProtection($true, $false)
        foreach ($strSecurityIdentifier in @($objOwnerSecurityIdentifier.Value, 'S-1-5-18', 'S-1-5-32-544')) {
            $objAccessControl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
                [Security.Principal.SecurityIdentifier]::new($strSecurityIdentifier), 'FullControl',
                'ContainerInherit,ObjectInherit', 'None', 'Allow'))
        }
        [IO.FileSystemAclExtensions]::Create([IO.DirectoryInfo]::new($Path), $objAccessControl)
        Assert-WindowsWriter $Path
        if (-not (Get-Acl -LiteralPath $Path).AreAccessRulesProtected) {
            throw 'toolchain: private DACL was not applied'
        }
    } else {
        [void]([IO.Directory]::CreateDirectory($Path, [IO.UnixFileMode]::UserRead -bor
            [IO.UnixFileMode]::UserWrite -bor [IO.UnixFileMode]::UserExecute))
        if ([int][IO.File]::GetUnixFileMode($Path) -ne 448) {
            throw 'toolchain: private POSIX directory mode was not applied'
        }
    }
    $null = Assert-OrdinaryPath $Path -Directory
}
function Assert-ArchiveName {
    # .SYNOPSIS
    # Rejects unsafe runtime archive member names.
    #
    # .DESCRIPTION
    # Requires the exact release root. Rejects control characters, whitespace, dangerous punctuation, absolute paths, and empty or traversal components. WindowsNames adds alias and reserved-device checks. Unsafe names throw.
    #
    # .PARAMETER Name
    # Archive member name, including any trailing directory separator.
    #
    # .PARAMETER ReleaseRoot
    # Exact top-level reviewed runtime directory name.
    #
    # .PARAMETER WindowsNames
    # Enables Windows alias and reserved-device checks. Use this switch by name.
    #
    # .EXAMPLE
    # Assert-ArchiveName -Name 'node-release/bin/node' -ReleaseRoot 'node-release'
    #
    # # Completes for an in-root member.
    #
    # .EXAMPLE
    # Assert-ArchiveName -Name 'node-release/../outside' -ReleaseRoot 'node-release'
    #
    # # Throws for the traversal component.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. An unsafe name causes a terminating error.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Name
    #   Position 1: ReleaseRoot
    #
    # WindowsNames is a named-only switch.
    #
    # Version: 1.0.20261008.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Position = 0)][string] $Name, [Parameter(Position = 1)][string] $ReleaseRoot, [switch] $WindowsNames)
    if ($Name.Length -gt 4096 -or $Name -match '[\x00-\x20\x7f\\:"<>|?*]' -or
        $Name.StartsWith('/') -or ($Name -cne $ReleaseRoot -and -not $Name.StartsWith("$ReleaseRoot/", [StringComparison]::Ordinal))) {
        throw 'toolchain: unsafe archive member name'
    }
    foreach ($strNameComponent in $Name.TrimEnd('/').Split('/')) {
        if ($strNameComponent -in @('', '.', '..') -or ($WindowsNames -and ($strNameComponent -match '[. ]$|~' -or
            $strNameComponent -match '^(?i:CON|PRN|AUX|NUL|COM[1-9¹²³]|LPT[1-9¹²³])(?:\.|$)'))) {
            throw 'toolchain: unsafe archive member component'
        }
    }
}
function Assert-MemberTree {
    # .SYNOPSIS
    # Rejects member collisions and escaping archive links.
    #
    # .DESCRIPTION
    # Checks the complete validated member dictionary before extraction. Requires member parents to be directories. Requires link targets to resolve directly to regular files in the release root. Throws on file/directory collisions, unsupported or escaping targets, and missing targets. The caller must first validate every name.
    #
    # .PARAMETER Members
    # System.Collections.Generic.Dictionary[string,object] of validated names and Kind, Size, and optional Target records.
    #
    # .PARAMETER ReleaseRoot
    # Exact top-level reviewed runtime directory name.
    #
    # .EXAMPLE
    # $objMembers = [Collections.Generic.Dictionary[string,object]]::new([StringComparer]::Ordinal)
    # $objMembers.Add('node-release/bin/node', @{ Kind = 'file'; Size = 1 })
    # Assert-MemberTree -Members $objMembers -ReleaseRoot 'node-release'
    #
    # # Completes for a validated regular-file record without a conflicting parent.
    #
    # .EXAMPLE
    # $objMembers = [Collections.Generic.Dictionary[string,object]]::new([StringComparer]::Ordinal)
    # $objMembers.Add('node-release/bin', @{ Kind = 'file' })
    # $objMembers.Add('node-release/bin/node', @{ Kind = 'file' })
    # Assert-MemberTree -Members $objMembers -ReleaseRoot 'node-release'
    #
    # # Throws because a file is used as a member parent.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Invalid archive topology causes a terminating error.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Members
    #   Position 1: ReleaseRoot
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([void])]
    param([Collections.Generic.Dictionary[string, object]] $Members, [string] $ReleaseRoot)
    foreach ($strMemberName in $Members.Keys) {
        $strParentMemberName = $strMemberName
        while ($strParentMemberName.Contains('/')) {
            $strParentMemberName = $strParentMemberName.Substring(0, $strParentMemberName.LastIndexOf('/'))
            if ($Members.ContainsKey($strParentMemberName) -and $Members[$strParentMemberName].Kind -cne 'directory') {
                throw 'toolchain: archive file/directory collision'
            }
        }
        if ($Members[$strMemberName].Kind -ceq 'link') {
            $strTargetPath = $Members[$strMemberName].Target
            if ($strTargetPath -match '[\x00-\x20\x7f\\:]' -or $strTargetPath.StartsWith('/')) {
                throw 'toolchain: unsafe archive link'
            }
            $strResolvedTargetPath = [IO.Path]::GetFullPath([IO.Path]::Combine('/archive', $strMemberName, '..', $strTargetPath)).Replace('\', '/')
            if (-not $strResolvedTargetPath.StartsWith("/archive/$ReleaseRoot/", [StringComparison]::Ordinal)) {
                throw 'toolchain: escaping archive link'
            }
            $strTargetMemberName = $strResolvedTargetPath.Substring('/archive/'.Length)
            if (-not $Members.ContainsKey($strTargetMemberName) -or $Members[$strTargetMemberName].Kind -cne 'file') {
                throw 'toolchain: archive link must resolve directly to an in-root regular file'
            }
        }
    }
}
function New-ArchiveProcess {
    # .SYNOPSIS
    # Configures an unstarted fixed GNU tar process.
    #
    # .DESCRIPTION
    # Requires the reviewed Linux tar/xz programs. Configures redirected output, no shell, and a minimal child environment. Adds caller arguments and the fixed /usr/bin/xz selector. Does not start the process or change the parent environment. The caller must start, wait for, inspect, and dispose the returned Process.
    #
    # .PARAMETER Arguments
    # Ordered GNU tar arguments; the fixed compression selector follows them.
    #
    # .EXAMPLE
    # $objProcess = New-ArchiveProcess -Arguments @('-tvf', $strArchivePath)
    # $objProcess.Dispose()
    #
    # # Configures and disposes an unstarted listing process. The caller supplies an archive path.
    #
    # .EXAMPLE
    # $objProcess = New-ArchiveProcess -Arguments @('-xf', $strArchivePath, '-C', $strDestinationPath)
    # $objProcess.Dispose()
    #
    # # Configures and disposes an unstarted extraction process. No files are extracted.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [System.Diagnostics.Process] One configured unstarted Process. Configuration errors throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Arguments
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([Diagnostics.Process])]
    param([string[]] $Arguments)
    $objArchiveProcess = [Diagnostics.Process]::new()
    $objArchiveProcess.StartInfo.FileName = '/usr/bin/tar'
    $objArchiveProcess.StartInfo.UseShellExecute = $false
    $objArchiveProcess.StartInfo.RedirectStandardOutput = $true
    $objArchiveProcess.StartInfo.RedirectStandardError = $true
    # Fixed tools and a small child environment exclude inherited tar/xz options
    # and native-loader selectors without changing the host or parent process.
    $objArchiveProcess.StartInfo.Environment.Clear()
    $objArchiveProcess.StartInfo.Environment['PATH'] = '/usr/bin:/bin'
    $objArchiveProcess.StartInfo.Environment['LC_ALL'] = 'C'
    $objArchiveProcess.StartInfo.Environment['TZ'] = 'UTC'
    foreach ($strArchiveArgument in $Arguments) {
        $objArchiveProcess.StartInfo.ArgumentList.Add($strArchiveArgument)
    }
    $objArchiveProcess.StartInfo.ArgumentList.Add('--use-compress-program=/usr/bin/xz')
    return $objArchiveProcess
}
function Expand-ReviewedArchive {
    # .SYNOPSIS
    # Validates and extracts a reviewed runtime archive.
    #
    # .DESCRIPTION
    # Requires a digest-verified archive, an empty caller-owned destination, and the exact release root. Inspects Windows ZIP or fixed Linux GNU tar members before extraction. Enforces names, topology, permissions, member and byte limits, then checks extracted identities and sizes. Unsafe content, native failures, incomplete extraction, and I/O failures throw. The caller owns cleanup of partial output.
    #
    # .PARAMETER Archive
    # Absolute archive path whose digest the caller has verified.
    #
    # .PARAMETER Destination
    # Absolute path of the empty owned extraction directory.
    #
    # .PARAMETER ReleaseRoot
    # Exact top-level directory required in the reviewed archive.
    #
    # .EXAMPLE
    # Expand-ReviewedArchive -Archive $strVerifiedArchivePath -Destination $strEmptyDestinationPath -ReleaseRoot $strReleaseRoot
    #
    # # Extracts after the internal caller has checked the digest and created the owned destination.
    #
    # .EXAMPLE
    # Expand-ReviewedArchive -Archive $strVerifiedArchivePath -Destination $strEmptyDestinationPath -ReleaseRoot 'different-release'
    #
    # # Throws when members do not match the requested root.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Writes validated members or throws; partial files can remain for caller-owned cleanup.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Archive
    #   Position 1: Destination
    #   Position 2: ReleaseRoot
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([void])]
    param([string] $Archive, [string] $Destination, [string] $ReleaseRoot)
    $objArchiveMembers = [Collections.Generic.Dictionary[string, object]]::new(
        $(if ($IsWindows) {
            [StringComparer]::OrdinalIgnoreCase
        } else {
            [StringComparer]::Ordinal
        }))
    [long]$intExpandedBytes = 0
    if ($IsWindows) {
        $objZipArchive = [IO.Compression.ZipFile]::OpenRead($Archive)
        try {
            foreach ($objZipEntry in $objZipArchive.Entries) {
                $strMemberName = $objZipEntry.FullName.TrimEnd('/')
                Assert-ArchiveName $strMemberName $ReleaseRoot -WindowsNames
                $strMemberKind = if ($objZipEntry.FullName.EndsWith('/')) {
                    'directory'
                } else {
                    'file'
                }
                if ($strMemberKind -ceq 'directory' -and $objZipEntry.Length -ne 0) {
                    throw 'toolchain: ZIP directory has file data'
                }
                $intUnixFileType = ($objZipEntry.ExternalAttributes -shr 16) -band 61440
                if (($objZipEntry.ExternalAttributes -band 1024) -or $intUnixFileType -notin @(0, 16384, 32768) -or
                    ($intUnixFileType -eq 16384 -and $strMemberKind -cne 'directory') -or
                    ($intUnixFileType -eq 32768 -and $strMemberKind -cne 'file')) {
                    throw 'toolchain: unsupported ZIP member attributes'
                }
                if (-not $objArchiveMembers.TryAdd($strMemberName, @{
                    Kind = $strMemberKind;
                    Size = $objZipEntry.Length
                })) {
                    throw 'toolchain: duplicate or case-colliding archive member'
                }
                $intExpandedBytes += $objZipEntry.Length
                if ($objArchiveMembers.Count -gt 50000 -or $intExpandedBytes -gt 1073741824) {
                    throw 'toolchain: archive extraction limit exceeded'
                }
            }
            Assert-MemberTree $objArchiveMembers $ReleaseRoot
            foreach ($objZipEntry in $objZipArchive.Entries) {
                $strTargetPath = [IO.Path]::GetFullPath((Join-Path $Destination $objZipEntry.FullName))
                if (-not $strTargetPath.StartsWith($Destination + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
                    throw 'toolchain: ZIP destination escaped its root'
                }
                if ($objZipEntry.FullName.EndsWith('/')) {
                    [void]([IO.Directory]::CreateDirectory($strTargetPath));
                    continue
                }
                [void]([IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($strTargetPath)))
                $null = Assert-OrdinaryPath ([IO.Path]::GetDirectoryName($strTargetPath)) -Directory
                $objInputStream = $objZipEntry.Open()
                $objOutputStream = $null
                try {
                    $objOutputStream = [IO.File]::Open($strTargetPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
                    $arrCopyBuffer = [byte[]]::new(65536)
                    [long]$intWrittenBytes = 0
                    while (($intReadByteCount = $objInputStream.Read($arrCopyBuffer, 0, $arrCopyBuffer.Length)) -gt 0) {
                        $intWrittenBytes += $intReadByteCount
                        if ($intWrittenBytes -gt $objZipEntry.Length) {
                            throw 'toolchain: ZIP data exceeds declared expansion limit'
                        }
                        $objOutputStream.Write($arrCopyBuffer, 0, $intReadByteCount)
                    }
                    if ($intWrittenBytes -ne $objZipEntry.Length) {
                        throw 'toolchain: truncated ZIP member'
                    }
                } finally {
                    if ($null -ne $objOutputStream) {
                        $objOutputStream.Dispose()
                    }
                    $objInputStream.Dispose()
                }
            }
        } finally {
            $objZipArchive.Dispose()
        }
    } else {
        # GNU tar escape quoting makes ambiguous names visible; this vendor layout
        # needs no quoted names, hardlinks or devices. Inspect before extraction.
        $objListingProcess = New-ArchiveProcess @('-tvf', $Archive, '--numeric-owner', '--full-time', '--quoting-style=escape')
        $boolListingStarted = $false
        try {
            $boolListingStarted = $objListingProcess.Start()
            if (-not $boolListingStarted) {
                throw 'toolchain: cannot start archive listing'
            }
            $objListingErrorTask = $objListingProcess.StandardError.ReadToEndAsync()
            while ($null -ne ($strListingLine = $objListingProcess.StandardOutput.ReadLine())) {
                if ($strListingLine.Length -gt 8192) {
                    throw 'toolchain: archive listing record exceeds its limit'
                }
                if ($strListingLine -cnotmatch '^([d\-l][rwxstST-]{9})\s+[0-9]+/[0-9]+\s+([0-9]+)\s+[0-9-]+\s+[0-9:.]+\s+(.+)$') {
                    throw 'toolchain: unsupported GNU tar member record'
                }
                $strMemberMode = $Matches[1];
                [long]$intMemberSize = $Matches[2];
                $strRecord = $Matches[3]
                $strMemberKind = switch ($strMemberMode[0]) {
                    'd' {
                        'directory'
                    };
                    'l' {
                        'link'
                    };
                    default {
                        'file'
                    }
                }
                if ($strMemberKind -cne 'file' -and $intMemberSize -ne 0) {
                    throw 'toolchain: non-file tar member has data'
                }
                $strTargetPath = ''
                if ($strMemberKind -ceq 'link') {
                    $arrLinkRecordParts = $strRecord.Split(' -> ', [StringSplitOptions]::None)
                    if ($arrLinkRecordParts.Count -ne 2) {
                        throw 'toolchain: ambiguous GNU tar link record'
                    }
                    $strRecord = $arrLinkRecordParts[0];
                    $strTargetPath = $arrLinkRecordParts[1]
                }
                $strMemberName = $strRecord.TrimEnd('/')
                Assert-ArchiveName $strMemberName $ReleaseRoot
                if ($strMemberMode -cmatch '[sStT]' -or ($strMemberKind -ceq 'file' -and $strMemberMode -cmatch 'x' -and
                    ($strMemberMode[5] -ceq 'w' -or $strMemberMode[8] -ceq 'w'))) {
                    throw 'toolchain: dangerous archive member permissions'
                }
                if (-not $objArchiveMembers.TryAdd($strMemberName, @{
                    Kind = $strMemberKind;
                    Size = $intMemberSize;
                    Target = $strTargetPath
                })) {
                    throw 'toolchain: duplicate archive member'
                }
                $intExpandedBytes += $intMemberSize
                if ($objArchiveMembers.Count -gt 50000 -or $intExpandedBytes -gt 1073741824) {
                    throw 'toolchain: archive extraction limit exceeded'
                }
            }
            $objListingProcess.WaitForExit()
            [void]($objListingErrorTask.GetAwaiter().GetResult())
            if ($objListingProcess.ExitCode -ne 0) {
                throw "Runtime archive listing failed: $($objListingProcess.ExitCode)"
            }
        } finally {
            if ($boolListingStarted -and -not $objListingProcess.HasExited) {
                $objListingProcess.Kill($true);
                $objListingProcess.WaitForExit()
            }
            $objListingProcess.Dispose()
        }
        Assert-MemberTree $objArchiveMembers $ReleaseRoot
        $objExtractionProcess = New-ArchiveProcess @('-xf', $Archive, '-C', $Destination,
            '--no-same-owner', '--no-same-permissions', '--delay-directory-restore')
        $boolExtractionStarted = $false
        try {
            $boolExtractionStarted = $objExtractionProcess.Start()
            if (-not $boolExtractionStarted) {
                throw 'toolchain: cannot start archive extraction'
            }
            $objOutputTask = $objExtractionProcess.StandardOutput.ReadToEndAsync()
            $objErrorTask = $objExtractionProcess.StandardError.ReadToEndAsync()
            $objExtractionProcess.WaitForExit()
            [void]($objOutputTask.GetAwaiter().GetResult())
            [void]($objErrorTask.GetAwaiter().GetResult())
            if ($objExtractionProcess.ExitCode -ne 0) {
                throw "Runtime extraction failed: $($objExtractionProcess.ExitCode)"
            }
        } finally {
            if ($boolExtractionStarted -and -not $objExtractionProcess.HasExited) {
                $objExtractionProcess.Kill($true);
                $objExtractionProcess.WaitForExit()
            }
            $objExtractionProcess.Dispose()
        }
    }
    $objObservedMemberNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($objPathItem in Get-ChildItem -LiteralPath $Destination -Recurse -Force) {
        $strMemberName = [IO.Path]::GetRelativePath($Destination, $objPathItem.FullName).Replace('\', '/')
        if (-not $objArchiveMembers.ContainsKey($strMemberName)) {
            throw 'toolchain: unexpected extracted member'
        }
        $hashtableMember = $objArchiveMembers[$strMemberName]
        if ($hashtableMember.Kind -ceq 'link') {
            if (-not ($objPathItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $objPathItem.LinkTarget -cne $hashtableMember.Target) {
                throw 'toolchain: extracted link does not match the reviewed listing'
            }
        } else {
            $null = Assert-OrdinaryPath $objPathItem.FullName -Directory:($hashtableMember.Kind -ceq 'directory')
            if ($hashtableMember.Kind -ceq 'file' -and $objPathItem.Length -ne $hashtableMember.Size) {
                throw 'toolchain: extracted file size changed'
            }
        }
        [void]($objObservedMemberNames.Add($strMemberName))
    }
    if ($objObservedMemberNames.Count -ne $objArchiveMembers.Count) {
        throw 'toolchain: incomplete archive extraction'
    }
}
function Assert-CurlCapability {
    # .SYNOPSIS
    # Requires the reviewed streaming download capabilities.
    #
    # .DESCRIPTION
    # Queries the already resolved curl application without default configuration. Requires unambiguous curl and libcurl versions of at least 8.5.0, HTTPS, SSL and every selected download option. Windows retains the curl major-version-8 restriction. Query failures or unsupported output throw before download. Produces no success output; Windows provenance uses the information stream.
    #
    # .PARAMETER Path
    # Ordinary absolute path to the previously resolved and inspected curl application.
    #
    # .PARAMETER Windows
    # Applies the retained Windows curl major-version restriction and provenance output.
    #
    # .EXAMPLE
    # Assert-CurlCapability -Path $strCurlPath -Windows:$IsWindows
    #
    # # Internal caller example: verifies the selected application before runtime acquisition.
    #
    # .EXAMPLE
    # Assert-CurlCapability -Path '/usr/bin/curl'
    #
    # # Internal Linux caller example: throws if the installed application lacks the required version or options.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Unsupported capabilities and unexpected native statuses throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    # No positional parameters are supported.
    #
    # Version: 1.0.20261009.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory = $true)][string] $Path, [switch] $Windows)
    $arrCurlVersionOutput = @(& $Path --disable --version)
    if ($LASTEXITCODE -ne 0 -or $arrCurlVersionOutput.Count -lt 3 -or
        -not $arrCurlVersionOutput[0].StartsWith('curl ', [StringComparison]::Ordinal)) {
        throw 'toolchain: curl capability version query failed'
    }
    $objCurlVersionMatches = [regex]::Matches($arrCurlVersionOutput[0], '(?<!\S)curl ([0-9]+\.[0-9]+\.[0-9]+)(?= |$)')
    $objLibraryVersionMatches = [regex]::Matches($arrCurlVersionOutput[0], '(?<!\S)libcurl/([0-9]+\.[0-9]+\.[0-9]+)(?= |$)')
    [version] $objCurlVersion = $null
    [version] $objLibraryVersion = $null
    if ($objCurlVersionMatches.Count -ne 1 -or $objLibraryVersionMatches.Count -ne 1 -or
        -not [version]::TryParse($objCurlVersionMatches[0].Groups[1].Value, [ref]$objCurlVersion) -or
        -not [version]::TryParse($objLibraryVersionMatches[0].Groups[1].Value, [ref]$objLibraryVersion) -or
        $objCurlVersion -lt [version]'8.5.0' -or $objLibraryVersion -lt [version]'8.5.0' -or
        ($Windows -and $objCurlVersion.Major -ne 8)) {
        throw 'toolchain: curl and libcurl 8.5+ are required; Windows curl must remain in major 8'
    }
    $arrProtocols = @($arrCurlVersionOutput | Where-Object { $_ -cmatch '^Protocols:' })
    $arrFeatures = @($arrCurlVersionOutput | Where-Object { $_ -cmatch '^Features:' })
    if ($arrProtocols.Count -ne 1 -or $arrProtocols[0] -cnotmatch '^Protocols:.*\bhttps\b' -or
        $arrFeatures.Count -ne 1 -or $arrFeatures[0] -cnotmatch '^Features:.*\bSSL\b') {
        throw 'toolchain: curl with HTTPS/TLS is required'
    }
    $arrCurlHelpOutput = @(& $Path --disable --help all)
    if ($LASTEXITCODE -ne 0) {
        throw 'toolchain: curl capability query failed'
    }
    foreach ($strCurlOption in @('disable', 'silent', 'show-error', 'fail', 'location', 'proto', 'proto-redir',
        'tlsv1.2', 'connect-timeout', 'max-time', 'max-filesize', 'retry', 'retry-max-time', 'output')) {
        if (($arrCurlHelpOutput -join [Environment]::NewLine) -cnotmatch ('(?m)^[^\r\n]*--' + [regex]::Escape($strCurlOption) + '(?: |$)')) {
            throw "toolchain: curl is missing required option --$strCurlOption"
        }
    }
    if ($Windows) {
        Write-Information -MessageData "curl $($arrCurlVersionOutput[0]) at $Path SHA256 $((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash)." -InformationAction Continue
    }
}
function Install-ReviewedRuntime {
    # .SYNOPSIS
    # Acquires and verifies one reviewed runtime role.
    #
    # .DESCRIPTION
    # Requires the initialized script-owned staging root and resolved reviewed curl. Creates a private role directory, downloads with bounded retries and a fixed compressed-byte limit, checks the completed file size, verifies the exact digest, and validates extraction. Checks absolute Node and bundled npm paths and versions. Writes visible provenance to the information stream. Acquisition, digest, archive, path, and version failures throw. The outer script owns failed-stage cleanup.
    #
    # .PARAMETER Role
    # Internal role preferred or recoveryCompatibility, admitted by the outer script.
    #
    # .PARAMETER Version
    # Exact reviewed Node version for the role.
    #
    # .PARAMETER NpmVersion
    # Exact bundled npm version expected for the role.
    #
    # .PARAMETER Digest
    # Reviewed lowercase SHA256 digest for this platform archive.
    #
    # .EXAMPLE
    # $hashtableRuntime = Install-ReviewedRuntime -Role 'preferred' -Version $objPackage.engines.node -NpmVersion $objPackage.engines.npm -Digest $strRuntimeDigest
    #
    # # Internal caller example: returns the verified preferred record. Script-owned paths must already be initialized.
    #
    # .EXAMPLE
    # $hashtableRuntime = Install-ReviewedRuntime -Role 'recoveryCompatibility' -Version $objPin.recoveryCompatibility.node -NpmVersion $objPin.recoveryCompatibility.npm -Digest $objPin.recoveryCompatibility.linuxX64Sha256
    #
    # # Internal Linux caller example: returns the separate recovery record. It does not publish PATH or install dependencies.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [hashtable] One runtime record with string properties Node, Npm, and Bin. Provenance is information output. Failures throw without a runtime record.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Role
    #   Position 1: Version
    #   Position 2: NpmVersion
    #   Position 3: Digest
    #
    # Version: 1.0.20261009.0
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([string] $Role, [string] $Version, [string] $NpmVersion, [string] $Digest)
    $strPlatform = if ($IsWindows) {
        'win-x64'
    } else {
        'linux-x64'
    }
    $strArchiveSuffix = if ($IsWindows) {
        'zip'
    } else {
        'tar.xz'
    }
    $strReleaseRoot = "node-v$Version-$strPlatform"
    $strDestinationPath = Join-Path $strNodeRoot $Role
    New-PrivateDirectory $strDestinationPath -Confirm:$false -WhatIf:$WhatIfPreference
    $strArchive = Join-Path $strNodeRoot "$Role.$strArchiveSuffix"
    $strDownloadAddress = "https://nodejs.org/dist/v$Version/$strReleaseRoot.$strArchiveSuffix"
    # This bounds retry admission, not an active transfer: nominal 483s/archive.
    & $strCurlPath --disable --silent --show-error --fail --location --proto '=https' `
    --proto-redir '=https' --tlsv1.2 --connect-timeout 20 --max-time 180 `
    --retry 2 --retry-max-time 300 --max-filesize $intMaximumRuntimeArchiveBytes --output $strArchive $strDownloadAddress
    if ($LASTEXITCODE -ne 0) {
        throw "Runtime download failed: $LASTEXITCODE ($Role/$strPlatform)"
    }
    $null = Assert-OrdinaryPath $strArchive
    if ((Get-Item -LiteralPath $strArchive -Force -ErrorAction Stop).Length -gt $intMaximumRuntimeArchiveBytes) {
        throw 'toolchain: compressed runtime archive exceeds the fixed size limit'
    }
    if ((Get-FileHash -LiteralPath $strArchive -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Digest) {
        throw "The runtime archive digest is incorrect for $strDownloadAddress. Check package.json engines.node and .github/workflows/ci-toolchain.json $Role. Verify the official release checksum before changing the declaration."
    }
    Expand-ReviewedArchive $strArchive $strDestinationPath $strReleaseRoot
    $strRuntimePath = Join-Path $strDestinationPath $strReleaseRoot
    $strNodePath = Join-Path $strRuntimePath $(if ($IsWindows) {
        'node.exe'
    } else {
        'bin/node'
    })
    $strNpmScriptPath = Join-Path $strRuntimePath $(if ($IsWindows) {
        'node_modules/npm/bin/npm-cli.js'
    } else {
        'lib/node_modules/npm/bin/npm-cli.js'
    })
    $null = Assert-OrdinaryPath $strNodePath
    $null = Assert-OrdinaryPath $strNpmScriptPath
    $strNpmRootPath = [IO.Path]::GetFullPath((Join-Path ([IO.Path]::GetDirectoryName($strNpmScriptPath)) '..'))
    $null = Assert-OrdinaryPath (Join-Path $strNpmRootPath 'bin/npx-cli.js')
    $hashtableNpmPackage = Read-BoundedJson (Join-Path $strNpmRootPath 'package.json')
    if ($hashtableNpmPackage.version -isnot [string] -or $hashtableNpmPackage.version -cne $NpmVersion) {
        throw 'The installed npm version is incorrect.'
    }
    $arrNodeVersionOutput = @(& $strNodePath --version)
    if ($LASTEXITCODE -ne 0 -or $arrNodeVersionOutput.Count -ne 1 -or $arrNodeVersionOutput[0] -cne "v$Version") {
        throw 'The installed Node version is incorrect.'
    }
    $arrNpmVersionOutput = @(& $strNodePath $strNpmScriptPath --version)
    if ($LASTEXITCODE -ne 0 -or $arrNpmVersionOutput.Count -ne 1 -or $arrNpmVersionOutput[0] -cne $NpmVersion) {
        throw 'The installed npm version is incorrect.'
    }
    Write-Information -MessageData "Verified $Role Node $Version/npm $NpmVersion $strPlatform SHA256 $Digest." -InformationAction Continue
    return @{
        Node = $strNodePath;
        Npm = $strNpmScriptPath;
        Bin = [IO.Path]::GetDirectoryName($strNodePath)
    }
}
if ((-not $IsLinux -and -not $IsWindows) -or
    [Runtime.InteropServices.RuntimeInformation]::OSArchitecture -ne [Runtime.InteropServices.Architecture]::X64 -or
    [Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -ne [Runtime.InteropServices.Architecture]::X64) {
    throw 'The CI runtime installer requires native Linux or Windows x64.'
}
if ($IncludeRecoveryCompatibility -and -not $IsLinux) {
    throw 'Recovery compatibility is supported only on Linux x64.'
}
foreach ($strRequiredVariable in @('RUNNER_TEMP', 'GITHUB_PATH', 'GITHUB_ENV')) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($strRequiredVariable))) {
        throw "CI setup requires the runner environment variable $strRequiredVariable."
    }
}
$strRepositoryRoot = Assert-OrdinaryPath ([IO.Path]::GetFullPath("$PSScriptRoot/../..")) -Directory
$objPin = Read-BoundedJson "$PSScriptRoot/ci-toolchain.json" 16384
$objPackage = Read-BoundedJson "$strRepositoryRoot/package.json"
Assert-Shape $objPin @('schemaVersion', 'preferred', 'recoveryCompatibility')
Assert-Shape $objPin.preferred @('linuxX64Sha256', 'windowsX64Sha256')
Assert-Shape $objPin.recoveryCompatibility @('node', 'npm', 'linuxX64Sha256')
if ($objPin.schemaVersion -isnot [long] -or $objPin.schemaVersion -ne 2 -or
    $objPackage.engines.node -isnot [string] -or $objPackage.engines.node -cnotmatch '\A24\.[0-9]+\.[0-9]+\z' -or
    $objPackage.engines.npm -isnot [string] -or $objPackage.engines.npm -cnotmatch '\A[0-9]+\.[0-9]+\.[0-9]+\z' -or
    $objPin.recoveryCompatibility.node -isnot [string] -or $objPin.recoveryCompatibility.node -cne '22.23.3' -or $objPin.recoveryCompatibility.npm -isnot [string] -or $objPin.recoveryCompatibility.npm -cne '10.9.9') {
    throw 'The reviewed runtime declaration is invalid.'
}
foreach ($strRuntimeDigest in @($objPin.preferred.linuxX64Sha256, $objPin.preferred.windowsX64Sha256, $objPin.recoveryCompatibility.linuxX64Sha256)) {
    if ($strRuntimeDigest -isnot [string] -or $strRuntimeDigest -cnotmatch '\A[a-f0-9]{64}\z') {
        throw 'The reviewed runtime declaration is invalid.'
    }
}
$strRunnerRoot = Assert-OrdinaryPath $env:RUNNER_TEMP -Directory
$objPathComparison = if ($IsWindows) {
    [StringComparison]::OrdinalIgnoreCase
} else {
    [StringComparison]::Ordinal
}
if ($strRunnerRoot.Equals($strRepositoryRoot, $objPathComparison) -or
    $strRunnerRoot.StartsWith($strRepositoryRoot + [IO.Path]::DirectorySeparatorChar, $objPathComparison)) {
    throw 'toolchain: staging root is inside the checkout'
}
$strCommandRoot = Assert-OrdinaryPath (Join-Path $strRunnerRoot '_runner_file_commands') -Directory
if ($strCommandRoot.Equals($strRepositoryRoot, $objPathComparison) -or
    $strCommandRoot.StartsWith($strRepositoryRoot + [IO.Path]::DirectorySeparatorChar, $objPathComparison)) {
    throw 'Runner command directory must be outside the checkout.'
}
$strCommandRootIdentity = Get-OwnedPathIdentity -Path $strCommandRoot -Directory
$null = Assert-OrdinaryPath $env:GITHUB_PATH
$null = Assert-OrdinaryPath $env:GITHUB_ENV
foreach ($strChannelPath in @($env:GITHUB_PATH, $env:GITHUB_ENV)) {
    if (-not [string]::Equals([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($strChannelPath)), $strCommandRoot, $objPathComparison)) {
        throw 'Runner channels must be direct files in RUNNER_TEMP/_runner_file_commands.'
    }
}
$strPathChannelIdentity = Get-RunnerChannelIdentity -Path $env:GITHUB_PATH
$strEnvironmentChannelIdentity = Get-RunnerChannelIdentity -Path $env:GITHUB_ENV
if ($strPathChannelIdentity -ceq $strEnvironmentChannelIdentity) {
    throw 'Runner channels must identify different files.'
}
if ([IO.Path]::GetFullPath($env:GITHUB_PATH).Equals([IO.Path]::GetFullPath($env:GITHUB_ENV), $objPathComparison)) {
    throw 'toolchain: runner communication files must be distinct'
}
if ($IsWindows) {
    for ($objPathComponent = [IO.DirectoryInfo]::new($strCommandRoot); $null -ne $objPathComponent; $objPathComponent = $objPathComponent.Parent) {
        Assert-WindowsWriter $objPathComponent.FullName
    }
    Assert-WindowsWriter $env:GITHUB_PATH
    Assert-WindowsWriter $env:GITHUB_ENV
    $strCurlPath = Join-Path ([Environment]::SystemDirectory) 'curl.exe'
} else {
    $strCurlPath = '/usr/bin/curl'
    $null = Assert-OrdinaryPath '/usr/bin/tar'
    $null = Assert-OrdinaryPath '/usr/bin/xz'
}
$null = Assert-OrdinaryPath $strCurlPath
if ($IsWindows) {
    if ($PSVersionTable.PSVersion.ToString() -cne '7.6.5') {
        throw 'toolchain: reviewed Windows PowerShell 7.6.5 is required'
    }
    for ($objPathComponent = Get-Item -LiteralPath $strCurlPath; $null -ne $objPathComponent;
        $objPathComponent = if ($objPathComponent -is [IO.DirectoryInfo]) {
            $objPathComponent.Parent
        } else {
            $objPathComponent.Directory
        }) {
        Assert-WindowsWriter $objPathComponent.FullName
    }
    Assert-CurlCapability -Path $strCurlPath -Windows
} elseif ((Get-LinuxEffectiveUserId) -eq 0) {
    throw 'toolchain: Linux extraction requires a nonzero effective UID'
}
& "$PSScriptRoot/Test-CheckoutCredentials.ps1"
foreach ($strRelativePath in @('.npmrc', '.github/.npmrc', '.github/workflows/.npmrc',
    'npm-shrinkwrap.json', '.github/workflows/npm-shrinkwrap.json')) {
    if ($null -ne (Get-Item -LiteralPath (Join-Path $strRepositoryRoot $strRelativePath) -Force -ErrorAction SilentlyContinue)) {
        throw "Unreviewed npm configuration selector: $strRelativePath"
    }
}
$strNodeRoot = Join-Path $strRunnerRoot 'styleguide-node'
$strOwnership = [Guid]::NewGuid().ToString('N')
$boolOwned = $false
$boolPublished = $false
$objPathChannel = $null
$objEnvironmentChannel = $null
try {
    # Exclusive handles also refuse aliased communication files before download.
    $objPathChannel = [IO.File]::Open($env:GITHUB_PATH, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $objEnvironmentChannel = [IO.File]::Open($env:GITHUB_ENV, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    if ((Get-RunnerChannelIdentity -Path $env:GITHUB_PATH -Stream $objPathChannel) -cne $strPathChannelIdentity -or
        (Get-RunnerChannelIdentity -Path $env:GITHUB_ENV -Stream $objEnvironmentChannel) -cne $strEnvironmentChannelIdentity) {
        throw 'Runner channel identity changed while opening its handle.'
    }
    New-PrivateDirectory $strNodeRoot -Confirm:$false -WhatIf:$WhatIfPreference
    $strRootIdentity = Get-OwnedPathIdentity $strNodeRoot -Directory
    $strMarker = Join-Path $strNodeRoot '.owner'
    [IO.File]::WriteAllText($strMarker, $strOwnership, $objStrictUtf8Encoding)
    $strMarkerIdentity = Get-OwnedPathIdentity $strMarker
    $boolOwned = $true
    # Process-local selector cleanup is mandatory before child execution.
    Remove-Item Env:STYLEGUIDE_RECOVERY_NODE22, Env:NODE_OPTIONS, Env:NODE_PATH -ErrorAction SilentlyContinue -Confirm:$false -WhatIf:$false
    Get-ChildItem Env: | Where-Object {
        $_.Name -imatch '^npm_config_'
    } |
    ForEach-Object {
        Remove-Item -LiteralPath "Env:$($_.Name)" -Confirm:$false -WhatIf:$false
    }
    $env:npm_config_userconfig = Join-Path $strNodeRoot 'npm-user.config'
    $env:npm_config_globalconfig = Join-Path $strNodeRoot 'npm-global.config'
    foreach ($strConfigurationPath in @($env:npm_config_userconfig, $env:npm_config_globalconfig)) {
        [IO.File]::WriteAllText($strConfigurationPath, '', $objStrictUtf8Encoding)
    }
    $env:npm_config_registry = 'https://registry.npmjs.org/'
    $env:npm_config_ignore_scripts = 'true'
    $env:npm_config_audit = 'false'
    $env:npm_config_fund = 'false'
    $env:CI = 'true'
    $strRuntimeDigest = if ($IsWindows) {
        $objPin.preferred.windowsX64Sha256
    } else {
        $objPin.preferred.linuxX64Sha256
    }
    if (-not $IsWindows) {
        Assert-CurlCapability -Path $strCurlPath
    }
    $hashtablePreferredRuntime = Install-ReviewedRuntime 'preferred' $objPackage.engines.node $objPackage.engines.npm $strRuntimeDigest
    $hashtableCompatibilityRuntime = $null
    if ($IncludeRecoveryCompatibility) {
        $hashtableCompatibilityRuntime = Install-ReviewedRuntime 'recoveryCompatibility' $objPin.recoveryCompatibility.node `
        $objPin.recoveryCompatibility.npm $objPin.recoveryCompatibility.linuxX64Sha256
    }
    $arrInstallRoots = @()
    if ($InstructionDependencies) {
        $arrInstallRoots += $strRepositoryRoot
    }
    if ($WorkflowDependencies) {
        $arrInstallRoots += $PSScriptRoot
    }
    $arrAllManifestPaths = @($arrInstallRoots | ForEach-Object {
        Join-Path $_ 'package.json'
        Join-Path $_ 'package-lock.json'
    })
    foreach ($strManifestPath in $arrAllManifestPaths) {
        $null = Read-BoundedJson $strManifestPath 5242880
    }
    $arrAllManifestHashesBefore = @($arrAllManifestPaths | ForEach-Object {
        (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash
    })
    foreach ($strInstallRoot in $arrInstallRoots) {
        $arrManifestPaths = @('package.json', 'package-lock.json') | ForEach-Object {
            Join-Path $strInstallRoot $_
        }
        foreach ($strManifestPath in $arrManifestPaths) {
            $null = Read-BoundedJson $strManifestPath 5242880
        }
        $arrManifestHashesBefore = @($arrManifestPaths | ForEach-Object {
            (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash
        })
        & $hashtablePreferredRuntime.Node --permission "--allow-fs-read=$strRepositoryRoot" "$PSScriptRoot/Validate-WorkflowPolicy.mjs" --preflight |
            ForEach-Object { Write-Information -MessageData $_ -InformationAction Continue }
        if ($LASTEXITCODE -ne 0) {
            throw 'Package and workflow preflight failed before installation.'
        }
        & $hashtablePreferredRuntime.Node $hashtablePreferredRuntime.Npm --prefix $strInstallRoot ci --ignore-scripts --no-audit --fund=false --include=dev --package-lock=true |
            ForEach-Object { Write-Information -MessageData $_ -InformationAction Continue }
        if ($LASTEXITCODE -ne 0) {
            throw "Locked installation failed: $LASTEXITCODE"
        }
        $arrManifestHashesAfter = @($arrManifestPaths | ForEach-Object {
            (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash
        })
        if (($arrManifestHashesBefore -join ',') -cne ($arrManifestHashesAfter -join ',')) {
            throw 'Locked installation changed a package manifest or lockfile.'
        }
    }
    $arrAllManifestHashesAfter = @($arrAllManifestPaths | ForEach-Object {
        (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash
    })
    if (($arrAllManifestHashesBefore -join ',') -cne ($arrAllManifestHashesAfter -join ',')) {
        throw 'Locked installation changed a requested manifest or lockfile.'
    }
    [IO.File]::WriteAllText((Join-Path $strNodeRoot 'ready.json'),
        (@{
            node = $objPackage.engines.node;
            npm = $objPackage.engines.npm
        } | ConvertTo-Json -Compress), $objStrictUtf8Encoding)
    $arrRunnerRecords = @("npm_config_userconfig=$env:npm_config_userconfig", "npm_config_globalconfig=$env:npm_config_globalconfig",
        'npm_config_registry=https://registry.npmjs.org/', 'npm_config_ignore_scripts=true', 'npm_config_audit=false', 'npm_config_fund=false', 'CI=true',
        'NODE_PATH=')
    if ($null -ne $hashtableCompatibilityRuntime) {
        $arrRunnerRecords += "STYLEGUIDE_RECOVERY_NODE22=$($hashtableCompatibilityRuntime.Node)"
    } else {
        $arrRunnerRecords += 'STYLEGUIDE_RECOVERY_NODE22='
    }
    foreach ($strRecord in $arrRunnerRecords + @($hashtablePreferredRuntime.Bin)) {
        if ($strRecord -match '[\r\n]') {
            throw 'toolchain: invalid runner record'
        }
    }
    $null = Assert-OrdinaryPath $env:GITHUB_PATH
    $null = Assert-OrdinaryPath $env:GITHUB_ENV
    if ((Get-OwnedPathIdentity -Path $strCommandRoot -Directory) -cne $strCommandRootIdentity -or
        (Get-RunnerChannelIdentity -Path $env:GITHUB_PATH) -cne $strPathChannelIdentity -or
        (Get-RunnerChannelIdentity -Path $env:GITHUB_ENV) -cne $strEnvironmentChannelIdentity -or
        (Get-RunnerChannelIdentity -Path $env:GITHUB_PATH -Stream $objPathChannel) -cne $strPathChannelIdentity -or
        (Get-RunnerChannelIdentity -Path $env:GITHUB_ENV -Stream $objEnvironmentChannel) -cne $strEnvironmentChannelIdentity) {
        throw 'Runner command directory or channel identity changed before publication.'
    }
    # A partial channel write fails the step. No downstream job may use its output.
    $objUtf8Encoding = [Text.UTF8Encoding]::new($false)
    $arrEnvironmentBytes = $objUtf8Encoding.GetBytes(($arrRunnerRecords -join "`n") + "`n")
    $arrPathBytes = $objUtf8Encoding.GetBytes($hashtablePreferredRuntime.Bin + "`n")
    [void]($objEnvironmentChannel.Seek(0, [IO.SeekOrigin]::End))
    $objEnvironmentChannel.Write($arrEnvironmentBytes, 0, $arrEnvironmentBytes.Length)
    $objEnvironmentChannel.Flush($true)
    [void]($objPathChannel.Seek(0, [IO.SeekOrigin]::End))
    $objPathChannel.Write($arrPathBytes, 0, $arrPathBytes.Length)
    $objPathChannel.Flush($true)
    $objEnvironmentChannel.Dispose();
    $objEnvironmentChannel = $null
    $objPathChannel.Dispose();
    $objPathChannel = $null
    $env:PATH = $hashtablePreferredRuntime.Bin + [IO.Path]::PathSeparator + $env:PATH
    if ($null -ne $hashtableCompatibilityRuntime) {
        $env:STYLEGUIDE_RECOVERY_NODE22 = $hashtableCompatibilityRuntime.Node
    }
    $boolPublished = $true
    Write-Output 'Reviewed runtime setup completed.'
} finally {
    foreach ($objChannel in @($objPathChannel, $objEnvironmentChannel)) {
        if ($null -ne $objChannel) {
            try {
                $objChannel.Dispose()
            } catch {
                Write-Warning 'Runtime channel cleanup failed after the primary setup failure.'
            }
        }
    }
    if ($boolOwned -and -not $boolPublished) {
        try {
            $null = Assert-OrdinaryPath $strNodeRoot -Directory
            $null = Assert-OrdinaryPath $strMarker
            # IDs survive normal metadata writes. The nonce is an additional ownership check.
            # These sampled path checks do not isolate hostile code with the same user token.
            if ((Get-OwnedPathIdentity $strNodeRoot -Directory) -cne $strRootIdentity -or
                (Get-OwnedPathIdentity $strMarker) -cne $strMarkerIdentity -or
                (Get-Item -LiteralPath $strMarker -Force).Length -ne 32 -or
                [IO.File]::ReadAllText($strMarker) -cne $strOwnership) {
                throw 'ownership changed'
            }
            # Do not follow links or recursively delete caller-selected directories.
            $arrOwnedItems = @(Get-ChildItem -LiteralPath $strNodeRoot -Recurse -Force | Sort-Object {
                $_.FullName.Length
            } -Descending)
            foreach ($objPathItem in $arrOwnedItems) {
                if ($objPathItem.PSIsContainer -and -not ($objPathItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                    [IO.Directory]::Delete($objPathItem.FullName, $false)
                } else {
                    [IO.File]::Delete($objPathItem.FullName)
                }
            }
            [IO.Directory]::Delete($strNodeRoot, $false)
        } catch {
            Write-Warning "Runtime cleanup could not prove completion; retained owned staging at $strNodeRoot."
        }
    }
}
