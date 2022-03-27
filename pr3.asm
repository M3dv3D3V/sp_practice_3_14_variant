extern printf
extern scanf


section .data
    size_array_message:             db "Size array (NxN):", 10, 0
    size_array_value_string         db "%d", 0
    message_random_array            db "========== Random array ==========", 10, 0
    message_result_array:           db "========== New array ==========", 10, 0

    digit_print                     db "%d", 10, 0

section .bss
    size_array:         resb 8      ; количество элементов массива
    offset_row_max:     resb 4096   ; максимальный адрес смещения
    offset_row:         resb 4096   ; переменная для смещения в моменте
    random_array:       resb 4096   ; массив для рандомных чисел
    result_array:       resb 4096


SECTION .text
global create_array_from_largest_elements
create_array_from_largest_elements:
    push rbp ;setup stack

    lea rdi, [size_array_message]    ; вывод сообщения о размере массива
    xor rax, rax
    call printf

    lea rdi, [size_array_value_string]     ; заполнения переменной размера массива
    lea rsi, [size_array]
    xor rax, rax
    call scanf

    xor rax, rax
    mov rdx, [size_array]
    mov rax, 4
    mul rdx
    mov [offset_row], rax           ; вычисление смещения для строки (3*3 смещение - 4 * 3 = 12 байт) 

    xor rax, rax
    mov rax, [size_array]
    mul rax
    xor rdx, rdx
    mov rdx, 4
    mul rdx                             ; вычисление смещения для строки (для 3*3 - 3*3*4 = 36 байт) 
    mov [offset_row_max], rax
    
    ; заполнение массива рандомными числами
    mov r13, 0 ; counter
    mov r14, 0 ; row
    mov r15, 0 ; column
    for_start:

        for_internal:
            rdtscp
            and rax, 0x00000000000fffff
            mov [random_array + r14 + r15], rax        ; запись рандомного числа в массив

            add r15, 4
            cmp r15, [offset_row]                      ; если указатель для столбца на последнем элементе
            jne for_internal
            jmp for_internal_end
        
        for_internal_end:
            add r14, [offset_row]                      ; новый адрес строки
            mov r15, 0


        add r13, 4
        cmp r14, [offset_row_max]
        jne for_start
        jmp for_end

    for_end:

    lea rdi, [message_random_array]                     ; вывезти сообщение "========== Random array =========="
    xor rax, rax
    call printf

    ; print first array from random numbers
    ; вывести первый массив из рандомых чисел
    mov r13, 0                                          ; счетчик для цикла
    start_print_array:
        mov rax, [size_array]
        add rax, rax
        mul rax
        cmp r13, rax                                    ; условие для выхода из цикла
        je end_print_array

        mov r8, [random_array+r13]
        ; вывод элемента массива
        lea rdi, [digit_print]
        mov rsi, r8
        xor rax, rax
        call printf

        add r13, 4
        jmp start_print_array

    end_print_array:

    ; цикл для вычисления максимального значения в строке и запись в новый массив
    mov r8, 0   ; для поиска максимального элемента
    mov r9, 0
    mov r13, 0 ; счетчик
    mov r14, 0 ; счетчик для строки
    mov r15, 0 ; счетчик для столбца
    for_start_new_array:

        for_internal_new_array:
            mov rcx, [random_array + r14 + r15]        ; элемент в текущей строке
            cmp rcx, r8
            jg new_maximum
            jmp not_maximum

            new_maximum:
                mov r8, [random_array + r14 + r15]

            not_maximum:

            add r15, 4
            cmp r15, [offset_row]                       ; если указатель для столбца на последнем элемент
            jne for_internal_new_array
            jmp for_internal_end_new_array
        
        for_internal_end_new_array:
            add r14, [offset_row]                       ; новый адрес строки
            mov r15, 0

            mov [result_array + r9], r8
            mov r8, 0
            add r9, 4

        add r13, 4
        cmp r14, [offset_row_max]
        jne for_start_new_array
        jmp for_new_array_end

    for_new_array_end:

    ; костыль для проверки последнего элемента
    mov rax, [size_array]                   
    mov rdx, 4
    mul rdx
    mov r14, [result_array+rax]                         ; последний элемент в случайном массиве
    mov r8, rax                                         ; сохранить смещение для последнего элемента

    xor rax, rax
    mov rax, [size_array]
    mul rax
    mov rdx, 4
    mul rdx
    mov r15, [random_array+rax]                         ; последний элемент в массиве

    cmp r14, r15
    jg is_more_last_element
    jmp is_not_more_last_element

    is_more_last_element:
        mov [result_array+r8-4], r14

    is_not_more_last_element:

    lea rdi, [message_result_array]                     ; вывод "========== New array =========="
    xor rax, rax
    call printf

    mov r13, 0                                          ; счетчик для цикла
    start_print_result_array:
        mov rax, [size_array]
        mov rdx, 4
        mul rdx
        cmp r13, rax                                    ; условие для выхода из цикла
        je end_print_result_array

        mov r8, [result_array+r13]
        lea rdi, [digit_print]
        mov rsi, r8
        xor rax, rax
        call printf

        add r13, 4
        jmp start_print_result_array

    end_print_result_array:
        pop rbp

    mov     rax, 60         ; системный вызов для завершения работы
    xor     rdi, rdi
    syscall