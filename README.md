# lita-icinga2

**lita-icinga2** is a handler for [Lita](https://github.com/jimmycuadra/lita) that allows interaction with Icinga monitoring solution.
It listens for notifications on a HTTP endpoint.

Work is based upon [lita-nagios](https://github.com/josqu4red/lita-nagios) handler.

Note: Colors in notifications are not enabled yet, because it relies completely on the adapter and no abstraction layer is implemented nor designed as of now.

## Installation

Add lita-icinga2 to your Lita instance's Gemfile:

``` ruby
gem "lita-icinga2"
```

## Configuration

### HTTP interface
* `default_room` (String) - Default chat room for notifications

### Icinga commands
* `api` - Icinga API URL
* `user` - Icinga user with system commands authorization
* `pass` - User password
* `verify_ssl` - default: `true`

### Example

``` ruby
Lita.configure do |config|
  config.handlers.icinga2.default_room = "#admin_room"
  config.handlers.icinga2.api = "http://icinga.example.com:5665"
  config.handlers.icinga2.user = "lita"
  config.handlers.icinga2.pass = "xxxx"
  config.handlers.icinga2.verify_ssl = true
end
```

## Usage

### Display notifications in channel

lita-icinga provides a HTTP endpoint to receive Icinga notifications:

```
POST /icinga2/notification
```
Request parameters must include those fields:
* `type` - `host` or `service`
* `room` - notifications destination (see `default_room` in configuration section)
* `host` - Icinga' $HOSTNAME or $HOSTALIAS
* `output` - Icinga' $HOSTOUTPUT or $SERVICEOUTPUT
* `state` - Icinga' $HOSTSTATE or $SERVICESTATE
* `notificationtype` - Icinga' $NOTIFICATIONTYPE
* `description` - Icinga' $SERVICEDESC (only for `service` type)

see [contrib/icinga2.txt](contrib/icinga2.txt) for information how to enable and configure notification in icinga2

### Available commands

```
lita: icinga2 recheck <-h | --host HOST> [-s | --service SERVICE] - Reschedule check for given host/service
lita: icinga2 ack(nowledge) <-h | --host HOST> [-s | --service SERVICE] [-m | --message MESSAGE] - Acknowledge host/service problem with optional message
lita: icinga2 unack(nowledge) <-h | --host HOST> <-s | --service SERVICE> - Remove acknowledge on host/service problem
lita: icinga2 list [-h | --host HOST] - List all checks (optional on specific host)
```

### ToDo

```
lita: icinga2 enable notif(ication(s)) <-h | --host HOST> [-s | --service SERVICE] - Enable notifications for given host/service
lita: icinga2 disable notif(ication(s)) <-h | --host HOST> [-s | --service SERVICE] - Disable notifications for given host/service
lita: icinga2 (fixed|flexible) downtime <-d | --duration DURATION > <-h | --host HOST> [-s | --service SERVICE] - Schedule downtime for a host/service with duration units in (m, h, d, default to seconds)
```
