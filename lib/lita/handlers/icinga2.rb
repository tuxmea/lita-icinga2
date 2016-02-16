module Lita
  module Handlers
    class Icinga2 < Handler

      config :default_room
      config :api, default: "http://icinga.example.com:5665/"
      config :user, default: "icingaadmin"
      config :pass, default: "icinga"
      config :verify_ssl, default: true

      def initialize(robot)
        headers = {
          "Accept" => "application/json",
          "Content" => "application/json",
        }
        if robot.config.handlers.icinga2.verify_ssl == true
          ssl_ca_file = "pki/icinga2-ca.crt"
          verify_ssl = ''
        else
          ssl_ca_file = ''
          verify_ssl = OpenSSL::SSL::VERIFY_NONE
        end 
        @site = RestClient::Resource.new(
          URI.encode(robot.config.handlers.icinga2.api),
          :headers => headers,
          :user => robot.config.handlers.icinga2.user,
          :password => robot.config.handlers.icinga2.pass,
          :ssl_ca_file => ssl_ca_file,
          :verify_ssl => verify_ssl,
          :accept => :json
        )
        super(robot)
      end

      ##
      # Chat routes
      ##

      route /^icinga\s+recheck/, :recheck,
        command: true,
        kwargs: {
          host: { short: "h" },
          service: { short: "s" }
        },
        help: {
          "icinga recheck <-h | --host HOST> [-s | --service SERVICE]" => "Reschedule check for given host/service"
        }

      def recheck(response)
        args = response.extensions[:kwargs]
        return response.reply("Missing 'host' argument") unless args[:host]

        if args[:service]
          payload_w_params = { 
                  "type" => "Service", 
                  "filter" => "service.name==\"#{args[:service]}\" && host.name==\"#{args[:host]}\"", 
                  "force_check" => true 
          }
          reply = "#{args[:service]} on #{args[:host]}"
        else
          payload_w_params = { 
                  "type" => "Service", 
                  "filter" => "host.name==\"#{args[:host]}\"", 
                  "force_check" => true 
          }
          reply = args[:host]
        end

        reply = @site["/v1/actions/reschedule-check"].post payload_w_params.to_json { |response, request, result, &block|
          response.return!(result)
        }
        format_reply = ''
        JSON.parse(reply)["results"].each do |stat|
          format_reply += stat["status"] + "\n"
        end
        response.reply(format_reply)
      end

      route /^icinga\s+ack(nowledge)?/, :acknowledge,
        command: true,
        kwargs: {
          host: { short: "h" },
          service: { short: "s" },
          message: { short: "m" }
        },
        help: {
          "icinga ack(nowledge) <-h | --host HOST> [-s | --service SERVICE] [-m | --message MESSAGE]" => "Acknowledge host/service problem with optional message",
        }

      def acknowledge(response)
        args = response.extensions[:kwargs]
        return response.reply("Missing 'host' argument") unless args[:host]

        user = response.message.source.user.name
        message =  args[:message] ? "#{args[:message]} (#{user})" : "acked by #{user}"

        if args[:service]
          payload_w_params = { 
            "author" => "#{user}", 
            "comment" => "#{message}",
            "type" => "Service", 
            "filter" => "service.name==\"#{args[:service]}\" && host.name==\"#{args[:host]}\"", 
            "notify" => true
          }
          reply = "#{args[:service]} on #{args[:host]}"
        else
          payload_w_params = { 
            "author" => "#{user}", 
            "comment" => "#{message}",
            "type" => "Service", 
            "filter" => "host.name==\"#{args[:host]}\"", 
            "notify" => true
          }
          reply = args[:host]
        end

        reply = @site["/v1/actions/acknowledge-problem"].post payload_w_params.to_json { |response, request, result, &block|
          response.return!(result)
        }
        format_reply = ''
        JSON.parse(reply)["results"].each do |stat|
          format_reply += stat["status"] + "\n"
        end
        response.reply(format_reply)
      end

      route /^icinga\s+unack(nowledge)?/, :unacknowledge,
        command: true,
        kwargs: {
          host: { short: "h" },
          service: { short: "s" }
        },
        help: {
          "icinga unack(nowledge) <-h | --host HOST> <-s | --service SERVICE>" => "Remove Acknowledge host/service problem",
        }

      def unacknowledge(response)
        args = response.extensions[:kwargs]
        return response.reply("Missing 'host' argument") unless args[:host]
        return response.reply("Missing 'service' argument") unless args[:service]

        payload_w_params = { 
          "type" => "Service", 
          "filter" => "service.name==\"#{args[:service]}\" && host.name==\"#{args[:host]}\"", 
        }
        reply = "#{args[:service]} on #{args[:host]}"

        reply = @site["/v1/actions/remove-acknowledgement"].post payload_w_params.to_json { |response, request, result, &block|
          response.return!(result)
        }
        format_reply = ''
        JSON.parse(reply)["results"].each do |stat|
          format_reply += stat["status"] + "\n"
        end
        response.reply(format_reply)
      end

