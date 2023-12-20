-- Atividade 3: André Bamberg Pan e João Vitor Camargo Bueno.

ALTER TABLE Emprestimo DROP CONSTRAINT IF EXISTS emprestimo_id_cli_fkey;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Emprestimo;

CREATE TABLE Cliente (
    id_cli SERIAL PRIMARY KEY,
    CPF BIGINT NOT NULL UNIQUE,
    Nome VARCHAR(100) NOT NULL,
    data_reg DATE NOT NULL,
    valor_max_liberado NUMERIC(10, 2) NOT NULL
);

CREATE TABLE Emprestimo (
    id_empr SERIAL PRIMARY KEY,
    data_empr DATE NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    nro_parcelas INTEGER NOT NULL,
    quitado BOOLEAN NOT NULL,
    id_cli INTEGER REFERENCES Cliente(id_cli) NOT NULL
);

--função para gerar cpf
CREATE OR REPLACE FUNCTION gerar_cpf_aleatorio(cpf_inicial BIGINT DEFAULT NULL)
RETURNS BIGINT AS $$
DECLARE
    v_cpf BIGINT;
BEGIN
    IF cpf_inicial IS NOT NULL THEN
        -- se um CPF inicial for fornecido, usar(no caso nao usei, portanto ficou um padrao de 10000000001)
        v_cpf := cpf_inicial;
    ELSE
        -- caso contrario, gere um CPF aleatorio
        v_cpf := (10000000000 + (random() * 90000000000)::BIGINT);
    END IF;
    RETURN v_cpf;
END;
$$ LANGUAGE plpgsql;


--populando as tabelas, com 50 tuplas cada
CREATE OR REPLACE FUNCTION popular_tabela_cliente()
RETURNS VOID AS $$
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Cliente(CPF, Nome, data_reg, valor_max_liberado)
        VALUES (gerar_cpf_aleatorio(10000000000 + i), 'Cliente' || i, CURRENT_DATE - (i * 10), (i * 1000.00)::NUMERIC(10, 2));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION popular_tabela_emprestimo()
RETURNS VOID AS $$
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Emprestimo(data_empr, valor_total, nro_parcelas, quitado, id_cli)
        VALUES (CURRENT_DATE - (i * 5), (i * 500.00)::NUMERIC(10, 2), 12, FALSE, i);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM popular_tabela_cliente();
SELECT * FROM popular_tabela_emprestimo();


-- 1-Dado o nome do cliente, retorna o id:
CREATE OR REPLACE FUNCTION nomeID(f1_nome VARCHAR(20))
RETURNS INTEGER AS $$
DECLARE
    f1_id INTEGER;
BEGIN
    SELECT id_cli INTO f1_id
    FROM Cliente
    WHERE Nome = f1_nome;

    RETURN f1_id;
END;
$$ LANGUAGE plpgsql;

select * from nomeID('Cliente10'); --passar nome do cliente para a função.


-- 2- Dado o ID de um cliente, retornar o valor total devido dos emprestimos.
CREATE OR REPLACE FUNCTION valorDevido(f2_id_cliente INTEGER)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    f2_valor_total NUMERIC(10, 2) := 0;
BEGIN
    SELECT SUM(valor_total)
    INTO f2_valor_total
    FROM Emprestimo
    WHERE id_cli = f2_id_cliente AND quitado = FALSE;

    RETURN COALESCE(f2_valor_total, 0);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM valorDevido(10);--passar id como parametro.


-- 3- Dado o ID de um cliente, retornar sua data de registro no sistema.
drop function if exists dataRegistro;
CREATE OR REPLACE FUNCTION dataRegistro(f3_id_cliente INTEGER)
RETURNS DATE AS $$
DECLARE
    f3_data_reg DATE;
BEGIN
    SELECT data_reg INTO f3_data_reg
    FROM Cliente
    WHERE id_cli = f3_id_cliente;

    RETURN f3_data_reg;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM dataRegistro(30);--passar id como parametro.


-- 4- Dados o CPF e o novo valor, atualizar o cliente com seu novo valor liberado para emprestimo.
CREATE OR REPLACE FUNCTION atualizarValorMax(f4_cpf BIGINT, f4_novo_valor NUMERIC(10, 2))
RETURNS VOID AS $$
BEGIN
    UPDATE Cliente
    SET valor_max_liberado = f4_novo_valor
    WHERE CPF = f4_cpf;
END;
$$ LANGUAGE plpgsql;

SELECT atualizarValorMax(10000000001, 1550.00);-- passar CPF e novo valor maximo para emprestimo.(valor max antigo = 1000.00)


-- 5- Dado o ID do emprestimo, quitar o mesmo.
CREATE OR REPLACE FUNCTION quitarEmprestimo(f5_id_emprestimo INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE Emprestimo
    SET quitado = TRUE
    WHERE id_empr = f5_id_emprestimo;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM quitarEmprestimo(1);--passar ID do emprestimo


-- 6- Dado o ID de um cliente, retornar o valor do emprestimo mais antigo que não esta quitado.
CREATE OR REPLACE FUNCTION empMaisAntigo(f6_id_cliente INTEGER)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    f6_valor_emprestimo NUMERIC(10, 2);
BEGIN
    SELECT valor_total INTO f6_valor_emprestimo
    FROM Emprestimo
    WHERE id_cli = f6_id_cliente AND quitado = FALSE
    ORDER BY data_empr
    LIMIT 1;

    RETURN COALESCE(f6_valor_emprestimo, 0);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM empMaisAntigo(10);-- se o emprestivo estiver quitado, retorna 0.



