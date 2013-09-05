module Helpers
  extend self

  # Take a screenshot when the example is failed
  def capture_output_for(page, example)
    Capturer.new(page, example).capture!
  end

  class Capturer
    attr_reader :example
    attr_reader :page

    def initialize(page, example)
      create_broken_pages_dir!
      @page = page
      @example = example
    end

    def capture!
      page.driver.render(full_file_name('png'), full: true)
      File.open(full_file_name('html'), 'w') { |f| f.write(page.body) }
    rescue
      nil
    end

    def capture_with_fail_check!
      return unless failed_example?
      capture_without_fail_check!
    end

    alias_method_chain :capture!, :fail_check

    private

    def create_broken_pages_dir!
      Dir.mkdir(broken_pages_directory) unless Dir.exists?(broken_pages_directory)
    end

    def failed_example?
      example.exception.present?
    end

    def broken_pages_directory
      File.join(Rails.root, 'reports', 'broken_pages')
    end

    def full_file_name(extension)
      file_name = example.full_description.downcase.gsub(/\s/, '-')
      File.join(broken_pages_directory, "#{file_name}.#{extension}")
    end
  end

end
