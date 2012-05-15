require "spec_helper"

describe PulseMeter::Visualize::Layout do
  let(:layout) do
    l = PulseMeter::Visualize::DSL::Layout.new
    l.page "page1" do |p|
      p.line "w1"
      p.spline "w2"
    end
    l.page "page2" do |p|
      p.line "w3"
      p.spline "w4"
    end
    l.to_layout
  end

  describe "#page_titles" do
    it "should return list of page titles with ids" do
      layout.page_titles.should == [
        {title: "page1", id: 1},
        {title: "page2", id: 2}
      ]
    end
  end

  describe "#options" do
    it "should return layout options" do
      ldsl = PulseMeter::Visualize::DSL::Layout.new
      ldsl.use_utc true
      l = ldsl.to_layout
      l.options.should == {use_utc: true}
    end
  end

  describe "#widget" do
    it "should return data for correct widget" do
      w = layout.widget(1, 0)
      w.should include(id: 1, title: "w3")
      w = layout.widget(0, 1)
      w.should include(id: 2, title: "w2")
    end
  end

  describe "#widgets" do
    it "should return data for correct widgets of a page" do
      datas = layout.widgets(1)
      datas[0].should include(id: 1, title: "w3")
      datas[1].should include(id: 2, title: "w4")
    end
  end

end