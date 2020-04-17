'~This is file Goo_Glob.bas
'~A library to present technical data
'~
'~Licence: LGPLv2
'~(C) 2012-2020 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

/'*
SECTION:Goo_Data
@Title: GooData
@Short_Description: common functions used for all widgets.

bla, bla, bla
'/

#IF DEFINED(__FB_WIN32__)
#LIBPATH "C:\opt\GTK\lib" '~                             your paths here
#ENDIF

#INCLUDE ONCE "Goo_Glob.bi"

/'*
goo_set_decimal_separator:
@V: the new value for the decimal separator.

Sets the decimal separator character. This can be either a '.' or a ','
character. To use the current locale setting call this function with
empty parameter list or 0 (null) as parameter.

Returns: the new decimal separator setting.

Since: 0.0
'/
FUNCTION goo_set_decimal_separator CDECL(BYVAL V AS UBYTE = 0) AS UBYTE
  SELECT CASE AS CONST V
  CASE 0
    VAR m = g_strdup_printf("%g", 2.2)
    _GOO_NO_CHR[0] = m[1]
    g_free(m)
  CASE ASC("."), ASC(",") : _GOO_NO_CHR[0] = V
  END SELECT : RETURN _GOO_NO_CHR[0]
END FUNCTION

FUNCTION _goo_palette CDECL(BYVAL Scale AS GooFloat, BYVAL Alpha_ AS UBYTE = &hFF) AS guint
  STATIC AS UBYTE _
    r(...) = {255, 255, 0  ,   0, 255}, _
    g(...) = {  0, 255, 255,   0,   0}, _
    b(...) = {  0,   0, 0  , 255, 255}
  VAR n = UBOUND(r)
  IF Scale <= 0. THEN RETURN r(0) SHL 24 + g(0) SHL 16 + b(0) SHL 8 + Alpha_
  IF Scale >= 1. THEN RETURN r(n) SHL 24 + g(n) SHL 16 + b(n) SHL 8 + Alpha_
  VAR c1 = CUINT(INT(Scale * n)), c2 = c1 + 1
  VAR f2 = n * (Scale - c1 / n), f1 = 1 - f2
  DIM AS guint x =  (f1 * r(c1) + f2 * r(c2)) SHL 24
               x += (f1 * g(c1) + f2 * g(c2)) SHL 16
       RETURN  x + ((f1 * b(c1) + f2 * b(c2))) SHL 8 + Alpha_
END FUNCTION

/'*
goo_palette_set_function:
@Func: A function that returns a color value for a rgba property
 (ie for #GooCanvasItemSimple:fill-color-rgba).

Sets the goo_palette_function() for color gradients. Pass %NULL to
reset the default goo_palette_function().

Since: 0.0
'/
SUB goo_palette_set_function CDECL(BYVAL Func AS goo_palette_function)
  goo_palette = IIF(Func, Func, @_goo_palette)
END SUB


/'*
goo_data_points_ref:
@Points: a #GooDataPoints struct.

Increments the reference count of the given #GooDataPoints struct.

Returns: the #GooDataPoints struct.

Since: 0.0
'/
FUNCTION goo_data_points_ref CDECL( _
  BYVAL Points AS GooDataPoints PTR) AS GooDataPoints PTR
  Points->RefCount += 1
  RETURN Points
END FUNCTION

/'*
goo_data_points_unref:
@Points: a #GooDataPoints struct.

Decrements the reference count of the given #GooDataPoints struct,
freeing it if the reference count falls to zero.

Since: 0.0
'/
SUB goo_data_points_unref CDECL(BYVAL Points AS GooDataPoints PTR)
  WITH *Points
    .RefCount -= 1
    IF .RefCount <= 0 THEN
      IF .m_flag THEN g_slice_free1(.Row * .Col * SIZEOF(GooFloat), .Dat)
      g_slice_free(GooDataPoints, Points)
    END IF
  END WITH
END SUB

G_DEFINE_BOXED_TYPE(GooDataPoints, goo_data_points, _
                                   goo_data_points_ref, _
                                   goo_data_points_unref)

/'*
goo_data_points_new:
@Rows : the number of rows to create in the array.
@Columns: the number of columns to create in the array or nothing to create one column.
@Array: an (optional) array with the given number of rows and columns
of GooFloat values or %NULL to create a new internal array.

Creates a new #GooDataPoints struct. The structure can either allocate
space for the given number of values or can hold an previously created
array of GooFloat values.

In the second case the memory must not be
freed while the #GooDataPoints struct is in usage (its reference counter
is greater than zero) and when the calling code has to free it after
the #GooDataPoints struct memory gets freed.

