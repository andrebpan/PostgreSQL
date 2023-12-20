--Atividade 2: André Bamberg Pan e João Vitor Camargo Bueno.

drop table if exists Aluno;
drop table if exists Discip;
drop table if exists Matricula;

CREATE TABLE Aluno(
  Nome VARCHAR(50) NOT NULL,
  RA DECIMAL(8) NOT NULL,
  DataNasc DATE NOT NULL,
  Idade DECIMAL(3),
  NomeMae VARCHAR(50) NOT NULL,
  Cidade VARCHAR(30),
  Estado CHAR(2),
  Curso VARCHAR(50),
  periodo integer
);

CREATE TABLE Discip(
  Sigla CHAR(7) NOT NULL,
  Nome VARCHAR(25) NOT NULL,
  SiglaPreReq CHAR(7),
  NNCred DECIMAL(2) NOT NULL,
  Monitor DECIMAL(8),
  Depto CHAR(8)
);

CREATE TABLE Matricula(
  RA DECIMAL(8) NOT NULL,
  Sigla CHAR(7) NOT NULL,
  Ano CHAR(4) NOT NULL,
  Semestre CHAR(1) NOT NULL,
  CodTurma DECIMAL(4) NOT NULL,
  NotaP1 NUMERIC(3,1),
  NotaP2 NUMERIC(3,1),
  NotaTrab NUMERIC(3,1),
  NotaFIM NUMERIC(3,1),
  Frequencia DECIMAL(3)
);

-- Exercício 1: populando as tabelas

create or replace function numero(digitos integer) returns integer as
$$
begin
	return trunc(random()*power(10,  digitos));
end;
$$ language plpgsql;

-- Data aleatoria
create or replace function data() returns date as
$$
begin
	return date(timestamp '1980-01-01 00:00:00' +
			random() * (timestamp '2017-01-30 00:00:00' -
			timestamp '1990-01-01 00:00:00'));
end;
$$ language plpgsql;

-- Texto aleatorio
Create or replace function texto(tamanho integer) returns text as
$$
declare
	chars text[] := '{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
	result text := '';
	i integer := 0;
begin
	if tamanho < 0 then
		raise exception 'Tamanho dado nao pode ser menor que zero';
	end if;

	for i in 1..tamanho loop
		result := result || chars[1+random()*(array_length(chars, 1)-1)];
	end loop;

	return result;
end;
$$ language plpgsql;


SET datestyle TO "YMD";

--Adicionando para as tabelas, com 1500 tuplas cada tabela.

DO $$
BEGIN
  FOR i IN 1..1500 LOOP
    INSERT INTO Aluno(Nome, RA, DataNasc, Idade, NomeMae, Cidade, Estado, Curso, periodo)
    VALUES (texto(30), i, data(), numero(2), texto(30), texto(10), texto(2), texto(30), numero(1));
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  FOR i IN 1..1500 LOOP
    INSERT INTO Discip(Sigla, Nome, SiglaPreReq, NNCred, Monitor, Depto)
    VALUES (texto(7), texto(20), texto(7), numero(2), numero(2) + 1, texto(8));
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  FOR i IN 1..1500 LOOP
    INSERT INTO Matricula(RA, Sigla, Ano, Semestre, CodTurma, NotaP1, NotaP2, NotaTrab, NotaFIM, Frequencia)
    VALUES (i, texto(7), '2023', '1', numero(2), 0, 0, 0, 0, numero(2));
  END LOOP;
END;
$$ LANGUAGE plpgsql;

select * from Aluno;
select * from Discip;
select * from Matricula;

--Exercicio 2: 
CREATE UNIQUE INDEX IdxAlunoNNI ON Aluno (Nome, NomeMae, Idade);

-- 1- Escreva uma consulta que utilize esse índice
analyze Aluno;
explain select Aluno, Nome, NomeMae from Aluno where Nome = 'scwemofqzhlfdphfqrsryvrbtrlnji' and NomeMae = 'ymibiwcrsicvzofgysgnvomuspkjvo' and idade = 65;

-- 2- Mostre um exemplo onde o índice não é usado mesmo utilizando algum campo indexado na clausula where, e explique por quê
explain select Aluno, Nome, NomeMae from Aluno where Nome like 'scwemofqzhlfdphfqrsryvrbtrlnji';
--'like' pode impedir o uso eficiente do índice, especialmente se o índice foi projetado para corresponder a valores específicos.

--Exercicio 3:  Crie índices e mostre exemplos de consultas (resultados e explain) que usam os seguintes tipos de acessos:
-- a) Sequential Scan
CREATE INDEX idx_Aluno_Cidade ON Aluno (Cidade);
ANALYZE;
EXPLAIN ANALYZE SELECT * FROM Aluno WHERE Cidade = 'zeauuewrpl';

--b)bitmap scan
CREATE EXTENSION IF NOT EXISTS btree_gin;
DROP INDEX IF EXISTS IdxAlunoIdade;
CREATE INDEX IdxAlunoIdade ON Aluno USING gin (idade);
analyze;
explain select * from Aluno where idade = 33;

