module ApplicationHelper

  def history_path(i)
    if session[:page_history]
      session[:page_history][i] || root_path
    else
      root_path
    end
  end

  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def markdown_format(s)
    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }
    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)
    markdown.render(s).html_safe
  end

  def app_logo
    if Preference.app_logo.to_s != ''
      if Preference.app_logo.to_s.match(/^</)  # if SVG path
        Preference.app_logo.to_s.html_safe
      else
        image_tag Preference.app_logo
      end
    else
      Setting.app_name
    end
  end

  def site_announcement
    Preference['site_announcement'] && markdown_format(Preference['site_announcement']).gsub(/\<\/?p\>/, '').html_safe
  end

  def apps_navigation
    SiteNavigation.nav
  end

  def apps_menu
    SiteNavigation.menu
  end

  def page_footer
    Preference['page_footer'] && Preference['page_footer'].html_safe
  end

  def default_authorize_path
    user_omniauth_authorize_path(:facebook)
  end

  def regexp_parse(s)
    s.gsub('$', '').gsub('.+', '').gsub('\.', '.')
  end

  def fb_image_tag(id, size=100)
    image_tag 'https://graph.facebook.com/' + id.to_s + '/picture?width=' + size.to_s + '&height=' + size.to_s
  end

  def options_for_select_to_item_menu(s)
    s.gsub(/option/, 'div').gsub(/value/, 'class="item" data-value').html_safe
  end
end
