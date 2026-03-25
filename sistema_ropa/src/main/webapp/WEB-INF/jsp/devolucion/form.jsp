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

<div class="container-fluid mt-4">

    <!-- MENSAJES -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show">
            ${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row">

        <!-- IZQUIERDA - PRODUCTOS A DEVOLVER -->
        <div class="col-lg-8">
            <div class="card shadow">
                <div class="card-header bg-warning text-dark">
                    <h5 class="mb-0">🔄 Seleccionar productos a devolver</h5>
                </div>
                <div class="card-body">

                    <form method="POST" action="${pageContext.request.contextPath}/devoluciones/guardar"
                          onsubmit="return validarDevolucion()">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <input type="hidden" name="ventaId" value="${venta.id}"/>

                        <!-- TABLA DE PRODUCTOS -->
                        <div class="table-responsive">
                            <table class="table table-bordered">
                                <thead class="table-dark">
                                <tr>
                                    <th style="width: 60px;">Devolver</th>
                                    <th>Producto</th>
                                    <th class="text-center">Vendido</th>
                                    <th class="text-center">Ya devuelto</th>
                                    <th class="text-center">Disponible</th>
                                    <th class="text-center">Cantidad a devolver</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach items="${venta.items}" var="item" varStatus="status">
                                    <c:set var="disponible" value="${item.cantidad - item.cantidadDevuelta}"/>

                                    <tr id="row-${item.id}">
                                        <td class="text-center">
                                            <c:if test="${disponible > 0}">
                                                <input type="checkbox"
                                                       class="form-check-input item-checkbox"
                                                       id="checkbox-${item.id}"
                                                       data-item-id="${item.id}"
                                                       data-max="${disponible}"
                                                       onchange="toggleCantidad(${item.id}, ${disponible})">
                                            </c:if>
                                            <c:if test="${disponible == 0}">
                                                <span class="text-muted">-</span>
                                            </c:if>
                                        </td>

                                        <td>
                                            <strong>${item.productoTalle.producto.descripcion}</strong>
                                            <br>
                                            <small class="text-muted">
                                                Talle: ${item.productoTalle.talle.nombre}
                                            </small>
                                        </td>

                                        <td class="text-center">${item.cantidad}</td>

                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.cantidadDevuelta > 0}">
                                                    <span class="badge bg-danger">${item.cantidadDevuelta}</span>
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${disponible > 0}">
                                                    <strong class="text-success">${disponible}</strong>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-danger">0</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-center">
                                            <c:if test="${disponible > 0}">
                                                <input type="number"
                                                       name="cantidades"
                                                       id="cantidad-${item.id}"
                                                       class="form-control form-control-sm text-center cantidad-input"
                                                       min="1"
                                                       max="${disponible}"
                                                       value="1"
                                                       disabled
                                                       style="width: 80px; display: inline-block;">
                                                <input type="hidden"
                                                       name="ventaItemIds"
                                                       id="hidden-${item.id}"
                                                       value="${item.id}"
                                                       disabled>
                                            </c:if>
                                            <c:if test="${disponible == 0}">
                                                <span class="text-muted">-</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <!-- MOTIVO -->
                        <div class="row mt-4">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Motivo de la devolución *</label>
                                <select name="motivo" class="form-select" required>
                                    <option value="" disabled selected>-- Seleccionar motivo --</option>
                                    <option value="TALLE_INCORRECTO">Talle incorrecto</option>
                                    <option value="DEFECTO_FABRICA">Defecto de fábrica</option>
                                    <option value="NO_LE_GUSTO">No le gustó</option>
                                    <option value="CAMBIO_COLOR">Cambio de color</option>
                                    <option value="OTRO">Otro</option>
                                </select>
                            </div>
                        </div>

                        <!-- OBSERVACIONES -->
                        <div class="row mt-3">
                            <div class="col-md-12">
                                <label class="form-label fw-semibold">Observaciones (opcional)</label>
                                <textarea name="observaciones"
                                          class="form-control"
                                          rows="3"
                                          placeholder="Detalles adicionales sobre la devolución..."></textarea>
                            </div>
                        </div>

                        <!-- BOTONES -->
                        <div class="mt-4">
                            <button type="submit" class="btn btn-warning btn-lg"
                            onclick="this.disabled=true; this.form.submit();">
                                ✅ Crear Devolución
                            </button>
                            <a href="${pageContext.request.contextPath}/devoluciones/buscar"
                               class="btn btn-outline-secondary btn-lg">
                                ← Cancelar
                            </a>
                        </div>

                    </form>

                </div>
            </div>
        </div>

        <!-- DERECHA - INFO DE LA VENTA -->
        <div class="col-lg-4">
            <div class="card shadow mb-3">
                <div class="card-header bg-dark text-white">
                    <h6 class="mb-0">📋 Información de la venta</h6>
                </div>
                <div class="card-body">
                    <p class="mb-2">
                        <strong>Ticket:</strong><br>
                        <code class="fs-6">${venta.codigo}</code>
                    </p>
                    <p class="mb-2">
                        <strong>Fecha:</strong><br>
                        ${fechaVentaFmt}
                    </p>
                    <p class="mb-2">
                        <strong>Cliente:</strong><br>
                        <c:choose>
                            <c:when test="${venta.cliente != null}">
                                ${venta.cliente.nombre} ${venta.cliente.apellido}
                            </c:when>
                            <c:otherwise>
                                Consumidor Final
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <p class="mb-2">
                        <strong>Total:</strong><br>
                        <span class="fs-5 fw-bold">$<fmt:formatNumber value="${venta.total}" minFractionDigits="2"/></span>
                    </p>
                </div>
            </div>

            <!-- POLÍTICAS -->
            <div class="card shadow">
                <div class="card-body bg-light">
                    <h6 class="fw-bold">📌 Política de devolución</h6>
                    <small class="text-muted">
                        • Máximo 15 días desde la compra<br>
                        • Producto sin uso y con etiqueta<br>
                        • No se aceptan productos en oferta<br>
                        • El cliente debe traer el ticket
                    </small>
                </div>
            </div>
        </div>

    </div>

