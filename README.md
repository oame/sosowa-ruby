# Sosowa

[![Build Status](https://secure.travis-ci.org/oame/sosowa-ruby.png)](http://travis-ci.org/oame/sosowa-ruby)

創想話パーサー for Ruby<br>
samples/に各種サンプルが入っています。

## Requirement

* Ruby 1.9.x

## Installation

	gem install sosowa

## Usage

	require "sosowa"
	
	# 最新版から最初のSSを持ってくる
	novel = Sosowa.get.first
	puts novel.text
	
	# 作品集番号156の1320873807を持ってくる
	novel = Sosowa.get(:log => 156, :key => 1320873807)
	puts novel.text
	
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
