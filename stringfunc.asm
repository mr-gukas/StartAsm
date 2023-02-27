.model tiny
locals @@
;-------------------------------------------------
.data
line1 db "Hello", 0
line2 db "Hell", 0

;-------------------------------------------------
.code          
org 100h

start: jmp main
;------------------------------------------------
; ENTRY: DI - pointer to the null-terminated byte string to be analyzed
;
; EXIT:  AX - characters count 
;
; EXPECT:
;
; DESTROY: 
;------------------------------------------------
_strlen proc
    
            xor ax, ax      
            push di         ; save bp value
            mov cx, -1     ; in case a zero is not encountered

@@cycle:
            cmp byte ptr [di], 0 ; compare the byte at [di] to 0
            je @@done        
            inc ax         
            inc di        
            loop @@cycle  
@@done:
            pop di 
            ret             ; Return the length of the string in AX
            endp
;------------------------------------------------
; ENTRY: DI - pointer to the object to be examined
;        SI - byte to search for
;        DX - max number of bytes to examine
;
; EXIT:  AX - pointer to the location of the byte, or a null pointer if no such byte is found.
;
; EXPECT:
;
; DESTROY: 
;------------------------------------------------
_memchr proc 
            mov ax, si 
            push di         ; save bp value
            push dx

@@cycle:
            cmp [di], al; compare the byte at [di] to searchable sybmol
            je @@found        
            dec dx         
            inc di        

            cmp dx, 0
            jne @@cycle
            jmp @@notfound
@@found:
            mov ax, di
            jmp @@done

@@notfound:
            mov ax, 0
@@done:
            pop dx
            pop di 
            ret             
            endp
;------------------------------------------------
; ENTRY: DI - pointer to the null-terminated byte string to be analyzed
;        SI - byte to search for
;
; EXIT:  AX - pointer to the found character in str, or null pointer if no such character is found.
;
; EXPECT:
;
; DESTROY: CX 
;------------------------------------------------
_strchr proc 
            mov ax, si 
            push di         ; save bp value
            mov cx, -1

@@cycle:
            cmp byte ptr [di], 0; compare the byte at [di] to searchable sybmol
            je @@notfound

            cmp [di], al 
            je @@found 

            inc di        

            loop @@cycle  

            jmp @@done
@@found:
            mov ax, di 
            jmp @@done

@@notfound:
            mov ax, 0
@@done:
            pop di 
            ret             
            endp
;------------------------------------------------
; ENTRY: DI - pointer to the object to fill
;        SI - fill byte 
;        DX - number of bytes to fill
;
; EXIT:  AX - dest - DI.
;
; EXPECT:
;
; DESTROY: DI 
;------------------------------------------------
_memset proc 
            mov ax, di      ; return value 
            push dx
            push bx
            mov bx, si

@@cycle:
            mov byte ptr [di], bl 

            dec dx         
            inc di 

            cmp dx, 0
            jne @@cycle
            
            pop bx
            pop dx

            ret             
            endp
;------------------------------------------------
; ENTRY: DI - pointer to the object to fill
;        SI - pointer to the memory location to copy from
;        DX - number of bytes to copy
;
; EXIT:  AX - dest - DI.
;
; EXPECT:
;
; DESTROY: CX
;------------------------------------------------
_memcpy proc 
            mov ax, di      ; return value 
            push si         ; save bp value
            push dx

@@cycle:
            mov cl, byte ptr [si]
            mov byte ptr [di], cl 

            dec dx         
            inc si        
            inc di 

            cmp dx, 0
            jne @@cycle

            pop dx
            pop si
            ret             
            endp
;------------------------------------------------
; ENTRY: DI - pointer to the character array to write to
;        SI - pointer to the null-terminated byte string to copy from
;
; EXIT:  AX - dest = DI
;
; EXPECT:
;
; DESTROY: CX, DI
;------------------------------------------------
_strcpy proc 
            mov ax, di 

            push si         ; save bp value

@@cycle:
            mov cl, [si]
            mov [di], cl 
            
            cmp cl, 0
            je @@done

            inc si        
            inc di 

            jmp @@cycle 
@@done:
            pop si 
            ret             
            endp
;------------------------------------------------
; ENTRY: DI - pointer to the null-terminated byte strings to compare
;        SI - pointer to the null-terminated byte strings to compare
;
; EXIT:  AX - negative value if DI appears before SI in lexicographical order.
;             zero if DI and SI compare equal.
;             positive value if DI appears after SI in lexicographical order;
;
; EXPECT:
;
; DESTROY: CX, DI
;------------------------------------------------
_strcmp proc 
            xor ax, ax
            
            push di 
            push si 

@@cycle:
            mov cl, [si]
             
            cmp [di], cl 
            
            jne @@done 
            
            inc di 
            inc si 
            jmp @@cycle 

@@done:
            mov al, [di]
            sub al, cl

            pop si
            pop di

            ret  
            endp 
;------------------------------------------------
; ENTRY: DI, SI - pointer to the memory buffers to compare 
;        DX     - number of bytes to examine
;           
;
; EXIT:  AX - negative value if the first differing byte in DI is less than the corresponding byte in SI 
;             zero if all DX bytes of DI and SI are equal  
;             positive value if the first differing byte in DI is greater than corresponding byte in SI    
;
; EXPECT:
;
; DESTROY: 
;------------------------------------------------
_memcmp proc 
            xor ax, ax
            
            push di 
            push si 
            push dx

@@cycle:
            mov byte ptr cx, [si]
             
            cmp [di], byte ptr cx 
            
            jne @@done 
            
            inc di 
            inc si 
            dec dx
            cmp dx, 0
            jne @@cycle 

@@done:
            mov byte ptr ax, [di]
            sub ax, cx

            pop si
            pop di

            ret  
            endp 
;------------------------------------------------
main:
            mov di, offset line1
            mov si, offset line2
            mov dx, 3
            
            call _strcmp  

            mov ax, 4c00h
            int 21h           

            end start

