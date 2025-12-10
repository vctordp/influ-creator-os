
enum BlockType { hero, stats, logos, about, pricing, gallery, contact, unknown }

class MediaKitBlock {
  final BlockType type;
  final Map<String, dynamic> data;

  const MediaKitBlock({required this.type, required this.data});

  factory MediaKitBlock.fromJson(Map<String, dynamic> json) {
    return MediaKitBlock(
      type: _parseType(json['type']),
      data: json['data'] ?? {},
    );
  }

  static BlockType _parseType(String? typeStr) {
    switch (typeStr?.toUpperCase()) {
      case 'HERO_HEADER': return BlockType.hero;
      case 'STATS_GRID': return BlockType.stats;
      case 'BRAND_LOGOS': return BlockType.logos;
      case 'ABOUT_SECTION': return BlockType.about;
      case 'PRICING_TABLE': return BlockType.pricing;
      case 'GALLERY_GRID': return BlockType.gallery;
      case 'CONTACT_SECTION': return BlockType.contact;
      default: return BlockType.unknown;
    }
  }
}
