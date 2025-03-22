# ~/.config/nushell/config.nu
# Main Nushell configuration file

# Load environment
source ~/.config/nushell/env.nu

# History settings
$env.config = {
    history: {
        max_size: 5000                  # Max history entries
        file_format: "sqlite"           # History file format
        sync_on_enter: true             # Sync on each command
        isolation: false                # Share history across sessions
    }
    # History filtering (equivalent to HISTORY_IGNORE)
    # Note: Nushell handles history filtering differently from zsh
    # You may need to use hooks for more complex filtering
}

# Load modules - Nushell equivalent of sourcing zsh modules
# You'll need to convert each zsh module to a Nushell module
# Example:
# source ~/.config/nushell/modules/aliases.nu
# source ~/.config/nushell/modules/functions.nu

# NODE_PATH environment variable
$env.NODE_PATH = if ($env.NODE_PATH | is-empty) { 
    "/opt/homebrew/lib/node_modules" 
} else { 
    $"/opt/homebrew/lib/node_modules:($env.NODE_PATH)" 
}

# For Powerlevel10k-like prompt, you'll need to use Nushell's prompt customization
# Nushell has its own prompt system that's different from zsh/p10k
# Check https://www.nushell.sh/book/customizing_prompts.html
