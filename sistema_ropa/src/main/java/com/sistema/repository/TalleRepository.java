package com.sistema.repository;

import com.sistema.model.Talle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TalleRepository extends JpaRepository<Talle, Long> {

    Optional<Talle> findByNombreIgnoreCase(String nombre);

    boolean existsByNombreIgnoreCase(String nombre);
}
