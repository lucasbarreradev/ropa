package com.sistema.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
    @Getter
@Setter
    @NoArgsConstructor
@AllArgsConstructor
    @Table(name = "devolucion")
    public class Devolucion {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @Column(nullable = false, unique = true)
        private String codigo;

        @ManyToOne
        @JoinColumn(name = "venta_id", nullable = false)
        private Venta venta;

        @Column(nullable = false)
        private LocalDateTime fecha;

        @Enumerated(EnumType.STRING)
        @Column(nullable = false)
        private MotivoDevolucion motivo;

        @Column(length = 500)
        private String observaciones;

        @Column(nullable = false, precision = 15, scale = 2)
        private BigDecimal totalDevuelto;

        @OneToMany(mappedBy = "devolucion", cascade = CascadeType.ALL, orphanRemoval = true)
        private List<DevolucionItem> items = new ArrayList<>();

        @Enumerated(EnumType.STRING)
        @Column(nullable = false)
        private EstadoDevolucion estado;

        // Métodos de conveniencia
        public void agregarItem(DevolucionItem item) {
            items.add(item);
            item.setDevolucion(this);
        }

        public void calcularTotal() {
            this.totalDevuelto = items.stream()
                    .map(DevolucionItem::getSubtotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
        }

        public enum MotivoDevolucion {
            TALLE_INCORRECTO,
            DEFECTO_FABRICA,
            NO_LE_GUSTO,
            CAMBIO_COLOR,
            OTRO
        }

        public enum EstadoDevolucion {
            PENDIENTE,      // Creada pero no procesada
            APROBADA,       // Aprobada, stock devuelto
            RECHAZADA       // No se acepta la devolución
        }
    }

