# frozen_string_literal: true

RSpec.describe Nanook::Key do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }

  it 'should add a work peer correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"work_peer_add","address":"::ffff:172.17.0.1:7076","port":"7076"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success":""}',
      headers: {}
    )

    expect(Nanook.new.work_peers.add(address: '::ffff:172.17.0.1:7076', port: 7076)).to be true
  end

  it 'should clear work peers correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"work_peers_clear"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success":""}',
      headers: {}
    )

    expect(Nanook.new.work_peers.clear).to be true
  end

  it 'should list work peers correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"work_peers"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"work_peers":["::ffff:172.17.0.1:7076"]}',
      headers: {}
    )

    expect(Nanook.new.work_peers.list).to have(1).item
  end
end
