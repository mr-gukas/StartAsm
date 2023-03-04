.286
.model tiny
.code

locals @@ 
org 100h

start:  jmp     load                     ; переход на нерезидентную часть
        old09     dd  0                    ; адрес старого обработчика 
        old08     dd  0
        hotkey    db 0
        
        regsval dw 10 dup (?) 
        txtclr db 0ah
        hex    db "0123456789abcdef"

        _regtxt db "ax=", 0
                db "bx=", 0
                db "cx=", 0
                db "dx=", 0
                db "di=", 0 
                db "si=", 0
                db "bp=", 0
                db "ds=", 0
                db "es=", 0
;------------------------------------------------
make08  proc 
        mov     ax,  3508h               ; получение адреса старого обработчика
        int     21h                      ; прерываний от клавиатуры
        mov     word ptr old08,  bx        ; сохранение смещения обработчика
        mov     word ptr old08 + 2,  es    ; сохранение сегмента обработчика
        mov     ax,  2508h               ; установка адреса нашего обработчика
        mov     dx,  offset new08        ; указание смещения нашего обработчика
        int     21h                      ; вызов DOS

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
;------------------------------------------------
_regsdump    proc

        mov di, 160d + 71d*2 + 162d             ; настройка DI на начало текста 
        
        mov bp, 0
@@loop:
        shl bp, 2
        mov si, offset _regtxt
        add si, bp 

        mov ah, txtclr
            call _printstr
        push di
        add di, 6
        shr bp, 1
        mov bx, word ptr cs:[regsval + bp]
        shr bp, 1
        call print2hex 
        pop di
        add di, 160d
       
        inc bp
        cmp bp, 9
        jne @@loop

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
            push dx

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
            
            pop dx
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
new08   proc                             ; процедура обработчика прерываний от таймера
        cli
        pushf                            ; создание в стеке структуры для IRET
;----------------------------
;start doing shit ok?
        mov cs:[regsval + 14], ds 
        push    cs
        pop     ds
        mov [regsval], ax
        mov [regsval + 2], bx
        mov [regsval + 4], cx
        mov [regsval + 6], dx
        mov [regsval + 8], di
        mov [regsval + 10], si
        mov [regsval + 12], bp
        mov [regsval + 16], es 

        mov     bx,  0B800h              ; настройка AX на сегмент видеопамяти
        mov     es,  bx                  ; запись в ES значения сегмента видеопамяти
        mov di, 160d + 71d*2             ; настройка DI на начало таблицы 
        call printTable
        call _regsdump 

@@recovery:
;----------------------------
        mov ax, [regsval]
        mov bx, [regsval + 2]
        mov cx, [regsval + 4]
        mov dx, [regsval + 6]
        mov di, [regsval + 8]
        mov si, [regsval + 10]
        mov bp, [regsval + 12]
        mov es, [regsval + 16]
        mov ds, [regsval + 14]
;----------------------------
        sti
        call cs:old08
        iret                             ; возврат из обработчика
new08   endp                             ; конец процедуры обработчика


;------------------------------------------------
new09   proc                             ; процедура обработчика прерываний от таймера
        cli
        pushf                            ; создание в стеке структуры для IRET
        push ax
        in al, 60h
        cmp al, 29h
        jne @@callold
        pop ax
        cmp cs:[hotkey], 1
        je @@return
;----------------------------
        push es ds ax
;----------------------------
        push    cs
        pop     ds
        
        call make08
        
        mov cs:[hotkey], 1

        in al, 61h
        and al, 80h 
        out 61h, al
        or al, 80h
        out 61h, al
        mov al, 20h
        out 20h, al

@@recovery:
;----------------------------
        pop ax ds es
        popf
;----------------------------
        jmp @@done
@@callold:
        pop ax
@@return:
        call    cs:old09                   ; вызов старого обработчика прерываний
@@done:
        sti
        iret                             ; возврат из обработчика
new09   endp                             ; конец процедуры обработчика

EOP:                               ; метка для определения размера резидентной части программы
;------------------------------------------------

load:   mov     ax,  3509h               ; получение адреса старого обработчика
        int     21h                      ; прерываний от клавиатуры
        mov     word ptr old09,  bx        ; сохранение смещения обработчика
        mov     word ptr old09 + 2,  es    ; сохранение сегмента обработчика
        mov     ax,  2509h               ; установка адреса нашего обработчика
        mov     dx,  offset new09        ; указание смещения нашего обработчика
        int     21h                      ; вызов DOS

        mov     ax,  3100h               ; функция DOS завершения резидентной программы
        mov     dx, (EOP - start + 10Fh) / 16 ; определение размера резидентной
                                                    ; части программы в параграфах
        int     21h                      ; вызов DOS
        ends                             ; конец кодового сегмента
        end     start                    ; конец программы


