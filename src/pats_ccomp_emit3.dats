(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi (gmhwxi AT gmail DOT com)
// Start Time: January, 2013
//
(* ****** ****** *)

staload ERR = "./pats_error.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_ccomp_emit2"

(* ****** ****** *)

staload "pats_basics.sats"

(* ****** ****** *)
//
staload
FIL = "./pats_filename.sats"
staload
LOC = "./pats_location.sats"
//
(* ****** ****** *)

staload SYN = "./pats_syntax.sats"

(* ****** ****** *)

staload
S2E = "./pats_staexp2.sats"
typedef d2con = $S2E.d2con

(* ****** ****** *)

staload
D2E = "./pats_dynexp2.sats"
typedef d2ecl = $D2E.d2ecl
typedef d2eclist = $D2E.d2eclist

(* ****** ****** *)

staload
TR2ENV = "./pats_trans2_env.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

implement
emit_saspdec
  (out, hid) = let
//
val loc0 = hid.hidecl_loc
val-HIDsaspdec (d2c) = hid.hidecl_node
//
val () = emit_text (out, "/*\n")
val () = emit_location (out, loc0)
val () = emit_text (out, "\n*/\n")
//
val () = emit_text (out, "ATSassume(")
val () = emit_s2cst (out, d2c.s2aspdec_cst)
val () = emit_text (out, ") ;\n")
//
in
  // nothing
end // end of [emit_saspdec]

(* ****** ****** *)

implement
emit_extcode
  (out, hid) = let
//
val loc0 = hid.hidecl_loc
val-HIDextcode (knd, pos, code) = hid.hidecl_node
//
val () = emit_text (out, "/*\n")
val () = emit_location (out, loc0)
val () = emit_text (out, "\n*/")
val () = emit_text (out, code)  
//
in
  // nothing
end // end of [emit_extcode]

(* ****** ****** *)

local

fun auxloc
(
  out: FILEref, loc: location
) : void = let
  val () = emit_text (out, "/*\n")
  val () = emit_location (out, loc)
  val () = emit_text (out, "\n*/\n")
in
  // nothing
end // end of [auxloc]

fun auxsta
(
  out: FILEref, d2cs: d2eclist
) : void = let
in
//
case+ d2cs of
| list_cons
    (d2c, d2cs) => let
    val () = (
    case+
      d2c.d2ecl_node of
    | $D2E.D2Cextcode
        (knd, pos, code) => let
        val () =
          auxloc (out, d2c.d2ecl_loc)
        // end of [val]
      in
        emit_text (out, code)
      end // end of [D2Cextcode]
    | $D2E.D2Cstaload
      (
        idopt, fil, flag, fenv, loaded
      ) => let
        val () =
          auxloc (out, d2c.d2ecl_loc)
        val d2cs =
          $TR2ENV.filenv_get_d2eclist (fenv)
        val issta =
          $FIL.filename_is_sats (fil)
      in
        if issta then auxsta (out, d2cs) else ()
      end // end of [D2Cstaload]
    | _ => ()
    ) : void // end of [val]
  in
    auxsta (out, d2cs)
  end // end of [list_cons]
| list_nil () => ()
//
end // end of [auxsta]

fun auxdyn (
  out: FILEref, d2cs: d2eclist
) : void = let
in
//
case+ d2cs of
| list_cons
    (d2c, d2cs) => let
    val (
    ) = (
    case+
      d2c.d2ecl_node of
    | $D2E.D2Cstaload
      (
        idopt, fil, flag, fenv, loaded
      ) => let
        val () =
          auxloc (out, d2c.d2ecl_loc)
        val d2cs =
          $TR2ENV.filenv_get_d2eclist (fenv)
        val issta =
          $FIL.filename_is_sats (fil)
      in
        if issta
          then auxsta (out, d2cs) else auxdyn (out, d2cs)
        // end of [if]
      end // end of [D2Cstaload]
    | $D2E.D2Clocal
      (
        d2cs_head, d2cs_body
      ) => let
        val () = auxdyn (out, d2cs_head)
        val () = auxdyn (out, d2cs_body) in (*nothing*)
      end // end of [D2Clocal]
    | _ => ()
    ) : void // end of [val]
  in
    auxdyn (out, d2cs)
  end // end of [list_cons]
| list_nil () => ()
//
end // end of [auxdyn]

in (* in of [local] *)

implement
emit_staload
  (out, hid) = let
//
val-HIDstaload
(
  fil, flag, fenv, loaded
) = hid.hidecl_node
(*
val () = 
  println! ("emit_staload: flag = ", flag)
*)
val d2cs = $TR2ENV.filenv_get_d2eclist (fenv)
//
val issta = $FIL.filename_is_sats (fil)
//
in
  if issta then auxsta (out, d2cs) else auxdyn (out, d2cs)
end // end of [emit_staload]

end // end of [local]

(* ****** ****** *)

extern
fun emit_patckont (out: FILEref, fail: patckont): void

implement
emit_patckont
  (out, fail) = let
in
//
case+ fail of
| PTCKNTnone () => {
    val () =
      emit_text
    (
      out, "ATSINSdeadcode_fail()"
    ) // end of [val]
  }
| PTCKNTtmplab (tlab) => {
    val () =
      emit_text (out, "ATSgoto(")
    // end of [val]
    val () = emit_tmplab (out, tlab)
    val () = emit_text (out, ")")
  }
| PTCKNTtmplabint (tlab, i) => {
    val () =
      emit_text (out, "ATSgoto(")
    // end of [val]
    val () = emit_tmplabint (out, tlab, i)
    val () = emit_text (out, ")")
  }
| PTCKNTcaseof_fail (loc) => {
    val () =
      emit_text
    (
      out, "ATSINScaseof_fail(\""
    ) // end of [val]
    val () = $LOC.fprint_location (out, loc)
    val () = emit_text (out, "\")")
  }
| PTCKNTfunarg_fail (loc, fl) => {
    val () =
      emit_text
    (
      out, "ATSINSfunarg_fail(\""
    ) // end of [val]
    val () = $LOC.fprint_location (out, loc)
    val () = emit_text (out, "\")")
  }
| PTCKNTraise (pmv_exn) => {
    val () =
      emit_text (out, "ATSraise_exn(")
    val () = emit_primval (out, pmv_exn)
    val () = emit_text (out, ")")
  }
//
end // (* end of [emit_patckont] *)

(* ****** ****** *)
//
// HX-2013-01:
//
// the kind of code duplication in the implementation
// of [emit_instr_patck] can be readily removed by using
// template system of ATS2.
//
//
local

fun auxcon
(
  out: FILEref
, pmv: primval, d2c: d2con, fail: patckont
) : void =let
//
val s2c = $S2E.d2con_get_scst (d2c)
//
in
//
case+ 0 of
| _ when
    $S2E.s2cst_is_singular (s2c) => ()
| _ when
    $S2E.s2cst_is_listlike (s2c) => let
    val islst = $S2E.s2cst_get_islst (s2c) 
    val isnil = (
      case+ islst of
      | Some xx =>
          $S2E.eq_d2con_d2con (d2c, xx.0)
      | None () => false (* deadcode *)
    ) : bool // end of [val]
    val () = emit_text (out, "if (")
    val () =
    (
      if (isnil)
        then emit_text (out, "ATSCKptriscons(")
        else emit_text (out, "ATSCKptrisnull(")
      // end of [if]
    ) : void // end of [val]
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  in
    // nothing
  end // end of [islistlike]
| _ => let
    val isnul =
      $S2E.d2con_is_nullary (d2c)
    // end of [val]
    val () = emit_text (out, "ATSifnot(")
    val () =
    (
      if isnul
        then emit_text (out, "ATSPATCKcon0(")
        else emit_text (out, "ATSPATCKcon1(")
    ) : void // end of [val]
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_int (out, $S2E.d2con_get_tag (d2c))
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  in
    // nothing
  end // end of [PATCKcon]
//
end // end of [auxcon]

fun auxexn
(
  out: FILEref
, pmv: primval, d2c: d2con, fail: patckont
) : void = let
//
val narg = $S2E.d2con_get_arity_real (d2c)
//
val () = emit_text (out, "ATSifnot(")
val () = (
  if narg = 0
    then emit_text (out, "ATSPATCKexn0(")
    else emit_text (out, "ATSPATCKexn1(")
  // end of [if]
) : void // end of [val]
val () = emit_primval (out, pmv)
val () = emit_text (out, ", ")
val () = emit_d2con (out, d2c);
val () = emit_text (out, ")) { ")
val () = emit_patckont (out, fail)
val () = emit_text (out, " ; }")
//
in
  // nothing
end // end of [auxexn]

fun auxmain (
  out: FILEref
, pmv: primval, patck: patck, fail: patckont
) : void = let
in
//
case+ patck of
| PATCKint (i) => {
    val () = emit_text (out, "ATSifnot(")
    val () = emit_text (out, "ATSPACKint(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVint (out, i)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  } // end of [PATCKint]
| PATCKbool (b) => {
    val () = emit_text (out, "ATSifnot(")
    val () = emit_text (out, "ATSPACKbool(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVbool (out, b)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  } // end of [PATCKbool]
| PATCKchar (c) => {
    val () = emit_text (out, "ATSifnot(")
    val () = emit_text (out, "ATSPACKchar(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVchar (out, c)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  } // end of [PATCKchar]
| PATCKstring (str) => {
    val () = emit_text (out, "ATSifnot(")
    val () = emit_text (out, "ATSPACKstring(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVstring (out, str)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  } // end of [PATCKstring]
| PATCKi0nt (tok) => {
    val () = emit_text (out, "ATSifnot(")
    val () = emit_text (out, "ATSPACKint(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVi0nt (out, tok)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  } // end of [PATCKi0nt]
| PATCKf0loat (tok) => {
    val () = emit_text (out, "ATSifnot(")
    val () = emit_text (out, "ATSPACKfloat(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVf0loat (out, tok)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; }")
  } // end of [PATCKf0loat]
//
| PATCKcon (d2c) => auxcon (out, pmv, d2c, fail)
| PATCKexn (d2c) => auxexn (out, pmv, d2c, fail)
//
(*
| _ => let
    val () = prerr_interror ()
    val () = prerrln! (": emit_instr_patck: patck = ", patck)
    val () = assertloc (false)
  in
    $ERR.abort ()
  end // end of [_]
*)
//
end (* end of [auxmain] *)

in (* in of [local] *)

implement
emit_instr_patck
  (out, ins) = let
//
val-INSpatck
  (pmv, patck, fail) = ins.instr_node
val isnone = patckont_is_none (fail)
val () =
  if isnone then emit_text (out, "#if(0)\n")
val () = auxmain (out, pmv, patck, fail)
val () =
  if isnone then emit_text (out, "\n#endif")
//
in
  // nothing
end // end of [emit_instr_patck]

end // end of [local]

(* ****** ****** *)

local

fun auxfun
(
  out: FILEref, fent: funent
) : void = let
//
val flab = funent_get_lab (fent)
val istmp = (funlab_get_tmpknd (flab) > 0)
//
val qopt = funlab_get_d2copt (flab)
val isqua =
(
  case+ qopt of Some (d2c) => true | None () => false
) : bool // end of [val]
val isext =
(
case+ qopt of
| Some (d2c) =>
    if $D2E.d2cst_is_static (d2c) then false else true
| None _ => false
) : bool // end of [val]
//
val flopt = funlab_get_origin (flab)
val isqua =
(
  case+ flopt of Some _ => false | None () => isqua
) : bool // end of [val]
val isext =
(
  case+ flopt of Some _ => false | None () => isext
) : bool // end of [val]
val issta = not (isext)
//
val () = if istmp then emit_text (out, "#if(0)\n")
val () = if isqua then emit_text (out, "#if(0)\n")
val () = if isext then emit_text (out, "ATSglobaldec()\n")
val () = if issta then emit_text (out, "ATSstaticdec()\n")
//
val hse_res = funlab_get_type_res (flab)
val hses_arg = funlab_get_type_fullarg (flab)
//
val (
) = emit_hisexp (out, hse_res)
val () = emit_text (out, "\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "(")
val (
) = emit_hisexplst_sep (out, hses_arg, ", ")
val () = emit_text (out, ") ;\n")
//
val () =
  if isqua then emit_text (out, "#endif // end of [QUALIFIED]\n")
//
val () =
  if istmp then emit_text (out, "#endif // end of [TEMPLATE]\n")
//
in
  // nothing
end // end of [auxfun]

in (* in of [local] *)

implement
emit_funent_ptype
  (out, fent) = let
//
val () = auxfun (out, fent)
//
val () = emit_newline (out)
//
in
  // nothing
end // end of [emit_funentry_ptype]

end // end of [local]

(* ****** ****** *)

local

fun aux1_arglst
(
  out: FILEref
, hses: hisexplst, n0: int, i: int
) : void = let
in
//
case+ hses of
| list_cons
    (hse, hses) => let
    val () = if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " arg"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux1_arglst (out, hses, n0, i+1)
  end // end of [list_cons]
| list_nil () => ()
//
end (* end of [aux1_arglst] *)

fun aux2_arglst
(
  out: FILEref
, hses: hisexplst, n0: int, i: int
) : void = let
in
//
case+ hses of
| list_cons
    (hse, hses) => let
    val () =
      if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_text (out, "arg"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux2_arglst (out, hses, n0, i+1)
  end // end of [list_cons]
| list_nil () => ()  
//
end (* end of [aux2_arglst] *)

fun aux1_envlst
(
  out: FILEref, d2es: d2envlst, i: int
) : void = let
in
//
case+ d2es of
| list_cons
    (d2e, d2es) => let
    val hse = d2env_get_type (d2e)
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " env"); emit_int (out, i)
    )
    val () = emit_text (out, " ;\n")
  in
    aux1_envlst (out, d2es, i+1)
  end // end of [list_cons]
| list_nil () => ()
//
end (* end of [aux1_envlst] *)

fun aux2_envlst
(
  out: FILEref, d2es: d2envlst, n0: int, i: int
) : int = let
in
//
case+ d2es of
| list_cons
    (d2e, d2es) => let
    val hse = d2env_get_type (d2e)
    val () = if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " env"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux2_envlst (out, d2es, n0, i+1)
  end // end of [list_cons]
| list_nil () => (n0+i)
//
end (* end of [aux2_envlst] *)

fun aux3_envlst
(
  out: FILEref, d2es: d2envlst, n0: int, i: int
) : int = let
in
//
case+ d2es of
| list_cons
    (d2e, d2es) => let
    val () =
      if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_text (out, "env"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux3_envlst (out, d2es, n0, i+1)
  end // end of [list_cons]
| list_nil () => (n0+i)
//
end (* end of [aux3_envlst] *)

fun aux4_envlst
(
  out: FILEref, d2es: d2envlst, n0: int, i: int
) : int = let
in
//
case+ d2es of
| list_cons
    (d2e, d2es) => let
    val () = if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_text (out, "p_cenv->env"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux4_envlst (out, d2es, n0, i+1)
  end // end of [list_cons]
| list_nil () => (i)
//
end (* end of [aux4_envlst] *)

fun aux5_envlst
(
  out: FILEref, d2es: d2envlst, i: int
) : void = let
in
//
case+ d2es of
| list_cons
    (d2e, d2es) => let
    val hse = d2env_get_type (d2e)
    val () =
    (
      emit_text (out, "p_cenv->env"); emit_int (out, i)
    ) : void // end of [val]
    val () =
    (
      emit_text (out, " = "); emit_text (out, "env"); emit_int (out, i)
    ) : void // end of [val]
    val () = emit_text (out, " ;\n")
  in
    aux5_envlst (out, d2es, i+1)
  end // end of [list_cons]
| list_nil () => ()
//
end (* end of [aux5_envlst] *)

fun auxclo_type
(
  out: FILEref, flab: funlab, d2es: d2envlst
) : void = let
//
val () = emit_text (out, "typedef struct")
val () = emit_text (out, "\n{\n")
val () = emit_text (out, "atstype_funptr cfun ;\n")
val () = aux1_envlst (out, d2es, 0)
val () = emit_text (out, "} ")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$closure_t0ype ;\n")
//
in
  // nothing
end (* end of [auxclo_type] *)

fun auxclo_cfun
(
  out: FILEref, flab: funlab, d2es: d2envlst
) : void = let
//
val hse_res = funlab_get_type_res (flab)
val hses_arg = funlab_get_type_arg (flab)
//
val () = emit_text (out, "ATSstaticdec()\n")
val () = emit_hisexp (out, hse_res)
val () = emit_text (out, "\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$cfun")
val () = emit_text (out, "\n(\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$closure_t0ype *p_cenv")
val () = aux1_arglst (out, hses_arg, 1, 0)
val () = emit_text (out, "\n)\n{\n")
val () = emit_text (out, "return ")
val () = emit_funlab (out, flab)
val () = emit_text (out, "(")
val n0 = aux4_envlst (out, d2es, 0, 0)
val () = aux2_arglst (out, hses_arg, n0, 0)
val () = emit_text (out, ") ;\n")
val () = emit_text (out, "} /* end of [cfun] */\n")
//
in
  // nothing
end (* end of [auxclo_cfun] *)

fun auxclo_init
(
  out: FILEref, flab: funlab, d2es: d2envlst
) : void = let
//
val () = emit_text (out, "ATSstaticdec()\n")
val () = emit_text (out, "atstype_cloptr\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$closureinit")
val () = emit_text (out, "\n(\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$closure_t0ype *p_cenv")
val n0 = aux2_envlst (out, d2es, 1, 0)
val () = emit_text (out, "\n)\n{\n")
val () = aux5_envlst (out, d2es, 0)
val () = emit_text (out, "p_cenv->cfun = ")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$cfun ;\n")
val () = emit_text (out, "return p_cenv ;\n")
val () = emit_text (out, "} /* end of [closureinit] */\n")
//
in
  // nothing
end (* end of [auxclo_init] *)

fun auxclo_create
(
  out: FILEref, flab: funlab, d2es: d2envlst
) : void = let
//
val () = emit_text (out, "ATSstaticdec()\n")
val () = emit_text (out, "atstype_cloptr\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$closurerize")
val () = emit_text (out, "\n(\n")
val n0 = aux2_envlst (out, d2es, 0, 0)
val () = emit_text (out, "\n)\n{\n")
val () = emit_text (out, "return ")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$closureinit(")
val () = emit_text (out, "ATS_MALLOC(sizeof(")
val () = emit_funlab (out, flab)
val () = emit_text (out, "$closure_t0ype))")
val n0 = aux3_envlst (out, d2es, 1, 0)
val () = emit_text (out, ") ;\n")
val () = emit_text (out, "} /* end of [closurerize] */\n")
//
in
  // nothing
end (* end of [auxclo_create] *)

in (* in of [local] *)

implement
emit_funent_closure
  (out, fent) = let
//
val flab = funent_get_lab (fent)
val d2es = funent_eval_d2envlst (fent)
//
val () = auxclo_type (out, flab, d2es)
val () = auxclo_cfun (out, flab, d2es)
val () = auxclo_init (out, flab, d2es)
val () = auxclo_create (out, flab, d2es)
//
val () = emit_newline (out)
//
in
  // nothing
end // end of [emit_funent_closure]

end // end of [local]

(* ****** ****** *)

local

fun auxtmp
(
  out: FILEref, fent: funent
) : void = let
//
val imparg = funent_get_imparg (fent)
val tmparg = funent_get_tmparg (fent)
val tsubopt = funent_get_tmpsub (fent)
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "imparg = ")
val () = $S2E.fprint_s2varlst (out, imparg)
val () = emit_text (out, "\n")
val () = emit_text (out, "tmparg = ")
val () = $S2E.fprint_s2explstlst (out, tmparg)
val () = emit_text (out, "\n")
val () = emit_text (out, "tmpsub = ")
val () = fprint_tmpsubopt (out, tsubopt)
val () = emit_text (out, "\n")
val () = emit_text (out, "*/\n")
//
in
  // nothing
end // end of [auxtmp]

in // in of [local]

implement
emit_funent_implmnt
  (out, fent) = let
//
val loc0 = funent_get_loc (fent)
val flab = funent_get_lab (fent)
val d2es = funent_eval_d2envlst (fent)
//
val () = emit_text (out, "/*\n")
val () = $LOC.fprint_location (out, loc0)
val () = emit_text (out, "\n*/\n")
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "local: ")
val lfls0 = funent_get_flablst (fent)
val () = fprint_funlablst (out, lfls0)
val () = emit_newline (out)
val () = emit_text (out, "global: ")
val gfls0 = funent_eval_flablst (fent)
val () = fprint_funlablst (out, gfls0)
val () = emit_newline (out)
//
val () = emit_text (out, "local: ")
val ld2es = funent_eval_d2envlst (fent)
val () = fprint_d2envlst (out, ld2es)
val () = emit_newline (out)
val () = emit_text (out, "global: ")
val gd2es = funent_eval_d2envlst (fent)
val () = fprint_d2envlst (out, gd2es)
val () = emit_newline (out)
//
val () = emit_text (out, "*/\n")
//
val hse_res = funlab_get_type_res (flab)
val hses_arg = funlab_get_type_arg (flab)
//
val tmpret = funent_get_tmpret (fent)
//
// function header
//
val qopt = funlab_get_d2copt (flab)
val isext =
(
case+ qopt of
| Some (d2c) =>
    if $D2E.d2cst_is_static (d2c) then false else true
| None _ => false
) : bool // end of [val]
val flopt = funlab_get_origin (flab)
val isext =
(
  case+ flopt of Some (d2c) => false | None () => isext
) : bool // end of [val]
val issta = not (isext)
//
val () =
  if isext then emit_text (out, "ATSglobaldec()\n")
val () =
  if issta then emit_text (out, "ATSstaticdec()\n")
//
val istmp = funent_is_tmplt (fent)
val () = if istmp then auxtmp (out, fent)
//
val () = emit_hisexp (out, hse_res)
val () = emit_text (out, "\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "(")
val nenv = emit_funenvlst (out, d2es)
val () = emit_funarglst (out, nenv, hses_arg)
val () = emit_text (out, ")\n")
//
val () = funent_varbindmap_initize (fent)
//
// function body
//
val () = emit_text (out, "{\n")
val tmplst = funent_get_tmpvarlst (fent)
val () = emit_text (out, "/* tmpvardeclst(beg) */\n")
val () = emit_tmpdeclst (out, tmplst)
val () = emit_text (out, "/* tmpvardeclst(end) */\n")
val () = emit_text (out, "/* funbodyinstrlst(beg) */\n")
val body_inss = funent_get_instrlst (fent)
val () = emit_instrlst (out, body_inss)
val () = emit_text (out, "\n")
val () = emit_text (out, "/* funbodyinstrlst(end) */\n")
//
// function return
//
val isvoid = tmpvar_is_void (tmpret)
val () = (
  if ~isvoid
    then emit_text(out, "ATSreturn(")
    else emit_text(out, "ATSreturn_void(")
  // end of [if]
) : void // end of [val]
//
val () = emit_tmpvar (out, tmpret)
val () = emit_text (out, ") ;")
//
val () = emit_text (out, "\n}")
val () =
  emit_text (out, " /* end of [")
val () = emit_funlab (out, flab)
val () = emit_text (out, "] */\n")
//
val () = funent_varbindmap_uninitize (fent)
//
in
end // end of [emit_funent_implmnt]

end // end of [local]

(* ****** ****** *)

local

staload UN = "prelude/SATS/unsafe.sats"

fun emit_primdec
  (out: FILEref, pmd: primdec) : void = let
in
//
case+ pmd.primdec_node of
//
| PMDnone () => ()
//
| PMDlist (pmds) => emit_primdeclst (out, pmds)
//
| PMDsaspdec _ => ()
//
| PMDdatdecs _ => ()
| PMDexndecs _ => ()
//
| PMDfundecs _ => ()
//
| PMDvaldecs
    (knd, hvds, inss) =>
    emit_instrlst_ln (out, $UN.cast{instrlst}(inss))
| PMDvaldecs_rec (knd, hvds, inss) =>
    emit_instrlst_ln (out, $UN.cast{instrlst}(inss))
//
| PMDvardecs (hvds, inss) =>
    emit_instrlst_ln (out, $UN.cast{instrlst}(inss))
//
| PMDimpdec _ => ()
//
| PMDinclude (pmds) => emit_primdeclst (out, pmds)
//
| PMDstaload _ => ()
//
| PMDlocal (
    pmds_head, pmds_body
  ) => {
    val () =
      emit_text (out, "/* local */\n")
    val () = emit_primdeclst (out, pmds_head)
    val () =
      emit_text (out, "/* in of [local] */\n")
    val () = emit_primdeclst (out, pmds_body)
    val () =
      emit_text (out, "/* end of [local] */\n")
    // end of [val]
  } // end of [PMDlocal]
//
end // end of [emit_primdec]

in // in of [local]

implement
emit_primdeclst
  (out, pmds) = let
in
//
case+ pmds of
| list_cons
    (pmd, pmds) => let
    val () =
      emit_primdec (out, pmd) in emit_primdeclst (out, pmds)
    // end of [val]
  end // end of [list_cons]
| list_nil () => ()
//
end // end of [emit_primdeclst]

end // end of [local]

(* ****** ****** *)

implement
emit_d2cst_exdec
  (out, d2c) = let
//
macdef
ismac = $D2E.d2cst_is_mac
macdef
isfun = $D2E.d2cst_is_fun
//
macdef
iscastfn = $D2E.d2cst_is_castfn
//
in
//
case+ 0 of
| _ when
    ismac (d2c) => let
    val () = emit_text (out, "ATSdyncst_mac(")
    val () = emit_d2cst (out, d2c)
    val () = emit_text (out, ") ;\n")
  in
    // nothing
  end // end of [ismac]
| _ when
    isfun (d2c) => let
    val issta = $D2E.d2cst_is_static (d2c)
    val () =
    (
      if issta then
        emit_text (out, "ATSdyncst_stafun(")
      else
        emit_text (out, "ATSdyncst_extfun(")
      // end of [if]
    ) : void // end of [val]
//
    val () = emit_d2cst (out, d2c)
    val () =
    {
      val () = emit_text (out, ", (")
      val hses = d2cst_get2_type_arg (d2c)
      val () = emit_hisexplst_sep (out, hses, ", ")
      val () = emit_text (out, "), ")
    } // end of [val]
//
    val () = let
      val hse =
        d2cst_get2_type_res (d2c) in emit_hisexp (out, hse)
      // end of [val]
    end // end of [val]
//
    val () = emit_text (out, ") ;\n")
//
  in
    // nothing
  end // end of [isfun]
//
| _ when
    iscastfn (d2c) => let
    val () = emit_text (out, "ATSdyncst_castfn(")
    val () = emit_d2cst (out, d2c)
    val () = emit_text (out, ") ;\n")
  in
    // nothing
  end // end of [castfn]
| _ => let
    val () = emit_text (out, "ATSdyncst_unknown(")
    val () = emit_d2cst (out, d2c)
    val () = emit_text (out, ") ;\n")
  in
    // nothing
  end // end of [_]
//
end // end of [emit_d2cst_exdec]

implement
emit_d2cstlst_exdec
  (out, d2cs) = let
in
//
case+ d2cs of
| list_cons
    (d2c, d2cs) => let
    val () =
      emit_d2cst_exdec (out, d2c)
    // end of [val]
  in
    emit_d2cstlst_exdec (out, d2cs)
  end // end of [list_cons]
| list_nil () => ()
//
end // end of [emit_d2cstlst_exdec]

(* ****** ****** *)

(* end of [pats_ccomp_emit3.dats] *)