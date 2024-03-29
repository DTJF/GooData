' Example: Segmented Pie Graph
'
' A <link linkend="GooPie2d">GooPie2d</link> item type "default"
' pie charts can can get reduced to a limited area by <link linkend="GooPie2d--segmented">>setting a start ankle and an ankle range</link>.
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
            "line_width", line_group / 2, _
             NULL)

'~ the header line
VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Segmented Pie Graph" _
           !"</span>\n\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE1, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

'~ the pie chart
var grid = goo_pie2d_new(group, Dat, 0.0, 0.0, wdth, hght, _
            "channels", "0 1 2 3 4 5", _
            "segmented", "20 180", _
            "gaps", "0.005 0.3", _
            NULL)
