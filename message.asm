.model tiny

locals @@
;-------------------------------------------------
.data
txt_clr  db 4eh

styles db 10 dup (?) 
       db 0c9h, 0cbh, 0bbh, 0cch, 0b0h, 0b9h, 0c8h, 0cah, 0bch, 7eh
       db 9 dup (03h), 0a4h 

wide      dw 0
height    dw 0
table_clr db 0
style     db 0
;-------------------------------------------------
.code          
org 100h

start:      jmp main
;-------------------------------------------------
; ENTRY:    NONE 
;
; EXIT:     DI table start
;           wide 
;           height
;           style 
;           
; EXPECT:              
;
; DESTROYS: AX, BX, BP, DX 
;-------------------------------------------------
table_params proc
             
            mov cx, ds:[80h]
            mov ch, 0
            sub cl, 1 ; fisrt symb is space
  
            xor bx, bx
            
            mov bl, 1 ; lines counter
            mov si, 82h ; cmd line args start
            
            lodsb 
            dec si
            cmp al, '0' ; if custom table style
            jne styleset
            
            add si, 2 
            mov bp, 0
readstyle:
            lodsb ; read customs style symbols
             
            mov [styles - bp], al
            inc bp 
            cmp bp, 9
            jne readstyle 
            
            add si, 1 ; read custom style color
            call readhex
            mov [styles + 9], dl 

            sub cl, 15
            mov bx, 1
            jmp newisset            


styleset:
           lodsb 
           sub al, 30h
           mov style, al ; set chosen style
           add si, 1
           sub cl, 2

newisset:
           mov bp, 0
           push bp

 
lines:
            lodsb

            cmp al, "~" ; new line sign
            jne @@next1
            inc bl

            pop dx
            cmp bp, dx ; for finding the longest line
            jle old_bp

            push bp
            mov bp, -1
            jmp @@next1
old_bp:
            push dx 
            mov bp, -1
@@next1:
            cmp al, '[' ; skip new txt clr
            jne @@next2
            add si, 5
            sub cx, 5
            jmp @@new_line
@@next2:
            inc bp
@@new_line:
            loop lines
            
            add bx, 2
            mov height, bx
             
            pop dx
            cmp bp, dx
            jge newwide
            mov bp, dx

newwide:
            add bp, 2 ; set wide 
            mov wide, bp

            mov ax, 80
            sub ax, wide

            mov dl, 2
            div dl 
            
            add al, ah 
            mov ah, 2
            mul ah 
            
            mov ah, 0
            mov di, ax
            
            mov ax, 25
            sub ax, height

            mov dl, 80
            mul dl 

            add di, ax ; table start here 

            mov ax, di  ; if di is in second part move it in first
            mov dl, 160
            div dl
            
            mov al, ah 
            mov ah, 0

            cmp ax, 80 

            jle @@done

            sub di, 80
@@done:
            ret 
            endp
;-------------------------------------------------
; ENTRY:    SI - begin of number  
;
; EXIT:     DL - the read number 
;
; EXPECT:    
;
; DESTROYS: AX, BX 
;-------------------------------------------------
readhex     proc 
            
            mov ah, 0
            mov bl, 16 
            mov dx, 0

@@cycle: 
            lodsb 
            cmp al, 20h
            je @@done 
            
            cmp al, 61h
            jge letter
            sub al, 30h 
            jmp @@next

letter: 
            sub al, 57h
@@next:
            add al, dl
            cmp byte ptr ds:[si], 20h ; if next symbol is space
            je @@last
            mul bl
@@last:
            mov dl, al 
            
            jmp @@cycle 

@@done:
            
            ret 
            endp
;-------------------------------------------------
; ENTRY:    NONE 
;
; EXIT:     DI table's start 
;
; EXPECT:   ES b800h 
;
; DESTROYS: AX, BX 
;-------------------------------------------------
printTable  proc
            
            call table_params
            push di ; first point addr

            mov al, style ; set style
            mov ah, 10
            mul ah 
            mov bx, offset styles 
            mov ah, 0
            add bx, ax
            


            mov ah, [bx + 9] ; set table clr
            push di ; save begin of the line
             
            mov al, [bx + 2] ; right upper corner
            push ax
            mov al, [bx + 1] ; middle upper elem
            push ax
            mov al, [bx]     ; left upper corner
            push ax
            push wide
            
            call printLine

            mov dx, height
            sub dx, 2

            pop di 
            add di, 160d ; next line
            push di 

@@cycle:
            mov al, [bx + 5] ; right middle elem
            push ax
            mov al, [bx + 4] ; middle middle elem
            push ax
            mov al, [bx + 3] ; left middle elem
            push ax
            push wide

            call printLine

            pop di 
            add di, 160d
            push di 
            
            dec dx
            cmp dx, 0
            jne @@cycle

            pop di 
            mov al, [bx + 8] ; right lower corner
            push ax
            mov al, [bx + 7] ; middle lower corner
            push ax
            mov al, [bx + 6] ; left lower corner
            push ax
            push wide


            call printLine
            
            pop di 
            ret 
            endp
;-------------------------------------------------
; ENTRY:    in stk: wide
;                   left corner 
;                   middle elem 
;                   right corner 
;           DI:     videoseg addr
;
; EXIT:     
;
; EXPECT:   
;
; DESTROY:  AX
;------------------------------------------------
 printLine  proc
            
            pop bp ; ret addr
            pop cx ; wide
            
            sub cx, 2
            pop ax ; lft_crn
            stosw
            pop ax ; middle elem
@@line:
            stosw
            loop @@line

            pop ax ; right crn
            stosw
            
            push bp
            ret 
            endp
;-------------------------------------------------
; ENTRY:    NONE
;
; EXIT:     DI last line coord
;
; EXPECT:   SI 82h
;
; DESTROY:  AX
;------------------------------------------------
printText   proc 
            
            mov cx, ds:[80h] ; count of char
            mov ch, 0
            sub cl, 1

            push di
            mov ah, txt_clr ; base color

            lodsb
            cmp al, '0'    ; if custom type
            je @@custom
            add si, 1
            sub cl, 2
            jmp @@lines

@@custom:
           add si, 14
           sub cl, 15

@@lines:
            lodsb

            cmp al, "~"  ; if new line
            jne @@next
            pop di 
            add di, 160
            push di 
            jmp @@done

@@next:
           cmp al, '[' ; if new txt clr 
           jne @@next1

           add si, 1 
           call readhex ; read clr
           add si, 1
           mov ah, dl
           sub cl, 5
           jmp @@done

@@next1:
           stosw 
@@done:
           loop @@lines
           
           pop di
           ret 
           endp 
;-------------------------------------------------
main:
            mov ax, 0b800h
            mov es, ax
 
            call printTable

            mov si, 82h
            add di, 162d

            call printText 

            mov ax, 4c00h
            int 21h           

            end start

