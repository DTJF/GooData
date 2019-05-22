#IF __FB_OUT_EXE__ OR __FB_OUT_OBJ__
#INCLIB "Goo_Data"
#ENDIF

'#INCLUDE ONCE "goocanvas.bi"
#INCLUDE ONCE "Gir/GooCanvas-2.0.bi"
#INCLUDE ONCE "Gir/_GLibMacros-2.0.bi"
#INCLUDE ONCE "Gir/_GObjectMacros-2.0.bi"

#DEFINE GOO_EPS (1e-7)
TYPE AS gdouble GooType

/'* GooDataMarkers:
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
/'* GooDataPoints:

#GooDataPoints represents an array of numerical values as the source
for all the graph types. It contains private data only. Use the
functions of the goo_data_points family to set the content.

The data array may contain more data (more columns)
than used in a graph, so one structs can be used for multiple graphs.

Since: 0.0
'/
TYPE _GooDataPoints
  AS guint Row, Col
  AS GooType PTR Dat
  AS gint RefCount, m_flag : 1
END TYPE
TYPE AS _GooDataPoints GooDataPoints

DECLARE FUNCTION goo_data_points_new CDECL( _
  BYVAL Rows AS guint, _
  BYVAL Columns AS guint, _
  BYVAL Array AS GooType PTR = 0) AS GooDataPoints PTR
DECLARE FUNCTION goo_data_points_ref CDECL( _
  BYVAL Points AS GooDataPoints PTR) AS GooDataPoints PTR
DECLARE SUB goo_data_points_unref CDECL(BYVAL Points AS GooDataPoints PTR)
DECLARE SUB goo_data_points_set_point CDECL( _
  BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, _
  BYVAL Column AS guint, _
  BYVAL Value AS GooType)
DECLARE FUNCTION goo_data_points_get_point CDECL( _
  BYVAL Points AS GooDataPoints PTR, _
  BYVAL Row AS guint, _
  BYVAL Column AS guint) AS GooType
DECLARE FUNCTION _goo_data_points_get_type CDECL() AS GType
#DEFINE GOO_TYPE_DATA_POINTS (_goo_data_points_get_type())
'~ #DEFINE GOO_DATA_POINTS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), GOO_TYPE_DATA_POINTS, GooDataPoints))
'~ #DEFINE GOO_IS_DATA_POINTS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GOO_TYPE_DATA_POINTS))


/'* GooFillerValue:

This struct represents a set of a #GooCanvasItemSimple filling methods.
It contains private data only. Use the functions of the goo_filler family
to set the content.

Since: 0.0
'/
TYPE _GooFillerValue
  AS gchar PTR Prop
  AS gpointer Value
END TYPE
TYPE AS _GooFillerValue GooFillerValue

/'* GooFiller:

This struct is used to set the #GooCanvasItemSimple filling methods
for graphs with multiple colored items like #GooBar2d or #GooPie2d.
It contains private data only. Use the functions below to set the
content.

Since: 0.0
'/
TYPE _GooFiller
  AS GooFillerValue PTR Values
  AS gint RefCount, Entries
  DECLARE PROPERTY Prop(BYVAL Index AS guint) AS gchar PTR
  DECLARE PROPERTY Value(BYVAL Index AS guint) AS gpointer
END TYPE
TYPE AS _GooFiller GooFiller

#DEFINE GOO_TYPE_FILLER (_goo_filler_get_type())
DECLARE FUNCTION _goo_filler_get_type CDECL() AS GType
DECLARE FUNCTION goo_filler_new CDECL(BYVAL Entries AS guint = 1) AS GooFiller PTR
DECLARE SUB goo_filler_unref CDECL(BYVAL Filler AS GooFiller PTR)
DECLARE FUNCTION goo_filler_ref CDECL(BYVAL Filler AS GooFiller PTR) AS GooFiller PTR
DECLARE FUNCTION goo_filler_set CDECL( _
  BYVAL Filler AS GooFiller PTR, _
  BYVAL Index AS guint, _
  BYVAL Prop AS gchar PTR, _
  BYVAL Value AS gpointer) AS gboolean




/'* goo_palette_function:
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
'typedef guint (* goo_palette_function) (gdouble Scale, char Alpha_);
TYPE goo_palette_function AS FUNCTION CDECL(BYVAL Scale AS gdouble, BYVAL Alpha_ AS UBYTE = &hFF) AS guint
STATIC SHARED AS goo_palette_function goo_palette
DECLARE SUB goo_palette_set_function CDECL(BYVAL Func AS goo_palette_function)
goo_palette_set_function(NULL)

#INCLUDE ONCE "Goo_Axis.bi"
#INCLUDE ONCE "Goo_Polax.bi"
#INCLUDE ONCE "Goo_Curve2d.bi"
#INCLUDE ONCE "Goo_Simplecurve2d.bi"
#INCLUDE ONCE "Goo_Pie2d.bi"
#INCLUDE ONCE "Goo_Bar2d.bi"
#INCLUDE ONCE "Goo_Box2d.bi"
