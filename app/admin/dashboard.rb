ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    columns do
      column do
        panel "System Info" do
          div Rails::Info.to_s.gsub(/\n/, '<br>').html_safe
          hr
          if Preference['admin_web_transactions_chart_code'].to_s != ''
            div Preference['admin_web_transactions_chart_code'].html_safe
            hr
          end
          ul do
            Setting.each do |key, value|
              if key =~ /key$/ || key =~ /secret/ || key =~ /pepper$/
                li "#{key}: #{value[0..5] + value.gsub(/./, '*')}"
              elsif key =~ /logo$/ || key =~ /icon$/
                value = value[0..50] + '...' if value.length > 50
                li "#{key}: #{value}"
              else
                li "#{key}: #{value}"
              end
            end
          end
        end
        if Preference['admin_apdex_score_chart_code'].to_s != ''
          panel "<a target=\"_blank\" href=\"#{Preference['admin_app_monitor_url']}\">System Apdex Score</a>".html_safe do
            div Preference['admin_apdex_score_chart_code'].html_safe
          end
        end
      end
      column do
        if Preference['admin_throughput_chart_code'].to_s != ''
          panel "<a target=\"_blank\" href=\"#{Preference['admin_app_monitor_url']}\">Throughput</a>".html_safe do
            div Preference['admin_throughput_chart_code'].html_safe
          end
        end
        panel '<a href="/admin/users?q%5Bcurrent_sign_in_at_gteq%5D=1994-07-02&order=current_sign_in_at_desc&as=detailed_table">Recent Signed-In Users</a>'.html_safe do
          table_for User.where('current_sign_in_at IS NOT NULL').order("current_sign_in_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(truncate(user.fbid, length: 8), "https://facebook.com/#{user.fbid}", :target => "_blank") }
            column("SID") { |user| user.student_id }
            column("Sign In Time") { |user| user.current_sign_in_at && distance_of_time_in_words_to_now(user.current_sign_in_at) }
            column("Sign In Count") { |user| "#{user.sign_in_count} (#{'%.3f' % (user.sign_in_count.to_f / ((Time.now - user.created_at) / 1.day)+0.5)}/day)" }
            column("IP") { |user| (user.current_sign_in_ip == user.last_sign_in_ip) ? status_tag(user.current_sign_in_ip, :class => 'yes') : status_tag(user.current_sign_in_ip) }
            column("Last Sign In Ip") { |user| user.last_sign_in_ip }
          end
        end
        panel '<a href="/admin/users?order=created_at_desc&as=detailed_table">Recent Registered Users</a>'.html_safe do
          table_for User.order("created_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(truncate(user.fbid, length: 20), "https://facebook.com/#{user.fbid}", :target => "_blank") }
            column("SID") { |user| user.student_id }
            column("Created At") { |user| user.created_at }
            column("Confirmed") do |user|
              if !!user.confirmed_at
                status_tag('Yes', :class => 'yes')
              else
                status_tag('No', :class => 'no')
              end
            end
            column("IP") { |user| user.current_sign_in_ip }
          end
        end
        if Preference['admin_error_rate_chart_code'].to_s != ''
          panel "<a target=\"_blank\" href=\"#{Preference['admin_app_monitor_url']}\">Error Rate</a>".html_safe do
            div Preference['admin_error_rate_chart_code'].html_safe
          end
        end
      end
    end
  end
end
