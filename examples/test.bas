#LIBPATH "../src"
#INCLUDE ONCE "../src/Goo_Data.bi"
#undef true
#define TRUE 1

'This handles button presses in item views. We simply output a message to
'the console.
FUNCTION on_rect_button_press(BYVAL item AS GooCanvasItem PTR, _
                              BYVAL target AS GooCanvasItem PTR, _
                              BYVAL event AS GdkEventButton PTR, _
                              BYVAL data_ AS gpointer) AS gboolean
  ?!"\nRect item received button press event: ";item,
  DIM AS GooFloat w
  'g_object_get(item, "width", @w, NULL)
'?w,
  'w += 100.0
'?w
  'g_object_set(item, "width", w, NULL)
  goo_canvas_item_translate(item, 10.0, 7.0)
  goo_canvas_item_scale(item, 1.3, 0.7)
  RETURN TRUE
END FUNCTION



' Initialize GTK+.
gtk_init (@__FB_ARGC__, @__FB_ARGV__)

' Create the window and widgets.
VAR win = gtk_window_new (GTK_WINDOW_TOPLEVEL)
gtk_window_set_default_size (GTK_WINDOW (win), 640, 600)
gtk_widget_show (win)
g_signal_connect (win, "delete_event", G_CALLBACK(@gtk_main_quit), NULL)

VAR scrolled_win = gtk_scrolled_window_new (NULL, NULL)
gtk_scrolled_window_set_shadow_type (GTK_SCROLLED_WINDOW (scrolled_win), _
                                     GTK_SHADOW_IN)
gtk_widget_show (scrolled_win)
gtk_container_add (GTK_CONTAINER (win), scrolled_win)

VAR canvas = goo_canvas_new ()
gtk_widget_set_size_request (canvas, 600, 450)
goo_canvas_set_bounds (GOO_CANVAS (canvas), 0, 0, 1000, 1000)
gtk_widget_show (canvas)
gtk_container_add (GTK_CONTAINER (scrolled_win), canvas)

VAR glob = goo_canvas_get_root_item(GOO_CANVAS (canvas))

'g_object_set(canvas, "automatic_bounds", TRUE, NULL)

'CONST az = 30
'VAR line_group = 1.0, l = 4 * ATN(1)
'VAR da = LA_M(az + 1, 3), f = 2 * l / IIF(az, az, 1)
'FOR i AS INTEGER = 0 TO az
  'VAR x = -l + i / az * 2 * l
  'da.Set_(i, 0, x)
  'da.Set_(i, 1, SIN(x))
  'da.Set_(i, 2, COS(x))
'NEXT
'VAR W = 422.0, H = 240.0
'VAR Tx = "angle <i>φ</i>", _
    'Ty = !"sin(<i>φ</i>)\ncos(<i>φ</i>)"

'CONST W = 422, H = 322
'#INCLUDE "example_simplecurve.bas"
'#INCLUDE "example_curve_markers.bas"
'#INCLUDE "example_curve_perpens.bas"
'#INCLUDE "example_curve_areas.bas"
'#INCLUDE "example_curve_helix.bas"
'#INCLUDE "example_curve_portfolio.bas"
'#INCLUDE "example_curve_erros.bas"
'#INCLUDE "example_curve_slope.bas"

'#INCLUDE "example_bar.bas"
'#INCLUDE "example_bar_stacked.bas"

'#INCLUDE "example_box_simple.bas"
'#INCLUDE "example_box_outliers.bas"

'#INCLUDE "example_pie_segments.bas"
'#INCLUDE "example_pie_simple.bas"
'#INCLUDE "example_pie_rings.bas"
'#INCLUDE "example_pie_avarage.bas"
'#INCLUDE "example_pie_stacked.bas"
'#INCLUDE "example_pie_percent.bas"

#INCLUDE "ex_pie_gantt.bas"
'#INCLUDE "ex_polax.bas"
'#INCLUDE "all.bas"
'#INCLUDE "test_pie.bas"
'#INCLUDE "test_bar.bas"
'#INCLUDE "test_polax.bas"


goo_canvas_update(GOO_CANVAS (canvas))
VAR bounds = GOO_CANVAS_ITEM_SIMPLE(group)->bounds
VAR tx = 5.0 - bounds.x1, ty = 5.0 - bounds.y1
goo_canvas_item_translate(group, tx, ty)

var w = bounds.x2 - bounds.x1 + 10.0, h = bounds.y2 - bounds.y1 + 10.0
var xxx = goo_canvas_rect_new(glob, 0.0, 0.0, w, h, _
                              "line_width", 1.0, _
                              "stroke_color", "green", _
                              NULL)

g_signal_connect(group, "button_press_event", _
                 G_CALLBACK(@on_rect_button_press), NULL)


'~ Pass control to the GTK+ main event loop.
gtk_main ()

