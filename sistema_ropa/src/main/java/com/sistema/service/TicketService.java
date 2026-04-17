package com.sistema.service;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.pdf.draw.LineSeparator;
import com.sistema.model.*;
import org.springframework.stereotype.Service;

import java.io.OutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.time.format.DateTimeFormatter;

@Service
public class TicketService {

    private static final DecimalFormat DF = new DecimalFormat("#,##0.00");
    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private Image generarCodigoBarras(PdfWriter writer, String codigo) throws Exception {

        Barcode128 barcode = new Barcode128();
        barcode.setCodeType(Barcode128.CODE128);
        barcode.setCode(codigo);

        Image barcodeImage = barcode.createImageWithBarcode(
                writer.getDirectContent(),
                BaseColor.BLACK,
                BaseColor.BLACK
        );

        barcodeImage.scalePercent(120);

        return barcodeImage;
    }

    public void generarTicketPdf(Venta venta, OutputStream out) throws Exception {

        Document document = new Document(PageSize.A4, 40, 40, 40, 40);

        PdfWriter writer = PdfWriter.getInstance(document, out);
        document.open();

        // ==============================
        // FUENTES
        // ==============================

        Font titulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
        Font bold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
        Font normal = FontFactory.getFont(FontFactory.HELVETICA, 10);
        Font small = FontFactory.getFont(FontFactory.HELVETICA, 9);
        Font smallGray = FontFactory.getFont(FontFactory.HELVETICA, 8, BaseColor.GRAY);
        Font totalFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);

        // ==============================
        // HEADER EMPRESA
        // ==============================

        Paragraph empresa = new Paragraph("MOBEZA ELECTRICIDAD", titulo);
        empresa.setAlignment(Element.ALIGN_CENTER);
        document.add(empresa);

        Paragraph direccion = new Paragraph(
                "Acceso Norte S/N - 2681 Etruria, Argentina", smallGray);
        direccion.setAlignment(Element.ALIGN_CENTER);
        document.add(direccion);

        Paragraph tel = new Paragraph(
                "Tel: (03562) 123-4567", smallGray);
        tel.setAlignment(Element.ALIGN_CENTER);
        tel.setSpacingAfter(10);
        document.add(tel);

        agregarLinea(document);

        Paragraph noFiscal = new Paragraph("COMPROBANTE NO FISCAL", bold);
        noFiscal.setAlignment(Element.ALIGN_CENTER);
        noFiscal.setSpacingAfter(10);
        document.add(noFiscal);

        // ==============================
        // DATOS DE VENTA
        // ==============================

        PdfPTable datos = new PdfPTable(2);
        datos.setWidthPercentage(100);
        datos.setWidths(new int[]{30, 70});

        datos.addCell(celda("Fecha:", bold));
        datos.addCell(celda(venta.getFechaVenta().format(DATE_FMT), normal));

        datos.addCell(celda("Ticket:", bold));
        datos.addCell(celda(venta.getCodigo(), normal));

        String cliente = venta.getCliente() != null
                ? venta.getCliente().getNombre() + " " + venta.getCliente().getApellido()
                : "Consumidor Final";

        datos.addCell(celda("Cliente:", bold));
        datos.addCell(celda(cliente, normal));

        datos.addCell(celda("Forma de pago:", bold));
        datos.addCell(celda(formatearFormaPago(venta.getFormaPago()), normal));

        document.add(datos);

        agregarLinea(document);

        // ==============================
        // TABLA ITEMS
        // ==============================

        PdfPTable tabla = new PdfPTable(4);
        tabla.setWidthPercentage(100);
        tabla.setWidths(new int[]{50, 10, 20, 20});

        tabla.addCell(header("Producto"));
        tabla.addCell(header("Cant"));
        tabla.addCell(header("Precio"));
        tabla.addCell(header("Subtotal"));

        for (VentaItem item : venta.getItems()) {

            ProductoTalle pt = item.getProductoTalle();

            String desc =
                    pt.getProducto().getDescripcion() +
                            " (Talle " + pt.getTalle().getNombre() + ")";

            tabla.addCell(celda(desc, small));

            tabla.addCell(celdaCentro(item.getCantidad().toString()));

            tabla.addCell(celdaCentro("$" + DF.format(item.getPrecioUnitario())));

            tabla.addCell(celdaCentro("$" + DF.format(item.getSubtotal())));
        }

        document.add(tabla);

        agregarLinea(document);

        // ==============================
        // TOTAL
        // ==============================

        PdfPTable totalTable = new PdfPTable(2);
        totalTable.setWidthPercentage(100);
        totalTable.setWidths(new int[]{70, 30});

