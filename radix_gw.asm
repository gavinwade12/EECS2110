; Gavin Wade - Radix Project
; This project uses the Irvine32 library; however, as noted in the
; instructions, it only uses the ReadChar and WriteChar procedures.
; The maximum radix this program accepts is 64, and the maximum size
; for Numbers A and B and the results produced from the arithmetic 
; performed on them is two bytes. It uses the same characters as other 
; common base64 encoders/decoders. The uppercase letters precede lowercase 
; letters as the base increases, with the 63rd and 64th characters being 
; '+' and '/' respectively. When using any radix below 33, uppercase letters
; and their respective lowercase counterparts have the same value.

include \Irvine\Irvine32.inc
includelib \Irvine\Irvine32.lib

.DATA
InputRadixMessage	DB	13, 10, 'Please enter the input radix (64 max, use digits, "h" or "H" for hex, or "x" or "X" to exit): ', 0
OutputRadixmessage	DB	13, 10, 'Please enter the output radix (64 max, use digits, "h" or "H" for hex, or "x" or "X" to exit): ', 0
InputNumberAMessage	DB	13, 10, 'Please enter the number A (2 byte max): ', 0
InputNumberBMessage	DB	13, 10, 'Please enter the number B (2 byte max): ', 0
NumberInputError	DB	13, 10, 'Oops! Something is wrong with your input. Please try again.', 0
SumMessage			DB	13, 10, 'A + B = ', 0
DifferenceMessage	DB	13, 10, 'A - B = ', 0
ProductMessage		DB	13, 10, 'A * B = ', 0
QuotientMessage		DB	13, 10, 'A / B = ', 0
ExponentMessage		DB	13, 10, 'A ^ B = ', 0
OverflowError		DB	' Experienced an overflow during this operation. Not printing incorrect results. Skipping...', 0
RadixPostfix		DB	' Base', ?, ?, 0
DecimalPostfix		DB	' Decimal', 0
RemainderPostfix	DB	' remainder ', 0
ArithmeticFlags		DB	? ; Signifies an overflow for sum, difference, product, and exponential results at bits 0, 1, 2, and 3 respectively
InputRadix			DB	?
OutputRadix			DB	?
LastInputRadix		DB	?
LastOutputRadix		DB	?
NumberA				DW	?
NumberB				DW	?
Sum					DW	?
Difference			DW	?
Product				DW	?
Quotient			DW	?
Remainder			DW	?
ExponentialResult	DW	?

.CODE
Main PROC
Cycle:
call GetParsedRadices
cmp dx, -1
je Shutdown
call GetNumbers
call Arithmetic
call OutputResults
jmp Cycle

Shutdown:
invoke ExitProcess, 0
Main ENDP

GetParsedRadices PROC NEAR ; dx = -1 signals a program exit
GetInputRadix:
xor ax, ax
lea ebx, InputRadixMessage
call WriteBytes
call ReadChar
call WriteChar
cmp al, 13H
je UseLastInput
cmp al, 'H'
je UseHexInput
cmp al, 'h'
je UseHexInput
cmp al, 'x'
je ExitSignal
cmp al, 'X'
je ExitSignal

sub al, '0'
cmp al, 1
jle GetInputRadix
cmp al, 9
jg GetInputRadix
mov LastInputRadix, al
call ReadChar
call WriteChar
cmp al, 13H
jmp UseLastInput
sub al, '0'
jl GetInputRadix
cmp al, 9
jg GetInputRadix
xchg LastInputRadix, al
mov ah, 10
mul ah
add LastInputRadix, al
jmp UseLastInput

UseHexInput:
mov LastInputRadix, 16

UseLastInput:
cmp LastInputRadix, 0
je GetInputRadix
mov dh, LastInputRadix
mov InputRadix, dh

GetOutputRadix:
xor ax, ax
lea ebx, OutputRadixMessage
call WriteBytes
call ReadChar
call WriteChar
cmp al, 13H
je UseLastOutput
cmp al, 'H'
je UseHexOutput
cmp al, 'h'
je UseHexOutput
cmp al, 'x'
je ExitSignal
cmp al, 'X'
je ExitSignal

sub al, '0'
cmp al, 1
jle GetOutputRadix
cmp al, 9
jg GetOutputRadix
mov LastOutputRadix, al
call ReadChar
call WriteChar
cmp al, 13H
jmp UseLastOutput
sub al, '0'
jl GetOutputRadix
cmp al, 9
jg GetOutputRadix
xchg LastOutputRadix, al
mov ah, 10
mul ah
add LastOutputRadix, al
jmp UseLastOutput

UseHexOutput:
mov LastOutputRadix, 16

UseLastOutput:
cmp LastOutputRadix, 0
je GetOutputRadix
mov dl, LastOutputRadix
mov OutputRadix, dl
xor ah, ah ; Set the RadixPostfix
mov al, dl
mov dl, 10
div dl
add al, 30H
add ah, 30H
mov ebx, offset RadixPostfix + 4
mov [ebx], al
inc bx
mov [ebx], ah
RET

ExitSignal:
mov dx, -1
RET
GetParsedRadices ENDP

GetNumbers PROC NEAR
GetNumberA:
lea ebx, InputNumberAMessage
call WriteBytes

