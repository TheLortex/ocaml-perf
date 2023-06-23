type type' = Hardware

let int_of_type = function
  | Hardware -> C.Type.perf_type_hardware

type config = Count_hw_cpu_cycles

let int_of_config = function
  | Count_hw_cpu_cycles -> C.Type.perf_count_hw_cpu_cycles

type sample = Period of int | Freq of int

let int_of_sample = function
  | None -> 0L
  | Some (Period v) | Some (Freq v) -> Int64.of_int v

type sample_type = Identifier

let int_of_sample_type = function
  | Identifier -> C.Type.perf_sample_identifier

type read_format = Total_time_enabled | Total_time_running

let int_of_read_format = function
  | Total_time_enabled -> C.Type.perf_format_total_time_enabled
  | Total_time_running -> C.Type.perf_format_total_time_running

type precise_ip = Arbitrary | Constant | Requested_zero | Must_zero

let int_of_precise_ip = function
  | Arbitrary -> 0
  | Constant -> 1
  | Requested_zero -> 2
  | Must_zero -> 3

type perf_event_attr = {
  type': type'; (* u32 *)
  (* size u32 *)
  config: config; (* u64 *)
  sample: sample option; (* u64 *)
  sample_type: sample_type; (* u64 *)
  read_format: read_format list; (* u64 *)
  (* single u64 *)
  disabled: bool;
  inherit': bool;
  pinned: bool;
  exclusive: bool;
  exclude_user: bool;
  exclude_kernel: bool;
  exclude_hv: bool;
  exclude_idle: bool;
  precise_ip: precise_ip;
  (* *)
}

let flag c ofs value =
  if c then
    Int64.logor value (Int64.shift_left 1L ofs)
  else
    value

let int_of_flags v =
  let open Int64 in
  0L
  |> (flag v.disabled 0)
  |> (flag v.inherit' 1)
  |> (flag v.pinned 2)
  |> (flag v.exclusive 3)
  |> (flag v.exclude_user 4)
  |> (flag v.exclude_kernel 5)
  |> (flag v.exclude_idle 6)
  |> (Int64.(logor (shift_left (of_int (int_of_precise_ip v.precise_ip)) 8)))

let serialize_to_bytes v bytes =
  let open Bytes in
  set_int32_ne bytes 0 (int_of_type v.type');
  set_int32_ne bytes 4 0x88l;
  set_int64_ne bytes 8 (int_of_config v.config);
  set_int64_ne bytes 16 (int_of_sample v.sample);
  set_int64_ne bytes 24 (int_of_sample_type v.sample_type);
  set_int64_ne bytes 32 (List.map int_of_read_format v.read_format |> List.fold_left (Int64.logor) 0L);
  set_int64_ne bytes 40 (int_of_flags v)

external ml_perf_open : bytes -> int -> int -> int -> int -> Unix.file_descr = "ml_perf_open"


type flags = Fd_cloexec

let int_of_flag = fun Fd_cloexec -> C.Type.perf_flag_fd_cloexec

let event_open ?(pid = -1) ?(cpu = -1) ?(group_fd = -1) ~flags attr =
  let bytes = Bytes.create 0x88 in
  serialize_to_bytes attr bytes;
  ml_perf_open bytes pid cpu group_fd (List.map int_of_flag flags |> List.fold_left (Int.logor) 0)

external ml_ioctl : Unix.file_descr -> int -> int -> unit = "ml_perf_ioctl"

let event_reset fd =
  ml_ioctl fd C.Type.perf_event_ioc_reset 0

let event_disable fd =
  ml_ioctl fd C.Type.perf_event_ioc_reset 0

let event_enable fd =
  ml_ioctl fd C.Type.perf_event_ioc_enable 0
