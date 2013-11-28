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
  def page_title()
    subtitle = content_for(:title)
    title = 'Labtool'
    subtitle.empty? ? title : subtitle+" - "+title
  end

  def set_page_title(title)
    content_for(:title){ title }
  end
end


