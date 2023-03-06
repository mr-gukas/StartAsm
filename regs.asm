.286
.model tiny
.code


locals @@ 
org 100h

start:  jmp     main                ; jump to the non-resident part      
;------------------------------------------------
; resident data 
;------------------------------------------------
        old09      dd  0            ; address of the old 09 handler
        old08      dd  0            ; address of the old 08 handler 
        hotkey_on  db  0            ; frame_on
        hotkey_off db  0            ; frame_off

        regsval dw 10 dup (?)       ; save source regs value
        
        st_row   equ 1d
        st_col   equ 71d
        wid      equ 9d
        height   equ 11d
        st_frame equ 302d 

        txtclr db 0ah               ; table's text color
        hex    db "0123456789abcdef"; hex symbols table

        savebuf  dw 99 dup (0) 
        drawbuf  dw 99 dup (0) 

        _regtxt db "ax=", 0         ; regs frame strings
                db "bx=", 0
                db "cx=", 0
                db "dx=", 0
                db "di=", 0 
                db "si=", 0
                db "bp=", 0
                db "ds=", 0
                db "es=", 0
;------------------------------------------------
; unpin regs frame  
;------------------------------------------------
unlink08  proc 
        mov     ax,  2508h               
        mov     dx,  offset ret2old08    ; come back to old 08 
        int     21h                       
        ret 
        endp 
;------------------------------------------------
ret2old08 proc 
        cli
        pushf   
        cmp cs:[hotkey_on], 0
        je @@done

        mov cs:[regsval + 14], ds 
        push    cs
        pop     ds
;----------------------------
        mov [regsval    ], ax
        mov [regsval + 2], bx
        mov [regsval + 4], cx
        mov [regsval + 6], dx
        mov [regsval + 8], di
        mov [regsval + 10], si
        mov [regsval + 12], bp
        mov [regsval + 16], es 
;----------------------------
        call _restorevid
        mov cs:[hotkey_on], 0

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
@@done:
        call cs:old08
        sti
        iret                            
        endp                             
;------------------------------------------------
link08  proc 
        mov     ax,  2508h               ; link based link interrupt with regs frame 
        mov     dx,  offset new08        
        int     21h                      

        ret 
        endp 
;------------------------------------------------
; copy bytes from videoseg to buffer
;------------------------------------------------
; ENTRY: si buff addr
; EXIT:
; EXPECT: es b800h
; DESTROYS: 
;------------------------------------------------
_savebuf proc
        pusha
        mov ax, 0b800h 
        mov es, ax
        
        mov di, st_frame 
        mov cx, height 
@@rows:
        push cx
        mov cx, wid 
        push di
@@in_row:
        mov ax, es:[di]
        mov cs:[si], ax
        add si, 2
        add di, 2
        loop @@in_row
        
        pop di 
        add di, 160d
        pop cx
        
        loop @@rows
        popa
        ret
        endp
;------------------------------------------------
; compares the video segment with the data from the frame buffer
;------------------------------------------------
; ENTRY: 
; EXIT:
; EXPECT: es b800h
; DESTROYS: 
;------------------------------------------------
_checkbuf proc
        mov di, st_frame
        mov si, offset drawbuf 

        mov cx, height 
@@rows:
        push cx
        mov cx, wid 
        push di
@@in_row:
        mov ax, word ptr [si]
        cmp word ptr es:[di], ax
        jne @@recovery

        add di, 2
        add si, 2 
        loop @@in_row
        
        pop di 
        add di, 160d
        pop cx
        
        loop @@rows
        jmp @@return

@@recovery:
        pop di
        pop cx
        mov si, offset savebuf
        call _savebuf
@@return:
        ret  
        endp
;------------------------------------------------
; restores the video segment using the data from the buffer
;------------------------------------------------
; ENTRY: 
; EXIT:
; EXPECT: 
; DESTROYS: 
;------------------------------------------------
_restorevid proc 
        mov ax, 0b800h 
        mov es, ax 
        mov di, st_frame

        mov si, offset savebuf
        mov cx, height
@@rows:
        push cx 
        mov cx, wid
        push di
