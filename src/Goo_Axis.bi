/'*
GooAxisType:
     @GOO_AXIS_WEST: the axis is on the left of the background box
    @GOO_AXIS_SOUTH: the axis is below the background box
     @GOO_AXIS_EAST: the axis is on the right of the background box
    @GOO_AXIS_NORTH: the axis is above the background box
 @GOO_GRIDAXIS_WEST: the axis is on the left of the background box and
                     grid lines are drawn in the background box
@GOO_GRIDAXIS_SOUTH: the axis is below the background box and grid
                     lines are drawn in the background box
 @GOO_GRIDAXIS_EAST: the axis is on the right of the background box
                     and grid lines are drawn in the background box
@GOO_GRIDAXIS_NORTH: the axis is above the background box and grid
                     lines are drawn in the background box

Enum values used for goo_axis_new(), to specify the position and the
type of the axis.

Since: 0.0
'/
ENUM GooAxisType
  GOO_AXIS_WEST
  GOO_AXIS_SOUTH
  GOO_AXIS_EAST
  GOO_AXIS_NORTH
  GOO_GRIDAXIS_WEST
  GOO_GRIDAXIS_SOUTH
  GOO_GRIDAXIS_EAST
  GOO_GRIDAXIS_NORTH
END ENUM

/'*
GooAxis:

The #GooAxis-struct struct contains private data only.

Since: 0.0
'/
TYPE GooAxis
  AS GooCanvasGroup parent_instance

  DECLARE FUNCTION Pos(BYVAL V AS GooFloat) AS GooFloat
  DECLARE SUB Geo(BYREF S AS GooFloat, BYREF L AS GooFloat)
  AS GooAxisType Mo

  AS GooCanvasItem PTR Parent, Back
  AS GooCanvasItem PTR Textgr, Label, Ticktext
  AS GooCanvasItem PTR Bline, Grid, Tick, STick

  AS gchar PTR TLen, TVal, Text, Borders, Form '', Offset
  AS guint Tsub, TextAlign

  AS STRING TickLabels
  AS GooFloat Smin, Smax, Basis
  AS GooFloat Angle, TickOffs, TextOffs
  AS GooFloat Alen, TickHeight, Tin, Tout
  AS GooFloat Along, Across, X1, Y1, X2, Y2
  AS GooFloat Voffs, VScale, POffs
  AS GooFloat Bx, By, Bb, Bh
  AS GooFloat eps
  AS guint PoMo
END TYPE

/'*
GooAxisClass:

The #GooAxisClass-struct struct contains private data only.

Since: 0.0
'/
TYPE GooAxisClass
  AS GooCanvasGroupClass parent_class
END TYPE

DECLARE FUNCTION goo_axis_get_type CDECL() AS GType
#DEFINE GOO_TYPE_AXIS (goo_axis_get_type())
#DEFINE GOO_AXIS(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), GOO_TYPE_AXIS, GooAxis))
#DEFINE GOO_IS_AXIS(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), GOO_TYPE_AXIS))
#DEFINE GOO_AXIS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), GOO_TYPE_AXIS, GooAxisClass))
#DEFINE GOO_IS_AXIS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), GOO_TYPE_AXIS))
#DEFINE GOO_AXIS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), GOO_TYPE_AXIS, GooAxisClass))

DECLARE FUNCTION goo_axis_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Back AS GooCanvasItem PTR, _
  BYVAL Modus AS GooAxisType, _
  BYVAL Text AS gchar PTR, _
  ...) AS GooAxis PTR

DECLARE SUB goo_axis_get_text_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
DECLARE SUB goo_axis_set_text_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
DECLARE SUB goo_axis_get_grid_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
DECLARE SUB goo_axis_set_grid_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
DECLARE SUB goo_axis_get_ticks_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
DECLARE SUB goo_axis_set_ticks_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
DECLARE SUB goo_axis_get_subticks_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
DECLARE SUB goo_axis_set_subticks_properties CDECL(BYVAL Axis AS GooAxis PTR, ...)
