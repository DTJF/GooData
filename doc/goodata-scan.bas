#INCLUDE ONCE "crt/string.bi"
#INCLUDE ONCE "crt/stdlib.bi"
'#include once "crt/stdio.bi"
#INCLUDE ONCE "crt/errno.bi"
#INCLUDE ONCE "glib-object.bi"

' run with
' LD_LIBRARY_PATH="../src" ./goodata-scan

#IFDEF GTK_IS_WIDGET_CLASS
#INCLUDE ONCE "gtk/gtk.bi"
#ENDIF

#LIBPATH "../src"
#INCLUDE ONCE "../src/Goo_Data.bas"

DIM SHARED AS GType object_types(7)

FUNCTION get_object_types CDECL() AS GType PTR 'static

    DIM AS gpointer _class
    DIM AS GType typ

    object_types(0) = _goo_data_points_get_type ()
    object_types(1) = _goo_axis_get_type ()
    object_types(2) = _goo_polax_get_type ()
    object_types(3) = _goo_curve2d_get_type ()
    object_types(4) = _goo_bar2d_get_type ()
    object_types(5) = _goo_box2d_get_type ()
    object_types(6) = _goo_pie2d_get_type ()
    object_types(7) = 0

    '/* reference the GObjectClass to initialize the param spec pool
     '* potentially needed by interfaces. See http://bugs.gnome.org/571820 */
    _class = g_type_class_ref (G_TYPE_OBJECT)

    '/* Need to make sure all the types are loaded in and initialize
     '* their signals and properties.
     '*/
    VAR i = 0
    WHILE object_types(i)
      typ = object_types(i)
      IF (G_TYPE_IS_CLASSED (typ)) THEN g_type_class_ref (typ)
      IF (G_TYPE_IS_INTERFACE (typ)) THEN g_type_default_interface_ref (typ)
      i += 1
    WEND

    g_type_class_unref (_class)

    RETURN @object_types(0)
END FUNCTION

'/*
 '* This uses GObject type functions to output signal prototypes and the object
 '* hierarchy.
 '*/

'/* The output files */
'~ DIM SHARED AS ZSTRING PTR signals_filename = @"./goodata.signals.new"
'~ DIM SHARED AS ZSTRING PTR hierarchy_filename = @"./goodata.hierarchy.new"
'~ DIM SHARED AS ZSTRING PTR interfaces_filename = @"./goodata.interfaces.new"
'~ DIM SHARED AS ZSTRING PTR prerequisites_filename = @"./goodata.prerequisites.new"
'~ DIM SHARED AS ZSTRING PTR args_filename = @"./goodata.args.new"
DIM SHARED AS ZSTRING PTR signals_filename = @"./goodata.signals"
DIM SHARED AS ZSTRING PTR hierarchy_filename = @"./goodata.hierarchy"
DIM SHARED AS ZSTRING PTR interfaces_filename = @"./goodata.interfaces"
DIM SHARED AS ZSTRING PTR prerequisites_filename = @"./goodata.prerequisites"
DIM SHARED AS ZSTRING PTR args_filename = @"./goodata.args"

DECLARE SUB output_signals CDECL()
DECLARE SUB output_object_signals CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL object_type AS GType)
DECLARE SUB output_object_signal CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL object_class_name AS CONST gchar PTR, _
  BYVAL signal_id AS guint)
DECLARE FUNCTION get_type_name CDECL( _
  BYVAL type_ AS GType, _
  BYVAL is_pointer AS gboolean PTR) AS CONST gchar PTR
DECLARE SUB output_object_hierarchy CDECL()
DECLARE SUB output_hierarchy CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL type_ AS GType, _
  BYVAL level AS guint)
DECLARE SUB output_object_interfaces CDECL()
DECLARE SUB output_interfaces CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL type_ AS GType)
DECLARE SUB output_interface_prerequisites CDECL()
DECLARE SUB output_prerequisites CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL type_ AS GType)
DECLARE SUB output_args CDECL()
DECLARE SUB output_object_args CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL object_type AS GType)

g_type_init() : g_type_class_ref(G_TYPE_OBJECT)

get_object_types ()
?"Hier1"
output_signals ()
?"Hier2"
output_object_hierarchy ()
?"Hier3"
output_object_interfaces ()
?"Hier4"
output_interface_prerequisites ()
?"Hier5"
output_args ()
?"Hier6"

END 0


SUB output_signals CDECL() 'static

  DIM AS FILE PTR fp
  fp = fopen (signals_filename, "w")
  IF (fp = NULL) THEN
    'g_warning ("Couldn't open output file: %s : %s", signals_filename, g_strerror(errno))
    g_warning ("Couldn't open output file: %s", signals_filename)
    EXIT SUB
  END IF

  VAR i = 0
  WHILE object_types(i)
    output_object_signals (fp, object_types(i))
    i += 1
  WEND

  fclose (fp)
END SUB

FUNCTION compare_signals CDECL( _
  BYVAL a AS ANY PTR, _
  BYVAL b AS ANY PTR) AS gint 'static

  DIM AS CONST guint PTR signal_a, signal_b
  signal_a = CAST(guint PTR, a)
  signal_b = CAST(guint PTR, b)

  RETURN strcmp (g_signal_name (*signal_a), g_signal_name (*signal_b))
END FUNCTION

