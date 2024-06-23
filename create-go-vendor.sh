 #!/bin/bash

version=$1
source='a'

[ -z "${version}" ] && read -p 'version: ' version

rm -rf a b
[ -f "v${version}.tar.gz" ] && tar -xzf v${version}.tar.gz
[ -f "netdata-v${version}.tar.gz" ] && tar -xzf netdata-v${version}.tar.gz
if [ ! -d "netdata-v${version}" ]
then
  echo "Error: Archive is not extracted or archive is corrupted"
  exit 1
fi
mv netdata-v${version} a

pushd a/src/go/collectors/go.d.plugin/

sed -i -e '/github.com\/ilyam8\/hashstructure v1.1.0 /s/h1.*$/h1:o3hpiGa1yergDO4AlUVBJGNvCEeaD+Ynu0OWYxee0iA=/' go.sum
go mod vendor
retval=$?
if [ ${retval} -ne 0 ]
then
  echo -e "\033[1;31mError: Cannot get all go modules. Vendor archive of sources will not be created !!!\033[0m"
else
  tar -cJf ../../../../../go.d.plugin-vendor-${version}.tar.xz vendor
fi
popd
rm -rf a 
exit ${retval}
