# ~/.config/nushell/env.nu
# Defines global environment variables for all Nushell sessions

# Base directories
$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"  # Symlinked from ~/.config where possible
$env.CF = $env.XDG_CONFIG_HOME
$env.DOTZ = $"($env.HOME)/.config/zsh"         # Real files in ~/.config/zsh
$env.RX = $"($env.HOME)/.config/rx"            # Real files in ~/.config/rx
$env.NV = $"($env.HOME)/il-diab"
$env.NTS = $"($env.HOME)/notes"
$env.DX = $"($env.HOME)/Documents"
$env.DN = $"($env.HOME)/Downloads"
$env.SCS = $"($env.DX)/webpage"
$env.SUSO = $"($env.HOME)/sucias-social"
$env.CAPTURE_FOLDER = $"($env.HOME)/Pictures"

# Tool-specific settings
$env.PATH = (
    $env.PATH | 
    prepend $"($env.HOME)/myCommands" |
    prepend $"($env.HOME)/myCommands/bin" |
    prepend "/opt/homebrew/opt/ruby/bin" |
    prepend $"($env.HOME)/.cargo/bin" |
    prepend $"($env.HOME)/.local/bin" |
    prepend $env.RX
)

$env.FZF_DEFAULT_OPTS = '--height=20% --cycle --info=hidden --tabstop=4 --black'
$env.CLICOLOR = 1
$env.EDITOR = 'nvim'

# Set MAKEFLAGS based on system type
# if (sys).host.name == "Darwin" {
#     if (run-external "sysctl" "-n" "hw.cputype" | str trim) == "16777228" {
#         # Apple Silicon
#         $env.MAKEFLAGS = $"-j(run-external "sysctl" "-n" "hw.ncpu" | str trim)"
#     } else {
#         # Intel
#         $env.MAKEFLAGS = $"-j(run-external "sysctl" "-n" "hw.ncpu" | str trim)"
#     }
# } else if (sys).host.name == "Linux" {
#     $env.MAKEFLAGS = $"-j(run-external "nproc" | str trim)"
# }

$env.FUNCNEST = 25000

# Homebrew path
$env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")

# Golang settings
$env.GOROOT = "/opt/homebrew/opt/go/libexec"
$env.GOPATH = $"($env.HOME)/go"
$env.PATH = (
    $env.PATH | 
    prepend $"($env.GOPATH)/bin" | 
    prepend $"($env.GOROOT)/bin"
)

# Source carapace completions - may require additional setup in Nushell
# Equivalent might be: use ~/.config/nushell/completions/carapace.nu
# Note: Specific implementation depends on carapace's Nushell support
