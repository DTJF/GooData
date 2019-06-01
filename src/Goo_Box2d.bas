'~ See main file for licence information: GooData.bas
/'*
SECTION:Goo_Box2d
@Title: GooBox2d
@Short_Description: box plot (scaled by a #GooAxis).
@Image: img/example_box_outliers.bas.png

#GooBox2d is a subclass of #GooCanvasGroup and so
inherits all of the style properties such as #GooCanvasGroup:stroke-color,
#GooCanvasGroup:fill-color and #GooCanvasGroup:line-width.
It also inherits the #GooCanvasItem interface, so you can
use the #GooCanvasItem functions such as goo_canvas_item_raise() or
goo_canvas_item_rotate().

To create a #GooBox2d use goo_box2d_new().

All box plots can be orientated in horizontal or vertical direction
depending on the axis used for scaling. A vertical axis (ie %GOO_AXIS_WEST
or %GOO_AXIS_EAST) causes boxes in vertical direction.

The #GooBox2d group contains these childs:
- a #GooCanvasPath for the whiskers
- a #GooCanvasPath for the boxes
- a #GooCanvasPath for the outliers

The childrens are drawn in the given order, so the outliers (if any)
will be on top and the whiskers
are in the background.

To set or get individual properties for the childs use the functions
goo_box2d_[get|set]_XYZ_properties with XYZ
for whiskers or outliers. The remaining item (boxes)
is contolled directly by the #GooBox2d properties.

'/

#INCLUDE ONCE "Goo_Glob.bi"
#INCLUDE ONCE "Goo_Axis.bi"
#INCLUDE ONCE "Goo_Box2d.bi"

STATIC SHARED _Box2d__update AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)
DECLARE SUB _box2d_update CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

SUB _box2d_item_interface_init CDECL( _
  BYVAL iface AS GooCanvasItemIface PTR) STATIC
  _Box2d__update = iface->update
  iface->update = @_box2d_update
END SUB

G_DEFINE_TYPE_WITH_CODE(GooBox2d, goo_box2d, GOO_TYPE_CANVAS_GROUP, _
       G_IMPLEMENT_INTERFACE(GOO_TYPE_CANVAS_ITEM, _box2d_item_interface_init))

SUB _box2d_finalize CDECL( _
  BYVAL Obj AS GObject PTR)
TRIN("")

  WITH *GOO_BOX2D(Obj)
    IF .Chan THEN g_free(.Chan)
    IF .Boxs THEN g_free(.Boxs)
    IF .Outl THEN g_free(.Outl)
    g_object_unref(.Axis)
    goo_data_points_unref(.Dat)
  END WITH

  G_OBJECT_CLASS(goo_box2d_parent_class)->finalize(Obj)

TROUT("")
END SUB

ENUM
  GOO_BOX2D_PROP_0
  GOO_BOX2D_PROP_CHAN
  GOO_BOX2D_PROP_BOXS
  GOO_BOX2D_PROP_OUTL
END ENUM

