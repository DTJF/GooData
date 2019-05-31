'~ See main file for licence information: GooData.bas
/'*
SECTION:Goo_Curve2d
@Title: GooCurve2d
@Short_Description: a curve on a rectangle background (scaled by at least one #GooAxis).
@Image: img/example_curve_areas.bas.png

#GooCurve2d is a subclass of #GooCanvasGroup and so
inherits all of the style properties such as "stroke-color", "fill-color"
and "line-width". It also inherits the #GooCanvasItem interface, so you can
use the #GooCanvasItem functions such as goo_canvas_item_raise() or
goo_canvas_item_rotate().

To create a #GooCurve2d use goo_curve2d_new().

Setting a style property on a #GooCurve2d will affect
all children in the #GooCurve2d group (unless the children override the
property setting).

The #GooCurve2d group contains these childs:
- a #GooCanvasPath for an area,
- a #GooCanvasPath for perpendicular lines,
- a #GooCanvasPath for the curve line
- a #GooCanvasPath for markers,
- a #GooCanvasPath for error lines,
- a #GooCanvasPath for vectors,

The childrens are drawn in the given order, so the vectors will be on top and the
area is in the background. It's unlikely to use all childs at once. By default
just the curve line gets drawn.

To set or get individual properties for the childs use the functions
goo_curve2d_[get|set]_XYZ_properties with XYZ
for area, perpens, markers, errors and vectors. The remaining item (curve line)
is contolled directly by the #GooCurve2d properties.

The position and the scale of the curve are connected to the #GooAxis for X-
and Y direction. Also the transformation matrix of the #GooAxis is applied to
the #GooCurve2d. Note: it's not supported to move the #GooAxis
after creating the #GooCurve2d. Instead put the background box, the #GooAxis and the
 #GooCurve2d in to a #GooCanvasGroup and move the entire group.
'/

#INCLUDE ONCE "Goo_Glob.bi"
#INCLUDE ONCE "Goo_Axis.bi"
#INCLUDE ONCE "Goo_Curve2d.bi"

STATIC SHARED _curve2d__update AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)
DECLARE SUB _curve2d_update CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

SUB _curve2d_item_interface_init CDECL( _
  BYVAL iface AS GooCanvasItemIface PTR) STATIC
  _curve2d__update = iface->update
  iface->update = @_curve2d_update
END SUB

G_DEFINE_TYPE_WITH_CODE(GooCurve2d, goo_curve2d, GOO_TYPE_CANVAS_GROUP, _
       G_IMPLEMENT_INTERFACE(GOO_TYPE_CANVAS_ITEM, _curve2d_item_interface_init))

SUB _curve2d_finalize CDECL( _
  BYVAL Obj AS GObject PTR)
TRIN("")

  WITH *GOO_CURVE2D(Obj)
    IF .Chan THEN g_free(.Chan)
    IF .ADir THEN g_free(.ADir)
    IF .ATyp THEN g_free(.ATyp)
    IF .Pers THEN g_free(.Pers)
    IF .Erro THEN g_free(.Erro)
    IF .Vect THEN g_free(.Vect)
    IF .Mark THEN g_free(.Mark)
    g_object_unref(.AxisX)
    g_object_unref(.AxisY)
    goo_data_points_unref(.Dat)
  END WITH

  G_OBJECT_CLASS(goo_curve2d_parent_class)->finalize(Obj)

TROUT("")
END SUB

ENUM
  GOO_CURVE2D_PROP_0
  GOO_CURVE2D_PROP_CHAN
  GOO_CURVE2D_PROP_PERS
  GOO_CURVE2D_PROP_ERRS
  GOO_CURVE2D_PROP_VECT
  GOO_CURVE2D_PROP_ATYP
  GOO_CURVE2D_PROP_ADIR
  GOO_CURVE2D_PROP_MARK
  GOO_CURVE2D_PROP_LTYP
END ENUM

'~ different line types
ENUM GooCurve2dFeatures
  CURVE2D_DEFAULT
  CURVE2D_PERPENS_H
  CURVE2D_PERPENS_V
  CURVE2D_MARKERS
  CURVE2D_VAR_PERPENS_H
  CURVE2D_VAR_PERPENS_V
  CURVE2D_VAR_MARKERS
  CURVE2D_LINE_HISTO_H
  CURVE2D_LINE_HISTO_V
  CURVE2D_ERRORS
  CURVE2D_SLOPE
  CURVE2D_VECTORS
  CURVE2D_LINE
  CURVE2D_QUADR
  CURVE2D_CUBIC
  CURVE2D_LINE_BACK
  CURVE2D_QUADR_BACK
  CURVE2D_CUBIC_BACK
  CURVE2D_LINE_BACK_X
  CURVE2D_QUADR_BACK_X
  CURVE2D_CUBIC_BACK_X
END ENUM

SUB _curve2d_get_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  WITH *GOO_CURVE2D(Obj)
    SELECT CASE AS CONST Prop_id
    CASE GOO_CURVE2D_PROP_CHAN : g_value_set_string(Value, .Chan)
    CASE GOO_CURVE2D_PROP_ATYP : g_value_set_string(Value, .ATyp)
    CASE GOO_CURVE2D_PROP_ADIR : g_value_set_string(Value, .ADir)
    CASE GOO_CURVE2D_PROP_ERRS : g_value_set_string(Value, .Erro)
    CASE GOO_CURVE2D_PROP_VECT : g_value_set_string(Value, .Vect)
    CASE GOO_CURVE2D_PROP_PERS : g_value_set_string(Value, .Pers)
    CASE GOO_CURVE2D_PROP_MARK : g_value_set_string(Value, .Mark)
    CASE GOO_CURVE2D_PROP_LTYP : g_value_set_string(Value, .LTyp)
    CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
    END SELECT
  END WITH

TROUT("")
END SUB

