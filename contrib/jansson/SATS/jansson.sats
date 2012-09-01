(*
** Copyright (C) 2010 Chris Double.
**
** Permission to use, copy, modify, and distribute this software for any
** purpose with or without fee is hereby granted, provided that the above
** copyright notice and this permission notice appear in all copies.
** 
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
** WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
** MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
** ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
** WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
** ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
** OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*)

(* ****** ****** *)

(*
** Time: September, 2012
** Author Hongwei Xi (gmhwxi AT gmail DOT com)
**
** The API is slightly modified in the hope that it can be used more easily.
*)

(* ****** ****** *)

%{#
#include "jansson/CATS/jansson.cats"
%}

(* ****** ****** *)

#define ATS_STALOADFLAG 0 // no need for staloading at run-time

(* ****** ****** *)

typedef SHR(x:type) = x // for commenting purpose
typedef NSH(x:type) = x // for commenting purpose

(* ****** ****** *)
//
abst@ype json_type = $extype"json_type"
//
macdef JSON_OBJECT   = $extval (json_type, "JSON_OBJECT")
macdef JSON_ARRAY    = $extval (json_type, "JSON_ARRAY")
macdef JSON_STRING   = $extval (json_type, "JSON_STRING")
macdef JSON_INTEGER  = $extval (json_type, "JSON_INTEGER")
macdef JSON_REAL     = $extval (json_type, "JSON_REAL")
macdef JSON_TRUE     = $extval (json_type, "JSON_TRUE")
macdef JSON_FALSE    = $extval (json_type, "JSON_FALSE")
macdef JSON_NULL     = $extval (json_type, "JSON_NULL")
//
abst@ype json_t = $extype"json_t" // json_type + refcount
abst@ype json_error_t = $extype"json_error_t" // locinfo + errmsg
//
abst@ype json_int_t = $extype"json_int_t" // largest available int type
//
(* ****** ****** *)

absviewtype JSONptr (l:addr) // json_t*
viewtypedef JSONptr0 = [l:addr] JSONptr (l)
viewtypedef JSONptr1 = [l:addr | l > null] JSONptr (l)

(* ****** ****** *)

absviewtype JSONiter (l:addr)
viewtypedef JSONiter0 = [l:addr] JSONiter l
viewtypedef JSONiter1 = [l:addr | l > null] JSONiter l

(* ****** ****** *)

castfn JSONptr2ptr {l:addr} (x: !JSONptr l):<> ptr (l)
castfn JSONiter2ptr {l:addr} (x: !JSONiter l):<> ptr (l)

(* ****** ****** *)

praxi JSONptr_free_null
  {l:addr | l <= null} (x: JSONptr l):<> void
// end of [JSONptr_free_null]

(* ****** ****** *)

fun JSONptr_is_null
  {l:addr} (x: !JSONptr l):<> bool (l == null) = "mac#atspre_ptr_is_null"
// end of [JSONptr_is_null]

fun JSONptr_isnot_null
  {l:addr} (x: !JSONptr (l)):<> bool (l > null) = "mac#atspre_ptr_isnot_null"
// end of [JSONptr_isnot_null]

overload ~ with JSONptr_isnot_null

(* ****** ****** *)

fun JSONiter_is_null
  {l:addr} (x: !JSONiter l):<> bool (l == null) = "mac#atspre_ptr_is_null"
// end of [JSONiter_is_null]

fun JSONiter_isnot_null
  {l:addr} (x: !JSONiter (l)):<> bool (l > null) = "mac#atspre_ptr_isnot_null"
// end of [JSONiter_isnot_null]

overload ~ with JSONiter_isnot_null

(* ****** ****** *)

fun json_typeof
  {l:agz} (json: !JSONptr l): int = "mac#atsctrb_json_typeof"

(* ****** ****** *)
//
// HX-2012-09:
// these functions currently indeed return 0/1 for false/true
//
fun json_is_null
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_null"
fun json_is_true
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_true"
fun json_is_false
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_false"

fun json_is_boolean
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_boolean"
  
fun json_is_integer
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_integer"
fun json_is_real
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_real"
fun json_is_number
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_number"

fun json_is_string
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_string"
fun json_is_array
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_array"
fun json_is_object
  {l:addr} (json: !JSONptr (l)) : bool = "mac#atsctrb_json_is_object"

(* ****** ****** *)

fun json_incref
  {l:agz}
  (json: !JSONptr (l)) : JSONptr (l) = "mac#atsctrb_json_incref"

fun json_decref
  {l:addr} (json: JSONptr (l)) : void = "mac#atsctrb_json_decref"

(* ****** ****** *)

fun json_null () : JSONptr1 = "mac#atsctrb_json_null"

fun json_true () : JSONptr1 = "mac#atsctrb_json_true"
fun json_false () : JSONptr1 = "mac#atsctrb_json_false"

