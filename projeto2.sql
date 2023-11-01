DROP TABLE pessoa;
DROP TABLE motorista;
DROP TABLE cliente;
DROP TABLE morada;
DROP TABLE taxi;
DROP TABLE periodo;
DROP TABLE viagem;

CREATE TABLE morada (
id NUMBER(5),
rua VARCHAR(40) CONSTRAINT nn_morada_rua NOT NULL,
numero_da_porta NUMBER(2) CONSTRAINT nn_morada_numerp_da_porta NOT NULL,
codigo_postal NUMBER(4) CONSTRAINT nn_morada_codigo_postal NOT NULL,
localidade VARCHAR(40) CONSTRAINT nn_morada_localidade NOT NULL,
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

CONSTRAINT ck_periodo
CHECK (inicio < fim)
);

------------------------------------------------------------------------------

CREATE TABLE taxi (
matricuka VARCHAR(8),
ano_de_compra DATE CONSTRAINT nn_taxi_ano_de_compra NOT NULL,
marca VARCHAR(40) CONSTRAINT nn_taxi_marca NOT NULL,
modelo VARCHAR(40) CONSTRAINT nn_taxi_modelo NOT NULL,
nivel_de_comforto VARCHAR(40) CONSTRAINT nn_taxi_nivel_de_comforto NOT NULL,
--
CONSTRAINT pk_pessoa
PRIMARY KEY (nif)
);

------------------------------------------------------------------------------

CREATE TABLE pessoa (
nif NUMBER(9),
nome VARCHAR(40) CONSTRAINT nn_pessoa_nome NOT NULL,
genero VARCHAR(10) CONSTRAINT nn_pessoa_genero NOT NULL,
--
CONSTRAINT pk_pessoa
PRIMARY KEY (nif)
);