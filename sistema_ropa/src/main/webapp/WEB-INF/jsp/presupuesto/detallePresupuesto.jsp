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

    <div class="container mt-4">

    <!-- MENSAJES -->
    <c:if test="${not empty mensaje}">
        <div class="alert alert-success">${mensaje}</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <c:if test="${not empty presupuesto}">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="mb-0">📋 Detalle de Presupuesto</h4>

            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/presupuestos/nuevo"
                   class="btn btn-primary btn-sm">
                    + Nuevo Presupuesto
                </a>
                <a href="${pageContext.request.contextPath}/presupuestos"
                   class="btn btn-outline-secondary btn-sm">
                    📋 Volver al listado
                </a>
            </div>
        </div>

        <div class="card">

            <!-- HEADER -->
            <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                <div class="fs-5 fw-bold">
                    ${presupuesto.codigo}
                </div>

                <div class="d-flex gap-2 align-items-center">
                    <span class="badge
                        ${presupuesto.estado == 'PENDIENTE' ? 'bg-warning text-dark' :
                          presupuesto.estado == 'APROBADO' ? 'bg-success' :
                          presupuesto.estado == 'VENDIDO' ? 'bg-info' : 'bg-danger'} fs-6">
                        ${presupuesto.estado}
                    </span>
                </div>
            </div>

            <!-- BODY -->
            <div class="card-body">

                <div class="row mb-3 pb-3 border-bottom">

                    <div class="col-md-3">
                        <div class="text-muted">Fecha</div>
                        <div class="small">
                            ${fechaPresupuestoFmt}
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="text-muted">Cliente</div>
                        <div class="small">
                            <c:choose>
                                <c:when test="${presupuesto.cliente != null}">
                                    ${presupuesto.cliente.nombre} ${presupuesto.cliente.apellido}
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Consumidor Final</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="text-muted">Forma de pago</div>
                        <div class="small">
                            <c:choose>
                                <c:when test="${not empty presupuesto.formaPago}">
                                    ${presupuesto.formaPago}
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="text-muted">Validez</div>
                        <div class="small text-warning">
                            ⏱️ 15 días desde emisión
                        </div>
                    </div>

                </div>

                <!-- ITEMS -->
                <table class="table table-hover table-striped">
                    <thead class="table-dark">
                    <tr>
                        <th>Producto</th>
                        <th class="text-center">Cantidad</th>
                        <th class="text-end">Precio Unit.</th>
                        <th class="text-center">Desc.</th>
                        <th class="text-end">Subtotal</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach items="${presupuesto.detalles}" var="detalle">
                        <tr>
                            <td>
                                <strong>${detalle.productoTalle.producto.descripcion}</strong>
                                <br>
                                <small class="text-muted">
                                    Talle: <span class="badge bg-secondary text-white">${detalle.productoTalle.talle.nombre}</span>
                                    <c:if test="${detalle.productoTalle.stock <= 5}">
                                        <span class="badge bg-danger ms-1 text-white">
                                            Stock bajo: ${detalle.productoTalle.stock}
                                        </span>
                                    </c:if>
                                </small>
                            </td>
                            <td class="text-center">${detalle.cantidad}</td>
                            <td class="text-end">
                                $<fmt:formatNumber value="${detalle.precioUnitario}" minFractionDigits="2"/>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${detalle.descuentoPct > 0}">
                                        ${detalle.descuentoPct}%
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end fw-semibold">
                                $<fmt:formatNumber value="${detalle.subtotal}" minFractionDigits="2"/>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>

                    <tfoot class="table-secondary">
                    <c:choose>
                        <c:when test="${presupuesto.cliente != null
                                       and presupuesto.cliente.condicionIva == 'RESPONSABLE_INSCRIPTO'}">

                            <tr>
                                <td colspan="4" class="text-end fw-bold">Neto</td>
                                <td class="text-end">
                                    $<fmt:formatNumber value="${totales.totalNeto}" minFractionDigits="2"/>
                                </td>
                            </tr>

                            <c:forEach var="entry" items="${totales.ivasMap}">
                                <tr>
                                    <td colspan="4" class="text-end fw-bold">
                                        IVA <c:out value="${entry.key}"/>%
                                    </td>
                                    <td class="text-end">
                                        $<fmt:formatNumber value="${entry.value}" minFractionDigits="2"/>
                                    </td>
                                </tr>
                            </c:forEach>

                            <tr>
                                <td colspan="4" class="text-end fw-bold fs-5">TOTAL</td>
                                <td class="text-end fw-bold fs-5 text-success">
                                    $<fmt:formatNumber value="${totales.total}" minFractionDigits="2"/>
                                </td>
                            </tr>

                        </c:when>

                        <c:otherwise>
                            <tr>
                                <td colspan="4" class="text-end fw-bold fs-5">TOTAL</td>
                                <td class="text-end fw-bold fs-5 text-success">
                                    $<fmt:formatNumber value="${presupuesto.total}" minFractionDigits="2"/>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tfoot>
                </table>

                <!-- ACCIONES SEGÚN ESTADO -->
                <div class="mt-3 d-flex gap-2">

                    <!-- SI ESTÁ PENDIENTE -->
                    <c:if test="${presupuesto.estado == 'PENDIENTE'}">

                        <!-- APROBAR Y GENERAR VENTA -->
                        <form action="${pageContext.request.contextPath}/presupuestos/aprobar"
                              method="post"
                              class="d-inline"
                              onsubmit="return confirm('¿Aprobar este presupuesto y generar la venta?')">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <input type="hidden" name="id" value="${presupuesto.id}"/>
                            <button type="submit" class="btn btn-success">
                                ✅ Aprobar y generar venta
                            </button>
                        </form>

                        <!-- RECHAZAR -->
                        <form action="${pageContext.request.contextPath}/presupuestos/rechazar"
                              method="post"
                              class="d-inline"
                              onsubmit="return confirm('¿Rechazar este presupuesto?')">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <input type="hidden" name="id" value="${presupuesto.id}"/>
                            <button type="submit" class="btn btn-outline-danger">
                                ❌ Rechazar
                            </button>
                        </form>



                        <!-- DESCARGAR PDF -->
                        <a href="${pageContext.request.contextPath}/presupuestos/${presupuesto.id}/pdf"
                           class="btn btn-outline-secondary"
                           target="_blank">
                            📄 Descargar PDF
                        </a>

                    </c:if>

                    <!-- SI ESTÁ APROBADO/VENDIDO -->
                    <c:if test="${presupuesto.estado == 'APROBADO' or presupuesto.estado == 'VENDIDO'}">
                        <div class="alert alert-success mb-0">
                            ✅ Este presupuesto ya fue aprobado y convertido en venta.
                        </div>
                    </c:if>

                    <!-- SI ESTÁ RECHAZADO -->
                    <c:if test="${presupuesto.estado == 'RECHAZADO'}">
                        <div class="alert alert-danger mb-0">
                            ❌ Este presupuesto fue rechazado.
                        </div>
                    </c:if>

                </div>

                <!-- ADVERTENCIAS DE STOCK -->
                <c:set var="hayStockBajo" value="false"/>
                <c:forEach items="${presupuesto.detalles}" var="detalle">
                    <c:if test="${detalle.cantidad > detalle.productoTalle.stock}">
                        <c:set var="hayStockBajo" value="true"/>
                    </c:if>
                </c:forEach>

                <c:if test="${hayStockBajo and presupuesto.estado == 'PENDIENTE'}">
                    <div class="alert alert-warning mt-3">
                        <strong>⚠️ Atención:</strong> Algunos productos tienen stock insuficiente para cumplir con las cantidades solicitadas.
                    </div>
                </c:if>

            </div>
        </div>

    </c:if>

    </div>

</div>

<!-- Footer -->
<footer class="sticky-footer bg-white">
    <div class="container my-auto">
        <div class="copyright text-center my-auto">
            <span>Copyright &copy; Sistema de Gestión</span>
        </div>
    </div>
</footer>

</body>
</html>