#!/bin/bash - 
#===============================================================================
#
#          FILE: ./pdf2rmnotebook.sh
# 
#         USAGE: ./pdf2rmnotebook.sh [options] file.pdf [...]
# 
#   DESCRIPTION: Build multi page reMarkable Notebook from PDF Files
# 
#       OPTIONS: See Usage()
#  REQUIREMENTS: drawj2d, pdfinfo
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Alberto Varesio (JCN), jcn9000@gmail.com
#  ORGANIZATION: 
#       CREATED: 05/26/2021 01:24:45 PM
#      REVISION: 1.1   : Multi page PDF conversion
#                1.2.0 : Usage, Verbosity and Version options
#===============================================================================

set -o nounset                              # Treat unset variables as an error

Version=1.2.0

NAME=$(basename $0 .sh)
TEMP=$(mktemp -d)

# === Functions ===
Usage() {
cat <<EOD
$NAME: $Version
Usage:
$NAME [options] file.pdf [...]
options:
  -h    this page (help)
  -q    Less messages to stdout (quiet)
  -v    More messages to stdout (verbose)
  -V    Display version (Version)
EOD
}

Cleanup() {
  rm -rf ${TEMP}
}

# === Main ===
trap Cleanup EXIT

VARLIB=/var/lib/${NAME}
test -d ${VARLIB} || VARLIB=$(dirname $0)/var/lib/${NAME}

QVFLAG='-q'
VERBOSE=false
DEBUG=false

while getopts "hqvV" opt
do
  case $opt in
    q)
      QVFLAG='-q'
      VERBOSE=false
      ;;
    h)
      Usage
      exit 0
      ;;
    v)
      QVFLAG='-v'
      VERBOSE=true
      ;;
    V)
      echo $NAME: $Version
      exit 0
      ;;
    \?)
      echo "Invalid option; -$OPTARG" >&2
      Usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      Usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [[ $# -le 0 ]]
then
  Usage
  exit 1
fi

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

_page=0
UUID_N=$(uuidgen)   # UUID for Notebook

mkdir ${NB}/${UUID_N}
cp ${VARLIB}/UUID.pagedata ${NB}/${UUID_N}.pagedata
cp ${VARLIB}/UUID_HEAD.content ${NB}/${UUID_N}.content

for _P in "$@"
do

#  test ${_page} -ne 0 && echo , >> ${NB}/${UUID_N}.content

  $VERBOSE && echo Working on file: ${_P}
  test -f "${_P}" || { echo "${_P}: No such file or directory." ; Usage ; exit 1 ; }

  # Get Pages from file, loop over all of them
  read x _NP <<< $(pdfinfo "${_P}" | grep Pages: )
  _PP=1
  while [[ ${_PP} -le ${_NP} ]]
  do
    test ${_page} -ne 0 && echo , >> ${NB}/${UUID_N}.content
    cp ${TEMP}/page.hcl ${TEMP}/P_${_page}.hcl
    echo "image {${_P}} ${_PP} 0 0 .73" >> ${TEMP}/P_${_page}.hcl
#  drawj2d -T rmapi -o ${TEMP}/P_${_page}.zip ${TEMP}/P_${_page}.hcl

    UUID_P=$(uuidgen)   # Notebook Pages should be named using the UUID from .content file
#  rmapi interface to reMarkable cloud renames pages from UUID to page number while up/downloading
#  so we need to use the same convention in naming pages: 0.rm 1.rm ... instead of UUIDs
#  which are used internally in the rM (see ~/.local/share/remarkable/xochitl/ )
#  It is indeed easier to have page numbers instead of random UUIDs referenced elsewhere
    drawj2d ${QVFLAG} -T rm -o ${NB}/${UUID_N}/${_page}.rm ${TEMP}/P_${_page}.hcl
    cp ${VARLIB}/UUID_PAGE-metadata.json ${NB}/${UUID_N}/${_page}-metadata.json

    echo -n \"${UUID_P}\" >> ${NB}/${UUID_N}.content

    _PP=$(( $_PP + 1 ))
    _page=$(( _page + 1 ))
  done
done


cat ${VARLIB}/UUID_TAIL.content >> ${NB}/${UUID_N}.content
sed -i "s/%PAGENUM%/${_page}/" ${NB}/${UUID_N}.content
#DEBUG  cat ${NB}/${UUID_N}.content

(
cd ${NB}
zip ${QVFLAG} ${TEMP}/Notebook.zip ${UUID_N}.* ${UUID_N}/*
)

cp ${TEMP}/Notebook.zip .

#DEBUG  find ${TEMP} -ls

