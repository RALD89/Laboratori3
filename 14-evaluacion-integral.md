# Evidencia 14: Evaluación Integral de Riesgos de Privacidad y Gobierno de Datos

## 1. Objetivo
Realizar un diagnóstico integral sobre la infraestructura y procesos de datos de la organización a partir de un escenario real, identificando vulnerabilidades, violaciones a principios de protección de datos personales (LFPDPPP) y proponiendo controles técnicos y administrativos de mitigación.

---

## 2. Matriz de Evaluación Integral de Riesgos

| # | Problema Identificado | Principio Afectado | Riesgo Asociado | Control Propuesto |
|---|---|---|---|---|
| **1** | Acceso directo del área de analítica a la tabla principal `clientes` | Mínimo Privilegio / Minimización de Datos | Exposición no autorizada de PII (identificadores directos como RFC y teléfono) a personal que solo genera estadísticas. | Revocar `SELECT` en `clientes` para analistas. Crear vistas agregadas o anonimizadas (`v_analitica_clientes`) y otorgar permisos exclusivos sobre la vista. |
| **2** | Exposición de identificadores directos (`nombre`, `correo`, `telefono`, `RFC`) a analítica | Proporcionalidad y Separación de Finalidades | Reidentificación de titulares, filtración de datos sensibles o uso indebido de la información personal. | Implementar enmascaramiento dinámico de datos (*Dynamic Data Masking*) o utilizar algoritmos de anonimización en el pipeline de BI. |
| **3** | Conservación de datos de clientes durante 12 años sin justificación | Minimización temporal / Retención de Datos | Acumulación masiva de datos inactivos que incrementa el impacto ante un ataque de *ransomware* o filtración de datos (*data breach*). | Definir y documentar una política de retención. Archivar o eliminar registros que superen el periodo legal y operativo justificado (p. ej., 5 años fiscales). |
| **4** | Ausencia de una política documentada de retención de datos | Responsabilidad Demostrada (*Accountability*) / Cumplimiento Legal | Incumplimiento normativo de la LFPDPPP, imposibilidad de justificar la conservación ante auditorías del INAI y posibles sanciones económicas. | Elaborar, aprobar e implementar una Política Institucional de Retención y Purgado de Datos respaldada por el área jurídica y la dirección. |
| **5** | Uso de copias completas con datos reales en entornos de desarrollo y pruebas | Privacidad por Defecto / Confidencialidad | Copia de datos productivos en laptops de desarrolladores o servidores de pruebas con bajos controles de seguridad, provocando fugas masivas. | Implementar técnicas de seudonimización, anonimización o generación de datos sintéticos (*pg_dump* filtrado o bibliotecas como *Faker*) para entornos Dev/QA. |
| **6** | Uso de correos electrónicos para marketing sin verificación de consentimiento | Limitación de Finalidad / Consentimiento | Violación al derecho de oposición del cliente, envío de SPAM no solicitado y multas por tratamiento no autorizado para finalidades secundarias. | Implementar campo de control de consentimiento (`recibe_promociones BOOLEAN DEFAULT FALSE`) y condicionar las listas de emailing mediante vistas filtradas. |
| **7** | Ausencia de documentación sobre la finalidad de cada dato (Falta de Catálogo/Inventario) | Transparencia / Gobierno de Datos | Desconocimiento del uso legítimo de la información, decisiones arbitrarias por parte de TI y dificultad para atender solicitudes ARCO. | Crear y mantener un **Catálogo/Inventario de Datos** oficial que mapee cada campo con su finalidad, responsable (*Data Owner*) y nivel de acceso. |
| **8** | Ausencia de separación entre ambientes de producción, desarrollo y analítica | Privacidad por Diseño / Control de Acceso | Contaminación de datos de producción, ejecuciones accidentales de `UPDATE`/`DELETE` o extracción sin auditoría desde entornos no protegidos. | Segregar redes, servidores y bases de datos aisladas. Restringir la extracción masiva de datos mediante políticas de RBAC y monitoreo de red. |
| **9** | Falta de controles de auditoría sobre quién consulta los datos de 50,000 clientes | Trazabilidad / Responsabilidad | Imposibilidad de realizar análisis forense si un empleado descarga o filtra la base de datos completa. | Configurar la extensión `pgAudit` en PostgreSQL para registrar consultas masivas, modificaciones e intentos de acceso no autorizados sobre datos personales. |
| **10** | Exposición constante de RFC en consultas operativas y estadísticas | Confidencialidad / Protección de datos fiscales | Uso indebido de datos fiscales para suplantación de identidad o fraude ante autoridades tributarias (SAT). | Restringir el acceso al RFC únicamente al rol de `Facturación` mediante permisos a nivel de columna o vistas específicas. |

---

## 3. Análisis de Impacto y Priorización

El escenario presentado muestra una organización operando bajo un esquema tradicional de **"acumulación indiscriminada"**, donde la base de datos de producción es tratada como un recurso de acceso abierto para todos los departamentos. 

Los mayores riesgos inmediatos son:
1. **Fuga por entorno de desarrollo:** Es el vector de ataque más probable, dado que los datos reales residen en ambientes con menor seguridad.
2. **Sanciones por uso secundario no autorizado:** La reutilización de correos para marketing sin mecanismo de desacuerdo (*opt-out*) infringe directamente la regulación de protección de datos personales.

---

## 4. Conclusión

La evaluación integral demuestra que la seguridad técnica del motor PostgreSQL es ineficaz si no está acompañada por un marco sólido de **Gobierno de Datos**. La implementación de controles como la segregación de ambientes, el uso de datos sintéticos en desarrollo, las vistas agregadas para analítica y la definición de políticas formales de retención reducen drásticamente la superficie de vulnerabilidad de Comercializadora Norte S.A. de C.V.