// search delegate class for questions
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:provider/provider.dart';
import 'package:hajj_app/main.dart';

class QuestionSearch extends SearchDelegate<String> {
  final List<Question> questions;
  QuestionSearch(this.questions);

  // change direction
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(textTheme: theme.textTheme);
  }

  // change the hint text
  @override
  String get searchFieldLabel => 'ابحث عن سؤال';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9')
        .toLowerCase();
  }

  String _getBaseWord(String word) {
    if (word.length > 4 &&
        (word.startsWith("وال") ||
            word.startsWith("فال") ||
            word.startsWith("بال") ||
            word.startsWith("كال"))) {
      return word.substring(3);
    }
    if (word.length > 3 && word.startsWith("لل")) {
      return word.substring(2);
    }
    if (word.length > 2 && word.startsWith("ال")) {
      return word.substring(2);
    }
    return word;
  }

  bool _containsWord(String text, String queryWord, String baseQueryWord) {
    final words = text.split(RegExp(r'\s+'));
    for (var w in words) {
      if (w.isEmpty) continue;
      // Strip common punctuation from the word before checking
      String cleanedWord =
          w.replaceAll(RegExp(r'''[؟\?\.،,;:!*()\[\]"'\n\r\-\/]'''), '');
      if (cleanedWord.isEmpty) continue;

      if (cleanedWord == queryWord || cleanedWord == baseQueryWord) return true;

      String bw = _getBaseWord(cleanedWord);
      // Ensure the base target word starts or ends with the base query word
      if (bw == baseQueryWord ||
          bw.startsWith(baseQueryWord) ||
          bw.endsWith(baseQueryWord)) {
        return true;
      }
    }
    return false;
  }

  List<Question> _getFilteredQuestions(String query) {
    if (query.trim().isEmpty) {
      return questions;
    }

    final normalizedQuery = _normalizeText(query);
    final queryWords =
        normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();

    return questions.where((q) {
      final normalizedTitle = _normalizeText(q.question ?? "");
      final normalizedAnswer = _normalizeText(q.answerText ?? "");
      // Ensure ALL words in the query appear somewhere in the question or the answer
      return queryWords.every((word) {
        String baseWord = _getBaseWord(word);
        return _containsWord(normalizedTitle, word, baseWord) ||
            _containsWord(normalizedAnswer, word, baseWord);
      });
    }).toList();
  }

  RichText _buildHighlightedText(
      BuildContext context, String text, List<String> queryWords,
      {bool isTitle = true}) {
    if (queryWords.isEmpty || text.isEmpty) {
      return RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: "Zarids",
            fontSize: isTitle ? 26 : 20,
            color: isTitle
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final baseStyle = TextStyle(
      fontFamily: "Zarids",
      fontSize: isTitle ? 26 : 20,
      color: isTitle
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final highlightStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
    );

    final parts = text.split(' ');
    List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final normalizedPart = _normalizeText(part);
      bool isMatch = queryWords.any((q) {
        if (q.isEmpty) return false;
        String baseWord = _getBaseWord(q);
        return _containsWord(normalizedPart, q, baseWord);
      });

      spans.add(TextSpan(
        text: part + (i < parts.length - 1 ? ' ' : ''),
        style: isMatch ? highlightStyle : baseStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildSearchResultItem(
      BuildContext context, Question q, List<String> queryWords) {
    final normalizedTitle = _normalizeText(q.question ?? "");
    bool titleHasMatch = queryWords.any((w) {
      if (w.isEmpty) return false;
      String baseWord = _getBaseWord(w);
      return _containsWord(normalizedTitle, w, baseWord);
    });

    Widget titleWidget = _buildHighlightedText(
        context, q.question ?? 'بدون عنوان', queryWords,
        isTitle: true);

    Widget? answerSnippet;
    if (!titleHasMatch && q.answerText != null) {
      String answer = q.answerText!;
      String normalizedAnswer = _normalizeText(answer);
      int matchIndex = -1;
      for (var w in queryWords) {
        if (w.isEmpty) continue;
        String baseWord = _getBaseWord(w);

        final words = normalizedAnswer.split(RegExp(r'\s+'));
        for (var targetWord in words) {
          if (_containsWord(targetWord, w, baseWord)) {
            matchIndex = normalizedAnswer.indexOf(targetWord);
            break;
          }
        }
        if (matchIndex != -1) break;
      }

      if (matchIndex != -1) {
        int start = (matchIndex - 40).clamp(0, answer.length);
        int end = (matchIndex + 60).clamp(0, answer.length);

        if (start > 0) {
          int spaceIdx = answer.indexOf(' ', start);
          if (spaceIdx != -1 && spaceIdx < matchIndex) start = spaceIdx + 1;
        }
        if (end < answer.length) {
          int spaceIdx = answer.lastIndexOf(' ', end);
          if (spaceIdx != -1 && spaceIdx > matchIndex) end = spaceIdx;
        }

        String snippet = (start > 0 ? "... " : "") +
            answer.substring(start, end).replaceAll('\n', ' ') +
            (end < answer.length ? " ..." : "");
        answerSnippet = Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: _buildHighlightedText(context, snippet, queryWords,
              isTitle: false),
        );
      }
    }

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              if (answerSnippet != null) answerSnippet,
            ],
          ),
          onTap: () {
            Provider.of<GlobalAudioProvider>(context, listen: false)
                .setBookmarkMode(false);
            Get.to(() => QuestionPage(q),
                transition: Transition.rightToLeft,
                routeName: '/question/${q.no}');
          },
        ),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Question> suggestionList = _getFilteredQuestions(query);
    final queryWords =
        _normalizeText(query).split(' ').where((w) => w.isNotEmpty).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) =>
            _buildSearchResultItem(context, suggestionList[index], queryWords),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Question> suggestionList = _getFilteredQuestions(query);
    final queryWords =
        _normalizeText(query).split(' ').where((w) => w.isNotEmpty).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) =>
            _buildSearchResultItem(context, suggestionList[index], queryWords),
      ),
    );
  }
}
