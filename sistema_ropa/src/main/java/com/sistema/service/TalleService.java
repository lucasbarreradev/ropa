package com.sistema.service;

import com.sistema.model.Talle;
import com.sistema.repository.TalleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class TalleService {

    private final TalleRepository talleRepo;

    public TalleService(TalleRepository talleRepo) {
        this.talleRepo = talleRepo;
    }

    /**
     * Busca un talle por nombre, si no existe lo crea automáticamente
     */
    public Talle obtenerOCrearTalle(String nombreTalle) {

        if (nombreTalle == null || nombreTalle.trim().isEmpty()) {
            throw new IllegalArgumentException("El nombre del talle no puede estar vacío");
        }

        String nombre = nombreTalle.trim().toUpperCase();

        // Buscar si ya existe
        Optional<Talle> talleExistente = talleRepo.findByNombreIgnoreCase(nombre);

        if (talleExistente.isPresent()) {
            return talleExistente.get();
        }

        // Si no existe, crear uno nuevo
        Talle nuevoTalle = new Talle(nombre);
        return talleRepo.save(nuevoTalle);
    }

    public List<Talle> listarTodos() {
        return talleRepo.findAll();
    }

    public void eliminar(Long id) {
        talleRepo.deleteById(id);
    }
}