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
// Start Time: May, 2011
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload _(*anon*) = "prelude/DATS/list_vt.dats"
staload _(*anon*) = "prelude/DATS/reference.dats"

(* ****** ****** *)

staload UT = "pats_utils.sats"

(* ****** ****** *)

staload LOC = "pats_location.sats"
macdef location_combine = $LOC.location_combine

(* ****** ****** *)

staload LEX = "pats_lexing.sats"

(* ****** ****** *)

staload "pats_staexp2.sats"
staload "pats_dynexp2.sats"

(* ****** ****** *)

#include "pats_basics.hats"

(* ****** ****** *)

#define l2l list_of_list_vt
macdef list_sing (x) = list_cons (,(x), list_nil)

(* ****** ****** *)

implement
d2sym_make (
  loc, q, id, d2pis
) = '{
  d2sym_loc= loc
, d2sym_qua= q, d2sym_sym= id
, d2sym_pitmlst= d2pis
} // end of [d2sym_make]

(* ****** ****** *)
//
// HX: dynamic patterns
//
(* ****** ****** *)

typedef s2varset = $UT.lstord (s2var)

val p2at_svs_nil : lstord (s2var) = $UT.lstord_nil ()
val p2at_dvs_nil : lstord (d2var) = $UT.lstord_nil ()

fun p2at_svs_add_svar (
  svs: s2varset, s2v: s2var
) : s2varset = let
in
  $UT.lstord_insert (svs, s2v, compare_s2vsym_s2vsym)
end // end of [p2at_svs_add_svar]

fun p2at_svs_add_svarlst (
  svs: s2varset, s2vs: s2varlst
) : s2varset = let
  typedef svs = lstord (s2var)
in
  list_fold_left_fun<svs><s2var> (p2at_svs_add_svar, svs, s2vs)
end // end of [p2at_svs_add_svarlst]

implement
p2atlst_svs_union (p2ts) = let
  typedef svs = lstord (s2var)
  val cmp = compare_s2vsym_s2vsym
in
  list_fold_left_fun<svs><p2at> (
    lam (svs, p2t) =<1> $UT.lstord_union (svs, p2t.p2at_svs, cmp), p2at_svs_nil, p2ts
  ) // end of [list_fold_left]
end // end of [p2atlst_svs_union]

implement
p2atlst_dvs_union (p2ts) = let
  typedef dvs = lstord (d2var)
  val cmp = compare_d2vsym_d2vsym
in
  list_fold_left_fun<dvs><p2at> (
    lam (dvs, p2t) =<1> $UT.lstord_union (dvs, p2t.p2at_dvs, cmp), p2at_dvs_nil, p2ts
  ) // end of [list_fold_left]
end // end of [p2atlst_dvs_union]

(* ****** ****** *)

implement
eq_pckind_pckind
  (x1, x2) = (
  case+ (x1, x2) of
  | (PCKcon (), PCKcon ()) => true
  | (PCKunfold (), PCKunfold ()) => true
  | (PCKfree (), PCKfree ()) => true
  | (PCKnonlin (), PCKnonlin ()) => true
  | (_, _) => false
) // end of [eq_pckind_pckind]

(* ****** ****** *)

implement
p2at_make_node (
  loc, svs, dvs, node
) = '{
  p2at_loc= loc
, p2at_svs= svs, p2at_dvs= dvs
, p2at_type= None () // s2hnfopt
, p2at_node= node
} // end of [p2at_make_node]

implement
p2at_any (loc) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tany ())
// end of [p2at_any]

implement
p2at_var
  (loc, refknd, d2v) = let
  val dvs = $UT.lstord_sing (d2v)
in
  p2at_make_node (loc, p2at_svs_nil, dvs, P2Tvar (refknd, d2v))
end // end of [p2at_var]

(* ****** ****** *)

implement
p2at_int (loc, i) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tint (i))
// end of [p2at_int]

implement
p2at_intrep (loc, rep) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tintrep (rep))
// end of [p2at_int]

