# Evidencia 05: Análisis de Finalidad Secundaria

## 1. Objetivo
Analizar las implicaciones legales, éticas y técnicas de la reutilización de datos personales para finalidades secundarias (campañas de mercadotecnia y promociones personalizadas), evaluando el cumplimiento del principio de limitación de finalidad y diseñando controles de acceso para mitigar riesgos de privacidad.

---

## 2. Análisis del Escenario

### 1. ¿El hecho de que la organización ya tenga los datos significa automáticamente que puede utilizarlos para cualquier finalidad?
**No.** Contar con la posesión física o técnica de los datos en la base de datos no otorga un derecho irrestricto de uso. 
* **Marco Legal (LFPDPPP):** El principio de **limitación de finalidad** establece que los datos personales únicamente pueden ser tratados para las finalidades que fueron informadas y autorizadas por el titular en el Aviso de Privacidad original.
* **Finalidades Primarias vs. Secundarias:** La atención al cliente y la facturación son finalidades *primarias* (necesarias para la relación jurídica). El envío de promociones personalizadas representa una finalidad *secundaria*. Reutilizar los datos para este fin sin contar con una base jurídica válida o sin haber ofrecido al titular el mecanismo para manifestar su negativa o consentimiento constituye una violación a la legislación aplicable.

---

### 2. ¿Qué preguntas debería realizar la organización antes de implementar este tratamiento?
Antes de autorizar la implementación técnica en la base de datos, la organización debe evaluar las siguientes interrogantes:

1. **Aviso de Privacidad:** ¿El Aviso de Privacidad actual contempla explícitamente el tratamiento de datos para fines mercadotécnicos o publicitarios?
2. **Derecho de Oposición / Consentimiento:** ¿Se le proporcionó al cliente un mecanismo (opt-in / opt-out) para negarse a recibir mercadotecnia sin que esto afecte el servicio principal?
3. **Proporcionalidad y Minimización:** ¿Realmente se requieren datos personales identificables o se pueden generar campañas basadas en segmentos anonimizados?
4. **Gobierno de Datos:** ¿Quién es el propietario de este dato (*data owner*) y qué área autorizó la ampliación del uso de la información?
5. **Riesgo y Exposición:** ¿Qué impacto tendría en la reputación de la empresa y en los derechos del titular si esta información es utilizada incorrectamente o sufre una filtración?

---

### 3. ¿Qué datos serían realmente necesarios?
Para cumplir con la finalidad de personalización de promociones reduciendo al mínimo la exposición de datos personales (Principio de Minimización), se deben clasificar los campos:

* **Datos Necesarios:**
  * `correo` o `telefono` (únicamente como canal de contacto final).
  * `ciudad` (para ofertas por región geográfica).
  * `rango_edad` (derivado o agrupado, no la fecha de nacimiento ni la edad exacta).
  * *Historial o categoría de compra* (datos operativos de consumo agregados).
* **Datos Innecesarios / Prohibidos para Marketing:**
  * `rfc` (dato fiscal confidencial ajeno a la mercadotecnia).
  * `nombre` completo (si la plataforma de marketing permite el envío mediante identificadores opacos o tokens, o limitando el acceso a solo un primer nombre/alias).
  * `fecha_alta`, `codigo_postal` exacto o edad precisa.

---

### 4. ¿Necesitaría el área de marketing acceso directo a la tabla `clientes`?
**No.** Otorgar acceso directo (`SELECT ON clientes`) al equipo de marketing violaría el principio de mínimo privilegio y privacidad por defecto. 

El área de marketing no requiere visualizar registros completos ni datos sensibles o fiscales. Su interacción con los datos debe realizarse a través de vistas intermedias, tablas de salida anonimizadas o mediante herramientas de envío automáticas (como pasarelas de correo) donde no puedan exportar ni manipular la base de datos de producción.

---

### 5. ¿Qué controles técnicos podrían limitar la información entregada?
Para limitar la exposición de datos se deben implementar los siguientes controles en el SGBD:

1. **Vistas Limitadas y Enmascaramiento:** Crear una vista específica para marketing que exponga únicamente el canal de envío y el segmento, aplicando enmascaramiento sobre identificadores directos:
   ```sql
   CREATE VIEW v_marketing_promociones AS
   SELECT 
       correo,
       ciudad,
       CASE 
           WHEN edad BETWEEN 18 AND 29 THEN '18-29'
           WHEN edad BETWEEN 30 AND 44 THEN '30-44'
           ELSE '45+'
       END AS segmento_edad
   FROM clientes
   WHERE rechaza_publicidad = FALSE; -- Control de oposición
   ```
2. **Control de Acceso Basado en Roles (RBAC):** Crear un rol restringido `rol_marketing` con permisos exclusivos de `SELECT` sobre la vista `v_marketing_promociones`, sin privilegios sobre la tabla principal `clientes`.
3. **Banderas de Consentimiento / Opt-Out:** Incluir un campo booleano de control de preferencia (`acepta_publicidad DEFAULT FALSE` o `recibe_promociones`) para filtrar automáticamente en las vistas a aquellos usuarios que hayan ejercido su derecho de oposición (Derecho ARCO - Oposición).
4. **Seudonimización:** Sustituir la llave primaria real por un identificador sintético (token) al transferir datos hacia la plataforma externa de emailing.

---

## 3. Conclusión
Poseer la información en la base de datos no autoriza su uso indiscriminado. Las finalidades secundarias exigen una validación previa del marco del consentimiento y la implementación de controles técnicos estrictos (vistas reducidas, RBAC y filtros de preferencia) que garanticen que el personal de mercadotecnia trabaje únicamente con los datos mínimos necesarios sin comprometer la privacidad del titular.