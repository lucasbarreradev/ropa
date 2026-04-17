<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">

    <title>Imprimir Etiquetas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <style>
        body {
            margin: 0;
            padding: 0;
        }

        .no-print {
            display: block;
            padding: 15px;
            background: #f8f9fa;
            border-bottom: 1px solid #dee2e6;
        }

        @media print {
            .no-print {
                display: none !important;
            }
        }

        .etiquetas-container {
            display: flex;
            flex-wrap: wrap;
            gap: 5mm;
            padding: 10mm;
        }

        .etiqueta {
            width: 80mm;
            height: 40mm;
            border: 1px dashed #999;
            padding: 3mm;
            text-align: center;
            background: white;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            page-break-inside: avoid;
        }

        @media print {
            .etiqueta {
                border: 1px solid #000;
            }
        }
        @page {
            size: A4;
            margin: 10mm;
        }

        .etiqueta h5 {
            font-size: 14px;
            margin: 0 0 2mm 0;
            font-weight: bold;
            line-height: 1.2;
        }

        .etiqueta .talle-color {
            font-size: 14px;
            color: #666;
            margin: 1mm 0;
        }

        .etiqueta img {
            width: 100%;
            height: 22mm;
            object-fit: contain;
        }

        .etiqueta .codigo {
            font-size: 8px;
            color: #666;
            margin-top: 1mm;
            font-family: monospace;
        }
    </style>
</head>
<body>

    <div class="no-print">
        <div class="container">
            <button onclick="window.print()" class="btn btn-primary"
            onclick="this.disabled=true; this.form.submit();">
                🖨️ Imprimir Etiquetas
            </button>
            <a href="${pageContext.request.contextPath}/etiquetas/seleccionar"
               class="btn btn-outline-secondary">
                ← Volver
            </a>
            <span class="ms-3 text-muted">
                Tamaño: 80mm x 40mm | Total: ${tallesProducto.size()} etiquetas
            </span>
        </div>
    </div>

    <div class="etiquetas-container">
        <c:forEach items="${tallesProducto}" var="tp">
            <div class="etiqueta">
                <h5>${tp.producto.descripcion}</h5>

                <div class="talle-color">
                    Talle: ${tp.talle.nombre}
                </div>

                <img src="${pageContext.request.contextPath}/etiquetas/imagen/${tp.codigoBarras}"
                     alt="Código de barras">


            </div>
        </c:forEach>
    </div>
<script>
window.addEventListener("pageshow", function (event) {
    if (event.persisted || performance.getEntriesByType("navigation")[0].type === "back_forward") {
        window.location.href = "${pageContext.request.contextPath}/etiquetas/seleccionar";
    }
});
</script>
</body>
</html>