In the first case the memory gets handled by the functions of the
goo_data_points family and the content (values) can be manipulated by
goo_data_points_set_point() and goo_data_points_get_point().

Free the memory by calling goo_data_points_unref() when done.

Returns: (transfer full): a new #GooDataPoints struct.

Since: 0.0
'/
FUNCTION goo_data_points_new CDECL( _
  BYVAL Rows AS guint = 1, _
  BYVAL Columns AS guint = 1, _
  BYVAL Array AS GooFloat PTR = 0) AS GooDataPoints PTR

  VAR points = g_slice_new(GooDataPoints)
  WITH *points
    .Row =    IIF(Rows < 1, 1, Rows)
    .Col = IIF(Columns < 1, 1, Columns)
    IF Array THEN
      .Dat = Array
      .m_flag = 0
    ELSE
      .Dat = g_slice_alloc(.Row * .Col * SIZEOF(GooFloat))
      .m_flag = 1
    END IF
    .RefCount = 1
  END WITH
  RETURN points
END FUNCTION

/'*
goo_data_points_set_point:
@Points: a #GooDataPoints struct.
@Row: the row of the value to set.
@Column: the column of the value to set.
@Value: the value to set at row and column.

Set a value in the #GooDataPoints struct.

Since: 0.0
'/
SUB goo_data_points_set_point CDECL(BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, BYVAL Column AS guint, _
  BYVAL Value AS GooFloat)
  WITH *Points
    g_return_if_fail(Row < .Row)
    g_return_if_fail(Column < .Col)
    .Dat[Row * .Col + Column] = Value
  END WITH
END SUB

/'*
goo_data_points_get_point:
@Points: a #GooDataPoints struct.
@Row: the row of the value to get.
@Column: the column of the value to get.

Get a value from the #GooDataPoints struct.

Returns: the value to get from row and column.

Since: 0.0
'/
FUNCTION goo_data_points_get_point CDECL(BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, BYVAL Column AS guint) AS GooFloat
  WITH *Points
    g_return_val_if_fail(Row < .Row, 0.0)
    g_return_val_if_fail(Column < .Col, 0.0)
    RETURN .Dat[Row * .Col + Column]
  END WITH
END FUNCTION

PROPERTY GooFiller.Prop(BYVAL Index AS guint) AS gchar PTR
  RETURN values[IIF(Index < Entries, Index, Index MOD Entries)].Prop
END PROPERTY

PROPERTY GooFiller.Value(BYVAL Index AS guint) AS gpointer
  RETURN values[IIF(Index < Entries, Index, Index MOD Entries)].Value
END PROPERTY

/'*
goo_filler_new:
@Entries: the number of entries in the #GooFiller.

Creates a new #GooFiller struct to be used in properties like
#GooBar2d:filler or #GooPie2d:filler. The entries gets initialized by
the default filler methods. Use goo_filler_set() to override an entry.

Free the memory by goo_filler_unref() when done.

Returns: (transfer full): a new #GooFiller structure.

Since: 0.0
'/
FUNCTION goo_filler_new CDECL(BYVAL Entries AS guint = 1) AS GooFiller PTR

  VAR filler = g_slice_new(GooFiller)
  WITH *filler
    .Entries = Entries
    .Values = g_slice_alloc(Entries * SIZEOF(GooFillerValue))
    VAR c = 0, d = @_goo_filler_default, e = UBOUND(_goo_fillers)
    FOR i AS INTEGER = 0 TO Entries - 1
      .Values[i] = TYPE(g_strdup(d->Prop(c)), d->Value(c))
      c += 1 : IF c > e THEN c = 0
    NEXT
    .RefCount = 1
  END WITH
  RETURN filler
