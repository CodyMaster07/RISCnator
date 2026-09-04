.data
msg_init: .asciz "Salve camarada! Eu sou o gênio RISCnator.\nEstou pensando em um número de 1 a 100, tente adivinhar qual é.\n"

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
	
	li s0, 67
	# Chama a função
	jal ra, get_chute # Chama a função recursiva
	
	j seq_end
	
get_chute: # FUNÇÃO QUE COLETA OS CHUTES DO USUÁRIO E VERIFICA SE ACERTOU
	# PRÓLOGO, armazenando na pilha o endereço de retorno e sX
	addi sp, sp, -4
	sw ra, 0(sp)
	li t1, 0 # Inicialização do contador de chutes

get_chute_cp: # CHECKPOINT	
	# CORPO
	li a7, 4 # Imprime a mensagem de inserir um chute
	la a0, msg_chute
	ecall
	
	li a7, 5 # Coleta o chute feito pelo usuário
	ecall
	mv t0, a0 # Armazena em t0 o chute atual
	
	addi sp, sp, -4 # Aumenta o espaço da pilha para armazenar o chute
	addi t1, t1, 1 # Adiciona um ao contador
	
	# VERIFICAÇÕES
	li t3, 100
	bgt t0, t3, inv_chute  # Se o número inserido for maior que 100, imprime a mensagem de invalidez e reinicia
	ble t0, zero, inv_chute # Se o número inserido for menor que 0 imprime a mensagem de invalidez e reinicia 
	
	sw t0, 0(sp) # Guarda na pilha o chute armazenado em t0 só se o chute NÂO FOR INVÁLIDO
	
	bgt t0, s0, lt_chute # Se o chute for maior que o alvo, chama a rotina de falar que é menor
	blt t0, s0, gt_chute # Se o chute for menor do que o alvo, chama a rotina de falar que é maior
		
	# EPÍLOGO - SE CHEGAR ATÉ AQUI O USUÁRIO ACERTOU!
	li a7, 4 # Imprime a primeira parte da msg final
	la a0, msg_end1
	ecall 
	
	li a7, 1 # Imprime o número de tentativas
	mv a0, t1
	ecall
	
	li a7, 4 # Imprime a segunda parte da msg final
	la a0, msg_end2
	ecall
	
	mv a1, t1 # Passa o número do contador para o parâmetro a0 para pop_stack
	
	li t1, 0 # Reseta t1
	jal pop_stack
	
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
	
	addi t1, t1, -1 # Reduz o contador
	
	addi sp, sp, 4 # Libera o espaço na pilha que não foi ocupado
	j get_chute_cp
	
pop_stack: # FUNÇÃO QUE PRITNTA TODOS OS CHUTES ARMAZENADOS NA STACK
	addi t1, t1, 1 # Incrementa o novo contador
	lw a0, 0(sp) # Guarda em a0 o chute a ser impresso
	addi sp, sp, 4
	
	li a7, 1 # Imprime o chute atual
	ecall
	
	li a7, 4 # Imprime o enter para separar os chutes
	la a0, enter
	ecall
	
	blt t1, a1, pop_stack # Se o contador não atingiu a quantidade de chutes, volte no pop
	jr ra

seq_end:  # ROTINA DE FINALIZAÇÃO NORMAL DO JOGO
	li a7, 4 # Imprime a msg final
	la a0, msg_goodbye
	ecall
	
	li a7, 93
	li a0, 0
	ecall
