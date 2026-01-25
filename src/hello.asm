BITS 64

%ifdef LINUX
  %define SYSCALL_EXIT 60
%elifdef FREEBSD
  %define SYSCALL_EXIT 1
%endif


section .data
    text db "Hello, World!",10
    prompt db "Enter a number between 1-10: ",0
    promptLen equ $ - prompt
    fun_text db "The best function has been called.", 10
    fun_textLen equ $ - fun_text
    fail_text db "Wrong. Try Again!", 10
    fail_textLen equ $ - fail_text
    success_text db "You succeeded! :3"
    success_textLen equ $ - success_text
    continue_text db "Continue?", 10
    continue_textLen equ $ - continue_text

section .bss
    buffer resb 16

section .text
    global _start
 
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, text
    mov rdx, 14
    syscall
.prompt: 
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, promptLen
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 16
    syscall

    call atoi

    mov r10, rax

    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    syscall

    call random
    
    cmp r10, r11
    
    jne failure

    jmp _exit
    
_exit:
    mov rax, SYSCALL_EXIT
    mov rdi, 0
    syscall

failure:
    xor rsi, rsi

    mov rax, 1
    mov rdi, 1
    mov rsi, fail_text
    mov rdx, fail_textLen
    syscall
    jmp _start.prompt 

random:
    rdrand rax
    jnc random

    xor rdx, rdx
    mov rcx, 10
    div rcx
    inc rdx
    mov r11, rdx

    ret

atoi:
    xor rax, rax
    mov rsi, buffer
.loop:
    movzx rcx, byte [rsi]

    cmp rcx, 10
    je .done
    cmp rcx, 0
    je .done

    cmp rcx, '0'
    jl .done
    cmp rcx, '9'
    jg .done

    sub rcx, '0'
    imul rax, 10
    add rax, rcx

    inc rsi
    jmp .loop
.done:
    ret

  
continue:
    mov rax, 1
    mov rdi, 1 
    mov rsi, continue_text
    mov rdx, continue_textLen
    syscall
    
    lea rdi, [buffer]
    mov rcx, 2
    xor eax, eax
    cld
    rep stosq

    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 15
    syscall

    mov byte [rsi + rax], 0
    syscall


