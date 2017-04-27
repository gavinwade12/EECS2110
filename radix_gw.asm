; Gavin Wade - Radix Project
; This project uses the Irvine32 library; however, as noted in the
; instructions, it only uses the ReadChar and WriteChar procedures.
; The maximum radix this program accepts is 64. The maximum size
; for Numbers A and B and the results produced from the arithmetic 
; performed on them is a 16bit signed integer. It uses the same characters as other 
; common base64 encoders/decoders. The uppercase letters precede lowercase 
; letters as the base increases, with the 63rd and 64th characters being 
; '+' and '/' respectively. When using any radix below 33, uppercase letters
; and their respective lowercase counterparts have the same value. When the output radix
; is set to binary or hex, negative results will be output with 2's compliment
; signed binary. All other radices will have negative numbers output as normal,
; but will have a '-' preceding them.

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
DivideByZeroError	DB	' Cannot divide by zero! Skipping...', 0
RadixPostfix		DB	' Base', ?, ?, ' ', 0
BinaryPostfix		DB	' Binary ', 0
DecimalPostfix		DB	' Decimal ', 0
RemainderPostfix	DB	'remainder ', 0
ResultSeparator		DB	', ', 0
ArithmeticFlags		DB	0 ; Signifies an overflow for sum, difference, product, divide by zero, and exponential results at bits 0, 1, 2, 3, and 4 respectively
NegativeInputFlag	DB	0 ; All bits on if input is negative
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
mov bl, 16
jmp UseNewInputRadix

EndInputRadix:
cmp ch, 0
jg UseNewInputRadix

UseLastInput:
cmp LastInputRadix, 0
je InputRadixError
mov bl, LastInputRadix
mov InputRadix, bl
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
mov bl, 16
jmp UseNewOutputRadix

EndOutputRadix:
cmp ch, 0
jg UseNewOutputRadix

UseLastOutput:
cmp LastOutputRadix, 0
je OutputRadixError
mov bl, LastOutputRadix
mov OutputRadix, bl
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
mov dl, 10
mov ebx, offset RadixPostfix + 6
RadixPostfixLoop:
idiv dl
add ah, 30H
mov [ebx], ah
dec ebx
xor ah, ah
idiv dl
add ah, 30H
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
mov NegativeInputFlag, 0
mov cl, InputRadix

call ReadChar
call WriteChar
cmp al, '-'
jne NumberACases
mov NegativeInputFlag, 11111111B

GetNextAInput:
call ReadChar
call WriteChar
NumberACases:
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
jge NumberAInputError
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
cmp NegativeInputFlag, 11111111B
jne SetNumberA
neg bx

SetNumberA:
mov NumberA, bx

GetNumberB:
lea ebx, InputNumberBMessage
call WriteBytes

xor ax, ax
xor bx, bx
mov NegativeInputFlag, 0
xor cx, cx
mov cl, InputRadix

call ReadChar
call WriteChar
cmp al, '-'
jne NumberBCases
mov NegativeInputFlag, 11111111B

GetNextBInput:
call ReadChar
call WriteChar
NumberBCases:
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
cmp NegativeInputFlag, 11111111B
jne SetNumberB
neg bx

SetNumberB:
mov NumberB, bx
RET
GetNumbers ENDP

ParseRadixSub33 PROC NEAR ; Params: al - input char. Output: al - Hex image
cmp al, 'A'
jl InvalidInputError
cmp al, 'Z'
jg CheckLowerCase
sub al, 37H
RET

CheckLowerCase:
cmp al, 'a'
jl InvalidInputError
cmp al, 'z'
jg InvalidInputError
sub al, 3DH
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
sub al, 37H
RET

CheckLowerCase:
cmp al, 'a'
jl InvalidInputError
cmp al, 'z'
jg InvalidInputError
sub al, 57H
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
cmp cx, 0
je DivideByZero
cmp ax, 0
jge Divide
mov dx, 0FFFFH
Divide:
idiv cx
mov Quotient, ax
mov Remainder, dx

GetExponent:
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
or ArithmeticFlags, 00000001B
jmp GetDifference

DifferenceOverflow:
or ArithmeticFlags, 00000010B
jmp GetProduct

ProductOverflow:
or ArithmeticFlags, 00000100B
jmp GetQuotient

