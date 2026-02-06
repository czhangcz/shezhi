# Fix Warp tmpdir permission issue: only override when in Warp Terminal
if set -q WARP_TERMINAL_VERSION
    # Running inside Warp Terminal
    set -gx TMPDIR /tmp
    set -gx WARP_USE_SSH_WRAPPER 0
end
set -gx TMPDIR /tmp
set -gx WARP_USE_SSH_WRAPPER 0

if status is-interactive
    # Commands to run in interactive sessions can go here

    # Add paths to PATH
    fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/local/bin $HOME/local/lib/flutter/bin

    # starship prompt
    starship init fish | source

    # atuin
    set -gx ATUIN_NOBIND "true"
    atuin init fish | source
    # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search

    pyenv init - | source
    pyenv virtualenv-init - | source 

    set -gx EDITOR vim


    if test (uname) = Darwin
        set -gx SDKROOT (xcrun --show-sdk-path)
        set -gx CPATH (xcrun --show-sdk-path)/usr/include
        set -gx LIBRARY_PATH (xcrun --show-sdk-path)/usr/lib
        set -gx CXXFLAGS "-stdlib=libc++ -I"(xcrun --show-sdk-path)"/usr/include/c++/v1"
    end
end

alias claude="$HOME/.claude/local/claude"