implement
p2at_bool (loc, b) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tbool (b))
// end of [p2at_bool]

implement
p2at_char (loc, c) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tchar (c))
// end of [p2at_char]

implement
p2at_string (loc, str) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tstring (str))
// end of [p2at_string]

implement
p2at_float (loc, rep) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tfloat (rep))
// end of [p2at_float]

(* ****** ****** *)

implement
p2at_i0nt (loc, x) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Ti0nt (x))
// end of [p2at_i0nt]

implement
p2at_f0loat (loc, x) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tf0loat (x))
// end of [p2at_f0loat]

(* ****** ****** *)

implement
p2at_empty (loc) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Tempty ())
// end of [p2at_empty]

(* ****** ****** *)

implement
p2at_con (
  loc, pck // '~' and '@'
, d2c, s2qs, s2f, npf, darg
) = let
  val svs = p2atlst_svs_union (darg)
  val svs = let
    fn f (
      res: s2varset, x: s2qua
    ) : s2varset =
      p2at_svs_add_svarlst (res, x.s2qua_svs)
    // end of [f]
  in
    list_fold_left_fun<s2varset><s2qua> (f, svs, s2qs)
  end // end of [val]
  val dvs = p2atlst_dvs_union (darg)
  val node = P2Tcon (pck, d2c, s2qs, s2f, npf, darg)
in
  p2at_make_node (loc, svs, dvs, node)
end // end of [p2at_con]

(* ****** ****** *)

implement
p2at_list
  (loc, npf, p2ts) = let
  val svs = p2atlst_svs_union (p2ts)
  val dvs = p2atlst_dvs_union (p2ts)
in
  p2at_make_node (loc, svs, dvs, P2Tlist (npf, p2ts))
end // end of [p2at_list]

(* ****** ****** *)

implement
p2at_rec
  (loc, knd, npf, lp2ts) = let
  val p2ts = aux (lp2ts) where {
    fun aux (
      xs: labp2atlst
    ) : List_vt (p2at) = case+ xs of
      | list_cons (x, xs) => (case+ x of 
        | LABP2ATnorm (l0, p2t) => list_vt_cons (p2t, aux xs)
        | LABP2ATomit (loc) => aux (xs)
        ) // end of [list_cons]
      | list_nil () => list_vt_nil ()
    // end of [aux]
  } // end of [val]
  val svs = p2atlst_svs_union ($UN.castvwtp1(p2ts))
  val dvs = p2atlst_dvs_union ($UN.castvwtp1(p2ts))
  val () = list_vt_free (p2ts)
in
  p2at_make_node (loc, svs, dvs, P2Trec (knd, npf, lp2ts))
end // end of [p2at_lp2ts]

(* ****** ****** *)

implement
p2at_lst (loc, lin, p2ts) = let
  val svs = p2atlst_svs_union (p2ts)
  val dvs = p2atlst_dvs_union (p2ts)
in
  p2at_make_node (loc, svs, dvs, P2Tlst (lin, p2ts))
end // end of [p2at_lst]

(* ****** ****** *)

implement
p2at_refas (loc, refknd, d2v, p2t) = let
  val svs = p2t.p2at_svs
  val dvs = $UT.lstord_insert
    (p2t.p2at_dvs, d2v, compare_d2vsym_d2vsym)
  // end of [val]
in
  p2at_make_node (loc, svs, dvs, P2Trefas (refknd, d2v, p2t))
end // end of [p2at_refas]

implement
p2at_exist
  (loc, s2vs, p2t) = let
  val svs =
    p2at_svs_add_svarlst (p2t.p2at_svs, s2vs)
  // end of [val]
  val dvs = p2t.p2at_dvs
in
  p2at_make_node (loc, svs, dvs, P2Texist (s2vs, p2t))
end // end of [p2at_exist]

(* ****** ****** *)

