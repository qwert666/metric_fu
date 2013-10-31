require 'spec_helper'
MetricFu.lib_require { 'gem_version' }

describe MetricFu::GemVersion do

  it 'has a list of gem deps' do
    gem_version = MetricFu::GemVersion.new
    gem_deps = gem_version.gem_runtime_dependencies.map(&:name)
    MetricFu::Metric.metrics.reject{|metric| metric.name == :hotspots || metric.name == :stats}.map(&:name).map(&:to_s).each do |metric_name|
      expect(gem_deps).to include(metric_name)
    end
  end

  it 'behaves like metric_fu_requires' do
    expect(MetricFu::GemVersion.for('saikuro')).to eq(MetricFu::MetricVersion.saikuro)
  end

end
