let attr = {
  Perf.type' = Hardware;
  config = Count_hw_cpu_cycles;
  sample = None;
  sample_type = Identifier;
  read_format = [Total_time_enabled; Total_time_running];
  disabled = false;
  inherit' = true;
  pinned = false;
  exclusive = false;
  exclude_user = false;
  exclude_kernel = false;
  exclude_hv = false;
  exclude_idle = false;
  precise_ip = Arbitrary
}

let init_global_fds () =
  (* number of CPUs *)
  List.init 8 @@ fun cpu ->
  Perf.event_open ~cpu ~flags:[Fd_cloexec] attr

let global_fds = lazy (init_global_fds ())

type state = {
  fds: Unix.file_descr list
}

let init () = {fds = init_global_fds ()}

type t = {
  cycles_self: int64;
  cycles_total: int64;
}

type measurement = {
    cycles: int64;
    time_enabled: int64;
    time_running: int64;
}

let measurement_zero = {
  cycles = 0L;
  time_enabled = 0L;
  time_running = 0L;
}

let measurement_add m1 m2 =
  let ( + ) = Int64.add in
  {
    cycles = m1.cycles + m2.cycles;
    time_enabled = m1.time_enabled + m2.time_enabled;
    time_running = m1.time_running + m2.time_running
  }

let measurement_sub m1 m2 =
  let ( - ) = Int64.sub in
  {
    cycles = m1.cycles - m2.cycles;
    time_enabled = m1.time_enabled - m2.time_enabled;
    time_running = m1.time_running - m2.time_running
  }

type pending = {
  start_self: measurement;
  start_all: measurement;
  fd: Unix.file_descr;
}

let measure fd =
  let bytes = Bytes.create 24 in
  let _ = Unix.read fd bytes 0 24 in
  {
    cycles = Bytes.get_int64_ne bytes 0;
    time_enabled = Bytes.get_int64_ne bytes 8;
    time_running = Bytes.get_int64_ne bytes 16;
  }


let start {fds} =
  let fd = Perf.event_open ~pid:0 ~flags:[Fd_cloexec] attr in
  {
    start_self = measure fd;
    start_all = (List.map measure fds |> List.fold_left measurement_add measurement_zero);
    fd;
  }

let cycles { cycles; time_enabled; time_running } =
  let open Int64 in
  let dilation = (Int64.to_float time_enabled) /. (Int64.to_float time_running) in
  Printf.printf ">> %Ld %f %f\n" cycles (Int64.to_float time_running) (Int64.to_float time_enabled);
  Printf.printf ">> %f\n" dilation;
  (* cycles / real cycles = time_running / time_enabled *)
  (* real cycles = time_enabled / time_running * cycle *)
  if Int64.equal cycles Int64.zero then
    0L
  else
    Int64.of_float (dilation *. Int64.to_float cycles)

let stop {fds} {start_self; start_all;fd} =
  let end_self = measure fd in
  Unix.close fd;
  let end_all = List.map measure fds |> List.fold_left measurement_add measurement_zero in
  let delta_self = measurement_sub end_self start_self in
  let cycles_self = cycles delta_self in
  Printf.printf ".\n";
  let delta_all = measurement_sub end_all start_all in
  let cycles_total = cycles delta_all in
  {cycles_self; cycles_total }

let total_cycles t = t.cycles_total

let cycles t = t.cycles_self
