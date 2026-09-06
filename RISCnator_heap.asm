.data
msg_init: .asciz "Salve camarada! Eu sou o gênio RISCnator.\nEstou pensando em um número de 1 a 100, tente adivinhar qual é!\nConforme você for chutando, vou te informar se o meu número é maior ou menor que o número que você chutou.\n"

msg_chute: .asciz "Chute um número de 1 a 100: "

msg_gt: .asciz "Meu número é maior que "

msg_lt: .asciz "Meu número é menor que "

msg_end1: .asciz "Você acertou! Essas foram todas as suas "
msg_end2: .asciz " tentativas até chegar na resposta:\n"

msg_inv: .asciz "Esse chute é inválido!\n"

msg_goodbye: .asciz "Adeus!"

exc: .asciz "!\n"

enter: .asciz "\n"

space: .asciz " "

.globl main
.text
.align 2
main:	
	li a7, 4 # Imprime a mensagem inicial
	la a0, msg_init
	ecall 
	
	# Chama a função de gerar um número aleatório
	jal get_rand
	
	li t1, 100
	rem s0, a0, t1
	addi s0, s0, 1 # Faz com que o número seja do intervalo de entre 1 a 100
	
	# Chama a função
	jal ra, get_chute # Chama a função recursiva
	
	j seq_end
	
get_chute: # FUNÇÃO QUE COLETA OS CHUTES DO USUÁRIO E VERIFICA SE ACERTOU
	# PRÓLOGO, armazenando na pilha o endereço de retorno e sX
	addi sp, sp, -4
	sw ra, 0(sp)
	li t1, 0 # Inicialização do contador de chutes
	
	li a7, 9 # Aluga espaço na heap para o chute inicial e guarda o endereço inicial na memória
	li a0, 8 # 8 bytes, 4 para o número, 4 para o endereço
	ecall
	mv s1, a0 # Em s1 está o endereço inicial da Linked List
	mv t2, s1 # Guarda em t2 o endereço atual
	
get_chute_cp: # CHECKPOINT	
	# CORPO
	li a7, 4 # Imprime a mensagem de inserir um chute
	la a0, msg_chute
	ecall
	
	li a7, 5 # Coleta o chute feito pelo usuário
	ecall
	mv t0, a0 # Armazena em t0 o chute atual
	
	# VERIFICAÇÕES
	li t3, 100
	bgt t0, t3, inv_chute  # Se o número inserido for maior que 100, imprime a mensagem de invalidez e reinicia
	ble t0, zero, inv_chute # Se o número inserido for menor que 0 imprime a mensagem de invalidez e reinicia 
	
	addi t1, t1, 1 # Adiciona um ao contador
	
	# ADIÇÃO NA LINKED LIST
	sw t0, 0(t2) # Guarda no endereço atual o chute
	
	li a7, 9 # Cria mais um slot da lista
	li a0, 8
	ecall

	sw a0 4(t2) # Guarda o próximo endereço no fim do slot anterior

	mv t2, a0 # O endereço atual recebe agora o novo endereço
	
	bgt t0, s0, lt_chute # Se o chute for maior que o alvo, chama a rotina de falar que é menor
	blt t0, s0, gt_chute # Se o chute for menor do que o alvo, chama a rotina de falar que é maior
		
	# EPÍLOGO - SE CHEGAR ATÉ AQUI O USUÁRIO ACERTOU!
	li t0, -1
	sw t0, 0(t2) # Guarda -1 no próximo endereço (número inválido que indica fim)
	sw t0, 4(t2) # Guarda -1 no endereço (para garantir que não salte para lugar nenhum)
	
	li a7, 4 # Imprime a primeira parte da msg final
	la a0, msg_end1
	ecall 
	
	li a7, 1 # Imprime o número de tentativas
	mv a0, t1
	ecall
	
	li a7, 4 # Imprime a segunda parte da msg final
	la a0, msg_end2
	ecall
	
	mv a1, t1 # Passa o número do contador para o parâmetro a1 para go_trough_list
	
	li t1, 0 # Reseta t1
	jal go_through_list # Chama a função para percorrer a lista e printar os chutes
	
	lw ra, 0(sp) # Recupera o endereço de retorno e desocupa pilha
	addi sp, sp, 4
	
	jr ra
	
gt_chute: # ROTINA QUE IMPRIME MENSAGEM QUE O CHUTE É MAIOR QUE O NÚMERO
	li a7, 4 # Imprime a mensagem adequada
	la a0, msg_gt
	ecall
	
	li a7, 1 # Imprime o chute atual
	mv a0, t0
	ecall
	
	li a7, 4 # Imprime a exclamação e o enter para finalizar a mensagem
	la a0, exc
	ecall
	
	j get_chute_cp
	
lt_chute: # ROTINA QUE IMPRIME MENSAGEM QUE O CHUTE É MENOR QUE O NÚMERO
	li a7, 4 # Imprime a mensagem adequada
	la a0, msg_lt
	ecall
	
	li a7, 1 # Imprime o chute atual
	mv a0, t0
	ecall
	
	li a7, 4 # Imprime a exclamação e o enter para finalizar a mensagem
	la a0, exc
	ecall
	
	j get_chute_cp
	
inv_chute:  # ROTINA QUE IMPRIME MENSAGEM DE NÚMERO INVÁLIDO
	li a7, 4 # Imprime a mensagem de resposta
	la a0, msg_inv
	ecall 
	
	j get_chute_cp
	
get_rand: # FUNÇÃO QUE GERA UM NÚMERO ALEATÓRIO ENTRE DA ESCALA DE 2^31 (LINEAR CONGRUENTIAL GENERATOR)
	li a7, 30 # Carrega o código para obter o timer atual da máquina
	ecall
	
	# Gerador: X = (A*Xo + B)mod 2^31 
	li a1, 1103515245 # Carrega em a1 o A
	li a2, 12345 # Carrega em a2 oo B
	li a3, 1
	
	mul a0, a0, a1
	add a0, a0, a2
	
	srli a0, a0, 1 # Descarta o bit de sinal de complemento de dois
	
	jr ra

go_through_list: # FUNÇÃO QUE PRITNTA TODOS OS CHUTES ARMAZENADOS NA HEAP
	addi sp, sp, -8 # Guardando na pilha o endereço de retorno e o endereço do início da lista
	sw ra, 4(sp)
	sw s1, 0(sp)
	
go_through_list_cp: # CHECKPOINT PARA O LOOP
	addi t1, t1, 1 # Incrementa o novo contador
	lw a0, 0(s1) # Guarda em a0 o chute a ser impresso
	lw t0, 4(s1) # Guarda em t0 o próximo endereço a ser percorrido
	
	mv s1, t0 # Passa o próximo endereço a ser lido para s1
	
	li a7, 1 # Imprime o chute atual
	ecall
	
	li a7, 4 # Imprime o enter para separar os chutes
	la a0, enter
	ecall
	
	blt t1, a1, go_through_list_cp # Se o contador não atingiu a quantidade de chutes, volte na função
	
	lw ra, 4(sp)
	lw s1, 0(sp)
	addi sp, sp, 8
	jr ra

seq_end:  # ROTINA DE FINALIZAÇÃO NORMAL DO JOGO
	li a7, 4 # Imprime a msg final
	la a0, msg_goodbye
	ecall
	
	li a7, 93
	li a0, 0
	ecall