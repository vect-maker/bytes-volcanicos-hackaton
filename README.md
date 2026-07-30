
# Mercanto - Arquitectura del Sistema y Orquestación

Repositorio global para la orquestación de submódulos desacoplados.

### Referencias de Submódulos

* **[Submódulo Backend (`./mercanto-backend`)](https://github.com/vect-maker/mercanto)**: Repositorio activo. API central en Rust y workers.
* **[Submódulo Frontend (`./mercanto-frontend`)](https://github.com/doomii18/Mercanto_Front-end)**: Repositorio activo. Cliente híbrido JS/TS (Vite). *(Documentación pendiente)*.

---

## Descripción General

* **Aislamiento Multi-Tenant:** Implementación de JSON Web Tokens (JWT) y RBAC para separar criptográficamente a Compradores y Proveedores.
* **Patrón Transactional Outbox:** Delega cargas de I/O (cálculos PostGIS, pgvector, WebSockets) a workers asíncronos vía NATS JetStream, mitigando bloqueos en el hilo de Axum.
* **Diseño Guiado por Dominio (DDD):** Nutype y SQLx previenen estados corruptos en memoria mediante verificación estricta en tiempo de compilación.

## Tecnologías Utilizadas

* **Frontend:** React, JS/TS, Vite, HTML5, CSS3.
* **API Core:** Rust, Axum, Serde, Utoipa.
* **Persistencia:** PostgreSQL, PostGIS, pgvector, SQLx, Nutype.
* **Infraestructura:** Podman, Compose, Caddy, Alpine Linux.
* **Seguridad:** Argon2 (hashing criptográfico).

## Compatibilidad y Entorno de Ejecución

> **Restricción de Entorno:** Diseño y optimización nativa para **Linux**. Ejecución orquestada obligatoriamente con **Podman + Compose** (rootless daemonless). Gestión de tareas mediante **Justfile**.
> **Entornos Windows:** Ejecución soportada pero **estrictamente recomendada a través de WSL (Windows Subsystem for Linux)**. Windows nativo carece de las dependencias Bash requeridas para interpretar las recetas de compilación.

* **Requisitos del Host:** Podman, Podman Compose, Just, SQLx CLI.

## Instalación y Ejecución (Tutorial de Desarrollo)

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
