Pry.config.prompt_name = Rails.application.class.parent_name.scan(/[A-Z]/).join().underscore + '-' + Setting.app_url.match(/https?:\/\/([A-Za-z0-9]+)/).captures[0]

unless Rails.env.development?
  old_prompt = Pry.config.prompt

  if Rails.env.production?
    env = "\001\e[0;34m\002#{Rails.env.upcase[0]}\001\e[0m\002"

  else
    env = "\001\e[0;32m\002#{Rails.env.upcase[0]}\001\e[0m\002"
  end

  Pry.config.prompt = [
    proc { |*a| "#{env} #{old_prompt.first.call(*a)}"  },
    proc { |*a| "#{env} #{old_prompt.second.call(*a)}" }
  ]
end
