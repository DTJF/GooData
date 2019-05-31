VAR root = goo_canvas_group_new(Glob, _
            "line_width", line_group / 2, _
             NULL)

VAR title = goo_canvas_text_new(root, _
            "<span size=""xx-large"">" _
            "Pie Graph" _
           !"</span>\n\n", _
            0.0, 0.0, W, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE1, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

var grid = goo_pie2d_new(root, Dat, 0.0, 0.0, W, H, _
_            "channels", "b1 0 2 3 1", _
            "channels", "g 1 5", _
_            "format", "%.1g T€", _
            "segmented", "20 180", _
            "gaps", "5 40", _
_            "stroke_pattern", NULL, _
            NULL)
