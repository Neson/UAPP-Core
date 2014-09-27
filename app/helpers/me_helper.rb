module MeHelper
  def gender_options_for_select
    get_options_for_select_from_constant_and_locale('user_genders')
  end

  def data_privacy_options_for_select
    get_options_for_select_from_constant_and_locale('user_data_privacies')
  end
end