implement
p2at_ann (loc, p2t, s2e) =
  p2at_make_node (loc, p2t.p2at_svs, p2t.p2at_dvs, P2Tann (p2t, s2e))
// end of [p2at_ann]

(* ****** ****** *)

implement
p2at_err (loc) =
  p2at_make_node (loc, p2at_svs_nil, p2at_dvs_nil, P2Terr ())
// end of [p2at_err]

(* ****** ****** *)
//
// HX: dynamic expressions
//
(* ****** ****** *)

implement
d2exp_make (loc, node) = '{
  d2exp_loc= loc, d2exp_node= node, d2exp_type= None()
} // end of [d2exp_make]

implement
d2exp_var (loc, d2v) = d2exp_make (loc, D2Evar (d2v))

(* ****** ****** *)

implement
d2exp_int (loc, i) = d2exp_make (loc, D2Eint (i))
implement
d2exp_intrep (loc, rep) = d2exp_make (loc, D2Eintrep (rep))
implement
d2exp_bool (loc, b) = d2exp_make (loc, D2Ebool (b))
implement
d2exp_char (loc, c) = d2exp_make (loc, D2Echar (c))
implement
d2exp_string (loc, s) = d2exp_make (loc, D2Estring (s))
implement
d2exp_float (loc, rep) = d2exp_make (loc, D2Efloat (rep))

implement
d2exp_i0nt (loc, x) = d2exp_make (loc, D2Ei0nt (x))
implement
d2exp_c0har (loc, x) = d2exp_make (loc, D2Ec0har (x))
implement
d2exp_f0loat (loc, x) = d2exp_make (loc, D2Ef0loat (x))
implement
d2exp_s0tring (loc, x) = d2exp_make (loc, D2Es0tring (x))

(* ****** ****** *)

implement
d2exp_cstsp
  (loc, cst) = d2exp_make (loc, D2Ecstsp (cst))
// end of [d2exp_cstsp]

(* ****** ****** *)

implement
d2exp_top (loc) = d2exp_make (loc, D2Etop ())

implement
d2exp_empty (loc) = d2exp_make (loc, D2Eempty ())

(* ****** ****** *)

implement
d2exp_extval
  (loc, typ, code) = d2exp_make (loc, D2Eextval (typ, code))
// end of [d2exp_extval]

(* ****** ****** *)

implement
d2exp_con
  (loc, d2c, locfun, sarg, npf, locarg, darg) =
  d2exp_make (loc, D2Econ (d2c, locfun, sarg, npf, locarg, darg))
// end of [d2exp_con]

implement
d2exp_cst (loc, d2c) = d2exp_make (loc, D2Ecst (d2c))

implement
d2exp_sym (loc, d2s) = d2exp_make (loc, D2Esym (d2s))

(* ****** ****** *)

implement
d2exp_loopexn (loc, knd) = d2exp_make (loc, D2Eloopexn knd)

(* ****** ****** *)

implement
d2exp_foldat
  (loc, s2as, d2e) = d2exp_make (loc, D2Efoldat (s2as, d2e))
// end of [d2exp_foldat]
implement
d2exp_freeat
  (loc, s2as, d2e) = d2exp_make (loc, D2Efreeat (s2as, d2e))
// end of [d2exp_freeat]

(* ****** ****** *)

implement
d2exp_tmpid (loc, d2e_id, t2mas) =
  d2exp_make (loc, D2Etmpid (d2e_id, t2mas))
// end of [d2exp_tmpid]

(* ****** ****** *)

implement
d2exp_let (loc, d2cs, body) =
  d2exp_make (loc, D2Elet (d2cs, body))
// end of [d2exp_let]

implement
d2exp_where (loc, body, d2cs) =
  d2exp_make (loc, D2Ewhere (body, d2cs))
// end of [d2exp_where]

(* ****** ****** *)

implement
d2exp_applst (
  loc, d2e_fun, d2as_arg
) = d2exp_make (loc, D2Eapplst (d2e_fun, d2as_arg))

