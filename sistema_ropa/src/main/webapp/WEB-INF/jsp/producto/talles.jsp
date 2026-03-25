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

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h4 class="mb-0">👕 ${producto.descripcion}</h4>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/productos"
                           class="btn btn-outline-secondary">
                            ← Volver al listado
                        </a>
                    </div>
                </div>

                <div class="row">
                    <!-- FORMULARIO AGREGAR TALLE -->
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header bg-primary text-white">
                                ➕ Agregar Talle
                            </div>
                            <div class="card-body">
                                <form method="POST"
                                      action="${pageContext.request.contextPath}/productos/${producto.id}/talles/agregar">

                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                                    <div class="mb-3">
                                        <label class="form-label">Talle *</label>
                                        <input type="text"
                                               name="nombreTalle"
                                               id="inputTalle"
                                               class="form-control"
                                               placeholder="Ej: S, M, L, 38, 40"
                                               required
                                               maxlength="20"
                                               autocomplete="off"
                                               list="tallesExistentes">

                                        <!-- Datalist con talles existentes -->
                                        <datalist id="tallesExistentes">
                                            <c:forEach items="${tallesExistentes}" var="t">
                                                <option value="${t.nombre}">
                                            </c:forEach>
                                        </datalist>

                                        <small class="text-muted">
                                            Podés escribir uno nuevo o elegir de la lista.
                                        </small>
                                    </div>

                                    <!-- STOCK -->
                                    <div class="mb-3">
                                        <label class="form-label">Stock</label>
                                        <input type="number"
                                               name="stock"
                                               class="form-control"
                                               min="0"
                                               value="0"
                                               required>
                                    </div>

                                    <!-- PRECIO COMPRA -->
                                    <div class="mb-3">
                                        <label class="form-label">Precio Compra</label>
                                        <input type="number"
                                               name="precioCompra"
                                               class="form-control"
                                               step="0.01"
                                               min="0">
                                    </div>

                                    <!-- PRECIO CONTADO -->
                                    <div class="mb-3">
                                        <label class="form-label">Precio Contado</label>
                                        <input type="number"
                                               name="precioContado"
                                               class="form-control"
                                               step="0.01"
                                               min="0">
                                    </div>

                                    <!-- PRECIO TARJETA -->
                                    <div class="mb-3">
                                        <label class="form-label">Precio Tarjeta</label>
                                        <input type="number"
                                               name="precioTarjeta"
                                               class="form-control"
                                               step="0.01"
                                               min="0">
                                    </div>

                                    <!-- PRECIO CUENTA CORRIENTE -->
                                    <div class="mb-3">
                                        <label class="form-label">Precio Cuenta Corriente</label>
                                        <input type="number"
                                               name="precioCuentaCorriente"
                                               class="form-control"
                                               step="0.01"
                                               min="0">
                                    </div>

                                    <button type="submit" class="btn btn-primary w-100">
                                        ➕ Agregar Talle
                                    </button>
                                </form>
                            </div>
                        </div>
                        </div>
                    <!-- TABLA DE TALLES EXISTENTES -->
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header bg-success text-white">
                                📋 Talles y Precios Configurados
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty tallesProducto}">
                                        <div class="alert alert-info">
                                            ℹ️ Aún no hay talles agregados. Usá el formulario de la izquierda para agregar.
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead class="table-dark">
                                                    <tr>
                                                        <th>Talle</th>
                                                        <th>Stock</th>
                                                        <th>Precio Contado</th>
                                                        <th>Precio Tarjeta</th>
                                                        <th>Precio C/C</th>
                                                        <th>Código</th>
                                                        <th>Acciones</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${tallesProducto}" var="tp">
                                                        <tr>
                                                            <td>
                                                                <span class="badge bg-secondary text-white fs-6">
                                                                    ${tp.talle.nombre}
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <span class="badge ${tp.stock <= 5 ? 'bg-danger text-white' :
                                                                                    tp.stock <= 20 ? 'bg-warning text-dark' :
                                                                                    'bg-success text-white'}">
                                                                    ${tp.stock}
                                                                </span>
                                                            </td>
                                                            <td>$${tp.precioContado}</td>
                                                            <td>$${tp.precioTarjeta}</td>
                                                            <td>$${tp.precioCuentaCorriente}</td>
                                                            <td>
                                                                <small>
                                                                    <code>${tp.codigoBarras}</code>
                                                                </small>
                                                            </td>
                                                            <td>
                                                                <button type="button"
                                                                        class="btn btn-sm btn-primary"
                                                                        onclick="editarTalle(${tp.id}, '${tp.talle.nombre}', ${tp.stock}, ${tp.precioCompra}, ${tp.precioContado}, ${tp.precioTarjeta}, ${tp.precioCuentaCorriente})">
                                                                    ✏️
                                                                </button>
                                                                <form method="POST"
                                                                      action="${pageContext.request.contextPath}/productos/talles/${tp.id}/eliminar"
                                                                      style="display:inline">
                                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                                    <button type="submit"
                                                                            class="btn btn-sm btn-danger"
                                                                            onclick="return confirm('¿Eliminar este talle?')">
                                                                        🗑️
                                                                    </button>
                                                                </form>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                                <tfoot class="table-secondary">
                                                    <tr>
                                                        Stock total: ${stockTotal}
                                                    </tr>
                                                </tfoot>
                                            </table>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
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

<!-- MODAL EDITAR TALLE -->
<div class="modal fade" id="modalEditarTalle" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">✏️ Editar Talle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST" id="formEditarTalle">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Talle</label>
                        <input type="text" id="editTalle" class="form-control" readonly>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Stock *</label>
                        <input type="number" name="stock" id="editStock" class="form-control" min="0" required>
                    </div>

                    <div class="mb-3">
                                            <label class="form-label">Precio Compra</label>
                                            <input type="number" name="precioCompra" id="editPrecioCompra" class="form-control" step="0.01">
                                        </div>

                    <div class="mb-3">
                        <label class="form-label">Precio Contado</label>
                        <input type="number" name="precioContado" id="editPrecioContado" class="form-control" step="0.01">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Precio Tarjeta</label>
                        <input type="number" name="precioTarjeta" id="editPrecioTarjeta" class="form-control" step="0.01">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Precio Cuenta Corriente</label>
                        <input type="number" name="precioCuentaCorriente" id="editPrecioCC" class="form-control" step="0.01">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary"
                    onclick="this.disabled=true; this.form.submit();">💾 Guardar Cambios</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function editarTalle(id, talle, stock, precioCompra, precioContado, precioTarjeta, precioCC) {
    document.getElementById('editTalle').value = talle;
    document.getElementById('editStock').value = stock;
    document.getElementById('editPrecioCompra').value = precioCompra;
    document.getElementById('editPrecioContado').value = precioContado;
    document.getElementById('editPrecioTarjeta').value = precioTarjeta;
    document.getElementById('editPrecioCC').value = precioCC;

    document.getElementById('formEditarTalle').action =
        '${pageContext.request.contextPath}/productos/talles/' + id + '/actualizar';

    new bootstrap.Modal(document.getElementById('modalEditarTalle')).show();
}
</script>
</body>
</html>