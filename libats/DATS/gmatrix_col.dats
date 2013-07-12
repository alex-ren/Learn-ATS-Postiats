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
staload "libats/SATS/gmatrix_col.sats"

(* ****** ****** *)

implement{a}
gmatcol_getref_col_at
  {m,n}{ld}(M, m, j) = let
//
val pcol = $UN.cast2Ptr1(ptr_add<a> (addr@(M), j * m))
//
in
  $UN.ptr2cptr{array(a,m)}(pcol)
end // end of [gmatcol_getref_col_at]

(* ****** ****** *)

implement{a}
multo_gvector_gmatcol_gvector
  {m,n}{d1,ld2,d3}
(
  V1, M2, V3, m, n, d1, ld2, d3
) = let
//
fun loop
  {l1,l2,l3:addr}{n:nat} .<n>.
(
  pf1: !GV (a, l1, m, d1)
, pf2: !GMC (a, l2, m, n, ld2)
, pf3: !GV (a?, l3, n, d3) >> GV (a, l3, n, d3)
| p1: ptr(l1), p2: ptr(l2), p3: ptr(l3), n: int n
) : void = let
in
//
if n > 0 then let
//
prval (pf21, pf22) = gmatcol_v_uncons (pf2)
prval (pf31, pf32) = gvector_v_uncons (pf3)
//
prval () = array2gvector(!p2)
val () = !p3 := mul_gvector_gvector_scalar (!p1, !p2, m, d1, 1)
val () = loop (pf1, pf22, pf32 | p1, ptr_add<a> (p2, ld2), ptr_add<a> (p3, d3), n-1)
prval () = gvector2array(!p2)
//
prval () = pf2 := gmatcol_v_cons (pf21, pf22)
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
prval () = lemma_gmatcol_param (M2)
//
in
  loop (view@V1, view@M2, view@V3 | addr@V1, addr@M2, addr@V3, n)
end // end of [multo_gvector_gmatcol_gvector]

(* ****** ****** *)

implement{a}
multo_gmatcol_gmatcol_gmatcol
  {p,q,r}{lda,ldb,ldc}
(
  A, B, C, p, q, r, lda, ldb, ldc
) = let
//
prval () = lemma_gmatcol_param (A)
prval () = lemma_gmatcol_param (B)
prval () = lemma_gmatcol_param (C)
//
fun loop
  {la,lb,lc,lt:addr}{p:nat} .<p>.
(
  pfa: !GMC (a, la, p, q, lda)
, pfb: !GMC (a, lb, q, r, ldb)
, pfc: !GMC (a?, lc, p, r, ldc) >> GMC (a, lc, p, r, ldc)
, pft: !array_v(a?, lt, q) >> _
| pa: ptr la, pb: ptr lb, pc: ptr lc, pt: ptr lt, p: int p
) : void =
(
if p > 0
then let
//
prval
(
  pfa1, pfa2
) = gmatcol_v_uncons2 (pfa)
prval
(
  pfc1, pfc2
) = gmatcol_v_uncons2 (pfc)
//
prval () = array2gvector (!pt)
val () = copyto_gvector_gvector (!pa, !pt, q, lda, 1)
val () = multo_gvector_gmatcol_gvector (!pt, !pb, !pc, q, r, 1, ldb, ldc)
prval () = gvector2array (!pt)
//
val (
) = loop (
  pfa2, pfb, pfc2, pft
| ptr_succ<a> (pa), pb, ptr_succ<a> (pc), pt, pred(p)
) (* end of [val] *)
//
prval () = pfa := gmatcol_v_cons2 (pfa1, pfa2)
prval () = pfc := gmatcol_v_cons2 (pfc1, pfc2)
//
in
  // nothing
end else let
//
prval () = (pfc := gmatcol_v_unnil2_nil2{a?,a}(pfc))
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
  view@A, view@B, view@C, pft | addr@A, addr@B, addr@C, pt, p
) (* end of [val] *)
//
val ((*void*)) = array_ptr_free (pft, pftgc | pt)
//
in
  // nothing
end // end of [multo_gmatcol_gmatcol_gmatcol]

(* ****** ****** *)

implement{a}
tmulto_gvector_gvector_gmatcol
  {m,n}{d1,d2,ld3}
(
  V1, V2, M3, m, n, d1, d2, ld3
) = let
//
fun loop
  {l1,l2,l3:addr}{n:nat} .<n>.
(
  pf1: !GV (a, l1, m, d1)
, pf2: !GV (a, l2, n, d2)
, pf3: !GMC (a?, l3, m, n, ld3) >> GMC (a, l3, m, n, ld3)
| p1: ptr l1, p2: ptr l2, p3: ptr l3, m: int m, n: int n
) : void =
(
if n > 0
  then let
//
prval (pf21, pf22) = gvector_v_uncons (pf2)
prval (pf31, pf32) = gmatcol_v_uncons (pf3)
//
val k = !p2
prval () = array2gvector(!p3)
val (
) = multo_scalar_gvector_gvector (k, !p1, !p3, m, d1, 1)
val (
) = loop (pf1, pf22, pf32 | p1, ptr_add<a> (p2, d2), ptr_add<a> (p3, ld3), m, pred(n))
prval () = gvector2array(!p3)
prval () = pf2 := gvector_v_cons (pf21, pf22)
prval () = pf3 := gmatcol_v_cons (pf31, pf32)
//
in
  // nothing
end else let
//
prval () = (pf3 := gmatcol_v_unnil_nil{a?,a}(pf3))
//
in
  // nothing
end // end of [if]
)
//
prval () = lemma_gmatcol_param (M3)
//
in
  loop (view@V1, view@V2, view@M3 | addr@V1, addr@V2, addr@M3, m, n)
end // end of [tmul_gvector_gvector_gmatcol]

(* ****** ****** *)

(* end of [gmatrix_col.dats] *)