END FUNCTION

/'*
goo_filler_unref:
@Filler: a #GooFiller structure.

Decrements the reference count of the given #GooFiller structure,
freeing it if the reference count falls to zero.

Since: 0.0
'/
SUB goo_filler_unref CDECL(BYVAL Filler AS GooFiller PTR)
  WITH *Filler
    .RefCount -= 1
    IF .RefCount <= 0 THEN
      FOR i AS INTEGER = 0 TO .Entries - 1
        g_free(.Values[i].Prop)
      NEXT
      g_slice_free1(.Entries * SIZEOF(GooFillerValue), .Values)
      g_slice_free(GooFiller, Filler)
    END IF
  END WITH
END SUB

/'*
goo_filler_ref:
@Filler: a #GooFiller structure.

Increments the reference count of the given #GooFiller structure.

Returns: the #GooFiller structure.

Since: 0.0
'/
FUNCTION goo_filler_ref CDECL(BYVAL Filler AS GooFiller PTR) AS GooFiller PTR
  Filler->RefCount += 1
  RETURN Filler
END FUNCTION

/'*
goo_filler_set:
@Filler: a #GooFiller structure.
 @Index: the position where to set the new property.
  @Prop: a property name for a #GooCanvasItemSimple filling method.
 @Value: the value for the filling method.

Set one #GooFiller property and value. All fill properties of
#GooCanvasItemSimple can be used (
#GooCanvasItemSimple:fill-color,
#GooCanvasItemSimple:fill-color-rgba,
#GooCanvasItemSimple:fill-color-gdk-rgba,
#GooCanvasItemSimple:fill-pattern,
#GooCanvasItemSimple:fill-pixbuf).

Returns: %TRUE1 if the new filler is set, otherwise %FALSE.

Since: 0.0
'/
FUNCTION goo_filler_set CDECL( _
  BYVAL Filler AS GooFiller PTR, _
  BYVAL Index AS guint, _
  BYVAL Prop AS gchar PTR, _
  BYVAL Value AS gpointer) AS gboolean
  WITH *Filler
    g_return_val_if_fail(Index < .Entries, TRUE1)
    g_return_val_if_fail(Prop > NULL, TRUE1)
    g_return_val_if_fail(Value > NULL, TRUE1)
    WITH .Values[Index]
      IF .Prop THEN g_free(.Prop)
      .Prop = g_strdup(Prop)
      .Value = Value
    END WITH
  END WITH
  RETURN FALSE
END FUNCTION

G_DEFINE_BOXED_TYPE(GooFiller, goo_filler, _
                               goo_filler_ref, _
                               goo_filler_unref)


SUB _goo_line.init(BYVAL Xn AS GooFloat, BYVAL Yn AS GooFloat, _
                   BYVAL Xa AS GooFloat, BYVAL Ya AS GooFloat)
  x = Xn
  y = Yn
  dx = x - Xa
  dy = y - Ya
  l = SQR(dx * dx + dy * dy)
  IF ABS(dx) > _GOO_EPS THEN
    w = ATN(dy / dx)
    IF dx < 0 THEN w += _GOO_PI
  ELSE
    w = IIF(dy < 0, -1, 1) * _GOO_PI_2
  END IF
END SUB

