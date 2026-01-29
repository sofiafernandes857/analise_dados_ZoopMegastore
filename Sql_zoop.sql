-- =============== Conhecendo os dados =====================

-- Verificar a quantidade de dados em cada tabela
SELECT COUNT(*) QTD, 'T_categorias' Tabela FROM categorias
UNION ALL 
SELECT COUNT(*) QTD, 'T_clientes' Tabela FROM clientes
UNION ALL
SELECT COUNT(*) QTD, 'T_fornecedores' Tabela FROM fornecedores
UNION ALL
SELECT COUNT(*) QTD, 'T_itens_venda' Tabela FROM itens_venda
UNION ALL
SELECT COUNT(*) QTD, 'T_marcas' Tabela FROM marcas
UNION ALL
SELECT COUNT(*) QTD, 'T_produtos' Tabela FROM produtos
UNION ALL
SELECT COUNT(*) QTD, 'T_vendas' Tabela FROM vendas

-- Período dos dados
SELECT 
	DISTINCT strftime('%Y/%m', data_venda) periodo 
FROM vendas
ORDER BY periodo

-- Quais fornecedores temos
SELECT DISTINCT f.nome
FROM fornecedores f

-- Quais categorias temos
SELECT DISTINCT nome_categoria
FROM categorias

-- Quais marcas temos 
SELECT DISTINCT nome
FROM marcas

-- =============== Fornecedores =====================

-- Vendas de cada fornecedor por mês
SELECT 
	data, 
	SUM(
    	CASE 
    		WHEN nome = 'NebulaNetworks' THEN qtd_vendas ELSE 0 END) AS qtd_nebula,
    SUM(
    	CASE 
    		WHEN nome = 'HorizonDistributors' THEN qtd_vendas ELSE 0 END) AS qtd_horizon,
    SUM(
    	CASE 
    		WHEN nome = 'AstroSupply' THEN qtd_vendas ELSE 0 END) AS qtd_astro,
    SUM(
    	CASE 
    		WHEN nome = 'InfinityImports' THEN qtd_vendas ELSE 0 END) AS qtd_infinity,
    SUM(
    	CASE 
    		WHEN nome = 'SummitSolutions' THEN qtd_vendas ELSE 0 END) AS qtd_summit,
    SUM(
    	CASE 
    		WHEN nome = 'PinnaclePartners' THEN qtd_vendas ELSE 0 END) AS qtd_pinnacle,
    SUM(
    	CASE 
    		WHEN nome = 'TerraTrade' THEN qtd_vendas ELSE 0 END) AS qtd_terra,
    SUM(
    	CASE 
    		WHEN nome = 'EchoLogistics' THEN qtd_vendas ELSE 0 END) AS qtd_echo,
    SUM(
    	CASE 
    		WHEN nome = 'CosmicConnections' THEN qtd_vendas ELSE 0 END) AS qtd_cosmic,
    SUM(
    	CASE 
    		WHEN nome = 'OceanicOrigins' THEN qtd_vendas ELSE 0 END) AS qtd_oceanic
            
FROM (  
  SELECT f.nome, Count(p.fornecedor_id) qtd_vendas, strftime('%Y/%m', data_venda) data
    FROM itens_venda iv
    LEFT JOIN produtos p
        ON p.id_produto = iv.produto_id
    LEFT JOIN fornecedores f
        ON p.fornecedor_id = f.id_fornecedor
    LEFT JOIN vendas v 
        on iv.venda_id = v.id_venda
    GROUP BY fornecedor_id, data 
    ORDER BY data ASC)
    GROUP BY data

-- Para criação de gráfico de comparação entre os dois piores fornecedores e os dois melhores
SELECT 
	data, 
	SUM(
    	CASE 
    		WHEN nome = 'NebulaNetworks' THEN qtd_vendas ELSE 0 END) AS qtd_nebula,
    SUM(
    	CASE 
    		WHEN nome = 'HorizonDistributors' THEN qtd_vendas ELSE 0 END) AS qtd_horizon,
    SUM(
    	CASE 
    		WHEN nome = 'AstroSupply' THEN qtd_vendas ELSE 0 END) AS qtd_astro,
    SUM(
    	CASE 
    		WHEN nome = 'OceanicOrigins' THEN qtd_vendas ELSE 0 END) AS qtd_oceanic
            
