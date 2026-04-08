package com.sistema.service;

import com.sistema.model.*;
import com.sistema.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;

@Service
@Transactional
public class VentaService {

    private final VentaRepository ventaRepo;
    private final ProductoTalleRepository productoTalleRepo;
    private final ClienteRepository clienteRepo;
    private final PresupuestoRepository presupuestoRepo;
    private final MovimientoInventarioService movimientoService;
    private final DevolucionRepository devolucionRepo;
    public VentaService(VentaRepository ventaRepo,
                        ProductoTalleRepository productoTalleRepo,
                        ClienteRepository clienteRepo,
                        PresupuestoRepository presupuestoRepo,
                        MovimientoInventarioService movimientoService,
                        DevolucionRepository devolucionRepo) {
        this.ventaRepo = ventaRepo;
        this.productoTalleRepo = productoTalleRepo;
        this.clienteRepo = clienteRepo;
        this.presupuestoRepo = presupuestoRepo;
        this.movimientoService = movimientoService;
        this.devolucionRepo = devolucionRepo;
    }

    // =====================================================
    // 1️⃣ VENTA DIRECTA
    // =====================================================
    public Venta crearVentaDirecta(Long clienteId,
                                   List<VentaItem> items,
                                   FormaPago formaPago,
                                   String nota) {

        if (items == null || items.isEmpty()) {
            throw new IllegalArgumentException("La venta debe tener al menos un item");
        }

        Cliente cliente = null;
        if (clienteId != null) {
            cliente = clienteRepo.findById(clienteId)
                    .orElseThrow(() -> new IllegalArgumentException("Cliente no encontrado"));
        }

        Venta venta = new Venta(
                generarCodigoVenta(),
                cliente,
                Venta.Origen.DIRECTA,
                formaPago,
                null,
                nota
        );

        // Procesar items
        for (VentaItem item : items) {

            ProductoTalle productoTalle = productoTalleRepo.findById(
                    item.getProductoTalle().getId()
            ).orElseThrow(() -> new IllegalArgumentException("Producto/Talle no encontrado"));

            // Validar stock
            if (productoTalle.getStock() < item.getCantidad()) {
                throw new IllegalStateException(
                        "Stock insuficiente para " + productoTalle.getProducto().getDescripcion()
                                + " talle " + productoTalle.getTalle().getNombre()
                );
            }

            // Asegurar entidad gestionada
            item.setProductoTalle(productoTalle);

            // Obtener precio según forma de pago
            BigDecimal precio = productoTalle.getPrecioSegunFormaPago(formaPago);

            if (precio == null) {
                throw new IllegalStateException("El producto no tiene precio configurado");
            }

            // Snapshot del precio actual
            item.setPrecioUnitario(precio);
            item.setCostoUnitario(
                    productoTalle.getPrecioCompra() != null
                            ? productoTalle.getPrecioCompra()
                            : BigDecimal.ZERO
            );
            item.setAlicuotaIva(productoTalle.getProducto().getTipoIva().getPorcentaje());

            // Calcular subtotal
            item.calcularSubtotal();

            // Asociar item a la venta
            venta.agregarItem(item);


            // Movimiento de inventario
            movimientoService.registrarVenta(
                    productoTalle.getId(),
                    item.getCantidad(),
                    "Venta " + venta.getCodigo()
            );
        }

        venta.calcularTotales();
        venta.setEstado(Venta.Estado.COMPLETADA);
        return ventaRepo.save(venta);
    }

    // =====================================================
    // 2️⃣ VENTA DESDE PRESUPUESTO
    // =====================================================
    @Transactional
    public Venta crearDesdePresupuesto(Long presupuestoId,
                                       FormaPago formaPago) {

        Presupuesto p = presupuestoRepo.findById(presupuestoId)
                .orElseThrow(() -> new IllegalArgumentException("Presupuesto no encontrado"));

        if (p.getEstado() != EstadoPresupuesto.PENDIENTE) {
            throw new IllegalStateException(
                    "Solo se puede vender un presupuesto PENDIENTE");
        }

        Venta venta = new Venta(
                generarCodigoVenta(),
                p.getCliente(),
                Venta.Origen.PRESUPUESTO,
                formaPago,
                p.getCodigo(),
                "Generada desde presupuesto " + p.getCodigo()
        );

        // Items
        for (DetallePresupuesto dp : p.getDetalles()) {

            ProductoTalle productoTalle = productoTalleRepo.findById(
                    dp.getProductoTalle().getId()
            ).orElseThrow(() -> new IllegalArgumentException("Producto/Talle no encontrado"));

            // Validar stock
            if (productoTalle.getStock() < dp.getCantidad()) {
                throw new IllegalStateException(
                        "Stock insuficiente para " + productoTalle.getProducto().getDescripcion()
                                + " talle " + productoTalle.getTalle().getNombre()
                );
            }

            BigDecimal precio = productoTalle.getPrecioSegunFormaPago(formaPago);

            if (precio == null) {
                throw new IllegalStateException("El producto no tiene precio configurado");
            }

            VentaItem item = new VentaItem();
            item.setPrecioUnitario(precio);
            item.setProductoTalle(productoTalle);
            item.setCantidad(dp.getCantidad());
            item.setCostoUnitario(
                    productoTalle.getPrecioCompra() != null
                            ? productoTalle.getPrecioCompra()
                            : BigDecimal.ZERO
            );
            item.setDescuentoPct(dp.getDescuentoPct());
            item.setAlicuotaIva(productoTalle.getProducto().getTipoIva().getPorcentaje());
            item.calcularSubtotal();

            venta.agregarItem(item);

            movimientoService.registrarVenta(
                    productoTalle.getId(),
                    dp.getCantidad(),
                    "Venta desde presupuesto " + p.getCodigo()
            );
        }

        venta.calcularTotales();
        venta.setEstado(Venta.Estado.COMPLETADA);
        Venta ventaGuardada = ventaRepo.save(venta);

        p.setEstado(EstadoPresupuesto.VENDIDO);
        presupuestoRepo.save(p);

        return ventaGuardada;
    }

