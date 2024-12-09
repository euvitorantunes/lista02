Este projeto implementa um sistema de gerenciamento acadêmico utilizando pacotes PL/SQL para o Oracle Database. Ele oferece funcionalidades para gerenciar alunos, disciplinas e professores.

Funcionalidades

PKG_ALUNO (Pacote de Alunos)
Excluir aluno e suas matrículas
Listar alunos maiores de 18 anos
Listar alunos por disciplina

PKG_DISCIPLINA (Pacote de Disciplinas)
Cadastrar novas disciplinas
Obter o total de alunos por disciplina
Calcular a idade média por disciplina
Listar alunos matriculados em uma disciplina

PKG_PROFESSOR (Pacote de Professores)
Obter o total de turmas por professor
Calcular o total de turmas para um professor específico
Encontrar o professor que ministra uma disciplina específica

Instalação
Conecte-se ao seu banco de dados Oracle usando o SQL*Plus ou outro cliente Oracle.
Execute o script academic_management_system.sql:
sql

Copiar código
@academic_management_system.sql
Detalhes dos Pacotes

PKG_ALUNO
delete_aluno: Exclui um aluno e todas as suas matrículas.
c_alunos_maiores_18: Cursor que lista alunos maiores de 18 anos.
c_alunos_por_curso: Cursor parametrizado para listar alunos por disciplina.

PKG_DISCIPLINA
cadastrar_disciplina: Cadastra uma nova disciplina.
c_total_alunos_disciplina: Lista disciplinas com mais de 10 alunos.
c_media_idade_disciplina: Calcula a idade média dos alunos por disciplina.
listar_alunos_disciplina: Lista todos os alunos matriculados em uma disciplina.

PKG_PROFESSOR
c_total_turmas_professor: Lista professores que ministram mais de uma turma.
total_turmas_professor: Retorna o total de turmas de um professor específico.
professor_disciplina: Retorna o professor que ministra uma disciplina específica.
Esquema do Banco de Dados

O sistema utiliza as seguintes tabelas:

alunos
disciplinas
professores
matriculas
turmas
Testes
Casos de teste exemplo estão incluídos no final do script SQL. Você pode executar testes adicionais utilizando os procedimentos e funções fornecidos pelos pacotes.
