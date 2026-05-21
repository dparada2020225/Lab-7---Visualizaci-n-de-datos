-- ============================================================
-- RetailMax | Área 3: FINANZAS
-- Dashboard: 12 indicadores en 2 tabs
-- Tab 1: Rentabilidad y Márgenes (indicadores 1-6)
-- Tab 2: Pagos y Reembolsos     (indicadores 7-12)
-- ============================================================


-- ===========================================================
-- TAB 1: RENTABILIDAD Y MÁRGENES
-- ===========================================================

-- ── INDICADOR 1 ─────────────────────────────────────────────
-- Nombre: Ingresos Totales vs Costo Total (por mes)
-- Qué representa: Evolución mensual de ingresos brutos y costo
--   de ventas, mostrando la brecha de rentabilidad.
-- Por qué importa: Permite detectar meses donde el margen se
--   comprime o expande, alertando sobre presión en costos.
-- Visualización: Gráfico de líneas doble (ingresos vs costo).
--   Dos series en el tiempo son ideales para comparar tendencias.
-- ────────────────────────────────────────────────────────────
SELECT
    TO_CHAR(p.fecha, 'YYYY-MM')                                        AS mes,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0)), 2)                        AS ingresos_netos,
    ROUND(SUM(dp.cantidad * pr.precio_costo), 2)                       AS costo_total
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
JOIN producto pr       ON pr.id_producto = dp.id_producto
WHERE p.estado = 'completado'
GROUP BY mes
ORDER BY mes;


-- ── INDICADOR 2 ─────────────────────────────────────────────
-- Nombre: Margen Bruto por Categoría
-- Qué representa: Utilidad bruta (ingreso - costo) y porcentaje
--   de margen agrupado por categoría de producto.
-- Por qué importa: Identifica qué líneas de producto son más
--   rentables para orientar decisiones de portafolio.
-- Visualización: Gráfico de barras horizontales ordenado de
--   mayor a menor margen %. Fácil comparación entre categorías.
-- ────────────────────────────────────────────────────────────
SELECT
    c.nombre                                                            AS categoria,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0)), 2)                        AS ingresos_netos,
    ROUND(SUM(dp.cantidad * pr.precio_costo), 2)                       AS costo_total,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0))
          - SUM(dp.cantidad * pr.precio_costo), 2)                     AS margen_bruto,
    ROUND(
        (SUM(dp.cantidad * dp.precio_unitario * (1 - dp.descuento / 100.0))
         - SUM(dp.cantidad * pr.precio_costo))
        / NULLIF(SUM(dp.cantidad * dp.precio_unitario
                     * (1 - dp.descuento / 100.0)), 0) * 100
    , 2)                                                               AS margen_pct
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
JOIN producto pr       ON pr.id_producto = dp.id_producto
JOIN categoria c       ON c.id_categoria = pr.id_categoria
WHERE p.estado = 'completado'
GROUP BY c.nombre
ORDER BY margen_pct DESC;


-- ── INDICADOR 3 ─────────────────────────────────────────────
-- Nombre: Top 10 Productos más Rentables
-- Qué representa: Los 10 productos que generan mayor margen
--   bruto absoluto en ventas completadas.
-- Por qué importa: Permite a Finanzas priorizar qué productos
--   proteger en presupuesto y negociación con proveedores.
-- Visualización: Tabla con columnas de ingresos, costo y margen.
--   La tabla permite ver valores exactos, ideal para informes.
-- ────────────────────────────────────────────────────────────
SELECT
    pr.nombre                                                           AS producto,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0)), 2)                        AS ingresos_netos,
    ROUND(SUM(dp.cantidad * pr.precio_costo), 2)                       AS costo_total,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0))
          - SUM(dp.cantidad * pr.precio_costo), 2)                     AS margen_bruto
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
JOIN producto pr       ON pr.id_producto = dp.id_producto
WHERE p.estado = 'completado'
GROUP BY pr.nombre
ORDER BY margen_bruto DESC
LIMIT 10;


-- ── INDICADOR 4 ─────────────────────────────────────────────
-- Nombre: Ingresos por Tienda (Ranking)
-- Qué representa: Ingreso neto total generado por cada sucursal
--   de RetailMax en todo el período.
-- Por qué importa: Finanzas necesita saber qué tiendas justifican
--   su inversión operativa y cuáles están por debajo del umbral.
-- Visualización: Gráfico de barras verticales ordenadas. Permite
--   comparación directa del desempeño por sucursal.
-- ────────────────────────────────────────────────────────────
SELECT
    t.nombre                                                            AS tienda,
    t.ciudad,
    t.region,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0)), 2)                        AS ingresos_netos
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
JOIN tienda t          ON t.id_tienda = p.id_tienda
WHERE p.estado = 'completado'
GROUP BY t.nombre, t.ciudad, t.region
ORDER BY ingresos_netos DESC;


