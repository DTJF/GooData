'~ See main file for licence information: GooData.bas
/'*
SECTION:Goo_Pie2d
@Title: GooPie2d
@Short_Description: pie charts.
@Image: img/example_pie_segments.bas.png

#GooPie2d is a subclass of #GooCanvasGroup and so
inherits all of the style properties such as #GooCanvasGroup:stroke-color,
#GooCanvasGroup:fill-color and #GooCanvasGroup:line-width.
It also inherits the #GooCanvasItem interface, so you can
use the #GooCanvasItem functions such as goo_canvas_item_raise() or
goo_canvas_item_rotate().

To create a #GooPie2d use goo_pie2d_new().

Setting a style property on a #GooPie2d will affect
all children in the #GooPie2d group (unless the children override the
property setting).

The #GooPie2d group contains these childs:
- a #GooCanvasGroup for the pie segments (several #GooCanvasPath),
- a #GooCanvasGroup for the labels (several #GooCanvasText).

'/
'~ !!!
'~ '* To set or get individual properties for the childs use the functions
'~ '* goo_pie2D_[get|set]_XYZ_properties with XYZ
'~ '* for area, perpens, markers, errors and vectors. The remaining item (pie line)
'~ '* is contolled directly by the #GooPie2d properties.

#INCLUDE ONCE "Goo_Pie2d.bi"

STATIC SHARED _Pie2d__update AS SUB CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)
DECLARE SUB _pie2d_update CDECL( _
  BYVAL AS GooCanvasItem PTR, _
  BYVAL AS gboolean, _
  BYVAL AS cairo_t PTR, _
  BYVAL AS GooCanvasBounds PTR)

SUB _pie2d_item_interface_init CDECL( _
  BYVAL iface AS GooCanvasItemIface PTR) STATIC
  _Pie2d__update = iface->update
  iface->update = @_pie2d_update
END SUB

G_DEFINE_TYPE_WITH_CODE(GooPie2d, _goo_pie2d, GOO_TYPE_CANVAS_GROUP, _
       G_IMPLEMENT_INTERFACE(GOO_TYPE_CANVAS_ITEM, _pie2d_item_interface_init))

SUB _pie2d_finalize CDECL( _
  BYVAL Obj AS GObject PTR)
TRIN("")

  WITH *GOO_PIE2D(Obj)
    IF .Chan THEN g_free(.Chan)
    IF .Gaps THEN g_free(.Gaps)
    IF .PSeg THEN g_free(.PSeg)
    IF .Form THEN g_free(.Form)
    goo_data_points_unref(.Dat)
  END WITH

  G_OBJECT_CLASS(_goo_pie2d_parent_class)->finalize(Obj)
TROUT("")
END SUB

'~ properties for pie charts
ENUM
  GOO_PIE2D_PROP_0
  GOO_PIE2D_PROP_CHAN
  '~ GOO_PIE2D_PROP_ALPH
  GOO_PIE2D_PROP_FILL
  GOO_PIE2D_PROP_FORM
  GOO_PIE2D_PROP_GAPS
  GOO_PIE2D_PROP_SEGM
END ENUM

'~ types of pie charts
ENUM
  GOO_PIE2D_SIMPLE
  GOO_PIE2D_BAR
  GOO_PIE2D_CHANNEL
  GOO_PIE2D_VALUE
  GOO_PIE2D_MIDDLE
  GOO_PIE2D_PERCENT
  GOO_PIE2D_STACK
  GOO_PIE2D_GANTT
END ENUM


