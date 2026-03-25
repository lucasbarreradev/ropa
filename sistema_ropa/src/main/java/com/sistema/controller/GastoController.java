package com.sistema.controller;

import com.sistema.model.Gasto;
import com.sistema.service.GastoService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;


@Controller
@RequestMapping("/gastos")
public class GastoController {
    private final GastoService gastoService;

    public GastoController(GastoService gastoService) {
        this.gastoService = gastoService;
    }

    // ==========================================
    // LISTAR gastos
    // ==========================================
    @GetMapping
    public String listar(
            @RequestParam(required = false) Gasto gasto,
            Model model) {

        model.addAttribute("gastos",
                gastoService.getGastos());

        return "gasto/listar";
    }

    // ==========================================
    // FORM NUEVO gasto
    // ==========================================
    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Gasto gasto = new Gasto();
        gasto.setFecha(LocalDate.now());
        model.addAttribute("gasto", gasto);
        return "gasto/form";
    }


    // ==========================================
    // GUARDAR gasto (nuevo)
    // ==========================================
    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Gasto gasto,
                          RedirectAttributes ra) {

        gastoService.saveGasto(gasto);
        ra.addFlashAttribute("mensaje",
                "Gasto creado correctamente");

        return "redirect:/gastos";
    }

    // ==========================================
    // FORM EDITAR gasto
    // ==========================================
    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id,
                         Model model,
                         RedirectAttributes ra) {

        Gasto gasto = gastoService
                .getGastoById(id)
                .orElse(null);

        if (gasto == null) {
            ra.addFlashAttribute("error",
                    "Gasto no encontrado");
            return "redirect:/gastos";
        }

        model.addAttribute("gasto", gasto);
        return "gasto/form";
    }

    // ==========================================
    // ACTUALIZAR gasto
    // ==========================================
    @PostMapping("/actualizar/{id}")
    public String actualizar(@PathVariable Long id,
                             @ModelAttribute Gasto gasto,
                             RedirectAttributes ra) {

        gastoService.updateGasto(id, gasto);
        ra.addFlashAttribute("mensaje",
                "Gasto actualizado correctamente");

        return "redirect:/gastos";
    }

    // ==========================================
    // ELIMINAR gasto
    // ==========================================
    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable Long id,
                           RedirectAttributes ra) {

        gastoService.deleteGasto(id);
        ra.addFlashAttribute("mensaje",
                "Gasto eliminado correctamente");

        return "redirect:/gastos";
    }
}
