CREATE TABLE alunos (
    id_aluno NUMBER PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    id_curso NUMBER
);

CREATE TABLE disciplinas (
    id_disciplina NUMBER PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    descricao VARCHAR2(500),
    carga_horaria NUMBER NOT NULL
);

CREATE TABLE professores (
    id_professor NUMBER PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL
);

CREATE TABLE matriculas (
    id_matricula NUMBER PRIMARY KEY,
    id_aluno NUMBER,
    id_disciplina NUMBER,
    FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno),
    FOREIGN KEY (id_disciplina) REFERENCES disciplinas(id_disciplina)
);

CREATE TABLE turmas (
    id_turma NUMBER PRIMARY KEY,
    id_disciplina NUMBER,
    id_professor NUMBER,
    FOREIGN KEY (id_disciplina) REFERENCES disciplinas(id_disciplina),
    FOREIGN KEY (id_professor) REFERENCES professores(id_professor)
);

CREATE OR REPLACE PACKAGE PKG_ALUNO AS
    PROCEDURE delete_aluno(p_id_aluno IN NUMBER);
    
    CURSOR c_alunos_maiores_18 IS
        SELECT nome, data_nascimento
        FROM alunos
        WHERE MONTHS_BETWEEN(SYSDATE, data_nascimento)/12 > 18;
    
    CURSOR c_alunos_por_curso(p_id_curso IN NUMBER) IS
        SELECT nome
        FROM alunos
        WHERE id_curso = p_id_curso;
END PKG_ALUNO;
/

CREATE OR REPLACE PACKAGE BODY PKG_ALUNO AS
    PROCEDURE delete_aluno(p_id_aluno IN NUMBER) IS
    BEGIN
        DELETE FROM matriculas WHERE id_aluno = p_id_aluno;
        
        DELETE FROM alunos WHERE id_aluno = p_id_aluno;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Error deleting student: ' || SQLERRM);
    END delete_aluno;
END PKG_ALUNO;
/

CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
    PROCEDURE cadastrar_disciplina(
        p_nome IN VARCHAR2,
        p_descricao IN VARCHAR2,
        p_carga_horaria IN NUMBER
    );

    CURSOR c_total_alunos_disciplina IS
        SELECT d.nome, COUNT(m.id_aluno) as total_alunos
        FROM disciplinas d
        LEFT JOIN matriculas m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.nome
        HAVING COUNT(m.id_aluno) > 10;

    CURSOR c_media_idade_disciplina(p_id_disciplina IN NUMBER) IS
        SELECT AVG(MONTHS_BETWEEN(SYSDATE, a.data_nascimento)/12) as media_idade
        FROM alunos a
        JOIN matriculas m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    
    PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER);
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA AS
    PROCEDURE cadastrar_disciplina(
        p_nome IN VARCHAR2,
        p_descricao IN VARCHAR2,
        p_carga_horaria IN NUMBER
    ) IS
    BEGIN
        INSERT INTO disciplinas (id_disciplina, nome, descricao, carga_horaria)
        VALUES (seq_disciplina.NEXTVAL, p_nome, p_descricao, p_carga_horaria);
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Error registering course: ' || SQLERRM);
    END cadastrar_disciplina;
    
    PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER) IS
        CURSOR c_alunos IS
            SELECT a.nome
            FROM alunos a
            JOIN matriculas m ON a.id_aluno = m.id_aluno
            WHERE m.id_disciplina = p_id_disciplina;
        v_nome alunos.nome%TYPE;
    BEGIN
        FOR aluno_rec IN c_alunos LOOP
            DBMS_OUTPUT.PUT_LINE('Student: ' || aluno_rec.nome);
        END LOOP;
    END listar_alunos_disciplina;
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE PKG_PROFESSOR AS
    CURSOR c_total_turmas_professor IS
        SELECT p.nome, COUNT(t.id_turma) as total_turmas
        FROM professores p
        LEFT JOIN turmas t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;
    
    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER;
    
    FUNCTION professor_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;
/

CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR AS
    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(id_turma)
        INTO v_total
        FROM turmas
        WHERE id_professor = p_id_professor;
        
        RETURN v_total;
    END total_turmas_professor;
    
    FUNCTION professor_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
        v_nome_professor VARCHAR2(100);
    BEGIN
        SELECT p.nome
        INTO v_nome_professor
        FROM professores p
        JOIN turmas t ON p.id_professor = t.id_professor
        WHERE t.id_disciplina = p_id_disciplina
        AND ROWNUM = 1;
        
        RETURN v_nome_professor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END professor_disciplina;
END PKG_PROFESSOR;
/

CREATE SEQUENCE seq_aluno START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_disciplina START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_professor START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_matricula START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_turma START WITH 1 INCREMENT BY 1;

    FOR aluno IN PKG_ALUNO.c_alunos_maiores_18 LOOP
        DBMS_OUTPUT.PUT_LINE('Student: ' || aluno.nome || ', Birth date: ' || TO_CHAR(aluno.data_nascimento, 'DD/MM/YYYY'));
    END LOOP;
    
    PKG_DISCIPLINA.cadastrar_disciplina('Database Systems', 'Introduction to DBMS', 60);
    
    DBMS_OUTPUT.PUT_LINE('Total classes for professor 1: ' || PKG_PROFESSOR.total_turmas_professor(1));
END;
/
