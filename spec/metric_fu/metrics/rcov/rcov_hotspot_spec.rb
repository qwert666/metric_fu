require "spec_helper"
MetricFu.metrics_require { 'hotspots/init' }
MetricFu.metrics_require { 'hotspots/hotspot' }
MetricFu.metrics_require { 'hotspots/analysis/record' }
MetricFu.metrics_require { 'rcov/rcov_hotspot' }

describe MetricFu::RcovHotspot do
  describe "map" do
    let(:zero_row) do
      MetricFu::Record.new({"percentage_uncovered"=>0.0}, nil)
    end

    let(:non_zero_row) do
      MetricFu::Record.new({"percentage_uncovered"=>0.75}, nil)
    end

    it {subject.map(zero_row).should eql(0.0)}
    it {subject.map(non_zero_row).should eql(0.75)}
  end
end
