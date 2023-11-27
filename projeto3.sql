-- ----------------------------------------------------------------------------
DROP TABLE viagem CASCADE CONSTRAINTS;
DROP TABLE taxi;
DROP TABLE motorista;
-- ----------------------------------------------------------------------------
CREATE TABLE motorista (
nif NUMBER (9),
nome VARCHAR (80) CONSTRAINT nn_motorista_nome NOT NULL,
genero CHAR (1) CONSTRAINT nn_motorista_genero NOT NULL,
nascimento NUMBER (4) CONSTRAINT nn_motorista_nascimento NOT NULL,
localidade VARCHAR (80) CONSTRAINT nn_motorista_localidade NOT NULL,
--
CONSTRAINT pk_motorista
PRIMARY KEY (nif),
--
CONSTRAINT ck_motorista_nif -- RIA 10.
CHECK (nif BETWEEN 100000000 AND 999999999),
--
CONSTRAINT ck_motorista_genero -- RIA 11.
CHECK (UPPER(genero) IN ('F', 'M')), -- F(eminino), M(asculino).
--
CONSTRAINT ck_motorista_nascimento -- Não suporta RIA 6, mas
CHECK (nascimento > 1900) -- impede erros básicos.
);
-- ----------------------------------------------------------------------------
CREATE TABLE taxi (
matricula CHAR (6),
ano NUMBER (4) CONSTRAINT nn_taxi_ano NOT NULL,
marca VARCHAR (20) CONSTRAINT nn_taxi_marca NOT NULL,
conforto CHAR (1) CONSTRAINT nn_taxi_conforto NOT NULL,
eurosminuto NUMBER (4,2) CONSTRAINT nn_taxi_eurosminuto NOT NULL,
--
CONSTRAINT pk_taxi
PRIMARY KEY (matricula),
--
CONSTRAINT ck_taxi_matricula
CHECK (LENGTH(matricula) = 6),
--

CONSTRAINT ck_taxi_ano -- Não suporta RIA 7, mas
CHECK (ano > 1900), -- impede erros básicos.
--
CONSTRAINT ck_taxi_conforto -- RIA 16.
CHECK (UPPER(conforto) IN ('B', 'L')), -- B(ásico), L(uxuoso).
--
CONSTRAINT ck_taxi_eurosminuto -- RIA 17 (adaptada a esta tabela).
CHECK (eurosminuto > 0.0)
);
-- ----------------------------------------------------------------------------
CREATE TABLE viagem (
motorista,
inicio DATE,
fim DATE CONSTRAINT nn_viagem_fim NOT NULL,
taxi CONSTRAINT nn_viagem_taxi NOT NULL,
passageiros NUMBER (1) CONSTRAINT nn_viagem_passageiros NOT NULL,
--
CONSTRAINT pk_viagem
PRIMARY KEY (motorista, inicio), -- Simplificação.
--
CONSTRAINT fk_viagem_motorista
FOREIGN KEY (motorista)
REFERENCES motorista (nif),
--
CONSTRAINT fk_viagem_taxi
FOREIGN KEY (taxi)
REFERENCES taxi (matricula),
--
CONSTRAINT ck_viagem_periodo -- RIA 5 (adaptada a esta tabela).
CHECK (inicio < fim),
--
CONSTRAINT ck_viagem_passageiros -- RIA 19.
CHECK (passageiros BETWEEN 1 AND 8)
);
-- --------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- insert motorista.

INSERT INTO motorista (nif, nome, genero, nascimento , localidade)
     VALUES ('917258191','Sofia Afonso' ,'F', '2001', ' Porto');

INSERT INTO motorista (nif, nome, genero, nascimento , localidade)
     VALUES ('917258192','Margarida Afonso' ,'F', '2002', ' Porto');

INSERT INTO motorista (nif, nome, genero, nascimento , localidade)
     VALUES ('917258193','Beatriz Afonso' ,'F', '2002', ' Porto');

INSERT INTO motorista (nif, nome, genero, nascimento , localidade)
     VALUES ('917258194','Catarina Afonso' ,'F', '2002', ' Porto');

