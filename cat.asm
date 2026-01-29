global _start
section .bss
  buffer resb 4096
  fd resq 1 

section .text 
_start:
  mov rax, [rsp]
  cmp rax, 2
  jl use_stdin 

  mov rdi, [rsp+16]
  mov rax, 2
  xor rsi, rsi 
  syscall 

  cmp rax, 0
  jl exit 

  mov [rel fd], rax 
  jmp read_loop 

use_stdin: 
  mov qword [rel fd], 0

read_loop:
  mov rax, 0
  mov rdi, [rel fd]
  mov rsi, buffer 
  mov rdx, 4096 
  syscall 

  cmp rax, 0
  jle exit 

  mov rdi, 1
  mov rdx, rax 
  mov rax, 1
  syscall 

  jmp read_loop 

exit:
  mov rax, 60
  xor rdi, rdi 
  syscall 