(* ****** ****** *)

fun json_string
  (value: NSH(string)) : JSONptr0 = "mac#atsctrb_json_string"
// end of [json_string]

fun json_string_nocheck
  (value: NSH(string)) : JSONptr0 = "mac#atsctrb_json_string_nocheck"
// end of [json_string_nocheck]

fun json_string_value
  {l1:agz} (
  json: !JSONptr (l1)
) : [l2:agz]
  (minus (JSONptr l1, strptr l2) | strptr l2) = "mac#atsctrb_json_string_value"
// end of [json_string_value]

fun json_string_set
  {l:agz} (
  json: !JSONptr (l)
, value: NSH(string)
) : int = "mac#atsctrb_json_string_set"
// end of [json_string_set]

fun json_string_set_nocheck
  {l:agz} (
  json: !JSONptr (l)
, value: NSH(string)
) : int = "mac#atsctrb_json_string_set_nocheck"

(* ****** ****** *)

typedef json_int = json_int_t

castfn int2json_int (x: int): json_int
castfn lint2json_int (x: lint): json_int
castfn llint2json_int (x: llint): json_int

fun json_integer
  (value: json_int) : JSONptr0 = "mac#atsctrb_json_integer"
// end of [json_integer]

fun json_integer_value
  {l:agz}
  (json: !JSONptr l): json_int = "mac#atsctrb_json_integer_value"
// end of [json_integer_value]

fun json_integer_set
  {l:agz} (
  json: !JSONptr l, value: json_int
) : int(*err*) = "mac#atsctrb_json_integer_set"

(* ****** ****** *)

fun json_real
  (value: int) : JSONptr0 = "mac#atsctrb_json_real"
// end of [json_real]

fun json_real_value
  {l:agz} (json: !JSONptr l): double = "mac#atsctrb_json_real_value"

fun json_real_set
  {l:agz} (
  json: !JSONptr l, value: double
) : int = "mac#atsctrb_json_real_set"

(* ****** ****** *)

fun json_number_value
  {l:agz} (json: !JSONptr l): double = "mac#atsctrb_json_number_value"
// end of [json_number_value]

(* ****** ****** *)

fun json_array
  ((*void*)) : JSONptr0 = "mac#atsctrb_json_array"
// end of [json_array]

fun json_array_size
  {l:agz} (json: !JSONptr l) : size_t = "mac#atsctrb_json_array_size"
// end of [json_array_size]

fun json_array_get
  {l1:agz} (
  json: !JSONptr (l1), index: size_t
) : [l2:addr]
  (minus (JSONptr (l1), JSONptr (l2)) | JSONptr (l2)) = "mac#atsctrb_json_array_get"
// end of [json_array_get]

fun json_array_set
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1), index: size_t, value: !JSONptr l2(*preserved*)
) : int(*err*) = "mac#atsctrb_json_array_set"

fun json_array_set_new
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1), index: size_t, value: JSONptr (l2) /*consumed*/
) : int(*err*) = "mac#atsctrb_json_array_set_new"

fun json_array_append
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1), index: size_t, value: !JSONptr l2(*preserved*)
) : int(*err*) = "mac#atsctrb_json_array_append"

fun json_array_append_new
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1), index: size_t, value: JSONptr (l2) /*consumed*/
) : int(*err*) = "mac#atsctrb_json_array_append_new"

fun json_array_insert
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1), index: size_t, value: !JSONptr l2(*preserved*)
) : int(*err*) = "mac#atsctrb_json_array_insert"

fun json_array_insert_new
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1), index: size_t, value: JSONptr (l2) /*consumed*/
) : int(*err*) = "mac#atsctrb_json_array_insert_new"

fun json_array_remove
  {l:agz} (
  json: !JSONptr l, index: size_t
) : int(*err*)
  = "mac#atsctrb_json_array_remove"

fun json_array_clear
  {l:agz} (json: !JSONptr l) : int(*0*) = "mac#atsctrb_json_array_clear"
// end of [json_array_clear]

fun json_array_extend
  {l1,l2:agz} (
  json1: !JSONptr (l1), json2: !JSONptr (l2)
) : int(*err*) = "mac#atsctrb_json_array_extend"

(* ****** ****** *)

fun json_object
  ((*void*)) : JSONptr0 = "mac#atsctrb_json_object"
// end of [json_object]

fun json_object_size
  {l:agz} (json: !JSONptr l): size_t = "mac#atsctrb_json_object_size"
// end of [json_object_size]

fun json_object_get
  {l1:agz} (
  json: !JSONptr l1, key: NSH(string)
) : [l2:addr]
  (minus (JSONptr l1, JSONptr l2) | JSONptr l2) = "mac#atsctrb_json_object_get"
// end of [json_object_get]

fun json_object_set
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1)
, key: NSH(string)
, value: !JSONptr l2(*preserved*)
) : int(*err*) = "mac#atsctrb_json_object_set"

