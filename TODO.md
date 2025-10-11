
# TODO

- Add color management: Colot:Filename => Import filename using Color as pen
  Es. if file is named/rferred red:report.md then import text using the red pen
- Import text file : rmc does text to typed text conversion
- Import text file : drawj2d can import text using stroke font
- Import svg : rmc
- import bitmap : [potrace](https://potrace.sourceforge.net/)o
- Convert image to SVG polylines  https://github.com/LingDong-/linedraw
- Manage rM files
- add existing .rm pages to notebook ( create pages then build notebook )
- merge multiple .rmdoc contents into new .rmdoc

To send files to rM use something in the list:
- rM native web interface via USB
- RCU
- Other tools like : https://github.com/adaerr/reMarkableScripts/blob/master/pdf2remarkable.sh
  https://potrace.sourceforge.net/, https://github.com/peerdavid/remapy

- Remap images to rM colormap, dither and convert to colored SVG
- enhance linedraw to manage colors

## Other Ideas and Information

# NOTES

reMarkable 2: device screen width = 157 mm, height = 209 mm
reMarkable 2: monochrome display, drawj2d will map colours to black, grey or white
reMarkable Pro: device screen width = 179 mm, height = 239 mm. Preview drawj2d -Tscreen -W168 -H239 thales.hcl

reMarkable 2: 1872 x 1404 resolution (226 DPI)
Embed page 5 of an A4 sized (297mm x 210mm) pdf file, scale to fit the tablet height (297 * 0.7 = 208mm < 209mm), right justified (9 + 210 * 0.7 = 156mm < 157mm).
   moveto 9 0
   image article.pdf 5 0 0 0.7

reMarkable Pro: 2160 x 1620 resolution (229 PPI)
Embed page 5 of an A4 sized (297mm x 210mm) pdf file, scale to fit the tablet height (297 * 0.8 = 238mm < 239mm), right justified (210*0.8 = 168mm <= 179mm - 11mm).
    move10 11 0
    image article.pdf 5 0 0 0.8
convert pappagallo.jpg pappagallo.pdf
convert pappagallo.pdf -dither FloydSteinberg -remap colormap.png rM-pappagallo.pdf

~/Python-Env/rmc/bin/rmc -t rm  -o GrafanaMail.rm GrafanaMail.md

