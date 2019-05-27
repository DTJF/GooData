#DEFINE MODULE "GooData"

#LIBPATH "../src"
' list of source files
#INCLUDE ONCE "../src/Goo_Data.bas"
#INCLUDE ONCE "../src/Goo_Axis.bas"
#INCLUDE ONCE "../src/Goo_Bar2d.bas"
#INCLUDE ONCE "../src/Goo_Box2d.bas"
#INCLUDE ONCE "../src/Goo_Curve2d.bas"
#INCLUDE ONCE "../src/Goo_Pie2d.bas"
#INCLUDE ONCE "../src/Goo_Polax.bas"
#INCLUDE ONCE "../src/Goo_Simplecurve2d.bas"

'list of object types to scan
DIM SHARED AS GType object_types(7)
object_types(0) = _goo_data_points_get_type ()
object_types(1) = _goo_axis_get_type ()
object_types(2) = _goo_polax_get_type ()
object_types(3) = _goo_curve2d_get_type ()
object_types(4) = _goo_bar2d_get_type ()
object_types(5) = _goo_box2d_get_type ()
object_types(6) = _goo_pie2d_get_type ()
object_types(7) = 0

' the code to export object info
#INCLUDE ONCE "gtk-doc-scan.bas"
