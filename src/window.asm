BITS 64
%define EXIT_ERROR 1
%define SYSCALL_EXIT 60

%define AF_UNIX 1
%define SOCK_STREAM 1
%define SYSCALL_SOCKET 41
%define SYSCALL_CONNECT 42

%define STDOUT 1
%define SYSCALL_WRITE 1

%ifdef FREEBSD
  %define SYSCALL_EXIT 1
%endif

section .rodata

sun_path: db "/tmp/.X11-unix/X0", 0
static sun_path:data

section .text

extern x11_connect_to_server
extern x11_send_handshake

exit:
  mov rax, SYSCALL_EXIT
  xor edi, edi
  syscall

die:
  mov rax, SYSCALL_EXIT
  mov rdi, EXIT_ERROR
  syscall

_start:
global _start:function
  call x11_connect_to_server
  call x11_send_handshake
  jmp exit
