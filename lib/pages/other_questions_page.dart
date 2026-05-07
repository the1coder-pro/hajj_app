import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hajj_app/components/question_tile.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/pages/other_question_page.dart';
import 'package:http/http.dart' as http;

class OtherQuestionsPage extends StatefulWidget {
  const OtherQuestionsPage({
    super.key,
  });

  @override
  State<OtherQuestionsPage> createState() => _OtherQuestionsPageState();
}

class _OtherQuestionsPageState extends State<OtherQuestionsPage> {
  final otherQuestionsLink =
      'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/4';

  late Future<Map<String, List<OtherQuestion>>> _groupedQuestionsFuture;

  static const String _allQuestionsChipTitle = 'الكل';
  String _selectedSection = _allQuestionsChipTitle;

  double _drawerWidth = 300.0;
  double _detailsWidth = 400.0;
  OtherQuestion? _selectedQuestion;

  @override
  void initState() {
    super.initState();
    _groupedQuestionsFuture = _loadAndGroupQuestions();
  }

  Future<Map<String, List<OtherQuestion>>> _loadAndGroupQuestions() async {
    final response = await http.get(Uri.parse(otherQuestionsLink));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    var decodedData = utf8.decode(response.bodyBytes);
    var data = jsonDecode(decodedData) as List;

    final Map<String, List<OtherQuestion>> questionsBySection = {};
    for (var item in data) {
      final question = OtherQuestion.fromJson(item);
      final section = question.section ?? 'متفرقات';
      if (section != 'متفرقات') {
        (questionsBySection[section] ??= []).add(question);
      }
    }
    return questionsBySection;
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: isLargeScreen
            ? null
            : AppBar(
                title: Text("مسائل إضافية",
                    style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface)),
                centerTitle: true,
              ),
        body: FutureBuilder<Map<String, List<OtherQuestion>>>(
          future: _groupedQuestionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('فشل تحميل البيانات: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("لا توجد أسئلة أخرى"));
            }

            final groupedQuestions = snapshot.data!;
            final sections = [
              _allQuestionsChipTitle,
              ...groupedQuestions.keys.toList()
            ];

            List<OtherQuestion> questionsToShow;
            if (_selectedSection == _allQuestionsChipTitle) {
              questionsToShow =
                  groupedQuestions.values.expand((q) => q).toList();
            } else {
              questionsToShow = groupedQuestions[_selectedSection] ?? [];
            }

            if (isLargeScreen) {
              return Row(
                children: [
                  SizedBox(
                    width: _drawerWidth,
                    child: Drawer(
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16.0,
                                  right: 8.0,
                                  left: 16.0,
                                  bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          "مسائل إضافية",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontFamily: "Zarids",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Text(
                                      "الأقسام",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontFamily: "Zarids",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sections.length,
                              itemBuilder: (context, index) {
                                final section = sections[index];
                                return ListTile(
                                  selected: _selectedSection == section,
                                  selectedTileColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  title: Text(
                                    section,
                                    style: TextStyle(
                                      fontFamily: "Zarids",
                                      fontSize: 20,
                                      fontWeight: _selectedSection == section
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _selectedSection == section
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedSection = section;
                                      _selectedQuestion = null;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        setState(() {
                          _drawerWidth -= details.delta.dx;
                          _drawerWidth = _drawerWidth.clamp(
                              200.0, MediaQuery.of(context).size.width * 0.5);
                        });
                      },
                      child: const SizedBox(
                        width: 10,
                        child: VerticalDivider(width: 1, thickness: 1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: questionsToShow.length,
                      itemBuilder: (context, index) {
                        return QuestionTile(
                          questionModelAr: questionsToShow[index],
                          onTapOther: (q) {
                            setState(() {
                              _selectedQuestion = q;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  if (_selectedQuestion != null)
                    MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanUpdate: (details) {
                          setState(() {
                            _detailsWidth += details.delta.dx;
                            _detailsWidth = _detailsWidth.clamp(
                                300.0, MediaQuery.of(context).size.width * 0.5);
                          });
                        },
                        child: const SizedBox(
                          width: 10,
                          child: VerticalDivider(width: 1, thickness: 1),
                        ),
                      ),
                    ),
                  if (_selectedQuestion != null)
                    SizedBox(
                      width: _detailsWidth,
                      child: OtherQuestionPage(
                        _selectedQuestion!,
                        key: ValueKey(_selectedQuestion!.question),
                        showAppBar: false,
                        onBack: () {
                          setState(() {
                            _selectedQuestion = null;
                          });
                        },
                      ),
                    ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: sections.map((section) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(section),
                            selected: _selectedSection == section,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedSection = section;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: questionsToShow.length,
                    itemBuilder: (context, index) {
                      return QuestionTile(
                        questionModelAr: questionsToShow[index],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
