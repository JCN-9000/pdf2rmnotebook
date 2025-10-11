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
#                1.3.0 : Image inclusion
#                2.2.0 : option to create reMarkable Notebook .rmn file
#                3.0.0 : Color management for Pro, rmdoc
#                3.1.0 : Color management for text files imorted
#===============================================================================

#  reMarkable 2: device screen width ≅ 157 mm, height = 209 mm
#  reMarkable 2: monochrome display, drawj2d will map colours to black, grey or white
#  reMarkable Pro: device screen width ≅ 179 mm, height = 239 mm.
#     Preview drawj2d -Tscreen -W168 -H239 thales.hcl
#
#  reMarkable 2:
# Embed page 5 of an A4 sized (297mm x 210mm) pdf ﬁle, scale to ﬁt the tablet height (297 * 0.7 = 208mm < 209mm), right justiﬁed (9 + 210 * 0.7 = 156mm < 157mm).
#    moveto 9 0
#    image article.pdf 5 0 0 0.7
#
# reMarkable Pro:
# Embed page 5 of an A4 sized (297mm x 210mm) pdf ﬁle, scale to ﬁt the tablet height (297 * 0.8 = 238mm < 239mm), right justiﬁed (210*0.8 = 168mm <= 179mm - 11mm).
#     move10 11 0
#     image article.pdf 5 0 0 0.8
#  convert pappagallo.jpg pappagallo.pdf
#  convert pappagallo.pdf -dither FloydSteinberg -remap colormap.png rM-pappagallo.pdf

# From: https://github.com/ricklupton/rmc
#    Command line tool for converting to/from remarkable .rm version 6 (software version 3) files.
# ~/Python-Env/rmc/bin/rmc -t rm  -o GrafanaMail.rm GrafanaMail.md

# To add multiple files in multiple colors arg parsing should be splitted,
# everything will become too complicated. please use multiple sepaate
# conversions, merge on the device.

set -o nounset                              # Treat unset variables as an error

Version=3.1.0

NAME=$(basename $0 .sh)
TEMP=$(mktemp -d)

# === Functions ===
Usage() {
cat <<EOD
$NAME: $Version
Usage:
  $NAME [options] file.pdf [...]

Create multi-page reMarkable Notebook file from PDF files
  * Creates .zip files by default for use with rmapi
  * Use -r option to create a reMarkable Notebook .rmn file for use with RCU
  * Use -R option to create a reMarkable Notebook .rmdoc file for use with USB Link

  Switches (no arguments required):
    -h    Display this help and exit
    -q    Produce fewer messages to stdout
    -r    Create a reMarkable Notebook .rmn file (default: zip)
    -R    Create a reMarkable Notebook .rmdoc file
    -v    Produce more messages to stdout
    -V    Display version information and exit

  With arguments:
    -n NAME    Set the rmn Notebook Display Name (default: Notebook-<yyyymmdd_hhmm.ss>)
               Only used with -r/-R option
    -o FILE    Set the output filename (default: Notebook-<yyyymmdd_hhmm.ss>.zip)
    -s SCALE   Set the scale value (default: 0.75) - 0.75 is a good value for A4/Letter PDFs
    -c COLOR   Set a color for the files to be imported

Example:
  $NAME -n "My Notebook" -o mynotebook.zip -s 1.0 file.pdf
EOD
}

Cleanup() {
 rm -rf ${TEMP}
}

# Simple ASCII text file is embedded into HCL and then converted
textFile(){
  # $1 = Filename
  # $2 = HCL Page

  _F=$1
  _HCL=$2

  # Overwrite default page settings
    echo pen $COLOR 0.1 solid > ${_HCL}
    echo font Lines up 3.5 >> ${_HCL}
    echo moveto 12 8 >> ${_HCL}

    cat ${_F} >> ${_HCL}.tmp
    sed -i 's/"/\\"/g'  ${_HCL}.tmp
    sed -i 's/`/\\`/g'  ${_HCL}.tmp
    sed -i 's/]/\\]/g' ${_HCL}.tmp
    sed -i 's/\[/\\[/g' ${_HCL}.tmp
    sed -i 's/\$/\\$/g' ${_HCL}.tmp
    sed -i 's/\(.*\)/text "\1" 140/' ${_HCL}.tmp
    cat ${_HCL}.tmp >> ${_HCL}
    rm ${_HCL}.tmp
}

