class Board {
  final String name;

  Board(this.name);

  factory Board.fromJson(Map<String, dynamic> json) {
    print(json["title"]);
//    return Board(json["title"]);
  }
}

class BoardListItem {
  BoardListItem(this.name, this.value, this.checked);

  final String name;
  final String value;
  bool checked;
}

class Thread {
  final int no;
  final String now;
  final String com;
  final int replies;
  final String filename;
  final String extension;
  final int resto;

  Thread(this.no, this.now, this.com, this.replies, this.filename,
      this.extension, this.resto);
}
