--André Bamberg Pan e João Vitor Camargo Bueno

CREATE TABLE IF NOT EXISTS Usuario (
  	CPF VARCHAR(11) PRIMARY KEY,
  	Nome VARCHAR(20) NOT NULL,
  	Idade INT NOT NULL,
  	Cidade VARCHAR(30) NOT NULL,
  	Estado VARCHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Carro (
	Placa VARCHAR(7) PRIMARY KEY,
  	Modelo VARCHAR(30) NOT NULL,
  	Cor VARCHAR(15) NOT NULL,
  	Ano INT NOT NULL,
  	CPF VARCHAR(11),
  	FOREIGN KEY (CPF) REFERENCES Usuario (CPF)
);

CREATE TABLE IF NOT EXISTS Cancelas (
	ID_Cancela SERIAL PRIMARY KEY,
	Entrada VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS Permissao (
    Placa VARCHAR(7),
    ID_Cancela INT,
    CONSTRAINT permissao_pk PRIMARY KEY (Placa, ID_Cancela),
    FOREIGN KEY (Placa) REFERENCES Carro (Placa),
    FOREIGN KEY (ID_Cancela) REFERENCES Cancelas (ID_Cancela)
);

CREATE TABLE IF NOT EXISTS Acesso (
    Data_Hora TIMESTAMP,
    Status BOOLEAN,
    Placa VARCHAR(7),
    ID_Cancela INT,
    CONSTRAINT acesso_pk PRIMARY KEY (Data_Hora, Placa, ID_Cancela),
    FOREIGN KEY (Placa) REFERENCES Carro (Placa),
    FOREIGN KEY (ID_Cancela) REFERENCES Cancelas (ID_Cancela)
);

	
-- Funções para gerar dados aleatorios, para serem usados nas tabelas:

CREATE OR REPLACE FUNCTION gerar_cpf_aleatorio()
RETURNS VARCHAR(14) AS $$
DECLARE
    cpf_aleatorio VARCHAR(14);
BEGIN
    -- gera os 11 digitos do CPF
    cpf_aleatorio := '';
    FOR i IN 1..11 LOOP
        cpf_aleatorio := cpf_aleatorio || floor(random() * 10)::INT;
    END LOOP;
    RETURN cpf_aleatorio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gerar_nome_aleatorio()
RETURNS VARCHAR(30) AS $$
DECLARE
    nomes_comuns VARCHAR[] := ARRAY['João', 'André', 'Marcos', 'José', 'Maria', 'Ana', 'Gustavo', 'Lucas', 'Fernanda', 'Beatriz', 'Pedro', 'Juliana', 'Rafael', 'Carla', 'Thiago', 'Amanda', 'Diego', 'Camila', 'Marcelo', 'Natália', 'Vinícius', 'Mariana', 'Felipe', 'Larissa', 'Bruno', 'Isabela', 'Rodrigo', 'Débora', 'Alexandre', 'Priscila', 'Luciana', 'Ricardo', 'Roberta', 'Cristiano', 'Vanessa', 'Eduardo', 'Patrícia', 'Leandro', 'Tatiane', 'Fábio', 'Adriana', 'Daniel', 'Fernando', 'Letícia', 'Alex', 'Flávia', 'Renato'];
    nome_aleatorio VARCHAR(30);
BEGIN
    -- seleciona um nome aleatorio do vetor
    nome_aleatorio := nomes_comuns[1 + floor(random() * array_length(nomes_comuns, 1))];

    -- retorna o nome aleatorio
    RETURN nome_aleatorio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gerar_idade_usuario()
RETURNS INT AS $$
DECLARE
    idade_usuario INT;
BEGIN
    idade_usuario := floor(random() * (70 - 18 + 1) + 18)::INT;
    RETURN idade_usuario;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gerar_cidade_estado_aleatorio()
RETURNS TABLE (Cidade VARCHAR(30), Estado VARCHAR(2)) AS $$
DECLARE
    cidades_estados VARCHAR[] := ARRAY['Curitiba-PR', 'Florianopolis-SC', 'Sao Paulo-SP', 'Rio de Janeiro-RJ', 'Belo Horizonte-MG', 'Porto Alegre-RS', 'Brasilia-DF', 'Salvador-BA', 'Fortaleza-CE', 'Recife-PE', 'Pato Branco-PR', 'Londrina-PR', 'Ponta Grossa-PR', 'Maringá-PR'];
    cidade_estado_aleatorio VARCHAR(30);
BEGIN
    cidade_estado_aleatorio := cidades_estados[1 + floor(random() * array_length(cidades_estados, 1))];

    RETURN QUERY
    SELECT 
        substring(cidade_estado_aleatorio from 1 for position('-' in cidade_estado_aleatorio) - 1)::VARCHAR(30) as Cidade,
        substring(cidade_estado_aleatorio from position('-' in cidade_estado_aleatorio) + 1)::VARCHAR(2) as Estado;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION gerar_placa_aleatoria()
RETURNS VARCHAR(8) AS $$
DECLARE
    letras VARCHAR[] := ARRAY['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
    numeros VARCHAR[] := ARRAY['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    placa_aleatoria VARCHAR(8);
BEGIN
    placa_aleatoria := letras[1 + floor(random() * array_length(letras, 1))] || 
                       letras[1 + floor(random() * array_length(letras, 1))] || 
                       letras[1 + floor(random() * array_length(letras, 1))] || 
                       numeros[1 + floor(random() * array_length(numeros, 1))] ||
                       letras[1 + floor(random() * array_length(letras, 1))] ||
                       numeros[1 + floor(random() * array_length(numeros, 1))] ||
                       numeros[1 + floor(random() * array_length(numeros, 1))];
    
    RETURN placa_aleatoria;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gerar_cor_aleatoria()
RETURNS VARCHAR(50) AS $$
DECLARE
    cores_carro VARCHAR[] := ARRAY['Branco', 'Preto', 'Cinza', 'Vermelho', 'Azul'];
    cor_aleatoria VARCHAR(50);
BEGIN
    cor_aleatoria := cores_carro[1 + floor(random() * array_length(cores_carro, 1))];
    RETURN cor_aleatoria;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gerar_modelo_aleatorio()
RETURNS VARCHAR(40) AS $$
DECLARE
    modelos_carro VARCHAR[] := ARRAY['Gol', 'Uno', 'Onix', 'Civic', 'Corolla', 'Fusca', 'Palio', 'Ka'];
    modelo_aleatorio VARCHAR(40);
BEGIN
    modelo_aleatorio := modelos_carro[1 + floor(random() * array_length(modelos_carro, 1))];
    RETURN modelo_aleatorio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gerar_ano_carro_aleatorio()
RETURNS INT AS $$
BEGIN
    RETURN floor(random() * (2023 - 2005 + 1) + 2005)::INT;
END;
$$ LANGUAGE plpgsql;

--Funcões para popular as tabelas, utilizando as funções de dados aleatorios:
CREATE OR REPLACE FUNCTION popular_usuario()
RETURNS VOID AS $$
DECLARE
    i INT := 1;
    cidade_estado RECORD;
    existe_registros BOOLEAN;
BEGIN
    -- Verifica se já existem registros na tabela Usuario
    SELECT EXISTS (SELECT 1 FROM Usuario LIMIT 1) INTO existe_registros;

    -- Se já existem registros, sai sem fazer nada
    IF existe_registros THEN
        RETURN;
    END IF;

    -- Caso contrário, continua com a inserção de dados
    WHILE i <= 1000 LOOP
        cidade_estado := gerar_cidade_estado_aleatorio();
        INSERT INTO Usuario (CPF, Nome, Idade, Cidade, Estado)
        VALUES (gerar_cpf_aleatorio(), gerar_nome_aleatorio(), gerar_idade_usuario(), cidade_estado.Cidade, cidade_estado.Estado);
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION popular_carro()
RETURNS VOID AS $$
DECLARE
    i INT := 1;
    cpf_usuario VARCHAR(11);
    existe_registros BOOLEAN;
BEGIN
    -- Verifica se já existem registros na tabela Carro
    SELECT EXISTS (SELECT 1 FROM Carro LIMIT 1) INTO existe_registros;

    -- Se já existem registros, sai sem fazer nada
    IF existe_registros THEN
        RETURN;
    END IF;

    -- Caso contrário, continua com a inserção de dados
    WHILE i <= 600 LOOP
        -- seleciona aleatoriamente um CPF existente da tabela Usuario
        SELECT CPF INTO cpf_usuario FROM Usuario ORDER BY random() LIMIT 1;

        INSERT INTO Carro (Placa, Modelo, Cor, Ano, CPF)
        VALUES (gerar_placa_aleatoria(), gerar_modelo_aleatorio(), gerar_cor_aleatoria(), gerar_ano_carro_aleatorio(), cpf_usuario);

        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION popular_cancelas()
RETURNS VOID AS $$
DECLARE
    existe_registros BOOLEAN;
BEGIN
    -- Verifica se já existem registros na tabela Cancelas
    SELECT EXISTS (SELECT 1 FROM Cancelas LIMIT 1) INTO existe_registros;

    -- Se já existem registros, sai sem fazer nada
    IF existe_registros THEN
        RETURN;
    END IF;

    -- Caso contrário, continua com a inserção de dados
    INSERT INTO Cancelas (Entrada) VALUES ('Entrada1'), ('Entrada2');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION popular_permissao()
RETURNS VOID AS $$
DECLARE
  placa_carro VARCHAR(7);
  id_cancela_selecionado INT;
  i INT := 1;
  existe_registros BOOLEAN;
BEGIN
  -- Verifica se já existem registros na tabela Permissao
  SELECT EXISTS (SELECT 1 FROM Permissao LIMIT 1) INTO existe_registros;

  -- Se já existem registros, sai sem fazer nada
  IF existe_registros THEN
      RETURN;
  END IF;

  -- Caso contrário, continua com a inserção de dados
  WHILE i <= 300 LOOP
    -- seleciona aleatoriamente uma placa existente da tabela Carro
    placa_carro := (SELECT Placa FROM Carro ORDER BY random() LIMIT 1);

    -- seleciona aleatoriamente um ID de cancela existente da tabela Cancelas
    id_cancela_selecionado := (SELECT ID_Cancela FROM Cancelas ORDER BY random() LIMIT 1);

    -- tenta inserir a permissão, tratando duplicatas
    BEGIN
      INSERT INTO Permissao (Placa, ID_Cancela)
      VALUES (placa_carro, id_cancela_selecionado);

    EXCEPTION
      WHEN unique_violation THEN
        -- se uma chave única já existe, tenta novamente
        CONTINUE;
    END;
    i := i + 1;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT popular_usuario();
SELECT popular_carro();
SELECT popular_cancelas();
SELECT popular_permissao();

ANALYZE Usuario;
ANALYZE Carro;
ANALYZE Permissao;
ANALYZE Cancelas;

--Criando indices adequados às consultas mais frequentes:

DROP INDEX IF EXISTS idx_permissao_placa;
DROP INDEX IF EXISTS idx_permissao_id_cancela;
DROP INDEX IF EXISTS idx_carro_placa;
DROP INDEX IF EXISTS idx_carro_cpf;
DROP INDEX IF EXISTS idx_acesso_data_hora;

CREATE INDEX idx_permissao_placa ON Permissao (Placa);--em quais cancelas o carro tem permissao
CREATE INDEX idx_permissao_id_cancela ON Permissao (ID_Cancela);-- quais carros tem permissao para tal cancela

CREATE INDEX idx_carro_cpf ON Carro (CPF);-- procurar todos os carros de um usuario

CREATE INDEX idx_acesso_data_hora ON Acesso (Data_Hora);--saber quais carro passaram pela cancela por um determinado tempo

EXPLAIN SELECT * FROM Permissao WHERE placa = 'PGQ2J74';--Indice nao foi utilizdo pois a tabela tem poucas tuplas
EXPLAIN SELECT * FROM Permissao WHERE ID_cancela = 1;

EXPLAIN SELECT * FROM Carro WHERE CPF = '73544562582';--Usando o indice idx_carro_cpf


--Criando funções que representem consultas corriqueiras, ou realizem alguma tarefa nas tabelas:

CREATE OR REPLACE FUNCTION usuario_variosCarros()--Retorna todos os usuarios que possuem mais de um carro
RETURNS TABLE (cpf VARCHAR(11), nome VARCHAR(20), quantidade_carros INTEGER)
AS $$
BEGIN
    RETURN QUERY
    SELECT U.CPF, U.Nome, COUNT(*)::INTEGER AS Quantidade_Carros
    FROM Usuario U
    INNER JOIN Carro C ON U.CPF = C.CPF
    GROUP BY U.CPF, U.Nome
    HAVING COUNT(*) > 1;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM usuario_variosCarros();


CREATE OR REPLACE FUNCTION verificar_permissao(p_placa VARCHAR, p_id_cancela INT) --Verifica se o carro esta permitido para entrar
RETURNS BOOLEAN AS $$
DECLARE
    v_permitido BOOLEAN;
BEGIN
    -- Verifica se a placa tem permissão
    SELECT EXISTS (
        SELECT 1
        FROM Permissao
        WHERE Placa = p_placa AND ID_Cancela = p_id_cancela
    ) INTO v_permitido;

    RETURN v_permitido;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM verificar_permissao('KNI3O91', 1);


CREATE OR REPLACE FUNCTION inserir_Acesso(p_placa VARCHAR, p_id_cancela INT)-- simulação da chegada de um carro na frente da cancela
RETURNS VOID AS $$
DECLARE
    v_permitido BOOLEAN;
    v_data_hora TIMESTAMP;
BEGIN
    -- Obtem a data e hora atuais, incluindo milissegundos
    v_data_hora := CURRENT_TIMESTAMP;

    v_permitido := verificar_permissao(p_placa, p_id_cancela);
	
	 RAISE NOTICE 'Placa: %, ID_Cancela: %, Permitido: %', p_placa, p_id_cancela, v_permitido;

    -- Insere na tabela Acesso com status TRUE se permitido, FALSE se não permitido
    INSERT INTO Acesso (Data_Hora, Status, Placa, ID_Cancela)
    VALUES (v_data_hora, v_permitido, p_placa, p_id_cancela);

END;
$$ LANGUAGE plpgsql;

/*
SELECT * FROM inserir_Acesso('CIQ2F04', 1);
SELECT * FROM inserir_Acesso('CIQ2F04', 2);
SELECT * FROM inserir_Acesso('SHH9K14', 1);
SELECT * FROM inserir_Acesso('NFS2U60', 2);
SELECT * FROM inserir_Acesso('BTB0H50', 1);
SELECT * FROM inserir_Acesso('EHB6J97', 1);
SELECT * FROM inserir_Acesso('IWE3T15', 2);
SELECT * FROM inserir_Acesso('KBP6H30', 2);
SELECT * FROM inserir_Acesso('KBP6H30', 1);
SELECT * FROM inserir_Acesso('CCA9C00', 1);
SELECT * FROM inserir_Acesso('QGN8W75', 1);
*/


-- Criando views comuns e uma tabela de auditoria para um tabela.
CREATE TABLE IF NOT EXISTS Acesso_Auditoria (
    Data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Operacao VARCHAR(10),
    Usuario_modificador VARCHAR(30),
    Detalhes_modificacao VARCHAR(255)
);

CREATE OR REPLACE VIEW info_carro_dono AS --mostra os detalhes do carro e seu respectivo dono
SELECT
    C.Placa,
    C.Modelo,
    U.CPF AS CPF_Dono,
    U.Nome AS Nome_Dono
FROM
    Carro C
JOIN Usuario U ON C.CPF = U.CPF;

SELECT * FROM info_carro_dono;

CREATE OR REPLACE VIEW vcarros_permitidos_2020 AS --mostra todos os carros com permissao para entrar que sao do ano 2020 para frente
SELECT
    P.Placa,
    C.Modelo,
    C.Ano,
    C.CPF AS CPF_Dono,
    U.Nome AS Nome_Dono
FROM
    Permissao P
JOIN Carro C ON P.Placa = C.Placa
JOIN Usuario U ON C.CPF = U.CPF
WHERE
    C.Ano >= 2020;

SELECT * FROM vcarros_permitidos_2020;

CREATE OR REPLACE VIEW vw_carros_permissao AS -- mostra as informações de todos os carros que passaram por alguma catraca
SELECT
    C.Placa,
    C.Modelo,
    C.Cor,
    C.Ano,
    C.CPF AS CPF_Dono,
    U.Nome AS Nome_Dono,
    A.ID_Cancela,
    A.Data_Hora,
    A.Status
FROM
    Carro C
    JOIN Usuario U ON C.CPF = U.CPF
    JOIN Permissao P ON C.Placa = P.Placa
    JOIN Acesso A ON P.Placa = A.Placa AND P.ID_Cancela = A.ID_Cancela
WHERE
    A.Status = true;

SELECT * FROM vw_carros_permissao;

--Criando triggers que tratem eventos em tabelas com atributos derivados e auditorias:

DROP TRIGGER IF EXISTS trigger_auditoria ON acesso_Auditoria CASCADE;
DROP TRIGGER IF EXISTS trigger_inserir_novo ON Acesso CASCADE;

--Trigger para inserir tuplas na tabela auditoria, apos ocorrer inserção na tabela acesso
CREATE OR REPLACE FUNCTION trigger_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Status = TRUE THEN
        INSERT INTO Acesso_Auditoria (Data_registro, Operacao, Usuario_modificador, Detalhes_modificacao)
        VALUES (CURRENT_TIMESTAMP, 'Insercao', SESSION_USER, 'Entrada bem-sucedida');
    ELSE
        INSERT INTO Acesso_Auditoria (Data_registro, Operacao, Usuario_modificador, Detalhes_modificacao)
        VALUES (CURRENT_TIMESTAMP, 'Insercao', SESSION_USER, 'Entrada mal-sucedida');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auditoria
AFTER INSERT ON Acesso
FOR EACH ROW
EXECUTE FUNCTION trigger_auditoria();

/*
SELECT * FROM inserir_Acesso('UVF6D52', 2);
SELECT * FROM inserir_Acesso('CQB0I96', 2);
SELECT * FROM inserir_Acesso('OIV4Z40', 1);
SELECT * FROM inserir_Acesso('KQI6N00', 1);
SELECT * FROM inserir_Acesso('GDY3C78', 1);
*/

--Trigger para quando chegar um carro nao registrado ainda, adicionar os carros nas tabelas e depois conceder o acesso ou nao 
CREATE OR REPLACE FUNCTION carro_desconhecido(p_placa VARCHAR(7), p_id_cancela INT)
RETURNS VOID AS $$
BEGIN
    -- verifica se o carro já existe na tabela Carro
    IF NOT EXISTS (SELECT 1 FROM Carro WHERE Placa = p_placa) THEN
        -- procura ou cria um usuário fictício com CPF "Desconhecido"
        INSERT INTO Usuario (CPF, Nome, Idade, Cidade, Estado)
        VALUES ('00000000000', 'Desconhecido', 0, 'Desconhecido', '--')
        ON CONFLICT (CPF) DO NOTHING;

        -- se não existe, adiciona o carro com valores desconhecidos
        INSERT INTO Carro (Placa, Modelo, Cor, Ano, CPF)
        VALUES (p_placa, 'Desconhecido', 'Desconhecido', 0, '00000000000');

        -- Adiciona o carro à tabela Permissao
        INSERT INTO Permissao (Placa, ID_Cancela)
        VALUES (p_placa, p_id_cancela);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verificarTabelas()
RETURNS TRIGGER AS $$
BEGIN
    -- Antes de inserir na tabela Acesso, adiciona o carro se não existir
    PERFORM carro_desconhecido(NEW.Placa, NEW.ID_Cancela);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Associação da Trigger à tabela Acesso
CREATE TRIGGER trigger_inserir_novo
BEFORE INSERT ON Acesso
FOR EACH ROW
EXECUTE FUNCTION verificarTabelas();

SELECT * FROM carro_desconhecido('ABC1D23',1);
SELECT * FROM inserir_Acesso('ABC1D23', 1);

EXPLAIN SELECT * FROM Acesso WHERE Data_Hora BETWEEN '2023-12-12 13:20:00' AND '2023-12-12 19:00:00';
