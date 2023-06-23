type type' = Hardware

type config = Count_hw_cpu_cycles

type sample = Period of int | Freq of int

type sample_type = Identifier

type read_format = Total_time_enabled | Total_time_running

type precise_ip = Arbitrary | Constant | Requested_zero | Must_zero

type perf_event_attr = {
  type' : type';
  config : config;
  sample : sample option;
  sample_type : sample_type;
  read_format : read_format list;
  disabled : bool;
  inherit' : bool;
  pinned : bool;
  exclusive : bool;
  exclude_user : bool;
  exclude_kernel : bool;
  exclude_hv : bool;
  exclude_idle : bool;
  precise_ip : precise_ip;
}

type flags = Fd_cloexec

val event_open :
  ?pid:int ->
  ?cpu:int ->
  ?group_fd:int -> flags:flags list -> perf_event_attr -> Unix.file_descr

val event_reset : Unix.file_descr -> unit

val event_enable : Unix.file_descr -> unit

val event_disable : Unix.file_descr -> unit
