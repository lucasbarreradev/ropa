package com.sistema.controller;

import com.sistema.model.*;
import com.sistema.repository.*;
import com.sistema.service.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/productos")
public class ProductoController {

    private final ProductoRepository productoRepo;
    private final TalleRepository talleRepo;
    private final TalleProductoRepository talleProductoRepo;
    private final ProveedorService proveedorService;
    private final EtiquetaService etiquetaService;
    private final TalleService talleService;
    private final ProductoService productoService;

    public ProductoController(ProductoRepository productoRepo,
                              TalleRepository talleRepo,
                              TalleProductoRepository talleProductoRepo,
                              ProveedorService proveedorService,
                              EtiquetaService etiquetaService,
                              TalleService talleService,
                              ProductoService productoService) {
        this.productoRepo = productoRepo;
        this.talleRepo = talleRepo;
        this.talleProductoRepo = talleProductoRepo;
        this.proveedorService = proveedorService;
        this.etiquetaService = etiquetaService;
        this.talleService = talleService;
        this.productoService = productoService;
    }

    // ==========================================
    // LISTAR PRODUCTOS
    // ==========================================
    @GetMapping
    public String listar(Model model) {
        model.addAttribute("productos", productoRepo.findAll());
        return "producto/listar";
    }

    // ==========================================
    // FORM NUEVO PRODUCTO
    // ==========================================
    @GetMapping("/nuevo")
    public String nuevo(
            @RequestParam(required = false) Long proveedorId,
            Model model) {
        Producto producto = (Producto) model.getAttribute("producto");

        if (producto == null) {
            producto = new Producto();
        }

        if (proveedorId != null) {
            proveedorService.getProveedorById(proveedorId)
                    .ifPresent(producto::setProveedor);
        }

        model.addAttribute("producto", producto);
        model.addAttribute("tiposIva", TipoIva.values());
        return "producto/form";
    }

