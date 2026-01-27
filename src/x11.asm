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

env_not_found_mes: db "ENV var unable to load from stack", 10
env_not_found_mes_len: equ $ - env_not_found_mes

sun_path: db "/tmp/.X11-unix/X0", 0
static sun_path:data

section .bss

x11_buffer_len equ 4096
x11_buffer resb x11_buffer_len

section .data

x11_setup:
  db 'l'
  db 0
  dw 11
  dw 0
  dw 0
  dw 0
  dw 0
x11_setup_len equ $ - x11_setup

section .text
; Create a UNIX domain socket and connect to the X11 server.
; @returns The Socket file descriptor
global x11_connect_to_server
x11_connect_to_server:
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

  leave
  ret

global x11_send_handshake
x11_send_handshake:
  push rbp

  mov rbp, rsp
  
  sub rsp, 1<<15

  mov BYTE [rsp + 0], 'l'
  mov word [rsp + 2], 11
  ; syscall write setup packet to initiate handshake
  mov rax, SYSCALL_WRITE
  mov rdi, rdi
  lea rsi, x11_setup
  mov rdx, x11_setup_len
  syscall

  cmp rax, 12
  jnz die

  ; syscall read to read response
  mov rax, 0
  mov rdi, r12    ; the file descriptor of the socket
  mov rsi, x11_buffer
  mov rdx, x11_buffer_len
  syscall

  leave
  ret


; @param rdi - pointer to envp array
;
global load_xauth_env
load_xauth_env:
  push rbp
  mov rbp, rsp

.loop:
  mov rdx, [rdi]  ; pointer to current env string
  test rdx, rdx
  jz .env_not_found   ; if it's null jump to failure
  
  mov rax, [rdx]
  mov r8, `XAUTHORI`
  cmp rax, r8
  je .check_suffix  ; if match, check the "TY=" part

.next_env:
  add rdi, 8 ; Next pointer in envp array
  jmp .loop

.check_suffix:
  mov eax, [rdx + 8]
  and eax, 0x00FFFFFF ; clear the 4th byte to avoid garbage data like \0
  mov r8d, `TY=`
  cmp eax, r8d
  jne .next_env  ; handle as a partial match if necessary

  lea rax, [rdx + 11] ; Success! return pointer to the value
  jmp .done
.env_not_found:
  mov rax, SYSCALL_WRITE
  mov rdi, STDOUT
  mov rsi, env_not_found_mes
  mov rdx, env_not_found_mes_len
  syscall

  jmp die
.done: 
  leave
  ret

die:
  mov rax, SYSCALL_EXIT
  mov rdi, EXIT_ERROR
  syscall


