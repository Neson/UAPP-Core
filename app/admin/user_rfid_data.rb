ActiveAdmin.register UserRfidData do
  menu priority: 115, parent: "資料集"

  active_admin_import :validate => true,
                      :template_object => ActiveAdminImport::Model.new(
                        :hint => "匯入 CSV 檔案格式為：學號,MD5(卡號)，匯入之前會將現有資料清除！",
                        :csv_headers => ["sid", "encrypted_code"]
                      ),
                      :before_import => proc {
                        UserRfidData.delete_all
                      }

  permit_params :sid, :encrypted_code

  index do
    selectable_column
    id_column
    column :sid
    column :encrypted_code
    actions
  end
end

