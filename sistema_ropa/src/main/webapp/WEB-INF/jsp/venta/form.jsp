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

<div class="container-fluid mt-4">
<div class="row">

    <!-- IZQUIERDA -->
    <div class="col-lg-9 col-md-8 col-sm-12">
        <div class="card shadow mb-4">
            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                <span>🛒 Detalles de la venta</span>
                <small class="badge bg-light text-dark">Paso 2: Agregar productos</small>
            </div>
            <div class="card-body">

                <!-- BUSCADOR CON SCANNER -->
                <div class="row mb-3">
                    <div class="col-md-12">
                        <label class="form-label fw-semibold">
                            🔍 Buscar producto (nombre o código de barras)
                        </label>
                        <input type="text"
                               id="buscarProducto"
                               class="form-control form-control-lg"
                               placeholder="Escribí el nombre o escaneá el código..."
                               autocomplete="off">
                        <div id="resultados"
                             class="list-group position-absolute w-100"
                             style="z-index:1000; max-height:400px; overflow-y:auto;"></div>
                        <small class="text-muted">
                            💡 Podés escribir el nombre o usar el lector de códigos de barras
                        </small>
                    </div>
                </div>

                <!-- DATOS PRODUCTO SELECCIONADO -->
                <div class="row mb-3">
                    <div class="col-md-2">
                        <label>Talle</label>
                        <input type="text" id="talle" class="form-control" readonly>
                    </div>
                    <div class="col-md-2">
                        <label>Stock</label>
                        <input type="text" id="stock" class="form-control" readonly>
                    </div>
                    <div class="col-md-2">
                        <label>Cantidad *</label>
                        <input type="number" id="cantidad" class="form-control" min="1" value="1">
                    </div>
                    <div class="col-md-2">
                        <label>Precio</label>
                        <input type="text" id="precio" class="form-control" readonly>
                        <small class="text-muted" id="textoPrecio"></small>
                    </div>
                    <div class="col-md-2">
                        <label>Descuento (%)</label>
                        <input type="number"
                               id="descuento"
                               class="form-control"
                               value="0"
                               min="0"
                               max="100">
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button class="btn btn-success w-100" onclick="agregarProducto()">
                            + Agregar
                        </button>
                    </div>
                </div>

                <!-- TABLA DE ITEMS -->
                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead class="table-dark">
                        <tr>
                            <th>Producto</th>
                            <th class="text-center">Cant.</th>
                            <th class="text-end">Precio Unit.</th>
                            <th class="text-center">Desc.</th>
                            <th class="text-end">Subtotal</th>
                            <th class="text-center" style="width: 60px;"></th>
                        </tr>
                        </thead>
                        <tbody id="detalleVenta">
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">
                                No hay productos agregados. Buscá y agregá productos arriba.
                            </td>
                        </tr>
                        </tbody>
                        <tfoot class="table-secondary">
                        <tr>
                            <td colspan="4" class="fw-bold text-end">SUBTOTAL (Efectivo):</td>
                            <td class="text-end fw-bold fs-5 text-dark">
                                $<span id="subtotalEfectivo">0.00</span>
                            </td>
                            <td></td>
                        </tr>
                        </tfoot>
                    </table>
                </div>

            </div>
        </div>
    </div>

    <!-- DERECHA -->
    <div class="col-lg-3 col-md-4 col-sm-12">
        <div class="card shadow mb-4">
            <div class="card-header bg-success text-white">
                📝 Datos de la venta
            </div>

            <div class="card-body">
                <form method="post"
                      action="${pageContext.request.contextPath}/ventas/guardar"
                      onsubmit="return validarVenta()">

                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                    <!-- CLIENTE -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            <small class="badge bg-secondary">Paso 1</small>
                            Cliente (opcional)
                        </label>

                        <!-- Input con botón de agregar cliente -->
                        <div class="input-group">
                            <input type="text"
                                   id="buscarCliente"
                                   class="form-control"
                                   placeholder="Buscar cliente..."
                                   autocomplete="off">
                            <button type="button"
                                    class="btn btn-primary"
                                    data-bs-toggle="modal"
                                    data-bs-target="#modalNuevoCliente"
                                    title="Nuevo cliente">
                                <i class="fas fa-user-plus"></i>
                            </button>
                        </div>

                        <input type="hidden" name="clienteId" id="clienteId">

                        <div id="resultadosCliente"
                             class="list-group position-absolute w-100"
                             style="z-index:1050; max-height:200px; overflow-y:auto;"></div>
                        <small class="text-muted">Dejá vacío para "Consumidor Final"</small>
                    </div>

                    <hr>

                    <!-- RESUMEN -->
                    <div class="mb-3">
                        <small class="text-muted">Productos agregados:</small>
                        <div class="fs-5 fw-bold text-primary">
                            <span id="cantidadItems">0</span> items
                        </div>
                    </div>

                    <div class="mb-3">
                        <small class="text-muted">Subtotal (efectivo):</small>
                        <div class="fs-4 fw-bold text-dark">
                            $<span id="subtotalGeneral">0.00</span>
                        </div>
                    </div>

                    <hr>

                    <!-- FORMA DE PAGO -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            <small class="badge bg-warning text-dark">Paso 3</small>
                            💳 Forma de pago *
                        </label>
                        <select name="formaPago"
                                id="formaPago"
                                class="form-select form-select-lg"
                                required
                                onchange="actualizarPreciosFinal()">
                            <option value="">-- Seleccionar método de pago --</option>
                            <option value="CONTADO">💵 Efectivo</option>
                            <option value="TARJETA">💳 Tarjeta</option>
                            <option value="CUENTA_CORRIENTE">📋 Cuenta Corriente</option>
                        </select>
                    </div>

                    <!-- TOTAL FINAL -->
                    <div class="mb-4 p-3 bg-light rounded">
                        <small class="text-muted">TOTAL A PAGAR:</small>
                        <div class="fs-2 fw-bold text-success">
                            $<span id="totalFinal">0.00</span>
                        </div>
                        <small class="text-muted" id="detalleRecargo"></small>
                    </div>

                    <div id="itemsHidden"></div>

                    <button type="submit"
                            class="btn btn-success btn-lg w-100"
                            id="btnGuardar"
                            disabled>
                        💾 Confirmar Venta
                    </button>
                    <small class="text-muted d-block text-center mt-2" id="mensajeAyuda">
                        ⬆️ Agregá productos primero
                    </small>
                </form>
            </div>
        </div>
    </div>