'~ read a value from a string (BIN, OCT, DEC, HEX with fractional digits)
FUNCTION _goo_value(BYREF T AS UBYTE PTR) AS GooFloat
  STATIC AS INTEGER a, e, b, x, y, d, f, v, c_deci = 10
  STATIC AS UBYTE PTR n
  STATIC AS DOUBLE r

  r = 0.0 : v = 1
  WHILE v '~             search for number start (first valid character)
    a = 0 : x = 0 : y = 0 : d = 1 : f = 0
    DO
      IF 0 = *T THEN T = 0 : RETURN 0.0 '~ stop at the end of the STRING
      IF *T = ASC("-") THEN n = T : T += 1 ELSE n = 0
      SELECT CASE AS CONST *T
      CASE ASC("."), ASC(",")
        IF *T = _GOO_NO_CHR[0] THEN _
                                  T += 1 : b = 10 : e = 14 : d = -1 : a = 1 : EXIT DO
      CASE ASC("0") : T += 1 '                      start C style values
        IF *T = _GOO_NO_CHR[0] THEN _
                          v = 0 : T += 1 : b = 10 : e = 14 : d = -1 : a = 1 : EXIT DO
        IF *T = ASC("x") THEN     T += 1 : b = 16 : e = 22 : EXIT DO
        v = 0                            : b =  8 : e =  8 : EXIT DO
      CASE ASC("1") TO ASC("9")          : b = 10 : e = 14 : EXIT DO
      CASE ASC("&") : T += 1 '~                    start FB style values
        SELECT CASE AS CONST *T
        CASE ASC("h"), ASC("H") : T += 1 : b = 16 : e = 22 : EXIT DO
        CASE ASC("o"), ASC("O") : T += 1 : b =  8 : e =  8 : EXIT DO
        CASE ASC("b"), ASC("B") : T += 1 : b =  2 : e =  2 : EXIT DO
        CASE ELSE : CONTINUE DO
        END SELECT
      END SELECT
      T += 1
    LOOP

    DO '~                                        collect all valid chars
      VAR i = a
      WHILE *T <> _GOO_NO_CHR[i] '~                          check digit
        i += 1 : IF i > e THEN EXIT DO '~             not valid -> break
      WEND

      IF i > c_deci ANDALSO e = 14 THEN '~              decimal exponent
        IF 0.0 = r THEN T += 1 : EXIT DO
        d = 0 : T += 1 : e = c_deci
        IF *T = ASC("+") THEN T += 1 ELSE _
        IF *T = ASC("-") THEN T += 1 : y = 1
        CONTINUE DO
      END IF

      IF i THEN
        f += d : v = 0
        IF d > 0 THEN '~                                    normal digit
          r *= b : r += _GOO_NO_VAL(i)
        ELSEIF d < 0 THEN '~                            fractional digit
          r += _GOO_NO_VAL(i) * b ^ f
        ELSE '~                                                 exponent
          x *= b : x += _GOO_NO_VAL(i)
        END IF
      ELSE '~                           decimal seperator (allowed once)
        a = 1 : d = -1 : f = 0
      END IF
      T += 1
    LOOP UNTIL 0 = *T '~                  break at the end of the STRING
  WEND : IF x THEN RETURN IIF(n, -r, r) * 10 ^ IIF(y, -x, x) '~ exponent
  RETURN IIF(n, -r, r) '~                        number without exponent
END FUNCTION

