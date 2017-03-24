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
InputStringCopy		DB	51 DUP (?)
GetFunctionMessage	DB	13, 10, 'Please enter a function code: ', 0
BadFunctionMessage	DB	'Invalid function code.', 0
GetCharMessage		DB	'Please enter a character: ', 0
GetReplacerMessage	DB	13, 10, 'Please enter a character to insert in place of the last entered character: ', 0
NewStringMessage	DB	13, 10, 'The new string is: ', 0
OccurencesMessage	DB	13, 10, 'Occurences found in string: ', 0
IndexFoundMessage	DB	13, 10, 'First occurence found at index: ', 0
CharNotFoundMessage	DB	13, 10, 'Character was not found in string.', 0
StringLengthMessage	DB	'Length of string: ', 0
AlphaNumericMessage	DB	'Number of alphanumerics found in string: ', 0	
ErrorMessage		DB	13, 10, 'An error has occurred. Please press any key to exit . . . .', 0

.CODE
Main	PROC

call Function9
call Function100

GetFunctionCode:
lea edx, GetFunctionMessage
call WriteString
call ReadInt
jo BadFunctionCode
cmp eax, 0
je ExitMain
cmp eax, 1
je CallFunction1
cmp eax, 2
je CallFunction2
cmp eax, 3
je CallFunction3
cmp eax, 4
je CallFunction4
cmp eax, 5
je CallFunction5
cmp eax, 6
je CallFunction6
cmp eax, 7
je CallFunction7
cmp eax, 8
je CallFunction8
cmp eax, 9
je CallFunction9
cmp eax, 10
je CallFunction10
cmp eax, 100
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
call CopyInputString
call Function5
jmp OutputNewString

CallFunction6:
call CopyInputString
call Function6
jmp OutputNewString

CallFunction7:
call CopyInputString
call Function7
jmp OutputNewString

CallFunction8:
call CopyInputString
push 0
call Function8
jmp OutputNewString

CallFunction9:
call CopyInputString
call Function9
jmp OutputNewString

CallFunction10:
call Function10
call CopyInputString
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

lea edx, GetCharMessage
call WriteString
call ReadChar
xor cx, cx
xor dx, dx
mov cl, MAX_CHARS
lea ebx, InputString

NextChar:
jcxz EndOfString
mov dl, [ebx]
inc bx
dec cx
cmp dl, al
je Found
jmp NextChar

Found:
sub cx, 50
neg cx
xor eax, eax
mov ax, cx
lea edx, IndexFoundMessage
call WriteString
call WriteInt
jmp Done

EndOfString:
lea edx, CharNotFoundMessage
call WriteString
Done:

RET
Function1	ENDP

Function2	PROC NEAR

lea edx, GetCharMessage
call WriteString
call ReadChar
xor cx, cx
xor dx, dx
mov cl, MAX_CHARS
lea ebx, InputString

NextChar:
jcxz EndOfString
mov dl, [ebx]
inc ebx
dec cx
cmp dl, al
je Match
jmp NextChar
Match:
inc dh
jmp NextChar

EndOfString:
xor eax, eax
mov al, dh
lea edx, OccurencesMessage
call WriteString
call WriteInt

RET
Function2	ENDP

Function3	PROC NEAR

xor cx, cx
xor dx, dx
mov cl, MAX_CHARS
lea ebx, InputString

NextChar:
jcxz EndOfString
mov dl, [ebx]
inc ebx
dec cx
cmp dl, 0
je EndOfString
jmp NextChar

EndOfString:
xor eax, eax
sub cx, 49
neg cx
mov ax, cx
lea edx, StringLengthMessage
call WriteString
call WriteInt

RET
Function3	ENDP

Function4	PROC NEAR

xor cx, cx
xor dx, dx
mov cl, MAX_CHARS
lea ebx, InputString

NextChar:
jcxz EndOfString
mov dl, [ebx]
inc ebx
dec cx
cmp dl, 0
je EndOfString

NumberCheck:
cmp dl, 30h
jl NextChar
cmp dl, 39h
jg UpperCaseCheck
inc dh
jmp NextChar

UpperCaseCheck:
cmp dl, 41h
jl NextChar
cmp dl, 5ah
jg LowerCaseCheck
inc dh
jmp NextChar

LowerCaseCheck:
cmp dl, 61h
jl NextChar
cmp dl, 7ah
jg NextChar
inc dh
jmp NextChar

EndOfString:
xor eax, eax
mov al, dh
lea edx, AlphaNumericMessage
call WriteString
call WriteInt

RET
Function4	ENDP

Function5	PROC NEAR

lea edx, GetCharMessage
call WriteString
call ReadChar
mov bl, al
lea edx, GetReplacerMessage
call WriteString
call ReadChar
mov ah, bl

xor cx, cx
mov cl, MAX_CHARS
lea ebx, InputString

NextChar:
jcxz Done
mov dl, [ebx]
inc ebx
dec cx
cmp dl, 0
je Done
cmp dl, ah
jne NextChar
mov [ebx - 1], al
jmp NextChar
Done:

RET
Function5	ENDP

Function6	PROC NEAR

push 1
call Function8

RET
Function6	ENDP

Function7	PROC NEAR

push -1
call Function8

RET
Function7	ENDP

Function8	PROC NEAR, case:BYTE

mov ah, case
xor cx, cx
mov cl, MAX_CHARS
lea ebx, InputString

NextChar:
jcxz Done
mov al, [ebx]
inc ebx
dec cx
cmp dl, 0
je Done
cmp al, 41h
jl NextChar
cmp al, 5ah
jle FixCase
cmp al, 61h
jl NextChar
cmp al, 7ah
jle FixCase
jmp NextChar

FixCase:
cmp ah, -1
je LowerCase
cmp ah, 1
je UpperCase
xor al, 20h
mov [ebx - 1], al
jmp NextChar

LowerCase:
or al, 20h
mov [ebx - 1], al
jmp NextChar

UpperCase:
shl al, 3
shr al, 3
or al, 40h
mov [ebx - 1], al
jmp NextChar

Done:

RET
Function8	ENDP

Function9	PROC NEAR

GetInputString:
lea edx, InputMessage
call WriteString
lea edx, InputString
xor ecx, ecx
mov cl, MAX_CHARS
call ReadString

cmp InputString, 10
je GetInputString

RET
Function9	ENDP

Function10	PROC NEAR

xor cx, cx
mov cl, MAX_CHARS
inc cl
lea ebx, InputStringCopy
lea edx, InputString
mov al, [ebx]
cmp al, 0
je Done

NextChar:
jcxz Done
mov al, [ebx]
mov [edx], al
inc ebx
inc edx
dec cx
jmp NextChar
Done:

RET
Function10	ENDP

CopyInputString	PROC NEAR

xor cx, cx
mov cl, MAX_CHARS
inc cl
lea ebx, InputString
lea edx, InputStringCopy

NextChar:
jcxz Done
mov al, [ebx]
mov [edx], al
inc ebx
inc edx
dec cx
jmp NextChar
Done:

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