package com.sistema.controller;

import com.sistema.model.Producto;
import com.sistema.model.ProductoTalle;
import com.sistema.repository.ProductoRepository;
import com.sistema.repository.ProductoTalleRepository;
import com.sistema.service.EtiquetaService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/etiquetas")
public class EtiquetaController {

    private final EtiquetaService etiquetaService;
    private final ProductoTalleRepository productoTalleRepo;
    private final ProductoRepository productoRepo;

    public EtiquetaController(EtiquetaService etiquetaService,
                              ProductoTalleRepository productoTalleRepo,
                              ProductoRepository productoRepo) {
        this.etiquetaService = etiquetaService;
        this.productoTalleRepo = productoTalleRepo;
        this.productoRepo = productoRepo;
    }

    // ==========================================
    // SELECCIONAR PRODUCTOS/TALLES PARA ETIQUETAR
    // ==========================================
    @GetMapping("/seleccionar")
    public String seleccionar(Model model) {
        // Traer todos los productos con sus talles
        List<Producto> productos = productoRepo.findAll();
        model.addAttribute("productos", productos);
        return "etiqueta/seleccionar";
    }

    // ==========================================
    // GENERAR CÓDIGOS Y PREPARAR IMPRESIÓN
    // ==========================================
    @PostMapping("/generar")
    public String generarCodigos(
            @RequestParam List<Long> productoTalleIds,
            @RequestParam List<Integer> cantidades,
            RedirectAttributes ra) {

        try {
            if (productoTalleIds == null || productoTalleIds.isEmpty()) {
                ra.addFlashAttribute("error", "Debe seleccionar al menos un producto");
                return "redirect:/etiquetas/seleccionar";
            }

            if (productoTalleIds.size() != cantidades.size()) {
                throw new IllegalArgumentException(
                        "La cantidad de items y cantidades no coinciden");
            }

            int totalEtiquetas = 0;
            List<ProductoTalle> tallesParaImprimir = new ArrayList<>();

            for (int i = 0; i < productoTalleIds.size(); i++) {
                Long productoTalleId = productoTalleIds.get(i);
                Integer cantidad = cantidades.get(i);

                if (cantidad == null || cantidad <= 0) {
                    continue;  // Saltar si no ingresaron cantidad
                }

                // Generar código si no tiene
                etiquetaService.generarCodigoBarras(productoTalleId);

                // Buscar el productoTalle
                ProductoTalle productoTalle = productoTalleRepo.findById(productoTalleId)
                        .orElseThrow(() -> new IllegalArgumentException(
                                "ProductoTalle no encontrado: " + productoTalleId));

                // Agregar N veces según la cantidad
                for (int j = 0; j < cantidad; j++) {
                    tallesParaImprimir.add(productoTalle);
                }

                totalEtiquetas += cantidad;
            }

            if (totalEtiquetas == 0) {
                ra.addFlashAttribute("error", "No se generaron etiquetas. Verifica las cantidades.");
                return "redirect:/etiquetas/seleccionar";
            }

            ra.addFlashAttribute("mensaje",
                    "Total de etiquetas a imprimir: " + totalEtiquetas);
            ra.addFlashAttribute("tallesProducto", tallesParaImprimir);

            return "redirect:/etiquetas/imprimir-directo";

        } catch (Exception e) {
            ra.addFlashAttribute("error", "Error: " + e.getMessage());
            return "redirect:/etiquetas/seleccionar";
        }
    }

    // ==========================================
    // PANTALLA DE IMPRESIÓN
    // ==========================================
    @GetMapping("/imprimir-directo")
    public String imprimirDirecto(Model model) {
        if (!model.containsAttribute("tallesProducto")) {
            return "redirect:/etiquetas/seleccionar";
        }
        return "etiqueta/imprimir";
    }

    // ==========================================
    // SERVIR IMAGEN DEL CÓDIGO DE BARRAS
    // ==========================================
    @GetMapping(value = "/imagen/{codigo}", produces = MediaType.IMAGE_PNG_VALUE)
    @ResponseBody
    public byte[] obtenerImagen(@PathVariable String codigo) {
        return etiquetaService.generarImagenBarras(codigo);
    }

    // ==========================================
    // BUSCAR POR CÓDIGO (para scanner en ventas)
    // ==========================================
    @PostMapping("/buscar")
    @ResponseBody
    public ResponseEntity<?> buscarProducto(@RequestParam String codigo) {
        try {
            ProductoTalle productoTalle = etiquetaService.buscarPorCodigoBarras(codigo);

            // Retornar info completa
            Map<String, Object> response = new HashMap<>();
            response.put("id", productoTalle.getId());
            response.put("descripcion", productoTalle.getProducto().getDescripcion());
            response.put("talle", productoTalle.getTalle().getNombre());
            response.put("stock", productoTalle.getStock());
            response.put("precioContado", productoTalle.getPrecioContado());
            response.put("precioTarjeta", productoTalle.getPrecioTarjeta());
            response.put("precioCuentaCorriente", productoTalle.getPrecioCuentaCorriente());
            response.put("codigoBarras", productoTalle.getCodigoBarras());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}