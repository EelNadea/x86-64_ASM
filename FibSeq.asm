section .data
	newline db 0xA

section .text
	global _start

_start:
	mov rbp, rsp
	sub rsp, 48

	; [rbp-1] to [rbp-20] for the printable characters, 20 bytes

	mov qword [rbp-32], 0		; int a (the number that will be printed)
	mov qword [rbp-40], 1		; int b
	mov qword [rbp-48], 0		; int c

loop_start:

	; r12 and r13 are passed as arguments
	lea r12, [rbp-32]		; Load address of 'a'
	lea r13, [rbp-20]		; Load address of char buffer
	call get_indiv_nums

	mov rax, qword [rbp-32]		; Load a
	mov qword [rbp-48], rax		; c = a

	mov rax, qword [rbp-40]		; Load b
	add qword [rbp-48], rax		; c += b
	jc exit				; Exit if the "add" instruction results in unsigned overflow (carry flag set)

	mov rax, qword [rbp-40]		; Load b
	mov qword [rbp-32], rax		; a = b

	mov rax, qword [rbp-48]		; Load c
	mov qword [rbp-40], rax		; b = c

	jmp loop_start

exit:
	mov rax, 60			; sys_exit
	mov rdi, 0
	syscall

get_indiv_nums:
	push rbp
	mov rbp, rsp
	sub rsp, 16

	mov byte [rbp-1], 0		; "Counter"

	mov qword [rbp-16], r13		; Save address of char buffer
	mov rax, [r12]			; Load dividend from address in r12

get_indiv_nums_loop:
	xor rdx, rdx			; Clear rdx
	mov rcx, 10
	div rcx				; rax = quotient, rdx = remainder

	movzx rbx, byte [rbp-1]		; Store the counter into rbx
	add rdx, 0x30			; Add 0x30 to convert the digit into a its ascii character
	mov byte [r13+rbx], dl		; Store the remainder. 'r13' contains the address of the chars buffer in "_start" stack frame

	inc byte [rbp-1]		; Increment "Counter"

	test rax, rax			; Check if 'rax' is equal to zero. If it is, then all digits are now split
	jnz get_indiv_nums_loop

print_nums:

	; 'r13' contains the address [rbp-24] in the "_start" stack frame.
	; Add the value "counter-1" into r13 to obtain the address of the last stored character
	movzx rbx, byte [rbp-1]
	mov r13, qword [rbp-16]
	add rbx, r13

print_nums_loop:
	dec rbx

	mov rax, 1			; sys_write
	mov rdi, 1			; fd:stdout
	mov rsi, rbx
	mov rdx, 1
	syscall

	cmp rbx, r13
	jnz print_nums_loop

	mov rax, 1			; sys_write
	mov rdi, 1			; fd:stdout
	mov rsi, newline
	mov rdx, 1
	syscall

	mov rsp, rbp
	pop rbp
	ret
