(*
** FALCON project
*)

(* ****** ****** *)
//
typedef
print_type (a:t@ype) = (a) -> void
typedef
fprint_type (a:t@ype) = (FILEref, a) -> void
//
(* ****** ****** *)

abstype symbol_type = ptr
typedef symbol = symbol_type

(* ****** ****** *)
//
fun print_symbol : (symbol) -> void
fun fprint_symbol : fprint_type (symbol)
//
overload print with print_symbol
overload fprint with fprint_symbol
//
(* ****** ****** *)
//
fun symbol_make (string): symbol
fun symbol_get_name (symbol): string
fun symbol_compare : (symbol, symbol) -> int
//
symintr .name
overload .name with symbol_get_name
overload compare with symbol_compare
//
(* ****** ****** *)

abstype gene_type = ptr
typedef gene = gene_type

(* ****** ****** *)

(*
** BB-2014: |genes| < 50
*)
absvtype genes_vtype = ptr
vtypedef genes = genes_vtype

(* ****** ****** *)

fun genes_union (xs: genes, ys: genes): genes

(* ****** ****** *)

absvtype GDMap_vtype = ptr
vtypedef GDMap = GDMap_vtype

fun gDMap_make_nil (): GDMap
fun gDMap_free (gdm: GDMap): void

fun gDMap_find (!GDMap, g: gene): double
fun gDMap_insert (mp: !GDMap, g: gene, dval: double): bool

(* ****** ****** *)

(* end of [falcon.sats] *)
