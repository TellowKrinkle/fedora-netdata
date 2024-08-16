#!/bin/bash

source='a'
target='b'

version=$(rpmspec -P netdata.spec | grep -i '^version' | awk -F ':' '{print $2}' | tr -d ' ')
[ -z "${version}" ] && read -p 'version: ' version

[ -f "v${version}.tar.gz" ] && tar -xzf v${version}.tar.gz
[ -f "netdata-${version}.tar.gz" ] && tar -xzf netdata-${version}.tar.gz
[ -d a ] && rm -rf a
[ -d b ] && rm -rf b
if [ -d "netdata-${version}" ]
then
    mv netdata-${version} a
elif [ -d "netdata-v${version}" ]
then
    mv netdata-v${version} a
else
  echo "Error: Archive is not extracted or archive is corrupted"
  exit 1
fi

cp -a a b

pushd ${target}
for script in $(grep -R '/usr/bin/env bash' * | cut -d ':' -f1) $(grep -R '/usr/bin/env sh' * | cut -d ':' -f1)
do
  [ "$(basename ${script})" == "README.md" ] && continue
  echo ${script}
  sed -i -e '1s^env bash^bash^' -e '1s^env sh^sh^' ${script}
done
for script in $(grep -R '/usr/bin/env python' * | cut -d ':' -f1)
do
  [ "$(basename ${script})" == "README.md" ] && continue
  echo ${script}
  if [ "$(basename ${script})" == "boinc_client.py" ]
  then
    sed -i -e '1s^!/usr/bin/env python$^^' ${script}
  else
    sed -i -e '1s^env python$^python3^' ${script}
  fi
done
popd
cat << EOF > netdata-fix-shebang-${version}.patch
Fix shebang according to
https://docs.fedoraproject.org/en-US/packaging-guidelines/#_shebang_lines

EOF
patchver=$(echo ${version} | cut -d- -f1)
diff -rup a b >> netdata-fix-shebang-${patchver}.patch
#sed -e 's^/usr/bin/sh^/bin/sh^' -e 's^/usr/bin/bash^/bin/bash^' netdata-fix-shebang-${patchver}.patch > netdata-fix-shebang-${patchver}.el6.patch

rm -rf a b
