module ApplicationHelper
  def label status
    return "cancel participation" if status
    "participate"
  end

  def rendered content
    return "" if content.nil?
    require 'redcarpet'
    renderer = Redcarpet::Render::HTML.new
    extensions = {fenced_code_blocks: true}
    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    raw(redcarpet.render content)
  end
end