implement
d2exp_app_sta (
  loc0, d2e_fun, s2as
) = let
(*
  val () = (
    print "d2exp_app_sta: d2e_fun = "; print_d2exp d2e_fun; print_newline ()
  ) // end of [val]
*)
in
//
case+ s2as of
| list_cons _ => let
    val d2a = D2EXPARGsta (s2as)
    val node = (
      case+ d2e_fun.d2exp_node of
      | D2Eapplst (d2e_fun, d2as) => let
          val d2as = list_extend (d2as, d2a)
        in
          D2Eapplst (d2e_fun, (l2l)d2as)
        end
      | _ => D2Eapplst (d2e_fun, list_sing (d2a))
    ) : d2exp_node // end of [val]
  in
    d2exp_make (loc0, node)
  end // end of [list_cons]
| list_nil _ => d2e_fun
//
end (* end of [d2exp_app_sta] *)

implement
d2exp_app_dyn (
  loc0, d2e_fun, npf, locarg, darg
) = let
(*
  val () = (
    print "d2exp_app_fun: d2e_fun = "; print_d2exp d2e_fun; print_newline ()
  ) // end of [val]
*)
  val d2a =
    D2EXPARGdyn (npf, locarg, darg)
  // end of [val]
  val node = (
    case+ d2e_fun.d2exp_node of
    | D2Eapplst (d2e_fun, d2as) => let
        val d2as = list_extend (d2as, (d2a))
      in
        D2Eapplst (d2e_fun, (l2l)d2as)
      end
    | _ => D2Eapplst (d2e_fun, list_sing (d2a))
  ) : d2exp_node // end of [val]
in
  d2exp_make (loc0, node)
end // end of [d2exp_app_dyn]

implement
d2exp_app_sta_dyn (
  loc_dyn, loc_sta
, d2e_fun, sarg, locarg, npf, darg
) = let
  val d2e_sta =
    d2exp_app_sta (loc_sta, d2e_fun, sarg)
  // end of [val]
in
  d2exp_app_dyn (loc_dyn, d2e_sta, npf, locarg, darg)
end // end of [d2exp_app_sta_dyn]

(* ****** ****** *)

implement
d2exp_ifhead
  (loc, r2es, _cond, _then, _else) =
  d2exp_make (loc, D2Eifhead (r2es, _cond, _then, _else))
// end of [d2exp_ifhead]

implement
d2exp_sifhead
  (loc, r2es, _cond, _then, _else) =
  d2exp_make (loc, D2Esifhead (r2es, _cond, _then, _else))
// end of [d2exp_sifhead]

(* ****** ****** *)

implement
d2exp_casehead
  (loc, knd, inv, d2es, c2ls) =
  d2exp_make (loc, D2Ecasehead (knd, inv, d2es, c2ls))
// end of [d2exp_casehead]

implement
d2exp_scasehead (
  loc, inv, s2f, sc2ls
) = d2exp_make (loc, D2Escasehead (inv, s2f, sc2ls))

(* ****** ****** *)

implement
d2exp_lst (loc, lin, elt, d2es) =
  d2exp_make (loc, D2Elst (lin, elt, d2es))
// end of [d2exp_lst]

implement
d2exp_tup (loc, knd, npf, d2es) =
  d2exp_make (loc, D2Etup (knd, npf, d2es))
// end of [d2exp_tup]

implement
d2exp_rec (loc, knd, npf, ld2es) =
  d2exp_make (loc, D2Erec (knd, npf, ld2es))
// end of [d2exp_rec]

implement
d2exp_seq
  (loc, d2es) = d2exp_make (loc, D2Eseq (d2es))
// end of [d2exp_seq]

(* ****** ****** *)

implement
d2exp_deref
  (loc, _lval) = d2exp_make (loc, D2Ederef (_lval))
// end of [d2exp_assgn]  

implement
d2exp_assgn (
  loc, _left, _right
) = d2exp_make (loc, D2Eassgn (_left, _right))
// end of [d2exp_assgn]  

