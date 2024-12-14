-- Ajustando privilegios
SET GLOBAL local_infile = 1;

-- Criando schema
CREATE schema maxxi

-- setando o schema
use maxxi

-- criando a tabela cadastro e vendas 
CREATE TABLE cadastro (
    cod_cadastro INT PRIMARY KEY,
    estado_civil VARCHAR(25),
    grau_instrucao VARCHAR(40),
    num_filhos TINYINT,
    salario FLOAT,
    idade_anos TINYINT,
    reg_procedencia VARCHAR(25)
);

CREATE TABLE vendas (
    cod_venda INT PRIMARY KEY,
    cod_cadastro INTEGER,
    produto VARCHAR(40),
    valor FLOAT,
    FOREIGN KEY (cod_cadastro) REFERENCES cadastro(cod_cadastro)
);

-- Inserindo dados Cadastro e Vendas
LOAD DATA LOCAL INFILE 'C:\\Users\\danie\\TesteMaxxi\\cadastro.csv'
INTO TABLE cadastro
FIELDS TERMINATED BY ';' -- Delimitador de campo
LINES TERMINATED BY '\n' -- Quebra de linha
IGNORE 1 ROWS; 

LOAD DATA LOCAL INFILE 'C:\\Users\\danie\\TesteMaxxi\\vendas.csv'
INTO TABLE vendas
FIELDS TERMINATED BY ';' -- Delimitador de campo
LINES TERMINATED BY '\n' -- Quebra de linha
IGNORE 1 ROWS; 


-- Respondendo as questões

-- Avaliando as Tabelas
SELECT * from cadastro

SELECT * from vendas

-- Questao 1
 -- Quem mais gastou
WITH Ranking_Clientes AS (
  SELECT 
    c.cod_cadastro as 'Cliente', 
    ROUND(SUM(v.valor),2) AS 'Total Gasto',
    RANK() OVER (ORDER BY SUM(v.valor) DESC) AS Ranking
  FROM vendas v
    LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
    GROUP BY c.cod_cadastro
    ORDER BY Ranking
    )
  
SELECT * FROM Ranking_Clientes
WHERE Ranking = (SELECT  MIN(Ranking) FROM Ranking_Clientes);

 -- Quem menos gastou
WITH Ranking_Clientes AS (
  SELECT 
    c.cod_cadastro as 'Cliente', 
    ROUND(SUM(v.valor),2) AS 'Total Gasto',
    RANK() OVER (ORDER BY SUM(v.valor) DESC) AS Ranking
  FROM vendas v
    LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
    GROUP BY c.cod_cadastro
    ORDER BY Ranking
    )
  
SELECT * FROM Ranking_Clientes
WHERE Ranking = (SELECT  MAX(Ranking) FROM Ranking_Clientes); --Mudou-se de MIN para MAX


-- Questão 2 -- SEM USAR O RANK, PORÉM ERA POSSÍVEL
SELECT c.reg_procedencia as 'Região', ROUND(SUM(v.valor),2) AS 'Total Gasto' FROM vendas v
LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
GROUP BY c.reg_procedencia
ORDER BY SUM(v.valor) DESC
LIMIT 1



-- Questão 3 
-- Resposta: 2 PRODUTOS, PODE-SE USAR OUTRO CIRTÉRIO PARA TRAZER APENAS 1 PRODUTO, COMO O VALOR TOTAL 
WITH Ranking_Clientes AS (
  SELECT 
    produto, 
    COUNT(produto) AS 'Qtde. Total de compras',
    RANK() OVER (ORDER BY COUNT(produto) DESC) AS Ranking
  FROM vendas v
    GROUP BY produto
    ORDER BY Ranking
    )
  
SELECT * FROM Ranking_Clientes
WHERE Ranking = (SELECT  MIN(Ranking) FROM Ranking_Clientes); 



-- Questao 4
-- CENÁRIO 1: Em Valor
SELECT 
  c.*, 
  ROUND(SUM(v.valor),2) AS 'Total Gasto', 
  COUNT(produto) AS 'Qtde Total de compras',
  SUM(salario)/ROUND(SUM(v.valor),2) AS 'Salario/Gasto',
  ROUND(SUM(v.valor),2)/COUNT(produto) AS 'TKT MEDIO'
