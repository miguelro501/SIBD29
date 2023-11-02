DROP TABLE motorista CASCADE CONSTRAINTS;
DROP TABLE cliente;
DROP TABLE pessoa;
DROP TABLE morada CASCADE CONSTRAINTS;
DROP TABLE taxi CASCADE CONSTRAINTS;
DROP TABLE periodo CASCADE CONSTRAINTS;
DROP TABLE turno CASCADE CONSTRAINTS;
DROP TABLE viagem;
--DROP SEQUENCE viagem_seq
--DROP SEQUENCE morada_seq

--CREATE SEQUENCE viagem_seq
--    START WITH 1
--    MINVALUE 1
--    INCREMENT BY 1;

--CREATE SEQUENCE morada_seq
--    START WITH 1
--    MINVALUE 1
--    INCREMENT BY 1;
    
CREATE TABLE morada (
  id               NUMBER(5),
  rua              VARCHAR(40) CONSTRAINT nn_morada_rua NOT NULL,
  numero_da_porta  NUMBER(2)   CONSTRAINT nn_morada_numerp_da_porta NOT NULL,
  codigo_postal    NUMBER(4)   CONSTRAINT nn_morada_codigo_postal NOT NULL,
  localidade       VARCHAR(40) CONSTRAINT nn_morada_localidade NOT NULL,
--
  CONSTRAINT pk_morada
  PRIMARY KEY (id)
);

------------------------------------------------------------------------------

CREATE TABLE periodo (
  inicio DATE,
  fim DATE,
--
  CONSTRAINT pk_periodo
  PRIMARY KEY (inicio, fim),
--
  CONSTRAINT ck_periodo
  CHECK (inicio < fim)
);

------------------------------------------------------------------------------

CREATE TABLE taxi (
  matricula         VARCHAR(6),
  ano_compra        DATE        CONSTRAINT nn_taxi_ano_compra NOT NULL,
  marca             VARCHAR(16) CONSTRAINT nn_taxi_marca NOT NULL,
  modelo            VARCHAR(16) CONSTRAINT nn_taxi_modelo NOT NULL,
  nivel_conforto    VARCHAR(7)  CONSTRAINT nn_taxi_nivel_conforto NOT NULL,
--
  CONSTRAINT pk_taxi
    PRIMARY KEY (matricula),
--
  CONSTRAINT ck_taxi_matricula
    CHECK (LENGTH (matricula) = 6),
--
  CONSTRAINT ck_taxi_nivel_conforto
    CHECK ((nivel_conforto = 'basico') OR (nivel_conforto = 'luxuoso'))
);

------------------------------------------------------------------------------

CREATE TABLE pessoa (
  nif       NUMBER(9),
  genero    VARCHAR(1)  CONSTRAINT nn_pessoa_genero NOT NULL,
  nome      VARCHAR(40) CONSTRAINT nn_pessoa_nome NOT NULL,
--
  CONSTRAINT pk_pessoa
    PRIMARY KEY (nif),
--
  CONSTRAINT ck_pessoa_nif
    CHECK ((LENGTH (nif) = 9) AND (nif > 0)),
--
  CONSTRAINT ck_pessoa_genero
    CHECK ((genero = 'F') OR (genero = 'M'))
);

-----------------------------------------------------------------------------

CREATE TABLE cliente (
  nif,
--
  CONSTRAINT pk_cliente
    PRIMARY KEY (nif),
--
  CONSTRAINT fk_cliente_nif
    FOREIGN KEY (nif)
    REFERENCES pessoa (nif)
);

-----------------------------------------------------------------------------

