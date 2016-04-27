class ActionCorreo < ActionMailer::Base

  def send_mensaje(de,para,asunto,cc,cco,mensaje,adjuntos = [""],is_adjunto)

    if is_adjunto == true
        adjuntos.each do |adjunto|
            filename = adjunto.original_filename
            filepath = adjunto.path
            attachments[filename] = File.read(filepath)
        end
    end

    cc  = (cc.length > 0) ? cc : ''
    cco = (cco.length > 0) ? cco : ''

    mail(from: de, to: para, subject: asunto, cc: cc, bcc: cco, delivery_method_options: smtp_settings(de)) do |format|
        format.html { mensaje }
    end

  end

  private


  def smtp_settings(username)

    @setting_email = SettingsEmail.where(username: username)

    @setting_email.each do |setting|
      @username = setting.username
      @password = setting.password
    end

    self.smtp_settings = {
        address:              'smtp.gmail.com',
        port:                 587,
        domain:               'gmail.com',
        user_name:            @username,
        password:             @password,
        authentication:       'plain',
        enable_starttls_auto: true
    }
  end


end