# Evidencia 10: Análisis de Política de Retención de Datos

## 1. Objetivo

Evaluar la propuesta de almacenamiento indefinido de datos de clientes formulada por la organización, identificando los riesgos técnicos, legales y operacionales asociados a la acumulación de datos innecesarios, y definiendo los criterios requeridos para establecer una política de retención conforme al principio de minimización y al marco regulatorio aplicable (LFPDPPP).

---

## 2. Análisis del Escenario

La propuesta formulada por la organización:
> *"Conservar todos los datos de clientes indefinidamente porque podrían ser útiles en el futuro."*

Representa una práctica anti-patrón en el gobierno de datos, contraria a la privacidad por diseño y a las normativas de protección de datos personales. A continuación se responden las interrogantes planteadas.

---

## 3. Respuestas a las Preguntas de Análisis

### Pregunta 1: ¿Es compatible con el principio de minimización?

**No.** El principio de minimización de datos exige que el tratamiento se limite a lo estrictamente adecuado, pertinente y necesario para la finalidad que justificó su obtención. 

* **Minimización temporal:** La minimización no solo aplica a la *cantidad* de datos recopilados, sino también al *tiempo* durante el cual se conservan.
* **Incompatibilidad:** Almacenar datos bajo la premisa de que "podrían ser útiles en el futuro" viola directamente el principio de minimización y de limitación de la finalidad, ya que convierte un tratamiento hipotético en una justificación para la conservación indefinida.

---

### Pregunta 2: ¿Qué riesgos genera conservar información innecesaria?

Conservar datos personales de forma indefinida incrementa de manera exponencial los siguientes riesgos:

1. **Mayor superficie de impacto ante incidentes de seguridad:** En caso de una filtración de datos (*data breach*) o ataque por *ransomware*, el volumen de información expuesta será mucho mayor, afectando incluso a titulares que ya no mantienen relación comercial con la empresa.
2. **Imposibilidad de justificación legal y sanciones regulatorias:** Ante una auditoría por parte del órgano garante (como el INAI en México), no contar con un plazo de conservación legalmente justificado constituye una infracción directa a la LFPDPPP, lo que puede resultar en multas económicas severas.
3. **Inconsistencias y datos desactualizados (Baja Calidad):** Los datos almacenados por largos periodos sin actualización pierden exactitud, lo que afecta negativamente las operaciones de negocio y las decisiones analíticas.
4. **Elevación de costos de infraestructura y mantenimiento:** Aumenta innecesariamente el consumo de almacenamiento, el tiempo de ejecución de respaldos (*backups*), la replicación y la complejidad en el mantenimiento del motor PostgreSQL.
5. **Dificultad en la atención de Derechos ARCO:** Localizar, modificar o cancelar información de titulares se vuelve más complejo cuando los volúmenes de datos históricos inactivos crecen sin control.

---

### Pregunta 3: ¿Qué debería determinar la organización antes de establecer un periodo de retención?

Antes de definir cuánto tiempo debe conservarse un dato en la base de datos, la organización debe determinar:

1. **Obligaciones Legales y Fiscales:** Identificar si existen normativas que exijan un periodo mínimo de conservación (por ejemplo, el Código Fiscal de la Federación en México exige conservar documentación contable y comprobantes fiscales por al menos 5 años).
2. **Necesidad Operativa y Comercial:** Definir durante cuánto tiempo es indispensable mantener el dato activo para prestar el servicio o cumplir con el contrato originario.
3. **Plazos de prescripción de acciones legales:** Determinar el tiempo en el que podrían presentarse reclamaciones contractuales o laborales derivadas de la relación comercial.
4. **Ciclo de vida del titular:** Establecer criterios para definir cuándo un cliente pasa de ser "activo" a "inactivo" (por ejemplo, 12 o 24 meses sin transacciones).
5. **Mecanismos de borrado o anonimización:** Definir qué ocurrirá al finalizar el plazo: si el dato será eliminado de forma definitiva o si será anonimizado de manera irreversible para fines meramente estadísticos.

---

### Pregunta 4: ¿Qué información debería documentarse para justificar el periodo seleccionado?

Para dar cumplimiento a los principios de responsabilidad demostrada (*accountability*) y transparencia, la organización debe incluir en su política documentada:

1. **Tabla de Retención de Datos:** Matriz que relacione la categoría de dato, su finalidad, la base legal que lo ampara y el tiempo exacto de retención.
2. **Fundamento Jurídico o Regulatorio:** Cita explícita de las leyes, reglamentos o códigos que imponen el plazo de conservación (p. ej., Ley del IVA, CFF, LFPDPPP).
3. **Reglas de Desencadenamiento (Triggers del ciclo de vida):** Especificación del evento que inicia el conteo del periodo de retención (p. ej., "a partir de la fecha del último pago" o "a partir de la cancelación de la cuenta").
4. **Procedimiento de Supresión / Anonimización:** Instrucciones detalladas sobre los métodos técnicos utilizados para purgar los datos de la base de datos de producción, respaldos y sistemas secundarios.
5. **Roles y Responsables:** Definición de quién aprueba la política (*Data Owner* / Área Jurídica) y quién ejecuta los procedimientos técnicos en la base de datos (*Data Custodian* / DBA).

---

## 4. Conclusión

El almacenamiento indefinido de datos personales bajo la suposición de un "uso futuro" es insostenible desde la perspectiva de seguridad, privacidad y cumplimiento legal. Establecer una política formal de retención de datos permite reducir la superficie de ataque del sistema PostgreSQL, optimizar el uso de recursos técnicos y garantizar que la conservación de la información responda a justificaciones normativas y operativas reales.