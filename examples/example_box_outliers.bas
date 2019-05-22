' Example: Tailed Box Plot
'
' A <link linkend="GooBox2d">GooBox2d</link> item from six channels
' some text here !!!
'
'~Licence: GPLv3
'~(C) 2012-2019 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

'~ create the data
RANDOMIZE TIMER
CONST cols = 5, rows = 30
DIM AS GooType datas(rows, cols)
FOR r AS INTEGER = 0 TO rows
  FOR c AS INTEGER = 0 TO cols
    datas(r, c) = RND() * 6.20 + 1
  NEXT
NEXT
VAR Dat = goo_data_points_new(rows + 1, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0, line_group = 1.0

'~ the group for all items
VAR group = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
             NULL)

'~ the header text line
VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Tailed Box Plot" _
           !"</span>\n" _
           !"(40% IQR outliers, stroke_pattern = NULL)\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

'~ the background item
VAR back = goo_canvas_rect_new(group, _
             0.0, 0.0, wdth, hght, _
            "fill_color", "#F7F7F7", _
            "stroke_pattern", NULL, _
             NULL)

'~ an axis for scaling
VAR y = goo_axis_new(group, back, GOO_GRIDAXIS_SOUTH, "Pressure [bar]", _
            "range", "-0.1 10", _
            "subticks", 3, _
             NULL)

'~ customize the grid style
goo_axis_set_grid_properties(y, _
            "line_width", 1.0, _
            "stroke_color", "grey", _
             NULL)

'~ create the boxplot
VAR z = goo_box2d_new(group, y, Dat, _
            "channels", "0 1 2 3 4 5", _
            "boxes", "0.5 0.16 0.7", _
            "outliers", "p 0.4 0.3 " & GOO_MARKER_CIRCLE, _
            "fill_color", "green", _
            "stroke_pattern", NULL, _
             NULL)

'~ customize whisker style
goo_box2d_set_whiskers_properties(z, _
            "stroke_color", "blue", _
             NULL)

'~ customize outliers style
goo_box2d_set_outliers_properties(z, _
            "fill_color", "red", _
             NULL)
