#!/bin/sh

set -e

params=""
src=""
dst=""

# collect params, src and dst
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

show_progress() {
	if [ ! -e "$src" ]; then
		return
	fi

	local src_size=$(du -s $src | cut -f1)
	while :
	do
		if [ -e "$dst" ]; then
			local beg=$(date +%s)
			local dst_size=$(du -s $dst | cut -f1)
			local end=$(date +%s)

			# show progress in %
			printf "\r%d%%" $((((1 + dst_size) * 100) / (1 + src_size)))

			# wait at least as long as the `du` command took
			sleep $((1 + end - beg))
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
