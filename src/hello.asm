BITS 64

section .data
    text db "Hello, World!",10
    prompt db "Enter a number between 1-10: ",0
    promptLen equ $ - prompt
    fun_text db "The best function has been called.", 10
    fun_textLen equ $ - fun_text

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

    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    syscall

    call best_function
    
    call random
    
    jmp _exit
    
_exit:
    mov rax, 60
    mov rdi, 0
    syscall

best_function:
    xor rsi, rsi

    mov rax, 1
    mov rdi, 1
    mov rsi, fun_text
    mov rdx, fun_textLen
    syscall
    ret

random:
    rdrand rax
    jnc random

    xor rdx, rdx
    mov rcx, 10
    div rcx
    inc rdx
    ret

string_to_int:
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
    

