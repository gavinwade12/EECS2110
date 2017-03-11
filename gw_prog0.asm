include \Irvine\Irvine32.inc
includelib \Irvine\Irvine32.lib

.DATA
FirstFeetMessage		DB	'Please enter the first positive number in feet: ', 0
FirstInchesMessage		DB	'Please enter the first positive number in inches: ', 0
SecondFeetMessage		DB	'Please enter the second positive number in feet: ', 0
SecondInchesMessage		DB	'Please enter the second positive number in inches: ', 0
ThirdFeetMessage		DB	'Please enter the third positive number in feet: ', 0
ThirdInchesMessage		DB	'Please enter the third positive number in inches: ', 0
Product					DD	?
CubicFeetFactor			DD	1728
ProductInchesMessage	DB	'The calculated volume in cubic inches is: ', 0
ProductFeetMessage		DB	13, 10, 'The calculated volume in cubic feet is: ', 0
ProductRemainderMessage	DB	' with a remainder (in cubic inches) of: ', 0
FinalMessage			DB	13, 10, 'Press enter key to exit....', 0
OverflowErrorMessage	DB	13, 10, "Error: Experienced overflow or number larger than I'd like to handle."

.CODE
Volume PROC

GetFirstInputFeet:
XOR EAX, EAX
LEA EDX, FirstFeetMessage
call WriteString
call ReadInt
JO GetFirstInputFeet
CMP EAX, 0
JL GetFirstInputFeet
CMP EAX, 0FFFFH
JG OverflowError
MOV DX, 12
IMUL DX
JO OverflowError
push DX
push AX
pop Product

GetFirstInputInches:
XOR EAX, EAX
LEA EDX, FirstInchesMessage
call WriteString
call ReadInt
JO GetFirstInputInches
CMP EAX, 0
JL GetFirstInputInches
CMP EAX, 0FFFFH
JG OverflowError
ADD Product, EAX
JO OverflowError
CMP Product, 0
JE GetFirstInputFeet

GetSecondInputFeet:
XOR EAX, EAX
LEA EDX, SecondFeetMessage
call WriteString
call ReadInt
JO GetSecondInputFeet
CMP EAX, 0
JL GetSecondInputFeet
CMP EAX, 0FFFFH
JG OverflowError
MOV DX, 12
IMUL DX
JO OverflowError
push DX
push AX
pop EBX

GetSecondInputInches:
XOR EAX, EAX
LEA EDX, SecondInchesMessage
call WriteString
call ReadInt
JO GetSecondInputInches
CMP EAX, 0
JL GetSecondInputInches
CMP EAX, 0FFFFH
JG OverflowError
ADD EAX, EBX
JO OverflowError
CMP EAX, 0
JE GetSecondInputFeet
IMUL Product
JO OverflowError
CMP EDX, 0
JG OverflowError
MOV Product, EAX

GetThirdInputFeet:
XOR EAX, EAX
LEA EDX, ThirdFeetMessage
call WriteString
call ReadInt
JO GetThirdInputFeet
CMP EAX, 0
JL GetThirdInputFeet
CMP EAX, 0FFFFH
JG OverflowError
MOV DX, 12
IMUL DX
JO OverflowError
push DX
push AX
pop EBX

GetThirdInputInches:
XOR EAX, EAX
LEA EDX, ThirdInchesMessage
call WriteString
call ReadInt
JO GetThirdInputInches
CMP EAX, 0
JL GetThirdInputInches
CMP EAX, 0FFFFH
JG OverflowError
ADD EAX, EBX
JO OverflowError
CMP EAX, 0
JE GetThirdInputFeet
IMUL Product
JO OverflowError
CMP EDX, 0
JG OverflowError
MOV Product, EAX

OutputResultsInInches:
LEA EDX, ProductInchesMessage
call WriteString
MOV EAX, Product
call WriteInt

CalculateCubicFeet:
MOV EAX, Product
XOR EDX, EDX
IDIV CubicFeetFactor

OutputResultsInFeet:
MOV EBX, EDX
LEA EDX, ProductFeetMessage
call WriteString
call WriteInt
LEA EDX, ProductRemainderMessage
call WriteString
MOV EAX, EBX
call WriteInt

JMP ExitProg

OverflowError:
LEA EDX, OverflowErrorMessage
call WriteString

ExitProg:
LEA EDX, FinalMessage
call WriteString
call ReadChar
invoke ExitProcess, 0
Volume ENDP
END Volume