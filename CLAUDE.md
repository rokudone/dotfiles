# dotfiles

## キー割り当て

キーは上流から Karabiner-Elements、Ghostty、herdr の順に流れる。割り当てを変えるときは、上流から順に、変換されるか（Karabiner）、Ghostty が自前で消費せず herdr へ流すか（Ghostty）、どの操作に割り当てるか（herdr）を確かめる。

1. Karabiner: 手で書くのは config/karabiner/assets/complex_modifications/ の素材ファイル（util.json と windows.json）で、karabiner.json は Karabiner が書き出す生成物である。karabiner.json は直接書き換えない。rule の description には `[util]` や `[windows]` の接頭辞が付くが、util.json にも `[windows]` の rule があるので、足す前に同種の rule がどちらのファイルにあるかを grep で確かめる
2. Ghostty: config/ghostty/config.ghostty。herdr へ流すキーは `keybind = <key>=text:\x1b[<code>;<mod>u` の CSI u 形式で送る。mod は 1 に shift=1、alt=2、ctrl=4、super=8 を足した値（ctrl=5、ctrl+shift=6、ctrl+super=13、ctrl+super+shift=14）
3. herdr: config/herdr/config.toml（~/.config/herdr/config.toml からのシンボリックリンク）。prefix は ctrl+q。キー名は `herdr --default-config` の記述に従う
4. 割り当てを入れ替えたら、config.toml と config.ghostty の両方のコメントを新しい役割に合わせて直す

## 反映

どれも再起動は要らない。herdr の再起動は案内しない（セッションが切れる）。

1. herdr: `herdr server reload-config`。sandbox からはソケットに届かないので、`!` 付きの一行で渡す
2. Ghostty: cmd+shift+, で再読み込み
3. Karabiner: ファイルの変更を自動で読み込む。素材ファイルに足した rule は、Karabiner の UI（Complex Modifications の Add rule）で有効化が要る

## 設定ファイルの編集

1. 編集の前に `git diff --stat` で既存の未コミット差分を控え、報告では自分の変更と元からあった差分を分けて書く
2. JSON や TOML は、シリアライザーで丸ごと書き戻さず、対象の範囲だけを置き換える。丸ごと書き戻すしかないなら、読んで書くだけの往復が元と一致することを確かめてから行い、一致しなければ止める
