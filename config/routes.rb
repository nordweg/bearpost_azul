Rails.application.routes.draw do
  resources :shipments do
    member do
      post 'azul/new',            to: "azul#new"
      post 'azul/send_to_azul',   to: "azul#send_to_azul"
    end
  end
  post  "azul/:shipment_id/send_shipment",  to: "azul#send_shipment"
  post  "azul/:shipment_id/get_awb",        to: "azul#get_awb"
  post  "azul/authenticate_user_ajax",      to: "azul#authenticate_user_ajax"
end
