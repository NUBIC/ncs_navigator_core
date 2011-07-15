module ApplicationHelper
  
  def title(page_title, show_title = true)
    @show_title = show_title
    content_for(:title) { page_title.to_s }
  end

  def show_title?
    @show_title
  end

  def app_version_helper
    "Release Version #{ApplicationController::APP_VERSION}"
  end
  
end
