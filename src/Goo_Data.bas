'~This is file Goo_Data.bas
'~A library to present technical data
'~
'~Licence: LGPLv2
'~(C) 2012-2018 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net

/'*
SECTION:Goo_Data
@Title: GooData
@Short_Description: common functions used for all widgets.

bla, bla, bla
'/

#IF DEFINED(__FB_WIN32__)
#LIBPATH "C:\opt\GTK\lib" '~                             your paths here
#ENDIF

#INCLUDE ONCE "Goo_Data.bi"

#DEFINE __(_T_) _T_
'~ #DEFINE DBL_MAX 1.79e308
'~ #IFDEF GOO_DEBUG
#IF 0
 #DEFINE TRIN(_T_) ?!"\n"; LCASE(__FUNCTION__);_T_;
 #DEFINE TROUT(_T_) ?" -> out ";_T_;
#ELSE
 ?"";
 #DEFINE TRIN(_T_)
 #DEFINE TROUT(_T_)
#ENDIF

#DEFINE GOO_DEFAULT_FORM @"%g"
#DEFINE GOO_SINF CVS(MKI(&b01111111100000000000000000000000uL))
#DEFINE GOO_DINF CVD(MKLONGINT(&b0111111111110000000000000000000000000000000000000000000000000000uLL))

CONST GOO_PI = 4 * ATN(1)
CONST _2GOO_PI = GOO_PI * 2
CONST GOO_PI_2 = GOO_PI / 2
CONST GOO_PI_32 = GOO_PI_2 * 3
CONST DEG_RAD = GOO_PI / 180

STATIC SHARED AS _GooFillerValue _goo_fillers(15)
_goo_fillers( 0) = TYPE(@"fill-color", @"red1")
_goo_fillers( 1) = TYPE(@"fill-color", @"blue1")
_goo_fillers( 2) = TYPE(@"fill-color", @"green1")
_goo_fillers( 3) = TYPE(@"fill-color", @"yellow1")
_goo_fillers( 4) = TYPE(@"fill-color", @"gray1")
_goo_fillers( 5) = TYPE(@"fill-color", @"orange1")
_goo_fillers( 6) = TYPE(@"fill-color", @"brown1")
_goo_fillers( 7) = TYPE(@"fill-color", @"pink1")
_goo_fillers( 8) = TYPE(@"fill-color", @"red3")
_goo_fillers( 9) = TYPE(@"fill-color", @"blue3")
_goo_fillers(10) = TYPE(@"fill-color", @"green3")
_goo_fillers(11) = TYPE(@"fill-color", @"yellow3")
_goo_fillers(12) = TYPE(@"fill-color", @"gray3")
_goo_fillers(13) = TYPE(@"fill-color", @"orange3")
_goo_fillers(14) = TYPE(@"fill-color", @"brown3")
_goo_fillers(15) = TYPE(@"fill-color", @"pink3")
'~ STATIC SHARED AS guint _GOO_COLORS(...) => { _
  '~ &hFF0000FF, &h00FF00FF, &h0000FFFF, &hFF00FFFF, _
  '~ &hFFFF00FF, &h00FFFFFF, &hC0C0C0FF, &hFF8000FF, _
  '~ &h00FFB0FF, &h407F40FF, &h800080FF, &hC0FFC0FF, _
  '~ &hA08060FF, &h40F0C0FF, &h80A060FF, &h6080A0FF}
'~ _goo_fillers( 0) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hFF0000FFu))
'~ _goo_fillers( 1) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h00FF00FFu))
'~ _goo_fillers( 2) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h0000FFFFu))
'~ _goo_fillers( 3) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hFF00FFFFu))
'~ _goo_fillers( 4) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hFFFF00FFu))
'~ _goo_fillers( 5) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h00FFFFFFu))
'~ _goo_fillers( 6) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hC0C0C0FFu))
'~ _goo_fillers( 7) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hFF8000FFu))
'~ _goo_fillers( 8) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h00FFB0FFu))
'~ _goo_fillers( 9) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h407F40FFu))
'~ _goo_fillers(10) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hC0FFC0FFu))
'~ _goo_fillers(11) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hC0FFC0FFu))
'~ _goo_fillers(12) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&hA08060FFu))
'~ _goo_fillers(13) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h40F0C0FFu))
'~ _goo_fillers(14) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h80A060FFu))
'~ _goo_fillers(15) = TYPE(@"fill-color-rgba", GSIZE_TO_POINTER(&h6080A0FFu))
STATIC SHARED AS GooFiller _goo_filler_default
WITH _goo_filler_default
  .Values = @_goo_fillers(0)
  .Entries = UBOUND(_goo_fillers) + 1
  .RefCount = 1
