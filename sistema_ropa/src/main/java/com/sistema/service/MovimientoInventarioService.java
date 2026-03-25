package com.sistema.service;

import com.sistema.model.MovimientoInventario;
import com.sistema.model.ProductoTalle;
import com.sistema.repository.MovimientoInventarioRepository;
import com.sistema.repository.ProductoTalleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class MovimientoInventarioService {

        private final MovimientoInventarioRepository movRepo;
        private final ProductoTalleRepository productoTalleRepo;
        public MovimientoInventarioService(
                MovimientoInventarioRepository movRepo,
                ProductoTalleRepository productoTalleRepo
        ) {
            this.movRepo = movRepo;
            this.productoTalleRepo = productoTalleRepo;
        }

    public MovimientoInventario registrarDevolucion(
            Long productoTalleId,
            Integer cantidad,
            String nota
    ) {
        ProductoTalle productoTalle = productoTalleRepo.findById(productoTalleId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Producto no encontrado"));

        if (cantidad <= 0) {
            throw new IllegalArgumentException("Cantidad inválida");
        }

        MovimientoInventario mov = new MovimientoInventario();
        mov.setProductoTalle(productoTalle);
        mov.setTipo(MovimientoInventario.Tipo.ENTRADA);
        mov.setCantidad(cantidad);
        mov.setStockPrevio(productoTalle.getStock());
        mov.setFechaMovimiento(LocalDateTime.now());

        // 🔁 Devolver stock
        //productoTalle.setStock(productoTalle.getStock() + cantidad);

        mov.setStockPosterior(productoTalle.getStock());

        return movRepo.save(mov);
    }

        @Transactional
        public MovimientoInventario registrarVenta(
                Long productoTalleId,
                Integer cantidad,
                String nota
        ) {
            ProductoTalle productoTalle = productoTalleRepo.findById(productoTalleId)
                    .orElseThrow(() ->
                            new IllegalArgumentException("Producto no encontrado"));

            if (cantidad <= 0) {
                throw new IllegalArgumentException("Cantidad inválida");
            }

            if (productoTalle.getStock() < cantidad) {
                throw new IllegalStateException("Stock insuficiente. Disponible: " + productoTalle.getStock()
                );
            }

            MovimientoInventario mov = new MovimientoInventario();
            mov.setProductoTalle(productoTalle);
            mov.setTipo(MovimientoInventario.Tipo.SALIDA);
            mov.setCantidad(cantidad);
            mov.setStockPrevio(productoTalle.getStock());
            mov.setFechaMovimiento(LocalDateTime.now());

            // Actualizar stock
            productoTalle.setStock(productoTalle.getStock() - cantidad);

            mov.setStockPosterior(productoTalle.getStock());

            return movRepo.save(mov);
        }


    }

