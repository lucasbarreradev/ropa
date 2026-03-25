package com.sistema.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class Producto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(unique = true, nullable = false)
    private String sku;
    @ManyToOne
    @JoinColumn(name="proveedor_id")
    @JsonIgnore
    private Proveedor proveedor;
    private String descripcion;
    @Enumerated(EnumType.STRING)
    private TipoIva tipoIva;
    @OneToMany(mappedBy = "producto", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<ProductoTalle> talles = new ArrayList<>();
    public int getStockTotal() {
        return talles.stream()
                .mapToInt(ProductoTalle::getStock)
                .sum();
    }

    public BigDecimal getPrecioDesde() {
        return talles.stream()
                .map(ProductoTalle::getPrecioContado)
                .min(BigDecimal::compareTo)
                .orElse(BigDecimal.ZERO);
    }
}
