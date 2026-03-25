package com.sistema.repository;

import com.sistema.model.ProductoTalle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TalleProductoRepository extends JpaRepository<ProductoTalle, Long> {

    List<ProductoTalle> findByProductoId(Long productoId);

    Optional<ProductoTalle> findByProductoIdAndTalleId(Long productoId, Long talleId);

    Optional<ProductoTalle> findByCodigoBarras(String codigoBarras);

    boolean existsByCodigoBarras(String codigoBarras);
}
