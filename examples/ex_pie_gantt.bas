CONST cols = 5
DIM AS GooFloat datas(..., cols) = _
  { _
    {0.1, 0.1 , 0.25, 0.4 , 0.0, 1.0 - GOO_EPS} _
  , {0.3, 0.05, 0.7 , 0.05, 0.0, 0.0} _
  , {0.6, 0.1 , 0.8 , 0.05, 0.0, 0.0} _
  , {0.9, 0.05, 0.9 , 0.3 , 0.0, 0.0} _
  }

VAR az = UBOUND(datas, 1)
VAR Dat = goo_data_points_new(az + 1, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0, line_group = 1.0

VAR group = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
             NULL)

VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Gantt Pie Graph" _
           !"</span>\n\n", _
             0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

var grid = goo_pie2d_new(group, Dat, 0.0, 0.0, wdth, hght, _
            "channels", "G 1 3 5", _
_            "segmented", "20 180", _
            "gaps", "0.015 0.40", _
_            "stroke_pattern", NULL, _
             NULL)