    // ==========================================
    // GUARDAR PRODUCTO (sin talles todavía)
    // ==========================================
    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Producto producto,
                          @RequestParam(required = false) Long proveedorId,
                          RedirectAttributes ra) {
        producto.setId(null);

        if (proveedorId != null) {
            Proveedor proveedor = proveedorService
                    .getProveedorById(proveedorId)
                    .orElseThrow(() -> new RuntimeException("Proveedor no encontrado"));
            producto.setProveedor(proveedor);
        }

        Producto productoGuardado = productoService.saveProducto(producto);

        ra.addFlashAttribute(
                "mensaje",
                "Producto creado. Ahora agregá talles y precios."
        );

        return "redirect:/productos/" + productoGuardado.getId() + "/talles";
    }

    // ==========================================
    // GESTIONAR TALLES DEL PRODUCTO
    // ==========================================
    @GetMapping("/{id}/talles")
    public String gestionarTalles(@PathVariable Long id, Model model) {
        Producto producto = productoRepo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Producto no encontrado"));

        int stockTotal = producto.getTalles()
                .stream()
                .mapToInt(ProductoTalle::getStock)
                .sum();
        model.addAttribute("producto", producto);
        model.addAttribute("tallesProducto", talleProductoRepo.findByProductoId(id));

        // Agregar talles existentes para autocompletado
        model.addAttribute("tallesExistentes", talleService.listarTodos());
        model.addAttribute("stockTotal",stockTotal);
        return "producto/talles";
    }

    // ==========================================
    // AGREGAR TALLE AL PRODUCTO
    // ==========================================
    @PostMapping("/{id}/talles/agregar")
    public String agregarTalle(
            @PathVariable Long id,
            @RequestParam (required = false) String nombreTalle,  // ← Usuario escribe el talle
            @RequestParam (required = false) Integer stock,
            @RequestParam (required = false) BigDecimal precioContado,
            @RequestParam (required = false) BigDecimal precioTarjeta,
            @RequestParam (required = false) BigDecimal precioCuentaCorriente,
            @RequestParam (required = false) BigDecimal precioCompra,
            RedirectAttributes ra) {

        try {
            Producto producto = productoRepo.findById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Producto no encontrado"));

            // Obtener o crear el talle
            Talle talle = talleService.obtenerOCrearTalle(nombreTalle);

            // Verificar si ya existe esta combinación
            Optional<ProductoTalle> existente = talleProductoRepo
                    .findByProductoIdAndTalleId(id, talle.getId());

            if (existente.isPresent()) {
                ra.addFlashAttribute("error",
                        "Este producto ya tiene el talle " + talle.getNombre());
                return "redirect:/productos/" + id + "/talles";
            }

            if (precioTarjeta == null) {
                precioTarjeta = BigDecimal.ZERO;
            }

            if (precioCuentaCorriente == null) {
                precioCuentaCorriente = BigDecimal.ZERO;
            }

            if (precioCompra == null) {
                precioCompra = BigDecimal.ZERO;
            }

            if (precioContado == null) {
                precioContado = BigDecimal.ZERO;
            }

            // Crear ProductoTalle
            ProductoTalle productoTalle = new ProductoTalle(
                    producto,
                    talle,
                    stock,
                    precioContado,
                    precioTarjeta,
                    precioCuentaCorriente,
                    precioCompra
            );

            // Guardar y generar código de barras
            talleProductoRepo.save(productoTalle);
            String codigo = etiquetaService.generarCodigoBarras(productoTalle.getId());
            productoTalle.setCodigoBarras(codigo);
            talleProductoRepo.save(productoTalle);

            ra.addFlashAttribute("mensaje", "Talle agregado exitosamente");

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/productos/" + id + "/talles";
    }

    // ==========================================
    // ELIMINAR TALLE DEL PRODUCTO
    // ==========================================
    @PostMapping("/talles/{talleProductoId}/eliminar")
    public String eliminarTalle(@PathVariable Long talleProductoId,
                                RedirectAttributes ra) {

        ProductoTalle talleProducto = talleProductoRepo.findById(talleProductoId)
                .orElseThrow(() -> new IllegalArgumentException("Talle no encontrado"));

        Long productoId = talleProducto.getProducto().getId();

        talleProductoRepo.delete(talleProducto);

        ra.addFlashAttribute("mensaje", "Talle eliminado");
        return "redirect:/productos/" + productoId + "/talles";
    }

    // ==========================================
    // EDITAR TALLE (stock y precios)
    // ==========================================
    @PostMapping("/talles/{talleProductoId}/actualizar")
    public String actualizarTalle(
            @PathVariable Long talleProductoId,
            @RequestParam (required = false) Integer stock,
            @RequestParam (required = false) BigDecimal precioContado,
            @RequestParam (required = false) BigDecimal precioTarjeta,
            @RequestParam (required = false) BigDecimal precioCuentaCorriente,
            @RequestParam (required = false) BigDecimal precioCompra,
            RedirectAttributes ra) {

        ProductoTalle talleProducto = talleProductoRepo.findById(talleProductoId)
                .orElseThrow(() -> new IllegalArgumentException("Talle no encontrado"));

        if (precioTarjeta == null) {
            precioTarjeta = BigDecimal.ZERO;
        }

        if (precioCuentaCorriente == null) {
            precioCuentaCorriente = BigDecimal.ZERO;
        }

        if (precioCompra == null) {
            precioCompra = BigDecimal.ZERO;
        }

        if (precioContado == null) {
            precioContado = BigDecimal.ZERO;
        }

        talleProducto.setStock(stock);
        talleProducto.setPrecioContado(precioContado);
        talleProducto.setPrecioTarjeta(precioTarjeta);
        talleProducto.setPrecioCuentaCorriente(precioCuentaCorriente);
        talleProducto.setPrecioCompra(precioCompra);

        talleProductoRepo.save(talleProducto);

        ra.addFlashAttribute("mensaje", "Talle actualizado");
        return "redirect:/productos/" + talleProducto.getProducto().getId() + "/talles";
    }

    // ==========================================
    // ELIMINAR PRODUCTO
    // ==========================================
    @PostMapping("/eliminar/{id}")
    public String eliminar(@PathVariable Long id, RedirectAttributes ra) {
        try {
            productoRepo.deleteById(id);
            ra.addFlashAttribute("mensaje", "Producto eliminado");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Error eliminando producto: " + e.getMessage());
        }
        return "redirect:/productos";
    }

    // ==========================================
    // FORM EDITAR producto
    // ==========================================
    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id,
                         @RequestParam(required = false) Long proveedorId,
                         Model model,
                         RedirectAttributes ra) {

        Producto producto = productoService.getProductoById(id).orElse(null);

        if (producto == null) {
            ra.addFlashAttribute("error", "Producto no encontrado");
            return "redirect:/productos";
        }

        if (proveedorId != null) {
            proveedorService.getProveedorById(proveedorId)
                    .ifPresent(producto::setProveedor);
        }

        model.addAttribute("producto", producto);
        model.addAttribute("tiposIva", TipoIva.values());
        return "producto/form";
    }


    // ==========================================
    // ACTUALIZAR productos
    // ==========================================
    @PostMapping("/actualizar/{id}")
    public String actualizar(@PathVariable Long id,
                             @ModelAttribute Producto producto,
                             @RequestParam(required = false) Long proveedorId,
                             RedirectAttributes ra) {

        if (proveedorId != null) {

            Proveedor proveedor = proveedorService
                    .getProveedorById(proveedorId)
                    .orElseThrow(() -> new RuntimeException("Proveedor no encontrado"));

            producto.setProveedor(proveedor);

        } else {
            producto.setProveedor(null);
        }

        productoService.updateProducto(id, producto);

        ra.addFlashAttribute("mensaje",
                "Producto actualizado correctamente");

        return "redirect:/productos";
    }

    // ==========================================
    // BUSCAR (para autocomplete)
    // ==========================================
    @GetMapping("/buscar")
    @ResponseBody
    public List<ProductoTalle> buscar(@RequestParam String q) {

        String qNormalizado = q
                .replace("'", "")
                .replace("-", "")
                .trim();

        return talleProductoRepo.findAll().stream()
                .filter(tp -> {

                    String codigo = tp.getCodigoBarras() == null
                            ? ""
                            : tp.getCodigoBarras()
                            .replace("'", "")
                            .replace("-", "")
                            .trim();

                    return tp.getProducto().getDescripcion()
                            .toLowerCase()
                            .contains(q.toLowerCase())
                            || codigo.contains(qNormalizado);

                })
                .toList();
    }
}