END WITH


'~ don't change the order, important for _goo_value()!
STATIC SHARED AS STRING*23 _GOO_NO_CHR = ".0123456789DEdeABCFabcf"
STATIC SHARED AS UBYTE _GOO_NO_VAL(...) = {0,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, _
                                          13, 14, 13, 14, 10, 11, 12, 15, 10, 11, 12, 15}

/'* goo_set_decimal_separator:
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

FUNCTION _goo_palette CDECL(BYVAL Scale AS GooType, BYVAL Alpha_ AS UBYTE = &hFF) AS guint
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

/'* goo_palette_set_function:
@Func: A function that returns a color value for a rgba property
 (ie for #GooCanvasItemSimple:fill-color-rgba).

Sets the goo_palette_function() for color gradients. Pass %NULL to
reset the default goo_palette_function().

Since: 0.0
'/
SUB goo_palette_set_function CDECL(BYVAL Func AS goo_palette_function)
  goo_palette = IIF(Func, Func, @_goo_palette)
END SUB


/'* goo_data_points_ref:
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

/'* goo_data_points_unref:
@Points: a #GooDataPoints struct.

Decrements the reference count of the given #GooDataPoints struct,
freeing it if the reference count falls to zero.

Since: 0.0
'/
SUB goo_data_points_unref CDECL(BYVAL Points AS GooDataPoints PTR)
  WITH *Points
    .RefCount -= 1
    IF .RefCount <= 0 THEN
      IF .m_flag THEN g_slice_free1(.Row * .Col * SIZEOF(GooType), .Dat)
      g_slice_free(GooDataPoints, Points)
    END IF
  END WITH
END SUB

G_DEFINE_BOXED_TYPE(GooDataPoints, _goo_data_points, _
                                    goo_data_points_ref, _
                                    goo_data_points_unref)

/'* goo_data_points_new:
@Rows : the number of rows to create in the array.
@Columns: the number of columns to create in the array or nothing to create one column.
@Array: an (optional) array with the given number of rows and columns
of GooType values or %NULL to create a new internal array.

Creates a new #GooDataPoints struct. The structure can either allocate
space for the given number of values or can hold an previously created
array of GooType values.

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
  BYVAL Array AS GooType PTR = 0) AS GooDataPoints PTR

  VAR points = g_slice_new(GooDataPoints)
  WITH *points
    .Row =    IIF(Rows < 1, 1, Rows)
    .Col = IIF(Columns < 1, 1, Columns)
    IF Array THEN
      .Dat = Array
      .m_flag = 0
    ELSE
      .Dat = g_slice_alloc(.Row * .Col * SIZEOF(GooType))
      .m_flag = 1
    END IF
    .RefCount = 1
  END WITH
  RETURN points
END FUNCTION

/'* goo_data_points_set_point:
@Points: a #GooDataPoints struct.
@Row: the row of the value to set.
@Column: the column of the value to set.
@Value: the value to set at row and column.

Set a value in the #GooDataPoints struct.

Since: 0.0
'/
SUB goo_data_points_set_point CDECL(BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, BYVAL Column AS guint, _
  BYVAL Value AS GooType)
  WITH *Points
    g_return_if_fail(Row < .Row)
    g_return_if_fail(Column < .Col)
    .Dat[Row * .Col + Column] = Value
  END WITH
END SUB

/'* goo_data_points_get_point:
@Points: a #GooDataPoints struct.
@Row: the row of the value to get.
@Column: the column of the value to get.

Get a value from the #GooDataPoints struct.

Returns: the value to get from row and column.

Since: 0.0
'/
FUNCTION goo_data_points_get_point CDECL(BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, BYVAL Column AS guint) AS GooType
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

/'* goo_filler_new:
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

/'* goo_filler_unref:
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

/'* goo_filler_ref:
@Filler: a #GooFiller structure.

Increments the reference count of the given #GooFiller structure.

Returns: the #GooFiller structure.

Since: 0.0
'/
FUNCTION goo_filler_ref CDECL(BYVAL Filler AS GooFiller PTR) AS GooFiller PTR
  Filler->RefCount += 1
  RETURN Filler
END FUNCTION

/'* goo_filler_set:
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

Returns: %TRUE if the new filler is set, otherwise %FALSE.

