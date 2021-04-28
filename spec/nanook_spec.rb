# frozen_string_literal: true

RSpec.describe Nanook do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }

  it 'default_unit class method should return :nano by default' do
    expect(Nanook.default_unit).to eq(:nano)
  end

  it 'default_unit class method should return Nanook::UNIT if defined' do
    silent_warnings do
      Nanook::UNIT = :raw
      expect(Nanook.default_unit).to eq(:raw)
      Nanook::UNIT = :nano # reset
    end
  end

  it 'should have a block method' do
    expect(Nanook.new.block('some_block')).to be_kind_of(Nanook::Block)
  end

  it 'should have a private_key method' do
    expect(Nanook.new.private_key).to be_kind_of(Nanook::PrivateKey)
  end

  it 'should have a public_key method' do
    expect(Nanook.new.public_key('some_key')).to be_kind_of(Nanook::PublicKey)
  end

  it 'should have a node method' do
    expect(Nanook.new.node).to be_kind_of(Nanook::Node)
  end

  it 'should have a wallet method' do
    expect(Nanook.new.wallet).to be_kind_of(Nanook::Wallet)
  end

  it 'should have an account method' do
    expect(Nanook.new.account('some_account')).to be_kind_of(Nanook::Account)
  end

  it 'should have a work_peers method' do
    expect(Nanook.new.work_peers).to be_kind_of(Nanook::WorkPeer)
  end

  it 'should have a rpc accessor' do
    expect(Nanook.new.rpc).to be_kind_of(Nanook::Rpc)
  end

  it 'should request network_telemetry correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"telemetry"}',
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
          {
            "block_count": "5777903",
            "cemented_count": "688819",
            "unchecked_count": "443468",
            "account_count": "620750",
            "bandwidth_cap": "1572864",
            "peer_count": "32",
            "protocol_version": "18",
            "uptime": "556896",
            "genesis_block": "F824C697633FAB78B703D75189B7A7E18DA438A2ED5FFE7495F02F681CD56D41",
            "major_version": "21",
            "minor_version": "0",
            "patch_version": "1",
            "pre_release_version": "2",
            "maker": "3",
            "timestamp": "1587055945990",
            "active_difficulty": "ffffffcdbf40aa45"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.network_telemetry).to eq(
      block_count: 5_777_903,
      cemented_count: 688_819,
      unchecked_count: 443_468,
      account_count: 620_750,
      bandwidth_cap: 1_572_864,
      peer_count: 32,
      protocol_version: 18,
      uptime: 556_896,
      genesis_block: Nanook.new.block('F824C697633FAB78B703D75189B7A7E18DA438A2ED5FFE7495F02F681CD56D41'),
      major_version: 21,
      minor_version: 0,
      patch_version: 1,
      pre_release_version: 2,
      maker: 3,
      timestamp: Time.at(1_587_055_945_990),
      active_difficulty: 'ffffffcdbf40aa45'
    )
  end
end
