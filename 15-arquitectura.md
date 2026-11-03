# Evidencia 15: Propuesta de Arquitectura de Datos Protegidos

## 1. Objetivo

Diseñar un modelo conceptual de arquitectura de base de datos en PostgreSQL que traduzca los principios de privacidad, minimización, limitación de finalidad y gobierno de datos en controles técnicos específicos, separando los flujos operacionales, analíticos y de auditoría.

---

## 2. Diagrama de Arquitectura Conceptual

```text
                                BASE DE DATOS (PostgreSQL)
                                            │
           ┌────────────────────────────────┼────────────────────────────────┐
           │                                │                                │
           ▼                                ▼                                ▼
  ESQUEMA OPERATIVO                 ESQUEMA ANALÍTICO                ESQUEMA AUDITORÍA
 (Esquema: `public`)              (Esquema: `analytics`)             (Esquema: `audit`)
           │                                │                                │
           ▼                                ▼                                ▼
   Datos Necesarios                  Datos Agregados                Bitácoras Inmutables
    para Operación                  y Anonimizados                   y Trazabilidad
 (Atención / Facturación)          (Vistas / Datamarts)             (pgAudit / WAL Logs)
```

---

## 3. Desglose de Controles por Capa y Principio

### A. Control de Acceso (RBAC & Mínimo Privilegio)
* **Capa Operativa:** Se definen roles funcionales estrictos (`rol_soporte`, `rol_facturacion`). Ningún usuario de aplicación tiene acceso directo a tablas sin intermediación de permisos específicos o vistas.
* **Capa Analítica:** El rol `rol_analista` solo posee permisos de `SELECT` sobre el esquema `analytics`. Se prohíbe explícitamente el acceso a la tabla base `public.clientes`.
* **Capa de Auditoría:** El esquema `audit` es de solo lectura para auditores de seguridad (`rol_auditor`) y de consulta exclusiva para procesos del sistema. Ningún usuario operativo ni el DBA en tareas rutinarias modifica estas tablas.

---

### B. Minimización de Datos
* **Separación por esquemas y tablas secundarias:** Creación de tablas específicas (`clientes_soporte`) y vistas restringidas para que cada departamento consuma únicamente los campos esenciales.
* **Agregación en tiempo real / diferido:** Transformación de variables individuales (ej. `edad`) en variables categóricas anonimizadas (ej. `rango_edad`) mediante vistas o procesos ETL antes de exponerlos a Analítica.

---

### C. Protección de Información Sensible
* **Cifrado en Reposo y Nivel de Columna:** Cifrado de datos fiscales como el `rfc` mediante extensiones criptográficas (`pgcrypto`) o cifrado de disco completo (TDE/LUKS).
* **Enmascaramiento de Datos (Data Masking):** Enmascaramiento dinámico o estático para campos de contacto (`telefono` expuesto como `XXXX-XX12`, `correo` como `a***@example.com`) en ambientes de pruebas y soporte secundario.
* **Segregación de Entornos:** Los entornos de desarrollo/QA utilizan bases de datos generadas sintéticamente (*Faker*) o volcados previa anonibilización irreversible (`pg_dump` con scripts de ofuscación).

---

### D. Retención de Datos
* **Triggers de Ciclo de Vida / Particionamiento:** Creación de tablas particionadas por fecha para facilitar el purgado de datos inactivos al cumplir su tiempo de retención legal (ej. 5 años para datos de facturación).
* **Mantenimiento Automatizado (`pg_cron` / Jobs Scheduled):** Procesos programados que identifican registros cuyo periodo de retención ha expirado para moverlos a estado de bloqueo o proceder con su eliminación definitiva.

---

### E. Trazabilidad
* **Auditoría con `pgAudit`:** Registro detallado de todas las sentencias DDL (modificación de estructuras) y DML (consultas/modificaciones sobre tablas con PII).
* **Columnas de Metadatos:** Inclusión de campos de auditoría interna (`creado_por`, `creado_en`, `modificado_por`, `modificado_en`) gestionados mediante *triggers* automáticos en la base de datos.

---

### F. Eliminación Segura
* **Borrado Definitivo (*Hard Delete* vs. *Soft Delete*):** 
  * Uso de *Soft Delete* (`eliminado_en TIMESTAMP`, `estado = 'CANCELADO'`) únicamente durante el periodo de bloqueo legal exigido por las autoridades.
  * *Hard Delete* (`DELETE` físico + `VACUUM FULL` / Purga de páginas) ejecutado al concluir el periodo de bloqueo legal o ante una orden express de cancelación.
* **Políticas de Depuración en Respaldos:** Protocolo documentado para asegurar que los respaldos históricos purguen o sobrescriban datos según la ventana de retención (ej. rotación de backups a 30 días).

---

### G. Atención de Solicitudes ARCO
* **Procedimientos de Acceso (A):** Scripts y vistas consolidadas para extraer la totalidad de la información de un titular ante una solicitud formal.
* **Procedimientos de Rectificación (R):** Interfaces de actualización controladas con registro de bitácora que capturan la justificación y el usuario que autorizó la modificación del dato.
* **Procedimientos de Cancelación y Oposición (C / O):** 
  * Inclusión de la bandera `acepta_publicidad BOOLEAN DEFAULT FALSE` para respetar la oposición a finalidades secundarias.
  * Mecanismo de estado `bloqueado_por_arco` para congelar el tratamiento de datos durante la resolución de disputas de privacidad.

---

## 4. Conclusión

La arquitectura propuesta demuestra que la protección de datos no es una medida aislada, sino una estructura multicapa donde el motor PostgreSQL aplica controles de **Control de Acceso (RBAC)**, **Minimización (Vistas/Esquemas)**, **Trazabilidad (Auditoría)** y **Ciclo de Vida (Retención/Eliminación)**. Esta separación conceptual garantiza que Comercializadora Norte S.A. de C.V. cumpla con el marco legal (LFPDPPP) garantizando la privacidad por diseño y por defecto.