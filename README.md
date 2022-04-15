# コンピュータ論理設計 / Computer Logic Design

Tokyo Institute of Technology 2022-1Q

## acri 接続方法 & 環境構築

### 環境構築
1. `code ~/.ssh/config`でリモート接続時のコマンドを省略する
2. 
```
Host acri
  HostName gw.acri.c.titech.ac.jp
  User <user-name>
  PreferredAuthentications publickey
  UseKeychain yes
  AddKeysToAgent yes
```

のような内容を追加する。

3. vscodeで Remote - SSH という拡張機能をインストール
4. Connect to Host から acri へ接続する


### 接続方法

5. `4.` の方法でアクセスできた先では `iverilog <filename>.v`のような処理は行えないので、自分が予約したサーバへアクセスする。
  `ssh vs<server-number>` でアクセスする。

6. vscode側で、Open Folder から cld を選択し開く
7. GUIでファイルを見ることができる

8. ローカルからリモートへデータをアップロードする場合は、ドラック&ドロップで可能
9. リモートからローカルへデータをダウンロードする場合は、ファイルを選択して右クリックでダウンロードが可能(ファイル指定でするのは面倒なので、ダウンロードしたいファイルをまとめてフォルダにするのが良い )

### 参考資料

- [Qiita: SSH公開鍵認証で接続するまで](https://qiita.com/kazokmr/items/754169cfa996b24fcbf5)
- [ACRi](https://gw.acri.c.titech.ac.jp/wp/manual/how-to-reserve)
- [Acri MacOS](https://www.acri.c.titech.ac.jp/wordpress/archives/1730)

## ローカル環境で iverilog を使えるようにする

