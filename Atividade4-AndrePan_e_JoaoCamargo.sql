-- Atividade 4: André Bamberg Pan e João Vitor Camargo Bueno

DROP TABLE IF EXISTS Funcionario;
DROP TABLE IF EXISTS Departamento;

CREATE TABLE Departamento (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    num_funcionarios INTEGER NOT NULL,
    max_mesas INTEGER NOT NULL,
    lotacao VARCHAR(20)
);

CREATE TABLE Funcionario (
    id SERIAL PRIMARY KEY,
    CPF VARCHAR(14) NOT NULL UNIQUE CHECK (cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'), --cpf no formato "xxx.xxx.xxx-xx"
    Nome VARCHAR(100) NOT NULL,
    data_reg DATE NOT NULL,
    id_dep INTEGER REFERENCES Departamento(id)
);

-- 1-Quando um novo funcionario é inserido e alocado a um departamento, incrementar o numero de
--funcionarios naquele departamento.
CREATE OR REPLACE FUNCTION incNumFunc()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Departamento
    SET num_funcionarios = num_funcionarios + 1
    WHERE id = NEW.id_dep;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerNumFunc
BEFORE INSERT ON Funcionario
FOR EACH ROW
EXECUTE FUNCTION incNumFunc();

INSERT INTO Departamento (nome, num_funcionarios, max_mesas, lotacao) VALUES
    ('Departamento A', 0, 10, NULL),
    ('Departamento B', 0, 10, NULL),
    ('Departamento C', 0, 10, NULL);

INSERT INTO Funcionario (CPF, Nome, data_reg, id_dep) VALUES
    ('232.453.231-90', 'Marcos', '2023-03-11', 2),
	('123.456.789-01', 'João', '2023-01-01', 1),
    ('987.654.321-09', 'Maria', '2023-02-01', 1),
    ('111.223.344-55', 'Carlos', '2023-03-01', 2),
    ('222.334.455-66', 'Andre', '2023-03-02', 3),
    ('333.445.566-77', 'Ana', '2023-03-03', 1),
    ('444.556.677-88', 'Paulo', '2023-03-04', 2),
    ('555.667.788-99', 'Kaue', '2023-03-05', 3),
    ('666.778.899-00', 'Jose', '2023-03-06', 1),
    ('777.889.900-11', 'Marcelo', '2023-03-07', 2),
    ('888.900.001-22', 'Mateus', '2023-03-08', 3),
    ('999.001.122-33', 'Gabriel', '2023-03-09', 1),
    ('123.001.122-34', 'Ricardo', '2023-03-10', 2);
	
-- 2-Quando um funcionario é excluido da base de dados, reduzir o numero de funcionarios no departamento que ele trabalhava em 1.
CREATE OR REPLACE FUNCTION redNumFunc()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE Departamento
	SET num_funcionarios = num_funcionarios-1
	WHERE id = OLD.id_dep;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerRedNum
BEFORE DELETE ON Funcionario
FOR EACH ROW
EXECUTE FUNCTION redNumFunc();

DELETE FROM Funcionario
WHERE id IN (13); -- passar id do funcionario, que no caso foi o 'Ricardo', sendo assim diminui um funcionario do departamento 2.

-- 3-Quando um funcionario muda de departamento, atualizar os numeros de funcionarios de ambos departamentos.

CREATE OR REPLACE FUNCTION atualizaDep()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Departamento
    SET num_funcionarios = num_funcionarios - 1
    WHERE id = OLD.id_dep;

    UPDATE Departamento
    SET num_funcionarios = num_funcionarios + 1
    WHERE id = NEW.id_dep;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerAtualiza
BEFORE UPDATE ON Funcionario
FOR EACH ROW
WHEN (NEW.id_dep <> OLD.id_dep) -- somente se o departamento mudou
EXECUTE FUNCTION atualizaDep();

UPDATE Funcionario
SET id_dep = 3
WHERE id = 1;--Atualizou com o departamento do funcionario com id = 1 para departamento = 3.

-- 4- Antes de inserir ou modificar os dados de um funcionario, verificar se a data de registro é anterior a data atual,
--padronizar o nome para letras minusculas e verificar se o CPF possui o formato ’xxx.xxx.xxx-xx’
CREATE OR REPLACE FUNCTION validarFuncionario()
RETURNS TRIGGER AS $$
BEGIN
    -- verificar se a data de registro é anterior a data atual
    IF NEW.data_reg > CURRENT_DATE THEN
        RAISE EXCEPTION 'a data de registro deve ser anterior ou igual à data atual.';
    END IF;

    -- padronizar o nome para letras minúsculas
    NEW.Nome = LOWER(NEW.Nome);

    -- verificar se o CPF possui o formato 'xxx.xxx.xxx-xx'
    IF NOT NEW.CPF ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$' THEN
        RAISE EXCEPTION 'o CPF deve estar no formato "xxx.xxx.xxx-xx".';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerValidar
BEFORE INSERT OR UPDATE ON Funcionario
FOR EACH ROW
EXECUTE FUNCTION validarFuncionario();

INSERT INTO Funcionario (CPF, Nome, data_reg, id_dep) VALUES
    ('573.706.119-14', 'GUSTAVO', '2023-04-9', 1);--adiciona um funcionario verificando as condições e deixando as letras em minusculo

-- 5-  Sempre que o numero de funcionarios de um dado departamento for modificado, atualizar o campo lotação para os seguintes valores:
--Mínimo, quando o número de funcionarios for menor que 30% do numero máximo de mesas; Médio, quando for equivalente a metade; 
--Parcialmente Cheio, quando acima de 50% e menor que 80%; Cheio, quando acima de 80% e menor que 100%; Esgotado, quando não existem mesas livres.
CREATE OR REPLACE FUNCTION atualizaLotacao()
RETURNS TRIGGER AS $$
DECLARE
    num_max_mesas INTEGER;
    ocupacao DECIMAL;
BEGIN
    -- número máximo de mesas para o departamento
    SELECT max_mesas INTO num_max_mesas
    FROM Departamento
    WHERE id = NEW.id_dep;
	
    -- calcular o percentual de ocupação
 	IF num_max_mesas > 0 THEN
    	ocupacao := (SELECT COUNT(*) FROM Funcionario WHERE id_dep = NEW.id_dep) / num_max_mesas * 100;
	ELSE
   		ocupacao := 0;
	END IF;

    -- atualiza a lotacao de acordo com a porcentagem
    UPDATE Departamento
    SET lotacao =
        CASE
            WHEN ocupacao < 30 THEN 'Mínimo'
            WHEN ocupacao >= 30 AND ocupacao < 50 THEN 'Médio'
            WHEN ocupacao >= 50 AND ocupacao < 80 THEN 'Parcialmente Cheio'
            WHEN ocupacao >= 80 AND ocupacao < 100 THEN 'Cheio'
            WHEN ocupacao >= 100 THEN 'Esgotado'
        END
    WHERE id = NEW.id_dep;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER triggerLotacao
AFTER INSERT OR UPDATE ON Funcionario
FOR EACH ROW
EXECUTE FUNCTION atualizaLotacao();

INSERT INTO Funcionario (CPF, Nome, data_reg, id_dep) VALUES
    ('111.222.333-44', 'Vinicius', '2023-04-01', 1),
	('111.222.333-55', 'Junior', '2023-04-02', 2),
	('111.222.333-66', 'Enzo', '2023-04-03', 3);



