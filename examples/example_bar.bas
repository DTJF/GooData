' Example: Simple Bar Graph
'
' A <link linkend="GooBar2d">GooBar2d</link> item type "default" from three channels
' each rectangle represents a value in Dat. The values in a row are grouped together.
'
'~Licence: GPLv3
'~(C) 2012-2022 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

'~ create the data
CONST cols = 5
DIM AS gdouble datas(..., cols) = _
  { _
    {0.1, 0.1 , 0.25, 0.4 , 0.0, 1.0 - _GOO_EPS} _
  , {0.3, 0.05, 0.7 , 0.05, 0.0, 0.0} _
  , {0.6, 0.1 , 0.8 , 0.05, 0.0, 0.0} _
  , {0.9, 0.05, 0.9 , 0.3 , 0.0, 0.0} _
  }
VAR az = UBOUND(datas, 1)
VAR Dat = goo_data_points_new(az + 1, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0, line_group = 2.0

'~ the group for all items
VAR group = goo_canvas_group_new(Glob, _
            "line_width", 1.0, _
             NULL)

'~ the header text line
VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Simple Bar Graph" _
           !"</span>\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE1, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

'~ the background item
VAR back = goo_canvas_rect_new(group, _
             0.0, 0.0, wdth, hght, _
            "fill_color", "#D7E1FE", _
            "stroke_pattern", NULL, _
             NULL)

'~ an axis for scaling
VAR axis = goo_axis_new(group, back, GOO_GRIDAXIS_EAST, "", _
            "range", "-.03 1", _
            "offset", "5", _
             NULL)

'~ customize the grid style
goo_axis_set_grid_properties(axis, _
            "line_width", 1.0, _
            "stroke_color", "grey", _
             NULL)

'~ create the bar chart
VAR bar = goo_bar2d_new(group, axis, Dat, _
            "channels", "0 3 1", _
            "gaps", "0.1 0.3", _
            "stroke_pattern", NULL, _
             NULL)
