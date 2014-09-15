ActiveAdmin.register User do
  menu priority: 10

  permit_params :admin, :name, :email, :fbid, :gender, :identity, :student_id, :admission_year, :admission_department_code, :department_code, :mobile, :birthday, :address, :brief

  index do
    selectable_column
    id_column
    column :admin
    column :name do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column :fbid do |user|
      link_to user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank"
    end
    column :confirmed_at
    column :sign_in_count
    actions
  end

  index :as => :detailed_table do
    selectable_column
    id_column
    column :admin
    column :confirmed_at
    column :name do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column :fbid do |user|
      link_to user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank"
    end
    column :gender
    column :sign_in_count
    column :identity
    column :student_id
    column :admission_year
    column :admission_department
    column :department
    column :mobile
    column :birthday
    column :address
    column :brief
    column :created_at
    column :updated_at
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    column :unconfirmed_mobile
    column :unconfirmed_email
    actions
  end

  index as: :grid, columns: 10, per_page: 500 do |user|
    div do
      link_to(image_tag(user.avatar), admin_user_path(user))
    end
    link_to(user.name, admin_user_path(user))
  end

  form do |f|
    f.inputs do
      f.input :admin
      f.input :name
      f.input :email
      f.input :fbid
      f.input :gender, :as => :select, :collection => options_for_select([['male', 'male'], ['female', 'female']], user.gender)
      f.input :identity, :as => :select, :collection => options_for_select([[t('bachelor'), 'bachelor'], [t('master'), 'master'], [t('doctor'), 'doctor'], [t('professor'), 'professor'], [t('staff'), 'staff'], [t('other'), 'other'], [t('guest'), 'guest']], user.identity)
      f.input :student_id
      f.input :admission_year
      f.input :admission_department_code, :as => :select, :collection => option_groups_from_collection_for_select(College.all, :departments, :name, :code, :name, user.admission_department_code)
      f.input :department_code, :as => :select, :collection => option_groups_from_collection_for_select(College.all, :departments, :name, :code, :name, user.department_code)
      f.input :mobile
      f.input :birthday
      f.input :address
      f.input :brief
    end
    f.actions
  end

  scope :all, :default => true
  scope :confirmed
  scope :unconfirmed

  filter :id
  filter :email
  filter :name
  filter :fbid
  filter :student_id
  filter :identity
  filter :admission_year
  filter :admission_department
  filter :department
  filter :mobile
  filter :gender
  filter :birthday
  filter :mobile_confirm_tries
  filter :admin
  filter :created_at
  filter :confirmed_at
  filter :updated_at
  filter :sign_in_count
  filter :current_sign_in_at
  filter :last_sign_in_at
  filter :current_sign_in_ip
  filter :last_sign_in_ip
  filter :unconfirmed_email
end
