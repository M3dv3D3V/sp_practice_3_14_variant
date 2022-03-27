extern printf
extern scanf


section .data
    size_array_message:             db "Size array (NxN):", 10, 0
    size_array_value_string         db "%d", 0
    message_random_array            db "========== Random array ==========", 10, 0
    message_result_array:           db "========== New array ==========", 10, 0

    digit_print           db "%d", 10, 0

section .bss
    size_array:         resb 8      ; (N)
    offset_row_max:     resb 4096
    offset_row:         resb 4096
    array:              resb 4096
    result_array:       resb 4096


SECTION .text                       ; Code section.
global create_array_from_largest_elements
create_array_from_largest_elements:
    push rbp ;setup stack

    lea rdi, [size_array_message]       ; print (message for array size)
    xor rax, rax
    call printf

    lea rdi, [size_array_value_string]     ; scanf array size
    lea rsi, [size_array]
    xor rax, rax
    call scanf

    xor rax, rax
    mov rdx, [size_array]
    mov rax, 4
    mul rdx
    mov [offset_row], rax           ; calculate offset for row (for 3*3 offset - 4 * 3 = 12 byte)

    xor rax, rax
    mov rax, [size_array]
    mul rax
    xor rdx, rdx
    mov rdx, 4
    mul rdx                             ; calculate maximum_offset_for_row (for 3*3 - 3*3*4 = 36 bytes)
    mov [offset_row_max], rax
    
    ; filling array random numbers
    mov r13, 0 ; counter
    mov r14, 0 ; row
    mov r15, 0 ; column
    for_start:

        for_internal:
            rdtscp
            and rax, 0x00000000000fffff
            mov [array + r14 + r15], rax        ; filling array random numbers

            add r15, 4
            cmp r15, [offset_row]                                ; if pointer for column on the last element
            jne for_internal
            jmp for_internal_end
        
        for_internal_end:
            add r14, [offset_row] ; new row address
            mov r15, 0


        add r13, 4
        cmp r14, [offset_row_max]
        jne for_start
        jmp for_end

    for_end:

    lea rdi, [message_random_array]       ; print (message for array size)
    xor rax, rax
    call printf

    ; print first array from random numbers
    mov r13, 0  ; counter for cycle
    start_print_array:
        mov rax, [size_array]
        add rax, rax
        mul rax
        cmp r13, rax                  ; condition for exit from cycle
        je end_print_array

        mov r8, [array+r13]
        ; output Enter message...
        lea rdi, [digit_print] ;first argument
        mov rsi, r8 ; second argument
        xor rax, rax
        call printf

        add r13, 4
        jmp start_print_array

    end_print_array:

    ; cycle for calculate maximum number and create new array
    mov r8, 0   ; for search maximum number
    mov r9, 0
    mov r13, 0 ; counter
    mov r14, 0 ; row
    mov r15, 0 ; column
    for_start_new_array:

        for_internal_new_array:
            mov rcx, [array + r14 + r15]        ; element in current row
            cmp rcx, r8
            jg new_maximum
            jmp not_maximum

            new_maximum:
                mov r8, [array + r14 + r15]

            not_maximum:

            add r15, 4
            cmp r15, [offset_row]                                ; if pointer for column on the last element
            jne for_internal_new_array
            jmp for_internal_end_new_array
        
        for_internal_end_new_array:
            add r14, [offset_row] ; new row address
            mov r15, 0

            mov [result_array + r9], r8
            mov r8, 0
            add r9, 4

        add r13, 4
        cmp r14, [offset_row_max]
        jne for_start_new_array
        jmp for_new_array_end

    for_new_array_end:

    ; duct tape for checking last element
    mov rax, [size_array]                   
    mov rdx, 4
    mul rdx
    mov r14, [result_array+rax]             ; last element in random array
    mov r8, rax                            ; save offset for last element

    xor rax, rax
    mov rax, [size_array]
    mul rax
    mov rdx, 4
    mul rdx
    mov r15, [array+rax]                    ; last element in array

    cmp r14, r15
    jg is_more_last_element
    jmp is_not_more_last_element

    is_more_last_element:
        mov [result_array+r8-4], r14

    is_not_more_last_element:

    lea rdi, [message_result_array]       ; print (message for array size)
    xor rax, rax
    call printf

    mov r13, 0  ; counter for cycle
    start_print_result_array:
        mov rax, [size_array]
        mov rdx, 4
        mul rdx
        cmp r13, rax                  ; condition for exit from cycle
        je end_print_result_array

        mov r8, [result_array+r13]
        ; output Enter message...
        lea rdi, [digit_print] ;first argument
        mov rsi, r8 ; second argument
        xor rax, rax
        call printf

        add r13, 4
        jmp start_print_result_array

    end_print_result_array:
        pop rbp

    mov     rax, 60         ; "exit" function number
    xor     rdi, rdi        ; error code (0)
    syscall                 ; terminate the program