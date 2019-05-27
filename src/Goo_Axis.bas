'~ See main file for licence information: GooData.bas
/'*
SECTION:Goo_Axis
@Title: GooAxis
@Short_Description: an axis for a rectangle background.

#GooAxis is a subclass of #GooCanvasGroup and so
inherits all of the style properties such as #GooCanvasItemSimple:stroke-color,
#GooCanvasItemSimple:fill-color and #GooCanvasItemSimple:line-width.
It also inherits the #GooCanvasItem interface, so you can
use the #GooCanvasItem functions such as goo_canvas_item_raise() or
goo_canvas_item_rotate().

Setting a style property on a #GooAxis will affect
all children of the #GooAxis (unless the children override the
property setting).

The #GooAxis group contains these childs:
- a #GooCanvasPath for the base line,
- a #GooCanvasText with the axis label,
- a #GooCanvasGroup of texts with the tick labels and
- three #GooCanvasPath with tick lines, grid lines and subtick lines.

To create a #GooAxis use goo_axis_new().

To set or get individual properties for the childs use the functions
goo_axis_[get|set]_XYZ_properties with XYZ for grid, ticks, subticks
and text (ticklabels). The remaining items (label and base line)
are contolled directly by the #GooAxis properties.

Position and length of the axis are connected to the background box.
Also the transformation matrix of the background box is applied to
the #GooAxis. Note: it's not supported to move the background box
after creating the #GooAxis. Instead put the background box and the
#GooAxis in to a #GooCanvasGroup and move the entire group.

'/
#INCLUDE ONCE "Goo_Glob.bi"
#INCLUDE ONCE "Goo_Axis.bi"

STATIC SHARED _axis__update AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)
DECLARE SUB _axis_update CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

#DEFINE AXIS_VERTICAL 0 = BIT(.Mo, 0)
#DEFINE AXIS_TYPE .Mo AND &b11
#DEFINE AXIS_DIRECTION .Mo AND &b11
#DEFINE AXIS_GRID .Mo > GOO_AXIS_NORTH

FUNCTION _GooAxis.Pos(BYVAL V AS GooType) AS GooType
  SELECT CASE AS CONST PoMo
    CASE 0, 1 : RETURN (V - VOffs) * VScale
  END SELECT  : RETURN (LOG(ABS(V)) - VOffs) * VScale
END FUNCTION

SUB _GooAxis.Geo(BYREF P AS GooType, BYREF L AS GooType)
  SELECT CASE AS CONST Mo AND &b11
  CASE GOO_AXIS_NORTH, GOO_AXIS_SOUTH : P = Bx : L = Bb
  CASE ELSE                           : P = By : L = Bh
  END SELECT
END SUB

SUB _axis_item_interface_init CDECL( _
  BYVAL iface AS GooCanvasItemIface PTR) STATIC
  _axis__update = iface->update
  iface->update = @_axis_update
END SUB

G_DEFINE_TYPE_WITH_CODE(GooAxis, _goo_axis, GOO_TYPE_CANVAS_GROUP, _
       G_IMPLEMENT_INTERFACE(GOO_TYPE_CANVAS_ITEM, _axis_item_interface_init))

SUB _axis_finalize CDECL( _
  BYVAL Obj AS GObject PTR)
TRIN("")

  WITH *GOO_AXIS(Obj)
    IF .TVal THEN g_free(.TVal)
    IF .TLen THEN g_free(.TLen)
    IF .Text THEN g_free(.Text)
    '~ IF .Offset THEN g_free(.Offset)
    IF .Borders THEN g_free(.Borders)
    IF .Form THEN g_free(.Form)
    g_object_unref(.Back)
  END WITH

  G_OBJECT_CLASS(_goo_axis_parent_class)->finalize(Obj)

TROUT("")
END SUB

ENUM
  GOO_AXIS_PROP_0
  GOO_AXIS_PROP_TEXT
  GOO_AXIS_PROP_TEXT_ALIGN
  GOO_AXIS_PROP_TICKS
  GOO_AXIS_PROP_TICKLEN
  GOO_AXIS_PROP_LOGBAS
  GOO_AXIS_PROP_TICKS_ANGLE
  GOO_AXIS_PROP_SUBTICK
  GOO_AXIS_PROP_BORDERS
  GOO_AXIS_PROP_FORMAT
  GOO_AXIS_PROP_OFFSET
  GOO_AXIS_PROP_OFFS_ALONG
  GOO_AXIS_PROP_OFFS_ACROSS
  GOO_AXIS_PROP_TICK_OFFSET
  GOO_AXIS_PROP_TEXT_OFFSET
END ENUM

