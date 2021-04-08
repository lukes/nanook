# frozen_string_literal: true

RSpec.describe Nanook::Node do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }

  it 'should request account_count correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"frontier_count"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"count":"1000"}',
      headers: {}
    )

    expect(Nanook.new.node.account_count).to eq 1000
  end

  it 'should request block_count correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"block_count"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"count":"1000","unchecked":"10"}',
      headers: {}
    )

    expect(Nanook.new.node.block_count).to have_key(:count)
  end

  it 'should request keepalive correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"keepalive","address":"::ffff:138.201.94.249","port":"7075"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"started":"1"}',
      headers: {}
    )

    expect(Nanook.new.node.keepalive(address: '::ffff:138.201.94.249', port: '7075')).to be true
  end

  it 'should request bootstrap correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"bootstrap","address":"::ffff:138.201.94.249","port":"7075"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success":""}',
      headers: {}
    )

    expect(Nanook.new.node.bootstrap(address: '::ffff:138.201.94.249', port: '7075')).to be true
  end

  it 'should request bootstrap correctly when error' do
    stub_request(:post, uri).with(
      body: '{"action":"bootstrap","address":"::ffff:138.201.94.249","port":"7075"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{}',
      headers: {}
    )

    expect(Nanook.new.node.bootstrap(address: '::ffff:138.201.94.249', port: '7075')).to be false
  end

  it 'should request bootstrap_any correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"bootstrap_any"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success":""}',
      headers: {}
    )

    expect(Nanook.new.node.bootstrap_any).to be true
  end

  it 'should request bootstrap_any correctly when error' do
    stub_request(:post, uri).with(
      body: '{"action":"bootstrap_any"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{}',
      headers: {}
    )

    expect(Nanook.new.node.bootstrap_any).to be false
  end

  it 'should request bootstrap_lazy correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"bootstrap_lazy","hash":"FF0144381CFF0B2C079A115E7ADA7E96F43FD219446E7524C48D1CC9900C4F17","force":"false"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"started":"1"}',
      headers: {}
    )

    response = Nanook.new.node.bootstrap_lazy('FF0144381CFF0B2C079A115E7ADA7E96F43FD219446E7524C48D1CC9900C4F17')
    expect(response).to eq(true)
  end

  it 'should request bootstrap_lazy correctly with error' do
    stub_request(:post, uri).with(
      body: '{"action":"bootstrap_lazy","hash":"FF0144381CFF0B2C079A115E7ADA7E96F43FD219446E7524C48D1CC9900C4F17","force":"false"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"started":"0"}',
      headers: {}
    )

    response = Nanook.new.node.bootstrap_lazy('FF0144381CFF0B2C079A115E7ADA7E96F43FD219446E7524C48D1CC9900C4F17')
    expect(response).to eq(false)
  end

  it 'should request bootstrap_lazy with force correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"bootstrap_lazy","hash":"FF0144381CFF0B2C079A115E7ADA7E96F43FD219446E7524C48D1CC9900C4F17","force":"true"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"started":"1"}',
      headers: {}
    )

    response = Nanook.new.node.bootstrap_lazy('FF0144381CFF0B2C079A115E7ADA7E96F43FD219446E7524C48D1CC9900C4F17',
                                              force: true)
    expect(response).to eq(true)
  end

  it 'should request representatives correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"representatives"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"representatives":{"nano_1111111111111111111111111111111111111111111111111117353trpda":"3822372327060170000000000000000000000","nano_1111111111111111111111111111111111111111111111111awsq94gtecn":"30999999999999999999999999000000","nano_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi":"0"}}',
      headers: {}
    )

    response = Nanook.new.node.representatives
    expect(response).to have_key(:nano_1111111111111111111111111111111111111111111111111117353trpda)
    expect(response[:nano_1111111111111111111111111111111111111111111111111117353trpda]).to eq(3_822_372.32706017)
  end

  it 'should request representatives with unit correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"representatives"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"representatives":{"nano_1111111111111111111111111111111111111111111111111117353trpda":"3822372327060170000000000000000000000","nano_1111111111111111111111111111111111111111111111111awsq94gtecn":"30999999999999999999999999000000","nano_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi":"0"}}',
      headers: {}
    )

    response = Nanook.new.node.representatives(unit: :raw)
    expect(response).to have_key(:nano_1111111111111111111111111111111111111111111111111117353trpda)
    expect(response[:nano_1111111111111111111111111111111111111111111111111117353trpda]).to eq(3_822_372_327_060_170_000_000_000_000_000_000_000)
  end

  it 'should request representatives_online correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"representatives_online"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"representatives":["nano_1111111111111111111111111111111111111111111111111117353trpda","nano_1111111111111111111111111111111111111111111111111awsq94gtecn","nano_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi"]}',
      headers: {}
    )

    response = Nanook.new.node.representatives_online
    expect(response).to have(3).items
    expect(response.first).to eq('nano_1111111111111111111111111111111111111111111111111117353trpda')
  end

  it 'should request difficulty correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"active_difficulty","include_trend":"false"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"network_minimum":"ffffffc000000000","network_current":"ffffffcdbf40aa45","multiplier":"1.273557846739298"}',
      headers: {}
    )

    response = Nanook.new.node.difficulty
    expect(response).to eq({
                             network_minimum: 'ffffffc000000000',
                             network_current: 'ffffffcdbf40aa45',
                             multiplier: 1.273557846739298
                           })
  end

  it 'should request difficulty with include_trend correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"active_difficulty","include_trend":"true"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"network_minimum":"ffffffc000000000","network_current":"ffffffcdbf40aa45","multiplier":"1.273557846739298","difficulty_trend":["1.156096135149775","1.190133894573061"]}',
      headers: {}
    )

    response = Nanook.new.node.difficulty(include_trend: true)
    expect(response).to eq({
                             network_minimum: 'ffffffc000000000',
                             network_current: 'ffffffcdbf40aa45',
                             multiplier: 1.273557846739298,
                             difficulty_trend: [
                               1.156096135149775,
                               1.190133894573061
                             ]
                           })
  end

  it 'should request peers correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"peers","peer_details":"true"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"peers":{"[::ffff:172.17.0.1]:32841":"3"}}',
      headers: {}
    )

    expect(Nanook.new.node.peers).to have_key('[::ffff:172.17.0.1]:32841')
  end

  it 'change receive minimum' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"receive_minimum_set\",\"amount\":\"1000000001000000000000000000000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success": ""}',
      headers: {}
    )

    expect(Nanook.new.node.change_receive_minimum(1.000000001)).to be true
  end

  it 'change receive minimum in raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"receive_minimum_set\",\"amount\":\"1000000001000000000000000000000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success": ""}',
      headers: {}
    )

    expect(Nanook.new.node.change_receive_minimum(1000000001000000000000000000000, unit: :raw)).to be true
  end

  it 'search pending' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"search_pending_all\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success": ""}',
      headers: {}
    )

    expect(Nanook.new.node.search_pending).to eq true
  end

  it 'receive minimum' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"receive_minimum\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"amount": "10000000000000000000000000000000"}',
      headers: {}
    )

    expect(Nanook.new.node.receive_minimum).to eq(10.0)
  end

  it 'receive minimum unit raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"receive_minimum\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"amount": "1000000000000000000000000"}',
      headers: {}
    )

    expect(Nanook.new.node.receive_minimum(unit: :raw)).to eq(1000000000000000000000000)
  end

  it 'should request confirmation_quorum correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"confirmation_quorum"}',
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
      {
        "quorum_delta": "41469707173777717318245825935516662250",
        "online_weight_quorum_percent": "50",
        "online_weight_minimum": "60000000000000000000000000000000000000",
        "online_stake_total": "82939414347555434636491651871033324568",
        "peers_stake_total": "69026910610720098597176027400951402360",
        "peers_stake_required": "60000000000000000000000000000000000000"
      }
      BODY
      headers: {}
    )

    response = Nanook.new.node.confirmation_quorum
    expect(response).to eq({
      "quorum_delta": 41469707.17377772,
      "online_weight_quorum_percent": 50,
      "online_weight_minimum": 60000000.0,
      "online_stake_total": 82939414.34755543,
      "peers_stake_total": 69026910.6107201,
      "peers_stake_required": 60000000.0
    })
  end

  it 'should request confirmation_quorum correctly, unit: :raw' do
    stub_request(:post, uri).with(
      body: '{"action":"confirmation_quorum"}',
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
      {
        "quorum_delta": "41469707173777717318245825935516662250",
        "online_weight_quorum_percent": "50",
        "online_weight_minimum": "60000000000000000000000000000000000000",
        "online_stake_total": "82939414347555434636491651871033324568",
        "peers_stake_total": "69026910610720098597176027400951402360",
        "peers_stake_required": "60000000000000000000000000000000000000"
      }
      BODY
      headers: {}
    )

    response = Nanook.new.node.confirmation_quorum(unit: :raw)
    expect(response).to eq({
      "quorum_delta": 41469707173777717318245825935516662250,
      "online_weight_quorum_percent": 50,
      "online_weight_minimum": 60000000000000000000000000000000000000,
      "online_stake_total": 82939414347555434636491651871033324568,
      "peers_stake_total": 69026910610720098597176027400951402360,
      "peers_stake_required": 60000000000000000000000000000000000000
    })
  end

  it 'should request stop correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"stop"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success":""}',
      headers: {}
    )

    expect(Nanook.new.node.stop).to be true
  end

  it 'should request uptime correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"uptime"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"seconds":"6000"}',
      headers: {}
    )

    expect(Nanook.new.node.uptime).to eq(6000)
  end

  it 'should request version correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"version"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"rpc_version":"1","store_version":"2","node_vendor":"RaiBlocks 7.5.0"}',
      headers: {}
    )

    expect(Nanook.new.node.version).to have_key(:rpc_version)
  end

  it 'should request frontier_count correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"frontier_count"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"count":"100"}',
      headers: {}
    )

    # frontier_count is an alias of account_count
    expect(Nanook.new.node.frontier_count).to eq 100
  end

  it 'should show block_count progress as a percentage with sync_process' do
    stub_request(:post, uri).with(
      body: '{"action":"block_count"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"count":"1000","unchecked":"5"}',
      headers: {}
    )

    expect(Nanook.new.node.sync_progress).to eq 99.50248756218906
  end

  it 'should show synchronizing_blocks' do
    stub_request(:post, uri).with(
      body: '{"action":"unchecked","count":"1000"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":{"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F":"{\\"type\\": \\"open\\",\\"account\\": \\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\",\\"representative\\": \\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\",\\"source\\": \\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\\",\\"work\\": \\"0000000000000000\\",\\"signature\\":\\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\\"}","000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3C":"{\\"type\\": \\"open\\",\\"account\\": \\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\",\\"representative\\": \\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\",\\"source\\": \\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\\",\\"work\\": \\"0000000000000000\\",\\"signature\\":\\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\\"}"}}',
      headers: {}
    )

    response = Nanook.new.node.synchronizing_blocks

    expect(response).to have(2).items

    block = response['000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F']

    expect(block[:type]).to eq 'open'
    expect(block[:account]).to eq 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
    expect(block[:representative]).to eq 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
    expect(block[:source]).to eq 'FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4'
    expect(block[:work]).to eq '0000000000000000'
    expect(block[:signature]).to eq '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
  end

  it 'should show synchronizing_blocks with limit' do
    stub_request(:post, uri).with(
      body: '{"action":"unchecked","count":"1"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks": {"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F": "{\\"type\\": \\"open\\",\\"account\\": \\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\",\\"representative\\": \\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\\",\\"source\\": \\"FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4\\",\\"work\\": \\"0000000000000000\\",\\"signature\\":\\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\\"}"}}',
      headers: {}
    )

    response = Nanook.new.node.synchronizing_blocks(limit: 1)

    expect(response).to have(1).item

    block = response['000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F']

    expect(block[:type]).to eq 'open'
    expect(block[:account]).to eq 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
    expect(block[:representative]).to eq 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
    expect(block[:source]).to eq 'FA5B51D063BADDF345EFD7EF0D3C5FB115C85B1EF4CDE89D8B7DF3EAF60A04A4'
    expect(block[:work]).to eq '0000000000000000'
    expect(block[:signature]).to eq '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
  end
end