SUB _curve2d_set_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS CONST GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  VAR simple = CAST(GooCanvasItemSimple PTR, Obj)

  IF simple->model THEN _
      g_warning("Can't set property of a canvas item with a model - " _
                "set the model property instead") : EXIT SUB

  WITH *GOO_CURVE2D(Obj)
    SELECT CASE AS CONST Prop_id
    CASE GOO_CURVE2D_PROP_CHAN : g_free(.Chan) : .Chan = g_value_dup_string(Value)
    CASE GOO_CURVE2D_PROP_LTYP : g_free(.LTyp) : .LTyp = g_value_dup_string(Value)
    CASE GOO_CURVE2D_PROP_ATYP : g_free(.ATyp) : .ATyp = g_value_dup_string(Value)
    CASE GOO_CURVE2D_PROP_ADIR : g_free(.ADir) : .ADir = g_value_dup_string(Value)
    CASE GOO_CURVE2D_PROP_ERRS : g_free(.Erro) : .Erro = g_value_dup_string(Value)
    CASE GOO_CURVE2D_PROP_VECT : g_free(.Vect) : .Vect = g_value_dup_string(Value)
    CASE GOO_CURVE2D_PROP_PERS : g_free(.Pers) : .Pers = g_value_dup_string(Value)
    CASE GOO_CURVE2D_PROP_MARK : g_free(.Mark) : .Mark = g_value_dup_string(Value)
    CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
    END SELECT
  END WITH

  goo_canvas_item_simple_changed(simple, TRUE1)

TROUT("")
END SUB

'~ check background position and size, set clipping rectangle
FUNCTION _curve2d_calc(BYVAL Curve2d AS GooCurve2d PTR) AS INTEGER
TRIN("")

  WITH *Curve2d
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
    g_object_set(Curve2d, _
                 "x", .Bx, _
                 "y", .By, _
                 "width", .Bb, _
                 "height", .Bh, _
                 NULL)
TROUT("")
  END WITH : RETURN 1

END FUNCTION

'~ draw error lines (0=up, 1=down, 2=left, 3=right)
#MACRO _error_lines(_C_)
  IF echa[0] >= 0 THEN
    yn = ABS(.AxisY->VScale * _C_[echa[0]])
    _goo_add_path(path, ASC("M"), x + l, y - yn)
    _goo_add_path(path, ASC("h"), xa)
    _goo_add_path(path, ASC("m"), l, 0.0)
    _goo_add_path(path, ASC("v"), yn)
  END IF
  IF echa[1] >= 0 THEN
    yn = ABS(.AxisY->VScale * _C_[echa[1]])
    _goo_add_path(path, ASC("M"), x + l, y + yn)
    _goo_add_path(path, ASC("h"), xa)
    _goo_add_path(path, ASC("m"), l, 0.0)
    _goo_add_path(path, ASC("v"), -yn)
  END IF
  IF echa[2] >= 0 THEN
    xn = ABS(.AxisX->VScale * _C_[echa[2]])
    _goo_add_path(path, ASC("M"), x - xn, y + l)
    _goo_add_path(path, ASC("v"), xa)
    _goo_add_path(path, ASC("m"), 0.0, l)
    _goo_add_path(path, ASC("h"), xn)
  END IF
  IF echa[3] >= 0 THEN
    xn = ABS(.AxisX->VScale * _C_[echa[3]])
    _goo_add_path(path, ASC("M"), x + xn, y + l)
    _goo_add_path(path, ASC("v"), xa)
    _goo_add_path(path, ASC("m"), 0.0, l)
    _goo_add_path(path, ASC("h"), -xn)
  END IF
#ENDMACRO

'~ draw vector lines (channel 0=X, 1=Y)
#MACRO _vector_lines(_C_)
  xn = .AxisX->VScale * _C_[echa[0]]
  yn = .AxisY->VScale * _C_[echa[1]]
  _goo_add_path(path, ASC("M"), x, y)
  _goo_add_path(path, ASC("l"), xn, yn)
#ENDMACRO

'~ draw slope lines
#MACRO _slope_lines(_C_)
  xn = _C_[echa[0]]
  IF ABS(xn) <> GOO_DINF THEN
    yn = ATN(xn)
    xn = COS(yn) * l
    yn = SIN(yn) * l
  ELSE
    xn = 0 : yn = l
  END IF
  _goo_add_path(path, ASC("M"), x - xn / 2, y - yn / 2)
  _goo_add_path(path, ASC("l"), xn, yn)
#ENDMACRO

#DEFINE _move_line(_T_, _V_) _
  _goo_add_path(path, ASC("M"), x, y) : _
  _goo_add_path(path, ASC(_T_), _V_)

#DEFINE _line_line(_T1_, _V1_,_T2_, _V2_) _
  _goo_add_path(path, ASC(_T1_), _V1_) : _
  _goo_add_path(path, ASC(_T2_), _V2_)

#MACRO _bezier_start()
  _goo_add_path(path, ASC("M"), x, y)
  i = 0 : xa = x : ya = y
  DO '~                              find two further (non-equal) points
    s += d : g_return_if_fail(s >= .Dat->Dat ANDALSO s <= e)
    IF sx THEN x += sx ELSE x = .AxisX->Pos(s[kx])
    IF sy THEN y += sy ELSE y = .AxisY->Pos(s[ky])

    IF ABS(x - xa) > GOO_EPS ORELSE ABS(y - ya) > GOO_EPS THEN
      IF i THEN EXIT DO
      xn = xa : xa = x : yn = ya : ya = y : i = s
    END IF
  LOOP : s = i
  o->init(xa, ya, xn, yn)
  SELECT CASE AS CONST Mo '~                    start line drawing OUADR
  CASE CURVE2D_QUADR, CURVE2D_QUADR_BACK, CURVE2D_QUADR_BACK_X
    n->init(x, y, xa, ya)
    w = (o->w + n->w) / 2 + IIF(ABS(o->w - n->w) > GOO_PI, GOO_PI, 0.0)
    l = IIF(n->l > o->l, o->l, n->l) / 2
    _goo_add_path(path, ASC("Q"), xa - COS(w) * l, ya - SIN(w) * l, xa, ya)
  END SELECT
  x = xa
  y = ya
