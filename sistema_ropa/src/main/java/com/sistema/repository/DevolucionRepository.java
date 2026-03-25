package com.sistema.repository;

import com.sistema.model.Devolucion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface DevolucionRepository extends JpaRepository<Devolucion, Long> {
    List<Devolucion> findAllByOrderByFechaDesc();
    List<Devolucion> findByVentaIdOrderByFechaDesc(Long ventaId);
    List<Devolucion> findByEstadoOrderByFechaDesc(Devolucion.EstadoDevolucion estado);

    // ==========================================
    // FILTRAR POR VENTA Y ESTADO
    // ==========================================
    List<Devolucion> findByVentaIdAndEstado(Long ventaId, Devolucion.EstadoDevolucion estado);

    // ==========================================
    // DEVOLUCIONES EN RANGO DE FECHAS
    // ==========================================
    List<Devolucion> findByEstadoAndFechaBetween(
            Devolucion.EstadoDevolucion estado,
            LocalDateTime inicio,
            LocalDateTime fin
    );

    // ==========================================
    // TOTAL DEVUELTO EN UN PERÍODO
    // ==========================================
    @Query("""
        SELECT COALESCE(SUM(d.totalDevuelto), 0)
        FROM Devolucion d
        WHERE d.estado = :estado
        AND d.fecha BETWEEN :inicio AND :fin
    """)
    BigDecimal calcularTotalDevueltoPeriodo(
            @Param("estado") Devolucion.EstadoDevolucion estado,
            @Param("inicio") LocalDateTime inicio,
            @Param("fin") LocalDateTime fin
    );

    // ==========================================
    // TOTAL DEVUELTO DEL DÍA
    // ==========================================
    @Query("""
        SELECT COALESCE(SUM(d.totalDevuelto), 0)
        FROM Devolucion d
        WHERE d.estado = :estado
        AND d.fecha BETWEEN :inicioDia AND :finDia
    """)
    BigDecimal calcularTotalDevueltoDelDia(
            @Param("estado") Devolucion.EstadoDevolucion estado,
            @Param("inicioDia") LocalDateTime inicioDia,
            @Param("finDia") LocalDateTime finDia
    );
}