FROM (  
  SELECT f.nome, Count(p.fornecedor_id) qtd_vendas, strftime('%Y/%m', data_venda) data
    FROM itens_venda iv
    LEFT JOIN produtos p
        ON p.id_produto = iv.produto_id
    LEFT JOIN fornecedores f
        ON p.fornecedor_id = f.id_fornecedor
    LEFT JOIN vendas v 
        on iv.venda_id = v.id_venda
    WHERE f.nome IN ('NebulaNetworks', 'AstroSupply', 'HorizonDistributors', 'OceanicOrigins')
    GROUP BY fornecedor_id, data 
    ORDER BY data ASC)
    GROUP BY data

-- Porcentagem dos Forcedores
SELECT 
	nome AS Nome_Fornecedores,
    qtd_vendas AS Quantidade_de_Vendas,
    ROUND(100.0*qtd_vendas / (SELECT COUNT(produto_id) FROM itens_venda), 2) || '%' AS Porcentagem
FROM (
  SELECT f.nome, Count(p.id_produto) qtd_vendas
  FROM itens_venda iv
  LEFT JOIN produtos p
      ON p.id_produto = iv.produto_id
  LEFT JOIN fornecedores f 
      ON p.fornecedor_id = f.id_fornecedor
  LEFT JOIN vendas v 
      on iv.venda_id = v.id_venda
  GROUP BY f.nome
  ORDER BY qtd_vendas DESC
  )

--- Melhor fornecedor de cada categoria
SELECT
	nome AS Nome_Fornecedor,
    nome_categoria AS Nome_Categoria,
    MAX(qtd_vendas) AS Quantidade_de_Venda
FROM (
  SELECT f.nome, c.nome_categoria, Count(p.fornecedor_id) qtd_vendas
  FROM itens_venda iv
  LEFT JOIN produtos p
      ON p.id_produto = iv.produto_id
  LEFT JOIN fornecedores f
      ON p.fornecedor_id = f.id_fornecedor
  LEFT JOIN vendas v 
      on iv.venda_id = v.id_venda
  LEFT JOIN categorias c 
  	on c.id_categoria = p.categoria_id
  GROUP BY fornecedor_id, categoria_id
  ORDER BY qtd_vendas
 )
 WHERE nome_categoria IN ('Alimentos', 'Livros', 'Vestuário', 'Eletrônicos', 'Esportes')
 GROUP BY nome_categoria

-- =============== Categorias =====================

-- Vendas de cada categoria durante os meses
SELECT 
	data, 
	SUM(
    	CASE 
    		WHEN nome_categoria = 'Eletrônicos' THEN qtd_vendas ELSE 0 END) AS qtd_eletronicos,
    SUM(
    	CASE 
    		WHEN nome_categoria = 'Livros' THEN qtd_vendas ELSE 0 END) AS qtd_livros,
    SUM(
    	CASE 
    		WHEN nome_categoria = 'Vestuário' THEN qtd_vendas ELSE 0 END) AS qtd_vestuario,
    SUM(
    	CASE 
    		WHEN nome_categoria = 'Esportes' THEN qtd_vendas ELSE 0 END) AS qtd_esportes,
    SUM(
    	CASE 
    		WHEN nome_categoria = 'Alimentos' THEN qtd_vendas ELSE 0 END) AS qtd_alimentos
            
FROM (  
  SELECT c.nome_categoria, Count(p.categoria_id) qtd_vendas, strftime('%Y/%m', data_venda) data
    FROM itens_venda iv
    LEFT JOIN produtos p
        ON p.id_produto = iv.produto_id
    LEFT JOIN categorias c
        ON p.categoria_id = c.id_categoria
    LEFT JOIN vendas v 
        on iv.venda_id = v.id_venda
    GROUP BY p.categoria_id, data 
    ORDER BY data ASC)
    GROUP BY data

