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

                <!-- Título -->
                <h1 class="h3 mb-4 text-gray-800 mt-4">
                    <c:choose>
                        <c:when test="${gasto.id != null}">
                            Editar Gasto
                        </c:when>
                        <c:otherwise>
                           + Nuevo Gasto
                        </c:otherwise>
                    </c:choose>
                </h1>

                <!-- Card -->
                <div class="card shadow mb-4">
                    <div class="card-body">

                        <!-- Acción del form -->
                        <c:choose>
                            <c:when test="${gasto.id != null}">
                                <c:url var="formAction" value="/gastos/actualizar/${gasto.id}"/>
                            </c:when>
                            <c:otherwise>
                                <c:url var="formAction" value="/gastos/guardar"/>
                            </c:otherwise>
                        </c:choose>

                        <form method="post" action="${formAction}">
                        <input type="hidden"
                                   name="${_csrf.parameterName}"
                                   value="${_csrf.token}"/>
                            <div class="row">

                                <div class="col-md-6 mb-3">
                                    <label>Descripción</label>
                                    <input type="text" name="descripcion"
                                           class="form-control"
                                           value="${gasto.descripcion}" required>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label>Monto</label>
                                    <input type="text" name="monto"
                                           class="form-control"
                                           value="${gasto.monto}">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label>Fecha</label>
                                    <input type="date"
                                           name="fecha"
                                           class="form-control"
                                           value="${gasto.fecha}">
                                </div>
                            </div>



                            <!-- Botones -->
                            <div class="mt-4">
                                <button type="submit" class="btn btn-success"
                                onclick="this.disabled=true; this.form.submit();">
                                    Guardar
                                </button>

                                <a href="<c:url value='/clientes'/>"
                                   class="btn btn-secondary">
                                    Cancelar
                                </a>
                            </div>

                        </form>

                    </div>
                </div>

            </div>
        </div>

    </div>
</div>

</body>
</html>