implement
d2exp_xchng (
  loc, _left, _right
) = d2exp_make (loc, D2Exchng (_left, _right))
// end of [d2exp_xchng]  

(* ****** ****** *)

implement
d2exp_arrsub (
  loc, d2s, arr, locind, ind
) = d2exp_make (loc, D2Earrsub (d2s, arr, locind, ind))

implement
d2exp_arrinit (
  loc, s2e_elt, asz, init
) = d2exp_make (loc, D2Earrinit (s2e_elt, asz, init))

implement
d2exp_arrsize (
  loc, s2eopt_elt, d2es_ini
) = d2exp_make (loc, D2Earrsize (s2eopt_elt, d2es_ini))

(* ****** ****** *)

implement
d2exp_raise (loc, d2e) = d2exp_make (loc, D2Eraise (d2e))

implement
d2exp_delay
  (loc, knd, d2e) = d2exp_make (loc, D2Edelay (knd, d2e))
// end of [d2exp_delay]

(* ****** ****** *)

implement
d2exp_effmask
  (loc, s2fe, d2e) = d2exp_make (loc, D2Eeffmask (s2fe, d2e))
// end of [d2exp_effmask]

(* ****** ****** *)

implement
d2exp_ptrof (loc, d2e) = d2exp_make (loc, D2Eptrof (d2e))

implement
d2exp_viewat (loc, d2e) = d2exp_make (loc, D2Eviewat (d2e))

(* ****** ****** *)

implement
d2exp_sel_dot
  (loc, d2e, d2ls) =
  d2exp_make (loc, D2Eselab (d2e, d2ls))
// end of [d2exp_sel_dot]

implement
d2exp_sel_ptr
  (loc, d2e, d2l) = let
  val loc2 = d2e.d2exp_loc
  val d2e_deref = d2exp_deref (loc2, d2e)
in
  d2exp_make (loc, D2Eselab (d2e_deref, list_sing (d2l)))
end // end of [d2exp_sel_ptr]

(* ****** ****** *)

implement
d2exp_exist
  (loc, s2a, d2e) = d2exp_make (loc, D2Eexist (s2a, d2e))
// end of [d2exp_exist]

(* ****** ****** *)

implement
d2exp_lam_dyn (
  loc, knd, npf, arg, body
) = d2exp_make (loc, D2Elam_dyn (knd, npf, arg, body))

implement
d2exp_laminit_dyn (
  loc, knd, npf, arg, body
) = d2exp_make (loc, D2Elaminit_dyn (knd, npf, arg, body))

implement
d2exp_lam_met
  (loc, ref, met, body) = d2exp_make (loc, D2Elam_met (ref, met, body))
// end of [d2exp_lam_met]

implement
d2exp_lam_met_new
  (loc, met, body) = let
  val ref = ref<d2varlst> (list_nil)
in
  d2exp_lam_met (loc, ref, met, body)
end // end of [d2exp_lam_met_new]

implement
d2exp_lam_sta
  (loc, s2vs, s2ps, body) =
  d2exp_make (loc, D2Elam_sta (s2vs, s2ps, body))
// end of [d2exp_lam_sta]

implement
d2exp_fix (
  loc, knd, d2v_fun, d2e_body
) = d2exp_make (loc, D2Efix (knd, d2v_fun, d2e_body))

(* ****** ****** *)

implement
d2exp_ann_type
  (loc, d2e, s2e) =
  d2exp_make (loc, D2Eann_type (d2e, s2e))
// end of [d2exp_ann_type]

implement
d2exp_ann_seff
  (loc, d2e, s2fe) = d2exp_make (loc, D2Eann_seff (d2e, s2fe))
// end of [d2exp_ann_seff]

implement
d2exp_ann_funclo
  (loc, d2e, fc) = d2exp_make (loc, D2Eann_funclo (d2e, fc))
// end of [d2exp_ann_funclo]

(* ****** ****** *)

