module Admin::AdminHelper
  # Returns <li class="active"><a href="/">Example</a></li>
  def li_link(title, path)
    li_class = request.fullpath == path ? 'active' : ''
    content_tag :li, class: li_class do
      link_to title, path
    end
  end
end
