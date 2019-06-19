class AzulController < ApplicationController
  before_action :set_shipment

  def new
  end

  def send_to_azul
    xml_string  = params[:azul][:nfe_xml].read
    encoded_xml = Base64.strict_encode64(xml_string.strip)

    token_expire_date = @shipment.account.azul_settings['token_expire_date']
    if !token_expire_date || token_expire_date > DateTime.now
      Carrier::Azul.validar_usuario(@shipment.account)
    end

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

end
