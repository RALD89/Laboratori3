# Evidencia 12: Análisis de Privacidad por Diseño y por Defecto

## 1. Objetivo

Analizar la propuesta de diseño de tabla de clientes formulada por el equipo de desarrollo, evaluando las violaciones a los principios de privacidad, identificando datos innecesarios o sensibles y proponiendo una arquitectura basada en **Privacidad por Diseño (Privacy by Design)** y **Privacidad por Defecto (Privacy by Default)**.

## 2. Análisis del Escenario

La propuesta del desarrollador:

```
CREATE TABLE clientes (
    id BIGSERIAL, 
    nombre TEXT, 
    correo TEXT, 
    telefono TEXT, 
    rfc TEXT,
    edad INTEGER, 
    direccion TEXT, 
    ciudad TEXT, 
    codigo_postal TEXT, 
    fecha_nacimiento DATE,
    ocupacion TEXT, 
    salario NUMERIC, 
    estado_civil TEXT,
    ...
);

```

Justificación expresada: *"Es mejor guardar todos los datos por si posteriormente necesitamos alguno."*

## 3. Respuestas a las Preguntas de Análisis

### 1. ¿Qué problemas identificas?

* **Sobre-recopilación e indefensión jurídica:** Se están recopilando datos socioeconómicos y personales de alto riesgo (`salario`, `estado_civil`, `ocupacion`) sin una finalidad operativa definida.

* **Redundancia e inconsistencia:** Se solicitan tanto `edad` como `fecha_nacimiento`, lo que genera redundancia de datos. La edad es un dato derivado de la fecha de nacimiento.

* **Inexistencia de controles de acceso y tipos restringidos:** Todos los campos son de tipo general (`TEXT`, `NUMERIC`) sin restricciones de nulidad, validaciones ni esquemas de cifrado.

* **Aumento drástico de la superficie de impacto:** En caso de una filtración de la base de datos (*data breach*), la inclusión del salario y la ocupación expone a los clientes a riesgos severos como extorsión, fraude o robo de identidad.

### 2. ¿Qué principio de privacidad se está ignorando?

Se ignoran principalmente los siguientes principios:

* **Principio de Minimización de Datos:** Requiere tratar únicamente los datos estrictamente necesarios para la finalidad del servicio.

* **Principio de Limitación de la Finalidad:** Los datos no deben recopilarse "por si acaso" en el futuro, sino para propósitos explícitos, legítimos y comunicados previamente en el Aviso de Privacidad.

* **Privacidad por Diseño y por Defecto:** La privacidad debe ser una consideración técnica estructural desde la fase conceptual del modelo de datos, no un ajuste posterior.

### 3. ¿Qué preguntas realizarías antes de aprobar el diseño?

1. ¿Cuál es el objetivo de negocio explícito y la base jurídica para cada uno de los datos solicitados?

2. ¿El Aviso de Privacidad actual informa a los usuarios que se recopilarán datos como `salario` y `estado_civil`?

3. ¿Qué función operativa dentro de la aplicación requiere conocer la `ocupacion` o el `salario` del cliente?

4. ¿Es viable procesar esta información de forma anonimizada o mediante servicios de agregación de terceros sin guardarla en producción?

5. ¿Quién será el *Data Owner* responsable de aprobar la conservación de estos campos?

### 4. ¿Qué datos eliminarías?

Para una aplicación estándar de registro y soporte de clientes, se deben eliminar de inmediato:

* **`salario`:** Dato financiero altamente sensible innecesario para un registro operativo comercial general.

* **`estado_civil`:** Dato personal innecesario para la prestación del servicio.

* **`ocupacion`:** Dato innecesario salvo que la aplicación sea de otorgamiento de crédito o del sector financiero.

* **`edad`:** Dato redundante si se registra la fecha de nacimiento (o viceversa). No se deben almacenar ambos.

### 5. ¿Qué datos requerirían una justificación adicional?

* **`fecha_nacimiento` / `edad`:** Requeriría justificación adicional para verificar si la aplicación requiere legalmente validar la mayoría de edad del usuario.

* **`rfc`:** Requeriría justificación si la aplicación contempla facturación electrónica inmediata. De no ser así, debe solicitarse únicamente cuando el cliente requiera un CFDI.

* **`direccion` completa:** Solo justificado si la aplicación realiza entregas de mercancía o servicios a domicilio.

### 6. ¿Cómo aplicarías privacidad por defecto?

Para aplicar **Privacidad por Defecto (Privacy by Default)** en el motor PostgreSQL:

1. **Estructura Mínima al Crear la Tabla:**
   Diseñar la tabla de registro únicamente con los campos indispensables para la autenticación y contacto inicial:

   ```
   CREATE TABLE clientes (
       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
       nombre VARCHAR(120) NOT NULL,
       correo VARCHAR(150) NOT NULL UNIQUE,
       telefono VARCHAR(20),
       fecha_alta DATE DEFAULT CURRENT_DATE
   );
   
   ```

2. **Solicitud Progresiva de Datos (*Progressive Profiling*):**
   Los datos adicionales (como `rfc` o `direccion`) no se piden en el formulario de registro inicial, sino únicamente cuando el usuario solicita una función específica (p. ej., solicitar factura o pedir un envío).

3. **Opt-in por Defecto para Tratamientos Secundarios:**
   Las casillas de autorización para marketing o transferencia de datos deben estar desmarcadas por defecto (`DEFAULT FALSE`).

4. **Vistas Restringidas y RBAC:**
   Bloquear el acceso directo a la tabla `clientes` y exponer vistas filtradas según el rol del usuario del sistema.

## 4. Conclusión

La premisa de "guardar todo por si acaso" viola los principios fundamentales de protección de datos. Aplicar **Privacidad por Diseño y por Defecto** implica cuestionar la necesidad de cada atributo en el modelo entidad-relación antes de escribir código SQL, garantizando que el esquema de la base de datos nazca con la menor exposición posible de información personal.