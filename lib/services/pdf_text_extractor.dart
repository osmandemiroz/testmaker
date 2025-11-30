import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf;

/// ********************************************************************
/// PdfTextExtractor
/// ********************************************************************
///
/// Service for extracting text content from PDF files.
///
/// This service uses Syncfusion PDF library to read and extract
/// text from PDF documents, which can then be used for question generation.
///
class PdfTextExtractor {
  const PdfTextExtractor();

  /// Extracts all text from a PDF file.
  ///
  /// Returns the extracted text as a single string.
  /// If the PDF cannot be read or contains no text, returns an empty string.
  Future<String> extractText(String pdfPath) async {
    try {
      final pdfFile = File(pdfPath);
      if (!await pdfFile.exists()) {
        return '';
      }

      final List<int> bytes = await pdfFile.readAsBytes();
      final document = pdf.PdfDocument(inputBytes: bytes);

      // Extract text from entire document
      final extractor = pdf.PdfTextExtractor(document);
      final extractedText = extractor.extractText();

      document.dispose();

      return extractedText.trim();
    } on Exception catch (_) {
      // If extraction fails, return empty string
      return '';
    }
  }

  /// Extracts text from a PDF file, limited to a maximum number of pages.
  ///
  /// This is useful for large PDFs where you only want to generate questions
  /// from the first N pages to avoid token limits or processing time.
  ///
  /// [maxPages] specifies the maximum number of pages to extract (default: 10).
  /// Note: This extracts all text but limits by character count to approximate page limits.
  Future<String> extractTextLimited(
    String pdfPath, {
    int maxPages = 10,
  }) async {
    try {
      // Extract all text first
      final fullText = await extractText(pdfPath);

      if (fullText.isEmpty) {
        return '';
      }

      // Approximate characters per page (rough estimate: 2000 chars per page)
      // This is a simple heuristic - actual page content varies
      const estimatedCharsPerPage = 2000;
      final maxChars = maxPages * estimatedCharsPerPage;

      if (fullText.length <= maxChars) {
        return fullText;
      }

      // Return first N characters (approximating first N pages)
      return fullText.substring(0, maxChars);
    } on Exception catch (_) {
      // If extraction fails, return empty string
      return '';
    }
  }
}
