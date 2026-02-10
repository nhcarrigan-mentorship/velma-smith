%define SYSCALL_OPEN 2
%define SYSCALL_EXIT 60
%define SYSCALL_WRITE 1
%define STDOUT 1
%define EXIT_ERROR 2

extern cookie_space

section .rodata
  env_not_found_mes: db "ENV var unable to load from stack", 10
  env_not_found_mes_len: equ $ - env_not_found_mes
  cookie_fail_mes: db "FAILED TO FIND COOKIE", 10
  cookie_fail_mes_len: equ $ - cookie_fail_mes

section .bss
  auth_file_buf_size equ 1024
  auth_file_buf resb auth_file_buf_size
section .text
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
; retrieve the MIT-MAGIC-COOKIE-1 from the file
;
; @param rax - contains the path from load_xauth_env
global get_cookie_from_file
get_cookie_from_file:
  mov rdi, rax  ; path from load_xauth_env loaded into rdi as argument to syscall
  mov rsi, 0    ; O_RDONLY flag
  mov rax, SYSCALL_OPEN    ; open file
  syscall
  
  cmp rax, 0    ; error handling if negative = error
  jl .failure
  mov r12, rax ; store fd for later use

  mov rdi, r12
  lea rsi, [auth_file_buf]
  mov rdx, auth_file_buf_size
  mov rax, 0  ; read file into buffer
  syscall
  
  mov rcx, rax

  mov rdi, r12
  mov rax, 3    ; close file
  syscall
  
  lea rdi, [auth_file_buf]
.search:
  mov rax, [rdi]
  mov r8, `MIT-MAGI`
  cmp rax, r8
  je .found_prefix
  inc rdi
  loop .search
  jmp .failure

.found_prefix:
  mov rax, [rdi + 8]
  mov r8, `C-COOKIE`
  cmp rax, r8
  jne .retry_search
 ; cookie starts 20 bytes after 'M' (18 name + 2 pad for length) 
  lea rsi, [rdi + 20]
  lea rdi, [cookie_space] ; pointer to the handshake struct
  mov rcx, 16
  rep movsb
  ret

.retry_search:
  inc rdi
  jmp .search

.failure:
  mov r15, rax    ; Save the error code to check in gdb
  mov rax, SYSCALL_WRITE
  mov rdi, STDOUT
  mov rsi, cookie_fail_mes
  mov rdx, cookie_fail_mes_len
  syscall

  jmp die

die:
  mov rax, SYSCALL_EXIT
  mov rdi, EXIT_ERROR
  syscall

