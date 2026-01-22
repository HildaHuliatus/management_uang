import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

Future<void> generateLaporanPdf({
  required String namaUser,
  required double pemasukan,
  required double pengeluaran,
  required double saldo,
  required List<Map<String, dynamic>> kategori,
  required List<Map<String, dynamic>> transaksi,
}) async {
  final pdf = pw.Document();
  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  final dateFormat = DateFormat('dd MMM yyyy');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [

        // ===== HEADER =====
        pw.Text(
          'LAPORAN KEUANGAN',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Nama: $namaUser'),
        pw.Text('Tanggal Cetak: ${dateFormat.format(DateTime.now())}'),

        pw.Divider(),

        // ===== RINGKASAN =====
        pw.Text('RINGKASAN KEUANGAN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _row('Total Pemasukan', currency.format(pemasukan)),
            _row('Total Pengeluaran', currency.format(pengeluaran)),
            _rowBold('Saldo Bersih', currency.format(saldo)),
          ],
        ),

        pw.SizedBox(height: 20),

        // ===== BREAKDOWN =====
        pw.Text('RINGKASAN PENGELUARAN PER KATEGORI',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                _cellBold('Kategori'),
                _cellBold('Nominal'),
                _cellBold('Persentase'),
              ],
            ),
            ...kategori.map((e) => pw.TableRow(
              children: [
                _cell(e['title']),
                _cell(currency.format(e['amount'])),
                _cell(e['subtitle']),
              ],
            )),
          ],
        ),

        pw.SizedBox(height: 20),

        // ===== DETAIL TRANSAKSI =====
        pw.Text('DETAIL TRANSAKSI',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                _cellBold('Tanggal'),
                _cellBold('Deskripsi'),
                _cellBold('Tipe'),
                _cellBold('Nominal'),
              ],
            ),
            ...transaksi.map((t) => pw.TableRow(
              children: [
                _cell(dateFormat.format(DateTime.parse(t['transaction_date']))),
                _cell(t['description'] ?? '-'),
                _cell(t['transaction_type'] == 'income' ? 'Pemasukan' : 'Pengeluaran'),
                _cell(currency.format(t['amount'])),
              ],
            )),
          ],
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

// ===== Helper =====
pw.TableRow _row(String label, String value) => pw.TableRow(
  children: [
    _cell(label),
    _cell(value),
  ],
);

pw.TableRow _rowBold(String label, String value) => pw.TableRow(
  children: [
    _cellBold(label),
    _cellBold(value),
  ],
);

pw.Widget _cell(String text) =>
    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text));

pw.Widget _cellBold(String text) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
