# pdf2rmnotebook

Creates a reMarkable Notebook from multiple PDF files.

## Changelog
Version
- V1.1   - All pdf pages are converted, no need to split file ( needs pdfinfo command )
- V1.2.0 - Some options added: Verbosity, Usage, Version; Cleanup and Checks
- V2.1.0 - Image formats png/jpg can be directly converted
           -s option to scale notebook page size


## Sample 
In the example folder.
PDF are not correctly ingested.

## Screenshot
![Screenshot](./example/Notebook.png)

## Installation
Create a /var/lib/pdf2rmnotebook folder and copy there the UUID* files from var/lib 

## Requirements
- [drawj2d](https://sourceforge.net/projects/drawj2d/)
- pdfinfo: from your distribution package manager:  Deb:poppler-utils

## Usage
Run the script followed by the list of PDF files, it will create a Notebook.zip file that can be uploaded to rM Cloud via rmapi tool.

```shell
$ pdf2rmnotebook 2d-3.pdf 3d-1.pdf shapes-1.pdf

$ pdf2rmnotebook -s 2 flower.png
```

## Thanks
- [drawj2d](https://sourceforge.net/projects/drawj2d/)

## Badges
[![rm1](https://img.shields.io/badge/rM1-supported-green)](https://remarkable.com/store/remarkable)
[![rm2](https://img.shields.io/badge/rM2-supported-green)](https://remarkable.com/store/remarkable-2)
[![Discord](https://img.shields.io/discord/385916768696139794.svg?label=reMarkable&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/ATqQGfu)

