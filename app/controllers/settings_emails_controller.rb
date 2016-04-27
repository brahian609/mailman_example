class SettingsEmailsController < ApplicationController
  before_action :set_settings_email, only: [:show, :edit, :update, :destroy]

# GET /settings_emails
  def index
    reset_session
    @settings_emails = SettingsEmail.all
  end

# GET /settings_emails/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @settings_email }
    end
  end

# GET /settings_emails/new
  def new
    @settings_email = SettingsEmail.new
  end

# GET /settings_emails/1/edit
  def edit
  end

# POST /settings_emails
  def create

    @settings_email = SettingsEmail.new(settings_email_params)

    if @settings_email.save

      respond_to do |format|
        format.html {
          redirect_to @settings_email, notice: "Configuración de email creada correctamente"
        }
        format.json {
          render json: {notification: "Configuración de email creada correctamente"}, status: :created
        }
      end

    else

      respond_to do |format|
        format.html {
          render :new
        }
        format.json {
          render json: {notification: "Error al guardar la configuración"}, status: :unprocessable_entity
        }
      end


    end

  end

# PATCH/PUT /settings_emails/1
  def update
    if @settings_email.update(settings_email_params)

      # respond_to do |format|
      #   format.html {
      #     redirect_to @settings_email, notice: "Configuración de email modificada correctamente"
      #   }
      #   format.json {
      #     render json: {notification: "Configuración de email modificada correctamente"}, status: :ok
      #   }
      # end

      render json: {notification: "Configuración de email modificada correctamente"}, status: :ok

    else

      # respond_to do |format|
      #   format.html {
      #     render :edit
      #   }
      #   format.json {
      #     render json: {notification: "Error al guardar la configuración"}, status: :unprocessable_entity
      #   }
      # end

      render json: {notification: "Error al guardar la configuración"}, status: :unprocessable_entity

    end
  end

# DELETE /settings_emails/1
  def destroy
    @settings_email.destroy
    redirect_to settings_emails_url, notice: 'Configuración de email eliminada correctamente'
  end

  private
# Use callbacks to share common setup or constraints between actions.
  def set_settings_email

    begin

      @settings_email = SettingsEmail.find(params[:id])

    rescue

      @settings_email = { errors: {status: 404, message: "Record Not Found"}  }

    end

  end

# Only allow a trusted parameter "white list" through.
  def settings_email_params
    params.require(:settings_email).permit(:username, :password, :server, :port)
  end
end