INSERT INTO motorista (nif, nome, genero, nascimento , localidade)
     VALUES ('917258195','joana Afonso' ,'F', '2002', ' Porto');
    
INSERT INTO motorista (nif, nome, genero, nascimento , localidade)
     VALUES ('917258111','Joao Pedro' ,'M', '2002', ' Porto');
    
INSERT INTO motorista (nif, nome, genero, nascimento , localidade)
     VALUES ('917258112','Duarte Afonso' ,'M', '2002', ' Porto');
-- ----------------------------------------------------------------------------
-- insert taxi.

INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
     VALUES ('AA11AA',
     '1999',
     'Renault',
     'L',
     '2.0');

INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
     VALUES ('BA11AA',
     '1999',
     'Renault',
     'L',
     '3.0');

INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
     VALUES ('BB22BB',
     '2005',
     'Audi',
     'L',
     '3.0');

INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
     VALUES ('BA22BB',
     '2005',
     'Audi',
     'L',
     '5.0');
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
     VALUES ('CB22CB',
     '2005',
     'Lancia',
     'L',
     '3.0');
-- ----------------------------------------------------------------------------
-- insert viagem.

INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258191', 'BB22BB',
     TO_DATE('2023/05/03 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2023/05/03 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '7');

INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258192', 'BB22BB',
     TO_DATE('2023/12/31 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2023/12/31 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');
     
INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258193', 'AA11AA',
     TO_DATE('2023/11/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2023/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');
     
INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258194', 'BB22BB',
     TO_DATE('2023/11/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2023/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');

INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258195', 'BA11AA',
     TO_DATE('2023/11/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2023/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');

INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258111', 'BA11AA',
     TO_DATE('2023/11/23 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2023/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');
     
INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258112', 'BA22BB',
     TO_DATE('2022/12/22 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2022/12/22 10:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');

INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258194', 'BB22BB',
     TO_DATE('2022/11/23 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2022/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');

INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258111', 'CB22CB',
     TO_DATE('2022/9/12 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2022/9/13 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '2');
     
INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258112', 'CB22CB',
     TO_DATE('2022/9/15 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2022/9/16 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '2');
     
INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258112', 'CB22CB',
     TO_DATE('2022/9/18 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2022/9/19 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '2');
     
INSERT INTO viagem (motorista, taxi , inicio, fim, passageiros)
     VALUES ('917258111', 'CB22CB',
     TO_DATE('2022/9/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2022/9/25 18:00:00', 'yyyy/mm/dd hh24:mi:ss'),
     '3');
     
-- ----------------------------------------------------------------------------

--NIF, nome, e idade das motoristas femininas com apelido Afonso, que conduziram em 
--viagens com três ou mais passageiros, em táxis com conforto luxuoso, durante o ano de
--2023, incluindo o caso particular da noite da passagem de ano, em que uma viagem pode
--ter começado em 2022 e terminado já em 2023. A matrícula e a marca do(s) táxi(s) tam-
--bém devem ser mostradas. O resultado deve vir ordenado de forma ascendente pela idade
--e nome das motoristas, e de forma descendente pela marca e matrícula dos táxis. Nota: a
--extração do ano a partir de uma data pode ser feita usando TO_CHAR(data, 'YYYY').
--Variantes com menor cotação: a) sem o cálculo da idade das motoristas; e b) sem a verifi-
--cação do caso da noite da passagem de ano

SELECT DISTINCT M.nif AS Nif, M.nome AS Nome,
                EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM TO_DATE(M.nascimento, 'YYYY')) AS Idade,
                T.matricula, T.marca
FROM motorista M, viagem V, taxi T
WHERE V.motorista = M.nif
AND V.taxi = T.matricula
AND M.genero = 'F'
AND UPPER(M.nome) LIKE '% AFONSO'
AND V.passageiros >= 3
AND T.conforto = 'L'
AND (EXTRACT(YEAR FROM V.inicio) = 2023
    OR V.inicio BETWEEN TO_DATE('2022/12/31 0:00:00', 'yyyy/mm/dd hh24:mi:ss') 
    AND TO_DATE('2022/12/31 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
    )
AND EXTRACT (YEAR FROM V.fim) = 2023
ORDER BY Idade ASC, M.nome ASC, T.marca DESC, T.matricula DESC;

-----------------------------------------------------------------------------------

/*
2. NIF e nome dos motoristas masculinos que, considerando apenas viagens iniciadas em
2022 (não deve ser considerada a data de fim das viagens), ou não conduziram táxis da
marca Lancia ou conduziram táxis dessa marca em até duas viagens. Adicionalmente, os
motoristas resultantes não podem ter conduzido táxis comprados antes de 2000, indepen-
dentemente do ano das viagens. O resultado deve vir ordenado pelo nome dos motoristas
de forma ascendente e pelo NIF de forma descendente.
Variantes com menor cotação: a) sem a verificação dos motoristas nunca terem conduzido
táxis comprados antes de 2000; e b) sem a verificação do número de viagens que conduzi-
ram em 2022.
*/

SELECT DISTINCT M.nif AS Nif, M.nome AS Nome
FROM motorista M
WHERE M.genero = 'M'
AND ((SELECT COUNT(*)
      FROM viagem V, taxi T
      WHERE V.motorista = M.nif
      AND V.taxi = T.matricula
      AND T.ano < 2000) = 0)
AND ((SELECT COUNT(*)
      FROM viagem V, taxi T
      WHERE V.motorista = M.nif
      AND (EXTRACT (YEAR FROM V.inicio)) = 2022
      AND V.taxi = T.matricula
      AND UPPER (T.marca) = 'LANCIA') < 3)
ORDER BY Nome ASC, Nif DESC;

--pergunta 4
--NIF e nome dos motoristas que faturaram mais euros em viagens em cada ano, separada-
--mente para motoristas masculinos e femininos, devendo o género dos motoristas e o total
--faturado em cada ano também aparecer no resultado. Considere que o valor de faturação
--de uma viagem corresponde ao preço por minuto do táxi, em euros, a multiplicar pelos
--minutos que passaram entre o início e o fim da viagem. A ordenação do resultado deve ser
--pelo ano de forma descendente e pelo género dos motoristas de forma ascendente. No caso
--de haver mais do que um(a) motorista com o mesmo máximo de faturação num ano, de-
--vem ser mostrados todos esses motoristas. Nota: para efeitos de determinação do ano de
--faturação, deve ser considerada a data de fim de cada viagem (mesmo que a viagem tenha
--começado no ano anterior). Nota: por conveniência, está disponível a função minutos_-
--que_passaram, que calcula quantos minutos passaram entre duas datas.1
--Variantes com menor cotação: a) mostrar o total faturado em viagens por cada motorista
--em cada ano, sem verificar se foram os/as que mais faturaram; e b) sem a distinção entre
--motoristas femininos e masculinos.
--SELECT minutos_que_passaram(SYSDATE, SYSDATE + 1)

SELECT Nif, Nome, Genero, Ano, TotalFaturado
FROM (
    SELECT M.nif AS Nif, M.nome AS Nome, M.genero AS Genero, EXTRACT(YEAR FROM V.fim) AS Ano,
        minutos_que_passaram(V.inicio, V.fim) AS minutos,
        SUM(minutos_que_passaram(V.inicio, V.fim) * T.eurosminuto) AS TotalFaturado,
        MAX(SUM(minutos_que_passaram(V.inicio, V.fim) * T.eurosminuto)) OVER (PARTITION BY EXTRACT(YEAR FROM V.fim), M.genero) AS MaxTotalFaturado
    FROM motorista M
        JOIN viagem V ON M.nif = V.motorista
        JOIN taxi T ON V.taxi = T.matricula
    GROUP BY M.nif, M.nome, M.genero,
        EXTRACT(YEAR FROM V.fim),
        minutos_que_passaram(V.inicio, V.fim)
)
WHERE TotalFaturado = MaxTotalFaturado
ORDER BY Ano DESC, Genero ASC;



