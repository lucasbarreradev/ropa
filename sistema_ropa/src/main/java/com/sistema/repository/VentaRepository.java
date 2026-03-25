package com.sistema.repository;

import com.sistema.model.Venta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface VentaRepository extends JpaRepository<Venta, Long> {

    Optional<Venta> findByCodigo(String codigo);

    List<Venta> findByEstado(Venta.Estado estado);

    List<Venta> findByEstadoNotOrderByFechaVentaDesc(Venta.Estado estado);

    // ==========================================
    // FILTRAR POR RANGO DE FECHAS
    // ==========================================
    List<Venta> findByFechaVentaBetween(LocalDateTime inicio, LocalDateTime fin);

    List<Venta> findByFechaVentaBetweenAndEstado(
            LocalDateTime inicio,
            LocalDateTime fin,
            Venta.Estado estado
    );

    List<Venta> findByFechaVentaBetweenAndEstadoNot(
            LocalDateTime inicio,
            LocalDateTime fin,
            Venta.Estado estado
    );

    // =========================
    // 📅 CONTAR VENTAS DEL DÍA
    // =========================
    @Query("""
        SELECT COUNT(v)
        FROM Venta v
        WHERE v.fechaVenta BETWEEN :inicioDia AND :finDia
          AND v.estado <> :estado
    """)
    Long contarVentasDelDia(
            @Param("inicioDia") LocalDateTime inicioDia,
            @Param("finDia") LocalDateTime finDia,
            @Param("estado") Venta.Estado estado
    );

    // =========================
    // 📆 CONTAR VENTAS DEL MES
    // =========================
    @Query("""
        SELECT COUNT(v)
        FROM Venta v
        WHERE v.fechaVenta BETWEEN :inicioMes AND :finMes
          AND v.estado <> :estado
    """)
    Long contarVentasDelMes(
            @Param("inicioMes") LocalDateTime inicioMes,
            @Param("finMes") LocalDateTime finMes,
            @Param("estado") Venta.Estado estado
    );

    // ==========================================
    // SUMA TOTAL EN RANGO (SIN devoluciones)
    // ==========================================
    @Query("""
        SELECT SUM(v.total)
        FROM Venta v
        WHERE v.fechaVenta BETWEEN :inicio AND :fin
          AND v.estado <> :estado
    """)
    BigDecimal sumarTotalEntreFechas(
            @Param("inicio") LocalDateTime inicio,
            @Param("fin") LocalDateTime fin,
            @Param("estado") Venta.Estado estado
    );
}

