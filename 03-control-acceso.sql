-- ============================================================
-- Actividad 4: Control de acceso relacionado con la finalidad
-- ============================================================

-- 1. Crear el rol de base de datos sin permiso de inicio de sesión directo (NOLOGIN)
CREATE ROLE analista NOLOGIN;

-- 2. Crear vista con la información segregada y anonimizada para analítica
CREATE VIEW v_analitica_clientes AS 
SELECT 
    ciudad, 
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más' 
    END AS rango_edad 
FROM clientes;

-- 3. Otorgar únicamente los permisos estrictamente necesarios sobre el esquema y la vista
GRANT USAGE ON SCHEMA public TO analista;
GRANT SELECT ON v_analitica_clientes TO analista;

-- NOTA: Se omite intencionalmente dar permisos sobre la tabla principal:
-- NO EJECUTAR: GRANT SELECT ON clientes TO analista;

-- 4. Verificación de privilegios asignados al rol analista
SELECT 
    grantee, 
    table_name, 
    privilege_type 
FROM information_schema.role_table_grants
WHERE grantee = 'analista';