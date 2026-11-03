# Evidencia 11: Matriz de Gobierno de Datos

## 1. Objetivo

Establecer una matriz de gobierno de datos para definir la asignación de responsabilidades (*Data Owner*), los niveles de acceso basados en necesidades funcionales (RBAC / Mínimo Privilegio), las medidas de protección técnica, los tiempos de retención legal/operativa y las acciones al finalizar el ciclo de vida de cada dato en la base de datos de Comercializadora Norte S.A. de C.V.

---

## 2. Matriz de Gobierno de Datos

| Dato | Finalidad | Responsable (*Data Owner*) | Usuarios Autorizados | Protección | Retención | Acción al finalizar |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **nombre** | Identificación del titular para prestación de servicios y facturación. | Dirección de Operaciones / Servicio al Cliente | Atención al cliente, Facturación, DBA (Lectura técnica / Mantenimiento) | Control de acceso por roles (RBAC), Cifrado en tránsito (TLS/SSL). | Duración de la relación contractual + 5 años fiscales. | Purga / Eliminación definitiva de producción y respaldos. |
| **correo** | Comunicación operativa, envío de facturas y autenticación de cuenta. | Dirección de Operaciones | Atención al cliente, Facturación, DBA | RBAC, Cifrado en tránsito, Restricción de exportaciones masivas. | Duración del contrato o hasta solicitud de cancelación. | Borrado definitivo (Supresión de listas operativas). |
| **telefono** | Contacto directo para soporte de entregas o emergencias operativas. | Gerencia de Atención al Cliente | Atención al cliente, DBA | RBAC, Mascaramiento parcial en pantalla (`XXXX-XX12`). | Duración de la relación contractual. | Eliminación física del registro (`DELETE` controlado). |
| **rfc** | Identificación tributaria para la emisión de CFDI y auditorías fiscales. | Gerencia de Administración y Finanzas | Facturación, DBA (Mantenimiento exclusivo) | Cifrado en reposo (Column-level Encryption / PGP), RBAC estricto, Auditoría activa. | 5 años fiscales a partir del ejercicio correspondiente (Código Fiscal). | Bloqueo posterior y purga al vencer plazo legal. |
| **edad** | Segmentación demográfica para análisis de mercado (Uso Agregado). | Gerencia de Inteligencia de Negocio / Analítica | Analítica (solo vista anonimizada/agregada), DBA | Transformación a rangos en Vistas (`v_analitica_clientes`), Sin acceso a tabla base. | No se almacena edad exacta; rangos agregados de forma indefinida. | Anonimización irreversible / Desasociación completa. |
| **ciudad** | Logística de envíos y análisis de cobertura regional. | Gerencia de Logística | Atención al cliente, Facturación, Analítica, DBA | RBAC, Vistas agregadas para el área de Analítica. | Duración del contrato (Operativo) / Indefinido (Datos Agregados). | Eliminación del dato individual / Conservar agregado. |
| **codigo_postal** | Validación de envíos, costos de flete y requisitos de timbrado fiscal. | Gerencia de Logística / Finanzas | Atención al cliente, Facturación, DBA | RBAC, Enmascaramiento parcial en consultas analíticas. | Duración de la relación contractual + 5 años (Fiscal). | Purga del registro directo. |

---

## 3. Justificación del Diseño y Asignación de Roles

1. **Relación entre Acceso y Necesidad Funcional:** 
   * El área de **Facturación** únicamente requiere `nombre`, `correo`, `rfc`, `ciudad` y `codigo_postal` para la generación de CFDI. No requiere acceso a datos como `telefono` o `edad`.
   * El área de **Atención al Cliente** interactúa con el usuario a través de `nombre`, `correo` y `telefono`, pero no tiene justificación para consultar el `rfc`.
   * El área de **Analítica** trabaja exclusivamente sobre datos geográficos y rangos de edad mediante vistas (`v_analitica_clientes`), impidiendo el acceso a identificadores directos.

2. **Rol del DBA como Custodio de Datos (*Data Custodian*):**
   * El DBA administra la infraestructura del motor PostgreSQL y aplica los controles técnicos (vistas, roles, esquemas de cifrado), pero **no es el propietario (*Data Owner*) del dato**. Las decisiones sobre quién accede a cada campo dependen del área de negocio responsable.

3. **Acciones al Finalizar el Ciclo de Vida:**
   * Se diferencian las acciones de **Purga/Eliminación definitiva** (para identificadores directos en producción) y **Anonimización irreversible** (para conservación de estadísticas desasociadas de personas físicas).

---

## 4. Conclusión

La implementación de una matriz de gobierno de datos permite operacionalizar los principios de **Privacidad por Diseño y por Defecto**. Al vincular explícitamente cada dato con un propietario (*Data Owner*), un propósito funcional y una medida de protección específica en PostgreSQL, la organización garantiza que los permisos no se otorguen de forma masiva o indiscriminada, reduciendo la exposición de información sensible y facilitando la trazabilidad operativa.