CREATE TABLE motorista (
  nif,
  id_morada,
  carta_conducao NUMBER(9) CONSTRAINT nn_motorista_carta_conducao NOT NULL,
  ano_nascimento DATE CONSTRAINT nn_motorista_ano_nascimento NOT NULL,
  data_atual DATE DEFAULT SYSDATE,
--
  CONSTRAINT pk_motorista
    PRIMARY KEY (nif),
--
  CONSTRAINT fk_motorista_nif
    FOREIGN KEY (nif)
    REFERENCES pessoa (nif),
--
  CONSTRAINT fk_motorista_id_morada
    FOREIGN KEY (id_morada)
    REFERENCES morada (id),
--
  CONSTRAINT un_motorista_carta_conducao
    UNIQUE (carta_conducao),
--
  CONSTRAINT ck_motorista_carta_conducao
    CHECK (LENGTH(carta_conducao) = 9 AND carta_conducao > 0),
--
  CONSTRAINT ck_motorista_ano_nascimento
    CHECK (data_atual - ano_nascimento > 18)
);

-----------------------------------------------------------------------------

CREATE TABLE turno (
  motorista,
  taxi,
  inicio_periodo,
  fim_periodo,
  preco_por_minuto NUMBER(6,2) CONSTRAINT nn_motorista_preco_por_minuto NOT NULL,
--
  CONSTRAINT pk_turno
    PRIMARY KEY (motorista, taxi, inicio_periodo, fim_periodo),
--
  CONSTRAINT fk_turno_motorista
    FOREIGN KEY (motorista)
    REFERENCES motorista (nif),
--
  CONSTRAINT fk_turno_taxi
    FOREIGN KEY (taxi)
    REFERENCES taxi (matricula),
--
  CONSTRAINT fk_turno_inicio_periodo
    FOREIGN KEY (inicio_periodo, fim_periodo)
    REFERENCES periodo (inicio, fim),
--
  CONSTRAINT ck_turno_preco_por_minuto
    CHECK (preco_por_minuto > 0.0)
    
    -- Sophie: nao sei como incorporar as RIAS 7 e 8 no turno
    
    -- RIA 7 - O taxi nao consegue referenciar atributos do turno nem o turno do taxi, e portanto,
    -- nao da para comparar a data de compra do taxi e a data de inicio do turno
    
    -- RIA 8 - Mesma situacao que na RIA 7, nao da para comparar dois turnos e ver se
    -- dao overlap
);
    
-----------------------------------------------------------------------------


CREATE TABLE viagem (
  motorista,
  taxi,
  turno_inicio_periodo,
  turno_fim_periodo,
  sequencia             NUMBER(3),
  numero_de_pessoas     NUMBER(2)   CONSTRAINT nn_viagem_numero_pessoas NOT NULL,
  inicio_periodo                    CONSTRAINT nn_viagem_inicio_periodo NOT NULL,
  fim_periodo                       CONSTRAINT nn_viagem_fim_periodo NOT NULL,  
  partida                           CONSTRAINT nn_viagem_partida NOT NULL,
  chegada                           CONSTRAINT nn_viagem_chegada NOT NULL,
  km_percorridos        NUMBER(6)   CONSTRAINT nn_viagem_km_percorridos NOT NULL,
--
  CONSTRAINT pk_viagem
    PRIMARY KEY (motorista, taxi, turno_inicio_periodo, turno_fim_periodo, sequencia),
--
  CONSTRAINT fk_viagem_turno
    FOREIGN KEY (motorista, taxi, turno_inicio_periodo, turno_fim_periodo)
    REFERENCES turno (motorista, taxi, inicio_periodo, fim_periodo)
    ON DELETE CASCADE,
--
  CONSTRAINT fk_viagem_periodo
    FOREIGN KEY (inicio_periodo, fim_periodo)
    REFERENCES periodo (inicio, fim),
--
  CONSTRAINT fk_viagem_partida
    FOREIGN KEY (partida)
    REFERENCES morada (id),
--
  CONSTRAINT fk_viagem_chegada
    FOREIGN KEY (chegada)
    REFERENCES morada (id),
--
  CONSTRAINT ck_viagem_numero_de_pessoas
    CHECK (numero_de_pessoas > 0),
--
  CONSTRAINT ck_viagem_km_percorridos
    CHECK (km_percorridos > 0)
    
    -- RIA-18 Nao esta a verificar que o numero de sequencia tem de 
    -- começar em 1, nao sei como fazer
    --
);

