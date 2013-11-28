(*
** Parsing: ATS -> UTFPL
*)

(* ****** ****** *)
//
#include
"share/atspre_define.hats"
//
(* ****** ****** *)
//
staload "./../utfpl.sats"
//
(* ****** ****** *)

staload "{$JSONC}/SATS/json_ML.sats"

(* ****** ****** *)

staload "./parsing.sats"
staload "./parsing.dats"

(* ****** ****** *)

extern
fun parse_p2at_node (jsv: jsonval): p2at_node

(* ****** ****** *)

implement
parse_p2at
  (jsv0) = let
//
val-~Some_vt(jsv) =
  jsonval_get_field (jsv0, "p2at_loc") 
val-JSONstring(loc) = jsv
val loc = location_make (loc)
val-~Some_vt(jsv) =
  jsonval_get_field (jsv0, "p2at_node") 
val node = parse_p2at_node (jsv)
//
in
  p2at_make_node (loc, node)
end // end of [parse_p2at]

(* ****** ****** *)

extern
fun parse_P2Tvar (jsonval): p2at_node

extern
fun parse_P2Terr (jsonval): p2at_node

(* ****** ****** *)

implement
parse_p2at_node
  (jsv0) = let
//
val-~Some_vt(jsv1) =
  jsonval_get_field (jsv0, "d2exp_name")
val-~Some_vt(jsv2) =
  jsonval_get_field (jsv0, "d2exp_arglst")
//
val-JSONstring(name) = jsv1
//
in
//
case+ name of
| "P2Tvar" => parse_P2Tvar (jsv2)
| _(*rest*) => parse_P2Terr (jsv2)
//
end // end of [parse_p2at_node]

(* ****** ****** *)

implement
parse_P2Tvar (jsv2) = let
//
val-JSONarray(A, n) = jsv2
val () = assertloc (n >= 1)
val d2v = parse_d2var (A[0])
//
in
  P2Tvar (d2v)
end // end of [parse_P2Tvar]

(* ****** ****** *)

implement
parse_P2Terr (jsv) = P2Terr ((*void*))

(* ****** ****** *)

(* end of [parsing_p2at.dats] *)
