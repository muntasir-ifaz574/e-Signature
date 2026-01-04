import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';
import 'package:pdf/pdf.dart' hide PdfDocument, PdfPage, PdfImage, PdfColor;
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entity/field_entity.dart';
import '../../presentation/providers/editor_provider.dart';
import '../../../document/domain/entity/document_entity.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final DocumentEntity document;
  const EditorScreen({super.key, required this.document});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _loadingFile = true;
  PdfDocument? _pdfDocument;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      final url = widget.document.fileUrl;
      final response = await http.get(Uri.parse(url));
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.document.id}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      final document = await PdfDocument.openFile(file.path);

      if (mounted) {
        setState(() {
          _pdfDocument = document;
          _totalPages = document.pagesCount;
          _loadingFile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load PDF: $e')));
        setState(() => _loadingFile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider(widget.document));
    final controller = ref.read(editorProvider(widget.document).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'export') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: SelectableText(controller.exportJson()),
                  ),
                );
              } else if (v == 'import') {
                _showImportDialog(controller);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Config'),
              ),
              if (!editorState.isPublished)
                const PopupMenuItem(
                  value: 'import',
                  child: Text('Import Config'),
                ),
            ],
          ),
          if (!editorState.isPublished)
            TextButton(
              onPressed: () => controller.togglePublish(),
              child: const Text(
                'PUBLISH',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                await controller.save();
                if (!mounted) return;

                if (controller.validateSubmission()) {
                  _generateFinalPdf(editorState.fields);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Draft Saved (Fill all required fields to Finish)',
                      ),
                    ),
                  );
                }
              },
              child: Text(
                controller.validateSubmission() ? 'SAVE' : 'FINISH',
                style: const TextStyle(color: Colors.greenAccent),
              ),
            ),
        ],
      ),
      body: _loadingFile
          ? const Center(child: CircularProgressIndicator())
          : _pdfDocument == null
          ? const Center(child: Text('Error loading PDF'))
          : ListView.builder(
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                final pageFields = editorState.fields
                    .where((f) => f.pageIndex == index)
                    .toList();
                return _PdfPageWrapper(
                  document: _pdfDocument!,
                  pageIndex: index + 1,
                  fields: pageFields,
                  isPublished: editorState.isPublished,
                  onFieldUpdate: (f) => controller.updateField(f),
                  onFieldDelete: (id) => controller.deleteField(id),
                  onFieldTap: (f) => _handleFieldTap(f, controller),
                  selectedFieldId: editorState.selectedFieldId,
                  onSelect: (id) => controller.selectField(id),
                );
              },
            ),
      bottomNavigationBar: !editorState.isPublished
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        controller.addField(FieldType.signature, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_fields),
                    onPressed: () => controller.addField(FieldType.text, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_box),
                    onPressed: () => controller.addField(FieldType.checkbox, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => controller.addField(FieldType.date, 0),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _showImportDialog(EditorController controller) {
    final c = TextEditingController(text: controller.exportJson());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit JSON Config'),
        content: TextField(controller: c, maxLines: 10, minLines: 5),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.importJson(c.text);
              Navigator.pop(context);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _handleFieldTap(FieldEntity field, EditorController controller) async {
    if (field.type == FieldType.text) {
      final c = TextEditingController(text: field.value);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: TextField(controller: c),
          actions: [
            TextButton(
              onPressed: () {
                controller.updateField(field.copyWith(value: c.text));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else if (field.type == FieldType.date) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date != null) {
        controller.updateField(
          field.copyWith(value: date.toString().split(' ')[0]),
        );
      }
    } else if (field.type == FieldType.checkbox) {
      final current = field.value == 'true';
      controller.updateField(field.copyWith(value: (!current).toString()));
    } else if (field.type == FieldType.signature) {
      final SignatureController _sigController = SignatureController(
        penStrokeWidth: 3,
        penColor: Colors.black,
      );

      if (field.value != null && field.value!.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signature cannot be edited after saving.'),
            ),
          );
        }
        return;
      }

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Signature(
                      controller: _sigController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _sigController.clear(),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () async {
                if (_sigController.isNotEmpty) {
                  final data = await _sigController.toPngBytes();
                  if (data != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    final url = await controller.uploadSignature(data);
                    Navigator.pop(context);

                    if (url != null) {
                      controller.updateField(field.copyWith(value: url));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to upload signature'),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _generateFinalPdf(List<FieldEntity> fields) async {
    setState(() => _loadingFile = true);
    try {
      final doc = pw.Document();
      for (int i = 1; i <= _totalPages; i++) {
        final page = await _pdfDocument!.getPage(i);
        final imageBytes = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
        );

        if (imageBytes != null) {
          final image = pw.MemoryImage(imageBytes.bytes);
          final pageFields = fields
              .where((f) => f.pageIndex == (i - 1))
              .toList();
          final List<pw.Widget> fieldWidgets = [];

          for (final f in pageFields) {
            pw.Widget child;
            if (f.type == FieldType.signature && f.value != null) {
              try {
                final val = f.value!;
                if (val.startsWith('http')) {
                  final response = await http.get(Uri.parse(val));
                  if (response.statusCode == 200) {
                    child = pw.Image(pw.MemoryImage(response.bodyBytes));
                  } else {
                    child = pw.Text("Sig (Load Err)");
                  }
                } else {
                  child = pw.Image(pw.MemoryImage(base64Decode(val)));
                }
              } catch (_) {
                child = pw.Text("Error");
              }
            } else if (f.type == FieldType.checkbox) {
              child = f.value == 'true'
                  ? pw.Text("X", style: const pw.TextStyle(fontSize: 20))
                  : pw.Container();
            } else {
              child = pw.Text(f.value ?? "");
            }

            fieldWidgets.add(
              pw.Positioned(
                left: f.x,
                top: f.y,
                child: pw.SizedBox(
                  width: f.width,
                  height: f.height,
                  child: child,
                ),
              ),
            );
          }

          doc.addPage(
            pw.Page(
              pageFormat: PdfPageFormat(page.width, page.height),
              build: (pw.Context context) {
                return pw.Stack(children: [pw.Image(image), ...fieldWidgets]);
              },
            ),
          );
        }
        await page.close();
      }
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating PDF: $e")));
    } finally {
      setState(() => _loadingFile = false);
    }
  }
}

class _PdfPageWrapper extends StatefulWidget {
  final PdfDocument document;
  final int pageIndex;
  final List<FieldEntity> fields;
  final bool isPublished;
  final Function(FieldEntity) onFieldUpdate;
  final Function(String) onFieldDelete;
  final Function(FieldEntity) onFieldTap;
  final String? selectedFieldId;
  final Function(String) onSelect;

  const _PdfPageWrapper({
    required this.document,
    required this.pageIndex,
    required this.fields,
    required this.isPublished,
    required this.onFieldUpdate,
    required this.onFieldDelete,
    required this.onFieldTap,
    required this.selectedFieldId,
    required this.onSelect,
  });

  @override
  State<_PdfPageWrapper> createState() => _PdfPageWrapperState();
}

class _PdfPageWrapperState extends State<_PdfPageWrapper> {
  Image? _pageImage;
  double _pageWidth = 0;
  double _pageHeight = 0;

  @override
  void initState() {
    super.initState();
    _renderPage();
  }

  Future<void> _renderPage() async {
    final page = await widget.document.getPage(widget.pageIndex);
    final pageImage = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.png,
    );
    if (pageImage != null) {
      if (mounted) {
        setState(() {
          _pageImage = Image.memory(pageImage.bytes);
          _pageWidth = page.width;
          _pageHeight = page.height;
        });
      }
    }
    await page.close();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageImage == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _pageWidth;
        final displayHeight = _pageHeight * scale;

        return SizedBox(
          height: displayHeight,
          width: constraints.maxWidth,
          child: Stack(
            children: [
              Positioned.fill(child: _pageImage!),
              ...widget.fields.map((field) {
                final isSelected = widget.selectedFieldId == field.id;

                Widget contentWidget;
                if (field.type == FieldType.signature && field.value != null) {
                  if (field.value!.startsWith('http')) {
                    contentWidget = Image.network(
                      field.value!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Err: $error',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    );
                  } else {
                    try {
                      contentWidget = Image.memory(
                        base64Decode(field.value!),
                        fit: BoxFit.contain,
                      );
                    } catch (e) {
                      contentWidget = Text(
                        field.value ?? field.type.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: field.isRequired
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }
                  }
                } else {
                  contentWidget = Text(
                    field.value ?? field.type.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: field.isRequired
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }

                return Positioned(
                  left: field.x * scale,
                  top: field.y * scale,
                  width: field.width * scale,
                  height: field.height * scale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // The Field Content & Drag Logic
                      GestureDetector(
                        onTap: () {
                          widget.onSelect(field.id);
                          if (widget.isPublished) widget.onFieldTap(field);
                        },
                        onPanUpdate: widget.isPublished
                            ? null
                            : (details) {
                                widget.onSelect(field.id);
                                widget.onFieldUpdate(
                                  field.copyWith(
                                    x: field.x + details.delta.dx / scale,
                                    y: field.y + details.delta.dy / scale,
                                  ),
                                );
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: field.type == FieldType.signature
                                ? (field.value != null
                                      ? Colors.transparent
                                      : Colors.blue.withOpacity(0.2))
                                : Colors.yellow.withOpacity(0.3),
                            border: Border.all(
                              color: isSelected ? Colors.red : Colors.black,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(child: contentWidget),
                              if (field.isRequired && field.value == null)
                                const Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Text(
                                    '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Resize Handle (Bottom Right)
                      if (!widget.isPublished && isSelected)
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              final newWidth =
                                  field.width + details.delta.dx / scale;
                              final newHeight =
                                  field.height + details.delta.dy / scale;
                              widget.onFieldUpdate(
                                field.copyWith(
                                  width: newWidth > 20 ? newWidth : 20,
                                  height: newHeight > 20 ? newHeight : 20,
                                ),
                              );
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.drag_handle,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Delete Button
                      if (!widget.isPublished && isSelected)
                        Positioned(
                          right: -10,
                          top: -10,
                          child: GestureDetector(
                            onTap: () => widget.onFieldDelete(field.id),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 2,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
