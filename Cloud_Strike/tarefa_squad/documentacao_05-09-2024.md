# Cloud_Strike 

<p align="center">
  <img src="https://editors.dexerto.fr/wp-content/uploads/sites/2/2023/10/12/michael-jackson-sinvite-sur-cs2-grace-a-une-simple-commande.jpg" alt="Descrição da Imagem" width="1200" height="200"/>
</p>

### 📜 - DOCUMENTAÇÃO 05/09/2024

- Lucas Leite
- Gabriel Perosa
- Gabriel Roberto
- Julia Torres
- João Barbosa

<br>
<br>

# 💡 - Ideias para Otimização

Esse campo foi criado na documentação para fins de ideias que podem ser implementadas e discutidas com o time no caso a nossa squad para que possamos melhorar as consultas e fazendo assim com que nossos projetos consumam menos dados gerando assim custos menores que é o nosso objetivo.


## ⚙️ - Configuração e Análise de Dados no GCP

O projeto tem como objetivo configurar o ambiente Google Cloud Platform e utilizar o BigQuery para a manipulação de dados provenientes dos arquivos CSV 'Campaign' e 'Purchase'. A partir dessas configurações, serão criadas tabelas consolidadas com base em consultas SQL que cruzarão os dados de campanhas e compras. Por fim, será criada uma série de views, onde cada view dependerá da anterior, adicionando camadas de análise ou agregando dados, de forma que o encadeamento das views gere insights progressivos sobre as campanhas e o comportamento de compra dos clientes. Dessa forma, o ambiente GCP estará configurado, com as tabelas e views necessárias para a análise completa dos dados.

## ⚖️ - Particionamento e Clusterização de Tabelas

No BigQuery, tanto o particionamento quanto a clusterização são estratégias que ajudam a otimizar suas consultas, tornando-as mais rápidas e baratas. O particionamento divide os dados em pedaços menores com base em uma coluna específica, como a data, o que facilita o processamento ao focar apenas em partes relevantes. Já a clusterização organiza os dados em blocos baseados em uma ou mais colunas, o que acelera as consultas que usam essas colunas para filtros ou junções. Com essas técnicas, você consegue reduzir a quantidade de dados processados e melhorar o desempenho das suas análises.

<b>Exemplo em Código:</b>

- Particionamento por Data:

```sql
CREATE OR REPLACE TABLE `project.dataset.purchases`
PARTITION BY DATE(purchase_date) AS
SELECT * FROM `project.dataset.raw_purchases`;
```

- Clusterização por Coluna:

```sql
CREATE OR REPLACE TABLE `project.dataset.purchases`
PARTITION BY DATE(purchase_date)
CLUSTER BY client_id AS
SELECT * FROM `project.dataset.raw_purchases`;
```

## 👀 - Uso de Views Materializadas

As views materializadas armazenam resultados de consultas em uma tabela física e atualizam esses resultados conforme necessário. Elas são úteis para melhorar a performance de consultas complexas e frequentes, pois evitam a recomputação de resultados e utilizam os dados pré-calculados.

<b>Exemplo em Código:</b>

- Criação de View Materializada:

```sql
CREATE MATERIALIZED VIEW `project.dataset.v_compras_clientes_mat` AS
SELECT
    client_id,
    SUM(price * amount * (1 - discount_applied)) AS total_price,
    ARRAY_AGG(purchase_location ORDER BY COUNT(purchase_location) DESC LIMIT 1)[OFFSET(0)] AS most_purchase_location,
    MIN(purchase_date) AS first_purchase,
    MAX(purchase_date) AS last_purchase,
    CURRENT_DATE() AS date_today,
    FORMAT_TIMESTAMP('%m%Y', CURRENT_TIMESTAMP()) AS anomes_today
FROM
    `project.dataset.purchases`
GROUP BY
    client_id;
```

## 📅 - Agendamento de Jobs e Automação com Dataform

O Dataform permite agendar a execução de scripts SQL e a atualização automática das tabelas e views. Utilize Dataform para criar pipelines de dados que se atualizam regularmente, garantindo que seus dados estejam sempre atualizados sem intervenção manual.


## ⚠️ - Monitoramento e Alertas para Performance

Implementação de monitoramento e alertas para identificar e reagir rapidamente a problemas de desempenho e consumo de recursos. Utilize as métricas e logs disponíveis no GCP para monitorar a performance das suas consultas e a saúde geral do seu ambiente BigQuery.

## 📊 - Uso de Tabelas Temporárias para Consultas Complexas

Essa e alto descritiva pois ajuda muito no consumo de dados pois assim não será armazenado e após a consulta ela irá sumir. Isso pode melhorar a performance e facilitar a depuração

## ☁️ - Bucket automatizado

Por fim a squad teve como ideia a automatização do bucket para que ele ligue em determinados horarios de consultas e depois desligue para que o consumo seja menor e existem algumas vantagens e desavantagens 

<b>Vantagens:</b>
- 1 - Redução de Custos: Se o bucket não é utilizado constantemente, você pode reduzir custos associados ao armazenamento e às operações.

- 2 - Gerenciamento de Recursos: Evita a utilização desnecessária de recursos e pode ajudar a manter o ambiente mais organizado.

<b>Desvantagens:</b>

- 1 - Complexidade Adicional: Gerenciar o tempo de atividade e inatividade dos buckets pode adicionar complexidade ao gerenciamento do projeto.

- 2 - Risco de Acesso: Se o bucket precisar estar disponível fora do horário programado, pode haver problemas com o acesso inesperado.


