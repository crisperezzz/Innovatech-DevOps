# Migración Lift & Shift - Innovatech Chile (AWS + Terraform)

Este repositorio contiene el código de Infraestructura como Código (IaC) para el despliegue automatizado de la arquitectura de Innovatech Chile en Amazon Web Services (AWS), utilizando Terraform.

## 📌 Contexto del Proyecto
Innovatech requiere modernizar su infraestructura local para soportar el crecimiento del negocio. La estrategia seleccionada es un modelo **Lift and Shift**, migrando la aplicación a una arquitectura de 3 capas en AWS sin reescribir el código fuente.

## 🏗️ Arquitectura Desplegada
El proyecto provisiona una topología de red aislada y segura bajo el principio de mínimo privilegio:
* **VPC:** Red privada virtual con direccionamiento `10.0.0.0/16`.
* **Subred Pública:** Aloja la instancia EC2 del Frontend (`10.0.1.0/24`) y el NAT Gateway.
* **Subred Privada:** Aloja las instancias EC2 del Backend y la Base de Datos (`10.0.2.0/24`), sin acceso directo desde Internet.
* **Seguridad:** Implementación de Security Groups en cascada.

## 🚀 Requisitos Previos
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) instalado localmente.
* Cuenta de AWS Academy (Learner Lab) activa.
* Credenciales efímeras configuradas en la terminal.

## ⚙️ Instrucciones de Despliegue

1. **Configurar Credenciales:**
   Configurar las variables de entorno temporales (AWS STS) en la terminal de PowerShell:
   ```powershell
   $Env:AWS_ACCESS_KEY_ID="TU_ACCESS_KEY"
   $Env:AWS_SECRET_ACCESS_KEY="TU_SECRET_KEY"
   $Env:AWS_SESSION_TOKEN="TU_SESSION_TOKEN"