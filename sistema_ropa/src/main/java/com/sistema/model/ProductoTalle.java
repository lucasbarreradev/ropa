package com.sistema.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Getter @Setter @AllArgsConstructor @NoArgsConstructor
    public class ProductoTalle {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @ManyToOne(optional = false)
        private Producto producto;

        @ManyToOne(optional = false)
        private Talle talle;

        @Column(name = "codigo_barras", unique = true)
        private String codigoBarras;

        private Integer stock;

        private BigDecimal precioCompra;
        private BigDecimal precioContado;
        private BigDecimal precioTarjeta;
        private BigDecimal precioCuentaCorriente;

        public BigDecimal getPrecioSegunFormaPago(FormaPago formaPago) {
            if (formaPago == null) {
                throw new IllegalArgumentException("Forma de pago no puede ser null");
            }

            switch (formaPago) {
                case CONTADO:
                    return precioContado;
                case TARJETA:
                    return precioTarjeta;
                case CUENTA_CORRIENTE:
                    return precioCuentaCorriente;
                default:
                    throw new IllegalArgumentException("Forma de pago inválida");
            }
        }

    // Constructor útil
    public ProductoTalle(Producto producto, Talle talle, Integer stock,
                         BigDecimal precioContado, BigDecimal precioTarjeta,
                         BigDecimal precioCuentaCorriente, BigDecimal precioCompra) {
        this.producto = producto;
        this.talle = talle;
        this.stock = stock;
        this.precioContado = precioContado;
        this.precioTarjeta = precioTarjeta;
        this.precioCuentaCorriente = precioCuentaCorriente;
        this.precioCompra = precioCompra;
    }
    }


