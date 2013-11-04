MetricFu.metrics_require   { 'saikuro/scratch_file'    }
MetricFu.metrics_require   { 'saikuro/parsing_element' }
MetricFu.data_structures_require { 'line_numbers' }
module MetricFu

  class SaikuroGenerator < MetricFu::Generator

    def self.metric
      :saikuro
    end

    def emit
      options_string = options.inject("") do |options, option|
        option[0] == :input_directory ? options : options + "--#{option.join(' ')} "
      end

      options[:input_directory].each do |input_dir|
        options_string += "--input_directory #{input_dir} "
      end

      command = %Q(mf-saikuro #{options_string})
      mf_debug "** #{command}"
      `#{command}`
    end

    def analyze
      @files = sort_files(assemble_files)
      @classes = sort_classes(assemble_classes(@files))
      @meths = sort_methods(assemble_methods(@files))
    end

    def to_h
      files = @files.map do |file|
        my_file = file.to_h

        f = file.filepath
        f.gsub!(%r{^#{metric_directory}/}, '')
        f << "/#{file.filename}"

        my_file[:filename] = f
        my_file
      end
      @saikuro_data = {:files => files,
                       :classes => @classes.map {|c| c.to_h},
                       :methods => @meths.map {|m| m.to_h}
                      }
      {:saikuro => @saikuro_data}
    end

    def per_file_info(out)
      @saikuro_data[:files].each do |file_data|
        filename = file_data[:filename]
        next if erb_file?(filename) || file_not_exists?(filename)
        next unless line_numbers = line_numbers_from_file(filename)

        build_output_from_line_numbers(out, line_numbers, file_data)
      end
    end

    def build_output_from_line_numbers(out, line_numbers, file_data)
      filename = file_data[:filename]
      out[filename] ||= Hash.new {|hash, key| hash[key] = [] }
      method_data_for_file_data(file_data) do |method_data|
         line = line_numbers.start_line_for_method(method_data[:name]).to_s
         result = {
           :type => :saikuro,
           :description => "Complexity #{method_data[:complexity]}"
         }
         out[filename][line] <<  result
      end
    end

    def line_numbers_from_file(filename)
      MetricFu::LineNumbers.new(File.read(filename))
    rescue StandardError => e
      raise e unless e.message =~ /you shouldn't be able to get here/
      mf_log "ruby_parser blew up while trying to parse #{file_path}. You won't have method level Saikuro information for this file."
    end

    def method_data_for_file_data(file_data, &block)
      return unless block_given?
      file_data[:classes].each do |class_data|
        class_data[:methods].each do |method_data|
          yield method_data
        end
      end
    end

    private

    def erb_file?(filename)
      File.extname(filename) == '.erb'
    end

    def file_not_exists?(filename)
      !File.exists?(filename)
    end

    def sort_methods(methods)
      methods.sort_by {|method| method.complexity.to_i}.reverse
    end

    def assemble_methods(files)
      methods = []
      files.each do |file|
        file.elements.each do |element|
          element.defs.each do |defn|
            defn.name = "#{element.name}##{defn.name}"
            methods << defn
          end
        end
      end
      methods
    end

    def sort_classes(classes)
      classes.sort_by {|k| k.complexity.to_i}.reverse
    end

    def assemble_classes(files)
      files.map {|f| f.elements}.flatten
    end

    def sort_files(files)
      files.sort_by do |file|
        file.elements.
             max {|a,b| a.complexity.to_i <=> b.complexity.to_i}.
             complexity.to_i
      end.reverse
    end

    def assemble_files
      SaikuroScratchFile.assemble_files( Dir.glob("#{metric_directory}/**/*.html") )
    end

  end

end
