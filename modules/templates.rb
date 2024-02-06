require 'erb'

class Templates
  def self.process(templates_dir, results_dir, variables)
    Dir.mkdir(results_dir) unless File.exists?(results_dir)

    templates = Dir.glob(templates_dir + "/*.erb")

    templates.each do |template|
      template_erb = ERB.new(File.read(template), trim_mode: "-")

      template_result = template_erb.result_with_hash(variables)

      File.write(results_dir + "/" + File.basename(template, ".*"), template_result)
    end
  end
end