if Rails.respond_to?(:application)
  Rails.application.routes.draw do |map|
    namespace :upload_juicer do
      resources :uploads, :only => [ :create ]
    end
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.namespace :upload_juicer do |upload_juicer|
      upload_juicer.resources :uploads, :only => [ :create ]
    end
  end
end