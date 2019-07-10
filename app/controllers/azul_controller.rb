class AzulController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_shipment, only: [:new, :send_to_azul]

  def new
  end

  def send_to_azul
    # xml_string  = params[:azul][:nfe_xml].read
    # encoded_xml = Base64.strict_encode64(xml_string.strip)
    encoded_xml = Base64.strict_encode64(@shipment.nfe_xml)

    token_expire_date = @shipment.account.azul_settings['token_expire_date'].try(:to_datetime)
    if !token_expire_date || token_expire_date < DateTime.now
      Carrier::Azul.validate_user(@shipment.account)
    end

    20.times { p "Enviando" }

    response = Carrier::Azul.send_to_azul(@shipment.account,encoded_xml)
    if response.success?
      @shipment.settings['sent_to_azul'] = true
      @shipment.save
      flash[:success] = "Nota fiscal enviada para a Azul"
    else
      flash[:error] = response.body["ErrorText"]
    end
    redirect_to @shipment
  end

  def set_shipment
    @shipment = Shipment.find(params[:id])
  end

  def authenticate_user_ajax
    account  = Account.find(params["account"])
    user     = params["email"]
    password = params["password"]
    cpf_cnpj = params["cpf_cnpj"]
    response = Carrier::Azul.authenticate_user(account, user, password, cpf_cnpj)
    render json: response.body
  end

end
