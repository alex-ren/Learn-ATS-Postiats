(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2012 Hongwei Xi, ATS Trustful Software, Inc.
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
(* Start time: December, 2012 *)

(* ****** ****** *)

staload "libats/SATS/funmap_avltree.sats"

(* ****** ****** *)

implement
{key}
compare_key_key
  (k1, k2) = gcompare_val<key> (k1, k2)
// end of [compare_key_key]

(* ****** ****** *)
//
// HX-2012-12-26:
// the file should be included here
// before [map_type] is assumed
//
#include "./SHARE/funmap.hats" // code reuse
//
(* ****** ****** *)
//
// HX: maximal height difference of two siblings
//
#define HTDF 1
#define HTDF1 (HTDF+1)
#define HTDF_1 (HTDF-1)
//
(* ****** ****** *)

datatype avltree
(
  key:t@ype, itm:t@ype+, int(*height*)
) =
  | {hl,hr:nat |
     hl <= hr+HTDF;
     hr <= hl+HTDF}
    B (key, itm, 1+max(hl,hr)) of
    (
      int(1+max(hl,hr)), key, itm, avltree(key, itm, hl), avltree(key, itm, hr)
    )
  | E (key, itm, 0) of ((*void*))
// end of [datatype avltree]

typedef avltree_inc
  (key:t@ype, itm:t@ype, h:int) =
  [h1:nat | h <= h1; h1 <= h+1] avltree (key, itm, h1)
// end of [avltree_inc]

typedef avltree_dec
  (key:t@ype, itm:t@ype, h:int) =
  [h1:nat | h1 <= h; h <= h1+1] avltree (key, itm, h1)
// end of [avltree_dec]

(* ****** ****** *)

assume
map_type (key:t0p, itm: vt0p) = [h:nat] avltree (key, itm, h)
// end of [map_type]

(* ****** ****** *)

(* end of [funmap_avltree.dats] *)
