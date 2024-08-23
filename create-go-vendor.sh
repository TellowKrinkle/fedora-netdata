 #!/bin/bash

source='a'

version=$(rpmspec -P netdata.spec | grep -i '^version' | awk -F ':' '{print $2}' | tr -d ' ')
[ -z "${version}" ] && read -p 'version: ' version

[ -d a ] && rm -rf a
[ -f "v${version}.tar.gz" ] && tar -xzf v${version}.tar.gz
[ -f "netdata-v${version}.tar.gz" ] && tar -xzf netdata-v${version}.tar.gz
if [ ! -d "netdata-v${version}" ]
then
  echo "Error: Archive is not extracted or archive is corrupted"
  exit 1
fi
mv netdata-v${version} a

pushd a/src/go 1>/dev/null 2>&1

go env -w GOPROXY=https://proxy.golang.org,direct
go mod vendor
retval=$?
if [ ${retval} -ne 0 ]
then
  echo -e "\033[1;31mError: Cannot get all go modules. Vendor archive of sources will not be created !!!\033[0m"
else
  tar -czf ../../../go.d.plugin-vendor-${version}.tar.gz vendor
  echo "Create go.d.plugin-vendor-${version}.tar.gz"
fi
popd 1>/dev/null 2>&1
rm -rf a
exit ${retval}
