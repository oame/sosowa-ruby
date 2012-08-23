# -*- coding: utf-8 -*-

require "pp"
require "spec_helper"

describe Sosowa, "が #get, :log => 0 を呼ぶ時は" do
  before do
    @log = Sosowa.get :log => 0
  end
  
  it "Megalith::Subjectを返すこと" do
    @log.class.should == Megalith::Subject
  end

  it "最初がMegalith::Indexであること" do
    @log.first.class.should == Megalith::Index
  end

  it "最初のタイトルがStringであること" do
    @log.first.title.class.should == String
  end

  it "#next_pageがMegalith::Subjectを返すこと" do
    @log.next_page.class.should == Megalith::Subject
  end

  it "#prev_pageがMegalith::Subjectを返すこと" do
    @log.prev_page.class.should == Megalith::Subject
  end

  it "#latest_logがFixnumを返すこと" do
    @log.latest_log.class.should == Fixnum
  end

  it "最初を#fetchしたらMegalith::Novelを返すこと" do
    @log.first.fetch.class.should == Megalith::Novel
  end

  it "最初を#fetchしたMegalith::Novel#titleがStringなこと" do
    @log.first.fetch.title.class.should == String
  end
end