#include <math.h>
#include <goodata.h>

int
main (int argc, char *argv[])
{
  GtkWidget *window, *scrolled_win, *canvas;
  GooCanvasItem *root, *group, *title, *grid, *x, *y, *c1, c2;

  /* Initialize GTK+. */
  gtk_init (&argc, &argv);

  /* Create the window and widgets. */
  window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_window_set_default_size (GTK_WINDOW (window), 640, 600);
  gtk_widget_show (window);
  g_signal_connect (window, "delete_event", (GtkSignalFunc) on_delete_event,
                    NULL);

  scrolled_win = gtk_scrolled_window_new (NULL, NULL);
  gtk_scrolled_window_set_shadow_type (GTK_SCROLLED_WINDOW (scrolled_win),
                                       GTK_SHADOW_IN);
  gtk_widget_show (scrolled_win);
  gtk_container_add (GTK_CONTAINER (window), scrolled_win);

  canvas = goo_canvas_new ();
  gtk_widget_set_size_request (canvas, 600, 450);
  goo_canvas_set_bounds (GOO_CANVAS (canvas), 0, 0, 1000, 1000);
  gtk_widget_show (canvas);
  gtk_container_add (GTK_CONTAINER (scrolled_win), canvas);

  root = goo_canvas_get_root_item (GOO_CANVAS (canvas));

  /* ********************************* */
  /* ***** Start of GooData code ***** */
  /* ********************************* */

  /* Generate data */
  int values = 31;
  gdouble Dat[values][3], vx, vy;
  for(int i = 0; i < values; i++)
    {
      vx = G_PI * (2 * i / (values - 1) - 1);
      vy = sin(vx);
      Dat[i][0] = vx;
      Dat[i][1] = vy * vy * vy;
      Dat[i][2] = vy;
    }

  /* Create a GooCanvasGroup for the grapgh */
  group = goo_canvas_group_new (Glob,
          "line_width", 1.0,
          "font", "Arial",
           NULL);

  /* Add a text for the title */
  title = goo_canvas_text_new (group,
          "<span size=\"xx-large\">"
          "Areas in a Grid Box"
          "</span>\n",
           0.0, 0.0, 400.0, GOO_CANVAS_ANCHOR_SW,
          "use_markup", TRUE,
          "alignment", PANGO_ALIGN_CENTER,
           NULL);

  /* Add a rectangle as background */
  grid = goo_canvas_rect_new (group,
           0.0, 0.0, 400.0, 300.0,
           NULL);

  /* Add an X-axis with a grid */
  x = goo_axis_new (group, grid, "angle <i>φ</i>", GOO_GRIDAXIS_SOUTH,
          "borders", "-3.3 3.3",
          "ticks", "1",
           NULL);

  /* Set the X-grid color */
  goo_axis_set_grid_properties (x,
          "stroke_color", "lightgray",
           NULL);

  /* Add an Y-axis with a grid */
  y = goo_axis_new (group, grid, "<span color=\"green\">sin <i>φ</i></span> "
          "<span color=\"red\">sin³ <i>φ</i></span>", GOO_GRIDAXIS_WEST,
          "text_offset", 7.,
          "borders", "-1.15 1.15",
          "ticks", ".5",
           NULL);

  /* Set the Y-grid color */
  goo_axis_set_grid_properties (y,
          "stroke_color", "lightgray",
           NULL);

  /* Add a curve with area, channels 0 and 2 */
  c1 = goo_curve_new (group, x, y, Dat,
          "channels", "0 2",
          "stroke_color", "green",
          "area", "Y0",
           NULL);

  /* Set the area fill color */
  goo_curve_set_area_properties (c1,
          "fill-color-rgba", 0x00C00030,
           NULL);

  /* Add a curve with area, channels 0 and 1 */
  c2 = goo_curve_new (group, x, y, Dat,
          "fill_color", "lightred",
          "stroke_color", "red",
          "area", "Y0",
           NULL);

  /* Set the area fill color */
  goo_curve_set_area_properties (c2,
          "fill-color-rgba", 0xC0000030,
           NULL);

  /* ********************************* */
  /* *****  End of GooData code  ***** */
  /* ********************************* */

  /* Move the group to the final position */
  goo_canvas_item_translate(group, 40.0, 90.0);

  /* Pass control to the GTK+ main event loop. */
  gtk_main ();

  return 0;
}