DivideByZero:
or ArithmeticFlags, 00001000B
jmp GetExponent

ExponentialOverflow:
or ArithmeticFlags, 00010000B
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
call OutputDecimal
lea ebx, ResultSeparator
call WriteBytes
lea ebx, Sum
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
lea ebx, ResultSeparator
call WriteBytes
lea ebx, Difference
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
lea ebx, ResultSeparator
call WriteBytes
lea ebx, Product
call OutputUserRadix

PrintQuotient:
lea ebx, QuotientMessage
call WriteBytes
mov bl, ArithmeticFlags
and bl, 00001000B
cmp bl, 00001000B
je DivideByZero
lea ebx, Quotient
call OutputDecimal
lea ebx, RemainderPostfix
call WriteBytes
lea ebx, Remainder
call OutputDecimal
lea ebx, ResultSeparator
call WriteBytes
lea ebx, Quotient
call OutputUserRadix
lea ebx, RemainderPostfix
call WriteBytes
lea ebx, Remainder
call OutputUserRadix

PrintExponentialResult:
lea ebx, ExponentMessage
call WriteBytes
mov bl, ArithmeticFlags
and bl, 00010000B
cmp bl, 00010000B
je ExponentialOverflow
lea ebx, ExponentialResult
call OutputDecimal
lea ebx, ResultSeparator
call WriteBytes
lea ebx, ExponentialResult
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

DivideByZero:
lea ebx, DivideByZeroError
call WriteBytes
jmp PrintExponentialResult

ExponentialOverflow:
lea ebx, OverflowError
call WriteBytes
RET
OutputResults ENDP

OutputDecimal PROC NEAR ; Params: ebx - location of word size value to output
mov ax, [ebx]
xor dx, dx
xor cx, cx
mov bx, 10
cmp ax, 0
jge OutputNextChar
push ax
mov ax, '-'
call WriteChar
pop ax
neg ax

OutputNextChar:
idiv bx
add dx, 30H
push dx
xor dx, dx
inc cx
cmp ax, 0
jg OutputNextChar

Write:
pop ax
call WriteChar
dec cx
cmp cx, 0
jg Write
lea ebx, DecimalPostfix
call WriteBytes
RET
OutputDecimal ENDP

OutputUserRadix PROC NEAR ; Params: ebx - location of word size value to output
mov ax, [ebx]
push ax
xor cx, cx
xor dx, dx
xor bx, bx
mov bl, OutputRadix
cmp ax, 0
jge OutputNextChar
cmp bl, 2
je OutputSignedBinary
cmp bl, 16
je OutputSignedBinary
push ax
mov ax, '-'
call WriteChar
pop ax
neg ax

OutputNextChar:
idiv bx
cmp dx, 9
jle Digit
cmp dx, 36
jle Uppercase
cmp dx, 62
jle Lowercase
cmp dx, 63
je PlusSign
push '/'
LoopBookKeeping:
inc cx
xor dx, dx
cmp ax, 0
jg OutputNextChar

Write:
pop ax
call WriteChar
dec cx
cmp cx, 0
jg Write
pop bx
cmp bl, 0
jl BinaryPostfixDecision
OutputRadixPostfix:
lea ebx, RadixPostfix
call WriteBytes
RET

BinaryPostfixDecision:
mov bl, OutputRadix
cmp bl, 2
je OutputBinaryPostfix
cmp bl, 16
je OutputBinaryPostfix
jmp OutputRadixPostfix
OutputBinaryPostfix:
lea ebx, BinaryPostfix
call WriteBytes
RET

Digit:
add dx, 30H
push dx
jmp LoopBookKeeping

Uppercase:
add dx, 37H
push dx
jmp LoopBookKeeping

Lowercase:
add dx, 3CH
push dx
jmp LoopBookKeeping

PlusSign:
push '+'
jmp LoopBookKeeping

OutputSignedBinary:
mov dx, 00000001B
OutputBinaryLoop:
mov bx, dx
and bx, ax
cmp dx, bx
jne ZeroCase
mov bx, 31H
push bx
jmp BinaryLoopBookKeeping
ZeroCase:
mov bx, 30H
push bx
BinaryLoopBookKeeping:
shl dx, 1
inc cx
cmp dx, 0
je Write
jmp OutputBinaryLoop

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