'~This is file ex_box_area.bas
'
'~Licence: GPLv3
'~(C) 2012-2019 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

'VAR line_group = 1.0, l = 4 * ATN(1)
'VAR da = LA_M(az + 1, 3), f = 2 * l / IIF(az, az, 1)
'FOR i AS INTEGER = 0 TO az
  'VAR x = -l + i / az * 2 * l


CONST cols = 2, az = 30, l = 4 * ATN(1)
DIM AS gdouble datas(az, cols)
FOR i AS INTEGER = 0 TO az
  VAR x = -l + i / az * 2 * l
  datas(i, 0) = x
  datas(i, 1) = SIN(x)
  datas(i, 2) = COS(x)
NEXT
VAR Dat = goo_data_points_new(az + 1, cols + 1, @datas(0, 0))
VAR line_group = 2.0


VAR group = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
            "font", "Arial", _
             NULL)

VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">"_
            "Areas in a Grid Box" _
           !"</span>\n", _
            0.0, 0.0, W, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

VAR grid = goo_canvas_rect_new(group, _
            0.0, 0.0, W, H, _
            "line_width", line_group, _
             NULL)

VAR x = goo_axis_new(group, grid, GOO_GRIDAXIS_SOUTH, Tx, _
            "range", "-3.3 3.3", _
            "ticks", "1", _
             NULL)

goo_axis_set_grid_properties(x, _
            "stroke_color", "lightgray", _
             NULL)

VAR y = goo_axis_new(group, grid, GOO_GRIDAXIS_WEST, Ty, _
            "text_offset", 7., _
            "range", "-1.15 1.15", _
            "ticks", ".5", _
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
