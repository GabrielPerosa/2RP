SELECT 
    -- Seleciona o ID do cliente
    p.client_id,
    
    -- Seleciona o local de compra mais utilizado pelo cliente
    p.purchase_location AS most_purchase_location,
    
    -- Calcula o total gasto pelo cliente, aplicando o desconto e arredondando para duas casas decimais,
    -- e concatena o resultado com o símbolo 'R$' para formatar como valor monetário
    CONCAT('R$ ', CAST(ROUND(SUM(p.price * p.amount * (1 - p.discount_applied)), 2) AS STRING)) AS total_price,
    
    -- Seleciona a data da primeira compra do cliente, formatada como 'yyyy-MM-dd'
    DATE_FORMAT(MIN(p.purchase_datetime), 'yyyy-MM-dd') AS first_purchase_date,
    
    -- Seleciona a data da última compra do cliente, formatada como 'yyyy-MM-dd'
    DATE_FORMAT(MAX(p.purchase_datetime), 'yyyy-MM-dd') AS last_purchase_date,
    
    -- Seleciona a campanha mais recebida pelo cliente
    c.most_campaign,
    
    -- Conta o número de campanhas com status 'error' para o cliente, substituindo NULL por 0 caso não haja erros
    COALESCE(e.error_count, 0) AS error_count,
    
    -- Adiciona a data atual formatada como 'yyyy-MM-dd'
    DATE_FORMAT(CURRENT_DATE, 'yyyy-MM-dd') AS current_date_format,
    
    -- Adiciona a data atual formatada como 'MM/yyyy'
    DATE_FORMAT(CURRENT_DATE, 'MM/yyyy') AS current_date_month_year

FROM (
    -- Subconsulta para calcular o local de compra mais utilizado por cliente e outras métricas relacionadas a compras
    SELECT 
        client_id,
        purchase_location,
        price,
        amount,
        discount_applied,
        purchase_datetime,
        -- Calcula o número da linha (rank) por cliente para determinar o local mais utilizado
        ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY COUNT(*) DESC) AS rank
    FROM 
        purchase
    GROUP BY 
        client_id, 
        purchase_location,
        price,
        amount,
        discount_applied,
        purchase_datetime
) p

-- Junta a subconsulta com a tabela de campanhas para adicionar a campanha mais recebida pelo cliente
LEFT JOIN (
    -- Subconsulta para encontrar a campanha mais recebida pelo cliente
    SELECT 
        client_id,
        id_campaign AS most_campaign
    FROM (
        -- Subconsulta interna para contar as campanhas recebidas por cliente
        SELECT 
            client_id,
            id_campaign,
            COUNT(*) AS campaign_count,
            -- Calcula o número da linha (rank) por cliente para determinar a campanha mais recebida
            ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY COUNT(*) DESC) AS rank
        FROM 
            campaigns_2023_hist
        WHERE 
            return_status = 'received'
        GROUP BY 
            client_id,
            id_campaign
    ) ranked_campaigns
    WHERE rank = 1
) c ON p.client_id = c.client_id

-- Junta a subconsulta com a tabela de campanhas para adicionar a quantidade de campanhas com status 'error' por cliente
LEFT JOIN (
    -- Subconsulta para contar o número de campanhas com status 'error' por cliente
    SELECT 
        client_id,
        COUNT(*) AS error_count
    FROM 
        campaigns_2023_hist
    WHERE 
        return_status = 'error'
    GROUP BY 
        client_id
) e ON p.client_id = e.client_id

-- Filtra apenas o local de compra mais utilizado por cliente, onde a rank é igual a 1
WHERE p.rank = 1

-- Agrupa os resultados finais por cliente e os diferentes atributos calculados
GROUP BY 
    p.client_id,
    p.purchase_location,
    c.most_campaign,
    e.error_count;