'~ See main file for licence information: GooData.bas
/'*
SECTION:Goo_Simplecurve2d
@Title: GooSimpleCurve2d
@Short_Description: a simple curve scaled by at least one #GooAxis.
@Image: img/example_simplecurve.bas.png

#GooSimplecurve2d is a subclass of #GooCanvasPolyline and so
inherits all of the style properties such as "stroke-color", "fill-color"
and "line-width". It also inherits the #GooCanvasItem interface, so you can
use the #GooCanvasItem functions such as goo_canvas_item_raise() or
goo_canvas_item_rotate().

To create a #GooSimplecurve2d use goo_simplecurve2d_new().

The position and the scale of the curve are connected to the #GooAxis for X-
and Y direction. Also the transformation matrix of the #GooAxis is applied to
the #GooCurve2d. Note: it's not supported to move the #GooAxis
after creating the #GooSimplecurve2d. Instead put the background box,
the #GooAxis and the
 #GooSimplecurve2d in to a #GooCanvasGroup and move the entire group.

In contrast to the #GooCurve2d
the GooSimplecurve2d doesn't support smooth lines, markers, error-markers,
areas, perpendiculars or vectors. It's just a straight line between
some points. But it's faster and it consumes less
memory, so it should be prefered when you have to draw a huge amount
of of points.
'/

#INCLUDE ONCE "Goo_Simplecurve2d.bi"

STATIC SHARED _simplecurve2d__update AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)
DECLARE SUB _simplecurve2d_update CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

SUB _simplecurve2d_item_interface_init CDECL( _
  BYVAL iface AS GooCanvasItemIface PTR) STATIC
  _simplecurve2d__update = iface->update
  iface->update = @_simplecurve2d_update
END SUB

G_DEFINE_TYPE_WITH_CODE(GooSimplecurve2d, goo_simplecurve2d, GOO_TYPE_CANVAS_POLYLINE, _
       G_IMPLEMENT_INTERFACE(GOO_TYPE_CANVAS_ITEM, _simplecurve2d_item_interface_init))

SUB _simplecurve2d_finalize CDECL( _
  BYVAL Obj AS GObject PTR)
TRIN("")

  WITH *GOO_SIMPLECURVE2D(Obj)
    g_object_unref(.AxisX)
    g_object_unref(.AxisY)
    goo_data_points_unref(.Dat)
  END WITH

  G_OBJECT_CLASS(goo_simplecurve2d_parent_class)->finalize(Obj)

TROUT("")
END SUB

'~ check background position and size, set clipping rectangle
FUNCTION _simplecurve2d_calc(BYVAL Simple AS GooSimplecurve2d PTR) AS INTEGER
TRIN("")

  WITH *Simple
    DIM AS DOUBLE x, y, b, h
    .AxisX->Geo(x, b)
    .AxisY->Geo(y, h)
    IF x = .Bx ANDALSO _
       y = .By ANDALSO _
       b = .Bb ANDALSO _
       h = .Bh THEN RETURN 0

    .Bx = x
    .By = y
    .Bb = b
    .Bh = h
    g_object_set(Simple, _
                 "x", CAST(gdouble, .Bx), _
                 "y", CAST(gdouble, .By), _
                 "width", CAST(gdouble, .Bb), _
                 "height", CAST(gdouble, .Bh), _
                 NULL)
TROUT("")
  END WITH : RETURN 1

END FUNCTION

SUB _simplecurve2d_update CDECL( _
  BYVAL item AS GooCanvasItem PTR, _
  BYVAL entire_tree AS gboolean, _
  BYVAL cr AS cairo_t PTR, _
  BYVAL bounds AS GooCanvasBounds PTR)
TRIN("")

  VAR curve = GOO_SIMPLECURVE2D(item)
  VAR simple = GOO_CANVAS_ITEM_SIMPLE(item)

  WITH *curve
    IF _simplecurve2d_calc(curve) ORELSE entire_tree ORELSE simple->need_update THEN

      IF .ChX < .Dat->Col ANDALSO .ChY < .Dat->Col ANDALSO _
        (.ChX >= 0 ORELSE .ChY >= 0) THEN '~              channels valid

        VAR s = .Dat->Dat, d = .Dat->Col, az = .Dat->Row, e = s + d * az - 1
        VAR sx = .Bb / az, sy = .Bh / az, x = - sx / 2, y = -sy / 2
        VAR a = .parent_instance.polyline_data->coords
        FOR i AS GooFloat PTR = s TO e STEP d '~           set the points
          IF .ChX < 0 THEN x += sx ELSE x = .AxisX->Pos(i[.ChX])
          *a = x : a += 1
          IF .ChY < 0 THEN y += sy ELSE y = .AxisY->Pos(i[.ChY])
          *a = y : a += 1
        NEXT
      END IF
    END IF
    _simplecurve2d__update(item, entire_tree, cr, bounds)
  END WITH