'~ add drawing statements to an GArray (GooCanvasPath)
SUB _goo_add_path(BYREF Path AS GArray PTR, BYVAL Mo AS UBYTE, ...)
  DIM AS GooCanvasPathCommand cmd
  DIM AS CVA_LIST args
  CVA_START(args, Mo)
  SELECT CASE AS CONST Mo
  CASE ASC("M"), ASC("m") : cmd.simple.relative = IIF(Mo = ASC("m"), 1, 0)
                          : cmd.simple.x = CVA_ARG(args, gdouble)
                          : cmd.simple.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_MOVE_TO
  CASE ASC("L"), ASC("l") : cmd.simple.relative = IIF(Mo = ASC("l"), 1, 0)
                          : cmd.simple.x = CVA_ARG(args, gdouble)
                          : cmd.simple.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_LINE_TO
  CASE ASC("H"), ASC("h") : cmd.simple.relative = IIF(Mo = ASC("h"), 1, 0)
                          : cmd.simple.x = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_HORIZONTAL_LINE_TO
  CASE ASC("V"), ASC("v") : cmd.simple.relative = IIF(Mo = ASC("v"), 1, 0)
                          : cmd.simple.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_VERTICAL_LINE_TO
  CASE ASC("T"), ASC("t") : cmd.simple.relative = IIF(Mo = ASC("t"), 1, 0)
                          : cmd.curve.x = CVA_ARG(args, gdouble)
                          : cmd.curve.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_SMOOTH_QUADRATIC_CURVE_TO
  CASE ASC("Q"), ASC("q") : cmd.simple.relative = IIF(Mo = ASC("q"), 1, 0)
                          : cmd.curve.x1 = CVA_ARG(args, gdouble)
                          : cmd.curve.y1 = CVA_ARG(args, gdouble)
                          : cmd.curve.x = CVA_ARG(args, gdouble)
                          : cmd.curve.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_QUADRATIC_CURVE_TO
  CASE ASC("S"), ASC("s") : cmd.simple.relative = IIF(Mo = ASC("s"), 1, 0)
                          : cmd.curve.x2 = CVA_ARG(args, gdouble)
                          : cmd.curve.y2 = CVA_ARG(args, gdouble)
                          : cmd.curve.x = CVA_ARG(args, gdouble)
                          : cmd.curve.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_SMOOTH_CURVE_TO
  CASE ASC("C"), ASC("c") : cmd.simple.relative = IIF(Mo = ASC("c"), 1, 0)
                          : cmd.curve.x1 = CVA_ARG(args, gdouble)
                          : cmd.curve.y1 = CVA_ARG(args, gdouble)
                          : cmd.curve.x2 = CVA_ARG(args, gdouble)
                          : cmd.curve.y2 = CVA_ARG(args, gdouble)
                          : cmd.curve.x = CVA_ARG(args, gdouble)
                          : cmd.curve.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_CURVE_TO
  CASE ASC("A"), ASC("a") : cmd.simple.relative = IIF(Mo = ASC("a"), 1, 0)
                          : cmd.arc.rx = CVA_ARG(args, gdouble)
                          : cmd.arc.ry = CVA_ARG(args, gdouble)
                          : cmd.arc.x_axis_rotation = CVA_ARG(args, gdouble)
                          : cmd.arc.large_arc_flag = CVA_ARG(args, gint)
                          : cmd.arc.sweep_flag = CVA_ARG(args, gint)
                          : cmd.arc.x = CVA_ARG(args, gdouble)
                          : cmd.arc.y = CVA_ARG(args, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_ELLIPTICAL_ARC
  CASE ELSE
    cmd.simple.type = GOO_CANVAS_PATH_CLOSE_PATH
  END SELECT : CVA_END(args)
  Path = g_array_append_val(Path, cmd)
END SUB

'~ add a marker to an GArray (GooCanvasPath)
SUB _goo_add_marker(BYVAL Path AS GArray PTR, _
  BYVAL Xp AS gdouble, BYVAL Yp AS gdouble, _
  BYVAL T AS GooDataMarkers = GOO_MARKER_CIRCLE, _
  BYVAL S AS gdouble = 8.0)

  VAR a = ABS(S), b = a / 2
  SELECT CASE AS CONST T
  CASE GOO_MARKER_TRIANGLE
    _goo_add_path(Path, ASC("M"), Xp, Yp + b)
    _goo_add_path(Path, ASC("l"), b, -a)
    _goo_add_path(Path, ASC("h"),-a)
    _goo_add_path(Path, ASC("l"), b, a)
    _goo_add_path(Path, ASC("z"))
  CASE GOO_MARKER_TRIANGLE2
    _goo_add_path(Path, ASC("M"), Xp, Yp + b)
    _goo_add_path(Path, ASC("l"), b, a)
    _goo_add_path(Path, ASC("h"),-a)
    _goo_add_path(Path, ASC("l"), b,-a)
    _goo_add_path(Path, ASC("z"))
  CASE GOO_MARKER_RHOMBUS
    _goo_add_path(Path, ASC("M"), Xp, Yp - b)
    _goo_add_path(Path, ASC("l"), b, b)
    _goo_add_path(Path, ASC("l"),-b, b)
    _goo_add_path(Path, ASC("l"),-b,-b)
    _goo_add_path(Path, ASC("l"), b,-b)
    _goo_add_path(Path, ASC("z"))
  CASE GOO_MARKER_RHOMBUS2
    _goo_add_path(Path, ASC("M"), Xp, Yp)
    _goo_add_path(Path, ASC("l"), b, b)
    _goo_add_path(Path, ASC("h"),-a)
    _goo_add_path(Path, ASC("l"), a,-a)
    _goo_add_path(Path, ASC("h"),-a)
    _goo_add_path(Path, ASC("l"), b, b)
    _goo_add_path(Path, ASC("z"))
  CASE GOO_MARKER_RHOMBUS3
    _goo_add_path(Path, ASC("M"), Xp, Yp)
    _goo_add_path(Path, ASC("l"), b, b)
    _goo_add_path(Path, ASC("v"),-a)
    _goo_add_path(Path, ASC("l"),-a, a)
    _goo_add_path(Path, ASC("v"),-a)
    _goo_add_path(Path, ASC("l"), b, b)
    _goo_add_path(Path, ASC("z"))
  CASE GOO_MARKER_SQUARE
    _goo_add_path(Path, ASC("M"), Xp + b, Yp + b)
    _goo_add_path(Path, ASC("v"),-a)
    _goo_add_path(Path, ASC("h"),-a)
    _goo_add_path(Path, ASC("v"), a)
    _goo_add_path(Path, ASC("z"))
  CASE GOO_MARKER_CROSS
    _goo_add_path(Path, ASC("M"), Xp - b, Yp - b)
    _goo_add_path(Path, ASC("l"), a, a)
    _goo_add_path(Path, ASC("m"),-a, 0.0)
    _goo_add_path(Path, ASC("l"), a,-a)
  CASE GOO_MARKER_CROSS2
    _goo_add_path(Path, ASC("M"), Xp, Yp - b)
    _goo_add_path(Path, ASC("v"), a)
    _goo_add_path(Path, ASC("m"),-b,-b)
    _goo_add_path(Path, ASC("h"), a)
  CASE GOO_MARKER_FLOWER1
    VAR c = a / 4
    _goo_add_path(Path, ASC("M"), Xp - c, Yp - c)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1, b, 0.0)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1, 0.0, b)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1,-b, 0.0)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1, 0.0,-b)
    _goo_add_path(Path, ASC("z"))
  CASE GOO_MARKER_FLOWER2
    VAR c = a / 4
    _goo_add_path(Path, ASC("M"), Xp, Yp - b)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1, b, b)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1,-b, b)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1,-b,-b)
    _goo_add_path(Path, ASC("a"), c, c, 0.0, 1, 1, b,-b)
    _goo_add_path(Path, ASC("z"))
  CASE ELSE '~ GOO_MARKER_CIRCLE
    _goo_add_path(Path, ASC("M"), Xp, Yp - b)
    _goo_add_path(Path, ASC("a"), b, b, 0.0, 0, 1, 0.0, a)
    _goo_add_path(Path, ASC("a"), b, b, 0.0, 0, 1, 0.0, -a)
    _goo_add_path(Path, ASC("z"))
  END SELECT
