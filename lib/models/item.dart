class Item {
  String imageUrl;
  String title;
  String detailUrl;

  Item(this.imageUrl, this.title, this.detailUrl);

  @override
  String toString() {
    return 'Item{imageUrl: $imageUrl, title: $title, detailUrl: $detailUrl}';
  }
}
