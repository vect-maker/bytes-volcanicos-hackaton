# Mercanto

Plataforma B2B de comercio mayorista diseñada para descentralizar y digitalizar la cadena de suministro en Nicaragua. Conecta a importadores y mayoristas con MIPYMES regionales, eliminando la fricción logística y la asimetría de información en el abastecimiento comercial.

---

## 📋 Descripción General

Mercanto transforma las dinámicas del comercio mayorista tradicional mediante una plataforma distribuida que ofrece:

* **Catálogo Mayorista con Precios Escalonados:** Permite a los distribuidores configurar precios por volumen, ofertas promocionales y disponibilidad de inventario en tiempo real.
* **Negociación y Cotizaciones (RFQ):** Flujo formal de solicitud de cotizaciones, contraofertas, generación automática de proformas/facturas en PDF y conversión a órdenes de compra.
* **Búsqueda Inteligente Multimodal:** Motor de búsqueda en dos etapas que combina filtros tradicionales estructurados con búsqueda semántica e inversa por imágenes impulsada por el modelo de visión **CLIP** y distancias vectoriales en **pgvector**.
* **Geolocalización Comercial y Cobertura:** Cálculo geoespacial con **PostGIS** de cobertura departamental y distancias para optimizar rutas de entrega y cálculo de fletes.
* **Billetera Digital B2B:** Sistema de libro contable (*ledger*) para gestión de saldos comerciales, transferencias entre cuentas, depósitos y retiros.
* **Mensajería en Tiempo Real:** Canales directos de chat WebSocket entre compradores y proveedores respaldados por NATS JetStream.

### 📁 Organización del Repositorio (Monorepo)

El proyecto está estructurado como un monorepo que integra dos subsistemas independientes:

* 🦀 **[Backend (`./backend`)](backend/README.md):** Sistema distribuido de alto rendimiento en Rust (Axum), arquitectura asíncrona con *Transactional Outbox*, workers de eventos (NATS JetStream), worker de Machine Learning (CLIP / pgvector), persistencia geoespacial (PostGIS) y almacenamiento S3 (RustFS).
* ⚡ **[Frontend (`./frontend`)](frontend/README.md):** Cliente web SPA en Vue 3 (Composition API), Vite, TypeScript, Tailwind CSS, Pinia para gestión de estado y mapas geoespaciales interactivos con Leaflet.

---

## 🛠️ Stack de Tecnologías

El sistema implementa tecnologías modernas seleccionadas por su confiabilidad, rendimiento y verificación estricta de tipos:

| Categoría | Tecnologías | Descripción y Rol |
| :--- | :--- | :--- |
| **Backend & Runtime** | **Rust (Edición 2021)**, **Axum 0.8**, **Tokio**, **Tower** | Framework asíncrono de alto rendimiento, concurrencia segura y tipado estricto. |
| **Bases de Datos** | **PostgreSQL 16**, **PostGIS**, **pgvector**, **SQLx** | Persistencia relacional ACID, cálculos geoespaciales y almacenamiento de embeddings vectoriales con consultas verificadas en tiempo de compilación. |
| **Streaming & Eventos** | **NATS JetStream 2.12**, **Transactional Outbox** | Bus de mensajería asíncrona de alto rendimiento, persistencia de streams y patrón outbox para entrega garantizada *at-least-once*. |
| **Inteligencia Artificial (ML)** | **CLIP (ViT-B/32)**, **Safetensors (HuggingFace)** | Generación de embeddings vectoriales (512 dimensiones) para búsqueda semántica e inversa por imagen de productos. |
| **Almacenamiento de Objetos** | **RustFS (API S3 Compatible)** | Servidor de almacenamiento de archivos estáticos (imágenes de catálogo, logotipos, comprobantes y facturas PDF). |
| **Seguridad & Criptografía** | **JWT con ED25519**, **Argon2id**, **Nutype** | Autenticación asimétrica basada en firmas criptográficas, hash seguro de contraseñas y validación exhaustiva de invariantes de dominio. |
| **Frontend Web** | **Vue 3**, **Vite**, **TypeScript**, **Tailwind CSS** | Arquitectura Single Page Application reactiva con Composition API (`<script setup>`) y tipado estricto (`vue-tsc`). |
| **Gestión de Estado & UI** | **Pinia**, **Vue Router**, **Leaflet** | Manejo de estado global reactivo, enrutamiento con guardias de navegación y visualización de mapas departamentales. |
| **Infraestructura & Gateway** | **Caddy 2.9**, **Scalar**, **Alpine Linux** | Reverse proxy con soporte TLS/HTTPS, CORS para S3, y renderizador interactivo de documentación OpenAPI 3.1. |
| **Contenedores & Automatización** | **Podman / Docker**, **Podman Compose**, **Just**, **Zellij** | Empaquetado OCI reproducible, orquestación multicontenedor, automatización de tareas y multiplexación de entorno de desarrollo. |