END SUB

'~ sort the index field of an array of GooFloat values
SUB _Goo_Sort(BYVAL V AS GooFloat PTR PTR, BYVAL N AS UINTEGER)
  VAR f = 0, l = N, p = 0
  DIM AS INTEGER QStack(l \ 5 + 10)
  DO
    DO
      VAR Temp = *V[(f + l) SHR 1]
      VAR i = f, j = l
      DO
        WHILE *V[i] < Temp
          i += 1
        WEND
        WHILE *V[j] > Temp
          j -= 1
        WEND
        IF i > j THEN EXIT DO
        IF i < j THEN SWAP V[i], V[j]
        i += 1
        j -= 1
      LOOP WHILE i <= j
      IF i < l THEN
        QStack(p) = i
        QStack(p + 1) = l
        p += 2
      END IF
      l = j
    LOOP WHILE f < l
    IF p = 0 THEN EXIT DO
    p -= 2
    f = QStack(p)
    l = QStack(p + 1)
  LOOP
END SUB

'~ set the drawing area
FUNCTION GooPolar.init(BYVAL Obj AS gpointer, _
                       BYVAL X AS GooFloat, BYVAL Y AS GooFloat, _
                       BYVAL W AS GooFloat, BYVAL H AS GooFloat, _
                       BYVAL A AS GooFloat, BYVAL R AS GooFloat, _
                       BYVAL C AS GooFloat = 0.0) AS gboolean

  Ws = A '~                             start angle
  Wr = IIF(R > _GOO_EPS, R, _2GOO_PI) '~ angle range

  DIM AS gdouble xn, xm, yn, ym, v, e = Ws + Wr, lw
  v = COS(A) : IF v > 0 THEN xm = v : xn = v * C ELSE xm = v * C : xn = v
  v = SIN(A) : IF v > 0 THEN ym = v : yn = v * C ELSE ym = v * C : yn = v
  IF ABS(A) < _GOO_EPS ORELSE _
      e > _2GOO_PI THEN                                     xm =  1.0
  IF (A < _GOO_PI_2  ANDALSO e > _GOO_PI_2) ORELSE _
      e > _GOO_PI_2 * 5 THEN                                 ym =  1.0
  IF (A < _GOO_PI    ANDALSO e > _GOO_PI) ORELSE _
      e > _GOO_PI_2 * 6 THEN                                 xn = -1.0
  IF (A < _GOO_PI_32 ANDALSO e > _GOO_PI_32) ORELSE _
      e > _GOO_PI_2 * 7 THEN                                 yn = -1.0
  v = COS(e) : IF v > xm THEN  xm = v  ELSE IF v < xn THEN  xn = v
  v *= C     : IF v > xm THEN  xm = v  ELSE IF v < xn THEN  xn = v
  v = SIN(e) : IF v > ym THEN  ym = v  ELSE IF v < yn THEN  yn = v
  v *= C     : IF v > ym THEN  ym = v  ELSE IF v < yn THEN  yn = v

  g_object_get(Obj, "line_width", @lw, NULL)
  VAR rx = (W - lw) / (xm - xn) : g_return_val_if_fail(rx > 0, TRUE1)
  VAR ry = (H - lw) / (ym - yn) : g_return_val_if_fail(ry > 0, TRUE1)

  Rr = rx * (1 - C) '~                 radius range
  Rv = ry / rx '~                      radius ratio
  Cx = X - xn * rx '~             center position X
  Cy = Y + H + yn * ry '~         center position Y
  Cent = rx * C '~              free area in center
  RETURN FALSE
