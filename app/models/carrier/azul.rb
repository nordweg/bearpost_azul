class Carrier::Azul < Carrier
  class << self

    def shipping_methods
      {
        'Standart': ['id_base']
      }
    end

    def general_settings
      ['Email','Senha','CpfCnpj']
    end

    def tracking_url
      "http://www.azulcargo.com.br/Rastreio.aspx?n={tracking}&tipoAwb=Nacional"
    end

    def get_tracking_number(shipment)
      shipment.shipment_number
    end

    def shipment_menu_links
      [
        ['Checar AWB', '/']
      ]
    end

    def send_to_carrier(shipment)
      check_authentication(shipment)
      check_invoice_xml(shipment)
      account      = shipment.account
      encoded_xml  = Base64.strict_encode64(shipment.invoice_xml)
      response     = send_to_azul(account,encoded_xml)
      shipment.sent_to_carrier = true
      shipment.status = 'shipped'
      shipment.save
      response
    end

    def authenticate_user(account, user, password, cpf_cnpj)
      credentials = {
          "Email" => user,
          "Senha" => password,
          "CpfCnpj" => cpf_cnpj
      }
      response    = request.post("WebAPI_EdiAzulCargo/api/Autenticacao/ValidarUsuarioPortalClienteEdi", credentials)
      if response.body["HasErrors"]
        raise Exception.new("Azul - Authentication Error: #{response.body["ErrorText"]}")
      else
        token       = response.body["Value"]
        account.azul_settings['token'] = token
        account.azul_settings['token_expire_date'] = DateTime.now + 7.hours
        account.save
      end
      response
    end

    private

    def check_authentication(shipment)
      account           = shipment.account
      settings          = shipment.account.azul_settings
      token_expire_date = settings['token_expire_date'].try(:to_datetime)
      user     = settings['user']
      password = settings['password']
      cpf_cnpj = settings['cpf_cnpj']
      authenticate_user(account, user, password, cpf_cnpj) if !token_expire_date || token_expire_date < DateTime.now
    end

    def check_invoice_xml(shipment)
      raise Exception.new("Azul - Invoice XML required") if shipment.invoice_xml.blank?
    end

    def send_to_azul(account, encoded_xml)
      token = account.azul_settings['token']
      body  = {
        "xml": encoded_xml,
      }
      response = request.post("http://hmg.onlineapp.com.br/WebAPI_EdiAzulCargo/api/NFe/Enviar?token=#{token}",body)
      if response.body["HasErrors"]
        raise Exception.new(response.body["ErrorText"])
      end
      response
    end

    def request
      Faraday.new(url: "http://hmg.onlineapp.com.br/") do |conn|
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

  end
end