FROM vendas v
LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
GROUP BY c.cod_cadastro
ORDER BY SUM(v.valor) DESC
LIMIT 5

-- Avaliando os produtos para os TOP 5 clientes em Gasto
-- Produto mais rentavel
WITH CLIENTES_TOP5_QTDE AS (
SELECT 
  c.cod_cadastro 
FROM vendas v
LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
GROUP BY c.cod_cadastro
ORDER BY SUM(v.valor) DESC
LIMIT 5
) 
SELECT produto, SUM(v.valor) FROM vendas v
WHERE v.cod_cadastro IN (SELECT cod_cadastro FROM CLIENTES_TOP5_QTDE)
GROUP BY v.produto
ORDER BY SUM(v.valor) DESC;

-- Produto mais frequente
WITH CLIENTES_TOP5_QTDE AS (
SELECT 
  c.cod_cadastro 
FROM vendas v
LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
GROUP BY c.cod_cadastro
ORDER BY SUM(v.valor) DESC
LIMIT 5
) 
SELECT produto, COUNT(produto) FROM vendas v
WHERE v.cod_cadastro IN (SELECT cod_cadastro FROM CLIENTES_TOP5_QTDE)
GROUP BY v.produto
ORDER BY COUNT(produto) DESC;

--R: 
 -- A maior parte gastou entre 30 e 50
 -- A maioria tem um ticket Medio entre 10 e 15
 -- 60% São solteiros e não tem filhos
 -- 80% tem salário superior a 13 e inferior a 20 
 -- 80% dos top 5 em valor gasto fizeram 3 compras.
 -- O produto mais frequente entre os cliente foi o pó de café (3 unidades)
 -- E o mais rentável entre os cliente foi o Queijo ($71)


-- CENÁRIO 2: Em Qtde de compras
SELECT 
  c.*,
  ROUND(SUM(v.valor),2) AS 'Total Gasto', 
  COUNT(produto) AS 'Qtde Total de compras',
  SUM(salario)/ROUND(SUM(v.valor),2) AS 'Salario/Gasto',
  ROUND(SUM(v.valor),2)/COUNT(produto) AS 'TKT MEDIO'
FROM vendas v
LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
GROUP BY c.cod_cadastro
ORDER BY COUNT(produto) DESC
LIMIT 5;

-- Avaliando os produtos para Top 5 clientes em Qtde
-- Produto mais rentavel
WITH CLIENTES_TOP5_QTDE AS (
SELECT 
  c.cod_cadastro 
FROM vendas v
LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
GROUP BY c.cod_cadastro
ORDER BY COUNT(produto) DESC
LIMIT 5
) 
SELECT produto, SUM(v.valor) FROM vendas v
WHERE v.cod_cadastro IN (SELECT cod_cadastro FROM CLIENTES_TOP5_QTDE)
GROUP BY v.produto
ORDER BY SUM(v.valor) DESC;

-- Produto mais frequente
WITH CLIENTES_TOP5_QTDE AS (
SELECT 
  c.cod_cadastro 
FROM vendas v
LEFT JOIN cadastro c on c.cod_cadastro = v.cod_cadastro
GROUP BY c.cod_cadastro
ORDER BY COUNT(produto) DESC
LIMIT 5
) 
SELECT produto, COUNT(produto) FROM vendas v
WHERE v.cod_cadastro IN (SELECT cod_cadastro FROM CLIENTES_TOP5_QTDE)
GROUP BY v.produto
ORDER BY COUNT(produto) DESC;

--R: 
 -- A maior parte gastou mais 2x mais do que recebe
 -- 80% São casados 
 -- 80% tem salário superior a 13 e inferior a 15, com baixo desvio padrão 
 -- 100% dos clientes top 5 fizeram 3 compras.
 -- Os produtos mais comprados foram Bolacha e Laranja (3 unidades)
 -- O produto mais rentável foi o pó de café ($43,6)

 

 -- Questão 5
SELECT SUM(c.num_filhos) FROM cadastro c
GROUP BY c.grau_instrucao
