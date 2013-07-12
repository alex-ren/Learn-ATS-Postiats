(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
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

(* Author: Hongwei Xi *)
(* Authoremail: hwxi AT cs DOT bu DOT edu *)
(* Start time: July, 2013 *)

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/gvector.sats"
staload "libats/SATS/gmatrix_row.sats"

(* ****** ****** *)

implement{a}
gmatrow_getref_row_at
  {m,n}{ld}(M, n, i) = let
//
val prow = $UN.cast2Ptr1(ptr_add<a> (addr@(M), i * n))
//
in
  $UN.ptr2cptr{array(a,n)}(prow)
end // end of [gmatrow_getref_row_at]

(* ****** ****** *)

implement{a}
multo_gmatrow_gvector_gvector
  {m,n}{ld1,d2,d3}
(
  M1, V2, V3, m, n, ld1, d2, d3
) = let
//
fun loop
  {l1,l2,l3:addr}{m:nat} .<m>.
(
  pf1:
  !GMR (a, l1, m, n, ld1)
, pf2: !GV (a, l2, n, d2)
, pf3: !GV (a?, l3, m, d3) >> GV (a, l3, m, d3)
| p1: ptr(l1), p2: ptr(l2), p3: ptr(l3), m: int m
) : void = let
in
//
if m > 0 then let
//
prval (pf11, pf12) = gmatrow_v_uncons (pf1)
prval (pf31, pf32) = gvector_v_uncons (pf3)
//
prval () = array2gvector(!p1)
val () = !p3 := mul_gvector_gvector_scalar (!p1, !p2, n, 1, d2)
val () = loop (pf12, pf2, pf32 | ptr_add<a> (p1, ld1), p2, ptr_add<a> (p3, d3), m-1)
prval () = gvector2array(!p1)
//
prval () = pf1 := gmatrow_v_cons (pf11, pf12)
prval () = pf3 := gvector_v_cons (pf31, pf32)
//
in
  // nothing
end else let
//
prval () = pf3 := gvector_v_unnil_nil{a?,a}(pf3)
//
in
  // nothing
end // end of [if]
//
end // end of [loop]
//
prval () = lemma_gmatrow_param (M1)
//
in
  loop (view@M1, view@V2, view@V3 | addr@M1, addr@V2, addr@V3, m)
end // end of [multo_gmatrow_gvector_gvector]

(* ****** ****** *)

implement{a}
multo_gmatrow_gmatrow_gmatrow
  {p,q,r}{lda,ldb,ldc}
(
  A, B, C, p, q, r, lda, ldb, ldc
) = let
//
prval () = lemma_gmatrow_param (A)
prval () = lemma_gmatrow_param (B)
prval () = lemma_gmatrow_param (C)
//
fun loop
  {la,lb,lc,lt:addr}{r:nat} .<r>.
(
  pfa: !GMR (a, la, p, q, lda)
, pfb: !GMR (a, lb, q, r, ldb)
, pfc: !GMR (a?, lc, p, r, ldc) >> GMR (a, lc, p, r, ldc)
, pft: !array_v(a?, lt, q) >> _
| pa: ptr la, pb: ptr lb, pc: ptr lc, pt: ptr lt, r: int r
) : void =
(
if r > 0
then let
//
prval
(
  pfb1, pfb2
) = gmatrow_v_uncons2 (pfb)
prval
(
  pfc1, pfc2
) = gmatrow_v_uncons2 (pfc)
//
prval () = array2gvector (!pt)
val () = copyto_gvector_gvector (!pb, !pt, q, ldb, 1)
val () = multo_gmatrow_gvector_gvector (!pa, !pt, !pc, p, q, lda, 1, ldc)
prval () = gvector2array (!pt)
//
val (
) = loop (
  pfa, pfb2, pfc2, pft
| pa, ptr_succ<a> (pb), ptr_succ<a> (pc), pt, pred(r)
) (* end of [val] *)
//
prval () = pfb := gmatrow_v_cons2 (pfb1, pfb2)
prval () = pfc := gmatrow_v_cons2 (pfc1, pfc2)
//
in
  // nothing
end else let
//
prval () = (pfc := gmatrow_v_unnil2_nil2{a?,a}(pfc))
//
in
  // nothing
end // end of [if]
)
//
val qsz = i2sz(q)
val [lt:addr]
  (pft, pftgc | pt) = array_ptr_alloc<a> (qsz)
//
val (
) = loop (
  view@A, view@B, view@C, pft | addr@A, addr@B, addr@C, pt, r
) (* end of [val] *)
//
val ((*void*)) = array_ptr_free (pft, pftgc | pt)
//
in
  // nothing
end // end of [multo_gmatrow_gmatrow_gmatrow]

(* ****** ****** *)

implement{a}
tmulto_gvector_gvector_gmatrow
  {m,n}{d1,d2,ld3}
(
  V1, V2, M3, m, n, d1, d2, ld3
) = let
//
fun loop
  {l1,l2,l3:addr}{m:nat} .<m>.
(
  pf1: !GV (a, l1, m, d1)
, pf2: !GV (a, l2, n, d2)
, pf3: !GMR (a?, l3, m, n, ld3) >> GMR (a, l3, m, n, ld3)
| p1: ptr l1, p2: ptr l2, p3: ptr l3, m: int m, n: int n
) : void =
(
if m > 0
  then let
//
prval (pf11, pf12) = gvector_v_uncons (pf1)
prval (pf31, pf32) = gmatrow_v_uncons (pf3)
//
val k = !p1
prval () = array2gvector(!p3)
val (
) = multo_scalar_gvector_gvector (k, !p2, !p3, n, d2, 1)
val (
) = loop (pf12, pf2, pf32 | ptr_add<a> (p1, d1), p2, ptr_add<a> (p3, ld3), pred(m), n)
prval () = gvector2array(!p3)
prval () = pf1 := gvector_v_cons (pf11, pf12)
prval () = pf3 := gmatrow_v_cons (pf31, pf32)
//
in
  // nothing
end else let
//
prval () = (pf3 := gmatrow_v_unnil_nil{a?,a}(pf3))
//
in
  // nothing
end // end of [if]
)
//
prval () = lemma_gmatrow_param (M3)
//
in
  loop (view@V1, view@V2, view@M3 | addr@V1, addr@V2, addr@M3, m, n)
end // end of [tmul_gvector_gvector_gmatrow]

(* ****** ****** *)

(* end of [gmatrix.dats] *)