fun json_object_set_nocheck
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1)
, key: NSH(string)
, value: !JSONptr l2(*preserved*)
) : int(*err*) = "mac#atsctrb_json_object_set_nocheck"

fun json_object_set_new
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1)
, key: NSH(string)
, value: JSONptr l2 /*consumed*/
) : int(*err*) = "mac#atsctrb_json_object_set_new"

fun json_object_set_new_nocheck
  {l1:agz}{l2:addr} (
  json: !JSONptr (l1)
, key: NSH(string)
, value: JSONptr l2 /*consumed*/
) : int(*err*) = "mac#atsctrb_json_object_set_new_nocheck"

fun json_object_del
  {l:agz} (
  json: !JSONptr l, key: NSH(string)
) : int(*err*) = "mac#atsctrb_json_object_del"

fun json_object_clear
  {l:agz} (json: !JSONptr l): int(*err*) = "mac#atsctrb_json_object_clear"
// end of [json_object_clear]

fun json_object_update
  {l1:agz}{l2:addr} (
  json1: !JSONptr l1, json2: !JSONptr l2
) : int(*err*) = "mac#atsctrb_json_object_update"

(* ****** ****** *)

typedef json_err = json_error_t

fun json_loads (
  inp: NSH(string)
, flags: int, error: &json_err?
) : JSONptr0 = "mac#atsctrb_json_loads"

fun json_loadb
  {lb:addr}
  {n1,n2:int | n1 >= n2} (
  pfbuf: !bytes(n1) @ lb | pbuf: ptr lb, n2: size_t n2
, flags: int, error: &json_err?
) : JSONptr0 = "mac#atsctrb_json_loadb"

fun json_loadf (
  inp: FILEref
, flags: int, error: &json_err?
) : JSONptr0 = "mac#atsctrb_json_loadf"

fun json_load_file (
  path: NSH(string)
, flags: int, error: &json_err?
) : JSONptr0 = "mac#atsctrb_json_load_file"

(* ****** ****** *)

fun json_dumps
  {l:agz}
  (root: !JSONptr l, flags: int): strptr0 = "mac#atsctrb_json_dumps"
// end of [json_dumps]

fun json_dumpf
  {l:agz} (
  root: !JSONptr l
, out: FILEref, flags: int
) : int(*err*)
  = "mac#atsctrb_json_dumpf"

fun json_dump_file
  {l:agz} (
  root: !JSONptr l
, path: NSH(string), flags: int
) : int(*err*)
  = "mac#atsctrb_json_dump_file"

(* ****** ****** *)

(* end of [jasson.sats] *)

////

fun json_object_iter
  {l1:agz} (
    json: !JSONptr (l1,0)
  ) : [l2:addr] (minus(JSONptr (l1,0), JSONiter l2) | JSONiter l2)
  = "mac#atsctrb_json_object_iter"

fun json_object_iter_at
  {l1:agz} (
    json: !JSONptr (l1,0), key: string
  ) : [l2:addr] (minus(JSONptr (l1,0), JSONiter l2) | JSONiter l2)
  = "mac#atsctrb_json_object_iter_at"

fun json_object_iter_next
  {l1:agz} (
    json: !JSONptr (l1,0), iter: !JSONiter1
  ) : [l2:addr] (minus(JSONptr (l1,0), JSONiter l2) | JSONiter l2)
  = "mac#atsctrb_json_object_iter_next"

fun json_object_iter_key
  (
    iter: !JSONiter1
  ) : string = "mac#atsctrb_json_object_iter_key"

fun json_object_iter_value
  (
    iter: !JSONiter1
  ) : [l:agz] JSONptr (l, 0) = "mac#atsctrb_json_object_iter_value"

fun json_object_iter_set
  {l1, l2, l3:agz} {n1, n2:int} (
    json: !JSONptr (l1, n1), iter: !JSONiter l3, value: !JSONptr (l2, n2)
  ) : int = "mac#atsctrb_json_object_iter_set"

fun json_object_iter_set_new
  {l1, l2, l3:agz} {n1, n2:int} (
    json: !JSONptr (l1, n1), iter: !JSONiter l3, value: JSONptr (l2, n2)
  ) : int = "mac#atsctrb_json_object_iter_set_new"


// TODO: JSON_INDENT
macdef JSON_COMPACT   = $extval (int, "JSON_COMPACT")
macdef JSON_ENSURE_ASCII   = $extval (int, "JSON_ENSURE_ASCII")
macdef JSON_SORT_KEYS   = $extval (int, "JSON_SORT_KEYS")
macdef JSON_PRESERVE_ORDER   = $extval (int, "JSON_PRESERVE_ORDER")
macdef JSON_ENCODE_ANY   = $extval (int, "JSON_ENCODE_ANY")
