# For more information on defining custom themes, see
# https://www.nushell.sh/book/coloring_and_theming.html
# And here is the theme collection
# https://github.com/nushell/nu_scripts/tree/main/themes
let dark_theme = {
    # color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    # Closures can be used to choose colors for specific values.
    # The value (in this case, a bool) is piped into the closure.
    # eg) {|| if $in { light_cyan } else { light_gray } }
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: { bg: red fg: white }
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_external_resolved: light_yellow_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: white bg: red attr: b }
    shape_glob_interpolation: cyan_bold
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
    shape_raw_string: light_purple
}

let light_theme = {
    # color for nushell primitives
    separator: dark_gray
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    # Closures can be used to choose colors for specific values.
    # The value (in this case, a bool) is piped into the closure.
    # eg) {|| if $in { dark_cyan } else { dark_gray } }
    bool: dark_cyan
    int: dark_gray
    filesize: cyan_bold
    duration: dark_gray
    date: purple
    range: dark_gray
    float: dark_gray
    string: dark_gray
    nothing: dark_gray
    binary: dark_gray
    cell-path: dark_gray
    row_index: green_bold
    record: dark_gray
    list: dark_gray
    block: dark_gray
    hints: dark_gray
    search_result: { fg: white bg: red }
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_external_resolved: light_purple_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: white bg: red attr: b }
    shape_glob_interpolation: cyan_bold
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
    shape_raw_string: light_purple
}

# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false # true or false to enable or disable the welcome banner at startup

    ls: {
        use_ls_colors: true # use the LS_COLORS environment variable to colorize output
        clickable_links: true # enable or disable clickable links. Your terminal has to support links.
    }

    rm: {
        always_trash: false # always act as if -t was given. Can be overridden with -p
    }

    table: {
        mode: compact # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: auto # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
        show_empty: true # show empty list and empty record placeholders for command output
        padding: { left: 1, right: 1 } # a left right padding of each column in a table
        trim: {
            methodology: wrapping # wrapping or truncating
            wrapping_try_keep_words: true # A strategy used by the wrapping methodology
            truncating_suffix: "..." # A suffix used by the truncating methodology
        }
        header_on_separator: false # show header text on separator/border line
        footer_inheritance: false # render footer in parent table if child is big enough (extended table option)
        # abbreviated_row_count: 10 # limit data rows from top and bottom after reaching a set point
    }

    error_style: "fancy" # "fancy" or "plain" for screen reader-friendly error messages

    # Whether an error message should be printed if an error of a certain kind is triggered.
    display_errors: {
        exit_code: false # assume the external command prints an error message
        # Core dump errors are always printed, and SIGPIPE never triggers an error.
        # The setting below controls message printing for termination by all other signals.
        termination_signal: true
    }

    # datetime_format determines what a datetime rendered in the shell would look like.
    # Behavior without this configuration point will be to "humanize" the datetime display,
    # showing something like "a day ago."
    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z'  # shows up in displays of variables or other datetimes outside of tables
        table: '%d %M %y %H:%M:%S'         # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
    }

    explore: {
        status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" },
        command_bar_text: { fg: "#C4C9C6" },
        highlight: { fg: "black", bg: "yellow" },
        status: {
            error: { fg: "white", bg: "red" },
            warn: {}
            info: {}
        },
        selected_cell: { bg: light_blue },
    }

    history: {
        max_size: 100_000 # Session has to be reloaded for this to take effect
        sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
        file_format: "plaintext" # "sqlite" or "plaintext"
        isolation: false # only available with sqlite file_format. true enables history isolation, false disables it. true will allow the history to be isolated to the current session using up/down arrows. false will allow the history to be shared across all sessions.
    }

    completions: {
        case_sensitive: false # set to true to enable case-sensitive completions
        quick: true    # set this to false to prevent auto-selecting completions when only one remains
        partial: true    # set this to false to prevent partial filling of the prompt
        algorithm: "prefix"    # prefix or fuzzy
        sort: "smart" # "smart" (alphabetical for prefix matching, fuzzy score for fuzzy matching) or "alphabetical"
        external: {
            enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
            max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
            completer: null # check carapace_completer above as an example
        }
        use_ls_colors: true # set this to true to enable file/path/directory completions using LS_COLORS
    }

    filesize: {
        metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
        format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, auto
    }

    cursor_shape: {
        emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
        vi_insert: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
        vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
    }

    color_config: $dark_theme # if you want a more interesting theme, you can replace the empty record with `$dark_theme`, `$light_theme` or another custom record
    footer_mode: 25 # always, never, number_of_rows, auto
    float_precision: 2 # the precision for displaying floats in tables
    buffer_editor: null # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.VISUAL and $env.EDITOR
    use_ansi_coloring: true
    bracketed_paste: true # enable bracketed paste, currently useless on windows
    edit_mode: vi # emacs, vi
    shell_integration: {
        # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
        osc2: true
        # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
        osc7: true
        # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
        osc8: true
        # osc9_9 is from ConEmu and is starting to get wider support. Its similar to osc7 in that it communicates the path to the terminal
        osc9_9: false
        # osc133 is several escapes invented by Final Term which include the supported ones below.
        # 133;A - Mark prompt start
        # 133;B - Mark prompt end
        # 133;C - Mark pre-execution
        # 133;D;exit - Mark execution finished with exit code
        # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
        osc133: true
        # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
        # 633;A - Mark prompt start
        # 633;B - Mark prompt end
        # 633;C - Mark pre-execution
        # 633;D;exit - Mark execution finished with exit code
        # 633;E - Explicitly set the command line with an optional nonce
        # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
        # and also helps with the run recent menu in vscode
        osc633: true
        # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
        reset_application_mode: true
    }
    render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
    use_kitty_protocol: true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
    highlight_resolved_externals: false # true enables highlighting of external commands in the repl resolved by which.
    recursion_limit: 50 # the maximum number of times nushell allows recursion before stopping it

    plugins: {} # Per-plugin configuration. See https://www.nushell.sh/contributor-book/plugins.html#configuration.

    plugin_gc: {
        # Configuration for plugin garbage collection
        default: {
            enabled: true # true to enable stopping of inactive plugins
            stop_after: 10sec # how long to wait after a plugin is inactive to stop it
        }
        plugins: {
            # alternate configuration for specific plugins, by name, for example:
            #
            # gstat: {
            #     enabled: false
            # }
        }
    }

    hooks: {
        pre_prompt: [{ null }] # run before the prompt is shown
        pre_execution: [{ null }] # run before the repl input is run
        env_change: {
            PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline
        command_not_found: { null } # return an error message when a command is not found
    }

    menus: [
        # Configuration for default nushell menus
        # Note the lack of source parameter
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: ide_completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: ide
                min_completion_width: 0,
                max_completion_width: 50,
                max_completion_height: 10, # will be limited by the available lines in the terminal
                padding: 0,
                border: true,
                cursor_offset: 0,
                description_mode: "prefer_right"
                min_description_width: 0
                max_description_width: 50
                max_description_height: 10
                description_offset: 1
                # If true, the cursor pos will be corrected, so the suggestions match up with the typed text
                #
                # C:\> str
                #      str join
                #      str trim
                #      str split
                correct_cursor_pos: false
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]

    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: completion_previous_menu
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
        }
        {
            name: ide_completion_menu
            modifier: control
            keycode: space
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: ide_completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: help_menu }
        }
        {
            name: next_page_menu
            modifier: control
            keycode: char_x
            mode: emacs
            event: { send: menupagenext }
        }
        {
            name: undo_or_previous_page_menu
            modifier: control
            keycode: char_z
            mode: emacs
            event: {
                until: [
                    { send: menupageprevious }
                    { edit: undo }
                ]
            }
        }
        {
            name: escape
            modifier: none
            keycode: escape
            mode: [emacs, vi_normal, vi_insert]
            event: { send: esc }    # NOTE: does not appear to work
        }
        {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
        }
        {
            name: quit_shell
            modifier: control
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrld }
        }
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: { send: clearscreen }
        }
        {
            name: search_history
            modifier: control
            keycode: char_q
            mode: [emacs, vi_normal, vi_insert]
            event: { send: searchhistory }
        }
        {
            name: open_command_editor
            modifier: control
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: openeditor }
        }
        {
            name: move_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: move_down
            modifier: none
            keycode: down
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: move_left
            modifier: none
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuleft }
                    { send: left }
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: none
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { send: menuright }
                    { send: right }
                ]
            }
        }
        {
            name: move_one_word_left
            modifier: control
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movewordleft }
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: control
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintwordcomplete }
                    { edit: movewordright }
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: none
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: char_a
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: none
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { edit: movetolineend }
                ]
            }
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: control
            keycode: char_e
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { edit: movetolineend }
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_end
            modifier: control
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolineend }
        }
        {
            name: move_down
            modifier: control
            keycode: char_n
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: move_up
            modifier: control
            keycode: char_p
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: delete_one_character_backward
            modifier: none
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspace }
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: delete_one_character_forward
            modifier: none
            keycode: delete
            mode: [emacs, vi_insert]
            event: { edit: delete }
        }
        {
            name: delete_one_character_forward
            modifier: control
            keycode: delete
            mode: [emacs, vi_insert]
            event: { edit: delete }
        }
        {
            name: delete_one_character_backward
            modifier: control
            keycode: char_h
            mode: [emacs, vi_insert]
            event: { edit: backspace }
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: move_left
            modifier: none
            keycode: backspace
            mode: vi_normal
            event: { edit: moveleft }
        }
        {
            name: newline_or_run_command
            modifier: none
            keycode: enter
            mode: emacs
            event: { send: enter }
        }
        {
            name: move_left
            modifier: control
            keycode: char_b
            mode: emacs
            event: {
                until: [
                    { send: menuleft }
                    { send: left }
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: control
            keycode: char_f
            mode: emacs
            event: {
                until: [
                    { send: historyhintcomplete }
                    { send: menuright }
                    { send: right }
                ]
            }
        }
        {
            name: redo_change
            modifier: control
            keycode: char_g
            mode: emacs
            event: { edit: redo }
        }
        {
            name: undo_change
            modifier: control
            keycode: char_z
            mode: emacs
            event: { edit: undo }
        }
        {
            name: paste_before
            modifier: control
            keycode: char_y
            mode: emacs
            event: { edit: pastecutbufferbefore }
        }
        {
            name: cut_word_left
            modifier: control
            keycode: char_w
            mode: emacs
            event: { edit: cutwordleft }
        }
        {
            name: cut_line_to_end
            modifier: control
            keycode: char_k
            mode: emacs
            event: { edit: cuttolineend }
        }
        {
            name: cut_line_from_start
            modifier: control
            keycode: char_u
            mode: emacs
            event: { edit: cutfromstart }
        }
        {
            name: swap_graphemes
            modifier: control
            keycode: char_t
            mode: emacs
            event: { edit: swapgraphemes }
        }
        {
            name: move_one_word_left
            modifier: alt
            keycode: left
            mode: emacs
            event: { edit: movewordleft }
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: right
            mode: emacs
            event: {
                until: [
                    { send: historyhintwordcomplete }
                    { edit: movewordright }
                ]
            }
        }
        {
            name: move_one_word_left
            modifier: alt
            keycode: char_b
            mode: emacs
            event: { edit: movewordleft }
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: char_f
            mode: emacs
            event: {
                until: [
                    { send: historyhintwordcomplete }
                    { edit: movewordright }
                ]
            }
        }
        {
            name: delete_one_word_forward
            modifier: alt
            keycode: delete
            mode: emacs
            event: { edit: deleteword }
        }
        {
            name: delete_one_word_backward
            modifier: alt
            keycode: backspace
            mode: emacs
            event: { edit: backspaceword }
        }
        {
            name: delete_one_word_backward
            modifier: alt
            keycode: char_m
            mode: emacs
            event: { edit: backspaceword }
        }
        {
            name: cut_word_to_right
            modifier: alt
            keycode: char_d
            mode: emacs
            event: { edit: cutwordright }
        }
        {
            name: upper_case_word
            modifier: alt
            keycode: char_u
            mode: emacs
            event: { edit: uppercaseword }
        }
        {
            name: lower_case_word
            modifier: alt
            keycode: char_l
            mode: emacs
            event: { edit: lowercaseword }
        }
        {
            name: capitalize_char
            modifier: alt
            keycode: char_c
            mode: emacs
            event: { edit: capitalizechar }
        }
        # The following bindings with `*system` events require that Nushell has
        # been compiled with the `system-clipboard` feature.
        # If you want to use the system clipboard for visual selection or to
        # paste directly, uncomment the respective lines and replace the version
        # using the internal clipboard.
        {
            name: copy_selection
            modifier: control_shift
            keycode: char_c
            mode: emacs
            event: { edit: copyselection }
            # event: { edit: copyselectionsystem }
        }
        {
            name: cut_selection
            modifier: control_shift
            keycode: char_x
            mode: emacs
            event: { edit: cutselection }
            # event: { edit: cutselectionsystem }
        }
        # {
        #     name: paste_system
        #     modifier: control_shift
        #     keycode: char_v
        #     mode: emacs
        #     event: { edit: pastesystem }
        # }
        {
            name: select_all
            modifier: control_shift
            keycode: char_a
            mode: emacs
            event: { edit: selectall }
        }
    ]
}