Since: 0.0
'/
FUNCTION goo_filler_set CDECL( _
  BYVAL Filler AS GooFiller PTR, _
  BYVAL Index AS guint, _
  BYVAL Prop AS gchar PTR, _
  BYVAL Value AS gpointer) AS gboolean
  WITH *Filler
    g_return_val_if_fail(Index < .Entries, TRUE)
    g_return_val_if_fail(Prop > NULL, TRUE)
    g_return_val_if_fail(Value > NULL, TRUE)
    WITH .Values[Index]
      IF .Prop THEN g_free(.Prop)
      .Prop = g_strdup(Prop)
      .Value = Value
    END WITH
  END WITH
  RETURN FALSE
END FUNCTION

G_DEFINE_BOXED_TYPE(GooFiller, _goo_filler, _
                                goo_filler_ref, _
                                goo_filler_unref)


'~ analyse a line, calculate angle and length
TYPE _GooLine
  AS GooType x, y, dx, dy, l, w
  DECLARE SUB init(BYVAL Xn AS GooType, BYVAL Yn AS GooType, _
                   BYVAL Xa AS GooType, BYVAL Ya AS GooType)
END TYPE

SUB _GooLine.init(BYVAL Xn AS GooType, BYVAL Yn AS GooType, _
                  BYVAL Xa AS GooType, BYVAL Ya AS GooType)
  x = Xn
  y = Yn
  dx = x - Xa
  dy = y - Ya
  l = SQR(dx * dx + dy * dy)
  IF ABS(dx) > GOO_EPS THEN
    w = ATN(dy / dx)
    IF dx < 0 THEN w += GOO_PI
  ELSE
    w = IIF(dy < 0, -1, 1) * GOO_PI_2
  END IF
END SUB

'~ read a value from a string (BIN, OCT, DEC, HEX with fractional digits)
FUNCTION _goo_value(BYREF T AS UBYTE PTR) AS GooType
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
SUB _goo_add_path(BYVAL Path AS GArray PTR, BYVAL Mo AS UBYTE, ...)
  STATIC AS GooCanvasPathCommand cmd
  STATIC AS ANY PTR va
  SELECT CASE AS CONST Mo
  CASE ASC("M"), ASC("m")     : cmd.simple.relative = IIF(Mo = ASC("m"), 1, 0)
    va = VA_FIRST()           : cmd.simple.x = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.simple.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_MOVE_TO
  CASE ASC("L"), ASC("l")     : cmd.simple.relative = IIF(Mo = ASC("l"), 1, 0)
    va = VA_FIRST()           : cmd.simple.x = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.simple.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_LINE_TO
  CASE ASC("H"), ASC("h")     : cmd.simple.relative = IIF(Mo = ASC("h"), 1, 0)
    va = VA_FIRST()           : cmd.simple.x = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_HORIZONTAL_LINE_TO
  CASE ASC("V"), ASC("v")     : cmd.simple.relative = IIF(Mo = ASC("v"), 1, 0)
    va = VA_FIRST()           : cmd.simple.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_VERTICAL_LINE_TO
  CASE ASC("T"), ASC("t")     : cmd.simple.relative = IIF(Mo = ASC("t"), 1, 0)
    va = VA_FIRST()           : cmd.curve.x = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_SMOOTH_QUADRATIC_CURVE_TO
  CASE ASC("Q"), ASC("q")     : cmd.simple.relative = IIF(Mo = ASC("q"), 1, 0)
    va = VA_FIRST()           : cmd.curve.x1 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y1 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.x = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_QUADRATIC_CURVE_TO
  CASE ASC("S"), ASC("s")     : cmd.simple.relative = IIF(Mo = ASC("s"), 1, 0)
    va = VA_FIRST()           : cmd.curve.x2 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y2 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.x = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_SMOOTH_CURVE_TO
  CASE ASC("C"), ASC("c")     : cmd.simple.relative = IIF(Mo = ASC("c"), 1, 0)
    va = VA_FIRST()           : cmd.curve.x1 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y1 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.x2 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y2 = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.x = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.curve.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_CURVE_TO
  CASE ASC("A"), ASC("a")     : cmd.simple.relative = IIF(Mo = ASC("a"), 1, 0)
    va = VA_FIRST()           : cmd.arc.rx = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.arc.ry = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.arc.x_axis_rotation = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.arc.large_arc_flag = VA_ARG(va, gint)
    va = VA_NEXT(va, gint)    : cmd.arc.sweep_flag = VA_ARG(va, gint)
    va = VA_NEXT(va, gint)    : cmd.arc.x = VA_ARG(va, gdouble)
    va = VA_NEXT(va, gdouble) : cmd.arc.y = VA_ARG(va, gdouble)
    cmd.simple.type = GOO_CANVAS_PATH_ELLIPTICAL_ARC
  CASE ELSE
    cmd.simple.type = GOO_CANVAS_PATH_CLOSE_PATH
  END SELECT
  g_array_append_val(Path, cmd)
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

