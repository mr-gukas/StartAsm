.286
.model tiny
.code

locals @@ 
org 100h

start:  jmp     load                     ; переход на нерезидентную часть
        old     dd  0                    ; адрес старого обработчика 

txtclr db 0ah
hex    db "0123456789abcdef"

_ax     db "ax=", 0
_bx     db "bx=", 0
_cx     db "cx=", 0
_dx     db "dx=", 0
_di     db "di=", 0 
_si     db "si=", 0
_bp     db "bp=", 0
_ds     db "ds=", 0
_es     db "es=", 0
;------------------------------------------------
; ENTRY:    DI coordinate
;           SI string pointer    
;           AH text color
;
; EXIT:     NONE 
;
; EXPECT:   ES 0b800h
;
; DESTROYS: AX, SI 
;------------------------------------------------
_showreg    proc
        pop bp

        mov di, 160d + 71d*2 + 162d             ; настройка DI на начало текста 

        mov si, offset _ax
        mov ah, txtclr
            call _printstr
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print ax
        pop di  
        add di, 160d

        mov si, offset _bx
        mov ah, txtclr
            call _printstr
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print bx
        pop di  
        add di, 160d

        mov si, offset _cx
        mov ah, txtclr
            call _printstr
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print cx
        pop di  
        add di, 160d
        
        mov si, offset _dx
        mov ah, txtclr
            call _printstr
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print dx
        pop di  
        add di, 160d

        mov si, offset _di
        mov ah, txtclr
            call _printstr
        
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print di
        pop di  
        add di, 160d

        mov si, offset _si
        mov ah, txtclr
            call _printstr
        
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print si
        pop di  
        add di, 160d
        
        mov si, offset _bp
        mov ah, txtclr
            call _printstr
        
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print bp
        pop di  
        add di, 160d
        
        mov si, offset _ds
        mov ah, txtclr
            call _printstr
        
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print ds
        pop di  
        add di, 160d
         
        mov si, offset _es
        mov ah, txtclr
            call _printstr
        
        pop  bx       
        push di 
        add di, 6
            call print2hex  ; print di
        pop di  

        push bp
        ret 
        endp
;------------------------------------------------
; ENTRY:    DI coordinate
;           SI string pointer    
;           AH text color
;
; EXIT:     NONE 
;
; EXPECT:   ES 0b800h
;
; DESTROYS: AX, SI 
;------------------------------------------------
_printstr   proc 
        push di
@@loop:
        lodsb
        cmp al, 0
        je @@done 

        stosw 
        jmp @@loop 

@@done:
        pop di 
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
            mov ah, txtclr
            
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
; EXIT:     DI table's start 
;
; EXPECT:   ES b800h 
;
; DESTROYS: AX, BX 
;-------------------------------------------------
printTable  proc
            
            mov ah, txtclr ; set table clr
            push di     ; save begin of the line
             
            mov al, 0bbh ; right upper corner
            push ax
            mov al, 0cbh ; middle upper elem
            push ax
            mov al, 0c9h ; left upper corner
            push ax
            push 9d
            
                call printLine

            mov dx, 11d
            sub dx, 2d

            pop di 
            add di, 160d ; next line
            push di 

@@cycle:
            mov al, 0b9h ; right middle elem
            push ax
            mov al, 20h ; middle middle elem
            push ax
            mov al, 0cch ; left middle elem
            push ax
            push 9d 

                call printLine

            pop di 
            add di, 160d
            push di 
            
            dec dx
            cmp dx, 0
            jne @@cycle

            pop di 

            mov al, 0bch ; right lower corner
            push ax
            mov al, 0cah ; middle lower corner
            push ax
            mov al, 0c8h ; left lower corner
            push ax
            push 9d 

                call printLine
            
            ret 
            endp

;------------------------------------------------
new09   proc                             ; процедура обработчика прерываний от таймера
        cli
        pushf                            ; создание в стеке структуры для IRET
        push ax
        in al, 60h
        cmp al, 29h
        jne @@callold
        pop ax
;----------------------------
        push es
        push ds 
        push bp 
        push si
        push di 
        push dx
        push cx
        push bx 
        push ax
;----------------------------
        push    cs
        pop     ds
        
        push es
        push ds 
        push bp 
        push si
        push di 
        push dx
        push cx
        push bx 
        push ax

        mov     bx,  0B800h              ; настройка AX на сегмент видеопамяти
        mov     es,  bx                  ; запись в ES значения сегмента видеопамяти
        mov di, 160d + 71d*2             ; настройка DI на начало таблицы 
        call printTable
        call _showreg 

        in al, 61h
        and al, 80h 
        out 61h, al
        or al, 80h
        out 61h, al
        mov al, 20h
        out 20h, al

@@recovery:
;----------------------------
        pop     ax 
        pop     bx                       ; восстановление модифицируемых регистров
        pop     cx
        pop     dx
        pop     di
        pop     si
        pop     bp
        pop     ds
        pop     es
        popf
;----------------------------
        jmp @@done
@@callold:
        pop ax
        call    cs:old                   ; вызов старого обработчика прерываний
@@done:
        sti
        iret                             ; возврат из обработчика
new09   endp                             ; конец процедуры обработчика

EOP:                               ; метка для определения размера резидентной части программы
;------------------------------------------------

load:   mov     ax,  3509h               ; получение адреса старого обработчика
        int     21h                      ; прерываний от клавиатуры
        mov     word ptr old,  bx        ; сохранение смещения обработчика
        mov     word ptr old + 2,  es    ; сохранение сегмента обработчика
        mov     ax,  2509h               ; установка адреса нашего обработчика
        mov     dx,  offset new09        ; указание смещения нашего обработчика
        int     21h                      ; вызов DOS
        mov     ax,  3100h               ; функция DOS завершения резидентной программы
        mov     dx, (EOP - start + 10Fh) / 16 ; определение размера резидентной
                                                    ; части программы в параграфах
        int     21h                      ; вызов DOS
        ends                             ; конец кодового сегмента
        end     start                    ; конец программы


