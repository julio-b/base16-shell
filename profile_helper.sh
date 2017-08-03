#!/usr/bin/env bash
if [ -s $BASH ]; then
    file_name=${BASH_SOURCE[0]}
elif [ -s $ZSH_NAME ]; then
    file_name=${(%):-%x}
fi
script_dir=$(cd $(dirname $file_name) && pwd)

. $script_dir/realpath/realpath.sh

if [ -f ~/.base16_theme ]; then
  script_name=$(basename $(realpath ~/.base16_theme) .sh)
  echo "export BASE16_THEME=${script_name}"
  echo ". ~/.base16_theme"
fi
cat <<'FUNC'
_base16()
{
  local script=$1
  local theme=$2
  [ -f $script ] && . $script
  ln -fs $script ~/.base16_theme
  export BASE16_THEME=${theme}
  echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$theme'\n  colorscheme base16-$theme\nendif" >| ~/.vimrc_background
  local TMPFILE=`mktemp -q /tmp/Xresources.XXXXXXXXXX` && ( [ -f $HOME/.config/base16-xresources/xresources/base16-$theme-256.Xresources ] \
   && (head -n -2 $HOME/.Xresources && echo -e "#include \".config/base16-xresources/xresources/base16-$theme-256.Xresources\"\n! vim:ft=xdefaults" ) > $TMPFILE \
   && cp $TMPFILE $HOME/.Xresources && xrdb $HOME/.Xresources ) || notify-send "Theme base16-$theme does not exist for Xresources"
  [ -x $HOME/.config/i3/scripts/update_color_theme.sh ] && ( $HOME/.config/i3/scripts/update_color_theme.sh \
   && (echo "`date`: Base16 theme reload " && i3-msg reload) >> $HOME/.config/i3/stdout) || notify-send "Theme base16-$theme does not exist for i3"
}
FUNC
for script in $script_dir/scripts/base16*.sh; do
  script_name=${script##*/}
  script_name=${script_name%.sh}
  theme=${script_name#*-}
  func_name="base16_${theme}"
  echo "alias $func_name=\"_base16 \\\"$script\\\" $theme\""
done;