implement
d2exp_err (loc) = d2exp_make (loc, D2Eerr ())

(* ****** ****** *)

implement
labd2exp_make (l, d2e) = $SYN.DL0ABELED (l, d2e)

(* ****** ****** *)

implement
d2lab_lab (loc, lab) = '{
  d2lab_loc= loc, d2lab_node= D2LABlab (lab)
}
implement
d2lab_ind (loc, ind) = '{
  d2lab_loc= loc, d2lab_node= D2LABind (ind)
}

(* ****** ****** *)

implement
i2nvarg_make
  (d2v, typ) = '{
  i2nvarg_var= d2v, i2nvarg_typ= typ
} // end of [i2nvarg_make]

implement
i2nvresstate_nil = i2nvresstate_make (
  list_nil(*svs*), list_nil(*gua*), list_nil(*arg*)
) // end of [i2nvresstate_nil]

implement
i2nvresstate_make
  (s2vs, s2ps, arg) = '{
  i2nvresstate_svs= s2vs
, i2nvresstate_gua= s2ps
, i2nvresstate_arg= arg
, i2nvresstate_met= None ()
} // end of [i2nvresstate_make]

implement
i2nvresstate_make_met (
  s2vs, s2ps, arg, met
) = '{
  i2nvresstate_svs= s2vs
, i2nvresstate_gua= s2ps
, i2nvresstate_arg= arg
, i2nvresstate_met= met
} // end of [i2nvresstate_make]

(* ****** ****** *)

implement
loopi2nv_make (
  loc, s2vs, s2ps, met, arg, res
) = '{
  loopi2nv_loc= loc
, loopi2nv_svs= s2vs
, loopi2nv_gua= s2ps
, loopi2nv_met= met
, loopi2nv_arg= arg
, loopi2nv_res= res
} // end of [loopi2nv_make]

(* ****** ****** *)

implement
m2atch_make (loc, d2e, p2topt) = '{
  m2atch_loc= loc, m2atch_exp= d2e, m2atch_pat= p2topt
} // end of [m2atch_make]

implement
c2lau_make (
  loc, p2t, gua, seq, neg, d2e
) = '{
  c2lau_loc= loc
, c2lau_pat= p2t
, c2lau_gua= gua
, c2lau_seq= seq
, c2lau_neg= neg
, c2lau_body= d2e
} // end of [c2lau_make]

implement
sc2lau_make (loc, sp2t, d2e) = '{
  sc2lau_loc= loc, sc2lau_pat= sp2t, sc2lau_body= d2e
} // end of [sc2lau_make]

(* ****** ****** *)
//
// HX: various declarations
//
(* ****** ****** *)

implement
v2aldec_make (
  loc, p2t, def, ann
) = '{
  v2aldec_loc= loc
, v2aldec_pat= p2t
, v2aldec_def= def
, v2aldec_ann= ann
} // end of [v2aldec_make]

(* ****** ****** *)

implement
v2ardec_make (
  loc, knd, d2v, s2v, typ, wth, ini
) = '{
  v2ardec_loc= loc
, v2ardec_knd= knd
, v2ardec_dvar= d2v
, v2ardec_svar= s2v
, v2ardec_typ= typ
, v2ardec_wth= wth
, v2ardec_ini= ini
} // end of [v2ardec_make]

(* ****** ****** *)

implement
f2undec_make (
  loc, d2v, def, ann
) = '{
  f2undec_loc= loc
, f2undec_var= d2v
, f2undec_def= def
, f2undec_ann= ann
} // end of [f2undec_make]

(* ****** ****** *)

implement
i2mpdec_make (
  loc, locid
, d2c, s2vs, s2ess, s2pss, def
) = '{
  i2mpdec_loc= loc
, i2mpdec_locid= locid
, i2mpdec_cst= d2c
, i2mpdec_imparg= s2vs
, i2mpdec_tmparg= s2ess, i2mpdec_tmpgua= s2pss
, i2mpdec_def= def
} // end of [i2mpdec_make]

