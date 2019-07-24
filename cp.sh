#!/bin/sh

set -e

params=""
src=""
dst=""

# collect params, src and dst
for arg in $@; do
  if [ "$(echo $arg | cut -c1-1)" = "-" ]; then
    params="$params $arg"
  else
    src="$src $dst"
    dst="$arg"
  fi
done

show_progress() {
  if [ ! -e "$src" ]; then
    return
  fi

  local bar="########################################"
  local src_size=$(du -s -c $src | tail -1 | cut -f1)
  local dst="$dst"

  # make sure dst is the target folder/file
  if [ -e "$dst" ]; then
    dst="$dst/$(basename $src)"
  fi

  while :
  do
    if [ -e "$dst" ]; then

      local beg=$(date +%s)
      local dst_size=$(du -s $dst | cut -f1)
      local end=$(date +%s)

      local pc=$((((1 + dst_size) * 100) / (1 + src_size)))
      local bar_len=$((pc * ${#bar} / 100))

      # show progress with bar and in %
      printf "\r[%-${#bar}s] %d%%" $(expr substr $bar 1 $bar_len) $pc

      # wait at least as long as the `du` command took
      sleep $((1 + end - beg))
    else
      printf "A\n"
      sleep 1
    fi
  done
}

show_progress &
PID=$!

# kill show_progress
finish() {
  kill -9 $PID 2> /dev/null
}

trap finish INT TERM EXIT

cp $params $src $dst

printf "\r[$bar] 100%\n"
finish
