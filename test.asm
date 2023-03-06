.286
.model tiny
locals @@
.code 
org 100h
start:
    mov ax, 1111h
    mov bx, 2222h
    mov cx, 3333h
    mov dx, 4444h
@@loop:
    in al, 60h
    cmp al, 02h
    jne @@loop

    mov ax, 4c00h
    int 21h

end start