# Set various environment variables
$env.XDG_CONFIG_HOME = $env.HOME + "/.config"
$env.CF = $env.XDG_CONFIG_HOME
$env.DOTN = $env.CF + "/nushell"
$env.RX = $env.CF + "/rx"
$env.NV = $env.HOME + "/.lua-is-the-devil"
$env.NOT = $env.HOME + "/notes"
$env.DX = $env.HOME + "/Documents"
$env.DN = $env.HOME + "/Downloads"
$env.SCS = $env.DX + "/webpage"
$env.SUSO = $env.HOME + "/sucias-social"

def cfdr [] {
   ^cd ~/.config;
  pwd
}

# History settings
let history_file = $env.HOME + "/.nushell_history"
$env.HISTORY_FILE = $history_file

def cdc [] {
    cd
    clear
}

# General Aliases
alias c = clear
alias c- = cd -
alias ctc = copy_file_contents_to_clipboard
def dt [] {
    date now | date format "+%F"
}
alias z = zoxide
alias e = exit 0
alias ex = expand
alias o = ^open
alias ffav = ffmpeg_remux_audio_video
alias sdd = spotify_dl
alias grep = grep --color=auto
alias ln = ln -i
alias mnf = ^mediainfo
alias o. = ^open .
alias ptc = paste_output_to_clipboard
alias nowrap = setterm --linewrap off
alias wrap = setterm --linewrap on

# Git Alias
alias gc = git commit -m 
alias gca = git commit -am 
alias gph = git push origin HEAD
alias gpu = git pull origin
alias gst = git status
alias glog = git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit
alias gadd = git add .

def gacp [$args] {
    git fetch
    git add .
    gca $args
    gph
}

alias va = ^nvim env.DOTN/config.nu
# Chezmoi Aliases
export alias ch = chezmoi
export alias chad = chezmoi add
export alias chap = chezmoi apply
export alias chd = chezmoi diff
export alias chda = chezmoi data
export alias chs = chezmoi status

