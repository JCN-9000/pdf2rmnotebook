
# Files to explain Conversion bug

Issue #6 : rM lines are automatically closed from last to first point when converted by drawj2d from PDF to rM notebook

It has something to do with the data of the pdf when converted from a notebook

- Shapes.zip  rM Notebook with shapes
- Shapes.pdf  Same Notebook sent by email
- XShapes.pdf pdf file generated using xournalpp
- shape.hcl   hcl file using Shapes.pdf
- xshape.hcl  hcl file using XShapes.pdf

# Commands

    drawj2d -Tscr -W157 -H209 shape.hcl

    drawj2d -Tscr -W157 -H209 xshape.hcl

# Screenshots

![BAD](Shapes.png)
![GOOD](XShapes.png)