</div>

<script>
let items = [];
let productoTalleSeleccionado = null;
let clienteSeleccionado = null;
let productoDescripcion = "";
let precioContado = 0;
let precioTarjeta = 0;
let precioCC = 0;

// ==========================================
// AGREGAR PRODUCTO
// ==========================================
function agregarProducto() {
    if (!productoTalleSeleccionado) {
        alert("⚠️ Seleccioná un producto primero");
        return;
    }

    let cantidad = parseInt(document.getElementById("cantidad").value);
    let stock = parseInt(document.getElementById("stock").value);
    let descuentoPct = parseFloat(document.getElementById("descuento").value || 0);

    if (!cantidad || cantidad <= 0) {
        alert("⚠️ La cantidad debe ser mayor a 0");
        return;
    }

    // Buscar si el producto ya existe
    let itemExistente = items.find(i => i.productoTalleId === productoTalleSeleccionado);

    let cantidadTotal = cantidad;
    if (itemExistente) {
        cantidadTotal += itemExistente.cantidad;
    }

    if (cantidadTotal > stock) {
        alert(`⚠️ Stock insuficiente. Disponible: ${stock}`);
        return;
    }

    if (itemExistente) {
        itemExistente.cantidad += cantidad;
    } else {
        items.push({
            productoTalleId: productoTalleSeleccionado,
            descripcion: productoDescripcion,
            cantidad: cantidad,
            precioContado: precioContado,
            precioTarjeta: precioTarjeta,
            precioCC: precioCC,
            descuento: descuentoPct
        });
    }

    limpiarSeleccion();
    renderTabla();
    actualizarPreciosFinal();
}

function limpiarSeleccion() {
    productoTalleSeleccionado = null;
    productoDescripcion = "";
    document.getElementById("buscarProducto").value = "";
    document.getElementById("talle").value = "";
    document.getElementById("stock").value = "";
    document.getElementById("precio").value = "";
    document.getElementById("cantidad").value = "1";
    document.getElementById("descuento").value = "0";
    document.getElementById("textoPrecio").textContent = "";
    document.getElementById("buscarProducto").focus();
}

