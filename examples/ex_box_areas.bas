'~This is file ex_box_area.bas
'
'~Licence: GPLv3
'~(C) 2012-2020 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

VAR group = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
            "font", "Arial", _
             NULL)

VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">"_
            "Areas in a Grid Box" _
           !"</span>\n", _
            0.0, 0.0, W, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE1, _
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
            "channels", "0 2", _
            "line-type", "none", _
_            "stroke_color", "green", _
            "area-direction", "north", _
             NULL)

goo_curve_set_area_properties(c1, _
            "fill-color-rgba", &h00C00030, _
             NULL)

VAR c2 = goo_curve2d_new(group, x, y, Dat, _
            "channels", "0 4", _
            "fill_color", "lightred", _
            "line_type", "none", _
_            "stroke_color", "red", _
_            "area", "Y0", _
            "area_type", "bezier", _
            "area_direction", "y0.41", _
             NULL)

goo_curve_set_area_properties(c2, _
            "fill-color-rgba", &hC0000030, _
             NULL)
