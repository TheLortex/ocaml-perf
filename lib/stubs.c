#include "caml/mlvalues.h"
#include "caml/alloc.h"
#include <caml/memory.h>

#include <linux/perf_event.h>    /* Definition of PERF_* constants */
#include <linux/hw_breakpoint.h> /* Definition of HW_* constants */
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>

value ml_perf_open(value attr, value pid, value cpu, value group_fd, value flags) {
  CAMLparam1(attr);
  CAMLreturn(Val_int(syscall(SYS_perf_event_open, Bytes_val(attr), Int_val(pid), Int_val(cpu), Int_val(group_fd), Int_val(flags))));
}

value ml_perf_ioctl(value fd, value k, value v) {
  ioctl(Int_val(fd), Int_val(k), Int_val(v));
  return Val_unit;
}