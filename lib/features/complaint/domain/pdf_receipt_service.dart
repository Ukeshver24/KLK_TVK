import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/services/app_permission_service.dart';

class PdfReceiptService {
  /// Generate official TVK grievance acknowledgment PDF and save to device
  static Future<String?> generateAndSaveReceipt({
    required String referenceId,
    required String name,
    required String phone,
    String? constituency,
    String? submissionDate,
    String? complaintDescription,
  }) async {
    try {
      // Remove '#' symbol if present
      final cleanRefId = referenceId.replaceAll('#', '').trim();
      final applicantName = (name.trim().isNotEmpty) ? name.trim() : 'Gowtham J';
      final mobileNumber = (phone.trim().isNotEmpty) ? phone.trim() : '+91 9876543210';
      final cleanConstituency = (constituency != null && constituency.trim().isNotEmpty)
          ? constituency.trim()
          : 'Kallakurichi';
      final formattedDate = (submissionDate != null && submissionDate.trim().isNotEmpty)
          ? submissionDate.trim()
          : '27 Aug 2026, 12:35 PM';
      final descriptionText = (complaintDescription != null && complaintDescription.trim().isNotEmpty)
          ? complaintDescription.trim()
          : 'Water supply issue in Ward 4, Kallakurichi constituency. Seeking immediate inspection and redressal from the local authorities.';

      // Load Unicode Tamil font to ensure all Tamil + English characters render smoothly
      pw.Font? ttfFont;
      try {
        final fontData = await rootBundle.load('assets/fonts/NotoSansTamil-Regular.ttf');
        ttfFont = pw.Font.ttf(fontData);
      } catch (fontErr) {
        debugPrint('Custom Tamil font load notice: $fontErr');
      }

      final pageTheme = ttfFont != null
          ? pw.ThemeData.withFont(
              base: ttfFont,
              bold: ttfFont,
            )
          : pw.ThemeData.base();

      final pdf = pw.Document(theme: pageTheme);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pageTheme,
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('#800000'),
                  width: 2,
                ),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 🏛️ TVK OFFICIAL LETTERHEAD HEADER BANNER
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(18),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#800000'),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#FFC107'),
                        width: 1.5,
                      ),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'TAMILAGA VETRI KAZHAGAM (TVK)',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#FFC107'),
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'PUBLIC GRIEVANCE REDRESSAL PORTAL - KALLAKURICHI CONSTITUENCY',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 18),

                  // 📄 LETTER HEAD TITLE
                  pw.Center(
                    child: pw.Text(
                      'OFFICIAL COMPLAINT ACKNOWLEDGMENT LETTER',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#500000'),
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  // 📌 REFERENCE ID BOX (Status pill removed as requested)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FFF9E6'),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#FFC107'),
                        width: 1.5,
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'REFERENCE ID',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#8C6B00'),
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          cleanRefId,
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#500000'),
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 18),

                  // 👤 CITIZEN DETAILS TABLE
                  pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfColor.fromHex('#E5DCDC')),
                    ),
                    child: pw.Column(
                      children: [
                        _buildPdfRow('Applicant Name', applicantName),
                        pw.Divider(color: PdfColor.fromHex('#EBE5E5')),
                        _buildPdfRow('Mobile Number', mobileNumber),
                        pw.Divider(color: PdfColor.fromHex('#EBE5E5')),
                        _buildPdfRow('Constituency', cleanConstituency),
                        pw.Divider(color: PdfColor.fromHex('#EBE5E5')),
                        _buildPdfRow('Submission Date', formattedDate),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 18),

                  // 📝 COMPLAINT DESCRIPTION BOX (TEXT ALIGN JUSTIFY)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfColor.fromHex('#E5DCDC')),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'COMPLAINT DESCRIPTION / GRIEVANCE DETAILS',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#800000'),
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          descriptionText,
                          textAlign: pw.TextAlign.justify,
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#2C0000'),
                            fontSize: 11,
                            lineSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.Spacer(),

                  // 📱 SCANNABLE APP PLAY STORE QR CODE FOOTER
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FAFAFA'),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
                    ),
                    child: pw.Row(
                      children: [
                        // Scannable Barcode QR Code Widget (Redirects to App on Play Store)
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: 'https://play.google.com/store/apps/details?id=com.tvk.grievance.kallakurichi',
                          width: 64,
                          height: 64,
                        ),
                        pw.SizedBox(width: 14),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'SCAN TO TRACK STATUS LIVE',
                                style: pw.TextStyle(
                                  color: PdfColor.fromHex('#500000'),
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Scan this QR code to open the TVK Official App on Play Store or Apple App Store based on your mobile device to track complaint resolution live.',
                                style: const pw.TextStyle(
                                  color: PdfColors.grey800,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // Digital Signature Footnote
                  pw.Center(
                    child: pw.Text(
                      'Digitally generated official grievance acknowledgment letter by TVK Public Service Portal.',
                      style: const pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save PDF file directly into Mobile Downloads folder
      final pdfBytes = await pdf.save();
      final fileName = 'TVK_Grievance_ACK_${cleanRefId.replaceAll('/', '_')}.pdf';

      // Check / request storage permission
      await AppPermissionService.instance.ensureStoragePermission();

      Directory? outputDir;
      try {
        if (Platform.isAndroid) {
          final publicDownload = Directory('/storage/emulated/0/Download');
          if (await publicDownload.exists()) {
            outputDir = publicDownload;
          } else {
            try {
              await publicDownload.create(recursive: true);
              outputDir = publicDownload;
            } catch (_) {
              outputDir = null;
            }
          }

          if (outputDir == null) {
            final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
            if (extDirs != null && extDirs.isNotEmpty) {
              outputDir = extDirs.first;
            }
          }
        }
      } catch (_) {
        outputDir = null;
      }

      outputDir ??= await getApplicationDocumentsDirectory();

      File file = File('${outputDir.path}/$fileName');
      try {
        await file.writeAsBytes(pdfBytes, flush: true);
      } catch (writeErr) {
        debugPrint('Public write notice: $writeErr. Falling back to application documents directory.');
        final fallbackDir = await getApplicationDocumentsDirectory();
        file = File('${fallbackDir.path}/$fileName');
        await file.writeAsBytes(pdfBytes, flush: true);
      }

      return file.path;
    } catch (e) {
      debugPrint('Error generating PDF receipt: $e');
      return null;
    }
  }

  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 11,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#2C0000'),
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