'/* This outputs all the signals of one object. */
SUB output_object_signals CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL object_type AS GType) 'static

  DIM AS CONST gchar PTR object_class_name
  DIM AS guint n_signals
  'guint sig

  IF (G_TYPE_IS_INSTANTIATABLE (object_type) ORELSE _
      G_TYPE_IS_INTERFACE (object_type)) THEN

    object_class_name = g_type_name (object_type)

    DIM AS guint PTR signals
    signals = g_signal_list_ids (object_type, @n_signals)
    qsort (signals, n_signals, SIZEOF (guint), @compare_signals)

    FOR sig AS INTEGER = 0 TO n_signals - 1
      output_object_signal (fp, object_class_name, signals[sig])
    NEXT
    g_free (signals)
  END IF
END SUB


'/* This outputs one signal. */
SUB output_object_signal CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL object_name AS CONST gchar PTR, _
  BYVAL signal_id AS guint) 'static

  DIM AS GSignalQuery query_info
  DIM AS CONST gchar PTR type_name, ret_type, object_arg, arg_name
  DIM AS gchar PTR pos_, object_arg_lower
  DIM AS gboolean is_pointer
  DIM AS ZSTRING*1024 buffer '[1024]
  DIM AS guint i, param
  DIM AS gint param_num, widget_num, event_num, callback_num
  DIM AS gint PTR arg_num
  DIM AS ZSTRING*128 signal_name '[128]
  DIM AS ZSTRING*16 flags '[16]

  '/*  g_print ("Object: %s Signal: %u\n", object_name, signal_id);*/

  param_num = 1
  widget_num = event_num = callback_num = 0

  g_signal_query (signal_id, @query_info)

  '/* Output the signal object type and the argument name. We assume the
     'type is a pointer - I think that is OK. We remove "Gtk" or "Gnome" and
     'convert to lower case for the argument name. */
  pos_ = @buffer
  sprintf (pos_, "%s ", object_name)
  pos_ += strlen (pos_)

  '/* Try to come up with a sensible variable name for the first arg
   '* It chops off 2 know prefixes :/ and makes the name lowercase
   '* It should replace lowercase -> uppercase with '_'
   '* GFileMonitor -> file_monitor
   '* GIOExtensionPoint -> extension_point
   '* GtkTreeView -> tree_view
   '* if 2nd char is upper case too
   '*   search for first lower case and go back one char
   '* else
   '*   search for next upper case
   '*/
  IF (0 = strncmp (object_name, @"Gtk", 3)) THEN
    object_arg = object_name + 3
  ELSEIF (0 = strncmp (object_name, @"Gnome", 5)) THEN
    object_arg = object_name + 5
  ELSE
    object_arg = object_name
  END IF

  object_arg_lower = g_ascii_strdown (object_arg, -1)
  sprintf (pos_, "*%s\n", object_arg_lower)
  pos_ += strlen (pos_)
  IF (0 = strncmp (object_arg_lower, "widget", 6)) THEN widget_num = 2
  g_free(object_arg_lower)

  '/* Convert signal name to use underscores rather than dashes '-'. */
  'strncpy (signal_name, query_info.signal_name, 127);
  signal_name[127] = 0
  i = 0
  WHILE signal_name[i]
    IF (signal_name[i] = ASC("-")) THEN signal_name[i] = ASC("_")
    i += 1
  WEND

  '/* Output the signal parameters. */
  FOR param AS INTEGER = 0 TO query_info.n_params - 1
    type_name = get_type_name (query_info.param_types[param] AND NOT G_SIGNAL_TYPE_STATIC_SCOPE, @is_pointer)

    '/* Most arguments to the callback are called "arg1", "arg2", etc.
       'GtkWidgets are called "widget", "widget2", ...
       'GtkCallbacks are called "callback", "callback2", ... */
    IF (0 = strcmp (type_name, "GtkWidget")) THEN
      arg_name = @"widget"
      arg_num = @widget_num
    ELSEIF (0 = strcmp (type_name, "GtkCallback") ORELSE _
            0 = strcmp (type_name, "GtkCCallback")) THEN
      arg_name = @"callback"
      arg_num = @callback_num
    ELSE
      arg_name = @"arg"
      arg_num = @param_num
    END IF
    sprintf (pos_, "%s ", type_name)
    pos_ += strlen (pos_)

    IF (0 = arg_num ORELSE *arg_num = 0) THEN
      sprintf (pos_, "%s%s\n", *IIF(is_pointer, @"*", @" "), arg_name)
    ELSE
      sprintf (pos_, "%s%s%i\n", *IIF(is_pointer, @"*", @" "), arg_name, _
               *arg_num)
    END IF
    pos_ += strlen (pos_)

    IF (arg_num) THEN
      IF (*arg_num = 0) THEN
        *arg_num = 2
      ELSE
        *arg_num += 1
      END IF

    END IF
  NEXT

  pos_ = @flags
  '/* We use one-character flags for simplicity. */
  IF (query_info.signal_flags AND G_SIGNAL_RUN_FIRST) THEN _
    *pos_ = ASC("f") : pos_ += 1
  IF (query_info.signal_flags AND G_SIGNAL_RUN_LAST) THEN _
    *pos_ = ASC("l") : pos_ += 1
  IF (query_info.signal_flags AND G_SIGNAL_RUN_CLEANUP) THEN _
    *pos_ = ASC("c") : pos_ += 1
  IF (query_info.signal_flags AND G_SIGNAL_NO_RECURSE) THEN _
    *pos_ = ASC("r") : pos_ += 1
  IF (query_info.signal_flags AND G_SIGNAL_DETAILED) THEN _
    *pos_ = ASC("d") : pos_ += 1
  IF (query_info.signal_flags AND G_SIGNAL_ACTION) THEN _
    *pos_ = ASC("a") : pos_ += 1
  IF (query_info.signal_flags AND G_SIGNAL_NO_HOOKS) THEN _
    *pos_ = ASC("h") : pos_ += 1
  *pos_ = 0

  '/* Output the return type and function name. */
  ret_type = get_type_name (query_info.return_type OR NOT G_SIGNAL_TYPE_STATIC_SCOPE, @is_pointer)

  fprintf (fp, _
           !"<SIGNAL>\n<NAME>%s::%s</NAME>\n<RETURNS>%s%s</RETURNS>\n<FLAGS>%s</FLAGS>\n%s</SIGNAL>\n\n", _
           object_name, query_info.signal_name, ret_type, *IIF(is_pointer, @"*", @""), flags, buffer)
