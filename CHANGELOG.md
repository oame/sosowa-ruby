## 0.4
* 細かいバグを修正

## 0.3
* Sosowa#Logを追加。作品集単位で抽象化出来るようになりました。殆どの場合、このクラスはArrayとして振る舞います。
* Sosowa#Log.logで絶対作品集番号を得ることが出来ます。このメソッドは最新作品集であっても0では無く実際の番号が割り振られます。
* Sosowa#Log.next_page, Sosowa#Log.prev_pageが追加されました。前後のページを取得してSosowa#Logを返します。
* 0.3のサンプルはtest/feature-0.3.rbで確認することが出来ます。

## 0.2
* Sosowa::Novel.titleを追加。むしろどうして今まで無かった
* Sosowa::Author, Sosowa::Commentが取得出来ないバグを修正

## 0.1
* Sosowa#searchを追加
* Sosowa::Novel#plainを使って<br>タグや改行コードが取り除かれたテキストを得ることが出来ます。

## 0.0.2
* 最初のリリースです！