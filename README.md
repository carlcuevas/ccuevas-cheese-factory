# 🧀 The Cheese Factory Infrastructure (v3)

**Autor:** Carl Cuevas (`@carlcuevas`)  
**Asignatura:** AUY1103 - Infraestructura como Código  
**Estado:** ✅ Finalizado

---

## 📋 Descripción del Proyecto

Este repositorio contiene la infraestructura como código (IaC) profesionalizada para el despliegue de la aplicación web "The Cheese Factory" en AWS.

El proyecto ha sido refactorizado desde su versión original para cumplir con estándares de la industria, implementando:
- **Estado Remoto:** Gestión del estado de Terraform en S3 con bloqueo de escritura mediante DynamoDB.
- **Arquitectura Modular:** Uso de módulos oficiales (`terraform-aws-modules`) para VPC y S3.
- **Seguridad:** Implementación de "Security Groups" bajo el principio de mínimo privilegio y subredes privadas para la capa de cómputo.
- **Alta Disponibilidad:** Despliegue en múltiples zonas de disponibilidad (AZs).

---

## 🏗 Arquitectura

El proyecto se divide en dos fases lógicas para garantizar un ciclo de vida limpio:

### 1. Bootstrap (`s3-backend-bootstrap/`)
Encargado de preparar el "terreno" para Terraform.
- **Recursos:** Bucket S3 (con versionamiento y encriptación) + Tabla DynamoDB (LockID).
- **Propósito:** Almacenar el archivo `terraform.tfstate` de forma segura y remota.

### 2. Infraestructura Principal (`the-cheese-factory/`)
Contiene la lógica de negocio y la red.
- **VPC:** Red personalizada con 3 subredes públicas y 3 privadas.
- **ALB:** Balanceador de carga público (Internet Facing) escuchando en puerto 80.
- **EC2:** Instancias web inaccesibles directamente desde internet (solo a través del ALB).
- **Auto-configuración:** Scripts de `user_data` para despliegue automático del servicio web.

---

## 📂 Estructura del Repositorio

```text
ccuevas-cheese-factory/
├── README.md                   # Documentación principal
├── .gitignore                  # Exclusión de archivos sensibles y temporales
├── s3-backend-bootstrap/       # FASE 1: Configuración del Backend
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── the-cheese-factory/         # FASE 2: Infraestructura de la aplicación
    ├── vpc.tf                  # Definición de red
    ├── ec2.tf                  # Servidores Web
    ├── alb.tf                  # Balanceador de Carga
    ├── security.tf             # Grupos de Seguridad (Firewalls)
    ├── variables.tf            # Definiciones de variables
    ├── terraform.tfvars.example # Plantilla de variables
    └── providers.tf            # Configuración de AWS y Backend S3
