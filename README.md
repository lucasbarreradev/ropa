# Sistema de Gestión de Ropa

## 📑 Descripción
Aplicación web desarrollada con Spring Boot y JSP para la gestión de productos de indumentaria.

Permite administrar productos, talles, stock y proveedores mediante una arquitectura en capas y desplegada en contenedores Docker.

## ⚙️ Funcionalidades
- 👕 Gestión de productos
- 📏 Manejo de talles
- 📦 Control de stock por producto y talle
- 🏷 Asociación con proveedores
- 🔍 Búsqueda y filtrado de productos

## 🏗 Arquitectura
- **Controller** → Manejo de requests HTTP
- **Service** → Lógica de negocio
- **Repository** → Persistencia (Spring Data JPA)
- **View** → JSP + JSTL

## 🛠 Tecnologías
- Java 17
- Spring Boot
- Spring MVC
- Spring Data JPA
- JSP + JSTL
- SQL Server
- Docker
- Docker Compose

## 📦 Requisitos
- Docker
- Docker Compose

## 🚀 Ejecución con Docker

1. Clonar el repositorio
```bash
git clone <tu-repo>
cd <tu-carpeta>
```
2. Levantar el sistema
```bash
docker-compose up -d
```
3. Acceder a la aplicación
```bash
http://localhost:8081/
```

🗄 Base de datos

El sistema utiliza SQL Server corriendo en contenedor Docker.

📌 Estructura del proyecto
/controller → Controladores
/service → Lógica de negocio
/repository → Acceso a datos
/model → Entidades
/WEB-INF/jsp → Vistas JSP

⚠️ Notas
Asegurarse de que los puertos no estén en uso
Verificar variables de entorno en docker-compose.yml

✒️ Autor
Lucas Barrera
* [LinkedIn](https://www.linkedin.com/in/lucas-barrera-dev)
