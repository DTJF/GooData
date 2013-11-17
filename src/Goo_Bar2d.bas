'~ See main file for licence information: GooData.bas
/'* SECTION:Goo_Bar2d
@Title: GooBar2d
@Short_Description: bar chart (scaled by a #GooAxis).
@Image: img/example_bar_stacked.bas.png

#GooBar2d is a subclass of #GooCanvasGroup and so
inherits all of the style properties such as #GooCanvasGroup:stroke-color,
#GooCanvasGroup:fill-color and #GooCanvasGroup:line-width.
It also inherits the #GooCanvasItem interface, so you can
use the #GooCanvasItem functions such as goo_canvas_item_raise() or
goo_canvas_item_rotate().

To create a #GooBar2d use goo_bar2d_new().

All bar charts can be orientated in horizontal or vertical direction
depending on the axis used for scaling. A vertical axis (ie %GOO_AXIS_WEST
or %GOO_AXIS_EAST) causes bars in vertical direction.

The #GooBar2d group contains these childs:
- a #GooCanvasGroup for the bars (several #GooCanvasRect),
- a #GooCanvasGroup for the labels (several #GooCanvasText).

'/

#INCLUDE ONCE "Goo_Bar2d.bi"

STATIC SHARED _Bar2d__update AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)
DECLARE SUB _bar2d_update CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

SUB _bar2d_item_interface_init CDECL( _
  BYVAL iface AS GooCanvasItemIface PTR) STATIC
  _Bar2d__update = iface->update
  iface->update = @_bar2d_update
END SUB

G_DEFINE_TYPE_WITH_CODE(GooBar2d, _goo_bar2d, GOO_TYPE_CANVAS_GROUP, _
       G_IMPLEMENT_INTERFACE(GOO_TYPE_CANVAS_ITEM, _bar2d_item_interface_init))

SUB _bar2d_finalize CDECL( _
  BYVAL Obj AS GObject PTR)
TRIN("")

  WITH *GOO_BAR2D(Obj)
    IF .Chan THEN g_free(.Chan)
    IF .Gaps THEN g_free(.Gaps)
    g_object_unref(.Axis)
    goo_data_points_unref(.Dat)
  END WITH

  G_OBJECT_CLASS(_goo_bar2d_parent_class)->finalize(Obj)
TROUT("")
END SUB

ENUM
  GOO_BAR2D_PROP_0
  GOO_BAR2D_PROP_CHAN
  GOO_BAR2D_PROP_GAPS
  '~ GOO_BAR2D_PROP_ALPH
  GOO_BAR2D_PROP_FILL
END ENUM

