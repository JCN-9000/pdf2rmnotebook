# pdf2rmnotebook

Creates a reMarkable Notebook from multiple PDF files.

## Changelog
Version
- V1.1   - All pdf pages are converted, no need to split file ( needs pdfinfo command )
- V1.2.0 - Some options added: Verbosity, Usage, Version; Cleanup and Checks


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
```

## Thanks
- [drawj2d](https://sourceforge.net/projects/drawj2d/)
