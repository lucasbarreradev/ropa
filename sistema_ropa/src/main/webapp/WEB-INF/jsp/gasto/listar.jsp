<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">

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
                    <div class="alert alert-success">${mensaje}</div>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <!-- Header -->
                <div class="d-sm-flex align-items-center justify-content-between mb-4 mt-4">
                    <h1 class="h3 mb-0 text-gray-800">Gastos</h1>

                    <a href="${pageContext.request.contextPath}/gastos/nuevo"
                       class="btn btn-primary">
                        + Nuevo Gasto
                    </a>
                </div>

                <!-- Card -->
                <div class="card shadow mb-4">

                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">
                            Listado de Gastos
                        </h6>
                    </div>
                    <div class="d-sm-flex align-items-center m-4">
                        <div class="ms-auto" style="max-width: 300px;">
                            <input type="text" id="searchInput"
                                   class="form-control"
                                   placeholder="Buscar gasto...">
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

                    <div class="card-body">
                        <div class="table-responsive">

                            <table class="table table-bordered table-hover"
                                   id="dataTable"
                                   width="100%" cellspacing="0">

                                <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Descripción</th>
                                    <th>Monto</th>
                                    <th>Fecha</th>
                                    <th>Acciones</th>
                                </tr>
                                </thead>

                                <tbody>
                                <c:forEach items="${gastos}" var="g">
                                    <tr>
                                        <td>${g.id}</td>
                                        <td>${g.descripcion}</td>
                                        <td>${g.monto}</td>
                                        <td>${g.fecha}</td>

                                        <td class="text-center">
                                            <a class="btn btn-sm btn-warning"
                                               href="${pageContext.request.contextPath}/gastos/editar/${g.id}">
                                                Editar
                                            </a>
                                            <a class="btn btn-sm btn-danger"
                                               href="${pageContext.request.contextPath}/gastos/eliminar/${g.id}"
                                               onclick="return confirm('¿Eliminar gasto?');">
                                                Eliminar
                                            </a>
                                        </td>
                                    </tr>
                                    </c:forEach>
                                </tbody>

                            </table>

                        </div>
                    </div>
                </div>

            </div> <!-- container-fluid -->
        </div> <!-- content -->

        <!-- Footer -->
        <footer class="sticky-footer bg-white">
            <div class="container my-auto">
                <div class="copyright text-center my-auto">
                    <span>Copyright &copy;</span>
                </div>
            </div>
        </footer>

    </div> <!-- content-wrapper -->
</div> <!-- wrapper -->