#ENDMACRO

#MACRO _bezier_cubic()
  n->init(x, y, o->x, o->y) '~                     continue line drawing
  w = (o->w + n->w) / 2 : IF ABS(o->w - n->w) > GOO_PI THEN w += GOO_PI
  yn = SIN(w) * befa
  xn = COS(w) * befa
  _goo_add_path(path, ASC("C"), _
                xa, ya, _
                o->x - xn * o->l, o->y - yn * o->l, _
                o->x, o->y)
  xa = o->x + xn * n->l
  ya = o->y + yn * n->l
  SWAP o, n
#ENDMACRO

'~ add objects to path (all line types)
SUB _curve2d CDECL( _
  BYVAL Curve2d AS GooCurve2d PTR, _
  BYVAL Item AS GooCanvasItem PTR, _
  BYVAL Mo AS UINTEGER = CURVE2D_DEFAULT, _
  ...)

  STATIC AS gdouble x, y, sx, sy, xa, ya, xn, yn, w, l, befa
  STATIC AS _goo_line old_, new_
  STATIC AS _goo_line PTR o = @old_, n = @new_
  STATIC AS guint az, ch
  STATIC AS GooFloat PTR s, e, i
  STATIC AS ANY PTR va
  STATIC AS gint PTR echa
  STATIC AS gint d, kx, ky
  STATIC AS GArray PTR path

  WITH *Curve2d
    path = GOO_CANVAS_PATH(Item)->path_data->path_commands
    s = .Dat->Dat : d = .Dat->Col : az = .Dat->Row : e = s + d * az - 1
    kx = .ChX : ky = .ChY ': va = VA_FIRST()
    DIM AS CVA_LIST args : CVA_START(args, Mo)

    SELECT CASE AS CONST Mo '~                      get extra parameters
    CASE CURVE2D_PERPENS_H :   xn = .AxisX->Pos(CVA_ARG(args, gdouble))
    CASE CURVE2D_PERPENS_V :   yn = .AxisY->Pos(CVA_ARG(args, gdouble))
    CASE CURVE2D_MARKERS   :    l = ABS(CVA_ARG(args, gdouble))
    CASE CURVE2D_VECTORS   : echa = CVA_ARG(args, gint PTR)
    CASE CURVE2D_SLOPE     : echa = CVA_ARG(args, gint PTR)
                           : l = CVA_ARG(args, gdouble)
    CASE CURVE2D_ERRORS    :   xa = CVA_ARG(args, gdouble)
                           : echa = CVA_ARG(args, gint PTR)
      l = xa / 2 : xa *= -1
    CASE CURVE2D_VAR_PERPENS_H, CURVE2D_VAR_PERPENS_V, CURVE2D_VAR_MARKERS
      ch = CVA_ARG(args, guint) : g_return_if_fail(Ch < .Dat->Col)
    CASE CURVE2D_CUBIC     : befa = CVA_ARG(args, gdouble)
      befa = CLAMP(befa, 0.0, 1.0) / 2
    CASE CURVE2D_LINE_BACK TO CURVE2D_CUBIC_BACK_X '~     swap direction
      SWAP s, e : d = -d
      IF Mo >= CURVE2D_LINE_BACK_X THEN
        kx = CVA_ARG(args, gint) : g_return_if_fail(kx < .Dat->Col)
      ELSE
        ky = CVA_ARG(args, gint) : g_return_if_fail(ky < .Dat->Col)
      END IF
      SELECT CASE AS CONST Mo '~                and get extra parameters
      CASE CURVE2D_CUBIC_BACK, CURVE2D_CUBIC_BACK_X
        befa = CVA_ARG(args, gdouble)
        befa = CLAMP(befa, 0.0, 1.0) / 2
      END SELECT
    END SELECT : CVA_END(args)

    sx = IIF(kx < 0, .Bb / az, 0.0)
    sy = IIF(ky < 0, .Bh / az, 0.0)
    x = IIF(sx, sx / 2, .AxisX->Pos(s[kx]))
    y = IIF(sy, sy / 2, .AxisY->Pos(s[ky]))

    SELECT CASE AS CONST Mo '~                    starting point or line
    CASE CURVE2D_LINE_HISTO_H  : xa = x : _goo_add_path(path, ASC("M"), x, y)
    CASE CURVE2D_LINE_HISTO_V  : ya = y : _goo_add_path(path, ASC("M"), x, y)
    CASE CURVE2D_PERPENS_H     : _move_line("H", xn)
    CASE CURVE2D_PERPENS_V     : _move_line("V", yn)
    CASE CURVE2D_VAR_PERPENS_H : _move_line("H", .AxisX->Pos(s[ch]))
    CASE CURVE2D_VAR_PERPENS_V : _move_line("V", .AxisY->Pos(s[ch]))
    CASE CURVE2D_MARKERS       : _goo_add_marker(path, x, y, .MType, l)
    CASE CURVE2D_VAR_MARKERS   : _goo_add_marker(path, x, y, .MType, s[ch] * .MScal)
    CASE CURVE2D_ERRORS
      _error_lines(s)
    CASE CURVE2D_VECTORS
      _vector_lines(s)
    CASE CURVE2D_SLOPE
      _slope_lines(s)
    CASE CURVE2D_QUADR, CURVE2D_QUADR_BACK, CURVE2D_QUADR_BACK_X, _
         CURVE2D_CUBIC, CURVE2D_CUBIC_BACK, CURVE2D_CUBIC_BACK_X
      _bezier_start()
    CASE ELSE
      _goo_add_path(path, ASC("M"), x, y)
    END SELECT

    FOR i = s + d TO e STEP d '~                         draw the points
      IF sx THEN x += sx ELSE x = .AxisX->Pos(i[kx])
      IF sy THEN y += sy ELSE y = .AxisY->Pos(i[ky])

      SELECT CASE AS CONST Mo
      CASE CURVE2D_PERPENS_H     : _move_line("H", xn)
      CASE CURVE2D_PERPENS_V     : _move_line("V", yn)
      CASE CURVE2D_VAR_PERPENS_H : _move_line("H", .AxisX->Pos(i[ch]))
      CASE CURVE2D_VAR_PERPENS_V : _move_line("V", .AxisY->Pos(i[ch]))
      CASE CURVE2D_LINE_HISTO_H  : _line_line("H", (x + xa) / 2, "V", y) : xa = x
      CASE CURVE2D_LINE_HISTO_V  : _line_line("V", (y + ya) / 2, "H", x) : ya = y
      CASE CURVE2D_MARKERS       : _goo_add_marker(path, x, y, .MType, l)
      CASE CURVE2D_VAR_MARKERS   : _goo_add_marker(path, x, y, .MType, i[ch] * .MScal)
      CASE CURVE2D_VECTORS
        _vector_lines(i)
      CASE CURVE2D_SLOPE
        _slope_lines(i)
      CASE CURVE2D_ERRORS
        _error_lines(i)
      CASE CURVE2D_LINE, CURVE2D_LINE_BACK, CURVE2D_LINE_BACK_X
        _goo_add_path(path, ASC("L"), x, y)
      CASE CURVE2D_QUADR, CURVE2D_QUADR_BACK, CURVE2D_QUADR_BACK_X
        IF ABS(x - xa) > GOO_EPS ORELSE ABS(y - ya) > GOO_EPS THEN
          xa = x
          ya = y
          _goo_add_path(path, ASC("T"), x, y)
        END IF
      CASE CURVE2D_CUBIC, CURVE2D_CUBIC_BACK, CURVE2D_CUBIC_BACK_X
        IF ABS(x - o->x) > GOO_EPS ORELSE ABS(y - o->y) > GOO_EPS THEN
          _bezier_cubic()
        END IF
      CASE ELSE : g_return_if_reached()
      END SELECT
    NEXT

    SELECT CASE AS CONST Mo '~                              special ends
    CASE CURVE2D_LINE_HISTO_H : _goo_add_path(path, ASC("H"), x)
    CASE CURVE2D_LINE_HISTO_V : _goo_add_path(path, ASC("V"), y)
    CASE CURVE2D_CUBIC, CURVE2D_CUBIC_BACK, CURVE2D_CUBIC_BACK_X
      _goo_add_path(path, ASC("C"), xa, ya, o->x, o->y, o->x, o->y)
    END SELECT
  END WITH
