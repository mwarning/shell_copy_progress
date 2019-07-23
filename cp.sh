#!/bin/sh

set -e

params=""
src=""
dst=""

for arg in $@; do
  if [ "$(echo $arg | cut -c1-1)" = "-" ]; then
  	params="$params $arg"
  elif [ -z "$src" ]; then
  	src="$arg"
  elif [ -z "$dst" ]; then
	dst="$arg"
  else
  	echo "Too many parameters."
  	exit 1
  fi
done

get_size() {
	du -s $1 | cut -f1
}

show_progress() {
	if [ ! -e "$src" ]; then
		return
	fi

	local src_size=$(get_size $src)
	while :
	do
		if [ -e "$dst" ]; then
			local beg=$(date +%s)
			local dst_size=$(get_size $dst)
			local end=$(date +%s)
			local delay=$((1 + end - beg))
			local progress=$((((1 + dst_size) * 100) / (1 + src_size)))

			printf "\r%d%%" $progress
			sleep $delay
		else
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

cp $params "$src" "$dst"

printf "\r100%% - done\n"
finish
