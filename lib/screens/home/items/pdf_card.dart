import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/models/course.dart';
import 'package:testmaker/screens/home/widgets/widgets.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds a card for a PDF in a course.
class PdfCard extends StatefulWidget {
  const PdfCard({
    required this.theme,
    required this.textTheme,
    required this.controller,
    required this.course,
    required this.pdfIndex,
    required this.fileName,
    required this.pdfPath,
    required this.constraints,
    required this.onViewPdf,
    required this.showRenameDialog,
    required this.onDelete,
    required this.onGenerateQuestions,
    required this.onGenerateFlashcards,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final HomeController controller;
  final Course course;
  final int pdfIndex;
  final String fileName;
  final String pdfPath;
  final BoxConstraints constraints;
  final void Function(String pdfPath, String pdfName) onViewPdf;
  final Future<void> Function({
    required String title,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) showRenameDialog;
  final void Function(Course course, int pdfIndex, String pdfName) onDelete;
  final void Function(Course course, String pdfPath) onGenerateQuestions;
  final void Function(Course course, String pdfPath) onGenerateFlashcards;

  @override
  State<PdfCard> createState() => _PdfCardState();
}

class _PdfCardState extends State<PdfCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final pdfName = widget.course.getPdfName(widget.pdfIndex, widget.pdfPath);

    return Container(
      margin: ResponsiveSizer.cardMarginFromConstraints(widget.constraints),
      child: Material(
        color: widget.theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          ResponsiveSizer.borderRadiusFromConstraints(widget.constraints),
        ),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () => widget.onViewPdf(widget.pdfPath, pdfName),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    widget.constraints,
                  ),
                ),
                topRight: Radius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    widget.constraints,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveSizer.cardPaddingFromConstraints(
                    widget.constraints,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: ResponsiveSizer.iconContainerSizeFromConstraints(
                        widget.constraints,
                        multiplier: 1.2,
                      ),
                      height: ResponsiveSizer.iconContainerSizeFromConstraints(
                        widget.constraints,
                        multiplier: 1.2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveSizer.borderRadiusFromConstraints(
                            widget.constraints,
                          ),
                        ),
                        color: widget.theme.colorScheme.errorContainer,
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: widget.theme.colorScheme.onErrorContainer,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          widget.constraints,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveSizer.spacingFromConstraints(
                        widget.constraints,
                        multiplier: 2,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            pdfName,
                            style: widget.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              widget.constraints,
                              multiplier: 0.5,
                            ),
                          ),
                          Text(
                            'PDF Document',
                            style: widget.textTheme.bodySmall?.copyWith(
                              color: widget.theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit button
                    IconButton(
                      onPressed: () => widget.showRenameDialog(
                        title: 'Rename PDF',
                        currentName: pdfName,
                        onSave: (String newName) async {
                          await widget.controller.renamePdf(
                            widget.pdfIndex,
                            newName,
                          );
                        },
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          widget.constraints,
                          multiplier: 0.9,
                        ),
                      ),
                      color: widget.theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      tooltip: 'Rename',
                    ),
                    // Delete button
                    IconButton(
                      onPressed: () => widget.onDelete(
                        widget.course,
                        widget.pdfIndex,
                        pdfName,
                      ),
                      icon: Icon(
                        Icons.delete_outlined,
                        size: ResponsiveSizer.iconSizeFromConstraints(
                          widget.constraints,
                          multiplier: 0.9,
                        ),
                      ),
                      color: widget.theme.colorScheme.error,
                      tooltip: 'Delete',
                    ),
                    // Expand/collapse button with animation
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        turns: _isExpanded ? 0.5 : 0.0,
                        child: Icon(
                          Icons.expand_more,
                          size: ResponsiveSizer.iconSizeFromConstraints(
                            widget.constraints,
                            multiplier: 0.9,
                          ),
                        ),
                      ),
                      color: widget.theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      tooltip: _isExpanded ? 'Collapse' : 'Expand',
                    ),
                  ],
                ),
              ),
            ),
            // Animated expandable section for generate buttons
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: _isExpanded
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            widget.theme.colorScheme.surfaceContainerHighest,
                            widget.theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              widget.constraints,
                            ),
                          ),
                          bottomRight: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              widget.constraints,
                            ),
                          ),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              widget.constraints,
                            ),
                          ),
                          bottomRight: Radius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              widget.constraints,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveSizer.cardPaddingFromConstraints(
                              widget.constraints,
                            ),
                            vertical: ResponsiveSizer.spacingFromConstraints(
                              widget.constraints,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Divider
                              Container(
                                height: 1,
                                margin: EdgeInsets.only(
                                  bottom:
                                      ResponsiveSizer.spacingFromConstraints(
                                    widget.constraints,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Colors.transparent,
                                      widget.theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Generate Questions button
                              AnimatedActionButton(
                                theme: widget.theme,
                                textTheme: widget.textTheme,
                                constraints: widget.constraints,
                                icon: Icons.auto_awesome,
                                label: 'Generate Questions',
                                isLoading:
                                    widget.controller.isGeneratingQuestions,
                                onPressed:
                                    widget.controller.isGeneratingQuestions
                                        ? null
                                        : () => widget.onGenerateQuestions(
                                              widget.course,
                                              widget.pdfPath,
                                            ),
                              ),
                              SizedBox(
                                height: ResponsiveSizer.spacingFromConstraints(
                                  widget.constraints,
                                  multiplier: 0.75,
                                ),
                              ),
                              // Generate Flashcards button
                              AnimatedActionButton(
                                theme: widget.theme,
                                textTheme: widget.textTheme,
                                constraints: widget.constraints,
                                icon: Icons.style_outlined,
                                label: 'Generate Flashcards',
                                isLoading:
                                    widget.controller.isGeneratingFlashcards,
                                onPressed:
                                    widget.controller.isGeneratingFlashcards
                                        ? null
                                        : () => widget.onGenerateFlashcards(
                                              widget.course,
                                              widget.pdfPath,
                                            ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
