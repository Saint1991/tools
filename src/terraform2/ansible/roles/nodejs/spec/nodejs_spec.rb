require 'spec_helper'

describe package('nodejs') do
  it { should be_installed }
end

describe command("node -v") do
  its(:exit_status) { should eq 0 }
end