ActiveAdmin.register_page "Preference" do
  menu priority: 100, label: "系統設定"

  content do

    form :action => admin_preference_update_path, :method => :post do |f|
      f.input :name => 'authenticity_token', :type => :hidden, :value => form_authenticity_token.to_s

      panel "Preference" do
        fieldset do
          ol do

            li do
              label '維修模式'
              f.input :id => "cb-maintenance_mode", :type => 'checkbox', :onchange => "if (this.checked) { document.getElementById('ip-maintenance_mode').value = 'true'; } else { document.getElementById('ip-maintenance_mode').value = 'false'; }", "#{Preference.maintenance_mode ? 'checked' : 'not_checked'}" => ('checked' if Preference.maintenance_mode)
              f.input :name => "data[maintenance_mode]", :id => "ip-maintenance_mode", :type => 'hidden'
            end

            li do
              label '全站公告 (支援 markdown 語法)'
              f.textarea :name => "data[site_announcement]" do
                Preference.site_announcement
              end
            end

          end
        end
      end

      panel "Site Settings" do
        fieldset do
          ol do

            li do
              label 'LOGO (可以是圖片網址、或是 svg 向量圖)'
              f.textarea :name => "data[app_logo]" do
                Preference.app_logo
              end
            end

            li do
              label 'Facebook 專頁網址'
              f.input :name => "data[fb_page]", :type => 'text', :value => Preference.fb_page
            end

            li do
              label '頁腳內容，可使用 HTML，例如： <a class="item" href="/">回首頁</a>'
              f.input :name => "data[page_footer]", :type => 'text', :value => Preference.page_footer
            end

          end
        end
      end

      panel "Admin Dashboard Settings" do
        fieldset do
          ol do

            li do
              label 'Throughput Chart Code'
              f.input :name => "data[admin_throughput_chart_code]", :type => 'text', :value => Preference.admin_throughput_chart_code
            end

            li do
              label 'Web Transactions Chart Code'
              f.input :name => "data[admin_web_transactions_chart_code]", :type => 'text', :value => Preference.admin_web_transactions_chart_code
            end

          end
        end
      end

      f.input :type => 'submit', :value => '更新'
    end
  end

  page_action :update, :method => :post do
    params['data'].each do |k, v|
      v = true if v.to_s == 'true'
      v = false if v.to_s == 'false'
      Preference[k] = v
    end
    redirect_to :back, :notice => "設定已更新"
  end
end
