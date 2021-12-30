'~This is file ex_3d_perpens.bas
'
'~Licence: GPLv3
'~(C) 2012-2022 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

VAR root = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
             NULL)

VAR title = goo_canvas_text_new(root, _
            "<span size=""xx-large"">"_
            "3D Effect, Perpendiculars, Background Pixbuf" _
           !"</span>\n", _
            0.0, 0.0, W, GOO_CANVAS_ANCHOR_SW, _
            "font", "Purisa Bold Italic", _
            "use_markup", TRUE1, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

VAR pixbuf = gdk_pixbuf_new_from_file("FreeBasic.png", 0)
VAR grid = goo_canvas_rect_new(root, _
             0.0, 0.0, W, H, _
            "stroke_color", "yellow", _
            "fill_color", "lightyellow", _
            "line_width", line_group, _
             NULL)

VAR image = goo_canvas_image_new(root, _
            pixbuf, _
            0.0, 0.0, _
            "width", W, _
            "height", H, _
            "scale-to-fit", TRUE1, _
             NULL)

VAR x = goo_axis_new(root, grid, GOO_AXIS_SOUTH, Tx, _
            "stroke_color", "yellow", _
            "fill_color", "yellow", _
            "offset", "25 27", _
            "range", "-3.3 3.3", _
            "tick_length", "0.01", _
            "tick_angle", -30.0, _
            "ticks", "1", _
             NULL)

goo_axis_set_ticks_properties(x, _
            "stroke_color", "black", _
             NULL)

goo_axis_set_text_properties(x, _
            "fill_color", "black", _
             NULL)

VAR y = goo_axis_new(root, grid, GOO_AXIS_EAST, Ty, _
            "stroke_color", "yellow", _
            "fill_color", "yellow", _
            "offset", "25 -27", _
            "text_offset", 7., _
            "range", "-1.15 1.15", _
            "ticks", ".5", _
            "tick_length", "0.01", _
            "tick_angle", -30.0, _
             NULL)

goo_axis_set_ticks_properties(y, _
            "stroke_color", "black", _
             NULL)

goo_axis_set_text_properties(y, _
            "fill_color", "black", _
             NULL)

VAR zz = goo_curve2d_new(root, x, y, Dat, _
            "channels", "0 2", _
            "stroke_color", "green", _
            "perpendiculars", "V4", _
             NULL)

goo_curve_set_perpens_properties(zz, _
            "stroke_color_rgba", &hC0C0C090, _
             NULL)

VAR z = goo_curve2d_new(root, x, y, Dat, _
            "channels", "0 4", _
            "line-type", "bezier 0.5", _
            "stroke_color", "red", _
             NULL)

goo_canvas_item_set_simple_transform(root, W / 2, h / 2, 1.0, 30.0)
