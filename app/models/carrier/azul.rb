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
      check_invoice_xml(shipment)
      get_awb(shipment)
    end

    def check_for_updates
      shipments.each do |shipment|
        get_updates(shipment)
      end
    end

    def get_awb(shipment)
      xml = Nokogiri::XML(shipment.invoice_xml)
      str = xml.at_css('infNFe').attribute("Id").try(:content)
      nfe_key = str[3..-1]
      account = shipment.account
      check_authentication(account)
      token = account.azul_settings['token']
      response = request.get("WebAPI_EdiAzulCargo/api/Ocorrencias/Consultar?token=#{token}&ChaveNFE=#{nfe_key}")
      check_response(response)
      response.body.dig("Value",0,"Awb")
    end

    def get_delivery_updates(shipment)
      check_authentication(shipment.account)
      check_tracking_number(shipment)
      token = shipment.account.azul_settings['token']
      response = request.get("WebAPI_EdiAzulCargo/api/Ocorrencias/Consultar?Token=#{token}&AWB=#{shipment.tracking_number}")
      check_response(response)
      events = response.body.dig("Value",0,"Ocorrencias")
      events.each do |event|
        history = shipment.histories.find_by(description:event["Descricao"])
        next if history.present?
        description = "#{event["Descricao"]} - #{event["UnidadeMunicipio"]}, #{event["UnidadeUF"]}"
        shipment.histories.create(
          description: description,
          city: event["UnidadeMunicipio"],
          state: event["UnidadeUF"],
          date: event["DataHora"],
          changed_by: 'Azul',
          category: 'carrier'
        )
      end
    end

    def check_response(response)
      if response.body["HasErrors"]
        raise Exception.new("Azul - #{response.body["ErrorText"]}")
      elsif response.body["Value"].empty?
        raise Exception.new("Ainda não há informações de rastreamento. Tente mais tarde.")
      end
    end

    def check_tracking_number(shipment)
      raise Exception.new("Azul - Este envio não tem um código de rastreio (AWB)") if shipment.tracking_number.blank?
    end

    def send_to_carrier(shipments)
      response = []
      shipments.each do |shipment|
        begin
          account = shipment.account
          check_authentication(account)
          check_invoice_xml(shipment)
          encoded_xml = Base64.strict_encode64(shipment.invoice_xml)
          faraday_response = send_to_azul(account,encoded_xml)
          message = faraday_response.body["HasErrors"] ? faraday_response.body["ErrorText"] : faraday_response.body["Value"]
          shipment.update(sent_to_carrier:true) unless faraday_response.body["HasErrors"]
          response << {
            shipment: shipment,
            success: shipment.sent_to_carrier,
            message: message
          }
        rescue  Exception => e
          response << {
            shipment: shipment,
            success: shipment.sent_to_carrier,
            message: e.message
          }
        end
      end
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

    def check_authentication(account)
      settings          = account.azul_settings
      token_expire_date = settings['token_expire_date'].try(:to_datetime)
      user     = settings['general']['Email']
      password = settings['general']['Senha']
      cpf_cnpj = settings['general']['CpfCnpj']
      authenticate_user(account, user, password, cpf_cnpj) if !token_expire_date || token_expire_date < DateTime.now
    end

    def check_invoice_xml(shipment)
      raise Exception.new("Azul - É necessário o XML da nota fiscal") if shipment.invoice_xml.blank?
    end

    def send_to_azul(account, encoded_xml)
      token = account.azul_settings['token']
      body  = {
        "xml": encoded_xml,
      }
      response = request.post("WebAPI_EdiAzulCargo/api/NFe/Enviar?token=#{token}",body)
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
