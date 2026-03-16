section .data
    err_open db "Error opening file", 10
    err_len  equ $ - err_open

    err_read db "Error reading file", 10 
    err_read_len equ $ - err_read 

section .bss
    buffer   resb 4096

section .text
    global _start

_start:
    mov rbx, [rsp]
    cmp rbx, 1 
    jle read_stdin 

    lea r12, [rsp+16]
    jmp next_file

read_stdin: 
  xor r13, r13  

stdin_loop: 
  mov rax, 0 
  mov rdi, r13 
  mov rsi, buffer 
  mov rdx, 4096 
  syscall 

  test rax, rax
  js read_error 
  jz exit 

  mov rdx, rax 
  mov rax, 1 
  mov rdi, 1 
  mov rsi, buffer 
  syscall 
jmp stdin_loop 

next_file:
    mov rsi, [r12]
    test rsi, rsi
    jz exit

    mov rax, 257
    mov rdi, -100
    mov rdx, 0
    mov r10, 0
    syscall

    test rax, rax
    js open_error

    mov r13, rax

read_loop:
    mov rax, 0
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 4096
    syscall

    test rax, rax
    js read_error 
    jz close_file
     

    mov rdx, rax
    mov rax, 1
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

read_error: 
  mov rax, 1 
  mov rdi, 2  
  mov rsi, err_read 
  mov rdx, err_read_len 
  syscall 
  jmp exit  

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

