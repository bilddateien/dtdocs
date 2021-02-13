#!/usr/bin/env bash

# Adapted from https://gitlab.com/fdroid/fdroid-website/-/raw/master/tools/i18n.sh
# Requires po4a version 0.58 or higher.

set -e

if ! which po4a; then
    echo "ERROR: Missing po4a (apt-get install po4a)"
    exit 1
fi

# TODO: All the ruby does is compare the version; can't we do that in bash?
# version=$(po4a --version | sed -En 's,po4a version ([0-9][0-9.]+[0-9]).*,\1,p')
# if ruby -e "exit(Gem::Version.new('$version') < Gem::Version.new('0.58'))"; then
#     echo "ERROR: po4a v0.58 or higher required (try from backports)"
#     exit 1
# fi

PROJECT_ROOT=$(cd `dirname $0`/..; pwd)
cd ${PROJECT_ROOT}

# TODO: I don't understand what this does.
# if [ "$1" == "md2po" ]; then
#     # this is for syncing to the .pot and .po files, so do all languages
#     languages=`ls po/_*.*.po | cut -d . -f 2|sort -u`
# else
#     languages=$(ruby -ryaml -e "data = YAML::load(open('_config.yml')); puts data['languages']")
# fi
# test -n "$languages"

# if [ "$1" == "md2po" ]; then
#     languages=$(cd _data; find * -type d)
# fi

# convert newlines to spaces
#languages=`echo $languages`
languages=`echo br_pt it es-mx de`

for section in content; do
    # po4a_conf=$(mktemp)
    po4a_conf=po/po_config
    echo "[po4a_langs] $languages" > $po4a_conf
    echo "[po4a_paths] po/${section}.pot \$lang:po/${section}.\$lang.po" >> $po4a_conf
    cat >> $po4a_conf <<EOF

[options] opt:"--addendum-charset=UTF-8" opt:"--localized-charset=UTF-8" opt:"--master-charset=UTF-8" opt:"--msgmerge-opt='--no-wrap'" opt:"--porefs=file" opt:"--wrap-po=newlines" opt:"--master-language=en_US"

[po4a_alias:markdown] text opt:"--option markdown" opt:"--option yfm_keys=title" opt:"--addendum-charset=UTF-8" opt:"--localized-charset=UTF-8" opt:"--master-charset=UTF-8" opt:"--keep=80"

EOF
    # for f in $section/*.md; do
    for f in  $(find content -type f -name '*.md'); do
	echo "[type: markdown] $f \$lang:$section/$(basename $f .md).$lang.md" >> $po4a_conf
    done
    po4a --verbose $po4a_conf &
done
wait

# no need to keep these around
rm -f po/*.en.po