SUB _box2d_get_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  WITH *GOO_BOX2D(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_BOX2D_PROP_CHAN : g_value_set_string(Value, .Chan)
  CASE GOO_BOX2D_PROP_BOXS : g_value_set_string(Value, .Boxs)
  CASE GOO_BOX2D_PROP_OUTL : g_value_set_string(Value, .Outl)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

TROUT("")
END SUB

SUB _box2d_set_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS CONST GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  VAR simple = CAST(GooCanvasItemSimple PTR, Obj)

  IF simple->model THEN _
      g_warning("Can't set property of a canvas item with a model - " _
                "set the model property instead") : EXIT SUB

  WITH *GOO_BOX2D(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_BOX2D_PROP_CHAN : g_free(.Chan) : .Chan = g_value_dup_string(Value)
  CASE GOO_BOX2D_PROP_BOXS : g_free(.Boxs) : .Boxs = g_value_dup_string(Value)
  CASE GOO_BOX2D_PROP_OUTL : g_free(.Outl) : .Outl = g_value_dup_string(Value)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

  goo_canvas_item_simple_changed(simple, TRUE1)

TROUT("")
END SUB

FUNCTION _box2d_calc(BYVAL Box2d AS GooBox2d PTR) AS INTEGER
TRIN("")

  WITH *Box2d
    IF .Axis->Bx = .Bx ANDALSO _
       .Axis->By = .By ANDALSO _
       .Axis->Bb = .Bb ANDALSO _
       .Axis->Bh = .Bh THEN RETURN 0

    .Bx = .Axis->Bx
    .By = .Axis->By
    .Bb = .Axis->Bb
    .Bh = .Axis->Bh
    .Vertical = -(0 = BIT(.Axis->Mo, 0))
  END WITH : RETURN 1

TROUT("")
END FUNCTION

SUB _box2d_draw(BYVAL Box2d AS GooBox2d PTR)
TRIN("")

  WITH *Box2d
    g_object_set(.PBox, "data", NULL, NULL)
    VAR boxes = GOO_CANVAS_PATH(.PBox)->path_data->path_commands
    g_object_set(.PWis, "data", NULL, NULL)
    VAR whisk = GOO_CANVAS_PATH(.PWis)->path_data->path_commands
    g_object_set(.POut, "data", NULL, NULL)
    VAR outli = GOO_CANVAS_PATH(.POut)->path_data->path_commands
    VAR az = .Dat->Row - 1 : g_return_if_fail(az >= 4)
TRIN("1")
/'*
GooBox2d:channels:

The channels (columns) in the @Dat array
for the box chart.
This may contain
- no value to use the default channel (= 0). Example "" or %NULL.
- one or more values to set channels for a graph with one box
  for each column.
  Example: "7  9" to draw a graph with two boxes for channels 7
  and 9 in @Dat.

When a channel number is greater than the number of columns in @Dat
no box chart will be drawn.

Since: 0.0
'/
    VAR p = .Chan, nchannels = 0, chno = ""
    IF 0 = p ORELSE 0 = p[0] THEN
      chno = MKI(0)
    ELSE
      WHILE p
        VAR channel = CUINT(goo_value(p)) : IF 0 = p THEN EXIT WHILE
        g_return_if_fail(channel < .Dat->Col)
        chno &= MKI(channel)
        nchannels += 1
      WEND : g_return_if_fail(nchannels > 0)
      nchannels -= 1
    END IF
TRIN("2")
/'*
GooBox2d:boxes:

The style of the boxes and whiskers. By default the boxes fill 80
percent of the natural width (the place in the graph for one box),
they have no waist (0 percent) and the whisker lines are as long as
the boxes width (100 percent). These lenghts can be changed by this
property.
This may contain
- no value to use the default style. Example "" or %NULL.
- one value to set the width of the boxes as a factor of the natural
  width in the range of [0.0, 1.0].
  Example: "0.5" for 50 percent box width.
- two values to set the width and the waist of the box. The waist is
  specified as a factor of the box width in the range of [0.0, 1.0]
  and it defaults to 0.0. The size of the waist gets limited when
  there's not enough space in the box.
  Example: "0.5 0.6" for boxes 50 percent wide and with a waist of 60
  percent.
- three values to set width and waist of the box and the width of the
  whisker lines. The whisker width is
  specified as a factor of the box width in the range of [0.0, 1.0]
  and it defaults to 1.0.
  Example: "0.5 0.6 0.4" for a box 50 percent wide, 60
  percent waist and 40 percent whisker line width.

The minimum width of a box is 10 percent.

Since: 0.0
'/
    VAR o = IIF(.Vertical, .Bb, .Bh) / (nchannels + 1)
    VAR bb = 0.8 * o, bw = 0.0, wb = bb
    p = .Boxs
    IF p <> 0 ANDALSO p[0] <> 0 THEN
      VAR v = goo_value(p) : IF p THEN bb = o * CLAMP(v, 0.1, 1.0) : _
      v = goo_value(p) : IF p THEN bw = bb * (1 - CLAMP(v, 0.0, 1.0)) * 0.5 : _
      v = goo_value(p) : IF p THEN wb = bb * CLAMP(v, 0.0, 1.0)
      IF ABS(bw) < GOO_EPS THEN bw = 0.0
    END IF
TRIN("3")
/'*
GooBox2d:outliers:

The style of the outliers. Outliers occur when the lengths of the
whiskers are limited or when an amount of values is specified to be
outliers. The later is specified by the start letter 'p'.
Without this start letter the lengths of the whiskers are limited by
a multiple of the interquartile range (= IQR, also called the
midspread or middle fifty).
By default no outliers will be drawn.
This may contain
- no value to use the default outlier style. Example "" or %NULL.
- one value to set the length of the whiskers as a factor of the box
  length (IQR).
  Example: "0.5" to set the whiskers length to a maximum of 50
  percent IQR.
- two values to set the whiskers length and the markers size. The
  markers size is set as a faktor of the box width.
  Example: "0.5  0.2" for a whiskers length of 50 percent IQR and a
  markers size of 20 percent of the box width.
- three values to set whiskers length, markers size and markers type.
  The markers type is set as a %GooDataMarkers value.
  Example: "0.5  0.2  " & GOO_MARKER_CIRCLE for a whiskers length of 50
  percent IQR, a markers size of 20 percent of the box width and
  circled markers.
- 'P' as the start letter and one value to set the length of the whiskers
  as a factor of the box
  length (interquartile range = IQR, also called the midspread or
  middle fifty).
  Example: "0.5" to set the whiskers length to a maximum of 50
  percent IQR.
- 'P' as the start letter and two values to set the whiskers lengths
  and the markers size. The
  markers size is set as a faktor of the box width.
  Example: "0.5  0.2" for a whiskers length of 50 percent IQR and a
  markers size of 20 percent of the box width.
- 'P' as the start letter and three values to set whiskers lengths,
  markers size and markers type.
  The markers type is set as a %GooDataMarkers value.
  Example: "0.5  0.2  " & GOO_MARKER_CIRCLE for a whiskers length of 50
  percent IQR, a markers size of 20 percent of the box width and
  circled markers.

Since: 0.0
'/
    VAR wf = 0.0, ms = 0.2 * bb, mt = GOO_MARKER_CIRCLE
    p = .Outl
    IF p <> 0 ANDALSO p[0] <> 0 THEN
      VAR f = IIF(p[0] = ASC("P") ORELSE p[0] = ASC("p"), 1, -1)
      VAR v = goo_value(p)
      IF p THEN wf = IIF(ABS(v) > GOO_EPS, CLAMP(v, 0.0, 0.5) * f, 0.0) : _
        v = goo_value(p) : IF p THEN ms = bb * CLAMP(v, 0.0, 1.0) : _
        mt = CINT(goo_value(p))
    END IF
TRIN("4")

    VAR c = CAST(guint PTR, SADD(chno))
    VAR mid_i = az SHR 1, lbox_i = mid_i SHR 1, ubox_i = az - lbox_i
    DIM AS GooFloat PTR v(az)
    VAR s = .Dat->Col, e = .Dat->Dat + .Dat->Row * s - 1
    VAR x = IIF(.Vertical, .Bx, .By) + 0.5 * o
TRIN("5")

    FOR chan AS INTEGER = 0 TO nchannels
      VAR z = @v(0)
      FOR p AS GooFloat PTR = .Dat->Dat + c[chan] TO e STEP s
        *z = p
        z += 1
      NEXT : _Goo_Sort(@v(0), az)

      VAR bm = *v(mid_i)
      IF BIT(az, 0) THEN bm = 0.5 * (bm + *v(mid_i + 1))
      VAR bl = *v(lbox_i), bu = *v(ubox_i)
      IF BIT(mid_i, 0) THEN bl = 0.5 * (bl + *v(lbox_i + 1)) : bu = 0.5 * (bu + *v(ubox_i - 1))

      VAR wl = *v(0), wu = *v(az)
      IF wf > 0 THEN '~                     outliers by fixed percentage
        VAR d = CUINT(wf * az), dl = 0, du = az
        IF d >= lbox_i THEN d = lbox_i - 1
        FOR i AS UINTEGER = 0 TO d
          IF bl - *v(dl) > *v(du) - bu THEN
            IF .Vertical THEN
            _goo_add_marker(outli, x, .Axis->Pos(*v(dl)), mt, ms)
            ELSE
            _goo_add_marker(outli, .Axis->Pos(*v(dl)), x, mt, ms)
            END IF
            dl += 1
          ELSE
            IF .Vertical THEN
            _goo_add_marker(outli, x, .Axis->Pos(*v(du)), mt, ms)
            ELSE
            _goo_add_marker(outli, .Axis->Pos(*v(du)), x, mt, ms)
            END IF
            du -= 1
          END IF
        NEXT
        wl = *v(dl)
        wu = *v(du)
      ELSEIF wf < 0 THEN '~                       outliers by IQR factor
        wu = wf * (bl - bu)
        wl = bl - wu : IF wl < *v(0)  THEN wl = *v(0)
        wu += bu     : IF wu > *v(az) THEN wu = *v(az)
        FOR i AS UINTEGER = 0 TO az
          IF *v(i) >= wl THEN EXIT FOR
          IF .Vertical THEN
            _goo_add_marker(outli, x, .Axis->Pos(*v(i)), mt, ms)
          ELSE
            _goo_add_marker(outli, .Axis->Pos(*v(i)), x, mt, ms)
          END IF
        NEXT
        FOR i AS UINTEGER = az TO 0 STEP -1
          IF *v(i) <= wu THEN EXIT FOR
          IF .Vertical THEN
            _goo_add_marker(outli, x, .Axis->Pos(*v(i)), mt, ms)
          ELSE
            _goo_add_marker(outli, .Axis->Pos(*v(i)), x, mt, ms)
          END IF
        NEXT
      END IF

      bm = .Axis->Pos(bm)
      bl = .Axis->Pos(bl) : bu = .Axis->Pos(bu)
      wl = .Axis->Pos(wl) : wu = .Axis->Pos(wu)
      IF .Vertical THEN
        IF bw THEN '~                                      waisted boxes
          VAR p2 = ABS(bm - bl), p3 = ABS(bu - bm)
          VAR p1 = MIN(p2, p3)
          p1 = IIF(bw > p1, p1, bw) : p2 = 0.5 * bb : p3 = p2 - p1
          IF bu > bl THEN p1 *= -1
          _goo_add_path(boxes, ASC("M"), x - p3, bm)
          _goo_add_path(boxes, ASC("L"), x - p2, bm + p1)
          _goo_add_path(boxes, ASC("L"), x - p2, bl)
          _goo_add_path(boxes, ASC("h"), bb)
          _goo_add_path(boxes, ASC("L"), x + p2, bm + p1)
          _goo_add_path(boxes, ASC("L"), x + p3, bm)
          _goo_add_path(boxes, ASC("L"), x - p3, bm)
          _goo_add_path(boxes, ASC("L"), x - p2, bm - p1)
          _goo_add_path(boxes, ASC("L"), x - p2, bu)
          _goo_add_path(boxes, ASC("h"), bb)
          _goo_add_path(boxes, ASC("L"), x + p2, bm - p1)
          _goo_add_path(boxes, ASC("L"), x + p3, bm)
        ELSE '~                                      boxes without waist
          _goo_add_path(boxes, ASC("M"), x - 0.5 * bb, bm)
          _goo_add_path(boxes, ASC("v"), bl - bm)
          _goo_add_path(boxes, ASC("h"), bb)
          _goo_add_path(boxes, ASC("v"), bm - bl)
          _goo_add_path(boxes, ASC("h"),-bb)
          _goo_add_path(boxes, ASC("v"), bu - bm)
          _goo_add_path(boxes, ASC("h"), bb)
          _goo_add_path(boxes, ASC("v"), bm - bu)
        END IF
        _goo_add_path(whisk, ASC("M"), x - 0.5 * wb, wl)
        _goo_add_path(whisk, ASC("h"), wb)
        _goo_add_path(whisk, ASC("M"), x, wl)
        _goo_add_path(whisk, ASC("L"), x, bl)
        _goo_add_path(whisk, ASC("M"), x, bu)
        _goo_add_path(whisk, ASC("L"), x, wu)
        _goo_add_path(whisk, ASC("M"), x - 0.5 * wb, wu)
        _goo_add_path(whisk, ASC("h"), wb)
      ELSE '~                                                 horizontal
        IF bw THEN '~                                      waisted boxes
          VAR p2 = ABS(bm - bl), p3 = ABS(bu - bm)
          VAR p1 = MIN(p2, p3)
          p1 = IIF(bw > p1, p1, bw) : p2 = 0.5 * bb : p3 = p2 - p1
          IF bu < bl THEN p1 *= -1
          _goo_add_path(boxes, ASC("M"), bm     , x - p3)
          _goo_add_path(boxes, ASC("L"), bm - p1, x - p2)
          _goo_add_path(boxes, ASC("L"), bl     , x - p2)
          _goo_add_path(boxes, ASC("v"), bb)
          _goo_add_path(boxes, ASC("L"), bm - p1, x + p2)
          _goo_add_path(boxes, ASC("L"), bm     , x + p3)
          _goo_add_path(boxes, ASC("L"), bm     , x - p3)
          _goo_add_path(boxes, ASC("L"), bm + p1, x - p2)
          _goo_add_path(boxes, ASC("L"), bu     , x - p2)
          _goo_add_path(boxes, ASC("v"), bb)
          _goo_add_path(boxes, ASC("L"), bm + p1, x + p2)
          _goo_add_path(boxes, ASC("L"), bm     , x + p3)
        ELSE '~                                      boxes without waist
          _goo_add_path(boxes, ASC("M"), bm, x - 0.5 * bb)
          _goo_add_path(boxes, ASC("h"), bl - bm)
          _goo_add_path(boxes, ASC("v"), bb)
          _goo_add_path(boxes, ASC("h"), bm - bl)
          _goo_add_path(boxes, ASC("v"),-bb)
          _goo_add_path(boxes, ASC("h"), bu - bm)
          _goo_add_path(boxes, ASC("v"), bb)
          _goo_add_path(boxes, ASC("h"), bm - bu)
        END IF
        _goo_add_path(whisk, ASC("M"), wl, x - 0.5 * wb)
        _goo_add_path(whisk, ASC("v"), wb)
        _goo_add_path(whisk, ASC("M"), wl, x)
        _goo_add_path(whisk, ASC("L"), bl, x)
        _goo_add_path(whisk, ASC("M"), bu, x)
        _goo_add_path(whisk, ASC("L"), wu, x)
        _goo_add_path(whisk, ASC("M"), wu, x - 0.5 * wb)
        _goo_add_path(whisk, ASC("v"), wb)
      END IF
      x += o
    NEXT
  END WITH

TROUT("")
END SUB

SUB _box2d_update CDECL( _
  BYVAL item AS GooCanvasItem PTR, _
  BYVAL entire_tree AS gboolean, _
  BYVAL cr AS cairo_t PTR, _
  BYVAL bounds AS GooCanvasBounds PTR)
TRIN("")

  VAR box2d = GOO_BOX2D(item)
  VAR simple = GOO_CANVAS_ITEM_SIMPLE(item)

  WITH *box2d
    IF _box2d_calc(box2d) ORELSE entire_tree ORELSE simple->need_update THEN _box2d_draw(box2d)
    _Box2d__update(item, entire_tree, cr, bounds)
  END WITH

TROUT("")
END SUB

SUB goo_box2d_class_init CDECL( _
  BYVAL box2d_class AS GooBox2dClass PTR)
TRIN("")

  VAR klass = G_OBJECT_CLASS(box2d_class)
  WITH *klass
  .finalize     = @_box2d_finalize
  .get_property = @_box2d_get_property
  .set_property = @_box2d_set_property
  END WITH

  g_object_class_install_property(klass, GOO_BOX2D_PROP_CHAN, _
     g_param_spec_string("channels", _
           __("ColumnsInDat"), _
           __("The columns in Dat to draw the box plot from."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_BOX2D_PROP_BOXS, _
     g_param_spec_string("boxes", _
           __("BoxesStyle"), _
           __("The style of the box and whisker lines."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_BOX2D_PROP_OUTL, _
     g_param_spec_string("outliers", _
           __("OutliersStyle"), _
           __("The style of the points outside the whiskers."), _
           NULL, _
           G_PARAM_READWRITE))

TROUT("")
END SUB

'~The standard object initialization function.
SUB goo_box2d_init CDECL( _
  BYVAL Box2d AS GooBox2d PTR)
TRIN("")

  WITH *Box2d
    .Chan = NULL
    .Boxs = NULL
    .Outl = NULL
  END WITH

TROUT("")
END SUB

/'*
goo_box2d_get_whiskers_properties:
@Box2d: a #GooBox2d
  @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the whiskers #GooCanvasPath.

Since: 0.0
'/
/'*
goo_box2d_set_whiskers_properties:
@Box2d: a #GooBox2d
  @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the whiskers #GooCanvasPath.

Since: 0.0
'/
_GOO_DEFINE_PROP(box2d,Box2d,BOX2D,whiskers,PWis)

/'*
goo_box2d_get_outliers_properties:
@Box2d: a #GooBox2d
  @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the outliers #GooCanvasPath.

Since: 0.0
'/
/'*
goo_box2d_set_outliers_properties:
@Box2d: a #GooBox2d
  @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the outliers #GooCanvasPath.

Since: 0.0
'/
_GOO_DEFINE_PROP(box2d,Box2d,BOX2D,outliers,POut)

/'*
goo_box2d_new:
@Parent: the parent item, or %NULL. If a parent is specified, it will assume
 ownership of the item, and the item will automatically be freed when it is
 removed from the parent. Otherwise call g_object_unref() to free it.
  @Axis: the axis to scale the values
   @Dat: the data values to draw
   @...: optional pairs of property names and values, and a terminating %NULL.

Create a new box chart item from values in @Dat. By default channel 0 (zero) is
used. Specify an alternative set of channels by #GooBox2d:channels. Each row gets
one box, the boxes are all the same wide.

Since: 0.0
Returns: (transfer full): a new bar item.
'/
FUNCTION goo_box2d_new CDECL ALIAS "goo_box2d_new"( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Axis AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  ...) AS GooBox2d PTR EXPORT
TRIN("")

  g_return_val_if_fail(Dat > 0, NULL)
  g_return_val_if_fail(GOO_IS_AXIS(Axis), NULL)

  'VAR box2d = g_object_new(GOO_TYPE_BOX2D, NULL)
  'VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
  'IF arg THEN g_object_set_valist(box2d, arg, VA_NEXT(va, ANY PTR))
  _GOO_NEW_OBJECT(BOX2D,box2d,Dat)

  WITH *GOO_BOX2D(box2d)
    .Parent = Parent
    .Axis = Axis : g_object_ref(.Axis)
    .Dat = Dat : goo_data_points_ref(.Dat)

    .PWis = goo_canvas_path_new(box2d, NULL, NULL)
    .PBox = goo_canvas_path_new(box2d, NULL, _
_               "fill-rule", CAIRO_FILL_RULE_EVEN_ODD, _
               NULL)
    .POut = goo_canvas_path_new(box2d, NULL, NULL)
  END WITH

  IF Parent THEN
    goo_canvas_item_add_child(Parent, box2d, -1)
    g_object_unref(box2d)
  END IF

TROUT("")
  RETURN box2d
END FUNCTION
