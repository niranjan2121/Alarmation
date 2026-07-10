class WakeUpSong {
  final String id;
  final String title;
  final String author;
  final String fileUrl; 
  final bool isPremium;
  final String category; 
  final bool isAsset; // NEW: Tells the player if this is a bundled app file

  WakeUpSong({
    required this.id,
    required this.title,
    required this.author,
    required this.fileUrl,
    required this.isPremium,
    this.category = 'Basic',
    this.isAsset = false,
  });
}