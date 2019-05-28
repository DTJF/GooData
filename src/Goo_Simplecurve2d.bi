#INCLUDE ONCE "Goo_Glob.bi"
#INCLUDE ONCE "Goo_Axis.bi"

/'*
GooSimplecurve2d:

The #GooSimplecurve2d-struct struct contains private data only.

Since: 0.0
'/
TYPE GooSimplecurve2d
  AS GooCanvasPolyline parent_instance

  AS GooCanvasItem PTR Parent
  AS GooAxis PTR AxisX, AxisY
  AS GooDataPoints PTR Dat

  AS gint ChX, ChY
  AS GooType Bx, By, Bb, Bh
END TYPE

/'*
GooSimplecurve2dClass:

The #GooSimplecurve2dClass-struct struct contains private data only.

Since: 0.0
'/
TYPE GooSimplecurve2dClass
  AS GooCanvasPolylineClass parent_class
END TYPE

DECLARE FUNCTION goo_simplecurve2d_get_type CDECL() AS GType
#DEFINE GOO_TYPE_SIMPLECURVE2D (goo_simplecurve2d_get_type())
#DEFINE GOO_SIMPLECURVE2D(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), GOO_TYPE_SIMPLECURVE2D, GooSimplecurve2d))
#DEFINE GOO_IS_SIMPLECURVE2D(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), GOO_TYPE_SIMPLECURVE2D))
#DEFINE GOO_SIMPLECURVE2D_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), GOO_TYPE_SIMPLECURVE2D, GooSimplecurve2dClass))
#DEFINE GOO_IS_SIMPLECURVE2D_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), GOO_TYPE_SIMPLECURVE2D))
#DEFINE GOO_SIMPLECURVE2D_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), GOO_TYPE_SIMPLECURVE2D, GooSimplecurve2dClass))

DECLARE FUNCTION goo_simplecurve2d_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL AxisX AS GooAxis PTR, _
  BYVAL AxisY AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  BYVAL ChX AS guint, _
  BYVAL ChY AS guint, _
  ...) AS GooCanvasItem PTR