SUB _pie2d_get_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  WITH *GOO_PIE2D(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_PIE2D_PROP_CHAN : g_value_set_string(Value, .Chan)
  CASE GOO_PIE2D_PROP_FORM : g_value_set_string(Value, .Form)
  CASE GOO_PIE2D_PROP_GAPS : g_value_set_string(Value, .Gaps)
  CASE GOO_PIE2D_PROP_SEGM : g_value_set_string(Value, .PSeg)
  '~ CASE GOO_PIE2D_PROP_ALPH : g_value_set_uint(Value, .Alph)
  CASE GOO_PIE2D_PROP_FILL : g_value_set_pointer(Value, .GoFi)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

TROUT("")
END SUB

SUB _pie2d_set_property CDECL( _
  BYVAL Obj AS GObject PTR, _
  BYVAL Prop_id AS guint, _
  BYVAL Value AS CONST GValue PTR, _
  BYVAL Pspec AS GParamSpec PTR)
TRIN(Prop_id)

  VAR simple = CAST(GooCanvasItemSimple PTR, Obj)

  IF simple->model THEN _
      g_warning("Can't set property of a canvas item with a model - " _
                "set the model property instead") : EXIT SUB

  WITH *GOO_PIE2D(Obj)
  SELECT CASE AS CONST Prop_id
  CASE GOO_PIE2D_PROP_CHAN : g_free(.Chan) : .Chan = g_value_dup_string(Value)
  CASE GOO_PIE2D_PROP_FORM : g_free(.Form) : .Form = g_value_dup_string(Value)
  CASE GOO_PIE2D_PROP_GAPS : g_free(.Gaps) : .Gaps = g_value_dup_string(Value)
  CASE GOO_PIE2D_PROP_SEGM : g_free(.PSeg) : .PSeg = g_value_dup_string(Value)
  '~ CASE GOO_PIE2D_PROP_ALPH : .Alph = g_value_get_uint(Value)
  CASE GOO_PIE2D_PROP_FILL : .GoFi = g_value_get_pointer(Value)
  CASE ELSE : G_OBJECT_WARN_INVALID_PROPERTY_ID(Obj, Prop_id, Pspec)
  END SELECT
  END WITH

  goo_canvas_item_simple_changed(simple, TRUE)

TROUT("")
END SUB

/'* GooPie2d:alpha:

The alpha value of transparency for the pie graph, defaults to no
transparency (= 255). This is useful to make the background shine
through the pie segment fillings, ie grid lines better readability.

Since: 0.0
'/
 SUB _pie2d_draw(BYVAL Pie2d AS GooPie2d PTR)
TRIN("")

  WITH *Pie2d
    goo_canvas_item_remove(.PSegm)
    .PSegm = goo_canvas_group_new(GOO_CANVAS_ITEM(Pie2d), _
               "line-join", CAIRO_LINE_JOIN_ROUND, _
               "fill_rule", CAIRO_FILL_RULE_EVEN_ODD, _
               NULL)
    '~ goo_canvas_item_remove(.PLabl)
    '~ .PLabl = goo_canvas_group_new(GOO_CANVAS_ITEM(Pie2d), _
               '~ NULL)

'~ /'*
 '~ '* GooPie2d:range:
 '~ '*
 '~ '* By default the pie graph starts at an angle of 0 degrees (3 o'clock)
 '~ '* and uses a full circle. The first value rotates the graph so that the
 '~ '* first segment doesn't start at the 0 degree angle. The second value
 '~ '* is the angle to be used for the grap. Both values should be in the
 '~ '* interval [0, 359.9999]. (Negative values will be scaled by -1, greater
 '~ '* values will get broken to a congruent value like 370 gets 10.)
 '~ '*
 '~ '* Since: 0.0
 '~ '/
/'* GooPie2d:segmented:

The area of the pie chart. The string can contain one or two values.
By default the pie segments are started at the mathematical zero angle
(3 o'clock) and are drawn over an angle of 360 degrees. An offset can
be specified to rotate the pie segment start. The second value limits
the range of the pie graph. Bith values are scaled in degrees.
This may contain
- no values for default (= "0  360"). Example NULL or "".
- one value for the start angle. Example "45" to start the graph at
  45 degrees (and use a full circle).
- two values to set a start angle and the angular range. Example:
  "0  180" to set the start angle to 0 degrees and to use only the
  upper half of the cirle (180 degrees).

If the second value is less than 360 both radius of the pie chart
grow to fill the given area. The center of the pie chart may be
drawn outside the center of the specified graph area.

Since: 0.0
'/
    _GOO_EVAL_SEGMENT(.PSeg, angle, range)

/'* GooPie2d:channels:

The channels in @Dat to read the data from. By default the first channel
(0 = zero) is used.
This may contain
- no value to draw a standard pie chart by the values of the default
  channel (= 0). Example "" or %NULL.
- one or more channel numbers for a standard pie chart.
  If more than one channel is set each column gets a
  ring of pie segments starting at the center. Only positive
  values are valid in @Dat (negative values gets scaled by -1).
  Example: "7  9" to draw a pie chart of channel 7 in the center and
  a pie ring of channel 9 around it.
- 'A' as the start letter and two or more channel numbers to draw an avarage
  bar-type pie graph. Each row in @Dat gets a group of bar-segments.
  Positive and negative values are valid in @Dat. Scaling is done by
  the maximum differenz (smallest and largest value) and the bars of
  a group start at the avarage value of the group.
  Example: "a 1  2  3" to draw bar segments from channels 1, 2 and 3
  from the avarage values of this channels.
- 'B' as the start letter and two or more channel numbers to draw a
  bar-type pie graph. Each value in @Dat gets a bar-segment.
  Positive and negative values are valid in @Dat. Scaling is done by
  the maximum differenz (smallest and largest value). All bars start
  at the center (mind the second value in #GooData:gaps).
  Example: "b 1  2  3" to draw bar segments from channels 1, 2 and 3
  from the center.
- 'C' as the start letter and two or more channel numbers to draw a
  bar-type pie graph with bar segments starting at the value of the
  first channel. Each row in @Dat gets a group of bar-segment.
  Positive and negative values are valid in @Dat. Scaling is done by
  the maximum differenz (smallest and largest value).
  Example: "c 1  2  3" to draw bar segments from channels 2 and 3
  starting at the value of channel 1.
- 'G' as the start letter and one or more channel numbers to draw a Gantt
  type pie chart. The specified channels set the width of the pie segments.
  Their start angles are set by the previous channel values. Example:
  "g 1" draws pie segments of the width by channel 1 and the start angle
  by channel 0. The segments of additional channels will be drawn in a
  separate ring. Segments with a width of zero gets skipped. Both, the
  start angle and the width values should be in the range of [0, 0.9999999]
  where 0 is equal to 0 degrees and 1 is equal to 360 degrees (, negative
  values gets scaled by -1; values greater than 1 are reduced to their
  fractional part).
  In a Gantt type pie chart gaps are only between the rings but not
  between the segments in circular direction.
- 'P' as the start letter and two or more values to draw a chart of stacked
  pie segments. Each row in @Dat gets a stack, scaled to 100 percent.
  Each stack has the same height (radius). The height of each segment
  is equal to the percentage rate based on the sum of the row. The
  segments of a channel are in same color.
  Only positive values are valid (negative values are scaled by -1).
  Example: "P 4  5  6" to stack the percentage values of channels 4, 5 and 6.
- 'S' as the start letter and two or more values to draw a chart of stacked
  bar-segments. Only positive values are valid (and negative values are
  scaled by -1).
  The segments start at the center. Each value creates a segment on top of
  the previous. Example: "S 4  7  2" to stack the values from channel 4,
  7 and 2 (latest at the outside).
- 'V' as the start letter, a real number and one or more channel numbers
  to draw a bar-type pie graph with bar segments starting at the
  specified value. Each value in @Dat gets a bar-segment.
  Positive and negative values are valid in @Dat. Scaling is done by
  the maximum differenz (smallest and largest value).
  Example: "v 1.7 1  2  3" to draw bar segments from channels 1, 2 and 3
  starting at the value 1.7.

When a channel number is greater than the number of columns in @Dat
(or negative) no pie graph will be drawn.

Since: 0.0
'/
    VAR chno = "", nchannels = -1, mo = GOO_PIE2D_SIMPLE , ch = -1, offset = 0.0
    VAR p = .Chan
    IF 0 = p ORELSE 0 = p[0] THEN
      chno = MKI(0) : nchannels = 0
    ELSE
      SELECT CASE AS CONST p[0]
      CASE ASC("A"), ASC("a") : mo = GOO_PIE2D_MIDDLE
      CASE ASC("B"), ASC("b") : mo = GOO_PIE2D_BAR
      CASE ASC("C"), ASC("c") : mo = GOO_PIE2D_CHANNEL
        ch = CUINT(_goo_value(p)) : g_return_if_fail(ch < .Dat->Col)
      CASE ASC("G"), ASC("g") : mo = GOO_PIE2D_GANTT
      CASE ASC("P"), ASC("p") : mo = GOO_PIE2D_PERCENT
      CASE ASC("S"), ASC("s") : mo = GOO_PIE2D_STACK
      CASE ASC("V"), ASC("v") : mo = GOO_PIE2D_VALUE : offset = _goo_value(p)
      END SELECT
      WHILE p
        VAR channel = CUINT(_goo_value(p)) : IF 0 = p THEN EXIT WHILE
        g_return_if_fail(channel < .Dat->Col)
        IF mo = GOO_PIE2D_GANTT THEN g_return_if_fail(channel > 0)
        chno &= MKI(channel)
        nchannels += 1
      WEND
    END IF
    g_return_if_fail(nchannels >= 0)

/'* GooPie2d:gaps:

The gaps between pie segments and optional free space in the center.
By default the pie segments are placed side by side. A gap can be set
to be drawn between the pie segments.
This may contain
- no value to draw the pie segments side by side. Example "" or %NULL.
- one value to set a gap factor. The size of the gaps is specified
  as a factor of the circumference of the pie graph
  (see #GooPie2d:segmented). If the pie graph has an
  area from 0 to 360 degrees, a factor of 0.01 will use 1 percent
  (= 3.6 degrees) for each gap.
  Segments smaller than the gaps gets unvisible.
  Example: "0.005"
- two values to set the gap size and the free area in the center...
  0 < center < 1.0

Since: 0.0
'/
    p = .Gaps
    VAR gap = 0.0, cent = 0.0
    IF p ANDALSO p[0] <> 0 THEN
      gap = _goo_value(p)
      gap = CLAMP(gap, 0.0, 0.08)
      cent = IIF(p, ABS(_goo_value(p)), 0.0)
      cent = CLAMP(cent, 0.0, 1.0)
    END IF

    VAR filler = IIF(.GoFi, .GoFi, @_goo_filler_default)

    DIM AS _GooPolar pie
    IF pie.init(Pie2d, .Bx, .By, .Bb, .Bh, angle, range, cent) THEN EXIT SUB

    VAR az = IIF(mo = GOO_PIE2D_SIMPLE, .Dat->Row, nchannels)
    DIM AS GArray PTR path(az)
    FOR i AS INTEGER = 0 TO az '~       create paths, one for each color
      VAR x = goo_canvas_path_new(.PSegm, NULL, _
                    filler->Prop(i), filler->Value(i), NULL)
      path(i) = GOO_CANVAS_PATH(x)->path_data->path_commands
    NEXT

    VAR c = CAST(guint PTR, SADD(chno))
    VAR s = .Dat->Col, e = .Dat->Dat + .Dat->Row * s - 1
    SELECT CASE AS CONST mo
    CASE GOO_PIE2D_BAR, GOO_PIE2D_MIDDLE, GOO_PIE2D_CHANNEL, GOO_PIE2D_VALUE
      IF gap THEN IF pie.init_gaps(gap, 1) THEN EXIT SUB
      VAR xn = 0.0
      SELECT CASE AS CONST mo
      CASE GOO_PIE2D_VALUE   : xn = offset
      CASE GOO_PIE2D_CHANNEL : xn = p[ch]
      END SELECT
      VAR xm = xn, p = .Dat->Dat
      FOR p = p TO e STEP s
        FOR i AS INTEGER = 0 TO nchannels '~              search extrema
          VAR v = p[c[i]]
          IF v < xn THEN xn = v
          IF v > xm THEN xm = v
        NEXT
        IF mo = GOO_PIE2D_CHANNEL THEN
          IF p[ch] < xn THEN xn = p[ch]
          IF p[ch] > xm THEN xm = p[ch]
        END IF
      NEXT

      IF xm <> xn THEN
        xm = 1.0 / (xm - xn)
        xn *= xm
        VAR w = 0.0, dw = 1 / (nchannels + 1) / .Dat->Row
        VAR r = 0.0, dr = 0.0, r0 = IIF(mo = GOO_PIE2D_VALUE, offset * xm, 0.0) - xn
        FOR p = .Dat->Dat TO e STEP s
          SELECT CASE AS CONST mo
          CASE GOO_PIE2D_MIDDLE
            VAR sum = 0.0
            FOR i AS INTEGER = 0 TO nchannels
              sum += p[c[i]]
            NEXT
            r0 = sum / (nchannels + 1) * xm - xn
          CASE GOO_PIE2D_CHANNEL
            r0 = p[ch] * xm - xn
          END SELECT

          FOR i AS INTEGER = 0 TO nchannels
            r = p[c[i]] * xm - xn
            IF r <= r0 THEN dr = r0 - r ELSE dr = r - r0 : r = r0
            IF ABS(dr) > GOO_EPS THEN pie.segment(path(i), r, dr, w, dw)
            w += dw
          NEXT
        NEXT
      END IF

    CASE GOO_PIE2D_GANTT
      IF gap THEN IF pie.init_gaps(gap, nchannels + 1) THEN EXIT SUB
      VAR dr = 1.0 / (nchannels + 1)
      FOR p AS GooType PTR = .Dat->Dat TO e STEP s
        FOR i AS INTEGER = 0 TO nchannels
          VAR r = i * dr
          VAR dw = FRAC(ABS(p[c[i]]))
          IF dw > GOO_EPS THEN
            VAR w = FRAC(ABS(p[c[i] - 1]))
            IF range < _2GOO_PI ANDALSO w + dw > 1.0 THEN
              pie.segment(path(i), r, dr, w, 1.0 - w)
              dw -= 1.0 - w
              w = 0.0
            END IF
            pie.segment(path(i), r, dr, w, dw)
          END IF
        NEXT
      NEXT

    CASE GOO_PIE2D_PERCENT
      IF gap THEN IF pie.init_gaps(gap, nchannels + 1) THEN EXIT SUB
      VAR w = 0.0, dw = 1.0 / .Dat->Row
      FOR p AS GooType PTR = .Dat->Dat TO e STEP s
        VAR xm = 0.0
        FOR i AS INTEGER = 0 TO nchannels
          xm += ABS(p[c[i]])
        NEXT
        IF xm > 0 THEN
          xm = 1.0 / xm
          VAR r = 0.0
          FOR i AS INTEGER = 0 TO nchannels
            VAR dr = ABS(p[c[i]]) * xm
            IF dr > GOO_EPS THEN pie.segment(path(i), r, dr, w, dw)
            r += dr
          NEXT
        END IF
        w += dw
      NEXT

    CASE GOO_PIE2D_STACK
      IF gap THEN IF pie.init_gaps(gap, nchannels + 1) THEN EXIT SUB
      VAR xm = 0.0
      FOR p AS GooType PTR = .Dat->Dat TO e STEP s
        VAR xn = 0.0
        FOR i AS INTEGER = 0 TO nchannels
          xn += ABS(p[c[i]])
        NEXT
        IF xn > xm THEN xm = xn
      NEXT
      g_return_if_fail(xm > 0)
      xm = 1.0 / xm
      VAR w = 0.0, dw = 1.0 / .Dat->Row
      FOR p AS GooType PTR = .Dat->Dat TO e STEP s
        VAR r = 0.0
        FOR i AS INTEGER = 0 TO nchannels
          VAR dr = ABS(p[c[i]]) * xm
          IF dr > GOO_EPS THEN pie.segment(path(i), r, dr, w, dw)
          r += dr
        NEXT
        w += dw
      NEXT

    CASE ELSE '~ GOO_PIE2D_SIMPLE
      IF gap THEN IF pie.init_gaps(gap, nchannels + 1) THEN EXIT SUB
      VAR r = 0.0, dr = 1.0 / (nchannels + 1)
      FOR i AS INTEGER = 0 TO nchannels
        VAR sum = 0.0
        FOR p AS GooType PTR = .Dat->Dat TO e STEP s
          sum += ABS(p[c[i]])
        NEXT
        IF sum THEN
          VAR w = 0.0, col = 0
          FOR p AS GooType PTR = .Dat->Dat TO e STEP s
            VAR dw = ABS(p[c[i]]) / sum
            pie.segment(path(col), r, dr, w, dw)
            w += dw
            col += 1
          NEXT
        END IF
        r += dr
      NEXT
    END SELECT

/'* GooPie2d:format:

By default only the pie segments are drawn.

Since: 0.0
'/
    '~ VAR tt = g_string_new(""), z = .Form
    '~ IF 0 = z ORELSE z[0] = 0 THEN z = GOO_DEFAULT_FORM
    '~ FOR i AS INTEGER = 0 TO nval
      '~ IF 1 THEN
        '~ VAR anchor = 0
        '~ SELECT CASE ww / GOO_PI
        '~ CASE 0.05 TO 0.45 : anchor = GOO_CANVAS_ANCHOR_SW
        '~ CASE 0.45 TO 0.55 : anchor = GOO_CANVAS_ANCHOR_S
        '~ CASE 0.55 TO 0.95 : anchor = GOO_CANVAS_ANCHOR_SE
        '~ CASE 0.95 TO 1.05 : anchor = GOO_CANVAS_ANCHOR_E
        '~ CASE 1.05 TO 1.45 : anchor = GOO_CANVAS_ANCHOR_NE
        '~ CASE 1.45 TO 1.55 : anchor = GOO_CANVAS_ANCHOR_N
        '~ CASE 1.55 TO 1.95 : anchor = GOO_CANVAS_ANCHOR_NW
        '~ CASE ELSE         : anchor = GOO_CANVAS_ANCHOR_W
        '~ END SELECT
        '~ g_string_printf(tt, z, v(i))
        '~ p = goo_canvas_text_new(.PLabl, tt->str, sec(i).Xt, sec(i).Yt, -1.0, anchor, NULL)
      '~ END IF
    '~ NEXT
  END WITH

TROUT("")
END SUB

SUB _pie2d_update CDECL( _
  BYVAL item AS GooCanvasItem PTR, _
  BYVAL entire_tree AS gboolean, _
  BYVAL cr AS cairo_t PTR, _
  BYVAL bounds AS GooCanvasBounds PTR)
TRIN("")

  VAR pie2d = GOO_PIE2D(item)
  VAR simple = GOO_CANVAS_ITEM_SIMPLE(item)

  WITH *pie2d
    IF entire_tree ORELSE simple->need_update THEN _pie2d_draw(pie2d)
    _Pie2d__update(item, entire_tree, cr, bounds)
  END WITH

TROUT("")
END SUB

SUB _goo_pie2d_class_init CDECL( _
  BYVAL pie2d_class AS GooPie2dClass PTR)
TRIN("")

  VAR klass = G_OBJECT_CLASS(pie2d_class)
  WITH *klass
  .finalize     = @_pie2d_finalize
  .get_property = @_pie2d_get_property
  .set_property = @_pie2d_set_property
  END WITH

  g_object_class_install_property(klass, GOO_PIE2D_PROP_CHAN, _
     g_param_spec_string("channels", _
           __("PieDataChannel"), _
           __("The channels in the data array for the pie chart."), _
           NULL, _
           G_PARAM_READWRITE))

  '~ g_object_class_install_property(klass, GOO_PIE2D_PROP_ALPH, _
     '~ g_param_spec_uint("alpha", _
           '~ __("TransparencyAlpha"), _
           '~ __("The alpa value for transparency of the pie graph."), _
           '~ 0, 255, 0, _
           '~ G_PARAM_READWRITE))
'~
  g_object_class_install_property(klass, GOO_PIE2D_PROP_FILL, _
     g_param_spec_pointer("filler", _
           __("FillerObject"), _
           __("The filler object to set color/pattern/pixbuf for pie segments."), _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_PIE2D_PROP_FORM, _
     g_param_spec_string("format", _
           __("LabelFormat"), _
           __("The format for the segment labels."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_PIE2D_PROP_GAPS, _
     g_param_spec_string("gaps", _
           __("GapsBetweenPieSegments"), _
           __("The gap between the pie segments and at the center."), _
           NULL, _
           G_PARAM_READWRITE))

  g_object_class_install_property(klass, GOO_PIE2D_PROP_SEGM, _
     g_param_spec_string("segmented", _
           __("AreaSegment"), _
           __("The start angle and the angle area for the graph."), _
           NULL, _
           G_PARAM_READWRITE))

TROUT("")
END SUB

'~The standard object initialization function.
SUB _goo_pie2d_init CDECL( _
  BYVAL Pie2d AS GooPie2d PTR)
TRIN("")

  WITH *Pie2d
    .Chan = NULL
    .Gaps = NULL
    .GoFi = NULL
    .PSeg = NULL
    .Form = NULL
    '~ .Alph = 255
  END WITH

TROUT("")
END SUB

/'* goo_pie2d_new:
@Parent: the parent item, or %NULL. If a parent is specified, it will assume
 ownership of the item, and the item will automatically be freed when it is
 removed from the parent. Otherwise call g_object_unref() to free it.
   @Dat: the data values to draw
     @X: the x coordinate of the left top corner of the area for the pie chart.
     @Y: the y coordinate of the left top corner of the area for the pie chart
@Width_: the width of the area for the pie chart
@Height: the height of the area for the pie chart
   @...: optional pairs of property names and values, and a terminating %NULL.

Create a new pie chart item from values in @Dat. By default channel 0 (zero) is
used. Specify an alternative channel by #GooPie2d:channels. Each value gets a pie
segment in a different goo_color() and width. Small segments are unvisible until they
are separated from their neighbors by a #GooPie2d:gaps. Negative values are scaled
by -1.

Since: 0.0
Returns: (transfer full): a new pie item.
'/
'~ '*
'~ * <!--PARAMETERS-->
'~ *
'~ * !!!Here's an example showing how to create a pie chart :
'~ *
'~ * <informalexample><programlisting>
'~ *  GooPie2d *pie = goo_pie_new (mygroup, myData, 40.0, 50.0, 300, 200,
'~ *                                  "channel", 2,
'~ *                                  "gap", 5.0,
'~ *                                  "start-angle", 45.0,
'~ *                                   NULL);
'~ * </programlisting></informalexample>
FUNCTION goo_pie2d_new CDECL( _
  BYVAL Parent AS GooCanvasItem PTR, _
  BYVAL Dat AS GooDataPoints PTR, _
  BYVAL X AS GooType, _
  BYVAL Y AS GooType, _
  BYVAL Width_ AS GooType, _
  BYVAL Height AS GooType, _
  ...) AS GooPie2d PTR
TRIN("")

  g_return_val_if_fail(Width_ > 0, NULL)
  g_return_val_if_fail(Height > 0, NULL)
  '~ g_return_val_if_fail(GOO_IS_DATA_POINTS(Dat), NULL)
  g_return_val_if_fail(Dat > 0, NULL)

  VAR pie2d = g_object_new(GOO_TYPE_PIE2D, NULL)

  WITH *GOO_PIE2D(pie2d)
    .Parent = Parent
    .Dat = Dat : goo_data_points_ref(.Dat)
    .Bx = X
    .By = Y
    .Bb = Width_
    .Bh = Height
    '~ g_object_set(pie2d, _
                 '~ "x", CAST(gdouble, .Bx), _
                 '~ "y", CAST(gdouble, .By), _
                 '~ "width", CAST(gdouble, .Bb), _
                 '~ "height", CAST(gdouble, .Bh), _
                 '~ NULL)

    .PSegm = goo_canvas_group_new(pie2d, NULL)
    .PLabl = goo_canvas_group_new(pie2d, NULL)
  END WITH

  VAR va = VA_FIRST(), arg = VA_ARG(va, ZSTRING PTR)
  IF arg THEN g_object_set_valist(pie2d, arg, VA_NEXT(va, ANY PTR))

  IF Parent THEN
    goo_canvas_item_add_child(Parent, pie2d, -1)
    g_object_unref(pie2d)
  END IF

TROUT("")
  RETURN pie2d

END FUNCTION