END SUB


'/* Returns the type name to use for a signal argument or return value, given
   'the GtkType from the signal info. It also sets is_pointer to TRUE if the
   'argument needs a '*' since it is a pointer. */
FUNCTION get_type_name CDECL( _
  BYVAL type_ AS GType, _
  BYVAL is_pointer AS gboolean PTR) AS CONST gchar PTR 'static

  DIM AS CONST gchar PTR type_name

  *is_pointer = FALSE
  type_name = g_type_name (type_)

  SELECT CASE AS CONST (type_)
  CASE G_TYPE_NONE
  CASE G_TYPE_CHAR
  CASE G_TYPE_UCHAR
  CASE G_TYPE_BOOLEAN
  CASE G_TYPE_INT
  CASE G_TYPE_UINT
  CASE G_TYPE_LONG
  CASE G_TYPE_ULONG
  CASE G_TYPE_FLOAT
  CASE G_TYPE_DOUBLE
  CASE G_TYPE_POINTER
    '/* These all have normal C type names so they are OK. */
    RETURN type_name

  CASE G_TYPE_STRING
    '/* A GtkString is really a gchar*. */
    '*is_pointer = TRUE;
    RETURN @"gchar"

  CASE G_TYPE_ENUM
  CASE G_TYPE_FLAGS
    '/* We use a gint for both of these. Hopefully a subtype with a decent
       'name will be registered and used instead, as GTK+ does itself. */
    RETURN @"gint"

  CASE G_TYPE_BOXED
    '/* The boxed type shouldn't be used itself, only subtypes. Though we
       'return 'gpointer' just in case. */
    RETURN @"gpointer"

  CASE G_TYPE_PARAM
    '/* A GParam is really a GParamSpec*. */
    *is_pointer = TRUE
    RETURN @"GParamSpec"

#IF GLIB_CHECK_VERSION (2, 25, 9)
  CASE G_TYPE_VARIANT
    *is_pointer = TRUE
    RETURN @"GVariant"
#ENDIF

'default:
    'break;
  END SELECT

  '/* For all GObject subclasses we can use the class name with a "*",
     'e.g. 'GtkWidget *'. */
  IF (g_type_is_a (type_, G_TYPE_OBJECT)) THEN *is_pointer = TRUE

  '/* Also catch non GObject root types */
  IF (G_TYPE_IS_CLASSED (type_)) THEN *is_pointer = TRUE

  '/* All boxed subtypes will be pointers as well. */
  '/* Exception: GStrv */
  IF (g_type_is_a (type_, G_TYPE_BOXED) ANDALSO _
      0 = g_type_is_a (type_, G_TYPE_STRV)) THEN *is_pointer = TRUE

  '/* All pointer subtypes will be pointers as well. */
  IF (g_type_is_a (type_, G_TYPE_POINTER)) THEN *is_pointer = TRUE

  '/* But enums are not */
  IF (g_type_is_a (type_, G_TYPE_ENUM) ORELSE _
      g_type_is_a (type_, G_TYPE_FLAGS)) THEN *is_pointer = FALSE

  RETURN type_name
END FUNCTION


'/* This outputs the hierarchy of all objects which have been initialized,
   'i.e. by calling their XXX_get_type() initialization function. */
SUB output_object_hierarchy CDECL() 'static

  'FILE *fp;
  'gint i,j;
  DIM AS GType root, type_
  DIM AS GType root_types(UBOUND(object_types))
  root_types(0) = G_TYPE_INVALID

  DIM AS FILE PTR fp
  fp = fopen (hierarchy_filename, "w")
  IF (fp = NULL) THEN
    'g_warning ("Couldn't open output file: %s : %s", hierarchy_filename, g_strerror(errno))
    g_warning ("Couldn't open output file: %s", hierarchy_filename)
    EXIT SUB
  END IF
?"Hier2a"
  output_hierarchy (fp, G_TYPE_OBJECT, 0)
?"Hier2b"
  output_hierarchy (fp, G_TYPE_INTERFACE, 0)
?"Hier2c"

  VAR i = 0
  WHILE object_types(i)
    root = object_types(i)
    WHILE ((type_ = g_type_parent (root)))
      root = type_
    WEND
    IF ((root <> G_TYPE_OBJECT) ANDALSO (root <> G_TYPE_INTERFACE)) THEN
      VAR j = 0
      WHILE root_types(j)
        IF (root = root_types(j)) THEN root = G_TYPE_INVALID : EXIT WHILE
        j += 1
      WEND
      IF (root) THEN
        root_types(j) = root
        output_hierarchy (fp, root, 0)
      END IF
    END IF
    i += 1
  WEND

  fclose (fp)
END SUB

'/* This is called recursively to output the hierarchy of a object. */
SUB output_hierarchy CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL type_ AS GType, _
  BYVAL level AS guint) ''static

  DIM AS GType PTR children
  DIM AS guint n_children

  IF (0 = type_) THEN EXIT SUB

  FOR i AS INTEGER = 0 TO level - 1
    fprintf (fp, "  ")
  NEXT
  fprintf (fp, !"%s\n", g_type_name (type_))

  children = g_type_children (type_, @n_children)

  FOR i AS INTEGER = 0 TO n_children - 1
    output_hierarchy (fp, children[i], level + 1)
  NEXT

  g_free (children)
