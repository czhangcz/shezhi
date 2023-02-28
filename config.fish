if status is-interactive
    # Commands to run in interactive sessions can go here

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
end
