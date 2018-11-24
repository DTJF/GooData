CHDIR "/home/tom/Projekte/GooData/examples"

CONST az = 5, cols = 5
VAR line_group = 2.0, l = 4 * ATN(1)
VAR f = 2 * l / IIF(az, az, 1)
dim as GooType datas(az, cols)
var dat = @datas(0, 0)
FOR i AS INTEGER = 0 TO az
  VAR x = -l + i * f
  VAR y = SIN(x)
  *dat = x : dat += 1
  *dat = x * x * x / 32 : dat += 1
  *dat = y : dat += 1
  *dat = i : dat += 1
  *dat = y * y * y : dat += 1
  *dat = (i + 2) / az : dat += 1
  'datas(i, 0) = x
  'datas(i, 1) = x * x * x / 32
  'datas(i, 2) = y
  'datas(i, 3) = i
  'datas(i, 4) = y * y * y
  'datas(i, 5) = (i + 2) / az
NEXT

'?dat

FUNCTION example_pie( _
  BYVAL Glob AS GooCanvasItem PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  BYREF Tx AS STRING, _
  BYREF Ty AS STRING, _
  BYVAL W AS gdouble, _
  BYVAL H AS gdouble, _
  BYVAL line_group AS gdouble _
    ) AS GooCanvasItem PTR
'~ '~
#INCLUDE "ex_pie.bas"
'~ '~
RETURN root
END FUNCTION
'~
'~ FUNCTION example_bar( _
  '~ BYVAL Glob AS GooCanvasItem PTR, _
  '~ BYVAL Dat AS GooDataPoints PTR, _
  '~ BYREF Tx AS STRING, _
  '~ BYREF Ty AS STRING, _
  '~ BYVAL W AS gdouble, _
  '~ BYVAL H AS gdouble, _
  '~ BYVAL line_group AS gdouble _
    '~ ) AS GooCanvasItem PTR
'~
'~ #INCLUDE "ex_bar.bas"
'~
'~ RETURN root
'~ END FUNCTION

'~ FUNCTION example_line_markers( _
  '~ BYVAL Glob AS GooCanvasItem PTR, _
  '~ BYVAL Dat AS GooDataPoints PTR, _
  '~ BYREF Tx AS STRING, _
  '~ BYREF Ty AS STRING, _
  '~ BYVAL W AS gdouble, _
  '~ BYVAL H AS gdouble, _
  '~ BYVAL line_group AS gdouble _
    '~ ) AS GooCanvasItem PTR
'~
'~ #INCLUDE "ex_line_markers.bas"
'~
'~ RETURN root
'~ END FUNCTION

'FUNCTION example_curve_areas( _
  'BYVAL Glob AS GooCanvasItem PTR, _
  'BYVAL Dat AS GooDataPoints PTR, _
  'BYREF Tx AS STRING, _
  'BYREF Ty AS STRING, _
  'BYVAL W AS gdouble, _
  'BYVAL H AS gdouble, _
  'BYVAL line_group AS gdouble _
    ') AS GooCanvasItem PTR

'#INCLUDE "ex_curve_areas.bas"

'RETURN group
'END FUNCTION

'FUNCTION example_3d_perpens( _
  'BYVAL Glob AS GooCanvasItem PTR, _
  'BYVAL Dat AS GooDataPoints PTR, _
  'BYREF Tx AS STRING, _
  'BYREF Ty AS STRING, _
  'BYVAL W AS gdouble, _
  'BYVAL H AS gdouble, _
  'BYVAL line_group AS gdouble _
    ') AS GooCanvasItem PTR

'#INCLUDE "ex_3d_perpens.bas"

'RETURN root
'END FUNCTION

VAR Po = goo_data_points_new(az + 1, cols + 1, @datas(0, 0))
VAR Tx = "angle <i>φ</i>"
VAR Ty = "<span color=""green"">sin <i>φ</i></span> " _
         "<span color=""red"">sin³ <i>φ</i></span>"
VAR W = 422, H = 211 '200

'~ VAR e1 = example_line_markers(glob, Po, Tx, _
         '~ !"<span color=""green"">sin <i>φ</i></span>\n" _
          '~ "<span color=""red"">sin³ <i>φ</i></span>", W, H, line_group)
'~ goo_canvas_item_translate(e1, 40.0,  90.0)
'~
'~ VAR e2 = example_curve_areas(glob, Po, Tx, Ty, W, H, line_group)
'~ goo_canvas_item_translate(e2, 540.0, 90.0)
'~
'~ VAR e3 = example_3d_perpens(glob, Po, Tx, Ty, W, H, line_group)
'~ goo_canvas_item_translate(e3, 350.0, 335.0)

VAR e4 = example_pie(glob, Po, Tx, Ty, W, H, line_group)
goo_canvas_item_translate(e4, 150.0, 185.0)
'~
'~ VAR e5 = example_bar(glob, Po, Tx, Ty, W, H, line_group)
'~ goo_canvas_item_translate(e5, 50.0, 155.0)