END SUB

SUB output_object_interfaces CDECL() 'static

  DIM AS FILE PTR fp
  fp = fopen (interfaces_filename, "w")
  IF (fp = NULL) THEN
    'g_warning ("Couldn't open output file: %s : %s", interfaces_filename, g_strerror(errno))
    g_warning ("Couldn't open output file: %s", interfaces_filename)
    EXIT SUB
  END IF
  output_interfaces (fp, G_TYPE_OBJECT)

  VAR i = 0
  WHILE object_types(i)
    IF (0 = g_type_parent (object_types(i)) ANDALSO _
       (object_types(i) <> G_TYPE_OBJECT) ANDALSO _
        G_TYPE_IS_INSTANTIATABLE (object_types(i))) THEN _
          output_interfaces (fp, object_types(i))
    i += 1
  WEND
  fclose (fp)
END SUB

SUB output_interfaces CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL type_ AS GType) 'static

  'guint i;
  DIM AS GType PTR children, interfaces
  DIM AS guint n_children, n_interfaces

  IF (0 = type_) THEN EXIT SUB

  interfaces = g_type_interfaces (type_, @n_interfaces)

  IF (n_interfaces > 0) THEN
    fprintf (fp, "%s", g_type_name (type_))
    FOR i AS INTEGER = 0 TO n_interfaces - 1
      fprintf (fp, " %s", g_type_name (interfaces[i]))
    NEXT
    fprintf (fp, !"\n")
  END IF
  g_free (interfaces)

  children = g_type_children (type_, @n_children)

  FOR i AS INTEGER = 0 TO n_children - 1
    output_interfaces (fp, children[i])
  NEXT

  g_free (children)
END SUB

SUB output_interface_prerequisites CDECL() 'static

  DIM AS FILE PTR fp
  fp = fopen (prerequisites_filename, "w")
  IF (fp = NULL) THEN
    'g_warning ("Couldn't open output file: %s : %s", prerequisites_filename, g_strerror(errno))
    g_warning ("Couldn't open output file: %s", prerequisites_filename)
    EXIT SUB
  END IF
  output_prerequisites (fp, G_TYPE_INTERFACE)
  fclose (fp)
END SUB

SUB output_prerequisites CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL type_ AS GType) 'static

#IF GLIB_CHECK_VERSION(2,1,0)
  DIM AS GType PTR children, prerequisites
  DIM AS guint n_children, n_prerequisites

  IF (0 = type_) THEN EXIT SUB

  prerequisites = g_type_interface_prerequisites (type_, @n_prerequisites)

  IF (n_prerequisites > 0) THEN
    fprintf (fp, "%s", g_type_name (type_))
    FOR i AS INTEGER = 0 TO n_prerequisites - 1
      fprintf (fp, " %s", g_type_name (prerequisites[i]))
    NEXT
    fprintf (fp, !"\n")
  END IF
  g_free (prerequisites)

  children = g_type_children (type_, @n_children)

  FOR i AS INTEGER = 0 TO n_children - 1
    output_prerequisites (fp, children[i])
  NEXT

  g_free (children)
#ENDIF
END SUB

SUB output_args CDECL() 'static

  DIM AS FILE PTR fp
  fp = fopen (args_filename, "w")
  IF (fp = NULL) THEN
    'g_warning ("Couldn't open output file: %s : %s", args_filename, g_strerror(errno))
    g_warning ("Couldn't open output file: %s", args_filename)
    RETURN
  END IF

?"Hier6a"

  VAR i = 0
  WHILE object_types(i)
    output_object_args (fp, object_types(i))
    i += 1
  WEND

?"Hier6b"

  fclose (fp)
END SUB

FUNCTION compare_param_specs CDECL( _
  BYVAL a AS ANY PTR, _
  BYVAL b AS ANY PTR) AS gint 'static

  DIM AS GParamSpec PTR spec_a
  spec_a = *CAST(GParamSpec PTR PTR, a)
  DIM AS GParamSpec PTR spec_b
  spec_b = *CAST(GParamSpec PTR PTR, b)

  RETURN strcmp (g_param_spec_get_name (spec_a), g_param_spec_get_name (spec_b))
END FUNCTION

'/* Its common to have unsigned properties restricted
 '* to the signed range. Therefore we make this look
 '* a bit nicer by spelling out the max constants.
 '*/

'/* Don't use "==" with floats, it might trigger a gcc warning.  */
#DEFINE GTKDOC_COMPARE_FLOAT(x, y) (x = y) '(x <= y andalso x >= y)

FUNCTION describe_double_constant CDECL( _
  BYVAL value AS gdouble) AS gchar PTR 'static

  DIM AS gchar PTR desc

  IF (GTKDOC_COMPARE_FLOAT (value, G_MAXDOUBLE)) THEN
    desc = g_strdup ("G_MAXDOUBLE")
  ELSEIF (GTKDOC_COMPARE_FLOAT (value, G_MINDOUBLE)) THEN
    desc = g_strdup ("G_MINDOUBLE")
  ELSEIF (GTKDOC_COMPARE_FLOAT (value, -G_MAXDOUBLE)) THEN
    desc = g_strdup ("-G_MAXDOUBLE")
  ELSEIF (GTKDOC_COMPARE_FLOAT (value, G_MAXFLOAT)) THEN
    desc = g_strdup ("G_MAXFLOAT")
  ELSEIF (GTKDOC_COMPARE_FLOAT (value, G_MINFLOAT)) THEN
    desc = g_strdup ("G_MINFLOAT")
  ELSEIF (GTKDOC_COMPARE_FLOAT (value, -G_MAXFLOAT)) THEN
    desc = g_strdup ("-G_MAXFLOAT")
  ELSE
    '/* make sure floats are output with a decimal dot irrespective of
    '* current locale. Use formatd since we want human-readable numbers
    '* and do not need the exact same bit representation when deserialising */
    desc = g_malloc0 (G_ASCII_DTOSTR_BUF_SIZE)
    g_ascii_formatd (desc, G_ASCII_DTOSTR_BUF_SIZE, "%g", value)
  END IF

  RETURN desc
