# -*- coding: utf-8 -*-

require "pp"
require "spec_helper"

describe Sosowa, "が #get, :log => 0 を呼ぶ時は" do
  before do
    @log = Sosowa.get :log => 0
  end
  
  it "Megalopolis::Subjectを返すこと" do
    @log.class.should == Megalopolis::Subject
  end

  it "最初がMegalopolis::Indexであること" do
    @log.first.class.should == Megalopolis::Index
  end

  it "最初のタイトルがStringであること" do
    @log.first.title.class.should == String
  end

  it "#next_pageがMegalopolis::Subjectを返すこと" do
    @log.next_page.class.should == Megalopolis::Subject
  end

  it "#next_pageの#prev_pageがMegalopolis::Subjectを返すこと" do
    @log.next_page.prev_page.class.should == Megalopolis::Subject
  end

  it "#latest_logがFixnumを返すこと" do
    @log.latest_log.class.should == Fixnum
  end

  it "最初を#fetchしたらMegalopolis::Novelを返すこと" do
    @log.first.fetch.class.should == Megalopolis::Novel
  end

  it "最初を#fetchしたMegalopolis::Novel#entry#titleがStringなこと" do
    @log.first.fetch.entry.title.class.should == String
  end
end