# File Management Aliases
def bydate [] {
    $env.RX | path join "sort-file-by-date.sh" | run
}
alias d = fd -H -t f.DS_Store -X rm -frv
alias fdf = fd -tf -d 1 
alias f = fzf 
alias free = freespace
alias ft = fd_type
alias mia = move_ipa_to_target_directory
def --env mk [dir] {
    mkdir -v $dir;
}
def mtt [] {
    sudo rm -rfv /Volumes/*/.Trashes
    sudo rm -rfv $env.HOME/.Trash
}
alias rm = rm -rfv
alias srm = sudo rm -rfv
alias mkrx = create_script_and_open

# Torrent Management Aliases
alias mat = move_all_torrents
alias mnx = move_nix
alias mvb = move_btn_torrents
alias mvm = move_mam_torrents
alias mvp = move_ptp_torrents
alias mve = move_emp_torrents
alias mlf = move_repo_files_larger_than_99M
alias obt = open_btn_torrents_in_transmission
alias opt = open_ptp_torrents_in_deluge
alias odt = open_downloaded_torrents

# Blog Aliases
def blog [...args] {
    $env.RX | path join "blog.sh" | run $in ...$args
}
def epi [...args] {
    $env.RX | path join "blog.sh" | run $in "epi" ...$args
}
def feat [...args] {
    $env.RX | path join "blog.sh" | run $in "feat" ...$args
}

# Image Management Aliases
alias rsz50p = imagemagick_resize_50
alias rsz500 = imagemagick_resize_500
alias rsz720 = imagemagick_resize_720
alias coltxt = pick_color_fill_text
alias mpx = move_download_pix_to_pictures_dir
alias rpx = remove_pix
alias shave = imagemagick_shave
alias ytt = youtube_thumbnail

# Miscellaneous Aliases
alias clock = tty-clock -B -C 5 -c
def instadl [...args] {
    $env.RX | path join "igdn.sh" | run $in ...$args
}
alias or = ^open /Volumes/cold/ulto/
def oss [] {
    ^open -a ScreenSaverEngine
}
alias trv = trim_video
alias wst = wezterm cli set-tab-title 
alias zl = zellij

# eza (ls alternative)
alias ls = eza --color=always --icons --git 
alias la = ls -a --git
def ldn [] {
    ls $env.HOME/Downloads
}
alias lsd = ls -D
alias lsf = ls -f
alias lt = ls --tree --level=2
alias lta = ls --tree --level=3 --long --git
alias lx = ls -lbhHgUmuSa@
alias tree = tree_with_exclusions

# Directory Navigation Aliases
alias "..." = ../..
alias "...." = ../../..

# Brew Aliases
alias bi = brew install 
alias bl = brew list
alias bri = brew reinstall
alias brm = brew remove --zap
def bu [] {
    brew update
    brew upgrade
    brew cleanup
}
alias bci = brew install --cask 
alias bs = brew search 

# YouTube-DL
alias ytd = yt_dlp_download
alias ytx = yt_dlp_extract_audio
alias ytf = yt_dlp_extract_audio_from_file
alias yta = yt_dlp_download_with_aria2c

# Cargo Aliases
alias ci = cargo install 

# Nvim Aliases
alias v = nvim
alias vw = open_wezterm

# Rclone Aliases
alias rcm = rclone_move
alias rcc = rclone_copy
alias rdo = rclone_dedupe_old
alias rdn = rclone_dedupe_new

# Tmux Aliases
alias t = tmux
alias ta = tmux a -t 
alias tl = tmux ls
alias tn = tmux_new_sesh
alias tm = tmuxinator
alias ttmp = tmux new-session -A -s tmp

# ===========================
# Clipboard Functions
# ===========================
def copy_file_contents_to_clipboard [file_path: string] {
    if ($file_path | path exists) {
        cat $file_path ; pbcopy
        echo "٩(•̀ᴗ•́)و File contents copied to clipboard."
    } else {
        echo "┐(￣ヘ￣)┌  File not found. Please check the path is correct."
    }
}
def paste-to-file [filename: string] {
    if ($filename | is-empty) {
        echo "┐(￣ヘ￣)┌  paste-to-file <filename>"
        return
    }
    pbpaste ; append $filename
}

def paste_output_to_clipboard [command: string] {
    if ($command | is-empty) {
        echo "٩(•̀ᴗ•́)و  Copying command output to clipboard"
        return
    }
    eval $command ; pbpaste
}
# ===========================
# File Management Functions
# ===========================
let BACKUP_DIR = "/Volumes/armor/"

def move_repo_files_larger_than_99M [pwd_command: string] {
    let target_dir = $"($env.HOME)/jackpot"
    let files_to_move = (fd -tf -S +99M | lines)

    for file in $files_to_move {
        let filename = ($file | path basename)
        let target_path = $"($target_dir)/($file | path dirname)"
        mkdir $target_path
        mv $file $"($target_path)/($filename)"
    }
}

## Create and Open Script Files
def create_script_file [name: string] {
    let script_name = $"($name).sh"
    let script_file = $"($env.HOME)/.config/rx/($script_name)"

    if ($script_file | path exists) {
        echo "(눈︿눈)  Script file ($script_file) already exists."
        return
    }

    mkdir ($script_file | path dirname)
    $"#!/bin/zsh" | save $script_file
    chmod +x $script_file
}

def open_script_file_in_editor [name: string] {
    let script_name = $"($name).sh"
    let script_file = $"($env.HOME)/.config/rx/($script_name)"

    if (not ($script_file | path exists)) {
        echo "(눈︿눈)  Script file ($script_file) does not exist."
        return
    }

    nvim $script_file
}

def create_script_and_open [name: string] {
    create_script_file $name
    open_script_file_in_editor $name
}

## Move Files
def mvo [] { # move-iso-file from downloads to /Volumes/armor/iso/
    let source_dir = $env.DN
    let target_dir = "/Volumes/armor/iso/"

    if (not ($target_dir | path exists)) {
        echo "0_0 you tard, ($target_dir) does NOT exist"
        return
    }

    for ext in [iso dmg pkg] {
        let files = (glob $"($source_dir)/*.($ext)")
        if ($files | is-empty) {
            continue
        }
        $files | each { |file|
            mv $file $target_dir
            echo "( ⋂‿⋂) (($file | path basename)) made its way to ($target_dir)"
        }
    }
}

def move_nix [] {
    let source_dir = $env.DN
    let target_dir = $"($env.BACKUP_DIR)/iso/nix/"

    if (not ($target_dir | path exists)) {
        echo "0_0 you tard, ($target_dir) does NOT exist"
        return
    }

    let files = (glob $"($source_dir)/*.iso")
    if ($files | is-empty) {
        echo "No .iso files found in ($source_dir)"
        return
    }

    $files | each { |file|
        mv $file $target_dir
        echo "( ⋂‿⋂) (($file | path basename)) made its way to ($target_dir)"
    }
}

def move_download_pix_to_pictures_dir [] {
    let source_dir = $env.DN
    let target_dir = $"($env.HOME)/Pictures/"

    if (not ($target_dir | path exists)) {
        echo "0_0 you tard, ($target_dir) does NOT exist"
        return
    }

    for ext in [heic jpg jpeg png webp] {
        let files = (glob $"($source_dir)/*.($ext)")
        if ($files | is-empty) {
            continue
        }
        $files | each { |file|
            mv $file $target_dir
            echo "( ⋂‿⋂) (($file | path basename)) made its way to ($target_dir)"
        }
    }
}

def move_ipa_to_target_directory [] {
    let source_directory = $env.DN
    let target_directory = $"($env.BACKUP_DIR)/iso/ipa/"

    if (not ($target_directory | path exists)) {
        echo "0_0 you tard, ($target_directory) does NOT exist"
        return
    }

    let files = (glob $"($source_directory)/*.ipa")
    if ($files | is-empty) {
        echo "No .ipa files found in ($source_directory)"
        return
    }

    $files | each { |file|
        mv $file $target_directory
        echo "( ⋂‿⋂) (($file | path basename)) was moved to ($target_directory)"
    }
}

## Remove Files
def remove_pix [] {
    let old_dir = $env.PWD
    cd /Volumes/cold/ulto/
    fd -e jpg -e jpeg -e png -e webp -e nfo -e txt -x rm -v
    cd $old_dir
}

## Extract Archives
def expand [...filenames: string] {
    for filename in $filenames {
        if ($filename | path exists) {
            let extension = ($filename | path parse | get extension)
            let full_extension = if $extension == "gz" or $extension == "bz2" {
                $"tar.($extension)"
            } else {
                $extension
            }
            
            match $full_extension {
                "tar.bz2" => { run-external "tar" "xjf" $filename },
                "tar.gz" => { run-external "tar" "xzf" $filename },
                "bz2" => { run-external "bunzip2" $filename },
                "rar" => { run-external "unrar" "x" $filename },
                "gz" => { run-external "gunzip" $filename },
                "tar" => { run-external "tar" "xf" $filename },
                "tbz2" => { run-external "tar" "xjf" $filename },
                "tgz" => { run-external "tar" "xzf" $filename },
                "zip" => { run-external "unzip" $filename },
                "Z" => { run-external "uncompress" $filename },
                "7z" => { run-external "7z" "x" $filename },
                _ => { echo $"(눈︿눈) ($filename) cannot be extracted via ex()" }
            }
        } else {
            echo $"(눈︿눈) ($filename) is not found"
        }
    }
}

## Create and Navigate to Directory
def mkd [...dirs] {
    mkdir $dirs
    cd ($dirs | last)
}

## Backup and Restore Files

def bak [
    file: string,  # The file to backup or restore
    --ext: string = "bak",  # Custom backup extension (default: bak)
    --quiet(-q)  # Suppress output
] {
    if not ($file | path exists) {
        error make {msg: $"File '($file)' does not exist"}
    }

    let parsed = ($file | path parse)
    let filename = $parsed.stem
    let original_ext = $parsed.extension

    if $original_ext == $ext {
        let base_filename = ($filename | str replace -r $"[.]?($ext)$" "")
        let new_filename = ([$parsed.parent $base_filename] | path join)
        mv $file $new_filename
        if not $quiet { echo $"Removed .($ext) extension from '($file)'. New filename: '($new_filename)'" }
    } else {
        let new_filename = ([$parsed.parent $"($filename).($original_ext).($ext)"] | path join)
        if ($new_filename | path exists) {
            error make {msg: $"'($new_filename)' already exists."}
        } else {
            mv $file $new_filename
            if not $quiet { echo $"Appended .($ext) extension to '($file)'. New filename: '($new_filename)'" }
        }
    }
}

# ===========================
# Miscellaneous Functions
# ===========================

def timer [time: string] {
    ^termdown $time
    ^cvlc $"($env.HOME)/Music/ddd.mp3" --play-and-exit >/dev/null
}

# fd file(s) exclude dir then move to excluded dir
def fdd [pattern: string, dir: string] { ^fd -tf $pattern -E $dir -x mv {} $dir }

# fd file(s) and move-to-dir
def fdm [pattern: string, target_dir: string] { ^fd -tf -d 1 $pattern -x mv -v {} $target_dir }

def slug [filename: string] {
    if ($filename | is-empty) {
        echo "(￣ヘ￣)  slugifying <filename>"
        return 1
    }

    let slugified = (^slugify -atcdu $filename)
    echo $slugified
}

# Trim video from start to specified time, or copy without trimming if no start time is provided
def trv [
    input_file: string,
    output_file: string,
    --start(-s): duration,
    --end(-e): duration,
    --overwrite(-y)
] {
    if not ($input_file | path exists) {
        error make {msg: $"Input file '($input_file)' does not exist"}
    }

    mut args = [-i $input_file -c:v copy -c:a copy]

    if not ($start | is-empty) {
        $args = ($args | prepend [-ss $start])
    }

    if not ($end | is-empty) {
        $args = ($args | append [-to $end])
    }

    if $overwrite {
        $args = ($args | prepend [-y])
    }

    $args = ($args | append $output_file)

    let result = (^ffmpeg ...$args)

    if $result.exit_code != 0 {
        error make {msg: $"FFmpeg command failed: ($result.stderr)"}
    }

    echo $"Video processed successfully: '($output_file)'"
}

# Open Neovim configuration file in Neovim
def vm [] { nvim $"($env.HOME)/.lua-is-the-devil/nvim/init.lua" }

# Open WezTerm configuration file in Neovim
def vw [] { nvim $"($env.XDG_CONFIG_HOME)/wezterm.lua" }

# Open Nushell history file in Neovim
def vh [] { nvim $"($env.DOTN)/history.txt" }

# Open Nushell configuration file in Neovim
def vn [] { ^nvim $"($env.CF)/nushell/config.nu" }

def ffmpeg_remux_audio_video [input_file1: string, input_file2: string, output_file: string] {
    ^ffmpeg -i $input_file1 -i $input_file2 -c copy $output_file
}

def spotify_dl [url: string] {
    ^spotdl download $url
}

def mkv_to_mp4 [] {
    ls *.mkv | each { |f|
        let output_file = ($f.name | str replace '.mkv' '.mp4')
        ^ffmpeg -i $f.name -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k $output_file
    }
}
# ===========================
# ImageMagick Functions
# ===========================

def imagemagick_resize_50 [input_file: string, output_file: string] {
    ^magick $input_file -resize 50% $output_file
}

def imagemagick_resize_500 [input_file: string, output_file: string] {
    ^magick $input_file -resize 500 $output_file
}

def imagemagick_resize_720 [input_file: string, output_file: string] {
    ^magick $input_file -resize 720 $output_file
}

def imagemagick_shave [input_file: string, output_file: string, shave_args: string] {
    ^magick $input_file -shave $shave_args $output_file
}

def pick_color_fill_text [
    label: string,
    font: string,
    font_size: string,
    fill: string,
    filename: string,
    stroke?: string
] {
    if ($stroke | is-empty) {
        ^magick -background transparent -density 250 -pointsize $font_size -font $font -interline-spacing -15 -fill $fill -gravity center label:"$label" "$filename.png"
    } else {
        ^magick -background transparent -density 250 -pointsize $font_size -font $font -interline-spacing -15 -fill $fill -stroke $stroke -strokewidth 2 -gravity center label:"$label" "$filename.png"
    }
}

def youtube_thumbnail [
    label: string,
    filename: string,
    font?: string = "Arial-Black",
    template_img?: string = "$SCS/images/YT-thumbnail-template.png",
    output_dir?: string = "/Volumes/cold/sucias-pod-files/YT-thumbs",
    output_file?: string = "$output_dir/${filename}-thumb.png"
] {
    # Create temporary label image
    ^magick -background transparent -density 250 -pointsize 27 -font $font -interline-spacing -35 -fill gold -stroke magenta -strokewidth 2 -gravity center label:"$label" -rotate -12 $output_file

    # Composite label image with template and save final output
    ^magick composite -geometry +600+20 $output_file $template_img $output_file
}
# ===========================
# Git Functions
# ===========================

# def is_apple_silicon [] {
#     if ($env.CPU_ARCH == "arm64") {
#         return true
#     } else {
#         return false
#     }
# }
# def setup_ssh [] {
#     if ($env.SSH_AGENT_PID | is-empty) or (ps | where pid == $env.SSH_AGENT_PID | is-empty) {
#         eval (^ssh-agent -s)
#     }
# }
def git_pull [remote?: string, branch?: string] {
    setup_ssh
    let remote = if ($remote | is-empty) { "origin" } else { $remote }
    let branch = if ($branch | is-empty) { (^git rev-parse --abbrev-ref HEAD) } else { $branch }
    ^git pull --rebase -q $remote $branch
}

def git_push [remote?: string, branch?: string] {
    setup_ssh
    let remote = if ($remote | is-empty) { "origin" } else { $remote }
    let branch = if ($branch | is-empty) { (^git rev-parse --abbrev-ref HEAD) } else { $branch }
    ^git push -q $remote $branch
}

def git_add [] {
    ^git add.
}

def git_commit_message [message?: string] {
    if ($message | is-empty) {
        let today = (^date +%Y-%m-%d)
        let changed_files = (^git status --short | awk {print $2} | str join "\n")
        let message = $"$today\nChanged files:\n$changed_files"
    } else {
        let message = $message
    }

    ^git commit -m $message
    if (^git commit -m $message | is-error) {
        echo "(X︿x )  Failed to commit changes."
        return 1
    }
}

def check_git_status [repos] {
    for repo in $repos {
        if ($repo | path exists) {
            try {
                $repo
            } catch {
                continue }
            echo "Checking git status for $repo"
            ^git status
            try {
                cd -
            } catch {
                
            continue }
        } else {
            echo "Directory $repo does not exist"
        }
    }
}


def git_add_commit_push [message?: string] {
    git_add
    git_commit_message $message
    git_push
}
# ===========================
# Rclone functions
# ===========================

let base_opts = "-P --exclude-from $env.XDG_CONFIG_HOME/clear --fast-list"
let move_opts = "--delete-empty-src-dirs"
let new_dedupe = "--dedupe-mode newest"
let old_dedupe = "--dedupe-mode oldest"

# Define a function to execute rclone commands
def execute_rclone_command [
    command: string,
    source_dir: string,
    target_dir?: string,
    extra_opts?: string
] {
    if not ($source_dir | path exists) {
        echo "(눈︿눈)   Source file or directory $source_dir does not exist."
        return 1
    }

    ^rclone $command $base_opts $source_dir $target_dir $extra_opts
}

## Copy with rclone
# usage: rclone_copy <source_dir> <target_dir>
def rclone_copy [source_dir: string, target_dir: string] {
    execute_rclone_command "copy" $source_dir $target_dir
}

## Move with rclone
# usage: rclone_move <source_dir> <target_dir>
def rclone_move [source_dir: string, target_dir: string] {
    execute_rclone_command "move" $source_dir $target_dir $move_opts
}

## Dedupe with rclone keeping newest files
# usage: rclone_dedupe_new <source_dir>
def rclone_dedupe_new [source_dir: string] {
    execute_rclone_command "dedupe" $source_dir "--by-hash" $new_dedupe
}

## Dedupe with rclone keeping oldest files
# usage: rclone_dedupe_old <source_dir>
def rclone_dedupe_old [source_dir: string] {
    execute_rclone_command "dedupe" $source_dir "--by-hash" $old_dedupe
}
# ===========================
# Torrent Management Functions
# ===========================
if ( '/Volumes/kalisma/torrent' | path exists ) {
    let TORRENT_DIR = '/Volumes/kalisma/torrent'
    # Any other code that uses TORRENT_DIR
}
if ( '/Volumes/armor' | path exists ) {
    let BACKUP_DIR = '/Volumes/armor'
    # Any other code that uses BACKUP_DIR
}

let REPOS = [
  $"($env.HOME)/.dotfiles",
  $"($env.HOME)/.lua-is-the-devil",
  $"($env.HOME)/.noktados",
  $"($env.HOME)/Documents/widclub",
  $"($env.HOME)/notes"
]

## Open Torrent Files
def open_downloaded_torrents [] {
  ls $"($env.DN)/*.torrent" | each { |file| open $file.name }
  ^open -a wezterm
}

## Move Torrent Files
def move_torrents [source_dir: string, target_dir: string, pattern: string] {
  if not ($target_dir | path exists) {
    mkdir $target_dir
  }
  fd -e torrent $pattern --search-path $source_dir -X mv -v {} $target_dir
}

def move_emp_torrents [] {
  cd $env.DN
  fd -tf -e torrent "empornium" -x mv {} "/Volumes/kalisma/torrent/EMP/"
}

def move_mam_torrents [] {
    let torrent_dir = "/Volumes/kalisma/torrent/MAM/"
    let download_dir = $env.DN

    fd -e torrent --regex '\[[0-9]{5,6}\]' $download_dir -x mv {} $torrent_dir
}

def move_btn_torrents [] {
  let destination = "/Volumes/kalisma/torrent/BTN"
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "landof")
    if ($tracker_info | is-not-empty) {
      mv -v $file.name $destination
    }
  }
}

def open_btn_torrents_in_transmission [] {
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "landof")
    if ($tracker_info | is-not-empty) {
     ^open -a "Transmission" $file.name
    }
  }
}

def move_ptp_torrents [] {
  let destination = "/Volumes/kalisma/torrent/PTP"
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "passthepopcorn")
    if ($tracker_info | is-not-empty) {
      mv -v $file.name $destination
    }
  }
}

def open_ptp_torrents_in_deluge [] {
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "passthepopcorn")
    if ($tracker_info | is-not-empty) {
     ^open -a "Deluge" $file.name
    }
  }
}

def move_all_torrents [] {
  move_emp_torrents
  move_ptp_torrents
  move_mam_torrents
  move_btn_torrents
  ^open -a wezterm
}
# ===========================
# YouTube-DL Functions
# ===========================

def yt_dlp_download [...args: string] {
    ^yt-dlp --embed-chapters --no-warnings --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" -o "%(title)s.%(ext)s" $args
}

def yt_dlp_extract_audio [...args: string] {
    ^yt-dlp -x --audio-format "mp3/m4a" --audio-quality 0 --write-thumbnail --embed-metadata --concurrent-fragments 6 --yes-playlist -o "%(artist)s - %(title)s.%(ext)s" --ignore-errors --no-overwrites --continue $args
}

def yt_dlp_extract_audio_from_file (file_path: string) {
    # Create or clear the log file
    let log_file = "download_errors.log"
    open $log_file | each { |_| rm $log_file }

    # Read URLs from the specified file
    let urls = open $file_path | get 0

    # Iterate over each URL
    for $url in $urls {
        # Attempt to download audio using yt-dlp
        let result = run yt-dlp -x --audio-format "mp3/m4a" --audio-quality 0 --write-thumbnail --embed-metadata --concurrent-fragments 6 --yes-playlist -o "%(artist)s - %(title)s.%(ext)s" --ignore-errors --no-overwrites --continue $url

        # Check if the download was successful
        if ($result.status != 0) {
            # Log the URL if there was an error
            echo $url >> $log_file
        }
    }

    echo "Download complete. Check '$log_file' for any errors."
}

# Source this in your ~/.config/nushell/config.nu
$env.ATUIN_SESSION = (atuin uuid)
hide-env -i ATUIN_HISTORY_ID

# Magic token to make sure we don't record commands run by keybindings
let ATUIN_KEYBINDING_TOKEN = $"# (random uuid)"

let _atuin_pre_execution = {||
    if ($nu | get -i history-enabled) == false {
        return
    }
    let cmd = (commandline)
    if ($cmd | is-empty) {
        return
    }
    if not ($cmd | str starts-with $ATUIN_KEYBINDING_TOKEN) {
        $env.ATUIN_HISTORY_ID = (atuin history start -- $cmd)
    }
}

let _atuin_pre_prompt = {||
    let last_exit = $env.LAST_EXIT_CODE
    if 'ATUIN_HISTORY_ID' not-in $env {
        return
    }
    with-env { ATUIN_LOG: error } {
        do { atuin history end $'--exit=($last_exit)' -- $env.ATUIN_HISTORY_ID } | complete

    }
    hide-env ATUIN_HISTORY_ID
}

def _atuin_search_cmd [...flags: string] {
    let nu_version = do {
        let version = version
        let major = $version.major?
        if $major != null {
            # These members are only available in versions > 0.92.2
            [$major $version.minor $version.patch]
        } else {
            # So fall back to the slower parsing when they're missing
            $version.version | split row '.' | into int
        }
    }
    [
        $ATUIN_KEYBINDING_TOKEN,
        ([
            `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline) } {`,
                (if $nu_version.0 <= 0 and $nu_version.1 <= 90 { 'commandline' } else { 'commandline edit' }),
                (if $nu_version.1 >= 92 { '(run-external atuin search' } else { '(run-external --redirect-stderr atuin search' }),
                    ($flags | append [--interactive] | each {|e| $'"($e)"'}),
                (if $nu_version.1 >= 92 { ' e>| str trim)' } else {' | complete | $in.stderr | str substring ..-1)'}),
            `}`,
        ] | flatten | str join ' '),
    ] | str join "\n"
}

$env.config = ($env | default {} config).config
$env.config = ($env.config | default {} hooks)
$env.config = (
    $env.config | upsert hooks (
        $env.config.hooks
        | upsert pre_execution (
            $env.config.hooks | get -i pre_execution | default [] | append $_atuin_pre_execution)
        | upsert pre_prompt (
            $env.config.hooks | get -i pre_prompt | default [] | append $_atuin_pre_prompt)
    )
)

$env.config = ($env.config | default [] keybindings)

$env.config = (
    $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
            name: atuin
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: { send: executehostcommand cmd: (_atuin_search_cmd) }
        }
    )
)

$env.config = (
    $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
            name: atuin
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menuup}
                    {send: executehostcommand cmd: (_atuin_search_cmd '--shell-up-key-binding') }
                ]
            }
        }
    )
)

source ~/.config/nushell/env.nu
source ~/.zoxide.nu
source ~/.cache/carapace/init.nu
source ~/.local/share/atuin/init.nu
use ~/.cache/starship/init.nu
