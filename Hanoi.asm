;;
;
;;; TORRE DE HANOI - NASM - X86
;;; Linux 32 bits
;;


;__PARTE EXECUTÁVEL;

section .text

    global _start                       ;SE FOR RODAR ONLINE
    ;global hanoi                       ;SE FOR RODAR EM MÁQUINA LINUX 32BITS

;__PRINCIPAL;

    _start:                             ;SE FOR RODAR ONLINE
    ;hanoi:                             ;SE FOR RODAR EM MÁQUINA LINUX 32BITS

        push ebp                        ; salva o registrador base na pilha
        mov ebp, esp                    ; ebp recebe o ponteiro para o topo da pilha (esp)

        ; MENSAGEM DE BOAS VINDAS
        mov edx,len                     ; recebe o tamanho da mensagem
        mov ecx,menu                    ; recebe a mensagem
        mov ebx,1                       ; entrada padrão 
        mov eax,4                       ; informa que será uma escrita no ecrã
        int 0x80                        ; Interrupção Kernel Linux

        ;ENTRADA DO TECLADO (USUÁRIO DIGITA A QUANTIDADE DE DISCOS)
        mov edx, 5                      ; tamanho da entrada 
        mov ecx, disk                   ; armazenamento em 'disk'
        mov ebx, 0                      ; entrada padrão
        mov eax, 3                      ; informa que serÃ¡ uma leitura           
        int 0x80                        ; Interrupção Kernel Linux
        
        mov edx, disk                   ; Move o endereÃ§o referente a quantidade de discos para o registrador eax
        call    _atoi

        ; REFERENCIA PARA AS 3 PILHAS (3 PINOS) DA TORRE DE HANOI EM ORDEM
        push dword 0x2                  ; pino de trabalho (pilha)
        push dword 0x3                  ; pino de destino (pilha)
        push dword 0x1                  ; pino de origem (pilha)
        push eax                        ; eax na pilha ( n = numero de discos inicial )

        call funcaoHanoi                 ; Chama a função rhanoi

        ; Converte instrucoes_executadas para string
        mov eax, [instrucoes_executadas]
        lea ebx, [num_buffer]           ; Endereço do buffer para armazenar a string convertida
        call itoa                       ; Chama a função itoa para converter o número para string

        ; Imprime a mensagem final
        mov eax, 4                          ; syscall para imprimir
        mov ebx, 1                          ; file descriptor (stdout)
        mov ecx, mensagem_final       ; ponteiro para a mensagem final
        mov edx, len_mensagem_final         ; tamanho da mensagem final em bytes
        int 0x80                            ; chama o kernel para imprimir

        ; FIM DO PROGRAMA
        mov eax, 1                      ; Saida do sistema
        mov ebx, 0                      ; saida padrão  
        int 0x80                        ; Interrupção Kernel Linux


;__CONVERSÃO DE ASCII PARA INTEGER;

_atoi:
    xor     eax, eax                    ; Limpa o registrador (define o bit resultante para 1 , se e somente se os bits dos operandos são diferentes. Se os bits dos operandos são os mesmos ( ambos 0 ou ambos 1 ) , o bit resultante é limpo para 0)
    mov     ebx, 10                     ; EBX vai ser o registrador auxiliar de multiplicação.
    
    .loop:
        movzx   ecx, byte [edx]         ; Mover um byte de EDX para ECX. [Representando um "nÃºmero"]
        inc     edx                     ; Aumenta o EDX para que aponte para o prÃ³ximo byte.
        cmp     ecx, '0'                ; Comparar ECX com '0'
        jb      .done                   ; Caso for menor, pule pra linha .done
        cmp     ecx, '9'                ; Comparar ECX com '9'
        ja      .done                   ; Caso for maior, pule pra linha .done
        
        sub     ecx, '0'                ; Subtrai a "string" de 'zero', irá "transformar em int"
        imul    eax, ebx                ; Multiplica por EBX, na primeira interação resultado Ã© 0!
        add     eax, ecx                ; Adiciona o valor de ECX que foi "convertido" a EAX
        jmp     .loop                   ; Fazer isso até chegar em uma das comparações acima.
    
    .done:
        ret 


