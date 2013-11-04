module MetricFu

  class FlayGenerator < Generator

    def self.metric
      :flay
    end

    def emit
      minimum_score_parameter = options[:minimum_score] ? "--mass #{options[:minimum_score]} " : ""

      command = %Q(flay #{minimum_score_parameter} #{options[:dirs_to_flay].join(" ")})
      mf_debug "** #{command}"
      @output = `#{command}`
    end

    def analyze
      @matches = @output.chomp.split("\n\n").map{|m| m.split("\n  ") }
    end

    def to_h
      target = []
      total_score = @matches.shift.first.split('=').last.strip
      @matches.each do |problem|
        reason = problem.shift.strip
        lines_info = problem.map do |full_line|
          name, line = full_line.split(":")
          {:name => name.strip, :line => line.strip}
        end
        target << [:reason => reason, :matches => lines_info]
      end
      {:flay => {:total_score => total_score, :matches => target.flatten}}
    end
  end
end
