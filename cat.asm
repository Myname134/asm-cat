%define STDIN  0
%define STDOUT 1
%define STDERR 2

%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_OPEN  2
%define SYS_CLOSE 3
%define SYS_EXIT  60

%define BUF_SIZE 4096

global _start

section .bss
buffer resb BUF_SIZE
fd     resq 1

section .rodata
open_err db "cat: Cannot open file", 10
open_err_len equ $ - open_err

section .text
_start:
    mov rax, [rsp]        
    cmp rax, 2
    jl use_stdin

    mov rdi, [rsp+16]     
    mov rax, SYS_OPEN
    xor rsi, rsi          
    syscall

    cmp rax, 0
    jl open_failed

    mov [rel fd], rax
    jmp read_loop

open_failed:
    mov rdi, STDERR
    mov rsi, open_err
    mov rdx, open_err_len
    mov rax, SYS_WRITE
    syscall

   
    mov rax, [rsp+16]     
    mov rdi, 1
    mov rax, SYS_EXIT
    syscall

use_stdin:
    mov qword [rel fd], STDIN

read_loop:
    mov rax, SYS_READ
    mov rdi, [rel fd]
    mov rsi, buffer
    mov rdx, BUF_SIZE
    syscall

    cmp rax, 0
    jle exit_file

    
    mov rcx, rax
    mov rbx, buffer

write_loop:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rbx
    mov rdx, rcx
    syscall
    cmp rax, 0
    jl write_failed

    sub rcx, rax
    add rbx, rax
    jnz write_loop

    jmp read_loop

write_failed:
    neg rax
    mov rdi, rax
    mov rax, SYS_EXIT
    syscall

exit_file:
    mov rax, [rel fd]
    cmp rax, STDIN
    je exit_program
    mov rdi, rax
    mov rax, SYS_CLOSE
    syscall

exit_program:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

