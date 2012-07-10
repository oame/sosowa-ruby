# Sosowa

Sosowa Parser for Ruby 1.9.x

## Requirements

* Ruby 1.9.x
* mechanize gem

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
