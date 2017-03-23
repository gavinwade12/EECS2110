include \Irvine\Irvine32.inc
includelib \Irvine\Irvine32.lib

.DATA
InputMessage		DB	'Please enter a sentence up to 50 characters: ', 0
MenuMessage1		DB	13, 10, 'Function 1: Enter a letter and get the position of the first occurrance in the string.', 13, 10,
						'Function 2: Enter a letter and get the number of occurrences in the string.', 13, 10,
						'Function 3: Get the length of the string.', 13, 10,
						'Function 4: Get the number of alphanumeric characters in the string.', 13, 10, 0
MenuMessage2		DB	'Function 5: Enter a letter to be replaced and a letter that will do the replacing in the string.', 13, 10,
						'Function 6: Capitalize the letters in the string.', 13, 10,
						'Function 7: Make all the letters in the string lower case.', 13, 10,
						'Function 8: Toggle the case of each letter in the string.', 13, 10, 0
MenuMessage3		DB	'Function 9: Input a new string.', 13, 10,
						'Function 10: Undo the last action that modified the string.', 13, 10,
						'Function 100: Output this menu again.', 13, 10,
						'Function 0: Exit the program.', 13, 10, 0
MAX_CHARS			DB	50
InputString			DB	51 DUP (?)
InputStringCopy		DB	51 DUP(?)
GetFunctionMessage	DB	13, 10, 'Please enter a function code: ', 0
BadFunctionMessage	DB	'Invalid function code.', 0
GetCharMessage		DB	'Please enter a character: ', 0
GetReplacerMessage	DB	'Please enter a character to insert in place of the last entered character: ', 0
NewStringMessage	DB	'The new string is: ', 0
ErrorMessage		DB	13, 10, 'An error has occurred. Please press any key to exit . . . .', 0

.CODE
Main	PROC

GetInputString:
lea edx, InputMessage
call WriteString
lea edx, InputString
xor ecx, ecx
mov cl, MAX_CHARS
call Readstring

cmp InputString, 10
je GetInputString

call Function100

GetFunctionCode:
lea edx, GetFunctionMessage
call WriteString
call ReadChar
sub al, 30h
jl BadFunctionCode
cmp al, 0
je ExitMain
cmp al, 1
je CallFunction1
cmp al, 2
je CallFunction2
cmp al, 3
je CallFunction3
cmp al, 4
je CallFunction4
cmp al, 5
je CallFunction5
cmp al, 6
je CallFunction6
cmp al, 7
je CallFunction7
cmp al, 8
je CallFunction8
cmp al, 9
je CallFunction9
cmp al, 10
je CallFunction10
cmp al, 100
je CallFunction100
jmp BadFunctionCode

CallFunction1:
call Function1
jmp GetFunctionCode

CallFunction2:
call Function2
jmp GetFunctionCode

CallFunction3:
call Function3
jmp GetFunctionCode

CallFunction4:
call Function4
jmp GetFunctionCode

CallFunction5:
call Function5
jmp OutputNewString

CallFunction6:
call Function6
jmp OutputNewString

CallFunction7:
call Function7
jmp OutputNewString

CallFunction8:
call Function8
jmp OutputNewString

CallFunction9:
call Function9
jmp OutputNewString

CallFunction10:
call Function10
jmp OutputNewString

CallFunction100:
call Function100
jmp GetFunctionCode

OutputNewString:
lea edx, NewStringMessage
call WriteString
lea edx, InputString
call WriteString
jmp GetFunctionCode

BadFunctionCode:
lea edx, BadFunctionMessage
call WriteString
jmp GetFunctionCode

GenericError:
lea edx, ErrorMessage
call WriteString
call ReadChar

ExitMain: invoke ExitProcess, 0
Main	ENDP

Function1	PROC NEAR
RET
Function1	ENDP

Function2	PROC NEAR
lea edx, GetCharMessage
call WriteString
call ReadChar
jo
xor cx, cx
lea bx, InputString
Loop:
mov dl, [bx]
cmp 
RET
Function2	ENDP

Function3	PROC NEAR
RET
Function3	ENDP

Function4	PROC NEAR
RET
Function4	ENDP

Function5	PROC NEAR
RET
Function5	ENDP

Function6	PROC NEAR
RET
Function6	ENDP

Function7	PROC NEAR
RET
Function7	ENDP

Function8	PROC NEAR
RET
Function8	ENDP

Function9	PROC NEAR
RET
Function9	ENDP

Function10	PROC NEAR
RET
Function10	ENDP

CopyInputString	PROC NEAR
RET
CopyInputString	ENDP

Function100	PROC NEAR
lea	edx, MenuMessage1
call WriteString
lea edx, MenuMessage2
call WriteString
lea edx, MenuMessage3
call WriteString
RET
Function100 ENDP
END Main