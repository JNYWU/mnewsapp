class Category {
  String id;
  String name;
  String slug;

  Category({
    this.id,
    this.name,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
      };

  bool isLatestCategory() {
    return id == 'latest';
  }

  static bool checkIsLatestCategoryBySlug(String slug) {
    return slug == 'latest';
  }

  @override
  int get hashCode => this.hashCode;

  @override
  bool operator ==(covariant Category other) {
    // compare this to other
    return this.id == other.id;
  }
}
