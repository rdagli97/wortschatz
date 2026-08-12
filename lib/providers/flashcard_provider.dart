import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word.dart';
import 'word_provider.dart';

// Flash card oturumunun durumu
class FlashcardState {
  final List<Word> shuffledWords;
  final int currentIndex;
  final bool isRevealed;
  final bool isFinished;

  const FlashcardState({
    this.shuffledWords = const [],
    this.currentIndex = 0,
    this.isRevealed = false,
    this.isFinished = false,
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
    bool? isFinished,
  }) {
    return FlashcardState(
      shuffledWords: shuffledWords ?? this.shuffledWords,
      currentIndex: currentIndex ?? this.currentIndex,
      isRevealed: isRevealed ?? this.isRevealed,
      isFinished: isFinished ?? this.isFinished,
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

  // Tinder tarzı değerlendirme: doğru/yanlış işaretle, sonucu kaydet ve ilerle
  Future<void> answer(bool correct) async {
    final word = state.currentWord;
    if (word?.id == null) return;

    await ref.read(databaseServiceProvider).recordAnswer(word!.id!, correct);
    ref.invalidate(wordsProvider);

    if (state.isLastCard) {
      state = state.copyWith(isFinished: true);
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isRevealed: false,
      );
    }
  }
}

final flashcardControllerProvider =
    NotifierProvider<FlashcardController, FlashcardState>(
        FlashcardController.new);