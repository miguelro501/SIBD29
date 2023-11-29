--SIBD 2023/2024, Etapa 3, Grupo 29
--Miguel Simoes n60451: Exercicio 1,4 -50%
--Nuno Graxinha n59855 Turma 5: Exercicio 3, 25%
--Sofia Santos  n59804 Turma 5: Exercicio 2, 25%

--1 NIF, nome, e idade das motoristas femininas com apelido Afonso, que conduziram em 
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

/*
3. Todos os dados dos táxis da marca Lexus, com preço por minuto acima da média dos pre-
ços por minuto de todos os táxis (independentemente da marca), e que tenham sido algu-
ma vez conduzidos por todos os motoristas de Lisboa na parte da manhã dos dias, mais
precisamente entre as 6h00 e as 11h59. Para simplificar, consideram-se apenas as viagens
iniciadas de manhã (a data de fim das viagens deve ser ignorada). O resultado deve vir
ordenado pelo preço por minuto dos táxis de forma descendente e pela matrícula dos táxis
de forma ascendente. Nota: a extração da hora do dia a partir de uma data pode ser feita
usando TO_CHAR(data, 'HH24').
Variantes com menor cotação: a) sem a verificação do preço por minuto dos táxis ser su-
perior à média dos preços por minuto de todos os táxis; e b) sem as verificações da locali-
dade dos motoristas e da hora das viagens.
*/
SELECT T1.marca, T1.matricula, T1.ano, T1.conforto, T1.eurosminuto
  FROM taxi T1, viagem V1, motorista M1
 WHERE (V1.motorista = M1.nif)
   AND (V1.taxi = T1.matricula)
   AND (T1.marca = 'Lexus')
   AND (T1.eurosminuto > (SELECT AVG(T2.eurosminuto)
                            FROM taxi T2))
   AND (TO_CHAR(V1.inicio, 'HH24:MI:SS') >= '06:00:00') 
   AND (TO_CHAR(V1.inicio, 'HH24:MI:SS') < '12:00:00')
   AND M1.localidade = 'Lisboa'
GROUP BY 
    T1.marca, 
    T1.matricula, 
    T1.ano, 
    T1.conforto, 
    T1.eurosminuto
HAVING 
    COUNT(DISTINCT M1.nif) = (SELECT COUNT(DISTINCT nif) FROM motorista WHERE localidade = 'Lisboa')
ORDER BY T1.eurosminuto DESC, T1.matricula ASC;

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



