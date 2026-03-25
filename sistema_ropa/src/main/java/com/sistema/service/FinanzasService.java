package com.sistema.service;

import com.sistema.model.Devolucion;
import com.sistema.model.Venta;
import com.sistema.repository.DevolucionRepository;
import com.sistema.repository.VentaItemRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
public class FinanzasService {

    private final VentaItemRepository ventaItemRepository;
    private final DevolucionRepository devolucionRepository;

    public FinanzasService(VentaItemRepository ventaItemRepository,
                           DevolucionRepository devolucionRepository) {
        this.ventaItemRepository = ventaItemRepository;
        this.devolucionRepository = devolucionRepository;
    }

    // ==========================================
    // GANANCIA ENTRE FECHAS (CON DEVOLUCIONES)
    // ==========================================
    public BigDecimal gananciaEntreFechas(LocalDate desde, LocalDate hasta) {

        LocalDateTime inicio = desde.atStartOfDay();
        LocalDateTime fin = hasta.atTime(23, 59, 59, 999_999_999);

        BigDecimal ganancia = ventaItemRepository.gananciaRealEntreFechas(
                inicio,
                fin,
                Venta.Estado.ANULADA
        );

        return ganancia != null ? ganancia : BigDecimal.ZERO;
    }

    // ==========================================
    // CAJA ENTRE FECHAS (CON DEVOLUCIONES)
    // ==========================================
    public BigDecimal cajaEntreFechas(LocalDate desde, LocalDate hasta) {

        LocalDateTime inicio = desde.atStartOfDay();
        LocalDateTime fin = hasta.atTime(23, 59, 59, 999_999_999);

        // Caja bruta
        BigDecimal cajaBruta = ventaItemRepository.cajaDelDia(
                inicio,
                fin,
                Venta.Estado.ANULADA
        );
        if (cajaBruta == null) cajaBruta = BigDecimal.ZERO;

        // Devoluciones
        BigDecimal devoluciones = devolucionRepository.calcularTotalDevueltoPeriodo(
                Devolucion.EstadoDevolucion.APROBADA,
                inicio,
                fin
        );

        // Caja neta
        return cajaBruta.subtract(devoluciones);
    }

    // ==========================================
    // DEVOLUCIONES ENTRE FECHAS
    // ==========================================
    public BigDecimal devolucionesEntreFechas(LocalDate desde, LocalDate hasta) {

        LocalDateTime inicio = desde.atStartOfDay();
        LocalDateTime fin = hasta.atTime(23, 59, 59, 999_999_999);

        return devolucionRepository.calcularTotalDevueltoPeriodo(
                Devolucion.EstadoDevolucion.APROBADA,
                inicio,
                fin
        );
    }
}