xor ax, ax
xor bx, bx
xor cx, cx
mov cl, InputRadix
GetNextAInput:
call ReadChar
call WriteChar
cmp al, 13H
je PrepareForNumberB
cmp al, '0'
jl GetNumberABaseParser
cmp al, '9'
jg GetNumberABaseParser
sub al, 30H
jmp HandleNumberAInput

GetNumberABaseParser:
cmp cl, 33
jl NumberAParseSub33
call ParseRadix33To64
cmp ax, -1
je NumberAInputError
jmp HandleNumberAInput

NumberAParseSub33:
call ParseRadixSub33
cmp ax, -1
je NumberAInputError

HandleNumberAInput:
cmp al, dl
jg NumberAInputError
xor ah, ah
xchg ax, bx
mul cx
cmp dx, 0
jg NumberAInputError
add bx, ax
jmp GetNextAInput

NumberAInputError:
lea ebx, NumberInputError
call WriteBytes
jmp GetNumberA

PrepareForNumberB:
mov NumberA, bx

GetNumberB:
lea ebx, InputNumberBMessage
call WriteBytes

xor ax, ax
xor bx, bx
xor cx, cx
mov cl, InputRadix
GetNextBInput:
call ReadChar
call WriteChar
cmp al, 13H
je Done
cmp al, '0'
jl GetNumberBBaseParser
cmp al, '9'
jg GetNumberBBaseParser
sub al, 30H
jmp HandleNumberBInput

GetNumberBBaseParser:
cmp cl, 33
jl NumberBParseSub33
call ParseRadix33To64
cmp ax, -1
je NumberBInputError
jmp HandleNumberBInput

NumberBParseSub33:
call ParseRadixSub33
cmp ax, -1
je NumberBInputError

HandleNumberBInput:
cmp al, dl
jg NumberBInputError
xor ah, ah
xchg ax, bx
mul cx
cmp dx, 0
jg NumberBInputError
add bx, ax
jmp GetNextBInput

NumberBInputError:
lea ebx, NumberInputError
call WriteBytes
jmp GetNumberB

Done:
mov NumberB, bx
RET
GetNumbers ENDP

ParseRadixSub33 PROC NEAR ; Params: al - input char. Output: al - Hex image
cmp al, 'A'
jl InvalidInputError
cmp al, 'Z'
jg CheckLowerCase
sub al, 31H
RET

CheckLowerCase:
cmp al, 'a'
jl InvalidInputError
cmp al, 'z'
jg InvalidInputError
sub al, 51H
RET

InvalidInputError:
mov ax, -1
RET
ParseRadixSub33 ENDP

ParseRadix33To64 PROC NEAR ; Params: al - input char. Output: al - Hex image
cmp al, '/'
je Character64
cmp al, '+'
je Character63
cmp al, 'A'
jl InvalidInputError
cmp al, 'Z'
jg CheckLowerCase
sub al, 31H
jmp Done

CheckLowerCase:
cmp al, 'a'
jl InvalidInputError
cmp al, 'z'
jg InvalidInputError
sub al, 6H
jmp Done

Character64:
mov al, 64
jmp Done

Character63:
mov al, 63
RET

InvalidInputError:
mov ax, -1
RET
ParseRadix33To64 ENDP

Arithmetic PROC NEAR
mov bx, NumberA
mov cx, NumberB
mov bx, ax
add ax, cx
jo SumOverflow
mov Sum, ax

GetDifference:
mov ax, bx
sub ax, cx
jo DifferenceOverflow
mov Difference, ax

GetProduct:
mov ax, bx
mul cx
jo ProductOverflow
cmp dx, 0
jg ProductOverflow
mov Product, ax

GetQuotient:
xor dx, dx
mov ax, bx
div cx
mov Quotient, ax
mov Remainder, dx

cmp cx, 0
je ZeroExponent
cmp cx, 0
jg BeginExponent
neg cx

BeginExponent:
mov ax, bx
dec cx

Exponent:
jcxz SetExponentialResult
mul bx
cmp dx, 0
jg ExponentialOverflow
dec cx
jmp Exponent

ZeroExponent:
mov ax, 1

SetExponentialResult:
mov ExponentialResult, ax
RET

SumOverflow:
add ArithmeticFlags, 00000001B
jmp GetDifference

DifferenceOverflow:
add ArithmeticFlags, 00000010B
jmp GetProduct

ProductOverflow:
add ArithmeticFlags, 00000100B
jmp GetQuotient

ExponentialOverflow:
add ArithmeticFlags, 00001000B
RET
Arithmetic ENDP

OutputResults PROC NEAR
lea ebx, SumMessage
call WriteBytes
mov dx, ArithmeticFlags
mov bx, dx
and bx, 00000001B
cmp bx, 00000001B
je SumOverflow

SumOverflow:
lea ebx, OverflowMessage
call WriteBytes
jmp PrintDifference

DifferenceOverflow:
lea ebx, OverflowMessage
call WriteBytes
jmp PrintProduct

ProductOverflow:
lea ebx, OverflowMessage
call WriteBytes
jmp PrintQuotient

ExponentialOverflow:
lea ebx, OverflowMessage
call WriteBytes
RET
OutputResults ENDP

WriteBytes PROC NEAR ; Params: ebx - location of first byte. stops outputting at null byte
OutputLoop:
mov al, [ebx]
cmp al, 0
je Done
call WriteChar
inc ebx
jmp OutputLoop
Done:
RET
WriteBytes ENDP
END Main