'~ sort the index field of an array of GooType values
SUB _Goo_Sort(BYVAL V AS GooType PTR PTR, BYVAL N AS UINTEGER)
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

'~ struct for polax and pie segments
TYPE _GooPolar
  AS GooType Cx, Cy, Rr, Rv, Ws, Wr, Gap, Cent
  AS gboolean GapFlag
  DECLARE FUNCTION init(BYVAL Obj AS gpointer, _
                        BYVAL X AS GooType, BYVAL Y AS GooType, _
                        BYVAL W AS GooType, BYVAL H AS GooType, _
                        BYVAL A AS GooType, BYVAL E AS GooType, _
                        BYVAL C AS GooType = 0.0) AS gboolean
  DECLARE FUNCTION init_gaps(BYVAL G AS GooType, BYVAL N AS UINTEGER) AS gboolean
  DECLARE SUB line(BYVAL Pa AS GArray PTR, BYVAL P AS GooType)
  DECLARE SUB circle(BYVAL Pa AS GArray PTR, BYVAL P AS GooType)
  DECLARE SUB segment(BYVAL Path AS GArray PTR, _
                      BYVAL Ri AS GooType, BYVAL Rd AS GooType, _
                      BYVAL Wa AS GooType, BYVAL Wd AS GooType)
END TYPE

'~ set the drawing area
FUNCTION _GooPolar.init(BYVAL Obj AS gpointer, _
                        BYVAL X AS GooType, BYVAL Y AS GooType, _
                        BYVAL W AS GooType, BYVAL H AS GooType, _
                        BYVAL A AS GooType, BYVAL R AS GooType, _
                        BYVAL C AS GooType = 0.0) AS gboolean

  Ws = A '~                             start angle
  Wr = IIF(R > GOO_EPS, R, _2GOO_PI) '~ angle range

  DIM AS gdouble xn, xm, yn, ym, v, e = Ws + Wr, lw
  v = COS(A) : IF v > 0 THEN xm = v : xn = v * C ELSE xm = v * C : xn = v
  v = SIN(A) : IF v > 0 THEN ym = v : yn = v * C ELSE ym = v * C : yn = v
  IF ABS(A) < GOO_EPS ORELSE _
      e > _2GOO_PI THEN                                     xm =  1.0
  IF (A < GOO_PI_2  ANDALSO e > GOO_PI_2) ORELSE _
      e > GOO_PI_2 * 5 THEN                                 ym =  1.0
  IF (A < GOO_PI    ANDALSO e > GOO_PI) ORELSE _
      e > GOO_PI_2 * 6 THEN                                 xn = -1.0
  IF (A < GOO_PI_32 ANDALSO e > GOO_PI_32) ORELSE _
      e > GOO_PI_2 * 7 THEN                                 yn = -1.0
  v = COS(e) : IF v > xm THEN  xm = v  ELSE IF v < xn THEN  xn = v
  v *= C     : IF v > xm THEN  xm = v  ELSE IF v < xn THEN  xn = v
  v = SIN(e) : IF v > ym THEN  ym = v  ELSE IF v < yn THEN  yn = v
  v *= C     : IF v > ym THEN  ym = v  ELSE IF v < yn THEN  yn = v

  g_object_get(Obj, "line_width", @lw, NULL)
  VAR rx = (W - lw) / (xm - xn) : g_return_val_if_fail(rx > 0, TRUE)
  VAR ry = (H - lw) / (ym - yn) : g_return_val_if_fail(ry > 0, TRUE)

  Rr = rx * (1 - C) '~                 radius range
  Rv = ry / rx '~                      radius ratio
  Cx = X - xn * rx '~             center position X
  Cy = Y + H + yn * ry '~         center position Y
  Cent = rx * C '~              free area in center
  RETURN FALSE
END FUNCTION

'~ set gaps for pie segments, if required
FUNCTION _GooPolar.init_gaps(BYVAL G AS GooType, BYVAL N AS UINTEGER) AS gboolean
  Gap = G * ((Cent + Rr) * (Rv + 1)) * Wr / 2 '~   gaps between segments
  GapFlag = IIF(N > 1, 1, 0) '~                              radial gaps
  g_return_val_if_fail(Gap * N < Rr, TRUE) '~             gaps too large
  RETURN FALSE
END FUNCTION

