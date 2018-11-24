#LIBPATH "../src"
#DEFINE CAIRO_HAS_PNG_FUNCTIONS 1
#INCLUDE ONCE "../src/Goo_Data.bi"


' Initialize GTK+.
gtk_init (@__FB_ARGC__, @__FB_ARGV__)

VAR canvas = goo_canvas_new ()
goo_canvas_set_bounds (GOO_CANVAS (canvas), 0, 0, 1000, 1000)
VAR glob = goo_canvas_get_root_item (GOO_CANVAS (canvas))