// ==========================================
// RENDERIZAR TABLA
// ==========================================
function renderTabla() {
    let tbody = document.getElementById("detalleVenta");
    let hidden = document.getElementById("itemsHidden");

    tbody.innerHTML = "";
    hidden.innerHTML = "";

    if (items.length === 0) {
        tbody.innerHTML =
            "<tr>" +
                "<td colspan='6' class='text-center text-muted py-4'>" +
                    "No hay productos agregados.<br>Buscá y agregá productos arriba." +
                "</td>" +
            "</tr>";

        document.getElementById("btnGuardar").disabled = true;
        document.getElementById("mensajeAyuda").textContent = "⬆️ Agregá productos primero";

    } else {
        items.forEach((item, index) => {
            let formaPago = document.getElementById("formaPago").value;

            let precio = item.precioContado;

            if (formaPago === "TARJETA") {
                precio = item.precioTarjeta;
            } else if (formaPago === "CUENTA_CORRIENTE") {
                precio = item.precioCC;
            }
            let subtotal = item.cantidad * precio * (1 - item.descuento / 100);

            tbody.innerHTML +=
                "<tr>" +
                    "<td><strong>" + item.descripcion + "</strong></td>" +
                    "<td class='text-center'>" + item.cantidad + "</td>" +
                    "<td class='text-end'>$" + precio.toFixed(2) + "</td>" +
                    "<td class='text-center'>" + item.descuento + "%</td>" +
                    "<td class='text-end fw-semibold'>$" + subtotal.toFixed(2) + "</td>" +
                    "<td class='text-center'>" +
                        "<button type='button' class='btn btn-danger btn-sm' onclick='eliminar(" + index + ")'>✕</button>" +
                    "</td>" +
                "</tr>";

            hidden.innerHTML +=
                "<input type='hidden' name='productoTalleIds' value='" + item.productoTalleId + "'>" +
                "<input type='hidden' name='cantidades' value='" + item.cantidad + "'>" +
                "<input type='hidden' name='descuentos' value='" + item.descuento + "'>";
        });

        verificarHabilitarBoton();
    }

    document.getElementById("cantidadItems").textContent = items.length;
}

// ==========================================
// ACTUALIZAR PRECIOS SEGÚN FORMA DE PAGO
// ==========================================
function actualizarPreciosFinal() {
    const formaPago = document.getElementById("formaPago").value;
    let totalEfectivo = 0;
    let totalFinal = 0;

    items.forEach(item => {
        let precio = item.precioContado;

        if (formaPago === "TARJETA") {
            precio = item.precioTarjeta;
        } else if (formaPago === "CUENTA_CORRIENTE") {
            precio = item.precioCC;
        }

        let subtotal = item.cantidad * precio * (1 - item.descuento / 100);
        totalFinal += subtotal;

        let subtotalEfectivo = item.cantidad * item.precioContado * (1 - item.descuento / 100);
        totalEfectivo += subtotalEfectivo;
    });

    document.getElementById("subtotalEfectivo").textContent = totalEfectivo.toFixed(2);
    document.getElementById("subtotalGeneral").textContent = totalEfectivo.toFixed(2);
    document.getElementById("totalFinal").textContent = totalFinal.toFixed(2);

    let detalleRecargo = "";
    if (formaPago === "TARJETA") {
        let recargo = totalFinal - totalEfectivo;
        detalleRecargo = `Incluye +$${recargo.toFixed(2)} de recargo por tarjeta`;
    } else if (formaPago === "CUENTA_CORRIENTE") {
        let recargo = totalFinal - totalEfectivo;
        detalleRecargo = `Incluye +$${recargo.toFixed(2)} de recargo por C/C`;
    } else if (formaPago === "CONTADO") {
        detalleRecargo = "Precio en efectivo";
    }

    document.getElementById("detalleRecargo").textContent = detalleRecargo;
    renderTabla();
    verificarHabilitarBoton();
}

// ==========================================
// VERIFICAR SI SE PUEDE GUARDAR
// ==========================================
function verificarHabilitarBoton() {
    const hayProductos = items.length > 0;
    const hayFormaPago = document.getElementById("formaPago").value !== "";

    if (hayProductos && hayFormaPago) {
        document.getElementById("btnGuardar").disabled = false;
        document.getElementById("mensajeAyuda").textContent = "✅ Todo listo para confirmar";
        document.getElementById("mensajeAyuda").className = "text-success d-block text-center mt-2 fw-bold";
    } else if (hayProductos && !hayFormaPago) {
        document.getElementById("btnGuardar").disabled = true;
        document.getElementById("mensajeAyuda").textContent = "💳 Seleccioná la forma de pago";
        document.getElementById("mensajeAyuda").className = "text-warning d-block text-center mt-2";
    } else {
        document.getElementById("btnGuardar").disabled = true;
        document.getElementById("mensajeAyuda").textContent = "⬆️ Agregá productos primero";
        document.getElementById("mensajeAyuda").className = "text-muted d-block text-center mt-2";
    }
}

