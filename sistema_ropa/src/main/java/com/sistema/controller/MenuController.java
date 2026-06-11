package com.sistema.controller;


import com.sistema.model.Devolucion;
import com.sistema.model.Venta;
import com.sistema.repository.*;
import com.sistema.service.FinanzasService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Controller
public class MenuController {

    private final VentaItemRepository ventaItemRepository;
    private final VentaRepository ventaRepository;
    private final FinanzasService finanzasService;
    private final DevolucionRepository devolucionRepository;
    private final GastoRepository gastoRepository;
    private final ProductoTalleRepository productoTalleRepository;

    public MenuController(VentaItemRepository ventaItemRepository,
                          VentaRepository ventaRepository,
                          FinanzasService finanzasService,
                          DevolucionRepository devolucionRepository,
                          GastoRepository gastoRepository,
                          ProductoTalleRepository productoTalleRepository
                            ) {
        this.ventaItemRepository = ventaItemRepository;
        this.ventaRepository = ventaRepository;
        this.finanzasService = finanzasService;
        this.devolucionRepository = devolucionRepository;
        this.gastoRepository = gastoRepository;
        this.productoTalleRepository = productoTalleRepository;
    }

    @GetMapping("/")
    public String index(Model model) {

        LocalDate hoy = LocalDate.now();
        Venta.Estado estadoExcluido = Venta.Estado.ANULADA;

        // =========================
        // 📅 DÍA
        // =========================
        LocalDateTime inicioDia = hoy.atStartOfDay();
        LocalDateTime finDia = hoy.atTime(23, 59, 59, 999_999_999);

        Long ventasDia = ventaRepository.contarVentasDelDia(
                inicioDia,
                finDia,
                estadoExcluido
        );

        // Caja bruta (sin restar devoluciones)
        BigDecimal cajaBruta = ventaItemRepository.cajaDelDia(
                inicioDia,
                finDia,
                estadoExcluido
        );
        if (cajaBruta == null) cajaBruta = BigDecimal.ZERO;

        // Devoluciones del día
        BigDecimal devolucionesDia = devolucionRepository.calcularTotalDevueltoDelDia(
                Devolucion.EstadoDevolucion.APROBADA,
                inicioDia,
                finDia
        );

        BigDecimal gastosDia = gastoRepository.gastosEntreFechas(
                hoy,
                hoy
        );

        if (gastosDia == null) gastosDia = BigDecimal.ZERO;

        // Caja neta (real)
        BigDecimal cajaNeta = cajaBruta
                .subtract(devolucionesDia)
                .subtract(gastosDia);

        // Ganancia del día (considerando devoluciones)
        BigDecimal gananciaDia = ventaItemRepository.gananciaRealDelDia(
                inicioDia,
                finDia,
                estadoExcluido
        );
        if (gananciaDia == null) gananciaDia = BigDecimal.ZERO;

        // Ganancia real
        gananciaDia = gananciaDia.subtract(gastosDia);

        // =========================
        // 📆 MES
        // =========================
        LocalDate primerDiaMes = hoy.withDayOfMonth(1);
        LocalDate ultimoDiaMes = hoy.withDayOfMonth(hoy.lengthOfMonth());

        LocalDateTime inicioMes = primerDiaMes.atStartOfDay();
        LocalDateTime finMes = ultimoDiaMes.atTime(23, 59, 59, 999_999_999);

        Long ventasMes = ventaRepository.contarVentasDelMes(
                inicioMes,
                finMes,
                estadoExcluido
        );

        // Ganancia del mes (considerando devoluciones)
        BigDecimal gananciaMes = ventaItemRepository.gananciaRealEntreFechas(
                inicioMes,
                finMes,
                estadoExcluido
        );
        if (gananciaMes == null) gananciaMes = BigDecimal.ZERO;

        // Devoluciones del mes
        BigDecimal devolucionesMes = devolucionRepository.calcularTotalDevueltoPeriodo(
                Devolucion.EstadoDevolucion.APROBADA,
                inicioMes,
                finMes
        );

        BigDecimal gastosMes = gastoRepository.gastosEntreFechas(
                primerDiaMes,
                ultimoDiaMes
        );

        if (gastosMes == null) gastosMes = BigDecimal.ZERO;

        // Restar gastos
        gananciaMes = gananciaMes.subtract(gastosMes);

        //Productos disponibles en total
        Integer stockTotal = productoTalleRepository.stockTotalDisponible();

        if (stockTotal == null) {
            stockTotal = 0;
        }

        // =========================
        // 🛡️ NULL SAFE + MODEL
        // =========================
        model.addAttribute("ventasDia", ventasDia != null ? ventasDia : 0L);
        model.addAttribute("ventasMes", ventasMes != null ? ventasMes : 0L);

        // Caja
        model.addAttribute("cajaBruta", cajaBruta);
        model.addAttribute("devolucionesDia", devolucionesDia);
        model.addAttribute("cajaNeta", cajaNeta);

        // Ganancias
        model.addAttribute("gananciaDia", gananciaDia);
        model.addAttribute("gananciaMes", gananciaMes);
        model.addAttribute("devolucionesMes", devolucionesMes);

        //Gastos
        model.addAttribute("gastosDia", gastosDia);
        model.addAttribute("gastosMes", gastosMes);
        model.addAttribute("gastosDia", gastosDia);

        //Stock total
        model.addAttribute("stockTotal", stockTotal);
        return "index";
    }

    @GetMapping("/home")
    public String homeAlias() {
        return "index";
    }
}

