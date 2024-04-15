start:          loco address:
                push
                call addinput:        
                halt
addinput:       lodl 1
                stod answeraddress:
                loco str1:              ; load string 1
                call print:             ; print string 1
                loco num1:              ; load num location 1
                call readfirst:         ; read first number
                loco str1:              ; load string 1 again
                call print:             ; print string 1
                loco num2:              ; load num location 2
                call readfirst:         ; read second number
                call addnums:           ; add numbers put result in sum
                loco str2:              ; load string 2
                call print:             ; print string 2
                lodd sum:
                jneg overflow:
                call convert:           ; convert sum to string store in output
                loco output:            ; load output number as string
                call print:             ; print output number
                lodd sum:
                push
                lodd answeraddress:
                popi
                lodd c0:
                retn
overflow:       loco str3:
                call print:
                lodd cn1:
                retn
convert:        loco output:            ; load location of output
                stod pstr:              ; store in pstr
                lodd sum:               ; load sum
                stod dividend:          ; store in dividend
convertloop:    lodd c10:               ; load 10 to be divisor
                push                    ; push divisor
                lodd dividend:
                push                    ; push dividend
                div                     ; perform division
                pop                     ; pop quotient
                stod dividend:          ; store result for next dividend
                lodd offset:            ; put 48 into accumulator
                addl 0                  ; add remainder to 48 giving ascii code
                stol 0                  ; store that on top of stack
                lodd pstr:              ; lodd pstr
                popi                    ; put remainder in ascii into pstr
                insp 2                  ; move past dividend and divisor parameters
                lodd dividend:
                jzer done:              ; if dividend is zero we are done
                lodd pstr:
                pshi
                call swapbytes:
                lodd c10:
                push
                lodd dividend:
                push
                div                     ; perform division again
                pop
                stod dividend:
                lodd offset:
                addl 0                  ; put remainder + offset into accumulator
                insp 3                  ; move to prev digit shifted
                addl 0
                stol 0                  ; overwrite with added value
                lodd pstr:
                popi                    ; put into pstr
                addd c1:
                stod pstr:
                lodd dividend:
                jzer fill:
                jump convertloop:
fill:           lodd c0:
                push
                lodd pstr:
                popi
                retn
done:           retn
addnums:        lodd num1:              ; load first num
                push                    ; put on stack
                lodd num2:              ; load second num
                addl 0                  ; add first num from stack to second num
                stod sum:               ; store in sum
                insp 1
                retn
readfirst:      push                    ; push answer location
                lodd on:
                stod 4093
                call readbsywt:
                lodd 4092               ; get first digit
                subd offset:            ; subtract 48 to get from ASCII to binary
                push
readnum:        call readbsywt:
                lodd 4092
                stod nextchar:          ; store character
                subd c10:               ; subtract 10 to see if character is newline/enter
                jzer endread:
                mult 10                 ; mult prev by 10 to move to right ex. 10 -> 100
                lodd nextchar:          ; load next character
                subd offset:            
                addl 0                  ; add running total to value now in accumulator
                stol 0                  ; overwrite old number
                jump readnum:
endread:        lodl 1                  ; put answer location into accumulator
                popi                    ; put sum into answer location
                insp 1
                retn                    
print:          lodl 1
                pshi                    ; Put thing to be printed onto stack
                push                    ; put string pointer on stack bc writebsywt mangles accumulator
                lodd on:
                stod 4095               ; turn on transmitter 
                call writebsywt:
                pop                     ; get string pointer back
                addd c1:                ; add 1 to go to next spot in memory 
                stod pstr:              ; store that spot in our string pointer
                pop                     ; get our current character into memory
                push                    ; HACK 1 - make it so the stack has something to be popped off in crnl
                jzer crnl:              ; if its zero we are done go to carriage return new line
                pop                     ; HACK 2 - undo hack 1
                stod 4094               ; else put our character to transmitter 
                push                    ; put string back on stack 
                subd c255:              ; subtract 255 essentially right shifting 8 or putting the number negative 
                jneg crnl:              ; if negative we have no second character so goto to carriage return new line
                call swapbytes:         ; swap bytes 
                insp 1                  ; move sp down 
                push                    ; overwrite our other string now with swapped bytes 
                call writebsywt:
                pop
                stod 4094
                lodd pstr:              ; load next character 
                jump print:             ; loop 
crnl:           call writebsywt:    
                lodd cr:
                stod 4094               ; print carriage return
                call writebsywt:
                lodd nl:                ; print new line
                stod 4094
                insp 1                  ; make sure to skip past temp string to return
                retn
swapbytes:      loco 8                  ; create original loop counter 
loop:           jzer swapped:           ; if loop counter = 0 we are done 
                subd c1:                ; decrement loop counter 
                stod lpcnt:             ; store new loop counter 
                lodl 1                  ; load our bytes to be swapped 
                jneg add1:              ; if negative go to add1 so that an additional 1 can be added representing that negative first bit 
                addl 1                  ; add number to itself 
                stol 1                  ; overwrite old number 
                lodd lpcnt:             ; load loop count 
                jump loop:              ; loop 
add1:           addl 1                  ; add number to itself 
                addd c1:                ; add 1 
                stol 1                  ; store number back 
                lodd lpcnt:             ; load loop count 
                jump loop:              ; loop 
swapped:        lodl 1
                retn
writebsywt:     lodd 4095
                subd mask:
                jneg writebsywt:
                retn
readbsywt:      lodd 4093
                subd mask:
                jneg readbsywt:
                retn
                .LOC 200
on:             8
mask:           10
c0:             0
c1:             1
c10:            10
c255:           255
cn1:            -1
pstr:           0
lpcnt:          0
cr:             13
readbsywt:      10
offset:         48
nextchar:       0
num1:           0
num2:           0
sum:            0
dividend:       0
temp:           0
address:        0
answeraddress:  0
str1:           "PLEASE ENTER AN INTEGER BETWEEN 1 AND 32767"
str2:           "THE SUM OF THESE INTEGERS IS:"
output:         " "
str3:           "OVERFLOW: NO SUM POSSIBLE"