END FUNCTION

FUNCTION describe_signed_constant CDECL( _
  BYVAL size AS gsize, _
  BYVAL value AS gint64) AS gchar PTR 'static

  DIM AS gchar PTR desc = NULL

  SELECT CASE AS CONST (size)
    CASE 2
      IF (SIZEOF (gint) = 2) THEN
        IF (value = G_MAXINT) THEN
          desc = g_strdup ("G_MAXINT")
        ELSEIF (value = G_MININT) THEN
          desc = g_strdup ("G_MININT")
        ELSEIF (value = CAST(gint64, G_MAXUINT)) THEN
          desc = g_strdup ("G_MAXUINT")
        END IF
      END IF
    CASE 4
      IF (SIZEOF (gint) = 4) THEN
        IF (value = G_MAXINT) THEN
          desc = g_strdup ("G_MAXINT")
        ELSEIF (value = G_MININT) THEN
          desc = g_strdup ("G_MININT")
        ELSEIF (value = CAST(gint64, G_MAXUINT)) THEN
          desc = g_strdup ("G_MAXUINT")
        END IF
      END IF
      IF (value = G_MAXLONG) THEN
        desc = g_strdup ("G_MAXLONG")
      ELSEIF (value = G_MINLONG) THEN
        desc = g_strdup ("G_MINLONG")
      ELSEIF (value = CAST(gint64, G_MAXULONG)) THEN
        desc = g_strdup ("G_MAXULONG")
      END IF
    CASE 8
      IF (value = G_MAXINT64) THEN
        desc = g_strdup ("G_MAXINT64")
      ELSEIF (value = G_MININT64) THEN
        desc = g_strdup ("G_MININT64")
      END IF

    'default:
      'break;
  END SELECT
  IF (0 = desc) THEN _
    desc = g_strdup_printf ("%" G_GINT64_FORMAT, value)

  RETURN desc
END FUNCTION

FUNCTION describe_unsigned_constant CDECL( _
  BYVAL size AS gsize, _
  BYVAL value AS guint64) AS gchar PTR 'static

  DIM AS gchar PTR desc = NULL

  SELECT CASE AS CONST (size)
    CASE 2
      IF (SIZEOF (gint) = 2) THEN
        IF (value = CAST(guint64, G_MAXINT)) THEN
          desc = g_strdup ("G_MAXINT")
        ELSEIF (value = G_MAXUINT) THEN
          desc = g_strdup ("G_MAXUINT")
        END IF
      END IF
    CASE 4
      IF (SIZEOF (gint) = 4) THEN
        IF (value = CAST(guint64, G_MAXINT)) THEN
          desc = g_strdup ("G_MAXINT")
        ELSEIF (value = G_MAXUINT) THEN
          desc = g_strdup ("G_MAXUINT")
        END IF
      END IF
      IF (value = CAST(guint64, G_MAXLONG)) THEN
        desc = g_strdup ("G_MAXLONG")
      ELSEIF (value = G_MAXULONG) THEN
        desc = g_strdup ("G_MAXULONG")
      END IF
    CASE 8
      IF (value = G_MAXINT64) THEN
        desc = g_strdup ("G_MAXINT64")
      ELSEIF (value = G_MAXUINT64) THEN
        desc = g_strdup ("G_MAXUINT64")
      END IF
    'default:
      'break;
  END SELECT
  IF (0 = desc) THEN _
    desc = g_strdup_printf ("%" G_GUINT64_FORMAT, value)

  RETURN desc
END FUNCTION