#      route /^icinga(\s+(?<type>fixed|flexible))?\s+downtime/, :schedule_downtime,
#        command: true,
#        kwargs: {
#          host: { short: "h" },
#          service: { short: "s" },
#          duration: { short: "d" }
#        },
#        help: {
#          "icinga (fixed|flexible) downtime <-d | --duration DURATION > <-h | --host HOST> [-s | --service SERVICE]" => "Schedule downtime for a host/service with duration units in (m, h, d, default to seconds)"
#        }
#
#      def schedule_downtime(response)
#        args = response.extensions[:kwargs]
#        return response.reply("Missing 'host' argument") unless args[:host]
#
#        units = { "m" => :minutes, "h" => :hours, "d" => :days }
#        match = /^(?<value>\d+)(?<unit>[#{units.keys.join}])?$/.match(args[:duration])
#        return response.reply("Invalid downtime duration") unless (match and match[:value])
#
#        duration = match[:unit] ? match[:value].to_i.send(units[match[:unit]]) : match[:value].to_i
#
#        options = case response.match_data[:type]
#        when "fixed"
#          { type: :fixed, start_time: Time.now, end_time: Time.now + duration }
#        when "flexible"
#          { type: :flexible, hours: (duration / 3600), minutes: (duration % 3600 / 60) }
#        end.merge({ author: "#{response.message.source.user.name} via Lita" })
#
#        if args[:service]
#          method_w_params = [ :schedule_service_downtime, args[:host], args[:service], options ]
#          reply = "#{args[:service]} on #{args[:host]}"
#        else
#          method_w_params = [ :schedule_host_downtime, args[:host], options ]
#          reply = args[:host]
#        end
#
#        reply = @site.send(*method_w_params) ? "#{options[:type].capitalize} downtime set for #{reply}" : "Failed to schedule downtime for #{reply}"
#        response.reply(reply)
#      end
#

      ##
      # HTTP endpoints
      ##

      http.post "/icinga2/notification", :receive

      def receive(request, response)
        params = request.params

        if params.has_key?("room")
          room = params["room"]
        elsif config.default_room
          room = config.default_room
        else
          raise "Room must be defined. Either fix your command or specify a default room ('config.handlers.icinga.default_room')"
        end

        message = nil
        case params["notificationtype"]
        when "ACKNOWLEDGEMENT"
          message = "[ACK] "
        when "PROBLEM", "RECOVERY"
          message = ""
        else
          # Don't process FLAPPING* and DOWNTIME* events for now
          return
        end

        case params["type"]
        when "StateChange"
          message += "#{params["host"]} - #{params["service"]} - #{params["output"]}"
        else
          message += "Unknown type of event"
          #raise "Notification type must be defined in Icinga command ('host' or 'service')"
        end

        target = Source.new(room: room)
        robot.send_message(target, "icinga: #{message}")
      rescue Exception => e
        Lita.logger.error(e)
      end
      Lita.register_handler(self)
    end

  end
end
