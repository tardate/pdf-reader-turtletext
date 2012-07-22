require 'pathname'
require 'yaml'

module PdfSamplesHelper

  def pdf_samples_path
    Pathname.new(File.dirname(__FILE__)).join('..','fixtures','pdf_samples')
  end

  def junk_prefix_pdf_sample_name
    pdf_samples_path.join('junk_prefix.pdf').to_s
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
end