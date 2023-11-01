DROP TABLE historico;
DROP TABLE comissao;
DROP TABLE empregado CASCADE CONSTRAINTS;
DROP TABLE departamento;
DROP TABLE categoria;

CREATE TABLE categoria (
codigo NUMBER (3),
designacao VARCHAR (40) CONSTRAINT nn_categoria_designacao NOT NULL,
salario_base NUMBER (6,2) CONSTRAINT nn_categoria_salario_base NOT NULL,
--
CONSTRAINT pk_categoria
PRIMARY KEY (codigo),
--
CONSTRAINT un_categoria_designacao -- Designação é uma chave candidata, pois
UNIQUE (designacao), -- tem as restrições NOT NULL e UNIQUE.
--
CONSTRAINT ck_categoria_codigo
CHECK (codigo > 0),
--
CONSTRAINT ck_categoria_salario_base
CHECK (salario_base > 0.0)
);

-- ----------------------------------------------------------------------------

CREATE TABLE departamento (
  codigo      NUMBER  (3),
  nome        VARCHAR (40) CONSTRAINT nn_departamento_nome        NOT NULL,
  localizacao VARCHAR (40) CONSTRAINT nn_departamento_localizacao NOT NULL,
--
  CONSTRAINT pk_departamento
    PRIMARY KEY (codigo),
--
  CONSTRAINT un_departamento_nome          -- Nome é chave candidata, pois tem
    UNIQUE (nome),                         -- as restrições NOT NULL e UNIQUE.
--
  CONSTRAINT ck_departamento_codigo
    CHECK (codigo > 0)
--
-- Falta a chave estrangeira para o empregado que é diretor do departamento.
);

-- ----------------------------------------------------------------------------

CREATE TABLE empregado (
  numero       NUMBER  (5),
  nome         VARCHAR (40) CONSTRAINT nn_empregado_nome         NOT NULL,
  categoria                 CONSTRAINT nn_empregado_categoria    NOT NULL,
  departamento              CONSTRAINT nn_empregado_departamento NOT NULL,
  chefe                     CONSTRAINT nn_empregado_chefe        NOT NULL,
--
  CONSTRAINT pk_empregado
    PRIMARY KEY (numero),
--
  CONSTRAINT fk_empregado_categoria
    FOREIGN KEY (categoria)
    REFERENCES categoria (codigo),
--
  CONSTRAINT fk_empregado_departamento
    FOREIGN KEY (departamento)
    REFERENCES departamento (codigo),
--
  CONSTRAINT fk_empregado_chefe
    FOREIGN KEY (chefe)
    REFERENCES empregado (numero),
--
  CONSTRAINT ck_empregado_numero
    CHECK (numero > 0),
--
  CONSTRAINT ck_empregado_chefe      -- RIA 4: Um empregado não pode ser chefe
    CHECK ((numero <> chefe) OR      -- de si próprio, exceto o presidente
           (numero = 1))             -- (que se assume ter número 1).
);

-- ----------------------------------------------------------------------------

ALTER TABLE departamento ADD (
  diretor,            -- Pode não existir ainda o diretor de um departamento.
--
  CONSTRAINT fk_departamento_diretor
    FOREIGN KEY (diretor)
    REFERENCES empregado (numero),
--
  CONSTRAINT un_departamento_diretor     -- Obriga a que um empregado possa
    UNIQUE (diretor)                     -- dirigir no máximo um departamento.
);

-- ----------------------------------------------------------------------------

CREATE TABLE comissao (
  empregado,
  data      DATE,
  valor     NUMBER (6,2) CONSTRAINT nn_comissao_valor NOT NULL,
--
  CONSTRAINT pk_comissao
    PRIMARY KEY (empregado, data),
--
  CONSTRAINT fk_comissao_empregado
    FOREIGN KEY (empregado)                         -- Remoção de um empregado
    REFERENCES empregado (numero)                   -- apaga automaticamente
    ON DELETE CASCADE,                              -- as suas comissões.
--
  CONSTRAINT ck_comissao_valor
    CHECK (valor > 0.0)
);

-- ----------------------------------------------------------------------------

CREATE TABLE historico (
  empregado,
  categoria,
  data_admissao DATE CONSTRAINT nn_historico_data_admissao NOT NULL,
--
  CONSTRAINT pk_historico
    PRIMARY KEY (empregado, categoria),
--
  CONSTRAINT fk_historico_empregado
    FOREIGN KEY (empregado)
    REFERENCES empregado (numero),
--
  CONSTRAINT fk_historico_categoria
    FOREIGN KEY (categoria)
    REFERENCES categoria (codigo)
);
-- ----------------------------------------------------------------------------

ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';

