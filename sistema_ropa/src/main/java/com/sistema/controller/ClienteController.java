package com.sistema.controller;

import com.sistema.model.Cliente;
import com.sistema.model.CondicionIva;
import com.sistema.repository.ClienteRepository;
import com.sistema.service.ClienteService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/clientes")

public class ClienteController {
    private final ClienteService clienteService;
    private final ClienteRepository clienteRepo;
    public ClienteController(ClienteService clienteService,
                             ClienteRepository clienteRepo) {
        this.clienteService = clienteService;
        this.clienteRepo = clienteRepo;
    }

    // ==========================================
    // LISTAR clientes
    // ==========================================
    @GetMapping
    public String listar(
            @RequestParam(required = false) String origen,
            Model model) {

        model.addAttribute("clientes",
                clienteService.getClientes());

        model.addAttribute("origen", origen);
        return "cliente/listar";
    }

    // ==========================================
    // FORM NUEVO cliente
    // ==========================================
    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        model.addAttribute("cliente", new Cliente());
        model.addAttribute("condicionesIva", CondicionIva.values());
        return "cliente/form";
    }

    // ==========================================
    // GUARDAR cliente (nuevo)
    // ==========================================
    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Cliente cliente,
                          RedirectAttributes ra) {

        clienteService.saveCliente(cliente);
        ra.addFlashAttribute("mensaje",
                "Cliente creado correctamente");

        return "redirect:/clientes";
    }

    // ==========================================
    // FORM EDITAR cliente
    // ==========================================
    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id,
                         Model model,
                         RedirectAttributes ra) {

        Cliente cliente = clienteService
                .getClienteById(id)
                .orElse(null);

        if (cliente == null) {
            ra.addFlashAttribute("error",
                    "Cliente no encontrado");
            return "redirect:/clientes";
        }

        model.addAttribute("cliente", cliente);
        model.addAttribute("condicionesIva", CondicionIva.values());
        return "cliente/form";
    }

    // ==========================================
    // ACTUALIZAR cliente
    // ==========================================
    @PostMapping("/actualizar/{id}")
    public String actualizar(@PathVariable Long id,
                             @ModelAttribute Cliente cliente,
                             RedirectAttributes ra) {

        clienteService.updateCliente(id, cliente);
        ra.addFlashAttribute("mensaje",
                "Cliente actualizado correctamente");

        return "redirect:/clientes";
    }

    // ==========================================
    // ELIMINAR cliente
    // ==========================================
    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable Long id,
                           RedirectAttributes ra) {

        clienteService.deleteCliente(id);
        ra.addFlashAttribute("mensaje",
                "Cliente eliminado correctamente");

        return "redirect:/clientes";
    }

    @GetMapping("/buscar")
    @ResponseBody
    public List<Cliente> buscar(@RequestParam String q) {
        return clienteService.buscar(q);
    }

    // ==========================================
    // GUARDAR CLIENTE POR AJAX (desde venta)
    // ==========================================
    @PostMapping("/guardar-ajax")
    @ResponseBody
    public ResponseEntity<?> guardarClienteAjax(@RequestBody Cliente cliente) {

        try {
            // Validaciones
            if (cliente.getNombre() == null || cliente.getNombre().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El nombre es obligatorio"));
            }

            if (cliente.getApellido() == null || cliente.getApellido().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El apellido es obligatorio"));
            }

            // Verificar si el DNI ya existe
            Optional<Cliente> existente = clienteRepo.findByDni(cliente.getDni());
            if (existente.isPresent()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Ya existe un cliente con ese DNI"));
            }

            // Valores por defecto
            if (cliente.getCondicionIva() == null) {
                cliente.setCondicionIva(CondicionIva.CONSUMIDOR_FINAL);
            }

            // Guardar
            Cliente clienteGuardado = clienteService.saveCliente(cliente);

            // Retornar solo los datos necesarios
            Map<String, Object> response = new HashMap<>();
            response.put("id", clienteGuardado.getId());
            response.put("nombre", clienteGuardado.getNombre());
            response.put("apellido", clienteGuardado.getApellido());
            response.put("dni", clienteGuardado.getDni());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error al guardar el cliente: " + e.getMessage()));
        }
    }

}

