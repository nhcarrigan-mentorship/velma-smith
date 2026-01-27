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
extern load_xauth_env

exit:
  mov rax, SYSCALL_EXIT
  xor edi, edi
  syscall

_start:
global _start:function
  call x11_connect_to_server
  mov rax, r12
  call x11_send_handshake
  jmp exit