SUB _axis_get_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  WITH *GOO_AXIS(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_AXIS_PROP_TEXT        : g_value_set_string(Value, .Text)
  CASE GOO_AXIS_PROP_TICKS       : g_value_set_string(Value, .TVal)
  CASE GOO_AXIS_PROP_TICKLEN     : g_value_set_string(Value, .TLen)
  '~ CASE GOO_AXIS_PROP_OFFSET      : g_value_set_string(Value, .Offset)
  CASE GOO_AXIS_PROP_OFFS_ALONG  : g_value_set_double(Value, .Along)
  CASE GOO_AXIS_PROP_OFFS_ACROSS : g_value_set_double(Value, .Across)
  CASE GOO_AXIS_PROP_BORDERS     : g_value_set_string(Value, .Borders)
  CASE GOO_AXIS_PROP_FORMAT      : g_value_set_string(Value, .Form)
  CASE GOO_AXIS_PROP_TEXT_ALIGN  : g_value_set_enum  (Value, .TextAlign)
  CASE GOO_AXIS_PROP_SUBTICK     : g_value_set_uint  (Value, .Tsub)
  CASE GOO_AXIS_PROP_LOGBAS      : g_value_set_double(Value, .Basis)
  CASE GOO_AXIS_PROP_TICKS_ANGLE : g_value_set_double(Value, .Angle)
  CASE GOO_AXIS_PROP_TICK_OFFSET : g_value_set_double(Value, .TickOffs)
  CASE GOO_AXIS_PROP_TEXT_OFFSET : g_value_set_double(Value, .TextOffs)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

TROUT("")
END SUB

SUB _axis_set_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS CONST GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  VAR simple = CAST(GooCanvasItemSimple PTR, Obj)

  IF simple->model THEN _
      g_warning("Can't set property of a canvas item with a model - " _
                "set the model property instead") : EXIT SUB

  WITH *GOO_AXIS(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_AXIS_PROP_TEXT        :    g_free(.Text) : .Text = g_value_dup_string(Value)
  CASE GOO_AXIS_PROP_TICKS       :    g_free(.TVal) : .TVal = g_value_dup_string(Value)
  CASE GOO_AXIS_PROP_TICKLEN     :    g_free(.TLen) : .TLen = g_value_dup_string(Value)
  CASE GOO_AXIS_PROP_OFFSET      '~ :  g_free(.Offset) : .Offset = g_value_dup_string(Value)
/'* GooAxis:offset:

The offset between the background box and the axis base line (and
all elements of the axis).
By default the baseline is placed at the border of the background box.
This may contain
- no value for default (equals to "0 0"). Example "" or %NULL.
- one value for additional distance in outward direction. Example: "10"
- two values for outward and sideward distance. Example: "10 -7.5"

The offset can be used to draw more than one axis at the same position.

In case of syntax 3 the axis gets a 3D style, A positive second value
will move a horizontal axis
to the right and a vertical axis downwards. Additional lines between the
axis ticks and the corresponding position at the background box are drawn.
These lines are in the ticks group, their style can be changed by
goo_axis_set_ticks_properties().

Since: 0.0
'/
    VAR p = CAST(UBYTE PTR, g_value_get_string(Value))
    .Along  = IIF(p, _goo_value(p), 0.0)
    .Across = IIF(p, _goo_value(p), 0.0) : IF AXIS_VERTICAL THEN .Across *= -1
  CASE GOO_AXIS_PROP_OFFS_ALONG  :     .Along = g_value_get_double(Value)
  CASE GOO_AXIS_PROP_OFFS_ACROSS :    .Across = g_value_get_double(Value)
  CASE GOO_AXIS_PROP_BORDERS     : g_free(.Borders) : .Borders = g_value_dup_string(Value)
  CASE GOO_AXIS_PROP_FORMAT      :    g_free(.Form) : .Form = g_value_dup_string(Value)
  CASE GOO_AXIS_PROP_TEXT_ALIGN  : .TextAlign = g_value_get_enum(Value)
  CASE GOO_AXIS_PROP_SUBTICK     :      .Tsub = g_value_get_uint(Value)
  CASE GOO_AXIS_PROP_LOGBAS      :     .Basis = g_value_get_double(Value)
  CASE GOO_AXIS_PROP_TICKS_ANGLE :     .Angle = -g_value_get_double(Value)
  CASE GOO_AXIS_PROP_TICK_OFFSET :  .TickOffs = g_value_get_double(Value)
  CASE GOO_AXIS_PROP_TEXT_OFFSET :  .TextOffs = g_value_get_double(Value)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

  goo_canvas_item_simple_changed(simple, TRUE)

TROUT("")
END SUB

FUNCTION _axis_calc(BYVAL Axis AS GooAxis PTR) AS INTEGER
TRIN("")

  WITH *Axis
    DIM AS DOUBLE x, y, b, h
    g_object_get(.Back, _
        "x", @x, _
        "y", @y, _
        "width", @b, _
        "height", @h, _
        NULL)
    IF x = .Bx ANDALSO _
       y = .By ANDALSO _
       b = .Bb ANDALSO _
       h = .Bh THEN RETURN 0

    .Bx = x
    .By = y
    .Bb = b
    .Bh = h

    '~ VAR t = .Offset
    '~ .Along  = IIF(t, _goo_value(t), 0.0)
    '~ .Across = IIF(t, _goo_value(t), 0.0) : IF AXIS_VERTICAL THEN .Across *= -1

    SELECT CASE AS CONST AXIS_TYPE
    CASE GOO_AXIS_SOUTH
      .Y1 = y + h + .Along
      .Y2 = .Y1
      .Alen = b
      .X1 = x + .Across
      .X2 = .X1 + .Alen
    CASE GOO_AXIS_EAST
      .X1 = x + b + .Along
      .X2 = .X1
      .Y2 = y + .Across
      .Y1 = .Y2 + h
      .Alen = h
    CASE GOO_AXIS_NORTH
      .Y1 = y - .Along
      .Y2 = .Y1
      .Alen = b
      .X1 = x + .Across
      .X2 = .X1 + .Alen
    CASE ELSE '~GOO_AXIS_WEST
      .X1 = x - .Along
      .X2 = .X1
      .Y2 = y + .Across
      .Y1 = .Y2 + h
      .Alen = h
    END SELECT
    .TickHeight = 0.0
    .TickLabels = ""

/'* GooAxis:tick-length:

The length of the tick lines at the axis (or %NULL for default).
This may contain
- no value for default (8 units in outward direction, 0 units in inward
  direction). Example: %NULL or ""
- one value for the tick length in outward direction. Example: "15" for
  tick lines with a length of 15 units in outward direction.
- two values for the tick length in outward and inward direction. Example:
  "8 0" for the default value mentioned above.

Since: 0.0
'/
    VAR t = .TLen
    IF t THEN
      .Tout = IIF(t, _goo_value(t), 0.0)
      .Tin = IIF(t, _goo_value(t), 0.0)
    ELSE
      .Tout = 5.0
    END IF

/'* GooAxis:range:

The borders of the axis (or %NULL to reset).
This may contain
- no value (the axis is unscaled, the values in @Dat will be spread
  equidistantly in the given order along the axis).
- one value to scale the axis from zero to a positive value or from
  a negative value to zero.
- two values for the left (down) and the right (up) border. The left
  value may be greater than the right value to scale in reverse order.

Since: 0.0
'/
    t = .Borders
    .SMin = IIF(t, _goo_value(t), 0.0)
    .SMax = IIF(t, _goo_value(t), 0.0)
    IF .SMin = .SMax THEN .VScale = 0.0 : g_warning("Axis has no borders!") : RETURN 2
    IF t = 0 THEN IF .SMin > .SMax THEN SWAP .SMin, .SMax

/'* GooAxis:logbasis:

The basis of an logarithmic scale for the axis (or 0.0 for linear scale).
When a basis is set and the #GooAxis:ticks property has no or one value, then
the autoscale function will set ticks with an exponential increase for the
given base. If more than one value is set in the #GooAxis:ticks property the
ticks will be set as defined there.

Since: 0.0
'/
    .PoMo = IIF(AXIS_VERTICAL, 1, 0)
    IF .Basis THEN
      IF .SMin = 0.0 ORELSE .SMax = 0.0 THEN _
          .VScale = 0.0 : g_warning("Log axis, zero border ==> axis unscaled!") : RETURN 3
      IF .Basis < 0 ORELSE ABS(.Basis - 1) < GOO_EPS THEN _
          .VScale = 0.0 : g_warning("Log axis, logbasis < 0 or = 1 ==> axis unscaled!") : RETURN 3
      IF .Smax < 0.0 THEN g_warning("Log axis, swaping negative right border!") : .Smax = -.Smax
      IF .Smin < 0.0 THEN g_warning("Log axis, swaping negative left border!") : .Smin = -.Smin
      IF AXIS_VERTICAL THEN
        .VOffs = LOG(.SMax)
        .VScale = .Alen / (LOG(.Smin) - LOG(.Smax))
      ELSE
        .VOffs = LOG(.SMin)
        .VScale = .Alen / (LOG(.Smax) - LOG(.Smin))
      END IF
      .PoMo = BITSET(.PoMo, 1)
    ELSE
      IF AXIS_VERTICAL THEN
        .VOffs = .SMax
        .VScale = .Alen / (.Smin - .Smax)
      ELSE
        .VOffs = .SMin
        .VScale = .Alen / (.Smax - .Smin)
      END IF
    END IF
    IF .SMin > .SMax THEN SWAP .SMax, .SMin
    .POffs = IIF(AXIS_VERTICAL, y, x)
  END WITH : RETURN 1

TROUT("")
END FUNCTION

FUNCTION _axis_autoscale(BYVAL Axis AS GooAxis PTR, BYVAL S AS GooType) AS STRING
TRIN("")

  WITH *Axis
    IF .Basis ORELSE S < .eps * ABS(.Smax - .Smin) THEN '~find tic~ positions
      VAR x = g_string_new(""), t = .Form
      IF 0 = t ORELSE t[0] = 0 THEN t = GOO_DEFAULT_FORM

      DIM AS PangoRectangle ir, lr
      g_string_printf(x, t, .SMin)

      VAR n = goo_canvas_text_new(NULL, x->str, 0.0, 0.0, -1, 0, NULL)
      goo_canvas_text_get_natural_extents(GOO_CANVAS_TEXT(n), @ir, @lr)
      VAR w = lr.width, h = lr.height
      goo_canvas_item_remove(n)
      g_string_printf(x, t, .SMax)

      n = goo_canvas_text_new(NULL, x->str, 0.0, 0.0, -1, 0, NULL)
      goo_canvas_text_get_natural_extents(GOO_CANVAS_TEXT(n), @ir, @lr)
      IF lr.width > w THEN w = lr.width
      IF lr.height > h THEN h = lr.height
      goo_canvas_item_remove(n)
      g_string_free(x, TRUE)

      S = IIF(AXIS_VERTICAL, .Angle, .Angle + 90.) * DEG_RAD
      VAR c = ABS(COS(S))
      S = ABS(SIN(S))
      VAR l = IIF(w * S < h * c, h / c, w / S) / PANGO_SCALE, az = .Alen / l
      IF .Basis THEN '~                                logarithmic scale
        VAR nn = "", lb = LOG(.Basis)
        VAR n = ABS(LOG(.SMax / .SMin) / lb)
        VAR f = IIF(lb > 0, .Basis, 1 / .Basis)
        IF n >= 2 THEN '~                  more than two powers of Basis
          VAR s = (1 + INT(n)) / az
          IF s > 1 THEN f ^= 1 + INT(s)
          VAR so = .Basis ^ INT(LOG(.SMax) / lb + IIF(lb < 0, 0.99, 0.01))
          WHILE so >= .SMin
            nn &= MKD(so)
            so /= f
          WEND
        ELSE
          VAR so = INT(.SMax / f) * f
          VAR x = LOG((.SMax - .SMin) / az) / lb
          VAR e = INT(x + IIF(lb < 0, 0.01, 0.99))
          x = .Basis ^ e
          IF n >= 1 THEN '~                          two powers of Basis
            nn = MKD(x) & MKD(.Basis ^ IIF(lb < 0, e + 1, e - 1))
          ELSE '~                          less than two powers of Basis
            WHILE so >= .SMin
              nn &= MKD(so)
              so -= x
            WEND
          END IF
        END IF
        SELECT CASE AS CONST LEN(nn) '~     add border[s] if <= one tick
        CASE 0 : nn = MKD(.SMin) & MKD(.SMax)
        CASE 8
          IF ABS(LOG(CVD(nn)) / lb) > ABS(LOG((.SMax + .SMin) / 2) / lb) THEN
            nn &= MKD(.SMin)
          ELSE
            nn &= MKD(.SMax)
          END IF
        END SELECT : RETURN nn
      END IF '~                            compute linear tick positions
      IF az < 2 THEN az = 2 ELSE IF az > 13 THEN az = 13
      c = .SMax - .SMin
      S = 10 ^ (INT(LOG(c) / LOG(10)) - 1)
      IF c / S > az THEN S *= 2
      IF c / S > az THEN S *= 1.25
      IF c / S > az THEN S *= 2
      IF c / S > az THEN S *= 2
    END IF

    VAR nn = "", eps = .eps * S, f = 0.0, fin = 0.0
    IF .Smax > .Smin THEN
      f = INT(.Smin / S) * S
      IF f < .Smin - eps THEN f += S
      fin = .Smax + eps
    ELSE
      f = INT(.Smax / S) * S
      IF f < .Smax - eps THEN f += S
      fin = .Smin + eps
    END IF

    DO
      nn &= MKD(f)
      f += S
    LOOP UNTIL f > fin

    SELECT CASE AS CONST LEN(nn) '~         add border[s] if <= one tick
    CASE 0 : nn = MKD(.SMin) & MKD(.SMax)
    CASE 8
      IF CVD(nn) > (.SMax + .SMin) / 2 THEN
        nn &= MKD(.SMin)
      ELSE
        nn &= MKD(.SMax)
      END IF
    END SELECT : RETURN nn
  END WITH
END FUNCTION

FUNCTION _axis_parse_ticks(BYVAL Axis AS GooAxis PTR) AS STRING
TRIN("")

  STATIC AS ZSTRING PTR s1 = @"{", s2 = @"}"
  WITH *Axis
    IF 0 = .TVal ORELSE 0 = .TVal[0] THEN RETURN _axis_autoscale(Axis, 0.0)

    VAR nn = "", t = .TVal
    IF INSTR(*t, *s1) THEN '~                       single ticks defined
      DO
        VAR r = _goo_value(t) : IF t THEN nn &= MKD(r) ELSE EXIT DO
        VAR a = INSTR(*t, *s1) + 1 : IF a <= 1 THEN EXIT DO '~ !!! unscaled
        VAR e = INSTR(*t, *s2) : IF e < a THEN EXIT DO
        .TickLabels &= MID(*t, a, e - a) & CHR(0)
        t += e
      LOOP : RETURN nn
    END IF

    DO
      VAR r = _goo_value(t) : IF t THEN nn &= MKD(r) ELSE EXIT DO
    LOOP : IF LEN(nn) > 8 THEN RETURN nn

TROUT("")
    RETURN _axis_autoscale(Axis, ABS(CVD(nn)))
  END WITH
END FUNCTION

/'* GooAxis:ticks:

Where to set ticks at the axis (or %NULL for autoscale).
This may contain
- no value for autoscale.
  The autoscale function calculates the values for the ticks based
  on the axis length and the maximum space needed by the left and
  the right border tick
  labels in the current font. Example: "" or %NULL
- one value for the distance of the ticks (ignored when #GooAxis:logbasis
  != 0.0). Example: "0.5" will set ticks at 0, 0.5, 1, 1.5, ...
- two or more values to specify the tick positions. The positions may be
  unequal spaced. Example: "-1  1  3  7.5"
- pairs of a value and a corresponding text in braces. The text
  will be set at the position instead of the value. Example:
  "1{small}  3{middle}  6{large}"

Ticks will be labeled with the value unless syntax 4 is used. To
set the label format use #GooAxis:format.

Since: 0.0

'/
SUB _axis_ticks(BYVAL Axis AS GooAxis PTR, BYREF Nn AS STRING)
TRIN("")

  WITH *Axis
    VAR ct = .Y1 - .Tin, dt = .Tin + .Tout
    SELECT CASE AS CONST AXIS_TYPE
    CASE GOO_AXIS_EAST  : ct = .X1 - .Tin
    CASE GOO_AXIS_NORTH : ct = .Y1 - .Tout
    CASE GOO_AXIS_WEST  : ct = .X1 - .Tout
    END SELECT
    g_object_set(.Tick, "data", NULL, NULL)
    VAR path = GOO_CANVAS_PATH(.Tick)->path_data->path_commands
    VAR o = .POffs + .Across
    FOR i AS INTEGER = 1 TO LEN(Nn) STEP 8
      VAR f = .Pos(CVD(MID(Nn, i, 8))) + o
      IF AXIS_VERTICAL THEN
        _goo_add_path(path, ASC("M"), ct, f)
        _goo_add_path(path, ASC("h"), dt)
      ELSE
        _goo_add_path(path, ASC("M"), f, ct)
        _goo_add_path(path, ASC("v"), dt)
      END IF
    NEXT

    IF .Across THEN
      VAR dtx = -.Across , dty = -.Along
      SELECT CASE AS CONST AXIS_TYPE
      CASE GOO_AXIS_EAST  : dtx = -.Along  : dty = -.Across
      CASE GOO_AXIS_NORTH : dtx = -.Across : dty =  .Along
      CASE GOO_AXIS_WEST  : dtx =  .Along  : dty = -.Across
      END SELECT
      FOR i AS INTEGER = 1 TO LEN(Nn) STEP 8
        VAR f = .Pos(CVD(MID(Nn, i, 8))) + o
        IF AXIS_VERTICAL THEN
          _goo_add_path(path, ASC("M"), .X1, f)
          _goo_add_path(path, ASC("l"), dtx, dty)
        ELSE
          _goo_add_path(path, ASC("M"), f, .Y1)
          _goo_add_path(path, ASC("l"), dtx, dty)
        END IF
      NEXT
    END IF
  END WITH

TROUT("")
END SUB

/'* GooAxis:subticks:

The number of subticks between the main ticks. Ie a value of 1 adds
one subtick.

Since: 0.0

'/
SUB _axis_subticks(BYVAL Axis AS GooAxis PTR, BYREF Nn AS STRING)
TRIN("")

  WITH *Axis
    VAR ct = .Y1 - .Tin / 2, dt = (.Tin + .Tout) / 2
    SELECT CASE AS CONST AXIS_TYPE
    CASE GOO_AXIS_EAST  : ct = .X1 - .Tin  / 2
    CASE GOO_AXIS_NORTH : ct = .Y1 - .Tout / 2
    CASE GOO_AXIS_WEST  : ct = .X1 - .Tout / 2
    END SELECT
    g_object_set(.STick, "data", NULL, NULL)
    VAR path = GOO_CANVAS_PATH(.STick)->path_data->path_commands
    VAR f = CVD(MID(Nn, 1, 8)), o = .POffs - .Across
    FOR i AS INTEGER = 9 TO LEN(Nn) STEP 8
      VAR df = (CVD(MID(Nn, i, 8)) - f) / (.Tsub + 1)
      FOR i AS INTEGER = 1 TO .Tsub
        f += df
        IF AXIS_VERTICAL THEN
          _goo_add_path(path, ASC("M"), ct, .Pos(f) - o)
          _goo_add_path(path, ASC("h"), dt)
        ELSE
          _goo_add_path(path, ASC("M"), .Pos(f) - o, ct)
          _goo_add_path(path, ASC("v"), dt)
        END IF
      NEXT
      f = CVD(MID(Nn, i, 8))
    NEXT
  END WITH

TROUT("")
END SUB

SUB _axis_grid(BYVAL Axis AS GooAxis PTR, BYREF Nn AS STRING)
TRIN("")

  DIM AS GooType gu, go
  WITH *Axis
    IF AXIS_VERTICAL THEN
      gu = .By + .Bh * .eps
      go = .By + .Bh * (1 - .eps)
    ELSE
      gu = .Bx + .Bb * .eps
      go = .Bx + .Bb * (1 - .eps)
    END IF
    g_object_set(.Grid, "data", NULL, NULL)
    VAR grid = GOO_CANVAS_PATH(.Grid)->path_data->path_commands
    FOR i AS INTEGER = 1 TO LEN(Nn) STEP 8
      VAR f = .Pos(CVD(MID(Nn, i, 8))) + .POffs
      IF f < go ANDALSO _
         f > gu THEN
        IF AXIS_VERTICAL THEN
          _goo_add_path(grid, ASC("M"), .Bx, f)
          _goo_add_path(grid, ASC("h"), .Bb)
        ELSE
          _goo_add_path(grid, ASC("M"), f, .By)
          _goo_add_path(grid, ASC("v"), .Bh)
        END IF
      END IF
    NEXT
  END WITH

TROUT("")
END SUB

FUNCTION _axis_next_label(BYREF P AS UBYTE PTR, BYVAL E AS UBYTE PTR) AS ZSTRING PTR
  DIM AS ZSTRING PTR a = P
  WHILE P < E
    IF 0 = *P THEN P += 1 : RETURN a
    P += 1
  WEND : P = a : RETURN a
END FUNCTION

SUB _axis_ticklabels(BYVAL Axis AS GooAxis PTR, BYREF Nn AS STRING)
TRIN("")

  STATIC AS GooType aeps = 4.5, tx, ty
  WITH *Axis
    DIM AS PangoRectangle ir, lr
    VAR n = goo_canvas_text_new(NULL, ",", 30.0, 30.0, -1, 0, NULL)
    goo_canvas_text_get_natural_extents(GOO_CANVAS_TEXT(n), @ir, @lr)
    goo_canvas_item_remove(n)
    VAR hmax = 0.0, bmax = 0.0, tanchor = 0
    VAR small_angle = ABS(.Angle) < aeps, big_angle = 90 - ABS(.Angle) > aeps

/'* GooAxis:tick-angle:

The rotation of the tick texts at the axis. By default the text is
placed in horizontal direction for all axis positions. Using this property the
text can be rotated, ie to get more space for the tick labels. A positive
value rotates counterclockwise. For small and big #GooAxis:tick-angle values
the tick line is connected to the edge of the text. In case of medium-sized
#GooAxis:tick-angle values the tick line is connected to the corner of the
text.

Since: 0.0
'/
/'* GooAxis:tick-offset:

Additional space between the ticks and the tick labels. By default
the tick labels are placed next to the ticks. A positiv #GooAxis:tick-offset
adds some space in outward direction. A negativ value will move the
tick labels towards the background box.

Since: 0.0
'/
/'* GooAxis:format:

The format for the tick labels (defaults to "\%g" if #GooAxis:format is
%NULL or ""). This can be used to putput customized tick labels, ie
including additional text.
Note: tick labels don't use markup. To set text attributes use
goo_axis_set_text_properties().

Since: 0.0
'/
    SELECT CASE AS CONST AXIS_TYPE
    CASE GOO_AXIS_SOUTH
      ty = .Y1 + .Tout + .TickOffs
      tanchor = IIF(small_angle, GOO_CANVAS_ANCHOR_N, _
                    IIF(big_angle, _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_NW, GOO_CANVAS_ANCHOR_NE), _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_W, GOO_CANVAS_ANCHOR_E)))
    CASE GOO_AXIS_EAST
      tx = .X1 + .Tout + .TickOffs + ir.height / PANGO_SCALE
      tanchor = IIF(small_angle, GOO_CANVAS_ANCHOR_W, _
                    IIF(big_angle, _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_SW, GOO_CANVAS_ANCHOR_NW), _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_S, GOO_CANVAS_ANCHOR_N)))
    CASE GOO_AXIS_NORTH
      ty = .Y1 - .Tout - .TickOffs
      tanchor = IIF(small_angle, GOO_CANVAS_ANCHOR_S, _
                    IIF(big_angle, _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_SE, GOO_CANVAS_ANCHOR_SW), _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_E, GOO_CANVAS_ANCHOR_W)))
    CASE ELSE '~ GOO_AXIS_WEST
      tx = .X1 - .Tout - .TickOffs - ir.height / PANGO_SCALE
      tanchor = IIF(small_angle, GOO_CANVAS_ANCHOR_E, _
                    IIF(big_angle, _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_NE, GOO_CANVAS_ANCHOR_SE), _
                        IIF(.Angle > 0, GOO_CANVAS_ANCHOR_N, GOO_CANVAS_ANCHOR_S)))
    END SELECT

    goo_canvas_item_remove(.Ticktext)
    .Ticktext = goo_canvas_group_new(.Textgr, NULL)

    VAR x = g_string_new(""), y = .Form
    IF 0 = y ORELSE y[0] = 0 THEN y = GOO_DEFAULT_FORM
    VAR p = SADD(.TickLabels), l = LEN(.TickLabels)
    VAR e = p + l, t = y, o = .POffs + .Across

    FOR i AS INTEGER = 1 TO LEN(Nn) STEP 8
      VAR f = CVD(MID(Nn, i, 8))
      IF AXIS_VERTICAL THEN ty = .Pos(f) + o ELSE tx = .Pos(f) + o
      IF l THEN
        t = _axis_next_label(CAST(UBYTE PTR, p), e)
      ELSE
        g_string_printf(x, y, f) : t = x->str
      END IF

      VAR n = goo_canvas_text_new(NULL, t, tx, ty, -1, tanchor, NULL)
      goo_canvas_text_get_natural_extents(GOO_CANVAS_TEXT(n), @ir, @lr)
      g_object_set(n, "parent", .Ticktext, NULL)
      IF .Angle THEN goo_canvas_item_rotate(n, .Angle, tx, ty)
      IF lr.width > bmax THEN bmax = lr.width
      IF lr.height > hmax THEN hmax = lr.height
    NEXT : g_string_free(x, TRUE)
    IF AXIS_VERTICAL THEN
      o = (90 - ABS(.Angle)) * DEG_RAD
      .TickHeight = 1.5
    ELSE
      o = ABS(.Angle) * DEG_RAD
      .TickHeight = 1.1
    END IF
    .TickHeight *= (SIN(o) * bmax + COS(o) * hmax) / PANGO_SCALE
  END WITH

