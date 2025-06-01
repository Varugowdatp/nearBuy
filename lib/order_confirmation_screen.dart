import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final DocumentSnapshot product;

  const OrderConfirmationScreen({super.key, required this.product});

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Order Receipt", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text("Product Name: ${product['name']}"),
              pw.Text("Description: ${product['description']}"),
              pw.Text("Price: ₹${product['price']}"),
              pw.Text("Shop ID: ${product['shopId']}"),
              pw.Text("Order Date: ${DateTime.now()}"),
              pw.SizedBox(height: 20),
              pw.Text("Thank you for your purchase!"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your order for '${product['name']}' has been placed successfully!",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => generatePdf(context),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Download Receipt as PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