function eliminar(index) {
    if (confirm("¿Eliminar este producto?")) {
        items.splice(index, 1);
        renderTabla();
        actualizarPreciosFinal();
    }
}

function validarVenta() {
    if (items.length === 0) {
        alert("⚠️ Agregá al menos un producto");
        return false;
    }

    if (!document.getElementById("formaPago").value) {
        alert("⚠️ Seleccioná la forma de pago");
        return false;
    }

    document.getElementById("btnGuardar").disabled = true;
    document.getElementById("btnGuardar").textContent = "Guardando...";

    return true;
}

// ==========================================
// BÚSQUEDA DE PRODUCTOS (nombre o código)
// ==========================================
let timeoutBusqueda;

document.getElementById("buscarProducto").addEventListener("keyup", function(e) {
    let q = this.value.trim();

    // Limpiar timeout anterior
    clearTimeout(timeoutBusqueda);

    if (q.length < 2) {
        document.getElementById("resultados").innerHTML = "";
        return;
    }

    // Detectar si es código de barras (formato EMP-XXX-XXXX)
    let esCodigoBarras = /^EMP-\d{3}-\d{4}$/.test(q);

    if (esCodigoBarras) {
        // Búsqueda inmediata si es código completo
        buscarPorCodigo(q);
    } else {
        // Búsqueda con delay si es texto
        timeoutBusqueda = setTimeout(() => {
            buscarProductos(q);
        }, 300);
    }
});

function buscarProductos(query) {
    fetch("${pageContext.request.contextPath}/productos/buscar?q=" + encodeURIComponent(query))
        .then(res => res.json())
        .then(data => {
            mostrarResultados(data);
        })
        .catch(err => {
            console.error('Error buscando productos:', err);
        });
}

function buscarPorCodigo(codigo) {
    fetch("${pageContext.request.contextPath}/etiquetas/buscar", {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-CSRF-TOKEN': document.querySelector('[name="${_csrf.parameterName}"]').value
        },
        body: 'codigo=' + encodeURIComponent(codigo)
    })
    .then(res => res.json())
    .then(data => {
        if (data.error) {
            alert("❌ " + data.error);
            document.getElementById("resultados").innerHTML = "";
        } else {
            // Producto encontrado por código, seleccionar automáticamente
            seleccionarProducto(
                data.id,
                data.descripcion,
                data.talle,
                data.stock,
                data.precioContado,
                data.precioTarjeta,
                data.precioCuentaCorriente
            );
        }
    })
    .catch(err => {
        console.error('Error buscando por código:', err);
        alert("❌ Error al buscar el código de barras");
    });
}

function mostrarResultados(productosTalles) {
    let html = "";

    if (productosTalles.length === 0) {
        html = '<div class="list-group-item text-muted">No se encontraron productos</div>';
    } else {
        productosTalles.forEach(pt => {

            let stock = pt.stock || 0;
            let badgeClass = stock <= 5 ? 'bg-danger text-white'
                : stock <= 20 ? 'bg-warning text-dark fw-bold'
                : 'bg-success text-white';

            let talleNombre = pt.talle ? pt.talle.nombre : '';

            html +=
                "<a href='#' class='list-group-item list-group-item-action producto-item' " +
                "data-id='" + pt.id + "' " +
                "data-descripcion='" + pt.producto.descripcion + "' " +
                "data-talle='" + talleNombre + "' " +
                "data-stock='" + stock + "' " +
                "data-precio-contado='" + pt.precioContado + "' " +
                "data-precio-tarjeta='" + pt.precioTarjeta + "' " +
                "data-precio-cc='" + pt.precioCuentaCorriente + "'>" +
                    "<strong>" + pt.producto.descripcion + "</strong> " +
                    "<span class='badge bg-secondary text-white fs-6'>Talle " + talleNombre + "</span>" +
                    "<br><small class='text-muted'>" +
                        "Efectivo: $" + pt.precioContado + " | " +
                        "Stock: <span class='badge " + badgeClass + "'>" + stock + "</span>" +
                    "</small>" +
                "</a>";
        });
    }

    document.getElementById("resultados").innerHTML = html;
}

