package com.sistema.service;

import com.sistema.model.Gasto;
import com.sistema.repository.GastoRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class GastoService {
    private final GastoRepository gastoRepo;

    public GastoService(GastoRepository gastoRepo) {
        this.gastoRepo = gastoRepo;
    }

    public List<Gasto> getGastos() {
        return gastoRepo.findAllByOrderByFechaAsc();
    }

    public Optional<Gasto> getGastoById(Long id) {
        return gastoRepo.findById(id);
    }

    public Gasto saveGasto(Gasto gasto) {
        return gastoRepo.save(gasto);
    }

    public Gasto updateGasto(Long id, Gasto gasto) {
        Gasto existente = gastoRepo.findById(id)
                .orElseThrow(() -> new RuntimeException(
                        "Gasto no encontrado con id: " + id));

        existente.setDescripcion(gasto.getDescripcion());
        existente.setFecha(gasto.getFecha());
        existente.setMonto(gasto.getMonto());
        // setear SOLO lo que se permite modificar

        return gastoRepo.save(existente);
    }

    public void deleteGasto(Long id) {
        if (!gastoRepo.existsById(id)) {
            throw new RuntimeException("Gasto no existe");
        }
        gastoRepo.deleteById(id);
    }
}
