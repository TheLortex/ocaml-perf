(* let fd =
  Perf.(event_open ~cpu:(0) ~pid:(-1) ~flags:[] {
    type' = Hardware;
    config = Count_hw_cpu_cycles;
    sample = None;
    sample_type = Identifier;
    read_format = [Total_time_enabled; Total_time_running];
    disabled = true;
    inherit' = true;
    pinned = false;
    exclusive = false;
    exclude_user = false;
    exclude_kernel = false;
    exclude_hv = false;
    exclude_idle = false;
    precise_ip = Arbitrary
  })

let () =
  Perf.event_enable fd;
  let bytes = Bytes.create 24 in
  for i = 0 to 100 do
    let _ = Unix.read fd bytes 0 24 in
    Perf.event_reset fd;
    Perf.event_disable fd;
    Perf.event_enable fd;
    Printf.printf "OK: %12Ld\n%!" (Bytes.get_int64_ne bytes 0);
    Printf.printf "  : %12Ld\n%!" (Bytes.get_int64_ne bytes 8);
    Printf.printf "  : %12Ld\n%!" (Bytes.get_int64_ne bytes 16);
    Unix.sleepf 1.0
  done
 *)

 let () =
  let st = Perf_cost.init () in
  let v = Perf_cost.start st in
  for _ = 0 to 2000000000 do
    Sys.opaque_identity ()
  done;
  let e = Perf_cost.stop st v in
  Printf.printf "%Ld / %Ld\n" (Perf_cost.cycles e) (Perf_cost.total_cycles e)
