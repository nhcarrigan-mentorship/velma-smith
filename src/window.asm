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
; Create a UNIX domain socket and connect to the X11 server.
; @returns The Socket file descriptor
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
  
  cmp rax, 0  ; check return value of previous syscall
  jle die

  mov rdi, rax  ; store socket fd in `rdi`

  sub rsp, 112  ; make room for sock_addr struct 

  mov WORD [rsp], AF_UNIX ; set socket family to AF_UNIX

  ; fill structs sun_path with: "/tmp/.X11-unix/X0"
  lea rsi, sun_path
  mov r12, rdi ; store socket fd in `r12`
  lea rdi, [rsp + 2]
  cld
  mov ecx, 19
  rep movsb
  
  ; Connect to the server: connect(2).
  mov rax, SYSCALL_CONNECT
  mov rdi, r12
  lea rsi, [rsp]
  %define SIZEOF_SOCKADDR_UN 2+108
  mov rdx, SIZEOF_SOCKADDR_UN
  syscall

  cmp rax, 0 ; check return value of previous syscall 
  jne die

  mov rax, rdi ; Return the socket file descriptor

  add rsp, 112 
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
  call x11_connect_to_server
  jmp exit
