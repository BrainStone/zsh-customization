#! /usr/bin/env sh

# shellcheck disable=SC2016
git submodule foreach '
remote="$(git symbolic-ref refs/remotes/origin/HEAD --short)"
git switch -f -C "${remote##*/}" --track "${remote}"
'
