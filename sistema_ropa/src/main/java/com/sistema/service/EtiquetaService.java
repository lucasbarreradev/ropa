package com.sistema.service;

import com.sistema.model.ProductoTalle;
import com.sistema.repository.ProductoTalleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uk.org.okapibarcode.backend.Code128;
import uk.org.okapibarcode.backend.HumanReadableLocation;
import uk.org.okapibarcode.output.Java2DRenderer;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Random;

@Service
@Transactional
public class EtiquetaService {

    private final ProductoTalleRepository productoTalleRepo;

    public EtiquetaService(ProductoTalleRepository productoTalleRepo) {
        this.productoTalleRepo = productoTalleRepo;
    }

    // ==========================================
    // GENERAR CÓDIGO DE BARRAS ÚNICO
    // ==========================================
    public String generarCodigoBarras(Long productoTalleId) {

        ProductoTalle productoTalle = productoTalleRepo.findById(productoTalleId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "ProductoTalle no encontrado"));

        // Si ya tiene código, retornarlo
        if (productoTalle.getCodigoBarras() != null &&
                !productoTalle.getCodigoBarras().isEmpty()) {
            return productoTalle.getCodigoBarras();
        }

        // Generar código único
        String codigo;
        do {
            codigo = generarCodigoAleatorio();
        } while (productoTalleRepo.existsByCodigoBarras(codigo));

        // Guardar en BD
        productoTalle.setCodigoBarras(codigo);
        productoTalleRepo.save(productoTalle);

        return codigo;
    }

    // ==========================================
    // GENERAR CÓDIGO ALEATORIO
    // ==========================================
    private String generarCodigoAleatorio() {
        // Formato: EMPXXXYYYY
        Random random = new Random();
        int numeroAleatorio = random.nextInt(9999);
        int idProducto = random.nextInt(999);

        return String.format("EMP%03d%04d", idProducto, numeroAleatorio);
    }

    // ==========================================
    // GENERAR IMAGEN DEL CÓDIGO DE BARRAS
    // ==========================================
    public byte[] generarImagenBarras(String codigo) {
        try {
            // Configurar el código de barras
            Code128 barcode = new Code128();
            barcode.setContent(codigo);
            barcode.setModuleWidth(2);  // Ancho de barras
            barcode.setBarHeight(50);   // Altura de barras
            barcode.setHumanReadableLocation(HumanReadableLocation.NONE);
            barcode.setFontName("Monospaced");
            barcode.setFontSize(12);
            // Calcular dimensiones
            int width = barcode.getWidth();
            int height = barcode.getHeight();

            // Crear imagen
            BufferedImage image = new BufferedImage(
                    width,
                    height,
                    BufferedImage.TYPE_BYTE_GRAY
            );

            Graphics2D g2d = image.createGraphics();
            g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                    RenderingHints.VALUE_ANTIALIAS_ON);

            // Fondo blanco
            g2d.setColor(Color.WHITE);
            g2d.fillRect(0, 0, width, height);

            // ==========================================
            // CORRECCIÓN: Java2DRenderer con 4 parámetros
            // ==========================================
            Java2DRenderer renderer = new Java2DRenderer(
                    g2d,           // Graphics2D
                    1.0,           // magnification (escala)
                    Color.WHITE,   // background color
                    Color.BLACK    // foreground color (barras)
            );

            renderer.render(barcode);
            g2d.dispose();

            // Convertir a bytes
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", baos);

            return baos.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Error generando código de barras: " + e.getMessage(), e);
        }
    }

    // ==========================================
    // BUSCAR POR CÓDIGO DE BARRAS
    // ==========================================
    public ProductoTalle buscarPorCodigoBarras(String codigo) {

        String codigoNormalizado = codigo
                .replace("-", "")
                .replace("'", "")
                .trim();

        return productoTalleRepo.findByCodigoBarras(codigoNormalizado)
                .orElseThrow(() -> new IllegalArgumentException(
                        "No se encontró producto con código: " + codigo));
    }

    // ==========================================
    // VERIFICAR SI EXISTE UN CÓDIGO
    // ==========================================
    public boolean existeCodigo(String codigo) {
        return productoTalleRepo.existsByCodigoBarras(codigo);
    }
}