-- Porcentagem de vendas de cada categoria
SELECT 
	nome_categoria,
    qtd_vendas,
    ROUND(100.0*qtd_vendas / (SELECT COUNT(produto_id) FROM itens_venda), 2) || '%' AS porcentagem
FROM (
  SELECT c.nome_categoria, Count(p.id_produto) qtd_vendas
  FROM itens_venda iv
  LEFT JOIN produtos p
      ON p.id_produto = iv.produto_id
  LEFT JOIN categorias c
      ON p.categoria_id = c.id_categoria
  LEFT JOIN vendas v 
      on iv.venda_id = v.id_venda
  GROUP BY nome_categoria 
  ORDER BY qtd_vendas DESC
  )

-- =============== Marcas =====================

-- Para criação de gráfico de comparação entre as marcas
SELECT 
	data, 
	SUM(
    	CASE 
    		WHEN nome = 'BluePeak' THEN qtd_vendas ELSE 0 END) AS qtd_blue,
    SUM(
    	CASE 
    		WHEN nome = 'ZenithWave' THEN qtd_vendas ELSE 0 END) AS qtd_wave,
    SUM(
    	CASE 
    		WHEN nome = 'SolarFlare' THEN qtd_vendas ELSE 0 END) AS qtd_solar,
    SUM(
    	CASE 
    		WHEN nome = 'EchoBloom' THEN qtd_vendas ELSE 0 END) AS qtd_echo,
    SUM(
    	CASE 
    		WHEN nome = 'CrystalCrest' THEN qtd_vendas ELSE 0 END) AS qtd_crystal,
    SUM(
    	CASE 
    		WHEN nome = 'NovaSphere' THEN qtd_vendas ELSE 0 END) AS qtd_sphere,
    SUM(
    	CASE 
    		WHEN nome = 'GreenPulse' THEN qtd_vendas ELSE 0 END) AS qtd_green,
    SUM(
    	CASE 
    		WHEN nome = 'SilverStream' THEN qtd_vendas ELSE 0 END) AS qtd_silver,
    SUM(
    	CASE 
    		WHEN nome = 'AmberField' THEN qtd_vendas ELSE 0 END) AS qtd_amber,
    SUM(
    	CASE 
    		WHEN nome = 'InfinityAura' THEN qtd_vendas ELSE 0 END) AS qtd_infinity
            
FROM (  
  SELECT m.nome, Count(p.marca_id) qtd_vendas, strftime('%Y/%m', data_venda) data
    FROM itens_venda iv
    LEFT JOIN produtos p
        ON p.id_produto = iv.produto_id
    LEFT JOIN marcas m 
        ON p.marca_id = m.id_marca
    LEFT JOIN vendas v 
        on iv.venda_id = v.id_venda
    GROUP BY marca_id, data 
    ORDER BY data ASC)
    GROUP BY data

-- Marca mais vendida por categoria 
SELECT
	nome AS Nome_Marcas,
    nome_categoria AS Nome_Categoria,
    MAX(qtd_vendas) AS Quantidade_de_Venda
FROM (
  SELECT m.nome, c.nome_categoria, Count(p.marca_id) qtd_vendas
  FROM itens_venda iv
  LEFT JOIN produtos p
      ON p.id_produto = iv.produto_id
  LEFT JOIN marcas m
      ON p.marca_id = m.id_marca
  LEFT JOIN vendas v 
      on iv.venda_id = v.id_venda
  LEFT JOIN categorias c 
  	on c.id_categoria = p.categoria_id
  GROUP BY marca_id, categoria_id
  ORDER BY qtd_vendas 
 )
 WHERE nome_categoria IN ('Alimentos', 'Livros', 'Vestuário', 'Eletrônicos', 'Esportes')
 GROUP BY nome_categoria

-- Porcentagem das Marcas
SELECT 
	nome AS nome_marca,
    qtd_vendas,
    ROUND(100.0*qtd_vendas / (SELECT COUNT(produto_id) FROM itens_venda), 2) || '%' AS porcentagem
