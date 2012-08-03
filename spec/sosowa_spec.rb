# -*- coding: utf-8 -*-

require "pp"
require "spec_helper"

describe Sosowa, "が #get, :log => 0 を呼ぶ時は" do
  before do
    @log = Sosowa.get :log => 0
  end
  
  it "Sosowa::Logを返すこと" do
    @log.class.should == Sosowa::Log
  end

  it "最初がSosowa::Indexであること" do
    @log.first.class.should == Sosowa::Index
  end

  it "最初のタイトルがStringであること" do
    @log.first.title.class.should == String
  end

  it "#next_pageがSosowa::Logを返すこと" do
    @log.next_page.class.should == Sosowa::Log
  end

  it "#prev_pageがSosowa::Logを返すこと" do
    @log.prev_page.class.should == Sosowa::Log
  end

  it "#latest_logがFixnumを返すこと" do
    @log.latest_log.class.should == Fixnum
  end

  it "最初を#fetchしたらSosowa::Novelを返すこと" do
    @log.first.fetch.class.should == Sosowa::Novel
  end

  it "最初を#fetchしたSosowa::Novel#titleがStringなこと" do
    @log.first.fetch.title.class.should == String
  end
end