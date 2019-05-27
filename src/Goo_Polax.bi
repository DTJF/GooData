#INCLUDE ONCE "Goo_Glob.bi"

/'* GooPolax:

The #GooPolax-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooPolax
  AS GooCanvasGroup parent_instance

  AS GooCanvasItem PTR Parent
  AS GooCanvasItem PTR Textgr, Label, Ticktext
  AS GooCanvasItem PTR Back, Grid, Tick, STick
  AS gchar PTR PSeg, PTxt

  AS GooType Bx, By, Bb, Bh
END TYPE

/'* GooPolaxClass:

The #GooPolaxClass-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooPolaxClass
  AS GooCanvasGroupClass parent_class
END TYPE

DECLARE FUNCTION _goo_polax_get_type CDECL() AS GType
#DEFINE GOO_TYPE_POLAX (_goo_polax_get_type())
#DEFINE GOO_POLAX(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), GOO_TYPE_POLAX, GooPolax))
#DEFINE GOO_IS_POLAX(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), GOO_TYPE_POLAX))
#DEFINE GOO_POLAX_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), GOO_TYPE_POLAX, GooPolaxClass))
#DEFINE GOO_IS_POLAX_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), GOO_TYPE_POLAX))
#DEFINE GOO_POLAX_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), GOO_TYPE_POLAX, GooPolaxClass))

TYPE GooPolax AS _GooPolax
TYPE GooPolaxClass AS _GooPolaxClass

DECLARE FUNCTION goo_polax_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL X AS GooType, _
  BYVAL Y AS GooType, _
  BYVAL Width_ AS GooType, _
  BYVAL Height AS GooType, _
  BYVAL Text AS gchar PTR, _
  ...) AS GooCanvasItem PTR
