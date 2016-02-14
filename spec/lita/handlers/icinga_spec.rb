require "spec_helper"

describe Lita::Handlers::Icinga, lita_handler: true do
  it { is_expected.to route_http(:post, "/icinga/notifications").to(:receive) }
  it { is_expected.to route_command("icinga enable notif -h par-db4").with_authorization_for(:admins).to(:toggle_notifications) }
  it { is_expected.to route_command("icinga enable notif -h par-db4 -s Load").with_authorization_for(:admins).to(:toggle_notifications) }
  it { is_expected.to route_command("icinga disable notification -h par-db4 -s Load").with_authorization_for(:admins).to(:toggle_notifications) }
  it { is_expected.to route_command("icinga disable notifications -h par-db4 -s Load").with_authorization_for(:admins).to(:toggle_notifications) }

  it { is_expected.to route_command("icinga recheck -h par-db4").with_authorization_for(:admins).to(:recheck) }
  it { is_expected.to route_command("icinga recheck -h par-db4 -s Load").with_authorization_for(:admins).to(:recheck) }

  it { is_expected.to route_command("icinga ack -h par-db4").with_authorization_for(:admins).to(:acknowledge) }
  it { is_expected.to route_command("icinga ack -h par-db4 -s Load").with_authorization_for(:admins).to(:acknowledge) }

  it { is_expected.to route_command("icinga fixed downtime -d 2h -h par-db4 -s Load").with_authorization_for(:admins).to(:schedule_downtime) }
  it { is_expected.to route_command("icinga flexible downtime -d 2h -h par-db4 -s Load").with_authorization_for(:admins).to(:schedule_downtime) }
end
