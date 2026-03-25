package com.sistema.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Entity
@Getter @Setter
@ToString(exclude = {"presupuesto", "productoTalle"})
@Table(name = "presupuesto_detalle")
public class DetallePresupuesto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer cantidad;

    @ManyToOne
    @JoinColumn(name = "presupuesto_id", nullable = false)
    @JsonIgnore
    private Presupuesto presupuesto;

    // ==========================================
    // CAMBIO: Referenciar ProductoTalle
    // ==========================================
    @ManyToOne
    @JoinColumn(name = "producto_talle_id", nullable = false)
    private ProductoTalle productoTalle;

    @Column(name = "descuento_pct")
    private BigDecimal descuentoPct = BigDecimal.ZERO;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal precioUnitario;

    @Column(nullable = false, precision = 5, scale = 2)
    private BigDecimal alicuotaIva;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal subtotal;

    public DetallePresupuesto() {
    }

    // Helper para obtener el producto base
    @Transient
    public Producto getProducto() {
        return productoTalle != null ? productoTalle.getProducto() : null;
    }

    @Transient
    public BigDecimal getNeto() {
        BigDecimal divisor = BigDecimal.ONE.add(
                alicuotaIva.divide(BigDecimal.valueOf(100))
        );
        return subtotal.divide(divisor, 2, RoundingMode.HALF_UP);
    }

    @Transient
    public BigDecimal getIva() {
        return subtotal.subtract(getNeto());
    }

    public void calcularSubtotal() {
        BigDecimal precio = this.precioUnitario;
        BigDecimal cantidadBD = BigDecimal.valueOf(this.cantidad);
        BigDecimal bruto = precio.multiply(cantidadBD);

        BigDecimal descuentoPct = this.descuentoPct != null
                ? this.descuentoPct
                : BigDecimal.ZERO;

        BigDecimal descuentoMonto = bruto
                .multiply(descuentoPct)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

        this.subtotal = bruto.subtract(descuentoMonto);
    }
}