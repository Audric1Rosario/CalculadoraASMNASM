; Macros de impresion
%macro imprime 2 ; 2 parametros: salida, salidalen (la string y su longitud)
mov eax, 4 	; escribe
mov ebx, 1	; 
mov ecx, %1 ; cadena
mov edx, %2 ; longitud
int 0x80 ; imprimir
%endmacro

; salto de linea simplificado. 
%macro saltodelinea 0
imprime salto, saltolen
%endmacro

global main
extern printf, scanf

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
section .data
;   para captura de numeros
    scan_format: db "%f",0
    print_format_a: db "A: %d",0xA,0
	print_format_b: db "B: %d",0xA,0
;   para imprimir numeros.
	print_format_a_hex: db "A-hex: %x",0xA,0
	print_format_a_oct: db "A-oct: %o",0xA,0
	print_format_b_hex: db "B-hex: %x",0xA,0
	print_format_b_oct: db "B-oct: %o",0xA,0
;   para imprimir resultados
	; coma flotante
	print_sum: db "Operacion A+B: %f", 0xA, 0
	print_res: db "Operacion A-B: %f", 0xA, 0
	print_mul: db "Operacion AxB: %f", 0xA, 0
	print_div: db "Operacion A/B: %f", 0xA, 0
	; hexadecimal
	print_sum_hex: db "Operacion A+B: %x", 0xA, 0
	print_res_hex: db "Operacion A-B: %x", 0xA, 0
	print_mul_hex: db "Operacion AxB: %x", 0xA, 0
	print_div_hex: db "Operacion A/B: %x", 0xA, 0
	; octal
	print_sum_oct: db "Operacion A+B: %o", 0xA, 0
	print_res_oct: db "Operacion A-B: %o", 0xA, 0
	print_mul_oct: db "Operacion AxB: %o", 0xA, 0
	print_div_oct: db "Operacion A/B: %o", 0xA, 0
	
;   para imprimir mensajes piloto
    ingresar_a db "Ingrese numero A: ", 0
    ingresar_a_len equ $ - ingresar_a
    ingresar_b db "Ingrese numero B: ", 0
    ingresar_b_len equ $ - ingresar_b
    error db "B no puede ser igual a 0 para dividir a A.", 0xA, 0
    error_len equ $ - error
    
    msg1 db "Operaciones con flotantes: ", 0xA, 0
    msg1_len equ $ - msg1
    
    msg2 db "Resultados: ", 0xA, 0
    msg2_len equ $ - msg2
    
    msgdec db "Numeros decimales: ", 0xA, 0
    msgdec_len equ $ - msgdec
    
    msghex db "Operaciones con hexadecimales: ", 0xA, 0
    msghex_len equ $ - msghex
    
    msgoct db "Operaciones con octales: ", 0xA, 0
    msgoct_len equ $ - msgoct
; para salto de linea.
	salto db 0xA, 0xD
	saltolen equ $ - salto

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
section .bss ; espacio en memoria 
    ; Variables flotantes. 
    result_num: 		resb 4 ; aqui guardo el numero A
    result_num_a: 		resb 4 ; aqui guardo el numero B
    sum_num:			resb 8 ; aqui va la suma
    sub_num:			resb 8 ; aqui va la resta
    mul_num:			resb 8 ; aqui va la multiplicacion
    div_num:			resb 8 ; aqui va la division
    ; suma, resta, multiplicacion y division son los resultados
    ; Variables enteras
    result_num_dub: 	resb 4 ; valor entero de result_num
    result_num_dub_a:	resb 4 ; valor entero de result_num_A
    sum_num_dub:		resb 4 ; valor entero de la suma
    sub_num_dub:		resb 4 ; valor entero de la resta
    mul_num_dub:		resb 4 ; valor entero de la multiplicacion
    div_num_dub:		resb 4 ; valor entero de la division 


; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
section .text
main:
    ; -- Avisar que ingrese A
	imprime ingresar_a, ingresar_a_len
	; leer a
    push result_num		; agregamos el espacio en memoria al stack
    push scan_format	; agregamos el formato de lectura
    call scanf			; llamamos a scanf
    add esp, 8			; leemos float de 32 bits
    ; -- Avisar que ingrese B
    imprime ingresar_b, ingresar_b_len
	; leer b
    push result_num_a   ; mismo procedimiento
    push scan_format
    call scanf
    add esp, 8
    
    ; procedimiento... 
	saltodelinea
	
	imprime msg1, msg1_len
	; Nota: los resultados se imprimen en float 64
	; suma 
	sub esp, 8
	fld  dword [result_num]			; Cargo mi valor A
	fadd dword [result_num_a]       ; le aplico la operacion con el valor B
	fstp qword [sum_num]            ; guardo el valor float64 resultante en sum_num
	push dword[sum_num+4]           ; guardo la parte alta de sum_num (MSB) en el stack para imprimir
	push dword[sum_num]             ; guardo la parte baja de sum_num (LSB)
	push print_sum                  ; imprimo
	call printf
	add esp, 12

