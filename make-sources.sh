#!/bin/bash


version=$(rpmspec -P netdata.spec | grep -i '^version' | awk -F ':' '{print $2}' | tr -d ' ')
[ -z "${version}" ] && read -p 'version: ' version
url="https://github.com/netdata/netdata/releases/download/v${version}/netdata-v${version}.tar.gz"

filename=$(basename ${url})
[ ! -f ${filename} ] && curl -fsSLO ${url}

source="netdata-v${version}"
dest="netdata-${version}"
[ -d "${source}" ] && rm -rf ${source}
[ -d "${dest}" ] && rm -rf ${dest}

[ -f "v${version}.tar.gz" ] && tar -xzf v${version}.tar.gz
[ -f "netdata-v${version}.tar.gz" ] && tar -xzf netdata-v${version}.tar.gz
if [ ! -d "netdata-v${version}" ]
then
  echo "Error: Archive is not extracted or corrupted"
  exit 1
fi
mv ${source} ${dest}
rm -rf ${dest}/src/web/gui/v2 ${dest}/src/web/gui/index.html
tar -czf ${dest}.tar.gz ${dest}
rm -rf ${dest}

echo "Create ${dest}.tar.gz"
