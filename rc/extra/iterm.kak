# https://www.iterm2.com
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

## The default behaviour for the `new` command is to open an vertical pane in
## an iTerm session if not in a tmux session.
hook global KakBegin .* %sh{
    if [ "$TERM_PROGRAM" = "iTerm.app" ] && [ -z "$TMUX" ]; then
        echo "
            alias global new iterm-new-vertical
            alias global focus iterm-focus
        "
    fi
}

define-command -hidden -params 2 iterm-terminal-split-impl %{
    nop %sh{
        direction="$1"
        cmd="env PATH='${PATH}' TMPDIR='${TMPDIR}' sh -c '$2'"
        osascript                                                                             \
        -e "tell application \"iTerm\""                                                       \
        -e "    tell current session of current window"                                       \
        -e "        tell (split ${direction} with same profile command \"${cmd}\") to select" \
        -e "    end tell"                                                                     \
        -e "end tell" >/dev/null
    }
}

define-command iterm-terminal-vertical -params 1 -shell-completion -docstring '
iterm-terminal-vertical <program>: create a new terminal as an iterm pane
The current pane is split into two, top and bottom
The shell program passed as argument will be executed in the new terminal'\
%{
    iterm-terminal-split-impl 'vertically' %arg{1}
}
define-command iterm-terminal-horizontal -params 1 -shell-completion -docstring '
iterm-terminal-horizontal <program>: create a new terminal as an iterm pane
The current pane is split into two, left and right
The shell program passed as argument will be executed in the new terminal'\
%{
    iterm-terminal-split-impl 'horizontally' %arg{1}
}

define-command iterm-terminal-tab -params 1 -shell-completion -docstring '
iterm-terminal-tab <program>: create a new terminal as an iterm tab
The shell program passed as argument will be executed in the new terminal'\
%{
    nop %sh{
        cmd="env PATH='${PATH}' TMPDIR='${TMPDIR}' sh -c '$1'"
        osascript                                                       \
        -e "tell application \"iTerm\""                                 \
        -e "    tell current window"                                    \
        -e "        create tab with default profile command \"${cmd}\"" \
        -e "    end tell"                                               \
        -e "end tell" >/dev/null
    }
}

define-command iterm-terminal-window -params 1 -shell-completion -docstring '
iterm-terminal-window <program>: create a new terminal as an iterm window
The shell program passed as argument will be executed in the new terminal'\
%{
    nop %sh{
        cmd="env PATH='${PATH}' TMPDIR='${TMPDIR}' sh -c '$1'"
        osascript                                                      \
        -e "tell application \"iTerm\""                                \
        -e "    create window with default profile command \"${cmd}\"" \
        -e "end tell" >/dev/null
    }
}

define-command iterm-new-vertical -params .. -command-completion -docstring '
iterm-new-vertical <program>: create a new kakoune client as an iterm pane
The current pane is split into two, top and bottom
The optional arguments are passed as commands to the new client' \
%{
    iterm-terminal-vertical "kak -c %val{session} -e '%arg{@}'"
}
define-command iterm-new-horizontal -params .. -command-completion -docstring '
iterm-new-horizontal <program>: create a new kakoune client as an iterm pane
The current pane is split into two, left and right
The optional arguments are passed as commands to the new client' \
%{
    iterm-terminal-horizontal "kak -c %val{session} -e '%arg{@}'"
}
define-command iterm-new-tab -params .. -command-completion -docstring '
iterm-new-tab <program>: create a new kakoune client as an iterm tab
The optional arguments are passed as commands to the new client' \
%{
    iterm-terminal-tab "kak -c %val{session} -e '%arg{@}'"
}
define-command iterm-new-window -params .. -command-completion -docstring '
iterm-new-window <program>: create a new kakoune client as an iterm window
The optional arguments are passed as commands to the new client' \
%{
    iterm-terminal-window "kak -c %val{session} -e '%arg{@}'"
}

define-command iterm-focus -params ..1 -client-completion -docstring '
iterm-focus [<client>]: focus the given client
If no client is passed then the current one is used' \
%{
    evaluate-commands %sh{
        if [ $# -eq 1 ]; then
            printf %s\\n "evaluate-commands -client '$1' focus"
        else
            session="${kak_client_env_ITERM_SESSION_ID#*:}"
            osascript                                                      \
            -e "tell application \"iTerm\" to repeat with aWin in windows" \
            -e "    tell aWin to repeat with aTab in tabs"                 \
            -e "        tell aTab to repeat with aSession in sessions"     \
            -e "            tell aSession"                                 \
            -e "                if (unique id = \"${session}\") then"      \
            -e "                    select"                                \
            -e "                end if"                                    \
            -e "            end tell"                                      \
            -e "        end repeat"                                        \
            -e "    end repeat"                                            \
            -e "end repeat"
        fi
    }
}
