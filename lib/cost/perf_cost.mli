type pending

type state

type t

val init : unit -> state

val start : state -> pending

val stop : state -> pending -> t

val cycles : t -> int64

val total_cycles : t -> int64
