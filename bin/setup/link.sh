#!/bin/bash
cd `dirname $0` # scriptの位置に移動
cd `pwd -P` # symlinkを無視した位置に移動
cd ../../ # 2つ上がる = dotfilesの位置に移動

src_dir=`pwd -P`

# マシンを選択
if [ $# -eq 0 ]; then
  home=$HOME
else
  home=$1
fi

link_etc_files () {
  source_dir=$1
  dest_dir=$2

  files=$(ls -a $source_dir| grep -vE "^\.{1,2}$")
  for file in $files
  do
    if [[ $file =~ \.template ]] ; then
      place_template_file "$source_dir/$file" $dest_dir
    else
      ln -nfs "$source_dir/$file" $dest_dir
    fi
  done
}

place_template_file () {
  template_file=$1
  dest_dir=$2

  template_file_name=$(basename $template_file)
  file_name=$(echo $template_file_name|perl -pe "s/\.template//g")

  if [ -e $dest_dir/$file_name ]; then
    return
  fi

  fulltext=`cat $template_file`
  replaces=`cat $template_file | grep -Eo __.*__`

  echo "Create $filename"

  for replace in $replaces; do
    echo -n " $replace > "
    read value
    value=${value/@/\\@}
    fulltext=`echo "$fulltext"|perl -pe "s/$replace/$value/g"`
  done
  echo "$fulltext" > $dest_dir/$file_name
}

# bin
ln -nfs "$src_dir/bin" $home

# etc
link_etc_files "$src_dir/etc" $home

# config
config_dir="$src_dir/config"

mkdir -p "$home/.config"
mkdir -p "$home/.config/coc"

ln -fs "$config_dir/coc/ultisnips" "$home/.config/coc/"
ln -fs "$config_dir/alacritty" "$home/.config/"
ln -fs "$config_dir/karabiner" "$home/.config/"
ln -fs "$config_dir/kitty" "$home/.config/"
ln -fs "$config_dir/nvim" "$home/.config/"
ln -fs "$config_dir/ghostty" "$home/.config/"
ln -fs "$config_dir/vscode/mcp.json" "$home/Library/Application Support/Claude/claude_desktop_config.json"
ln -fs "$config_dir/vscode/mcp.json" "$home/.cursor/"

# vim
# ln -fs "$config_dir/nvim" "$home/.vim"
# ln -fs "$config_dir/nvim/init.vim" "$home/.vimrc"

if [ "$(uname)" == 'Darwin' ]; then
  # link dropbox dir to home
  ln -sf ${HOME}/Dropbox/.ssh ${HOME}/
  ln -sf ${HOME}/Dropbox/アプリ/.hammerspoon ${HOME}/
  ln -sf ${HOME}/Dropbox/アプリ/iTerm2/AutoLaunch ${HOME}/Library/ApplicationSupport/iTerm2/Scripts/
  # ln -sf ${HOME}/Dropbox/VSCode/User ${HOME}/Library/Application\ Support/Code/
fi
