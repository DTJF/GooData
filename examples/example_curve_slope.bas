' Example: Slope Field
'
' A <link linkend="GooCurve2d">GooCurve2d</link> item type "slope"
' the slope datas are red from a channel in Dat (inf is used for vertical slope).
'
'~Licence: GPLv3
'~(C) 2012-2019 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

' generate data
CONST cols = 2, l = 4 * ATN(1)
VAR i = 0
DIM AS GooFloat datas(168, cols)
FOR x AS GooFloat = -3 TO 3.1 STEP 0.5
  FOR y AS GooFloat = -3 TO 3.1 STEP 0.5
    datas(i, 0) = x
    datas(i, 1) = y
    datas(i, 2) = COS(x) * SIN(y)
    i += 1
  NEXT
NEXT
VAR Dat = goo_data_points_new(i, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0, line_group = 1.0


VAR group = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
            "font", "Arial", _
             NULL)

VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">"_
            "Slope Field in a Grid Box" _
           !"</span>\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE1, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

VAR grid = goo_canvas_rect_new(group, _
            0.0, 0.0, wdth, hght, _
            "line_width", line_group, _
             NULL)

VAR x = goo_axis_new(group, grid, GOO_GRIDAXIS_SOUTH, "X-Value", _
            "range", "-3.3 3.3", _
            "ticks", "1", _
             NULL)

goo_axis_set_grid_properties(x, _
            "stroke_color", "lightgray", _
             NULL)

VAR y = goo_axis_new(group, grid, GOO_GRIDAXIS_WEST, "Y-Value", _
            "offset-label", 7.0, _
            "range", "-3.3 3.3", _
            "ticks", "1", _
             NULL)

goo_axis_set_grid_properties(y, _
            "stroke_color", "lightgray", _
             NULL)

VAR c1 = goo_curve2d_new(group, x, y, Dat, _
            "channels", "0 1", _
            "line-type", "none", _
            "vectors", "Slope 2 15", _
             NULL)

goo_curve2d_set_vectors_properties(c1, _
            "stroke_color", "red", _
             NULL)
