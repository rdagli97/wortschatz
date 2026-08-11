import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word.dart';

// Flash card oturumunun durumu
class FlashcardState {
  final List<Word> shuffledWords;
  final int currentIndex;
  final bool isRevealed;

  const FlashcardState({
    this.shuffledWords = const [],
    this.currentIndex = 0,
    this.isRevealed = false,
  });

  // Şu anki kelime (liste boşsa null)
  Word? get currentWord =>
      shuffledWords.isEmpty ? null : shuffledWords[currentIndex];

  // Son kelimede miyiz?
  bool get isLastCard => currentIndex >= shuffledWords.length - 1;

  FlashcardState copyWith({
    List<Word>? shuffledWords,
    int? currentIndex,
    bool? isRevealed,
  }) {
    return FlashcardState(
      shuffledWords: shuffledWords ?? this.shuffledWords,
      currentIndex: currentIndex ?? this.currentIndex,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }
}

class FlashcardController extends Notifier<FlashcardState> {
  @override
  FlashcardState build() => const FlashcardState();

  // Oturumu başlat: kelimeleri karıştır
  void start(List<Word> words) {
    final shuffled = [...words]..shuffle();
    state = FlashcardState(
      shuffledWords: shuffled,
      currentIndex: 0,
      isRevealed: false,
    );
  }

  // Kartı çevir (artikeli göster)
  void reveal() {
    state = state.copyWith(isRevealed: true);
  }

  // Sonraki karta geç
  void next() {
    if (state.isLastCard) return;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      isRevealed: false,
    );
  }
}

final flashcardControllerProvider =
    NotifierProvider<FlashcardController, FlashcardState>(
        FlashcardController.new);