<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Imprimir Etiquetas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>

        /* ==========================================
           PANTALLA
        ========================================== */
        body {
            margin: 0;
            padding: 0;
            background: #e9ecef;
            font-family: Arial, sans-serif;
        }

        .no-print {
            display: block;
            padding: 15px 20px;
            background: #2c3e50;
            color: white;
            border-bottom: 3px solid #3498db;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .no-print .titulo {
            font-size: 18px;
            font-weight: bold;
        }

        .no-print .subtitulo {
            font-size: 13px;
            color: #bdc3c7;
        }

        .etiquetas-wrapper {
            padding: 20px;
            display: flex;
            justify-content: center;
        }

        .etiquetas-container {
            display: flex;
            flex-wrap: wrap;
            gap: 4mm;
            background: white;
            padding: 10mm;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            border-radius: 8px;
            max-width: 210mm;
            align-items: flex-start;
        }

        /* ==========================================
           ETIQUETA 40mm x 90mm
           Sin agujero, para pegar en la parte
           trasera de la etiqueta de cartón
        ========================================== */
        .etiqueta {
            width: 40mm;
            height: 90mm;
            border: 1px dashed #aaa; /* Solo guía de corte, no se imprime */
            border-radius: 2px;
            padding: 4mm 3mm 3mm 3mm;
            background: white;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: center;
            page-break-inside: avoid;
        }

        @media print {
            .etiqueta {
                /* Borde punteado suave como guía de corte */
                border: 0.5px dashed #ccc;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
        }

        /* ==========================================
           CONTENIDO
        ========================================== */

        /* Nombre del producto */
        .etiqueta-nombre {
            font-size: 11px;
            font-weight: bold;
            text-align: center;
            line-height: 1.3;
            color: #1a1a1a;
            width: 100%;
            word-break: break-word;
        }

        /* Separador */
        .etiqueta-sep {
            width: 85%;
            height: 0.5px;
            background: #ccc;
        }

        /* Talle */
        .etiqueta-talle-label {
            font-size: 7px;
            color: #999;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 1mm;
        }

        .etiqueta-talle-valor {
            font-size: 28px;
            font-weight: 900;
            color: #1a1a1a;
            line-height: 1;
            letter-spacing: 2px;
        }

        /* Código de barras */
        .etiqueta-barcode {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1.5px;
        }

        .etiqueta-barcode img {
            width: 100%;
            height: 20mm;
            object-fit: fill;
        }

        .etiqueta-codigo {
            font-size: 6.5px;
            color: #444;
            font-family: 'Courier New', monospace;
            letter-spacing: 1.5px;
            text-align: center;
            margin-top: 1px;
        }

        /* ==========================================
           IMPRESIÓN
        ========================================== */
        @media print {
            body {
                background: white;
                margin: 0;
                padding: 0;
            }

            .no-print {
                display: none !important;
            }

            .etiquetas-wrapper {
                padding: 0;
            }

            .etiquetas-container {
                box-shadow: none;
                border-radius: 0;
                padding: 5mm;
                gap: 3mm;
                max-width: 100%;
            }
        }

        @page {
            size: A4 portrait;
            margin: 8mm;
        }
    </style>
</head>
<body>

    <!-- BARRA SUPERIOR -->
    <div class="no-print">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <div class="titulo">🏷️ Impresión de Etiquetas</div>
                <div class="subtitulo">
                    ${tallesProducto.size()} etiquetas | 40mm × 90mm
                    | Para pegar en etiqueta de cartón
                </div>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/etiquetas/seleccionar"
                   class="btn btn-outline-light btn-sm">
                    ← Volver
                </a>
                <button onclick="window.print()" class="btn btn-primary btn-sm px-4">
                    🖨️ Imprimir
                </button>
            </div>
        </div>
    </div>

    <!-- ETIQUETAS -->
    <div class="etiquetas-wrapper">
        <div class="etiquetas-container">
            <c:forEach items="${tallesProducto}" var="tp">
                <div class="etiqueta">

                    <!-- NOMBRE DEL PRODUCTO -->
                    <div class="etiqueta-nombre">
                        ${tp.producto.descripcion}
                    </div>

                    <div class="etiqueta-sep"></div>

                    <!-- TALLE -->
                    <div style="text-align: center;">
                        <div class="etiqueta-talle-label">talle</div>
                        <div class="etiqueta-talle-valor">${tp.talle.nombre}</div>
                    </div>

                    <div class="etiqueta-sep"></div>

                    <!-- CÓDIGO DE BARRAS -->
                    <div class="etiqueta-barcode">
                        <img src="${pageContext.request.contextPath}/etiquetas/imagen/${tp.codigoBarras}"
                             alt="Código de barras">
                        <div class="etiqueta-codigo">${tp.codigoBarras}</div>
                    </div>

                </div>
            </c:forEach>
        </div>
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