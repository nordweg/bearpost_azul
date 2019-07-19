class AzulController < ApplicationController
  skip_before_action :verify_authenticity_token

  def authenticate_user_ajax
    begin
      account  = Account.find(params["account"])
      user     = params["email"]
      password = params["password"]
      cpf_cnpj = params["cpf_cnpj"]
      response = Carrier::Azul.authenticate_user(account, user, password, cpf_cnpj)
      render json: response.body.to_json
    rescue Exception => e
      render json: e.message.to_json
    end
  end

end