END SUB

/'*
GooCurve2d:line-type:

The type of the curve line. This may contain:
- no value to draw the curve by straight lines between the points in @Dat.
  Example "" or %NULL.
- 'N' as the start letter to draw no curve. Example: "n" or "none".
- 'H' as the start letter to draw a stepped curve (histrogram style), starting
  with a horizontal line. Example: "h" or "Horizontal".
- 'V' as the start letter to draw a stepped curve (histrogram style), starting
  with a vertical line. Example: "v" or "Vertical".
- 'B' as the start letter to draw a smooth curve by a quadratic bezier curve.
  Example: "b" or "bezier".
- 'B' as the start letter and a value in the range [0,1] to draw a smooth curve
  by a cubic bezier curve with (if the value is outside the
  range it will be set to the nearest border).
  Example: "b 0.6" or "bezier 0.6".

In case of a cubic bezier curve the value sets a form factor, used to specify
the distance of the computed bezier points from the given curve points. A high
form factor makes the line moderately curved at the @Dat points. The factor
1.0 sets a distance of 50 % of the line length between the @Dat points.
The factor 0.0 sets no distance between curve points and bezier points
(equals to a straight line).

Since: 0.0
'/
SUB _curve2d_cline(BYVAL Curve2d AS GooCurve2d PTR)
TRIN("")

  WITH *Curve2d
    g_object_set(.CLine, "data", NULL, NULL)
    VAR p = .LTyp
    IF p = 0 ORELSE p[0] = 0 THEN
      _curve2d(curve2d, .CLine, CURVE2D_LINE)
    ELSE
      SELECT CASE AS CONST .LTyp[0]
      CASE ASC("N"), ASC("n") : EXIT SUB
      CASE ASC("H"), ASC("h") : _curve2d(curve2d, .CLine, CURVE2D_LINE_HISTO_H)
      CASE ASC("V"), ASC("v") : _curve2d(curve2d, .CLine, CURVE2D_LINE_HISTO_V)
      CASE ASC("B"), ASC("b")
        VAR v = goo_value(p)
        IF p THEN _curve2d(curve2d, .CLine, CURVE2D_CUBIC, v) _
             ELSE _curve2d(curve2d, .CLine, CURVE2D_QUADR)
      CASE ELSE
        g_warning("GooCurve2d: no valid line-type property") : EXIT SUB
      END SELECT
    END IF
  END WITH

TROUT("")
END SUB

/'*
GooCurve2d:area-linetype:

