/'* GooPie2d:

The #GooPie2d-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooPie2d
  AS GooCanvasGroup parent_instance

  AS GooCanvasItem PTR Parent, PSegm, PLabl
  AS gchar PTR Chan, Form, Gaps, PSeg
  AS GooDataPoints PTR Dat
  AS GooFiller PTR GoFi
  '~ AS guint Alph

  AS GooType Bx, By, Bb, Bh
END TYPE

/'* GooPie2dClass:

The #GooPie2dClass-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooPie2dClass
  AS GooCanvasGroupClass parent_class
END TYPE

DECLARE FUNCTION _goo_pie2d_get_type CDECL() AS GType
#DEFINE GOO_TYPE_PIE2D (_goo_pie2d_get_type())
#DEFINE GOO_PIE2D(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), GOO_TYPE_PIE2D, GooPie2d))
#DEFINE GOO_IS_PIE2D(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), GOO_TYPE_PIE2D))
#DEFINE GOO_PIE2D_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), GOO_TYPE_PIE2D, GooPie2dClass))
#DEFINE GOO_IS_PIE2D_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), GOO_TYPE_PIE2D))
#DEFINE GOO_PIE2D_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), GOO_TYPE_PIE2D, GooPie2dClass))

TYPE GooPie2d AS _GooPie2d
TYPE GooPie2dClass AS _GooPie2dClass

DECLARE FUNCTION goo_pie2d_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  BYVAL X AS GooType, _
  BYVAL Y AS GooType, _
  BYVAL Width_ AS GooType, _
  BYVAL Height AS GooType, _
  ...) AS GooPie2d PTR
