.intel_syntax noprefix
.globl _start

.section .text

_start:
    # Create socket
    mov rdi, 2
    mov rsi, 1
    mov rdx, 0
    mov rax, 41     # SYS_socket
    syscall

    mov rbx, rax    # move fd to rbx to use later on

    # Allocate space for sockaddr_in struct on stack
    sub rsp, 16
    
    # sockaddr_in struct
    mov word ptr [rsp], 2              # sin_family: AF_INET
    mov word ptr [rsp + 2], 0x5000     # sin_port: Port number 80
    mov dword ptr [rsp + 4], 0x00000000# sin_addr: IP address 0.0.0.0
    mov qword ptr [rsp + 8], 0         # sin_zero: 8 bytes of padding

    # Bind socket
    mov rdi, rbx       # socket file descriptor
    mov rsi, rsp       # pointer to struct sockaddr
    mov rdx, 16        # sizeof(struct sockaddr)
    mov rax, 49        # SYS_bind
    syscall            # invoke syscall

    # Listen socket
    mov rdi, rbx
    mov rsi, 0
    mov rax, 50
    syscall

    # Accept connection
    mov rdi, rbx
    xor rsi, rsi    # xor to set rsi and rdx to NULL
    xor rdx, rdx
    mov rax, 43
    syscall

    mov rbx, rax    # move file descriptor from accepted connection to rbx

    # Read
    mov rdi, rbx
    mov rsi, rsp
    mov rdx, 256
    mov rax, 0
    syscall

    # Open
    mov byte ptr [rsp+20], 0    # set the 20th char as the escape sequence
    lea rdi, [rsp+4]            # load the file path from the 4th char
    mov rsi, 0
    mov rax, 2
    syscall

    mov rbp, rax  # fd from open
    mov rcx, rdi  # move file path to rcx

    # Read
    mov rdi, rbp
    mov rsi, rcx
    mov rdx, 1024
    mov rax, 0
    syscall

    mov r8, rax   # move file length in r8

    # Close
    mov rdi, rbp
    mov rax, 3
    syscall

    # Write
    mov rdi, rbx
    mov rsi, offset response
    mov rdx, 19
    mov rax, 1
    syscall

    # Write
    mov rdi, rbx
    add rsp, 4
    mov rsi, rsp
    mov rdx, r8
    mov rax, 1
    syscall

    # Close
    mov rdi, rbx
    xor rsi, rsi
    xor rdx, rdx
    mov rax, 3
    syscall

    # Exit program
    mov rdi, 0
    mov rax, 60     # SYS_exit
    syscall

.section .data
    response: .asciz "HTTP/1.0 200 OK\r\n\r\n"
