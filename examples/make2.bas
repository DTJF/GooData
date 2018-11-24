
goo_canvas_update(GOO_CANVAS(canvas))
VAR bounds = GOO_CANVAS_ITEM_SIMPLE(group)->bounds
VAR tx = rand - bounds.x1, ty = rand - bounds.y1

VAR w = bounds.x2 - bounds.x1 + 2 * rand, h = bounds.y2 - bounds.y1 + 2 * rand
DIM AS GooCanvasBounds drw = TYPE(0.0, 0.0, w, h)

var zzz = goo_canvas_group_new(glob, NULL)
g_object_set(group, "parent", zzz, NULL)
goo_canvas_item_translate(zzz, tx, ty)

VAR png = cairo_image_surface_create(CAIRO_FORMAT_RGB24, CUINT(w), CUINT(h))
VAR cst = cairo_create(png)
cairo_set_source_rgb(cst, 1.0, 1.0, 1.0)
cairo_paint(cst)
cairo_set_source_rgb(cst, 0.0, 0.0, 0.0)

goo_canvas_render(GOO_CANVAS(canvas), cst, @drw, 0.0)
cairo_surface_write_to_png(png, fname & ".png")

cairo_destroy(cst)
cairo_surface_destroy(png)


VAR scale = thumb / w
goo_canvas_item_scale(group, scale, scale)

goo_canvas_update(GOO_CANVAS(canvas))
bounds = GOO_CANVAS_ITEM_SIMPLE(group)->bounds
tx = rand - bounds.x1 : ty = rand - bounds.y1

goo_canvas_item_translate(zzz, tx, ty)



png = cairo_image_surface_create(CAIRO_FORMAT_RGB24, CUINT(thumb + rand), CUINT(h * scale + rand))
cst = cairo_create(png)
cairo_set_source_rgb(cst, 1.0, 1.0, 1.0)
cairo_paint(cst)
cairo_set_source_rgb(cst, 0.0, 0.0, 0.0)

goo_canvas_render(GOO_CANVAS(canvas), cst, @drw, 0.5)
cairo_surface_write_to_png(png, "t_" & fname & ".png")

cairo_destroy(cst)
cairo_surface_destroy(png)



gtk_widget_destroy(canvas)
