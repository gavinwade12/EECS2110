include \Irvine\Irvine32.inc
includelib \Irvine\Irvine32.lib

.DATA
FirstNumberMessage	DB	0DH, 0AH, 'Enter the first number: ', 0
SecondNumberMessage	DB	'Enter the second number: ', 0
LetterMessage		DB	'Enter a letter: ', 0
SumMessage			DB	0DH, 0AH, 'The sum is ', 0
DifferenceMessage	DB	', and the difference is ', 0
ProductMessage		DB	0DH, 0AH, 'The product is ', 0
QuotientMessage		DB	', and the quotient is ', 0
RemainderMessage	DB	' remainder ', 0
RepeatProgMessage	DB	0DH, 0AH, 'Do you wish to repeat? Enter y or Y to repeat, or enter n or N to exit: ', 0
NaLMessage			DB	'Invalid input. Please enter a letter: ', 0
DivideByZeroMessage	DB	'. Quotient cannot be computed: division by zero prohibited.', 0

FirstNumber			DW	?
SecondNumber		DW	?
Letter				DB	?

.CODE
Arithmetic	PROC

GetInput:
GetFirstNumber:
LEA EDX, FirstNumberMessage
call WriteString
call ReadInt
JO GetFirstNumber
MOV FirstNumber, AX

GetSecondNumber:
LEA EDX, SecondNumberMessage
call WriteString
call ReadInt
JO GetSecondNumber
MOV SecondNumber, AX

LEA EDX, LetterMessage
call WriteString
call ReadChar
MOV Letter, AL

InputSwitch:
CMP Letter, 041H
JL NaL
CMP Letter, 04DH
JLE AddAndSub
CMP Letter, 05AH
JLE MulAndDiv
CMP Letter, 061H
JL NaL
CMP Letter, 06DH
JLE AddAndSub
CMP Letter, 07AH
JLE MulAndDiv
JMP NaL

NaL:
LEA EDX, NaLMessage
call WriteString
call ReadChar
MOV Letter, AL
JMP InputSwitch

AddAndSub:
XOR EAX, EAX
MOV AX, FirstNumber
ADD AX, SecondNumber
CMP AX, 0
JGE OutputSum
NEG AX

OutputSum:
LEA EDX, SumMessage
call WriteString
call WriteInt

XOR EAX, EAX
MOV AX, FirstNumber
SUB	AX, SecondNumber
CMP AX, 0
JGE OutputDifference
NEG AX

OutputDifference:
LEA EDX, DifferenceMessage
call WriteString
call WriteInt
JMP AskForRepeat

MulAndDiv:
XOR EAX, EAX
MOV AX, FirstNumber
IMUL SecondNumber
PUSH DX
PUSH AX
POP EAX
LEA EDX, ProductMessage
call WriteString
call WriteInt

CMP SecondNumber, 0
JE DivideByZero
XOR EAX, EAX
XOR EDX, EDX
MOV AX, FirstNumber
CMP FirstNumber, 0
JGE Divide
MOV DX, 0FFFFH

Divide:
MOV BX, SecondNumber
IDIV BX
XOR EBX, EBX
MOV BX, DX
CMP AX, 0
JGE OutputQuotient
OR EAX, 0FFFF0000H

OutputQuotient:
LEA EDX, QuotientMessage
call WriteString
call WriteInt
MOV EAX, EBX
CMP AX, 0
JGE OutputRemainder
OR EAX, 0FFFF0000H

OutputRemainder:
LEA EDX, RemainderMessage
call WriteString
call WriteInt
JMP AskForRepeat

DivideByZero:
LEA EDX, DivideByZeroMessage
call WriteString

AskForRepeat:
LEA EDX, RepeatProgMessage
call WriteString
call ReadChar

CMP AL, 079H
JE GetInput
CMP AL, 059H
JE GetInput
CMP AL, 06EH
JE ExitProc
CMP AL, 04EH
JE ExitProc
JMP AskForRepeat

ExitProc:
invoke ExitProcess, 0
Arithmetic ENDP
END	Arithmetic