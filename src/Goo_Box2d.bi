#INCLUDE ONCE "Goo_Glob.bi"

/'*
GooBox2d:

The #GooBox2d-struct struct contains private data only.

Since: 0.0
'/
TYPE GooBox2d
  AS GooCanvasGroup parent_instance

  AS GooCanvasItem PTR Parent, PBox, PWis, POut
  AS GooAxis PTR Axis
  AS GooDataPoints PTR Dat

  AS gchar PTR Chan, Boxs, Outl
  AS guint Vertical
  AS gdouble Bx, By, Bb, Bh
END TYPE

/'*
GooBox2dClass:

The #GooBox2dClass-struct struct contains private data only.

Since: 0.0
'/
TYPE GooBox2dClass
  AS GooCanvasGroupClass parent_class
END TYPE

DECLARE FUNCTION goo_box2d_get_type CDECL() AS GType
#DEFINE GOO_TYPE_BOX2D (goo_box2d_get_type())
#DEFINE GOO_BOX2D(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), GOO_TYPE_BOX2D, GooBox2d))
#DEFINE GOO_IS_BOX2D(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), GOO_TYPE_BOX2D))
#DEFINE GOO_BOX2D_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), GOO_TYPE_BOX2D, GooBox2dClass))
#DEFINE GOO_IS_BOX2D_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), GOO_TYPE_BOX2D))
#DEFINE GOO_BOX2D_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), GOO_TYPE_BOX2D, GooBox2dClass))

DECLARE SUB goo_box2d_get_whiskers_properties CDECL(BYVAL Box2d AS GooBox2d PTR, ...)
DECLARE SUB goo_box2d_set_whiskers_properties CDECL(BYVAL Box2d AS GooBox2d PTR, ...)
DECLARE SUB goo_box2d_get_outliers_properties CDECL(BYVAL Box2d AS GooBox2d PTR, ...)
DECLARE SUB goo_box2d_set_outliers_properties CDECL(BYVAL Box2d AS GooBox2d PTR, ...)

DECLARE FUNCTION goo_box2d_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Axis AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  ...) AS GooBox2d PTR