-- ── INDICADOR 5 ─────────────────────────────────────────────
-- Nombre: Margen por Canal de Venta (Tienda vs Online)
-- Qué representa: Comparativa de ingresos, costos y margen
--   bruto diferenciado por canal (tienda física vs online).
-- Por qué importa: Determina cuál canal es más rentable para
--   orientar inversiones y decisiones de expansión.
-- Visualización: Gráfico de barras agrupadas (dos barras por
--   canal: ingreso y costo). Contraste visual inmediato.
-- ────────────────────────────────────────────────────────────
SELECT
    p.canal,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0)), 2)                        AS ingresos_netos,
    ROUND(SUM(dp.cantidad * pr.precio_costo), 2)                       AS costo_total,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0))
          - SUM(dp.cantidad * pr.precio_costo), 2)                     AS margen_bruto,
    ROUND(
        (SUM(dp.cantidad * dp.precio_unitario * (1 - dp.descuento / 100.0))
         - SUM(dp.cantidad * pr.precio_costo))
        / NULLIF(SUM(dp.cantidad * dp.precio_unitario
                     * (1 - dp.descuento / 100.0)), 0) * 100
    , 2)                                                               AS margen_pct
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
JOIN producto pr       ON pr.id_producto = dp.id_producto
WHERE p.estado = 'completado'
GROUP BY p.canal;


-- ── INDICADOR 6 ─────────────────────────────────────────────
-- Nombre: Impacto de Descuentos en Ingresos (por mes)
-- Qué representa: Monto total descontado mensualmente vs ingresos
--   brutos, mostrando qué tan agresiva es la política de descuentos.
-- Por qué importa: Los descuentos excesivos erosionan el margen;
--   Finanzas debe monitorear si los descuentos generan volumen
--   suficiente para compensar la pérdida de ingreso unitario.
-- Visualización: Gráfico de líneas (ingreso bruto vs descuento
--   aplicado). Revela correlación entre ambas variables.
-- ────────────────────────────────────────────────────────────
SELECT
    TO_CHAR(p.fecha, 'YYYY-MM')                                        AS mes,
    ROUND(SUM(dp.cantidad * dp.precio_unitario), 2)                    AS ingreso_bruto,
    ROUND(SUM(dp.cantidad * dp.precio_unitario * dp.descuento
              / 100.0), 2)                                             AS descuento_aplicado,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0)), 2)                        AS ingreso_neto
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
WHERE p.estado = 'completado'
GROUP BY mes
ORDER BY mes;


-- ===========================================================
-- TAB 2: PAGOS Y REEMBOLSOS
-- ===========================================================

-- ── INDICADOR 7 ─────────────────────────────────────────────
-- Nombre: Distribución de Métodos de Pago
-- Qué representa: Proporción de pagos realizados en efectivo,
--   tarjeta o transferencia, en cantidad y monto.
-- Por qué importa: Afecta la liquidez y los costos de transacción.
--   Muchos pagos en tarjeta implican comisiones bancarias.
-- Visualización: Gráfico de torta (pie chart). Ideal para mostrar
--   proporciones de un total dividido en pocas categorías.
-- ────────────────────────────────────────────────────────────
SELECT
    pg.metodo,
    COUNT(pg.id_pago)                                                  AS cantidad_pagos,
    ROUND(SUM(pg.monto), 2)                                            AS monto_total
FROM pago pg
GROUP BY pg.metodo
ORDER BY monto_total DESC;


-- ── INDICADOR 8 ─────────────────────────────────────────────
-- Nombre: Ingresos Cobrados vs Pedidos Cancelados (por mes)
-- Qué representa: Comparación mensual entre el valor de pedidos
--   completados (cobrados) y el valor perdido por cancelaciones.
-- Por qué importa: Los cancelados representan ingresos fallidos.
--   Finanzas debe cuantificar esta pérdida para proyecciones.
-- Visualización: Gráfico de barras apiladas o agrupadas por mes.
--   Muestra la magnitud de ambos estados en el tiempo.
-- ────────────────────────────────────────────────────────────
SELECT
    TO_CHAR(p.fecha, 'YYYY-MM')                                        AS mes,
    ROUND(SUM(CASE WHEN p.estado = 'completado'
                   THEN dp.cantidad * dp.precio_unitario
                        * (1 - dp.descuento / 100.0) ELSE 0 END), 2)  AS cobrado,
    ROUND(SUM(CASE WHEN p.estado = 'cancelado'
                   THEN dp.cantidad * dp.precio_unitario
                        * (1 - dp.descuento / 100.0) ELSE 0 END), 2)  AS perdido_cancelacion
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
GROUP BY mes
ORDER BY mes;


-- ── INDICADOR 9 ─────────────────────────────────────────────
-- Nombre: Monto Total de Reembolsos por Mes
-- Qué representa: Evolución mensual del dinero reembolsado a
--   clientes por devoluciones aprobadas.
-- Por qué importa: Los reembolsos son egresos directos. Un
--   aumento sostenido indica problemas de calidad o logística
--   que golpean el flujo de caja de Finanzas.
-- Visualización: Gráfico de área (area chart). Enfatiza la
--   acumulación de reembolsos a lo largo del tiempo.
-- ────────────────────────────────────────────────────────────
SELECT
    TO_CHAR(d.fecha, 'YYYY-MM')                                        AS mes,
    COUNT(d.id_devolucion)                                             AS cantidad_devoluciones,
    ROUND(SUM(d.monto_reembolso), 2)                                   AS total_reembolsado