    // =====================================================
    // 3️⃣ ANULAR VENTA
    // =====================================================
    public void anularVenta(Long ventaId) {

        Venta venta = ventaRepo.findById(ventaId)
                .orElseThrow(() -> new IllegalArgumentException("Venta no encontrada"));

        if (venta.getEstado() != Venta.Estado.COMPLETADA) {
            throw new IllegalStateException(
                    "Solo se pueden anular ventas completadas");
        }

        for (VentaItem item : venta.getItems()) {
            movimientoService.registrarDevolucion(
                    item.getProductoTalle().getId(),
                    item.getCantidad(),
                    "Anulación venta " + venta.getCodigo()
            );
        }

        venta.setEstado(Venta.Estado.ANULADA);
        venta.setFechaAnulacion(LocalDateTime.now());
        ventaRepo.save(venta);
    }

    public BigDecimal calcularTotalReal(Venta venta) {
        BigDecimal totalVenta = venta.getTotal();
        BigDecimal totalDevuelto = BigDecimal.ZERO;

        // Sumar todas las devoluciones aprobadas de esta venta
        List<Devolucion> devoluciones = devolucionRepo.findByVentaIdAndEstado(
                venta.getId(),
                Devolucion.EstadoDevolucion.APROBADA
        );

        for (Devolucion dev : devoluciones) {
            totalDevuelto = totalDevuelto.add(dev.getTotalDevuelto());
        }

        return totalVenta.subtract(totalDevuelto);
    }

    // =====================================================
    // CALCULAR GANANCIA REAL (descontando devoluciones)
    // =====================================================
    public BigDecimal calcularGananciaReal(Venta venta) {
        BigDecimal gananciaTotal = BigDecimal.ZERO;

        for (VentaItem item : venta.getItems()) {
            if (item.getCostoUnitario() == null) continue;

            // Cantidad neta (vendida - devuelta)
            Integer cantidadNeta = item.getCantidadNeta();

            if (cantidadNeta <= 0) continue;

            // Ganancia unitaria
            BigDecimal gananciaUnitaria = item.getPrecioUnitario()
                    .subtract(item.getCostoUnitario());

            // Ganancia total de este item (solo por lo que no se devolvió)
            BigDecimal gananciaItem = gananciaUnitaria
                    .multiply(BigDecimal.valueOf(cantidadNeta));

            gananciaTotal = gananciaTotal.add(gananciaItem);
        }

        return gananciaTotal;
    }

    // =====================================================
    // CALCULAR TOTALES DE MÚLTIPLES VENTAS
    // =====================================================
    public BigDecimal calcularTotalRealVentas(List<Venta> ventas) {
        return ventas.stream()
                .map(this::calcularTotalReal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public BigDecimal calcularGananciaRealVentas(List<Venta> ventas) {
        return ventas.stream()
                .map(this::calcularGananciaReal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // =====================================================
    // HELPERS
    // =====================================================
    public TotalesConIva calcularTotalesConIvaMap(Venta venta) {
        BigDecimal netoAcum = BigDecimal.ZERO;
        BigDecimal ivaAcum = BigDecimal.ZERO;
        Map<BigDecimal, BigDecimal> ivasMap = new HashMap<>();

        for (VentaItem item : venta.getItems()) {
            BigDecimal ivaRate = item.getAlicuotaIva();
            BigDecimal subtotal = item.getSubtotal();

            BigDecimal netoItem = subtotal.divide(
                    BigDecimal.ONE.add(ivaRate.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP)),
                    2,
                    RoundingMode.HALF_UP
            );

            BigDecimal ivaItem = subtotal.subtract(netoItem);

            netoAcum = netoAcum.add(netoItem);
            ivaAcum = ivaAcum.add(ivaItem);

            ivasMap.merge(ivaRate, ivaItem, BigDecimal::add);
        }

        BigDecimal total = netoAcum.add(ivaAcum);

        if (venta.getCliente() == null || venta.getCliente().getCondicionIva() == CondicionIva.CONSUMIDOR_FINAL) {
            netoAcum = total;
            ivaAcum = BigDecimal.ZERO;
            ivasMap.clear();
        }

        return new TotalesConIva(netoAcum, ivaAcum, total, ivasMap);
    }

    public List<Venta> listarVentasNoAnuladas() {
        return ventaRepo.findByEstadoNotOrderByFechaVentaDesc(Venta.Estado.ANULADA);
    }

    private String generarCodigoVenta() {
        return "VENTA-" + System.currentTimeMillis();
    }

    public BigDecimal calcularGananciaTotal(List<Venta> ventas) {
        return calcularGananciaRealVentas(ventas);
    }

}