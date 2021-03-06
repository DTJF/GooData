#INCLUDE ONCE "cairo/cairo.bi"
#INCLUDE ONCE "Gir/GooCanvas-2.0.bi"
#INCLUDE ONCE "Gir/_GObjectMacros-2.0.bi"
#INCLUDE ONCE "Gir/_GLibMacros-2.0.bi"

' fixing headers:
EXTERN AS GQuark goo_canvas_style_line_dash_id ALIAS "goo_canvas_style_line_dash_id"

#DEFINE TRUE1 (1)

TYPE AS gdouble GooFloat
#DEFINE __(_T_) _T_
'~ #DEFINE DBL_MAX 1.79e308
'~ #IFDEF GOO_DEBUG
#IF 1
 #DEFINE TRIN(_T_) ?!"\n"; LCASE(__FUNCTION__);_T_;
 #DEFINE TROUT(_T_) ?" -> out ";_T_;
#ELSE
 ?"";
 #DEFINE TRIN(_T_)
 #DEFINE TROUT(_T_)
#ENDIF

#DEFINE _GOO_DEFAULT_FORMAT @"%g"
#DEFINE _GOO_SINF CVS(MKI(&b01111111100000000000000000000000uL))
#DEFINE _GOO_DINF CVD(MKLONGINT(&b0111111111110000000000000000000000000000000000000000000000000000uLL))

CONST _GOO_EPS = 1e-7
CONST _GOO_PI = 4 * ATN(1)
CONST _2GOO_PI = _GOO_PI * 2
CONST _GOO_PI_2 = _GOO_PI / 2
CONST _GOO_PI_32 = _GOO_PI_2 * 3
CONST _DEG_RAD = _GOO_PI / 180



'~ don't change the order, important for _goo_value()!
STATIC SHARED AS STRING*23 _GOO_NO_CHR = ".0123456789DEdeABCFabcf"
STATIC SHARED AS UBYTE _GOO_NO_VAL(...) = {0,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, _
                                          13, 14, 13, 14, 10, 11, 12, 15, 10, 11, 12, 15}

TYPE GooScaleFunc AS FUNCTION(BYVAL AS GooFloat) AS GooFloat
TYPE GooItemUpdateFunc AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

/'*
GooDataMarkers:
@GOO_MARKER_NONE: no markers for the curve
@GOO_MARKER_CIRCLE: a filled circle
@GOO_MARKER_CROSS: a cross like an 'X'
@GOO_MARKER_CROSS2: a cross like a 't'
@GOO_MARKER_TRIANGLE: an equilateral triangle, tip up
@GOO_MARKER_TRIANGLE2: an equilateral triangle, tip down
@GOO_MARKER_RHOMBUS: a rhombus
@GOO_MARKER_RHOMBUS2: two rhombus in up / down direction
@GOO_MARKER_RHOMBUS3: two rhombus in left / right direction
@GOO_MARKER_SQUARE: a square
@GOO_MARKER_FLOWER1: four half-circles in up / down direction
@GOO_MARKER_FLOWER2: four half-circles rotated by 45 degrees

Enum values used for #GooCurve:marker-type property
to specify the type of the Markers.

Since: 0.0
'/
ENUM GooDataMarkers
  GOO_MARKER_NONE
  GOO_MARKER_CIRCLE
  GOO_MARKER_CROSS
  GOO_MARKER_CROSS2
  GOO_MARKER_TRIANGLE
  GOO_MARKER_TRIANGLE2
  GOO_MARKER_RHOMBUS
  GOO_MARKER_RHOMBUS2
  GOO_MARKER_RHOMBUS3
  GOO_MARKER_SQUARE
  GOO_MARKER_FLOWER1
  GOO_MARKER_FLOWER2
  '~ GOO_MARKER_LAST
END ENUM

DECLARE FUNCTION goo_set_decimal_separator CDECL(BYVAL V AS UByte = 0) AS UBYTE