TROUT("")
END SUB

/'* GooAxis:text:

The label text to use at the axis (or %NULL to reset). #PangoMarkupFormat
is used to format the text. Example: "tan (<i>theta</i>)"

Since: 0.0
'/
/'* GooAxis:text-offset:

Additional space between the tick labels and the axis text. By default
the text is placed next to the tick labels. A positiv #GooAxis:text-offset
adds some space in outward direction. A negativ value will move the
text towards the background box.

Since: 0.0
'/
/'* GooAxis:text-align:

The allignment for the label text as
a #PANGO_TYPE_ALIGNMENT value.

Since: 0.0
'/
SUB _axis_label(BYVAL Axis AS GooAxis PTR)
TRIN("")

  STATIC AS GooType tx, ty, po
  STATIC AS guint tanchor
  WITH *Axis

  po = .Tout + .TickOffs + .TextOffs + .TickHeight
  SELECT CASE AS CONST AXIS_TYPE
  CASE GOO_AXIS_SOUTH
    tx = 0.5 * (.X1 + .X2)
    ty = .Y1 + po
    tanchor = GOO_CANVAS_ANCHOR_N
  CASE GOO_AXIS_EAST
    tx = .X1 + po
    ty = 0.5 * (.Y1 + .Y2)
    tanchor = GOO_CANVAS_ANCHOR_N
  CASE GOO_AXIS_NORTH
    tx = 0.5 * (.X1 + .X2)
    ty = .Y1 - po
    tanchor = GOO_CANVAS_ANCHOR_S
  CASE ELSE '~ GOO_AXIS_WEST
    tx = .X1 - po
    ty = 0.5 * (.Y1 + .Y2)
    tanchor = GOO_CANVAS_ANCHOR_S
  END SELECT
  g_object_set(.Label, _
               "text", .Text, _
               "width", .Alen, _
               "anchor", tanchor, _
               "alignment", .TextAlign, _
               NULL)
  goo_canvas_item_set_simple_transform(.Label, _
                        tx, ty, 1.0, IIF(AXIS_VERTICAL, -90.0, 0.0))
  END WITH

