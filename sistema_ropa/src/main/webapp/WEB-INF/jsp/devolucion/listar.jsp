<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
            <div class="container-fluid">

                <!-- Mensajes -->
                <c:if test="${not empty mensaje}">
                    <div class="alert alert-success alert-dismissible fade show mt-3" role="alert">
                        ${mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show mt-3" role="alert">
                        ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Header -->
                <div class="d-sm-flex align-items-center justify-content-between mb-4 mt-4">
                    <h1 class="h3 mb-0 text-gray-800">🔄 Devoluciones</h1>
                    <a href="${pageContext.request.contextPath}/devoluciones/buscar"
                       class="btn btn-warning">
                        <i class="fas fa-plus"></i> Nueva Devolución
                    </a>
                </div>

                <!-- Card principal -->
                <div class="card shadow mb-4">

                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">
                            Listado de Devoluciones
                        </h6>
                    </div>

                    <div class="card-body">

                        <!-- Barra de búsqueda y filtros -->
                        <div class="d-flex justify-content-between align-items-center mb-4">

                            <!-- Buscador -->
                            <div style="max-width: 350px; width: 100%;">
                                <input type="text"
                                       id="searchInput"
                                       class="form-control"
                                       placeholder="🔍 Buscar por código, cliente o producto...">
                            </div>

                            <!-- Filtros por estado -->
                            <div class="btn-group" role="group">
                                <a href="${pageContext.request.contextPath}/devoluciones"
                                   class="btn btn-sm ${empty filtroEstado ? 'btn-dark' : 'btn-outline-dark'}">
                                    📊 Todas
                                </a>
                                <a href="${pageContext.request.contextPath}/devoluciones?estado=PENDIENTE"
                                   class="btn btn-sm ${filtroEstado == 'PENDIENTE' ? 'btn-warning' : 'btn-outline-warning'}">
                                    ⏳ Pendientes
                                </a>
                                <a href="${pageContext.request.contextPath}/devoluciones?estado=APROBADA"
                                   class="btn btn-sm ${filtroEstado == 'APROBADA' ? 'btn-success' : 'btn-outline-success'}">
                                    ✅ Aprobadas
                                </a>
                                <a href="${pageContext.request.contextPath}/devoluciones?estado=RECHAZADA"
                                   class="btn btn-sm ${filtroEstado == 'RECHAZADA' ? 'btn-danger' : 'btn-outline-danger'}">
                                    ❌ Rechazadas
                                </a>
                            </div>

                        </div>

                        <!-- Tabla -->
                        <div class="table-responsive">
                            <table id="dataTable" class="table table-bordered table-hover">
                                <thead class="table-dark">
                                <tr>
                                    <th style="width: 140px;">Código</th>
                                    <th style="width: 140px;">Venta</th>
                                    <th style="width: 130px;">Fecha</th>
                                    <th>Cliente</th>
                                    <th>Productos</th>
                                    <th class="text-end" style="width: 120px;">Total Devuelto</th>
                                    <th class="text-center" style="width: 120px;">Estado</th>
                                    <th class="text-center" style="width: 180px;">Acciones</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty devoluciones}">
                                        <c:forEach items="${devoluciones}" var="d">
                                            <tr>
                                                <td>
                                                    <strong class="text-warning">${d.codigo}</strong>
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/ventas/detalle/${d.venta.id}"
                                                       class="text-decoration-none">
                                                        ${d.venta.codigo}
                                                    </a>
                                                </td>
                                                <td>
                                                    <small>${fechasFormateadas[d.id]}</small>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${d.venta.cliente != null}">
                                                            <i class="fas fa-user text-muted"></i>
                                                            ${d.venta.cliente.nombre} ${d.venta.cliente.apellido}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fas fa-user-slash text-muted"></i>
                                                            <span class="text-muted">Consumidor Final</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <small>
                                                        <c:forEach items="${d.items}" var="item" varStatus="status">
                                                            ${item.ventaItem.productoTalle.producto.descripcion}
                                                            (T:${item.ventaItem.productoTalle.talle.nombre})
                                                            x${item.cantidadDevuelta}<c:if test="${!status.last}">, </c:if>
                                                        </c:forEach>
                                                    </small>
                                                </td>
                                                <td class="text-end">
                                                    <strong class="text-danger">
                                                        -$<fmt:formatNumber value="${d.totalDevuelto}" minFractionDigits="2"/>
                                                    </strong>
                                                </td>
                                                <td class="text-center">
                                                    <span class="badge
                                                        ${d.estado == 'PENDIENTE' ? 'bg-warning text-dark' :
                                                          d.estado == 'APROBADA' ? 'bg-success' : 'bg-danger'}">
                                                        ${d.estado}
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <div class="btn-group btn-group-sm" role="group">

                                                        <!-- VER DETALLE -->
                                                        <button type="button"
                                                                class="btn btn-info"
                                                                data-bs-toggle="modal"
                                                                data-bs-target="#modalDetalle${d.id}"
                                                                title="Ver detalle">
                                                            <i class="fas fa-eye"></i>
                                                        </button>

                                                        <!-- APROBAR (solo si está pendiente) -->
                                                        <c:if test="${d.estado == 'PENDIENTE'}">
                                                            <form method="POST"
                                                                  action="${pageContext.request.contextPath}/devoluciones/aprobar"
                                                                  style="display: inline;"
                                                                  onsubmit="return confirm('¿Aprobar esta devolución? Se devolverá el stock.')">
                                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                                <input type="hidden" name="id" value="${d.id}"/>
                                                                <button type="submit"
                                                                        class="btn btn-success"
                                                                        title="Aprobar">
                                                                    <i class="fas fa-check"></i>
                                                                </button>
                                                            </form>

                                                            <!-- RECHAZAR -->
                                                            <button type="button"
                                                                    class="btn btn-danger"
                                                                    data-bs-toggle="modal"
                                                                    data-bs-target="#modalRechazar${d.id}"
                                                                    title="Rechazar">
                                                                <i class="fas fa-times"></i>
                                                            </button>
                                                        </c:if>

                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8" class="text-center text-muted py-5">
                                                <i class="fas fa-inbox fa-3x mb-3 d-block text-muted opacity-50"></i>
                                                <p class="mb-0">No hay devoluciones registradas</p>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODALES (FUERA DE LA TABLA) -->