---

## 🏛️ Arquitectura Global del Sistema

```mermaid
flowchart TD
    subgraph Client ["Cliente"]
        Frontend["Frontend SPA<br/>Vue 3 + TypeScript + Pinia + Vite"]
    end

    subgraph Gateway ["Puerta de Enlace"]
        Caddy["Caddy Reverse Proxy<br/>:8443 TLS / :8080 HTTP / :9000 S3 Proxy"]
    end

    subgraph CoreServices ["Servicios Principales"]
        API["Core API (Axum / Rust)<br/>Auth ED25519 & Nutype"]
        Scalar["Scalar API Docs (:8030)"]
        RustFS[("RustFS<br/>S3-Compatible Object Storage")]
    end

    subgraph DataPlane ["Persistencia y Mensajería"]
        DB[("PostgreSQL 16<br/>PostGIS & pgvector")]
        NATS{{"NATS JetStream<br/>Event Bus & Stream Engine"}}
    end

    subgraph Workers ["Workers Asíncronos"]
        Worker["Transactional Worker<br/>Outbox Consumer, SMTP & PDF"]
        MLWorker["ML Worker<br/>Embeddings CLIP & Búsqueda Visual"]
    end

    Frontend -->|"HTTPS / WSS (:8443)"| Caddy
    Caddy -->|"Proxy /api"| API
    Caddy -->|"Proxy /storage"| RustFS
    API -.->|"OpenAPI Specs"| Scalar

    API -->|"Transacciones & Outbox"| DB
    API -->|"Almacenamiento Archivos"| RustFS

    Worker -->|"Consume Outbox Events"| DB
    Worker -->|"Publica Eventos"| NATS
    NATS -->|"Suscripción a Eventos"| MLWorker
    MLWorker -->|"Indexa Vectores"| DB
    MLWorker -->|"Lee / Escribe Objetos"| RustFS
```

---

## 🛠️ Requisitos Previos

