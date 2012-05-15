require 'spec_helper'

describe PulseMeter::Visualizer do
  describe "::draw" do
    it "should generate correct layout with passed block" do
      layout = described_class.draw do |l|

        l.title "My Gauges"

        l.page "Dashboard" do |p|
          p.spline :convertion do |c|
            c.sensor :adv_clicks, color: :green
            c.sensor :adv_shows, color: :red
          end

          p.pie :agents, title: 'User Agents' do |c|
            c.sensor :agent_ie
            c.sensor :agent_chrome
            c.sensor :agent_ff
            c.sensor :agent_other
          end

        end

        l.page "Request stats" do |p|
          p.spline :rph_total, sensor: :rph_total
          p.line :rph_main_page, sensor: :rph_main_page
          p.line :request_time_p95_hour
        
          p.pie :success_vs_fail_total_hourly do |w|
            w.sensor :success_total_hourly
            w.sensor :fail_total_hourly
          end

        end

      end
      layout.should be_kind_of(PulseMeter::Visualize::Layout)
    end
  end
end

