import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'section_card.dart';
import '../../../core/models/memo_model.dart';
import '../../../core/widgets/karaoke_transcript_widget.dart';

class KaraokeTranscriptCard extends StatelessWidget {
  final List<WordTimestamp> words;
  final List<TranscriptSegment> segments;
  final Duration currentPosition;

  const KaraokeTranscriptCard({
    super.key,
    required this.words,
    required this.segments,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'memo_sections.transcription'.tr(),
      icon: Icons.mic_rounded,
      accentColor: const Color(0xFF3B82F6), // Blue
      child: words.isNotEmpty
          ? KaraokeTranscriptWidget(
              words: words,
              currentPosition: currentPosition,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: segments.map((segment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    segment.original,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
