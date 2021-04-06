# frozen_string_literal: true

RSpec.describe Nanook::Block do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:block) { '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F' }

  it 'should request account correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_account\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"account":"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"}',
      headers: {}
    )

    response = Nanook.new.block(block).account
    expect(response).to be_kind_of Nanook::Account
    expect(response.id).to eq 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
  end

  it 'should request cancel_work correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_cancel\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{}',
      headers: {}
    )

    expect(Nanook.new.block(block).cancel_work).to be true
  end

  it 'should request chain correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to have(1).item
  end

  it 'should request chain and when no blocks (empty string response) return an array' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to eq []
  end

  it 'should request chain with a limit correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain(limit: 1)).to have(1).item
  end

  it 'should request chain with an offset correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain(offset: 1)).to have(1).item
  end

  it 'should alias ancestors to chain correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).ancestors).to have(1).item
  end

  it 'should request generate_work correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_generate\",\"hash\":\"#{block}\",\"use_peers\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"work":"2bf29ef00786a6bc"}',
      headers: {}
    )

    expect(Nanook.new.block(block).generate_work).to eq '2bf29ef00786a6bc'
  end

  it 'should request generate_work correctly with optional param user_peers true' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_generate\",\"hash\":\"#{block}\",\"use_peers\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"work":"2bf29ef00786a6bc"}',
      headers: {}
    )

    expect(Nanook.new.block(block).generate_work(use_peers: true)).to eq '2bf29ef00786a6bc'
  end

  it 'should request block_confirm correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_confirm\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"started":"1"}',
      headers: {}
    )

    expect(Nanook.new.block(block).confirm).to eq true
  end

  it 'should request confirmed_recently? correctly when hash is in confirmation history' do
    stub_request(:post, uri).with(
      body: '{"action":"confirmation_history"}',
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"confirmations\": [
          {
            \"hash\": \"#{block}\",
            \"tally\": \"80394786589602980996311817874549318248\"
          },
          {
            \"hash\": \"F2F8DA6D2CA0A4D78EB043A7A29E12BDE5B4CE7DE1B99A93A5210428EE5B8667\",
            \"tally\": \"68921714529890443063672782079965877749\"
          }
        ]
      }",
      headers: {}
    )

    expect(Nanook.new.block(block).confirmed_recently?).to eq true
  end

  it 'should request confirmed_recently? correctly when hash is not in confirmation history' do
    stub_request(:post, uri).with(
      body: '{"action":"confirmation_history"}',
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"confirmations\": [
          {
            \"hash\": \"EA70B32C55C193345D625F766EEA2FCA52D3F2CCE0B3A30838CC543026BB0FEA\",
            \"tally\": \"80394786589602980996311817874549318248\"
          },
          {
            \"hash\": \"F2F8DA6D2CA0A4D78EB043A7A29E12BDE5B4CE7DE1B99A93A5210428EE5B8667\",
            \"tally\": \"68921714529890443063672782079965877749\"
          }
        ]
      }",
      headers: {}
    )

    expect(Nanook.new.block(block).confirmed_recently?).to eq false
  end

  it 'should request info correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
          "amount": "30000000000000000000000000000000000",
          "balance": "5606157000000000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "5606157000000000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "send"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.block(block).info

    expect(response).to eq(
      {
        "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
        "amount": 30000.0,
        "balance": 5606157.0,
        "height": 58,
        "local_timestamp": 0,
        "checked": true,
        "confirmed": true,
        "id": "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F",
        "type": "state",
        "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
        "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
        "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
        "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
        "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
        "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
        "work": "8a142e07a10996d5",
        "subtype": "send"
      }
    )
  end

  it 'should request info correctly with unit as raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
          "amount": "30000000000000000000000000000000000",
          "balance": "5606157000000000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "5606157000000000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "send"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.block(block).info(unit: :raw)

    expect(response).to eq(
      {
        "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
        "amount": 30000000000000000000000000000000000,
        "balance": 5606157000000000000000000000000000000,
        "height": 58,
        "local_timestamp": 0,
        "confirmed": true,
        "checked": true,
        "id": "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F",
        "type": "state",
        "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
        "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
        "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
        "balance": 5606157000000000000000000000000000000,
        "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
        "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
        "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
        "work": "8a142e07a10996d5",
        "subtype": "send"
      }
    )
  end

  it 'should return block not found correctly on info' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"error":"Block not found"}',
      headers: {}
    )

    expect { Nanook.new.block(block).info } .to raise_error(Nanook::NodeRpcError)
  end

  it 'should request info allowing_unchecked when block is unchecked correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "modified_timestamp": "1565856525",
          "contents": {
            "type": "state",
            "account": "nano_1hmqzugsmsn4jxtzo5yrm4rsysftkh9343363hctgrjch1984d8ey9zoyqex",
            "previous": "009C587914611E83EE7F75BD9C000C430C720D0364D032E84F37678D7D012911",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "189012679592109992600249228",
            "link": "0000000000000000000000000000000000000000000000000000000000000000",
            "link_as_account": "nano_1111111111111111111111111111111111111111111111111111hifc8npp",
            "signature": "845C8660750895843C013CE33E31B80EF0A7A69E52DDAF74A5F1BDFAA9A52E4D9EA2C3BE1AB0BD5790FCC1AD9B7A3D2F4B44EECE4279A8184D414A30A1B4620F",
            "work": "0dfb32653e189699"
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.block(block).info(allow_unchecked: true)

    expect(response).to eq(
      {
        "modified_timestamp": 1565856525,
        "type": "state",
        "account": "nano_1hmqzugsmsn4jxtzo5yrm4rsysftkh9343363hctgrjch1984d8ey9zoyqex",
        "previous": "009C587914611E83EE7F75BD9C000C430C720D0364D032E84F37678D7D012911",
        "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
        "balance": 0.00018901267959211,
        "checked": false,
        "id": "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F",
        "link": 0,
        "link_as_account": "nano_1111111111111111111111111111111111111111111111111111hifc8npp",
        "signature": "845C8660750895843C013CE33E31B80EF0A7A69E52DDAF74A5F1BDFAA9A52E4D9EA2C3BE1AB0BD5790FCC1AD9B7A3D2F4B44EECE4279A8184D414A30A1B4620F",
        "work": "0dfb32653e189699"
      }
    )
  end

  it 'should request info allowing_unchecked when block is checked correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"error":"Block not found"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
          "amount": "30000000000000000000000000000000000",
          "balance": "5606157000000000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "5606157000000000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "send"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.block(block).info(allow_unchecked: true)

    expect(response).to eq(
      {
        "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
        "amount": 30000.0,
        "balance": 5606157.0,
        "height": 58,
        "local_timestamp": 0,
        "checked": true,
        "confirmed": true,
        "id": "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F",
        "type": "state",
        "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
        "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
        "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
        "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
        "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
        "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
        "work": "8a142e07a10996d5",
        "subtype": "send"
      }
    )
  end

  it 'should request republish correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    expect(Nanook.new.block(block).republish).to have(2).items
  end

  it 'should raise execption if both sources and destinations arguments passed to republish' do
    expect { Nanook.new.block(block).republish(sources: 2, destinations: 2) }.to raise_error(ArgumentError)
  end

  it 'should request republish with sources correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\",\"sources\":\"2\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    expect(Nanook.new.block(block).republish(sources: 2)).to have(2).items
  end

  it 'should request republish with destinations correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\",\"destinations\":\"2\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    Nanook.new.block(block).republish(destinations: 2)
  end

  it 'should request pending? correctly when block is pending' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending_exists\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"exists":"1"}',
      headers: {}
    )

    expect(Nanook.new.block(block).pending?).to be true
  end

  it 'should request pending? correctly when block is not pending' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending_exists\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"exists":"0"}',
      headers: {}
    )

    expect(Nanook.new.block(block).pending?).to be false
  end

  it 'should request process correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"process\",\"block\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"hash":"42A723D2B60462BF7C9A003FE9A70057D3A6355CA5F1D0A57581000000000000"}',
      headers: {}
    )

    Nanook.new.block(block).publish
  end

  it 'should request successors correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors).to have(1).item
  end

  it 'should request successors with limit correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors(limit: 1)).to have(1).item
  end

  it 'should request successors with offset correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors(offset: 1)).to have(1).item
  end

  it 'should request successors when there are none (empty string response) and return blank array' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors(limit: 1000)).to be_empty
  end

  it 'should request valid_work? correctly when valid' do
    work = '2bf29ef00786a6bc'

    stub_request(:post, uri).with(
      body: "{\"action\":\"work_validate\",\"hash\":\"#{block}\",\"work\":\"#{work}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"valid":"1"}',
      headers: {}
    )

    expect(Nanook.new.block(block).valid_work?(work)).to be true
  end

  it 'should request valid_work? correctly when not valid' do
    work = '2bf29ef00786a6bc'

    stub_request(:post, uri).with(
      body: "{\"action\":\"work_validate\",\"hash\":\"#{block}\",\"work\":\"#{work}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"valid":"0"}',
      headers: {}
    )

    expect(Nanook.new.block(block).valid_work?(work)).to be false
  end
end
