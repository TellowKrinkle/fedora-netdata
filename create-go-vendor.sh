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
if [ $? -ne 0 ]
then
  echo "Error: Cannot get all go modules"
  exit 1
fi
tar -cJf ../../../../../go.d.plugin-vendor-${version}.tar.xz vendor
popd
rm -rf a
