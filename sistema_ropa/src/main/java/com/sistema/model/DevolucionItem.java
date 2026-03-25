package com.sistema.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
    @Getter
@Setter
    @NoArgsConstructor
@AllArgsConstructor
    @Table(name = "devolucion_item")
    public class DevolucionItem {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @ManyToOne
        @JoinColumn(name = "devolucion_id", nullable = false)
        private Devolucion devolucion;

        @ManyToOne
        @JoinColumn(name = "venta_item_id", nullable = false)
        private VentaItem ventaItem;

        @Column(nullable = false)
        private Integer cantidadDevuelta;

        @Column(nullable = false, precision = 15, scale = 2)
        private BigDecimal precioUnitario;

        @Column(nullable = false, precision = 15, scale = 2)
        private BigDecimal subtotal;

        public void calcularSubtotal() {
            this.subtotal = precioUnitario
                    .multiply(BigDecimal.valueOf(cantidadDevuelta));
        }
    }

