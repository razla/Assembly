section .data
	num1:		dq 2.0		
	num2:		dq 4.0
	num3:		dq 3.0
	num4:		dq 4.0
	minOne:		dq -1.0	;; minus one
	zero:		dq '\n' ;; new line
	epsilonStr:	db "epsilon = %lf ", 0
	orderStr:	db "order = %d ", 0
	coeffStr:	db "coeff %d", 0
	initialStr:	db "initial = %lf %lf", 0
	coeffDouble:db " = %lf %lf " , 0
	formatD:	db "%lf", 10 , 0 ;; saves the format to print
	formatI:	db "%d", 10 , 0 ;; saves the format to print
	result5:	db "root = %.16e %.16e" , 10 , 0
	loopIndex:	db 0
	index1:		db 1
	index2:		db 0

section .bss
	add_r:		resq 1 ;; saves the real value after addition
	add_i:		resq 1 ;; saves the imaginary value after addition
	sub_r:		resq 1 ;; saves the real value after substruction
	sub_i:		resq 1 ;; saves the imaginary value after substruction
	mul_r:		resq 1 ;; saves the real value after multiplication
	mul_i:		resq 1 ;; saves the imaginary value after multiplication
	div_r:		resq 1 ;; saves the real value after division
	div_i:		resq 1 ;; saves the imaginary value after division
	cmplxReal:	resq 1 ;; saves the real double of the complex number
	cmplxImg:	resq 1 ;; saves the imaginary double of the complex number
	epsilon:	resq 1 ;; saves the epsilon value
	order:		resq 1 ;; saves the order of the func
	coeff:		resq 1 ;; saves the coeff
	coeffIndex: 	resq 1 ;; saves the coeff index
	initialReal:	resq 1 ;; saves the real double of the initial number
	initialImg:	resq 1 ;; saves the real double of the initial number
	initFinalReal:	resq 1 ;;
	initFinalImg:	resq 1 ;;
	func:	 	resq 1 ;; pointer to the array of the func
	derivative:	resq 1 ;; pointer to the array of the derivative
	evalFuncReal:	resq 1 ;;
	evalFuncImg:	resq 1 ;;
	evalDerivReal:	resq 1 ;;
	evalDerivImg:	resq 1 ;;
	normalReal:	resq 1 ;;
	normalImg:	resq 1 ;;

	extern printf, scanf, calloc , malloc
	global _add
	global _sub
	global _mul
	global _div
	global main

	section .text
		%macro _add 4	;; addition of 4 doubles and returns to the add_i add_r ;;
			enter 0,0
			finit
			fld %1
			fld %3
			faddp
			fstp qword [add_r]
			fld qword %2
			fld qword %4
			faddp
			fstp qword [add_i]
		%endmacro
		%macro _sub 4	;; substruction of 4 doubles and returns to the sub_i sub_r ;;
			enter 0,0
			finit
			fld %1
			fld %3
			fsubp
			fstp qword [sub_r]
			fld %2
			fld %4
			fsubp
			fstp qword [sub_i]
		%endmacro
		%macro _mult 4	;; multiplication of 4 doubles and returns to the 1st 2 args ;;
			enter 0,0
			finit
			fld %1
			fld %3
			fmulp
			fld qword [minOne]
			fld %2
			fmulp
			fld %4
			fmulp
			faddp
			fstp qword [mul_r]
			fld %1
			fld %4
			fmulp
			fld %2
			fld %3
			fmulp
			faddp
			fstp qword [mul_i]
		%endmacro
		%macro _divide 4	;; division of 4 doubles ;;
			enter 0,0
			finit
			fld %1
			fld %3
			fmulp
			fld %2
			fld %4
			fmulp
			faddp
			fld %3
			fld %3
			fmulp
			fld %4
			fld %4
			fmulp
			faddp
			fdivp
			fstp qword [div_r]
			fld %2
			fld %3
			fmulp
			fld %1
			fld %4
			fmulp
			fsubp
			fld %3
			fld %3
			fmulp
			fld %4
			fld %4
			fmulp
			faddp
			fdivp
			fstp qword [div_i]
		%endmacro

		;start:
		main:
			enter 0,0
			finit

			;;; reads the epsilon from the user ;;;

			lea rdi, [epsilonStr]
			lea rsi, [epsilon]
			call scanf

			;;; reads the order from the user ;;;

			lea rdi, [orderStr]
			lea rsi, [order]
			call scanf
			;;; allocates memory for the func real numbers array ;;;

			mov rax, [order]
			inc rax
			sal rax, 4
			mov rdi, rax
			call malloc
			mov qword [func], rax ;; returns the pointer from calloc		

			mov rax, [order]
			inc rax
			sal rax, 4
			mov rdi, rax
			call malloc
			mov qword [derivative], rax ;; returns the pointer from calloc	

			mov r15, qword[order] ;; sets register 15 to order given
			inc r15

			;;; reading coefficients for the func ;;;

			reading_coeff_loop:
				finit
				cmp r15, 0
				je stoping_coeff_loop

				;;; reads the coefficient index given ;;;
				
				lea rdi, [coeffStr]
				lea rsi, [coeffIndex]
				call scanf

				;;; reads the coefficient[index] double given ;;;

				lea rdi, [coeffDouble]
				lea rdx, [cmplxImg]
				lea rsi, [cmplxReal]
				call scanf

			test3:
				;;; inserts the complex num to the array ;;;
				
				mov r11, qword [coeffIndex]
				sal r11, 4
				add r11, [func] ;; inserts the func pointer to r11
				fld qword [cmplxReal]
				fstp qword [r11]
				add r11, 8
				fld qword [cmplxImg] 
				fstp qword [r11]

				fild qword [coeffIndex];;
				ftst
				fstsw ax
				sahf

				fld qword [cmplxReal]
				fild qword [coeffIndex]
				fmulp
			test4:
				mov r11, [coeffIndex]
				cmp r11, 0
				je done
				mov r11, [coeffIndex]
				sub r11, 1
				sal r11, 4
				add r11, [derivative]
				fstp qword [r11]
				add r11, 8
				fld qword [cmplxImg]
				fild qword [coeffIndex]
				fmulp
				fstp qword [r11]

			done:

				;;; decreases index of loop ;;;

				dec r15
				jmp reading_coeff_loop

			stoping_coeff_loop:

				;;; reads the initial number ;;;

				mov rdi, initialStr
				mov rsi, initialReal
				mov rdx, initialImg
				mov rax, 0
				call scanf	

				newton_raphson_loop:

				evaluate_func_z:
					finit
					fldz
					fst qword[evalFuncReal]
					fstp qword[evalFuncImg]
					mov r15, qword [order] 
					finit
					mov r11, r15
					sal r11, 4
					add r11, [func]
					
					eval_Func_Loop:
						
						cmp r15, 0
						jl eval_Normal
						_add qword[evalFuncReal], qword[evalFuncImg], qword[r11], qword[r11+8]
						fld qword[add_r]
						fstp qword[evalFuncReal]
						fld qword[add_i]
						fstp qword[evalFuncImg]
						cmp r15, 0
						je eval_Normal
						_mult qword[evalFuncReal], qword[evalFuncImg], qword[initialReal], qword[initialImg]
						fld qword[mul_r]
						fstp qword[evalFuncReal]
						fld qword[mul_i]
						fstp qword[evalFuncImg]
						sub r15, 1
						sub r11, 16
						jmp eval_Func_Loop

					eval_Normal:

						finit
						fld qword [evalFuncReal]
						fld qword [evalFuncReal]
						fmulp
						fstp qword [normalReal]
						fld qword [evalFuncImg]
						fld qword [evalFuncImg]
						fmulp
						fstp qword[normalImg]
						fld qword [normalReal]
						fld qword [normalImg]
						faddp 
						fstp qword [normalReal]
						fld qword [normalReal]
						fsqrt
						fstp  qword [normalReal] 

					lower_then_Epsilon:
						
						fld qword[normalReal]
						fld qword[epsilon]
						fcomi st1
						ja finish

					evaluate_derivative_z:

						
						fldz
						fst qword[evalDerivReal]
						fstp qword[evalDerivImg]
						mov r15, qword [order] 

						mov r11, r15
						sal r11, 4
						add r11, [derivative]
						
						eval_Deriv_Loop:
							
							cmp r15, 0
							jl nextZ
							_add qword[evalDerivReal], qword[evalDerivImg], qword[r11], qword[r11+8]
							fld qword[add_r]
							fstp qword[evalDerivReal]
							fld qword[add_i]
							fstp qword[evalDerivImg]
							cmp r15, 0
							je nextZ
							_mult qword[evalDerivReal], qword[evalDerivImg], qword[initialReal], qword[initialImg]
							fld qword[mul_r]
							fstp qword[evalDerivReal]
							fld qword[mul_i]
							fstp qword[evalDerivImg]
							sub r15, 1
							sub r11, 16
							jmp eval_Deriv_Loop

						nextZ:
							
							_divide qword [evalFuncReal], qword [evalFuncImg] , qword [evalDerivReal], qword [evalDerivImg]
							_sub qword [initialReal], qword [initialImg], qword[div_r], qword [div_i]
							fld qword [sub_r]
							fstp qword [initialReal]
							fld qword [sub_i]
							fstp qword [initialImg]

							;mov rdi, formatD
							;mov rax, 1
							;movsd xmm0, qword [initialReal]
							;call printf
							;mov rdi, formatD
							;mov rax, 1
							;movsd xmm0, qword [initialImg]
							;call printf
							

						test89:
							jmp newton_raphson_loop
	

					finish:	
						enter 0,0
						finit
						mov rdi, result5
						movsd xmm0, qword[initialReal]
						movsd xmm1, qword[initialImg]
						mov rax, 2
						call printf
						mov r11, 5
						enter 0,0
						finit
						leave