TROUT("")
END SUB

SUB _axis_update CDECL( _
  BYVAL item AS GooCanvasItem PTR, _
  BYVAL entire_tree AS gboolean, _
  BYVAL cr AS cairo_t PTR, _
  BYVAL bounds AS GooCanvasBounds PTR)
TRIN("")

  VAR axis = GOO_AXIS(item)
  VAR simple = GOO_CANVAS_ITEM_SIMPLE(item)
  WITH *axis
    IF _axis_calc(axis) ORELSE entire_tree ORELSE simple->need_update THEN
      g_object_set(.BLine, "data", NULL, NULL)
      VAR path = GOO_CANVAS_PATH(.BLine)->path_data->path_commands
      _goo_add_path(path, ASC("M"), .X1, .Y1)
      _goo_add_path(path, ASC("L"), .X2, .Y2)
      IF .Across THEN
        SELECT CASE AS CONST AXIS_TYPE
        CASE GOO_AXIS_EAST
          _goo_add_path(path, ASC("l"),-.Along ,-.Across)
          _goo_add_path(path, ASC("v"), .Alen)
          _goo_add_path(path, ASC("z"))
        CASE GOO_AXIS_NORTH
          _goo_add_path(path, ASC("l"),-.Across, .Along)
          _goo_add_path(path, ASC("h"),-.Alen)
          _goo_add_path(path, ASC("z"))
        CASE GOO_AXIS_WEST
          _goo_add_path(path, ASC("l"), .Along ,-.Across)
          _goo_add_path(path, ASC("v"), .Alen)
          _goo_add_path(path, ASC("z"))
        CASE ELSE 'GOO_AXIS_SOUTH
          _goo_add_path(path, ASC("l"),-.Across,-.Along)
          _goo_add_path(path, ASC("h"),-.Alen)
          _goo_add_path(path, ASC("z"))
        END SELECT
      END IF

      IF .VScale THEN
        VAR nn = _axis_parse_ticks(axis)
        IF LEN(nn) THEN
          IF AXIS_GRID THEN _axis_grid(axis, nn)
          IF .Tin + .Tout THEN
            _axis_ticks(axis, nn)
            IF .Tsub THEN _axis_subticks(axis, nn)
          END IF
          _axis_ticklabels(axis, nn)
        ELSE
          g_warning("Can't create ticks (borders left = right)")
        END IF
      END IF
      _axis_label(axis)

    END IF
  END WITH
  _axis__update(item, entire_tree, cr, bounds)

