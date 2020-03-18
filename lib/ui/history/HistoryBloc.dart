
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:yellow_box/entity/Idea.dart';
import 'package:yellow_box/entity/NavigationBarItem.dart';
import 'package:yellow_box/entity/Word.dart';
import 'package:yellow_box/ui/App.dart';
import 'package:yellow_box/ui/BaseBloc.dart';
import 'package:yellow_box/ui/history/HistoryState.dart';

class HistoryBloc extends BaseBloc {

  final _state = BehaviorSubject<HistoryState>.seeded(HistoryState());
  HistoryState getInitialState() => _state.value;
  Stream<HistoryState> observeState() => _state.distinct();

  final _themeRepository = dependencies.themeRepository;
  final _childScreenRepository = dependencies.childScreenRepository;
  final _wordRepository = dependencies.wordRepository;
  final _ideaRepository = dependencies.ideaRepository;

  CompositeSubscription _subscriptions = CompositeSubscription();

  HistoryBloc() {
    _subscriptions.add(_themeRepository.observeCurrentAppTheme()
      .listen((appTheme) {
      _state.value = _state.value.buildNew(
        appTheme: appTheme,
      );
    }));

    _subscriptions.add(_wordRepository.observeWords()
      .listen((words) {
      _state.value = _state.value.buildNew(
        words: words,
      );
    }));

    _subscriptions.add(_ideaRepository.observeIdeas()
      .listen((ideas) {
      _state.value = _state.value.buildNew(
        ideas: ideas,
      );
    }));
  }

  @override
  void dispose() {
    _subscriptions.dispose();
  }

  void onNavigationBarItemClicked(NavigationBarItem item) {
    _childScreenRepository.setCurrentChildScreenKey(item.key);
  }

  void onWordTabClicked() {
    _state.value = _state.value.buildNew(
      isWordTab: true,
    );
  }

  void onIdeaTabClicked() {
    _state.value = _state.value.buildNew(
      isWordTab: false,
    );
  }

  void onWordItemClicked(Word item) {
    _state.value = _state.value.buildNew(
      wordItemDialog: WordItemDialog(WordItemDialog.TYPE_LIST, item),
    );
  }

  void onWordItemDialogCloseClicked() {
    _state.value = _state.value.buildNew(
      wordItemDialog: WordItemDialog.NONE,
    );
  }

  void onWordItemDialogDeleteClicked(Word item) {
    _state.value = _state.value.buildNew(
      wordItemDialog: WordItemDialog(WordItemDialog.TYPE_CONFIRM_DELETE, item),
    );
  }

  void onConfirmDeleteWordClicked(Word item) {
    _wordRepository.deleteWord(item);

    _state.value = _state.value.buildNew(
      wordItemDialog: WordItemDialog.NONE,
    );
  }

  void onIdeaItemClicked(Idea item) {
    _state.value = _state.value.buildNew(
      ideaItemDialog: IdeaItemDialog(IdeaItemDialog.TYPE_LIST, item),
    );
  }

  void onIdeaItemDialogDeleteClicked(Idea item) {
    _state.value = _state.value.buildNew(
      ideaItemDialog: IdeaItemDialog(IdeaItemDialog.TYPE_CONFIRM_DELETE, item),
    );
  }

  void onIdeaItemDialogBlockClicked(Idea item) {
    _state.value = _state.value.buildNew(
      ideaItemDialog: IdeaItemDialog(IdeaItemDialog.TYPE_CONFIRM_BLOCK, item),
    );
  }

  void onIdeaItemDialogCloseClicked() {
    _state.value = _state.value.buildNew(
      ideaItemDialog: IdeaItemDialog.NONE,
    );
  }

  void onConfirmDeleteIdeaClicked(Idea item) {
    _ideaRepository.deleteIdea(item);

    _state.value = _state.value.buildNew(
      ideaItemDialog: IdeaItemDialog.NONE,
    );
  }

  void onConfirmBlockIdeaClicked(Idea item) {
    // todo
//    _ideaRepository.blockIdea(item);

    _state.value = _state.value.buildNew(
      ideaItemDialog: IdeaItemDialog.NONE,
    );
  }

  void onIdeaItemFavoriteClicked(Idea item) {
    if (item.isFavorite) {
      _ideaRepository.unfavoriteItem(item);
    } else {
      _ideaRepository.favoriteItem(item);
    }
  }

  bool handleBackPress() {
    if (_state.value.wordItemDialog.isValid()) {
      onWordItemDialogCloseClicked();
      return true;
    }

    if (_state.value.ideaItemDialog.isValid()) {
      onIdeaItemDialogCloseClicked();
      return true;
    }

    return false;
  }
}