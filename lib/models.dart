class Instructor {
  late String name;
  String? phone;
  String? whatsappNumber;
  List<Question> questions = [];

  Instructor(this.name, {this.phone, this.whatsappNumber});
}

class Question {
  late String mainTitle;
  late String subTitle;
  late String question;
  late String answer;

  Question(this.question, this.answer);
}
