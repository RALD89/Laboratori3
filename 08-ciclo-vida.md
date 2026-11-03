# Evidencia 08: Derecho de Cancelación y Ciclo de Vida de los Datos

## 1. Objetivo
Analizar las implicaciones técnicas y la complejidad operativa asociadas al **Derecho de Cancelación (Derecho ARCO)** dentro de la infraestructura de una organización, identificando las réplicas, respaldos, derivaciones y sistemas donde reside la información del titular más allá de la tabla principal de la base de datos.

---

## 2. Mapa del Ciclo de Vida y Ecosistema del Dato

```text
clientes (Tabla Principal / Base de Datos Producción)
   │
   ├── Tablas Relacionadas / Operativas
   │     ├── clientes_soporte
   │     ├── facturas / comprobantes fiscales
   │     └── historial_pedidos
   │
   ├── Respaldos (Backups)
   │     ├── Respaldos diarios / semanales (Dump SQL, PG_BASEBACKUP)
   │     └── Almacenamiento en la nube / cintas off-site
   │
   ├── Réplicas y Ambientes Secundarios
   │     ├── Réplicas de lectura (Read Replicas)
   │     ├── Servidores de Standby / High Availability (HA)
   │     └── Entornos de desarrollo / testing (Dev/QA)
   │
   ├── Registros de Auditoría y Bitácoras
   │     ├── Logs del motor (WAL / pg_activity)
   │     └── Audit logs del sistema (pgAudit)
   │
   ├── Copias para Analítica y BI
   │     ├── Vistas materializadas (v_analitica_clientes)
   │     └── Data Warehouse / Data Lake
   │
   ├── Reportes y Archivos Exportados
   │     ├── Archivos CSV / Excel descargados por personal
   │     └── PDF de facturas y reportes contables
   │
   └── Sistemas Externos y Terceros
         ├── Plataformas de mailing / CRM (SendGrid, Mailchimp)
         └── Proveedores de facturación electrónica (PAC)
```

---

## 3. Análisis Técnico y Respuestas a las Interrogantes

### ¿Existen otras tablas relacionadas?
**Sí.** En un SGBD relacional existen tablas asociadas como `clientes_soporte`, tablas de ordenes o ventas y comprobantes fiscales. Eliminar el registro en `clientes` sin considerar la integridad referencial (`FOREIGN KEY`) genera inconsistencias o errores de restricción.

### ¿Existen respaldos?
**Sí.** Las organizaciones generan *dumps* o imágenes completas de la base de datos diariamente. Aunque el dato se borre en producción, sigue existiendo de forma histórica dentro de los archivos de respaldo comprimidos e inmutables.

### ¿Existen réplicas?
**Sí.** Si existe replicación física o lógica activa en PostgreSQL, la sentencia de eliminación se propagará a las réplicas de lectura, pero si hay un desfase o réplicas fuera de línea, el dato persistirá en ellas hasta su sincronización.

### ¿Existen registros de auditoría?
**Sí.** Las operaciones de creación, modificación o eliminación se escriben en los archivos de bitácora (`Write-Ahead Logging - WAL` o `pgAudit`). Borrar el dato de la tabla no borra las líneas de auditoría pasadas que registraron la interacción del titular.

### ¿Existen copias utilizadas para analítica?
**Sí.** Los motores de inteligencia de negocios (BI) o Data Warehouses suelen importar o duplicar información periódicamente. Si no se sincronizan los procesos de cancelación, los datos personales permanecen en dichos entornos.

### ¿Existen archivos exportados?
**Sí.** Es común que áreas operativas generen extracciones locales en formatos `CSV`, `XLSX` o reportes impresos antes de procesar una cancelación.

### ¿Existen sistemas externos?
**Sí.** Si la empresa utiliza herramientas de terceros para envío de promociones (CRMs) o pasarelas de pago, los datos han sido transferidos fuera de la base de datos PostgreSQL.

---

## 4. Respuesta a la Pregunta Principal

**¿Por qué eliminar un registro de una tabla no necesariamente significa que toda la información relacionada con esa persona haya desaparecido de la organización?**

Ejecutar la instrucción `DELETE FROM clientes WHERE id = X;` únicamente elimina la fila correspondiente dentro de las páginas de datos activas de la tabla principal en el motor relacional. Sin embargo, esto **no elimina automáticamente la información del titular de la organización** debido a las siguientes razones fundamentales:

1. **Persistencia en Respaldos e Inmutabilidad:** Los respaldos (*backups*) están diseñados para ser inalterables por motivos de seguridad y recuperación ante desastres. Modificar un archivo de respaldo binario o `.dump` para borrar a un solo titular no es técnicamente viable sin invalidar la integridad del respaldo completo.
2. **Dispersión y Silos de Datos:** La información suele propagarse hacia Data Warehouses, réplicas, herramientas externas de marketing, archivos locales descargados por empleados y registros contables/fiscales.
3. **Obligaciones Legales de Conservación (Bloqueo):** Por ley (p. ej., legislación fiscal), determinados datos (como facturas y RFC) no pueden ser eliminados inmediatamente aunque el cliente lo solicite; deben pasar a un periodo de *bloqueo* donde dejan de tratarse operativamente pero se conservan para atender requerimientos de la autoridad.
4. **Trazabilidad y Bitácoras:** Las bitácoras de auditoría (`audit logs`) retienen el historial de los datos para garantizar la trazabilidad del sistema.

---

## 5. Conclusión
El **Derecho de Cancelación** no es simplemente ejecutar una consulta `DELETE` en la base de datos. Requiere un marco integral de **Gobierno de Datos y Ciclo de Vida** que combine procedimientos administrativos (políticas de eliminación en respaldos, notificaciones a terceros) y controles técnicos (bloqueo de datos, anonibilización irreversible y sincronización de réplicas) para asegurar que el dato deje de ser tratable de forma efectiva en toda la arquitectura de la organización.