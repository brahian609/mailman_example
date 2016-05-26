class MessagesController < ApplicationController

  after_action :allow_iframe, only: [:view_html,:index]

  #descargar lista de correos del usuario
  def index

    begin

      id_cuenta     = params[:id] #id de la cuenta de email
      rows          = params[:rows] #registros a obtener de la cuenta de email
      folder        = params[:folder]
      $buscar_texto = params[:buscar] #texto a buscar
      $buscar_por   = params[:por] #buscar por asunto,mensaje,etc

      if !id_cuenta.blank?
        session[:id_cuenta] = id_cuenta
      end

      @setting_email = SettingsEmail.where(id: session[:id_cuenta])

      if @setting_email.blank?

        # redirect_to :controller => 'settings_emails', :action => 'new'
        render json: { errors: {message: "Debes configurar la cuenta de correo entrante"}  }
      else

        @setting_email.each do |setting|
          $server   = setting.server
          $port     = setting.port
          $username = setting.username
          $password = setting.password
        end

        #definir el folder a descargar
        if folder.present?
          session[:folder] = folder.to_s
        elsif !folder.present? && !session[:folder].present?
          session[:folder] = 'INBOX'
        end #folder

        $folder = session[:folder]

        #definir el numero de filas a mostrar
        if rows.present?
          session[:rows] = rows.to_i
        elsif !rows.present? && !session[:rows].present?
          session[:rows] = 15
        end #filas a mostrar

        #borrar los adjuntos de cada usuario
        @att = Attachment.find_by_sql("select * from attachments where id != ''")
        if @att.length >= 1

          @att.each do |att|
            att.destroy
          end

        end #borrar registros

        if params[:a].blank? && params[:s].blank?

          $anterior = 1
          $siguiente = session[:rows]

        elsif !params[:a].blank?

          if params[:a].to_i <= session[:rows]

            $anterior = 1
            $siguiente = session[:rows]

          else

            $anterior = params[:a].to_i - session[:rows]
            $siguiente = params[:a].to_i

          end

        else

          $anterior = params[:s].to_i
          $siguiente = params[:s].to_i + session[:rows]

        end

        #obtener correos
        ENV['folder'] = 'mailbox'
        load 'script/mailman_server.rb'
        @messages = @@messages

        #obtener folders
        ENV['folder'] = 'folder'
        load 'script/mailman_folders.rb'
        @folders = @@folders

        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @messages }
        end

      end

    rescue Exception => e

      render json: { message: [e, *e.backtrace].join("\n")  }

    end

  end

  #probar la conexion con la cuenta de correo por medio de imap
  def test_connection

    $anterior  = 1
    $siguiente = 2

    $server   = params[:server]
    $port     = params[:port]
    $username = params[:username]
    $password = params[:password]

    @data = {
        username: $username,
        server: $server,
        port: $port
    }

    begin

      load 'script/mailman_server.rb'
      render json: { errors: {data: @data, status: 200, message: "conexión exitosa"}  }

    rescue

      render json: { errors: {data: @data, status: 500, message: "Error! valida las credenciales de acceso o revisa la configuración de tu cuenta"}  }

    end

  end

  #descargar el contenido de un correo en especifico
  def view_html

    $anterior = params[:id].to_i - 1
    $siguiente = params[:id].to_i - 1

    $buscar_texto = nil
    $buscar_por   = nil

    ENV['folder'] = 'mailbox'
    load 'script/mailman_server.rb'

    adjuntos = ''

    @@messages.each do |message|
      @from = message[:from]
      @to = message[:to]
      @cc = message[:cc]
      @bcc = message[:bcc]
      @subject = message[:subject]
      @date = message[:date]
      @text = message[:text_body]
      @html = message[:html_body]
    end

    cc_list = @cc.length > 0 ? 'Cc: <span style="word-wrap: break-word;">' + @cc + '</span><br>' : ''
    bcc_list = @bcc.length > 0 ? 'Cco: <span style="word-wrap: break-word;">' + @bcc + '</span><br>' : ''

    @@the_message_attachments.each do |att|
      adjuntos += '<li> <a style="color:#666; text-decoration:none;" href='+att.attached_file.url(:original, false)+' target="_blank">'+att.attached_file_file_name+'</a> </li>'
    end

    adjuntos_list =  (adjuntos.length > 0) ? 'Adjuntos: <ul>' + adjuntos + '</ul>' : ''

    # render file: 'messages/view_html'

    respond_to do |format|
      format.html {
        render text: '<div class="container-fluid"> ' +
          '<br>' +
          'De: ' + @from  +
          '<br>' +
          'A: <span style="word-wrap: break-word;">' + @to + '</span>' +
          '<br>' +
          cc_list +
          bcc_list +
          adjuntos_list +
          '<hr class="col-lg-12">' +
          '</div>' + @html, :layout => false
      }
      # format.html {
      #   render text: '<div class="container-fluid">' +
      #     '<div class="col-md-12" style="background-color: #ced8e1">' +
      #       '<h4>' + @subject + '</h4>' +
      #       '<hr style="margin-top: 0px; border-top: 1px solid #235589">' +
      #       '<strong>' + @from + '</strong>' +
      #       '<br>' +
      #       '<div style="max-width: 90%; float: left">' +
      #         '<small>Para ' + @to[0..50] + '</small>' +
      #       '</div>' +
      #       '<div style="margin-left: 5px; max-width: 1%; float: left">' +
      #         '<div class="dropdown">' +
      #           '<button class="btn btn-default btn-xs" type="button" data-toggle="dropdown" aria-haspopup="true">' +
      #             '<span class="caret"></span>' +
      #           '</button>' +
      #           '<div class="dropdown-menu"
      #                style="word-wrap: break-word;
      #                width: 500px;
      #                padding: 20px;
      #                height: 300px;
      #                overflow: auto">' +
      #             '<table>
      #               <tr>
      #                 <td valign="top">De:</td>
      #                 <th>' + @from + '</th>
      #               </tr>
      #               <tr>
      #                 <td valign="top">Para:</td>
      #                 <td>' + @to + '</td>
      #               </tr>
      #               <tr>
      #                 <td valign="top">Fecha:</td>
      #                 <td>' + @date + '</td>
      #               </tr>
      #               <tr>
      #                 <td valign="top">Asunto:</td>
      #                 <td>' + @subject + '</td>
      #               </tr>
      #             </table>
      #           </div>
      #         </div>
      #       </div>
      #     </div>
      #   </div>'
      # }
      format.json {
        render json: {
            message: @html
        }
      }
    end

  end

  #enviar correos electrónicos
  def send_email
    if request.post?

      @emails = []
      params[:para].each do |email|
        @emails = email
      end

      @cc = []
      params[:cc].each do |cc|
        @cc = cc
      end

      @cco = []
      params[:cco].each do |cco|
        @cco = cco
      end

      @messa = Message.create(:from => $username, :to => @emails, :subject => params[:asunto], :html_body => params[:mensaje])

      if @messa.save

        # params[:adjunto].each do |attachment|
        #   file = attachment
        #   file.class.class_eval { attr_accessor :original_filename, :content_type }
        #   file.original_filename = attachment.original_filename
        #   file.content_type = attachment.content_type
        #   att = Attachment.new
        #   att.message_id = @messa.id
        #   att.attached_file = file
        #
        #
        #   # att.attached_file_file_name = attachment.original_filename
        #   # att.attached_file_file_size = attachment.size
        #   # att.attached_file_content_type = attachment.content_type
        #   # att.attached_file_updated_at = attachment.updated_at
        #   att.save(:validate => false)
        # end

        is_adjunto = (params[:adjunto].present?) ? true : false

        ActionCorreo.send_mensaje($username,@emails,params[:asunto],@cc,@cco,params[:mensaje],params[:adjunto],is_adjunto).deliver_now
      end

      render text: "<div style='color: #3c763d; background-color: #dff0d8; border-color: #b2dba1;background-repeat: repeat-x; padding: 5px; text-align: center'><h2>Mensaje enviado</h2></div>"

    end
  end

  def add_attachment

    @func_num = params["CKEditorFuncNum"]
    @ck_editor = params["CKEditor"]
    if params.include?(:upload)
      data = params.delete(:upload)
      @image = Attachment.create({:attached_file => data}) if data.present?
      @url = @image.attached_file.url(:original, false)
    end
    puts "imagen => #{@url}"
    render text: "<script>window.parent.CKEDITOR.tools.callFunction(#{@func_num}, '#{@url}');</script>"

  end

  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  def edit
    @message = Message.find(params[:id])
  end

  def create
    @message = Message.new(params[:message])

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def allow_iframe
    response.headers.delete 'X-Frame-Options'
  end

end