SUB _bar2d_get_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  WITH *GOO_BAR2D(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_BAR2D_PROP_CHAN : g_value_set_string(Value, .Chan)
  CASE GOO_BAR2D_PROP_GAPS : g_value_set_string(Value, .Gaps)
  '~ CASE GOO_BAR2D_PROP_ALPH : g_value_set_uint(Value, .Alph)
  CASE GOO_BAR2D_PROP_FILL : g_value_set_pointer(Value, .GoFi)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

TROUT("")
END SUB

SUB _bar2d_set_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS CONST GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  VAR simple = CAST(GooCanvasItemSimple PTR, Obj)

  IF simple->model THEN _
      g_warning("Can't set property of a canvas item with a model - " _
                "set the model property instead") : EXIT SUB

  WITH *GOO_BAR2D(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_BAR2D_PROP_CHAN : g_free(.Chan) : .Chan = g_value_dup_string(Value)
  CASE GOO_BAR2D_PROP_GAPS : g_free(.Gaps) : .Gaps = g_value_dup_string(Value)
  '~ CASE GOO_BAR2D_PROP_ALPH : .Alph = g_value_get_uint(Value)
  CASE GOO_BAR2D_PROP_FILL : .GoFi = g_value_get_pointer(Value)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

  goo_canvas_item_simple_changed(simple, TRUE)

TROUT("")
END SUB

FUNCTION _bar2d_calc(BYVAL Bar2d AS GooBar2d PTR) AS INTEGER
TRIN("")

  WITH *Bar2d
    IF .Axis->Bx = .Bx ANDALSO _
       .Axis->By = .By ANDALSO _
       .Axis->Bb = .Bb ANDALSO _
       .Axis->Bh = .Bh THEN RETURN 0

    .Bx = .Axis->Bx
    .By = .Axis->By
    .Bb = .Axis->Bb
    .Bh = .Axis->Bh
    .Vertical = -(0 = BIT(.Axis->Mo, 0))

    '~ g_object_set(Bar, _
                 '~ "x", CAST(gdouble, .Bx - lw), _
                 '~ "y", CAST(gdouble, .By - lw), _
                 '~ "width", CAST(gdouble, .Bb + 2 * lw), _
                 '~ "height", CAST(gdouble, .Bh + 2 * lw), _
                 '~ NULL)

  END WITH : RETURN 1

TROUT("")
END FUNCTION

ENUM
  GOO_BAR2D_SIMPLE
  GOO_BAR2D_CHANNEL
  GOO_BAR2D_GANTT
  GOO_BAR2D_MIDDLE
  GOO_BAR2D_PERCENT
  GOO_BAR2D_STACK
  GOO_BAR2D_VALUE
END ENUM


/'* GooBar2d:alpha:

The alpha value of transparency for the bar graph, defaults to no
transparency (= 255). This is useful to make the grid lines shine
through the bars for better readability.

Since: 0.0
'/
'~ #DEFINE ADD_BAR2D VAR z = goo_canvas_rect_new(.BSegm, x, y, dx, dy, _
                          '~ "fill_color_rgba", goo_color(i, .Alph), NULL)
#DEFINE ADD_BAR2D VAR z = goo_canvas_rect_new(.BSegm, x, y, dx, dy, _
                          filler->Prop(i), filler->Value(i), NULL)

SUB _bar2d_draw(BYVAL Bar2d AS GooBar2d PTR)
TRIN("")

  WITH *Bar2d
    goo_canvas_item_remove(.BSegm)
    .BSegm = goo_canvas_group_new(GOO_CANVAS_ITEM(Bar2d), NULL)
    '~ goo_canvas_item_remove(.BLabl)
    '~ .BLabl = goo_canvas_group_new(GOO_CANVAS_ITEM(Bar2d), NULL)

/'* GooBar2d:gaps:

The gaps between the bars of the graph as percentage of the width.
The first value is the space between the bar groups (related to the
graph width) and the second value is the space between the
bars (related to the individual bar width).

By default the bars are set with 10 percent space between each group. So if
just one channel is choosen the bars will cover 90 percent of the available
space and between each bar a gap of 10 percent of the bar width is free.
If more than one channel is choosen, then by default the individual bars
of one row are set in a group side by side without space between them
and the 10 precent space is between the bar-groups of one row.

The range of the values is from 0 to 50 percent. Negative values are
scaled by -1 first, then values greater 50 are reduced to 50 percent.

This may contain
- no value to use default gaps. Example "" or %NULL (equal to "10  0").
- one value to set group gaps. Example: "25" for 25 percent space between
  the groups. ("0" for no spacing at all.)
- two values to set group gaps and individual gaps. Example: "0  20" for
  no group spacing but 20 percent space between each individual bar.

Note: the border line width needs some space if #GooCanvasItemSimple:stroke-pattern
is != %NULL.

Note: in case of stacked graphs (#GooBar2d:channels with start letter
'G', 'P' or 'S') the second value gets ignored.

Since: 0.0
'/
    VAR p = .Gaps, nchannels = 0, chno = "", mo = GOO_BAR2D_SIMPLE, offset = 0.0
    VAR gap1 = IIF(p, ABS(_goo_value(p)), 0.1)
    IF gap1 > 0.5 THEN gap1 = 0.5
    VAR gap2 = IIF(p, ABS(_goo_value(p)), 0.0)
    IF gap2 > 0.5 THEN gap2 = 0.5

/'* GooBar2d:channels:

The type of the bar graph and the channels (columns) in the @Dat array
for the values of the bars.
This may contain
- no value to use the default channel (= 0). Example "" or %NULL.
- one or more values to set channels for a standard graph with one bar
  for each column starting at zero in a group and one group per row.
  Example: "7  9".
- 'C' as the start letter and two or more values to draw a standard graph
  with bars starting at the value of the first channel (instead fo zero).
  Example: "c 4  1  7  9" to read the start value from channel 4; bars are
  drawn from channels 1, 7 and 9 goes to the value of channel 4.
- 'A' as the start letter and two or more values to let the bars of a
  standard graph start at the avarage of the values of the given channels
  in a row. Example: "a 1  2  3" to draw bars from the avarage of channel
  1, 2 and 3 to the values of channel 1, 2 and 3.
- 'G' as the start letter and two or more values to draw a Gantt chart.
  The given channel specifies the width of the bar, the start value gets
  red from the previous channel. Example: "g 1" draws a bar of the length
  of channel 1 with the start position from channel 0. Additional
  channels will be drawn in the same row. Bars with a length of zero
  will be skipped.
- 'P' as the start letter and two or more values to draw a chart of stacked
  bars, scaled to percentage values. Each bar stack goes from zero to
  100 and is separated into colored areas depending on the channel values.
  Only positive values are valid (and negative values are scaled by -1).
  Example: "P 4  5  6" to stack the percentage values of channels 4, 5 and 6.
- 'S' as the start letter and two or more values to draw a chart of stacked
  bars. Only positive values are valid (and negative values are scaled by -1).
  The bar starts at zero and each channel value creates a bar on top of
  the previous. Example: "S 4  7  2" to stack the values from channel 4,
  7 and 2 (latest on top).
- 'V' as the start letter to set an offset value and two or more channel numbers
  to draw a standard graph ...

When a channel number is greater than the number of columns in @Dat
no bar graph will be drawn.

Since: 0.0
'/
    p = .Chan
    IF 0 = p ORELSE 0 = p[0] THEN
      chno = MKI(0)
    ELSE
      SELECT CASE AS CONST p[0]
      CASE ASC("A"), ASC("a") : mo = GOO_BAR2D_MIDDLE
      CASE ASC("C"), ASC("c") : mo = GOO_BAR2D_CHANNEL
      CASE ASC("G"), ASC("g") : mo = GOO_BAR2D_GANTT   : gap2 = 0.0
      CASE ASC("P"), ASC("p") : mo = GOO_BAR2D_PERCENT : gap2 = 0.0
      CASE ASC("S"), ASC("s") : mo = GOO_BAR2D_STACK   : gap2 = 0.0
      CASE ASC("V"), ASC("v") : mo = GOO_BAR2D_VALUE : offset = _goo_value(p)
      END SELECT
      WHILE p
        VAR channel = CUINT(_goo_value(p)) : IF 0 = p THEN EXIT WHILE
        g_return_if_fail(channel < .Dat->Col)
        IF mo = GOO_BAR2D_GANTT THEN g_return_if_fail(channel > 0)
        chno &= MKI(channel)
        nchannels += 1
      WEND : g_return_if_fail(nchannels > 0)
      nchannels -= 1
    END IF

    VAR filler = IIF(.GoFi, .GoFi, @_goo_filler_default)

    VAR l = IIF(.Vertical, .Bb, .Bh)
    VAR o = l / .Dat->Row
    gap1 *= o
    VAR b = (o - gap1) / IIF(mo < GOO_BAR2D_PERCENT, nchannels + 1, 1)
    gap2 *= b
    VAR c = CAST(guint PTR, SADD(chno))
    VAR s = .Dat->Col, e = .Dat->Dat + .Dat->Row * s - 1
    IF .Vertical THEN
      VAR x = .Bx + 0.5 * (gap1 + gap2)
      VAR dx = b - gap2
      VAR y0 = .Axis->Pos(0)
      '~ VAR y = IIF(y0 < .By, .By, IIF(y0 > .By + .Bh, .By + .Bh, y0))
      VAR y = CLAMP(y0, .By, .By + .Bh)
      FOR p AS GooType PTR = .Dat->Dat TO e STEP s
        SELECT CASE AS CONST mo
        CASE GOO_BAR2D_SIMPLE
          FOR i AS INTEGER = 0 TO nchannels
            VAR dy = .Axis->Pos(p[c[i]]) - y0
            ADD_BAR2D
            x += b
          NEXT : x += gap1
        CASE GOO_BAR2D_CHANNEL
          y0 = .Axis->Pos(p[c[0]]) - y0
          FOR i AS INTEGER = 1 TO nchannels
            VAR dy = .Axis->Pos(p[c[i]]) - y0
            ADD_BAR2D
            x += b
          NEXT : x += gap1
        CASE GOO_BAR2D_VALUE
          y0 = .Axis->Pos(offset) - y0
          FOR i AS INTEGER = 0 TO nchannels
            VAR dy = .Axis->Pos(p[c[i]]) - y0
            ADD_BAR2D
            x += b
          NEXT : x += gap1
        CASE GOO_BAR2D_MIDDLE
          y0 = 0.0
          FOR i AS INTEGER = 0 TO nchannels
            y0 += p[c[i]]
          NEXT : y0 = .Axis->Pos(y0 / (nchannels + 1))
          '~ y = IIF(y0 < .By, .By, IIF(y0 > .By + .Bh, .By + .Bh, y0))
          y = CLAMP(y0, .By, .By + .Bh)
          FOR i AS INTEGER = 0 TO nchannels
            VAR dy = .Axis->Pos(p[c[i]]) - y0
            ADD_BAR2D
            x += b
          NEXT : x += gap1
        CASE GOO_BAR2D_PERCENT
          y = 0.0
          FOR i AS INTEGER = 0 TO nchannels
            y += ABS(p[c[i]])
          NEXT
          VAR f = IIF(y, 100.0 / y, 0.0)
          y = y0
          FOR i AS INTEGER = 0 TO nchannels
            VAR dy = .Axis->Pos(ABS(p[c[i]] * f)) - y0
            ADD_BAR2D
            y += dy
          NEXT : x += o
        CASE GOO_BAR2D_STACK
          y = y0
          FOR i AS INTEGER = 0 TO nchannels
            VAR dy = .Axis->Pos(ABS(p[c[i]])) - y0
            ADD_BAR2D
            y += dy
          NEXT : x += o
        CASE GOO_BAR2D_GANTT
          FOR i AS INTEGER = 0 TO nchannels
            y = .Axis->Pos(p[c[i] - 1])
            VAR dy = .Axis->Pos(p[c[i]]) - y
            IF dy THEN ADD_BAR2D
          NEXT : x += o
        END SELECT
      NEXT
    ELSE '~ horizontal
      VAR dy = b - gap2
      VAR y = .By + .Bh - 0.5 * (gap1 + gap2) - dy
      VAR x0 = .Axis->Pos(0)
      VAR x = CLAMP(x0, .Bx, .Bx + .Bb)
      FOR p AS GooType PTR = .Dat->Dat TO e STEP s
        SELECT CASE AS CONST mo
        CASE GOO_BAR2D_SIMPLE
          FOR i AS INTEGER = 0 TO nchannels
            VAR dx = .Axis->Pos(p[c[i]]) - x0
            ADD_BAR2D
            y -= b
          NEXT : y -= gap1
        CASE GOO_BAR2D_CHANNEL
          x0 = .Axis->Pos(p[c[0]]) - x0
          FOR i AS INTEGER = 1 TO nchannels
            VAR dx = .Axis->Pos(p[c[i]]) - x0
            ADD_BAR2D
            y -= b
          NEXT : y -= gap1
        CASE GOO_BAR2D_VALUE
          x0 = .Axis->Pos(offset) - x0
          FOR i AS INTEGER = 1 TO nchannels
            VAR dx = .Axis->Pos(p[c[i]]) - x0
            ADD_BAR2D
            y -= b
          NEXT : y -= gap1
        CASE GOO_BAR2D_MIDDLE
          x0 = 0.0
          FOR i AS INTEGER = 0 TO nchannels
            x0 += p[c[i]]
          NEXT : x0 = .Axis->Pos(x0 / (nchannels + 1))
          '~ x = IIF(x0 < .Bx, .Bx, IIF(x0 > .Bx + .Bb, .Bx + .Bb, x0))
          x = CLAMP(x0, .Bx, .Bx + .Bb)
          FOR i AS INTEGER = 0 TO nchannels
            VAR dx = .Axis->Pos(p[c[i]]) - x0
            ADD_BAR2D
            y -= b
          NEXT : y -= gap1
        CASE GOO_BAR2D_PERCENT
          x = 0.0
          FOR i AS INTEGER = 0 TO nchannels
            x += ABS(p[c[i]])
          NEXT
          VAR f = IIF(x, 100.0 / x, 0.0)
          x = x0
          FOR i AS INTEGER = 0 TO nchannels
            VAR dx = .Axis->Pos(ABS(p[c[i]] * f)) - x0
            ADD_BAR2D
            x += dx
          NEXT : y -= o
        CASE GOO_BAR2D_STACK
          x = x0
          FOR i AS INTEGER = 0 TO nchannels
            VAR dx = .Axis->Pos(ABS(p[c[i]])) - x0
            ADD_BAR2D
            x += dx
          NEXT : y -= o
        CASE GOO_BAR2D_GANTT
          FOR i AS INTEGER = 0 TO nchannels
            x = .Axis->Pos(p[c[i] - 1])
            VAR dx = .Axis->Pos(p[c[i]]) - x
            IF dx THEN ADD_BAR2D
          NEXT : y -= o
        END SELECT
      NEXT
    END IF
  END WITH

TROUT("")
END SUB

SUB _bar2d_update CDECL( _
  BYVAL item AS GooCanvasItem PTR, _
  BYVAL entire_tree AS gboolean, _
  BYVAL cr AS cairo_t PTR, _
  BYVAL bounds AS GooCanvasBounds PTR)
TRIN("")

  VAR bar2d = GOO_BAR2D(item)
  VAR simple = GOO_CANVAS_ITEM_SIMPLE(item)

  WITH *bar2d
    IF _bar2d_calc(bar2d) ORELSE entire_tree ORELSE simple->need_update THEN _bar2d_draw(bar2d)
    _Bar2d__update(item, entire_tree, cr, bounds)
  END WITH

TROUT("")
END SUB

SUB _goo_bar2d_class_init CDECL( _
  BYVAL bar2d_class AS GooBar2dClass PTR)
TRIN("")

  VAR klass = G_OBJECT_CLASS(bar2d_class)
  WITH *klass
  .finalize     = @_bar2d_finalize
  .get_property = @_bar2d_get_property
  .set_property = @_bar2d_set_property
  END WITH

  g_object_class_install_property(klass, GOO_BAR2D_PROP_CHAN, _
     g_param_spec_string_("channels", _
           __("ColumnsInDat"), _
           __("The columns in Dat to draw the bars from."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_BAR2D_PROP_GAPS, _
     g_param_spec_string_("gaps", _
           __("GapsBetweenBars"), _
           __("The gaps between the bars (1. bargroups, 2. single bars)."), _
           NULL, _
           G_PARAM_READWRITE))

  '~ g_object_class_install_property(klass, GOO_BAR2D_PROP_ALPH, _
     '~ g_param_spec_uint_("alpha", _
           '~ __("TransparencyAlpha"), _
           '~ __("The alpa value for transparency of the bars."), _
           '~ 0, 255, 255, _
           '~ G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_BAR2D_PROP_FILL, _
     g_param_spec_pointer_("filler", _
           __("FillerObject"), _
           __("The filler object to set color/pattern/pixbuf for bars."), _
           G_PARAM_READWRITE))

TROUT("")
END SUB

'~The standard object initialization function.
SUB _goo_bar2d_init CDECL( _
  BYVAL Bar2d AS GooBar2d PTR)
TRIN("")

  WITH *Bar2d
    .Chan = NULL
    .Gaps = NULL
    .GoFi = NULL
    .Alph = 255
  END WITH

TROUT("")
END SUB

/'* goo_bar2d_new:
@Parent: the parent item, or %NULL. If a parent is specified, it will assume
 ownership of the item, and the item will automatically be freed when it is
 removed from the parent. Otherwise call g_object_unref() to free it.
  @Axis: the axis to scale the values
   @Dat: the data values to draw
   @...: optional pairs of property names and values, and a terminating %NULL.

Create a new bar chart item from values in @Dat. By default channel 0
(zero) is used. Specify an alternative set of channels by #GooBar2d:channels.
Each row gets a set of bars in a different color generated by goo_color_function().


Since: 0.0
Returns: (transfer full): a new bar item.
'/
 '~ '*
 '~ * <!--PARAMETERS-->
 '~ *
 '~ * !!!Here's an example showing how to create a bar chart :
 '~ *
 '~ * <informalexample><programlisting>
 '~ *  GooPie *pie = goo_bar_new (mygroup, myData, 40.0, 50.0, 300, 200,
 '~ *                                  "channel", 2,
 '~ *                                  "gap", 5.0,
 '~ *                                  "start-angle", 45.0,
 '~ *                                   NULL);
 '~ * </programlisting></informalexample>
FUNCTION goo_bar2d_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Axis AS GooAxis PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  ...) AS GooBar2d PTR
TRIN("")

  '~ g_return_val_if_fail(GOO_IS_DATA_POINTS(Dat), NULL)
  g_return_val_if_fail(Dat > 0, NULL)
  g_return_val_if_fail(GOO_IS_AXIS(Axis), NULL)

  VAR bar2d = g_object_new(GOO_TYPE_BAR2D, NULL)

  WITH *GOO_BAR2D(bar2d)
    .Parent = Parent
    .Axis = Axis : g_object_ref(.Axis)
    .Dat = Dat : goo_data_points_ref(.Dat)

    '.BSegm = goo_canvas_group_new(bar2d, _
               '"fill-rule", CAIRO_FILL_RULE_EVEN_ODD, _
               'NULL)
    .BSegm = goo_canvas_group_new(bar2d, NULL)
    .BLabl = goo_canvas_group_new(bar2d, NULL)
  END WITH

  VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
  IF arg THEN g_object_set_valist(bar2d, arg, VA_NEXT(va, ANY PTR))

  IF Parent THEN
    goo_canvas_item_add_child(Parent, bar2d, -1)
    g_object_unref(bar2d)
  END IF

TROUT("")
  RETURN bar2d

END FUNCTION
