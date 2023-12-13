class StudentModel {
  int? id;
  String? name;
  String? email;
  String? classe;

  StudentModel({this.id, this.name, this.email, this.classe});

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        classe: json["classe"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "email": email, "classe": classe};
  }
}