# === Main ===
trap Cleanup EXIT

QVFLAG='-q'
VERBOSE=false
DEBUG=false
IMAGE=false
SCALE=.75
DEFAULT_OUTFILE="Notebook-$(date +%Y%m%d_%H%M.%S)"
OUTFILE=""
EXTENSION=".zip"
DISPLAY_NAME=$DEFAULT_OUTFILE
RMN=false
RMDOC=false
RMC=false
COLOR=black

while getopts "c:dhimn:qrRvs:Vo:" opt
do
  case $opt in
    c)
      COLOR=$OPTARG
      ;;
    m)
      # RMC Converted file
      RMC=true
      EXTENSION=".rmdoc"
      ;;
    d)
      # Fake some values
      DEBUG=true
      NAME=pdf2rmnotebook
      ;;
    n)
      DISPLAY_NAME=$OPTARG
      ;;
    o)
      OUTFILE=$OPTARG
      ;;
    q)
      QVFLAG='-q'
      VERBOSE=false
      ;;
    r)
      RMN=true
      EXTENSION=".rmn"
      TARARGS="cf"
      ;;
    R)
      RMDOC=true
      EXTENSION=".rmdoc"
      ;;
    h)
      Usage
      exit 0
      ;;
    i)
      IMAGE=true
      ;;
    s)  # Default is .75 so 1n A$ pdf scales to a rM page
      SCALE=$OPTARG
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

if [[ -z "$OUTFILE" ]]
then
  OUTFILE=$DEFAULT_OUTFILE
fi

VARLIB=/var/lib/${NAME}
test -d ${VARLIB} || VARLIB=$(dirname $0)/var/lib/${NAME}
test -d ${VARLIB} || { echo "Error - Incorrect Installation: ${VARLIB} not available" ; exit 1 ; }

if [[ $# -le 0 ]]
then
  Usage
  exit 1
fi

# Prepare HCL file for image inclusion
cat > ${TEMP}/page.hcl <<EOF
pen $COLOR 0.1 solid
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
#cp ${VARLIB}/UUID.pagedata ${NB}/${UUID_N}.pagedata
cp ${VARLIB}/UUID_HEAD.content ${NB}/${UUID_N}.content

for _P in "$@"
do

#  test ${_page} -ne 0 && echo , >> ${NB}/${UUID_N}.content

  $VERBOSE && echo Working on file: ${_P}
  test -f "${_P}" || { echo "${_P}: No such file or directory." ; Usage ; exit 1 ; }

  FILETYPE=$(file -b --mime-type "${_P}")
  if [ -z "$FILETYPE" -o "$FILETYPE" = "text/plain" ]
  then
    EXT=${_P##*.}
    case $EXT in
      md)   # Markdown
        RMC=true
        FILETYPE='text/markdown'
        _NP=1
        ;;
    esac
  fi

  case $FILETYPE in
    image/jpeg | image/png)
      _NP=1
      IMAGE=true
      ;;

    application/pdf )

      # Get Pages from file, loop over all of them
      read x _NP <<< $(pdfinfo "${_P}" | grep -a Pages: )
      ;;
  esac

    _PP=1
    while [[ ${_PP} -le ${_NP} ]]
    do
      test ${_page} -ne 0 && echo , >> ${NB}/${UUID_N}.content
      cp ${TEMP}/page.hcl ${TEMP}/P_${_page}.hcl

      case $FILETYPE in
        image/jpeg | image/png )
          echo "moveto 12 12"  >>  ${TEMP}/P_${_page}.hcl
          echo "image {${_P}} 200 0 0 $SCALE " >> ${TEMP}/P_${_page}.hcl
          ;;
        application/pdf )
          # Scale image: Usually PDF is A4/Letter, rM is smaller
          echo "image {${_P}} ${_PP} 0 0 $SCALE" >> ${TEMP}/P_${_page}.hcl
          ;;
        text/markdown )
          textFile ${_P} ${TEMP}/P_${_page}.hcl
          ;;
      esac

      UUID_P=$(uuidgen)   # Notebook Pages should be named using the UUID from .content file
  #  rmapi interface to reMarkable cloud renames pages from UUID to page number while up/downloading
  #  so we need to use the same convention in naming pages: 0.rm 1.rm ... instead of UUIDs
  #  which are used internally in the rM (see ~/.local/share/remarkable/xochitl/ )
  #  It is indeed easier to have page numbers instead of random UUIDs referenced elsewhere
  # Fix issue #18: remove .json file
      if [ ! $RMDOC ]
      then
        drawj2d ${QVFLAG} -T rm -o ${NB}/${UUID_N}/${_page}.rm ${TEMP}/P_${_page}.hcl
