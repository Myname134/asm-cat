global _start
section .bss 
  buffer resb 4096 

section .text 
_start:
.read_loop:
  mov rax, 0
  mov rdi, 0
  mov rsi, buffer 
  mov rdx, 4096 
  syscall 

  cmp rax, 0
  je .exit 
  jl .exit 

  mov rdi, 1
  mov rdx, rax 
  mov rax, 1
  syscall 

  jmp .read_loop 

.exit: 
  mov rax, 60
  xor rdi, rdi 
  syscall 


