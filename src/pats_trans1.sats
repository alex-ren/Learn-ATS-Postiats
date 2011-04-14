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

staload "pats_syntax.sats"
staload "pats_staexp1.sats"
staload "pats_dynexp1.sats"

(* ****** ****** *)

fun e0xp_tr (x: e0xp): e1xp
fun e0xplst_tr (x: e0xplst): e1xplst

(* ****** ****** *)

fun s0rt_tr (_: s0rt): s1rt
fun s0rtlst_tr (_: s0rtlst): s1rtlst
fun s0rtopt_tr (_: s0rtopt): s1rtopt

(* ****** ****** *)

fun a0srt_tr (x: a0srt): s1rt
fun a0msrt_tr (x: a0msrt): s1rtlst
fun a0msrtlst_tr (x: a0msrtlst): s1rtlstlst

(* ****** ****** *)

fun s0tacst_tr (_: s0tacst): s1tacst

(* ****** ****** *)

fun d0ecl_fixity_tr
  (dec: f0xty, ids: i0delst): void
fun d0ecl_nonfix_tr (ids: i0delst): void

(* ****** ****** *)

fun d0ecl_tr (_: d0ecl): d1ecl
fun d0eclist_tr (_: d0eclist): d1eclist

(* ****** ****** *)

(* end of [pats_trans1.sats] *)