        boolean esConsumidorFinal = venta.getCliente() == null ||
                venta.getCliente().getCondicionIva() == CondicionIva.CONSUMIDOR_FINAL;

        if (!esConsumidorFinal) {

            TotalesConIva totales = calcularTotales(venta);

            PdfPCell subLabel = celda("Subtotal:", normal);
            subLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);

            PdfPCell subValor = celda("$" + DF.format(totales.getTotalNeto()), normal);
            subValor.setHorizontalAlignment(Element.ALIGN_RIGHT);

            totalTable.addCell(subLabel);
            totalTable.addCell(subValor);

            PdfPCell ivaLabel = celda("IVA:", normal);
            ivaLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);

            PdfPCell ivaValor = celda("$" + DF.format(totales.getTotalIva()), normal);
            ivaValor.setHorizontalAlignment(Element.ALIGN_RIGHT);

            totalTable.addCell(ivaLabel);
            totalTable.addCell(ivaValor);
        }

        PdfPCell label = celda("TOTAL:", totalFont);
        label.setHorizontalAlignment(Element.ALIGN_RIGHT);

        PdfPCell valor = celda("$" + DF.format(venta.getTotal()), totalFont);
        valor.setHorizontalAlignment(Element.ALIGN_RIGHT);

        totalTable.addCell(label);
        totalTable.addCell(valor);

        document.add(totalTable);

        agregarLinea(document);

        // ==============================
        // POLITICA
        // ==============================

        Paragraph politicaTitulo =
                new Paragraph("POLITICA DE DEVOLUCION", bold);
        politicaTitulo.setAlignment(Element.ALIGN_CENTER);
        politicaTitulo.setSpacingBefore(10);
        document.add(politicaTitulo);

        com.itextpdf.text.List lista = new com.itextpdf.text.List(false, 10);
        lista.add(new ListItem("Devoluciones dentro de los 15 dias", small));
        lista.add(new ListItem("Debe conservar este ticket como comprobante", small));
        lista.add(new ListItem("Producto sin uso y con etiqueta original", small));

        document.add(lista);

        Paragraph espacio = new Paragraph(" ");
        espacio.setSpacingBefore(10);
        document.add(espacio);

        Paragraph tituloCodigo = new Paragraph("Codigo de Ticket", bold);
        tituloCodigo.setAlignment(Element.ALIGN_CENTER);
        document.add(tituloCodigo);

        Image barcode = generarCodigoBarras(
                writer,
                venta.getCodigo()
        );

        barcode.setAlignment(Element.ALIGN_CENTER);
        barcode.setSpacingBefore(5);

        document.add(barcode);

        document.close();
    }

    // ==============================
    // HELPERS
    // ==============================

    private PdfPCell celda(String txt, Font font) {
        PdfPCell c = new PdfPCell(new Phrase(txt, font));
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(5);
        return c;
    }

    private PdfPCell celdaCentro(String txt) {
        PdfPCell c = new PdfPCell(new Phrase(txt));
        c.setBorder(Rectangle.NO_BORDER);
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        c.setPadding(5);
        return c;
    }

    private PdfPCell header(String txt) {
        PdfPCell c = new PdfPCell(new Phrase(txt));
        c.setBackgroundColor(BaseColor.LIGHT_GRAY);
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        c.setPadding(6);
        return c;
    }

    private void agregarLinea(Document document) throws DocumentException {
        LineSeparator linea = new LineSeparator();
        linea.setLineWidth(1f);
        linea.setLineColor(BaseColor.BLACK);
        document.add(new Chunk(linea));
    }

    private String formatearFormaPago(FormaPago formaPago) {
        switch (formaPago) {
            case CONTADO: return "Efectivo";
            case TARJETA: return "Tarjeta";
            case CUENTA_CORRIENTE: return "Cuenta Corriente";
            default: return formaPago.toString();
        }
    }

    private TotalesConIva calcularTotales(Venta venta) {
        BigDecimal netoAcum = BigDecimal.ZERO;
        BigDecimal ivaAcum = BigDecimal.ZERO;
        for (VentaItem item : venta.getItems()) {
            BigDecimal ivaRate = item.getAlicuotaIva();
            BigDecimal subtotal = item.getSubtotal();
            BigDecimal netoItem = subtotal.divide(
                    BigDecimal.ONE.add(ivaRate.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP)), 2, RoundingMode.HALF_UP );
            BigDecimal ivaItem = subtotal.subtract(netoItem);
            netoAcum = netoAcum.add(netoItem);
            ivaAcum = ivaAcum.add(ivaItem);
        }
        BigDecimal total = netoAcum.add(ivaAcum);
        return new TotalesConIva(netoAcum, ivaAcum, total, null);
    }
}