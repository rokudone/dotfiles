#!/bin/bash
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false              # For VS Code
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false      # For VS Code Insider
defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false         # For VS Codium
defaults write com.microsoft.VSCodeExploration ApplePressAndHoldEnabled -bool false   # For VS Codium Exploration users
# defaults delete -g ApplePressAndHoldEnabled                                           # If necessary, reset global default
#
if [ "$(uname)" == 'Darwin' ]; then
  ln -sf ~/projects/dotfiles/vscode/settings.json ~/Library/Application\ Support/Cursor/User
  ln -sf ~/projects/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Cursor/User
  ln -sf ~/projects/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User
  ln -sf ~/projects/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User
  ln -sf ~/projects/dotfiles/vscode/settings.json ~/Library/Application\ Support/Kiro/User
  ln -sf ~/projects/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Kiro/User
fi

cat ~/projects/dotfiles/vscode/extensions | while read line
do
 cursor --install-extension $line
done

cat ~/projects/dotfiles/vscode/extensions | while read line
do
 code --install-extension $line
done

cat ~/projects/dotfiles/vscode/extensions | while read line
do
 kiro --install-extension $line
done