document.getElementById("resultados").addEventListener("click", function(e) {
    e.preventDefault();
    let item = e.target.closest(".producto-item");
    if (!item) return;

    seleccionarProducto(
        item.dataset.id,
        item.dataset.descripcion,
        item.dataset.talle,
        item.dataset.stock,
        item.dataset.precioContado,
        item.dataset.precioTarjeta,
        item.dataset.precioCc
    );
});

function seleccionarProducto(id, descripcion, talle, stock, pContado, pTarjeta, pCC) {
    productoTalleSeleccionado = Number(id);
    productoDescripcion = descripcion + (talle ? " - Talle " + talle : "");
    precioContado = parseFloat(pContado);
    precioTarjeta = parseFloat(pTarjeta);
    precioCC = parseFloat(pCC);

    document.getElementById("buscarProducto").value = productoDescripcion;
    document.getElementById("talle").value = talle || "-";
    document.getElementById("stock").value = Number(stock);
    document.getElementById("cantidad").value = 1;
    document.getElementById("cantidad").max = stock;
    document.getElementById("precio").value = pContado;
    document.getElementById("textoPrecio").textContent =
        `Tarjeta: $${pTarjeta} | C/C: $${pCC}`;

    document.getElementById("resultados").innerHTML = "";
    document.getElementById("cantidad").focus();
}

// ==========================================
// BÚSQUEDA DE CLIENTES
// ==========================================
document.getElementById("buscarCliente").addEventListener("keyup", function() {
    let q = this.value;

    if (q.length < 2) {
        document.getElementById("resultadosCliente").innerHTML = "";
        return;
    }

    fetch("${pageContext.request.contextPath}/clientes/buscar?q=" + encodeURIComponent(q))
        .then(res => res.json())
        .then(data => {
            let html = "";

            data.forEach(c => {
                html +=
                    "<a href='#' class='list-group-item list-group-item-action cliente-item' " +
                    "data-id='" + c.id + "' " +
                    "data-nombre='" + (c.nombre || '') + "' " +
                    "data-apellido='" + (c.apellido || '') + "'>" +
                    (c.nombre || '') + " " + (c.apellido || '') +
                    "</a>";
            });

            document.getElementById("resultadosCliente").innerHTML = html;
        });
});

document.getElementById("resultadosCliente").addEventListener("click", function(e) {
    e.preventDefault();
    let item = e.target.closest(".cliente-item");
    if (!item) return;

    seleccionarCliente(
        item.dataset.id,
        item.dataset.nombre,
        item.dataset.apellido
    );
});

function seleccionarCliente(id, nombre, apellido) {
    clienteSeleccionado = id;
    document.getElementById("clienteId").value = id;
    document.getElementById("buscarCliente").value = nombre + " " + apellido;
    document.getElementById("resultadosCliente").innerHTML = "";
}

// ==========================================
// ESCUCHAR CAMBIO DE FORMA DE PAGO
// ==========================================
document.getElementById("formaPago").addEventListener("change", actualizarPreciosFinal);

// Cerrar resultados al hacer clic fuera
document.addEventListener('click', function(e) {
    if (!e.target.closest('#buscarProducto') && !e.target.closest('#resultados')) {
        document.getElementById('resultados').innerHTML = '';
    }
    if (!e.target.closest('#buscarCliente') && !e.target.closest('#resultadosCliente')) {
        document.getElementById('resultadosCliente').innerHTML = '';
    }
});

// ==========================================
// GUARDAR NUEVO CLIENTE
// ==========================================
function guardarNuevoCliente(event) {
    event.preventDefault();

    const btnGuardar = document.getElementById('btnGuardarCliente');
    btnGuardar.disabled = true;
    btnGuardar.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Guardando...';

    const nuevoCliente = {
        nombre: document.getElementById('clienteNombre').value.trim(),
        apellido: document.getElementById('clienteApellido').value.trim(),
        dni: document.getElementById('clienteDni').value.trim(),
        telefono: document.getElementById('clienteTelefono').value.trim(),
        email: document.getElementById('clienteEmail').value.trim(),
        direccion: document.getElementById('clienteDireccion').value.trim(),
        condicionIva: document.getElementById('clienteCondicionIva').value,
    };

    fetch('${pageContext.request.contextPath}/clientes/guardar-ajax', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('[name="${_csrf.parameterName}"]').value
        },
        body: JSON.stringify(nuevoCliente)
    })
    .then(response => {
        if (!response.ok) {
            return response.json().then(err => {
                throw new Error(err.error || 'Error al guardar el cliente');
            });
        }
        return response.json();
    })
    .then(cliente => {
        // Cliente guardado exitosamente
        console.log('Cliente guardado:', cliente);

        // Seleccionar automáticamente el cliente recién creado
        seleccionarCliente(cliente.id, cliente.nombre, cliente.apellido);

        // Cerrar modal
        const modal = bootstrap.Modal.getInstance(document.getElementById('modalNuevoCliente'));
        modal.hide();

        // Limpiar formulario
        document.getElementById('formNuevoCliente').reset();
        document.getElementById('errorNuevoCliente').classList.add('d-none');

        // Mensaje de éxito
        alert('✅ Cliente creado correctamente');
    })
    .catch(error => {
        console.error('Error:', error);

        const errorDiv = document.getElementById('errorNuevoCliente');
        errorDiv.textContent = '❌ ' + error.message;
        errorDiv.classList.remove('d-none');
    })
    .finally(() => {
        btnGuardar.disabled = false;
        btnGuardar.innerHTML = '<i class="fas fa-save"></i> Guardar Cliente';
    });
}