'@RefCount: the reference count of the struct.
'@m_flag: a flag if array memory should be freed on ref_count = 0.
'@Row: the number of rows for the array.
'@Col: the number of columns for the array.
'@Dat: the data values to draw
/'*
GooDataPoints:

#GooDataPoints represents an array of numerical values as the source
for all the graph types. It contains private data only. Use the
functions of the goo_data_points family to set the content.

The data array may contain more data (more columns)
than used in a graph, so one structs can be used for multiple graphs.

Since: 0.0
'/
TYPE GooDataPoints
  AS guint Row, Col
  AS GooFloat PTR Dat
  AS gint RefCount, m_flag : 1
END TYPE

DECLARE FUNCTION goo_data_points_new CDECL( _
  BYVAL Rows AS guint, _
  BYVAL Columns AS guint, _
  BYVAL Array AS GooFloat PTR = 0) AS GooDataPoints PTR
DECLARE FUNCTION goo_data_points_ref CDECL( _
  BYVAL Points AS GooDataPoints PTR) AS GooDataPoints PTR
DECLARE SUB goo_data_points_unref CDECL(BYVAL Points AS GooDataPoints PTR)
DECLARE SUB goo_data_points_set_point CDECL( _
  BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, _
  BYVAL Column AS guint, _
  BYVAL Value AS GooFloat)
DECLARE FUNCTION goo_data_points_get_point CDECL( _
  BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, _
  BYVAL Column AS guint) AS GooFloat
DECLARE FUNCTION goo_data_points_get_type CDECL() AS GType
#DEFINE GOO_TYPE_DATA_POINTS (goo_data_points_get_type())
'~ #DEFINE GOO_DATA_POINTS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), GOO_TYPE_DATA_POINTS, GooDataPoints))
'~ #DEFINE GOO_IS_DATA_POINTS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GOO_TYPE_DATA_POINTS))


/'*
GooFillerValue:

The #GooFillerValue-struct struct represents a #GooCanvasItemSimple
filling method. It contains private data only. Use the functions of the
goo_filler family to set the content.

Since: 0.0
'/
TYPE GooFillerValue
  AS gchar PTR Prop
  AS gpointer Value
END TYPE

/'*
GooFiller:

The #GooFiller-struct struct is used to set the #GooCanvasItemSimple
filling methods for graphs with multiple colored items like #GooBar2d
or #GooPie2d. It contains private data only. Use the functions below to
set the content.

Since: 0.0
'/
TYPE GooFiller
  AS GooFillerValue PTR Values
  AS gint RefCount, Entries
  DECLARE PROPERTY Prop(BYVAL Index AS guint) AS gchar PTR
  DECLARE PROPERTY Value(BYVAL Index AS guint) AS gpointer
END TYPE

#DEFINE GOO_TYPE_FILLER (goo_filler_get_type())
DECLARE FUNCTION _goo_value(BYREF AS UBYTE PTR) AS GooFloat
DECLARE SUB _goo_add_path(BYREF AS GArray PTR, BYVAL AS UBYTE, ...)
DECLARE SUB _goo_sort(BYVAL AS GooFloat PTR PTR, BYVAL AS UINTEGER)
DECLARE SUB _goo_add_marker(BYVAL AS GArray PTR, _
  BYVAL AS GooFloat, BYVAL AS GooFloat, _
  BYVAL AS GooDataMarkers = GOO_MARKER_CIRCLE, _
  BYVAL AS GooFloat = 8.0)
DECLARE FUNCTION goo_filler_get_type CDECL() AS GType
DECLARE FUNCTION goo_filler_new CDECL(BYVAL Entries AS guint = 1) AS GooFiller PTR
DECLARE SUB goo_filler_unref CDECL(BYVAL Filler AS GooFiller PTR)
DECLARE FUNCTION goo_filler_ref CDECL(BYVAL Filler AS GooFiller PTR) AS GooFiller PTR
DECLARE FUNCTION goo_filler_set CDECL( _
  BYVAL Filler AS GooFiller PTR, _
  BYVAL Index AS guint, _
  BYVAL Prop AS gchar PTR, _
  BYVAL Value AS gpointer) AS gboolean

