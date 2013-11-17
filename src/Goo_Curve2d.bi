/'* GooCurve2d:

The #GooCurve2d-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooCurve2d
  AS GooCanvasGroup parent_instance

  AS GooCanvasItem PTR Parent, MItem
  AS GooCanvasItem PTR CLine, CArea, CErrs, CPerp, CMark, CVect
  AS GooAxis PTR AxisX, AxisY
  AS GooDataPoints PTR Dat
  AS gchar PTR LTyp, ATyp, ADir, Chan, Pers, Erro, Vect, Mark

  AS gint ChX, ChY, MType
  AS gdouble Bx, By, Bb, Bh, MScal
END TYPE

/'* GooCurve2dClass:

The #GooCurve2dClass-struct struct contains private data only.

Since: 0.0
'/
TYPE _GooCurve2dClass
  AS GooCanvasGroupClass parent_class
END TYPE

DECLARE FUNCTION _goo_curve2d_get_type CDECL() AS GType
#DEFINE GOO_TYPE_CURVE2D (_goo_curve2d_get_type ())
#DEFINE GOO_CURVE2D(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), GOO_TYPE_CURVE2D, GooCurve2d))
#DEFINE GOO_IS_CURVE2D(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GOO_TYPE_CURVE2D))
#DEFINE GOO_CURVE2D_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), GOO_TYPE_CURVE2D, GooCurve2dClass))
#DEFINE GOO_IS_CURVE2D_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), GOO_TYPE_CURVE2D))
#DEFINE GOO_CURVE2D_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), GOO_TYPE_CURVE2D, GooCurve2dClass))

TYPE GooCurve2d AS _GooCurve2d
TYPE GooCurve2dClass AS _GooCurve2dClass

DECLARE SUB goo_curve2d_get_area_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_set_area_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_get_perpens_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_set_perpens_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_get_errors_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_set_errors_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_get_markers_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_set_markers_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_get_vectors_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)
DECLARE SUB goo_curve2d_set_vectors_properties CDECL(BYVAL Curve2d AS GooCurve2d PTR, ...)

DECLARE FUNCTION goo_curve2d_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL AxisX AS GooAxis PTR, _
  BYVAL AxisY AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  ...) AS GooCurve2d PTR
