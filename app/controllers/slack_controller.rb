class SlackController < ApplicationController

  # POST /
  def index
    # something
  end

  # POST /commands
  def commands
    # slashコマンドの処理
    # verify
    logger.info(request.body.read)
    # SLACK_SIGNING_SECRET = ENV['SLACK_SIGNING_SECRET']
    # timestamp = request.header['X-Slack-Request-Timestamp']
    # signature = request.header['X-Slack-Signature']
    # sig_base = "v0:#{timestamp}:"
    # decode to [key, value] array
    request.body.rewind
    req = URI.decode_www_form(request.body.read)

    command_service.execute(req)

  end

  # POST /interact
  def interact
    # interaction element
    # TODO: request verification

    # decode to [key, value] array
    dec_json = URI.decode_www_form(request.body.read)
    # parse key "payload"'s value
    parsed_json = JSON.parse(dec_json.assoc('payload').last, symbolize_names: true)
    logger.info(parsed_json)
    interact_service.execute(parsed_json)
  end

  # Rake Task: reminder check
  def reminder
    reminders = get_reminders
    logger.info(reminders)
    
    reminders.each do |reminder|
      slack_client.send_msg('schedule', reminder)
    end
  end

  def get_reminders
    remind_service.check_reminders
  end

  def remind_service
    RemindService.new
  end

  def command_service
    CommandService.new
  end

  def interact_service
    InteractService.new
  end

  def slack_client
    @slack_client ||= Client::SlackClient.new()
  end

end
