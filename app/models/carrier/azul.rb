class Carrier::Azul < Carrier
  class << self
    def settings
      {
        'general': ['Email','Senha','CpfCnpj'],
        'shipping_methods': {
          'Standart': ['id_base']
        }
      }.with_indifferent_access
    end

    def tracking_url
      "http://www.azulcargo.com.br/Rastreio.aspx"
    end

    def get_tracking_number(shipment)
      shipment.shipment_number
    end

    def shipment_menu_links
      [
        ['Enviar NFe para Azul', ':id/azul/new'],
        ['Checar AWB', '/']
      ]
    end

    def ready_to_ship?(shipment)
      if !shipment.settings['sent_to_azul']
        false
      else
        true
      end
    end

    def send_to_azul(account, encoded_xml)
      token = account.azul_settings['token']
      body  = {
        "xml": encoded_xml,
      }
      response = request.post("http://hmg.onlineapp.com.br/WebAPI_EdiAzulCargo/api/NFe/Enviar?token=#{token}",body)
    end

    def validar_usuario(account)
      body     = account.azul_settings['general']
      response = request.post("WebAPI_EdiAzulCargo/api/Autenticacao/ValidarUsuarioPortalClienteEdi", body)
      token    = response.body["Value"]

      account.azul_settings['token'] = token
      account.azul_settings['token_expire_date'] = DateTime.now + 7.hours
      account.save

      {
        "Email": "lucaskuhn@azulcargo.com.br",
        "Senha": "123456",
        "CpfCnpj": "13536856000128"
      }
    end

    private

    def request
      Faraday.new(url: "http://hmg.onlineapp.com.br/") do |conn|
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

  end
end
