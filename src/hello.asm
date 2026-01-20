BITS 64

section .data
    text db "Hello, World!",10
    prompt db "Enter a number between 1-10: ",0
    promptLen equ $ - prompt

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

    mov rax, 1
    mov rdi, 1
    mov rdx, 16
    syscall

    mov rax, 60
    mov rdi, 0
    syscall


