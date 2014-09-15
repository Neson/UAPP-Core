ActiveAdmin.register OauthApplicationData do
  menu priority: 51, label: "應用程式資料", parent: "應用程式"

  permit_params :sms_quota, :allow_use_of_user_rfid

end
