#
# Module manifest for module 'DevTools-Win'
#
# Generated by: Chanth Miao
#
# Generated on: 2020/12/31
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule             = 'DevTools-Win.psm1'

    # Version number of this module.
    ModuleVersion          = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions   = @('Core', "Desktop")

    # ID used to uniquely identify this module
    GUID                   = 'fc06dd36-b88b-419c-b0ac-61847eedcef8'

    # Author of this module
    Author                 = 'Chanth Miao <chanthmiao@outlook.com>'

    # Company or vendor of this module
    CompanyName            = 'Unknown'

    # Copyright statement for this module
    Copyright              = '(c) Chanth Miao. All rights reserved.'

    # Description of the functionality provided by this module
    Description            = 'My persional power tools.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion      = '5.1'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    DotNetFrameworkVersion = '4.5'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    ClrVersion             = '4.0'

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies   = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess       = @(".\scripts\DevTools-Check.ps1")

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport      = @(
        'Add-Path',
        'Clear-WebProxy',
        'Enable-Clang',
        'Enable-Vcpkg',
        'Enter-VsEnv',
        'Format-ItemSize',
        'Get-CmdletAlias',
        'Get-ItemSize',
        'Get-TempDir',
        'Remove-Path',
        'Send-Notification',
        'Set-WebProxy',
        'Start-Log',
        'Stop-Log',
        'Write-Log'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport        = @()

    # Variables to export from this module
    VariablesToExport      = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport        = @(
        'apa',
        'clwp',
        'ecla',
        'etvs',
        'evpg',
        'fis',
        'gcas',
        'gis',
        'gtd',
        'rpa',
        'salg',
        'sdnf',
        'splg',
        'swp',
        'wrlg'
    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData            = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Developer', 'DevTools', 'Powerfull')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

