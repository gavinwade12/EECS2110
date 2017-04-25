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
RadixError			DB	13, 10, 'Error with radix. Try again.', 0
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
DecimalPostfix		DB	' Decimal, ', 0
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
mov cl, 10
mov ch, 0
lea ebx, InputRadixMessage
call WriteBytes
xor bx, bx

NextInputChar:
call ReadChar
call WriteChar
cmp al, 13
je EndInputRadix
inc ch
cmp al, 'H'
je UseHexInput
cmp al, 'h'
je UseHexInput
cmp al, 'x'
je ExitSignal
cmp al, 'X'
je ExitSignal

sub al, 30H
cmp al, 0
jl InputRadixError
cmp al, 9
jg InputRadixError
xchg bl, al
imul cl
add bl, al
cmp bl, 64
jg InputRadixError
jmp NextInputChar

InputRadixError:
lea ebx, RadixError
call WriteBytes
jmp GetInputRadix

UseHexInput:
mov ah, 16
jmp UseNewInputRadix

EndInputRadix:
cmp ch, 0
jg UseNewInputRadix

UseLastInput:
cmp LastInputRadix, 0
je InputRadixError
mov ah, LastInputRadix
mov InputRadix, ah
jmp GetOutputRadix

UseNewInputRadix:
cmp bl, 2
jl InputRadixError
cmp bl, 64
jg InputRadixError
mov InputRadix, bl
mov LastInputRadix, bl

GetOutputRadix:
xor ax, ax
mov cl, 10
mov ch, 0
lea ebx, OutputRadixMessage
call WriteBytes
xor bx, bx

NextOutputChar:
call ReadChar
call WriteChar
cmp al, 13
je EndOutputRadix
inc ch
cmp al, 'H'
je UseHexOutput
cmp al, 'h'
je UseHexOutput
cmp al, 'x'
je ExitSignal
cmp al, 'X'
je ExitSignal

sub al, 30H
cmp al, 0
jl OutputRadixError
cmp al, 9
jg OutputRadixError
xchg bl, al
imul cl
add bl, al
cmp bl, 64
jg OutputRadixError
jmp NextOutputChar

OutputRadixError:
lea ebx, RadixError
call WriteBytes
jmp GetOutputRadix

UseHexOutput:
mov ah, 16
jmp UseNewOutputRadix

EndOutputRadix:
cmp ch, 0
jg UseNewOutputRadix

UseLastOutput:
cmp LastOutputRadix, 0
je OutputRadixError
mov ah, LastOutputRadix
mov OutputRadix, ah
jmp SetRadixPostfix

UseNewOutputRadix:
cmp bl, 2
jl OutputRadixError
cmp bl, 64
jg OutputRadixError
mov OutputRadix, bl
mov LastOutputRadix, bl

SetRadixPostfix:
xor ax, ax
mov al, bl
mov bl, 10
mov ebx, offset RadixPostfix + 4
RadixPostfixLoop:
idiv dl
add ah, 30H
mov [ebx], ah
inc bx
xor ah, ah
cmp al, 0
jg SetRadixPostfix
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
cmp al, 13
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
cmp al, cl
jg NumberAInputError
xor ah, ah
xchg ax, bx
imul cx
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
cmp al, 13
je Done
cmp al, '0'
jl NumberBInputError
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
cmp al, cl
jg NumberBInputError
xor ah, ah
xchg ax, bx
imul cx
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
RET

CheckLowerCase:
cmp al, 'a'
jl InvalidInputError
cmp al, 'z'
jg InvalidInputError
sub al, 6H
RET

Character64:
mov al, 64
RET

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
mov ax, bx
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
imul cx
jo ProductOverflow
cmp dx, 0
jg ProductOverflow
mov Product, ax

GetQuotient:
xor dx, dx
mov ax, bx
idiv cx
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
imul bx
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
mov bl, ArithmeticFlags
and bl, 00000001B
cmp bl, 00000001B
je SumOverflow
lea ebx, Sum
mov edx, ebx
call OutputDecimal
mov ebx, edx
call OutputUserRadix

PrintDifference:
lea ebx, DifferenceMessage
call WriteBytes
mov bl, ArithmeticFlags
and bl, 00000010B
cmp bl, 00000010B
je DifferenceOverflow
lea ebx, Difference
call OutputDecimal
call OutputUserRadix

PrintProduct:
lea ebx, ProductMessage
call WriteBytes
mov bl, ArithmeticFlags
and bl, 00000100B
cmp bl, 00000100B
je ProductOverflow
lea ebx, Product
call OutputDecimal
call OutputUserRadix

PrintQuotient:
lea ebx, QuotientMessage
call WriteBytes
lea ebx, Quotient
call OutputDecimal
call OutputUserRadix

lea ebx, ExponentMessage
call WriteBytes
mov bl, ArithmeticFlags
and bl, 00001000B
cmp bl, 00001000B
je ExponentialOverflow
lea ebx, ExponentialResult
call OutputDecimal
call OutputUserRadix
RET

SumOverflow:
lea ebx, OverflowError
call WriteBytes
jmp PrintDifference

DifferenceOverflow:
lea ebx, OverflowError
call WriteBytes
jmp PrintProduct

ProductOverflow:
lea ebx, OverflowError
call WriteBytes
jmp PrintQuotient

ExponentialOverflow:
lea ebx, OverflowError
call WriteBytes
RET
OutputResults ENDP

OutputDecimal PROC NEAR ; Params: ebx - location of word size value to output
mov ax, [ebx]
xor cx, cx
xor dx, dx
mov cl, 10
cmp ax, 0
jge OutputNextChar
push '-'
inc ch
neg ax

OutputNextChar:
idiv cl
add ah, 30H
mov dl, ah
push dx
xor ah, ah
inc ch
cmp al, 0
jg OutputNextChar

Write:
pop ax
call WriteChar
dec ch
cmp ch, 0
jg Write
lea ebx, DecimalPostfix
call WriteBytes
RET
OutputDecimal ENDP

OutputUserRadix PROC NEAR ; Params: ebx - location of word size value to output
mov ax, [ebx]
xor cx, cx
xor dx, dx
mov cl, OutputRadix
cmp ax, 0
jge OutputNextChar
push '-'
inc ch
neg ax

OutputNextChar:
idiv cl
cmp ah, 9
jle Digit
cmp ah, 36
jle Uppercase
cmp ah, 62
jle Lowercase
cmp ah, 63
je PlusSign
push '/'
LoopBookKeeping:
inc ch
xor ah, ah
cmp al, 0
jg OutputNextChar

Write:
pop ax
call WriteChar
dec ch
cmp ch, 0
jg Write
lea ebx, RadixPostfix
call WriteBytes
RET

Digit:
add ah, 30H
mov dl, ah
push dx
jmp LoopBookKeeping

Uppercase:
add ah, 31H
mov dl, ah
push dx
jmp LoopBookKeeping

Lowercase:
add ah, 6H
mov dl, ah
push dx
jmp LoopBookKeeping

PlusSign:
push '+'
jmp LoopBookKeeping
OutputUserRadix ENDP

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