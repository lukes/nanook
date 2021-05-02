# frozen_string_literal: true

RSpec.describe Nanook::Block do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:block) { '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F' }

  it 'can compare equality' do
    block_1 = Nanook.new.block('foo')
    block_2 = Nanook.new.block('foo')
    block_3 = Nanook.new.block('bar')

    expect(block_1).to eq(block_2)
    expect(block_1).not_to eq(block_3)
  end

  it 'can be used as a hash key lookup' do
    hash = {
      Nanook.new.block('foo') => 'found'
    }

    expect(hash[Nanook.new.block('foo')]).to eq('found')
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
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to eq([
                                                  Nanook.new.block('111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
                                                ])
  end

  it 'should request chain and when no blocks (empty string response) return an array' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"0\"}",
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
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"2\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain(limit: 1)).to eq([
                                                            Nanook.new.block('111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
                                                          ])
  end

  it 'should request chain with an offset correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain(offset: 1)).to eq([
                                                             Nanook.new.block('111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
                                                           ])
  end

  it 'should alias ancestors to chain correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to eq([
                                                  Nanook.new.block('111D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
                                                ])
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
          "local_timestamp": "1617855149",
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
        "amount": 30_000.0,
        "balance": 5_606_157.0,
        "height": 58,
        "local_timestamp": Time.at(1_617_855_149),
        "confirmed": true,
        "id": '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F',
        "type": 'send',
        "account": Nanook.new.account('nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est'),
        "previous": Nanook.new.block('CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E'),
        "representative": Nanook.new.account('nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou'),
        "link": Nanook.new.block('5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5'),
        "link_as_account": Nanook.new.account('nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z'),
        "signature": '82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501',
        "work": '8a142e07a10996d5'
      }
    )
  end

  it 'should request info correctly when `type` is "state" and there is no `subtype`' do
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
          "local_timestamp": "1617855149",
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
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.block(block).info

    expect(response).to eq(
      {
        "amount": 30_000.0,
        "balance": 5_606_157.0,
        "height": 58,
        "local_timestamp": Time.at(1_617_855_149),
        "confirmed": true,
        "id": '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F',
        "type": 'state',
        "account": Nanook.new.account('nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est'),
        "previous": Nanook.new.block('CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E'),
        "representative": Nanook.new.account('nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou'),
        "link": Nanook.new.block('5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5'),
        "link_as_account": Nanook.new.account('nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z'),
        "signature": '82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501',
        "work": '8a142e07a10996d5'
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
          "local_timestamp": "1617855149",
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
        "amount": 30_000_000_000_000_000_000_000_000_000_000_000,
        "balance": 5_606_157_000_000_000_000_000_000_000_000_000_000,
        "height": 58,
        "local_timestamp": Time.at(1_617_855_149),
        "confirmed": true,
        "id": '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F',
        "type": 'send',
        "account": Nanook.new.account('nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est'),
        "previous": Nanook.new.block('CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E'),
        "representative": Nanook.new.account('nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou'),
        "link": Nanook.new.block('5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5'),
        "link_as_account": Nanook.new.account('nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z'),
        "signature": '82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501',
        "work": '8a142e07a10996d5'
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

    expect { Nanook.new.block(block).info }.to raise_error(Nanook::NodeRpcError)
  end

  it 'should request info allow_unchecked when block is unchecked correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "error":  "Block not found"
        }
      BODY
      headers: {}
    )

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
        "balance": 0.00018901267959211,
        "last_modified_at": Time.at(1_565_856_525),
        "confirmed": false,
        "id": block,
        "account": Nanook.new.account('nano_1hmqzugsmsn4jxtzo5yrm4rsysftkh9343363hctgrjch1984d8ey9zoyqex'),
        "previous": Nanook.new.block('009C587914611E83EE7F75BD9C000C430C720D0364D032E84F37678D7D012911'),
        "representative": Nanook.new.account('nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou'),
        "link": Nanook.new.block(0),
        "link_as_account": Nanook.new.account('nano_1111111111111111111111111111111111111111111111111111hifc8npp'),
        "signature": '845C8660750895843C013CE33E31B80EF0A7A69E52DDAF74A5F1BDFAA9A52E4D9EA2C3BE1AB0BD5790FCC1AD9B7A3D2F4B44EECE4279A8184D414A30A1B4620F',
        "type": 'state',
        "work": '0dfb32653e189699'
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
        "amount": 30_000.0,
        "balance": 5_606_157.0,
        "height": 58,
        "local_timestamp": Time.at(0),
        "confirmed": true,
        "id": '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F',
        "type": 'send',
        "account": Nanook.new.account('nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est'),
        "previous": Nanook.new.block('CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E'),
        "representative": Nanook.new.account('nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou'),
        "link": Nanook.new.block('5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5'),
        "link_as_account": Nanook.new.account('nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z'),
        "signature": '82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501',
        "work": '8a142e07a10996d5'
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

    expect(Nanook.new.block(block).republish.first).to be_kind_of(Nanook::Block)
    expect(Nanook.new.block(block).republish.map(&:id)).to eq(
      %w[
        991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948
        A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293
      ]
    )
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

  it 'should request successors correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    successors = Nanook.new.block(block).successors

    expect(successors).to eq([Nanook.new.block('A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293')])
  end

  it 'should request successors with limit correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"2\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    successors = Nanook.new.block(block).successors(limit: 1)

    expect(successors).to eq([Nanook.new.block('A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293')])
  end

  it 'should request successors with limit of -1 correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"-1\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    successors = Nanook.new.block(block).successors(limit: -1)

    expect(successors).to eq([Nanook.new.block('A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293')])
  end

  it 'should request successors with offset correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    successors = Nanook.new.block(block).successors(offset: 1)

    expect(successors).to eq([Nanook.new.block('A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293')])
  end

  it 'should request successors when there are none (empty string response) and return blank array' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors(limit: 1000)).to be_empty
  end

  it 'should request successors correctly when aliased as descendants' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1001\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    successors = Nanook.new.block(block).descendants

    expect(successors).to eq([Nanook.new.block('A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293')])
  end

  it 'should request valid_work? correctly when valid' do
    work = '2bf29ef00786a6bc'

    stub_request(:post, uri).with(
      body: "{\"action\":\"work_validate\",\"hash\":\"#{block}\",\"work\":\"#{work}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "valid_all": "0",
          "valid_receive": "1",
          "difficulty": "fffffff93c41ec94",
          "multiplier": "1.182623871097636" // calculated from the default base difficulty
        }
      BODY
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
      body: <<~BODY,
        {
          "valid_all": "0",
          "valid_receive": "0",
          "difficulty": "fffffff93c41ec94",
          "multiplier": "1.182623871097636" // calculated from the default base difficulty
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).valid_work?(work)).to be false
  end

  it 'should request type correctly' do
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

    expect(Nanook.new.block(block).type).to eq('send')
  end

  it 'should request send? correctly' do
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

    expect(Nanook.new.block(block)).to be_send
    expect(Nanook.new.block(block)).not_to be_open
    expect(Nanook.new.block(block)).not_to be_epoch
    expect(Nanook.new.block(block)).not_to be_change
    expect(Nanook.new.block(block)).not_to be_receive
  end

  it 'should request open? correctly' do
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
          "subtype": "open"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block)).to be_open
    expect(Nanook.new.block(block)).not_to be_send
    expect(Nanook.new.block(block)).not_to be_epoch
    expect(Nanook.new.block(block)).not_to be_change
    expect(Nanook.new.block(block)).not_to be_receive
  end

  it 'should request epoch? correctly' do
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
          "subtype": "epoch"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block)).to be_epoch
    expect(Nanook.new.block(block)).not_to be_send
    expect(Nanook.new.block(block)).not_to be_open
    expect(Nanook.new.block(block)).not_to be_change
    expect(Nanook.new.block(block)).not_to be_receive
  end

  it 'should request change? correctly' do
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
          "subtype": "change"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block)).to be_change
    expect(Nanook.new.block(block)).not_to be_send
    expect(Nanook.new.block(block)).not_to be_open
    expect(Nanook.new.block(block)).not_to be_epoch
    expect(Nanook.new.block(block)).not_to be_receive
  end

  it 'should request receive? correctly' do
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
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block)).to be_receive
    expect(Nanook.new.block(block)).not_to be_send
    expect(Nanook.new.block(block)).not_to be_open
    expect(Nanook.new.block(block)).not_to be_epoch
    expect(Nanook.new.block(block)).not_to be_change
  end

  it 'should request representative correctly' do
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
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    representative = Nanook.new.block(block).representative
    expect(representative).to be_kind_of(Nanook::Account)
    expect(representative.id).to eq('nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou')
  end

  it 'should request checked? correctly when block is checked' do
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
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block)).to be_checked
  end

  it 'should request checked? correctly when block is unchecked' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "error": "Block not found"
        }
      BODY
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"block_account":"nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est"}',
      headers: {}
    )

    expect(Nanook.new.block(block)).not_to be_checked
  end

  it 'should request unchecked? correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "error": "Block not found"
        }
      BODY
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
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
            "balance": "14360938463463374607431768211455",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block)).to be_unchecked
  end

  it 'should request amount correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_info\",\"hash\":\"#{block}\",\"json_block\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
          "amount": "340366928463463374607431768211455",
          "balance": "14360938463463374607431768211455",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "14360938463463374607431768211455",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).amount).to eq(340.3669284634633)
  end

  it 'should request amount correctly as raw' do
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
          "amount": "340366928463463374607431768211455",
          "balance": "14360938463463374607431768211455",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "14360938463463374607431768211455",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).amount(unit: :raw)).to eq(340_366_928_463_463_374_607_431_768_211_455)
  end

  it 'should request balance correctly' do
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
          "amount": "340366928463463374607431768211455",
          "balance": "14360938463463374607431768211455",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "14360938463463374607431768211455",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).balance).to eq(14.36093846346337)
  end

  it 'should request balance correctly as raw' do
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
          "amount": "340366928463463374607431768211455",
          "balance": "14360938463463374607431768211455",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "14360938463463374607431768211455",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).balance(unit: :raw)).to eq(14_360_938_463_463_374_607_431_768_211_455)
  end

  it 'should request height correctly' do
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
          "amount": "3100000000000000000000000000000000010000000000000000000000000",
          "balance": "3100000000000000000000000000000000010000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "3000000000000000000000000000000000010000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).height).to eq(58)
  end

  it 'should request confirmed? correctly' do
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
          "amount": "3100000000000000000000000000000000010000000000000000000000000",
          "balance": "3100000000000000000000000000000000010000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "3000000000000000000000000000000000010000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block)).to be_confirmed
  end

  it 'should request previous correctly' do
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
          "amount": "3100000000000000000000000000000000010000000000000000000000000",
          "balance": "3100000000000000000000000000000000010000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "3000000000000000000000000000000000010000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    previous = Nanook.new.block(block).previous

    expect(previous).to be_kind_of(Nanook::Block)
    expect(previous.id).to eq('CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E')
  end

  it 'should request next correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"2\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948","A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).next).to eq(
      Nanook.new.block('A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293')
    )
  end

  it 'should request work correctly' do
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
          "amount": "3100000000000000000000000000000000010000000000000000000000000",
          "balance": "3100000000000000000000000000000000010000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "3000000000000000000000000000000000010000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).work).to eq('8a142e07a10996d5')
  end

  it 'should request signature correctly' do
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
          "amount": "3100000000000000000000000000000000010000000000000000000000000",
          "balance": "3100000000000000000000000000000000010000000000000000000000000",
          "height": "58",
          "local_timestamp": "0",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "3000000000000000000000000000000000010000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.block(block).signature).to eq('82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501')
  end

  it 'should request timestamp correctly' do
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
          "amount": "3100000000000000000000000000000000010000000000000000000000000",
          "balance": "3100000000000000000000000000000000010000000000000000000000000",
          "height": "58",
          "local_timestamp": "1527698508",
          "confirmed": "true",
          "contents": {
            "type": "state",
            "account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
            "previous": "CE898C131AAEE25E05362F247760F8A3ACF34A9796A5AE0D9204E86B0637965E",
            "representative": "nano_1stofnrxuz3cai7ze75o174bpm7scwj9jn3nxsn8ntzg784jf1gzn1jjdkou",
            "balance": "3000000000000000000000000000000000010000000000000000000000000",
            "link": "5D1AA8A45F8736519D707FCB375976A7F9AF795091021D7E9C7548D6F45DD8D5",
            "link_as_account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
            "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
            "work": "8a142e07a10996d5"
          },
          "subtype": "receive"
        }
      BODY
      headers: {}
    )

    timestamp = Nanook.new.block(block).timestamp

    expect(timestamp).to eq(Time.at(1_527_698_508))
    expect(timestamp.zone).to eq('UTC')
  end
end
