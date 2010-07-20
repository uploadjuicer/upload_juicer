Rails.application.routes.draw do |map|
  namespace :upload_juicer do
    resources :uploads, :only => [ :create ]
  end
end