@@in_row:
        lodsw 
        stosw
        loop @@in_row
        
        pop di 
        add di, 160d 
        pop cx
        loop @@rows

        ret
        endp
;------------------------------------------------
; Show regs value in the frame
;------------------------------------------------
; ENTRY:   none 
;
; EXIT:    none 
;
; EXPECT:   es 0b800h
;
; DESTROYS: bx, si, di, bp 
;------------------------------------------------
_regsdump    proc

        mov di, st_frame + 162d             ; place where the text starts 
        
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
        call _print2hex 
        pop di
        add di, 160d
       
        inc bp
        cmp bp, 9
        jne @@loop

        ret 
        endp

;------------------------------------------------
; displays the null-terminated string on the videseg
;------------------------------------------------
; ENTRY:    di coordinate
;           si string pointer    
;           ah text color
;
; EXIT:     NONE 
;
; EXPECT:   es 0b800h
;
; DESTROYS: ax, si 
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
; displays the number in hex on the videoseg
;------------------------------------------------
; ENTRY:    bx number 
;           di coordinate
;
; EXIT:     none 
;
; EXPECT:   es 0b800h
;
; DESTROYS: ax, dh, ch 
;------------------------------------------------
_print2hex   proc
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
_printline  proc
            
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
_printframe  proc
            
            mov ah, txtclr ; set table clr
            push di     ; save begin of the line
             
            mov al, 0bbh ; right upper corner
            push ax
            mov al, 0cbh ; middle upper elem
            push ax
            mov al, 0c9h ; left upper corner
            push ax
            push wid 
            
                call _printline

            mov dx, height 
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
            push wid 

                call _printline

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
            push wid 

                call _printline
            
            ret 
            endp
;------------------------------------------------
new08   proc                             ; процедура обработчика прерываний от таймера
        cli
        pushf                            ; создание в стеке структуры для IRET
        cmp cs:[hotkey_on], 1
        jne @@done
;----------------------------
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

        mov     bx,  0B800h              
        mov     es,  bx                  

        call _checkbuf

        mov di, st_frame             ; set di on frame's start 
        call _printframe
        call _regsdump 

        mov si, offset drawbuf
            call _savebuf

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
@@done:
        sti
        call cs:old08
        iret                            
new08   endp                             

;------------------------------------------------
new09   proc                             
        cli
        pushf                            
        push ax
        in al, 60h
        cmp al, 29h             ; ~ button
        je @@turnon

@@turnoff:
        cmp al, 28h            ; ' button 
        jne @@callold
        pop ax
        cmp cs:[hotkey_on], 0
        je @@return 
        cmp cs:[hotkey_off], 1
        je @@return 
        jmp @@off  

@@turnon:
        pop ax
        cmp cs:[hotkey_on], 1
        je @@return
;----------------------------
        push es ds ax
        push    cs
        pop     ds
        
        mov si, offset savebuf  
        call _savebuf

        call link08
        mov cs:[hotkey_on], 1
        jmp @@wink

@@off:
        push es ds ax
        push    cs
        pop     ds
        call unlink08
        mov cs:[hotkey_off], 0
@@wink:
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
        call    cs:old09            ; call the old interrupt handler
@@done:
        sti
        iret                        ; return from the handler 
new09   endp                        ; end of handler procedure

EOP:                                ; label to determine the size of the resident part of the program
;------------------------------------------------

main:   mov     ax,  3509h               ; get the address of the old handler keyboard interrupt
        int     21h                      
        mov     word ptr old09,  bx      ; save handler offset 
        mov     word ptr old09 + 2,  es  ; save handler segment 
      
        mov     ax,  3508h               ; getting the address of the old interrupt handler from the timer counter       
        int     21h                      
        mov     word ptr old08,  bx        
        mov     word ptr old08 + 2,  es    

        mov     ax,  2509h               ;  set the address of new handler
        mov     dx,  offset new09        ;  set the new handler's offset
        int     21h                      

        mov     ax,  2508h               ;  set the address of new handler
        mov     dx,  offset new08        ;  set the new handler's offset
        int     21h                      

        mov     ax,  3100h               
        mov     dx, (EOP - start + 10Fh) / 16 ; determining the size of the resident program
                                                    
        int     21h                      
        ends                             
end     start                    



