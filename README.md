# RetailMax – Lab 7 Visualización de Datos
**CC3088 – Bases de Datos 1 | UVG | Ciclo 1, 2026**  
**Área asignada:** Área 3 – Finanzas  
**Grupo:** 3

---

## 📁 Estructura del repositorio

```
retailmax/
├── docker-compose.yml          # Orquestación PostgreSQL + Metabase
├── init-scripts/
│   ├── 00_create_metabase_db.sql   # Crea la DB interna de Metabase
│   ├── 01_DDL.sql                  # Esquema de RetailMax
│   └── 02_DATA.sql                 # Datos de RetailMax
├── metabase-data/              # Volumen persistido con el dashboard ya construido
├── informe.pdf                 # Documentación de los 12+ indicadores
└── README.md
```

---

## 🚀 Cómo levantar el proyecto

### Requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo
- Git

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/retailmax-lab7.git
cd retailmax-lab7

# 2. Copiar los archivos SQL al directorio de init (si no están ya)
#    DDL.sql  → init-scripts/01_DDL.sql
#    DATA.sql → init-scripts/02_DATA.sql

# 3. Levantar todo
docker compose up
```

> ⏳ La primera vez tarda ~2-3 minutos mientras Metabase inicializa.

### 4. Acceder a Metabase
Abrir en el navegador: **http://localhost:3000**

**Credenciales de calificación:**
| Campo | Valor |
|-------|-------|
| Correo | `calificar@uvg.edu.gt` |
| Contraseña | `secret123+` |

El dashboard **RetailMax – Finanzas** debe aparecer ya construido en la sección "Nuestro análisis".

---

## 📊 Dashboard

El dashboard está organizado en 2 tabs:

| Tab | Enfoque |
|-----|---------|
| **Rentabilidad y Márgenes** | Análisis de ingresos, costos, márgenes brutos por producto/categoría/tienda |
| **Pagos y Reembolsos** | Métodos de pago, comportamiento de reembolsos, impacto financiero de devoluciones |

---

## 🎥 Video de presentación

🔗 [Enlace al video – YouTube no listado / Google Drive](#)  
_(Actualizar este enlace antes de la entrega)_

---

## 👥 Integrantes

| Nombre | Carné |
|--------|-------|
| | |
| | |
| | |
| | |
| | |