#        cp ${VARLIB}/UUID_PAGE-metadata.json ${NB}/${UUID_N}/${_page}-metadata.json
      else
$DEBUG && cat ${TEMP}/P_${_page}.hcl
$DEBUG && echo drawj2d ${QVFLAG} -T rm -o ${NB}/${UUID_N}/${UUID_P}.rm ${TEMP}/P_${_page}.hcl
        drawj2d ${QVFLAG} -T rm -o ${NB}/${UUID_N}/${UUID_P}.rm ${TEMP}/P_${_page}.hcl
#        cp ${VARLIB}/UUID_PAGE-metadata.json ${NB}/${UUID_N}/${UUID_P}-metadata.json
      fi

      echo -n \"${UUID_P}\" >> ${NB}/${UUID_N}.content

      _PP=$(( $_PP + 1 ))
      _page=$(( _page + 1 ))
    done

done


cat ${VARLIB}/UUID_TAIL.content >> ${NB}/${UUID_N}.content
# sed in macOS need "backup file" argument
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/%PAGENUM%/${_page}/" ${NB}/${UUID_N}.content
else
    sed -i "s/%PAGENUM%/${_page}/" ${NB}/${UUID_N}.content
fi
#DEBUG  cat ${NB}/${UUID_N}.content

(
cd ${NB}
  if [ $QVFLAG = "-v" ]; then
    TARARGS="${TARARGS}v"
  fi


  CMOTIME=$(date +%s000)
  PAGE=1
  TYPE="DocumentType"
  if [ -z "$DISPLAY_NAME" ]; then
    DISPLAY_NAME=$DEFAULT_OUTFILE
  fi

  cat > "${NB}/${UUID_N}.metadata" <<EOF
  {
    "createdTime": ${CMOTIME},
    "lastModified": ${CMOTIME},
    "lastOpened": ${CMOTIME},
    "lastOpenedPage": ${PAGE},
    "parent": "",
    "pinned": false,
    "type": "${TYPE}",
    "visibleName": "${DISPLAY_NAME}"
  }
EOF

if [ $RMN = true ]; then
  tar $TARARGS ${TEMP}/Notebook$EXTENSION ${UUID_N}.* ${UUID_N}/*
else
  zip ${QVFLAG} ${TEMP}/Notebook$EXTENSION ${UUID_N}.* ${UUID_N}/*
fi
)


cp ${TEMP}/Notebook$EXTENSION ${OUTFILE}$EXTENSION

echo Output written to $OUTFILE$EXTENSION

#DEBUG  find ${TEMP} -ls

# vim:set ai et sts=2 sw=2 tw=80:

