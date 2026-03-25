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

                <h1 class="h3 mb-4 text-gray-800">📊 Dashboard</h1>

                <!-- CARDS DEL DÍA -->
                <div class="row">

                    <!-- VENTAS DEL DÍA -->
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                            Ventas Hoy
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                                            ${ventasDia}
                                        </div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-shopping-cart fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- CAJA DEL DÍA -->
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                            Caja Hoy
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                                            $<fmt:formatNumber value="${cajaNeta}" minFractionDigits="2"/>
                                        </div>
                                        <c:if test="${devolucionesDia > 0}">
                                            <small class="text-danger">
                                                -$<fmt:formatNumber value="${devolucionesDia}" minFractionDigits="2"/> dev.
                                            </small>
                                        </c:if>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-dollar-sign fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- GANANCIA DEL DÍA -->
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-info shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                            Ganancia Hoy
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                                            $<fmt:formatNumber value="${gananciaDia}" minFractionDigits="2"/>
                                        </div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-chart-line fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- VENTAS DEL MES -->
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                            Ventas Este Mes
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                                            ${ventasMes}
                                        </div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-calendar fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- CARDS DEL MES -->
                <div class="row">

                    <!-- GANANCIA DEL MES -->
                    <div class="col-xl-6 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                            Ganancia Este Mes
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                                            $<fmt:formatNumber value="${gananciaMes}" minFractionDigits="2"/>
                                        </div>
                                        <c:if test="${devolucionesMes > 0}">
                                            <small class="text-danger">
                                                -$<fmt:formatNumber value="${devolucionesMes}" minFractionDigits="2"/> devuelto
                                            </small>
                                        </c:if>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-chart-bar fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>



                <!-- INFORMACIÓN ADICIONAL -->
                <c:if test="${devolucionesDia > 0 or devolucionesMes > 0}">
                    <div class="row">
                        <div class="col-12">
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle"></i>
                                <strong>Nota:</strong> Los montos mostrados ya tienen descontadas las devoluciones aprobadas.
                                <a href="${pageContext.request.contextPath}/devoluciones" class="alert-link">
                                    Ver todas las devoluciones
                                </a>
                            </div>
                        </div>
                    </div>
                </c:if>

            </div>
        </div>
    </div>
</div>

</body>
</html>