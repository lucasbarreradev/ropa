<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <jsp:include page="/WEB-INF/jsp/head.jsp"/>
</head>
<body id="page-top">
<div id="wrapper">
<jsp:include page="/WEB-INF/jsp/nav_bar.jsp"/>

<div class="container-fluid mt-5">
    <div class="row justify-content-center">
        <div class="col-lg-6">

            <div class="card shadow-lg">
                <div class="card-header bg-warning text-dark text-center">
                    <h4 class="mb-0">🔄 Procesar Devolución</h4>
                </div>
                <div class="card-body p-5">

                    <!-- MENSAJE ERROR -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show">
                            ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- INSTRUCCIONES -->
                    <div class="alert alert-info">
                        <strong>📋 Instrucciones:</strong>
                        <ul class="mb-0 mt-2">
                            <li>Solicitá al cliente el ticket de compra</li>
                            <li>Ingresá o escaneá el código que aparece en el ticket</li>
                            <li>El código tiene formato: <strong>VENTA-XXXXXXXXXX</strong></li>
                        </ul>
                    </div>

                    <!-- FORMULARIO -->
                    <form method="POST" action="${pageContext.request.contextPath}/devoluciones/buscar">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                        <div class="mb-4">
                            <label class="form-label fs-5 fw-bold">
                                Código del Ticket:
                            </label>
                            <input type="text"
                                   name="codigoVenta"
                                   class="form-control form-control-lg text-center"
                                   placeholder="VENTA-1234567890"
                                   required
                                   autofocus
                                   style="font-family: 'Courier New', monospace; font-size: 1.5rem;">
                            <small class="text-muted">
                                El código está en la parte inferior del ticket
                            </small>
                        </div>

                        <button type="submit" class="btn btn-warning btn-lg w-100">
                            🔍 Buscar Venta
                        </button>
                    </form>

                    <hr class="my-4">

                    <!-- IMAGEN DE EJEMPLO -->
                    <div class="text-center">
                        <small class="text-muted">Ejemplo de ticket:</small>
                        <div class="border rounded p-3 mt-2" style="background-color: #f8f9fa; font-family: 'Courier New', monospace; font-size: 0.9rem;">
                            ========================================<br>
                            MOBEZA ELECTRICIDAD<br>
                            Acceso Norte S/N<br>
                            ========================================<br>
                            Fecha: 04/03/2026 15:30<br>
                            <strong style="background-color: yellow;">Ticket: VENTA-1234567890</strong> ← Ingresá este código<br>
                            Cliente: Juan Pérez<br>
                            ========================================
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

</body>
</html>