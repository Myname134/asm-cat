section .data
    err_open db "Error opening file", 10
    err_len  equ $ - err_open

section .bss
    buffer   resb 4096

section .text
    global _start

_start:
    mov rbx, [rsp]        ; argc
    cmp rbx, 2
    jl exit

    lea r12, [rsp+16]     ; &argv[1]

next_file:
    mov rsi, [r12]        ; current argv pointer
    test rsi, rsi
    jz exit               ; stop at NULL

    ; openat(AT_FDCWD, filename, O_RDONLY, 0)
    mov rax, 257
    mov rdi, -100
    mov rdx, 0
    mov r10, 0
    syscall

    test rax, rax
    js open_error

    mov r13, rax          ; fd

read_loop:
    mov rax, 0            ; read
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 4096
    syscall

    test rax, rax
    jle close_file

    mov rdx, rax
    mov rax, 1            ; write
    mov rdi, 1
    mov rsi, buffer
    syscall
    jmp read_loop

close_file:
    mov rax, 3
    mov rdi, r13
    syscall

    add r12, 8
    jmp next_file

open_error:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_open
    mov rdx, err_len
    syscall

    add r12, 8
    jmp next_file

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

