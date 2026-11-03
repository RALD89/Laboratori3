# Evidencia 01: Inventario y Finalidad de los Datos

## 1. Objetivo
Identificar, clasificar y evaluar la necesidad de cada uno de los campos de datos almacenados en la tabla de clientes de Comercializadora Norte S.A. de C.V., estableciendo su finalidad, necesidad operativa, niveles de acceso adecuados y política de retención conforme al marco de protección de datos (LFPDPPP) y los principios de minimización y proporcionalidad.

---

## 2. Matriz de Inventario y Gobierno de Datos

| Campo | ¿Es dato personal? | Finalidad | ¿Es necesario? | Nivel de acceso | Retención |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | No | Identificador único técnico y clave primaria para la integridad referencial del sistema. | Sí | Todos los roles operativos y técnicos (Lectura interna / Sistema). | Indefinido (mientras el registro exista operacionalmente). |
| **nombre** | Sí | Identificación directa del titular para la prestación del servicio, atención a clientes y emisión de facturación. | Sí | Atención al cliente, Facturación, DBA (Mínimo Privilegio). | Durante la relación contractual + periodo legal (p. ej., 5 años fiscales). |
| **correo** | Sí | Medio de contacto principal para notificaciones del servicio, confirmaciones de compra y autenticación. | Sí | Atención al cliente, DBA. | Durante la relación contractual o hasta que el cliente ejerza su derecho de cancelación. |
| **telefono** | Sí | Canal alternativo de contacto directo para soporte técnico, entregas o urgencias del servicio. | Sí | Atención al cliente, DBA. | Durante la relación contractual. |
| **rfc** | Sí (Dato fiscal/identificador) | Cumplimiento de obligaciones fiscales tributarias (emisión de CFDI/facturación). | Sí (Solo para facturación) | Exclusivo para el área de Facturación y DBA. | Conservación obligatoria por 5 años fiscales conforme al Código Fiscal de la Federación (CFF). |
| **edad** | Sí | Segmentación demográfica de clientes para análisis y estadísticas agregadas. | No (Para la operación directa) | Restringido / Solo agregados en vistas para Analítica. | Conservar únicamente como dato transformado (rango de edad) para analítica. |
| **ciudad** | Sí (Dato indirecto/geográfico) | Logística de envíos, soporte regional y análisis de distribución de mercado. | Sí | Atención al cliente, Facturación, Analítica (vistas agregadas), DBA. | Durante la relación contractual / Datos agregados indefinidamente. |
| **codigo_postal** | Sí (Dato de localización) | Verificación de cobertura, cálculo de costos de envío y validación de datos fiscales. | Sí | Atención al cliente, Facturación, DBA. | Durante la relación contractual / Datos agregados indefinidamente. |
| **fecha_alta** | No | Trazabilidad del registro y control del ciclo de vida de la cuenta dentro del sistema. | Sí | Atención al cliente, Facturación, Analítica, DBA. | Indefinido (asociado al ciclo de vida del registro). |

---

## 3. Justificación de Decisión por Campo

### **id**
* **Justificación:** Es un dato puramente sintético e interno generado por el sistema de base de datos. No contiene información personal que identifique a un individuo por sí solo, pero es indispensable para garantizar la integridad referencial y las operaciones del SGBD.

### **nombre**
* **Justificación:** Constituye un dato personal directo indispensable para la atención personalizada del cliente y para la formalización contractual o emisión de facturas. Se justifica su retención mientras la relación comercial esté activa y por el periodo legal contable aplicable.

### **correo**
* **Justificación:** Es el canal digital primario de comunicación operativa. Es estrictamente necesario para enviar confirmaciones, facturas o notificaciones de soporte. Debe restringirse el acceso al personal no operativo y no utilizarse para mercadotecnia sin consentimiento explícito previo.

### **telefono**
* **Justificación:** Es un dato personal de contacto directo. Es necesario para la resolución de dudas operativas o entregas de productos, pero no debe compartirse con analistas o áreas que no interactúen de forma directa con el usuario final.

### **rfc**
* **Justificación:** Aunque es un dato de identificación fiscal, su tratamiento es indispensable **únicamente** para procesos de facturación legal exigidos por las autoridades tributarias. No es necesario para el área de soporte ni analítica general, por lo que su nivel de acceso debe ser sumamente restrictivo.

### **edad**
* **Justificación:** La fecha o número exacto de edad constituye un dato personal que **no es necesario** para la prestación del servicio básico de atención al cliente ni facturación. Su recopilación directa y en texto plano viola el principio de minimización si el fin es meramente estadístico; en su lugar, se deben manejar rangos agrupados o procesados mediante analítica sin identificar al titular.

### **ciudad**
* **Justificación:** Dato de ubicación general necesario para determinar áreas de cobertura y logística operativa. Su riesgo individual es bajo cuando no va acompañado de una dirección completa, y permite la generación de analítica de mercado previa anonimización o agregación.

### **codigo_postal**
* **Justificación:** Necesario para validar domicilios de entrega y requisitos de facturación fiscal. Al ser un dato de ubicación indirecto, debe ser accesible para las áreas operativas, pero restringido para analítica si permite la reidentificación en poblaciones pequeñas.

### **fecha_alta**
* **Justificación:** Representa un metadato del sistema imprescindible para la auditoría de registros, la determinación del cumplimiento de tiempos de retención y la vigencia del contrato del titular dentro de la base de datos.

---

## 4. Resultado y Análisis
A través de este ejercicio de inventario se evidenció que la estructura actual de la base de datos de Comercializadora Norte S.A. de C.V. contiene una mezcla de datos estrictamente necesarios para la operación junto con datos que responden a necesidades estadísticas o secundarias (como la `edad`).

Al aplicar el **Principio de Minimización** y de **Limitación de Finalidad**:
1. Se determina que no todos los roles de la organización requieren acceso a todos los datos personales.
2. Los datos como el `rfc` deben ser segregados exclusivamente para el área fiscal.
3. Se identifica la necesidad de crear mecanismos (como vistas u homologación por rangos) para abastecer a áreas como Analítica sin exponer los datos de identificación personal directa.

---

## 5. Conclusión
El desarrollo del inventario y la matriz de datos permite migrar de una postura donde la base de datos acumula toda la información recibida "por si acaso", a una arquitectura gobernada bajo el enfoque de **Privacidad por Defecto**. Limitar el acceso y definir periodos de retención claros por cada tipo de campo reduce significativamente la superficie de impacto ante un incidente de seguridad y asegura el cumplimiento con la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP).