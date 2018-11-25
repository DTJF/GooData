' Example: Smooth Lines
'
' Two <link linkend="GooCurve2d">GooCurve2d</link> items, smooth line and straight line with markers
' points can get connected by smooth curves with quadratic or cubic bezier lines.
'
'~Licence: GPLv3
'~(C) 2012-2018 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

CONST cols = 1, az = 7, l = 10 * ATN(1)
DIM AS GooType datas(az, cols)
FOR i AS INTEGER = 0 TO az
  VAR a = i / az * l
  datas(i, 0) = SIN(a) * a / 4
  datas(i, 1) = COS(a) * a / 4
NEXT
VAR Dat = goo_data_points_new(az + 1, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0, line_group = 2.0

VAR group = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
            "font", "Arial", _
            NULL)

VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Smooth Lines by Bezier Curves" _
           !"</span>\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
            NULL)

VAR grid = goo_canvas_rect_new(group, _
            0.0, 0.0, wdth, hght, _
            NULL)

VAR x = goo_axis_new(group, grid, GOO_AXIS_SOUTH, _
            "X-Value", _
            "label_align", PANGO_ALIGN_LEFT, _
            "range", "-2.0 3.0", _
            "ticks", "1", _
            NULL)

goo_axis_set_grid_properties(x, _
            "stroke_color", "lightgray", _
            NULL)

VAR y = goo_axis_new(group, grid, GOO_AXIS_WEST, _
           !"Y-Value", _
            "label_align", PANGO_ALIGN_LEFT, _
            "offset_label", 7., _
            "range", "-1.5 2.0", _
            "ticks", ".5", _
            NULL)

goo_axis_set_grid_properties(y, _
            "stroke_color", "lightgray", _
            NULL)

VAR c1 = goo_curve2d_new(group, x, y, Dat, _
            "channels", "0 1", _
            "line_type", "bezier 0.7", _
            "stroke_color", "red", _
            NULL)

VAR c2 = goo_curve2d_new(group, x, y, Dat, _
            "channels", "0 1", _
            "markers", "12 " & GOO_MARKER_RHOMBUS, _
            "line_width", line_group / 3, _
            NULL)