END FUNCTION

'~ set gaps for pie segments, if required
FUNCTION GooPolar.init_gaps(BYVAL G AS GooFloat, BYVAL N AS UINTEGER) AS gboolean
  Gap = G * ((Cent + Rr) * (Rv + 1)) * Wr / 2 '~   gaps between segments
  GapFlag = IIF(N > 1, 1, 0) '~                              radial gaps
  g_return_val_if_fail(Gap * N < Rr, TRUE1) '~             gaps too large
  RETURN FALSE
END FUNCTION

'~ draw a radial line (polax grid)
SUB GooPolar.line(BYVAL Pa AS GArray PTR, BYVAL P AS GooFloat)
  VAR ri = Cent, ra = ri + Rr, w = Ws + P * Wr, s = SIN(W) * Rv, c = COS(W)
  _goo_add_path(Pa, ASC("M"), Cx + c * ri, Cy - s * ri)
  _goo_add_path(Pa, ASC("L"), Cx + c * ra, Cy - s * ra)
END SUB

'~ draw a circular line (polax grid)
SUB GooPolar.circle(BYVAL Pa AS GArray PTR, BYVAL P AS GooFloat)
  VAR rx = Cent + P * Rr, ry = rx * Rv
  IF Wr < _2GOO_PI THEN
    VAR we = Ws + Wr
    _goo_add_path(Pa, ASC("M"), COS(Ws) * rx + Cx, Cy - ry * SIN(Ws))
    _goo_add_path(Pa, ASC("A"), rx, ry, 0.0, IIF(Wr > _GOO_PI, 1, 0), 0, _
                                COS(we) * rx + Cx, Cy - ry * SIN(we))
  ELSE '~                                                    full circle
    _goo_add_path(Pa, ASC("M"), rx + Cx, Cy)
    _goo_add_path(Pa, ASC("A"), rx, ry, 0.0, 0, 0, Cx - rx, Cy)
    _goo_add_path(Pa, ASC("A"), rx, ry, 0.0, 0, 0, Cx + rx, Cy)
  END IF
