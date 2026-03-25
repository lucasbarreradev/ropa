<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Ticket - ${venta.codigo}</title>
    <style>
        @media print {
            body {
                margin: 0;
                padding: 0;
            }
            .no-print {
                display: none !important;
            }
            .ticket {
                width: 80mm;
                font-family: 'Courier New', monospace;
                font-size: 12px;
                line-height: 1.3;
            }
        }

        @media screen {
            body {
                background-color: #f0f0f0;
                padding: 20px;
            }
            .ticket {
                width: 80mm;
                background: white;
                margin: 0 auto;
                padding: 10mm;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
                font-family: 'Courier New', monospace;
                font-size: 12px;
                line-height: 1.3;
            }
        }

        .ticket {
            white-space: pre-wrap;
        }
    </style>
</head>
<body>

<!-- BOTONES (solo en pantalla) -->
<div class="no-print" style="text-align: center; margin-bottom: 20px;">
    <button onclick="window.print()" class="btn btn-primary btn-lg">
        🖨️ Imprimir Ticket
    </button>
    <a href="${pageContext.request.contextPath}/ventas/ticket/${venta.id}/descargar"
       class="btn btn-secondary btn-lg">
        💾 Descargar .txt
    </a>
    <a href="${pageContext.request.contextPath}/ventas"
       class="btn btn-outline-secondary btn-lg">
        ← Volver a ventas
    </a>
</div>

<!-- TICKET -->
<div class="ticket">${ticketTexto}</div>

<!-- AUTO-ABRIR DIÁLOGO DE IMPRESIÓN -->
<script>
    // Esperar 500ms y abrir automáticamente el diálogo de impresión
    setTimeout(function() {
        window.print();
    }, 500);
</script>

</body>
</html>