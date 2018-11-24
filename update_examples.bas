CONST TMP = "TMP", _
      EXA = "example_", _
     COM1 = "fbc -w all -exx " & TMP & ".bas", _
     COM2 = "LD_LIBRARY_PATH=""../src"" ./" & TMP

TYPE LstUdt
  AS STRING Nam, Cor, Txt
  AS INTEGER Done
END TYPE

CHDIR ("examples")
REDIM SHARED AS LstUdt LST(-1 TO -1)
REDIM SHARED AS STRING XML(0)
DIM SHARED AS STRING PRE, PST



FUNCTION get_file(BYREF N AS STRING) AS STRING
  VAR fnr = FREEFILE
  IF OPEN(N FOR INPUT AS fnr) THEN ?"Cannot read " & N : RETURN ""
  VAR r = STRING(LOF(fnr), 0)
  IF GET (fnr, , r) THEN ?"Error reading data from " & N : r = ""
  CLOSE #fnr
  RETURN r
END FUNCTION

SUB prepare_xml()
  VAR t = get_file("make.xml")
  VAR i = UBOUND(XML), a = 1, s = "<!--_V_-->", p = INSTR(t, s)
  WHILE p
    XML(i) = MID(t, a, p - a)
    i += 1
    REDIM PRESERVE XML(i)
    a = p + LEN(s)
    p = INSTR(a, t, s)
  WEND
  XML(i) = MID(t, a)
END SUB

SUB out_entry(BYVAL I AS INTEGER, BYVAL fnr_e AS INTEGER, BYVAL fnr_g AS INTEGER)
  STATIC AS STRING*2 NL = !"\n"
  WITH LST(I)
    IF .Done THEN EXIT SUB
    PRINT #fnr_e, _
"        <link linkend=""goodata-" & .Cor & "-example"">" & .Txt & "</link>" & NL & _
"<xi:include href=""" & .Nam & ".xml"" xmlns:xi=""http://www.w3.org/2001/XInclude""/>" & NL & _
"      </para></listitem><listitem><para>"

    PRINT #fnr_g, _
"        <link linkend=""goodata-" & .Cor & "-example"">" & NL & _
"          <inlinemediaobject>" & NL & _
"            <imageobject>" & NL & _
"              <imagedata fileref=""img/t_" & .Nam & ".png"" format=""PNG""/>" & NL & _
"            </imageobject>" & NL & _
"            <textobject>" & NL & _
"              <phrase>" & .Txt & "</phrase>" & NL & _
"            </textobject>" & NL & _
"          </inlinemediaobject>" & NL & _
"        </link>"

    .Done = 1
  END WITH
END SUB

SUB out_lists()
  'VAR NL = !"\n" '', s = "simcurbarboxpie", l = 3

  VAR n = "example.lst"
  VAR fnr_e = FREEFILE
  IF OPEN(n FOR OUTPUT AS fnr_e) THEN ?"Cannot write " & n : EXIT SUB

  n = "gallery.lst"
  VAR fnr_g = FREEFILE
  IF OPEN(n FOR OUTPUT AS fnr_g) THEN CLOSE #fnr_e : ?"Cannot write " & n : EXIT SUB

  n = "order.lst"
  VAR x = "", fnr_o = FREEFILE
  IF OPEN(n FOR INPUT AS fnr_o) THEN
    ?"Cannot read " & n
  ELSE
    WHILE NOT EOF(fnr_o)
      LINE INPUT #fnr_o, x
      SELECT CASE x
      CASE "" : PRINT #fnr_e, "" : PRINT #fnr_g, ""
      CASE ELSE 
        FOR i AS INTEGER = 0 TO UBOUND(LST)
          IF x = LST(i).Nam THEN out_entry(i, fnr_e, fnr_g) : EXIT SELECT
        NEXT
        ?"Datei nicht vorhanden: " & x
      END SELECT
    WEND
    CLOSE #fnr_o
  END IF

  x = ""
  FOR i AS INTEGER = 0 TO UBOUND(LST)
    IF 0 = LST(i).Done THEN out_entry(i, fnr_e, fnr_g) : x &= MKI(i)
  NEXT
  CLOSE #fnr_g
  CLOSE #fnr_e
  ?"Lst files created!"

  IF 0 = LEN(x) THEN EXIT SUB

  fnr_o = FREEFILE
  IF OPEN(n FOR APPEND AS fnr_o) THEN ?"Cannot append " & n : EXIT SUB
  PRINT #fnr_o, ""
  FOR i AS INTEGER = 1 TO LEN(x) STEP 4
    PRINT #fnr_o, LST(CVI(MID(x, i, 4))).Nam
  NEXT
  CLOSE #fnr_o
  ?n & " file appended!"

