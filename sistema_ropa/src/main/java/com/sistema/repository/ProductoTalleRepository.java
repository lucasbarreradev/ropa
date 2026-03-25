package com.sistema.repository;

import com.sistema.model.ProductoTalle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductoTalleRepository extends JpaRepository<ProductoTalle, Long> {

    List<ProductoTalle> findByProductoIdOrderByTalleNombreAsc(Long productoId);

    Optional<ProductoTalle> findByProductoIdAndTalleId(Long productoId, Long talleId);

    Optional<ProductoTalle> findByCodigoBarras(String codigoBarras);

    boolean existsByCodigoBarras(String codigoBarras);

    boolean existsByProductoIdAndTalleId(Long productoId, Long talleId);

    // Para búsqueda en ventas/presupuestos
    @Query("SELECT pt FROM ProductoTalle pt WHERE " +
            "LOWER(pt.producto.descripcion) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
            "LOWER(pt.talle.nombre) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
            "pt.codigoBarras LIKE CONCAT('%', :query, '%')")
    List<ProductoTalle> buscar(@Param("query") String query);
}
