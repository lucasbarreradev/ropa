package com.sistema.repository;

import com.sistema.model.Gasto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface GastoRepository extends JpaRepository<Gasto, Long> {
    @Query("""
    SELECT SUM(g.monto)
    FROM Gasto g
    WHERE g.fecha BETWEEN :inicio AND :fin
""")
    BigDecimal gastosEntreFechas(
            @Param("inicio") LocalDate inicio,
            @Param("fin") LocalDate fin
    );
    List<Gasto> findAllByOrderByFechaAsc();

}