TROUT("")
END SUB

SUB _goo_axis_class_init CDECL( _
  BYVAL axis_class AS GooAxisClass PTR)
TRIN("")

  VAR klass = G_OBJECT_CLASS(axis_class)
  WITH *klass
  .finalize     = @_axis_finalize
  .get_property = @_axis_get_property
  .set_property = @_axis_set_property
  END WITH

  g_object_class_install_property(klass, GOO_AXIS_PROP_TEXT, _
     g_param_spec_string("label", _
           __("Label text"), _
           __("Some text to descripe the sense of the axis."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_TEXT_ALIGN, _
     g_param_spec_enum("label-align", _
           __("Alignment of label"), _
           __("How to align the label text at the axis."), _
           PANGO_TYPE_ALIGNMENT, PANGO_ALIGN_CENTER, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_LOGBAS, _
     g_param_spec_double("logbasis", _
           __("Logarythmic Basis"), _
           __("The basis value of a logarithmic axis."), _
           0.0, G_MAXDOUBLE, 0.0, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_TICKS, _
     g_param_spec_string("ticks", _
           __("TicksValue"), _
           __("The distance or the place of main ticks at the axis"), _
           "0", _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_TICKLEN, _
     g_param_spec_string("tick-length", _
           __("TicksLengths out/in"), _
           __("How long are the ticks outwards and inwards"), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_TICKS_ANGLE, _
     g_param_spec_double("angle-ticklabel", _
           __("TickAngleValue"), _
           __("The rotation of the tick texts at the axis"), _
           -90.0, 90.0, 0.0, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_TICK_OFFSET, _
     g_param_spec_double("offset-ticklabel", _
           __("TicksDistance"), _
           __("Variable distance for tick texts at the axis"), _
           -G_MAXDOUBLE, G_MAXDOUBLE, 0.0, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_TEXT_OFFSET, _
     g_param_spec_double("offset-label", _
           __("TextDistance"), _
           __("Variable distance for the text of the axis"), _
           -G_MAXDOUBLE, G_MAXDOUBLE, 0.0, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_SUBTICK, _
     g_param_spec_uint("subticks", _
           __("InTick"), _
           __("The number of subticks"), _
           0, 9, 0, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_OFFSET, _
     g_param_spec_string("offset", _
           __("AxisOffset"), _
           __("The distance between axis and background item along (and maybe across) the axis direction"), _
           NULL, _
           G_PARAM_WRITABLE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_OFFS_ALONG, _
     g_param_spec_double("offset-along", _
           __("AxisOffsetAlong"), _
           __("The distance between the axis and the background item along the axis direction"), _
           -G_MAXDOUBLE, G_MAXDOUBLE, 0.0, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_OFFS_ACROSS, _
     g_param_spec_double("offset-across", _
           __("AxisOffsetAcross"), _
           __("The distance between the axis and the background item across the axis direction"), _
           -G_MAXDOUBLE, G_MAXDOUBLE, 0.0, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_BORDERS, _
     g_param_spec_string("range", _
           __("AxisBorders"), _
           __("The right/down and left/up border of the axis"), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_AXIS_PROP_FORMAT, _
     g_param_spec_string("format", _
           __("TicksFormat"), _
           __("How to format the ticks"), _
           NULL, _
           G_PARAM_READWRITE))

TROUT("")
END SUB

'~The standard object initialization function.
SUB _goo_axis_init CDECL( _
  BYVAL Axis AS GooAxis PTR)
TRIN("")

  WITH *Axis
    .Smin = 0.0
    .Smax = 0.0
    .TLen = NULL
    .TVal = NULL
    .Text = NULL
    '~ .Offset = NULL
    .Borders = NULL
    .Form = NULL
    .Basis = 0.0
    .TextAlign = PANGO_ALIGN_CENTER
    .Tsub = 0
    .Along = 0.0
    .Across = 0.0
    .Angle = 0.0
    .eps = .001
    .TickOffs = 0.0
    .TextOffs = 0.0
    .Bx = 0.0
    .By = 0.0
    .Bb = 0.0
    .Bh = 0.0
  END WITH

TROUT("")
END SUB

/'* goo_axis_get_text_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the #GooCanvasGroup of ticklabels.

Since: 0.0
'/
/'* goo_axis_set_text_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the #GooCanvasGroup of ticklabels.

Since: 0.0
'/
_GOO_DEFINE_PROP(axis,Axis,AXIS,text,Textgr)

/'* goo_axis_get_grid_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the #GooCanvasPath of grid lines.

Since: 0.0
'/
/'* goo_axis_set_grid_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the #GooCanvasPath of grid lines.

Since: 0.0
'/
_GOO_DEFINE_PROP(axis,Axis,AXIS,grid,Grid)

/'* goo_axis_get_ticks_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

get one or more properties of the #GooCanvasPath of tick lines (and
connection lines if the second value of #GooAxis:offset is set).

Since: 0.0
'/
/'* goo_axis_set_ticks_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the #GooCanvasPath of tick lines.

Since: 0.0
'/
_GOO_DEFINE_PROP(axis,Axis,AXIS,ticks,Tick)

/'* goo_axis_get_subticks_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

Get one or more properties of the #GooCanvasPath of subtick lines.

Since: 0.0
'/
/'* goo_axis_set_subticks_properties:
 @Axis: a #GooAxis
 @...: optional pairs of property names and values, and a terminating %NULL.

Set one or more properties for the #GooCanvasPath of subtick lines (and
connection lines if the second value of #GooAxis:offset is set).

Since: 0.0
'/
_GOO_DEFINE_PROP(axis,Axis,AXIS,subticks,STick)


/'* goo_axis_new:
@Parent: the parent item, or %NULL. If a parent is specified, it will assume
 ownership of the item, and the item will automatically be freed when it is
 removed from the parent. Otherwise call g_object_unref() to free it.
@Back: the background box to connect the axis to (a #GooCanvasRect,
 #GooCanvasImage, #GooCanvasGroup, ...).
 Note: to set the axis position and size, the properties
 #GooCanvasItemSimple:x, #GooCanvasItemSimple:y, #GooCanvasItemSimple:width and
 #GooCanvasItemSimple:height will be red (and therefore must be set in the
 background box item).
@Modus: the position and type as a %GooAxisType value (like %GOO_AXIS_SOUTH
 or %GOO_GRIDAXIS_SOUTH, ...)
@Text: the label text for the axis. You can use Pango markup language to
 format the text.
@...: optional pairs of property names and values, and a terminating %NULL.

Creates a new axis item.

Returns: (transfer full): a new axis item.

Since: 0.0
'/
'~ '*
'~ * <!--PARAMETERS-->
'~ *
'~ * !!!Here's an example showing how to create a curve centered at (100.0,
'~ * 100.0), with a horizontal radius of 50.0 and a vertical radius of 30.0.
'~ * It is drawn with a red outline with a width of 5.0 and filled with blue:
'~ *
'~ * <informalexample><programlisting>
'~ *  GooCurve *axisX = goo_axis_new (mygroup, myImage, GOO_AXIS_NORTH, "X axis text",
'~ *                                           "stroke-color", "red",
'~ *                                           "line-width", 5.0,
'~ *                                           "fill-color", "blue",
'~ *                                           NULL);
'~ * </programlisting></informalexample>
FUNCTION goo_axis_new CDECL ALIAS "goo_axis_new"( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Back AS GooCanvasItem PTR, _
  BYVAL Modus AS GooAxisType, _
  BYVAL Text AS gchar PTR, _
  ...) AS GooAxis PTR EXPORT
TRIN("")

  g_return_val_if_fail(Back > 0, NULL)

  VAR axis = g_object_new(GOO_TYPE_AXIS, NULL)

  VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
  IF arg THEN g_object_set_valist(axis, arg, VA_NEXT(va, ANY PTR))

  WITH *GOO_AXIS(axis)
    .Parent = Parent
    .Back = Back : g_object_ref(.Back)
    .Text = g_strdup(Text)
    .Mo = Modus

    .Textgr = goo_canvas_group_new(axis, NULL)
    .Label = goo_canvas_text_new(.Textgr, NULL, 0.0, 0.0, -1.0, 0, _
                                "alignment", PANGO_ALIGN_CENTER, _
                                "use-markup", TRUE, _
                                "wrap", PANGO_WRAP_WORD, _
                                NULL)
    .BLine = goo_canvas_path_new(axis, NULL, NULL)
    .Ticktext = goo_canvas_group_new(.Textgr, NULL)
    .Grid = goo_canvas_path_new(axis, NULL, NULL)
    .Tick = goo_canvas_path_new(axis, NULL, NULL)
    .STick = goo_canvas_path_new(axis, NULL, NULL)

    VAR lw = 0.0
    g_object_get(.Parent, "line-width", @lw, NULL)
    g_object_set(.STick, "line-width", lw / 2, NULL)
  END WITH

  GOO_CANVAS_ITEM_SIMPLE(axis)->simple_data->transform = _
    GOO_CANVAS_ITEM_SIMPLE(.Back)->simple_data->transform

  IF Parent THEN
    goo_canvas_item_add_child(Parent, axis, -1)
    g_object_unref(axis)
  END IF

TROUT("")
  RETURN axis
END FUNCTION
