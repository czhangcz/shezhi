local wezterm = require "wezterm"
local act = wezterm.action

local ubuntu2204 = {"C:\\Windows\\System32\\wsl.exe", "-d", "Ubuntu-22.04"}
local wsl_domains = wezterm.default_wsl_domains()

for _, dom in ipairs(wsl_domains) do
    dom.default_cwd = "~"
end

mykeys = {
    {
        key = "F3",
        action = "ShowLauncher",
    },
}

for i = 1, 9 do
    -- CTRL+ALT + number to activate that tab
    table.insert(mykeys, {
      key = tostring(i),
      mods = 'CTRL',
      action = act.ActivateTab(i - 1),
    })
    -- F1 through F8 to activate that tab
    -- table.insert(mykeys, {
    --   key = 'F' .. tostring(i),
    --   action = act.ActivateTab(i - 1),
    -- })
end

return {
    color_scheme = "Dracula",
    wsl_domains = wsl_domains,
    default_domain = "WSL:Ubuntu-22.04",    
    default_prog = { "wsl.exe" },

    keys = mykeys,
    ssh_domains = {
        {
            name = "RPI",
            remote_address = "192.168.2.5",
            username = "pi",
        }
    },

    font_size = 10.0,
    font_dirs = {"C:\\Windows\\Fonts"},
    font_rules = {
        {
            italic = false,
            bold = false,
            font = wezterm.font("DejaVu Sans Mono"),
        },
        {
            italic = true,
            bold = false,
            font = wezterm.font("DejaVu Sans Mono Oblique"),
        },
        {
            italic = false,
            bold = true,
            font = wezterm.font("DejaVu Sans Mono Bold"),
        },
        {
            italic = true,
            bold = true,
            font = wezterm.font("DejaVu Sans Mono Bold Oblique"),
        },
    },

    launch_menu = {
        {
            label = "Ubuntu WSL",
            args = {"wsl", "-d", "Ubuntu-22.04"},
        },
        {
            label = "Powershell",
            args = {"powershell"},
        },
        {
            label = "Cmd",
            args = {"cmd"},
        },
    },
}