</div>

<script>
function toggleCantidad(itemId, maxCantidad) {
    const checkbox = document.getElementById('checkbox-' + itemId);
    const cantidadInput = document.getElementById('cantidad-' + itemId);
    const hiddenInput = document.getElementById('hidden-' + itemId);

    if (checkbox.checked) {
        cantidadInput.disabled = false;
        cantidadInput.required = true;
        hiddenInput.disabled = false;
        cantidadInput.focus();
    } else {
        cantidadInput.disabled = true;
        cantidadInput.required = false;
        hiddenInput.disabled = true;
        cantidadInput.value = 1; // Reset
    }
}

function validarDevolucion() {
    const checkboxes = document.querySelectorAll('.item-checkbox:checked');

    if (checkboxes.length === 0) {
        alert('⚠️ Debe seleccionar al menos un producto para devolver');
        return false;
    }

    // Validar cantidades
    let valido = true;
    let mensajeError = '';

    checkboxes.forEach(cb => {
        const itemId = cb.dataset.itemId;
        const max = parseInt(cb.dataset.max);
        const cantidadInput = document.getElementById('cantidad-' + itemId);
        const valor = parseInt(cantidadInput.value);

        if (!valor || valor <= 0) {
            mensajeError = '⚠️ Todas las cantidades deben ser mayores a 0';
            valido = false;
        } else if (valor > max) {
            mensajeError = `⚠️ No podés devolver más de ${max} unidades`;
            valido = false;
        }
    });

    if (!valido) {
        alert(mensajeError);
        return false;
    }

    // Confirmar antes de enviar
    const totalItems = checkboxes.length;
    return confirm(`¿Confirmar la devolución de ${totalItems} producto(s)?`);
}

// Deshabilitar todos los inputs al cargar
window.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.cantidad-input').forEach(input => {
        input.disabled = true;
    });
    document.querySelectorAll('input[name="ventaItemIds"]').forEach(input => {
        input.disabled = true;
    });
});
</script>

</body>
</html>