<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <jsp:include page="/WEB-INF/jsp/head.jsp"/>
</head>

<body id="page-top">
<div id="wrapper">
    <jsp:include page="/WEB-INF/jsp/nav_bar.jsp"/>

    <div id="content-wrapper" class="d-flex flex-column">
        <div id="content">
            <div class="container-fluid mt-4">

                <c:if test="${not empty mensaje}">
                    <div class="alert alert-success">${mensaje}</div>
                </c:if>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">👕 Productos</h4>
                    <a href="${pageContext.request.contextPath}/productos/nuevo"
                       class="btn btn-primary">
                        ➕ Nuevo Producto
                    </a>
                </div>

                <div class="card shadow mb-4">

                                    <div class="card-header py-3">
                                        <h6 class="m-0 font-weight-bold text-primary">
                                            Listado de Productos
                                        </h6>
                                    </div>
                                    <div class="d-sm-flex align-items-center m-4">
                                        <div class="ms-auto" style="max-width: 300px;">
                                            <input type="text" id="searchInput"
                                                   class="form-control"
                                                   placeholder="Buscar producto...">
                                        </div>
                                    </div>

                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover" id="dataTable">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Producto</th>
                                        <th>Talles</th>
                                        <th>Stock Total</th>
                                        <th>Precio Desde</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${productos}" var="p">
                                        <tr>
                                            <td>
                                                <strong>${p.descripcion}</strong>
                                            </td>
                                            <td>
                                                <c:forEach items="${p.talles}" var="tp">
                                                    <span class="badge bg-secondary text-white fs-6">
                                                        ${tp.talle.nombre}
                                                    </span>
                                                </c:forEach>
                                                <c:if test="${empty p.talles}">
                                                    <small class="text-warning">Sin talles</small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="badge ${p.stockTotal <= 5 ? 'bg-danger text-white' :
                                                                    p.stockTotal <= 20 ? 'bg-warning text-dark' :
                                                                    'bg-success text-white'}">
                                                    ${p.stockTotal}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty p.talles}">
                                                        $${p.precioDesde}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <small class="text-muted">-</small>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/productos/${p.id}/talles"
                                                   class="btn btn-sm btn-primary"
                                                   title="Gestionar talles">
                                                    📏 Talles
                                                </a>
                                                                                            <a class="btn btn-sm btn-warning"
                                                                                               href="${pageContext.request.contextPath}/productos/editar/${p.id}"
                                                                                               title="Editar producto">
                                                                                                ✏️ Editar
                                                                                            </a>
                                                <form method="POST"
                                                      action="${pageContext.request.contextPath}/productos/eliminar/${p.id}"
                                                      style="display:inline">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                    <button type="submit"
                                                            class="btn btn-sm btn-danger"
                                                            onclick="return confirm('¿Eliminar producto y todos sus talles?')">
                                                        🗑️
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>


    </div>
</div>
<script>
                                    document.getElementById('searchInput').addEventListener('keyup', function () {
                                        const filter = this.value.toLowerCase();
                                        const rows = document.querySelectorAll('#dataTable tbody tr');

                                        rows.forEach(row => {
                                            row.style.display = row.textContent.toLowerCase().includes(filter)
                                                ? ''
                                                : 'none';
                                        });
                                    });
                                    </script>
</body>
</html>