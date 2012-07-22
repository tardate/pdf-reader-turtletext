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
  end

  def make_sample_hello_world
    filename = pdf_sample('hello_world.pdf')
    Prawn::Document.generate filename do
      text "Hello World"
    end
    puts "Created: #{filename}"
  end
end