'~ draw a radial line (polax grid)
SUB _GooPolar.line(BYVAL Pa AS GArray PTR, BYVAL P AS GooType)
  VAR ri = Cent, ra = ri + Rr, w = Ws + P * Wr, s = SIN(W) * Rv, c = COS(W)
  _goo_add_path(Pa, ASC("M"), Cx + c * ri, Cy - s * ri)
  _goo_add_path(Pa, ASC("L"), Cx + c * ra, Cy - s * ra)
END SUB

'~ draw a circular line (polax grid)
SUB _GooPolar.circle(BYVAL Pa AS GArray PTR, BYVAL P AS GooType)
  VAR rx = Cent + P * Rr, ry = rx * Rv
  IF Wr < _2GOO_PI THEN
    VAR we = Ws + Wr
    _goo_add_path(Pa, ASC("M"), COS(Ws) * rx + Cx, Cy - ry * SIN(Ws))
    _goo_add_path(Pa, ASC("A"), rx, ry, 0.0, IIF(Wr > GOO_PI, 1, 0), 0, _
                                COS(we) * rx + Cx, Cy - ry * SIN(we))
  ELSE '~                                                    full circle
    _goo_add_path(Pa, ASC("M"), rx + Cx, Cy)
    _goo_add_path(Pa, ASC("A"), rx, ry, 0.0, 0, 0, Cx - rx, Cy)
    _goo_add_path(Pa, ASC("A"), rx, ry, 0.0, 0, 0, Cx + rx, Cy)
  END IF
END SUB

'~ draw an area (pie segment, polax background)
SUB _GooPolar.segment(BYVAL Pa AS GArray PTR, _
                      BYVAL Ri AS GooType, BYVAL Rd AS GooType, _
                      BYVAL Wa AS GooType, BYVAL Wd AS GooType)
  VAR xi = Cent + Ri * Rr, xa = xi + Rd * Rr
  IF GapFlag THEN IF xi > GOO_EPS THEN xi += Gap : IF xi > xa THEN EXIT SUB
  VAR ya = xa * Rv, yi = xi * Rv
  VAR aa = Ws + Wa * Wr, ae = aa + Wd * Wr, ad2 = (ae - aa) / 2
  IF ad2 >= GOO_PI - GOO_EPS THEN '~                 full circle outside
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

  VAR siz = IIF(ad2 > GOO_PI_2, 1, 0)
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

  IF xi > Gap THEN dw = ASIN(Gap / xi / 2) ELSE dw = GOO_PI_2 : siz = 0
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


#MACRO _GOO_DEFINE_PROP(_W_,_T_,_I_,_L_,_C_)
 SUB goo_##_W_##_get_##_L_##_properties CDECL(BYVAL _T_ AS Goo##_T_ PTR, ...)
 _GOO_DEFINE_PROP_(get,_W_,_T_,_I_,_L_,_C_)
 SUB goo_##_W_##_set_##_L_##_properties CDECL(BYVAL _T_ AS Goo##_T_ PTR, ...)
 _GOO_DEFINE_PROP_(set,_W_,_T_,_I_,_L_,_C_)
#ENDMACRO

'[
#MACRO _GOO_DEFINE_PROP_(_M_,_W_,_T_,_I_,_L_,_C_)
 TRIN("")

   g_return_if_fail(GOO_IS_##_I_(_T_))

   VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
   IF arg THEN _
     g_object_##_M_##_valist(G_OBJECT(_T_->##_C_), arg, VA_NEXT(va, ANY PTR))

 TROUT("")
 END SUB
#ENDMACRO
']

'{
#MACRO _GOO_EVAL_SEGMENT(_P_,_A_,_R_)
 VAR _A_ = 0.0, _R_ = 0.0
 IF _P_ ANDALSO _P_[0] <> 0 THEN
   VAR p = _P_
   _A_ = ABS(_goo_value(p)) * DEG_RAD
   IF p THEN
     IF _A_ >= _2GOO_PI THEN _A_ = FRAC(_A_ / _2GOO_PI) * _2GOO_PI
     _R_ = ABS(_goo_value(p)) * DEG_RAD
     IF p THEN IF _R_ >= _2GOO_PI THEN _R_ = FRAC(_R_ / _2GOO_PI) * _2GOO_PI
   END IF
 END IF
#ENDMACRO
'}

#INCLUDE ONCE "Goo_Axis.bas"
#INCLUDE ONCE "Goo_Polax.bas"
#INCLUDE ONCE "Goo_Curve2d.bas"
#INCLUDE ONCE "Goo_Simplecurve2d.bas"
#INCLUDE ONCE "Goo_Pie2d.bas"
#INCLUDE ONCE "Goo_Bar2d.bas"
#INCLUDE ONCE "Goo_Box2d.bas"
