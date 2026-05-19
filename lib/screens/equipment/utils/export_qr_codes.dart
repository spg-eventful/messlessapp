import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../ws/schema/equipment/equipment.dart';

class ExportQrCodes {
  static Future<void> exportEquipmentQrCodes(
    BuildContext context,
    List<Equipment> items,
  ) async {
    if (items.isEmpty) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final List<XFile> xFiles = [];

      for (final item in items) {
        final file = await _generateQrWithLabel(item, tempDir.path);
        if (file != null) xFiles.add(XFile(file.path));
      }

      if (xFiles.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            files: xFiles,
            text: items.length == 1
                ? 'QR-Code für ${items.first.label}'
                : 'QR-Codes für ${items.length} Gegenstände',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Export: $e')));
      }
    }
  }

  static Future<File?> _generateQrWithLabel(
    Equipment equipment,
    String tempPath,
  ) async {
    const double qrSize = 800.0;
    const double padding = 60.0;
    const double textHeight = 120.0;
    const double canvasWidth = qrSize + (padding * 2);
    const double canvasHeight = qrSize + textHeight + (padding * 2);

    final qrValidationResult = QrValidator.validate(
      data: equipment.id.toString(),
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) return null;

    final painter = QrPainter.withQr(
      qr: qrValidationResult.qrCode!,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: ui.Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: ui.Color(0xFF000000),
      ),
      gapless: true,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
      Paint()..color = Colors.white,
    );
    final qrImageData = await painter.toImageData(qrSize);
    if (qrImageData == null) return null;
    final codec = await ui.instantiateImageCodec(
      qrImageData.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    canvas.drawImage(frame.image, const Offset(padding, padding), Paint());

    final textPainter = TextPainter(
      text: TextSpan(
        text: equipment.label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: qrSize);

    textPainter.paint(
      canvas,
      Offset(padding + (qrSize - textPainter.width) / 2, padding + qrSize + 10),
    );

    final finalImage = await recorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) return null;

    final sanitizedLabel = equipment.label.replaceAll(RegExp(r'[^\w\s-]'), '');
    final file = File('$tempPath/QR_${sanitizedLabel}_${equipment.id}.png');
    return await file.writeAsBytes(byteData.buffer.asUint8List());
  }
}