-- ----------------------------------------------------------------------------

-- A categoria do presidente.
INSERT INTO categoria (codigo, designacao, salario_base)
     VALUES (100, 'Presidente', 3000.30);

-- Um departamento, para já sem diretor.
INSERT INTO departamento (codigo, nome, localizacao, diretor)
     VALUES (10, 'Engenharia', 'Lisboa', NULL);

-- O presidente, que é o único chefe de si próprio.
INSERT INTO empregado (numero, nome, categoria, departamento, chefe)
     VALUES (1, 'Miguel', 100, 10, 1);

-- O mesmo empregado é diretor do departamento onde trabalha.
UPDATE departamento
   SET diretor = 1
 WHERE (codigo = 10);

-- Uma comissão atribuída ao empregado.
INSERT INTO comissao (empregado, data, valor)
     VALUES (1, TO_DATE('19.10.2015', 'DD.MM.YYYY'), 500.50);

-- O empregado entrou na empresa para a categoria de presidente executivo.
INSERT INTO historico (empregado, categoria, data_admissao)
     VALUES (1, 100, TO_DATE('25.02.2015', 'DD.MM.YYYY'));

-- ----------------------------------------------------------------------------
-- Mais dados de categorias.

INSERT INTO categoria (codigo, designacao, salario_base)
     VALUES (200, 'Diretor', 2000.20);

INSERT INTO categoria (codigo, designacao, salario_base)
     VALUES (300, 'Consultor', 1000.10);

INSERT INTO categoria (codigo, designacao, salario_base)
     VALUES (400, 'Cobrador', 500.50);

-- ----------------------------------------------------------------------------
-- Mais dados de departamentos (para já sem diretores).

INSERT INTO departamento (codigo, nome, localizacao, diretor)
     VALUES (20, 'Pessoal', 'Porto', NULL);

INSERT INTO departamento (codigo, nome, localizacao, diretor)
     VALUES (30, 'Vendas', 'Porto', NULL);

INSERT INTO departamento (codigo, nome, localizacao, diretor)
     VALUES (40, 'Contabilidade', 'Lisboa', NULL);

-- ----------------------------------------------------------------------------
-- Mais dados de empregados.

INSERT INTO empregado (numero, nome, categoria, departamento, chefe)
     VALUES (2, 'Ana', 200, 20, 1);

INSERT INTO empregado (numero, nome, categoria, departamento, chefe)
     VALUES (3, 'Pedro', 200, 30, 1);

INSERT INTO empregado (numero, nome, categoria, departamento, chefe)
     VALUES (4, 'Daniel', 300, 20, 2);

INSERT INTO empregado (numero, nome, categoria, departamento, chefe)
     VALUES (5, 'Pedro', 300, 40, 2);

INSERT INTO empregado (numero, nome, categoria, departamento, chefe)
     VALUES (6, 'Carla', 300, 30, 3);

INSERT INTO empregado (numero, nome, categoria, departamento, chefe)
     VALUES (7, 'Manuel', 300, 30, 6);

-- ----------------------------------------------------------------------------
-- Diretores dos novos departamentos.

UPDATE departamento SET diretor = 2 WHERE (codigo = 20);
UPDATE departamento SET diretor = 3 WHERE (codigo = 30);

-- ----------------------------------------------------------------------------
-- Mais dados da historico dos empregados.

INSERT INTO historico (empregado, categoria, data_admissao)
     VALUES (2, 200, TO_DATE('16.03.2015', 'DD.MM.YYYY'));

INSERT INTO historico (empregado, categoria, data_admissao)
     VALUES (3, 200, TO_DATE('07.04.2015', 'DD.MM.YYYY'));

INSERT INTO historico (empregado, categoria, data_admissao)
     VALUES (4, 300, TO_DATE('04.04.2015', 'DD.MM.YYYY'));

INSERT INTO historico (empregado, categoria, data_admissao)
     VALUES (5, 300, TO_DATE('18.04.2015', 'DD.MM.YYYY'));

INSERT INTO historico (empregado, categoria, data_admissao)
     VALUES (6, 300, TO_DATE('29.04.2015', 'DD.MM.YYYY'));

INSERT INTO historico (empregado, categoria, data_admissao)
     VALUES (7, 300, TO_DATE('16.08.2015', 'DD.MM.YYYY'));

-- ----------------------------------------------------------------------------

COMMIT;
-- ----------------------------------------------------------------------------
--RESET PASSWORD 
--SELECT designacao FROM categoria;

--DESCRIBE categoria;

--SELECT object_name AS nome
--FROM user_objects
--WHERE object_type = 'TABLE';

--Start empdep.sql