.model tiny
locals @@
;------------------------------------------------
.data
number db 5         ;MAX NUMBER OF CHARACTERS (4).
       db ?         ;NUMBER OF CHARACTERS ENTERED BY USER.
       db 5 dup (?) ;CHARACTERS ENTERED BY USER. 

hex    db "0123456789abcdef"

table_clr = 07eh
blue_clr   = 0bh

up_l_crn = 0c9h
lw_l_crn = 0c8h
up_r_crn = 0bbh
lw_r_crn = 0bch
up_hor   = 0cbh
lw_hor   = 0cah
l_vert   = 0cch
r_vert   = 0b9h

;------------------------------------------------
.code          
org 100h

start:      call main
;------------------------------------------------
; ENTRY:    BX number 
;           DI coordinate
;
; EXIT:     NONE 
;
; EXPECT:   ES 0b800h
;
; DESTROYS: AX
;------------------------------------------------
print2dec   proc
            push bx
            mov ax, bx 
            mov dl, 10
            mov cx, 0
            
@@cycle:	
            div dl
            
            mov dh, ah 
            mov ah, al
            mov al, dh
            add al, 48d
            mov bx, ax
            mov ah, blue_clr
            push ax
            add cl, 1
            
            mov ax, bx
            mov al, ah
            mov ah, 0
            
            cmp al, 0
            jne @@cycle

@@output:
            pop ax
            stosw
            loop @@output

            pop bx
            ret
            endp
;------------------------------------------------
; ENTRY:    BX number 
;           DI coordinate
;
; EXIT:     NONE 
;
; EXPECT:   ES 0b800h
;
; DESTROYS: AX
;------------------------------------------------
print2bin   proc
            push bx
            mov cl, 0
@@cycle:	
            shr bx, 1
            jc @@one
            mov al, 0
            jmp @@next
@@one:
            mov al, 1
@@next:
            add al, 48d
            mov ah, blue_clr
            push ax
            add cl, 1

            cmp bx, 0
            jne @@cycle
            
            mov ch, 0
output:
            pop ax
            stosw
            loop output

            pop bx

            ret
            endp
;------------------------------------------------
; ENTRY:    BX number 
;           DI coordinate
;
; EXIT:     NONE 
;
; EXPECT:   ES 0b800h
;
; DESTROYS: AX, DH, CH
;------------------------------------------------
print2hex   proc
            mov ax, 0
            push bx

@@cycle:	
            mov al, 0
            mov dh, 1
            mov ch, 4
    makesymb:
            shr bx, 1
            jc @@one
            jmp @@next

        @@one:
            add al, dh

        @@next:
            push ax
            mov al, dh
            mov dh, 2
            mul dh
            mov dh, al
            pop ax

            sub ch, 1
            cmp ch, 0
            jne makesymb
            mov ah, blue_clr
            
            push ax
            add cl, 1
            cmp bx, 0
            jne @@cycle

@@output:
            mov bx, offset hex
            pop ax
            xlat
            stosw
            loop @@output

            pop bx

            ret
            endp
;------------------------------------------------
; ENTRY:    DX string 
;
; EXIT:     BX number 
;
; EXPECT:   NONE
;
; DESTROYS: BP 
;------------------------------------------------
string2number         proc
            mov  si, offset number + 1 
            mov  cl, [si] ;number of characters                                          
            mov  ch, 0    ;
            add  si, cx   ;si points on least byte

            mov  bx, 0
            mov  bp, 1    ; ten in degree 0
repeat:         
            mov  al, [si] 
            sub  al, 48   ; make digit code 
            mov  ah, 0    
            mul  bp       ; AX*BP = DX:AX.
            add  bx,ax   

            mov  ax, bp
            mov  bp, 10
            mul  bp 
            mov  bp, ax   
            
            dec  si       ;next digit.
            loop repeat 
            ret 
            endp    
;-------------------------------------------------
; ENTRY:    NONE 
;
; EXIT:     DI coordinate
;
; DESTROYS: NONE
;-------------------------------------------------
getpoint    proc
            
            mov di, 0
            mov ah, 0ah
            mov dx, offset number
            int 21h
            
            call string2number ; get x coord

            mov ax, bx
            mov bl, 2d
            mul bl
            add di, ax

            mov  ah, 0ah
            mov  dx, offset number
            int  21h
            
            call string2number ; get y coord

            mov ax, bx
            mov bl, 160d 
            mul bl
            add di, ax

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
            call getpoint
            
            mov  ah, 0ah
            mov  dx, offset number
            int  21h

            call string2number
            
            push bx ; 
            
            mov  ah, 0ah
            mov  dx, offset number
            int  21h

            call string2number
            
            pop cx
            mov bh, cl

            mov ah, table_clr
            
            sub bl, 2
            sub bh, 2
            
            mov ch, 0
            mov cl, bl

            mov al, up_l_crn
            stosw

            mov al, up_hor
up_side:
            stosw
            loop up_side

            mov al, up_r_crn
            mov es:[di], ax
            
            mov cl, bh
            mov al, r_vert
r_side:
            add di, 160d
            mov es:[di], ax
            loop r_side


            add di, 160d
            mov al, lw_r_crn
            mov es:[di], ax
            
            std
            mov al, lw_hor
            mov cl, bl
            sub di, 2

lw_side:
            stosw
            loop lw_side

            cld

            mov al, lw_l_crn
            mov es:[di], ax
            
            mov cl, bh
            mov al, l_vert
l_side:
            sub di, 160d
            mov es:[di], ax
            loop l_side

            sub di, 160d
            ret 
            endp
            
;-------------------------------------------------
; ENTRY:    BX number
;
; EXIT:     NONE 
;
; EXPECT:   NONE 
;
; DESTROYS: NONE
;-------------------------------------------------
diffViews  proc
            push di
            call print2dec
            add di, 4
            call print2bin
            add di, 4
            call print2hex
            pop di

            ret 
            endp 
;-------------------------------------------------
main:
            mov ax, 0b800h
            mov es, ax
 
            call printTable

            add di, 324d
            
            mov  ah, 0ah
            mov  dx, offset number
            int  21h

            call string2number
            push bx

            mov  ah, 0ah
            mov  dx, offset number
            int  21h

            call string2number
            
            mov ax, bx
            pop bx
            push ax
            push bx

            add bx, ax
            call diffViews
            
            add di, 320
            pop bx
            pop ax
            push ax
            push bx
            sub bx, ax
            call diffViews

            add di, 320
            pop bx
            pop ax
            push ax
            push bx
             
            mul bl
            mov bx, ax
            call diffViews

            add di, 320
            pop ax
            pop bx

            div bl
            mov ah, 0
            mov bx, ax
            call diffViews

            mov  ax, 4c00h
            int  21h           

            end start