// Limpiar errores al cerrar el modal
document.getElementById('modalNuevoCliente').addEventListener('hidden.bs.modal', function () {
    document.getElementById('formNuevoCliente').reset();
    document.getElementById('errorNuevoCliente').classList.add('d-none');
});

// Inicializar
renderTabla();
</script>

<style>
@media (max-width: 1000px) {
    .row > .col-lg-9,
    .row > .col-lg-3 {
        flex: 0 0 100%;
        max-width: 100%;
        margin-top: 1rem;
    }

    table.table {
        display: block;
        overflow-x: auto;
        white-space: nowrap;
        -webkit-overflow-scrolling: touch;
    }
}

#resultados, #resultadosCliente {
    box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    border-radius: 4px;
}

.producto-item, .cliente-item {
    cursor: pointer;
    transition: background-color 0.2s;
}

.producto-item:hover, .cliente-item:hover {
    background-color: #f0f9ff !important;
}
</style>

<!-- ========================================== -->
<!-- MODAL NUEVO CLIENTE -->
<!-- ========================================== -->
<div class="modal fade" id="modalNuevoCliente" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">
                    <i class="fas fa-user-plus"></i> Nuevo Cliente
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <form id="formNuevoCliente" onsubmit="guardarNuevoCliente(event)">
                <div class="modal-body">

                    <div class="row">

                        <!-- NOMBRE -->
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Nombre</label>
                            <input type="text"
                                   id="clienteNombre"
                                   class="form-control"
                                   placeholder="Juan">
                        </div>

                        <!-- APELLIDO -->
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Apellido</label>
                            <input type="text"
                                   id="clienteApellido"
                                   class="form-control"
                                   placeholder="Pérez">
                        </div>

                        <!-- DNI -->
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">DNI</label>
                            <input type="text"
                                   id="clienteDni"
                                   class="form-control"
                                   placeholder="12345678">
                            <small class="text-muted">Solo números, sin puntos</small>
                        </div>

                        <!-- TELÉFONO -->
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Teléfono</label>
                            <input type="tel"
                                   id="clienteTelefono"
                                   class="form-control"
                                   placeholder="3512345678">
                        </div>

                        <!-- EMAIL -->
                        <div class="col-md-12 mb-3">
                            <label class="form-label fw-semibold">Email</label>
                            <input type="email"
                                   id="clienteEmail"
                                   class="form-control"
                                   placeholder="cliente@ejemplo.com">
                        </div>

                        <!-- DIRECCIÓN -->
                        <div class="col-md-12 mb-3">
                            <label class="form-label fw-semibold">Dirección</label>
                            <input type="text"
                                   id="clienteDireccion"
                                   class="form-control"
                                   placeholder="Calle 123">
                        </div>

                        <!-- CONDICIÓN IVA -->
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Condición IVA</label>
                            <select id="clienteCondicionIva"
                                    class="form-select">
                                <option value="CONSUMIDOR_FINAL" selected>Consumidor Final</option>
                                <option value="RESPONSABLE_INSCRIPTO">Responsable Inscripto</option>
                            </select>
                        </div>


                    </div>

                    <!-- Mensaje de error -->
                    <div id="errorNuevoCliente" class="alert alert-danger d-none"></div>

                </div>

                <div class="modal-footer">
                    <button type="button"
                            class="btn btn-secondary"
                            data-bs-dismiss="modal">
                        Cancelar
                    </button>
                    <button type="submit"
                            class="btn btn-primary"
                            id="btnGuardarCliente">
                        <i class="fas fa-save"></i> Guardar Cliente
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>


