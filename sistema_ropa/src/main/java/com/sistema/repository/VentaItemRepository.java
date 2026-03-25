package com.sistema.repository;

import com.sistema.model.Venta;
import com.sistema.model.VentaItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public interface VentaItemRepository extends JpaRepository<VentaItem, Long> {
    // ==========================================
    // GANANCIA ENTRE FECHAS (SIN devoluciones)
    // ==========================================
    @Query("""
        SELECT SUM((vi.precioUnitario - vi.costoUnitario) * vi.cantidad)
        FROM VentaItem vi
        WHERE vi.venta.fechaVenta BETWEEN :desde AND :hasta
        AND vi.venta.estado <> :estado
    """)
    BigDecimal gananciaEntreFechas(
            @Param("desde") LocalDateTime desde,
            @Param("hasta") LocalDateTime hasta,
            @Param("estado") Venta.Estado estado
    );

    // ==========================================
    // GANANCIA REAL (considerando devoluciones)
    // ==========================================
    @Query("""
        SELECT SUM((vi.precioUnitario - vi.costoUnitario) * (vi.cantidad - vi.cantidadDevuelta))
        FROM VentaItem vi
        WHERE vi.venta.fechaVenta BETWEEN :desde AND :hasta
        AND vi.venta.estado <> :estado
    """)
    BigDecimal gananciaRealEntreFechas(
            @Param("desde") LocalDateTime desde,
            @Param("hasta") LocalDateTime hasta,
            @Param("estado") Venta.Estado estado
    );

    // ==========================================
    // GANANCIA DEL DÍA (SIN devoluciones)
    // ==========================================
    @Query("""
        SELECT SUM((vi.precioUnitario - vi.costoUnitario) * vi.cantidad)
        FROM VentaItem vi
        WHERE vi.venta.fechaVenta BETWEEN :inicioDia AND :finDia
        AND vi.venta.estado <> :estado
    """)
    BigDecimal gananciaDelDia(
            @Param("inicioDia") LocalDateTime inicioDia,
            @Param("finDia") LocalDateTime finDia,
            @Param("estado") Venta.Estado estado
    );

    // ==========================================
    // GANANCIA REAL DEL DÍA (considerando devoluciones)
    // ==========================================
    @Query("""
        SELECT SUM((vi.precioUnitario - vi.costoUnitario) * (vi.cantidad - vi.cantidadDevuelta))
        FROM VentaItem vi
        WHERE vi.venta.fechaVenta BETWEEN :inicioDia AND :finDia
        AND vi.venta.estado <> :estado
    """)
    BigDecimal gananciaRealDelDia(
            @Param("inicioDia") LocalDateTime inicioDia,
            @Param("finDia") LocalDateTime finDia,
            @Param("estado") Venta.Estado estado
    );

    // ==========================================
    // MARGEN ENTRE FECHAS
    // ==========================================
    @Query("""
        SELECT SUM((vi.precioUnitario - vi.costoUnitario) * vi.cantidad)
        FROM VentaItem vi
        WHERE vi.venta.fechaVenta BETWEEN :inicio AND :fin
        AND vi.venta.estado <> :estado
    """)
    BigDecimal margenEntreFechas(
            @Param("inicio") LocalDateTime inicio,
            @Param("fin") LocalDateTime fin,
            @Param("estado") Venta.Estado estado
    );

    // ==========================================
    // CAJA DEL DÍA (SIN devoluciones)
    // ==========================================
    @Query("""
        SELECT SUM(vi.precioUnitario * vi.cantidad)
        FROM VentaItem vi
        WHERE vi.venta.fechaVenta BETWEEN :inicioDia AND :finDia
        AND vi.venta.estado <> :estado
    """)
    BigDecimal cajaDelDia(
            @Param("inicioDia") LocalDateTime inicioDia,
            @Param("finDia") LocalDateTime finDia,
            @Param("estado") Venta.Estado estado
    );

    // ==========================================
    // CAJA REAL DEL DÍA (considerando devoluciones)
    // ==========================================
    @Query("""
        SELECT SUM(vi.precioUnitario * (vi.cantidad - vi.cantidadDevuelta))
        FROM VentaItem vi
        WHERE vi.venta.fechaVenta BETWEEN :inicioDia AND :finDia
        AND vi.venta.estado <> :estado
    """)
    BigDecimal cajaRealDelDia(
            @Param("inicioDia") LocalDateTime inicioDia,
            @Param("finDia") LocalDateTime finDia,
            @Param("estado") Venta.Estado estado
    );



}
