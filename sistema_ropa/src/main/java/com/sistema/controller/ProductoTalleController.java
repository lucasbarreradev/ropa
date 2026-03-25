package com.sistema.controller;

import com.sistema.model.FormaPago;
import com.sistema.model.Producto;
import com.sistema.model.ProductoTalle;
import com.sistema.service.MovimientoInventarioService;
import com.sistema.service.ProductoService;
import com.sistema.service.ProductoTalleService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/talles")
public class ProductoTalleController {

    private final ProductoService productoService;
    private final ProductoTalleService talleService;
    private final MovimientoInventarioService movimientoService;

    public ProductoTalleController(
            ProductoService productoService,
            ProductoTalleService talleService,
            MovimientoInventarioService movimientoService
    ) {
        this.productoService = productoService;
        this.talleService = talleService;
        this.movimientoService = movimientoService;
    }

    // ==========================================
    // LISTAR TALLES DE UN PRODUCTO
    // ==========================================
    @GetMapping("/producto/{productoId}")
    public String listarPorProducto(@PathVariable Long productoId,
                                    Model model,
                                    RedirectAttributes ra) {

        Producto producto = productoService.getProductoById(productoId).orElse(null);

        if (producto == null) {
            ra.addFlashAttribute("error", "Producto no encontrado");
            return "redirect:/productos";
        }

        model.addAttribute("producto", producto);
        model.addAttribute("talles",
                talleService.findByProducto(productoId));

        return "talle/listar";
    }

    // ==========================================
    // FORM NUEVO TALLE
    // ==========================================
    @GetMapping("/nuevo/{productoId}")
    public String nuevo(@PathVariable Long productoId,
                        Model model,
                        RedirectAttributes ra) {

        Producto producto = productoService.getProductoById(productoId).orElse(null);

        if (producto == null) {
            ra.addFlashAttribute("error", "Producto no encontrado");
            return "redirect:/productos";
        }

        ProductoTalle talle = new ProductoTalle();
        talle.setProducto(producto);

        model.addAttribute("talle", talle);
        model.addAttribute("formasPago", FormaPago.values());

        return "talle/form";
    }

    // ==========================================
    // GUARDAR TALLE
    // ==========================================
    @PostMapping("/guardar")
    public String guardar(@ModelAttribute ProductoTalle talle,
                          @RequestParam Long productoId,
                          @RequestParam(required = false) Integer stockInicial,
                          RedirectAttributes ra) {

        Producto producto = productoService.getProductoById(productoId)
                .orElseThrow(() -> new IllegalArgumentException("Producto no encontrado"));

        talle.setProducto(producto);

        // Guardar talle
        ProductoTalle guardado = talleService.save(talle);

        // Registrar stock inicial
        if (stockInicial != null && stockInicial > 0) {
            movimientoService.registrarVenta(
                    guardado.getId(),
                    stockInicial,
                    "Stock inicial"
            );
        }

        ra.addFlashAttribute("mensaje", "Talle creado correctamente");
        return "redirect:/talles/producto/" + productoId;
    }

    // ==========================================
    // EDITAR TALLE
    // ==========================================
    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id,
                         Model model,
                         RedirectAttributes ra) {

        ProductoTalle talle = talleService.getById(id).orElse(null);

        if (talle == null) {
            ra.addFlashAttribute("error", "Talle no encontrado");
            return "redirect:/productos";
        }

        model.addAttribute("talle", talle);
        model.addAttribute("formasPago", FormaPago.values());

        return "talle/form";
    }

    // ==========================================
    // ACTUALIZAR TALLE
    // ==========================================
    @PostMapping("/actualizar/{id}")
    public String actualizar(@PathVariable Long id,
                             @ModelAttribute ProductoTalle talle,
                             RedirectAttributes ra) {

        ProductoTalle existente = talleService.getById(id)
                .orElseThrow(() -> new IllegalArgumentException("Talle no encontrado"));

        talle.setId(id);
        talle.setProducto(existente.getProducto());

        talleService.update(talle);

        ra.addFlashAttribute("mensaje", "Talle actualizado correctamente");
        return "redirect:/talles/producto/" + existente.getProducto().getId();
    }

    // ==========================================
    // ELIMINAR TALLE
    // ==========================================
    @PostMapping("/eliminar/{id}")
    public String eliminar(@PathVariable Long id,
                           RedirectAttributes ra) {

        ProductoTalle talle = talleService.getById(id).orElse(null);

        if (talle == null) {
            ra.addFlashAttribute("error", "Talle no encontrado");
            return "redirect:/productos";
        }

        talleService.delete(id);

        ra.addFlashAttribute("mensaje", "Talle eliminado");
        return "redirect:/talles/producto/" + talle.getProducto().getId();
    }

    // ==========================================
    // BUSCAR POR CÓDIGO DE BARRAS (SCANNER)
    // ==========================================
    @GetMapping("/buscar")
    @ResponseBody
    public ProductoTalle buscarPorCodigo(@RequestParam String codigo) {
        return talleService.findByCodigoBarras(codigo)
                .orElse(null);
    }
}