FUNCTION describe_type CDECL( _
  BYVAL spec AS GParamSpec PTR) AS gchar PTR 'static

  DIM AS gchar PTR desc
  DIM AS gchar PTR lower
  DIM AS gchar PTR upper

  IF (G_IS_PARAM_SPEC_CHAR (spec)) THEN
    DIM AS GParamSpecChar PTR pspec
    pspec = G_PARAM_SPEC_CHAR (spec)

    lower = describe_signed_constant (SIZEOF(gchar), pspec->minimum)
    upper = describe_signed_constant (SIZEOF(gchar), pspec->maximum)
    IF (pspec->minimum = G_MININT8 ANDALSO pspec->maximum = G_MAXINT8) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = G_MININT8) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXINT8) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_UCHAR (spec)) THEN
    DIM AS GParamSpecUChar PTR pspec
    pspec = G_PARAM_SPEC_UCHAR (spec)

    lower = describe_unsigned_constant (SIZEOF(guchar), pspec->minimum)
    upper = describe_unsigned_constant (SIZEOF(guchar), pspec->maximum)
    IF (pspec->minimum = 0 ANDALSO pspec->maximum = G_MAXUINT8) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = 0) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXUINT8) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_INT (spec)) THEN
    DIM AS GParamSpecInt PTR pspec
    pspec = G_PARAM_SPEC_INT (spec)

    lower = describe_signed_constant (SIZEOF(gint), pspec->minimum)
    upper = describe_signed_constant (SIZEOF(gint), pspec->maximum)
    IF (pspec->minimum = G_MININT ANDALSO pspec->maximum = G_MAXINT) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = G_MININT) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXINT) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_UINT (spec)) THEN
    DIM AS GParamSpecUInt PTR pspec
    pspec = G_PARAM_SPEC_UINT (spec)

    lower = describe_unsigned_constant (SIZEOF(guint), pspec->minimum)
    upper = describe_unsigned_constant (SIZEOF(guint), pspec->maximum)
    IF (pspec->minimum = 0 ANDALSO pspec->maximum = G_MAXUINT) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = 0) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXUINT) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_LONG (spec)) THEN
    DIM AS GParamSpecLong PTR pspec
    pspec = G_PARAM_SPEC_LONG (spec)

    lower = describe_signed_constant (SIZEOF(glong), pspec->minimum)
    upper = describe_signed_constant (SIZEOF(glong), pspec->maximum)
    IF (pspec->minimum = G_MINLONG ANDALSO pspec->maximum = G_MAXLONG) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = G_MINLONG) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXLONG) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_ULONG (spec)) THEN
    DIM AS GParamSpecULong PTR pspec
    pspec = G_PARAM_SPEC_ULONG (spec)

    lower = describe_unsigned_constant (SIZEOF(gulong), pspec->minimum)
    upper = describe_unsigned_constant (SIZEOF(gulong), pspec->maximum)
    IF (pspec->minimum = 0 ANDALSO pspec->maximum = G_MAXULONG) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = 0) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXULONG) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_INT64 (spec)) THEN
    DIM AS GParamSpecInt64 PTR pspec
    pspec = G_PARAM_SPEC_INT64 (spec)

    lower = describe_signed_constant (SIZEOF(gint64), pspec->minimum)
    upper = describe_signed_constant (SIZEOF(gint64), pspec->maximum)
    IF (pspec->minimum = G_MININT64 ANDALSO pspec->maximum = G_MAXINT64) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = G_MININT64) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXINT64) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_UINT64 (spec)) THEN
    DIM AS GParamSpecUInt64 PTR pspec
    pspec = G_PARAM_SPEC_UINT64 (spec)

    lower = describe_unsigned_constant (SIZEOF(guint64), pspec->minimum)
    upper = describe_unsigned_constant (SIZEOF(guint64), pspec->maximum)
    IF (pspec->minimum = 0 ANDALSO pspec->maximum = G_MAXUINT64) THEN
      desc = g_strdup ("")
    ELSEIF (pspec->minimum = 0) THEN
      desc = g_strdup_printf ("<= %s", upper)
    ELSEIF (pspec->maximum = G_MAXUINT64) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_FLOAT (spec)) THEN
    DIM AS GParamSpecFloat PTR pspec
    pspec = G_PARAM_SPEC_FLOAT (spec)

    lower = describe_double_constant (pspec->minimum)
    upper = describe_double_constant (pspec->maximum)
    IF (GTKDOC_COMPARE_FLOAT (pspec->minimum, -G_MAXFLOAT)) THEN
      IF (GTKDOC_COMPARE_FLOAT (pspec->maximum, G_MAXFLOAT)) THEN
        desc = g_strdup ("")
      ELSE
        desc = g_strdup_printf ("<= %s", upper)
      END IF
    ELSEIF (GTKDOC_COMPARE_FLOAT (pspec->maximum, G_MAXFLOAT)) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
  ELSEIF (G_IS_PARAM_SPEC_DOUBLE (spec)) THEN
    DIM AS GParamSpecDouble PTR pspec
    pspec = G_PARAM_SPEC_DOUBLE (spec)

    lower = describe_double_constant (pspec->minimum)
    upper = describe_double_constant (pspec->maximum)
    IF (GTKDOC_COMPARE_FLOAT (pspec->minimum, -G_MAXDOUBLE)) THEN
      IF (GTKDOC_COMPARE_FLOAT (pspec->maximum, G_MAXDOUBLE)) THEN
        desc = g_strdup ("")
      ELSE
        desc = g_strdup_printf ("<= %s", upper)
      END IF
    ELSEIF (GTKDOC_COMPARE_FLOAT (pspec->maximum, G_MAXDOUBLE)) THEN
      desc = g_strdup_printf (">= %s", lower)
    ELSE
      desc = g_strdup_printf ("[%s,%s]", lower, upper)
    END IF
    g_free (lower)
    g_free (upper)
#IF GLIB_CHECK_VERSION (2, 12, 0)
  ELSEIF (G_IS_PARAM_SPEC_GTYPE (spec)) THEN
    DIM AS GParamSpecGType PTR pspec
    pspec = G_PARAM_SPEC_GTYPE (spec)
    DIM AS gboolean is_pointer

    desc = g_strdup (get_type_name (pspec->is_a_type, @is_pointer))
#ENDIF
#IF GLIB_CHECK_VERSION (2, 25, 9)
  ELSEIF (G_IS_PARAM_SPEC_VARIANT (spec)) THEN
    DIM AS GParamSpecVariant PTR pspec
    pspec = G_PARAM_SPEC_VARIANT (spec)
    DIM AS gchar PTR variant_type

    variant_type = g_variant_type_dup_string (pspec->type)
    desc = g_strdup_printf ("GVariant<%s>", variant_type)
    g_free (variant_type)
#ENDIF
  ELSE
    desc = g_strdup ("")
  END IF

  RETURN desc
END FUNCTION