'~ analyse a line, calculate angle and length
TYPE _goo_line
  AS GooFloat x, y, dx, dy, l, w
  DECLARE SUB init(BYVAL Xn AS GooFloat, BYVAL Yn AS GooFloat, _
                   BYVAL Xa AS GooFloat, BYVAL Ya AS GooFloat)
END TYPE

/'*
GooPolar:

#GooPolar-struct struct is a container for polax and pie segments. It
contains private data only.

Since: 0.0
'/
TYPE GooPolar
  AS GooFloat Cx, Cy, Rr, Rv, Ws, Wr, Gap, Cent
  AS gboolean GapFlag
  DECLARE FUNCTION init(BYVAL Obj AS gpointer, _
                        BYVAL X AS GooFloat, BYVAL Y AS GooFloat, _
                        BYVAL W AS GooFloat, BYVAL H AS GooFloat, _
                        BYVAL A AS GooFloat, BYVAL E AS GooFloat, _
                        BYVAL C AS GooFloat = 0.0) AS gboolean
  DECLARE FUNCTION init_gaps(BYVAL G AS GooFloat, BYVAL N AS UINTEGER) AS gboolean
  DECLARE SUB line(BYVAL Pa AS GArray PTR, BYVAL P AS GooFloat)
  DECLARE SUB circle(BYVAL Pa AS GArray PTR, BYVAL P AS GooFloat)
  DECLARE SUB segment(BYVAL Path AS GArray PTR, _
                      BYVAL Ri AS GooFloat, BYVAL Rd AS GooFloat, _
                      BYVAL Wa AS GooFloat, BYVAL Wd AS GooFloat)
END TYPE




/'*
goo_palette_function:
 @Scale: the scale of the color in the integval [0,1]. Values outside
  this interval gets fitted to the next border.
@Alpha_: optional alpha value, if the color should be translucent (default
= 0xff).

A goo_palette_function() should return a color value to be used in
color gradients (ie for high maps).
The standard goo_pallete_function() returns colors ranging from red
over blue to green. The colors have low contrast to their neighbours.

