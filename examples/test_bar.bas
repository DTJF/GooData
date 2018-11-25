'~This is file example_bar.bas
'
'~Licence: GPLv3
'~(C) 2012-2018 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

'~ create the data
CONST cols = 5
DIM AS GooType datas(..., cols) = _
  { _
    {0.1, 0.1 , 0.25, 0.4 , 0.0, 1.0 - GOO_EPS} _
  , {0.3, 0.05, 0.7 , 0.05, 0.0, 0.0} _
  , {0.6, 0.1 , 0.8 , 0.05, 0.0, 0.0} _
  , {0.9, 0.05, 0.9 , 0.3 , 0.0, 0.0} _
  }
VAR az = UBOUND(datas, 1)
VAR Dat = goo_data_points_new(az + 1, cols + 1, @datas(0, 0))
VAR wdth = 422.0, hght = 240.0, line_group = 1.0

'~ the group for all items
VAR group = goo_canvas_group_new(Glob, _
            "line_width", 1.0, _
             NULL)

'~ the headline
VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Horizontal Stacked Bar Graph" _
           !"</span>\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE, _
            "alignment", PANGO_ALIGN_CENTER, _
             NULL)

'~ the background box
VAR back = goo_canvas_rect_new(group, _
             0.0, 0.0, wdth, hght, _
            "fill_color", "#F7F19E", _
            "stroke_pattern", NULL, _
             NULL)

'~ a horizontal axis below the box
VAR y = goo_axis_new(group, back, GOO_GRIDAXIS_SOUTH, "Output [mV]", _
            "range", "-0.1 1.5", _
            "offset", "5", _
             NULL)

'~ the grid in the backgraound box
goo_axis_set_grid_properties(y, _
            "line_width", 1.0, _
            "stroke_color", "grey", _
             NULL)

'var sep = goo_set_decimal_separator()
'?sep,chr(sep),str(2.5)

var filler = goo_filler_new(4)
var cellview = gtk_cell_view_new()
var pixbuf = gtk_widget_render_icon(cellview, _
                                     GTK_STOCK_QUIT, GTK_ICON_SIZE_MENU, NULL)
goo_filler_set(filler, 0, "fill-pixbuf", pixbuf)
pixbuf = gtk_widget_render_icon(cellview, _
_                                GTK_STOCK_OPEN, GTK_ICON_SIZE_DIALOG, _
_                                GTK_STOCK_SAVE, GTK_ICON_SIZE_DIALOG, _
                                GTK_STOCK_REFRESH, GTK_ICON_SIZE_MENU, _
                                NULL)
goo_filler_set(filler, 1, "fill-pixbuf", pixbuf)
gtk_widget_destroy(cellview)


 '~ the bars
VAR z = goo_bar2d_new(group, y, Dat, _
            "channels", "Stacked 0 3 1", _
            "gaps", "50 40", _
_            "stroke_pattern", NULL, _
            "filler", filler, _
            NULL)
