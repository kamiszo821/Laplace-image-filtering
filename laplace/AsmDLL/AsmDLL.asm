.data
	LAPLACE_MASK SDWORD 1, 1, 1, 1, -8, 1, 1, 1, 1

.code
laplacianFilterAsm proc EXPORT
	
	local iter_x: QWORD
	local iter_y: QWORD
	local x_max: QWORD
	local y_max: QWORD
	local image_width: QWORD
	local height: QWORD
	local newImage: QWORD
	local image: QWORD
	local sumR: SDWORD 
    local sumG: SDWORD 
    local sumB: SDWORD 

	mov sumR, 0							; zeruje zmienne
	mov sumG, 0
	mov sumB, 0
	mov iter_x, 0
	mov iter_y, 0
	XOR r12, r12
	VXORPS ymm0, ymm0, ymm0
	VXORPS ymm1, ymm1, ymm1
	VXORPS ymm2, ymm2, ymm2
	VXORPS ymm3, ymm3, ymm3
	VMOVUPS ymm3, LAPLACE_MASK+4
	VCVTDQ2PS ymm3, ymm3
	mov image, rcx						; wskaünik na tablicÍ ze zdjÍciem
	mov rax, 3 						    ; zapisanie width i height w zmiennych
	mul rdx
	mov image_width, rax
	mov height, r8

	mov newImage, r9					; zapisanie wskaünika na tablicÍ z rezultatem
					
	sub rax, 6							; ustawienie iter_x_max i iter_y_max
	mov x_max, rax
	sub r8, 2
	mov y_max, r8

PETLAY:									; pÍtla po wartoúciach y
	mov rcx, 0
	inc iter_y
	mov iter_x, 0

PETLAX:									; pÍtla po wartoúciach x
	add iter_x, 3

	mov sumR, 0						
	mov sumG, 0
	mov sumB, 0

; #################### TOP LEFT ############################
	; kaødy kolejny punkt jest przetwarzany analogicznie 					

	mov rax, iter_y		
	dec rax

	; top left pixel BLUE

	mul image_width
	add rax, iter_x
	add rax, image ; adres wyliczony tutaj
	sub rax, 1

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d
	pslldq xmm0, 4

	; top left pixel GREEN
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d
	pslldq xmm1, 4

	; top left pixel RED
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d
	pslldq xmm2, 4

; #################### TOP MIDDLE ############################
	add rax, 5
	; top mid pixel BLUE
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d
	pslldq xmm0, 4

	; top mid pixel GREEN	
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d
	pslldq xmm1, 4
	
	; top mid pixel RED
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d
	pslldq xmm2, 4

; #################### TOP RIGHT ############################

	add rax, 5
	; top right pixel BLUE
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d
	pslldq xmm0, 4

	; top right pixel GREEN	
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d
	pslldq xmm1, 4

		; top right pixel RED
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d
	pslldq xmm2, 4


; #################### MIDDLE LEFT ############################

	; middle left pixel BLUE
	mov rax, iter_y	
	mul image_width
	add rax, iter_x
	sub rax, 1				
	add rax, image

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d

	; top left pixel GREEN
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d

	; top left pixel RED
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d

	;#########
	;YMMM shift
	VPERM2F128 ymm0, ymm0, ymm0, 1
	VPERM2F128 ymm1, ymm1, ymm1, 1
	VPERM2F128 ymm2, ymm2, ymm2, 1
	;#########
; #################### MIDDLE MIDDLE ############################
	add rax, 5
	; middle mid pixel BLUE
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d
	pslldq xmm0, 4

	; middle mid pixel GREEN	
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d
	pslldq xmm1, 4
	
	; middle mid pixel RED
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d
	pslldq xmm2, 4


; #################### MIDDLE RIGHT ############################

	add rax, 5
	; middle right pixel BLUE
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d
	pslldq xmm0, 4

	; middle right pixel GREEN	
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d
	pslldq xmm1, 4
	
	; middle right pixel RED
	dec rax
	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d
	pslldq xmm2, 4

; #################### BOTTOM LEFT ############################
	
	; bottom left pixel BLUE
	mov rax, iter_y		
	inc rax				
	mul image_width
	add rax, iter_x
	sub rax, 1
	add rax, image

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d
	pslldq xmm0, 4
	; bottom left pixel GREEN
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d
	pslldq xmm1, 4
	; bottom left pixel RED
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d
	pslldq xmm2, 4
