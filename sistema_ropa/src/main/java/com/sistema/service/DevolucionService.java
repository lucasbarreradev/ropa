package com.sistema.service;

import com.sistema.model.*;
import com.sistema.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class DevolucionService {

    private final DevolucionRepository devolucionRepo;
    private final VentaRepository ventaRepo;
    private final VentaItemRepository ventaItemRepo;
    private final ProductoTalleRepository productoTalleRepo;
    private final MovimientoInventarioService movimientoService;

    public DevolucionService(DevolucionRepository devolucionRepo,
                             VentaRepository ventaRepo,
                             VentaItemRepository ventaItemRepo,
                             ProductoTalleRepository productoTalleRepo,
                             MovimientoInventarioService movimientoService) {
        this.devolucionRepo = devolucionRepo;
        this.ventaRepo = ventaRepo;
        this.ventaItemRepo = ventaItemRepo;
        this.productoTalleRepo = productoTalleRepo;
        this.movimientoService = movimientoService;
    }

    // ==========================================
    // CREAR DEVOLUCIÓN
    // ==========================================
    public Devolucion crear(Long ventaId,
                            List<Long> ventaItemIds,
                            List<Integer> cantidades,
                            Devolucion.MotivoDevolucion motivo,
                            String observaciones) {

        Venta venta = ventaRepo.findById(ventaId)
                .orElseThrow(() -> new IllegalArgumentException("Venta no encontrada"));

        if (venta.getEstado() != Venta.Estado.COMPLETADA) {
            throw new IllegalStateException("Solo se pueden devolver ventas completadas");
        }

        // Validar antigüedad (15 días)
        if (venta.getFechaVenta().isBefore(LocalDateTime.now().minusDays(15))) {
            throw new IllegalStateException("La venta tiene más de 15 días. No se aceptan devoluciones.");
        }

        Devolucion devolucion = new Devolucion();
        devolucion.setCodigo(generarCodigo());
        devolucion.setVenta(venta);
        devolucion.setFecha(LocalDateTime.now());
        devolucion.setMotivo(motivo);
        devolucion.setObservaciones(observaciones);
        devolucion.setEstado(Devolucion.EstadoDevolucion.PENDIENTE);

        // Agregar items
        for (int i = 0; i < ventaItemIds.size(); i++) {
            Long ventaItemId = ventaItemIds.get(i);
            Integer cantidadADevolver = cantidades.get(i);

            if (cantidadADevolver == null || cantidadADevolver <= 0) {
                continue; // Saltar items sin cantidad
            }

            VentaItem ventaItem = ventaItemRepo.findById(ventaItemId)
                    .orElseThrow(() -> new IllegalArgumentException("Item de venta no encontrado"));

            // Validar que pertenezca a esta venta
            if (!ventaItem.getVenta().getId().equals(ventaId)) {
                throw new IllegalArgumentException("El item no pertenece a esta venta");
            }

            // Validar cantidad disponible para devolver
            if (!ventaItem.puedeDevolver(cantidadADevolver)) {
                throw new IllegalStateException(
                        String.format("Solo se pueden devolver %d unidades de '%s - Talle %s'",
                                ventaItem.getCantidadNeta(),
                                ventaItem.getProductoTalle().getProducto().getDescripcion(),
                                ventaItem.getProductoTalle().getTalle().getNombre())
                );
            }

            DevolucionItem devItem = new DevolucionItem();
            devItem.setVentaItem(ventaItem);
            devItem.setCantidadDevuelta(cantidadADevolver);
            devItem.setPrecioUnitario(ventaItem.getPrecioUnitario());
            devItem.calcularSubtotal();

            devolucion.agregarItem(devItem);
        }

        if (devolucion.getItems().isEmpty()) {
            throw new IllegalArgumentException("Debe seleccionar al menos un producto para devolver");
        }

        devolucion.calcularTotal();
        return devolucionRepo.save(devolucion);
    }

    // ==========================================
    // APROBAR DEVOLUCIÓN (devuelve stock)
    // ==========================================
    @Transactional
    public void aprobar(Long devolucionId) {

        Devolucion devolucion = devolucionRepo.findById(devolucionId)
                .orElseThrow(() -> new IllegalArgumentException("Devolución no encontrada"));

        if (devolucion.getEstado() != Devolucion.EstadoDevolucion.PENDIENTE) {
            throw new IllegalStateException("Solo se pueden aprobar devoluciones pendientes");
        }

        Venta venta = devolucion.getVenta();

        // Devolver stock y marcar items como devueltos
        for (DevolucionItem devItem : devolucion.getItems()) {
            VentaItem ventaItem = devItem.getVentaItem();
            ProductoTalle productoTalle = ventaItem.getProductoTalle();

            // Devolver stock
            productoTalle.setStock(productoTalle.getStock() + devItem.getCantidadDevuelta());
            productoTalleRepo.save(productoTalle);

            // Marcar como devuelto en venta_item
            ventaItem.setCantidadDevuelta(
                    ventaItem.getCantidadDevuelta() + devItem.getCantidadDevuelta()
            );
            ventaItemRepo.save(ventaItem);

            // Registrar movimiento
            movimientoService.registrarDevolucion(
                    productoTalle.getId(),
                    devItem.getCantidadDevuelta(),
                    "Devolución " + devolucion.getCodigo()
            );
        }

        devolucion.setEstado(Devolucion.EstadoDevolucion.APROBADA);
        devolucionRepo.save(devolucion);

        boolean todosDevueltos = venta.getItems().stream()
                .allMatch(item -> item.getCantidad().equals(item.getCantidadDevuelta()));

        if (todosDevueltos && venta.getEstado() == Venta.Estado.COMPLETADA) {
            venta.setFechaAnulacion(LocalDateTime.now());
            venta.setNota((venta.getNota() != null ? venta.getNota() + "\n" : "")
                    + "Todos los items fueron devueltos el " + LocalDateTime.now());
            ventaRepo.save(venta);
        }
    }

    // ==========================================
    // RECHAZAR DEVOLUCIÓN
    // ==========================================
    public void rechazar(Long devolucionId, String motivo) {
        Devolucion devolucion = devolucionRepo.findById(devolucionId)
                .orElseThrow(() -> new IllegalArgumentException("Devolución no encontrada"));

        if (devolucion.getEstado() != Devolucion.EstadoDevolucion.PENDIENTE) {
            throw new IllegalStateException("Solo se pueden rechazar devoluciones pendientes");
        }

        devolucion.setEstado(Devolucion.EstadoDevolucion.RECHAZADA);
        devolucion.setObservaciones(
                (devolucion.getObservaciones() != null ? devolucion.getObservaciones() + "\n" : "")
                        + "RECHAZADA: " + motivo
        );
        devolucionRepo.save(devolucion);
    }

    // ==========================================
    // LISTADOS
    // ==========================================
    public List<Devolucion> listarTodas() {
        return devolucionRepo.findAllByOrderByFechaDesc();
    }

    public List<Devolucion> listarPorVenta(Long ventaId) {
        return devolucionRepo.findByVentaIdOrderByFechaDesc(ventaId);
    }

    public List<Devolucion> listarPorEstado(Devolucion.EstadoDevolucion estado) {
        return devolucionRepo.findByEstadoOrderByFechaDesc(estado);
    }

    public Devolucion buscarPorId(Long id) {
        return devolucionRepo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Devolución no encontrada"));
    }

    private String generarCodigo() {
        return "DEV-" + System.currentTimeMillis();
    }
}