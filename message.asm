.model tiny
locals @@
;------------------------------------------------
.data
number db 5         ;MAX NUMBER OF CHARACTERS (4).
       db ?         ;NUMBER OF CHARACTERS ENTERED BY USER.
       db 5 dup (?) ;CHARACTERS ENTERED BY USER. 

hex    db "0123456789abcdef"
table_clr = 07eh
blue_clr  = 07bh

styles db 0c9h, 0cbh, 0bbh, 0cch, 0b0h, 0b9h, 0c8h, 0cah, 0bch

wide   dw 0
height dw 0
;------------------------------------------------
.code          
org 100h

start:      jmp main
;-------------------------------------------------
; ENTRY:    NONE 
;
; EXIT:     DI coordinate
;
; DESTROYS: NONE
;-------------------------------------------------
table_params proc
             
            mov cx, ds:[80h]
            mov ch, 0
            sub cl, 1
  
            xor bx, bx
            
            mov bl, 1
            mov bp, 0
            push bp

            mov si, 82h

lines:
            lodsb

            cmp al, "~" 
            jne @@next
            inc bl

            pop dx
            cmp bp, dx
            jle old_bp

            push bp
            mov bp, -1
            jmp @@next
old_bp:
            push dx 
            mov bp, -1
@@next:
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
            add bp, 2
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

            add di, ax

            mov ax, di 
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
; ENTRY:    NONE 
;
; EXIT:     NONE 
;
; EXPECT:   ES b800h 
;
; DESTROYS: CX
;-------------------------------------------------
printTable  proc
            
            call table_params
            push di 
            mov ah, table_clr
            push di 
            
            mov al, [styles + 2]
            push ax
            mov al, [styles + 1]
            push ax
            mov al, [styles]
            push ax
            push wide
            
            call printLine

            mov dx, height
            sub dx, 2

            pop di 
            add di, 160d
            push di 

@@cycle:
            mov al, [styles + 5]
            push ax
            mov al, [styles + 4]
            push ax
            mov al, [styles + 3]
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
            mov al, [styles + 8]
            push ax
            mov al, [styles + 7]
            push ax
            mov al, [styles + 6]
            push ax
            push wide


            call printLine
            
            pop di 
            ret 
            endp

;------------------------------------------------
 printLine  proc
            
            pop bp 
            pop cx
            
            sub cx, 2
            pop ax
            stosw
            pop ax
@@line:
            stosw
            loop @@line

            pop ax
            stosw
            
            push bp
            ret 
            endp
;-------------------------------------------------
printText   proc 
            
            mov cx, ds:[80h]
            mov ch, 0
            sub cl, 1

            push di
            mov ah, blue_clr 

@@lines:
            lodsb

            cmp al, "~" 
            jne @@next
            pop di 
            add di, 160
            push di 
            jmp @@done

@@next:
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