FROM (
  SELECT m.nome, Count(p.id_produto) qtd_vendas
  FROM itens_venda iv
  LEFT JOIN produtos p
      ON p.id_produto = iv.produto_id
  LEFT JOIN marcas m
      ON p.marca_id = m.id_marca
  LEFT JOIN vendas v 
      on iv.venda_id = v.id_venda
  GROUP BY m.nome
  ORDER BY qtd_vendas DESC
  )

-- =============== Métricas =====================

-- Métrica para o quanto tivemos de aumento de uma ano para o outro 
WITH media_vendas_anteriores as
	(SELECT 
		AVG(qtd_vendas) as qtd_vendas_anteriores
    FROM (
      SELECT COUNT(*) AS qtd_vendas, strftime('%Y', v.data_venda) AS ano
      FROM vendas v
      WHERE strftime('%Y', v.data_venda) = '2021'
      GROUP BY ano
     )
    ),
     vendas_atual AS (
     	  SELECT 
       		qtd_vendas AS qtd_vendas_atual
          FROM (
            SELECT COUNT(*) AS qtd_vendas, strftime('%Y', v.data_venda) AS ano
            FROM vendas v
            WHERE strftime('%Y', v.data_venda) = '2022'
            GROUP BY ano
         )
     )
  	SELECT 
    	mva.qtd_vendas_anteriores,
        va.qtd_vendas_atual,
        ROUND((va.qtd_vendas_atual - mva.qtd_vendas_anteriores) / mva.qtd_vendas_anteriores * 100, 2) || '%' AS porcentagem
    FROM vendas_atual va, media_vendas_anteriores mva

-- Métrica para ver o quanto uma marca está abaixo da principal 
WITH 
  total_vendas AS (
    SELECT 
      COUNT(*) as total_vendas
    FROM itens_venda
  ),
  vendas_por_marcas AS (
      SELECT 
          m.nome AS nome_marca,
          COUNT(p.marca_id) qtd_vendas
      FROM vendas v 
      LEFT JOIN itens_venda iv 
          ON v.id_venda = iv.venda_id
      LEFT JOIN produtos p 
          ON p.id_produto = iv.produto_id
      LEFT JOIN marcas m 
          ON p.marca_id = m.id_marca
    GROUP BY m.nome
    ORDER BY qtd_vendas DESC
  ),
  marca_mais_vendida AS (
    SELECT 
      MAX(qtd_vendas) marca_mais_vendida
    FROM vendas_por_marcas
  )
  SELECT 
  	nome_marca,
    qtd_vendas AS quantidade_vendas,
  	ROUND(100.0*(Qtd_Vendas - marca_mais_vendida) / marca_mais_vendida, 2) || '%' AS Porcentagem
  FROM vendas_por_marcas
	CROSS JOIN total_vendas tv
	CROSS JOIN marca_mais_vendida

-- Métrica do total de venda do top 3 marcas
WITH 
total_vendas AS (
    SELECT 
        COUNT(*) AS total_vendas
    FROM itens_venda
),

vendas_por_marca AS (
    SELECT 
        m.nome AS nome_marca,
        COUNT(*) AS qtd_vendas
    FROM vendas v
    LEFT JOIN itens_venda iv 
        ON v.id_venda = iv.venda_id
    LEFT JOIN produtos p 
        ON p.id_produto = iv.produto_id
    LEFT JOIN marcas m 
        ON p.marca_id = m.id_marca
    GROUP BY m.nome
),

top_3_marcas AS (
    SELECT 
        nome_marca,
        qtd_vendas
    FROM vendas_por_marca
    ORDER BY qtd_vendas DESC
    LIMIT 3
),

vendas_top_3 AS (
    SELECT 
        SUM(qtd_vendas) AS total_top_3
    FROM top_3_marcas
)

SELECT 
    vtm.total_top_3 AS vendas_top_3_marcas,
    tv.total_vendas AS vendas_totais,
    ROUND(100.0 * vtm.total_top_3 / tv.total_vendas, 2) || '%' AS percentual_concentracao_top_3
FROM vendas_top_3 vtm
CROSS JOIN total_vendas tv;