FROM devolucion d
GROUP BY mes
ORDER BY mes;


-- ── INDICADOR 10 ─────────────────────────────────────────────
-- Nombre: Reembolsos por Motivo (Impacto Financiero)
-- Qué representa: Monto total reembolsado clasificado por motivo
--   de devolución (defectuoso, incorrecto, expectativas, etc.).
-- Por qué importa: Permite identificar el motivo que más dinero
--   le cuesta a la empresa, para priorizar acciones correctivas.
-- Visualización: Gráfico de barras horizontales. Facilita leer
--   etiquetas largas de motivos y comparar montos.
-- ────────────────────────────────────────────────────────────
SELECT
    d.motivo,
    COUNT(d.id_devolucion)                                             AS cantidad,
    ROUND(SUM(d.monto_reembolso), 2)                                   AS total_reembolsado,
    ROUND(AVG(d.monto_reembolso), 2)                                   AS promedio_reembolso
FROM devolucion d
GROUP BY d.motivo
ORDER BY total_reembolsado DESC;


-- ── INDICADOR 11 ─────────────────────────────────────────────
-- Nombre: Tasa de Devolución por Categoría (% sobre ventas)
-- Qué representa: Proporción del valor devuelto respecto al valor
--   vendido en cada categoría de producto.
-- Por qué importa: Una tasa alta en una categoría indica riesgo
--   financiero; Finanzas puede usar esto para ajustar provisiones
--   de reembolso en el presupuesto.
-- Visualización: Tabla con porcentaje. La precisión numérica es
--   clave para decisiones de aprovisionamiento financiero.
-- ────────────────────────────────────────────────────────────
SELECT
    c.nombre                                                            AS categoria,
    ROUND(SUM(dp.cantidad * dp.precio_unitario
              * (1 - dp.descuento / 100.0)), 2)                        AS ingresos_netos,
    ROUND(COALESCE(SUM(dev.monto_reembolso), 0), 2)                    AS total_reembolsado,
    ROUND(
        COALESCE(SUM(dev.monto_reembolso), 0)
        / NULLIF(SUM(dp.cantidad * dp.precio_unitario
                     * (1 - dp.descuento / 100.0)), 0) * 100
    , 2)                                                               AS tasa_devolucion_pct
FROM pedido p
JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
JOIN producto pr       ON pr.id_producto = dp.id_producto
JOIN categoria c       ON c.id_categoria = pr.id_categoria
LEFT JOIN devolucion dev ON dev.id_pedido = p.id_pedido
                        AND dev.id_producto = dp.id_producto
WHERE p.estado IN ('completado', 'devuelto')
GROUP BY c.nombre
ORDER BY tasa_devolucion_pct DESC;


-- ── INDICADOR 12 ─────────────────────────────────────────────
-- Nombre: Flujo Neto Mensual (Cobrado − Reembolsado)
-- Qué representa: El ingreso real mensual después de descontar
--   los reembolsos pagados a clientes.
-- Por qué importa: Es el indicador financiero más importante:
--   muestra el flujo de caja neto real del negocio, que es la
--   base para proyecciones, inversiones y reportes a dirección.
-- Visualización: Gráfico de barras con línea de tendencia.
--   Las barras muestran el neto mensual; la línea, la tendencia.
-- ────────────────────────────────────────────────────────────
SELECT
    TO_CHAR(series.mes, 'YYYY-MM')                                     AS mes,
    ROUND(COALESCE(ingresos.total, 0), 2)                              AS ingreso_neto,
    ROUND(COALESCE(reembolsos.total, 0), 2)                            AS reembolsado,
    ROUND(COALESCE(ingresos.total, 0)
          - COALESCE(reembolsos.total, 0), 2)                          AS flujo_neto
FROM (
    SELECT generate_series(
        MIN(fecha), MAX(fecha), '1 month'::interval
    ) AS mes
    FROM pedido
) series
LEFT JOIN (
    SELECT DATE_TRUNC('month', p.fecha)                                AS mes,
           SUM(dp.cantidad * dp.precio_unitario
               * (1 - dp.descuento / 100.0))                           AS total
    FROM pedido p
    JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
    WHERE p.estado = 'completado'
    GROUP BY DATE_TRUNC('month', p.fecha)
) ingresos ON ingresos.mes = series.mes
LEFT JOIN (
    SELECT DATE_TRUNC('month', d.fecha)                                AS mes,
           SUM(d.monto_reembolso)                                      AS total
    FROM devolucion d
    GROUP BY DATE_TRUNC('month', d.fecha)
) reembolsos ON reembolsos.mes = series.mes
ORDER BY series.mes;