-- ----------------------------------------------------------------------------
-- insert morada.

INSERT INTO morada (id, rua, numero_da_porta, codigo_postal, localidade)
     VALUES (1, 'Rua alexandre', 2, 4021, 'Porto');

INSERT INTO morada (id, rua, numero_da_porta, codigo_postal, localidade)
     VALUES (2, 'Rua fernao', 3, 5025, 'Lisboa');

-- ----------------------------------------------------------------------------
-- insert periodo.

INSERT INTO periodo (inicio, fim)
     VALUES (TO_DATE('2010/05/03 15:02:44', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2010/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));

INSERT INTO periodo (inicio, fim)
     VALUES (TO_DATE('2017/05/03 15:02:44', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2017/05/04 16:02:44', 'yyyy/mm/dd hh24:mi:ss'));

-- ----------------------------------------------------------------------------
-- insert taxi.

INSERT INTO taxi (matricula, ano_compra, marca, modelo, nivel_conforto)
     VALUES ('AA25BC',
     TO_DATE('2005/05/03', 'yyyy/mm/dd'),
     'Renault',
     'Clio',
     'basico');

INSERT INTO taxi (matricula, ano_compra, marca, modelo, nivel_conforto)
     VALUES ('BD82KL',
     TO_DATE('2004/02/05', 'yyyy/mm/dd'),
     'Audi',
     'A5',
     'luxuoso');
     
-- ----------------------------------------------------------------------------
-- insert pessoa.

INSERT INTO pessoa (nif, genero, nome)
     VALUES ('816592018', 'F', 'Catarina');
    
INSERT INTO pessoa (nif, genero, nome)
     VALUES ('825162957', 'F', 'Joana');

INSERT INTO pessoa (nif, genero, nome)
     VALUES ('917258197', 'M', 'Joao');
     
INSERT INTO pessoa (nif, genero, nome)
     VALUES ('957264182', 'M', 'Pedro');
     
-- ----------------------------------------------------------------------------
-- insert cliente.

INSERT INTO cliente (nif)
     VALUES ('816592018');

INSERT INTO cliente (nif)
     VALUES ('825162957');
     
-- ----------------------------------------------------------------------------
-- insert motorista.

INSERT INTO motorista (nif, id_morada, carta_conducao, ano_nascimento)
     VALUES ('917258197','1', '252856261', TO_DATE('1998/02/05', 'yyyy/mm/dd'));

INSERT INTO motorista (nif, id_morada, carta_conducao, ano_nascimento)
     VALUES ('957264182','2', '721956172', TO_DATE('1997/02/05', 'yyyy/mm/dd'));
     
-- ----------------------------------------------------------------------------
-- insert turno.

INSERT INTO turno (motorista, taxi, inicio_periodo, fim_periodo, preco_por_minuto)
     VALUES ('917258197', 'BD82KL', 
     TO_DATE('2010/05/03 15:02:44', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2010/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),
     '1.5');

INSERT INTO turno (motorista, taxi, inicio_periodo, fim_periodo, preco_por_minuto)
     VALUES ('957264182', 'AA25BC',
     TO_DATE('2017/05/03 15:02:44', 'yyyy/mm/dd hh24:mi:ss'),
     TO_DATE('2017/05/04 16:02:44', 'yyyy/mm/dd hh24:mi:ss'),
     '2.0');
     
-- ----------------------------------------------------------------------------
-- insert viagem.


INSERT INTO viagem (motorista, taxi, turno_inicio_periodo, turno_fim_periodo, sequencia, numero_de_pessoas, inicio_periodo, fim_periodo, partida, chegada, km_percorridos)
     VALUES ();

INSERT INTO viagem ()
     VALUES ();
     
-- ----------------------------------------------------------------------------

COMMIT;
-- ----------------------------------------------------------------------------