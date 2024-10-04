// generate a class model for this template
/*
{
"$rowIndex": "1",
"MainTitle": "مسائل",
"SubTitle": "وجوب الحج",
"Question": "ا: ما هو الدليل على وجوب الحج؟",
"Id": "15DDm-aGo74-tzcFHRhf-gYkI-Gq4wdy4",
"Link": "https://docs.google.com/uc?export=download&id=15DDm-aGo74-tzcFHRhf-gYkI-Gq4wdy4",
"no": "1",
"AnswerText": "الجواب: القرآن الكريم والسنة القطعية.\nوالحجّ ركن من أركان الدين، ووجوبه من الضروريات، وتركه ــ مع الاعتراف بثبوته ــ معصية كبيرة، كما أن إنكار أصل الفريضة ــ إذا لم يكن مستنداً إلى شبهة ــ كفر.\nقال الله تعالى في كتابه المجيد: [وَلِلَّهِ عَلَى النَّاسِ حجّ الْبَيْتِ مَنِ اسْتَطاعَ إِلَيْهِ سَبِيلاً ومَنْ كَفَرَ فَإِنَّ اللَّهَ غَنِيٌّ عَنِ الْعالَمِينَ].\nوروى الشيخ الكليني ــ بطريق معتبر ــ عن أبي عبد الله عليه السلام قال: (من مات ولم يحجّ حجّة الإسلام، لم يمنعه من ذلك حاجة تجحف به، أو مرض لا يطيق فيه الحجّ، أو سلطان يمنعه، فليمت يهودياً أو نصرانياً)."
},
 */

class Question {
  final String? rowIndex;
  final String? instructor;
  final String? mainTitle;
  final String? subTitle;
  final String? question;
  final String? id;
  final String? link;
  final String? no;
  final String? answerText;

  Question({
    required this.rowIndex,
    required this.instructor,
    required this.mainTitle,
    required this.subTitle,
    required this.question,
    required this.id,
    required this.link,
    required this.no,
    required this.answerText,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      rowIndex: json['\$rowIndex'],
      instructor: json['Instructor'],
      mainTitle: json['MainTitle'],
      subTitle: json['SubTitle'],
      question: json['Question'],
      id: json['Id'],
      link: json['Link'],
      no: json['no'],
      answerText: json['AnswerText'],
    );
  }
}

class OtherQuestion {
  final String? timestamp;
  final String? question;
  final String? answerText;
  final String? section;

  OtherQuestion({
    required this.timestamp,
    required this.question,
    required this.answerText,
    required this.section,
  });

  factory OtherQuestion.fromJson(Map<String, dynamic> json) {
    return OtherQuestion(
      timestamp: json['Timestamp'],
      question: json['Question'],
      answerText: json['Answer'],
      section: json['Section'],
    );
  }
}
