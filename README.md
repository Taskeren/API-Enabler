# API-Enabler

API-Enabler is a script tool to install and patch NetLimiter for API beginners.

This script is designed for the NL patching authors to help users to install. See below.

## How to Use?

[Example](https://github.com/Taskeren/NetLimiterPatching)

You need to make a folder in this structure.

```
.
└── MySuperNLFolder -- the pack, any name you like
    ├── Install.ps1 -- this script
    ├── netlimiter-a.b.c.d.exe -- the NL installer of compatible version (Optional)
    └── patch -- the patched dlls to replace the official ones
        ├── NetLimiter.dll
        ├── NLClientApp.Core.dll
        └── ...
```

And before you send the pack (MySuperNLFolder) to others, you need to specify the NL version in `Install.ps1`, at
line 42.

You can pack with the installer, or the script will download it when installing.

```diff
- $NL_VERSION = "5.2.6.0"
+ $NL_VERSION = "a.b.c.d"
```

And if the script fails at phase of patching, you skip the installation phase by starting the script with argument `/patch`.

```
./Install.ps1 /patch
```

### About PowerShell Execution Policies

[Microsoft Document](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)

TL;DR - Execute `Set-ExecutionPolicy Unrestricted` to allow this script to run.

## License

This script is licensed under WTFPL. But I hope that you don't change the credits in the script.