FUNCTION describe_default CDECL( _
  BYVAL spec AS GParamSpec PTR) AS gchar PTR 'static
  DIM AS gchar PTR desc

  IF (G_IS_PARAM_SPEC_CHAR (spec)) THEN
    DIM AS GParamSpecChar PTR pspec
    pspec = G_PARAM_SPEC_CHAR (spec)

    desc = g_strdup_printf ("%d", pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_UCHAR (spec)) THEN
    DIM AS GParamSpecUChar PTR pspec
    pspec = G_PARAM_SPEC_UCHAR (spec)

    desc = g_strdup_printf ("%u", pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_BOOLEAN (spec)) THEN
    DIM AS GParamSpecBoolean PTR pspec
    pspec = G_PARAM_SPEC_BOOLEAN (spec)

    desc = g_strdup_printf ("%s", *IIF(pspec->default_value, @"TRUE", @"FALSE"))
  ELSEIF (G_IS_PARAM_SPEC_INT (spec)) THEN
    DIM AS GParamSpecInt PTR pspec
    pspec = G_PARAM_SPEC_INT (spec)

    desc = g_strdup_printf ("%d", pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_UINT (spec)) THEN
    DIM AS GParamSpecUInt PTR pspec
    pspec = G_PARAM_SPEC_UINT (spec)

    desc = g_strdup_printf ("%u", pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_LONG (spec)) THEN
    DIM AS GParamSpecLong PTR pspec
    pspec = G_PARAM_SPEC_LONG (spec)

    desc = g_strdup_printf ("%ld", pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_LONG (spec)) THEN
    DIM AS GParamSpecULong PTR pspec
    pspec = G_PARAM_SPEC_ULONG (spec)

    desc = g_strdup_printf ("%lu", pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_INT64 (spec)) THEN
    DIM AS GParamSpecInt64 PTR pspec
    pspec = G_PARAM_SPEC_INT64 (spec)

    desc = g_strdup_printf ("%" G_GINT64_FORMAT, pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_UINT64 (spec)) THEN
    DIM AS GParamSpecUInt64 PTR pspec
    pspec = G_PARAM_SPEC_UINT64 (spec)

    desc = g_strdup_printf ("%" G_GUINT64_FORMAT, pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_UNICHAR (spec)) THEN
    DIM AS GParamSpecUnichar PTR pspec
    pspec = G_PARAM_SPEC_UNICHAR (spec)

    IF (g_unichar_isprint (pspec->default_value)) THEN
      desc = g_strdup_printf ("'%c'", pspec->default_value)
    ELSE
      desc = g_strdup_printf ("%u", pspec->default_value)
    END IF
  ELSEIF (G_IS_PARAM_SPEC_ENUM (spec)) THEN
    DIM AS GParamSpecEnum PTR pspec
    pspec = G_PARAM_SPEC_ENUM (spec)

    DIM AS GEnumValue PTR value
    value = g_enum_get_value (pspec->enum_class, pspec->default_value)
    IF (value) THEN
      desc = g_strdup_printf ("%s", value->value_name)
    ELSE
      desc = g_strdup_printf ("%d", pspec->default_value)
    END IF
  ELSEIF (G_IS_PARAM_SPEC_FLAGS (spec)) THEN
    DIM AS GParamSpecFlags PTR pspec
    pspec = G_PARAM_SPEC_FLAGS (spec)
    DIM AS guint default_value
    DIM AS GString PTR acc

    default_value = pspec->default_value
    acc = g_string_new ("")

    DIM AS GFlagsValue PTR value
    WHILE (default_value)
      value = g_flags_get_first_value (pspec->flags_class, default_value)

      IF (0 = value) THEN EXIT WHILE

      IF (acc->len > 0) THEN g_string_append (acc, "|")
      g_string_append (acc, value->value_name)

      'default_value &= ~value->value;
      default_value AND= NOT value->value
    WEND

    IF (default_value = 0) THEN
      desc = g_string_free (acc, FALSE)
    ELSE
      desc = g_strdup_printf ("%d", pspec->default_value)
      g_string_free (acc, TRUE)
    END IF
  ELSEIF (G_IS_PARAM_SPEC_FLOAT (spec)) THEN
    DIM AS GParamSpecFloat PTR pspec
    pspec = G_PARAM_SPEC_FLOAT (spec)

    '/* make sure floats are output with a decimal dot irrespective of
     '* current locale. Use formatd since we want human-readable numbers
     '* and do not need the exact same bit representation when deserialising */
    desc = g_malloc0 (G_ASCII_DTOSTR_BUF_SIZE)
    g_ascii_formatd (desc, G_ASCII_DTOSTR_BUF_SIZE, "%g", _
        pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_DOUBLE (spec)) THEN
    DIM AS GParamSpecDouble PTR pspec
    pspec = G_PARAM_SPEC_DOUBLE (spec)

    '/* make sure floats are output with a decimal dot irrespective of
     '* current locale. Use formatd since we want human-readable numbers
     '* and do not need the exact same bit representation when deserialising */
    desc = g_malloc0 (G_ASCII_DTOSTR_BUF_SIZE)
    g_ascii_formatd (desc, G_ASCII_DTOSTR_BUF_SIZE, "%g", _
        pspec->default_value)
  ELSEIF (G_IS_PARAM_SPEC_STRING (spec)) THEN
    DIM AS GParamSpecString PTR pspec
    pspec = G_PARAM_SPEC_STRING (spec)

    DIM AS gchar PTR esc
    IF (pspec->default_value) THEN
      esc = g_strescape (pspec->default_value, NULL)

      desc = g_strdup_printf (!"\"%s\"", esc)

      g_free (esc)
    ELSE
      desc = g_strdup_printf ("NULL")
    END IF
#IF GLIB_CHECK_VERSION (2, 25, 9)
  ELSEIF (G_IS_PARAM_SPEC_VARIANT (spec)) THEN
    DIM AS GParamSpecVariant PTR pspec
    pspec = G_PARAM_SPEC_VARIANT (spec)

    IF (pspec->default_value) THEN
      desc = g_variant_print (pspec->default_value, TRUE)
    ELSE
      desc = g_strdup ("NULL")
    END IF
