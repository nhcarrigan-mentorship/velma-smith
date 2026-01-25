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

x11_connect_to_server:
static x11_connect_to_server:function
  push rbp
  mov rbp, rsp

  ; open a unix socket
  mov rax, SYSCALL_SOCKET
  mov rdi, AF_UNIX
  mov rsi, SOCK_STREAM
  mov rdx, 0
  syscall
  
  cmp rax, 0
  jle die

  mov rdi, rax  ; store socket fd in `rdi`

  sub rsp, 112

  mov WORD [rsp], AF_UNIX

  lea rsi, sun_path
  mov r12, rdi
  lea rdi, [rsp + 2]
  cld
  mov ecx, 19
  rep movsb
  
  pop rbp
  ret

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

  jmp exit