--c)Index Scan
CREATE INDEX IdxAlunoIndexScan ON Aluno (Nome);
ANALYZE Aluno;
EXPLAIN SELECT * FROM Aluno WHERE Nome = 'nppcibjogqsckiiqqcpfxnewxebbix';

--d)Index-Only Scan
CREATE INDEX IdxAlunoOnlyScan ON Aluno (Nome);
ANALYZE Aluno;
EXPLAIN SELECT Nome FROM Aluno WHERE Nome = 'nppcibjogqsckiiqqcpfxnewxebbix';

--e)Multi-index Scan
CREATE INDEX IdxMatricula_RA ON Matricula (RA);
ANALYZE Matricula;
EXPLAIN ANALYZE
SELECT A.nome, M.RA
FROM Aluno AS A
JOIN Matricula AS M ON A.RA = M.RA
WHERE M.RA = 1;

-- Exercicio 4: Faça consultas com junções entre as tabelas e mostre o desempenho criando-se índices para cada chave estrangeira
CREATE INDEX idx_matricula_ra ON Matricula (RA);
CREATE INDEX idx_matricula_sigla ON Matricula (Sigla);
CREATE INDEX idx_discip_sigla ON Discip (Sigla);

-- Consulta com junção entre Aluno e Matricula
EXPLAIN ANALYZE
SELECT A.Nome, M.RA, M.Sigla
FROM Aluno AS A
JOIN Matricula AS M ON A.RA = M.RA;

-- Consulta com junção entre Aluno, Matricula e Discip
EXPLAIN ANALYZE
SELECT A.Nome, M.RA, M.Sigla, D.Nome AS NomeDiscip
FROM Aluno AS A
JOIN Matricula AS M ON A.RA = M.RA
JOIN Discip AS D ON M.Sigla = D.Sigla;

-- Exercicio 5: Utilize um índice bitmap para período e mostre-o em uso nas consultas
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE INDEX idx_aluno_periodo ON Aluno USING gin (periodo);
EXPLAIN ANALYZE
SELECT Nome, RA, periodo
FROM Aluno
WHERE periodo = 7;

-- Exercicio 6: Compare na prática o custo de executar uma consulta com e sem índice clusterizado na tabela aluno.
-- Ou seja, faça uma consulta sobre algum dado indexado, clusterize a tabela naquele índice e refaça a consulta.
-- Mostre os comandos e os resultados do explain analyze.

-- Consulta sem cluster
DROP INDEX IF EXISTS IdxAlunoPeriodo;
EXPLAIN ANALYZE
SELECT *
FROM Aluno
WHERE periodo = 7;

-- Clusterizar tabela pelo indice criado
CREATE INDEX IdxAlunoPeriodo ON Aluno (periodo);
CLUSTER Aluno USING IdxAlunoPeriodo;

-- Consulta com cluster
EXPLAIN ANALYZE
SELECT *
FROM Aluno
WHERE periodo = 7;

-- Exercicio 7: Acrescente um campo adicional na tabela de Aluno, chamado de informacoesExtras,
-- do tipo JSON. Insira dados diferentes telefônicos e de times de futebol que o aluno torce para cada aluno neste JSON.
-- Crie índices para o JSON e mostre consultas que o utilizam (explain analyze).
-- Exemplo: retorne os alunos que torcem para o Internacional.

ALTER TABLE Aluno ADD COLUMN informacoesExtras jsonb;

CREATE OR REPLACE FUNCTION time_futebol() RETURNS text AS
$$
DECLARE
  times text[] := '{"Flamengo", "Palmeiras", "Corinthians", "São Paulo", "Internacional", "Grêmio", "Athletico-PR", "Cruzeiro", "Fluminense", "Santos", "Chapecoense", "Botafogo", "Vasco", "Bahia", "Fortaleza", "Goiás", "Sport", "Ceará", "Atlético-MG", "Bragantino"}';
  result text := '';
BEGIN
  result := times[1 + random() * (array_length(times, 1) - 1)];

  RETURN result;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  FOR i IN 1501..4000 LOOP
    INSERT INTO Aluno(Nome, RA, DataNasc, Idade, NomeMae, Cidade, Estado, Curso, periodo, informacoesExtras)
    VALUES (
      texto(30),
      i,
      data(),
      numero(2),
      texto(30),
      texto(10),
      texto(2),
      texto(30),
      numero(1),
      ('{
        "telefone1": ' || numero(5) || ',
        "telefone2": "' || numero(5) || '",
        "timeFutebol": "' || time_futebol() || '"
      }')::jsonb
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

ANALYZE Aluno;

-- Consultas utilizando o índice, para alunos que torcem para o Internacional.
EXPLAIN ANALYZE SELECT informacoesExtras->>'timeFutebol' FROM Aluno
WHERE informacoesExtras->>'timeFutebol' = 'Internacional';