#ENDIF
  ELSE
    desc = g_strdup ("")
  END IF

  RETURN desc
END FUNCTION


SUB output_object_args CDECL( _
  BYVAL fp AS FILE PTR, _
  BYVAL object_type AS GType) 'static

  DIM AS gpointer class_
  DIM AS CONST gchar PTR object_class_name
  DIM AS guint arg
  'dim as gchar flags[16]
  DIM AS ZSTRING*16 flags
  DIM AS gchar PTR pos_
  DIM AS GParamSpec PTR PTR properties
  DIM AS guint n_properties
  DIM AS gboolean child_prop
  DIM AS gboolean style_prop
  DIM AS gboolean is_pointer
  DIM AS CONST gchar PTR type_name
  DIM AS gchar PTR type_desc
  DIM AS gchar PTR default_value

  IF (G_TYPE_IS_OBJECT (object_type)) THEN
    class_ = g_type_class_peek (object_type)
    IF (0 = class_) THEN EXIT SUB

    properties = g_object_class_list_properties (class_, @n_properties)
#IF GLIB_MAJOR_VERSION > 2 OR (GLIB_MAJOR_VERSION = 2 AND GLIB_MINOR_VERSION >= 3)
  ELSEIF (G_TYPE_IS_INTERFACE (object_type)) THEN
    class_ = g_type_default_interface_ref (object_type)

    IF (0 = class_) THEN EXIT SUB

    properties = g_object_interface_list_properties (class_, @n_properties)
#ENDIF
  ELSE
    EXIT SUB
  END IF

?"Hier6a1"

  object_class_name = g_type_name (object_type)

  child_prop = FALSE
  style_prop = FALSE

  WHILE (TRUE)
    qsort (properties, n_properties, SIZEOF (GParamSpec PTR), @compare_param_specs)
    FOR arg = 0 TO n_properties - 1
      DIM AS GParamSpec PTR spec
      DIM AS CONST gchar PTR nick, blurb, dot
      DIM AS CONST gchar PTR _nick, _blurb

      spec = properties[arg]
      IF (spec->owner_type <> object_type) THEN CONTINUE FOR

      pos_ = @flags
      '/* We use one-character flags for simplicity. */
      IF (child_prop ANDALSO 0 = style_prop) THEN _
        *pos_ = ASC("c") : pos_ += 1
      IF (style_prop) THEN _
        *pos_ = ASC("s") : pos_ += 1
      IF (spec->flags AND G_PARAM_READABLE) THEN _
        *pos_ = ASC("r") : pos_ += 1
      IF (spec->flags AND G_PARAM_WRITABLE) THEN _
        *pos_ = ASC("w") : pos_ += 1
      IF (spec->flags AND G_PARAM_CONSTRUCT) THEN _
        *pos_ = ASC("x") : pos_ += 1
      IF (spec->flags AND G_PARAM_CONSTRUCT_ONLY) THEN _
        *pos_ = ASC("X") : pos_ += 1
      *pos_ = 0

      nick = g_param_spec_get_nick (spec)
      blurb = g_param_spec_get_blurb (spec)

      dot = @""
      IF (blurb) THEN
        DIM AS size_t str_len
        str_len = strlen (blurb)
        IF (str_len > 0  ANDALSO blurb[str_len - 1] <> ASC(".")) THEN dot = @"."
      END IF

      type_desc = describe_type (spec)
      default_value = describe_default (spec)
      type_name = get_type_name (spec->value_type, @is_pointer)

      IF nick THEN _nick = nick ELSE _nick = @"(null)"
      IF blurb THEN _blurb = blurb ELSE _blurb = @"(null)"
      fprintf (fp, !"<ARG>\n<NAME>%s::%s</NAME>\n<TYPE>%s%s</TYPE>\n<RANGE>%s</RANGE>\n<FLAGS>%s</FLAGS>\n<NICK>%s</NICK>\n<BLURB>%s%s</BLURB>\n<DEFAULT>%s</DEFAULT>\n</ARG>\n\n", _
               object_class_name, g_param_spec_get_name (spec), type_name, *IIF(is_pointer, @"*", @""), type_desc, flags, _nick, _blurb, dot, default_value)
      g_free (type_desc)
      g_free (default_value)
    NEXT

?"Hier6a2"

    g_free (properties)

#IFDEF GTK_IS_CONTAINER_CLASS
    IF (0 = child_prop ANDALSO GTK_IS_CONTAINER_CLASS (class_)) THEN
      properties = gtk_container_class_list_child_properties (class_, @n_properties)
      child_prop = TRUE
      CONTINUE WHILE
    END IF
#ENDIF

#IFDEF GTK_IS_CELL_AREA_CLASS
    IF (0 = child_prop ANDALSO GTK_IS_CELL_AREA_CLASS (class_)) THEN
      properties = gtk_cell_area_class_list_cell_properties (class_, @n_properties)
      child_prop = TRUE
      CONTINUE WHILE
    END IF
#ENDIF

#IFDEF GTK_IS_WIDGET_CLASS
#IF GTK_CHECK_VERSION(2,1,0)
    IF (0 = style_prop ANDALSO GTK_IS_WIDGET_CLASS (class_)) THEN
      properties = gtk_widget_class_list_style_properties (GTK_WIDGET_CLASS (class_), @n_properties)
      style_prop = TRUE
      CONTINUE WHILE
    END IF
#ENDIF
#ENDIF

    EXIT WHILE 'break;
  WEND
END SUB