TROUT("")
END SUB

SUB _simplecurve2d_paint CDECL( _
  BYVAL Simple AS GooCanvasItemSimple PTR, _
  BYVAL Cr AS cairo_t PTR, _
  BYVAL Bounds AS CONST GooCanvasBounds PTR)

  WITH *GOO_CANVAS_POLYLINE(Simple)->polyline_data

    cairo_new_path (Cr)
    IF .num_points = 0 THEN EXIT SUB

    VAR style = GOO_CANVAS_ITEM_SIMPLE(Simple)->simple_data->style
    VAR svalue = IIF(style, goo_canvas_style_get_property(style, goo_canvas_style_line_dash_id), 0)
    VAR dash = IIF(svalue, CAST(GooCanvasLineDash PTR, svalue->data(0).v_pointer), 0)
    VAR curve = GOO_SIMPLECURVE2D(Simple)

'~ we don't support arrows at the line ends
    VAR p = .coords
    cairo_move_to (Cr, p[0], p[1])
    p += 2
    IF 0 = dash ORELSE _
       dash->num_dashes <> 2 ORELSE _
       dash->dashes[0] <> 0.0 ORELSE _
       dash->dashes[1] < curve->Bb + curve->Bh THEN '~             lines
      FOR p = p TO p + 2 * (.num_points - 3) STEP 2
        cairo_line_to (Cr, p[0], p[1])
      NEXT
    ELSE '~                                                  points only
      FOR p = p TO p + 2 * (.num_points - 2) STEP 2
        cairo_line_to(Cr, p[0], p[1])
        cairo_rel_move_to(Cr, 0.0, 0.0)
      NEXT
    END IF

    IF .close_path THEN cairo_close_path(Cr)
  END WITH
  goo_canvas_item_simple_paint_path (Simple, Cr)

'~ we don't support arrows at the line ends
END SUB

SUB goo_simplecurve2d_class_init CDECL( _
  BYVAL Simple2d_class AS GooSimplecurve2dClass PTR)
TRIN("")

  G_OBJECT_CLASS(Simple2d_class)->finalize                   = @_simplecurve2d_finalize
  GOO_CANVAS_ITEM_SIMPLE_CLASS(Simple2d_class)->simple_paint = @_simplecurve2d_paint

TROUT("")
END SUB

'~The standard object initialization function.
SUB goo_simplecurve2d_init CDECL( _
  BYVAL Simple2d AS GooSimplecurve2d PTR)
TRIN("")

  WITH *Simple2d
  .ChX = -1
  .ChY = -1
  END WITH

TROUT("")
END SUB

/'*
goo_simplecurve2d_new:
@Parent: the parent item, or %NULL. If a parent is specified, it will assume
 ownership of the item, and the item will automatically be freed when it is
 removed from the parent. Otherwise call g_object_unref() to free it.
 @AxisX: the X axis to scale the data
 @AxisY: the Y axis to scale the data
   @Dat: the data values to draw
   @ChX: the channel number for X values in @Dat
   @ChY: the channel number for Y values in @Dat
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

Returns: (transfer full): a new Simplecurve2d item.
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
FUNCTION goo_simplecurve2d_new CDECL ALIAS "goo_simplecurve2d_new"( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL AxisX AS GooAxis PTR, _
  BYVAL AxisY AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  BYVAL ChX AS guint, _
  BYVAL ChY AS guint, _
  ...) AS GooCanvasItem PTR EXPORT
TRIN("")

  'VAR poly = g_object_new(GOO_TYPE_SIMPLECURVE2D, NULL)
  'VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
  'IF arg THEN g_object_set_valist(G_OBJECT(poly), arg, VA_NEXT(va, ANY PTR))
  _GOO_NEW_OBJECT(SIMPLECURVE2D,simplecurve2d,Chy)

  WITH *GOO_SIMPLECURVE2D(simplecurve2d)
    .Parent = Parent
    .AxisX = AxisX : g_object_ref(.AxisX)
    .AxisY = AxisY : g_object_ref(.AxisY)
    .Dat = Dat : goo_data_points_ref(.Dat)
    .ChX = ChX
    .ChY = ChY
    VAR points = goo_canvas_points_new(.Dat->Row)
    g_object_set(G_OBJECT(simplecurve2d), "points", points, NULL)
    goo_canvas_points_unref(points)
  END WITH

  IF Parent THEN
    goo_canvas_item_add_child(Parent, simplecurve2d, -1)
    g_object_unref(simplecurve2d)
  END IF

TROUT("")
  RETURN simplecurve2d

END FUNCTION

