ActiveAdmin.register Department do
  menu priority: 111, parent: "資料集"

  permit_params :college_code, :code, :name

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :college
    actions
  end
end
