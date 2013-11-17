'~ See main file for licence information: GooData.bas
/'*
SECTION:Goo_Polax
@Title: GooPolax
@Short_Description: an axis and a background area to scale values
@Image: img/example_polax.bas.png

#GooPolax is a subclass of #GooCanvasGroup and so
inherits all of the style properties such as "stroke-color", "fill-color"
and "line-width". It also inherits the #GooCanvasItem interface, so you can
use the #GooCanvasItem functions such as goo_canvas_item_raise() or
goo_canvas_item_rotate().

To create a #GooPolax use goo_polax_new().

...


'/

#INCLUDE ONCE "Goo_Polax.bi"

STATIC SHARED _polax__update AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)
DECLARE SUB _polax_update CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

SUB _polax_item_interface_init CDECL( _
  BYVAL iface AS GooCanvasItemIface PTR) STATIC
  _polax__update = iface->update
  iface->update = @_polax_update
END SUB

G_DEFINE_TYPE_WITH_CODE(GooPolax, _goo_polax, GOO_TYPE_CANVAS_GROUP, _
       G_IMPLEMENT_INTERFACE(GOO_TYPE_CANVAS_ITEM, _polax_item_interface_init))

SUB _polax_finalize CDECL( _
  BYVAL Obj AS GObject PTR)
TRIN("")

  WITH *GOO_POLAX(Obj)
    IF .PSeg THEN g_free(.PSeg)
    IF .PTxt THEN g_free(.PTxt)
  END WITH

  G_OBJECT_CLASS(_goo_polax_parent_class)->finalize(Obj)

TROUT("")
END SUB

ENUM 
  GOO_POLAX_PROP_0
  GOO_POLAX_PROP_SEGM
END ENUM

'~ check background position and size, set clipping rectangle
SUB _polax_draw(BYVAL Polax AS GooPolax PTR)
TRIN("")

  WITH *Polax
    _GOO_EVAL_SEGMENT(.PSeg, angle, range)

    DIM AS _GooPolar back
    back.init(Polax, .Bx, .By, .Bb, .Bh, angle, range)

    VAR path = GOO_CANVAS_PATH(.Back)->path_data->path_commands
    back.segment(path, 0.0, 1.0, 0.0, 1.0)

    path = GOO_CANVAS_PATH(.Grid)->path_data->path_commands
'~ FOR i AS gdouble = 0.1 TO 0.9 step .1
  '~ back.line(path, i)
  '~ back.circle(path, i)
'~ NEXT
  END WITH

TROUT("")
END SUB

SUB _polax_update CDECL( _
  BYVAL item AS GooCanvasItem PTR, _
  BYVAL entire_tree AS gboolean, _
  BYVAL cr AS cairo_t PTR, _
  BYVAL bounds AS GooCanvasBounds PTR)
TRIN("")

  VAR simple = GOO_CANVAS_ITEM_SIMPLE(item)

  IF entire_tree ORELSE simple->need_update THEN _polax_draw(GOO_POLAX(item))
  _polax__update(item, entire_tree, cr, bounds)

TROUT("")
END SUB

