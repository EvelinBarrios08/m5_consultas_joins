
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- TechStore - Consultas SQL con JOINs
-- Autora: Barrios Evelin Eliana
-- Módulo 5 - Pre-entrega 5
-- Base de datos: Ventas_Tech_DB
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

USE Ventas_Tech_DB;
GO


-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 1 - VISTA BASE DEL PROYECTO (INNER JOIN)
-- Integra las ventas con clientes, productos y categorías para enriquecer el análisis comercial y utilizar la información en Power BI.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.ciudad,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, c.id_cliente;



-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 2 - CLIENTES SIN VENTAS (LEFT JOIN)
-- Identifica clientes registrados que nunca realizaron compras, para detectar oportunidades de activación desde el área de CRM.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    c.id_cliente,
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL
ORDER BY c.nombre;



-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 3 - PRODUCTOS SIN VENTAS (LEFT JOIN)
-- Identifica productos del catálogo sin ventas registradas, para detectar artículos que requieren análisis comercial.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL
ORDER BY p.nombre_producto;



-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 4 - CONSOLIDADO POR ORIGEN (UNION ALL)
-- Consolida las ventas en dos grupos definidos por ID y calcula el importe total de cada grupo.
-- Los nombres de origen se generan en la consulta y no representan canales comerciales registrados en la base.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    consolidado.canal,
    SUM(consolidado.total) AS total_canal
FROM (
    SELECT
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total,
        'Grupo 1' AS canal
    FROM ventas AS v
    WHERE v.id_venta <= 5

    UNION ALL

    SELECT
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total,
        'Grupo 2' AS canal
    FROM ventas AS v
    WHERE v.id_venta > 5
) AS consolidado
GROUP BY consolidado.canal
ORDER BY consolidado.canal;



-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- HALLAZGOS DE NEGOCIO
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════


-- 1. La consulta integra 10 registros de ventas, con una facturación total de $6.444.
--    La información permite analizar los resultados por cliente, producto,
--    categoría y ciudad, enriqueciendo la información para el análisis comercial.


-- 2. No se identificaron clientes sin compras entre los clientes registrados.
--    Por lo tanto, con los datos actuales no se detectan clientes pendientes de realizar su primera compra
--    para orientar acciones de activación por parte del área de CRM.


-- 3. No se identificaron productos sin ventas entre los productos asociados a una categoría.
--    En consecuencia, la consulta no detecta artículos sin movimiento comercial dentro del conjunto analizado.


-- 4. El Grupo 1 registra una facturación de $3.620, mientras que el Grupo 2 alcanza $2.824.
--    El Grupo 1 supera al Grupo 2 en $796. Esta comparación se basa en la división de las ventas por ID
--    y no representa una comparación entre canales comerciales reales.
