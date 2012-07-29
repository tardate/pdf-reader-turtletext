require 'pathname'
require 'yaml'

module PdfSamplesHelper

  def pdf_samples_path
    Pathname.new(File.dirname(__FILE__)).join('..','fixtures','pdf_samples')
  end

  def pdf_sample(sample_name)
    pdf_samples_path.join(sample_name)
  end

  def pdf_sample_names
    Dir[pdf_samples_path.join("*.pdf")]
  end

  def pdf_sample_expectations_path
    pdf_samples_path.join('expectations.yml')
  end

  def pdf_sample_expectations
    begin
      YAML.load_file pdf_sample_expectations_path
    rescue
      []
    end
  end

  def make_pdf_samples
    require 'prawn'
    puts "Making PDF samples for tests.."
    make_sample_hello_world
    make_sample_simple_table_text
  end

  def make_sample_hello_world
    filename = pdf_sample('hello_world.pdf')
    Prawn::Document.generate filename do
      text "Hello World"
    end
    puts "Created: #{filename}"
  end

  def make_sample_simple_table_text
    filename = pdf_sample('simple_table_text.pdf')
    Prawn::Document.generate filename do
      text "Simple Table Text"
      text_box "Table Header", :at => [10, 300], :width => 200

      text_box "row 1", :at => [10, 250], :width => 90
      text_box "val 1", :at => [100, 250], :width => 50
      text_box "val 2", :at => [150, 250], :width => 50
      text_box "val 3", :at => [200, 250], :width => 50

      text_box "row 2", :at => [10, 200], :width => 90
      text_box "val 1", :at => [100, 200], :width => 50
      text_box "val 2", :at => [150, 200], :width => 50
      text_box "val 3", :at => [200, 200], :width => 50

      text_box "Table Footer", :at => [10, 150], :width => 200
    end
    puts "Created: #{filename}"
  end

end