/'* GooBar2d:

The #GooBar2d-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooBar2d
  AS GooCanvasGroup parent_instance

  AS GooCanvasItem PTR Parent, BSegm, BLabl
  AS GooAxis PTR Axis
  AS GooDataPoints PTR Dat
  AS GooFiller PTR GoFi
  AS gchar PTR Chan, Gaps

  AS guint Alph, Vertical
  AS gdouble Bx, By, Bb, Bh
END TYPE

/'* GooBar2dClass:

The #GooBar2dClass-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooBar2dClass
  AS GooCanvasGroupClass parent_class
END TYPE

DECLARE FUNCTION _goo_bar2d_get_type CDECL() AS GType
#DEFINE GOO_TYPE_BAR2D (_goo_bar2d_get_type())
#DEFINE GOO_BAR2D(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), GOO_TYPE_BAR2D, GooBar2d))
#DEFINE GOO_IS_BAR2D(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), GOO_TYPE_BAR2D))
#DEFINE GOO_BAR2D_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), GOO_TYPE_BAR2D, GooBar2dClass))
#DEFINE GOO_IS_BAR2D_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), GOO_TYPE_BAR2D))
#DEFINE GOO_BAR2D_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), GOO_TYPE_BAR2D, GooBar2dClass))

TYPE GooBar2d AS _GooBar2d
TYPE GooBar2dClass AS _GooBar2dClass

DECLARE FUNCTION goo_bar2d_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Axis AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  ...) AS GooBar2d PTR
