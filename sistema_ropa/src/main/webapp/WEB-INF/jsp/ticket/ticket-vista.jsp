<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <jsp:include page="/WEB-INF/jsp/head.jsp"/>
    <title>Ticket - ${venta.codigo}</title>
</head>
<body id="page-top">
<div id="wrapper">
<jsp:include page="/WEB-INF/jsp/nav_bar.jsp"/>

<div class="container-fluid mt-5">
    <div class="row justify-content-center">
        <div class="col-lg-6 text-center">

            <div class="card shadow">
                <div class="card-header bg-success text-white">
                    <h4 class="mb-0">✅ Venta Registrada</h4>
                </div>
                <div class="card-body p-5">

                    <div class="mb-4">
                        <i class="fas fa-check-circle fa-5x text-success"></i>
                    </div>

                    <h5 class="mb-3">Venta: <strong>${venta.codigo}</strong></h5>
                    <p class="text-muted">Total: <strong class="fs-4">$${venta.total}</strong></p>

                    <hr class="my-4">

                    <!-- BOTÓN PRINCIPAL: IMPRIMIR TICKET -->
                    <a href="${pageContext.request.contextPath}/ventas/ticket/${venta.id}"
                       target="_blank"
                       class="btn btn-success btn-lg mb-3 w-100"
                       onclick="setTimeout(() => window.location='${pageContext.request.contextPath}/ventas', 2000)">
                        <i class="fas fa-print fa-2x"></i>
                        <br>
                        🖨️ Imprimir Ticket
                    </a>

                    <p class="text-muted small mb-3">
                        Se abrirá el ticket en una nueva pestaña.<br>
                        Entregá el ticket impreso al cliente.
                    </p>

                    <hr>

                    <!-- BOTONES SECUNDARIOS -->
                    <div class="d-grid gap-2">
                        <a href="${pageContext.request.contextPath}/ventas/detalle/${venta.id}"
                           class="btn btn-outline-primary">
                            📋 Ver Detalle de Venta
                        </a>

                        <a href="${pageContext.request.contextPath}/ventas/nueva"
                           class="btn btn-outline-secondary">
                            + Nueva Venta
                        </a>

                        <a href="${pageContext.request.contextPath}/ventas"
                           class="btn btn-outline-secondary">
                            ← Volver al Listado
                        </a>
                    </div>

                </div>
            </div>

            <!-- INSTRUCCIONES -->
            <div class="card mt-3">
                <div class="card-body bg-light">
                    <h6>📌 Instrucciones:</h6>
                    <small class="text-muted">
                        1. Hacé clic en "Imprimir Ticket"<br>
                        2. Se abrirá el PDF en una nueva pestaña<br>
                        3. Imprimí el ticket (Ctrl + P)<br>
                        4. Entregá el ticket al cliente junto con los productos<br>
                        5. <strong>El cliente debe conservar el ticket para devoluciones</strong>
                    </small>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- Auto-abrir ticket en nueva pestaña -->
<script>
    // Abrir automáticamente el ticket al cargar la página
    window.addEventListener('load', function() {
        setTimeout(function() {
            window.open('${pageContext.request.contextPath}/ventas/ticket/${venta.id}', '_blank');
        }, 500);
    });
</script>

</body>
</html>