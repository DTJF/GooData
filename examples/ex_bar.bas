'~This is file ex_bar.bas
'
'~Licence: GPLv3
'~(C) 2012-2018 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

VAR root = goo_canvas_group_new(Glob, _
            "line_width", line_group / 2, _
             NULL)

VAR title = goo_canvas_text_new(root, _
            "<span size=""xx-large"">" _
            "Bar Graph" _
           !"</span>\n", _
            0.0, 0.0, W, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

VAR back = goo_canvas_rect_new(root, _
             0.0, 0.0, W, H, _
            "fill_color", "#F7F19E", _
            "stroke_pattern", NULL, _
             NULL)

VAR y = goo_axis_new(root, back, GOO_GRIDAXIS_SOUTH, Ty, _
_ VAR y = goo_axis_new(root, back, GOO_GRIDAXIS_EAST, Ty, _
_ VAR y = goo_axis_new(root, back, GOO_GRIDAXIS_WEST, Ty, _
            "range", "-5 10", _
_            "range", "-1 101", _
_            "angle_ticklabel", 45.0, _
            "offset", "5", _
_            "ticks", "-5 0 5 10", _
             NULL)
goo_axis_set_grid_properties(y, _
            "line_width", 0.5 * line_group, _
            "stroke_color", "grey", _
             NULL)


VAR z = goo_bar2d_new(root, y, Dat, _
_            "channels", "0 1 2 3 4 5", _
_            "channels", "A 0 3 1", _
_            "channels", "P 0 3 1", _
            "channels", "S 0 3 1", _
            "gaps", "50 40", _
_            "gaps", "0 0", _
            "stroke_pattern", NULL, _
             NULL)
