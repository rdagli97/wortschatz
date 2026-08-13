import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word.dart';
import 'word_provider.dart';

// Bir test sorusuna verilen cevap
class TestAnswer {
  final Word word;
  final String selectedArticle;
  final String typedWord;

  const TestAnswer({
    required this.word,
    required this.selectedArticle,
    required this.typedWord,
  });

  bool get isCorrect =>
      selectedArticle == word.article &&
      typedWord.trim().toLowerCase() == word.word.trim().toLowerCase();
}

// Test modu oturumunun durumu
class TestModeState {
  final List<Word> words;
  final int currentIndex;
  final List<TestAnswer> answers;
  final bool isFinished;

  const TestModeState({
    this.words = const [],
    this.currentIndex = 0,
    this.answers = const [],
    this.isFinished = false,
  });

  Word? get currentWord => words.isEmpty ? null : words[currentIndex];
  bool get isLastWord => currentIndex >= words.length - 1;

  TestModeState copyWith({
    List<Word>? words,
    int? currentIndex,
    List<TestAnswer>? answers,
    bool? isFinished,
  }) {
    return TestModeState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class TestModeController extends Notifier<TestModeState> {
  @override
  TestModeState build() => const TestModeState();

  // Oturumu başlat: kelimeleri karıştırıp istenen sayıda seç
  void start(List<Word> words, int count) {
    final shuffled = [...words]..shuffle();
    state = TestModeState(words: shuffled.take(count).toList());
  }

  // Cevabı kaydet, kelimenin tekrar istatistiğini güncelle ve sıradaki soruya geç
  Future<void> submitAnswer({
    required String article,
    required String typedWord,
  }) async {
    final word = state.currentWord;
    if (word == null) return;

    final answer = TestAnswer(
      word: word,
      selectedArticle: article,
      typedWord: typedWord,
    );

    if (word.id != null) {
      await ref
          .read(databaseServiceProvider)
          .recordAnswer(word.id!, answer.isCorrect);
    }

    final updatedAnswers = [...state.answers, answer];

    if (state.isLastWord) {
      ref.invalidate(wordsProvider);
      state = state.copyWith(answers: updatedAnswers, isFinished: true);
    } else {
      state = state.copyWith(
        answers: updatedAnswers,
        currentIndex: state.currentIndex + 1,
      );
    }
  }
}

final testModeControllerProvider =
    NotifierProvider<TestModeController, TestModeState>(
        TestModeController.new);
