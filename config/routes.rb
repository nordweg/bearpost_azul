Rails.application.routes.draw do
  namespace :azul do
    post "authenticate_user_ajax"
    post "send_to_carrier"
    get  "get_awbs"
  end

  post  "azul/:shipment_id/get_awb",        to: "azul#get_awb"
end