The type of the areas curve line (ignored if #GooData:area-direction is unset).
This may contain:
- no value to draw the area curve by straight lines between the points in @Dat.
  Example "" or %NULL.
- 'H' as the start letter to draw a stepped curve (histrogram style), starting
  with a horizontal line. Example: "h" or "Horizontal".
- 'V' as the start letter to draw a stepped curve (histrogram style), starting
  with a vertical line. Example: "v" or "Vertical".
- 'B' as the start letter to draw a smooth curve (smoothing by a quadratic bezier
  curve). Example: "b" or "bezier".
- 'B' as the start letter and a value in the range [0,1] to draw a smooth curve
  (smoothing by cubic bezier curve). The value specifies a smoothing factor.
  The bigger the value the smoother the line at the points. If the value is
  outside the range it will be set to the nearest border. For details see
  #GooData:line-type. Example: "b 0.6" or "bezier 0.6".

Since: 0.0
'/

/'*
GooCurve2d:area-direction:

Draw a colored area from the curve to a given line.
This may contain
- no value to draw no area (= default). Example "" or %NULL
- one of the start letters 'n', 'w', 's', 'e' (for north, west, ...) to draw
  the area to the given border of the background box. Example: "e" or "east".
- 'X' as the start letter and a value to draw the area to the given value
  at the X-axis. Example: "x 1.5".
- 'Y' as the start letter and a value to draw the area to the given value
  at the Y-axis. Example: "y 1.5".
- 'H' as the start letter and a value to draw the area to the X-value of
  the given channel in @Dat (the area is between both curves in horizontal
  direction). Example: "h 3"
- 'V' as the start letter and a value to draw the area to the Y-value of
  the given channel in @Dat (the area is between both curves in vertical
  direction). Example: "v 3"

Since: 0.0
'/
SUB _curve2d_area(BYVAL Curve2d AS GooCurve2d PTR)
  WITH *Curve2d
    g_object_set(.CArea, "data", NULL, NULL)
    IF 0 = .ADir ORELSE .ADir[0] = 0 THEN EXIT SUB

    VAR typ = CURVE2D_LINE, befa = 0.0
    IF .ATyp <> 0 ANDALSO .ATyp[0] <> 0 THEN
      VAR p = .ATyp : befa = goo_value(p)
      SELECT CASE AS CONST .ATyp[0]
      CASE ASC("H"), ASC("h") : typ = CURVE2D_LINE_HISTO_H
      CASE ASC("V"), ASC("v") : typ = CURVE2D_LINE_HISTO_V
      CASE ASC("B"), ASC("b") : typ = IIF(p, CURVE2D_CUBIC, CURVE2D_QUADR)
      END SELECT
    END IF
    _curve2d(curve2d, .CArea, typ, befa)

    VAR d = 2 * .Dat->Row, p = .ADir, v = goo_value(p)
    VAR path = GOO_CANVAS_PATH(.CArea)->path_data->path_commands
    SELECT CASE AS CONST .ADir[0]
    CASE ASC("H"), ASC("h"), ASC("V"), ASC("v")
      typ += IIF(.ADir[0] = ASC("H") ORELSE .ADir[0] = ASC("h"), 6, 3)
      _curve2d(curve2d, .CArea, typ, CINT(v), befa)

    CASE ASC("X"), ASC("x")
      var e = IIF(.ChY < 0, .Bh / d, .AxisY->Pos(.Dat->Dat[.ChY]))
      _line_line("H", .AxisX->Pos(v), "V", e)
    CASE ASC("Y"), ASC("y") :
      var e = IIF(.ChX < 0, .Bb / d, .AxisX->Pos(.Dat->Dat[.ChX]))
      _line_line("V", .AxisY->Pos(v), "H", e)

    CASE ASC("S"), ASC("s")
      v = IIF(.ChX < 0, .Bb / d, .AxisX->Pos(.Dat->Dat[.ChX]))
      _line_line("V", .Bh, "H", v)
    CASE ASC("N"), ASC("n")
      v = IIF(.ChX < 0, .Bb / d, .AxisX->Pos(.Dat->Dat[.ChX]))
      _line_line("V", 0.0, "H", v)
    CASE ASC("E"), ASC("e")
      v = IIF(.ChY < 0, .Bh / d, .AxisY->Pos(.Dat->Dat[.ChY]))
      _line_line("H", .Bb, "V", v)
    CASE ASC("W"), ASC("w")
      v = IIF(.ChY < 0, .Bh / d, .AxisY->Pos(.Dat->Dat[.ChY]))
      _line_line("H", 0.0, "V", v)

    CASE ELSE
      g_warning("GooCurve2d: no valid area property") : EXIT SUB
    END SELECT
    _goo_add_path(path, ASC("z"))
  END WITH

TROUT("")
END SUB

/'*
GooCurve2d:perpendiculars:

Draw perpendiculars from the curve points to a given direction and value.
This may contain
- no value to draw no perpendiculars (= default). Example "" or %NULL
- one of the start letters 'n', 'w', 's', 'e' (for north, west, ...) to draw
  perpendiculars to the given border of the background box. Example: "e" or "east".
- 'X' as the start letter and a value to draw perpendiculars to the given value
  at the X-axis. Example: "x -1.5".
- 'Y' as the start letter and a value to draw perpendiculars to the given value
  at the Y-axis. Example: "y -1.5".
- 'H' as the start letter and a value to draw perpendiculars to the X-value of
  the given channel in @Dat (the perpendiculars are between both curves in horizontal
  direction). Example: "H 3"
- 'V' as the start letter and a value to draw perpendiculars to the Y-value of
  the given channel in @Dat (the perpendiculars are between both curves in vertical
  direction). Example: "V 3"

Since: 0.0
'/
SUB _curve2d_perpens(BYVAL Curve2d AS GooCurve2d PTR)
TRIN("")
  WITH *Curve2d
    g_object_set(.CPerp, "data", NULL, NULL)
    IF 0 = .Pers ORELSE .Pers[0] = 0 THEN EXIT SUB

    VAR x = .Pers, v = goo_value(x)
    SELECT CASE AS CONST .Pers[0]
    CASE ASC("H"), ASC("h") : _curve2d(curve2d, .CPerp, CURVE2D_VAR_PERPENS_H, CUINT(v))
    CASE ASC("V"), ASC("v") : _curve2d(curve2d, .CPerp, CURVE2D_VAR_PERPENS_V, CUINT(v))
    CASE ASC("S"), ASC("s") : _curve2d(curve2d, .CPerp, CURVE2D_PERPENS_V, .Bh)
    CASE ASC("N"), ASC("n") : _curve2d(curve2d, .CPerp, CURVE2D_PERPENS_V, 0.0)
    CASE ASC("E"), ASC("e") : _curve2d(curve2d, .CPerp, CURVE2D_PERPENS_H, .Bb)
    CASE ASC("W"), ASC("w") : _curve2d(curve2d, .CPerp, CURVE2D_PERPENS_H, 0.0)
    CASE ASC("X"), ASC("x") : _curve2d(curve2d, .CPerp, CURVE2D_PERPENS_H, .AxisX->Pos(v))
    CASE ASC("Y"), ASC("y") : _curve2d(curve2d, .CPerp, CURVE2D_PERPENS_V, .AxisY->Pos(v))
    CASE ELSE
      g_warning("GooCurve2d: no valid perpendiculars property") : EXIT SUB
    END SELECT
  END WITH

TROUT("")
END SUB

/'*
GooCurve2d:errors:

The size and the channels for error markers. An error marker is a
T-shaped line drawn in positive or negative X- or Y-direction to
show the possible error at a point. Each direction may have its
own channel in @Dat. But the same channel also can be used to draw error
markers equidistantly in more than one direction. This may contain:
- no value to draw no error lines (= default). Example "" or %NULL
- one value for the line size and one channel to drawn error lines equidistantly
  above and below the point.
- one value for the line size and two channels to drawn error lines
  above and below the point. The first channel sets the distance for the upper line
  and the second channel sets the lower error line.
- one value for the line size and three channels to drawn error lines
  above and below the point and equidistantly to the left and right. The first
  two channels set the vertical distances
  and the third channel sets the equidistant right and left error line.
- one value for the line size and four channels to drawn individual error lines
  above, below, left and right the point. The first pair of
  channels set the vertical distances
  and the second pair set the horizontal distances of the error lines.

The size value has to be set for each direction. It specifies the width
of the T-shaped line in global scale. If the
size is smaller or equal to 0.0 the default value of 8.0 is set.

The distances of the error lines are scalled by the corresponding #GooAxis,
so @Dat should contain the error values in the same scale as the points. Note:
you can use variable sized markers (property #GooCurve2d:marker-size with start
letter 'c') to show an error range in global scale.

To omit the error lines in one direction set the corresponding channel to -1.

Negative values in the @Dat error channels will be scaled by -1 before
drawing the error markers.

Since: 0.0
'/
SUB _curve2d_errors(BYVAL Curve2d AS GooCurve2d PTR)
TRIN("")

  WITH *Curve2d
    g_object_set(.CErrs, "data", NULL, NULL)
    IF 0 = .Erro ORELSE .Erro[0] = 0 THEN EXIT SUB

    VAR fl = 0, p = .Erro, v = ABS(goo_value(p))
    DIM AS gint c(3)
    FOR i AS INTEGER = 0 TO 3
      c(i) = IIF(p, CINT(goo_value(p)), -1)
      IF p THEN IF c(i) < .Dat->Col THEN fl += 1 ELSE c(i) = -1
    NEXT
    SELECT CASE AS CONST fl
    CASE 0
      g_warning("GooCurve2d: no valid error channels") : EXIT SUB
    CASE 1 : c(1) = c(0)
    CASE 3 : c(3) = c(2)
    END SELECT
    IF v < GOO_EPS THEN v = 8.0
    _curve2d(curve2d, .CErrs, CURVE2D_ERRORS, v, @c(0))
  END WITH

TROUT("")
END SUB

/'*
GooCurve2d:vectors:

The channels for vectors. A vector can either be a vector or a slope
line. A vector is a straight line drawn from a point to a second point,
specified by the X- and Y-value of two vector channels. A slope line
is a line centered at a point with a given slope value red from a channel
in @Dat.

This may contain:
- no value to draw no vector lines (= default). Example "" or %NULL
- two values for the channels in @Dat to read the difference vector
  from.
- 'S' as the start letter and one or two values for the channel in @Dat
  to read slope value and the optional length of the slope line
  (defaults to 8).

The difference vectors are scalled by the corresponding #GooAxis,
so @Dat should contain the vector values in the same scale as the points.

Since: 0.0
'/
SUB _curve2d_vectors(BYVAL Curve2d AS GooCurve2d PTR)
TRIN("")

  WITH *Curve2d
    g_object_set(.CVect, "data", NULL, NULL)
    IF 0 = .Vect ORELSE .Vect[0] = 0 THEN EXIT SUB

    VAR p = .Vect
    DIM AS gint c(1)
    c(0) = CINT(goo_value(p))
    IF c(0) < .Dat->Col THEN
      SELECT CASE AS CONST .Vect[0]
      CASE ASC("S"), ASC("s")
        VAR l = goo_value(p) : IF l <= 0 THEN l = 8.0
        _curve2d(curve2d, .CVect, CURVE2D_SLOPE, @c(0), l)
        EXIT SUB
      CASE ELSE
        c(1) = CINT(goo_value(p)) : IF c(1) >= .Dat->Col THEN EXIT SELECT
        _curve2d(curve2d, .CVect, CURVE2D_VECTORS, @c(0))
        EXIT SUB
      END SELECT
    END IF
    g_warning("GooCurve2d: no valid vector channel[s]")
  END WITH

TROUT("")
END SUB

/'*
GooCurve2d:markers:

The size and the type of the markers.
This may contain
- no value for no markers: Example: %NULL or "".
- one value for markers in this fixed size, scaled in global scaling. Example: "14"
- two values for fixed marker size (global scaling) and marker type
  (%GooDataMarkers). Example: "14 " & GOO_MARKER_CROSS
- 'C' as the start letter and a value to set a channel to read the
  marker size from. The markers will be variable scaled by the values of
  the given channel in @Dat. Global scalling is used as in the #GooCanvas
  (neither the X- nor the Y-axis scaling are used).
  Example "Channel 3" to read the marker size from channel 3 in @Dat.
- 'C' as the start letter and two values to set a channel
  (marker size) and the marker type.
  Example "Channel 2 " & GOO_MARKER_FLOWER to generate flower markers
  for size values red from channel 2 in @Dat.
- 'C' as the start letter and three values to set a channel
  (marker size), the marker type and a scaling factor.
  Example "Channel 2 " & GOO_MARKER_CIRCLE & " 3.5" to generate circle
  markers of the size values red from channel 2 in @Dat and scaled by 3.5.
- 'D' as the start letter to generate default markers (%GOO_MARKER_CIRCLE)
  in default size (8.0). Example "d" or "Default"
- 'D' as the start letter and a marker type (%GooDataMarkers) to generate
  the specified marker type in default size (8.0).
  Example "d " & GOO_MARKER_CROSS

 If the marker type specification (if any) is outside the range of
 %GooDataMarkers the standard marker type is used (%GOO_MARKER_CIRCLE).

Since: 0.0
'/
SUB _curve2d_markers(BYVAL Curve2d AS GooCurve2d PTR)
TRIN("")
  WITH *Curve2d
    g_object_set(.CMark, "data", NULL, NULL)
    IF .Mark = 0 ORELSE .Mark[0] = 0 THEN EXIT SUB

    VAR p = .Mark
    SELECT CASE AS CONST .Mark[0]
    CASE ASC("C"), ASC("c")
      VAR ch = CINT(goo_value(p)) : g_return_if_fail(ch >= 0)
      .MType = IIF(p, CINT(goo_value(p)), GOO_MARKER_CIRCLE)
      .MScal = IIF(p, ABS(goo_value(p)), 1.0)
      IF p = 0 THEN .MScal = 1.0 ELSE g_return_if_fail(.MScal > GOO_EPS)
      _curve2d(curve2d, .CMark, CURVE2D_VAR_MARKERS, ch)
    CASE ASC("D"), ASC("d")
      .MType = CINT(goo_value(p))
      _curve2d(curve2d, .CMark, CURVE2D_MARKERS, 8.0)
    CASE ELSE
      VAR size = ABS(goo_value(p))
      IF p THEN .MType = CINT(goo_value(p)) ELSE size = 8.0
      g_return_if_fail(size > GOO_EPS)
      _curve2d(curve2d, .CMark, CURVE2D_MARKERS, size)
    END SELECT
  END WITH

TROUT("")
END SUB

SUB _curve2d_update CDECL( _
  BYVAL item AS GooCanvasItem PTR, _
  BYVAL entire_tree AS gboolean, _
  BYVAL cr AS cairo_t PTR, _
  BYVAL bounds AS GooCanvasBounds PTR)
TRIN("")

  VAR curve2d = GOO_CURVE2D(item)
  VAR simple = GOO_CANVAS_ITEM_SIMPLE(item)

/'*
GooCurve2d:channels:

The channels (columns) in the @Dat array for the values of the curve.
The first value is for X channel, the second is Y.
In case of an nagative value the position isn't red from the @Dat array.
Instead all values are placed equidistantly on the axis in the given order.
This may contain
- no value to use default channels (X = 0, Y = 1). Example "" or %NULL.
- one value to set the Y-channel, X is set to -1. Example: "3" (is equal to "-1  3").
- two values to set both, the X and the Y channel. Example: "7  9" for
  X-channel = 7 and Y-channel = 9.

When a channel number is greater than the number of columns in @Dat
no curve will be drawn.

Since: 0.0
'/
  WITH *Curve2d
    IF _curve2d_calc(curve2d) ORELSE entire_tree ORELSE simple->need_update THEN
      VAR p = .Chan
      IF 0 = p ORELSE 0 = p[0] THEN '~                           default
        IF .Dat->Col = 1 THEN .ChX = -1 : .ChY = 0 ELSE .ChX = 0 : .ChY = 1
      ELSE
        .ChY = CINT(goo_value(p))
        .ChX = IIF(p, CINT(goo_value(p)), -1)
        IF p THEN SWAP .ChX, .ChY
      END IF

      IF .ChX < .Dat->Col ANDALSO .ChY < .Dat->Col ANDALSO _
        (.ChX >= 0 ORELSE .ChY >= 0) THEN '~              channels valid
        _curve2d_cline(curve2d)
        _curve2d_area(curve2d)
        _curve2d_errors(curve2d)
        _curve2d_perpens(curve2d)
        _curve2d_markers(curve2d)
        _curve2d_vectors(curve2d)
      END IF
    END IF
    _curve2d__update(item, entire_tree, cr, bounds)
  END WITH

TROUT("")
END SUB

SUB goo_curve2d_class_init CDECL( _
  BYVAL Curve2d_class AS GooCurve2dClass PTR)
TRIN("")

  VAR klass = G_OBJECT_CLASS(curve2d_class)
  WITH *klass
  .finalize     = @_curve2d_finalize
  .get_property = @_curve2d_get_property
  .set_property = @_curve2d_set_property
  END WITH

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_CHAN, _
     g_param_spec_string("channels", _
           __("CurveDataChannels"), _
           __("The channels in the data array for the values of the curve."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_LTYP, _
     g_param_spec_string("line_type", _
           __("TypeOfLine"), _
           __("The type of the line"), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_ATYP, _
     g_param_spec_string("area_linetype", _
           __("AreaLineType"), _
           __("The line type for the area."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_ADIR, _
     g_param_spec_string("area_direction", _
           __("AreaDirectionValue"), _
           __("The direction and an optional value to set the area bottom line."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_PERS, _
     g_param_spec_string("perpendiculars", _
           __("ValueForPerpendiculars"), _
           __("The type and value for perpendiculars"), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_ERRS, _
     g_param_spec_string("errors", _
           __("DefOfErrorLines"), _
           __("The size and the channels for error lines"), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_VECT, _
     g_param_spec_string("vectors", _
           __("VectorsChannels"), _
           __("The channels for vector lines"), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_CURVE2D_PROP_MARK, _
     g_param_spec_string("markers", _
           __("MarkersSizeType"), _
           __("The size and the type of the markers"), _
           NULL, _
           G_PARAM_READWRITE))

TROUT("")
END SUB

'~The standard object initialization function.
SUB goo_curve2d_init CDECL( _
  BYVAL Curve2d AS GooCurve2d PTR)
TRIN("")

  WITH *Curve2d
  .CLine = NULL
  .CArea = NULL
  .CPerp = NULL
  .CMark = NULL
  .CErrs = NULL
  .CVect = NULL
  .Mark = NULL
  .ATyp = NULL
  .ADir = NULL
  .Pers = NULL
  .Erro = NULL
  .Vect = NULL
  .Dat = NULL
  .MItem = NULL
  .ChX = -1
  .ChY = -1
  END WITH

TROUT("")
END SUB

/'*
goo_curve2d_get_area_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the areas #GooCanvasPath.

Since: 0.0
'/
/'*
goo_curve2d_set_area_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the areas #GooCanvasPath.

Since: 0.0
'/
_GOO_DEFINE_PROP(curve2d,Curve2d,CURVE2D,area,CArea)

/'*
goo_curve2d_get_perpens_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the perpendiculars #GooCanvasPath.

Since: 0.0
'/
/'*
goo_curve2d_set_perpens_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the perpendiculars #GooCanvasPath.

Since: 0.0
'/
_GOO_DEFINE_PROP(curve2d,Curve2d,CURVE2D,perpens,CPerp)

/'*
goo_curve2d_get_markers_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the markers #GooCanvasPath.

Since: 0.0
'/
/'*
goo_curve2d_set_markers_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the markers #GooCanvasPath.

Since: 0.0
'/
_GOO_DEFINE_PROP(curve2d,Curve2d,CURVE2D,markers,CMark)

/'*
goo_curve2d_get_errors_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the errors #GooCanvasPath.

Since: 0.0
'/
/'*
goo_curve2d_set_errors_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the errors #GooCanvasPath.

Since: 0.0
'/
_GOO_DEFINE_PROP(curve2d,Curve2d,CURVE2D,errors,CErrs)

/'*
goo_curve2d_get_vectors_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the vectors #GooCanvasPath.

Since: 0.0
'/
/'*
goo_curve2d_set_vectors_properties:
@Curve2d: a #GooCurve2d
    @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the vectors #GooCanvasPath.

Since: 0.0
'/
_GOO_DEFINE_PROP(curve2d,Curve2d,CURVE2D,vectors,CVect)


/'*
goo_curve2d_new:
@Parent: the parent item, or %NULL. If a parent is specified, it will assume
 ownership of the item, and the item will automatically be freed when it is
 removed from the parent. Otherwise call g_object_unref() to free it.
 @AxisX: the X axis to scale the data
 @AxisY: the Y axis to scale the data
   @Dat: the data values to draw
   @...: optional pairs of property names and values, and a terminating %NULL.

Creates a new curve item.

Returns: (transfer full): a new curve2d item.
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
FUNCTION goo_curve2d_new CDECL ALIAS "goo_curve2d_new"( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL AxisX AS GooAxis PTR, _
  BYVAL AxisY AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  ...) AS GooCurve2d PTR EXPORT
TRIN("")

  g_return_val_if_fail(GOO_IS_AXIS(AxisX), NULL)
  g_return_val_if_fail(GOO_IS_AXIS(AxisY), NULL)
  'g_return_val_if_fail(GOO_IS_DATA_POINTS(Dat), NULL)
  g_return_val_if_fail(Dat > 0, NULL)
  '~ g_return_val_if_fail(Dat->Col_() >= 1, NULL)

  'VAR curve2d = g_object_new (GOO_TYPE_curve2d, NULL)
  'VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
  'IF arg THEN g_object_set_valist(curve2d, arg, VA_NEXT(va, ANY PTR))
  _GOO_NEW_OBJECT(CURVE2D,curve2d,Dat)

  WITH *GOO_CURVE2D(curve2d)
    .Parent = Parent
    .AxisX = AxisX : g_object_ref(.AxisX)
    .AxisY = AxisY : g_object_ref(.AxisY)
    .Dat = Dat : goo_data_points_ref(.Dat)

    .CArea = goo_canvas_path_new(curve2d, NULL, _
                                "stroke_pattern", NULL, _
                                "fill_color_rgba", &hC0C0C060, _
                                NULL)
    .CPerp = goo_canvas_path_new(curve2d, NULL, NULL)
    .CLine = goo_canvas_path_new(curve2d, NULL, _
                                "fill_pattern", NULL, _
                                NULL)
    .CMark = goo_canvas_path_new(curve2d, NULL, NULL)
    .CErrs = goo_canvas_path_new(curve2d, NULL, NULL)
    .CVect = goo_canvas_path_new(curve2d, NULL, NULL)

    VAR lw = 0.0
    g_object_get(.Parent, "line_width", @lw, NULL)
    g_object_set(curve2d, "line_width", lw * 2, NULL)

    GOO_CANVAS_ITEM_SIMPLE(curve2d)->simple_data->transform = _
      GOO_CANVAS_ITEM_SIMPLE(.AxisX)->simple_data->transform
  END WITH

  IF Parent THEN
    goo_canvas_item_add_child (Parent, curve2d, -1)
    g_object_unref (curve2d)
  END IF

TROUT("")
  RETURN curve2d

END FUNCTION
