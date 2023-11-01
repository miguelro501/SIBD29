DROP TABLE viagem;
DROP TABLE turno;
DROP TABLE motorista;
DROP TABLE cliente;
DROP TABLE pessoa;
DROP TABLE taxi;
DROP TABLE periodo;
DROP TABLE morada;

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
  id_morada,                  CONSTRAINT nn_motorista_id_morada NOT NULL,
  carta_conducao    NUMBER(9) CONSTRAINT nn_motorista_carta_conducao NOT NULL,
  ano_nascimento    DATE      CONSTRAINT nn_motorista_ano_nascimento NOT NULL,
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
    CHECK ((LENGTH (carta_conducao) = 9) AND (carta_conducao > 0)),
--
  CONSTRAINT ck_motorista_ano_nascimento
    CHECK ((EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM ano_nascimento) >= 18))
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
  sequencia             NUMBER(4),
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
    CHECK (numero_de_pessoas > 0) 
--
  CONSTRAINT ck_viagem_km_percorridos
    CHECK (km_percorridos > 0)
--
  CONSTRAINT ck_viagem_contida_no_periodo
    CHECK ((inicio_periodo > turno_inicio_periodo) AND (fim_periodo < turno_fim_periodo))
    -- RIA-18 Nao esta a verificar que o numero de sequencia tem de 
    -- começar em 1, nao sei como fazer
    --
);
