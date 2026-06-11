package com.sistema.service;

import com.sistema.model.FormaPago;
import com.sistema.model.ProductoTalle;
import com.sistema.repository.ProductoTalleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ProductoTalleService {

    private final ProductoTalleRepository talleRepo;

    public ProductoTalleService(ProductoTalleRepository talleRepo) {
        this.talleRepo = talleRepo;
    }

    // ==========================================
    // CRUD BÁSICO
    // ==========================================

    public ProductoTalle save(ProductoTalle productoTalle) {

        if (productoTalle.getProducto() == null) {
            throw new IllegalArgumentException("El producto no puede ser nulo");
        }

        if (productoTalle.getTalle() == null) {
            throw new IllegalArgumentException("El talle no puede ser nulo");
        }

        // Validar duplicado
        validarTalleDuplicado(productoTalle);

        // Stock inicial
        if (productoTalle.getStock() == null) {
            productoTalle.setStock(0);
        }

        return talleRepo.save(productoTalle);
    }

    public ProductoTalle update(ProductoTalle productoTalle) {

        ProductoTalle existente = talleRepo.findById(productoTalle.getId())
                .orElseThrow(() -> new IllegalArgumentException("ProductoTalle no encontrado"));

        existente.setTalle(productoTalle.getTalle());
        existente.setCodigoBarras(productoTalle.getCodigoBarras());
        existente.setStock(productoTalle.getStock());
        existente.setPrecioCompra(productoTalle.getPrecioCompra());
        existente.setPrecioContado(productoTalle.getPrecioContado());
        existente.setPrecioTarjeta(productoTalle.getPrecioTarjeta());
        existente.setPrecioCuentaCorriente(productoTalle.getPrecioCuentaCorriente());

        return talleRepo.save(existente);
    }

    public void delete(Long id) {

        ProductoTalle productoTalle = talleRepo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("ProductoTalle no encontrado"));

        if (productoTalle.getStock() > 0) {
            throw new IllegalStateException(
                    "No se puede eliminar un talle con stock disponible");
        }

        talleRepo.delete(productoTalle);
    }

    // ==========================================
    // CONSULTAS
    // ==========================================

    public Optional<ProductoTalle> getById(Long id) {
        return talleRepo.findById(id);
    }

    public List<ProductoTalle> findByProducto(Long productoId) {
        return talleRepo.findByProductoIdOrderByTalleNombreAsc(productoId);
    }

    public Optional<ProductoTalle> findByCodigoBarras(String codigo) {
        String codigoNormalizado = codigo
                .replace("-", "")
                .replace("'", "")
                .trim();
        return talleRepo.findByCodigoBarras(codigoNormalizado);
    }

    // ==========================================
    // PRECIO SEGÚN FORMA DE PAGO
    // ==========================================

    public BigDecimal getPrecioSegunFormaPago(
            ProductoTalle productoTalle,
            FormaPago formaPago
    ) {

        if (formaPago == null) {
            throw new IllegalArgumentException("Forma de pago requerida");
        }

        switch (formaPago) {
            case CONTADO:
                return productoTalle.getPrecioContado();

            case TARJETA:
                return productoTalle.getPrecioTarjeta();

            case CUENTA_CORRIENTE:
                return productoTalle.getPrecioCuentaCorriente();

            default:
                throw new IllegalArgumentException("Forma de pago inválida");
        }
    }

    // ==========================================
    // VALIDACIONES
    // ==========================================

    private void validarTalleDuplicado(ProductoTalle productoTalle) {

        // Verificar si ya existe la combinación producto + talle
        boolean existe = talleRepo.existsByProductoIdAndTalleId(
                productoTalle.getProducto().getId(),
                productoTalle.getTalle().getId()
        );

        if (existe) {
            throw new IllegalArgumentException(
                    "El talle " + productoTalle.getTalle().getNombre() +
                            " ya existe para este producto");
        }
    }
}