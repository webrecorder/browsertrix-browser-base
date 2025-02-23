#!/bin/bash
set -e

current_version=$(cat brave-version.txt)
latest_version=$(\
    curl -s https://api.github.com/repos/brave/brave-browser/releases/latest \
    | jq '.tag_name' \
    | sed -e 's/^"v//' -e 's/\"//')

echo "current version: $current_version"
echo "latest version:  $latest_version"

if [ "$current_version" == "$latest_version" ]; then
    echo "brave-version.txt is already up to date"
    exit 0
fi

latest_version_when_sorted=$(\
    printf "${latest_version}\n${current_version}" \
    | sort -V \
    | tail -n 1)

if [ "$latest_version_when_sorted" != "$latest_version" ]; then
    echo "current version is newer than latest version"
    exit 0
fi

release_http_status=$(\
    curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/brave/brave-browser/releases/tags/v${latest_version})

if [ "$release_http_status" != "200" ]; then
    echo "Release not found, Github API returned $release_http_status"
    exit 1
fi

echo "updating brave-version.txt to $latest_version"

echo $latest_version > brave-version.txt

git add brave-version.txt
git commit --author "Github Actions Webrecorder <info@webrecorder.net>" -m "version: brave version to ${latest_version}"
git push
