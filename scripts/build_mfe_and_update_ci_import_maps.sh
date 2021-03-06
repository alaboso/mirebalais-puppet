#!/bin/bash

set -o xtrace  # print each command
set -e         # die on error

#=== Get package version number
app_version="$(node -e 'console.log(require("./package.json").version);')"
version="${app_version}.${bamboo_buildNumber}"

#=== Copy to distribution dir
# the repo name for the root config is pih-spa-frontend, so we need to override
directory_name=$(if [ "${bamboo_planRepository_name}" == "pih-spa-frontend" ];
                 then echo pih-esm-root-config;
                 else echo ${bamboo_planRepository_name};
                 fi)
parent_dir="/var/www/html/spa-repo/${directory_name}/unstable"
target_dir="${parent_dir}/${version}"
mkdir -p "${target_dir}"
cp -r dist/* "${target_dir}"
ls "${parent_dir}"

#=== Update latest/ symlink
rm -rf "${parent_dir}/latest"
ln -s ${target_dir} ${parent_dir}/latest

#=== Update import maps
package_name="$(node -e 'console.log(require("./package.json").name);')"
declare -A overrides
overrides["@pih/esm-root-config"]="@openmrs/esm-root-config"
package_name=${overrides["${package_name}"]:-${package_name}}
# we escape the colons in new_url since that will be our sed delimiter
new_url="https\://bamboo.pih-emr.org\:81/spa-repo/${directory_name}/unstable/${version}/${directory_name}.js"
for suffix in "ces" "zl"; do
    # using colon as delimiter because these variables are full of slashes
    sed -i "s:\"${package_name}\"\: \".*\":\"${package_name}\"\: \"${new_url}\":" "/var/www/html/spa-repo/import-map/import-map-ci-${suffix}.json"
done
