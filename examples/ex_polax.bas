'~This is file example_curve_slope.bas
'
'~Licence: GPLv3
'~(C) 2012-2018 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net


' generate data
CONST cols = 2, l = 4 * ATN(1)
VAR i = 0
DIM AS GooType datas(168, cols)
FOR x AS GooType = -3 TO 3.1 STEP 0.5
  FOR y AS GooType = -3 TO 3.1 STEP 0.5
    datas(i, 0) = x
    datas(i, 1) = y
    datas(i, 2) = COS(x) * SIN(y)
    i += 1
  NEXT
NEXT
VAR Dat = goo_data_points_new(i, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0, line_group = 2.0


VAR group = goo_canvas_group_new(Glob, _
            "line_width", line_group, _
            "font", "Arial", _
             NULL)

VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">"_
            "Polar Axis" _
           !"</span>\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

VAR x = goo_Polax_new(group, 0.0, 0.0, wdth, hght, "R-Value", _
_            "range", "-3.3 3.3", _
            "segmented", "13 333", _
_            "ticks", "1", _
             NULL)
