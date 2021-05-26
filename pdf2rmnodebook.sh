#!/bin/bash - 
#===============================================================================
#
#          FILE: reShapes.sh
# 
#         USAGE: ./reShapes.sh 
# 
#   DESCRIPTION: Build multi page reMarkable Notebook from PDF Files
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Alberto Varesio (JCN), jcn9000@gmail.com
#  ORGANIZATION: 
#       CREATED: 05/26/2021 01:24:45 PM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

NAME=$(basename $0 .sh)
VARLIB=/var/lib/${NAME}
test -d ${VARLIB} || VARLIB=$(dirname $0)/var/lib/${NAME}

TEMP=$(mktemp -d)

# Prepare HCL file for image inclusion
cat > ${TEMP}/page.hcl <<EOF
pen black 0.1 solid
line 1 1 156 1
line 156 1 156 208
line 156 208 1 208
line 1 208 1 1
moveto 0 0
EOF

NB=${TEMP}/Notebook
mkdir ${NB}

# Let's start with multiple single page PDF Files
_page=0
UUID=$(uuidgen)

mkdir ${NB}/${UUID}
cp ${VARLIB}/UUID.pagedata ${NB}/${UUID}.pagedata
cp ${VARLIB}/UUID_HEAD.content ${NB}/${UUID}.content

for _P in $*
do

  test ${_page} -ne 0 && echo , >> ${NB}/${UUID}.content

  echo Working on file: ${_P}
  cp ${TEMP}/page.hcl ${TEMP}/P_${_page}.hcl
  echo "image ${_P} 1 0 0 .73" >> ${TEMP}/P_${_page}.hcl
#  drawj2d -T rmapi -o ${TEMP}/P_${_page}.zip ${TEMP}/P_${_page}.hcl
  drawj2d -T rm -o ${NB}/${UUID}/${_page}.rm ${TEMP}/P_${_page}.hcl
  cp ${VARLIB}/UUID_PAGE-metadata.json ${NB}/${UUID}/${_page}-metadata.json

  echo -n \"$(uuidgen)\" >> ${NB}/${UUID}.content

  _page=$(( _page + 1 ))

done

cat ${VARLIB}/UUID_TAIL.content >> ${NB}/${UUID}.content
sed -i "s/%PAGENUM%/${_page}/" ${NB}/${UUID}.content

(
cd ${NB}
zip ${TEMP}/Notebook.zip ${UUID}.* ${UUID}/*
)

cp ${TEMP}/Notebook.zip .

find ${TEMP} -ls
rm -rf ${TEMP}
