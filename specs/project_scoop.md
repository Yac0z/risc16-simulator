# Project Scoop - Processeur RISC 16 bits

Ce projet consiste a concevoir, modeliser en VHDL, simuler sous ModelSim, puis
synthesiser/implementer sur FPGA Spartan 3E un processeur RISC 16 bits.

Contexte academique:
- Mini-projet "Conception de circuits numeriques" (2 Ing-ISEOC).
- Objectif: appliquer architecture processeur, RTL VHDL, verification,
	synthese et implementation FPGA.

Definition ISA et architecture:
- Processeur a une adresse.
- 64 registres de 16 bits.
- Registres speciaux:
	- R0 = ACC (accumulateur)
	- R63 = PC (program counter)
	- R62 = RPC (return program counter)
- Mot d'instruction 16 bits:
	- bits [15:12] = cond (predicate d'execution)
	- bits [11:8]  = op (opcode)
	- bit 7        = updt (mise a jour flags)
	- bit 6        = imm (0: registre, 1: immediat)
	- bits [5:0]   = val (rX si imm=0, sinon immediate X)

Statut/flags:
- Z (zero)
- N (negative)
- C (carry)
- V (overflow signe)

Regles flags importantes:
- Operations logiques: mettent a jour uniquement N et Z.
- Decalages: C prend le dernier bit ejecte; overflow si changement de signe.
- Addition/soustraction: gerer carry et overflow signe conformement a l'ISA.

Execution conditionnelle:
- Toutes les instructions sont conditionnelles via cond.
- Exemples donnes dans le sujet:
	- cond=0001 -> condition True (toujours executee)
	- cond=0010 -> execute si Z=1
	- cond=0100 -> execute si Z=0 et N=0 (positif)

Cycle processeur (FSM sur 5 etats):
- fetch1 -> fetch2 -> decode -> exec -> store

Semantique des etats:
- fetch1: PC sur bus d'adresse memoire.
- fetch2: mot instruction charge dans registre instruction.
- decode: chargement operandes op1/op2.
- exec:
	- calcul ALU
	- acces memoire initie (read/write)
	- increment PC, stocke dans PC (general) ou RPC (si CAL)
- store:
	- ecriture resultat ALU ou lecture memoire dans destination
	- pour CAL, ecriture dans PC

Composants a implementer:
- Registre instruction.
- Registre statut (4 bits).
- Banc de registres (64x16) avec lecture asynchrone de ACC et PC.
- ALU (AND/OR/XOR/NOT, ADD/SUB, shifts arithmetiques, recopie).
- Unite de controle FSM avec signaux:
	- instr_ce, acc_ce, pc_ce, rpc_ce, rx_ce, ram_we,
		sel_ram_addr, sel_op1, sel_rf_din
- Top-level structurel du processeur (interconnexion datapath + controle).

Regles banc de registres:
- Ecriture via din.
- Selection write enable:
	- acc_ce pour R0
	- pc_ce pour R63
	- rpc_ce pour R62
	- rx_ce pour registre pointe par rx_num
- Reset: PC doit revenir a 0x0000.

Contraintes techniques:
- Langage: VHDL RTL (synthesizable).
- Simulation: ModelSim.
- Cible implementation: FPGA Spartan 3E.
- Produire aussi une etude fmax et utilisation ressources (portes, Slices, CLB).

Etat actuel:
- Bootstrap a generer: structure projet, fichiers VHDL de base, package ISA,
	skeleton testbenches, et documentation AI de travail.

Attention importante:
- Les codes exacts d'opcodes et de conditions fournis dans les tableaux ont ete
	captures et integres au bootstrap VHDL.
