BITS 64

%define SYSCALL_EXIT 60
%ifdef FREEBSD
  %define SYSCALL_EXIT 1
%endif

%define SYSCALL_WRITE 1
%define STDOUT 1

section .text
global _start
_start:
  xor rax, rax
  call print_hello
  jmp exit
exit:
  mov rax, SYSCALL_EXIT
  mov rdi, 0
  syscall

print_hello:
    push rbp
    mov rbp, rsp

    sub rsp, 16  ; save 16 bytes of space on the stack
    mov BYTE [rsp + 0], 'h'
    mov BYTE [rsp + 1], 'e'
    mov BYTE [rsp + 2], 'l'
    mov BYTE [rsp + 3], 'l'
    mov BYTE [rsp + 4], 'o'
    mov BYTE [rsp + 5], ' '
    
    mov rax, SYSCALL_WRITE
    mov rdi, STDOUT
    lea rsi, [rsp]
    mov rdx, 6
    syscall

    call print_world

    add rsp, 16
    pop rbp
    ret

print_world:
    push rbp
    mov rbp, rsp

    sub rsp, 16
    mov BYTE [rsp + 0], 'w'
    mov BYTE [rsp + 1], 'o'
    mov BYTE [rsp + 2], 'r'
    mov BYTE [rsp + 3], 'l'
    mov BYTE [rsp + 4], 'd'
    mov BYTE [rsp + 5], 10

    mov rax, SYSCALL_WRITE
    mov rdi, STDOUT
    lea rsi, [rsp]
    mov rdx, 6
    syscall

    add rsp, 16

    pop rbp
    ret


  