(* ****** ****** *)

extern
fun d2ecl_make
  (loc: location, node: d2ecl_node): d2ecl
implement
d2ecl_make (loc, node) = '{
  d2ecl_loc= loc, d2ecl_node= node
}

implement
d2ecl_none (loc) = d2ecl_make (loc, D2Cnone ())

implement
d2ecl_list (loc, xs) = d2ecl_make (loc, D2Clist (xs))

implement
d2ecl_symintr
  (loc, ids) = d2ecl_make (loc, D2Csymintr (ids))
// end of [d2ecl_symintr]
implement
d2ecl_symelim
  (loc, ids) = d2ecl_make (loc, D2Csymelim (ids))
// end of [d2ecl_symelim]

implement
d2ecl_overload (loc, id, def) =
  d2ecl_make (loc, D2Coverload (id, def))

implement
d2ecl_stavars
  (loc, xs) = d2ecl_make (loc, D2Cstavars (xs))
// end of [d2ecl_stavars]

implement
d2ecl_saspdec (loc, d) = d2ecl_make (loc, D2Csaspdec (d))

implement
d2ecl_extype (loc, name, def) =
  d2ecl_make (loc, D2Cextype (name, def))
implement
d2ecl_extval (loc, name, def) =
  d2ecl_make (loc, D2Cextval (name, def))
implement
d2ecl_extcode (loc, knd, pos, code) =
  d2ecl_make (loc, D2Cextcode (knd, pos, code))

implement
d2ecl_datdec (loc, knd, s2cs) =
  d2ecl_make (loc, D2Cdatdec (knd, s2cs))

implement
d2ecl_exndec (loc, d2cs) =
 d2ecl_make (loc, D2Cexndec (d2cs))

implement
d2ecl_dcstdec (loc, knd, d2cs) =
  d2ecl_make (loc, D2Cdcstdec (knd, d2cs))

implement
d2ecl_valdecs (loc, knd, d2cs) =
  d2ecl_make (loc, D2Cvaldecs (knd, d2cs))

implement
d2ecl_valdecs_rec (loc, knd, d2cs) =
  d2ecl_make (loc, D2Cvaldecs_rec (knd, d2cs))

implement
d2ecl_vardecs (loc, d2cs) =
  d2ecl_make (loc, D2Cvardecs (d2cs))

implement
d2ecl_fundecs (loc, knd, decarg, d2cs) =
  d2ecl_make (loc, D2Cfundecs (knd, decarg, d2cs))

implement
d2ecl_impdec (loc, d2c) = d2ecl_make (loc, D2Cimpdec (d2c))

implement
d2ecl_include (loc, d2cs) =
  d2ecl_make (loc, D2Cinclude (d2cs))

implement
d2ecl_staload (
  loc, idopt, fil, flag, loaded, fenv
) =
  d2ecl_make (loc, D2Cstaload (idopt, fil, flag, loaded, fenv))
// endof [d2ecl_staload]

implement
d2ecl_dynload (loc, fil) = d2ecl_make (loc, D2Cdynload (fil))

implement d2ecl_local
  (loc, head, body) = d2ecl_make (loc, D2Clocal (head, body))
// end of [d2ecl_local]

(* ****** ****** *)

extern typedef "p2at_t" = p2at
extern typedef "d2exp_t" = d2exp

%{$

ats_void_type
patsopt_p2at_set_type (
  ats_ptr_type p2t, ats_ptr_type opt
) {
  ((p2at_t)p2t)->atslab_p2at_type = opt ; return ;
} // end of [patsopt_p2at_set_type]

ats_void_type
patsopt_d2exp_set_type (
  ats_ptr_type d2e, ats_ptr_type opt
) {
  ((d2exp_t)d2e)->atslab_d2exp_type = opt ; return ;
} // end of [patsopt_d2exp_set_type]

%} // end of [%{$]

(* ****** ****** *)

(* end of [pats_dynexp2.dats] *)
