package com.sistema.controller;

import com.sistema.model.*;
import com.sistema.repository.*;
import com.sistema.service.TicketService;
import com.sistema.service.VentaService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/ventas")
public class VentaController {

    private final VentaService ventaService;
    private final ProductoRepository productoRepo;
    private final ClienteRepository clienteRepo;
    private final VentaRepository ventaRepo;
    private final VentaItemRepository ventaItemRepo;
    private final ProductoTalleRepository productoTalleRepo;
    private final TicketService ticketService;

    public VentaController(VentaService ventaService,
                           ProductoRepository productoRepo,
                           ClienteRepository clienteRepo,
                           VentaRepository ventaRepo,
                           VentaItemRepository ventaItemRepo,
                           ProductoTalleRepository productoTalleRepo,
                           TicketService ticketService) {
        this.ventaService = ventaService;
        this.productoRepo = productoRepo;
        this.clienteRepo = clienteRepo;
        this.ventaRepo = ventaRepo;
        this.ventaItemRepo = ventaItemRepo;
        this.productoTalleRepo = productoTalleRepo;
        this.ticketService = ticketService;
    }

    // ==========================================
    // LISTAR VENTAS
    @GetMapping
    public String listarVentas(Model model) {
        model.addAttribute("ventas", ventaService.listarVentasNoAnuladas());
        return "venta/listar";
    }
    // ==========================================
    // ==========================================
    // FORM NUEVA VENTA
    // ==========================================
    @GetMapping("/nueva")
    public String nuevaVenta(
            @RequestParam(required = false) Long clienteId,
            Model model) {

        Venta venta = new Venta();

        if (clienteId != null) {
            Cliente cliente = clienteRepo.findById(clienteId).orElse(null);
            venta.setCliente(cliente);
        }

        model.addAttribute("venta", venta);
        model.addAttribute("productos", productoRepo.findAll());
        model.addAttribute("clientes", clienteRepo.findAll());
        return "venta/form";
    }



    // ==========================================
    // CREAR VENTA DIRECTA
    // ==========================================
    @PostMapping("/guardar")
    public String guardarVenta(
            @RequestParam(required = false) Long clienteId,
            @RequestParam FormaPago formaPago,
            @RequestParam(required = false) String nota,
            @RequestParam(required = false) List<Long> productoTalleIds,
            @RequestParam(required = false) List<Integer> cantidades,
            @RequestParam(required = false) List<BigDecimal> descuentos,
            RedirectAttributes ra
    ) {
        try {
            if (productoTalleIds == null || productoTalleIds.isEmpty()) {
                throw new IllegalArgumentException("Debe agregar al menos un producto");
            }

            if (cantidades == null || cantidades.isEmpty()) {
                throw new IllegalArgumentException("Debe ingresar cantidades");
            }

            if (productoTalleIds.size() != cantidades.size()) {
                throw new IllegalArgumentException("Datos inválidos de productos");
            }

            List<VentaItem> items = new ArrayList<>();

            for (int i = 0; i < productoTalleIds.size(); i++) {

                ProductoTalle productoTalle = productoTalleRepo.findById(productoTalleIds.get(i))
                        .orElseThrow(() -> new IllegalArgumentException("Producto/Talle no encontrado"));

                VentaItem item = new VentaItem();
                item.setProductoTalle(productoTalle);  // ← CAMBIO
                item.setCantidad(cantidades.get(i));

                if (descuentos != null && descuentos.size() == productoTalleIds.size()) {
                    item.setDescuentoPct(descuentos.get(i));
                } else {
                    item.setDescuentoPct(BigDecimal.ZERO);
                }

                items.add(item);
            }

            Venta venta = ventaService.crearVentaDirecta(
                    clienteId,
                    items,
                    formaPago,
                    nota
            );

            ra.addFlashAttribute("mensaje", "Venta realizada correctamente");
            return "redirect:/ventas?ticketId=" + venta.getId();

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/ventas/nueva";
        }
    }

    @GetMapping("/ticket/{id}")
    public void generarTicket(
            @PathVariable Long id,
            HttpServletResponse response) throws Exception {

        Venta venta = ventaRepo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Venta no encontrada"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
                "inline; filename=ticket_" + venta.getCodigo() + ".pdf");

        ticketService.generarTicketPdf(venta, response.getOutputStream());
    }


    // ==========================================
    // CREAR VENTA DESDE PRESUPUESTO
    // ==========================================
    @PostMapping("/desde-presupuesto/{id}")
    public String venderDesdePresupuesto(
            @PathVariable Long id,
            @RequestParam FormaPago formaPago,
            @RequestParam(required = false) String nota,
            RedirectAttributes ra
    ) {
        try {
            ventaService.crearDesdePresupuesto(id, formaPago);
            ra.addFlashAttribute("mensaje", "Venta creada desde presupuesto");
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/ventas";
    }

    // ==========================================
    // VER DETALLE DE VENTA
    // ==========================================

    @GetMapping("/detalle/{id}")
    public String verVenta(@PathVariable Long id, Model model) {

        Venta venta = ventaRepo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Venta no encontrada"));

        // ✅ Esto devuelve neto, IVA, total y el map de ivas
        TotalesConIva totales = ventaService.calcularTotalesConIvaMap(venta);

        model.addAttribute("venta", venta);
        model.addAttribute("totales", totales);  //
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        model.addAttribute("fechaVentaFmt",
                venta.getFechaVenta().format(formatter));

        return "venta/detalleVenta";
    }


    @PostMapping("/anular")
    public String anularVenta(
            @RequestParam Long id,
            RedirectAttributes ra
    ) {
        try {
            ventaService.anularVenta(id);
            ra.addFlashAttribute("mensaje", "Venta anulada correctamente");
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/ventas";
    }






    }