Returns: a color value for a rgba property (ie #GooCanvasItemSimple:fill-color-rgba).

Since: 0.0
'/
'typedef guint (* goo_palette_function) (GooFloat Scale, char Alpha_);
TYPE goo_palette_function AS FUNCTION CDECL(BYVAL Scale AS GooFloat, BYVAL Alpha_ AS UBYTE = &hFF) AS guint
STATIC SHARED AS goo_palette_function goo_palette
DECLARE SUB goo_palette_set_function CDECL(BYVAL Func AS goo_palette_function)
goo_palette_set_function(NULL)

STATIC SHARED AS GooFillerValue _goo_fillers(15)
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

#MACRO _GOO_GET_VA(_N_,_T_)
  DIM AS CVA_LIST args
  CVA_START(args, _T_)
  VAR arg = CVA_ARG(args, gchar PTR)
  IF arg THEN g_object_set_valist(G_OBJECT(_N_), arg, args)
  CVA_END(args)
#ENDMACRO

#MACRO _GOO_END_NEW_FUNC(_N_,_T_,_M_) 'N=item name, T=terminating var, M=mode for add child
  DIM AS CVA_LIST args
  CVA_START(args, _T_)
  VAR arg = CVA_ARG(args, gchar PTR)
  IF arg THEN g_object_set_valist(G_OBJECT(_N_), arg, args)
  CVA_END(args)
  IF Parent THEN
    goo_canvas_##_M_##_add_child(Parent, _N_, -1)
    g_object_unref(_N_)
  END IF
#ENDMACRO

#MACRO _GOO_DEFINE_PROP(_L_,_C_,_U_,_P_,_M_) 'L=lower case, C=camelcase, U=uppercase, P=property, M=member
 SUB goo_##_L_##_get_##_P_##_properties CDECL ALIAS G_STRINGIFY(goo_##_L_##_get_##_P_##_properties) _
   (BYVAL _C_ AS Goo##_C_ PTR, ...) EXPORT
  _GOO_DEFINE_PROP_(get,_C_,_U_,_M_)
 SUB goo_##_L_##_set_##_P_##_properties CDECL ALIAS G_STRINGIFY(goo_##_L_##_set_##_P_##_properties) _
   (BYVAL _C_ AS Goo##_C_ PTR, ...) EXPORT
  _GOO_DEFINE_PROP_(set,_C_,_U_,_M_)
#ENDMACRO

'[
#MACRO _GOO_DEFINE_PROP_(_MODE_,_C_,_U_,_M_) 'C=camelcase, U=uppercase, M=member
 TRIN("")

   g_return_if_fail(GOO_IS_##_U_(_C_))

   DIM AS CVA_LIST args
   CVA_START(args, _C_)
   VAR arg = CVA_ARG(args, gchar PTR)
   IF arg THEN g_object_##_MODE_##_valist(G_OBJECT(_C_##->##_M_), arg, args)
   CVA_END(args)
 TROUT("")
 END SUB
#ENDMACRO
']

'{
#MACRO _GOO_EVAL_SEGMENT(_P_,_A_,_R_)
 VAR _A_ = 0.0, _R_ = 0.0
 IF _P_ ANDALSO _P_[0] <> 0 THEN
   VAR p = _P_
   _A_ = ABS(_goo_value(p)) * _DEG_RAD
   IF p THEN
     IF _A_ >= _2GOO_PI THEN _A_ = FRAC(_A_ / _2GOO_PI) * _2GOO_PI
     _R_ = ABS(_goo_value(p)) * _DEG_RAD
     IF p THEN IF _R_ >= _2GOO_PI THEN _R_ = FRAC(_R_ / _2GOO_PI) * _2GOO_PI
   END IF
 END IF
#ENDMACRO
'}

#MACRO GOO_ITEM_CONNECT(NAM)
 STATIC SHARED AS GooItemUpdateFunc _chainup_update_item_##NAM

 DECLARE SUB _goo_##NAM##_update CDECL( _
   BYVAL AS GooCanvasItem PTR, _
   BYVAL AS gboolean, _
   BYVAL AS cairo_t PTR, _
   BYVAL AS GooCanvasBounds PTR)

 SUB _goo_##NAM##_item_interface_init CDECL( _
   BYVAL Iface AS GooCanvasItemIface PTR) STATIC
   _chainup_update_item_##NAM = iface->update
   iface->update = @_goo_##NAM##_update
   'Iface->set_model = @_goo_##NAM##_set_model
 END SUB
#ENDMACRO

#MACRO GOO_ITEM_CONNECT2(NAM)
 STATIC SHARED AS GooItemUpdateFunc _chainup_update_item
 STATIC SHARED AS GooCanvasItemIface PTR _chainup_parent_iface

 DECLARE SUB canvas_item_interface_init CDECL(BYVAL AS GooCanvasItemIface PTR)

 DECLARE SUB goo_##NAM##_update CDECL( _
   BYVAL AS GooCanvasItem PTR, _
   BYVAL AS gboolean, _
   BYVAL AS cairo_t PTR, _
   BYVAL AS GooCanvasBounds PTR)

 SUB goo_##NAM##_item_interface_init CDECL( _
   BYVAL Iface AS GooCanvasItemIface PTR) STATIC
 TRIN("")
   _chainup_update_item = iface->update
   Iface->update = @goo_##NAM##_update
   'Iface->set_model = @_goo_##NAM##_set_model
 TROUT("")
 END SUB
#ENDMACRO
