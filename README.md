# zsh-customization

These are my zsh settings and customizations. Will probably spend waaaaay too much time on that, but oh well...

## Installing

Installing this is super straight forward!

Make sure you have the following commands installed:

- `curl`
- `git`
- `route`
- `sudo` (if you install it globally)
- `zsh`

Then just run the install.sh:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BrainStone/zsh-customization/master/install.sh)"
```

### Set zsh as default shell

To set zsh as your default shell run:

```
chsh --shell "$(which zsh)"
```

## Font

This theme uses the special font of powerlevel10k.  
Follow these instructions to download and configure the font: https://github.com/romkatv/powerlevel10k/tree/21e89cb61d9ed240c1ddf6dd09ce306e7c9cf437#meslo-nerd-font-patched-for-powerlevel10k

## Special variables

All variables are considered active, when they are set and are not set to `false`, `no` or `0`.  
Every other value (including an empty string) considers the variable set:

| Value<br><small>(quotes are a visual help and are not part of the variables)</small> | Set? |
|--------------------------------------------------------------------------------------|------|
| `"true"`                                                                             | yes  |
| `""`                                                                                 | yes  |
| `"yes"`                                                                              | yes  |
| `"1"`                                                                                | yes  |
| `"banana"`                                                                           | yes  |
| \<variable not set\>                                                                 | no   |
| `"false"`                                                                            | no   |
| `"no"`                                                                               | no   |
| `"0"`                                                                                | no   |

If you want to persist these settings, it is recommended that you add this to your `~/.zshrc_local`:  
`export <variable>=true` to set or `export <variable>=false` to unset, though they all default to unset.

To temporarily try *setting* the variable (persists until you completely reopen the terminal):  
`<variable>=true exec zsh`

To temporarily try *unsetting* the variable (persists until you completely reopen the terminal):  
`<variable>=false exec zsh`

| Variable                   | Function                                  |
|----------------------------|-------------------------------------------|
| `ZSH_DISABLE_UPDATE_CHECK` | If set the theme won't check for updates. |
| `ZSH_FORCE_TTY`            | If set TTY mode is forced.                |
| `ZSH_NO_BASHRC`            | If set the bashrc will not be sourced.    | 
