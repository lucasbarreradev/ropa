package com.sistema.controller;

import com.sistema.model.Devolucion;
import com.sistema.model.Venta;
import com.sistema.repository.VentaRepository;
import com.sistema.service.DevolucionService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/devoluciones")
public class DevolucionController {

    private final DevolucionService devolucionService;
    private final VentaRepository ventaRepo;

    public DevolucionController(DevolucionService devolucionService,
                                VentaRepository ventaRepo) {
        this.devolucionService = devolucionService;
        this.ventaRepo = ventaRepo;
    }

    // ==========================================
    // LISTAR DEVOLUCIONES
    // ==========================================
    @GetMapping
    public String listar(@RequestParam(required = false) String estado,
                         Model model) {

        List<Devolucion> devoluciones;

        if (estado != null && !estado.isEmpty()) {
            Devolucion.EstadoDevolucion estadoEnum = Devolucion.EstadoDevolucion.valueOf(estado);
            devoluciones = devolucionService.listarPorEstado(estadoEnum);
        } else {
            devoluciones = devolucionService.listarTodas();
        }

        // Formatear fechas
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        Map<Long, String> fechasFormateadas = new HashMap<>();

        for (Devolucion d : devoluciones) {
            fechasFormateadas.put(d.getId(), d.getFecha().format(formatter));
        }

        model.addAttribute("devoluciones", devoluciones);
        model.addAttribute("fechasFormateadas", fechasFormateadas);
        model.addAttribute("filtroEstado", estado);

        return "devolucion/listar";
    }

    // ==========================================
    // PANTALLA DE BÚSQUEDA
    // ==========================================
    @GetMapping("/buscar")
    public String buscar(Model model) {
        return "ticket/buscar";
    }

    // ==========================================
    // BUSCAR VENTA POR CÓDIGO
    // ==========================================
    @PostMapping("/buscar")
    public String buscarPorCodigo(
            @RequestParam String codigoVenta,
            RedirectAttributes ra) {

        try {
            Venta venta = ventaRepo.findByCodigo(codigoVenta.trim().toUpperCase())
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Ticket no encontrado. Verificá el código."));

            if (venta.getEstado() != Venta.Estado.COMPLETADA) {
                throw new IllegalStateException("Esta venta no está completada");
            }

            // Verificar antigüedad (15 días)
            if (venta.getFechaVenta().isBefore(LocalDateTime.now().minusDays(15))) {
                throw new IllegalStateException(
                        "El ticket tiene más de 15 días. No se aceptan devoluciones.");
            }

            return "redirect:/devoluciones/nueva/" + venta.getId();

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/devoluciones/buscar";
        }
    }

    // ==========================================
    // FORM NUEVA DEVOLUCIÓN
    // ==========================================
    @GetMapping("/nueva/{ventaId}")
    public String nueva(@PathVariable Long ventaId, Model model) {

        Venta venta = ventaRepo.findById(ventaId)
                .orElseThrow(() -> new IllegalArgumentException("Venta no encontrada"));

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String fechaVentaFmt = venta.getFechaVenta().format(formatter);

        model.addAttribute("venta", venta);
        model.addAttribute("fechaVentaFmt", fechaVentaFmt);
        model.addAttribute("motivos", Devolucion.MotivoDevolucion.values());

        return "devolucion/form";
    }

    // ==========================================
    // GUARDAR DEVOLUCIÓN
    // ==========================================
    @PostMapping("/guardar")
    public String guardar(
            @RequestParam Long ventaId,
            @RequestParam(required = false) List<Long> ventaItemIds,
            @RequestParam(required = false) List<Integer> cantidades,
            @RequestParam(required = false) Devolucion.MotivoDevolucion motivo,
            @RequestParam(required = false) String observaciones,
            RedirectAttributes ra) {

        if (motivo == null) {
            ra.addFlashAttribute("error", "Debe seleccionar un motivo de devolución");
            return "redirect:/devoluciones/nueva/" + ventaId;
        }

        try {
            if (ventaItemIds == null || ventaItemIds.isEmpty()) {
                throw new IllegalArgumentException("Debe seleccionar al menos un producto");
            }

            Devolucion devolucion = devolucionService.crear(
                    ventaId,
                    ventaItemIds,
                    cantidades,
                    motivo,
                    observaciones
            );

            ra.addFlashAttribute("mensaje",
                    "Devolución creada: " + devolucion.getCodigo() + " - Estado: PENDIENTE");

            return "redirect:/devoluciones";

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/devoluciones/nueva/" + ventaId;
        }
    }

    // ==========================================
    // APROBAR DEVOLUCIÓN
    // ==========================================
    @PostMapping("/aprobar")
    public String aprobar(@RequestParam Long id, RedirectAttributes ra) {

        try {
            devolucionService.aprobar(id);
            ra.addFlashAttribute("mensaje", "✅ Devolución aprobada. Stock devuelto correctamente.");

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/devoluciones";
    }

    // ==========================================
    // RECHAZAR DEVOLUCIÓN
    // ==========================================
    @PostMapping("/rechazar")
    public String rechazar(@RequestParam Long id,
                           @RequestParam String motivoRechazo,
                           RedirectAttributes ra) {

        try {
            devolucionService.rechazar(id, motivoRechazo);
            ra.addFlashAttribute("mensaje", "❌ Devolución rechazada.");

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/devoluciones";
    }
}