SUB _polax_get_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  WITH *GOO_POLAX(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_POLAX_PROP_SEGM : g_value_set_string(Value, .PSeg)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

TROUT("")
END SUB

SUB _polax_set_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS CONST GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  VAR simple = CAST(GooCanvasItemSimple PTR, Obj)

  IF simple->model THEN _
      g_warning("Can't set property of a canvas item with a model - " _
                "set the model property instead") : EXIT SUB

  WITH *GOO_POLAX(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_POLAX_PROP_SEGM : g_free(.PSeg) : .PSeg = g_value_dup_string(Value)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

  goo_canvas_item_simple_changed(simple, TRUE)

TROUT("")
END SUB

SUB _goo_polax_class_init CDECL( _
  BYVAL Polax_class AS GooPolaxClass PTR)
TRIN("")

  VAR klass = G_OBJECT_CLASS(Polax_class)
  WITH *klass
  .finalize     = @_polax_finalize
  .get_property = @_polax_get_property
  .set_property = @_polax_set_property
  END WITH

  g_object_class_install_property(klass, GOO_POLAX_PROP_SEGM, _
     g_param_spec_string_("segmented", _
           __("SegmentOfPolarAxis"), _
           __("The segment where to place the polar axis in."), _
           NULL, _
           G_PARAM_READWRITE))
TROUT("")
END SUB

'~The standard object initialization function.
SUB _goo_polax_init CDECL( _
  BYVAL Polax AS GooPolax PTR)
TRIN("")

  WITH *Polax
    .PSeg = NULL
    .PTxt = NULL
  END WITH

TROUT("")
END SUB

/'* goo_polax_new:
@Parent: the parent item, or %NULL. If a parent is specified, it will assume
 ownership of the item, and the item will automatically be freed when it is
 removed from the parent. Otherwise call g_object_unref() to free it.
     @X: the x coordinate of the left top corner of the area for the pie chart.
     @Y: the y coordinate of the left top corner of the area for the pie chart
@Width_: the width of the area for the pie chart
@Height: the height of the area for the pie chart
  @Text: the label text for the axis. You can use Pango markup language to
         format the text.
   @...: optional pairs of property names and values, and a terminating %NULL.

Creates a new simple curve item.

The simple curve does support points scaled by one or two axis. If 
you need smooth lines, markers, error-markers, areas, perpendiculars
or vectors, have a look at #GooCurve2d.

To draw points only (and omit the lines between the points) a line
dash has to be set. It have to have exact two entries, the first is 0.0
and the second is greater than the sum of both axis length (the
height + width of the background box). Use
%CAIRO_LINE_CAP_ROUND or %CAIRO_LINE_CAP_SQUARE with
property #GooCanvasPolyline:line-cap to draw rounded or squared points.

Returns: (transfer full): a new Polax item.
Since: 0.0
'/
'~ '*
'~ * <!--PARAMETERS-->
'~ *
'~ * !!!Here's an example showing how to create a curve ... :
'~ *
'~ * <informalexample><programlisting>
'~ *  GooCurve2d *curve = goo_curve2d_new (mygroup, myXaxis, myYaxis, myData,
'~ *                                  "stroke_color", "red",
'~ *                                  "line_width", 5.0,
'~ *                                  "fill_color", "blue",
'~ *                                   NULL);
'~ * </programlisting></informalexample>
FUNCTION goo_polax_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL X AS GooType, _
  BYVAL Y AS GooType, _
  BYVAL Width_ AS GooType, _
  BYVAL Height AS GooType, _
  BYVAL Text AS gchar PTR, _
  ...) AS GooCanvasItem PTR
TRIN("")

  VAR polax = g_object_new(GOO_TYPE_POLAX, NULL)

  WITH *GOO_POLAX(polax)
    .Parent = Parent
    .Bx = X
    .By = Y
    .Bb = Width_
    .Bh = Height
    .PTxt = g_strdup(Text)

    .Textgr = goo_canvas_group_new(polax, NULL)
    .Label = goo_canvas_text_new(.Textgr, NULL, 0.0, 0.0, -1.0, 0, _
                                "alignment", PANGO_ALIGN_CENTER, _
                                "use-markup", TRUE, _
                                "wrap", PANGO_WRAP_WORD, _
                                NULL)
    .Back = goo_canvas_path_new(polax, NULL, NULL)
    .Ticktext = goo_canvas_group_new(.Textgr, NULL)
    .Grid = goo_canvas_path_new(polax, NULL, NULL)
    .Tick = goo_canvas_path_new(polax, NULL, NULL)
    .STick = goo_canvas_path_new(polax, NULL, NULL)

    VAR lw = 0.0
    g_object_get(.Parent, "line-width", @lw, NULL)
    g_object_set(.STick, "line-width", lw / 2, NULL)

  END WITH

  VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
  IF arg THEN g_object_set_valist(G_OBJECT(polax), arg, VA_NEXT(va, ANY PTR))

  IF Parent THEN
    goo_canvas_item_add_child(Parent, polax, -1)
    g_object_unref(polax)
  END IF

TROUT("")
  RETURN polax

END FUNCTION

