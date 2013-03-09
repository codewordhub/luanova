require 'redcarpet'
require 'rouge/plugins/redcarpet'

class Syntactical < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
  include Redcarpet::Render::SmartyPants
end

class SyntacticalTemplate < Tilt::RedcarpetTemplate::Redcarpet2
  def generate_renderer
    Syntactical.new(hard_wrap: false)
  end

  def prepare
    # override the options to include code fencing, etc.
    opts = {
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      autolink: true,
      strikethrough: true,
      lax_html_blocks: true,
      space_after_headers: false,
      superscript: true
    }
    @engine = Redcarpet::Markdown.new(generate_renderer, opts)
    @output = nil
  end
end

Tilt::register SyntacticalTemplate, 'mdown'
Tilt.prefer SyntacticalTemplate
