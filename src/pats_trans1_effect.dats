(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(*                              Hongwei Xi                             *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, Boston University
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
// Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
// Start Time: April, 2011
//
(* ****** ****** *)

staload ERR = "pats_error.sats"

(* ****** ****** *)

staload "pats_basics.sats"
staload "pats_effect.sats"
staload "pats_syntax.sats"

(* ****** ****** *)

staload "pats_staexp1.sats"
staload "pats_trans1.sats"

(* ****** ****** *)

fn name_is_nil (name: string): bool =
  if name = "0" then true else name = "nil"
fn name_is_all (name: string): bool =
  if name = "1" then true else name = "all"

fn name_is_exn (name: string): bool =
  if name = "exn" then true else name = "exception"

fn name_is_exnref (name: string): bool = name = "exnref"

fn name_is_ntm (name: string): bool =
  if name = "ntm" then true else name = "nonterm"

fn name_is_ref (name:string): bool =
  if name = "ref" then true else name = "reference"

fn name_is_wrt (name: string): bool =
  if name = "wrt" then true else name = "write"

//
// HX: !laz = 1,~ref
//
fn name_is_lazy (name: string): bool = name = "laz"

(* ****** ****** *)

val effvars_nil: effvarlst = list_nil ()

(* ****** ****** *)

local

fn loop_err (
  tag: e0fftag, name: string
) : void = {
  val loc = tag.e0fftag_loc
  val () = $LOC.prerr_location (loc)
  val () = prerr ": error(1)"
  val () = prerr ": unrecognized effect constant: ["
  val () = prerr name
  val () = prerr "]"
  val () = prerr_newline ()
  val () = $ERR.abort ()
} // end of [loop_err]

fun loop (
    fcopt: &funcloopt
  , lin: &int
  , prf: &int
  , efs: &effset
  , evs: &effvarlst
  , tags: e0fftaglst
  ) : void = begin case+ tags of
  | list_cons (tag, tags) => let
      val () = case+ tag.e0fftag_node of
//
      | E0FFTAGvar ev => evs := list_cons (ev, evs)
//
      | E0FFTAGint (int) => {
          val () = evs := effvars_nil
          val () = if int = 0 then efs := effset_nil
          val () = if int = 1 then efs := effset_all
        } // end of [E0FFTAGint]
//
      | E0FFTAGcst (isneg, name)
          when name_is_all name => {
          val () = evs := effvars_nil
          val () = if isneg > 0 then efs := effset_nil else efs := effset_all
        } // end of [E0FFTAGcst when ...]
      | E0FFTAGcst (isneg, name)
          when name_is_nil name => {
          val () = evs := effvars_nil
          val () = if isneg > 0 then efs := effset_all else efs := effset_nil
        } // end of [E0FFTAGcst when ...]
      | E0FFTAGcst (isneg, name)
          when name_is_lazy name => {
          val () = evs := effvars_nil
          val () = if isneg > 0 then
            efs := effset_add (effset_nil, effect_ref) // HX: nonsensical
          val () = if isneg = 0 then
            efs := effset_del (effset_all, effect_ref) // HX: !laz = 1,~ref
        } // end of [E0FFTAGcst when ...]
//
      | E0FFTAGcst (isneg, name) => begin case+ 0 of
        | _ when name_is_exn name => {
            val () = if isneg > 0 then efs := effset_del (efs, effect_exn)
            val () = if isneg = 0 then efs := effset_add (efs, effect_exn)
          } // end of [_ when ...]
        | _ when name_is_exnref name => {
            val () = if isneg > 0 then
              efs := effset_del (effset_del (efs, effect_exn), effect_ref)
            val () = if isneg = 0 then
              efs := effset_add (effset_add (efs, effect_exn), effect_ref)
          } // end of [_ when ...]
        | _ when name_is_ntm name => {
            val () = if isneg > 0 then efs := effset_del (efs, effect_ntm)
            val () = if isneg = 0 then efs := effset_add (efs, effect_ntm)
          } // end of [_ when ...]
        | _ when name_is_ref name => {
            val () = if isneg > 0 then efs := effset_del (efs, effect_ref)
            val () = if isneg = 0 then efs := effset_add (efs, effect_ref)
          } // end of [_ when ...]
        | _ => loop_err (tag, name)
        end // end of [E0FFTAGcst]
//
      | E0FFTAGprf () => prf := 1
//
      | E0FFTAGlin (i(*nil/all*)) => let
          val () = lin := 1 // linearity
        in
          if i > 0 then (efs := effset_all; evs := effvars_nil)
        end // end of [E0FFTAGlin]
//
      | E0FFTAGfun (uln, i(*nil/all*)) => let
          val () = if (uln >= 0) then lin := uln
          val () = fcopt := Some (FUNCLOfun ())
        in
          if i > 0 then (efs := effset_all; evs := effvars_nil)
        end // end of [E0FFTAGfun]
//
      | E0FFTAGclo (uln, knd, i) => let
          // knd : 1/~1:ptr/ref; i : nil/all
          val () = if (uln >= 0) then lin := uln
          val () = fcopt := Some (FUNCLOclo (knd))
        in
          if i > 0 then (efs := effset_all; evs := effvars_nil)
        end // end of [E0FFTAGclo]
//
    in
      loop (fcopt, lin, prf, efs, evs, tags)
    end // end of [let] // end of [list_cons]
  | list_nil () => () // end of [list_nil]
end // end of [loop]

in // in of [local]

implement
e0fftaglst_tr (tags) = let
  var fcopt: funcloopt = None()
  var lin: int = 0 and prf: int = 0
  var efs: effset = effset_nil and evs: effvarlst = effvars_nil
  val () = loop (fcopt, lin, prf, efs, evs, tags)
  val efc = (case+ 0 of
    | _ when eq_effset_effset (efs, effset_all) => EFFCSTall ()
    | _ when eq_effset_effset (efs, effset_nil) => begin
        case+ evs of list_nil () => EFFCSTnil () | _ => EFFCSTset (efs, evs)
      end // end of [_ when ...]
    | _ => EFFCSTset (efs, evs)
  ) : effcst // end of [val]
in
  @(fcopt, lin, prf, efc)
end // end of [e0fftaglst_tr]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans_effect.dats] *)
