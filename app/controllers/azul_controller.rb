class AzulController < ApplicationController
  skip_before_action :verify_authenticity_token

  def authenticate_user_ajax
    begin
      account  = current_company.accounts.find(params["account"])
      user     = params["email"]
      password = params["password"]
      cpf_cnpj = params["cpf_cnpj"]
      response = Carrier::Azul.authenticate_user(account, user, password, cpf_cnpj)
      render json: response.body.to_json
    rescue Exception => e
      render json: e.message.to_json
    end
  end

  def send_to_carrier # Button in settings to send shipments to azul
    carrier   = Carrier::Azul
    account   = Account.find(params["account"])
    shipments = carrier.shipment.ready_to_ship.where(account:account)
    begin
      shipments.each do |shipment|
        carrier.send_to_carrier(shipment)
        shipment.update(sent_to_carrier:true)
      end
      flash[:success] = 'Todos pedidos foram sincronizados'
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to edit_carrier_path(carrier.id)
  end

  def get_awbs
    @results = []
    Carrier::Azul.shipments.where(tracking_number:nil,account:params[:account]).each do |shipment|
      begin
        awb = Carrier::Azul.get_awb(shipment)
        shipment.update(tracking_number: awb)
        message = "Rastreio atualizado: AWB #{awb}"
      rescue Exception => e
        message = e.message
      end
      result_hash = {
        shipment: shipment,
        message: message
      }
      @results << result_hash
    end
  end

end