<!-- ========================================== -->
<c:forEach items="${devoluciones}" var="d">

    <!-- MODAL DETALLE -->
    <div class="modal fade" id="modalDetalle${d.id}" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title">Detalle de Devolución: ${d.codigo}</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Venta:</strong> ${d.venta.codigo}<br>
                            <strong>Fecha devolución:</strong> ${fechasFormateadas[d.id]}<br>
                            <strong>Motivo:</strong>
                            <c:choose>
                                <c:when test="${d.motivo == 'TALLE_INCORRECTO'}">Talle incorrecto</c:when>
                                <c:when test="${d.motivo == 'DEFECTO_FABRICA'}">Defecto de fábrica</c:when>
                                <c:when test="${d.motivo == 'NO_LE_GUSTO'}">No le gustó</c:when>
                                <c:when test="${d.motivo == 'CAMBIO_COLOR'}">Cambio de color</c:when>
                                <c:otherwise>Otro</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="col-md-6">
                            <strong>Cliente:</strong>
                            <c:choose>
                                <c:when test="${d.venta.cliente != null}">
                                    ${d.venta.cliente.nombre} ${d.venta.cliente.apellido}
                                </c:when>
                                <c:otherwise>Consumidor Final</c:otherwise>
                            </c:choose><br>
                            <strong>Estado:</strong>
                            <span class="badge
                                ${d.estado == 'PENDIENTE' ? 'bg-warning text-dark' :
                                  d.estado == 'APROBADA' ? 'bg-success' : 'bg-danger'}">
                                ${d.estado}
                            </span>
                        </div>
                    </div>

                    <c:if test="${not empty d.observaciones}">
                        <div class="alert alert-info">
                            <strong>Observaciones:</strong><br>
                            ${d.observaciones}
                        </div>
                    </c:if>

                    <h6 class="fw-bold mt-3">Productos devueltos:</h6>
                    <table class="table table-bordered table-sm">
                        <thead class="table-light">
                        <tr>
                            <th>Producto</th>
                            <th class="text-center">Cantidad</th>
                            <th class="text-end">Precio Unit.</th>
                            <th class="text-end">Subtotal</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${d.items}" var="item">
                            <tr>
                                <td>
                                    ${item.ventaItem.productoTalle.producto.descripcion}
                                    <br>
                                    <small class="text-muted">
                                        Talle: ${item.ventaItem.productoTalle.talle.nombre}
                                    </small>
                                </td>
                                <td class="text-center">${item.cantidadDevuelta}</td>
                                <td class="text-end">
                                    $<fmt:formatNumber value="${item.precioUnitario}" minFractionDigits="2"/>
                                </td>
                                <td class="text-end fw-semibold">
                                    $<fmt:formatNumber value="${item.subtotal}" minFractionDigits="2"/>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                        <tfoot class="table-secondary">
                        <tr>
                            <td colspan="3" class="text-end fw-bold">TOTAL:</td>
                            <td class="text-end fw-bold text-danger">
                                -$<fmt:formatNumber value="${d.totalDevuelto}" minFractionDigits="2"/>
                            </td>
                        </tr>
                        </tfoot>
                    </table>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL RECHAZAR -->
    <div class="modal fade" id="modalRechazar${d.id}" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST" action="${pageContext.request.contextPath}/devoluciones/rechazar">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <input type="hidden" name="id" value="${d.id}"/>

                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title">Rechazar Devolución</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>¿Está seguro que desea <strong>rechazar</strong> esta devolución?</p>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Motivo del rechazo *</label>
                            <textarea name="motivoRechazo"
                                      class="form-control"
                                      rows="3"
                                      placeholder="Explique por qué se rechaza la devolución..."
                                      required></textarea>
                        </div>

                        <div class="alert alert-warning">
                            <small>
                                <i class="fas fa-exclamation-triangle"></i>
                                Al rechazar, <strong>NO se devolverá el stock</strong> y la devolución quedará marcada como rechazada.
                            </small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-danger">❌ Rechazar Devolución</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</c:forEach>

<script>
document.getElementById('searchInput').addEventListener('keyup', function () {
    const filter = this.value.toLowerCase();
    const rows = document.querySelectorAll('#dataTable tbody tr');
    let visibleCount = 0;

    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        const shouldShow = text.includes(filter);

        row.style.display = shouldShow ? '' : 'none';
        if (shouldShow && !row.querySelector('td[colspan]')) {
            visibleCount++;
        }
    });
});
</script>

</body>
</html>