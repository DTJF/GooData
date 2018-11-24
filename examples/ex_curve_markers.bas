'~This is file example_curve_markers.bas
'
'~Licence: GPLv3
'~(C) 2012 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

CONST cols = 2, az = 30, l = 4 * ATN(1), line_group = 2.0
DIM AS GooType datas(az, cols)
FOR i AS INTEGER = 0 TO az
  VAR x = -l + i / az * 2 * l
  datas(i, 0) = x
  datas(i, 1) = SIN(x)
  datas(i, 2) = SIN(x) ^ 3
NEXT
VAR Dat = goo_data_points_new(az + 1, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0

VAR group = goo_canvas_group_new(Glob, _
            "line_width", 2.0, _
             NULL)

VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Line Graph With Markers" _
           !"</span>\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

VAR grid = goo_canvas_rect_new(group, _
             0.0, 0.0, wdth, hght, _
            "fill_color", "#F7F19E", _
            "stroke_pattern", NULL, _
             NULL)

VAR x = goo_axis_new(group, grid, GOO_AXIS_SOUTH, "angle <i>φ</i>", _
            "text_align", PANGO_ALIGN_RIGHT, _
            "offset", "-" & hght / 2, _
            "range", "-3.3 3.3", _
            "tick_length", "5 5", _
            "ticks", "-3 -2 -1 1 2 3", _
             NULL)

VAR y = goo_axis_new(group, grid, GOO_AXIS_WEST, !"sin(<i>φ</i>)\ncos(<i>φ</i>)", _
            "text_align", PANGO_ALIGN_RIGHT, _
            "offset", "-" & wdth / 2, _
_            "text_offset", 0., _
_            "logbasis", 0.001, _
_            "range", "0.1 4123.15", _
            "range", "-2.15 2.15", _
_            "ticks", "-1 -.5 .5 1", _
            "tick_length", "5 5", _
             NULL)

VAR zz = goo_curve2d_new(group, x, y, Dat, _
            "vectors", "1 2", _
_            "errors", "9 1 1 2", _
            "channels", "0 2", _
            "line_type", "none", _
            "markers", "d" & GOO_MARKER_CIRCLE, _
            NULL)

goo_curve2d_set_markers_properties(zz, _
            "stroke_color", "brown", _
            "fill_color", "green", _
             NULL)

goo_curve2d_set_vectors_properties(zz, _
            "stroke_color", "blue", _
             NULL)

goo_curve2d_set_errors_properties(zz, _
            "line_width", 0.5, _
            "stroke_color", "blue", _
             NULL)

VAR z = goo_curve2d_new(group, x, y, Dat, _
            "markers", "10 " & GOO_MARKER_RHOMBUS, _
_            "line-type", "h", _
_            "markers", "c0", _
             NULL)

goo_curve2d_set_markers_properties(z, _
            "stroke_color", "brown", _
            "fill_color", "red", _
             NULL)