END SUB

SUB add_lst(BYREF N AS STRING, BYREF B AS STRING, BYREF T AS STRING)
  VAR i = UBOUND(LST) + 1
  REDIM PRESERVE LST(i)
  LST(i).Nam = N
  LST(i).Cor = B
  LST(i).Txt = T
END SUB

FUNCTION create_bas(BYREF N AS STRING) AS INTEGER
  VAR bas = get_file(N), p = 0, a = 0, i = 0
  DIM AS STRING t(3)
  DO
    SELECT CASE AS CONST bas[p]
    CASE 0 : ?"Error reading comments!" : RETURN 1
    CASE ASC(!"\n")
      t(i) = LTRIM(MID(bas, a + 1, p - a), ANY !" \t'")
      a = p + 1
      i += 1 : IF i > UBOUND(t) THEN EXIT DO
    END SELECT
    p += 1
  LOOP

  VAR n_out = "../doc/MyXml/" & N, fnr = FREEFILE
  IF OPEN(n_out FOR OUTPUT AS fnr) THEN ?"Cannot write " & n_out : RETURN 1
  PRINT #fnr, "'~ This is file " & N
  PRINT #fnr, "'~ Example source code for GooData graphic library."
  PRINT #fnr, "'"
  PRINT #fnr, "'~ Licence: GPLv3"
  PRINT #fnr, "'~ (C) 2012 Thomas[ dot ]Freiherr[ at ]gmx[ dot ]net"
  PRINT #fnr, ""
  PRINT #fnr, MID(bas, a + 1);
  CLOSE #fnr
  ?"  Bas created!"

  VAR basename = LEFT(N, INSTRREV(N, ".") - 1)
  VAR corename = MID(basename, LEN(EXA) + 1)

  n_out = "../doc/MyXml/" & N & ".xml"
  fnr = FREEFILE
  IF OPEN(n_out FOR OUTPUT AS fnr) THEN ?"Cannot write " & n_out : RETURN 1
  FOR i AS INTEGER = 0 TO UBOUND(XML)
    PRINT #fnr, XML(i);
    SELECT CASE AS CONST i
    CASE 0 : PRINT #fnr, corename; ''     id for example
    CASE 1 : PRINT #fnr, t(0);
    CASE 2 : PRINT #fnr, t(1);
    CASE 3 : PRINT #fnr, N; ''              name for PNG
    CASE 4 : PRINT #fnr, t(2);
    CASE 5 : PRINT #fnr, t(3);
    CASE 6 : PRINT #fnr, corename; '' id for source code
    CASE 7 : PRINT #fnr, N; ''   name for programlisting
    CASE ELSE : IF i <> UBOUND(XML) THEN PRINT #fnr, "??? " & i & " ???";
    END SELECT
  NEXT
  CLOSE #fnr
  ?"  XML created!"

  add_lst(N, corename, t(0))

  RETURN 0
END FUNCTION

FUNCTION create_source(BYREF N AS STRING) AS INTEGER
  VAR n_out = TMP & ".bas", fnr = FREEFILE
  IF OPEN(n_out FOR OUTPUT AS fnr) THEN ?"Cannot write " & n_out : RETURN 1
  PRINT #fnr, PRE;
  PRINT #fnr, ""
  PRINT #fnr, "#INCLUDE ONCE """ & N & """"
  PRINT #fnr, "VAR fname = """ & N & """"
  PRINT #fnr, "VAR rand = 5.0"
  PRINT #fnr, "VAR thumb = 180"
  PRINT #fnr, "CHDIR ""../doc/html/img"""
  PRINT #fnr, ""
  PRINT #fnr, PST;
  CLOSE #fnr

  IF SHELL(COM1) THEN ?"Error compiling """ & N & """" : RETURN 1
  ?"  Compiled!"
  IF SHELL(COM2) THEN ?"Error executing """ & N & """" : RETURN 1
  ?"  Png generated!"
  RETURN 0
END FUNCTION


' main

prepare_xml()
PRE = get_file("make1.bas") : IF 0 = LEN(PRE) THEN END 1
PST = get_file("make2.bas") : IF 0 = LEN(PST) THEN END 1

VAR fname = ""
IF LEN(COMMAND) THEN fname = DIR(COMMAND) ELSE fname = DIR(EXA & "*.bas")

WHILE LEN(fname)
  ?fname
  IF create_bas(fname) THEN EXIT WHILE
  IF create_source(fname) THEN EXIT WHILE

'EXIT WHILE '' for testing

  fname = DIR()
WEND
KILL(TMP & ".bas")
KILL(TMP)

IF 0 = LEN(COMMAND) THEN out_lists()