END SUB

'~ draw an area (pie segment, polax background)
SUB GooPolar.segment(BYVAL Pa AS GArray PTR, _
                     BYVAL Ri AS GooFloat, BYVAL Rd AS GooFloat, _
                     BYVAL Wa AS GooFloat, BYVAL Wd AS GooFloat)
  VAR xi = Cent + Ri * Rr, xa = xi + Rd * Rr
  IF GapFlag THEN IF xi > _GOO_EPS THEN xi += Gap : IF xi > xa THEN EXIT SUB
  VAR ya = xa * Rv, yi = xi * Rv
  VAR aa = Ws + Wa * Wr, ae = aa + Wd * Wr, ad2 = (ae - aa) / 2
  IF ad2 >= _GOO_PI - _GOO_EPS THEN '~                full circle outside
    _goo_add_path(Pa, ASC("M"), xa + Cx, Cy)
    _goo_add_path(Pa, ASC("A"), xa, ya, 0.0, 0, 0, Cx - xa, Cy)
    _goo_add_path(Pa, ASC("A"), xa, ya, 0.0, 0, 0, Cx + xa, Cy)
    IF xi THEN '~                                     full circle inside
      _goo_add_path(Pa, ASC("M"), xi + Cx, Cy)
      _goo_add_path(Pa, ASC("A"), xi, yi, 0.0, 0, 0, Cx - xi, Cy)
      _goo_add_path(Pa, ASC("A"), xi, yi, 0.0, 0, 0, Cx + xi, Cy)
    END IF
    _goo_add_path(Pa, ASC("z"))
    EXIT SUB
  END IF

  VAR siz = IIF(ad2 > _GOO_PI_2, 1, 0)
  IF 0 = Gap THEN '~                                             no gaps
    VAR sa = SIN(aa), ca = COS(aa)
    VAR se = SIN(ae), ce = COS(ae)
    _goo_add_path(Pa, ASC("M"), Cx + xa * ca, Cy - ya * sa)
    _goo_add_path(Pa, ASC("A"), xa, ya, 0.0, siz, 0, Cx + xa * ce, Cy - ya * se)
    IF xi THEN '~                                          center circle
      _goo_add_path(Pa, ASC("L"), Cx + xi * ce, Cy - yi * se)
      _goo_add_path(Pa, ASC("A"), xi, yi, 0.0, siz, 1, Cx + xi * ca, Cy - yi * sa)
    ELSE '~                                                 center point
      _goo_add_path(Pa, ASC("L"), Cx, Cy)
    END IF
    _goo_add_path(Pa, ASC("z")) : EXIT SUB
  END IF

  VAR dw = ASIN(Gap / xa / 2) : IF dw > ad2 THEN EXIT SUB '~   too small
  VAR w = aa + dw '~                                  outer segment line
  _goo_add_path(Pa, ASC("M"), Cx + xa * COS(w), Cy - ya * SIN(w))
  w = ae - dw
  _goo_add_path(Pa, ASC("A"), xa, ya, 0.0, siz, 0, _
                              Cx + xa * COS(w), Cy - ya * SIN(w))

  IF xi > Gap THEN dw = ASIN(Gap / xi / 2) ELSE dw = _GOO_PI_2 : siz = 0
  IF ad2 < dw THEN '~                              inner segment point
    VAR l = Gap / SIN(ad2) / 2 : IF l > 0.9 * xa THEN l = 0.9 * xa
    w = aa + ad2
    _goo_add_path(Pa, ASC("L"), Cx + COS(w) * l, Cy - SIN(w) * l * Rv)
  ELSE '~                                          inner segment point
    w = ae - dw
    _goo_add_path(Pa, ASC("L"), Cx + xi * COS(w), Cy - yi * SIN(w))
    w = aa + dw
    _goo_add_path(Pa, ASC("A"), xi, yi, 0.0, siz, 1, _
                                Cx + xi * COS(w), Cy - yi * SIN(w))
  END IF
  _goo_add_path(Pa, ASC("z"))
END SUB

