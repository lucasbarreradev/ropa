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
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">🏷️ Generar Etiquetas con Código de Barras</h4>
                </div>

                <div class="card">
                    <div class="card-header bg-primary text-white">
                        Seleccionar Productos, Talles y Cantidad de Etiquetas
                    </div>
                    <div class="card-body">
                        <form method="POST"
                              action="${pageContext.request.contextPath}/etiquetas/generar"
                              id="formEtiquetas">

                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                            <div class="d-flex align-items-center mb-3">

                                <!-- Botones izquierda -->
                                <button type="button"
                                        class="btn btn-sm btn-outline-primary me-2 mr-2"
                                        onclick="seleccionarTodos()">
                                    ✓ Seleccionar visibles
                                </button>

                                <button type="button"
                                        class="btn btn-sm btn-outline-secondary me-3 mr-2"
                                        onclick="deseleccionarTodos()">
                                    ✗ Deseleccionar todos
                                </button>

                                <span class="text-muted mr-5">
                                    Total etiquetas: <strong id="totalEtiquetas">0</strong>
                                </span>

                                <!-- Buscador a la derecha -->
                                <div class="ms-auto" style="max-width: 250px;">
                                    <input type="text"
                                           id="searchInput"
                                           class="form-control form-control-sm"
                                           placeholder="Buscar producto...">
                                </div>

                            </div>

                            <div class="table-responsive">
                                <table class="table table-hover" id="dataTable">
                                    <thead class="table-dark">
                                        <tr>
                                            <th style="width: 50px;"></th>
                                            <th>Producto</th>
                                            <th>Talle</th>
                                            <th>Stock</th>
                                            <th style="width: 140px;">Cant. Etiquetas</th>
                                            <th>Código</th>
                                            <th>Proveedor</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${productos}" var="p">
                                            <c:forEach items="${p.talles}" var="tp">
                                                <tr>
                                                    <td>
                                                        <input type="checkbox"
                                                               id="check_${tp.id}"
                                                               name="productoTalleIds"
                                                               value="${tp.id}"
                                                               class="form-check-input talle-check"
                                                               onchange="toggleCantidad(${tp.id})">
                                                    </td>
                                                    <td>
                                                        <strong>${p.descripcion}</strong>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-secondary text-white fs-6">${tp.talle.nombre}</span>
                                                    </td>
                                                    <td>
                                                        <span class="badge ${tp.stock <= 5 ? 'bg-danger text-white' :
                                                                            tp.stock <= 20 ? 'bg-warning text-dark' :
                                                                            'bg-success text-white'}">
                                                            ${tp.stock}
                                                        </span>
                                                    </td>
                                                        <td>
                                                        <input type="number"
                                                               id="cantidad_${tp.id}"
                                                               name="cantidades"
                                                               class="form-control form-control-sm cantidad-input"
                                                               value="1"
                                                               min="1"
                                                               max="100"
                                                               style="width: 100px; display: inline-block;"
                                                               onchange="calcularTotal()"
                                                               disabled>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty tp.codigoBarras}">
                                                                <code>${tp.codigoBarras}</code>
                                                                <small class="text-success">✓</small>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <small class="text-muted">Sin código</small>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                                                                            <c:choose>
                                                                                                                <c:when test="${not empty p.proveedor}">
                                                                                                                    <code>${p.proveedor.nombreRazonSocial}</code>

                                                                                                                </c:when>
                                                                                                                <c:otherwise>

                                                                                                                </c:otherwise>
                                                                                                            </c:choose>
                                                                                                        </td>
                                                </tr>
                                            </c:forEach>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <div class="mt-3">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    🏷️ Generar Códigos e Imprimir
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <footer class="sticky-footer bg-white">
            <div class="container my-auto">
                <div class="copyright text-center my-auto">
                    <span>Copyright &copy;</span>
                </div>
            </div>
        </footer>
    </div>
</div>

<script>
function toggleCantidad(talleProductoId) {
    const checkbox = document.getElementById('check_' + talleProductoId);
    const cantidadInput = document.getElementById('cantidad_' + talleProductoId);
    const stockBadge = checkbox.closest('tr').querySelector('td:nth-child(4) span');
    const stock = parseInt(stockBadge.textContent.trim()) || 0;

    if (checkbox.checked) {
        cantidadInput.disabled = false;
        cantidadInput.focus();
        cantidadInput.value = stock;
    } else {
        cantidadInput.disabled = true;
        cantidadInput.value = 1;
    }

    calcularTotal();
}

function calcularTotal() {
    let total = 0;
    const checks = document.querySelectorAll('.talle-check:checked');

    checks.forEach(check => {
        const cantidadInput = document.getElementById('cantidad_' + check.value);
        total += parseInt(cantidadInput.value) || 0;
    });

    document.getElementById('totalEtiquetas').textContent = total;
}

function seleccionarTodos() {
    const checks = Array.from(document.querySelectorAll('.talle-check'))
        .filter(check => check.closest('tr').style.display !== 'none');

    checks.forEach(c => {
        c.checked = true;
        toggleCantidad(c.value);
    });
}

function deseleccionarTodos() {
    const checks = document.querySelectorAll('.talle-check');
    checks.forEach(c => {
        c.checked = false;
        toggleCantidad(c.value);
    });
}

document.getElementById('formEtiquetas').addEventListener('submit', function(e) {
    const checks = document.querySelectorAll('.talle-check:checked');

    if (checks.length === 0) {
        e.preventDefault();
        alert('Debes seleccionar al menos un producto/talle');
    }
    }),

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