;__FUNÇÃO QUE EXECUTA O ALGORITMO HANOI;

    funcaoHanoi: 

        ;[ebp+8] = n (número de discos iniciais) 
        ;[ebp+12] = pino de origem
        ;[ebp+16] = pino de trabalho
        ;[ebp+20] = pino de destino
        ;link: http://www.devmedia.com.br/torres-de-hanoi-solucao-recursiva-em-java/23738

        push ebp                        ; salva o registrador ebp na pilha
        mov ebp,esp                     ; ebp recebe o endereço do topo da pilha

        mov eax,[ebp+8]                 ; pega o a posição do primeiro elemento da pilha e mov para eax
        cmp eax,0x0                     ; cmp faz o comparativo do valor que estar em eax com 0x0 = 0 em hexadecimal 
        jle fim                         ; se eax for menor ou igual a 0, vai para o fim, desempilhar
        
        ;PASSO1 - RECURSIVIDADE
        dec eax                         ; decrementa 1 de eax
        push dword [ebp+16]             ; coloca na pilha o pino de trabalho
        push dword [ebp+20]             ; coloca na pilha o pino de destino
        push dword [ebp+12]             ; coloca na pilha o pino de origem
        push dword eax                  ; poe eax na pilha como parâmetro n, já com -1 para a recursividade
        call funcaoHanoi                ; Chama a mesma função (recursividade)

        ;PASSO2 - MOVER PINO E IMPRIMIR
        add esp,12                      ; libera mais 12 bits de espaço (20 - 8) Último e primeiro parâmetro
        push dword [ebp+16]             ; pega o pino de origem referenciado pelo parâmetro ebp+16
        push dword [ebp+12]             ; coloca na pilha o pino de origem
        push dword [ebp+8]              ; coloca na pilha o pino de o numero de disco inicial
        call imprime                    ; Chama a função 'imprime'
        inc dword [instrucoes_executadas]        ; Incrementa o contador de instruções

        
        ;PASSO3 - RECURSIVIDADE
        add esp,12                      ; libera mais 12 bits de espaço (20 - 8) Último e primeiro parâmetro
        push dword [ebp+12]             ; coloca na pilha o pino de origem
        push dword [ebp+16]             ; coloca na pilha o pino de trabalho
        push dword [ebp+20]             ; coloca na pilha o pino de destino
        mov eax,[ebp+8]                 ; move para o registrador eax o espaço reservado ao número de discos atuais
        dec eax                         ; decrementa 1 de eax

    push dword eax                      ; poe eax na pilha
        call funcaoHanoi                ; (recursividade)

    fim: 

        mov esp,ebp                     ; Move o valor de ebp para esp (guarda em outro registrador)
        pop ebp                         ; Remove da pilha (desempilha) o ebp
        ret                             ; Retorna a função de origem (antes de ter chamado a função 'fim')

    imprime:

        push ebp                      ; empurra o registrador ebp na pilha (para ser a base)
        mov ebp, esp                  ; aponta o ponteiro do topo da pilha (esp) para a base
        

        mov eax, [ebp + 8]         ; Coloca o número a ser convertido em eax
        lea ebx, [num_buffer]      ; Endereço do buffer para armazenar a string convertida
        call itoa                  ; Chama a função itoa para converter o número para string
        lea edi, [disco ]      ; Endereço de destino (disco), pulando os dois espaços iniciais
        mov esi, ebx               ; Endereço de origem (buffer)
        
        ; Copia a string convertida diretamente para disco, começando após os dois espaços
        mov ecx, num_length        ; Tamanho da string convertida
        rep movsb                  ; Copia a string de esi para edi


        mov eax, [ebp + 12]           ; coloca no registrador ax a torre de onde o disco saiu
        add al, 64                    ; conversao na tabela ASCII
        mov [pino_destino], al         ; coloca o valor no [torre_saida] para o print

        mov eax, [ebp + 16]           ; coloca no registrador ax a torre de onde o disco foi
        add al, 64                    ; conversao na tabela ASCII
        mov [pino_origem], al           ; coloca o valor no [torre_ida] para o print

        mov edx, lenght               ; tamanho da mensagem
        mov ecx, msg                  ; mensagem em si
        mov ebx, 1                    ; dá permissão para a saida
        mov eax, 4                    ; informa que será uma escrita
        int 128                       ; Interrupção para kernel

        mov     esp, ebp              ; aponta o ponteiro da base da pilha (ebp) para o topo
        pop     ebp                   ; tira o elemento do topo da pilha e guarda o valor em ebp
        ret                           ; retira o ultimo valor do topo da pilha e da um jump para ele (a linha de retorno nesse caso)
itoa:
    ; Entradas:
    ; eax: número a ser convertido
    ; ebx: endereço do buffer para armazenar a string convertida

    cmp eax, 0      ; Verifica se o número é zero
    jne convert_loop ; Se não for zero, pula para o loop de conversão
    ; Caso seja zero, coloca '0' no buffer e termina
    mov byte [ebx], '0'
    mov byte [ebx + 1], 0
    ret

convert_loop:
    mov     ecx, 10            ; Divisor (base decimal)
    xor     edx, edx           ; Limpa edx para a divisão
    div     ecx                ; Divide eax por 10, resultado em eax, resto em edx
    add     dl, '0'            ; Converte o resto para caractere ASCII
    dec     ebx                ; Move o ponteiro para o buffer para a próxima posição
    mov     [ebx], dl          ; Armazena o caractere convertido no buffer
    test eax, eax               ; Verifica se eax (quociente) é zero
    jnz  convert_loop          ; Se não for zero, continua o loop

    ret


;__DECLARAÇÃO DE VARIÁVEIS INICIALIZADAS;
section .data
   
    menu db 'DIGITE A QUANTIDADE DE DISCOS: ' ,0xa      ; mensagem do menu que aparecerá ao rodar a aplicação
    len equ $-menu                                      ; tamanho da mensagem do menu armazenado em na variável 'len'

    ; formatação da mensagem
    msg:
                          db        "disc: "   
        disco:            db        "  "
                          db        "   "                      
        pino_destino:      db        " "  
                          db        " -> "     
        pino_origem:     db        " ", 0xa  ; para quebrar linha
        
        lenght            equ       $-msg

    mensagem_final db 'Número de movimentos:   ', 0xa    ; mensagem final
    len_mensagem_final equ $-mensagem_final             ; tamanho da mensagem final
    num_length equ 10                  ; tamanho máximo da string convertida

    num_buffer resb 10                ; buffer para armazenar a string convertida do número


;__DECLARAÇÃO DE VARIÁVEIS NÃO INICIALIZADAS;
section .bss

    disk resb 5                 ; Armazenamento de dados não inicializado
    
    instrucoes_executadas resd 1       ; Variável para contar as instruções executadas