* **Sistema Operativo:** Optimizado para **Linux** (ej. Fedora, Ubuntu, Arch, Debian). En Windows se recomienda **WSL2**.
* **Motor de Contenedores:** [Podman](https://podman.io/) con [Podman Compose](https://github.com/containers/podman-compose) (o Docker con Docker Compose).
* **Gestor de Tareas:** [Just](https://github.com/casey/just) (v1.14 o superior).
* **Node.js:** v18+ LTS (v20 o v22 recomendado) y `npm`.
* **Herramientas Opcionales:**
  * [Zellij](https://zellij.dev/) para el entorno de desarrollo multiventana integrado.
  * [sqlx-cli](https://crates.io/crates/sqlx-cli) (`cargo install sqlx-cli --features rustls`) para gestión directa de migraciones en el host.

---

## 🚀 Instrucciones Básicas de Instalación y Ejecución

Sigue estos pasos ordenados para inicializar, compilar y ejecutar todo el ecosistema Mercanto:

### 1. Clonar el repositorio con submódulos
```bash
git clone --recurse-submodules https://github.com/vect-maker/bytes-volcanicos-hackaton.git
cd bytes-volcanicos-hackaton
```

### 2. Configurar variables de entorno
Copia los archivos de ejemplo en backend y frontend:
```bash
cp backend/.example.env backend/.env
cp frontend/.env.example frontend/.env
```

### 3. Inicialización Automática del Proyecto
Ejecuta la receta de preparación que genera las claves criptográficas asimétricas ED25519, descarga el modelo de Machine Learning (CLIP) e instala las dependencias de Node.js:
```bash
just setup
```
*(Nota: Esto creará las claves en `backend/keys/`, descargará el modelo en `backend/data/models/clip.safetensors` e instalará los paquetes en `frontend/node_modules/`)*.

### 4. Compilación de Contenedores
Compila las imágenes OCI del backend (servidor, workers y provisionador) y la imagen del frontend:
```bash
just build
```

### 5. Inicializar Base de Datos y Aplicar Migraciones
Levanta el contenedor de PostgreSQL y aplica las migraciones del esquema relacional:
```bash
# Iniciar Postgres en segundo plano
podman compose -f backend/compose.yml up -d postgres

# Aplicar las migraciones con Just
just backend migrate
```

### 6. Cargar Datos de Demostración (Seeders)
Puebla la base de datos con la geografía de Nicaragua, categorías de productos, cuentas de prueba, organizaciones comerciales, inventario y cotizaciones:
```bash
just backend provision-all
```

---

### 7. Ejecución de la Plataforma

Puedes ejecutar la plataforma de dos formas:

#### Opción A: Entorno Integrado con Zellij (Recomendado)
Abre un espacio de trabajo completo con pestañas para Frontend, Backend, Monitoreo de recursos (`htop` + `podman stats`) y Logs en vivo:
```bash
just dev
```

#### Opción B: Ejecución Estándar por Servicios
Si prefieres terminales independientes o no utilizas Zellij:

```bash
# Terminal 1: Iniciar todos los servicios del backend
cd backend
podman compose up

# Terminal 2: Iniciar el servidor de desarrollo del frontend
cd frontend
npm run dev
# (o mediante contenedor: just frontend dev)
```

---

## 🌐 Topología de Red y Puntos de Acceso

La arquitectura separa estrictamente los servicios expuestos a la máquina anfitriona (*host*) de los servicios privados que operan de forma exclusiva dentro de la red interna de Podman/Docker (`mercanto_default`):

### 1. Puntos de Acceso Expuestos al Host (Públicos)

| Servicio | URL / Puerto | Protocolo | Descripción |
| :--- | :--- | :--- | :--- |
| **Frontend Web (Dev)** | `http://localhost:5173` | HTTP | Interfaz SPA de usuario servida por Vite con HMR |
| **Frontend Web (Prod)** | `http://localhost:3000` | HTTP | Servidor estático optimizado con Nginx Alpine |
| **API Gateway Principal (Caddy)** | `https://localhost:8443` | HTTPS / WSS | Puerta de enlace segura con TLS; enruta tráfico al backend y WebSockets |
| **API Gateway Alternativo (Caddy)** | `http://localhost:8080` | HTTP | Puerto HTTP de Caddy (proxy inverso hacia `api:8080` interno) |
| **RustFS S3 Gateway (Caddy)** | `https://localhost:9000` | HTTPS | Proxy inverso de Caddy hacia RustFS con cabeceras CORS para subida de archivos |
| **Scalar API Reference** | `http://localhost:8030` | HTTP | Interfaz interactiva de documentación OpenAPI 3.1 |
| **RustFS Console (S3 UI)** | `http://localhost:9001` | HTTP | Consola web administrativa para gestión de buckets y objetos S3 |
| **PostgreSQL 16** | `localhost:5432` | TCP | Expuesto para herramientas de administración y migraciones (`sqlx-cli`) |
| **NATS JetStream (Dev)** | `localhost:4222` | TCP | Conexiones de clientes NATS locales |
| **NATS Monitoring (Dev)** | `http://localhost:8222` | HTTP | Dashboard de métricas y streams de NATS |

### 2. Servicios Privados (Red Interna de Podman / Sin Puertos al Host)

| Servicio Interno | Hostname Interno | Rol y Comunicación en la Red |
| :--- | :--- | :--- |
| **API Core (`mercanto-server`)** | `http://api:8080` | **No expone puertos directamente al host.** Todo el tráfico externo entra a través de Caddy. |
| **Object Storage API (`rustfs`)** | `http://rustfs:9000` | API S3 nativa utilizada internamente por el servidor y los workers. Accesible desde el frontend solo a través del proxy CORS de Caddy en el puerto 9000. |
| **Transactional Worker (`worker`)** | N/A (Headless) | Procesa outbox, genera miniaturas de imágenes y despacha correos/PDF. Solo conecta a `postgres:5432`, `nats:4222` y `rustfs:9000`. |
| **ML Worker (`ml_worker`)** | N/A (Headless) | Calcula embeddings con CLIP. Se comunica exclusivamente mediante NATS y RustFS S3. |
| **Provisioner (`provisioner`)** | N/A (CLI) | Contenedor de ejecución por lotes para poblar datos iniciales vía conexión interna a `postgres:5432`. |

---

## 🧭 Catálogo de Recetas `just`

El `justfile` raíz centraliza las operaciones del monorepo mediante el soporte de módulos:

| Comando | Descripción |
| :--- | :--- |
| `just setup` | Genera claves ED25519, descarga el modelo CLIP e instala dependencias de frontend. |
| `just build` | Compila las imágenes OCI de depuración del backend y la imagen del frontend. |
| `just check` | Ejecuta la verificación estática de tipos en el frontend (`vue-tsc`). |
| `just dev` | Inicia el entorno de desarrollo multiventana integrado en Zellij. |
| `just backend <receta>` | Ejecuta directamente cualquier tarea del backend (ej. `just backend migrate`, `just backend provision-all`). |
| `just frontend <receta>` | Ejecuta directamente cualquier tarea del frontend (ej. `just frontend dev`, `just frontend build-image`). |

Para consultar la documentación específica de cada subsistema:
* 📖 [Documentación Técnica del Backend](backend/README.md)
* 📖 [Documentación Técnica del Frontend](frontend/README.md)
* 🏛️ [Arquitectura Detallada del Sistema](backend/docs/arquitectura.md)