; Mismo procedimiento para las demas operaciones. 
	; resta
	sub esp, 8
	fld  dword [result_num]
	fsub dword [result_num_a]
	fstp qword [sub_num]
	push dword[sub_num+4]
	push dword[sub_num]
	push print_res
	call printf
	add esp, 12
	
	; multiplicacion
	sub esp, 8
	fld  dword [result_num]
	fmul dword [result_num_a]
	fstp qword [mul_num]
	push dword[mul_num+4]
	push dword[mul_num]
	push print_mul
	call printf
	add esp, 12
	
	; division
	; Si B es 0 entonces no se puede dividir
	mov eax, [result_num_a] ; muevo el valor de b a eax para compararlo con 0
	cmp eax, 0              ; si es 0 entonces saltar al mensaje
	je ErrMensaje           ; saltar al mensaje
	
	sub esp, 8 ; mismo procedimiento de la suma, resta, multiplicacion
	fld  dword [result_num]
	fdiv dword [result_num_a]
	fstp qword [div_num]
	push dword[div_num+4]
	push dword[div_num]
	push print_div
	call printf
	add esp, 12
	
	jmp continuar
	ErrMensaje:             ; presentar que es imposible dividir entre 0
	imprime error, error_len
	
	continuar: ; continuar... 
	
	; convertir
    ; imprimir: 
    ; para imprimir, simplemente tomare la parte entera, e imprimo ese entero en las bases hexadecimal y octal.
    
    ; Convertir de flotante a entero
    ; A
    fld 	dword [result_num]		; primero cargo mi flotante
    fistp 	dword [result_num_dub]  ; despues convierto a entero con fistp.
    ; B
    fld 	dword [result_num_a]	; mismo proceso
    fistp 	dword [result_num_dub_a]
    ; Suma
    fld 	qword[sum_num]
    fistp	dword[sum_num_dub]
    ; Resta
    fld 	qword[sub_num]
    fistp	dword[sub_num_dub]
    ; Multiplicacion
    fld 	qword[mul_num]
    fistp	dword[mul_num_dub]
    
    ; Si B es 0 entonces no se puede dividir
	mov eax, [result_num_a]
	cmp eax, 0
    je cont
    ; lo mismo que cuando obtuvimos el valor
    ; Division
    fld 	qword[div_num]
    fistp	dword[div_num_dub]
    
    cont:
    
    ; Imprime el valor en decimal
    ; imprimo los valores en enteros
    saltodelinea
    imprime msg2, msg2_len
    imprime msgdec, msgdec_len
    push dword [result_num_dub]   ; guardar numero en el stack
    push print_format_a		   	  ; guardar formato de impresion
    call printf
    add esp, 12   ; 12 bits a esp para retornar flotante en un sistema de 32 bits,
    
    push dword [result_num_dub_a]    
    push print_format_b
    call printf
    add esp, 12   
    
    ; Imprime el valor en hexadecimal -------------------------------------------------------------------------------------------------------------------------------------------------------------------
    saltodelinea
    imprime msghex, msghex_len
    push dword [result_num_dub]    ; simplemente tomar el valor convertido de float a int, y imprimirlo
    push print_format_a_hex        ; como es printf, a un valor entero %x lo imprimira como un hexadecimal
    call printf
    add esp, 12   
    
    push dword [result_num_dub_a]  ; Mismo procedimiento  
    push print_format_b_hex
    call printf
    add esp, 12   
    ; suma
    push dword [sum_num_dub]    
    push print_sum_hex
    call printf
    add esp, 12
    ; resta
    push dword [sub_num_dub]    
    push print_res_hex
    call printf
    add esp, 12   
    ; multiplicacion
    push dword [mul_num_dub]    
    push print_mul_hex
    call printf
    add esp, 12   
    
    ; Si B es 0 entonces no se puede dividir
	mov eax, [result_num_a]
	cmp eax, 0
    je conta
    ; Si B es = 0 entonces esto nunca se muestra
    ; division
    push dword [div_num_dub]    
    push print_div_hex
    call printf
    add esp, 12   
    
    conta:
    
    ; Imprime valor en octal ------------------------------------------------------------------------------------------------------------------------------------------------------------------
    saltodelinea
    imprime msgoct, msgoct_len
    push dword [result_num_dub]    
    push print_format_a_oct  	; como es printf, a un valor entero %o lo imprimira como un octal
    call printf
    add esp, 12   
    
    push dword [result_num_dub_a]    
    push print_format_b_oct
    call printf
    add esp, 12   
    
    ; suma
    push dword [sum_num_dub]    
    push print_sum_oct
    call printf
    add esp, 12
    ; resta
    push dword [sub_num_dub]    
    push print_res_oct
    call printf
    add esp, 12   
    ; multiplicacion
    push dword [mul_num_dub]    
    push print_mul_oct
    call printf
    add esp, 12   
    
    ; Si B es 0 entonces no se puede dividir
	mov eax, [result_num_a]
	cmp eax, 0
    je contb
    ; Si B es = 0 entonces esto nunca se muestra
    ; division
    push dword [div_num_dub]    
    push print_div_oct
    call printf
    add esp, 12   
    
    contb:
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ; salir, programa terminado
    xor ebx, ebx
    mov eax, 1
    int 0x80
    
    ret
