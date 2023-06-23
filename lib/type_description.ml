open Ctypes

module Types (F : Ctypes.TYPE) = struct
  open F

  let perf_type_hardware = constant "PERF_TYPE_HARDWARE" int32_t
  let perf_count_hw_cpu_cycles = constant "PERF_COUNT_HW_CPU_CYCLES" int64_t
  let perf_sample_identifier = constant "PERF_SAMPLE_IDENTIFIER" int64_t
  let perf_format_total_time_enabled = constant "PERF_FORMAT_TOTAL_TIME_ENABLED" int64_t
  let perf_format_total_time_running = constant "PERF_FORMAT_TOTAL_TIME_RUNNING" int64_t
  let perf_flag_fd_cloexec = constant "PERF_FLAG_FD_CLOEXEC" int

  let perf_event_ioc_reset = constant "PERF_EVENT_IOC_RESET" int
  let perf_event_ioc_enable = constant "PERF_EVENT_IOC_ENABLE" int
  let perf_event_ioc_disable = constant "PERF_EVENT_IOC_DISABLE" int
end
