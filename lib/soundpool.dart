import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

enum SoundEffect {
  ask,
  click,
  error,
  deploy,
  typing,
  warning,
  typingLong,
  information,
}

class SoundEffects {
  const SoundEffects(Map<SoundEffect, Sound> sounds) : _sounds = sounds;

  final Map<SoundEffect, Sound> _sounds;

  Sound? get ask => _sounds[SoundEffect.ask];
  Sound? get click => _sounds[SoundEffect.click];
  Sound? get error => _sounds[SoundEffect.error];
  Sound? get deploy => _sounds[SoundEffect.deploy];
  Sound? get typing => _sounds[SoundEffect.typing];
  Sound? get warning => _sounds[SoundEffect.warning];
  Sound? get typingLong => _sounds[SoundEffect.typingLong];
  Sound? get information => _sounds[SoundEffect.information];

  Sound? get(SoundEffect sound) => _sounds[sound];
}

class Sound {
  const Sound({required Soundpool pool, required this.id}) : _pool = pool;

  final Soundpool _pool;
  final Future<int> id;

  /// Plays the current loaded sound.
  ///
  /// `rate` has to be value in (0.5 - 2.0) range
  ///
  /// ```dart
  /// final SoundProvider sound = SoundProvider.of(context);
  /// await sound.typingLong.play(repeat: 100);
  Future<void> play({double rate = 1.0}) async {
    await _pool.play(await id, rate: rate);
  }
}

class SoundProvider extends StatefulWidget {
  const SoundProvider({
    required this.child,
    this.streamType = StreamType.notification,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// [streamType] parameter has effect on Android only.
  final StreamType streamType;

  static SoundEffects of(BuildContext context) {
    final provider = context.getElementForInheritedWidgetOfExactType<
                _SoundProviderInherited>() !=
            null
        ? context
            .getElementForInheritedWidgetOfExactType<_SoundProviderInherited>()!
            .widget as _SoundProviderInherited?
        : null;

    if (provider != null) {
      return provider.sounds;
    }

    return const SoundEffects({});
  }

  @override
  State<StatefulWidget> createState() => _SoundProviderState();
}

class _SoundProviderState extends State<SoundProvider> {
  Soundpool? _pool;
  SoundEffects? _sounds;

  @override
  void initState() {
    super.initState();

    _pool ??= Soundpool.fromOptions(
      options: SoundpoolOptions(streamType: widget.streamType),
    );
    _sounds ??= SoundEffects({
      SoundEffect.ask: Sound(pool: _pool!, id: _load('ask')),
      SoundEffect.click: Sound(pool: _pool!, id: _load('click')),
      SoundEffect.error: Sound(pool: _pool!, id: _load('error')),
      SoundEffect.deploy: Sound(pool: _pool!, id: _load('deploy')),
      SoundEffect.typing: Sound(pool: _pool!, id: _load('typing')),
      SoundEffect.warning: Sound(pool: _pool!, id: _load('warning')),
      SoundEffect.typingLong: Sound(pool: _pool!, id: _load('typing_long')),
      SoundEffect.information: Sound(pool: _pool!, id: _load('information')),
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pool?.dispose();
  }

  Future<int> _load(String sound) async {
    final soundId = await rootBundle
        .load('assets/sounds/$sound.mp3')
        .then((ByteData soundData) {
      return _pool!.load(soundData);
    });
    return soundId;
  }

  @override
  Widget build(BuildContext context) {
    return _SoundProviderInherited(
      pool: _pool!,
      sounds: _sounds!,
      child: widget.child,
    );
  }
}

class _SoundProviderInherited extends InheritedWidget {
  const _SoundProviderInherited({
    required this.pool,
    required this.sounds,
    required super.child,
  });

  final Soundpool pool;
  final SoundEffects sounds;

  @override
  bool updateShouldNotify(_SoundProviderInherited oldWidget) => false;
}
