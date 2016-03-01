require "spec_helper"

describe Lita::Handlers::Icinga2, lita_handler: true do
  it { is_expected.to route_http(:post, "/icinga2/notification").to(:receive) }
  #it { is_expected.to route_command("icinga2 enable notif -h par-db4").with_authorization_for(:admins).to(:toggle_notifications) }
  #it { is_expected.to route_command("icinga2 enable notif -h par-db4 -s Load").with_authorization_for(:admins).to(:toggle_notifications) }
  #it { is_expected.to route_command("icinga2 disable notification -h par-db4 -s Load").with_authorization_for(:admins).to(:toggle_notifications) }
  #it { is_expected.to route_command("icinga2 disable notifications -h par-db4 -s Load").with_authorization_for(:admins).to(:toggle_notifications) }

  it { is_expected.to route_command("icinga2 recheck -h par-db4").with_authorization_for(:admins).to(:recheck) }
  it { is_expected.to route_command("icinga2 recheck -h par-db4 -s Load").with_authorization_for(:admins).to(:recheck) }

  it { is_expected.to route_command("icinga2 ack -h par-db4").with_authorization_for(:admins).to(:acknowledge) }
  it { is_expected.to route_command("icinga2 ack -h par-db4 -s Load").with_authorization_for(:admins).to(:acknowledge) }

  it { is_expected.to route_command("icinga2 list -h par-db4").with_authorization_for(:admins).to(:list_checks) }

  #it { is_expected.to route_command("icinga2 fixed downtime -d 2h -h par-db4 -s Load").with_authorization_for(:admins).to(:schedule_downtime) }
  #it { is_expected.to route_command("icinga2 flexible downtime -d 2h -h par-db4 -s Load").with_authorization_for(:admins).to(:schedule_downtime) }
end
