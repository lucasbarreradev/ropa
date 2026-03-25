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

                <h4 class="mb-4">
                    ${empty producto.id ? '➕ Nuevo Producto' : '✏️ Editar Producto'}
                </h4>

                <div class="card">
                    <div class="card-body">
                        <form method="POST"
                              action="${pageContext.request.contextPath}/productos/guardar">

                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                            <div class="mb-3">
                                <label class="form-label">Descripción *</label>
                                <input type="text"
                                       name="descripcion"
                                       class="form-control"
                                       value="${producto.descripcion}"
                                       required>
                            </div>

                            <div class="row">

                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Proveedor</label>
                                        <div class="input-group">
                                                                                                            <input type="text"
                                                                                                                   class="form-control"
                                                                                                                   value="${producto.proveedor.nombreRazonSocial}"
                                                                                                                   readonly>

                                                                                                            <input type="hidden" name="proveedorId"
                                                                                                                   value="${producto.proveedor.id}">

                                                                                                            <a href="${pageContext.request.contextPath}/proveedores?origen=producto&productoId=${producto.id}"
                                                                                                               class="btn btn-primary ml-3">
                                                                                                                Buscar Proveedor
                                                                                                            </a>
                                                                                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Tipo IVA</label>
                                        <select name="tipoIva" class="form-select">
                                            <c:forEach items="${tiposIva}" var="iva">
                                                <option value="${iva}" ${producto.tipoIva == iva ? 'selected' : ''}>
                                                    ${iva}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>

                            </div>

                            <button type="submit" class="btn btn-primary"
                            onclick="this.disabled=true; this.form.submit();">
                                ${empty producto.id ? '➡️ Siguiente: Agregar Talles y Precios' : '💾 Guardar Cambios'}
                            </button>
                            <a href="${pageContext.request.contextPath}/productos" class="btn btn-secondary">
                                Cancelar
                            </a>
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
</body>
</html>