; #################### BOTTOM MIDDLE ############################
	add rax, 5
	; bottom middle pixel BLUE

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm0, r12d

	; top left pixel GREEN
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm1, r12d

	; top left pixel RED
	sub rax, 1			

	mov r12b, byte ptr [rax]
	CVTSI2SS xmm2, r12d

	; obliczenia i dodawanie do sum.

	VMULPS YMM0, YMM0, YMM3
	VMULPS YMM1, YMM1, YMM3
	VMULPS YMM2, YMM2, YMM3
	VCVTPS2DQ YMM0, YMM0
	VCVTPS2DQ YMM1, YMM1
	VCVTPS2DQ YMM2, YMM2

	xor rax, rax
    
	mov rcx, 4
	get_lower_lane:
	PEXTRD eax, xmm0, 0
	psrldq xmm0, 4
	add sumB, eax
	PEXTRD eax, xmm1, 0
	psrldq xmm1, 4
	add sumG, eax
	PEXTRD eax, xmm2, 0
	psrldq xmm2, 4
	add sumR, eax
	loop get_lower_lane 
	;#########
	;YMMM shift
	VPERM2F128 ymm0, ymm0, ymm0, 1
	VPERM2F128 ymm1, ymm1, ymm1, 1
	VPERM2F128 ymm2, ymm2, ymm2, 1
	;#########
	mov rcx, 4
	get_upper_lane:
	PEXTRD eax, xmm0, 0
	psrldq xmm0, 4
	add sumB, eax
	PEXTRD eax, xmm1, 0
	psrldq xmm1, 4
	add sumG, eax
	PEXTRD eax, xmm2, 0
	psrldq xmm2, 4
	add sumR, eax
	loop get_upper_lane 

	; #################### BOTTOM RIGHT ############################

	; bottom right pixel BLUE
	mov rax, iter_y	
	inc rax				
	mul image_width
	add rax, iter_x
	add rax, 5
	add rax, image
	mov r10b, [rax]
	xor rax, rax
	mov al, r10b
	imul [LAPLACE_MASK + 32]
	add sumB, eax

	; bottom right pixel GREEN
	mov rax, iter_y	
	inc rax				
	mul image_width
	add rax, iter_x
	add rax, 4
	add rax, image
	mov r10b, [rax]
	xor rax, rax
	mov al, r10b
	imul [LAPLACE_MASK + 32]
	add sumG, eax


		; bottom right pixel RED
	mov rax, iter_y	
	inc rax				
	mul image_width
	add rax, iter_x
	add rax, 3				
	add rax, image
	mov r10b, [rax]
	xor rax, rax
	mov al, r10b
	imul [LAPLACE_MASK + 32]
	add sumR, eax

	; normalizowanie sum
	
	xor rax, rax
	mov eax, sumR
	cmp sumR, 255		; por√≥wnanie z warto≈õciƒÖ g√≥rnƒÖ (255)
	JL LESS_R
	mov eax, 255		; ograniczenie warto≈õci do max 255
	mov sumR, eax
	JMP GREEN
LESS_R:
	cmp eax, 0			; por√≥wnanie do warto≈õci minimalnej
	JG GREEN
	mov eax, 0			; ograniczenie warto≈õci minimalnej
	mov sumR, eax

	; pozosta≈Çe kolory analogicznie

GREEN:
	xor rax, rax
	mov eax, sumG
	cmp sumG, 255		
	JL LESS_G
	mov eax, 255
	mov sumG, eax
	JMP BLUE
LESS_G:
	cmp eax, 0
	JG BLUE
	mov eax, 0
	mov sumG, eax

BLUE:
	xor rax, rax
	mov eax, sumB
	cmp sumB, 255		
	JL LESS_B
	mov eax, 255
	mov sumB, eax
	JMP SAVE
LESS_B:
	cmp eax, 0
	JG SAVE
	mov eax, 0
	mov sumB, eax

SAVE:					; zapisywanie nowych warto≈õci punktu do tablicy

	mov rcx, 3
; saving RED value
	mov rax, iter_y		; przej≈õcie do odpowiedniego Y
	mul image_width		; przesuniƒôcie do miejsca w tablicy
	add rax, iter_x		; przej≈õcie do odpowiedniego X
	add rax, 0				; ustawienie czerwonego koloru (R=0, G=1, B=2)
	add rax, newImage		; przej≈õcie do odpowiedniego miejsca w pamiƒôci
	mov r10d, sumR
	mov [rax], r10b			; zapisanie

	; saving GREEN value
	mov rax, iter_y		
	mul image_width
	add rax, iter_x
	add rax, 1				; ustawienie zielonego
	add rax, newImage
	mov r10d, sumG
	mov [rax], r10b

	; saving BLUE value
	mov rax, iter_y		
	mul image_width
	add rax, iter_x
	add rax, 2				; ustawienie niebieskiego
	add rax, newImage
	mov r10d, sumB
	mov [rax], r10b

	mov rax, iter_x		;koniec petli x
	cmp rax, x_max
	JB PETLAX

	mov rax, iter_y		;koniec petli y
	cmp rax, y_max
	JB PETLAY

	ret

laplacianFilterAsm endp

end