'~This is file example_pie_simple.bas
'
'~Licence: GPLv3
'~(C) 2012-2020 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net


'~ create the data
CONST cols = 5
DIM AS GooFloat datas(..., cols) = _
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
            "line_width", line_group, _
             NULL)

'~ the header line
VAR title = goo_canvas_text_new(group, _
            "<span size=""xx-large"">" _
            "Simple Pie Graph" _
           !"</span>\n\n", _
            0.0, 0.0, wdth, GOO_CANVAS_ANCHOR_SW, _
            "use_markup", TRUE1, _
            "alignment", PANGO_ALIGN_CENTER, _
            NULL)


var filler = goo_filler_new(4)
var cellview = gtk_cell_view_new()
var pixbuf = gtk_widget_render_icon(cellview, _
                                     GTK_STOCK_QUIT, GTK_ICON_SIZE_DIALOG, NULL)
goo_filler_set(filler, 0, "fill-pixbuf", pixbuf)
pixbuf = gtk_widget_render_icon(cellview, _
                                GTK_STOCK_OPEN, GTK_ICON_SIZE_DIALOG, NULL)
goo_filler_set(filler, 1, "fill-pixbuf", pixbuf)
'~ pixbufs(2) = gtk_widget_render_icon(cellview, _
                                    '~ GTK_STOCK_SAVE, GTK_ICON_SIZE_DIALOG, NULL)
'~ pixbufs(3) = gtk_widget_render_icon(cellview, _
                                    '~ GTK_STOCK_REFRESH, GTK_ICON_SIZE_DIALOG, NULL)
gtk_widget_destroy(cellview)


'~ the pie chart
var grid = goo_pie2d_new(group, Dat, 0.0, 0.0, wdth, hght, _
_            "channels", "g 1 3 2 5", _
_            "channels", "p 0 2 3", _
_            "channels", "s 0 2 3", _
            "channels", "a 0  4 5", _
_            "channels", "v 0.5 0 1 2", _
_           "channels", "0 1 2", _
_            "channels", "c 0 4 5", _
_            "segmented", "115 36", _
            "gaps", "0.005 0 .3", _
            "filler", filler, _
            NULL)
