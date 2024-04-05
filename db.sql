-- Etapa 1
CREATE DATABASE barbearia;

-- Etapa 2
CREATE TABLE clientes (
  id INT(11) NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY pk_cliente_id(id)
);

CREATE TABLE produtos (
  id INT(11) NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  preco DECIMAL(10, 2) NOT NULL,
  estoque INT(3) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY pk_produto_id(id)
);

CREATE TABLE servicos (
  id INT(11) NOT NULL AUTO_INCREMENT,
  nome VARCHAR(50) NOT NULL,
  preco DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY pk_servico_id(id)
);

CREATE TABLE barbeiros (
  id INT(11) NOT NULL AUTO_INCREMENT,
  nome VARCHAR(50) NOT NULL,
  servico1_id INT(11) NOT NULL,
  servico2_id INT(11) NULL,
  PRIMARY KEY(id),
  UNIQUE KEY pk_barbeiro_id(id),
  KEY fk_barbeiro_servico1_id_idx(servico1_id),
  KEY fk_barbeiro_servico2_id_idx(servico2_id),
  CONSTRAINT fk_barbeiro_servico1_id FOREIGN KEY(servico1_id) REFERENCES servicos(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_barbeiro_servico2_id FOREIGN KEY(servico2_id) REFERENCES servicos(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE compras (
    id INT(11) NOT NULL AUTO_INCREMENT,
    cliente_id INT(11) NOT NULL,
    produto_id INT(11) NOT NULL,
    quantidade INT(11) NOT NULL,
    data_compra DATE NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Populando as tabelas
INSERT INTO clientes (nome)
  VALUES
    ("Miguel"),
    ("Gabriel"),
    ("Fulano"),
    ("Ciclano");

INSERT INTO produtos (nome, preco, estoque)
  VALUES
    ("Shampoo Clear Men Anticaspa", 40.00, 50),
    ("Gel Bozzano Azul fator 4", 30.00, 40),
    ("Pomada Urban Men Efeito Seco", 35.00, 20),
    ("Pomada Urban Men Efeito Molhado", 37.00, 20),
    ("Óleo para Barba Urban Men", 60.00, 10);

INSERT INTO servicos (nome, preco)
  VALUES
    ("Corte Cabelo Tesoura", 25.00),
    ("Corte Cabelo Máquina", 30.00),
    ("Sobrancelha na Navalha", 7.00),
    ("Corte Barba", 40.00),
    ("Hidratação Cabelo", 40.00),
    ("Hidratação Barba", 40.00);

INSERT INTO barbeiros (nome, servico1_id, servico2_id)
  VALUES
    ("Jackson", 1, 2),
    ("Alexandre", 3, 4),
    ("Lucas", 5, 6);

-- Etapa 3
CREATE VIEW gastos_clientes AS
SELECT 
    c.nome AS nome_cliente,
    SUM(s1.preco + COALESCE(s2.preco, 0)) AS total_gasto
FROM 
    clientes c
LEFT JOIN 
    barbeiros b ON RAND() <= 0.33
LEFT JOIN 
    servicos s1 ON b.servico1_id = s1.id
LEFT JOIN 
    servicos s2 ON b.servico2_id = s2.id
GROUP BY 
    c.nome;

-- Etapa 4

CREATE TRIGGER atualizar_estoque_compra
AFTER INSERT ON compras
FOR EACH ROW
BEGIN
    -- Atualiza o estoque do produto comprado
    UPDATE produtos 
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;

END;

-- Testando Trigger

SELECT * FROM produtos;

INSERT INTO compras (cliente_id, produto_id, quantidade, data_compra)
VALUES 
    (1, 1, 10, NOW());

INSERT INTO compras (cliente_id, produto_id, quantidade, data_compra)
VALUES 
    (2, 2, 5, NOW());

SELECT * FROM produtos;