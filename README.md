# Mercanto

Repositorio global.

### Referencias de Submódulos

* **[Submódulo Backend (`./mercanto-backend`)](https://github.com/vect-maker/mercanto)**:  API central en Rust y workers.
* **[Submódulo Frontend (`./mercanto-frontend`)](https://github.com/doomii18/Mercanto_Front-end)**:  Cliente SPA en Vue 3 + TypeScript (Vite).

---

## Contexto del Dominio y Problema a Resolver

**TL;DR:** Mercanto es una plataforma e-commerce B2B orientada a digitalizar y descentralizar el comercio mayorista en Nicaragua. Conecta a importadores/mayoristas de Managua con MIPYMES regionales para eliminar la fricción logística y la asimetría de información en la cadena de suministro.

* **Problema:** La alta concentración geográfica de proveedores genera gastos elevados de transporte, ineficiencia temporal y dificultad para auditar precios y calidad por parte de los pequeños comerciantes departamentales.
* **Solución Arquitectónica:** Plataforma transaccional B2B basada en un modelo de comisión por transacción (2.5%) que centraliza el descubrimiento de proveedores, digitalización de catálogos y logística de envíos.
* **Casos de Uso Críticos & Edge Cases:**
  * **Verificación de Entidades (Prevención de Fraude):** Validación estricta mediante RUC e insignias de verificación. Previene la creación de tiendas fantasma.
  * **Comunicación de Alta Concurrencia:** Chat integrado comprador-distribuidor.
  * **Búsqueda Inteligente:** Filtros por ubicación, precio, categoría y reputación.

## Arquitectura y Diseño del Sistema

El sistema está diseñado priorizando **escalabilidad horizontal**, **consistencia transaccional** y **aislamiento de dominios**.

* **Aislamiento Multi-Tenant:** Implementación de JSON Web Tokens (JWT) y RBAC para separar criptográficamente a Compradores y Proveedores.
* **Patrón Transactional Outbox & Event Streaming:** Delega cargas pesadas de I/O (cálculos PostGIS, pgvector, WebSockets para el chat) a workers asíncronos vía NATS JetStream. Esto mitiga los cuellos de botella en el hilo principal de Axum, previniendo bloqueos del event loop durante picos de tráfico.
* **Diseño Guiado por Dominio (DDD):** Nutype y SQLx previenen estados corruptos en memoria mediante verificación estricta de invariantes en tiempo de compilación.

## Tecnologías Utilizadas

* **Frontend:** Vue 3 (Composition API), TypeScript, Pinia, Vue Router, Zod, Vite, HTML5, CSS3.
* **API Core:** Rust, Axum, Serde, Utoipa.
* **Persistencia:** PostgreSQL, PostGIS, pgvector, SQLx, Nutype.
* **Infraestructura:** Podman, Compose, Caddy, Alpine Linux.
* **Seguridad:** Argon2 (hashing criptográfico).

## Compatibilidad y Entorno de Ejecución

> **Restricción de Entorno:** Diseño y optimización nativa para **Linux**. Ejecución orquestada obligatoriamente con **Podman + Compose** (rootless daemonless). Gestión de tareas mediante **Justfile**.
> **Entornos Windows:** Ejecución soportada pero **estrictamente recomendada a través de WSL (Windows Subsystem for Linux)**. Windows nativo carece de las dependencias Bash requeridas para interpretar las recetas de compilación.

* **Requisitos del Host:** Podman, Podman Compose, Just, SQLx CLI, Node.js (v18+ LTS) y npm.

---

## Instalación y Ejecución (Tutorial de Desarrollo)

### Backend e Infraestructura

**1. Variables de Entorno**
Duplicar `.example.env` y poblar credenciales (PostgreSQL, SMTP, S3) para la inyección de infraestructura del orquestador.
```bash
cp .example.env .env

```

**2. Claves Criptográficas**
Generación de llaves ED25519 para emisión y validación de JWT.

```bash
just bootstrap-keys

```

**3. Sincronización SQLx (Desarrollo)**
Validación de metadata SQL contra el esquema activo para seguridad de tipos en compilación.

```bash
just prepare-sqlx

```

**4. Compilación de Imágenes OCI (Developer Build)**
Construcción de binarios Rust y empaquetado de contenedores en **modo debug** orientado al entorno de desarrollo local.

```bash
CONTAINER_ENGINE=podman just build-all-debug

```

**5. Despliegue de Infraestructura**
Orquestación de topología completa e inicialización de volúmenes (PostgreSQL, NATS, RustFS, API, Workers, Proxy).

```bash
podman compose up

```

---

### Frontend

> **Requisito:** Node.js (LTS) instalado en el host para ejecutar el servidor de desarrollo Vite y gestionar paquetes vía `npm`.

**1. Variables de Entorno**
Acceder al directorio del submódulo, duplicar el archivo `.example.env` y configurar la URL base del backend:

```bash
cd mercanto-frontend
cp .example.env .env

```

**2. Instalación de Dependencias**
Instalar los paquetes del proyecto vía npm:

```bash
npm install

```

**3. Ejecución del Servidor de Desarrollo**
Iniciar el servidor local con HMR (Hot Module Replacement):

```bash
npm run dev

```
