'~This is file example_complete.bas
'
'~Licence: GPLv3
'~(C) 2012 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

#INCLUDE ONCE "goodata.bi"

'~ initialize GTK+.
gtk_init (@__FB_ARGC__, @__FB_ARGV__)

'~ create the window
VAR window = gtk_window_new (GTK_WINDOW_TOPLEVEL)
gtk_window_set_default_size (GTK_WINDOW (window), 640, 600)
gtk_widget_show (window)
g_signal_connect (window, "delete_event", (GtkSignalFunc) on_delete_event, _
                  NULL)

'~ create a scrolable container
VAR scrolled_win = gtk_scrolled_window_new (NULL, NULL)
gtk_scrolled_window_set_shadow_type (GTK_SCROLLED_WINDOW (scrolled_win), _
                                     GTK_SHADOW_IN)
gtk_widget_show (scrolled_win)
gtk_container_add (GTK_CONTAINER (window), scrolled_win)

'~ create the GooCanvas
VAR canvas = goo_canvas_new ()
gtk_widget_set_size_request (canvas, 600, 450)
goo_canvas_set_bounds(GOO_CANVAS (canvas), 0, 0, 1000, 1000)
gtk_widget_show (canvas)
gtk_container_add(GTK_CONTAINER (scrolled_win), canvas)

'~ get the root item
VAR root = goo_canvas_get_root_item (GOO_CANVAS (canvas))

' *********************************
' ***** Start of GooData code *****
' *********************************

